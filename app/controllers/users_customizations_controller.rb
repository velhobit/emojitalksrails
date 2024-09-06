# app/controllers/user_customizations_controller.rb
class UserCustomizationsController < ApplicationController
  before_action :set_user_customization, only: %i[show update destroy]

  # GET /user_customizations
  def index
	@user_customizations = UserCustomization.all
	render json: @user_customizations
  end

  # GET /user_customizations/:id
  def show
	render json: @user_customization
  end

  # POST /user_customizations
  def create
	@user_customization = UserCustomization.new(user_customization_params)
	if @user_customization.save
	  render json: @user_customization, status: :created, location: @user_customization
	else
	  render json: @user_customization.errors, status: :unprocessable_entity
	end
  end

  # PATCH/PUT /user_customizations/:id
  def update
	if @user_customization.update(user_customization_params)
	  render json: @user_customization
	else
	  render json: @user_customization.errors, status: :unprocessable_entity
	end
  end

  # DELETE /user_customizations/:id
  def destroy
	@user_customization.destroy
  end

  private

  def set_user_customization
	@user_customization = UserCustomization.find(params[:id])
  end

  def user_customization_params
	params.require(:user_customization).permit(:uuid, :user_id, :profile_visibility, :favorite_emojis, :app_color_mode)
  end
end