class HouseholdsController < ApplicationController
  # Creating a household is how a user gets their first one, so it can't itself
  # require one.
  skip_before_action :require_household

  def new
    redirect_to(root_path) and return if Current.household.present?

    @household = Household.new
    authorize @household
  end

  def create
    @household = Household.new(household_params)
    authorize @household

    if @household.save
      Current.user.update!(household: @household)
      redirect_to root_path, notice: "Household created. Invite your partner to get started."
    else
      render :new, status: :unprocessable_content
    end
  end

  def show
    @household = Current.user.household
    authorize @household
    @invitation = @household.invitations.new
    @pending_invitations = @household.invitations.pending
  end

  private

  def household_params
    params.require(:household).permit(:name)
  end
end
