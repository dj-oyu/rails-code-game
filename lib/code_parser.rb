require 'ripper'

class CodeParser
  # Rubyコードから変数とメソッドを抽出する
  def self.extract_symbols(code)
    return [] if code.nil? || code.empty?

    # Ripperを使ってコードをパース
    sexp = Ripper.sexp(code)
    return [] unless sexp

    # 変数とメソッドを格納する配列
    symbols = {
      variables: [],
      methods: [],
      classes: []
    }

    # 再帰的にSexpツリーを探索
    extract_from_sexp(sexp, symbols)

    # 重複を削除して返す
    {
      variables: symbols[:variables].uniq,
      methods: symbols[:methods].uniq,
      classes: symbols[:classes].uniq
    }
  end

  private

  # Sexpツリーから変数とメソッドを抽出する再帰関数
  def self.extract_from_sexp(sexp, symbols)
    return unless sexp.is_a?(Array)

    case sexp[0]
    when :var_field, :var_ref
      # 変数参照
      symbols[:variables] << sexp[1][1] if sexp[1][0] == :@ident
    when :assign
      # 変数代入
      if sexp[1][0] == :var_field && sexp[1][1][0] == :@ident
        symbols[:variables] << sexp[1][1][1]
      end
    when :def
      # メソッド定義
      symbols[:methods] << sexp[1][1] if sexp[1][0] == :@ident
    when :call
      # メソッド呼び出し
      if sexp[3][0] == :@ident
        symbols[:methods] << sexp[3][1]
      end
    when :class
      # クラス定義
      if sexp[1][1][0] == :@const
        symbols[:classes] << sexp[1][1][1]
      end
    end

    # 子ノードを再帰的に探索
    sexp.each do |node|
      extract_from_sexp(node, symbols) if node.is_a?(Array)
    end
  end
end
