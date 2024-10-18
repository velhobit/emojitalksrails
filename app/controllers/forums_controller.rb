# app/controllers/forums_controller.rb
class ForumsController < ApplicationController
  before_action :set_forum, only: %i[show update destroy]
  before_action :set_current_user, only: %i[posts_by_alias]

  # GET /forums
  def index
    @forums = Forum.includes(:forum_emojis).all
    render json: @forums.as_json(include: { forum_emojis: { only: :emoji } })
  end

  # GET /forums/:id
  def show
    render json: @forum.as_json(include: { forum_emojis: { only: :emoji } })
  end
  
  #  GET /forums/:alias/posts
  def posts_by_alias
    # Busca o fórum pelo alias
    @forum = Forum.find_by(alias: params[:alias])
  
    if @forum
      # Busca os posts associados ao fórum
      @posts = Post.where(forum_id: @forum.id)
  
      # Retorna o fórum e os posts no formato JSON
      render json: {
        forum: @forum.as_json(only: [:id, :alias, :name], include: { forum_emojis: { only: :emoji } }), # Aqui você inclui os atributos que quiser do fórum
        posts: @posts.as_json(
          current_user_id: @current_user&.id,
          methods: :time_since_posted,
          include: {
            forum: { except: [:_id] , include: {
              forum_emojis: { only: :emoji }
            }},
            author: { only: [:name, :profile_picture, :theme_color, :description] }
          }
        )
      }
    else
      # Retorna um erro caso o fórum não seja encontrado
      render json: { error: "Forum not found" }, status: :not_found
    end
  end

  # POST /forums
  def create
    @forum = Forum.new(forum_params)
    if @forum.save
      render json: @forum, status: :created, location: @forum
    else
      render json: @forum.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /forums/:id
  def update
    if @forum.update(forum_params)
      render json: @forum
    else
      render json: @forum.errors, status: :unprocessable_entity
    end
  end

  # DELETE /forums/:id
  def destroy
    @forum.destroy
  end

  private

  def set_forum
    @forum = Forum.includes(:forum_emojis).find(params[:id])
  end
  
  def set_current_user
      token = request.headers['Authorization']&.split(' ')&.last
      if token
        decoded_token = User.decode_jwt(token)
        @current_user = User.find(decoded_token[:user_id]) if decoded_token
      end
  end

  def forum_params
    params.require(:forum).permit(:name, :alias, :description, :main_color, :uuid)
  end
end