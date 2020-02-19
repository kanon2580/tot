class CreateTaggings < ActiveRecord::Migration[5.2]
  def change
    create_table :taggings do |t|

      t.timestamps
    end
  end
end
