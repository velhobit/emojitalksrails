# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  def create
	@user = User.find_by(email: params[:email])

	if @user&.authenticate(params[:password])
	  render json: { message: 'Login successful', user: @user.as_json(except: [:password_digest]) }, status: :ok
	else
	  render json: { error: 'Invalid email or password' }, status: :unauthorized
	end
  end

  def destroy
	# Implementação do logout pode variar, mas para APIs, normalmente é a invalidação do token
	render json: { message: 'Logout successful' }, status: :ok
  end
end