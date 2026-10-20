---
title: "Bitcoin Optech Newsletter #379"
permalink: /ja/newsletters/2025/11/07/
name: 2025-11-07-newsletter-ja
slug: 2025-11-07-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---

今週のニュースレターでは、OpenSSLとlibsecp256k1ライブラリのこれまでのパフォーマンス比較の分析を掲載しています。
また、コンセンサスの変更に関する議論や、新しいリリースとリリース候補の発表、
人気のBitcoinインフラストラクチャソフトウェアの注目すべき更新など、恒例のセクションも含まれています。

## ニュース

- **OpenSSLとlibsecp256k1におけるECDSA署名検証のパフォーマンス比較:** Sebastian Falbesonerは、
  OpenSSLとlibsecp256k1のECDSAの署名検証パフォーマンスの過去10年間の比較をDelving Bitcoinに[投稿しました][sebastion delving]。
  彼は、Bitcoin CoreがOpenSSLからlibsecp256k1に切り替えてから今年で10周年を迎えることに言及し、
  Bitcoin Coreが切り替えをしなかったらという仮定の状況を想像したいと考えました。

  移行当初から、libsecp256k1はOpenSSLより2.5〜5.5倍高速でした。とはいえ、
  OpenSSLは年々改善されている可能性があり、10年間の比較をテストする価値はありました。

  手法は、両方のライブラリの関数を使ってテスト可能な3つのステップ（圧縮公開鍵のパース、
  DERエンコードされた署名のパース、ECDSA署名の検証）で構成されています。疑似乱数鍵ペアのリストを使ってベンチマークを作成し、
  3台の異なるマシンでベンチマークを実行し、棒グラフを作成しました。このグラフは、
  libsecp256k1が長年に渡り大幅に改善されてきたことを示しています。つまり、
  bc-0.19からbc-0.20にかけて約28%、bc-0.20からbc-22.0にかけて約30%の改善が見られましたが、OpenSSLは現状維持でした。

  Sebastianは、Bitcoinエコシステム以外では、secp256k1曲線はそれほと重要ではなく、
  改善に時間を費やし労力をはらうような第一級の存在とは見なされていないと結論付けています。
  彼はまた、結果を再現し、手法に関する問題や、自身の結果と違いを発見した場合はぜひ報告して欲しいと述べています。
  [ソースコード][libsecp benchmark code]はGithubで公開されています。

## コンセンサスの変更

_Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめた月次セクション_

- **<!--multiple-discussions-about-restricting-data-->データ制限に関する複数の議論**:
  複数の会話で、コンセンサスにおけるさまざまな分野の制限を変更するためのアイディアが検討されました。

  - *scriptPubkeyを520 byteに制限制限*:
    PortlandHODLは、コンセンサスでscriptPubkeyのサイズを520 byteに制限する提案をBitcoin-Devメーリングリストに[投稿しました][ph 520spk post]。
    BIP54のコンセンサスクリーンアップと同様に、これはレガシースクリプトのコーナーケースにおける最大ブロック検証コストを制限します。
    また、`OP_RETURN`を使って大きな連続データセグメントを作成することも不可能になります。
    このアイディアに対するフィードバックには、この変更により、最大ブロック検証コストを制限するBIP54と比較して、
    古い署名済みプロトコルの没収対象領域が拡大すること、そして特定の[ソフトフォークアップグレード][topic soft fork activation]パス（特に
    [量子耐性][topic quantum resistance]に関するもの）を閉ざされることへの反発が含まれていました。

  - *<!--temporary-soft-fork-to-reduce-data-->データを削減するための一時的なソフトフォーク*: Dathon Ohmは、
    Bitcoinトランザクションをデータのエンコードに使用する方法を一時的に制限する提案を[投稿し][do post]、
    BIPの[プルリクエスト][BIPs #2017]を作成しました。このソフトフォークは[一時的なもの][topic transitory soft forks]と説明されていますが、
    メーリングリストやプルリクエストの議論では、提案された変更による大規模な没収対象領域について批判的な意見が出ています。
    さらに、一時的なソフトフォークは可能ではあるものの、その期限切れをめぐる論争は、ハードフォークへと発展させる可能性を秘めています。
    これに対しPeter Toddは、提案されたBIPのテキストを、提案されたコンセンサスルールの下で有効なBitcoinトランザクションにエンコードすることで、
    このアプローチの限界を[示しました][pt post tx]。

- **<!--post-quantum-signature-aggregation-->ポスト量子署名の集約**:
  Tadge Dryjaは、ロックスクリプトが同じトランザクション内で使用される特定のUTXOにコミットできるようにする
  `OP_CHECKINPUTVERIFY`（`OP_CIV`）をBitcoin-Devメーリングリストに[投稿しました][td post civ]。
  これにより、関連するUTXOのグループを単一の承認署名で使用できるようになり、
  [インプットをまたいだ署名の集約][topic cisa]と同様の効果があります。
  このアプローチは、個別のECDSAや[BIP340][]署名よりもコストがかかりますが、数KBのポスト量子署名では、
  トランザクションの仮想バイトを大幅に節約できます。`OP_CIV`は、
  [BitVM][topic acc]のようなプロトコルにおける汎用的な兄弟インプットチェックにも使えます。
  `OP_CHECKCONTRACTVERIFY`などの他の提案も、兄弟`scriptPubKeys`にコミットすることで同様の署名共有スキームを実現できますが、
  異なる（おそらくより悪くなる）トレードオフがあります。

- **Bitcoin ScriptにおけるネイティブSTARK証明検証**: Abdelhamid Bakhtaは、
  Bitcoin ScriptでSTARK証明の特定のバージョンの検証を可能にする新しい[Tapscript][topic tapscript] opcode
  `OP_STARK_VERIFY`の詳細な提案をDalving Bitcoinに[投稿しました][abdel delving]。
  これにより、Bitcoinに任意の計算の証明を埋め込むことが可能になります。
  提案されたopcodeは、証明をBitcoin固有のデータにバインドしないため、
  証明は単にそれ自体が埋め込む計算の検証済みの証明に過ぎません。これらの証明は、
  他の署名方法を使って特定のBitcoinトランザクションにリンクできます。
  この投稿では、[Validity Rollup][news222 validity rollups]などのさまざまなユースケースについて議論しています。

- **BIP54の実装とTest Vector**: Antoine Poinsotは、[BIP54][]の
  [コンセンサスクリーンアップ][topic consensus cleanup]（詳細は[ニュースレター #348][news348 bip54]参照）の作業の最新情報を
  Bitcoin-Devメーリングリストに[投稿しました][ap bip54 post]。
  彼は[Bitcoin Inquisition #99][binq bip54 pr]を作成し、
  BIP54のコンセンサスルールを実装しました。このPRには、4つの緩和策それぞれの単体テストが含まれており、
  提案のTest Vectorを生成するのに使用できます。さらに、sigop計算ロジックのファズハーネスと、
  過去の違反を含む現実的な状況における緩和策の動作を模倣する機能テストが含まれています。
  さらに、タイムスタンプやコインベース制限など、mainnetのブロックを必要とする緩和策のTest Vectorに必要な
  完全なヘッダーチェーンを生成するための[カスタムマイナー][bip54 miner]も開発されました。
  最後に、生成されたTest VectorをBIP54に追加するために、[BIPs #2015][]を作成しました。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Core Lightning 25.09.2][]は、この人気のLNノードの現在のメジャーバージョンのメンテナンスリリースで、
  `bookkeeper`と`xpay`に関連するいくつかのバグ修正が含まれています。その一部は、コードとドキュメントの変更セクションにまとめられています。

- [LND 0.20.0-beta.rc3][]は、この人気のLNノードのリリース候補です。
  テストによって恩恵を受ける改善点の1つは、ウォレット再スキャンが早期に行われる問題の修正です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #31645][]は、デフォルトの`dbbatchsize`設定を16MBから32MBに増やしました。
  このオプションは、IBDまたは[assumeUTXO][topic assumeutxo]スナップショットの後に、
  メモリ（`dbcache`によって設定）にキャッシュされたUTXOセットをディスクにフラッシュする際に使用するバッチサイズを決定します。
  このアップデートは主にHDDとローエンドシステムにメリットをもたらします。
  たとえば、著者はRaspberry Piで`dbache`を500に設定した場合、フラッシュ時間が30%短縮されたと報告しています。
  ユーザーは必要に応じてデフォルト設定を上書きできます。

- [Core Lightning #8636][]は、期限に達すると`getroutes`が失敗する`askrene-timeout`設定（デフォルトは10秒）を追加します。
  `maxparts`が低い値に設定されている場合、`askrene`（[ニュースレター #316][news316 askrene]参照）は
  キャパシティ不足の経路で再試行ループに入る可能性があります。このPRは、そのようなシナリオでボトルネックとなる経路を無効にし、
  処理の進行を確実にします。

- [Core Lightning #8639][]は、オペレーティングシステムに依存する`argv`（コマンドライン引数）のサイズ制限を回避するために、
  `bitcoin-cli`とのインターフェース時に`-stdin`を使用するように`bcli`を更新しました。
  この更新により、ユーザーが大規模なトランザクション（たとえば、
  700個のインプットを持つ[PSBT][topic psbt]など）を作成できない問題が解決されました。
  大規模なトランザクションのパフォーマンスに関するその他の改善も行われています。

- [Core Lightning #8635][]は、支払いステータス管理を更新し、
  `xpay`（[ニュースレター #330][news330 xpay]参照）または`injectpaymentonion`を使用する際、
  送信[HTLC][topic htlc]が作成された後にのみ支払いパーツが保留中としてマークされるようになりました。
  これまでは、支払いのパーツは最初に保留中としてマークされ、その後HTLCの作成に失敗すると、
  `listpays`や`listsendpays`でアイテムが永久に保留中のままになる可能性がありました。

- [Eclair #3209][]は、ルーティング手数料率の値が負にならないようにするためのチェックを追加しました。
  これまでは、負の値が設定されるとチャネルが強制的に閉鎖されていました。

- [Eclair #3206][]は、[Liquidity Ads][topic liquidity advertisements]の購入が署名開始後、
  署名交換中に中止された場合、保留中の受信[HTLC][topic htlc]を直ちに失敗させます。
  これまでは、Eclairはこのエッジケースを処理できず、HTLCの有効期限直前に失敗させ、
  送信者の資金を不必要に拘束していました。この変更は、
  悪意のないモバイルウォレットが接続を切断して中止するケースを想定して行われました。

- [Eclair #3210][]は、[BOLT3][]の仕様およびLDKなどの他の実装に準拠し、
  73 byteのDERエンコードされた署名（[ニュースレター #6][news6 der]参照）を想定するようウェイトの推定を更新しました。
  これにより、このサイズを想定するピアが、手数料不足を理由にEclairからの`interactive-tx`の試行を拒否することがなくなります。
  Eclairはこのような非標準の署名を生成することはありません。

- [LDK #4140][]は、ノードが送信[非同期支払い][topic async payments]のために再起動する際に発生する、
  早期の強制閉鎖を修正しました。これまでは、頻繁にオフラインになるノードがオンラインに戻り、
  送信側の[HTLC][topic htlc]が[CLTV有効期限][topic cltv expiry delta]を
  `LATENCY_GRACE_PERIOD_BLOCKS`（3ブロック）過ぎていた場合、
  LDKはノードが再接続してピアがHTLCを失敗させる前に、直ちに強制閉鎖していました。
  このシナリオでは、ノードは受信側のHTLCを要求しようと競合していないため、
  LDKはHTLCのCLTV有効期限が切れた後、強制閉鎖する前に、4,032ブロックの猶予期間を追加します。

- [LDK #4168][]は、ピアのメッセージ読み取りの一時停止を通知する`read_event`フラグを削除します。
  これにより、`send_data`が一時停止/再開シグナルの唯一の信頼できる情報源になります。
  これにより、`send_data`が既に読み取りを再開した後に、
  ノードが`read_event`から遅れて一時停止通知を受信する可能性がある競合状態が修正されます。
  遅れた一時停止により、ノードがそのピアに再度メッセージを送信するまで、読み取りが無期限に無効になります。

- [Rust Bitcoin #5116][]は、トランザクションリストに隣接する重複が含まれている場合、
  `compute_merkle_root`と`compute_witness_root`のレスポンスで`None`を返すよう更新します。
  これにより、重複トランザクションを含む無効なブロックが有効なブロックと同じマークルルート（およびブロックハッシュ）を共有し、
  Rust Bitcoinが両方を混同して拒否してしまうという、
  変異型の[マークルルート脆弱性][topic merkle tree vulnerabilities]（CVE 2012-2459）を回避できます。
  この解決策はBitcoin Coreの解決策に着想を得ています。

- [BTCPay Server #6922][]では、`Subscriptions`が導入され
  マーチャントは定期支払いプランや支払い方法の設定、チェックアウトプロセスを介したユーザーの登録が可能になります。
  システムは各加入者のクレジット残高を追跡し、各請求期間に差し引かれます。加入者用のポータルでは、
  ユーザーがプランのアップグレードまたはダウングレード、クレジットの参照、履歴、領収書の確認ができます。
  マーチャントは、支払期日が近づくとユーザーに通知するメールアラートを設定できます。
  これにより自動課金が導入されるわけではありませんが、計画されている[Nostr Wallet Connect (NWC)][news290 nwc]との統合により、
  特定のウォレットではそれが実現する可能性があります。

{% include snippets/recap-ad.md when="2025-11-11 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2015,2017,31645,8636,8639,8635,3209,3206,3210,4140,4168,5116,6922" %}
[sebastion delving]: https://delvingbitcoin.org/t/comparing-the-performance-of-ecdsa-signature-validation-in-openssl-vs-libsecp256k1-over-the-last-decade/2087
[libsecp benchmark code]: https://github.com/theStack/secp256k1-plugbench
[ph 520spk post]: https://gnusha.org/pi/bitcoindev/6f6b570f-7f9d-40c0-a771-378eb2c0c701n@googlegroups.com/
[do post]: https://gnusha.org/pi/bitcoindev/AWiF9dIo9yjUF9RAs_NLwYdGK11BF8C8oEArR6Cys-rbcZ8_qs3RoJURqK3CqwCCWM_zwGFn5n3RECW_j5hGS01ntGzPLptqcOyOejunYsU=@proton.me/
[pt post tx]: https://gnusha.org/pi/bitcoindev/aP6gYSnte7J86g0p@petertodd.org/
[td post civ]: https://gnusha.org/pi/bitcoindev/05195086-ee52-472c-962d-0df2e0b9dca2n@googlegroups.com/
[abdel delving]: https://delvingbitcoin.org/t/proposal-op-stark-verify-native-stark-proof-verification-in-bitcoin-script/2056
[news222 validity rollups]: /ja/newsletters/2022/10/19/#validity-rollups
[ap bip54 post]: https://groups.google.com/g/bitcoindev/c/1XEtmIS_XRc
[news348 bip54]: /ja/newsletters/2025/04/04/#draft-bip-published-for-consensus-cleanup-bip
[binq bip54 pr]: https://github.com/bitcoin-inquisition/bitcoin/pull/99
[bip54 miner]: https://github.com/darosior/bitcoin/commits/bip54_miner/
[LND 0.20.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta.rc3
[Core Lightning 25.09.2]: https://github.com/ElementsProject/lightning/releases/tag/v25.09.2
[news316 askrene]: /ja/newsletters/2024/08/16/#core-lightning-7517
[news330 xpay]: /ja/newsletters/2024/11/22/#core-lightning-7799
[news6 der]: /en/newsletters/2018/07/31/#the-maximum-size-of-a-bitcoin-der-encoded-signature-is
[news290 nwc]: /ja/newsletters/2024/02/21/#nwc
