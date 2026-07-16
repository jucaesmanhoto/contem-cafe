class ChangeQuantityInGramsToDecimalOnBatches < ActiveRecord::Migration[8.1]
  def change
    change_column :batches, :initial_quantity_in_grams, :decimal, precision: 8, scale: 1
    change_column :batches, :final_quantity_in_grams, :decimal, precision: 8, scale: 1
  end
end
