class RenameTurningPointInSecondsOnBatches < ActiveRecord::Migration[8.1]
  def up
    return unless column_exists?(:batches, :turning_point_in_seconds)
    return if column_exists?(:batches, :turning_point_time_in_seconds)

    rename_column :batches, :turning_point_in_seconds, :turning_point_time_in_seconds
  end

  def down
    return unless column_exists?(:batches, :turning_point_time_in_seconds)
    return if column_exists?(:batches, :turning_point_in_seconds)

    rename_column :batches, :turning_point_time_in_seconds, :turning_point_in_seconds
  end
end
