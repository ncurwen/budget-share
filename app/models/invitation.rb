class Invitation < ApplicationRecord
  belongs_to :household
  belongs_to :invited_by, class_name: "User"

  has_secure_token :token

  validates :email, presence: true

  scope :pending, -> { where(accepted_at: nil) }

  def accepted?
    accepted_at.present?
  end

  # Moves the user into the household and marks the invite accepted.
  def accept!(user)
    transaction do
      user.update!(household: household)
      update!(accepted_at: Time.current)
    end
  end
end
