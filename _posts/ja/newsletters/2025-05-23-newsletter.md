---
title: 'Bitcoin Optech Newsletter #355'
permalink: /ja/newsletters/2025/05/23/
name: 2025-05-23-newsletter-ja
slug: 2025-05-23-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、サービスやクライアントソフトウェアの更新や、
新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの最近の変更など
恒例のセクションを掲載しています。

## ニュース

*今週は、どの[情報源][sources]からも重要なニュースは見つかりませんでした。*

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Cake WalletがPayjoin v2をサポート:**
  Cake Wallet [v4.28.0][cake wallet 4.28.0]では、
  [Payjoin][topic payjoin] v2プロトコルを使用した支払いを[受け取れる][cake blog]ようになりました。

- **Sparrowがpay-to-anchor機能を追加:**
  Sparrow [2.2.0][sparrow 2.2.0]では、
  [P2A（pay-to-anchor）][topic ephemeral anchors]アウトプットの表示と送信が可能になりました。

- **Safe Wallet 1.3.0リリース:**
  [Safe Wallet][safe wallet github]は、ハードウェア署名デバイスをサポートするデスクトップマルチシグウォレットで、
  [1.3.0][safe wallet 1.3.0]では受信トランザクションに[CPFP][topic cpfp]による手数料の引き上げが追加されました。

- **COLDCARD Q v1.3.2リリース:**
  COLDCARD Q [v1.3.2 リリース][coldcard blog]には、マルチシグ[支払いポリシー][coldcard ccc]の追加サポートと、
  [機密データ共有][coldcard kt]のための新機能が含まれています。

- **Payjoinを使用したトランザクションのバッチ処理:**
  [Private Pond][private pond post]は、Payjoinを使用して
  手数料の少ない小規模なトランザクションを生成する[トランザクションバッチ処理][topic payment batching]サービスの
  [実験的な実装][private pond github]です。

- **JoinMarket Fidelity Bond Simulator:**
  [JoinMarket Fidelity Bond Simulator][jmfbs github]は、
  JoinMarketの参加者が[Fidelity Bond][news161 fb]に基づいて
  市場でのパフォーマンスをシミュレーションするためのツールを提供します。

- **Bitcoin opcodeのドキュメント化:**
  [Opcode Explained][opcode explained website]では、Bitcoinスクリプトの各opcodeがドキュメント化されています。

- **Bitkeyのコードのオープンソース化:**
  ハードウェア署名デバイスBitkeyは、非商用利用向けに[ソースコード][bitkey github]を
  オープンソース化すること[発表しました][bitkey blog]

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [LND 0.19.0-beta][]は、この人気のLNノードの最新のメジャーリリースです。
  これには、協調クローズにおける新しいRBFベースの手数料引き上げを含む多くの[改善][lnd rn]や
  バグ修正が含まれています。

- [Core Lightning 25.05rc1][]は、この人気のLNノード実装の次期メジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #32423][]は、`rpcuser/rpcpassword`の非推奨通知を削除し、
  設定ファイルに平文の認証情報を保存することに関するセキュリティ警告に置き換えました。
  このオプションは、複数のRPCユーザーをサポートし、cookieをハッシュする`rpcauth`が
  [Bitcoin Core #7044][]で導入された際に非推奨となりました。
  また、このPRでは、両方のメソッドから取得した認証情報にランダムな16 byteのsaltを追加し、
  メモリに格納する前にハッシュします。

- [Bitcoin Core #31444][]は、`TxGraph`クラス（ニュースレター[#348][news348 txgraph]参照）を拡張し、
  3つの新しいヘルパー関数を追加しました。`GetMainStagingDiagrams()`は、
  メインの手数料率ダイアグラムとステージングの手数料率ダイアグラム間のクラスターの乖離を返します。
  `GetBlockBuilder()`は、グラフチャンク（サブクラスターの手数料率でソートされたグループ）を
  手数料率の高い順に反復処理してブロックの構築を最適化します。`GetWorstMainChunk()`は、
  排除の判断の際に、手数料率が最も低いチャンクを特定します。このPRは、
  [クラスターmempool][topic cluster mempool]プロジェクトの完全な初期実装における最終的な構成要素の1つです。

- [Core Lightning #8140][]は、デフォルトでチャネルバックアップの
  [ピアストレージ][topic peer storage]を有効にします（ニュースレター[#238][news238 storage]参照）。
  これにより、ストレージを現在または過去のチャネルを持つピアに限定し、
  `listdatastore`/`listpeerchannels`を繰り返し呼び出す代わりに、
  バックアップとピアリストをメモリにキャッシュし、バックアップの同時アップロードの上限を2つのピアに制限し、
  65 kBを超えるバックアップをスキップし、送信時にピアの選択をランダムにすることで、
  大規模ノードでも実行可能になりました。

- [Core Lightning #8136][]は、最近の[BOLTs #1215][]仕様更新にあわせて、
  アナウンスの署名の交換を6ブロック後ではなくチャネルの準備ができた時に行われるようになりました。
  [チャネルのアナウンス][topic channel announcements]に6ブロック待つ必要があるのは変わっていません。

- [Core Lightning #8266][]は、Recklessプラグインマネージャー（ニュースレター[#226][news226 reckless]参照）に
  `update`コマンドを追加します。このコマンドは、指定されたプラグイン、
  または指定されていない場合はインストール済みのすべてのプラグイン（
  固定のGitタグまたはコミットからインストールされたものは除く）を更新します。
  またこのPRは、`install`コマンドを拡張し、プラグイン名に加えて、
  ソースパスまたはURLからも取得できるようにしています。

- [Core Lightning #8021][]は、リモートのファンディング鍵のローテンションを修正することで、
  チャネルの再確立時に`splice_locked`を再送信することで元々見逃していたケースをカバーし（ニュースレター[#345][news345
  splicing]参照）、コミットメント署名メッセージが特定の順序で到着するという要件を緩和し、
  スプライシング[RBF][topic rbf]トランザクションの受け取りと開始を可能にし、
  必要に応じて送信[PSBT][topic psbt]をバージョン2に自動変換するなど、
  Eclairとの[スプライシング][topic splicing]の相互運用（ニュースレター[#331][news331 interop]参照）を完成させました。
  また、その他のリファクタリングも行われています。

- [Core Lightning #8226][]は、新しい`signmessagewithkey` RPCコマンドを追加することで、
  [BIP137][]を実装しました。このコマンドにより、ユーザーはBitcoinアドレスを指定することで、
  ウォレット内の任意の鍵でメッセージに署名できます。これまでは、Core Lightningの鍵でメッセージに署名するには、
  外部ライブラリで秘密鍵を抽出し、Bitcoin Coreでメッセージに署名する必要がありました。

- [LND #9801][]では、新しい`--no-disconnect-on-pong-failure`オプションが追加されました。
  このオプションは、pong応答が遅延または不一致の場合にピアを切断するかどうかを制御します。
  デフォルトではfalseに設定されており、pongメッセージの失敗時にピアを切断するLNDの現在の動作が維持されます
  （ニュースレター[#275][news275 ping]参照）。trueに設定すると、LNDはイベントをログに記録するだけです。
  このPRでは、ping watchdogをリファクタリングし、切断が抑制された場合もループを継続するようにしました。

{% include snippets/recap-ad.md when="2025-05-27 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32423,31444,8140,8136,8266,8021,8226,9801,7044,1215" %}
[lnd 0.19.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta
[sources]: /ja/internal/sources/
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.19.0.md
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[news348 txgraph]: /ja/newsletters/2025/04/04/#bitcoin-core-31363
[news238 storage]: /ja/newsletters/2023/02/15/#core-lightning-5361
[news226 reckless]: /ja/newsletters/2022/11/16/#core-lightning-5647
[news331 interop]: /ja/newsletters/2024/11/29/#core-lightning-7719
[news345 splicing]: /ja/newsletters/2025/03/14/#eclair-3007
[news275 ping]: /ja/newsletters/2023/11/01/#lnd-7828
[cake wallet 4.28.0]: https://github.com/cake-tech/cake_wallet/releases/tag/v4.28.0
[cake blog]: https://blog.cakewallet.com/bitcoin-privacy-takes-a-leap-forward-cake-wallet-introduces-payjoin-v2/
[sparrow 2.2.0]: https://github.com/sparrowwallet/sparrow/releases/tag/2.2.0
[safe wallet github]: https://github.com/andreasgriffin/bitcoin-safe
[safe wallet 1.3.0]: https://github.com/andreasgriffin/bitcoin-safe/releases/tag/1.3.0
[coldcard blog]: https://blog.coinkite.com/ccc-and-keyteleport/
[coldcard ccc]: https://coldcard.com/docs/coldcard-cosigning/
[coldcard kt]: https://github.com/Coldcard/firmware/blob/master/docs/key-teleport.md
[private pond post]: https://njump.me/naddr1qvzqqqr4gupzqg42s9gsae3lu2cketskuzfp778fh2vg9c5x3elx8ttdpzhfkk25qq2nv5nzddgxxdjtd4u9vwrdv939vmnswfzk6j85dxk
[private pond github]: https://github.com/Kukks/PrivatePond
[jmfbs github]: https://github.com/m0wer/joinmarket-fidelity-bond-simulator
[news161 fb]: /ja/newsletters/2021/08/11/#implementation-of-fidelity-bonds-fidelity-bond
[opcode explained website]: https://opcodeexplained.com/
[bitkey blog]: https://x.com/BEN0WHERE/status/1918073429791785086
[bitkey github]: https://github.com/proto-at-block/bitkey