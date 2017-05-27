class CreateSplit < ActiveRecord::Migration[5.1]
  def change
    create_table :splits do |t|
      t.integer :sok_id, null: false
      t.float :before, null: false
      t.float :after, null: false
    end
    add_index :splits, [:sok_id], unique: true
  end
end
