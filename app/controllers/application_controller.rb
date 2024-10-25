class ApplicationController < ActionController::API
  before_action :authorize_request

  # Disponibiliza o usuário autenticado para outros controladores
  def current_user
    @current_user
  end

  private

  def authorize_request
    header = request.headers['Authorization']
    header = header.split(' ').last if header
    decoded = User.decode_jwt(header)
    @current_user = User.find_by(id: decoded[:user_id]) if decoded
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: e.message }, status: :unauthorized
  rescue JWT::DecodeError => e
    render json: { errors: e.message }, status: :unauthorized
  end
end