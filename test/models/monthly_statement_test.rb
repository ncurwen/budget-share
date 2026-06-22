require "test_helper"

class MonthlyStatementTest < ActiveSupport::TestCase
  setup do
    @alex = create_user(name: "Alex")
    @sam = create_user(name: "Sam")
    @household = create_household(users: [ @alex, @sam ])
    @category = @household.categories.create!(name: "Groceries")
    @category.budget_targets.create!(year: 2026, month: 6, amount: 500)
  end

  def add_expense(payer:, amount:, shared: true, day: 5, category: @category)
    @household.expenses.create!(
      category:, user: payer, title: "X", amount:, shared:,
      paid_on: Date.new(2026, 6, day)
    )
  end

  test "square-up splits shared expenses 50/50 and names debtor/creditor" do
    add_expense(payer: @alex, amount: 100)
    add_expense(payer: @sam, amount: 40)
    su = MonthlyStatement.new(@household, 2026, 6).square_up

    assert_equal @sam, su.debtor
    assert_equal @alex, su.creditor
    assert_equal 3000, su.amount_cents # (10000 - 4000) / 2
  end

  test "personal expenses are excluded from the square-up" do
    add_expense(payer: @alex, amount: 100, shared: true)
    add_expense(payer: @sam, amount: 1000, shared: false) # huge personal, ignored
    su = MonthlyStatement.new(@household, 2026, 6).square_up

    assert_equal @sam, su.debtor
    assert_equal 5000, su.amount_cents # only the $100 shared counts: 10000/2
  end

  test "odd cents round to the nearest cent" do
    add_expense(payer: @alex, amount: 10.01) # Sam pays nothing
    su = MonthlyStatement.new(@household, 2026, 6).square_up

    # (1001 - 0) / 2 = 500.5 -> 501 (round half up)
    assert_equal 501, su.amount_cents
  end

  test "returns nil when nobody owes anything" do
    add_expense(payer: @alex, amount: 50)
    add_expense(payer: @sam, amount: 50)
    assert_nil MonthlyStatement.new(@household, 2026, 6).square_up
  end

  test "category rows report spend vs target and over-budget" do
    add_expense(payer: @alex, amount: 600)
    row = MonthlyStatement.new(@household, 2026, 6).category_rows.first

    assert_equal 60_000, row.spent_cents
    assert_equal 50_000, row.target_cents
    assert row.over_budget?
    assert_equal 100, row.percent # capped
  end

  test "only counts expenses within the given month" do
    add_expense(payer: @alex, amount: 100, day: 15)
    @household.expenses.create!(category: @category, user: @alex, title: "May",
                                amount: 999, paid_on: Date.new(2026, 5, 30))
    statement = MonthlyStatement.new(@household, 2026, 6)

    assert_equal 10_000, statement.total_spent_cents
  end

  test "uses the settled settlement once recorded" do
    add_expense(payer: @alex, amount: 100)
    @household.settlements.create!(year: 2026, month: 6, debtor: @sam, creditor: @alex,
                                   amount_cents: 5000, settled_at: Time.current, settled_by: @alex)
    statement = MonthlyStatement.new(@household, 2026, 6)

    assert statement.settled?
    assert_instance_of Settlement, statement.square_up
  end
end
