class Comment
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :uuid, type: String
  field :post_id, type: BSON::ObjectId
  field :post_uuid, type: BSON::ObjectId
  field :author_id, type: BSON::ObjectId
  field :content, type: String
  
  before_validation :generate_uuid_and_find_post_id
    
  validates :post_uuid, presence: true
  validates :content, presence: true, length: { maximum: 50000 } 
  validates :author_id, presence: true

  # Callbacks

  # Método para calcular o tempo desde que foi postado
  def time_since_posted
    return 'Just now' if created_at > 5.minutes.ago

    time_diff = Time.current - created_at

    if time_diff < 2.hours
      "#{(time_diff / 1.minute).to_i} minutes ago"
    elsif time_diff < 2.days
      "#{(time_diff / 1.hour).to_i} hours ago"
    else
      days = (time_diff / 1.day).to_i
      hours = ((time_diff % 1.day) / 1.hour).to_i
      "#{days} days and #{hours} hours ago"
    end
  end

  private
  
  def generate_uuid_and_find_post_id
    self.uuid = SecureRandom.uuid
    post = Post.find_by(uuid: self.post_uuid)
  
    unless post
      # puts "Post not found for UUID: #{self.post_uuid}"  # Adicione esta linha para depuração
      errors.add(:post, "not found")
      throw(:abort)
    end
  
    self.post_id = post.id
  end
  
  # Associations
  belongs_to :post
  belongs_to :author, class_name: 'User'
end