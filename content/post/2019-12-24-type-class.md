---
title: 型クラスのご紹介
---

この記事は[型 Advent Calendar 2019](https://qiita.com/advent-calendar/2019/type)の 23 日目だったのですが、記事をはてなブログから^[元記事: <https://coordination.hatenablog.com/entry/2019/12/24/012049>]移転した^[[新設、移転 - coord-e.com](/post/2020-11-29-transfer.html)]際に内容を変更したので^[表現を変えたりとか、言い回しを直したりとか、あと記事の趣旨を「型クラスの紹介」に寄せて後半の流れを変えた]もともとのそれとは少し違うものとなっています。

## はじめに

この記事では OCaml みたいな ML 系言語が登場します。関数型プログラミング言語と呼ばれる何かしらに触れたことがある人ならお気持ちで読み取れると思います。そうでない人は[こちら](https://ocaml.org/learn/)から OCaml に入門してみると楽しいと思います。楽しいと思いますって何ですか…

## 型クラスの紹介

### オーバーロードの必要性 ^[OCaml を dis るみたいな構図になっていて本当に申し訳ない、OCaml でもファンクタを使えば似たようなことはできると思うので OCaml のことは嫌いにならないでください、お願いしましたよ。]

`int`型の値が 2 つあって、等しいのか調べたいですね。コードを書きます

```ocaml
let rec eq_int a b =
  match a, b with
  | 0, 0 -> true
  | _, 0 -> false
  | 0, _ -> false
  | n, m -> eq_int (n - 1) (m - 1)
```

なるほど^[負の数のこと忘れてたけど面倒だからこれでええか？いいよ]。じゃあ `string` は^[構造的等値の話しかしない]？[標準ライブラリに](https://caml.inria.fr/pub/docs/manual-ocaml/libref/String.html)いい関数があったので借りてくる。

```ocaml
let eq_string = String.equal
```

いいね。使ってみる^[ #は superuser とは全く関係なくて ocaml のトップレベルに打ってねって意味なので superuser で実行したことによるいかなる事態についても責任は負えません]。

```ocaml
# eq_int 1 2 ;;
- : bool = false
# eq_string "abc" "abc" ;;
- : bool = true
```

正しい感じがする。ところで OCaml には `=` という演算子があって…同じ型であればこの演算子を使って値の比較ができる:

```ocaml
# (=) ;;
- : 'a -> 'a -> bool = <fun>
# 1 = 2 ;;
- : bool = false
# "abc" = "abc" ;;
- : bool = true
```

お〜すごい。ところで文字列と数値は内部表現がかなり違いそうな気がしますが…

[前の記事でちょっと書いた話と関連するんですが](./2019-05-24-mlml-impl.html)、OCaml はランタイムの値にメタな情報を埋め込んで、それを見ながら `=` の実装内で実行時に分岐して比較しています。

でもちょっと待って、`1 = 1`では `int` の値に適用しているんだから `eq_int` を、`"abc" = "abc"`では `string` の値に適用しているんだから `eq_string` を呼べばいいってことはコンパイル時に分かるのでは？整数含む全オブジェクトに共通の内部表現を持たせるのはなかなか厳しいものがあるので^[しんどかった]、コンパイル時に呼び分けることができたらかなり嬉しいですね。

おっとそれだけではない！！`'a -> 'a -> bool`というハイパワーな型を持っているので、例えば関数同士の比較といった"ない"操作^[や、∀a. f a = g a ↔ f = g なのかもしれませんがそんなことを決定する能力は一般的なプログラミング言語に備わっていないので…]も型チェックを通ってしまう。

```ocaml
# eq_int = eq_int ;;  (* runtime error *)
Exception: Invalid_argument "compare: function value".
```

おぅ…これはしんどいわね。

別の例を見てみます。OCaml でも `+` は見た目に違わず、加算の演算子です。使ってみましょう:

```ocaml
# 1 + 2 ;;
- : int = 3
# 1.1 + 1.2 ;;
Error: This expression has type float but an expression was expected of type
         int
```

<!-- textlint-disable @textlint-ja/no-dropping-i -->

なんか言ってますね。型を見てみます

<!-- textlint-enable @textlint-ja/no-dropping-i -->

```ocaml
# (+) ;;
- : int -> int -> int = <fun>
```

なるほど `+` は `int` にしか使えないらしい。じゃあ `float` はどうすれば…`+.`があります

```ocaml
# (+.) ;;
- : float -> float -> float = <fun>
# 1.1 +. 1.2 ;;
- : float = 2.3
```

ん〜解決ｗとはならなくて、使う型ごとに演算子を変えなきゃいけないのはしんどいなあという気持ちになります。

この時点でわかったしんどさをまとめてみます。`=`と `+` の例に共通していたのは、「同じ記号に型によって違う意味を持たせたい」という点でした。その上で:

- 型ごとに別名を作りたくない
  - `+.`のようにユーザーに呼び分けを要求したくない
- 取れる型を、意味が存在する型のみに制限したい
  - `(=) :: ('a -> 'a) -> ('a -> 'a) -> bool` は許容したくない
  - `(+) :: bool -> bool -> bool` も許容したくない

まず前者の問題を解決するために登場するのが^[とは言っているが、動的型付けで入力の型をみて条件分岐すればいいじゃんとは言われてしまうので、静的型付けの文脈で…みたいな忖度をお願いします]、**オーバーロード** (overloading)と呼ばれる機能です。直感的な説明としては同じ名前に対して複数の意味を与えられる言語機能になります。下に C++での例を示します^[実は[これ](https://en.cppreference.com/w/cpp/language/implicit_conversion#Floating.E2.80.93integral_conversions)のせいで float で呼び出そうとすると ambigous って怒られるんだが本質とは関係ないので無視してくれよな…]。

```c++
int add(int a, int b) {
    return add_int(a, b);
}

float add(float a, float b) {
    return add_float(a, b);
}
```

ここで、`add`には 2 つの実装があり、引数が `int` か `float` かによって呼び分けることができます。`=`についても同様で、実際に C++の標準ライブラリでは `operator==` が比較関数として様々な型にオーバーロードされています。

なお、今後の記事中で二項演算子(`+`とか)は二引数関数として扱います。すなわち `a + b` は `(+) a b`としてパースされるイメージです。

### 多相性について

さて話は変わりますが、**多相性** (_polymorphism_) についてお話しします。複数の型を同時に表す型で、とある世界線でのジェネリクスのようなものです。
多相性には大きく分けて二種類あって、

- **パラメトリック多相** (_parametric polymorphism_)
  1 つの名前に複数の型を持つ。付く型によらず同一のオブジェクトを示す。
- **アドホック多相** (_ad-hoc polymorphism_)
  1 つの名前が複数の型を持つ。付く型によって異なるオブジェクトを示す。

があります。パラメトリック多相のわかりやすい例としてはリストの長さを返す関数 `len :: 'a list -> int` があります。これは任意の `'a` について `'a list` 型のリストの長さを求める 1 つの関数です。一方、先ほど紹介したオーバーロードは型によって違う実装が使われるのでアドホック多相ですね。

### 型クラスあらわる

では後者の問題、すなわち取れる型の制限について考えてみましょう。先ほどの例で、`=`は `'a -> 'a -> bool` では弱すぎることがわかりました。`+`ではその問題がよりはっきりしていて、`'a -> 'a -> 'a'`ではたまったもんじゃない。じゃあ、名前に対して取れる型の集合を与えてあげてはどうでしょうか？`int`, `float`, `bool`、そして関数型しかないと仮定すると、こう:

```ocaml
(=) :: { int -> int -> bool, float -> float -> bool, bool -> bool -> bool }
```

```ocaml
(+) :: { int -> int -> int, float -> float -> float }
```

オ〜良さそうだ。しかしこの方法では拡張性がないですね。
すなわちこの方法では `(=)` の**定義箇所で** `(=)` が使える型を全て把握している必要がありますが、実際には `(=)` の定義**の後に** `(=)` が使える型を増やしたいことは往々にしてあります。
言語プリミティブの型は `=` が使えるがユーザーが定義した型は結局呼び分ける必要があるというのは（先程の状況からは改善されたとはいえ）悲しい気持ちになってしまいます。

そこで**型クラス**です。型クラスを使うとオーバーロードされた名前が取りうる型を*制限された*型スキームの形で表現することができます。

```ocaml
(=) :: ∀'a. Eq 'a => 'a -> 'a -> bool
```

```ocaml
(+) :: ∀'a. Num 'a => 'a -> 'a -> 'a
```

これは先程の方法と比べると取りうる型の制限の仕方が `Eq 'a` などとすこし抽象的になっています。
型の分類^[と操作]を型から分離したことで拡張性を手に入れた、といった感じでしょうか。
そのため、ユーザーが定義した型でもその型が `Eq` であると後で宣言してやることで、その型に対して `(=)` を使うことができます！
なお、型が型クラスに含まれていることを宣言するものをインスタンス宣言と呼んでいます。

### 型コンストラクタの型クラス

話は変わりますが^[（2）]`map`関数を知っていますか？僕は知っています:

```ocaml
List.map :: ('a -> 'b) -> 'a list -> 'b list
```

さて、`'a option`にも `map` は定義されている。

```ocaml
Option.map :: ('a -> 'b) -> 'a option -> 'b option
```

なら、`map`もオーバーロードできまいか。

```ocaml
map :: ∀'a 'b 'f. Mappable 'f => ('a -> 'b) -> 'a 'f -> 'b 'f
```

ム、`Mappable`^[これ（`map`できるやつ）は Functor と呼ばれている]になっている `'f` は型ではない。これは `'a 'f` で型になっているところからわかるとおり型を受けとって型を返す**型コンストラクタ**で、これの上の型クラスも許すことができたら嬉しいです。こういう型クラスと型コンストラクタを組み合わせた体系は**constructor class**という名前で[[2]](#ref2)で提示されました。

型コンストラクタに対する型クラスがあると様々な抽象を表現することができて、例えば先ほどの `Mappable`（というか `Functor`）の他にも `Monad` というのがあります。`Monad`は手続きを抽象化した構造で、Haskell にような純粋なプログラミング言語で副作用などの文脈をもった計算（手続き）を構造として扱ううえで欠かせないものとなっています。[[2]](#ref2)にモナドを紹介している節があるのでそれを見るとふむふむという感じになります。

## 実装

なんか型クラスがあるととても嬉しいんだなってことがわかってきてくれましたか？ありがとうございます。
この機能は型クラスという名前で Haskell に、またトレイトという名前で Rust に実装されています^[Scala とかにもあるのかもしれないが、詳しくない]。
Haskell のほうのやつは型コンストラクタに対する型クラスもありますが、Rust では多相の型コンストラクタというのがないのでもちろん型コンストラクタに対する型クラスもありません。
ありませんが、それでも十分便利に活用されています^[むしろ Rust は orphan instance を禁じたおかげで（？）重複するインスタンス宣言に関する制約が Haskell より緩んでいて、それがめちゃくちゃうれしい]。

ではどのようにして型クラスを実装することができるでしょうか？
先程書いたとおり型クラスには 2 つの側面があり、それぞれ別の場所で実装をすることになります。すなわち：

- 制限された型スキーム
  - 型推論器・型チェッカでの話
  - `1 + 2` を受理し、 `true + false` を弾きたい
- 型付けの結果に依存した実装の選択（オーバーロード）
  - 型が付いた後のコード変形・コード生成での話
  - `1 == 2` で `eq_int` が、 `"a" == "bc"` で `eq_string` が呼ばれるようにしたい

前者の型推論の話では、利用箇所で型スキームが具体化された結果として生成された型クラス制約（`Eq int` や `Eq bool` など）が、存在するインスタンス宣言のどれかに*マッチ*するかどうかを検査することになります。
ここでマッチという言葉を使いましたが、この判定は型推論を実装するときにやる単一化と違って片方向にしか型変数を単一化しません。すなわち、`Eq ('a, 'b)` のインスタンス宣言に `Eq (int, bool)` の型制約はマッチする一方で、`Eq int` のインスタンス宣言に `Eq 'a` の型制約はマッチしないのがポイントです。

後者のオーバーロードの実装では、型推論のときに型制約がどういった道のりで生成・解決されたかを記録しておき、最後にそれに沿ってその型クラスに必要な実装を含む**辞書**を受け渡していくようにコードを変換します。
この辞書というのはインスタンス宣言ごとに存在する値で、 `Eq` だったら `(=)` が、 `Num` だったら `(+)` の実装が入っています。
型制約を最初に発生させた場所というのはすなわちその実装を必要としている場所なので、そこでは辞書からそれらの実装を取り出してそれを呼び出すようにします。

[[3]](#ref3)が型クラスを含む型推論の具体的な実装をわかりやすくコードを交えて説明しています。
また、自分が過去に書いたスライドが型クラスの実装が具体的にどういう感じになるのか説明しているので、こちらもどうぞ。

[embed](https://coord-e.github.io/slide-type-class-lt/ "Haskellの型クラス"){ description="型クラスっていうのがあるらしいです" }

## まとめ

型クラスというのがあり、あると嬉しい。

## 参考文献

- <a name="ref1">[[1]](#ref1) Wadler, Philip, and Stephen Blott. "How to make ad-hoc polymorphism less ad hoc." Proceedings of the 16th ACM SIGPLAN-SIGACT symposium on Principles of programming languages. ACM, 1989.
- <a name="ref2">[[2]](#ref2) Jones, Mark P. "A system of constructor classes: overloading and implicit higher-order polymorphism." Journal of functional programming 5.1 (1995): 1-35.
- <a name="ref3">[[3]](#ref3) Jones, Mark P. "Typing Haskell in Haskell." Haskell workshop. Vol. 7. 1999.