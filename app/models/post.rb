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
  field :last_update_date, type: DateTime
  field :emoji, type: String
  field :likes_count, type: Integer, default: 0
  field :liked_by, type: Array, default: []
  
  before_create :generate_uuid
  before_save :update_last_update_date
  
  # Associations
  belongs_to :forum
  belongs_to :author, class_name: 'User'
  has_many :comments

 # Método para obter o estado do like
 def is_liked
   @is_liked
 end
 
 # Método público para definir o valor de `is_liked`
 def set_is_liked(user_id)
   # Se user_id não estiver presente, define @is_liked como false
   @is_liked = user_id.present? && liked_by.include?(user_id)
 end
  
  def like(user)
    return if liked_by.include?(user.id)
  
    self.liked_by << user.id
    self.likes_count += 1
    save
  end
  
  # Método para remover um like do post
  def unlike(user)
    return unless liked_by.include?(user.id)
  
    self.liked_by.delete(user.id)
    self.likes_count -= 1
    save
  end

  # Método para contar comentários
  def comment_count
    comments.count
  end

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
 
# Personalizar o método as_json
  def as_json(options = {})
    set_is_liked(options[:current_user_id])
    super(options.merge(
      methods: [:comment_count, :time_since_posted, :emoji, :is_liked],
    ))
  end
  
  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end

  def update_last_update_date
    self.last_update_date = Time.current
  end
end