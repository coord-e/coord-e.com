---
title: iPad で PCDJ
og-description: 明らかにタッチインターフェースを備えている iPad を PCDJ 機材の代わりにできないか検討し、実際にある程度の体験を得ることができたのでここではそれを紹介します。
---

こんにちは。天久保 Advent Calendar 2022 14 日目の記事です。

[embed](https://adventar.org/calendars/8233 "天久保 Advent Calendar 2022 - Adventar"){ description="茨城県つくば市の町域であるところの天久保とは無関係な任意団体" }

背景としてオタクダンスミュージックに頭を破壊され、スピーカーが 2 台あり、それなりに大きな音が鳴っているところで、 ダンスミュージックは勝利できると私は確信しているので、音楽盛り上がり体験の地産地消をしたいと考えました（2022 年の要約）。しかし PCDJ 機材は高額であり、特に DJ をやったこともない状態でいきなり購入するにはハードルが高すぎる節があります。そこで、明らかにタッチインターフェースを備えている iPad を PCDJ 機材の代わりにできないか検討し、実際にある程度の体験を得ることができたのでここではそれを紹介します。背景やそれに至った理由などに興味がない場合は直接次のリンクを踏むことでどのように表題を実現するか知ることができます:

[embed](https://github.com/coord-e/TouchMixxx#installation "coord-e/TouchMixxx: TouchMixxx fork with layout that imitates DDJ-400"){ description="TouchMixxx fork with layout that imitates DDJ-400." }

## PCDJ とは

機材を PC に繋いで行う DJ の形式だと思います^[知りませんが…]。DJ という言葉をここでは「複数の楽曲をノンストップで繋いでいく行為」と同義として話していきますが、そのためには同時に流しているトラックの音量などを調整する複数のツマミ群が必要となります。そのつまみの集合体として DJ コントローラーがあり、それが PC につながっていれば PCDJ ということでいいんじゃないかと思います。つまみを複数同時に調整する必要があることからマウスでの操作では手が足りず、またつまみを連続に（+1, -1 などでなく！）操作する必要があることからキーボードでの操作では解像度か変化量のどちらかが足りません。そのためつまみ風のインターフェースを持った PCDJ コントローラーが必要になってきます。

### PCDJ コントローラーが高額

長らく入門用としての地位を築いてきた DDJ-400 という PCDJ コントローラーがあります。

[embed](https://www.pioneerdj.com/ja-jp/product/controller/ddj-400/black/overview/ "DDJ-400 - 2-channel DJ controller for rekordbox dj (Black)"){ description="プロフェッショナル向けスクラッチスタイル 2ch DJ ミキサー (Black)" }

これはここ数ヶ月にわたって品薄が続いておりそもそも入手が困難だったのですが、つい最近 (11/25) に後継機にあたる DDJ-FLX4 が発売されました^[見た目がよりいい感じになっていてうれしい！]。

[embed](https://www.pioneerdj.com/ja-jp/product/controller/ddj-flx4/black/overview/ "DDJ-FLX4 - マルチアプリ対応2ch DJコントローラー (Black)"){ description="DDJ-FLX4 は、全世界でエントリー層向けのスタンダードモデルとなった DDJ-400 のプロフェッショナルなレイアウトを引き継ぎながら、親しみやすいシンプルなデザインを採用した、これから DJ を楽しみたいほうに最適な DJ コントローラーです。" }

そのため今 PCDJ を初めるならこれを買うのが通常の手順だと思われますが、どちらにせよ 44000 円もし、これは高額です。私は 12 月の頭に買うつもりでいたのですが、予想外にも 12 月の頭に他に買いたいものが多すぎたため、断念しました。

## TouchOSC で PCDJ

いろいろなデバイスでタッチパネル入力から MIDI や OSC を出力するインターフェースを作ることができる TouchOSC というアプリケーションがあり、App Store で 1600 円です。

[embed](https://hexler.net/touchosc "TouchOSC | hexler.net"){ description="" }

明らかに DJ 行為に必要なつまみやボタンを作れそうですね。この TouchOSC と無償の DJ ソフトウェア Mixxx を組み合わせることで PCDJ 環境を構築していきます。Mixxx は DJ コントローラーを自前で作ることができ、そのため TouchOSC で作るオリジナルコントローラーにも対応できます。

[embed](https://mixxx.org/ "Mixxx - Free DJ Mixing Software App"){ description="Download the most advanced FREE DJ software available, featuring iTunes integration, MIDI controller support, internet broadcasting, and integrated music library." }

とはいえ、TouchOSC のレイアウトと Mixxx のコントローラーを作成する必要があります。まず、当然の如くそのようなことを考える先人は存在し、ありがたい先行実装を示してくれています:

[embed](https://github.com/VoidRatio/TouchMixxx "VoidRatio/TouchMixxx: TouchMixxx is a TouchOSC layout designed to control the Mixxx DJ software."){ description="TouchMixxx is a TouchOSC layout designed to control the Mixxx DJ software." }

しかし私もとい経験のなさから DJ 機材の購入を渋っている層は同時に DJ 行為の入門も行いたいという点に問題があります。というのも、この VoidRatio/TouchMixxx はタブのような形で 4 デック + ミキサを切り替える形になっており、一般的な入門教材での入門が通用しません。先述の通り DDJ-400 が入門機としてメジャーなため、DDJ-400 のレイアウトで入門教材を探すのが筋が良く思えます。そのため、この実装を参考に DDJ-400 を真似たレイアウトでコントローラーの実装を作成しました:

<https://github.com/coord-e/TouchMixxx>

![様子](https://github.com/coord-e/TouchMixxx/raw/ddj-400/DDJ-400.png)

このレイアウトを用い、実際に私は DDJ-400 の入門教材から DJ 行為に入門することができました。参考までに PioneerDJ が投稿している入門動画を一部列挙します。

- PioneerDJJPN が出しているチュートリアル
  - <https://www.youtube.com/playlist?list=PLl-9U3HVXmNcyLgdwAEnM_6YIPmaOVolh>
- PioneerDJ が出している動画
  - <https://www.youtube.com/watch?v=1AqDRnYLeg4>
  - <https://www.youtube.com/watch?v=4SHA45HtL2o>
  - <https://www.youtube.com/watch?v=QXEIujJb0k4>
  - <https://www.youtube.com/watch?v=mlkGgQxF9-I>

真っ当な機材を使ったことがないので普通どういう感じかわかんないんですが、この実装のジョグ（ターンテーブル）はあまり使えない感じになっています。クオンタイズをオンにした状態でしか使ったことがないです。クオンタイズなしでの Mix は機材を買ってから練習しようと思っています。またやはり遅延は避けることができず、練習用として諦めています。とはいえ、そこそこ楽しめているので、1600 円にしては良い結果が出ていると思います。また、コントローラー自体を柔軟にカスタマイズできるのは TouchOSC を使っているからこその利点です。TouchOSC では Lua が動き、TouchOSC の Mixxx コントローラーは JavaScript で書かれています。自分は気持ちが出ておらずまだやっていないのですが、DJ 中の操作を自動化する方向で楽しむのもまた一興なのかもしれませんね。

とはいえ DDJ-FLX4 がほしい（おわり）
