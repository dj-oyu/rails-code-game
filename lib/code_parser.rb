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
      classes: [],
      puts_args: []
    }

    # 再帰的にSexpツリーを探索
    extract_from_sexp(sexp, symbols)

    # 末尾の変数評価を検出
    symbols[:tail_vars] = []
    symbols[:tail_vars_inner] = []
    if sexp.is_a?(Array) && sexp[0] == :program && sexp[1].is_a?(Array)
      last_stmt = sexp[1].last
      # 末尾が単一変数
      if last_stmt.is_a?(Array) && last_stmt[0] == :var_ref && last_stmt[1][0] == :@ident
        symbols[:tail_vars] << last_stmt[1][1]
      end
      # 末尾が式なら、その中の変数も抽出
      extract_inner_vars(last_stmt, symbols[:tail_vars_inner])
    end

    # putsの引数に含まれる変数の中身も抽出
    symbols[:puts_inner_vars] = []
    CodeParser.extract_puts_inner_vars(sexp, symbols[:puts_inner_vars])

    # putsの引数と末尾の変数を除外
    filtered_vars = symbols[:variables].uniq - symbols[:puts_args].uniq - symbols[:tail_vars].uniq - symbols[:tail_vars_inner].uniq - symbols[:puts_inner_vars].uniq

    # 重複を削除して返す
    {
      variables: filtered_vars,
      methods: symbols[:methods].uniq,
      classes: symbols[:classes].uniq,
      puts_args: symbols[:puts_args].uniq,
      tail_vars: symbols[:tail_vars].uniq,
      tail_vars_inner: symbols[:tail_vars_inner].uniq,
      puts_inner_vars: symbols[:puts_inner_vars].uniq
    }
  end

  # putsの引数に含まれる変数を再帰抽出
  def self.extract_puts_inner_vars(node, arr)
    return unless node.is_a?(Array)
    if node[0] == :command && node[1][1] == 'puts' && node[2][0] == :args_add_block
      args = node[2][1]
      args.each do |arg|
        extract_inner_vars(arg, arr)
      end
    else
      node.each { |child| extract_puts_inner_vars(child, arr) if child.is_a?(Array) }
    end
  end

  # 任意の式ノードから変数名を再帰抽出
  def self.extract_inner_vars(node, arr)
    return unless node.is_a?(Array)
    if node[0] == :var_ref && node[1][0] == :@ident
      arr << node[1][1]
    else
      node.each { |child| extract_inner_vars(child, arr) if child.is_a?(Array) }
    end
  end

  private

  # Sexpツリーから変数とメソッドを抽出する再帰関数
  def self.extract_from_sexp(sexp, symbols)
    return unless sexp.is_a?(Array)

    case sexp[0]
    when :assign
      # 変数代入
      if sexp[1][0] == :var_field && sexp[1][1][0] == :@ident
        symbols[:variables] << sexp[1][1][1]
      end
    when :def
      # メソッド定義
      symbols[:methods] << sexp[1][1] if sexp[1][0] == :@ident
    when :command
      # putsのようなメソッド呼び出し
      method_name = sexp[1][1] rescue nil
      if method_name == 'puts' && sexp[2][0] == :args_add_block
        args = sexp[2][1]
        args.each do |arg|
          if arg.is_a?(Array) && arg[0] == :var_ref && arg[1][0] == :@ident
            symbols[:puts_args] << arg[1][1]
          end
        end
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
