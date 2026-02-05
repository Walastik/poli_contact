class CreateOfficeHoldings < ActiveRecord::Migration[8.1]
  def change
    create_table :office_holdings do |t|
      t.references :office, null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
