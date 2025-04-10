class ProblemsController < ApplicationController
  def index
    @problems = Problem.all
  end

  def generate
    prompt = "冗長なRubyコードとその説明を生成してください"
    response = ProblemGenerator.generate(prompt)

    # 期待するレスポンス例
    # {
    #   "title": "...",
    #   "description": "...",
    #   "initial_code": "...",
    #   "expected_output": "..." (空文字列が期待される)
    # }

    # 問題コードを実行して期待出力を計算
    begin
      result = CodeEvaluator.evaluate(response["initial_code"], "", timeout_sec: 5)
      
      # シンタックスエラーがある場合は問題を破棄
      if result[:result] == "syntax_error"
        flash[:alert] = "生成された問題コードにシンタックスエラーがあります。もう一度お試しください。"
        redirect_to problems_path
        return
      end
      
      # 出力または戻り値を期待出力として設定
      expected_output = if !result[:output].strip.empty?
                          result[:output].strip
                        elsif result[:return_value]
                          result[:return_value].to_s.strip
                        else
                          ""
                        end
      
      # 期待出力が空の場合は問題を破棄
      if expected_output.empty?
        flash[:alert] = "生成された問題コードは出力も戻り値もありません。もう一度お試しください。"
        redirect_to problems_path
        return
      end
      
      problem = Problem.create!(
        title: response["title"],
        description: response["description"],
        initial_code: response["initial_code"],
        test_code: "",
        expected_output: expected_output
      )

      redirect_to problem_path(problem), notice: "問題を自動生成しました"
    rescue => e
      flash[:alert] = "問題の生成中にエラーが発生しました: #{e.message}"
      redirect_to problems_path
    end
  end

  def show
    @problem = Problem.find(params[:id])
    
    # 問題コードから変数・メソッドを抽出
    require 'code_parser'
    @available_symbols = CodeParser.extract_symbols(@problem.initial_code)
  end
end
