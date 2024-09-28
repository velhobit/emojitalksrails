# app/controllers/user_relationships_controller.rb
class UserRelationshipsController < ApplicationController
  before_action :authenticate_user!

  def follow
	user = User.find(params[:id])
	current_user.follow(user)
	render json: { message: 'Seguindo usuário' }, status: :ok
  end

  def unfollow
	user = User.find(params[:id])
	current_user.unfollow(user)
	render json: { message: 'Deixou de seguir usuário' }, status: :ok
  end

  def block
	user = User.find(params[:id])
	current_user.block(user)
	render json: { message: 'Usuário bloqueado' }, status: :ok
  end

  def unblock
	user = User.find(params[:id])
	current_user.unblock(user)
	render json: { message: 'Usuário desbloqueado' }, status: :ok
  end
end