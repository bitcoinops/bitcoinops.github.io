---
title: 'Bitcoin Optech Newsletter #281'
permalink: /ja/newsletters/2023/12/13/
name: 2023-12-13-newsletter-ja
slug: 2023-12-13-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Liquidity Adsのグリーフィング（嫌がらせ）に関する議論に加えて、
サービスとクライアントソフトウェアの変更、Bitcoin Stack Exchangeの人気のある質問とその回答、
新しいソフトウェアリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの最近の変更について掲載しています。

## ニュース

- **Liquidity Adsのグリーフィングの議論:** Bastien Teinturierは、
  [Liquidity Ads][topic liquidity advertisements]から作成された
  [デュアルファンドチャネル][topic dual funding]のタイムロックに関する潜在的な問題について
  Lightning-Devメーリングリストに[投稿しました][teinturier liqad]。
  これについては、以前[Recap #279][recap279 liqad]でも言及しました。
  たとえば、アリスは有料で28日間、自分の資金の内10,000 satsをチャネルにコミットしてもいいと広告します。
  28日間のタイムロックにより、アリスが支払いを受け取った後ですぐにチャネルを閉じて資金を他のことに使用することを防止します。

  例を続けると、ボブは100,000,000 sats (1 BTC)を追加で拠出してアリスとのチャネルを開設します。
  その後、ボブはすべての資金をこのチャネルを通じて送金します。現在、アリスのチャネル残高は、
  手数料として受け取った10,000 satsではなく、その金額のほぼ10,000倍です。
  ボブに悪意がある場合、アリスがコミットした28日間のタイムロックが切れるまで、
  資金の再移動を許可しないでしょう。

  Teinturierが提案し、彼や他の人たちによって議論された追加の緩和策は、
  タイムロックを提供した流動性（たとえば、アリスが提供した10,000 sats）にのみ適用するというものでした。
  これにより、問題は解決される可能性がありますが、複雑さが増し非効率になります。
  Teinturierが提案した代替案は、単純にタイムロックをやめ（またはオプションにし）、
  流動性の購入者に、プロバイダーが流動性の手数料を受け取った直後にチャネルを閉鎖するリスクを負わせるというものでした。
  Liquidity Adsを利用して開設されたチャネルが、通常、多額の転送手数料収入を生むのであれば、
  チャネルを開いたままにしておくインセンティブが生じるでしょう。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Stratum v2マイニングプールのローンチ:**
  [DEMAND][demand website]は、[Stratum v2参照実装][news247 sri]から構築されたマイニングプールで、
  最初はソロマイニングが可能で、将来的にはプールマイニングも計画されています。

- **Bitcoinネットワークのシミュレーションツールwarnetの発表:**
  [warnetソフトウェア][warnet github]を使用すると、ノードトポロジーを指定して、
  そのネットワーク上で[用意されたシナリオ][warnet scenarios]を実行し、
  [監視][warnet monitoring]とその結果の分析が可能になります。

- **Bitcoin Core用のPayjoinクライアントのリリース:**
  [payjoin-cli][]は、Bitcoin Core向けにコマンドラインの[payjoin][topic payjoin]送受信機能を追加するrustプロジェクトです。

- **<!--call-for-community-block-arrival-timestamps-->コミュニティによるブロック到着タイムスタンプの募集:**
  [Bitcoin Block Arrival Time Dataset][block arrival github]リポジトリのコントリビューターは、
  ノードオペレーターに対して、ブロック到着タイムスタンプの提出を[呼びかけました][b10c tweet]。
  [古いブロックデータ][stale block github]を収集する同様のリポジトリがあります。

- **Envoy 1.4リリース:**
  BitcoinウォレットEnvoyの[1.4リリース][envoy v1.4.0]では、[コインコントロール][topic
  coin selection]や[ウォレットのラベル付け][topic wallet labels]（[BIP329][]は近日公開）などの機能が追加されました。

- **BBQrエンコードスキームの発表:**
  この[スキーム][bbqr github]は、例えば[PSBT][topic psbt]のような大きなファイルを、
  エアギャップされたウォレット構成で使用するための一連のアニメーションQRに効率的にエンコードすることができます。

- **Zeus v0.8.0リリース:**
  [v0.8.0][zeus v0.8.0]リリースには、組み込みLNノードや、
  追加の[ゼロ承認チャネル][topic zero-conf channels]サポート、Simple Taproot Channelのサポート、
  その他の変更が含まれています。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [CPFPによる手数料の引き上げに関連するすべてのルールは？]({{bse}}120853)
  Pieter Wuilleは、関連するポリシールールのリストがある[RBF][topic rbf]による手数料引き上げ手法とは対照的に、
  [CPFP][topic cpfp]による手数料引き上げ手法には追加のポリシールールがないことを指摘しています。

- [RBFで置換されるトランザクションの総数はどのように計算されますか？]({{bse}}120823)
  MurchとPieter Wuilleは、[BIP125][]のルール5：「置き換えられる元のトランザクションと、
  mempoolから排除されるその子孫トランザクションの数は、合計100トランザクションを超えてはならない」
  に基づいて、RBFの置換の例をいくつか説明しています。読者は、PR Review Clubミーティングの
  [Add BIP-125 rule 5 testcase with default mempool][review club 25228]にも興味がわくかもしれません。

- [どのような種類のRBFが存在し、Bitcoin Coreはどれをデフォルトでサポートし、使用しますか？]({{bse}}120749)
  Murchは、Bitcoin Coreのトランザクションの置換の歴史と、[関連する質問]({{bse}}120773)で、
  RBF置換ルールのまとめとBitcoin Coreの[Mempool Replacements][bitcoin core mempool
  replacements]ドキュメントおよび[RBFの改善][glozow rbf improvements]に関するある開発者のアイディアのリンクを提供しています。

- [<!--what-is-the-block-1-983-702-problem-->ブロック1,983,702問題とは何ですか？]({{bse}}120834)
  Antoine Poinsotは、[BIP30][]でtxidの重複を制限し、
  [BIP34][]で現在のブロックの高さをコインベースフィールドに含めることを義務付ける原因となった問題の概要を説明しています。
  次に、ランダムなコインベースフィールドの内容が、後のブロックの必須の高さと偶然一致するブロックが多数存在することを指摘しています。
  ブロック1,983,702は、以前のブロックのコインベーストランザクションと同じものを使用できることが実質可能だった最初のブロックです。
  [関連する質問]({{bse}}120836)で、MurchとAntoine Poinsotは、その確率をより詳細に評価しています。
  [ニュースレター #182][news182 block1983702]もご覧ください。

- [Bitcoinでハッシュ関数は何に使われていますか？]({{bse}}120418)
  Pieter Wuilleは、コンセンサスルール、ピアツーピアプロトコル、ウォレットおよびノード実装にわたって、
  10以上の異なるハッシュ関数を使用する30以上の異なる事例を挙げています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.17.3-beta][]は、バックエンドでBitcoin Coreを使用した場合のメモリの削減を含む、
  いくつかのバグ修正を含むリリースです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [LDK #2685][]は、Electrumスタイルのサーバーからブロックチェーンデータを取得する機能を追加しています。

- [Libsecp256k1 #1446][]は、プロジェクトから一部のx86_64アセンブリコードを削除し、
  他のプラットフォームで常に使用されてきた既存のC言語のコードを使用するよう切り替えています。
  このアセンブリコードは、パフォーマンス向上のために数年前に人によって最適化されましたが、
  その間にコンパイラが改良され、GCCとLLVM（clang）の両方の最新バージョンでは
  さらにパフォーマンスの高いコードが生成されるようになりました。

- [BTCPay Server #5389][]では、[BIP129][]セキュアマルチシグウォレットセットアップ（
  [ニュースレター #136][news136 bip129]参照）のサポートを追加しています。
  これによりBTCPayサーバーは、簡単に調整されたマルチシグセットアップ手順の一部として、
  複数のソフトウェアウォレットおよびハードウェア署名デバイスと対話できるようになりました。

- [BTCPay Server #5490][]では、デフォルトで[mempool.space][]の[手数料の推定][ms fee api]を使用し始め、
  フォールバックとしてローカルのBitcoin Coreノードの手数料の推定を使用するようになりました。
  このPRにコメントした開発者は、Bitcoin Coreの手数料の推定は、
  ローカルのmempoolの変更に迅速に対応できていないと感じると述べています。
  手数料推定の精度を向上させるための課題に関する以前の関連する議論については、[Bitcoin Core
  #27995][]をご覧ください。

## ハッピーホリデー！

これは、Bitcoin Optechの今年最後の定期ニュースレターとなります。
12月20日（水）には、6回目の年間の振り返り特別号を発行します。
通常の発行は、1月3日（水）から再開します。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2685,5389,5490,1446,27995" %}
[LND 0.17.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.3-beta
[teinturier liqad]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-December/004227.html
[ms fee api]: https://mempool.space/docs/api/rest#get-recommended-fees
[mempool.space]: https://mempool.space/
[news136 bip129]: /ja/newsletters/2021/02/17/#securely-setting-up-multisig-wallets
[recap279 liqad]: /en/podcast/2023/11/30/#update-to-the-liquidity-ads-specification-transcript
[news182 block1983702]: /ja/newsletters/2022/01/12/#bitcoin-core-23882
[demand website]: https://dmnd.work/
[news247 sri]: /ja/newsletters/2023/04/19/#stratum-v2
[warnet github]: https://github.com/bitcoin-dev-project/warnet
[warnet scenarios]: https://github.com/bitcoin-dev-project/warnet/blob/main/docs/scenarios.md
[warnet monitoring]: https://github.com/bitcoin-dev-project/warnet/blob/main/docs/monitoring.md
[payjoin-cli]: https://github.com/payjoin/rust-payjoin/tree/master/payjoin-cli
[block arrival github]: https://github.com/bitcoin-data/block-arrival-times
[b10c tweet]: https://twitter.com/0xb10c/status/1732826609260872161
[stale block github]: https://github.com/bitcoin-data/stale-blocks
[envoy v1.4.0]: https://github.com/Foundation-Devices/envoy/releases/tag/v1.4.0
[bbqr github]: https://github.com/coinkite/BBQr
[zeus v0.8.0]: https://github.com/ZeusLN/zeus/releases/tag/v0.8.0
[review club 25228]: https://bitcoincore.reviews/25228
[bitcoin core mempool replacements]: https://github.com/bitcoin/bitcoin/blob/master/doc/policy/mempool-replacements.md
[glozow rbf improvements]: https://gist.github.com/glozow/25d9662c52453bd08b4b4b1d3783b9ff
