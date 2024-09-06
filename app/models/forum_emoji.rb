# app/models/forum_emoji.rb
class ForumEmoji
  include Mongoid::Document

  field :forum_id, type: BSON::ObjectId
  field :emoji, type: String

  # Associations
  belongs_to :forum
end