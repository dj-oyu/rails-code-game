require "net/http"
require "uri"
require "json"

class ProblemGenerator
  def self.generate(prompt)
    endpoint = ENV["LLM_API_ENDPOINT"]
    token = ENV["LLM_API_TOKEN"]

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

    system_prompt = <<~PROMPT
      あなたはRubyのコード問題を作成するAIです。
      以下のJSON Schemaに従い、冗長なコード問題をJSONで返してください。

      #{JSON.pretty_generate(schema)}

      問題作成時の制約:
      1. 問題は「標準出力に特定の値を出力する」タイプにしてください
      2. initial_codeは冗長で非効率なコードにしてください
      3. expected_outputは標準出力に出るべき値を明記してください
      4. 問題の難易度は初級〜中級にしてください
      5. 使用するメソッドや変数名を明確に指定してください
      6. 問題文には「標準出力に答えを出力してください」と明記してください
      7. 問題文には「puts」を使うことを明記してください
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
    JSON.parse(content)
  end
end
