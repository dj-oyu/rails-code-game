class CreateProblems < ActiveRecord::Migration[8.0]
  def change
    create_table :problems do |t|
      t.string :title
      t.text :description
      t.text :initial_code
      t.text :test_code

      t.timestamps
    end
  end
end
