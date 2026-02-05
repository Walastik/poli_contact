class Office < ApplicationRecord
  belongs_to :division

  has_many :office_holdings, dependent: :destroy
  has_many :people, through: :office_holdings

  validates :division, presence: true
end
