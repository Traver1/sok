class CreateSok < ActiveRecord::Migration[5.1]
  def change
    create_table :soks do |t|
      t.integer :company_id, null: false
      t.date :date, null: false
      t.float :open
      t.float :high
      t.float :low
      t.float :close
      t.integer :volume, limit: 8
    end
    add_index :soks, [:company_id, :date], unique: true
  end
end
