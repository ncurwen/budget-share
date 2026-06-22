# frozen_string_literal: true

# Base policy. `user` is the current User, who belongs to a single household. The
# default rule: a user may act on records belonging to their household.
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index? = household.present?
  def show? = record_in_household?
  def create? = household.present?
  def new? = create?
  def update? = record_in_household?
  def edit? = update?
  def destroy? = record_in_household?

  private

  def household = user&.household

  # Tenant isolation: the record must belong to the user's household. Records
  # without a direct household_id override this in their own policy.
  def record_in_household?
    return false if household.nil?
    return true unless record.respond_to?(:household_id)

    record.household_id == household.id
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.where(household_id: user&.household_id)
    end

    private

    attr_reader :user, :scope
  end
end
