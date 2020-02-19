class CreateRequiredTimeEvaluations < ActiveRecord::Migration[5.2]
  def change
    create_table :required_time_evaluations do |t|
      t.integer :user_id, null: false
      t.integer :issue_id, null: false
      t.datetime :first_comment_created_at, null: false
      t.datetime :issue_settled_at, null: false
      t.float :difference, null: false

      t.timestamps
    end
    add_index :required_time_evaluations, [:user_id, :issue_id], unique: true
  end
end
