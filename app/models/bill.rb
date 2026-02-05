class Bill < ApplicationRecord
  validates :congress, :bill_type, :number, presence: true

  scope :recent, -> { order(introduced_on: :desc).limit(20) }
end
