---
title: 'Bitcoin Optech Newsletter #248'
permalink: /ja/newsletters/2023/04/26/
name: 2023-04-26-newsletter-ja
slug: 2023-04-26-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin CoreからBIP35の`mempool`P2Pプロトコルメッセージのサポートを削除する提案に関する
フィードバックの要求に加え、Bitcoin Stack Exchangeからの人気の質問と回答、新しいリリースとリリース候補の発表、
人気のBitcoinインフラストラクチャソフトウェアの注目すべき変更など恒例のセクションを掲載しています。

## ニュース

- **BIP35 `mempool` P2Pメッセージの削除を提案:** Will Clarkは、
  [BIP35][]で元々定義されていた`mempool`P2Pメッセージのサポートを削除するために作成された[PR][bitcoin core #27426]について、
  Bitcoin-Devメーリングリストに[投稿][clark mempool]しました。
  元の実装では、`mempool`メッセージを受信したノードは、
  自身のmempool内のすべてのトランザクションのtxidを含む`inv`メッセージで要求元のピアに応答していました。
  要求元のピアは、その後、受け取りたいトランザクションのtxidを含む通常の`getdata`メッセージを送信することができました。
  BIPでは、このメッセージについて3つの動機を説明しています。
  ネットワーク診断、軽量クライアントが未承認トランザクションをポーリングできるようにすること、
  そして直近で起動したマイナーに未承認トランザクションを知らせることです（当時、
  Bitcoin Coreはシャットダウン時にmempoolを永続ストレージに保存していませんでした）。

    しかし、その後、`mempool`メッセージまたは`getdata`を使用して
    任意のmempoolトランザクションを要求できる機能を悪用することで、
    どのノードが最初にトランザクションをブロードキャストしたかをより簡単に特定できるようになる、
    プライバシーを低減するさまざまな技術が開発されました。
    [トランザクションの発信元のプライバシー][topic transaction origin privacy]を改善するために、
    Bitcoin Coreはその後、未公表のトランザクションを他のノードから要求する機能を削除し、
    `mempool`メッセージは軽量クライアント用の（[BIP37][]として定義されている）
    [トランザクションBloom Filter][topic transaction bloom filtering]と共に使用するよう制限されました。
    さらにその後、Bitcoin CoreはBloom Filterのサポートをデフォルトで無効にし（[ニュースレター #56][news56 bloom]参照）、
    `-whitelist`オプションで設定されたピアに対してのみ使用を許可しました（[ニュースレター #60][news60 bloom]参照）。
    これにより、BIP35の`mempool`メッセージもデフォルトで事実上無効になりました。

    ClarkのBitcoin CoreのPRは、プロジェクト内から支持を得ていますが、
    一部の支持者はBIP37のBloom Filterを先に削除すべきだと考えています。
    メーリングリストでは、この記事を書いている時点で唯一の[返信][harding mempool]があり、
    自分の信頼できるノードに接続する軽量クライアントは現在、BIP35およびBIP37を使用して、
    Bitcoin Coreで現在簡単に利用できる他の方法よりもはるかに帯域幅効率の良い方法で、
    未承認のトランザクションについて知ることができると述べています。
    この回答者は、Bitcoin Coreが現在のインターフェースを削除する前に、
    代替となる仕組みを提供することを提案しています。

    何らかの目的でBIP35の`mempool`メッセージを使用している人からの追加のフィードバックが求められています。
    メーリングリストの投稿または上記のPRに返信することができます。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--how-many-sigops-are-in-the-invalid-block-783426-->無効なブロック783426には何個のsigopsがありますか？]({{bse}}117837)
  Vojtěch Strnadは、ブロック内のすべてのトランザクションを反復処理し、
  [sigops]({{bse}}117359)をカウントするスクリプトを提供し、
  そのブロックに80,003個のsigopsがあり、[無効][max sigops]であることを示しました。

- [<!--how-would-an-adversary-increase-the-required-fee-to-replace-a-transaction-by-up-to-500-times-->敵対者は、どのようにしてトランザクションを置き換えるために必要な手数料を最大500倍に増やすことができるのでしょうか？]({{bse}}117734)
  Michael Folksonは、[エフェメラル・アンカー][topic ephemeral anchors]に関するBIPドラフトを参照しながら、
  トランザクションを置き換えるために必要な手数料が500倍に増加するというのはどうやって起こるのかと尋ねています。
  Antoine Poinsotは、攻撃者が[RBF（Replace-By-Fee）][topic rbf]による手数料引き上げルールを使用して、
  追加の置換トランザクションに対してはるかに高い手数料の支払いを要求できる例を挙げています。

- [<!--best-practices-with-multiple-cpfps-cpfp-rbf-->複数のCPFPとCPFP + RBFのベストプラクティスは？]({{bse}}117877)
  Sdaftuarは、最初の[CPFP（Child Pays For Parent）][topic cpfp]による手数料引き上げの試行が
  最初のトランザクションを承認させるのに十分な手数料を提供できなかったシナリオで、
  RBFとCPFPの手数料引き上げ技術を使用する際の考慮事項を説明しています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LDK 0.0.115][]は、LN対応ウォレットやアプリケーションを構築するためのこのライブラリのリリースです。
  実験的な[Offer][topic offers]プロトコルのサポートや、セキュリティとプライバシーの向上など、
  いくつかの新機能とバグ修正が含まれています。

- [LND v0.16.1-beta][]は、このLN実装のマイナーリリースで、いくつかのバグ修正とその他の改良が含まれています。
  リリースノートには、デフォルトのCLTV deltaが40ブロックから80ブロックに増加したことが記載されています（
  LNDのデフォルトのCLTV deltaの変更については、[ニュースレター #40][news40 cltv]を参照ください）。

- [Core Lightning 23.05rc1][]は、このLN実装の次のバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [LND #7564][]では、mempoolへのアクセスを提供するバックエンドのユーザーが、
  ノードのチャネルに含まれるHTLCのプリイメージを含む未承認トランザクションを監視できるようになりました。
  これにより、ノードは、これらのトランザクションが承認されるのを待つよりも、速くHTLCを解決できるようになります。

- [LND #6903][]は、[アンカー・アウトプット][topic anchor outputs]を使用してチャネルに手数料を追加するために
  オンチェーンで保持する必要がある金額を除いて、新しいチャネルにすべてのチャネル資金を割り当てる新しい
  `fundmax`オプションを追加し、`openchannel` RPCを更新しました。

- [LDK #2198][]は、チャネルがダウンしたこと（たとえば、リモートピアが利用できないなどで）を
  知らせるゴシップメッセージを送信するまでの時間を増やしました。
  これまでは、LDKは約1分後にチャネルがダウンしたことを知らせていました。
  他のLNノードはより長い時間を待ち、LNゴシッププロトコルの更新の[提案][bolts #1059]では、
  タイムスタンプフィールドを[Unixエポックタイム][Unix epoch time]ではなくブロック高に置き換えることを提案しており、
  ゴシップメッセージをブロック毎に1回（平均して10分毎）しか更新できないようにしています。
  PRでは、更新の送信を遅らせることにはトレードオフがあると指摘していますが、
  チャネルの無効化メッセージをブロードキャストする前に約10分待つようにLDKを更新しています。

- [Bitcoin Inquisition #23][]は、[エフェメラル・アンカー][topic ephemeral anchors]に対するサポートの一部を追加しました。
  これには、エフェメラル・アンカーが[トランザクション・ピニング攻撃][topic transaction pinning]を防止するために依存する
  [v3トランザクションリレー][topic v3 transaction relay]のサポートは含まれていません。

{% include references.md %}
{% include linkers/issues.md v=2 issues="7564,6903,2198,1059,23,27426" %}
[Core Lightning 23.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc1
[news56 bloom]: /en/newsletters/2019/07/24/#bitcoin-core-16152
[news60 bloom]: /en/newsletters/2019/08/21/#bitcoin-core-16248
[clark mempool]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021562.html
[harding mempool]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021563.html
[unix epoch time]: https://en.wikipedia.org/wiki/Unix_time
[max sigops]: https://github.com/bitcoin/bitcoin/blob/e9262ea32a6e1d364fb7974844fadc36f931f8c6/src/consensus/consensus.h#L17
[ldk 0.0.115]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.115
[lnd v0.16.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.1-beta
[news40 cltv]: /en/newsletters/2019/04/02/#lnd-2759
