class OfficeHolding < ApplicationRecord
  belongs_to :office
  belongs_to :person
end
