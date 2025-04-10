require "timeout"

class CodeEvaluator
  # user_code: ユーザー提出のワンライナー等
  # test_code: そのコードを評価するRSpecコード（describe〜end）
  # 戻り値: { result: "success"|"fail"|"timeout"|"error", output: 実行時の標準出力・エラー }
  def self.evaluate(user_code, expected_output, timeout_sec: 3)
    output = ""
    result = "error"

    begin
      Timeout.timeout(timeout_sec) do
        # 出力と戻り値を捕捉しつつユーザーコードを実行
        val = nil
        output = capture_stdout_stderr do
          val = eval(user_code, TOPLEVEL_BINDING)
        end

        # 出力が空なら戻り値を文字列化して比較
        compare_value = output.strip.empty? ? val.to_s.strip : output.strip

        if compare_value == expected_output.strip
          result = "success"
        else
          result = "fail"
        end
      end
    rescue Timeout::Error
      result = "timeout"
    rescue Exception => e
      output = "#{e.class}: #{e.message}\n#{e.backtrace&.join("\n")}"
      result = "error"
    end

    { result: result, output: output }
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
