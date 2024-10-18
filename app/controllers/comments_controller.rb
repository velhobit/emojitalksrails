# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  before_action :set_comment, only: %i[show update destroy]
  before_action :authorize_request, only: %i[create update destroy]

  # GET /comments
  def index
    @comments = Comment.all
    render json: @comments
  end

  # GET /comments/:id
  def show
    render json: @comment
  end
  
  # GET /comments/post/:post_uuid
  def comments_by_post
    @comments = Comment.includes(:author).where(post_uuid: params[:post_uuid])
  
    if @comments.any?
      render json: @comments.to_json(include: { author: { only: [:uuid, :name, :username, :email] } } )
    else
      render json: { message: "No comments found for this post." }, status: :not_found
    end
  end

  # POST /comments
  def create
    @comment = Comment.new(comment_params.merge(author_id: @current_user.id))
  
    if @comment.save
      render json: @comment, status: :created, location: @comment
    else
      # puts "Comment errors: #{@comment.errors.full_messages.join(', ')}"  # Logando os erros
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /comments/:id
  def update
    if @comment.update(comment_params)
      render json: @comment
    else
      render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /comments/:id
  def destroy
    if @comment.author_id == @current_user.id || %w[staff admin].include?(@current_user.role)
      @comment.destroy
      head :no_content
    else
      render json: { error: 'You are not authorized to delete this comment' }, status: :forbidden
    end
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:post_uuid, :content)
  end
  
  # Autoriza a requisição e define o usuário logado
  def authorize_request
    token = request.headers['Authorization']&.split(' ')&.last
    decoded_token = User.decode_jwt(token)
    @current_user = User.find(decoded_token[:user_id]) if decoded_token
  
    render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_user
  end
end