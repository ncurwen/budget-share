require "application_system_test_case"

class HouseholdsTest < ApplicationSystemTestCase
  test "a new user is onboarded by creating a household" do
    visit new_user_registration_path
    fill_in "user[name]", with: "Jordan"
    fill_in "user[email]", with: "jordan@example.com"
    fill_in "user[password]", with: "password123"
    fill_in "user[password_confirmation]", with: "password123"
    click_on "Sign up"

    # No household yet, so they're sent to create one.
    assert_text "Create a household"
    fill_in "household[name]", with: "Jordan & Riley"
    click_on "Create household"

    assert_text "Household created"
    assert_text "Spent this month"
    assert_equal "Jordan & Riley", User.find_by(email: "jordan@example.com").household.name
  end
end
