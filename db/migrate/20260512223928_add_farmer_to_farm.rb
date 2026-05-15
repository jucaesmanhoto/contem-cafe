class AddFarmerToFarm < ActiveRecord::Migration[8.1]
  def change
    add_column :farms, :farmer, :string
    add_column :farms, :city, :string
    add_column :farms, :state, :string
    add_column :farms, :region, :string
  end
end
