require "test_helper"

# Exercises the expenses and categories index pages now that they render through
# TableComponent with Ransack search/filter/sort and Pagy pagination.
class TableIndexPagesTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = create_user(name: "Jordan", email: "jordan@example.com")
    @household = create_household(name: "Jordan & Riley", users: [ @user ])
    @groceries = @household.categories.create!(name: "Groceries", color: "success")
    @rent = @household.categories.create!(name: "Rent", color: "primary")
    @date = Date.current.beginning_of_month
    @household.expenses.create!(title: "Costco run", amount_cents: 12_050, paid_on: @date,
                               shared: true, category: @groceries, user: @user)
    @household.expenses.create!(title: "Apartment", amount_cents: 90_000, paid_on: @date,
                               shared: true, category: @rent, user: @user)
    sign_in @user
  end

  test "expenses index renders with search toolbar and rows" do
    get expenses_path(year: @date.year, month: @date.month)
    assert_response :success
    assert_select "input[type=search]"
    assert_select "td", text: "Costco run"
    assert_select "td", text: "Apartment"
  end

  test "expenses index filters by ransack search" do
    get expenses_path(year: @date.year, month: @date.month, q: { title_or_description_cont: "Costco" })
    assert_response :success
    assert_select "td", text: "Costco run"
    assert_select "td", { text: "Apartment", count: 0 }
  end

  test "expenses index filters by category select and shared badge" do
    get expenses_path(year: @date.year, month: @date.month, q: { category_id_eq: @rent.id })
    assert_response :success
    assert_select "td", text: "Apartment"
    assert_select "td", { text: "Costco run", count: 0 }
  end

  test "personal filter keeps shared_eq=false in the toggle url" do
    personal = @household.expenses.create!(title: "Solo coffee", amount_cents: 500,
                                           paid_on: @date, shared: false,
                                           category: @groceries, user: @user)

    # The Personal badge's toggle link must carry shared_eq=false (not be stripped).
    # The `[` is URL-encoded, so the param reads `q%5Bshared_eq%5D=false`.
    get expenses_path(year: @date.year, month: @date.month)
    assert_response :success
    assert_match(/shared_eq(%5D|\])=false/, response.body)

    # And applying it actually filters to personal-only expenses.
    get expenses_path(year: @date.year, month: @date.month, q: { shared_eq: false })
    assert_response :success
    assert_select "td", text: "Solo coffee"
    assert_select "td", { text: "Costco run", count: 0 }
  end

  test "expenses index sorts by ransack sort param" do
    get expenses_path(year: @date.year, month: @date.month, q: { s: "amount_cents asc" })
    assert_response :success
  end

  test "categories index renders with search toolbar and rows" do
    get categories_path(year: @date.year)
    assert_response :success
    assert_select "input[type=search]"
    assert_select "td", text: /Groceries/
    assert_select "td", text: /Rent/
  end

  test "categories index filters by name search" do
    get categories_path(year: @date.year, q: { name_cont: "Rent" })
    assert_response :success
    assert_select "td", text: /Rent/
    assert_select "td", { text: /Groceries/, count: 0 }
  end
end
