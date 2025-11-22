---
title: 'Bitcoin Optech Newsletter #381'
permalink: /ja/newsletters/2025/11/21/
name: 2025-11-21-newsletter-ja
slug: 2025-11-21-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、ブロックの伝播時間がマイナーの収益に及ぼす影響の分析と、
複数の当事者が資金を共有するプロトコルを解決するための新しいアプローチを取り上げています。
また、サービスとクライアントソフトウェアの最近の更新や、
人気のBitcoinインフラストラクチャソフトウェアの最近のマージの概要など、
恒例のセクションも含まれています。

## ニュース

- **<!--modeling-stale-rates-by-propagation-delay-and-mining-centralization-->伝播遅延とマイニングの集中化によるステイル率のモデル化:**
  Antoine Poinsotは、ステイル（古くなった）ブロック率のモデル化と、
  ブロック伝播時間がハッシュレートの関数としてマイナーの収益にどのような影響を与えるかについて
  Delving Bitcoinに[投稿しました][antoine delving]。彼は、すべてのマイナーが現実的に（デフォルトのBitcoin Coreノードで）
  行動するベースケースシナリオを設定しました：
  新しいブロックを受信したら、すぐにその上でマイニングを開始し、それを公開します。
  これにより、伝播時間がゼロの場合、ハッシュレートのシェアに比例した収益が得られます。

  均一なブロックの伝播を想定した彼のモデルでは、ブロックが古くなる2つの状況がありました。
  1. 別のマイナーが我々よりも**先に**ブロックを発見しました。他のすべてのマイナーは、
     競合するマイナーのブロックを先に受信し、その上でマイニングを開始しました。
     これらのマイナーのいずれかが、受信したブロックに基づいて２つめのブロックを見つけることができます。

  2. 別のマイナーが我々よりも**後に**ブロックを発見しました。そのマイナーはすぐにその上でマイニングを開始します。
     次のブロックも同じマイナーによって発見されました。

  Poinsotは、これらの状況のうち、最初の状況でブロックが古くなる可能性が高いことを指摘しています。
  これは、マイナーは自分のブロックを公開することよりも、他者のブロックをより早く受け取ることを重視している可能性を示唆しています。
  また、2つめの状況の確率は、マイナーの集中化と共に大幅に増加すると示唆しています。
  両方の状況で、マイナーのハッシュレートが増加するにつれて確率が増加することは分かっていますが、
  Poinsotはどの程度増加するかを計算したいと考えました。

  このために、彼は以下の2つのモデルを作成しました。

  ここで、**h**はネットワークハッシュレートのシェア、**s**はネットワークの残りが先に競合ブロックを発見するまでの秒数、
  **H**はネットワーク上のハッシュレートの分布を表すセットです。

  状況1のモデル:
  ![Illustration of P(another miner found a block before)](/img/posts/2025-11-stale-rates1.png)

  状況2のモデル:
  ![Illustration of P(another miner found a block after)](/img/posts/2025-11-stale-rates2.png)

  彼はさらに、ハッシュレートの分布のセットが与えられた場合に、
  マイナーのブロックが古くなる確率を伝播時間の関数としてグラフに示しました。
  グラフは、伝播時間が長いほど、規模の大きいマイナーがより多くの利益を得ることを示しています。

  たとえば、5EH/sのマイニングオペレーションでは、9,100万ドルの収益が見込まれ、
  ブロックの伝播に10秒かかった場合、収益は10万ドル増加します。9,100万ドルは収益であって利益ではないことに留意してください。
  したがって、10万ドルの収益増加は、マイナーの純利益という点でより大きな要因となります。

  グラフの下には、グラフの作成方法と、グラフ作成に使用したモデルの結果を裏付ける
  [シミュレーション][block prop simulation]のリンクが記載されています。

- **<!--private-key-handover-for-collaborative-closure-->共同クローズのための秘密鍵のハンドオーバー**:
  ZmnSCPxjは、秘密鍵のハンドオーバーについてDelving Bitcoinに[投稿しました][privkeyhand post]。
  これは、以前2人の当事者によって所有されていた資金を単一の当事者に払い戻す必要がある場合に、プロトコルが実装できる最適化です。
  この機能強化を最も効率的に動作させるためには、[Taproot][topic taproot]と[MuSig2][topic musig]のサポートが必要です。

  このようなプロトコルの一例として、[HTLC][topic htlc]が挙げられます。
  HTLCでは、プリイメージが明らかになった場合、一方の当事者が他方の当事者に支払いをし、
  両当事者の署名が必要な返金トランザクションを作成します。秘密鍵のハンドオーバーでは、
  プリイメージが明かされた後、エンティティは単純に一時的な秘密鍵を相手に引き渡すことができ、
  これにより受信者は資金への完全かつ一方的なアクセスを得ることができます。

  秘密鍵のハンドオーバーは以下のように機能します:

  - HTLCをセットアップする際、アリスとボブはそれぞれ一時的な公開鍵と永続的な公開鍵を交換します。
  - HTLC Taprootアウトプットのkeypath支払いのブランチは、アリスとボブの一時的な公開鍵のMuSig2として計算されます。
  - プロトコル操作の終了時に、ボブはアリスにプリイメージを提供し、アリスは引き換えに一時的な秘密鍵を渡します。
  - ボブは、MuSig2の合計となる結合秘密鍵を導出でき、資金を完全に管理できるようになります。

  この最適化にはいくつかの具体的なメリットがあります。まず、オンチェーン手数料が急上昇した場合、
  ボブは相手の協力なしにトランザクションを[RBF][topic rbf]できます。
  この機能は、簡単な概念実証でRBFを実装する必要がなくなるため、プロトコル開発者にとって特に有用です。
  2つめに、受信者は資金を請求するトランザクションを他の操作とバッチ処理できます。

  秘密鍵のハンドオーバーは、残りの資金のすべてを単一の受益者に一括で送信することを要求するプロトコルに限定されます。
  したがって、ライトニングチャネルの[スプライシング][topic splicing]や協調クローズはこれから恩恵を受けることはありません。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Arkadeのリリース:**
  [Arkade][ark labs blog]は[Arkプロトコル][topic ark]の実装であり、
  複数のプログラミング言語用SDK、ウォレット、BTCPayServerプラグイン、その他の機能が含まれています。

- **Mempoolモニタリングモバイルアプリケーション:**
  [Mempal][mempal gh] Androidアプリケーションは、セルフホスト型のmempoolサーバーからデータを取得し、
  Bitcoinネットワークに関するさまざまなメトリックとアラートを提供します。

- **Webベースのポリシーおよびminiscript IDE:**
  [Miniscript Studio][miniscript studio site]は、[miniscript][topic miniscript]および
  ポリシー言語を操作するためのインターフェースを提供します。
  機能については[ブログ記事][miniscript studio blog]で解説されており、
  [ソース][miniscript studio gh]も公開されています。

- **Phoenix WalletがTaprootチャネルをサポート:**
  Phoenix Walletは[Taproot][topic taproot]チャネル、既存チャネルの移行ワークフロー、
  マルチウォレット機能のサポートを[追加しました][phoenix post]。

- **Nunchuk 2.0のリリース:**
  [Nunchuk 2.0][nunchuk blog]は、マルチシグ、[タイムロック][topic timelocks]、
  miniscriptを使用したウォレットの設定をサポートします。また、デグレードマルチシグ機能も含まれています。

- **LNゴシップトラフィック分析ツールの発表:**
  [Gossip Observer][gossip observer gh]は、複数のノードからライトニングネットワークのゴシップメッセージを収集し、
  要約メトリクスを提供します。この結果は、ライトニング用の[minisketch][topic minisketch]のようなセット調整プロトコルに活用される可能性があります。
  [Delving Bitcoinのトピック][gossip observer delving]では、このアプローチに関する議論が行われています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #33745][]は、新しいマイニングプロセス間通信（IPC）`submitSolution()`
  インターフェース（[ニュースレター #325][news325 ipc]参照）を介して
  外部の[StratumV2][topic pooled mining]クライアントによって提出されたブロックのwitnessコミットメントが再検証されることを保証します。
  これまでは、Bitcoin Coreは元のテンプレート構築時にのみこれをチェックしていたため、
  無効またはwitnessコミットメントが欠落したブロックがベストチェーンの先端として受け入れられる可能性がありました。

- [Core Lightning #8537][]は、[MPP][topic multipath payments]を使用して非公開ノードに最初に支払いを試みる際、
  `xpay`の`maxparts`制限（[ニュースレター #379][news379 parts]参照）を6に設定します。これは、
  [JITチャネル][topic jit channels]の一種であるオンザフライ・ファンディング（[ニュースレター #323][news323 fly]参照）における
  Phoenixベースノードの6 [HTLC][topic htlc]受信制限に準拠しています。この制限値未満でルーティングが失敗した場合、
  `xpay`は制限を解除して再試行します。

- [Core Lightning #8608][]は、既存のチャネルバイアスに加えて`askrene`（[ニュースレター #316][news316 askrene]参照）に
  ノードレベルのバイアスを導入します。指定されたノードのすべての送信チャネルと受信チャネルを優先または非優先にするために
  新しく`askrene-bias-node` RPCコマンドが追加されました。バイアスには`timestamp`フィールドが追加され、
  一定期間後に有効期限が切れます。

- [Core Lightning #8646][]は、[BOLTs #1160][]および[BOLTs #1289][]で提案されている仕様変更に合わせて、
  [スプライシング][topic splicing]チャネルの再接続ロジックを更新します。具体的には、
  `channel_reestablish` TLVを拡張することで、ピアがスプライス状態を確実に同期し、
  再送信が必要な情報を通信できるようにします。この更新はスプライシングチャネルにとって互換性のない変更であるため、
  中断を回避するには両側で同時にアップグレードする必要があります。LDKにおける同様の変更は、
  [ニュースレター #374][news374 ldk]をご覧ください。

- [Core Lightning #8569][]は、[BLIP52][]（LSPS2）で規定されている[JITチャネル][topic jit channels]を、
  `lsp-trusts-client`モードで[MPP][topic multipath payments]をサポートせずに試験的にサポートします。
  この機能は、`experimental-lsps-client`および`experimental-lsps2-service`オプションの背後で制御されており、
  JITチャネルの完全なサポートに向けた第一歩となります。

- [Core Lightning #8558][]は、ピアの接続、切断、失敗、ping遅延の履歴を表示する`listnetworkevents`
  RPCコマンドを追加します。また、ネットワークイベントログの保存期間（デフォルト30日）を制御する
  `autoclean-networkevents-age`設定オプションも導入されました。

- [LDK #4126][]では、[ブラインドペイメントパス][topic rv routing]における`ReceiveAuthKey`
  ベースの認証検証が導入され、従来のホップ毎のHMAC/nonceスキーム（[ニュースレター #335][news335 hmac]参照）が置き換えられました。
  これは、ブラインドメッセージパス用に`ReceiveAuthKey`を追加した[LDK #3917][]を基盤としています。
  ホップごとのデータを削減することでペイロードが削減され、将来のPRでダミーメッセージホップと同様に
  ダミーペイメントホップ（[ニュースレター #370][news370 dummy]参照）が使用できるようになります。

- [LDK #4208][]は、ウェイトの推定を更新し、DERエンコードされた署名を常に72 byteと想定するようにしました。
  以前は、一部で72 byteを使用し、他の部分では73 byteを使用していました。73 byteの署名は非標準であり、
  LDKはそれを生成することはありません。Eclairの関連する変更については、
  [ニュースレター #379][news379 sign]をご覧ください。

- [LND #9432][]は、新しいグローバル設定オプション`upfront-shutdown-address`を追加しました。
  これは、特定のチャネルを開設または受け入れる際にオーバーライドされない限り、
  協調チャネルクローズ時のデフォルトのBitcoinアドレスを指定します。これは、[BOLT2][]で指定された
  アップフロント・シャットダウン機能に基づいています。LNDの実装に関する以前の記事については、
  [ニュースレター #76][news76 upfront]をご覧ください。

- [BOLTs #1284][]は、BOLT11を更新し、インボイスに`n`フィールドが存在する場合、署名は正規化されたLow-S形式でなければならず、
  存在しない場合は、公開鍵の復元でHigh-SとLow-Sのどちらも受け入れることができることを明確にしました。
  この動作を実装するLDKとEclairの最近の変更については、ニュースレター[#371][news371 eclair]および
  [#373][news373 ldk]をご覧ください。

- [BOLTs #1044][]は、オプションの[失敗の帰属][topic attributable failures]機能を定義しています。
  この機能は失敗のメッセージに帰属データを追加することで、ホップが送信したメッセージにコミットできるようにします。
  ノードが失敗のメッセージを破損した場合、送信者は後でそのノードを特定し、ペナルティを課すことができます。
  この仕組みとLDKおよびEclairの実装の詳細については、ニュースレター[#224][news224 fail]、
  [#349][news349 fail]および[#356][news356 fail]をご覧ください。

{% include snippets/recap-ad.md when="2025-11-25 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33745,8537,8608,8646,1160,1289,8569,8558,4126,3917,4208,9432,1284,1044" %}
[antoine delving]: https://delvingbitcoin.org/t/propagation-delay-and-mining-centralization-modeling-stale-rates/2110
[block prop simulation]: https://github.com/darosior/miningsimulation
[privkeyhand post]: https://delvingbitcoin.org/t/private-key-handover/2098
[news325 ipc]: /ja/newsletters/2024/10/18/#bitcoin-core-30955
[news379 parts]: /ja/newsletters/2025/11/07/#core-lightning-8636
[news323 fly]: /ja/newsletters/2024/10/04/#eclair-2861
[news316 askrene]: /ja/newsletters/2024/08/16/#core-lightning-7517
[news374 ldk]: /ja/newsletters/2025/10/03/#ldk-4098
[news335 hmac]: /ja/newsletters/2025/01/03/#ldk-3435
[news370 dummy]: /ja/newsletters/2025/09/05/#ldk-3726
[news379 sign]: /ja/newsletters/2025/11/07/#eclair-3210
[news76 upfront]: /ja/newsletters/2019/12/11/#lnd-3655
[news371 eclair]: /ja/newsletters/2025/09/12/#eclair-3163
[news373 ldk]: /ja/newsletters/2025/09/26/#ldk-4064
[news224 fail]: /ja/newsletters/2022/11/02/#ln
[news349 fail]: /ja/newsletters/2025/04/11/#ldk-2256
[news356 fail]: /ja/newsletters/2025/05/30/#eclair-3065
[ark labs blog]: https://blog.arklabs.xyz/press-start-arkade-goes-live/
[mempal gh]: https://github.com/aeonBTC/Mempal
[miniscript studio gh]: https://github.com/adyshimony/miniscript-studio
[miniscript studio blog]: https://adys.dev/blog/miniscript-studio-intro
[miniscript studio site]: https://adys.dev/miniscript
[phoenix post]: https://x.com/PhoenixWallet/status/1983524047712391445
[nunchuk blog]: https://nunchuk.io/blog/autonomous-inheritance
[gossip observer gh]: https://github.com/jharveyb/gossip_observer
[gossip observer delving]: https://delvingbitcoin.org/t/gossip-observer-new-project-to-monitor-the-lightning-p2p-network/2105
