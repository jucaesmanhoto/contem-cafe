class AddPositionToFarm < ActiveRecord::Migration[8.1]
  def change
    add_column :farms, :position, :integer, default: 0
  end
end
