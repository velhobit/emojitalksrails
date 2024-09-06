# app/models/comment.rb
class Comment
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :uuid, type: String
  field :post_id, type: BSON::ObjectId
  field :author_id, type: BSON::ObjectId
  field :content, type: String

  # Callbacks
  before_create :generate_uuid
  
  private
  
  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
  
  # Associations
  belongs_to :post
  belongs_to :author, class_name: 'User'
end