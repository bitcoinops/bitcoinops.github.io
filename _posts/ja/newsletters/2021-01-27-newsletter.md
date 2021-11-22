---
title: 'Bitcoin Optech Newsletter #133'
permalink: /ja/newsletters/2021/01/27/
name: 2021-01-27-newsletter-ja
slug: 2021-01-27-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Taprootのアクティベーションの仕組みについて話し合うためのミーティングの発表と、
Bitcoin Coreの使用状況調査のためのリンク、Bitcoin Stack Exchangeの上位の質問と回答、
リリースとリリース候補のリストおよび人気のBitcoinインフラストラクチャソフトウェアの注目すべき変更点の説明などの
通常のセクションを掲載しています。

## ニュース

- **Taprootのアクティベーションについて話し合うために予定されたミーティング:**
  Michael Folksonは、<time datetime="2021-02-02 19:00-0000">2月2日の19:00 UTC</time>に
  Freenodeの[##taproot-activation][]IRCチャンネルで、[BIP8][]のいくつかの望ましい改訂について
  話し合うことを[発表しました][folkson announce]。
  BIP8を実際にアクティベーションに使用するかどうかはまだ決まっていないため、今回のミーティングやその後のミーティングで
  代替案が議論されるかもしれません。[Taproot][topic taproot]のアクティベーションの仕組みについての背景や、
  ミーティングのアジェンダについてはFolksonのメールを参照してください。

- **Bitcoin Coreの使用状況の調査:**Bitcoin Coreの開発者Andrew Chowは、Bitcoin Coreのユーザーを対象とした
  [アンケート][chow survey]を作成しました。アンケートについての[ブログ記事][chow blog]で説明されているように、
  回答はユーザーの使用状況や求めていることを開発者に知らせるために使用されます。このアンケートは3月2日まで実施されます。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・答えを紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--q1-->ホワイトペーパーはどうやってブロックチェーンからデコードすればよいのでしょうか？]({{bse}}35959)
  2015年の元の質問へのフォローアップで、Steven RooseはフルノードでBitcoinのホワイトペーパーのPDFを生成するための
  `getrawtransaction`を使った1行の`bitcoin-cli`コマンドを提供しています。
  [jb55][bitcoin whitepaper gettxout]はプルーニングされたノードで機能する`gettxout`を使った同様のコマンドを提供しました。

- [<!--q2-->Bitcoin Script実行中の特殊ケースの完全なリスト?]({{bse}}101142)
  Pieter Wuilleは、[BIP16][] P2SHと[BIP141][] Segwitの両方の追加ルールの条件を含む、Bitcoin Scriptの評価の概要を擬似コードで提供しています。

- [<!--q3-->初見で二重支払い攻撃を防げますか？]({{bse}}101827)
  David Lynchは、[Replace-By-Fee (RBF)][topic rbf]を使わなければ二重支払い攻撃を防ぐことができるかどうか質問しています。
  これに対しPieter Wuilleは、ネットワーク上でのトランザクションの伝播を取り巻くさまざまなニュアンスの考慮事項やインセンティブについて説明し、
  どのようなタイプの未承認トランザクションであっても信頼することはできず、ユーザーは承認を待つべきだと結論づけています。

- [<!--q4-->Compact Block Filterを使用する軽量クライアントは、どうやって関連する未承認トランザクションを取得するんでしょうか？]({{bse}}101512)
  ユーザーPseudonymousは、[BIP37][topic transaction bloom filtering]Bloomトランザクションフィルタリングは未承認トランザクションを
  サポートしているが、[Compact Block Filter][topic compact block filters]はそのような考慮はしておらず、
  軽量クライアントには未承認トランザクションが有効か検証する手段がないため、圧縮されたブロックデータを持つ軽量クライアントにのみサービスを提供すると説明しています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [C-Lightning 0.9.3][c-lightning 0.9.3]はプロジェクトの最新のマイナーリリースです。
  これには、ユーザーインターフェースとプラグインの機能に加えて、提案されているOnion messageプロトコル（[Newsletter #92][news92 cl3600]参照）
  とOfferプロトコル（[Newsletter #128][news128 cl4255]参照）の実験的なサポートが含まれています。詳細は[リリースノート][c-lightning 0.9.3]と[変更履歴][cl cl]を参照してください。

- [LND 0.12.0-beta][]はこのLNソフトウェアの次のメジャーバージョンの最新リリースです。
  これには、[anchor output][topic anchor outputs]を利用したWatchtowerを使用するためのサポートが含まれ、
  [PSBT][topic psbt]を操作するための新しい`psbt`ウォレットサブコマンドが追加され、
  その他の改善やバグ修正も含まれています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、
[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #19866][]は、User-Level Statically Defined Trace (USDT) プローブのフレームワークを追加します。
  Linuxカーネルは、実行時にこれらのトレースポイントにフックすることができ、これによりノードオペレーターはbpftraceなどの
  eBPF (extended Berkely Packet Filter)ツールを使ってユーザースペースからカスタムインストロペクションを追加することができます。
  これは例えば、ほとんどオーバーヘッドなくロギングやプロファイリングを柔軟に追加するのに使えます。フレームワークがマージされたので、
  Bitcoin CoreでのUSDTプローブの潜在的なユースケースを探るため、課題[#20981][Bitcoin Core #20981]が公開されました。

- [Bitcoin Core #17920][]では 、macOS用のBitcoin Coreのバイナリに
  GNU Guixを使った[再現性のあるビルド][topic reproducible builds]のためのサポートを追加します。
  WindowsといくつかのLinuxプラットフォームはすでにサポートされているため、新しいGuix決定性ビルドシステムは
  既存のGitianシステムと同じプラットフォームをすべてサポートするようになりました。

- [LND #4908][]では、[anchor output][topic anchor outputs]を使っているチャネルが、
  場合によって確保していた残高を適用することでチャネル閉鎖時にコミットメントトランザクションの手数料をバンプできることを保証します。
  とはいえ、通常の`SendCoins` RPC呼び出しでは、`send_all`がセットされている場合を除いて、この確保していた残高はまだ適用されません。

{% include references.md %}
{% include linkers/issues.md issues="20981,19866,17920,4908" %}
[lnd 0.12.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.12.0-beta
[c-lightning 0.9.3]: https://github.com/ElementsProject/lightning/releases/tag/v0.9.3
[##taproot-activation]: https://webchat.freenode.net/##taproot-activation
[news92 cl3600]: /en/newsletters/2020/04/08/#c-lightning-3600
[news128 cl4255]: /en/newsletters/2020/12/16/#c-lightning-4255
[cl cl]: https://github.com/ElementsProject/lightning/blob/v0.9.3/CHANGELOG.md#093---2021-01-20
[folkson announce]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-January/018370.html
[chow survey]: https://survey.alchemer.com/s3/6081474/8acd79087feb
[chow blog]: https://achow101.com/2021/01/bitcoin-core-survey
[bitcoin whitepaper gettxout]: https://bitcoinhackers.org/@jb55/105595146491662406
