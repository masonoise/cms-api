module CmsApi
  class API < Grape::API
    mount ::CmsApi::API_v1
  end
end

