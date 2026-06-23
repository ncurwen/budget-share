require "test_helper"

class TableComponentTest < ViewComponent::TestCase
  def base_args(**overrides)
    {
      collection: [],
      partial: "expenses/expense",
      as: :expense,
      search_config: {
        url: "/expenses",
        attribute: :title_cont,
        value: nil,
        placeholder: "Search expenses..."
      }
    }.merge(overrides)
  end

  test "renders the search toolbar with the configured placeholder" do
    render_inline(TableComponent.new(**base_args)) do |t|
      t.with_column { "Title" }
      t.with_empty_message { "Nothing here yet." }
    end

    assert_selector "form[method=get]"
    assert_selector "input[type=search][placeholder='Search expenses...']"
    assert_selector "th", text: "Title"
  end

  test "shows the empty message when nothing matches and no search is active" do
    render_inline(TableComponent.new(**base_args)) do |t|
      t.with_column { "Title" }
      t.with_empty_message { "Nothing here yet." }
    end

    assert_text "Nothing here yet."
  end

  test "shows the no-results alert when a search yields nothing" do
    args = base_args(search_config: { url: "/expenses", attribute: :title_cont,
                                      value: "zzz", placeholder: "Search..." })
    render_inline(TableComponent.new(**args)) do |t|
      t.with_column { "Title" }
      t.with_empty_message { "Nothing here yet." }
    end

    assert_text "No results match your current search"
  end

  test "renders a select-style filter inside the search form" do
    args = base_args(filter_config: {
      param: :category_id_eq, active: nil, as: :select, prompt: "All categories",
      options: [ { value: 1, label: "Food" }, { value: 2, label: "Rent" } ]
    })
    render_inline(TableComponent.new(**args)) do |t|
      t.with_column { "Title" }
    end

    assert_selector "form select[name='q[category_id_eq]']"
    assert_selector "form select option", text: "Food"
    assert_selector "form select option", text: "All categories"
  end
end
