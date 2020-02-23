class CreateTags < ActiveRecord::Migration[5.2]
  def change
    create_table :tags do |t|
      t.integer :team_id, null: false
      t.string :name, null: false

      t.timestamps
    end
    add_index :tags, [:team_id, :name], unique: true
  end
end
