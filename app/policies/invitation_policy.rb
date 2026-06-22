# frozen_string_literal: true

# Any member may invite a partner into their household.
class InvitationPolicy < ApplicationPolicy
  def create? = record.household == user&.household
end
