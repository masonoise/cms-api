#
# This module implements the end points of the CMS API.
#
module CmsApi
  # API Version 1
  class API_v1 < Grape::API
    include ApiLib

    # Set to true for debugging output
    DEBUG = true

    MongoMapper.connection = Mongo::Connection.new('127.0.0.1', 27017, :pool_size => 5, :pool_timeout => 5)
    MongoMapper.database = 'cms'
    #MongoMapper.database.authenticate('{user-name}','{user-password}')

    version 'v1', :using => :path, :vendor => 'cms_api', :format => :json

    resource :cms do
      desc "Gets a piece of text content in a version, or all versions if passed 'any'."
      get '/text/:page/:block/:v' do
        version = params[:v] || CmsContent::LIVE_STATE
        puts "Fetching: page=#{CGI::unescape(params[:page])}, block = #{params[:block]}, version = #{version}" if DEBUG
        conditions = { :page => "#{CGI::unescape(params[:page])}", :block => params[:block] }
        conditions[:version] = version unless version == CmsContent::ANY_STATE
        items = CmsContent.all(conditions)
        if (items == "null")
          result = []
        else
          result = {:result => items.to_json}
        end
        result
      end

      desc "Returns all text content of a given version."
      get '/text/all/:v' do
        puts "Fetching all text of version #{params[:v]}" if DEBUG
        version = params[:v] || CmsContent::LIVE_STATE
        { :result => CmsContent.all(:version => version) }
      end

      desc "Updates content item."
      post '/:ctype/:page/:block/:v' do
        puts "Updating content #{params[:page]}/#{params[:block]}/#{params[:v]} with action=#{params[:action]}" if DEBUG
        # TODO: Make work for both text and file content items
        version = params[:v] || CmsContent::LIVE_STATE
        if (params[:action] == ApiLib::ACTION_DELETE)
          puts "--> Deleting" if DEBUG
          item = CmsContent.first(:page => "#{params[:page]}", :block => params[:block], :version => version)
          item.destroy
          { :result => "Deleted.", :item => "#{CGI::escape(params[:page])}/#{params[:block]}/#{version}" }
        elsif (params[:action] == ApiLib::ACTION_MAKE_LIVE)
          puts "--> Making live" if DEBUG
          { :result => ApiLib.make_live(params[:page], params[:block], version), :item => "#{CGI::escape(params[:page])}/#{params[:block]}/#{version}" }
        elsif (params[:action] == ApiLib::ACTION_REVERT)
          puts "--> Reverting" if DEBUG
          { :result => ApiLib.revert(params[:page], params[:block], version), :item => "#{CGI::escape(params[:page])}/#{params[:block]}/#{CmsContent::LIVE_STATE}" }
        elsif (params[:action] == ApiLib::ACTION_SAVE)
          puts "--> Saving changes" if DEBUG
          message = ApiLib.update_item(params[:page], params[:block], version, params)
          puts "--> Response: #{message}"
          # Return item with draft state, because saved changes will always apply to a draft version of the item
          { :result => message, :item => "#{CGI::escape(params[:page])}/#{params[:block]}/#{CmsContent::DRAFT_STATE}" }
        else
          puts "Update called for unknown action: #{params[:action]}"
        end
      end

      desc "Adds content into Draft state."
      post '/new' do
        # Check if the item already exists in draft state
        item = CmsContent.first(:page => params[:page], :block => params[:block], :version => CmsContent::DRAFT_STATE)
        if (!item.nil?)
          puts "Tried to create new content for existing page=#{params[:page]}, block=#{params[:block]}, draft"
          { :status => 'Item already exists!' }
        else
          # Required: content, title, page, block, ctype
          error!("missing :content", 400) unless (params[:content] && params[:content].length > 0)
          error!("missing :title", 400) unless (params[:title] && params[:title].length > 0)
          error!("missing :page", 400) unless (params[:page] && params[:content].length > 0)
          error!("missing :block", 400) unless (params[:block] && params[:content].length > 0)
          error!("missing :ctype", 400) unless (params[:ctype] && params[:ctype].length > 0)
          author = params[:author] || "Unknown"
          item = CmsContent.create(:title => params[:title],
                                   :content => params[:content],
                                   :page => params[:page],
                                   :block => params[:block],
                                   :type => params[:ctype],
                                   :version => CmsContent::DRAFT_STATE,
                                   :created_at => Time.new.to_i,
                                   :last_updated => Time.new.to_i,
                                   :last_updated_by => author)
          { :status => "Saved as draft." }
        end
      end

    end
  end
end
