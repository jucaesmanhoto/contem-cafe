class CreateCoffees < ActiveRecord::Migration[8.1]
  def change
    create_table :coffees do |t|
      t.string :name, null: false
      t.text :description
      t.string :variety
      t.string :processing
      t.integer :altitude
      t.references :farm, null: false, foreign_key: true

      t.timestamps
    end
  end
end
