---
title: 'Bitcoin Optech Newsletter #251'
permalink: /ja/newsletters/2023/05/17/
name: 2023-05-17-newsletter-ja
slug: 2023-05-17-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、HTLCエンドースメントのテストを開始する提案と、
ライトニングサービスプロバイダー（LSP）の仕様案に関するフィードバックの要請、
デュアル・ファンディングを使用する際のゼロ承認チャネルの開設に関する課題の議論、
Payjoinトランザクションの高度な応用に関する提案、
最近のBitcoin Core開発者の対面ミーティングの要約のリンクを掲載しています。
今週のニュースレターでは、トランザクションリレーとmempoolに含める際のポリシーに関する新シリーズの第一弾を掲載し、
また新しいリリースとリリース候補の発表（libsecp256k1のセキュリティリリースを含む）や、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など恒例のセクションも掲載しています。

## ニュース

- **HTLCエンドースメントのテスト:** 数週間前、Carla Kirk-CohenとClara Shikhelmanは、
  [チャネルジャミング攻撃][topic channel jamming attacks]の緩和策の一環として、
  [HTLC][topic htlc]エンドースメント（[ニュースレター #239][news239 endorsement]参照）
  のアイディアをテストするために計画している次のステップについて、
  Lightning-Devメーリングリストに[投稿しました][kcs endorsement]。
  最も注目すべきは、実験的なフラグを使用して展開できる短い[仕様案][bolts #1071]を提供し、
  その展開が不参加ノードとの相互作用に何も影響を与えないようにしたことです。

  実験者によって展開されると、このアイディアの[建設的な批判][decker endorsement]の1つである、
  転送された支払いが実際にどの程度この方式でブーストされるかという問いに答えることが容易になるはずです。
  LNのコアユーザーが同じ経路で頻繁にお互いに支払いを送り合っており、
  レピュテーションシステムが計画通りに機能すれば、
  チャネルジャミング攻撃を受けてもコアネットワークは機能し続ける可能性が高くなります。
  しかし、ほとんどの支払人が支払いを稀にしか送らない場合（あるいは高額な支払いなど、
  最も重要なタイプの支払いを稀にしか送らない場合）、レピュテーションを構築するのに十分な交流が得られないか、
  レピュテーションデータがネットワークの現在の状態から大きく遅れてしまうでしょう（
  レピュテーションが有用でなくなるか、あるいは悪用されるようになるでしょう）。

- **LSPの仕様案に関するフィードバックのお願い:** Severin Bühlerは、
  LSP（Lightning Service Provider）とそのクライアント（通常は非転送LNノード）間のインターオペラビリティに関する
  2つの仕様についてフィードバックの要請をLightning-Devメーリングリストに[投稿しました][buhler lsp]。
  1つめの仕様は、クライアントがLSPからチャネルを購入できるようにするためのAPIを定義しています。
  2つめの仕様は、JIT（Just-In-Time）チャネルをセットアップ・管理するためのAPIを定義しています。
  JITチャネルは、仮想ペイメントチャネルとして機能するチャネルで、
  仮想チャネルへの最初の支払いを受け取ると、LSPは、
  承認されるとチャネルをオンチェーンにアンカリングするトランザクションをブロードキャストします（通常のチャネルにします）。

  開発者のZmnSCPxjは[返信][zmnscpxj lsp]で、LSPのオープンな仕様に賛成しています。
  彼は、クライアントが複数のLSPに接続しやすくなり、ベンダーロックインを防ぎ、
  プライバシーを向上させることができると指摘しています。

- **<!--challenges-with-zero-conf-channels-when-dual-funding-->デュアル・ファンディング時のゼロ承認チャネルの課題:**
  Bastien Teinturierは、[デュアル・ファンディングプロトコル][topic dual funding]を使用する際に、
  [ゼロ承認チャネル][topic zero-conf channels]を許可する際の課題について、
  Lightning-Devメーリングリストに[投稿しました][teinturier 0conf]。
  ゼロ承認チャネルは、チャネル開設トランザクションが承認される前でも使用することができます。
  これは、いくつかのケースではトラストレスです。デュアル・ファンディングチャネルは、
  チャネル開設トランザクションにチャネルの両参加者のインプットが含まれるチャネルを含む
  デュアル・ファンディングプロトコルを使用して作成されたチャネルです。

  ゼロ承認は、一方の参加者がチャネル開設トランザクションのすべてのインプットを制御する場合にのみトラストレスです。
  たとえば、アリスがチャネル開設トランザクションを作成し、チャネルでボブに資金を渡し、
  ボブはその資金をアリスを介してキャロルに支払おうとします。
  アリスは、最終的に承認されるトランザクションを自分が制御していることを知っているので、
  支払いを安全にキャロルに転送することができます。しかし、チャネル開設トランザクションにボブのインプットもある場合、
  ボブは、競合するトランザクションを承認させることができ、
  それによりチャネル開設トランザクションの承認が妨げられ、
  アリスはキャロルに転送した資金の補償を受けられなくなります。

  この記事を書いている時点では、参加者が満足するようなものはありませんでしたが、
  デュアル・ファンディングによるゼロ承認チャネルの開設を可能にするためのいくつかのアイデアが議論されました。

- **高度なPayjoinの応用:** Dan Gouldは、
  [Payjoin][topic payjoin]プロトコルを使用して単純な支払いの送受信以上のことをするためのいくつかの提案を、
  Bitcoin-Devメーリングリストに[投稿しました][gould payjoin]。
  その提案の中で、最も興味深いと思った2つの提案は、
  プライバシーとスケーラビリティを向上させ、手数料コストを削減するための古いアイディアである
  [トランザクション・カットスルー][transaction cut-through]のバージョンでした:

  - *<!--payment-forwarding-->支払いの転送:* アリスはボブに支払う代わりに、
    ボブのベンダー（キャロル）に支払い、ボブのキャロルに対する債務を減らします（もしくは将来予想される請求の前払い）。

  - *<!--batched-payment-forwarding-->支払いの一括転送:*
    アリスはボブに支払う代わりに、ボブが支払う債務を持つ（または信用を築きたい）複数の人に支払います。
    Gouldの例では、安定した入出金の流れがある取引所を想定しています。
    Payjoinでは、可能な限り新しい入金によって引き出しの支払いを行うことができます。

  これらの技術はどちらも、少なくとも2つのトランザクションを1つのトランザクションに減らすことができ、
  かなりのブロックスペースを節約することができます。[バッチ処理][topic payment batching]を使用する場合は、
  さらに大きなスペースの節約が可能です。元の受信者（たとえばボブ）の観点からすると、
  元の支払人（たとえばアリス）が手数料の一部または全額を支払うことができるのはさらに良いことです。
  スペースや手数料の節約に加えて、トランザクションをブロックチェーンから削除し、
  受け取りや支払いなどの操作を組み合わせることで、ブロックチェーンの監視組織が資金の流れを確実に追跡することが著しく困難になります。

  この記事を書いている時点では、メーリングリストでの議論はありませんでした。

- **Bitcoin Core開発者の対面ミーティングの要約:** Bitcoin Coreに取り組んでいる開発者たちは、
  プロジェクトのいくつかの側面について議論するために最近ミーティングを行いました。
  そのミーティングでのいくつかの議論のメモが公開されました。
  議論されたトピックは、[ファズテスト][fuzz testing]や[assumeUTXO][]、[ASMap][]、
  [サイレント・ペイメント][silent payments]、[libbitcoinkernel][]、
  [リファクタリング][refactoring (or not)]および[パッケージリレー][package relay]などです。
  また、特別な注意を払うべきと思われる2つのトピックも議論されました:

  - [Mempool Clustering][Mempool clustering]は、
    トランザクションとそのメタデータがBitcoin Coreのmempoolに保存される方法の大幅な再設計に関する提案をまとめたものです。
    このメモでは、現在の設計に関するいくつかの問題について説明し、
    新しい設計の概要を示し、関連するいくつかの課題とトレードオフを示しています。
    設計の[説明][bitcoin core #27677]とプレゼンテーションの[スライド][mempool slides]のコピーが後に公開されました。

  - [Project Meta Discussion][Project meta discussion]は、
    プロジェクトの目標や、内外の多くの課題があるなかで、それらを達成するための方法についての議論をまとめたものです。
    議論の一部は、バージョン25以降の次のメジャーリリースに向けて、
    よりプロジェクトにフォーカスしたアプローチをとるなど、すでにプロジェクトの管理に実験的な変化をもたらしています。

## 承認を待つ #1: なぜmempoolがあるのか？

_トランザクションリレーや、mempoolへの受け入れ、マイニングトランザクションの選択に関する限定的な週次シリーズの最初のセグメントです。
Bitcoin Coreがコンセンサスで認められているよりも制限的なポリシーを持っている理由や、
ウォレットがそのポリシーを最も効果的に使用する方法などが含まれます。_

{% include specials/policy/ja/01-why-mempool.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Libsecp256k1 0.3.2][]は、[ECDH][]にlibsecpを使用し、
  かつGCCバージョン13以上でコンパイルされる可能性のあるアプリケーションのためのセキュリティリリースです。
  [作者の説明によると][secp ml]、新しいバージョンのGCCでは、
  一定時間で実行されるように設計されたlibsecpのコードを最適化しようとするため、
  特定の状況下で[サイドチャネル攻撃][topic side channels]を実行することが可能になります。
  Bitcoin CoreはECDHを使用していないため、影響を受けません。
  今後、コンパイラの将来の変更によって同様の問題が発生する可能性がある場合に、
  それを検知し、事前に変更を行うことができるようにするための作業が進められています。

- [Core Lightning 23.05rc2][]は、このLN実装の次期バージョンのリリース候補です。

- [Bitcoin Core 23.2rc1][]は、Bitcoin Coreの前のメジャーバージョンのメンテナンスリリースのリリース候補です。

- [Bitcoin Core 24.1rc3][]は、Bitcoin Coreの現在のバージョンのメンテナンスリリースのリリース候補です。

- [Bitcoin Core 25.0rc2][]は、Bitcoin Coreの次期メジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #26076][]は、公開鍵の導出パスを表示するRPCメソッドを更新し、
  強化導出ステップを示すためにシングルクォート`'`ではなく`h`を使用するようにしました。
  この変更により、ディスクリプターのチェックサムが変更されることに注意してください。
  秘密鍵を含むディスクリプターを処理する場合、ディスクリプターが生成またはインポートされた時と同じシンボルが使用されます。
  レガシーウォレットの場合、`getaddressinfo`の`hdkeypath`フィールドとウォレットのダンプのシリアライズ形式は変更されていません。

- [Bitcoin Core #27608][]は、他のピアからブロックが提供された場合でも、
  ピアからブロックのダウンロードを試行し続けるようにしました。
  Bitcoin Coreは、受信したブロックの1つがディスクに書き込まれるまで、
  そのブロックを持っていると主張するピアからブロックをダウンロードし続けます。

- [LDK #2286][]では、ローカルウォレットが管理するアウトプットのための
  [PSBT][topic psbt]の作成と署名を可能にしました。

- [LDK #1794][]では、[デュアル・ファンディング][topic dual funding]のサポートを開始し、
  デュアル・ファンディングに使用される対話型のファンディング・プロトコルに必要なメソッドを追加しました。

- [Rust Bitcoin #1844][]は、[BIP21][] URIのスキーマを小文字、つまり`bitcoin:`にしました。
  URIスキーマの仕様（RFC3986）では、スキーマは大文字小文字を区別しないとされていますが、
  テストの結果、いくつかのプラットフォームでは、大文字の`BITCOIN:`が渡された場合に、
  `bitcoin:` URIを処理するために割り当てられたアプリケーションを開かないことがわかりました。
  大文字が正しく処理されるようになれば、より効率的なQRコードの作成が可能になります（[ニュースレター#46][news46 qr]を参照）。

- [Rust Bitcoin #1837][]は、新しい秘密鍵を生成する関数を追加し、
  以前はより多くのコードを必要としたものを簡素化しました。

- [BOLTs #1075][]は、ノードがピアから警告メッセージを受け取った後にピアとの接続を解除しないよう仕様を更新しました。

{% include references.md %}
{% include linkers/issues.md v=2 issues="26076,27608,2286,1794,1844,1837,1075,1071,27677" %}
[Core Lightning 23.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc2
[bitcoin core 23.2rc1]: https://bitcoincore.org/bin/bitcoin-core-23.2/
[bitcoin core 24.1rc3]: https://bitcoincore.org/bin/bitcoin-core-24.1/
[bitcoin core 25.0rc2]: https://bitcoincore.org/bin/bitcoin-core-25.0/
[news239 endorsement]: /ja/newsletters/2023/02/22/#feedback-requested-on-ln-good-neighbor-scoring-ln
[fuzz testing]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-27-fuzzing/
[assumeutxo]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-27-assumeutxo/
[asmap]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-27-asmap/
[silent payments]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-26-silent-payments/
[libbitcoinkernel]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-26-libbitcoin-kernel/
[refactoring (or not)]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-25-refactors/
[package relay]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-25-package-relay-primer/
[mempool clustering]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-25-mempool-clustering/
[project meta discussion]: https://btctranscripts.com/bitcoin-core-dev-tech/2023-04-26-meta-discussion/
[kcs endorsement]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-April/003918.html
[decker endorsement]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-May/003944.html
[buhler lsp]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-May/003926.html
[zmnscpxj lsp]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-May/003930.html
[teinturier 0conf]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-May/003920.html
[gould payjoin]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021653.html
[transaction cut-through]: https://bitcointalk.org/index.php?topic=281848.0
[news46 qr]: /en/newsletters/2019/05/14/#bech32-sending-support
[mempool slides]: https://github.com/bitcoin/bitcoin/files/11490409/Reinventing.the.Mempool.pdf
[secp ml]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021683.html
[libsecp256k1 0.3.2]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.3.2
[ecdh]: https://ja.wikipedia.org/wiki/%E6%A5%95%E5%86%86%E6%9B%B2%E7%B7%9A%E3%83%87%E3%82%A3%E3%83%95%E3%82%A3%E3%83%BC%E3%83%BB%E3%83%98%E3%83%AB%E3%83%9E%E3%83%B3%E9%8D%B5%E5%85%B1%E6%9C%89
