# app/controllers/forum_emojis_controller.rb
class ForumEmojisController < ApplicationController
  before_action :set_forum_emoji, only: %i[show update destroy]

  # GET /forum_emojis
  def index
	@forum_emojis = ForumEmoji.all
	render json: @forum_emojis
  end

  # GET /forum_emojis/:id
  def show
	render json: @forum_emoji
  end

  # POST /forum_emojis
  def create
	@forum_emoji = ForumEmoji.new(forum_emoji_params)
	if @forum_emoji.save
	  render json: @forum_emoji, status: :created, location: @forum_emoji
	else
	  render json: @forum_emoji.errors, status: :unprocessable_entity
	end
  end

  # PATCH/PUT /forum_emojis/:id
  def update
	if @forum_emoji.update(forum_emoji_params)
	  render json: @forum_emoji
	else
	  render json: @forum_emoji.errors, status: :unprocessable_entity
	end
  end

  # DELETE /forum_emojis/:id
  def destroy
	@forum_emoji.destroy
  end

  private

  def set_forum_emoji
	@forum_emoji = ForumEmoji.find(params[:id])
  end

  def forum_emoji_params
	params.require(:forum_emoji).permit(:forum_id, :emoji)
  end
end