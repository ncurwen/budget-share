class Category < ApplicationRecord
  belongs_to :household
  has_many :expenses, dependent: :restrict_with_error
  has_many :budget_targets, dependent: :destroy
  accepts_nested_attributes_for :budget_targets

  validates :name, presence: true, uniqueness: { scope: :household_id, case_sensitive: false }

  def self.ransackable_attributes(_auth_object = nil)
    %w[name color position created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  # DaisyUI badge color suffixes available for categories.
  COLORS = %w[primary secondary accent info success warning error neutral].freeze

  # Target amount (in cents) set for a given year/month, or 0 if none.
  def target_cents_for(year, month)
    budget_targets.find_by(year:, month:)&.amount_cents || 0
  end

  # Existing targets for the year plus freshly built ones for any missing months,
  # so the editor can render all 12 months.
  def targets_for_year(year)
    existing = budget_targets.where(year:).index_by(&:month)
    BudgetTarget.months.keys.map { |month| existing[month] || budget_targets.build(year:, month:) }
  end
end
