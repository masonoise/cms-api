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
      @content_list = HTTParty.get("#{request.scheme}://#{request.host}:#{request.port}/api/v1/cms/all/#{@version}").parsed_response['result']
      erb :index
    end

    post '/new/:ctype' do
      response = HTTParty.post("#{request.scheme}://#{request.host}:#{request.port}/api/v1/cms/new",
          :body => {
              :title => params[:title],
              :content => params[:content],
              :page => params[:page],
              :block => params[:block],
              :ctype => params[:ctype]
          })
      @status = response.parsed_response #['result']
      redirect to("/show/#{CGI::escape(params[:page])}/#{params[:block]}/draft")
    end

    get '/show/:page/:block/:ver' do
      result = HTTParty.get("#{request.scheme}://#{request.host}:#{request.port}/api/v1/cms/get/#{CGI::escape(params[:page])}/#{params[:block]}/#{params[:ver]}").parsed_response['result']
      @item = JSON.parse(result)
      erb :show
    end

    post '/update' do
      puts "Update! For: #{params[:page]}/#{params[:block]}, action=#{params[:submit]}"
      puts "Params: #{params.inspect}"
      erb :show
    end
  end
end

