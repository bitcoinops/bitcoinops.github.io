---
title: 'Bitcoin Optech Newsletter #218'
permalink: /ja/newsletters/2022/09/21/
name: 2022-09-21-newsletter-ja
slug: 2022-09-21-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、`SIGHASH_ANYPREVOUT`を使用してDrivechainをエミュレートすることについての議論を掲載しています。
また、サービス、クライアントソフトウェアや人気のあるBitcoinインフラストラクチャソフトウェアの最近の変更について解説する
恒例のセクションも含まれています。

## ニュース

- **APOとTrusted SetupによるDrivechainの作成:** Jeremy Rubinは、
  提案中の[SIGHASH_ANYPREVOUT][topic sighash_anyprevout]とTrusted Setupの手順を組み合わせて
  [Drivechain][topic sidechains]で提案されているのと同様の動作を実装する方法について
  Bitcoin-Devメーリングリストに[投稿しました][rubin apodc]。
  Drivechainは、サイドチェーンの一種で、通常マイナーはサイドチェーンの資産を安全に保つ責任があります
  （フルノードがBitcoinのメインチェーンの資産を安全に保つのとは対照的です）。
  Drivechainの資産を盗もうとするマイナーは、その悪意ある意図を数日から数週間前にブロードキャストしなければらなず、
  その間ユーザーに自身のフルノードでサイドチェーンのルールの適用する機会を与えます。
  Drivechainは、主にソフトフォークとしてBitcoinに組み込むことが提案されていますが（BIP[300][bip300]および[301][bip301]参照）、
  メーリングリストへの以前の投稿では（[ニュースレター #190][news190 dc]参照）、
  Bitcoinのコントラクト言語に対する他のいくつかの柔軟な提案によりDrivechainの実装も可能になると説明されていました。

  今週の投稿でRubinは、Bitcoinのコントラクト言語への追加案（[BIP118][]で提案されている`SIGHASH_ANYPREVOUT` (APO)）を使用して
  Drivechainを実装する別の方法について説明しています。APOベースのDrivechainは、BIP300と比較していくつかの欠点がありますが、
  APOがDrivechainを有効にしているとみなすことができるほど十分類似した動作を提供する可能性があります。
  これをメリットと考える人もいれば、問題と考える人もいるでしょう。

## サービスとクライアントソフトエアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **MempoolプロジェクトがLightning Networkのエクスプローラーをローンチ:**
  Mempoolのオープンソースの[Lightningダッシュボード][mempool lightning]は、
  集約されたネットワーク統計だけでなく、個々のノードの流動性と接続性に関するデータも表示します。

- **フェデレーションソフトウェアFedimintがLightningをサポート:**
  最近の[ブログ記事][blockstream blog fedimint]でBlockstreamは、
  Lightning Networkのサポートを含む、フェデレーション型のChaumian e-cashプロジェクト[Fedimint][]のアップデートについて解説しています。
  このプロジェクトはまた、パブリックな[signet][topic signet]とFaucetが利用可能であることも[発表しました][fedimint signet tweet]。

- **BitpayウォレットがRBFのサポートを改善:**
  Bitpayは、[既存][bitpay 11935]の[RBF][topic rbf]トランザクションの送信のサポートを[改善し][bitpay 12051]、
  複数の受信者がいるトランザクションの手数料の引き上げをよりよく処理するようになりました。

- **Mutiny Lightningウォレットの発表:**
  Mutiny（以前はpLNだった）は、チャネル毎に別々のノードを使用するプライバシーに特化したLightningウォレットを[発表しました][mutiny wallet]。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Core Lightning #5581][]は、新しいイベント通知トピック"block_added"を追加しました。
  このトピックを購読しているプラグインは、新しいブロックをbitcoindから受信する度に通知を受け取ります。

- [Eclair #2418][]および[#2408][eclair #2408]は、
  [ブラインドルート][topic rv routing]で送られた支払いを受信するためのサポートを追加しました。
  ブラインド支払いを作成する送信者は、支払いを受け取るノードのIDを提供されません。
  これは、特に[未公表チャネル][topic unannounced channels]と一緒に使用するとプライバシーを向上する可能性があります。

- [Eclair #2416][]は、[提案中のBOLT12][proposed bolt12]で定義されている
  [Offer][topic offers]プロトコルを使用して要求された支払いを受信するためのサポートを追加しました。
  これは、最近追加されたブラインド支払いの受信をサポートします（以前のEclair #2418を参照）

- [LND #6335][]は、`TrackPayments` APIを追加し、
  ローカルのすべての支払いの試行のフィードを購読できるようになりました。
  PRの説明にあるように、これは[トランポリンルーティング][topic trampoline payments]を実行するノードなど、
  将来より良い支払いの送信とルーティングを行うために、支払いに関する統計情報を収集するのに使用できます。

- [LDK #1706][]は、承認済みのトランザクションをダウンロードするために、
  [BIP158][]で定義されている[Compact Block Filter][topic compact block filters]を使用するためのサポートを追加しました。
  このフィルターを使用すると、ブロックにウォレットに影響するトランザクションが含まれる可能性がある場合、
  最大4MBのフルブロックがダウンロードされます。ウォレットに影響のあるトランザクションが含まれていないことが確実な場合は、
  追加のデータはダウンロードされません。

{% include references.md %}
{% include linkers/issues.md v=2 issues="5581,2418,2408,2416,6335,1706" %}
[rubin apodc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020919.html
[news190 dc]: /ja/newsletters/2022/03/09/#drivechain
[proposed bolt12]: https://github.com/rustyrussell/lightning-rfc/blob/guilt/offers/12-offer-encoding.md
[mempool lightning]: https://mempool.space/lightning
[blockstream blog fedimint]: https://blog.blockstream.com/fedimint-update/
[bitpay 12051]: https://github.com/bitpay/wallet/pull/12051
[bitpay 11935]: https://github.com/bitpay/wallet/pull/11935
[mutiny wallet]: https://bc1984.com/make-lightning-payments-private-again/
[Fedimint]: https://github.com/fedimint/fedimint
[fedimint signet tweet]: https://twitter.com/EricSirion/status/1572329210727010307