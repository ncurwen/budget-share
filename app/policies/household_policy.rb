# frozen_string_literal: true

class HouseholdPolicy < ApplicationPolicy
  # A user can create a household only if they don't already belong to one.
  def create? = user.present? && user.household.nil?
  def new? = create?
  def show? = record == user&.household

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(id: user&.household_id)
    end
  end
end
