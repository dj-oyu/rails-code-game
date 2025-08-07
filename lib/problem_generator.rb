require "net/http"
require "uri"
require "json"

class ProblemGenerator
  def self.generate(prompt)
    endpoint = ENV["LLM_API_ENDPOINT"]
    token = ENV["LLM_API_TOKEN"]
    
    # 既存の問題を例として取得（最大3件）
    existing_examples = get_existing_examples(3)

    uri = URI.parse(endpoint)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"

    req = Net::HTTP::Post.new(uri.path, {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{token}"
    })
    schema = {
      type: "object",
      properties: {
        title: { type: "string" },
        description: { type: "string" },
        initial_code: { type: "string" },
        expected_output: { type: "string" }
      },
      required: ["title", "description", "initial_code", "expected_output"]
    }

    # 既存問題の例を含むプロンプト作成
    examples_text = ""
    if existing_examples.any?
      examples_text = "以下は既存の問題例です。これらとは異なる独創的な問題を作成してください：\n\n"
      existing_examples.each_with_index do |example, index|
        examples_text += "例#{index + 1}:\n"
        examples_text += "タイトル: #{example[:title]}\n"
        examples_text += "説明: #{example[:description]}\n"
        examples_text += "初期コード: #{example[:initial_code]}\n"
        examples_text += "期待出力: #{example[:expected_output]}\n\n"
      end
    end

    system_prompt = <<~PROMPT
      あなたはRubyのコード問題を作成するAIです。
      以下のJSON Schemaに従い、冗長なコード問題をJSONで返してください。

      #{JSON.pretty_generate(schema)}

      問題作成時の制約:
      1. 問題は「標準出力に特定の値を出力する」タイプにしてください
      2. initial_codeは冗長で非効率なコードにしてください
      3. expected_outputフィールドは空文字列にしてください（システムが自動的に計算します）
      4. 問題の難易度は初級〜中級にしてください
      5. 使用するメソッドや変数名を明確に指定してください
      6. 問題文には「標準出力に答えを出力してください」と明記してください
      7. 問題文には「puts」を使うことを明記してください
      8. 既存の問題と重複しない、独創的な問題を作成してください
      9. 問題のテーマを多様にしてください（配列操作、文字列処理、数値計算、ハッシュ操作など）
      10. 実用的なプログラミング課題を意識してください
      11. initial_codeは必ず実行可能なRubyコードにしてください（シンタックスエラーがないこと）
      12. initial_codeの最後の行は必ず標準出力（puts/print/p等）か、値を返す式にしてください

      #{examples_text}
    PROMPT

    req.body = {
      model: ENV["LLM_MODEL"],
      messages: [
        { role: "system", content: system_prompt },
        { role: "user", content: prompt }
      ],
      response_format: {
        type: "json_object",
        schema: schema
      }
    }.to_json

    res = http.request(req)

    unless res.is_a?(Net::HTTPSuccess)
      raise "LLM API error: #{res.code} #{res.body}"
    end

    body = JSON.parse(res.body)
    content = body.dig("choices", 0, "message", "content")
  puts "--- Content to be parsed: ---"
  puts content.inspect
  puts "-----------------------------"
    JSON.parse(content)
  end
  
  # 既存の問題を取得するメソッド
  def self.get_existing_examples(limit = 3)
    return [] unless defined?(Problem)
    
    # ランダムに問題を取得
    problems = Problem.order(:id).limit(limit)
    
    problems.map do |problem|
      {
        title: problem.title,
        description: problem.description,
        initial_code: problem.initial_code,
        expected_output: problem.expected_output
      }
    end
  rescue => e
    # モデルが存在しない場合やDBエラーの場合は空配列を返す
    Rails.logger.error "Failed to get existing examples: #{e.message}"
    []
  end
end
