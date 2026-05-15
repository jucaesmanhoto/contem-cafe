class AddToCoffee < ActiveRecord::Migration[8.1]
  def change
    add_column :coffees, :species, :string
    add_column :coffees, :price, :integer
    add_column :coffees, :slug, :string
  end
end
