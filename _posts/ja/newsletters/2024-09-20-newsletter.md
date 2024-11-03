---
title: 'Bitcoin Optech Newsletter #321'
permalink: /ja/newsletters/2024/09/20/
name: 2024-09-20-newsletter-ja
slug: 2024-09-20-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、アウトプットがUTXOセットの一部であることをゼロ知識で証明する概念実証の実装のリンクと、
オフラインLN支払いを可能にするための１つの新しい提案と２つの以前の提案、非IPネットワークアドレスのDNSシードに関する研究の概要を掲載しています。
また、クライアントとサービスの変更や、新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **UTXOセットの包含をゼロ知識で証明:** Johan Halsethは、
  現在のUTXOセット内の１つのアウトプットを管理していることを、どのアウトプットか明かさずに証明できる概念実証ツールの発表を
  Delving Bitcoinに[投稿しました][halseth utxozk]。最終的な目標は、
  LNのファンディングアウトプットの共同所有者が、彼らのオンチェーントランザクションに関する具体的な情報を明かすことなく、
  チャネルを管理していることを証明できるようにすることです。この証明は、
  LNの分散型ルーティング情報を構築するために使用される次世代の[チャネルアナウンスメッセージ][topic
  channel announcements]に添付することができます。

  使用される方法は、[ニュースレター #303][news303 aut-ct]で説明されているaut-ctの方法とは異なり、
  一部の議論は、違いを明確にすることに焦点を当てていました。追加の研究が必要で、
  Halsethはいくつかの未解決の問題を説明しています。

- **LNのオフライン支払い:** Andy Schroderは、
  LNウォレットがインターネットに接続されたウォレットの支払いのために提供できるトークンを生成するのに使用できる通信プロセスの説明を
  Delving Bitcoinに[投稿しました][schroder lnoff]。たとえば、
  アリスのウォレットは通常、アリスが管理するかLSP（_Lightning service provider_）によって管理されている
  常時オンラインのLNノードに接続されます。オンラインの間、アリスは認証トークンを事前生成します。

  その後、アリスのノードがオフラインの状態でボブに支払いをしたい場合、
  アリスはボブに認証トークンを渡します。これにより、ボブはアリスの常時オンラインノードまたはLSPに接続して、
  アリスが指定した金額を引き出すことができます。アリスは[NFC][]や、
  広く使用されている他のデータ転送プロトコルを使用して、ボブに認証トークンを提供することができます。
  このプロトコルはアリスがインターネットにアクセスする必要がないため、プロトコルはシンプルになり、
  計算リソースが限られているデバイス（スマートカードなど）に簡単に実装できます。

  開発者のZmnSCPxjは、以前説明した代替アプローチについて[言及し][zmn lnoff]、Bastien Teinurierは、
  この種のシチュエーション向けに設計したノードのリモートコントロール方法について[言及しました][t-bast lnoff]（
  [ニュースレター #271][news271 noderc]参照）。

- **非IPアドレース用のDNSシード:** 開発者のVirtuは、
  [匿名ネットワーク][topic anonymity networks]上のシードノードの可用性に関する調査を
  Delving Bitcoinに[投稿し][virtu seed]、それらのネットワークのみを使用する新しいノードが
  DNSシードを通じてピアについて学習できるようにする方法について説明しました。

  背景として、BitcoinノードやP2Pクライアントは、データをダウンロードできるピアのネットワークアドレスを知る必要があります。
  新しくインストールされたソフトウェアや、長い間オフラインになっていたソフトウェアは、
  アクティブなピアのネットワークアドレスを認識していない可能性があります。
  通常、Bitcoin Coreノードは、使用可能な可能性のある複数のピアのIPv4アドレスまたはIPv6アドレスを返す
  DNSシードに照会することでこれを解決します。DNSシードの照会が失敗した場合、
  または使用できない場合（IPv4やIPv6アドレスを使用しない匿名ネットワークなど）、
  Bitcoin Coreはソフトウェアのリリース時に利用可能だったピアのネットワークアドレスを含めます。
  これらのピアは _シードノード_ として使用され、ノードはシードノードに追加のピアのアドレスを要求し、
  それらを潜在的なピアとして使用します。DNSシードはシードノードよりも好まれます。
  これは、DNSシードの情報の方が最新であり、グローバルなDNSのキャッシュインフラストラクチャによって、
  DNSシードが各照会ノードのネットワークアドレスを学習するのを防ぐことができるためです。

  Virtuは、Bitcoin Coreの過去4つのメジャーリリースにリストされているシードノードを調査し、
  十分な数のシードノードがまだ利用可能であることを発見しました。
  これは、匿名ネットワークのユーザーがピアが見つけることができるはずであることを示しています。
  Virtuと他の議論の参加者は、DNSの`NULL`レコードを使用するか、
  代替ネットワークアドレスを擬似IPv6アドレスにエンコードすることで、
  匿名ネットワークのDNSシードを使用できるようにBitcoin Coreを変更する可能性も検討しました。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **StrikeがBOLT12をサポート:**
  Strikeは、[BIP353][]DNS支払い指示でのオファーの使用を含む[BOLT12オファー][topic offers]のサポートを
  [発表しました。][strike blog]

- **BitBox02がサイレントペイメントをサポート:**
  BitBox02は、[サイレントペイメント][topic silent payments]のサポートと
  [ペイメントリクエスト][bitbox blog pr]の実装を[発表しました][bitbox blog sp]。

- **Mempool Open Source Project v3.0.0リリース:**
  [v3.0.0リリース][mempool github 3.0.0]には、新しい[CPFP][topic cpfp]手数料計算、
  フルRBFのサポートを含む[RBF][topic rbf]の追加機能、P2PKのサポート、
  mempoolおよびブロックチェーンの新しい分析機能やその他の変更が含まれています。

- **ZEUS v0.9.0リリース:**
  [v0.9.0の投稿][zeus blog 0.9.0]では、LSPの追加機能、参照専用ウォレット、
  ハードウェア署名デバイスのサポート、チャネル開設トランザクションを含むトランザクションの[バッチ化][scaling payment batching]のサポートおよび、
  その他の機能について概説しています。

- **Live Walletが統合トランザクションをサポート:**
  Live Walletアプリケーションは、
  アウトプットをいつ使用すると[経済的に合理的でないか][topic uneconomical outputs]を判断するなど、
  異なる手数料率でUTXOセットを使用する事ストを分析します。[0.7.0のリリース][live wallet github 0.7.0]では、
  [統合][consolidate info]トランザクションをシミュレートし、統合用の[PSBT][topic psbt]を生成する機能が含まれています。

- **Bisqがライトニングをサポート:**
  [Bisq v2.1.0][bisq github v2.1.0]は、ユーザーがライトニングネットワークを使用して取引を決済する機能が追加されました。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [HWI 3.1.0][]は、複数の異なるハードウェア署名デバイスに共通のインターフェースを提供するこのパッケージの次期バージョンのリリースです。
  このリリースでは、Trezor Safe 5のサポートが追加され、その他のいくつかの改善とバグ修正が行われました。

- [Core Lightning 24.08.1][]は、最近の24.08リリースで発見されたクラッシュやその他のバグを修正した
  メンテナンスリリースです。

- [BDK 1.0.0-beta.4][]は、ウォレットやその他のBitcoin対応アプリケーションを構築するためのこのライブラリのリリース候補です。
  元の`bdk` Rustクレートの名前が`bdk_wallet`変更され、 低レイヤーのモジュールは、
  `bdk_chain`、`bdk_electrum`、`bdk_esplora`、`bdk_bitcoind_rpc`などの独自のクレートに抽出されました。
  `bdk_wallet`クレートは、「安定した 1.0.0 API を提供する最初のバージョンです」。

- [Bitcoin Core 28.0rc2][]は、主要なフルノード実装の次期メジャーバージョンのリリース候補です。
  [テストガイド][bcc testing]が利用可能です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

_注: 以下に掲載するBitcoin Coreへのコミットは、master開発ブランチに適用されるため、
これらの変更がリリースされるのは、次期バージョン28のリリースから約6ヶ月後になると思われます。_

- [Bitcoin Core #28358][]は、
  UTXOセットをRAMからディスクにフラッシュすることなくIBD（Initial Block Download）を完了するのに（
  ディスクへのフラシュを控えることで約25%の速度向上が[見込まれます][lopp cache]）、
  以前の16GBの制限では十分ではなくなったため、`dbcache`の制限を撤廃しました。
  将来に渡って使用可能な最適値が存在せず、ユーザーに完全な柔軟性を与えることができないため、
  制限を上げるのではなく撤廃しました。

- [Bitcoin Core #30286][]は、クラスターリニアライゼーションで使用される候補選択アルゴリズムを、
  この[Delving Bitcoinの投稿][delving cluster]のセクション２で説明されたフレームワークに基づいて最適化しますが、
  いくつかの変更を加えています。これらの最適化により、反復が最小限に抑えられ、
  リニアライゼーションのパフォーマンスが向上しますが、起動と反復あたりのコストが増加する可能性があります。
  これは、[クラスター mempool][topic cluster mempool]プロジェクトの一部です。
  ニュースレター[#315][news315 cluster]をご覧ください。

- [Bitcoin Core #30807][]は、バックグランドでチェーンを同期している[assumeUTXO][topic
  assumeutxo]ノードのシグナリングを`NODE_NETWORK`から`NODE_NETWORK_LIMITED`に変更し、
  ピアノードが約1週間以上前のブロックを要求しないようにします。これにより、
  ピアが履歴ブロックを要求しても応答がなく、assumeUTXOノードから切断されるというバグが修正されます。

- [LND #8981][]は、`paymentDescriptor`型をリファクタリングし、`lnwallet`パッケージ内でのみ使用するようにします。
  これは、[チャネルコミットメントのアップグレード][topic channel commitment upgrades]の一種である
  動的コミットメントを実装するPRのシリーズの一部として、後で`paymentDescriptor`を
  `LogUpdate`と呼ばれる新しい構造に置き換えて、更新のログ記録と処理を簡素化するためのものです。

- [LDK #3140][]は、[BOLTs #1149][]で定義されているように、
  常にオンラインの送信者として[非同期支払い][topic async payments]を送信するために
  静的な[BOLT12][topic offers]インボイス支払いをサポートしますが、
  支払いの[Onionメッセージ][topic onion messages]内でのインボイス要求は含まれません。
  頻繁にオフラインになる送信者として送信したり、非同期支払いを受け取ったりすることはまだできないため、
  フローをエンドツーエンドでテストすることはできません。

- [LDK #3163][]は、BOLT12インボイス内に`reply_path`を導入することで[オファー][topic offers]のメッセージフローを更新します。
  これにより、インボイスエラーが発生した場合に、支払人が受取人にエラーメッセージを送り返すことができます。

- [LDK #3010][]は、対応するインボイスをまだ受け取っていない場合に、
  ノードが[オファー][topic offers]のリプライパスにインボイスリクエストの送信を再試行する機能を追加します。
  これまでは、単一のリプライパスのインボイスリクエストメッセージがネットワークの切断により失敗した場合、再試行されませんでした。

- [BDK #1581][]は、`BranchAndBoundCoinSelection`戦略でカスタマイズ可能なフォールバックアルゴリズムを許可することで、
  [コイン選択][topic coin selection]アルゴリズムに変更を導入します。`coin_select`メソッドのシグネチャが更新され、
  コイン選択アルゴリズムに乱数生成器を直接渡すことができるようになりました。
  このPRには、追加のリファクタリングや、内部のフォールバック処理、エラー処理の簡素化も含まれています。

- [BDK #1561][]は、依存関係とCIの簡素化のために、`bdk_hwi`クレートをプロジェクトから削除します。
  `bdk_hwi`クレートには`HWISigner`が含まれていましたが、これは現在`rust_hwi`プロジェクトに移動されています。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28358,30286,30807,8981,3140,3163,3010,1581,1561,1149" %}
[BDK 1.0.0-beta.4]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.4
[bitcoin core 28.0rc2]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[halseth utxozk]: https://delvingbitcoin.org/t/proving-utxo-set-inclusion-in-zero-knowledge/1142/
[schroder lnoff]: https://delvingbitcoin.org/t/privately-sending-payments-while-offline-with-bolt12/1134/
[virtu seed]: https://delvingbitcoin.org/t/hardcoded-seeds-dns-seeds-and-darknet-nodes/1123
[news303 aut-ct]: /ja/newsletters/2024/05/17/#anonymous-usage-tokens
[nfc]: https://ja.wikipedia.org/wiki/近距離無線通信
[zmn lnoff]: https://delvingbitcoin.org/t/privately-sending-payments-while-offline-with-bolt12/1134/2
[t-bast lnoff]: https://delvingbitcoin.org/t/privately-sending-payments-while-offline-with-bolt12/1134/4
[news271 noderc]: /ja/newsletters/2023/10/04/#ln
[hwi 3.1.0]: https://github.com/bitcoin-core/HWI/releases/tag/3.1.0
[core lightning 24.08.1]: https://github.com/ElementsProject/lightning/releases/tag/v24.08.1
[delving cluster]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303#h-2-finding-high-feerate-subsets-5
[lopp cache]: https://github.com/bitcoin/bitcoin/pull/28358#issuecomment-2186630679
[news315 cluster]: /ja/newsletters/2024/08/02/#bitcoin-core-30126
[strike blog]: https://strike.me/blog/bolt12-offers/
[bitbox blog sp]: https://bitbox.swiss/blog/understanding-silent-payments-part-one/
[bitbox blog pr]: https://bitbox.swiss/blog/using-payment-requests-to-securely-send-bitcoin-to-an-exchange/
[mempool github 3.0.0]: https://github.com/mempool/mempool/releases/tag/v3.0.0
[zeus blog 0.9.0]: https://blog.zeusln.com/new-release-zeus-v0-9-0/
[live wallet github 0.7.0]: https://github.com/Jwyman328/LiveWallet/releases/tag/0.7.0
[consolidate info]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation
[bisq github v2.1.0]: https://github.com/bisq-network/bisq2/releases/tag/v2.1.0
