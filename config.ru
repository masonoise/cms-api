require File.expand_path('../config/environment', __FILE__)

map "/" do
  #use CmsMod::CmsApp
  #run Sinatra::Base
  use Rack::Static, :urls => ["/stylesheets", "/images", "/img", "/scripts"], :root => "public"
  run CmsMod::CmsApp.new
end

map "/api" do
  run CmsApi::App.new
end
