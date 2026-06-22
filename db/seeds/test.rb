# Rich, reproducible dataset for local testing. Loaded by the dynamically
# defined task in lib/tasks/custom_seed.rake:
#
#   bundle exec rails db:seed:test
#
# Covers the app's main scenarios:
#   * a two-person household (the "square up" 50/50 split path) with a full year
#     of budget targets and expenses across many months, both shared and personal;
#   * a three-person household (the non-couple path where square_up is nil);
#   * a settled and an unsettled month so settlement views have data;
#   * a user with no household and a pending invitation.
#
# Idempotent by way of a clean slate: every run truncates the app tables and
# rebuilds from a fixed RNG seed, so the data is identical each time.
module TestSeed
  PASSWORD = "password123"
  CURRENT  = Date.current

  CATEGORIES = [
    { name: "Rent",          color: "primary",   target: 1800, weight: 1 },
    { name: "Groceries",     color: "success",   target: 600,  weight: 8 },
    { name: "Utilities",     color: "info",      target: 250,  weight: 2 },
    { name: "Dining out",    color: "warning",   target: 300,  weight: 6 },
    { name: "Transport",     color: "secondary", target: 200,  weight: 4 },
    { name: "Entertainment", color: "accent",    target: 150,  weight: 3 },
    { name: "Health",        color: "error",     target: 120,  weight: 2 },
    { name: "Misc",          color: "neutral",   target: 100,  weight: 3 }
  ].freeze

  TITLES = {
    "Rent"          => [ "Monthly rent" ],
    "Groceries"     => [ "Costco haul", "Farmers market", "Corner store", "Weekly shop", "Trader Joe's" ],
    "Utilities"     => [ "Electricity", "Water", "Internet", "Gas bill" ],
    "Dining out"    => [ "Date night", "Team lunch", "Takeout", "Brunch", "Coffee" ],
    "Transport"     => [ "Gas", "Transit pass", "Rideshare", "Parking" ],
    "Entertainment" => [ "Movie night", "Concert tickets", "Streaming", "Board games" ],
    "Health"        => [ "Pharmacy", "Gym", "Copay", "Vitamins" ],
    "Misc"          => [ "Household goods", "Gift", "Hardware store", "Subscription" ]
  }.freeze

  module_function

  def run!
    raise "Refusing to run the test seed outside development/test (RAILS_ENV=#{Rails.env})" unless Rails.env.local?

    srand(1234) # deterministic expense amounts/dates across runs

    ApplicationRecord.transaction do
      wipe!

      build_couple
      build_trio
      build_orphan_with_invitation(Household.find_by!(name: "Alex & Sam"))
    end

    Household.order(:name).each { |household| report(household) }
    puts "\nSign in with any of these (password: #{PASSWORD}):"
    User.order(:email).pluck(:email).each { |email| puts "  - #{email}" }
  end

  def wipe!
    [ Settlement, Expense, BudgetTarget, Category, Invitation ].each(&:delete_all)
    User.update_all(household_id: nil)
    Household.delete_all
    User.delete_all
  end

  # --- Households ----------------------------------------------------------

  def build_couple
    household = Household.create!(name: "Alex & Sam")
    members = [
      create_user("alex@example.com", "Alex", household),
      create_user("sam@example.com",  "Sam",  household)
    ]

    categories = seed_categories(household)
    # A full prior year plus everything up to the current month this year.
    seed_targets(categories, CURRENT.year - 1, 1..12)
    seed_targets(categories, CURRENT.year, 1..12)
    seed_expenses(household, members, categories, months_back(13))

    # Square-up history: settle every completed month, leave the current one open.
    completed = months_back(13).reject { |d| d == CURRENT.beginning_of_month }
    seed_settlements(household, members, completed)
  end

  def build_trio
    household = Household.create!(name: "The Garcias")
    members = [
      create_user("maria@example.com", "Maria", household),
      create_user("diego@example.com", "Diego", household),
      create_user("lucia@example.com", "Lucia", household)
    ]

    categories = seed_categories(household)
    seed_targets(categories, CURRENT.year, 1..12)
    seed_expenses(household, members, categories, months_back(4))
  end

  def build_orphan_with_invitation(inviting_household)
    create_user("jordan@example.com", "Jordan", nil)

    inviting_household.invitations.create!(
      email: "newcomer@example.com",
      invited_by: inviting_household.users.first
    )
  end

  # --- Builders ------------------------------------------------------------

  def create_user(email, name, household)
    User.create!(email:, name:, household:, password: PASSWORD)
  end

  def seed_categories(household)
    CATEGORIES.each_with_index.map do |attrs, position|
      household.categories.create!(name: attrs[:name], color: attrs[:color], position:)
    end
  end

  def seed_targets(categories, year, months)
    categories.each_with_index do |category, i|
      months.each do |month|
        category.budget_targets.create!(year:, month:, amount: CATEGORIES[i][:target])
      end
    end
  end

  # A spread of expenses for each month, weighted so frequent categories (e.g.
  # Groceries) get more line items than one-off ones (e.g. Rent).
  def seed_expenses(household, members, categories, months)
    months.each do |month_date|
      categories.each_with_index do |category, i|
        attrs = CATEGORIES[i]

        expense_count_for(attrs).times do
          household.expenses.create!(
            category:,
            user: members.sample,
            title: title_for(attrs[:name]),
            description: [ "", "Split evenly", "Reimbursed later", "Joint" ].sample,
            amount: amount_for(attrs),
            shared: [ true, true, true, false ].sample, # ~75% shared
            paid_on: random_day_in(month_date)
          )
        end
      end
    end
  end

  def seed_settlements(household, members, months)
    return unless members.size == 2

    months.each do |month_date|
      square = MonthlyStatement.new(household, month_date.year, month_date.month).square_up
      next unless square

      settlement = household.settlements.create!(
        year: month_date.year,
        month: month_date.month,
        debtor: square.debtor,
        creditor: square.creditor,
        amount_cents: square.amount_cents
      )
      settlement.settle!(square.creditor)
    end
  end

  # --- Helpers -------------------------------------------------------------

  def months_back(count)
    (0...count).map { |i| (CURRENT - i.months).beginning_of_month }.reverse
  end

  def expense_count_for(attrs)
    attrs[:name] == "Rent" ? 1 : rand(1..attrs[:weight])
  end

  def amount_for(attrs)
    return attrs[:target] if attrs[:name] == "Rent" # rent is a fixed monthly figure

    base = attrs[:target].fdiv(attrs[:weight])
    (base * rand(0.4..1.4)).round(2)
  end

  def random_day_in(month_date)
    last = month_date == CURRENT.beginning_of_month ? CURRENT.day : month_date.end_of_month.day
    month_date.change(day: rand(1..last))
  end

  def title_for(category_name)
    TITLES.fetch(category_name, [ category_name ]).sample
  end

  def report(household)
    puts "Seeded '#{household.name}': " \
         "#{household.users.count} members, " \
         "#{household.categories.count} categories, " \
         "#{household.expenses.count} expenses, " \
         "#{household.settlements.count} settlements."
  end
end

TestSeed.run!
