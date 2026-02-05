class CreateOffices < ActiveRecord::Migration[8.1]
  def change
    create_table :offices do |t|
      t.references :division, null: false, foreign_key: true
      t.string :name
      t.string :role
      t.string :google_civic_office_id

      t.timestamps
    end
  end
end
