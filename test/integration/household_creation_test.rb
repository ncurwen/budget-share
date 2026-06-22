require "test_helper"

class HouseholdCreationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "a signed-in user without a household can create one" do
    user = create_user(name: "Jordan", email: "jordan@example.com")
    sign_in user

    # Hitting root with no household bounces to the new-household page.
    get root_path
    assert_redirected_to new_household_path

    post household_path, params: { household: { name: "Jordan & Riley" } }
    assert_redirected_to root_path

    assert_equal "Jordan & Riley", user.reload.household&.name
  end
end
