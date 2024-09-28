# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  before_action :set_post, only: %i[show update destroy]

  # GET /posts
  def index
    @posts = Post.includes(:forum, :author).order(last_update_date: :desc, created_at: :desc)
    render json: @posts.as_json(
      methods: [:time_since_posted, :comment_count], # Inclua :comment_count
      include: {
        forum: { except: [:_id], include: {
          forum_emojis: { only: :emoji }
        }},
        author: { only: [:name, :profile_picture, :theme_color, :description] }
      }
    )
  end

  # GET /posts/:uuid
  def show
    render json: @post.as_json(
      methods: :time_since_posted,
      include: {
        forum: { except: [:_id] , include: {
          forum_emojis: { only: :emoji }
        }},
        author: { only: [:name, :profile_picture, :theme_color, :description] }
      }
    )
  end

  # POST /posts
  def create
    @post = Post.new(post_params)
    if @post.save
      render json: @post.as_json(
        methods: :time_since_posted,
        include: {
          forum: { only: [:name] },
          author: { only: [:name, :profile_picture, :theme_color, :description] }
        }
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
        }
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

  def post_params
    params.require(:post).permit(:uuid, :title, :content, :forum_id, :author_id, :closure_date, :deletion_date, :last_update_date)
  end
end