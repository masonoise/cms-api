module RpxCms
  class API < Grape::API
    prefix 'api'
    mount ::RpxCms::API_v1
  end
end

