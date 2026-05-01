class CreateFarms < ActiveRecord::Migration[8.1]
  def change
    create_table :farms do |t|
      t.string :name, null: false
      t.text :description
      t.string :slug

      t.timestamps
    end

    add_index :farms, :slug, unique: true
  end
end
