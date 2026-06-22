class Household < ApplicationRecord
  has_many :users, dependent: :nullify
  has_many :invitations, dependent: :destroy
  has_many :categories, -> { order(:position, :name) }, dependent: :destroy
  has_many :budget_targets, through: :categories
  has_many :expenses, dependent: :destroy
  has_many :settlements, dependent: :destroy

  validates :name, presence: true
end
