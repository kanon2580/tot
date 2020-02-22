class CreateResponseEvaluations < ActiveRecord::Migration[5.2]
  def change
    create_table :response_evaluations do |t|
      t.integer :user_id, null: false
      t.integer :comment_id
      t.datetime :created_issue_at, null: false
      t.datetime :first_comment_created_at, null: false
      t.float :difference, null: false

      t.timestamps
    end
    add_index :response_evaluations, [:user_id, :comment_id], unique: true
  end
end
