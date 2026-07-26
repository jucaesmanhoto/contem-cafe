class ChangeDepthDefaultOnReferrals < ActiveRecord::Migration[8.1]
  def change
    # No DB-level default: a new record's depth must start out nil so the
    # model callback can tell "not set yet" apart from "explicitly set to 0".
    change_column_default :referrals, :depth, from: 0, to: nil
  end
end
