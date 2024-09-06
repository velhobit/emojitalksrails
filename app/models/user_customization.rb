# app/models/user_customization.rb
class UserCustomization
  include Mongoid::Document

  field :uuid, type: String
  field :user_id, type: BSON::ObjectId
  field :profile_visibility, type: String # "public" or "private"
  field :favorite_emojis, type: Array
  field :app_color_mode, type: String # "dark", "light", "system"

  # Callbacks
  before_create :generate_uuid
  
  private
  
  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
  
  # Associations
  belongs_to :user
end