class TextContent
  include MongoMapper::Document

  key :title, String
  key :content, String
  key :author, Integer
end
