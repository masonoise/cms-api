require 'sinatra'

module CmsMod
  class CmsApp < Sinatra::Base
    get '/' do
      @version = 'live'
      erb :index
    end

    get '/:ver' do
      @version = params[:ver]
      erb :index
    end
  end
end

