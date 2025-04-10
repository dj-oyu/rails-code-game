require "timeout"

class CodeEvaluator
  # user_code: ユーザー提出のワンライナー等
  # test_code: そのコードを評価するRSpecコード（describe〜end）
  # 戻り値: { result: "success"|"fail"|"timeout"|"error", output: 実行時の標準出力・エラー }
  def self.evaluate(user_code, test_code, timeout_sec: 3)
    output = ""
    result = "error"

    begin
      Timeout.timeout(timeout_sec) do
        # ユーザーコードを評価対象に組み込む
        full_code = <<~RUBY
          #{user_code}
          #{test_code}
        RUBY

        # 出力を捕捉
        output = capture_stdout_stderr do
          eval(full_code, TOPLEVEL_BINDING)
        end

        result = "success"
      end
    rescue Timeout::Error
      result = "timeout"
    rescue RSpec::Expectations::ExpectationNotMetError => e
      output = e.message
      result = "fail"
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
