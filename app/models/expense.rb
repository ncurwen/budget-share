class Expense < ApplicationRecord
  include Monetizable

  belongs_to :household
  belongs_to :category
  belongs_to :user

  alias_method :payer, :user
  alias_method :payer=, :user=

  monetize :amount_cents

  def self.ransackable_attributes(_auth_object = nil)
    %w[title description paid_on amount_cents shared category_id created_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[category user]
  end

  validates :title, presence: true
  validates :paid_on, presence: true
  validates :amount_cents, numericality: { greater_than: 0 }

  # Guard against attaching another household's category or a non-member payer
  # via crafted form params.
  validate :category_belongs_to_household
  validate :payer_belongs_to_household

  scope :shared, -> { where(shared: true) }
  scope :personal, -> { where(shared: false) }
  scope :for_month, ->(year, month) {
    start = Date.new(year, month, 1)
    where(paid_on: start..start.end_of_month)
  }
  scope :for_year, ->(year) {
    where(paid_on: Date.new(year, 1, 1)..Date.new(year, 12, 31))
  }
  scope :recent_first, -> { order(paid_on: :desc, created_at: :desc) }

  broadcasts_refreshes_to ->(expense) { [ expense.household, :expenses ] }

  private

  def category_belongs_to_household
    return if category.nil? || household_id.nil?

    errors.add(:category, "must belong to this household") if category.household_id != household_id
  end

  def payer_belongs_to_household
    return if user.nil? || household.nil?

    errors.add(:user, "must be a household member") unless household.users.exists?(user.id)
  end
end
