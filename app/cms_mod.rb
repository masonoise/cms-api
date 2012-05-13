require 'sinatra'
require 'cgi'
require 'sinatra/content_for2'
require 'rack-flash'

module CmsMod
  class CmsApp < Sinatra::Base
    enable :sessions
    use Rack::Flash
    helpers Sinatra::ContentFor2

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
        flash[:notice] = "#{@status['status']}"
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
    # Called to show a single content item, which could be text or file. It will get all of the
    # versions of the item.
    #
    get '/show/:ctype/:page/:block/:ver' do
      #puts "Showing #{request.scheme}://#{request.host}:#{request.port}/api/v1/cms#{params[:ctype]}/#{CGI::escape(params[:page])}/#{params[:block]}/#{params[:ver]}"
      result = HTTParty.get("#{request.scheme}://#{request.host}:#{request.port}/api/v1/cms/#{params[:ctype]}/#{CGI::escape(params[:page])}/#{params[:block]}/any").parsed_response['result']
      @items = JSON.parse(result) rescue @items = Array.new
      @item = nil
      @items.each do |i|
        @item = i if (i['version'] == params[:ver]) # Grab the one that was specifically requested
      end
      @items.delete(@item) if !(@item.nil?)
      erb :show
    end

    post '/update/:ctype/:page/:block/:ver' do
      action_item = "#{params[:ctype]}/#{CGI::escape(params[:page])}/#{params[:block]}/#{params[:ver]}"
      action = params[:action].downcase
      action = "make_live" if action == "make live" # Because of stupid form button
      puts "Update! For: #{action_item}, action=#{action}"
      if (action == ApiLib::ACTION_SAVE)
        response = HTTParty.post("#{request.scheme}://#{request.host}:#{request.port}/api/v1/cms/#{action_item}",
            :body => {
                :title => params[:title],
                :content => params[:content],
                :action => action
            })
        status = response.parsed_response['result']
        item = response.parsed_response['item']
        puts "Updated, status=#{status.inspect}, item=#{item.inspect}"

        #result = HTTParty.get("#{request.scheme}://#{request.host}:#{request.port}/api/v1/cms/#{params[:ctype]}/#{CGI::escape(params[:page])}/#{params[:block]}/#{params[:ver]}").parsed_response['result']
        #item = JSON.parse(result)[0] rescue @item = Hash.new
        redirect to("/show/text/#{item}?status=#{CGI::escape(status)}")
      else
        response = HTTParty.post("#{request.scheme}://#{request.host}:#{request.port}/api/v1/cms/#{action_item}",
            :body => {
                :action => action
            })
        status = response.parsed_response['result']
        if ((action == ApiLib::ACTION_MAKE_LIVE) || (action == ApiLib::ACTION_REVERT))
          redirect to("/show/text/#{CGI::escape(params[:page])}/#{params[:block]}/#{CmsContent::LIVE_STATE}?status=#{CGI::escape(status)}")
        else
          redirect to("/live?status=#{CGI::escape(status)}")
        end
      end
    end
  end
end

