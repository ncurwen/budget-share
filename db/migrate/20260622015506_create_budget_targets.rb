class CreateBudgetTargets < ActiveRecord::Migration[8.1]
  def change
    create_table :budget_targets do |t|
      t.references :category, null: false, foreign_key: true
      t.integer :year, null: false
      t.integer :month, null: false
      t.integer :amount_cents, null: false, default: 0

      t.timestamps
    end

    add_index :budget_targets, [ :category_id, :year, :month ], unique: true
  end
end
