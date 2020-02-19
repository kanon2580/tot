class CreateRequiredTimeEvaluations < ActiveRecord::Migration[5.2]
  def change
    create_table :required_time_evaluations do |t|

      t.timestamps
    end
  end
end
