require 'sinatra'
require 'cgi'

module CmsMod
  class CmsApp < Sinatra::Base
    get '/*favicon.ico' do
      halt
    end

    get '/' do
      redirect to('/live')
    end

    get '/:ver' do
      @version = params[:ver] || CmsContent::LIVE_STATE
      @content_list = HTTParty.get("#{request.scheme}://#{request.host}:#{request.port}/api/v1/cms/text/all/#{@version}").parsed_response['result']
      erb :index
    end

    post '/new/:ctype' do
      block_num = params[:block] || 0
      if (params[:ctype] == "text")
        response = HTTParty.post("#{request.scheme}://#{request.host}:#{request.port}/api/v1/cms/new",
            :body => {
                :title => params[:title],
                :content => params[:content],
                :page => params[:page],
                :block => block_num,
                :ctype => params[:ctype]
            })
        @status = response.parsed_response #['result']
        redirect to("/show/text/#{CGI::escape(params[:page])}/#{block_num}/draft")
      elsif (params[:ctype] == "file")
        # First get the file, then send it to S3, then invoke the API to store the reference info
        datafile = params[:the_file]
        s3 = AWS::S3.new(
            :access_key_id => AwsCredentials::ACCESS_KEY_ID,
            :secret_access_key => AwsCredentials::SECRET_ACCESS_KEY)
        cms_file = s3.buckets['cms_files'].objects["#{params[:page]}/#{datafile[:filename]}"]
        cms_file.write(File.read(datafile[:tempfile]))  # Send to S3 from the temp file
        # Now call the API to store the info about the file
        # >"url=%2Ftest%2Ffile&the_file=elongated-loris.jpg&description=Testing"}, @params={"page"=>"/test/file", "the_file"=>"elongated-loris.jpg", "description"=>"Testing"
        redirect to("/show/file/#{CGI::escape(params[:page])}/#{block_num}/draft")
      else
        puts "Oops, unknown content type #{params[:ctype]}!"
      end

    end

    #
    # Called to show a single content item, which could be text or file
    #
    get '/show/:ctype/:page/:block/:ver' do
      #puts "Showing #{request.scheme}://#{request.host}:#{request.port}/api/v1/cms#{params[:ctype]}/#{CGI::escape(params[:page])}/#{params[:block]}/#{params[:ver]}"
      result = HTTParty.get("#{request.scheme}://#{request.host}:#{request.port}/api/v1/cms/#{params[:ctype]}/#{CGI::escape(params[:page])}/#{params[:block]}/#{params[:ver]}").parsed_response['result']
      @item = JSON.parse(result)[0] rescue @item = Hash.new
      puts "Showing: #{@item.class} => #{@item.inspect}"
      erb :show
    end

    post '/update' do
      puts "Update! For: #{params[:page]}/#{params[:block]}, action=#{params[:submit]}"
      puts "Params: #{params.inspect}"
      erb :show
    end
  end
end

