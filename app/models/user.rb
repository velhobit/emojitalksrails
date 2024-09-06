# app/models/user.rb
require 'jwt'
require 'bcrypt'
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::SecurePassword

  field :name, type: String
  field :username, type: String
  field :email, type: String
  field :phone, type: String
  field :description, type: String
  field :profile_picture_url, type: String
  field :uuid, type: String
  field :theme_color, type: String
  field :password_digest, type: String

  # Enable password encryption and authentication
  has_secure_password

  # Validations
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, on: :create

  # Callbacks
  before_create :generate_uuid
  
  # JWT secret key
  SECRET_KEY = Rails.application.secrets.secret_key_base.to_s
  
  def generate_jwt
    payload = { user_id: id }
    self.class.encode_jwt(payload)
  end
  
  def self.encode_jwt(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end
  
  def self.decode_jwt(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new(decoded)
  rescue JWT::DecodeError => e
    nil
  end

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
end