module RpxCms
  class App
    def call(env)
      RpxCms::API.call(env)
    end
  end
end
