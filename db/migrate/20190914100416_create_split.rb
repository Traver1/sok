class CreateSplit < ActiveRecord::Migration[5.2]
  def change
    create_table :splits do |t|
			t.references :sok
			t.float :before
 			t.float :after
    end
  end
end
