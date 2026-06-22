require "test_helper"

class ExpensePolicyTest < ActiveSupport::TestCase
  setup do
    @alex = create_user(name: "Alex")
    @sam = create_user(name: "Sam")
    @outsider = create_user(name: "Pat")

    @household = create_household(name: "Ours", users: [ @alex, @sam ])
    @other = create_household(name: "Theirs", users: [ @outsider ])

    @category = @household.categories.create!(name: "Groceries")
    @expense = @household.expenses.create!(category: @category, user: @alex,
      title: "X", amount: 10, paid_on: Date.current)
  end

  def policy_for(user)
    ExpensePolicy.new(user, @expense)
  end

  test "a member of the household can manage its expenses" do
    policy = policy_for(@alex)

    assert policy.show?
    assert policy.update?
    assert policy.destroy?
  end

  test "a user in another household cannot touch this expense" do
    policy = policy_for(@outsider)

    assert_not policy.show?
    assert_not policy.update?
    assert_not policy.destroy?
  end

  test "policy scope returns only the user's household expenses" do
    outsider_expense = @other.expenses.create!(
      category: @other.categories.create!(name: "Rent"),
      user: @outsider, title: "Y", amount: 5, paid_on: Date.current
    )

    scope = ExpensePolicy::Scope.new(@alex, Expense).resolve

    assert_includes scope, @expense
    assert_not_includes scope, outsider_expense
  end
end
