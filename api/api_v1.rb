module RpxCms
  class API_v1 < Grape::API
    @@rang = 0
    version 'v1', :using => :path, :vendor => 'rpx', :format => :json
    resource :system do
      desc "Returns pong."
      get :ping do
        { :ping => "pong" }
      end
      get :ring do
        { :rang => @@rang }
      end
      post :ring do
        @@rang += 1
        { :rang => @@rang }
      end
      put :ring do
        error!("missing :count", 400) unless params[:count]
        @@rang += params[:count].to_i
        { :rang => @@rang }
      end
    end
    resource :cms do
      desc "Gets content."
      get :text do
        MongoMapper.connection = Mongo::Connection.new('127.0.0.1',27017, :pool_size => 5, :timeout => 5)
        MongoMapper.database = 'cms'
        #MongoMapper.database.authenticate('{user-name}','{user-password}')
        puts "Looking for content, id=#{params[:id]}"
        tc = TextContent.find_by_id(params[:id])
        tc.to_json
      end
      desc "Adds content."
      post :text do
        error!("missing :content", 400) unless params[:content]
        MongoMapper.connection = Mongo::Connection.new('127.0.0.1',27017, :pool_size => 5, :timeout => 5)
        MongoMapper.database = 'cms'
        #MongoMapper.database.authenticate('{user-name}','{user-password}')
        title = params[:title] || "Untitled"
        tc = TextContent.new(:title => title, :content => params[:content], :author => "Mason")
        puts "TextContent=#{tc.inspect}"
        tc.save
        { :result => "Saved." }
        puts "Saved, returning!"
      end
    end
  end
end
