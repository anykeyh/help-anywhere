class CreateHelpAnywhereItems < ActiveRecord::Migration
  def change
    create_table :help_anywhere_items do |t|
      t.string :target
      t.integer :x
      t.integer :y
      t.integer :width
      t.integer :height
      t.text :content
      t.string :class_id

      t.references :page

      t.timestamps
    end

    add_index :help_anywhere_items, :page_id
  end
end
