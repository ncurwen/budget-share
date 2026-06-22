class BudgetTarget < ApplicationRecord
  include Monetizable

  belongs_to :category
  has_one :household, through: :category

  monetize :amount_cents

  enum :month, {
    january: 1, february: 2, march: 3, april: 4, may: 5, june: 6,
    july: 7, august: 8, september: 9, october: 10, november: 11, december: 12
  }

  before_validation { self.amount_cents ||= 0 }

  validates :year, presence: true
  validates :month, presence: true
  validates :amount_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :category_id, uniqueness: { scope: [ :year, :month ] }
end
