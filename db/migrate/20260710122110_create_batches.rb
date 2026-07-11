class CreateBatches < ActiveRecord::Migration[8.1]
  def change
    create_table :batches do |t|
      t.references :coffee, null: false, foreign_key: true
      t.string :batch_number
      t.datetime :roast_end_time
      t.integer :total_time_in_seconds
      t.integer :start_celsius_temperature
      t.integer :turning_point_in_seconds
      t.integer :turning_point_celsius_temperature
      t.integer :turn_to_yellow_time_in_seconds
      t.integer :turn_to_yellow_celsius_temperature
      t.integer :first_crack_time_in_seconds
      t.integer :first_crack_celsius_temperature
      t.integer :initial_quantity_in_grams
      t.integer :final_quantity_in_grams
      t.integer :color_in_agtron

      t.timestamps
    end
  end
end
