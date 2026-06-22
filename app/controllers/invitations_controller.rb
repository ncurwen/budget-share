class InvitationsController < ApplicationController
  # Accepting an invite happens before the user has a household of their own.
  skip_before_action :require_household, only: :accept

  def create
    @invitation = current_household.invitations.new(invitation_params.merge(invited_by: current_user))
    authorize @invitation

    if @invitation.save
      redirect_to household_path,
                  notice: "Invite ready. Share the join link with #{@invitation.email}."
    else
      redirect_to household_path, alert: "Couldn't create the invite."
    end
  end

  # Token link the partner opens to join the household.
  def accept
    skip_authorization
    invitation = Invitation.find_by!(token: params[:token])

    if invitation.accepted?
      redirect_to root_path, alert: "That invite has already been used."
      return
    end

    invitation.accept!(current_user)
    redirect_to root_path, notice: "You've joined #{invitation.household.name}."
  end

  private

  def invitation_params
    params.require(:invitation).permit(:email)
  end
end
