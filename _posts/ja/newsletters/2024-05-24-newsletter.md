---
title: 'Bitcoin Optech Newsletter #304'
permalink: /ja/newsletters/2024/05/24/
name: 2024-05-24-newsletter-ja
slug: 2024-05-24-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LNチャネルを閉じたり再オープンしたりすることなく
チャネルをアップグレードするためのいくつかの提案の分析と、
プールマイナーに適切な支払いを保証する際の課題に関する議論、
サイレントペイメントに関する情報を伝達するためにPSBTを安全に使用することについての議論のリンク、
miniscriptのBIP提案の発表、価格先物契約をシミュレートするためにLNチャネルの頻繁なリバランスを使用する提案を掲載しています。
また、サービスとクライアントソフトウェアの変更、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、恒例のセクションも含まれています。

## ニュース

- **既存のLNチャネルのアップグレード:** Carla Kirk-Cohenは、
  新機能をサポートするために既存のLNチャネルをアップグレードするための既存の提案の要約と分析をDelving Bitcoinに
  [投稿しました][kc upchan]。彼女は以下のようなさまざまなケースを検証しています:

  - *<!--changing-parameters-->パラメーターの変更:* 現在、いくつかのチャネルの設定は、
    参加者間で交渉され、チャネルの存続中は変更できません。パラメーターを更新すると、その後の再交渉が可能になります。
    たとえばノードは、[HTLCのトリミング][topic trimmed htlc]を始めるsatoshiの量や、
    古い状態での閉鎖を抑制するために取引相手に保持させるチャネルリザーブの量を変更したい場合があります。

  - *<!--updating-commitments-->コミットメントの更新:* LNの _コミットメントトランザクション_ により、
    個々人は現在のチャネル状態をオンチェーンに展開することができます。
    [コミットメントのアップグレード][topic channel commitment upgrades]により、
    P2WSHベースのチャネルでは、[アンカーアウトプット][topic anchor outputs]や
    [v3トランザクション][topic v3 transaction relay]への切り替えが可能になり、
    [Simple Taproot Channel][topic simple taproot channels]では、
    [PTLC][topic ptlc]の使用への切り替えが可能になります。

  - *<!--replacing-funding-->ファンディングの置き換え:* LNチャネルは、
    _ファンディングトランザクション_ でオンチェーンにアンカリングされており、
    そのアウトプットは、コミットメントトランザクションとしてオフチェーンで繰り返し使用されます。
    当初、すべてのLNファンディングトランザクションは、P2WSHアウトプットを使用していました。
    しかし、[PTLC][topic ptlc]のような新しい機能では、
    ファンディングトランザクションはP2TRアウトプット使用する必要があります。

  Kirk-Cohenは、チャネルをアップグレードするための以前の3つのアイディアを比較しています:

  - *<!--dynamic-commitments-->ダイナミックコミットメント:* [ドラフト仕様][BOLTs #1117]に記載されているように、
    これはほとんどすべてのチャネルパラーメーターを変更することができ、
    新しい「キックオフ」トランザクションを使用してファンディングトランザクションおよび
    コミットメントトランザクションをアップグレードするための一般化されたパスも提供します。

  - *<!--splice-to-upgrade-->アップグレードのためのスプライス:* このアイディアは、
    チャネルのオンチェーンファンディングを更新する[スプライストランザクション][topic splicing]で、
    使用するファンディングタイプとオプションでコミットメントトランザクションのフォーマットを変更できるようにするものです。
    これはチャネルパラメーターの変更には直接対応しません。

  - *<!--upgrade-on-re-establish-->再確立時のアップグレード:* [ドラフト仕様][bolts #868]にも記載されているように、
    2つのノードがデータ接続を再確立するたびに多くのチャネルパラメーターを変更することができます。
    ファンディングトランザクションやコミットメントトランザクションの変更には直接対応しません。

  Kirk-Cohenは、提示されたすべてのオプションについて、オンチェーンコスト、長所、短所をリストアップした表で比較し、
  アップグレードしない場合のオンチェーンコストとも比較しています。
  彼女は次のようないくつかの結論を導き出しました。「Taprootチャネルへのアップグレードをどのように行うかに関係なく、
  [ダイナミックコミットメント][bolts #1117]を介したパラメーターとコミットメントの両方のアップグレードに取り組み始めるのが理になかっていると思います。
  これにより、`option_zero_fee_htlc_tx`アンカーチャネルへのアップグレードが可能になり、
  v3チャネルへのアップグレードに使用できるコミットメント形式のアップグレードメカニズムが提供されます。」

- **<!--challenges-in-rewarding-pool-miners-->プールマイナーへの報酬の課題:**
  Ethan Tuttleは、[マイニングプール][topic pooled mining]がマイナーにマイニングしたシェアに比例した
  [ecash][topic ecash]トークンを与える提案をDelving Bitcoinに[投稿しました][tuttle poolcash]。
  マイナーはそのトークンをすぐに売却したり送金することもできます。
  もしくは、プールがブロックをマイングするのを待つこともでき、マイニングされた時点でプールはトークンとsatoshiを交換します。

  このアイディアに対する批判と提案の両方が投稿されました。
  特にMatt Coralloの根本的な問題について説明した[返信][corallo pooldelay]は洞察に富んでいました。
  それは、プールマイナーが短期間で報酬の支払いを計算できるように、
  大規模なプールで実装されている標準化された支払い方法が存在しないというものです。
  一般的に使用される支払いの種類は2つあります:

  - *PPS（Pay per share）:* これはブロックが見つからなくても、マイナーが貢献した作業量に比例して支払われます。
    ブロック報酬の比例配当の計算は簡単ですが、トランザクション手数料の計算はより複雑です。
    Coralloは、ほとんどのプールはシェアが作成された日に収集された手数料の平均を用いているようで、
    これはシェアがマイニングされた翌日まで1シェアあたりの支払額を計算できないことを意味すると指摘しています。
    さらに、多くのプールでは、プールごとに異なる方法で手数料の平均を微調整する場合があります。

  - *PPLNS（Pay per last n shares）:* プールがブロックを見つける直前に見つかったシェアに対して
    マイナーに報酬を与えます。ただし、マイナーがプールでブロックを見つけたと確信できるのは、
    マイナー自身がブロックを見つけた場合のみです。一般的なマイナーにとって、
    プールが正しく支払いをしていることを知る方法は（短期的には）ありません。

  この情報の欠如は、メインプールが支払いを騙し始めても、マイナーがすぐに別のプールに乗り換えることがないことを意味します。
  [Stratum v2][topic pooled mining]ではこの問題は解決されませんが、
  プールは標準化されたメッセージを使用してマイナーに新しいシェアの支払いを停止することを伝えることができます。
  Coralloは、すべてのシェアが支払いに含まれていることをマイナーが確認できるようにする
  Stratum v2への[提案][corallo sv2 proposal]のリンクを記載しています。これにより、
  マイナーは少なくとも長期間経てば（数時間から数日）、正しく支払われていないかどうかを検知できるようになる可能性があります。

  この記事の執筆時点では、議論は継続中です。

- **サイレントペイメント用のPSBTに関する議論:** Josie Bakerは、
  Andrew Tothの[ドラフト仕様][toth psbtsp]を引用して、
  [サイレントペイメント][topic silent payments]（SP）用の[PSBT][topic psbt]拡張に関する議論を
  Delving Bitcoinで[始めました][baker psbtsp]。SP用のPSBTには2つの側面があります:

  - **<!--spending-to-sp-addresses-->SPアドレスへの支払い:** トランザクションに配置される実際のアウトプットスクリプトは、
    サイレントペイメントアドレスとトランザクションのインプットの両方に依存します。
    PSBT内のインプットを変更すると、標準的なウォレットソフトウェアではSPアウトプットを使用できなくなる可能性があるため、
    PSBTの追加検証が必要になります。インプットの種類によってはSPと一緒に使用できないため、これも検証が必要です。

    使用可能な種類のインプットについては、SP対応の支払いロジックにはそれらのインプットの秘密鍵が必要ですが、
    その基礎となる鍵がハードウェア署名デバイスに保存されている場合、ソフトウェアウォレットでは秘密鍵を利用できない可能性があります。
    Bakerは、支払人が秘密鍵なしでSPアウトプットスクリプトを作成できるようにするスキームについて説明していますが、
    これには秘密鍵が漏洩する可能性があるため、ハードウェア署名デバイスには実装されない可能性があります。

  - **過去に受信したSPアウトプットの使用:** PSBTには、
    支払いに使用する鍵への微調整に使用される共有シークレットを含める必要があります。
    これは単に追加のPSBTフィールドで構いません。

  この記事の執筆時点では、議論は継続中です。

- **miniscriptのBIP提案:** Ava Chowは、[miniscript][topic miniscript]の[BIPドラフト][chow bip]を
  Bitcoin-Devメーリングリストに[投稿しました][chow miniscript]。
  miniscriptは、Bitcoinスクリプトに変換できる言語で、さらに合成、テンプレート化、最終的な分析が可能です。
  このBIPのドラフトは、miniscriptの以前からあるWebサイトから派生したもので、
  P2WSH witnessスクリプトおよびP2TRの[Tapscript][topic tapscript]の両方の既存のminiscriptの実装に対応するものです。

- **<!--channel-value-pegging-->チャネル価格へのペグ:** Tony Klausingは、
  _ステーブルチャネル_ 関する提案を動作する[コード][klausing code]と共にDelving Bitcoinに[投稿しました][klausing stable]。
  アリスが$1,000 USDに相当する量のビットコインを保持したいと考えているとしましょう。
  ボブは、BTCの価値が上昇することを期待している、またはアリスが彼にプレミアム支払うため（もしくはその両方）、
  それを保証するつもりです。両者は一緒にLNチャネルを開き、1分ごとに以下のアクションを実行します:

  - どちらも同じBTC/USD価格ソースをチェックします。

  - BTCの価値が上昇した場合、アリスは自分のビットコイン残高を$1,000 USDになるまで減らし、
    超過分をボブに送信します。

  - BTCの価値が下がった場合は、ボブはアリスのビットコイン残高が再度$1,000 USDに等しくなるのに十分なBTCをアリスに送信します。

  目標は、各価格変動が不利な側のチャネルを閉じるコストを下回るほど頻繁にリバランスが行われるようにすることです。
  そうすることで、不利な側のトレーダーは、単に代金を支払って関係を継続するようになります。

  Klausingは、トレーダーによっては、
  このような最小限の信頼関係の方がカストディアルな先物市場よりも好ましいと感じる可能性があることを示唆しています。
  また、ドル建ての[ecash][topic ecash]を発行する銀行の基盤として利用できる可能性も示唆しています。
  このスキームは市場価格が決定できるあらゆる資産に対して機能します。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **<!--silent-payment-resources-->サイレントペイメントのリソース:**
  [silentpayments.xyz][sp website]情報サイトや、[2つの][bi ts sp]TypeScript[ライブラリ][bw ts sp]、
  [Goベースのバックエンド][gh blindbitd]、[Webウォレット][gh silentium][など][sp website devs]を含む、
  いくつかの[サイレントペイメント][topic silent payments]のリソースが発表されました。
  ほとんどのソフトウェアは新しいものや、ベータ版または開発中のものであるため注意が必要です。

- **Cake Walletがサイレントペイメントをサポート:**
  [Cake Wallet][cake wallet website]は最近、最新のベータリリースで
  サイレントペイメントのサポートを[発表しました][cake wallet announcement]。

- **コーディネーター不要のcoinjoinのPoC:**
  [Emessbee][gh emessbee]は、中央のコーディネーターを必要とせずに
  [coinjoin][topic coinjoin]トランザクションを作成する概念実証プロジェクトです。

- **OCEANがBOLT12をサポート:**
  OCEANマイニングプールは、[ライトニング支払い][ocean docs]の一部として、
  [署名付きメッセージ][topic generic signmessage]を使用してBitcoinアドレスを
  [BOLT12オファー][topic offers]に関連付けます。

- **Coinbaseがライトニングをサポート:**
  Coinbaseは[Lightspark][lightspark website]のライトニングインフラストラクチャを使用して、
  ライトニングの入出金のサポートを[追加しました][coinbase blog]。

- **Bitcoinエスクローツールの発表:**
  [BitEscrow][bitescrow website]チームは、非カストディアルのBitcoinエスクローを実装するための
  [開発ツール][bitescrow docs]のセットを発表しました。

- **Blockがマイニングコミュニティへフィードバックの呼びかけ:**
  Blockは、3nmのチップの進捗に関する[アップデート][block blog]の中で、
  マイニングハードウェアおよびソフトウェアの機能やメンテナンスおよびその他の質問について、
  マイニングコミュニティからのフィードバックを求めています。

- **Sentrumウォレットトラッカーのリリース:**
  [Sentrum][gh sentrum]は、さまざまな通知チャネルをサポートする監視専用ウォレットです。

- **Stack WalletがFROSTをサポート:**
  [Stack Wallet v2.0.0][gh stack wallet]は、モジュラーFROST Rustライブラリを使用して、
  FROST[閾値][topic threshold signature]マルチシグのサポートを追加しました。

- **<!--transaction-broadcast-tool-announced-->トランザクションブロードキャストツールの発表:**
  [Pushtx][gh pushtx]は、トランザクションをBitcoinのP2Pネットワークに直接ブロードキャストするシンプルなRustプログラムです。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Inquisition 27.0][]は、[signet][topic signet]上でソフトフォークや
  その他の主要なプロトコル変更をテストするために設計されたBitcoin Coreのこのフォークの最新メジャーリリースです。
  このリリースの新機能は、[BIN24-1][]と[BIP347][]で定義された[OP_CAT][]のsignetへの適用です。
  また、「スクリプトのopcodeの動作をテストするために使用できる`bitcoin-util`用の
  新しい`evalscript`サブコマンド」も含まれています。
  `annexdatacarrier`と疑似[エフェメラルアンカー][topic ephemeral anchors]のサポート（
  ニュースレター[#244][news244 annex]および[#248][news248 ephemeral]参照）は終了しました。

- [LND v0.18.0-beta.rc2][]は、この人気のLNノード実装の次期メジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。*

- [Bitcoin Core #27101][]では、JSON-RPC 2.0のリクエストとサーバーレスポンスのサポートが導入されています。
  注目すべき変更点は、HTTPエラーや不正なリクエストがない限り、サーバーは常にHTTP 200 "OK"を返すこと、
  エラーフィールドまたは結果フィールドのいずれかを返しますが両方を返すことはなく、
  単一リクエストとバッチリクエストの結果が同じエラー処理動作になることです。
  リクエストボディでバージョン2.0が指定されていない場合は、従来のJSON-RPC 1.1プロトコルが使用されます。

- [Bitcoin Core #30000][]では、`txid`の代わりに`wtxid`でインデックスを作成することで、
  `txid`が同じ複数のトランザクションが`TxOrphanage`内で共存できるようになります。
  orphanageは、Bitcoin Coreが現在アクセスできない親トランザクションのtxidを参照するトランザクションを保存するために
  使用するサイズが制限されたステージング領域です。
  そのtxidを持つ親トランザクションを受信したら、子を処理できます。
  1p1c（Opportunistic 1-parent-1-child）[パッケージ受け入れ][topic package relay]では、
  orphanageに保存されることを期待して、最初に子トランザクションを送信し、
  その後親トランザクションを送信します。これにより親子の集約手数料率が考慮されるようになります。

  ただ、1p1cがマージされた時（[ニュースレター #301][news301 bcc28970]参照）、
  攻撃者は無効なwitnessデータを含むバージョンの子トランザクションを先に送信することで、
  正直なユーザーがこの機能を使用するのを防ぐことができることが知られていました。
  その不正な子トランザクションは、正直な子トランザクションと同じtxidを持ちますが、
  親トランザクションを受信した際に検証に失敗し、パッケージの受け入れが機能するために必要な
  [CPFP][topic cpfp]パッケージ手数料率に子が貢献できなくなります。

  このPR以前は、orphanage内のトランザクションは、txidでインデックス付けされていたため、
  特定のtxidを持つトランザクションの最初のバージョンがorphanageに保存されるものとなり、
  正直なユーザーよりも速く頻繁にトランザクションを送信できる攻撃者は、
  正直なユーザーを無期限にブロックすることができました。このPR後は、
  それぞれ異なるwitnessデータを持つ（つまり、wtxidが異なる）ものの、
  txidが同じ複数のトランザクションを受け入れることができます。
  それらの親トランザクションを受信すると、ノードは不正な子トランザクションを削除し、
  有効な子トランザクションに対して期待される1p1cパッケージ受け入れを実行するのに十分な情報を持ちます。
  このPRについては、以前[ニュースレター #301][news301 prclub]のPR Review Clubの要約で取り上げました。

- [Bitcoin Core #28233][]は、[#17487][bitcoin core #17487]をベースに、
  ウォームコイン（UTXO）キャッシュの24時間毎の定期的なフラッシュを削除しました。
  #17487以前は、ディスクへの頻繁なフラッシュにより、
  ノードやハードウェアのクラッシュにより時間のかかる再インデックス処理が必要になるリスクが軽減されました。
  #17487以降、メモリキャッシュを空にすることなく、新しいUTXOをディスクに書き込むことができるようになりましたが、
  割り当てられた最大メモリ領域に近づくとキャッシュを空にする必要があります。
  ウォームキャッシュは、デフォルトのキャッシュ設定のノードのブロック検証速度をほぼ2倍にし、
  キャッシュに追加のメモリを割り当てたノードでは、さらに性能が向上します。

- [Core Lightning #7304][]では、`reply_path`ノードへのパスが見つからない場合に、
  [オファー][topic offers]スタイルの`invoice_requests`への返信フローが追加されました。
  CLNの`connectd`では、インボイスを含む[Onionメッセージ][topic onion messages]を配信するために、
  リクエストノードへの一時的なTCP/IP接続を開きます。
  このPRにより、Core LightningとLDKの相互運用性が向上し、
  少数のノードしかサポートしていない（[ニュースレター #283][news283 ldk2723]参照）
  Onionメッセージも使用できるようになります。

- [Core Lightning #7063][]は、手数料の値上げを動的に調整するため、セキュリティマージンの倍率を更新しました。
  この倍率は、チャネルトランザクションが承認されるのに十分な手数料率を支払うこと保証しようとするもので、
  （手数料引き上げできないトランザクションの場合は）直接または手数料の引き上げを通じて行われます。
  この倍率は低レート（1 sat/vbyte）では現在の[手数料率の推定][topic fee estimation]の2倍から始まり、
  手数料率が日次の`maxfeerate`に近づくにつれて徐々に1.1倍に減少します。

- [Rust Bitcoin #2740][]は、`pow`（proof of work）APIに`from_next_work_required`メソッドを追加しました。
  このメソッドは、（以前の難易度ターゲットを表す）`CompactTarget`と、
  （現在のブロックと以前のブロックの時間差を表す）`timespan`、
  ネットワークパラメーターオブジェクト`Params`を受け取り、
  次の難易度ターゲットを表す新しい`CompactTarget`を返します。
  この関数に実装されているアルゴリズムは、`pow.cpp`ファイルにあるBitcoin Coreの実装に基づいています。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when="2024-05-27 14:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27101,30000,28233,7304,7063,2740,1117,868,17487" %}
[lnd v0.18.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc2
[kc upchan]: https://delvingbitcoin.org/t/upgrading-existing-lightning-channels/881
[tuttle poolcash]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870
[corallo pooldelay]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870/14
[corallo sv2 proposal]: https://github.com/stratum-mining/sv2-spec/discussions/76#discussioncomment-9472619
[baker psbtsp]: https://delvingbitcoin.org/t/bip352-psbt-support/877
[toth psbtsp]: https://gist.github.com/andrewtoth/dc26f683010cd53aca8e477504c49260
[chow miniscript]: https://mailing-list.bitcoindevs.xyz/bitcoindev/0be34bd2-637b-44b1-a0d5-e0ad5812d505@achow101.com/
[chow bip]: https://github.com/achow101/bips/blob/miniscript/bip-miniscript.md
[klausing stable]: https://delvingbitcoin.org/t/stable-channels-peer-to-peer-dollar-balances-on-lightning/875
[klausing code]: https://github.com/toneloc/stable-channels/
[news301 prclub]: /ja/newsletters/2024/05/08/#bitcoin-core-pr-review-club
[news301 bcc28970]: /ja/newsletters/2024/05/08/#bitcoin-core-28970
[news283 ldk2723]: /ja/newsletters/2024/01/03/#ldk-2723
[news244 annex]: /ja/newsletters/2023/03/29/#bitcoin-inquisition-22
[news248 ephemeral]: /ja/newsletters/2023/04/26/#bitcoin-inquisition-23
[Bitcoin Inquisition 27.0]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v27.0-inq
[sp website]: https://silentpayments.xyz/
[bi ts sp]: https://github.com/Bitshala-Incubator/silent-pay
[bw ts sp]: https://github.com/BlueWallet/SilentPayments
[gh blindbitd]: https://github.com/setavenger/blindbitd
[gh silentium]: https://github.com/louisinger/silentium
[sp website devs]: https://silentpayments.xyz/docs/developers/
[cake wallet website]: https://cakewallet.com/
[cake wallet announcement]: https://twitter.com/cakewallet/status/1791500775262437396
[gh emessbee]: https://github.com/supertestnet/coinjoin-workshop
[coinbase blog]: https://www.coinbase.com/blog/coinbase-integrates-bitcoins-lightning-network-in-partnership-with
[lightspark website]: https://www.lightspark.com/
[block blog]: https://www.mining.build/latest-updates-3nm-system/
[gh sentrum]: https://github.com/sommerfelddev/sentrum
[ocean docs]: https://ocean.xyz/docs/lightning
[bitescrow website]: https://www.bitescrow.app/
[bitescrow docs]: https://www.bitescrow.app/dev
[gh stack wallet]: https://github.com/cypherstack/stack_wallet/releases/tag/build_222
[gh pushtx]: https://github.com/alfred-hodler/pushtx
