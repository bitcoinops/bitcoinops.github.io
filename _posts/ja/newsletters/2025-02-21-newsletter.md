---
title: 'Bitcoin Optech Newsletter #342'
permalink: /ja/newsletters/2025/02/21/
name: 2025-02-21-newsletter-ja
slug: 2025-02-21-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、モバイルウォレットが追加のUTXOなしでLNチャネルを決済できるようにするためのアイディアと、
LNの経路探索用にサービス品質フラグを追加することに関する議論の続きの要約を掲載しています。
また、クライアント、サービスおよび人気のBitcoinインフラストラクチャソフトウェアの最近の変更など
恒例のセクションも含まれています。

## ニュース

- **モバイルウォレットが追加のUTXOなしでチャネルを決済できるようにする:**
  Bastien Teinturierは、盗難の可能性があるすべてのケースで、
  モバイルウォレットがチャネル内の資金を使ってチャネルを決済できるようにする、
  LNチャネル用の[v3コミットメント][topic v3 commitments]のオプトイン版について
  Delving Bitcoinに[投稿しました][teinturier mobileclose]。
  モバイルウォレットは、チャネルを閉じるための手数料を支払うためにオンチェーンUTXOを準備しておく必要がなくなります。

  Teinturierまず、モバイルウォレットがトランザクションをブロードキャストする必要がある
  4つのケースの概要を説明しています:

  1. ピアが失効したコミットメントトランザクションをブロードキャストする、つまり、
     ピアが資金を盗もうとしている場合です。
     この場合、モバイルウォレットはすぐにチャネルの資金をすべて使用できるようになり、
     その資金を使って手数料を支払うことができます。

  2. モバイルウォレットがまだ決済されていない支払いを送信した場合。
     この場合、窃盗は不可能で、リモートピアは[HTLC][topic htlc]プリイメージ
     （つまり、最終的な受取人が支払いを受けたという証拠）を提供することによってのみ支払いを請求できます。
     窃盗は不可能なので、モバイルウォレットはチャネルを閉じるための手数料を支払うために必要なUTXOを時間をかけて用意することができます。

  3. 保留中の支払いがなくリモートピアが応答しない場合。
     この場合も窃盗は不可能なので、モバイルウォレットは時間をかけてチャネルを閉じることができます。

  4. モバイルウォレットがHTLCを受信している場合。この場合、
     リモートピアはHTLCプリイメージを受け入れることができます（これにより、
     上流のピアに資金を請求できます）が、決済されたチャネル残高を更新してHTLCを取り消すことはできません。
     この場合、モバイルウォレットは比較的少数のブロック内でチャネルを強制的に閉じる必要があります。
     これが、この記事の残りで取り扱うケースです。

  Teinturierは、リモートピアがモバイルウォレットに支払う各HTLCの2つの異なるバージョンに署名することを提案しています。
  1つは手数料ゼロのコミットメントに対するデフォルトポリシーに従う手数料ゼロバージョンで、
  もう1つは現在すぐに承認される手数料率で手数料を支払うバージョンです。
  手数料はモバイルウォレットに支払われるHTLCから差し引かれるため、
  このオプションを提供するリモートピアにコストはかからず、
  モバイルウォレットには本当に必要な場合にのみこのオプションを使用するインセンティブが生まれます。
  Teinturierは、リモートピアが手数料を支払い過ぎると安全上の考慮事項がいくつかあると
  [指摘しています][teinturier mobileclose2]が、それらは簡単に対処できるだろうと予想しています。

- **LNのサービス品質フラグに関する議論の続き:** Joost Jagerは、
  LNプロトコルにサービス品質（QoS）フラグを追加して、
  ノードが彼らチャネルの1つが高可用性（HA）である（つまり、指定された金額まで100%の信頼性で支払いを転送できる）ことを
  通知できるようにすること（[ニュースレター #239][news239 qos]参照）についての議論の続きをDelving Bitcoinに[投稿しました][jager lnqos]。
  支払人がHAチャネルを選択し、そのチャネルで支払いが失敗した場合、
  支払人はそのチャネルを二度と使用しないことでオペレーターにペナルティを課します。
  以前の議論から、Jagerはノードレベルのシグナリング（おそらく、
  ノードのテキストエイリアスに「HA」を追加するだけ）を提案し、
  プロトコルの現在のエラーメッセージでは支払いが失敗したチャネルの検出が保証されないことを指摘し、
  これは完全にオプトインベースでシグナリングと使用の両方ができるものではないため（つまり、広範な合意を必要としないので）、
  最終的にそれを使用する支払いノードと転送ノードがほとんどいないとしても、
  互換性のために規定されるべきだと提案しました。

  Matt Coralloは、LNの経路探索は現在うまく機能していると[答え][corallo lnqos]、
  LDKの経路探索アプローチを説明する[詳細なドキュメント][ldk path]のリンクを貼りました。
  このアプローチは、René PickhardtとStefan Richterが最初に説明したアプローチ（
  [ニュースレター #163][news163 pr paper]および[ニュースレター #270][news270 ldk2534]の
  [2つの項目][news270 ldk2547]を参照）を拡張したものです。ただし、
  QoSフラグによって将来のソフトウェアが信頼性の低い経路探索を実装し、
  HAチャネルのみの使用を優先するのではないかと懸念しています。その場合、
  大規模なノードは、チャネルが枯渇した際に一時的に信頼ベースの流動性を使用するという合意を大規模ピアと締結できますが、
  トラストレスなチャネルに依存する小規模ノードは、コストのかかる[JITリバランス][topic jit routing]を使用する必要があり、
  （コストを吸収する場合）チャネルの収益性が低下するか、
  （コストを支払人に転嫁する場合）望ましくない形になります。

  JagerとCoralloは、議論を続けましたが、明確な解決策には至りませんでした。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Ark Wallet SDKのリリース:**
  [Ark Wallet SDK][ark sdk github]は、[testnet][topic testnet]、[signet][topic signet]、
  [Mutinynet][new252 mutinynet]およびmainnet（現在は非推奨）でオンチェーンのBitcoinと
  [Ark][topic ark]の両方をサポートするウォレットを構築するためのTypeScriptライブラリです。

- **ZapriteがBTCPay Serverをサポート:**
  Bitcoinおよびライトニング決済インテグレーターの[Zaprite][zaprite website]は、
  サポートするウォレット接続リストにBTCPay Serverを追加しました。

- **Iris Walletデスクトップリリース:**
  [Iris Wallet][iris github]は、[RGB][topic client-side validation]プロトコルを使用した
  アセットの発行、送信、受信をサポートします。

- **Sparrow 2.1.0リリース:**
  Sparrow [2.1.0リリース][sparrow 2.1.0]では、以前の[HWI][topic hwi]実装が[Lark][news333 lark]に置き換えられ、
  [PSBTv2][topic psbt]のサポートとさまざまな更新が行われています。

- **Scure-btc-signer 1.6.0リリース:**
  [Scure-btc-signer][scure-btc-signer github]の[1.6.0][scure-btc-signer 1.6.0]リリースでは、
  バージョン3（[TRUC][topic v3 transaction relay]）トランザクションおよび
  [P2A（pay-to-anchors）][topic ephemeral anchors]がサポートされました。
  Scure-btc-signerは、[scure][scure website]ライブラリスイートの一部です。

- **Py-bitcoinkernelアルファ:**
  [Py-bitcoinkernel][py-bitcoinkernel github]は、
  [Bitcoin Coreの検証ロジックをカプセル化する][kernel blog]ライブラリである
  [libbitcoinkernel][Bitcoin Core #27587]と対話するためのPythonライブラリです。

- **Rust-bitcoinkernelライブラリ:**
  [Rust-bitcoinkernel][rust-bitcoinkernel github]は、libbitcoinkernelを使用してブロックデータを読み取り、
  トランザクションアウトプットとブロックを検証するための実験的なRustライブラリです。

- **BIP32 cbip32ライブラリ:**
  [cbip32ライブラリ][cbip32 library]は、libsecp256k1とlibsodiumを使用して
  Cで[BIP32][]を実装しています。

- **Lightning LoopがMuSig2に移行:**
  Lightning Loopのスワップサービスは、[最近のブログ記事][loop blog]で説明されているように、
  [MuSig2][topic musig]を使用するようになりました。

## 注目すべきコードとドキュメントの変更

_今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #27432][]では、`dumptxoutset` RPCコマンドで生成された
  コンパクトにシリアライズされたUTXOセット（[AssumeUTXO][topic assumeutxo]スナップショット用に設計）を
  SQLite3データベースに変換するPythonスクリプトが導入されています。`dumptxoutset`
  RPC自体を拡張してSQLite3データベースを出力することも検討されましたが、
  メンテナンスの負担が増すため、最終的に却下されました。
  このスクリプトは追加の依存関係を必要とせず、結果のデータベースはコンパクトにシリアライズされたUTXOセットの約2倍のサイズになります。

- [Bitcoin Core #30529][]では、`noseednode`、`nobind`、`nowhitebind`、`norpcbind`、
  `norpcallowip`、`norpcwhitelist`、`notest`、`noasmap`、`norpcwallet`、`noonlynet`、
  `noexternalip`などの否定オプションの処理が修正され、期待どおりに動作します。
  これまでは、これらのオプションを否定すると、混乱を招き、文書化されていない副作用が発生していましたが、
  現在は指定された設定をクリアしてデフォルトの動作を復元するだけです。

- [Bitcoin Core #31384][]は、ブロックヘッダー、トランザクション数、コインベーストランザクション用に予約された
  4,000 WU（weight unit）が誤って2回適用され、最大ブロックテンプレートのサイズが、
  不要に4,000 WU削減されて3,992,000 WUになる問題（ニュースレター[#336][news336 weightbug]参照）を解決します。
  この修正により、予約されたweightが1つのインスタンスに統合され、
  ユーザーが予約されるweightをカスタマイズできる新しい`-blockreservedweight`起動オプションが導入されます。
  予約されるweightが2,000 WUから4,000,000 WUの間の値に設定されていることを保証するための安全性チェックも追加されています。
  この範囲外の場合、Bitcoin Coreは起動に失敗します。

- [Core Lightning #8059][]は、`xpay`プラグイン（ニュースレター[#330][news330 xpay]参照）において、
  [マルチパス支払い][topic multipath payments]（MPP）をサポートしていない[BOLT11][]インボイスに支払いをする際に、
  この機能を抑制する機能を実装しました。同じロジックが[BOLT12][topic offers]インボイスにも拡張される予定ですが、
  次のリリースまで待たなければなりません。このPRで、BOLT12機能をプラグインに通知できるようにし、
  BOLT12インボイスをMPPで支払うことを明示的に許可するからです。

- [Core Lightning #7985][]は、[ブラインドパス][topic rv routing]経由のルーティングを有効にし、
  renepayの内部で使用されていた`sendpay`RPCコマンドを`sendonion`に置き換えることで、
  `renepay`プラグイン（ニュースレター[#263][news263 renepay]参照）で
  [BOLT12][topic offers]インボイスへの支払いをサポートできるようになりました。

- [Core Lightning #7887][]は、最新のBOLTの更新（ニュースレター[#290][news290 hrn]および
  [#333][news333 hrn]参照）に準拠するために、
  HRN（Human Readable Name）解決用の新しい[BIP353][]フィールドの処理をサポートします。
  このPRではまた、インボイスに`invreq_bip_353_name`フィールドを追加し、
  受信BIP353名フィールドの制限を適用し、ユーザーが`fetchinvoice` RPCでBIP353名を指定できるようにし、
  文言も変更しました。

- [Eclair #2967][]は、[BOLTs #1205][]で定義されている`option_simple_close`プロトコルをサポートします。
  この協調クローズプロトコルの簡略化版は、[Simple Taproot Channel][topic simple taproot
  channels]の前提条件です。これによりノードは、`shutdown`、`closing_complete`、`closing_sig`
  フェーズ中にnonceを安全に交換できます。これは、[MuSig2][topic musig]チャネルアウトプットを使用するために必要です。

- [Eclair #2979][]は、[トランポリン支払い][topic trampoline payments]を中継するための
  ウェイクアップフローを開始する前に、ノードがウェイクアップ通知（ニュースレター[#319][news319 wakeup]参照
  ）をサポートしていることを確認する検証手順を追加します。標準のチャネル支払いの場合、
  [BOLT11][]または[BOLT12][topic offers]インボイスでウェイクアップ通知のサポートが既に示されているため、
  このチェックは不要です。

- [Eclair #3002][]は、セキュリティを強化するために、ブロックとその承認済みトランザクションを処理して
  監視をトリガーするセカンダリの仕組みを導入します。これは、チャネルが使用されたか、
  支払いトランザクションがmempoolで検知されていない場合に特に便利です。
  ZMQの`rawtx`トピックはこれを処理しますが、信頼性が低く、
  リモートの`bitcoind`インスタンスを使用する場合に密かにドロップする可能性があります。
  新しいブロックが見つかるたびに、セカンダリシステムは最新Nブロック（デフォルトで6）を取得し、
  そのトランザクションを再処理します。

- [LDK #3575][]は、ノードがチャネルピアのバックアップを配布および保存できるようにする機能として
  [ピアストレージ][topic peer storage]プロトコルを実装します。ノード間でこれらのバックアップを交換できるように、
  2つの新しいメッセージタイプ、`PeerStorageMessage`と`PeerStorageRetrievalMessage`と
  それぞれのハンドラーが導入されています。ピアのデータは、`ChannelManager`の`PeerState`内に永続的に保管されます。

- [LDK #3562][]は、外部ソースからの実際の支払いパスの頻繁な[プローブ][topic payment probes]に基づいて
  スコアリングベンチマークをマージする新しいスコアラー（ニュースレター[#308][news308 scorer]参照）を導入します。
  これにより、一般的にネットワークビューが制限されている軽量ノードは、
  LSP（Lightning Service Provider）によって提供されるスコアなどの外部データを組み込むことで、
  支払いの成功率を向上させることができます。外部スコアは、ローカルスコアと組み合わせることも、
  ローカルスコアを上書きすることもできます。

- [BOLTs #1205][]は、[Simple Taproot Channel][topic simple taproot channels]に必要な
  協調クローズプロトコルの簡略化版である`option_simple_close`プロトコルをマージします。
  [BOLT2][]と[BOLT3][]が変更されました。

{% include snippets/recap-ad.md when="2025-02-25 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27432,30529,31384,8059,7985,7887,2967,2979,3002,3575,3562,1205,27587" %}
[news239 qos]: /ja/newsletters/2023/02/22/#ln-quality-of-service-flag-ln
[news163 pr paper]: /ja/newsletters/2021/08/25/#zero-base-fee-ln-discussion-ln
[news270 ldk2547]: /ja/newsletters/2023/09/27/#ldk-2547
[news270 ldk2534]: /ja/newsletters/2023/09/27/#ldk-2534
[teinturier mobileclose]: https://delvingbitcoin.org/t/zero-fee-commitments-for-mobile-wallets/1453
[teinturier mobileclose2]: https://delvingbitcoin.org/t/zero-fee-commitments-for-mobile-wallets/1453/3
[jager lnqos]: https://delvingbitcoin.org/t/highly-available-lightning-channels-revisited-route-or-out/1438
[corallo lnqos]: https://delvingbitcoin.org/t/highly-available-lightning-channels-revisited-route-or-out/1438/4
[ldk path]: https://lightningdevkit.org/blog/ldk-pathfinding/
[news330 xpay]: /ja/newsletters/2024/11/22/#core-lightning-7799
[news263 renepay]: /ja/newsletters/2023/08/09/#core-lightning-6376
[news290 hrn]: /ja/newsletters/2024/02/21/#dns-bitcoin
[news333 hrn]: /ja/newsletters/2024/12/13/#bolts-1180
[news319 wakeup]: /ja/newsletters/2024/09/06/#eclair-2865
[news308 scorer]: /ja/newsletters/2024/06/21/#ldk-3103
[news336 weightbug]: /ja/newsletters/2025/01/10/#bitcoin-core
[ark sdk github]: https://github.com/arklabshq/wallet-sdk
[new252 mutinynet]: /ja/newsletters/2023/05/24/#mutinynet-signet
[zaprite website]: https://zaprite.com
[iris github]: https://github.com/RGB-Tools/iris-wallet-desktop
[sparrow 2.1.0]: https://github.com/sparrowwallet/sparrow/releases/tag/2.1.0
[news333 lark]: /ja/newsletters/2024/12/13/#java-hwi
[scure-btc-signer github]: https://github.com/paulmillr/scure-btc-signer
[scure-btc-signer 1.6.0]: https://github.com/paulmillr/scure-btc-signer/releases
[scure website]: https://paulmillr.com/noble/#scure
[py-bitcoinkernel github]: https://github.com/stickies-v/py-bitcoinkernel
[rust-bitcoinkernel github]: https://github.com/TheCharlatan/rust-bitcoinkernel
[kernel blog]: https://thecharlatan.ch/Kernel/
[cbip32 library]: https://github.com/jamesob/cbip32
[loop blog]: https://lightning.engineering/posts/2025-02-13-loop-musig2/
