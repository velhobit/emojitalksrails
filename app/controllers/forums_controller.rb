# app/controllers/forums_controller.rb
class ForumsController < ApplicationController
  before_action :set_forum, only: %i[show update destroy]

  # GET /forums
  def index
    @forums = Forum.includes(:forum_emojis).all
    render json: @forums.as_json(include: { forum_emojis: { only: :emoji } })
  end

  # GET /forums/:id
  def show
    render json: @forum.as_json(include: { forum_emojis: { only: :emoji } })
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

  def forum_params
    params.require(:forum).permit(:name, :alias, :description, :main_color, :uuid)
  end
end