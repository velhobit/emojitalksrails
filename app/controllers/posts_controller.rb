# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  before_action :set_post, only: %i[show update destroy like unlike]
  before_action :set_current_user, only: %i[index show]
  before_action :authorize_request, only: %i[create update destroy like unlike]

  # GET /posts
  def index
    @posts = Post.includes(:forum, :author, :comments)
                 .order(last_update_date: :desc, created_at: :desc)
                 .page(params[:page])
                 .per(10)
    render json: @posts.as_json(
      current_user_id: @current_user&.id,
      include: {
        forum: { except: [:_id], include: {
          forum_emojis: { only: :emoji }
        }},
        author: { only: [:name, :profile_picture, :theme_color, :description] }
      },
      except: [:_id]
    )
  end
  
  # GET /posts/:uuid
  def show
    @post = Post.includes(:forum, :author, :comments).find_by(uuid: params[:uuid])
    render json: @post.as_json(
      current_user_id: @current_user&.id,
      methods: [:time_since_posted, :comment_count],  # Incluindo comment_count
      include: {
        forum: { except: [:_id], include: {
          forum_emojis: { only: :emoji }
        }},
        author: { only: [:name, :profile_picture, :theme_color, :description] }
      },
      except: [:_id],
      methods: [:emoji] # Inclui o emoji no retorno
    )
  end

  # POST /posts
  def create
    @post = Post.new(post_params.merge(author_id: @current_user.id)) # Define o author_id a partir do usuário logado
    if @post.save
      render json: @post.as_json(
        include: {
          forum: { only: [:name] },
          author: { only: [:name, :profile_picture, :theme_color, :description] }
        },
      ), status: :created, location: @post
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /posts/:id
  def update
    if @post.update(post_params)
      render json: @post.as_json(
        methods: :time_since_posted,
        include: {
          forum: { only: [:name] },
          author: { only: [:name, :profile_picture, :theme_color, :description] }
        },
        methods: [:emoji] # Inclui o emoji no retorno
      )
    else
      render json: @post.errors, status: :unprocessable_entity
    end
  end
  
  # POST /posts/:uuid/like
  def like
    user_id = @current_user.id
  
    # Checa se o usuário já curtiu o post para evitar duplicatas
    if @post.liked_by.include?(user_id)
      render json: { error: 'User has already liked this post' }, status: :unprocessable_entity
    else
      # Adiciona o ID do usuário ao array e incrementa o contador de likes
      if @post.push(liked_by: user_id) && @post.inc(likes_count: 1)
        render json: { likes_count: @post.likes_count }, status: :ok
      else
        render json: { error: 'Unable to like post' }, status: :unprocessable_entity
      end
    end
  end
  
  # DELETE /posts/:uuid/unlike
  def unlike
    user_id = @current_user.id
    
    # Verifica se o usuário já curtiu o post
    if @post.liked_by.include?(user_id)
      # Remove o ID do usuário do array e decrementa o contador de likes
      @post.pull(liked_by: user_id)
      @post.inc(likes_count: -1)
  
      render json: { likes_count: @post.likes_count }, status: :ok
    else
      render json: { error: 'User has not liked this post' }, status: :unprocessable_entity
    end
  end

  # DELETE /posts/:id
  def destroy
    @post.destroy
  end

  private
  
  def comment_count
    Comment.where(post_id: self.id).count # Conta comentários pelo post_id
  end

  def set_post
    @post = Post.find_by(uuid: params[:uuid])
    render json: { error: 'Post not found' }, status: :not_found unless @post
  end

  # Autoriza a requisição e define o usuário logado
  def authorize_request
    token = request.headers['Authorization']&.split(' ')&.last
    decoded_token = User.decode_jwt(token)
    @current_user = User.find(decoded_token[:user_id]) if decoded_token

    render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
  end
  
  def set_current_user
      token = request.headers['Authorization']&.split(' ')&.last
      if token
        decoded_token = User.decode_jwt(token)
        @current_user = User.find(decoded_token[:user_id]) if decoded_token
      end
  end

  def post_params
    params.require(:post).permit(:uuid, :title, :content, :forum_id, :emoji) # Permite o emoji nos parâmetros
  end
end