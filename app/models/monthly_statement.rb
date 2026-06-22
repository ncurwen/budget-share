# Computes a household's monthly picture: spend-vs-target per category and the
# 50/50 "square up" over *shared* expenses only. Plain Ruby, no persistence.
#
#   statement = MonthlyStatement.new(household, 2026, 6)
#   statement.category_rows    # => [<CategoryRow ...>, ...]
#   statement.square_up        # => <SquareUp debtor:, creditor:, amount_cents:> or nil
class MonthlyStatement
  CategoryRow = Data.define(:category, :spent_cents, :target_cents) do
    def remaining_cents = target_cents - spent_cents
    def over_budget? = spent_cents > target_cents
    # Percent of target spent, capped at 100 for progress bars (nil target => nil).
    def percent
      return nil if target_cents.zero?
      [ (spent_cents.fdiv(target_cents) * 100).round, 100 ].min
    end
  end

  SquareUp = Data.define(:debtor, :creditor, :amount_cents) do
    def settled? = false
  end

  attr_reader :household, :year, :month

  def initialize(household, year, month)
    @household = household
    @year = year
    @month = month
  end

  def expenses
    @expenses ||= household.expenses.for_month(year, month)
                           .includes(:category, :user).recent_first.to_a
  end

  def members
    @members ||= household.users.order(:name).to_a
  end

  def category_rows
    @category_rows ||= household.categories.map do |category|
      CategoryRow.new(
        category:,
        spent_cents: spent_by_category[category.id] || 0,
        target_cents: target_by_category[category.id] || 0
      )
    end
  end

  def total_spent_cents = expenses.sum(&:amount_cents)
  def total_target_cents = target_by_category.values.sum
  def shared_spent_cents = expenses.select(&:shared?).sum(&:amount_cents)
  def personal_spent_cents = expenses.reject(&:shared?).sum(&:amount_cents)

  # Cents each member paid toward shared expenses this month.
  def paid_by(user)
    shared_paid[user.id] || 0
  end

  # Who owes whom to even up a 50/50 split of shared expenses. Returns a SquareUp
  # (or the persisted Settlement if already recorded), or nil when there's nothing
  # to settle or the household isn't a two-person couple.
  def square_up
    return settlement if settled?
    return nil unless members.size == 2

    a, b = members
    paid_a = paid_by(a)
    paid_b = paid_by(b)
    return nil if paid_a == paid_b

    creditor, debtor = paid_a > paid_b ? [ a, b ] : [ b, a ]
    amount_cents = ((paid_by(creditor) - paid_by(debtor)) / 2.0).round
    SquareUp.new(debtor:, creditor:, amount_cents:)
  end

  def settlement
    @settlement ||= household.settlements.find_by(year:, month:)
  end

  def settled? = settlement&.settled?

  private

  def spent_by_category
    @spent_by_category ||= expenses.group_by(&:category_id)
      .transform_values { |list| list.sum(&:amount_cents) }
  end

  def target_by_category
    @target_by_category ||= household.budget_targets.where(year:, month:)
      .pluck(:category_id, :amount_cents).to_h
  end

  def shared_paid
    @shared_paid ||= expenses.select(&:shared?).group_by(&:user_id)
      .transform_values { |list| list.sum(&:amount_cents) }
  end
end
