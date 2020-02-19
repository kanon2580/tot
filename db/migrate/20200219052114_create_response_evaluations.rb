class CreateResponseEvaluations < ActiveRecord::Migration[5.2]
  def change
    create_table :response_evaluations do |t|

      t.timestamps
    end
  end
end
