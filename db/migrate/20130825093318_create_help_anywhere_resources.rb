class CreateHelpAnywhereResources < ActiveRecord::Migration
  def change
    create_table :help_anywhere_resources do |t|
      t.string :name

      t.timestamps
    end
  end
end
