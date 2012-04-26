class CmsContent
  include MongoMapper::Document

  key :title, String
  key :content, String
  key :page, String
  key :block, String
  key :type, String
  key :version, String
  key :last_updated_by, String
  key :last_update, Integer
  key :created_at, Integer

  LIVE_STATE = "live"
  DRAFT_STATE = "draft"
  RETIRED_STATE = "retired"
  ANY_STATE = "any"
end
