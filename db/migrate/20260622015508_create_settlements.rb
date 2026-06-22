class CreateSettlements < ActiveRecord::Migration[8.1]
  def change
    create_table :settlements do |t|
      t.references :household, null: false, foreign_key: true
      t.integer :year, null: false
      t.integer :month, null: false
      t.integer :amount_cents, null: false, default: 0
      t.references :debtor, null: false, foreign_key: { to_table: :users }
      t.references :creditor, null: false, foreign_key: { to_table: :users }
      t.datetime :settled_at
      t.references :settled_by, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :settlements, [ :household_id, :year, :month ], unique: true
  end
end
