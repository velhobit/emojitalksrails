# app/models/post.rb
class Post
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :uuid, type: String
  field :title, type: String
  field :content, type: String
  field :forum_id, type: BSON::ObjectId
  field :author_id, type: BSON::ObjectId
  field :closure_date, type: DateTime
  field :deletion_date, type: DateTime

  # Callbacks
  before_create :generate_uuid
  
  private
  
  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
  
  # Associations
  belongs_to :forum
  belongs_to :author, class_name: 'User'
  has_many :comments
end