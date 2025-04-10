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
