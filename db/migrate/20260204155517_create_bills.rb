class CreateBills < ActiveRecord::Migration[8.1]
  def change
    create_table :bills do |t|
      t.integer :congress, null: false
      t.string :bill_type, null: false
      t.integer :number, null: false
      t.string :title
      t.string :short_title
      t.text :summary
      t.date :introduced_on
      t.string :current_status
      t.date :current_status_date
      t.string :source_path

      t.timestamps
    end

    add_index :bills, [:congress, :bill_type, :number], unique: true
    add_index :bills, :introduced_on
  end
end
