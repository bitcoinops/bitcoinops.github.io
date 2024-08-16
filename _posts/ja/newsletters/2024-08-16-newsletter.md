---
title: 'Bitcoin Optech Newsletter #316'
permalink: /ja/newsletters/2024/08/16/
name: 2024-08-16-newsletter-ja
slug: 2024-08-16-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、新しいtestnet4にとって特に重要な新しいタイムワープ攻撃と、
Onionメッセージのサービス拒否の懸念に対する緩和策の提案の議論、
LNの支払人がオプションで身元を証明できるようにする提案のフィードバックの依頼、
下流の開発者やインテグレーターに影響を与える可能性のあるBitcoin Coreのビルドシステムの大きな変更を掲載しています。
また、新しいリリースとリリース候補の発表や、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

<!-- Note: confirmed via email that "Zawy" is how this person would like be attributed.  -harding -->

- **testnet4の新しいタイムワープ脆弱性:** Mark "Murch" Erhardtは、
  開発者のZawyが[発見した][zawy comment][testnet4][topic testnet]の新しい難易度調整アルゴリズムを悪用した攻撃について
  Delving Bitcoinに[投稿しました][erhardt warp]。testnet4は、
  [タイムワープ攻撃][topic time warp]をブロックすることを目的とした、
  mainnet用の[コンセンサスクリーンアップ][topic consensus cleanup]ソフトフォークを適用しました。
  しかし、Zawyは、マイニングの難易度を通常の値の1/16に下げるという、
  新しいルールでも使用できるタイムワープに似た攻撃について説明しました。
  Erhardtは、難易度を最小値に下げることができるようにZawyの攻撃を拡張しました。
  以下では、関連するいくつかの攻撃を簡略化した形で説明します:

  Bitcoinのブロックは確率的に生成され、難易度は2,016ブロック毎に再調整するよう意図されており、
  ブロック間の平均時間を約10分に保ちます。以下の簡略化した図は、一定のブロック生成率で、
  5ブロック毎に再調整する場合（図が読みやすくなるよう2,016ブロックから減らしています）に、
  何が起こるかを示しています:

  ![一定のハッシュレートによる正直なマイニングの図（簡易版）](/img/posts/2024-time-warp/reg-blocks.png)

  ハッシュレートの50%強を持つ不正なマイナー（またはマイナーの集団）は、
  他の50%弱の正直なマイナーによって生成されたブロックを検閲できます。
  当然、最初は平均して20分毎に1つのブロックしか生成されません。
  このパターンで2,016個のブロックが生成されると、難易度は元の値の半分に調整され、
  メインチェーンに追加されるブロックの速度は平均して10分毎に1つに戻ります。:

  ![ネットワーク全体のハッシュレートの50%強を持つ攻撃者によるブロックの検閲の図（簡易版）](/img/posts/2024-time-warp/50p-attack.png)

  タイムワープ攻撃は、不正なマイナーがハッシュレートの大半を使用して、
  ほとんどのブロックのタイムスタンプに最小許容値を使用するよう強制する際に発生します。
  2,016ブロックの再調整期間の最後に、マイナーはブロックヘッダーの時間を現在の[実時間][wall time]に戻し、
  ブロックの生成に実際よりも長い時間かかったように見せかけ、その後の期間の難易度を下げます。

  <!-- TODO:harding can probably integrate the illustration below into
  the time warp topic page -->

  ![典型的なタイムワープ攻撃の図（簡易版）](/img/posts/2024-time-warp/classic-time-warp.png)

  testnet4に適用された[新しいルール][testnet4 rule]は、新しい再調整期間の最初のブロックのタイムスタンプが、
  前のブロック（前の期間の最後のブロック）よりかなり前にならないようにすることでこの問題を解決します。

  元のタイムワープ攻撃と同様に、Zawyの攻撃のErhardtによるバージョンでは、
  ほとんどのブロックのヘッダーの時間が最小限増加します。ただし、3つの再調整期間の内の2つで、
  期間の最後のブロックと後続の期間の最初のブロックの時間を前に進めます。
  これにより、各期間で許容されている最大値（現在の値の1/4）だけ難易度が下がります。
  ３つめの期間では、すべてのブロックに対して許容される最小時間と、
  後続の期間の最初のブロックを使用し、何度を最大値（4倍）だけ上げます。つまり、
  難易度は1/4減少し、さらに1/16に減少し、その後元の値の1/4増加します:

  ![ZawyのErhardt版の新しいタイムワープ攻撃の図（簡易版）](/img/posts/2024-time-warp/new-time-warp.png)

  この3周期を無限に繰り返すことで、各周期で1/4ずつ下げて、
  最終的にマイナーが[1秒あたり最大6ブロック][erhardt se]を生成できるレベルまで下げることができます。

  再調整期間で難易度を1/4下げるには、攻撃側のマイナーは、再調整のブロックの時間を、
  現在の期間の開始時のブロックよりも8週間先に設定する必要があります。攻撃の開始時にこれを2回続けて実行するには、
  最終的に一部のブロックの時間を16週間先に設定する必要があります。フルノードは2時間以上先のブロックを受け入れないため、
  最初のブロックセットでは8週間、2つめのブロックセットでは16週間、悪意あるブロックが受け入れられることはありません。
  攻撃側のマイナーは、ブロックが受け入れられるのを待っている間に、難易度をさらに下げて追加のブロックを作成できます。
  攻撃者が準備をしている16週間の間に正直なマイナーが作成したブロックは、フルノードが攻撃者のブロックを受け入れ始めると、
  チェーンで再編成されます。これにより、その期間中に承認されたすべてのトランザクションが、
  現在のチェーン上では無効（競合）としてマークされる可能性があります。

  Erhardtは、再調整期間の最後のブロックのタイムスタンプが
  その期間の最初のブロックのタイムスタンプよりも大きいことを要求するソフトフォークで攻撃を解決することを提案しています。
  Zawyは、ブロックのタイムスタンプの減少を禁止する（一部のマイナーが
  ノードによって強制される2時間先の制限に近いブロックを生成すると問題が発生する可能性あり）か、
  少なくとも約2時間以上減少することを禁止するなど、いくつかの解決策を提案しました。

  全体として、mainnetでは、新しいタイムワープ攻撃は、マイニング機器の要件や、
  事前に検出できること、ユーザーへの影響およびソフトフォークによる修正の比較的簡単さにおいて、
  元の攻撃と似ています。攻撃者は、少なくとも1ヶ月間、ハッシュレートの少なくとも50%を管理し続ける必要があり、
  一方で攻撃が差し迫っていることをユーザーに知らせることになり、ユーザーが応答しないことを期待する可能性はありますが、
  これはmainnetでは非常に困難なことです。Zawyが[指摘している][zawy testnet risk]ように、
  testnetでは攻撃がはるかに簡単です。少数の最新のマイニング機器があれば、
  testnetのハッシュレートの50%を達成し、ステルス攻撃を仕掛けることができます。
  攻撃者は、理論上、1日あたり50万ブロック以上を生成できます。
  ソフトフォークで攻撃を阻止しない限り、攻撃を阻止できるのは、testnetに大量のハッシュレートを割く意思のある人だけです。

  執筆時点では、提案された解決策のトレードオフが議論されていました。

- **OnionメッセージのDoSリスクの議論:** Gijs van Damは、
  研究者のAmin BashiriとMajid Khabbazianによる[Onionメッセージ][topic onion messages]に関する
  最近の[論文][bk onion]についての議論をDelving Bitcoinに[投稿しました][vandam onion]。
  研究者らは、各Onionメッセージは多数のノード（Van Damの計算によると481ホップ）に転送される可能性があり、
  すべてのノードの帯域幅が浪費される可能性があると指摘しています。彼らは、
  帯域幅の乱用リスクを緩和するいくつかの方法について説明しています。その中には、
  各追加ホップ毎に指数関数的に増加するPoWを要求する巧妙な方法があり、
  これにより短い経路は計算コストが安く、長い経路はコストが高くなります。

  Matt Coralloは、より複雑な作業に取り組む前に、
  以前提案されたアイディア（[ニュースレター #207][news207 onion]参照）を試して、
  Onionメッセージを大量に送信しているノードに逆にプレッシャーをかけることを提案しまた。

- **LNの支払人の識別と認証オプション:** Bastien Teinturierは、
  支払人が支払いにオプションで追加データを含められるようにする方法の提案を
  Delving Bitcoinに[投稿しました][teinturier auth]。これにより受取人は、
  既知の連絡先からの支払いであることを識別できます。たとえば、
  アリスが[オファー][topic offers]を生成し、ボブが支払う場合、
  アリスは支払いがボブからのものであり、ボブになりすました第三者からの支払いでないことを暗号学的に証明したい場合があります。
  オファーは、デフォルトで支払人と受取人のIDを隠すように設計されているため、
  オプトインで識別と認証を可能にするには追加の仕組みが必要です。

  Teinturierは、ボブが自分の公開鍵をアリスに開示するために使用できる、
  オプトインの _コンタクト鍵_ 配布メカニズムについて説明するところから始めました。
  次に、ボブがアリスへの支払いに署名するために使用できる、追加のオプトインメカニズムの3つの候補について説明しています。
  ボブがこのメカニズムを使用する場合、アリスのLNウォレットはその署名がボブのものであることを認証し、
  その情報をアリスに表示することができます。認証されていない支払いでは、
  （自由形式の`payer_note`フィールドのような）支払人によって設定されたフィールドを、
  信頼できないフィールドとしてマークし、ユーザーがそこに入力された情報に頼らないようにすることができます。

  どの暗号化方法を使用するかについてのフィードバックが求められており、
  Teinturierは選択された方法の仕様で[BLIP42][blips #42]をリリースする予定です。

- **Bitcoin CoreのCMakeビルドシステムへの切り替え:** Cory Fieldsは、
  Bitcoin CoreがGNU autotoolsビルドシステムからCMakeビルドシステムへの切り替えを予定しているという発表を
  Bitcoin-Devメーリングリストに[投稿しました][fields cmake]。
  この切り替えはHennadii Stepanovが主導し、Michael Fordがバグ修正と最新化に協力し、
  他の数名の開発者（Fieldsを含む）がレビューと貢献をしました。
  これは、ほとんどのユーザーが使用していると予想されるBitcoinCore.orgで入手できる
  ビルド済みのバイナリを使用するユーザーには影響しません。ただし、
  テストやカスタマイズのために独自のバイナリをビルドする開発者やインテグレーター（
  特に、珍しいプラットフォームやビルド構成で作業している場合）は影響を受ける可能性があります。

  Fieldsのメールには、予想される質問への回答が記載されており、
  Bitcoin Coreを自分でビルドする人は、[PR #30454][bitcoin core #30454]をテストして問題を報告するよう求められています。
  このPRは、今後数週間以内にマージされバージョン29（今から約7ヶ月後）でリリースされる予定です。
  テストを早めに行うほど、Bitcoin Core開発者は、バージョン29のリリース前に問題を修正する時間が増え、
  リリースされるコードの問題が構成に影響するのを防ぐ可能性が高まります。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BDK 1.0.0-beta.1][]は、ウォレットやその他のBitcoin対応アプリケーションを構築するためのこのライブラリのリリース候補です。
  元の`bdk` Rustクレートの名前が`bdk_wallet`変更され、 低レイヤーのモジュールは、
  `bdk_chain`、`bdk_electrum`、`bdk_esplora`、`bdk_bitcoind_rpc`などの独自のクレートに抽出されました。
  `bdk_wallet`クレートは、「安定した 1.0.0 API を提供する最初のバージョンです」。

- [Core Lightning 24.08rc1][]は、この人気のLNノード実装の次期メジャーバージョンのリリース候補です。

- [LND v0.18.3-beta.rc1][]は、この人気のLNノード実装の軽微なバグ修正のリリース候補です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #29519][]は、[assumeUTXO][topic assumeutxo]スナップショットがロードされた後に、
  `pindexLastCommonBlock`の値をリセットし、ノードがスナップショット内の最新のブロック以降のブロックを優先的にダウンロードするようにしました。
  これにより、ノードがスナップショットをロードする前に既存のピアから`pindexLastCommonBlock`をセットし、
  そのかなり古いブロックからのブロックのダウンロードを開始するバグが修正されます。
  assumeUTXOのバックグラウンド検証のために古いブロックをダウンロードする必要はありますが、
  ユーザーが最近のトランザクションが承認されたかどうかを確認できるように、
  新しいブロックが優先される必要があります。

- [Bitcoin Core #30598][]は、[assumeUTXO][topic assumeutxo]スナップショットファイルのメタデータからブロック高を削除しました。
  これは、ブロックハッシュに比べて、事前にサニタイズされた信頼できないファイル内の一意な識別子ではないためです。
  ノードは他の多くの内部ソースからブロックの高さを引き続き取得できます。

- [Bitcoin Core #28280][]は、プルーニングのフラッシュ中にUTXOキャッシュを空にしないことで、
  プルーニングされたノードのIBD（Initial Block Download）のパフォーマンスを最適化します。
  これは、「ダーティ」キャッシュエントリー（データベースに最後に書き込まれてから変更されたエントリー）を
  個別に追跡することで実現します。これにより、ノードはプルーニングのフラッシュ中にキャッシュ全体を不必要にスキャンすることを回避し、
  代わりにダーティエントリーにフォーカスできます。この最適化により、
  プルーニングノードで`dbcache`の設定が高い場合に、IBDが最大32%高速化され、
  デフォルト設定では約9%の改善が実現します。ニュースレター[#304][news304 cache]をご覧ください。

- [Bitcoin Core #28052][]は、アンチウィルスソフトウェアや
  同様のソフトウェアによる意図しない偶発的なデータ破損に対する予防策として、
  `blocksdir *.dat`ファイルの作成時に[XOR][]エンコーディングを追加しました。
  これはオプションで無効にでき、意図的なデータ破損攻撃から保護するものではありません。
  これは、2015年9月に[Bitcoin Core #6650][]で`chainstate`ファイルに実装され、
  2023年11月に[#28207][bitcoin core #28207]でmempoolに実装されました（[ニュースレター #277][news277 bcc28207]参照）。

- [Core Lightning #7528][]は、時間的制約のない一方的なチャネル閉鎖のスイープの[手数料率の推定][topic fee estimation]を、
  2016ブロック（約2週間）の絶対期限に調整します。以前は、手数料率は300ブロック以内の承認を目標に設定されていたため、
  トランザクションが[最小リレー手数料の制限][topic default minimum transaction relay feerates]でスタックし、
  無期限の遅延が発生することがありました。

- [Core Lightning #7533][]は、内部のコイン移動の通知とトランザクションブックキーパーを更新し、
  [スプライシング][topic splicing]トランザクションのファンディングアウトプットの支払いを適切に記録します。
  以前は、このログ記録や追跡はありませんでした。

- [Core Lightning #7517][]では、`renepay`プラグイン（ニュースレター[#263][news263 renepay]参照）をベースに、
  Pickhart Paymentの実装を改良した、最小コスト経路探索のための新しい実験的プラグインとAPIインフラストラクチャである
  `askrene`を導入しました。`getroutes` RPCコマンドは、永続的なチャネル容量データと、
  [ブラインドパス][topic rv routing]やルートヒントのような一時的な情報を指定することができ、
  可能な経路のセットとその推定成功確率を返します。チャネルの追加や、
  チャネルデータの操作、ルーティングからノードの除外、レイヤーデータの検査、
  進行中の支払いの試行の管理など、レイヤー内のルーティングデータを管理するためのRPCコマンドが他にもいくつか追加されました。

- [LND #8955][]では、`sendcoins`コマンド（および対応する`SendCoinsRequest` RPCコマンドの`Outpoints`）に、
  オプションの`utxo`フィールドが追加され、[コイン選択][topic coin selection]のユーザーエクスペリエンスが
  シングルステップに簡素化されました。これまでは、コイン選択、手数料の推定、[PSBT][topic psbt]のファンディング、
  PSBTの完了およびトランザクションのブロードキャストなど、複数のステップを経る必要がありました。

- [LND #8886][]では、`BuildRoute`関数が更新され、経路探索プロセスを逆にすることで、
  受信者から送信者までを処理し、複数のホップにわたって正確な手数料計算を可能にすることで、
  [インバウンド転送手数料][topic inbound forwarding fees]をサポートします。
  インバウンド手数料の詳細については、ニュースレター[#297][news297 inboundfees]をご覧ください。

- [LND #8967][]では、[プロトコルアップグレード][topic channel commitment upgrades]を開始する前に
  チャネルの状態をロックするための新しいワイヤーメッセージタイプ`Stfu`（SomeThing Fundamental is Underway）が追加されました。
  `Stfu`メッセージタイプは、チャネルID、イニシエーターフラグおよび将来的な拡張のための追加データフィールドを含みます。
  これは、静止プロトコルの実装の一部です（ニュースレター[#309][news309 quiescence]参照）。

- [LDK #3215][]は、トランザクションが少なくとも65 byteであることをチェックし、
  内部のマークルノードのハッシュ値を一致させることで偽の64 byteのトランザクションに対して有効なSPVプルーフを作成できる、
  軽量クライアントSPVウォレットに対する[ありそうもないコストのかかる攻撃][spv attack]から保護します。
  [マークルツリーの脆弱性][topic merkle tree vulnerabilities]を参照。

- [BLIPs #27][]は、ネットワークに対する[チャネルジャミング攻撃][topic channel jamming attacks]を部分的に緩和するための
  実験的な[HTLCエンドースメント][topic htlc endorsement]のシグナリングプロトコルの提案に関するBLIP04を追加しました。
  これは実験的なエンドースメントのTLV値、展開アプローチおよびHTLCエンドースメントがBOLTにマージされた際の実験段階の最終的な廃止について概説しています。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29519,30598,28280,28052,7528,7533,7517,8955,8886,8967,3215,1658,27,30454,42,6650,28207" %}
[BDK 1.0.0-beta.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.1
[erhardt se]: https://bitcoin.stackexchange.com/a/123700
[erhardt warp]: https://delvingbitcoin.org/t/zawy-s-alternating-timestamp-attack/1062
[zawy comment]: https://github.com/bitcoin/bitcoin/pull/29775#issuecomment-2276135560
[wall time]: https://en.wikipedia.org/wiki/Elapsed_real_time
[testnet4 rule]: https://github.com/bitcoin/bips/blob/master/bip-0094.mediawiki#time-warp-fix
[zawy testnet risk]: https://delvingbitcoin.org/t/zawy-s-alternating-timestamp-attack/1062/5
[vandam onion]: https://delvingbitcoin.org/t/onion-messaging-dos-threat-mitigations/1058
[bk onion]: https://fc24.ifca.ai/preproceedings/104.pdf
[news207 onion]: /ja/newsletters/2022/07/06/#onion-message-rate-limiting
[teinturier auth]: https://delvingbitcoin.org/t/bolt-12-trusted-contacts/1046
[fields cmake]: https://mailing-list.bitcoindevs.xyz/bitcoindev/6cfd5a56-84b4-4cbc-a211-dd34b8942f77n@googlegroups.com/
[Core Lightning 24.08rc1]: https://github.com/ElementsProject/lightning/releases/tag/v24.08rc1
[LND v0.18.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta.rc1
[news304 cache]: /ja/newsletters/2024/05/24/#bitcoin-core-28233
[news263 renepay]: /ja/newsletters/2023/08/09/#core-lightning-6376
[news309 quiescence]: /ja/newsletters/2024/06/28/#bolts-869
[spv attack]: https://web.archive.org/web/20240329003521/https://bitslog.com/2018/06/09/leaf-node-weakness-in-bitcoin-merkle-tree-design/
[news297 inboundfees]: /ja/newsletters/2024/04/10/#lnd-6703
[news277 bcc28207]: /ja/newsletters/2023/11/15/#bitcoin-core-28207
[xor]: https://ja.wikipedia.org/wiki/ワンタイムパッド