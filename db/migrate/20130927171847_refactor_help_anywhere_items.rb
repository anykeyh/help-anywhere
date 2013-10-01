class RefactorHelpAnywhereItems < ActiveRecord::Migration
  def change
    remove_column :help_anywhere_items, :target
    remove_column :help_anywhere_items, :x
    remove_column :help_anywhere_items, :y
    remove_column :help_anywhere_items, :width
    remove_column :help_anywhere_items, :height
    remove_column :help_anywhere_items, :content
    add_column :help_anywhere_items, :content, :text
  end
end
