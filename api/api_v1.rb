module CmsApi
  class API_v1 < Grape::API
    MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017, :pool_size => 5, :pool_timeout => 5)
    MongoMapper.database = 'cms'
    #MongoMapper.database.authenticate('{user-name}','{user-password}')

    version 'v1', :using => :path, :vendor => 'cms_api', :format => :json

    resource :cms do
      desc "Gets content."
      get '/text/:id' do
        if (params[:id] == "all")
          { :result => TextContent.all }
        else
          tc = TextContent.find_by_id(params[:id])
          if (tc == "null")
            { :result => "Not found" }
          else
            { :result => tc.to_json }
          end
        end
      end

      desc "Updates content."
      post '/text/:id' do
        if (params[:delete] == "true")
          tc = TextContent.find_by_id(params[:id])
          tc.destroy
          { :result => "Deleted." }
        else
          puts "Update called but not deleting?"
        end
      end

      desc "Adds content."
      post :text do
        error!("missing :content", 400) unless (params[:content] && params[:content].length > 0)
        error!("missing :content", 400) if (params[:content] == "undefined")
        error!("missing :title", 400) if (params[:title] == "undefined")
        error!("missing :page", 400) unless (params[:page] && params[:content].length > 0)
        error!("missing :block", 400) unless (params[:block] && params[:content].length > 0)
        title = params[:title] || "Untitled"
        tc = TextContent.create(:title => title,
            :content => params[:content],
            :page => params[:page],
            :block => params[:block],
            :author => "Mason")
        { :result => "Saved." }
      end

    end
  end
end
