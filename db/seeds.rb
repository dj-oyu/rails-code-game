Problem.create!(
  title: "配列の合計を求めよ",
  description: "forループで合計を計算するコードを短く書き直せ。標準出力に合計を出してください。",
  initial_code: <<~RUBY,
    arr = [1, 2, 3, 4, 5]
    sum = 0
    for n in arr
      sum += n
    end
    puts sum
  RUBY
  test_code: "",
  expected_output: "15"
)
