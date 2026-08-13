class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  private

  def require_admin!
    return if current_user&.admin?

    redirect_to root_path, alert: "Você não tem autorização para acessar esta página."
  end
end
