module CmsApi
  class API_v1 < Grape::API
    ACTION_DELETE = 'delete'
    ACTION_MAKE_LIVE = 'make_live'

    MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017, :pool_size => 5, :pool_timeout => 5)
    MongoMapper.database = 'cms'
    #MongoMapper.database.authenticate('{user-name}','{user-password}')

    version 'v1', :using => :path, :vendor => 'cms_api', :format => :json

    resource :cms do
      desc "Gets content."
      get '/:page/:block/:v' do
        version = params[:v] || CmsContent::LIVE_STATE
        item = CmsContent.first(:page => "/#{params[:page]}", :block => params[:block], :version => version)
        if (item == "null")
          {:result => "Not found"}
        else
          {:result => item.to_json}
        end
      end

      desc "Lists content."
      get '/all/:v' do
        version = params[:v] || CmsContent::LIVE_STATE
        { :result => CmsContent.all(:version => version) }
      end

      desc "Updates content."
      post '/:page/:block/:v' do
        version = params[:v] || CmsContent::LIVE_STATE
        if (params[:action] == ACTION_DELETE)
          item = CmsContent.first(:page => "/#{params[:page]}", :block => params[:block], :version => version)
          item.destroy
          { :result => "Deleted." }
        elsif (params[:action] == ACTION_MAKE_LIVE)
          puts "Make live called for: /#{params[:page]}/#{params[:block]}/#{version}"
          item = CmsContent.first(:page => "/#{params[:page]}", :block => params[:block], :version => version)
          item.version = CmsContent::LIVE_STATE
          item.save
          { :result => "Promoted to live." }
        else
          puts "Update called for unknown action: #{params[:action]}"
        end
      end

      desc "Adds content."
      post '/' do
        # TODO: check if item with /page/block already exists!
        error!("missing :content", 400) unless (params[:content] && params[:content].length > 0)
        error!("missing :content", 400) if (params[:content] == "undefined")
        error!("missing :title", 400) if (params[:title] == "undefined")
        error!("missing :page", 400) unless (params[:page] && params[:content].length > 0)
        error!("missing :block", 400) unless (params[:block] && params[:content].length > 0)
        title = params[:title] || "Untitled"
        tc = CmsContent.create(:title => title,
            :content => params[:content],
            :page => params[:page],
            :block => params[:block],
            :type => "text",
            :version => CmsContent::DRAFT_STATE,
            :author => "Mason")
        { :result => "Saved as draft." }
      end

    end
  end
end
