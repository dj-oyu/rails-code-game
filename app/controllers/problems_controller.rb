class ProblemsController < ApplicationController
  def index
    @problems = Problem.all
  end

  def generate
    prompt = "冗長なRubyコードとその説明、期待出力を生成してください"
    response = ProblemGenerator.generate(prompt)

    # 期待するレスポンス例
    # {
    #   "title": "...",
    #   "description": "...",
    #   "initial_code": "...",
    #   "expected_output": "..."
    # }

    problem = Problem.create!(
      title: response["title"],
      description: response["description"],
      initial_code: response["initial_code"],
      test_code: "",
      expected_output: response["expected_output"]
    )

    redirect_to problem_path(problem), notice: "問題を自動生成しました"
  end

  def show
    @problem = Problem.find(params[:id])
  end
end
