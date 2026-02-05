class CreateDivisions < ActiveRecord::Migration[8.1]
  def change
    create_table :divisions do |t|
      t.string :ocd_id, null: false
      t.string :name
      t.string :level
      t.string :country
      t.string :state
      t.string :county
      t.string :district

      t.timestamps
    end

    add_index :divisions, :ocd_id, unique: true
  end
end
