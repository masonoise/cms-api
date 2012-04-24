module RpxCms
  class API < Grape::API
    mount ::RpxCms::API_v1
  end
end

