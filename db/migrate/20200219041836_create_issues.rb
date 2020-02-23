class CreateIssues < ActiveRecord::Migration[5.2]
  def change
    create_table :issues do |t|
      t.integer :user_id, null: false
      t.integer :team_id, null: false
      t.string :title, null: false
      t.text :body, null: false
      t.boolean :has_settled, null: false, default: false
      t.datetime :settled_at

      t.timestamps
    end
  end
end
