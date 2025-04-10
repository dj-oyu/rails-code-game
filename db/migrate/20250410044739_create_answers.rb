class CreateAnswers < ActiveRecord::Migration[8.0]
  def change
    create_table :answers do |t|
      t.references :problem, null: false, foreign_key: true
      t.text :user_code
      t.string :result
      t.text :output

      t.timestamps
    end
  end
end
