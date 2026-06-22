require "application_system_test_case"

class ExpensesTest < ApplicationSystemTestCase
  setup do
    @alex = create_user(name: "Alex", email: "alex@example.com")
    create_user(name: "Sam", email: "sam@example.com")
    @household = create_household(name: "Alex & Sam", users: [ @alex, User.find_by(email: "sam@example.com") ])
    @household.categories.create!(name: "Groceries", color: "success")
  end

  test "signing in, adding an expense, and squaring up" do
    sign_in_as @alex

    assert_text "Spent this month"

    # Add an expense via the modal.
    click_on "+ Add expense"
    within "dialog" do
      fill_in "expense[title]", with: "Costco run"
      fill_in "expense[amount]", with: "120.50"
      select "Groceries", from: "expense[category_id]"
      select "Alex", from: "expense[user_id]"
      click_on "Add expense"
    end

    # It shows up on the dashboard...
    assert_text "Costco run"
    assert_text "$120.50"

    # ...and Alex paid everything, so Sam owes half.
    assert_text "Sam owes"
    assert_text "Alex"

    # Record the square-up.
    click_on "Mark as squared up"
    assert_text "Squared up"
  end

  private

  def sign_in_as(user)
    visit new_user_session_path
    assert_text "Log in to your household"
    fill_in "user[email]", with: user.email
    fill_in "user[password]", with: "password123"
    click_on "Log in"
  end
end
