---
title: 'Bitcoin Optech Newsletter #407'
permalink: /ja/newsletters/2026/05/29/
name: 2026-05-29-newsletter-ja
slug: 2026-05-29-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、リモートピアがCore Lightningノードのクラッシュを可能にする脆弱性の責任ある開示と、
最近のBitcoin Core開発者会議の議事録のリンクを掲載しています。また、新しいリリースとリリース候補の発表や、
人気のBitcoin基盤ソフトウェアの注目すべき更新など恒例のセクションも含まれています。

## ニュース

- **Core LightningのアサーションDoSの開示:** Chandra Pratapは、
  2025年夏のBitcoinインターンシップ中に発見されたサービス拒否(DoS)の脆弱性の開示について
  Delving Bitcoinに[投稿しました][cln dos delving]。この脆弱性は、インバウンドチャネルを受け入れるCore Lightningノードに影響します。

  チャネル開設のハンドシェイク中、リモートピアは提案するファンディングトランザクションのtxidを含むメッセージを送信します。
  Core Lightningは、txidが非ゼロであることを要求するアサーションチェックを実行していました。
  ピアが代わりにすべてゼロのtxidを送信すると、アサーションが失敗してノードがクラッシュしました。
  どのピアもチャネルを開くハンドシェイクを開始して悪意あるメッセージを送信できるため、
  これによりリモートの攻撃者がインバウンドチャネルを受け入れた脆弱なノードを確実にクラッシュさせることが可能でした。

  この脆弱性は[責任を持って開示され][topic responsible disclosures]、ファジングによって発見されました。
  報告の時点で、Rusty Russell氏は独立して別のクラッシュバグに取り組んでおり、
  彼の修正は偶然にもこの脆弱性も解決していました。この脆弱性は[Core Lightning 26.04][news402 cln2604]で修正されました。

- **Bitcoin Core開発者会議の議事録:** 多くのBitcoin Core開発者が5月に対面で会合を行い、
  その会議の議事録が[公開されました][coredev 2026-05]。トピックには、[SwiftSync][coredev swiftsync]、
  [ポストクラスターmempool][coredev post-cluster]、[Erlayの再設計][coredev erlay]、
  [パッケージリレー][coredev pkg relay]、[サイレントペイメント][coredev silent payments]、
  [TCPホールパンチング][coredev tcp holepunch]([ニュースレター #406][news406 tcp holepunch]参照)、
  [プライベートブロードキャスト][coredev private broadcast]、[最新の暗号ライブラリ][coredev modern crypto]、
  [ミューテーションテスト][coredev mutation testing]などが含まれていました。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Eclair v0.14.0][]は、この人気のLNノード実装の最新リリースです。[スプライシング][topic splicing]、
  [Simple Taproot Channel][topic simple taproot channels]および
  [ゼロ手数料コミットメント][topic v3 commitments]の最終版を含み、
  非[アンカーアウトプット][topic anchor outputs]チャネルのサポートを削除し、
  流動性とルーティングの最適化のための実験的なピアスコアリングを追加しています。

- [Core Lightning 26.06rc2][]は、この人気のLNノードの次期メジャーバージョンのリリース候補で、
  新しい`graceful`、`sendamount`、`xkeysend` RPCを含み、`pay`から`xpay`への移行に向けた`pay`の非推奨化サイクルを開始し、
  [BOLT12][topic offers]のpayer-proof(支払者証明)RPCサポートを追加しています。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #33966][]は、Mining IPCインターフェース向けのマイニングブロックテンプレートオプションの処理方法を
  リファクタリングしています(ニュースレター[#310][news310 mining]および[#323][news323 mining]参照)。
  これまでは、`blockmaxweight`、`blockreservedweight`、`blockmintxfee`などの起動時のマイニングオプションは、
  IPCマイニングクライアントから渡される実行時オプションとは別々に処理されていました。今後は、
  これらのオプションは共有の`BlockCreateOptions`オブジェクトにパースされ、
  ブロックテンプレートの作成または更新時にマージされます。予約ブロックウェイトが最大ブロックウェイトを超えるなどの無効な組み合わせは、
  有効な範囲値に暗黙的に調整されるのではなく、拒否されるようになりました。

- [Bitcoin Core #34917][]では、ウォレットトランザクションRPCである`listtransactions`、`listsinceblock`、
  `gettransaction`において、非推奨の`bip125-replaceable`フィールドが返されなくなります。ただし、
  ユーザーは`-deprecatedrpc=bip125`オプションを使ってこのフィールドを引き続き要求できます。このPRではまた、
  起動オプション`-walletrbf`も非推奨となり、警告が表示されるようになりました。このオプションは次期リリースでの削除が予定されています。
  [RBF][topic rbf]関連フィールドのこれまでの削除については、[ニュースレター #403][news403 rbf]をご覧ください。

- [Bitcoin Core #35017][]は、予期しない検証失敗の後に後続のトランザクションがmempoolに残ってしまうのを防ぐため、
  [パッケージ][topic package relay]トランザクションの送信プロセスを更新します。パッケージの送信中、
  トランザクションは順次処理されるため、後続のトランザクションは、既にmempoolに追加された先行トランザクションを使用できるようになっています。
  これまでは、あるトランザクションが後段の検証チェック(コンセンサススクリプトチェックなど)に失敗した場合、
  Bitcoin Coreはそのトランザクションのみを削除していました。今後は、パッケージ内の後続のすべてのトランザクションも削除し、
  親が削除された後に子がmempoolに残ることを防ぎます。

- [BIPs #1944][]は、`OP_TWEAKADD`(調整済みx-only公開鍵を計算するための[Tapscript][topic tapscript] opcode)のソフトフォーク案である
  [BIP449][]を追加します([ニュースレター #370][news370 tweak]参照)。32 byteのx-only公開鍵と
  32 byteのスカラー調整値が与えられると、このopcodeは`P + tG`のx-only鍵をプッシュします。
  これにより、スクリプトが鍵と調整値の関係を直接検証できるようになり、調整値開示スクリプト、
  署名順序の証明、[署名委任][topic signer delegation]プロトコルなどの構築が可能になります。

- [BIPs #2108][]は、[BIP450][]（Formosa）を追加します。これは、
  [BIP39][]互換のウォレットエントロピーを物語形式のニーモニックフレーズとしてエンコードするためのドラフト仕様です。
  ランダムなBIP39ワードを使用する代わりに、Formosaはテーマで定義されたワードリストを使ってエントロピーをエンコードし、
  短く構造化された文を生成します。これらの物語は元のエントロピーにデコードして戻すことができ、
  シード導出の前に標準的なBIP39ニーモニックに変換できるため、BIP39との互換性が保たれます。

- [Eclair #3192][]は、[ニュースレター #404][news404 0fc]で取り上げた仕様に従って、
  [ゼロ手数料コミットメント][topic v3 commitments](0FC)チャネルの実験的サポートを追加します。
  この機能はデフォルトで無効になっており、`eclair.features.zero_fee_commitments = optional`で有効にできます。

- [LDK #4584][]は、[BOLT12][topic offers]のブラインドメッセージおよびペイメントパスのコンテキストに
  `payment_metadata`マップを追加します。これは、受取人側のメタデータを[ブラインドパス][topic rv routing]を通じて送信し、
  支払いが受領された際にそれを復元するための仕組みを追加するもので、[BOLT11][]の`payment_metadata`に似ています。
  メタデータ付きのオファーの作成は現時点ではサポートされていません。
  メタデータは数値キーからバイト配列へのマップとして格納され、同じ支払いに複数の独立したデータを付加できます。

- [LDK #4628][]は、[ニュースレター #405][news405 metadata]で取り上げたメタデータコミットメントに基づき、
  インバウンド支払いの作成時に[BOLT11][]の`payment_metadata`の暗号化を開始します。
  支払いの検証後、LDKはメタデータを復号し、アプリケーションが暗号化を自前で実装したり
  メタデータを支払人に公開したりすることなく、インボイスのメタデータにアクセスできるようにします。

- [LND #10552][]は、[Neutrino][topic compact block filters]をバックエンドとするLNDノード向けに、
  高速な初期同期機能を追加します。これにより、通常のP2P同期を再開する前に、
  ローカルファイルまたは HTTP(S) ソースから事前に構築されたBitcoinブロックヘッダーとコンパクトフィルターをインポートできます。
  新しい`neutrino.blockheaderssource`と`neutrino.filterheaderssource`オプションは一緒に設定する必要があります。
  インポートされたヘッダーはローカルで検証され、その後Neutrinoはインポートされた先端以降のヘッダーをネットワークピアから取得します。

- [LND #10820][]は、Taprootの[チャネルアナウンス][topic channel announcements]がまだサポートされていないため、
  パブリックチャネルを開く際にLNDが暗黙的に[Simple Taproot Channel][topic simple taproot channels]を選択するのを防止します。
  これまでは、両方のピアがこのタイプのチャネルのサポートを通知している場合、LNDがそれを選択した上で開設を拒否することがありました。
  今後は、Simple Taproot Channelは明示的に要求される必要があり、一方で暗黙的なネゴシエーションでは、
  legacy、static remote keyまたは[アンカー][topic anchor outputs]チャネルタイプを引き続き選択できます。
  このPRはまた、`lncli openchannel --channel_type=taproot`を更新して、本番用のSimple Taproot Channelタイプを選択するようにしています。

{% include snippets/recap-ad.md when="2026-06-02 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33966,34917,35017,3192,4584,4628,10552,10820,2108,1944" %}
[cln dos delving]: https://delvingbitcoin.org/t/vulnerability-disclosure-assertion-dos-in-core-lightning/2507
[news402 cln2604]: /ja/newsletters/2026/04/24/#core-lightning-26-04
[coredev 2026-05]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05
[coredev swiftsync]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/swiftsync
[coredev post-cluster]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/post-cluster-mempool
[coredev erlay]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/erlay-redesign
[coredev pkg relay]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/package-relay
[coredev silent payments]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/silent-payments
[coredev tcp holepunch]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/tcp-holepunch
[news406 tcp holepunch]: /ja/newsletters/2026/05/22/#nat-bitcoin-tcp
[coredev private broadcast]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/private-broadcast
[coredev modern crypto]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/modern-crypto-library
[coredev mutation testing]: https://btctranscripts.com/bitcoin-core-dev-tech/2026-05/mutation-testing
[Eclair v0.14.0]: https://github.com/ACINQ/eclair/releases/tag/v0.14.0
[Core Lightning 26.06rc2]: https://github.com/ElementsProject/lightning/releases/tag/v26.06rc2
[news310 mining]: /ja/newsletters/2024/07/05/#bitcoin-core-30200
[news323 mining]: /ja/newsletters/2024/10/04/#bitcoin-core-30510
[news403 rbf]: /ja/newsletters/2026/05/01/#bitcoin-core-34911
[news404 0fc]: /ja/newsletters/2026/05/08/#bolts-1228
[news405 metadata]: /ja/newsletters/2026/05/15/#ldk-4528
[news370 tweak]: /ja/newsletters/2025/09/05/#op-tweakadd-bip
