class AnswersController < ApplicationController
  def create
    problem = Problem.find(params[:problem_id])
    user_code = params[:user_code]

    result = CodeEvaluator.evaluate(user_code, problem.expected_output)

    Answer.create!(
      problem: problem,
      user_code: user_code,
      result: result[:result],
      output: result[:output],
      error_log: result[:error_log]
    )

    @result = result
    render :create
  end
end
