---
title: 'Bitcoin Optech Newsletter #397'
permalink: /ja/newsletters/2026/03/20/
name: 2026-03-20-newsletter-ja
slug: 2026-03-20-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、サービスとクライアントソフトの更新や、
新しいリリースとリリース候補の発表、人気のBitcoin基盤ソフトウェアの最近の更新など
恒例のセクションを掲載しています。

## ニュース

_今週は、どの[情報源][sources]からも重要なニュースは見つかりませんでした。_

## サービスとクライアントソフトウェアの更新

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Cake Walletがライトニングをサポート:**
  Cake Walletは、Breez SDKと[Spark][topic statechains]の統合によるライトニングネットワークのサポートを
  [発表しました][cake ln post]。ライトニングアドレスにも対応しています。

- **Sparrow 2.4.0および2.4.2リリース:**
  Sparrow [2.4.0][sparrow 2.4.0]では、[サイレントペイメント][topic silent payments]の
  ハードウェアウォレットサポートのための[BIP375][] [PSBT][topic psbt]フィールドを追加し、
  [Codex32][topic codex32]のインポーターも追加しました。Sparrow [2.4.2][sparrow 2.4.2]は、
  [v3トランザクション][topic v3 transaction relay]のサポートを追加しています。

- **Blockstream JadeがLiquid経由でライトニングに対応:**
  Blockstreamは、Jadeハードウェアウォレット（Greenアプリ5.2.0経由）が
  [サブマリンスワップ][topic submarine swaps]を使用してライトニングと連携できるようになったことを[発表しました][jade ln blog]。
  サブマリンスワップによりライトニングの支払いを[Liquid][topic sidechains] Bitcoin（L-BTC）に変換し、鍵をオフラインに保ちます。

- **Lightning Labsがエージェントツールをリリース:**
  Lightning Labsは、[L402プロトコル][blip 26]を使用して、
  人間の介入やAPIキーなしでAIエージェントがライトニングネットワーク上で動作できるようにする
  オープンソースツールキットを[リリースしました][ll agent tools]。

- **TetherがMiningOSをローンチ:**
  Tetherは、Bitcoinのマイニングオペレーションを管理するためのオープンソースのオペレーティングシステム
  MiningOSを[ローンチしました][tether mos]。Apache 2.0ライセンスのこのソフトウェアは、
  ハードウェアに依存せずに、モジュラーなP2Pアーキテクチャを採用しています。

- **FIBREネットワークが再開:**
  Localhost Researchは、2017年に停止していたFIBRE（Fast
  Internet Bitcoin Relay Engine）の再開を[発表しました][fibre blog]。
  今回の再開には、Bitcoin Core v30へのリベースとモニタリングスイートが含まれており、
  世界中に6つの公開ノードが展開されています。FIBREは、低遅延のブロック伝播を実現する
  [コンパクトブロックリレー][topic compact block relay]を補完します。

- **Bitcoin Core用のTUIリリース:**
  [Bitcoin-tui][btctui tweet]は、Bitcoin Core用のターミナルインターフェースで、
  JSON-RPCを介して接続し、ブロックチェーンやネットワークデータを表示します。
  mempoolの監視、トランザクションの検索とブロードキャスト、ピア管理などの機能を備えています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 31.0rc1][]は、主要なフルノード実装の次期メジャーバージョンのリリース候補です。
  [テストガイド][bcc31 testing]が利用可能です。

- [BTCPay Server 2.3.6][]は、このセルフホスト型のペイメントソリューションのマイナーリリースです。
  ウォレット検索バーにラベルフィルタリング機能が追加され、インボイスAPIエンドポイントに支払い方法データが含まれるようになり、
  プラグインによるカスタム権限ポリシーの定義が可能になりました。また、いくつかのバグ修正も含まれています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #31560][]は、`dumptxoutset` RPC（[ニュースレター #72][news72 dump]参照）を拡張し、
  UTXOセットのスナップショットを名前付きパイプに書き込めるようにしました。
  これにより、完全なダンプをディスクに書き込む必要なく、出力を別のプロセスに直接ストリーミングできます。
  これは、`utxo_to_sqlite.py`ツール（[ニュースレター #342][news342 sqlite]参照）と組み合わせることで、
  UTXOセットのSQLiteデータベースをオンザフライで作成できるようになります。

- [Bitcoin Core #31774][]は、ウォレットの暗号化に使用されるAES-256暗号鍵マテリアルを
  `secure_allocator`で保護するようになりました。これにより、メモリが不足した際に
  オペレーティングシステムによってディスクにスワップされるのを防ぎ、
  使用後はメモリからゼロクリアされます。ユーザーがウォレットを暗号化またはアンロックすると、
  パスフレーズからAES鍵が導出され、ウォレットの秘密鍵の暗号化または復号に使用されます。
  これまでは、この鍵マテリアルは標準のアロケーターで割り当てられていたため、
  ディスクにスワップされたりメモリ上に残存する可能性がありました。

- [Core Lightning #8817][]は、実装間のテスト中に発見されたEclairとの
  [スプライシング][topic splicing]の相互運用性に関する複数の問題を修正しました
  （以前の相互運用性の取り組みについては、ニュースレター[#331][news331 interop]および[#355][news355 interop]参照）。
  CLNは、スプライシングの再接続中にEclairがネゴシエーションを再開する前に送信する可能性のある
  `channel_ready`メッセージを処理できるようになり、クラッシュを引き起こす可能性のあるRPCエラーを修正し、
  新しい`channel_reestablish` TLVによるアナウンス署名の再送信を実装しました。

- [Eclair #3265][]および[LDK #4324][]は、BOLT仕様の最新の更新（[ニュースレター
  #396][news396 amount]参照）に合わせて、`offer_amount`がゼロに設定された
  [BOLT12オファー][topic offers]を拒否するようになりました。

- [LDK #4427][]は、ネゴシエーション済みだがまだロックされていない[スプライシング][topic splicing]の
  ファンディングトランザクションに対して、[静止][topic channel commitment upgrades]状態に再移行することで
  [RBF][topic rbf]による手数料引き上げのサポートを追加しました。両方のピアが同時にRBFを試みた場合、
  静止状態のタイブレークで敗れた側がアクセプターとして参加できます。取引相手がRBFを開始した際には、
  以前のコントリビューションが自動的に再利用され、手数料引き上げによってピアのスプライシング資金が暗黙的に除去されるのを防ぎます。
  これが基盤とするスプライシングのアクセプターのコントリビューションサポートについては、
  [ニュースレター #396][news396 splice]をご覧ください。

- [LDK #4484][]は、[ゼロ承認チャネル][topic zero-conf channels]を含む、
  手数料ゼロの[HTLC][topic htlc]を含む[アンカー][topic anchor outputs]チャネルについて、
  受け入れ可能なチャネル[ダスト][topic uneconomical outputs]制限の最大値を10,000 satoshiに引き上げました。
  これは[BOLTs #1301][]の推奨事項を実装するものです（[ニュースレター #395][news395 dust]参照）。

- [BIPs #1974][]は、[BIP446][]および[BIP448][]をドラフトBIPとして公開しました。
  [BIP446][]は`OP_TEMPLATEHASH`を規定しており、これは使用トランザクションのハッシュをスタックにプッシュする
  新しい[tapscript][topic tapscript] opcodeです（初期の提案については[ニュースレター #365][news365 op]参照）。
  [BIP448][]は、`OP_TEMPLATEHASH`を[OP_INTERNALKEY][BIP349]および[OP_CHECKSIGFROMSTACK][topic
  op_checksigfromstack]とグループ化し、「Taprootネイティブの再バインド可能なトランザクション」を提案します。
  この[コベナンツ][topic covenants]バンドルにより、[LN-Symmetry][topic eltoo]が可能になるほか、
  他のセカンドレイヤープロトコルにおける対話の削除と簡素化が可能になります。

{% include snippets/recap-ad.md when="2026-03-24 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31560,31774,8817,3265,4324,4427,4484,1974,1301" %}
[sources]: /ja/internal/sources/
[cake ln post]: https://blog.cakewallet.com/our-lightning-journey/
[sparrow 2.4.0]: https://github.com/sparrowwallet/sparrow/releases/tag/2.4.0
[sparrow 2.4.2]: https://github.com/sparrowwallet/sparrow/releases/tag/2.4.2
[jade ln blog]: https://blog.blockstream.com/jade-lightning-payments-are-here/
[ll agent tools]: https://github.com/lightninglabs/lightning-agent-tools
[blip 26]: https://github.com/lightning/blips/pull/26
[x402 blog]: https://blog.cloudflare.com/x402/
[tether mos]: https://mos.tether.io/
[fibre blog]: https://lclhost.org/blog/fibre-resurrected/
[btctui tweet]: https://x.com/_jan__b/status/2031741548098896272
[bitcoin core 31.0rc1]: https://bitcoincore.org/bin/bitcoin-core-31.0/
[bcc31 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/31.0-Release-Candidate-Testing-Guide
[BTCPay Server 2.3.6]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.6
[news72 dump]: /ja/newsletters/2019/11/13/#bitcoin-core-16899
[news342 sqlite]: /ja/newsletters/2025/02/21/#bitcoin-core-27432
[news331 interop]: /ja/newsletters/2024/11/29/#core-lightning-7719
[news355 interop]: /ja/newsletters/2025/05/23/#core-lightning-8021
[news396 amount]: /ja/newsletters/2026/03/13/#bolts-1316
[news396 splice]: /ja/newsletters/2026/03/13/#ldk-4416
[news395 dust]: /ja/newsletters/2026/03/06/#bolts-1301
[news365 op]: /ja/newsletters/2025/08/01/#taproot-op-templatehash