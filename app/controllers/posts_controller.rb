# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  before_action :set_post, only: %i[show update destroy]
  before_action :authorize_request, only: %i[create update destroy]

  # GET /posts
  def index
    @posts = Post.includes(:forum, :author).order(last_update_date: :desc, created_at: :desc)
    render json: @posts.as_json(
      methods: [:time_since_posted, :comment_count],
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

  # GET /posts/:uuid
  def show
    render json: @post.as_json(
      methods: :time_since_posted,
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
        methods: :time_since_posted,
        include: {
          forum: { only: [:name] },
          author: { only: [:name, :profile_picture, :theme_color, :description] }
        },
        methods: [:emoji] # Inclui o emoji no retorno
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

  # DELETE /posts/:id
  def destroy
    @post.destroy
  end

  private

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

  def post_params
    params.require(:post).permit(:uuid, :title, :content, :forum_id, :emoji) # Permite o emoji nos parâmetros
  end
end