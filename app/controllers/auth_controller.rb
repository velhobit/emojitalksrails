# app/controllers/auth_controller.rb
class AuthController < ApplicationController
  # POST /login
  def login
	@user = User.find_by(email: params[:email])

	if @user&.authenticate(params[:password])
	  token = @user.generate_jwt
	  render json: { token: token, user: @user }, status: :ok
	else
	  render json: { error: 'Invalid email or password' }, status: :unauthorized
	end
  end

  # POST /signup
  def signup
	@user = User.new(user_params)
	if @user.save
	  token = @user.generate_jwt
	  render json: { token: token, user: @user }, status: :created
	else
	  render json: @user.errors, status: :unprocessable_entity
	end
  end

  # GET /validate_token
  def validate_token
	token = request.headers['Authorization']&.split(' ')&.last
	decoded_token = User.decode_jwt(token)
	if decoded_token
	  @user = User.find_by(id: decoded_token[:user_id])
	  if @user
		render json: { user: @user }, status: :ok
	  else
		render json: { error: 'User not found' }, status: :not_found
	  end
	else
	  render json: { error: 'Invalid or expired token' }, status: :unauthorized
	end
  end

  private

  def user_params
	params.require(:user).permit(:name, :username, :email, :phone, :description, :profile_picture_url, :uuid, :theme_color, :password, :password_confirmation)
  end
end