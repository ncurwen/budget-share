# frozen_string_literal: true

class BudgetTargetPolicy < ApplicationPolicy
  private

  # BudgetTarget reaches household through its category.
  def record_in_household?
    record.category.household_id == household&.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:category).where(categories: { household_id: user&.household_id })
    end
  end
end
