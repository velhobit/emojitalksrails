class UsersController < ApplicationController
  before_action :set_user, only: %i[show update destroy]
  before_action :authorize_user, only: %i[update destroy]

  # GET /users
  def index
    @users = User.all
    render json: @users
  end

  # GET /users/:id
  def show
    render json: @user
  end
  
  # GET /users/current
  def current
    if current_user
      render json: current_user
    else
      render json: { error: 'No user logged in' }, status: :unauthorized
    end
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/:id
  def update
    # Permissão para alterar o role somente se o usuário for staff ou admin
    if user_params[:role].present? && !%w[staff admin].include?(@current_user.role)
      return render json: { error: 'Only staff or admin can change the role.' }, status: :forbidden
    end

    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/:id
  def destroy
    @user.destroy
    head :no_content
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_user
    # Verifica se o usuário logado é o mesmo que está sendo editado ou se é staff/admin
    unless @current_user.role == 'staff' || @current_user.role == 'admin' || @current_user.id == @user.id
      render json: { error: 'Not authorized to perform this action.' }, status: :forbidden
    end
  end

  def user_params
    params.require(:user).permit(:name, :username, :email, :phone, :description, :profile_picture_url, :uuid, :role, :theme_color, :password, :password_confirmation)
  end
end