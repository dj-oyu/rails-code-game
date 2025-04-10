require "rails_helper"
require "code_parser"

RSpec.describe CodeParser do
  it "putsの引数の変数はvariablesに含まれない" do
    code = <<~RUBY
      x = 10
      y = 5
      result = x + y
      puts result
    RUBY

    symbols = CodeParser.extract_symbols(code)
    expect(symbols[:variables]).to include("x", "y")
    expect(symbols[:variables]).not_to include("result")
    expect(symbols[:puts_args]).to include("result")
  end

  it "putsの引数が複合式なら、その中の変数も除外される" do
    code = <<~RUBY
      a = 1
      b = 2
      c = 3
      puts a + b + c
    RUBY

    symbols = CodeParser.extract_symbols(code)
    expect(symbols[:variables]).not_to include("a", "b", "c")
    expect(symbols[:puts_inner_vars]).to include("a", "b", "c")
  end

  it "末尾が複合式なら、その中の変数も除外される" do
    code = <<~RUBY
      x = 1
      y = 2
      z = 3
      x + y + z
    RUBY

    symbols = CodeParser.extract_symbols(code)
    expect(symbols[:variables]).not_to include("x", "y", "z")
    expect(symbols[:tail_vars_inner]).to include("x", "y", "z")
  end

  it "通常の代入変数はvariablesに含まれる" do
    code = <<~RUBY
      foo = 1
      bar = 2
    RUBY

    symbols = CodeParser.extract_symbols(code)
    expect(symbols[:variables]).to include("foo", "bar")
  end

  it "メソッド定義はmethodsに含まれる" do
    code = <<~RUBY
      def add(a, b)
        a + b
      end
    RUBY

    symbols = CodeParser.extract_symbols(code)
    expect(symbols[:methods]).to include("add")
  end
end
