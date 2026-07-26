class CreateReferrals < ActiveRecord::Migration[8.1]
  def change
    create_table :referrals do |t|
      t.string :name, null: false
      t.string :phone, null: false
      t.string :token, null: false
      # Nullable: the root of a chain has no referrer
      t.references :referrer, null: true, foreign_key: { to_table: :referrals }
      t.integer :depth, null: false, default: 0

      t.timestamps
    end

    add_index :referrals, :token, unique: true
  end
end
