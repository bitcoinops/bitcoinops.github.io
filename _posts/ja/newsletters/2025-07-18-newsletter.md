---
title: 'Bitcoin Optech Newsletter #363'
permalink: /ja/newsletters/2025/07/18/
name: 2025-07-18-newsletter-ja
slug: 2025-07-18-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、サービスとクライアントの更新の概要、新しいリリースとリリース候補の発表、
人気のBitcoinインフラストラクチャソフトウェアの注目すべき更新など、恒例のセクションを掲載しています。

## ニュース

_今週は、どの[情報源][sources]からも重要なニュースは見つかりませんでした。_

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Floresta v0.8.0リリース:**
  [Utreexo][topic utreexo]ノードの[Floresta v0.8.0][floresta v0.8.0]リリースでは、
  [バージョン2 P2Pトランスポート(BIP324)][topic v2 p2p transport]、
  [testnet4][topic testnet]のサポートや、メトリクスとモニタリングの機能強化、
  その他多くの機能追加とバグ修正が行われました。

- **RGB v0.12を発表:**
  RGB v0.12の[ブログ記事][rgb blog]では、Bitcoinのtestnetとmainnetで、
  [クライアントサイド検証済み][topic client-side validation]のRGBスマートコントラクト用の
  RGBコンセンサスレイヤーがリリースされたことが発表されました。

- **FROST署名デバイスが利用可能に:**
  [Frostsnap][frostsnap website]署名デバイスは、オンチェーンでは単一の署名のみで済む、
  FROSTプロトコルを使用したk-of-nの[閾値署名][topic threshold signature]をサポートしました。

- **GeminiがTaprootをサポート:**
  Gemini ExchangeとGemini Custodyは、[Taproot][topic taproot]アドレスへの送金（引き出し）をサポートしました。

- **Electrum 4.6.0リリース:**
  [Electrum 4.6.0][electrum 4.6.0]では、
  検出にnostrを用いた[サブマリンスワップ][topic submarine swaps]がサポートされました。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [LND v0.19.2-beta][]は、この人気のLNノードのメンテナンスバージョンのリリースです。
  これには、「重要なバグ修正とパフォーマンスの改善が含まれています」

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #32604][]は、`LogPrintf`、`LogInfo`、`LogWarning`、`LogError`などの
  ディスクへの無条件ログ出力をレート制限し、各ソースロケーションに1時間あたり1MBのクォータを設定することで、
  ディスク容量オーバーの攻撃を軽減します。ソースロケーションが抑制されている場合、
  すべてのログの行の先頭にアスタリスク(*)が付きます。コンソール出力や、
  明示的なカテゴリ引数を持つログ、`UpdateTip`初期ブロックダウンロード（IBD）メッセージはレート制限の対象外です。
  クォータがリセットされると、Coreはドロップされたbyte数を出力します。

- [Bitcoin Core #32618][]は、すべてのウォレットRPCから、`include_watchonly`およびその派生オプションと
  `iswatchonly`フィールドを削除します。これは[ディスクリプター][topic descriptors]ウォレットが
  監視専用のディスクリプターと支払いに使用可能なディスクリプターの混在をサポートしていないためです。
  これまでは、ユーザーは監視専用アドレスやスクリプトをレガシー支払いウォレットにインポートできましたが、
  レガシーウォレットは削除されました。

- [Bitcoin Core #31553][]は、`TxGraph::Trim()`関数を導入することで、
  [クラスターmempool][topic cluster mempool]プロジェクトにブロックの再編成処理機能を追加します。
  再編成によって以前承認されたトランザクションがmempoolに再導入され、
  結果として得られるクラスターがクラスター数もしくはウェイトポリシーの制限を超えると、
  `Trim()`は手数料率順で依存関係を考慮した基本的なリニアライゼーションを構築します。
  トランザクションの追加が制限を超える場合、そのトランザクションとそのすべての子孫は削除されます。

- [Core Lightning #7725][]は、軽量なJavaScriptログビューアを追加します。
  これはブラウザでCLNログファイルを読み込み、ユーザーがデーモン、タイプ、チャネルまたは正規表現で
  メッセージをフィルタリングできるようにします。このツールは、リポジトリメンテナンスのオーバーヘッドを最小限に抑えながら、
  開発者とノード実行者のデバッグ体験を向上させます。

- [Eclair #2716][]は、[HTLCエンドースメント][topic htlc endorsement]用に
  ローカルピアレピュテーションシステムを実装します。このシステムは、各着信ピアが獲得したルーティング手数料と、
  使用された流動性と[HTLC][topic htlc]スロットに基づいて獲得されるべき手数料を追跡します。
  支払いが成功するとスコアは満点になり、失敗するとスコアは下がり、
  設定された閾値を超えて保留中のHTLCには重いペナルティが課せられます。
  転送時に、ノードは現在のピアスコアを`update_add_htlc`エンドースメントTLV（ニュースレター
  [#315][news315 htlc]参照）に含めます。オペレーターは、
  レピュテーションの減衰（`half-life`）、スタック支払い閾値（`max-relay-duration`）、
  スタックHTLCのペナルティウェイト（`pending-multiplier`）を調整するか、
  設定でレビュテーションシステムを完全に無効にできます。このPRは主に、
  [チャネルジャミング攻撃][topic channel jamming attacks]の研究を改良するためのデータを収集し、
  まだペナルティは実装していません。

- [LDK #3628][]は、[非同期支払い][topic async payments]用のサーバーサイドロジックを実装し、
  LSPノードが頻繁にオフラインになる受取人に代わって[BOLT12][topic offers]静的インボイスを提供できるようにします。
  LSPノードは、受取人からの`ServeStaticInvoice`メッセージを受け入れ、提供された静的インボイスを保持し、
  [ブラインドパス][topic rv routing]を介してキャッシュされたインボイスを検索して返すことで支払人のインボイス要求に応答できます。

- [LDK #3890][]は、経路探索アルゴリズムでの経路の評価方法を変更し、
  総コストのみを考慮するのではなく、総コストをチャネル量制限（使用可能な容量のsatあたりのコスト）で割った値を考慮するようになりました。
  これにより、選択はより大容量の経路に偏り、過剰な[MPP][topic multipath payments]シャーディングが減り、
  結果として支払いの成功率が向上します。この変更により、小規模なチャネルに過度なペナルティが課せられますが、
  このトレードオフはこれまでの過剰なシャーディングよりも好ましいものです。

- [LND #10001][]では、運用環境で静止プロトコル（ニュースレター[#332][news332 quiescence]参照）が有効になり、
  チャネルが静止状態を維持できる最大期間を指定する新しい設定値`--htlcswitch.quiescencetimeout`が追加されました。
  この値により、[ダイナミックコミットメント][topic channel commitment upgrades]などの依存プロトコルが
  タイムアウト期間内に完了することが保証されます。デフォルト値は60秒、最小値は30秒です。

{% include snippets/recap-ad.md when="2025-07-22 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32604,32618,31553,7725,2716,3628,3890,10001" %}
[LND v0.19.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.2-beta
[sources]: /ja/internal/sources/
[floresta v0.8.0]: https://github.com/vinteumorg/Floresta/releases/tag/v0.8.0
[rgb blog]: https://rgb.tech/blog/release-v0-12-consensus/
[frostsnap website]: https://frostsnap.com/
[electrum 4.6.0]: https://github.com/spesmilo/electrum/releases/tag/4.6.0
[news315 htlc]: /ja/newsletters/2024/08/09/#eclair-2884
[news332 quiescence]: /ja/newsletters/2024/12/06/#lnd-8270