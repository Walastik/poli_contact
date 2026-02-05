class Person < ApplicationRecord
  has_many :office_holdings, dependent: :destroy
  has_many :offices, through: :office_holdings

  validates :name, presence: true
end
