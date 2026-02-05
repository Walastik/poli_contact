class CreatePeople < ActiveRecord::Migration[8.1]
  def change
    create_table :people do |t|
      t.string :name, null: false
      t.string :party
      t.string :photo_url
      t.string :email
      t.string :phone
      t.string :url
      t.jsonb :address_json, default: {}
      t.string :google_civic_person_id
      t.string :bioguide_id
      t.string :govtrack_id

      t.timestamps
    end

    add_index :people, :google_civic_person_id
    add_index :people, :bioguide_id
    add_index :people, :govtrack_id
  end
end
