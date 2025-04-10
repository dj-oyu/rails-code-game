class AddErrorLogToAnswers < ActiveRecord::Migration[8.0]
  def change
    add_column :answers, :error_log, :text
  end
end
