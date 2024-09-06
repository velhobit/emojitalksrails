# app/controllers/comments_controller.rb
class CommentsController < ApplicationController
  before_action :set_comment, only: %i[show update destroy]

  # GET /comments
  def index
	@comments = Comment.all
	render json: @comments
  end

  # GET /comments/:id
  def show
	render json: @comment
  end

  # POST /comments
  def create
	@comment = Comment.new(comment_params)
	if @comment.save
	  render json: @comment, status: :created, location: @comment
	else
	  render json: @comment.errors, status: :unprocessable_entity
	end
  end

  # PATCH/PUT /comments/:id
  def update
	if @comment.update(comment_params)
	  render json: @comment
	else
	  render json: @comment.errors, status: :unprocessable_entity
	end
  end

  # DELETE /comments/:id
  def destroy
	@comment.destroy
  end

  private

  def set_comment
	@comment = Comment.find(params[:id])
  end

  def comment_params
	params.require(:comment).permit(:uuid, :post_id, :author_id, :content)
  end
end