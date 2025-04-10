require "timeout"

class CodeEvaluator
  # user_code: ユーザー提出のワンライナー等
  # expected_output: 期待する出力
  # initial_code: 問題文中の初期コード（変数・メソッド定義を含む）
  # 戻り値: { result: "success"|"fail"|"timeout"|"error", output: 実行時の標準出力・エラー }
  def self.evaluate(user_code, expected_output, initial_code: nil, timeout_sec: 3)
    output = ""
    result = "error"
    error_log = nil
    return_value = nil

    begin
      Timeout.timeout(timeout_sec) do
        # 問題の初期コードを評価（変数・メソッド定義を反映）
        binding = TOPLEVEL_BINDING.dup
        if initial_code.present?
          # putsの引数変数を抽出し、ユーザーコード末尾でnil上書き
          begin
            require_relative 'code_parser'
            symbols = CodeParser.extract_symbols(initial_code)
            if symbols.is_a?(Hash)
              # putsの引数
              if symbols[:puts_args].is_a?(Array)
                symbols[:puts_args].each do |var|
                  user_code = "#{var} = nil\n" + user_code
                end
              end
              # 末尾の変数評価は長いランダム文字列で上書き
              require 'securerandom'
              if symbols[:tail_vars].is_a?(Array)
                symbols[:tail_vars].each do |var|
                  rand_str = SecureRandom.hex(32)
                  user_code = "#{var} = '#{rand_str}'\n" + user_code
                end
              end
            end
          rescue => e
            # 解析失敗時は何もしない
          end

          # 初期コードを評価（出力は捨てる）
          capture_stdout_stderr do
            eval(initial_code, binding)
          end
        end
        
        # 出力と戻り値を捕捉しつつユーザーコードを実行
        val = nil
        output = capture_stdout_stderr do
          val = eval(user_code, binding)
        end
        return_value = val

        # お題の期待出力が空文字列なら、ユーザーの出力も完全に空でなければfail
        if expected_output.strip.empty? && !output.empty?
          result = "fail"
        else
          # 出力が空なら戻り値を文字列化して比較
          compare_value = output.strip.empty? ? val.to_s.strip : output.strip

          if compare_value == expected_output.strip
            result = "success"
          else
            result = "fail"
          end
        end
      end
    rescue Timeout::Error
      result = "timeout"
    rescue SyntaxError => e
      # 簡潔なエラーメッセージを生成（ディレクトリパスを含まない）
      output = "#{e.class}: #{e.message}"
      result = "syntax_error"
      error_log = {
        error_type: "syntax_error",
        error_class: e.class.to_s,
        error_message: e.message,
        backtrace: e.backtrace,
        user_code: user_code,
        timestamp: Time.now.iso8601
      }
    rescue Exception => e
      # 簡潔なエラーメッセージを生成（ディレクトリパスを含まない）
      output = "#{e.class}: #{e.message}"
      result = "error"
      error_log = {
        error_type: "runtime_error",
        error_class: e.class.to_s,
        error_message: e.message,
        backtrace: e.backtrace,
        user_code: user_code,
        timestamp: Time.now.iso8601
      }
    end

    { 
      result: result, 
      output: output,
      return_value: return_value,
      error_log: (result == "error" || result == "syntax_error") ? error_log.to_json : nil
    }
  end

  def self.capture_stdout_stderr
    require "stringio"
    old_stdout = $stdout
    old_stderr = $stderr
    $stdout = StringIO.new
    $stderr = StringIO.new
    yield
    ($stdout.string + $stderr.string)
  ensure
    $stdout = old_stdout
    $stderr = old_stderr
  end
end
