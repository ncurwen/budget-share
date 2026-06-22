# Idempotent seed data: a household shared by two partners, a set of budget
# categories with monthly targets for the current year, and a handful of expenses
# for the current month so the dashboard and square-up render with real data.

PASSWORD = "password123"

alex = User.find_or_create_by!(email: "alex@example.com") do |u|
  u.name = "Alex"
  u.password = PASSWORD
end

sam = User.find_or_create_by!(email: "sam@example.com") do |u|
  u.name = "Sam"
  u.password = PASSWORD
end

household = Household.find_or_create_by!(name: "Alex & Sam")
[ alex, sam ].each { |user| user.update!(household:) }

# Categories with a default monthly target (in dollars) for the current year.
CATEGORIES = {
  "Rent"          => { color: "primary",   target: 1800 },
  "Groceries"     => { color: "success",   target: 600 },
  "Utilities"     => { color: "info",      target: 250 },
  "Dining out"    => { color: "warning",   target: 300 },
  "Transport"     => { color: "secondary", target: 200 },
  "Entertainment" => { color: "accent",    target: 150 }
}

year = Date.current.year
month = Date.current.month

categories = CATEGORIES.map.with_index do |(name, attrs), position|
  category = household.categories.find_or_create_by!(name: name) do |c|
    c.color = attrs[:color]
    c.position = position
  end

  (1..12).each do |m|
    target = category.budget_targets.find_or_initialize_by(year:, month: m)
    target.update!(amount: attrs[:target])
  end

  category
end.index_by(&:name)

# Sample expenses for the current month (only if none exist yet).
if household.expenses.for_month(year, month).none?
  first = Date.new(year, month, 1)
  [
    [ categories["Rent"],          alex, "Monthly rent",     "", 1800, true,  1 ],
    [ categories["Groceries"],     alex, "Costco haul",      "Bulk groceries", 184.32, true, 3 ],
    [ categories["Groceries"],     sam,  "Farmers market",   "Veg + eggs", 47.80, true, 8 ],
    [ categories["Utilities"],     sam,  "Electricity",      "", 96.40, true, 10 ],
    [ categories["Dining out"],    alex, "Anniversary dinner", "", 142.00, true, 12 ],
    [ categories["Dining out"],    sam,  "Solo lunch",       "Personal", 18.50, false, 14 ],
    [ categories["Transport"],     alex, "Gas",              "", 58.10, true, 15 ],
    [ categories["Entertainment"], sam,  "Concert tickets",  "", 120.00, true, 18 ]
  ].each do |category, payer, title, description, amount, shared, day|
    household.expenses.create!(
      category:, user: payer, title:, description:,
      amount:, shared:, paid_on: first.change(day: [ day, first.end_of_month.day ].min)
    )
  end
end

puts "Seeded household '#{household.name}' with #{household.users.count} members, " \
     "#{household.categories.count} categories, and #{household.expenses.count} expenses."
puts "Sign in as alex@example.com or sam@example.com (password: #{PASSWORD})."
