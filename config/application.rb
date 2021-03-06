require File.expand_path('../boot', __FILE__)

Bundler.require :default, ENV['RACK_ENV']

Dir[File.expand_path('../../api/lib/*.rb', __FILE__)].each do |f|
  require f
end
Dir[File.expand_path('../../api/api_v*.rb', __FILE__)].each do |f|
  require f
end
Dir[File.expand_path('../../app/models/*.rb', __FILE__)].each do |f|
  require f
end

require File.expand_path('../../api/api.rb', __FILE__)
require File.expand_path('../../app/cms_api_app.rb', __FILE__)
require File.expand_path('../../app/cms_mod.rb', __FILE__)
require File.expand_path('../aws_credentials.rb', __FILE__)
