require File.expand_path('../config/environment', __FILE__)

run RpxCms::App.new

require 'main'     
run Sinatra::Application

