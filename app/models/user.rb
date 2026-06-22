class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :household, optional: true
  has_many :expenses, dependent: :nullify
  has_many :sent_invitations, class_name: "Invitation", foreign_key: :invited_by_id,
                              inverse_of: :invited_by, dependent: :nullify

  validates :name, presence: true
end
