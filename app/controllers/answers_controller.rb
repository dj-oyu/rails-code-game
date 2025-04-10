class AnswersController < ApplicationController
  # CSRFトークン検証をスキップ（Ajaxリクエスト用）
  skip_before_action :verify_authenticity_token, only: :create, if: -> { request.format.json? || request.xhr? }

  def create
    problem = Problem.find(params[:problem_id])
    user_code = params[:user_code]

    result = CodeEvaluator.evaluate(
      user_code, 
      problem.expected_output, 
      initial_code: problem.initial_code
    )

    answer = Answer.create!(
      problem: problem,
      user_code: user_code,
      result: result[:result],
      output: result[:output],
      error_log: result[:error_log]
    )

    respond_to do |format|
      format.html do
        @result = result
        render :create
      end
      format.json do
        # エラーメッセージを整形して返す
        output = result[:output]
        if result[:result] == "error" || result[:result] == "syntax_error"
          # エラーメッセージを簡潔に
          error_parts = output.split(":")
          if error_parts.size >= 2
            error_class = error_parts[0].strip
            error_message = error_parts[1..-1].join(":").strip
            output = "#{error_class}: #{error_message}"
          end
        end
        
        # 戻り値を文字列化
        return_value_str = nil
        begin
          return_value_str = result[:return_value].inspect if result[:return_value]
        rescue => e
          return_value_str = "表示できません: #{e.message}"
        end
        
        render json: {
          result: result[:result],
          output: output,
          return_value: return_value_str,
          answer_id: answer.id
        }
      end
      format.any do
        if request.xhr?
          # エラーメッセージを整形して返す
          output = result[:output]
          if result[:result] == "error" || result[:result] == "syntax_error"
            # エラーメッセージを簡潔に
            error_parts = output.split(":")
            if error_parts.size >= 2
              error_class = error_parts[0].strip
              error_message = error_parts[1..-1].join(":").strip
              output = "#{error_class}: #{error_message}"
            end
          end
          
          # 戻り値を文字列化
          return_value_str = nil
          begin
            return_value_str = result[:return_value].inspect if result[:return_value]
          rescue => e
            return_value_str = "表示できません: #{e.message}"
          end
          
          render json: {
            result: result[:result],
            output: output,
            return_value: return_value_str,
            answer_id: answer.id
          }
        else
          @result = result
          render :create
        end
      end
    end
  end
end
