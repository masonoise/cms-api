module ApiLib
  ACTION_DELETE = 'delete'
  ACTION_MAKE_LIVE = 'make_live'
  ACTION_SAVE = 'save'

  def self.make_live(page, block, version, author = "Unknown")
    if (version != CmsContent::DRAFT_STATE)
      return "Error: Cannot make non-draft item live!"
    else
      puts "--> Make live"
      item = CmsContent.first(:page => page, :block => block, :version => version)
      return "Error: Could not find item!" if item.nil?
      # Is there already a live version? If so, make that one retired
      message = "Promoted to live."
      live_item = CmsContent.first(:page => page, :block => block, :version => CmsContent::LIVE_STATE)
      if (live_item)
        puts "--> Retiring existing live item"
        retired_item = CmsContent.first(:page => page, :block => block, :version => CmsContent::RETIRED_STATE)
        retired_item.destroy if (retired_item)
        live_item.version = CmsContent::RETIRED_STATE
        live_item.last_updated = Time.new.to_i
        live_item.last_updated_by = author
        live_item.save
        message = "Promoted to live. Existing live item retired."
      end
      item.version = CmsContent::LIVE_STATE
      item.last_updated = Time.new.to_i
      item.last_updated_by = author
      item.save
      return message
    end
  end

  def self.update_item(page, block, version, params, author = "Unknown")
    item = CmsContent.first(:page => page, :block => block, :version => version)
    return "Error: Could not find item!" if item.nil?
    # Are we updating a live item? If so, make this a new draft copy.
    if (version == CmsContent::LIVE_STATE)
      # Is there already a draft copy? If so, just update it.
      draft_item = CmsContent.first(:page => page, :block => block, :version => CmsContent::DRAFT_STATE)
      if (!draft_item.nil?)
        draft_item.title = params[:title]
        draft_item.content = params[:content]
        item.last_updated = Time.new.to_i
        item.last_updated_by = author
        draft_item.save
        message = "Changes saved: existing draft version updated."
      else
        item = CmsContent.create(:title => params[:title],
            :content => params[:content],
            :page => page,
            :block => block,
            :type => item.type,
            :version => CmsContent::DRAFT_STATE,
            :created_at => Time.new.to_i,
            :last_updated => Time.new.to_i,
            :last_updated_by => author)
        message = "Changes saved to new draft version."
      end
    elsif (version == CmsContent::DRAFT_STATE)
      item.title = params[:title]
      item.content = params[:content]
      item.last_updated = Time.new.to_i
      item.last_updated_by = author
      item.save
      message = "Changes saved."
    else
      message = "Cannot edit a retired item!"
    end
    return message
  end
end