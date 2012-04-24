module CmsApi
  class App
    def call(env)
      CmsApi::API.call(env)
    end
  end
end
