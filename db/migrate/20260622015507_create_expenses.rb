class CreateExpenses < ActiveRecord::Migration[8.1]
  def change
    create_table :expenses do |t|
      t.references :household, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.date :paid_on, null: false
      t.integer :amount_cents, null: false, default: 0
      t.boolean :shared, null: false, default: true

      t.timestamps
    end

    add_index :expenses, [ :household_id, :paid_on ]
  end
end
