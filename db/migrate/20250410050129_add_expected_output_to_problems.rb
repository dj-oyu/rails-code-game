class AddExpectedOutputToProblems < ActiveRecord::Migration[8.0]
  def change
    add_column :problems, :expected_output, :text
  end
end
