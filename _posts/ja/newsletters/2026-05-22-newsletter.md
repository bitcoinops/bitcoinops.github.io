---
title: 'Bitcoin Optech Newsletter #406'
permalink: /ja/newsletters/2026/05/22/
name: 2026-05-22-newsletter-ja
slug: 2026-05-22-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、BIP322の汎用署名メッセージフォーマットの更新に関する議論のリンクと、
NATの背後にあるBitcoinノードがインバウンド接続を受け入れられるよう支援するために
TCPホールパンチングを利用するというアイデアを掲載しています。また、サービスやクライアントソフトウェアの最近の更新や、
人気のあるBitcoin基盤ソフトウェアへの注目すべき更新など恒例のセクションも含まれています。

## ニュース

- **BIP322「Generic Signed Message Format」の重要な更新**: Oliver Guggerは、
  [BIP322][topic generic signmessage]を完成形にするためのアイデアについてBitcoin-Devメーリングリストに[投稿しました][guggero bip322 ml]。
  Guggerはbtcdでのサポートを実装する中で、いくつかの未解決の問題や提案の不備に気づきました。
  彼は提案に対して3つの主要な修正を提案しました:

  - 3種類の署名を区別するための人間が読めるプレフィックス

  - 「Proof of Funds(資金の証明)」版へのUTXO情報の含有

  - PSBTベースのメッセージ署名のサポート

  いくつかの議論を経て、PSBTの構築に関するフィードバックを取り込んだ後、BIP322への更新が公開されました（[ニュースレター #405][news405 bip322]参照）。
  GuggerはBIP322をComplete(完了)へと進め、仕様が安定し、実装準備が整ったことを示しました。
  この更新以降、Coldcardが3月にBIP322の[サポートを出荷していた][cc 322]ことが再び話題になりました。

  以前のバージョンのBIP322のサポートを実装していたプロジェクトは、新しい人間が読みやすいプレフィックスや、
  改訂されたProof of Funds署名フォーマットなど、互換性を損なう変更が導入された更新仕様との互換性を確認する必要があります。

- **NATの背後にあるBitcoinノードのためのTCPホールパンチング**: 0xB10C は、
  家庭用ルーターのNATの背後にあるより多くノードが、インバウンド接続を受け入れられるようにするためのアイデアについて、
  Delving Bitcoinに[投稿しました][hole punch del]。この最初の構想は、[Bitcoin Core v30.0][]以降で
  `-natpmp=1`をデフォルト設定しても、家庭用ISPにおける到達可能なノード数が期待どおりに増加しなかったという観察から生まれたものです。

  このアイデアは、ホールパンチングを活用します。これは、特定の種類のNATの背後にある2つのホストが、
  サーバー経由でトラフィックを中継することなく直接接続できる技術です。プロセスは次のように動作します。
  到達不能な2つのホスト、アリスとボブが、第三者を介して自分たちの公開エンドポイント(つまり、IPアドレスとポート)を交換し、
  同時に互いへの接続を開始します。これによりNAT内にマッピングが作成され、ホストはハンドシェイクを完了して接続を確立できます。
  提案されている技術はノード間の正確な同期を必要とするTCP上で動作するため、UDPを使う同様の技術と比較すると障害率が高くなります。

  0xB10Cは、BitcoinのP2Pプロトコルを使った実装に関する複数のアプローチに言及しました。
  1つめのアプローチでは、ランデブーサーバーと呼ばれるブリッジが必要であり、
  これによってアリスとボブがエンドポイント情報を交換できます。このサーバーは、
  到達不能なホストが自身の接続スロットを提供できるようにするマッチメイキングサービスを提供することもできますし、
  空きインバウンドスロットの不足により既存の接続を削除する代わりに、既存の接続のうち1つを別のピアに引き継ぐことを決定することもできます。
  彼はまた、[Tor/I2P][topic anonymity networks]下で直接ホールパンチングを実行し、
  接続確立のための第三者サーバーを不要にする方法についても説明しました。このアプローチでは、
  アリスが専用のTor/I2Pエンドポイントで待ち受けを開始し、そこにボブが接続してホールパンチングのプロセスを開始します。

  この提案はまだ正式なものではなく、多くの疑問点が残されています。0xB10Cはコミュニティからのフィードバックを求め、
  ホールパンチ接続をどのように分類するか、TCPホールパンチングの信頼性、起こりうる攻撃、
  実装の労力といった多くの未解決点に対処するための議論を呼びかけました。

## サービスとクライアントソフトウェアの更新

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Ibis Walletの発表:** [Ibis Wallet][ibis wallet]はBDK上に構築されたAndroidウォレットで、
  コインコントロール、[RBF][topic rbf]および[CPFP][topic cpfp]による手数料管理、マルチシグ、
  QRコードを用いたハードウェア署名デバイスとの統合、[サイレントペイメント][topic silent payments]、
  そして[Tor][topic anonymity networks]の統合をサポートします。また、Spark、Liquid、
  そして将来的には[Ark][topic ark]を含むオプションのセカンドレイヤーもサポートします。

- **LDK Serverの発表:** Spiralは[LDK Server][ldk server]を発表しました。これは、
  ペイメントプロセッサーやウォレットプロバイダー向けにLDK Node上に構築されたAPIファーストのライトニングノードデーモンです。
  gRPCインターフェース、組み込みのBDKベースのウォレット、そしてAIエージェントがノードと対話するための
  MCP（Model Context Protocol）サーバーを提供します。

- **Mempool.space v3.3.0リリース:** Mempool [v3.3.0][mempool v3.3.0]は、[Taproot][topic taproot]スクリプトツリーの可視化、
  更新された[PSBT][topic psbt]プレビュー、[手数料推定][topic fee estimation]の改善、
  [エフェメラル・ダスト][topic ephemeral anchors]のサポート、古くなったブロックの比較、
  sighashアイコン、merkle-proof APIなどの機能を追加しています。

- **peer-observer のP2P監視ツール:** 0xB10C は、自身の[peer-observer][peer-observer site]
  プラットフォームで使用されているいくつかのオープンソースコンポーネントを[概説しました][peer-observer delving]。
  これには、IPC、ログ、P2P、RPCのソースを使ってBitcoin Coreノードからイベントを抽出するためのインフラストラクチャが含まれます。
  彼はまた、アーカイブ、異常検知、アラートツールに関する継続的な開発についても説明しています。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #29136][]は、指定された[BIP32][]拡張秘密鍵をインポートするか、指定がなければ生成する
  `addhdkey` RPCを追加します。これはアウトプットスクリプトの生成には使われません。
  これにより、ウォレットは即座にアドレスを生成することなく、
  将来の使用(例えばマルチシグスクリプト向け)のために署名鍵を保管できます。このPRはまた、
  保管された鍵をウォレットバックアップに含めることができるように、
  `listdescriptors`が返す新しい`unused(KEY)`[ディスクリプター][topic descriptors]型も追加されています。

- [Bitcoin Core #34893][]は、[PSBT][topic psbt]を結合する際に[BIP174][]の独自フィールド（ニュースレター[#72][news72 psbt]
  および[#181][news181 psbt]を参照)を保持するよう`combinepsbt` RPCを更新します。
  これまでは`combinepsbt`が独自フィールドを暗黙的に破棄しており、アプリケーション固有のPSBTメタデータが失われる結果となっていました。
  `decodepsbt` RPCはすでにこれらのフィールドを適切にパース、シリアライズ、表示しています。

- [Bitcoin Core #34860][]は、`CreateNewBlock()`メソッドから`include_dummy_extranonce`
  オプションを削除します(ニュースレター[#392][news392 mining]参照)。Bitcoin Core は、
  高さ0から16のブロックを作成する際、内部のコインベースscriptSigに常にダミーパディングを付加するようになりました。
  これらの高さでは、[BIP34][]の高さエンコーディングだけではコンセンサス上の最小scriptSig長を満たせないためです。
  ただし、このパディングはMining IPCインターフェース経由で接続された[Stratum V2][topic pooled mining]クライアントに公開される
  `CoinbaseTx`構造体の`scriptSigPrefix`フィールドには含まれません(ニュースレター[#310][news310 ipc]および[#388][news388 ipc]参照)。

- [Bitcoin Core #31298][]は、無関係なトランザクションを拒否するよう
  `combinerawtransaction` RPCを更新します。これまでは、最初のトランザクションを暗黙的に返し、
  それらがマージできなかったことを報告しませんでした。Bitcoin Coreは現在、
  各トランザクションからインプットのscriptSigとwitnessを取り除き、
  その結果得られる未署名トランザクションのハッシュを比較し、それらが一致しない場合はエラーを返します。

- [Bitcoin Core #28802][]は、Bitcoin CoreのCLI引数パーサーである`ArgsManager`に、
  コマンド固有のオプションのサポートを追加します。コマンドは、自身に適用されるオプションを宣言できるようになり、
  `ArgsManager`はそれらのオプションを関連するコマンドのヘルプ出力の下に列挙し、
  無効なコマンドとオプションの組み合わせを自動的に拒否できます。このPRは、これを
  `bitcoin-wallet`([ニュースレター #32][news32 dump]参照)の`-dumpfile`オプションに適用しており、
  このオプションは現在`dump`および`createfromdump`コマンドに対してのみ登録されています。

- [Eclair #3298][]は、低い手数料率での[BIP125][]の置換ルールへの準拠を保証するよう設計された新しい
  [BOLT2][]の手数料率引き上げルールに従うよう、内部の[RBF][topic rbf]ロジックを更新します。
  これまでの25/24手数料率乗数のみを適用する代わりに、Eclairはその乗数か、追加の25 sat/kwのいずれか大きい方を使用するようになりました。
  これは、ニュースレター[#400][news400 rbf]で取り上げたLDKの挙動、およびニュースレター[#404][news404 rbf]で取り上げたBOLT仕様の更新と一致します。

- [LDK #4575][]は、チャネルに資金を[スプライシング][topic splicing]する際に
  ユーザーが手動でUTXOを選択できるようにする`splice_in_inputs` APIを追加します。
  選択されたUTXOは完全に消費され、その金額から手数料を差し引いた額がチャネルに追加され、
  お釣りのアウトプットは作成されません。これは既存の金額ベースのスプライスインフローを補完するものです。
  このフローでは、呼び出し側が追加する金額を指定し、ウォレットがインプットを選択します。ただし、
  2つのインプット選択フローを同一の資金提供内で混在させることはできません。

- [LND #10814][]は、バージョン0.21で削除予定とされていた非推奨の`SendPayment`、`SendPaymentSync`、
  `SendToRoute`、`SendToRouteSync`、`TrackPayment`エンドポイントを削除します(ニュースレター[#340][news340 lnd]参照)。
  呼び出し側はV2の代替である`SendPaymentV2`、`SendToRouteV2`、`TrackPaymentV2`を使用する必要があります。
  このPRはまた、非推奨の単一チャネル`outgoing_chan_id`フィールドも削除し、
  呼び出し側に複数チャネル対応の`outgoing_chan_ids`フィールドを使用することを要求します([ニュースレター #33][news33 lnd]参照)。

- [Rust Bitcoin #6191][]は、[Erlay][topic erlay]のトランザクションリコンシリエーションで使用される
  `sendtxrcncl` P2Pメッセージのエンコードおよびデコードのサポートを追加します。Bitcoin Coreは
  Erlayサポートの初期対応の一部としてこのメッセージのサポートを追加しました(ニュースレター[#223][news223 erlay]参照)。
  ただし、完全なErlayトランザクションリコンシリエーションはまだ実装されていません。

- [BLIPs #42][]は、[BOLT12][]の連絡先に関する仕様である[BLIP42][]を追加します。
  [BOLT12オファー][topic offers]は静的なライトニング支払い指示として再利用できるため、
  ウォレットはオファーを連絡先として保存できます。このBLIPは、
  支払人が連絡先への支払いを行う際に含めることができるオプションの`invoice_request`フィールド（
  連絡先シークレット、自身のオファー、[BIP353][]名など）を定義します。これにより、
  受取人は既知の連絡先からの支払いを認識したり、新しい連絡先を追加したり、
  追加のやり取りなしに支払い側に資金を送り返したりすることができます。

{% include snippets/recap-ad.md when="2026-05-26 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29136,34893,34860,31298,28802,3298,4575,10814,6191,42" %}
[ibis wallet]: https://github.com/aeonBTC/IbisWallet
[ldk server]: https://github.com/lightningdevkit/ldk-server
[mempool v3.3.0]: https://github.com/mempool/mempool/releases/tag/v3.3.0
[peer-observer delving]: https://delvingbitcoin.org/t/peer-observer-a-tool-and-infrastructure-for-monitoring-the-bitcoin-p2p-network-for-attacks-and-anomalies/1988/4
[peer-observer site]: https://public.peer.observer/
[news72 psbt]: /ja/newsletters/2019/11/13/#bips-849
[news181 psbt]: /ja/newsletters/2022/01/05/#bitcoin-core-17034
[news392 mining]: /ja/newsletters/2026/02/13/#bitcoin-core-32420
[news310 ipc]: /ja/newsletters/2024/07/05/#bitcoin-core-30200
[news388 ipc]: /ja/newsletters/2026/01/16/#bitcoin-core-33819
[news32 dump]: /en/newsletters/2019/02/05/#bitcoin-core-13926
[news400 rbf]: /ja/newsletters/2026/04/10/#ldk-4494
[news404 rbf]: /ja/newsletters/2026/05/08/#bolts-1327
[news340 lnd]: /ja/newsletters/2025/02/07/#lnd-9456
[news33 lnd]: /en/newsletters/2019/02/12/#lnd-2572
[news223 erlay]: /ja/newsletters/2022/10/26/#bitcoin-core-23443
[hole punch del]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497
[Bitcoin Core v30.0]: https://bitcoincore.org/ja/releases/30.0/
[guggero bip322 ml]: https://groups.google.com/g/bitcoindev/c/qd6BNz9gxCk/m/k1fHq4RKAQAJ
[cc 322]: https://blog.coinkite.com/bip322-wif/
[news405 bip322]: /ja/newsletters/2026/05/15/#bips-2141