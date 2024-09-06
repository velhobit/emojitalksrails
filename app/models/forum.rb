# app/models/forum.rb
class Forum
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :name, type: String
  field :alias, type: String
  field :description, type: String
  field :main_color, type: String
  field :uuid, type: String

  # Callbacks
  before_create :generate_uuid
  
  private
  
  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
  
  # Validations
  validates :name, presence: true, uniqueness: true

  # Associations
  has_many :forum_emojis
  has_many :posts, foreign_key: 'forum_id'
end