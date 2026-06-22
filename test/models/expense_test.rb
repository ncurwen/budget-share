require "test_helper"

class ExpenseTest < ActiveSupport::TestCase
  setup do
    @alex = create_user(name: "Alex")
    @sam = create_user(name: "Sam")
    @outsider = create_user(name: "Pat")
    @household = create_household(name: "Ours", users: [ @alex, @sam ])
    @other = create_household(name: "Theirs", users: [ @outsider ])
    @category = @household.categories.create!(name: "Groceries")
  end

  def build_expense(**attrs)
    @household.expenses.new(
      { category: @category, user: @alex, title: "X", amount: 10, paid_on: Date.current }.merge(attrs)
    )
  end

  test "amount accessor round-trips dollars to integer cents" do
    expense = build_expense(amount: "12.34")
    assert_equal 1234, expense.amount_cents
    assert_equal 12.34, expense.amount
  end

  test "is valid with a household category and a member payer" do
    assert build_expense.valid?
  end

  test "rejects a category from another household" do
    expense = build_expense(category: @other.categories.create!(name: "Rent"))
    assert_not expense.valid?
    assert_includes expense.errors[:category], "must belong to this household"
  end

  test "rejects a payer who isn't a household member" do
    expense = build_expense(user: @outsider)
    assert_not expense.valid?
    assert_includes expense.errors[:user], "must be a household member"
  end

  test "requires a positive amount" do
    assert_not build_expense(amount: 0).valid?
  end
end
