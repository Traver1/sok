class CreateCompany < ActiveRecord::Migration[5.1]
  def change
    create_table :companies do |t|
      t.string :code, null: false
      t.string :market, null: false
    end
    add_index :companies, [:code, :market], unique: true 
  end
end
