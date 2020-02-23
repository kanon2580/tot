class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.integer :user_id, null: false
      t.integer :issue_id, null: false
      t.integer :response_evaluation_id
      t.text :comment, null: false
      t.boolean :has_best_answer, null: false, default: false

      t.timestamps
    end
  end
end
