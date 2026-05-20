class AddStockStatusToCoffee < ActiveRecord::Migration[8.1]
  def change
    add_column :coffees, :stock_status, :string
  end
end
