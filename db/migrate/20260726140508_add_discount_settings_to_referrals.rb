class AddDiscountSettingsToReferrals < ActiveRecord::Migration[8.1]
  def up
    add_column :referrals, :initial_discount_percentage, :decimal, precision: 5, scale: 2, default: 0.0
    add_column :referrals, :discount_percentage_per_level, :decimal, precision: 5, scale: 2, default: 2.5
    add_column :referrals, :max_discount_percentage, :decimal, precision: 5, scale: 2, default: 20.0

    change_column_null :referrals, :initial_discount_percentage, false
    change_column_null :referrals, :discount_percentage_per_level, false
    change_column_null :referrals, :max_discount_percentage, false

    # Drop the defaults after backfilling existing rows: new records must see
    # nil so the model callback can tell "not set" apart from "explicitly 0".
    change_column_default :referrals, :initial_discount_percentage, from: 0.0, to: nil
    change_column_default :referrals, :discount_percentage_per_level, from: 2.5, to: nil
    change_column_default :referrals, :max_discount_percentage, from: 20.0, to: nil
  end

  def down
    remove_column :referrals, :initial_discount_percentage
    remove_column :referrals, :discount_percentage_per_level
    remove_column :referrals, :max_discount_percentage
  end
end
