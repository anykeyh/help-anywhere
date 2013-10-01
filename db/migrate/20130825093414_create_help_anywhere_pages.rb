class CreateHelpAnywherePages < ActiveRecord::Migration
  def change
    create_table :help_anywhere_pages do |t|
      t.integer :number
      t.references :resource

      t.timestamps
    end
    add_index :help_anywhere_pages, :resource_id
  end
end
