class Division < ApplicationRecord
  has_many :offices, dependent: :destroy

  validates :ocd_id, presence: true, uniqueness: true
end
