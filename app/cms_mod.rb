require 'sinatra'

module CmsMod
  class CmsApp < Sinatra::Base
    get '/' do
      erb :index
    end
  end
end

