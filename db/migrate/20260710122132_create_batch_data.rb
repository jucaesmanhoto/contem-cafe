class CreateBatchData < ActiveRecord::Migration[8.1]
  def change
    create_table :batch_data do |t|
      t.integer :time_in_milliseconds
      t.integer :bean_temperature_in_celsius
      t.integer :exaust_temperature_in_celsius
      t.decimal :ror
      t.decimal :power
      t.decimal :air_flow
      t.decimal :drum_rotation
      t.references :batch, null: false, foreign_key: true

      t.timestamps
    end
  end
end
