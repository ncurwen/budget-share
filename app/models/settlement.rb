class Settlement < ApplicationRecord
  include Monetizable

  belongs_to :household
  belongs_to :debtor, class_name: "User"
  belongs_to :creditor, class_name: "User"
  belongs_to :settled_by, class_name: "User", optional: true

  monetize :amount_cents

  validates :year, presence: true
  validates :month, presence: true, inclusion: { in: 1..12 }
  validates :household_id, uniqueness: { scope: [ :year, :month ] }

  def settled?
    settled_at.present?
  end

  def settle!(user)
    update!(settled_at: Time.current, settled_by: user)
  end
end
