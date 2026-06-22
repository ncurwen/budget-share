# Aggregates a household's whole year into a category x month matrix of spend vs
# target for the year overview. Plain Ruby, no persistence.
class AnnualStatement
  MONTHS = (1..12).to_a.freeze

  Row = Data.define(:category, :spent_by_month, :target_by_month) do
    def spent_cents(month) = spent_by_month[month] || 0
    def target_cents(month) = target_by_month[month] || 0
    def total_spent_cents = spent_by_month.values.sum
    def total_target_cents = target_by_month.values.sum
  end

  attr_reader :household, :year

  def initialize(household, year)
    @household = household
    @year = year
  end

  def rows
    @rows ||= household.categories.map do |category|
      Row.new(
        category:,
        spent_by_month: spent_by_category_month[category.id] || {},
        target_by_month: target_by_category_month[category.id] || {}
      )
    end
  end

  def total_spent_cents(month) = rows.sum { |row| row.spent_cents(month) }
  def total_target_cents(month) = rows.sum { |row| row.target_cents(month) }
  def grand_total_spent_cents = rows.sum(&:total_spent_cents)
  def grand_total_target_cents = rows.sum(&:total_target_cents)

  private

  # { category_id => { month => cents } }
  # NOTE: strftime is SQLite-specific; revisit if the app moves to another adapter.
  def spent_by_category_month
    @spent_by_category_month ||= household.expenses.for_year(year)
      .group(:category_id, Arel.sql("strftime('%m', paid_on)"))
      .sum(:amount_cents)
      .each_with_object({}) do |((category_id, month_str), cents), acc|
        (acc[category_id] ||= {})[month_str.to_i] = cents
      end
  end

  def target_by_category_month
    @target_by_category_month ||= household.budget_targets.where(year:)
      .pluck(:category_id, :month, :amount_cents)
      .each_with_object({}) do |(category_id, month, cents), acc|
        (acc[category_id] ||= {})[month] = cents
      end
  end
end
