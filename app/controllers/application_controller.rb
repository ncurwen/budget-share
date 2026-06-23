class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Backend

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :require_household

  # Guard with lambdas (not :only/:except) so Devise controllers, which lack an
  # :index action, don't trip Rails' missing-callback-action check.
  after_action :verify_authorized, unless: -> { devise_controller? || action_name == "index" }
  after_action :verify_policy_scoped, if: -> { action_name == "index" && !devise_controller? }

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  helper_method :current_household

  # Each user belongs to a single household. Nil until they create or join one.
  def current_household
    current_user&.household
  end

  private

  # The first of the month selected via :year/:month params, defaulting to the
  # current month. Used by the dashboard and expense list.
  def selected_month_date
    if params[:year].present? && params[:month].present?
      Date.new(params[:year].to_i, params[:month].to_i, 1)
    else
      Date.current.beginning_of_month
    end
  rescue Date::Error
    Date.current.beginning_of_month
  end

  # The year selected via the :year param, defaulting to the current year.
  def selected_year
    (params[:year] || Date.current.year).to_i
  end

  def require_household
    return if devise_controller? || current_household.present?

    redirect_to new_household_path, notice: "Create a household to get started."
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to do that."
    redirect_back fallback_location: root_path
  end
end
