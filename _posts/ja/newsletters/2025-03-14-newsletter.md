---
title: 'Bitcoin Optech Newsletter #345'
permalink: /ja/newsletters/2025/03/14/
name: 2025-03-14-newsletter-ja
slug: 2025-03-14-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、一般的なフルノードが経験するP2Pトラフィックの分析、
LNの経路探索の研究の要約、確率的な支払いを作成するための新しいアプローチについて掲載しています。
また、Bitcoin Core PR Review Clubミーティングの要約や、
新しいリリースとリリース候補の発表、人気のBitcoinインフラストラクチャプロジェクトの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **P2Pトラフィックの分析:** 開発者のVirtuは、IBD（initial block download）、
  非リスニング（アウトバウンド接続のみ）、非アーカイブ（プルーニング）リスニング、
  アーカイブリスニングの4つの異なるモードで、彼のノードが生成・受信したネットワークトラフィックの分析を
  Delving Bitcoinに[投稿しました][virtu traffic]。彼の単一のノードの結果が、
  すべてのケースを代表しているわけではないかもしれませんが、彼の発見にはいくつか興味深い点がありました:

  - *<!--high-block-traffic-as-an-archival-listening-node-->アーカイブリスニングノードの高ブロックトラフィック:*
    Virtuのノードは、非プルーニングリスニングノードとして動作しているときに、
    1時間ごとに数GBのブロックを他のノードに提供していました。そのブロックの多くは、
    IBDを実行するためにインバウンド接続によって要求された古いブロックでした。

  - *非アーカイブリスニングの高invトラフィック:* 古いブロックの提供を有効にする前は、
    ノードのトラフィック全体の約20%が`inv`メッセージでした。
    [Erlay][topic erlay]は、1日あたり約100MBに相当するこの20%のオーバーヘッドを大幅に削減する可能性があります。

  - *<!--bulk-of-inbound-peers-appear-to-be-spy-nodes-->インバウンドピアの大部分はスパイノードのようだ:* 「興味深いことに、
    インバウンドピアの大部分は私のノードと約1MBのトラフィックしか交換していません。
    これは通常の接続としては低すぎます（アウトバウンド接続経由のトラフィックを基準とした場合）。
    これらのノードが行っているのは、P2Pハンドシェイアクを完了し、
    pingメッセージを丁寧に返信しているだけで、それ以外は`inv`メッセージを吸い上げているだけです。」

  Virtuの投稿には、彼のノードが経験したトラフィックを示す追加の洞察と複数のチャートが含まれています。

- **単一パスのLN経路探索の研究:** Sindura Saraswathiは、
  支払いを1回で送信するためのLNノード間の最適な経路を見つけるというChristian Kümmerleと共同で行った
  [研究][sk path]についてDelving Bitcoinに[投稿しました][saraswathi path]。
  彼女の投稿では、Core Lightning、Eclair、LDK、LNDで現在使用されている戦略について説明しています。
  次に著者らは、（実際のネットワークのスナップショットに基づく）シミュレートされたLNネットワークで
  8つの変更済みおよび未変更のLNノードを使って経路探索をテストし、
  最高の成功率、最低の手数料率（最低コスト）、最短の合計タイムロック（最悪の場合の待機期間）、
  最短経路（支払いがスタックする可能性が最も低い）などの基準を評価します。
  すべてのケースで、他のアルゴリズムより優れたパフォーマンスを発揮したアルゴリズムはなく、
  Saraswathiは、実装によってユーザーがさまざな支払いに対して好みのトレードオフを選択できる、
  より優れた重み付け関数の提供の実装を提案しています。たとえば、少額の対面の購入では高い成功率を優先し、
  支払期限が数週間先の高額な月額の請求では低い手数料率を優先するなど。また彼女は、
  「この研究の範囲外ですが、この研究で得られた洞察は、[マルチパートペイメント][topic multipath payments]の
  経路探索アルゴリズムの将来の改善にも関連していることに注意してください」と述べています。

- **異なるハッシュ関数をXOR関数として使用する確率的支払い:** Robin Linusは、
  [確率的支払い][topic probabilistic payments]に関するDelving Bitcoinのスレッドに、
  概念的にシンプルなスクリプトを[返信しました][linus pp]。このスクリプトは、
  2人の参加者がそれぞれ任意の量のエントロピーをコミットし、後でそれを公開してXORすることで、
  どちらが支払いを受け取るかを決定するのに使用できる値を生成します。
  投稿のLinusのサンプルを（少し拡張して）使用すると:

  - アリスは値`1 0 0`と別のnonceを非公開で選択します。ボブは、`1 1 0`と別のnonceを非公開で選択します。

  - 各参加者は、nonceを連続的にハッシュし、値内の数値によってどのハッシュ関数が使用されるかが決まります。
    スタックの一番上の値が`0`の場合は`HASH160` opcodeを使用し、
    値が`1`の場合は`SHA256` opcodeを使用します。アリスの場合は、
    `sha256(hash160(hash160(alice_nonce)))`を実行します。
    ボブの場合は、`sha256(sha256(hash160(bob_nonce)))`を実行します。
    これにより、それぞれのコミットメントが生成され、値やnonceを明かすことなく生成したコミットメントをお互い送信します。

  - コミットメントを共有したら、`OP_IF`を使って入力を検証し、
    異なるハッシュ関数を選択して、どちらかが支払いを請求できるようにするスクリプトを使って
    オンチェーンのファンディングトランザクションを作成します。たとえば、
    2つのXORされた値の合計が0または1の場合、アリスがお金を受け取ります。
    2または3の場合、ボブが受け取ります。コントラクトには、タイムアウト条件と、
    スペースを節約するための相互合意条件が含まれる場合があります。

  - ファンディングトランザクションが適切な深さまで承認されると、アリスとボブはお互いに値とnonceを公開します。
    `1 0 0`と`1 1 0`をXORすると`0 1 0`で、合計は1となり、アリスは支払いを請求できます。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Stricter internal handling of invalid blocks][review club 31405]は、
[mzumsande][gh mzumsande]によるPRで、ブロックが無効とマークされたときにすぐに更新することで、
非コンセンサスクリティカルで計算コストの高い2つの検証フィールドの正確性を向上させます。
このPR以前は、リソースの使用を最小限に抑えるために、これらの更新は後のイベントまで延期されていました。
ただし、[Bitcoin Core #25717][]以降、攻撃者はこれを悪用するためにははるかに多くの作業をする必要があります。

具体的には、このPRにより、`ChainstateManager`の`m_best_header`が
常に有効であるとは知られていない最も作業量の多いヘッダーを指し、
ブロックの`BLOCK_FAILED_CHILD` `nStatus`が常に正しいことが保証されます。


{% include functions/details-list.md
  q0="`ChainstateManager::m_best_header`はどのような目的に使用されるのですか？"
  a0="`m_best_header`は、ノードがこれまに確認した最もPoWのあるヘッダーを表します。
  このヘッダーはまだ無効化されていませんが、有効であるとは保証できません。
  このヘッダーには多くの用途がありますが、主な用途は、ノードがベストチェーンを進めるための対象として機能することです。
  その他の使用例としては、現在の時刻の推定値や、
  ピアから欠落しているヘッダーを要求する際の最適なチェーンの高さの推定値の提供などがあります。
  より完全な概要は、約6年前のプルリクエスト[Bitcoin Core #16974][]で確認できます。"
  a0link="https://bitcoincore.reviews/31405#l-36"

  q1="このPR以前、以下の記述のうち正しいものはどれですか？
  1) 無効な先行処理を持つ`CBlockIndex`は常に`BLOCK_FAILED_CHILD` `nStatus`を持つ。
  2) 有効な先行処理を持つ`CBlockIndex`は決して`BLOCK_FAILED_CHILD` `nStatus`を持たない。"
  a1="記述 1) は誤りであり、このPRで直接対処されています。このPR以前は、
  `AcceptBlock()`が無効なブロックをそのようにマークしていましたが、
  パフォーマンス上の理由からその子孫をそのようにすぐ更新することはありませんでした。
  Review Clubの参加者は記述 2) が誤りであるシナリオを思いつきませんでした。"
  a1link="https://bitcoincore.reviews/31405#l-68"

  q2="このPRの目標の1つは、`m_best_header`と無効なブロックの後続ブロックの`nStatus`が常に正しく設定されることです。
  これらの値の更新を直接担当するのはどの関数ですか？"
  a2="`SetBlockFailureFlags()`が`nStatus`の更新を担当します。通常の操作では、
  `m_best_header`は`AddToBlockIndex()`のoutパラメーターを介して設定されるのが最も一般的ですが、
  `RecalculateBestHeader()`を介して計算および設定することもできます。"
  a2link="https://bitcoincore.reviews/31405#l-110"

  q3="コミット`4100495` `validation: in
  invalidateblock, calculate m_best_header right away`のロジックのほとんどは、
  新しいベストヘッダーを見つけるための実装です。ここで`RecalculateBestHeader()`を使用するだけでは不十分なのはなぜですか？"
  a3="`RecalculateBestHeader()`は、`m_block_index`全体をトラバースしますが、
  これは高価な操作です。コミット`4100495`では、代わりに高PoWヘッダーを持つ候補セットをキャッシュして反復処理することで
  これを最適化します。"
  a3link="https://bitcoincore.reviews/31405#l-114"

  q4="ブロックツリーを前方（つまりジェネシスブロックから離れて）に反復できる場合、
  `cand_invalid_descendants`キャッシュは依然必要ですか？このPRで採用されているアプローチと比較して、
  このようなアプローチの長所と短所は何でしょうか？"
  a4="`CBlockIndex`オブジェクトがすべての子孫への参照を保持している場合、
  子孫を無効にするために`m_block_index`全体を反復処理する必要がないため、
  `cand_invalid_descendants`キャッシュは不要になります。
  ただし、このアプローチには重大な欠点があります。まず、各`CBlockIndex`オブジェクトのメモリフットプリントが増加します。
  これは、`m_block_index`全体にわたってメモリ内に保持する必要があります。
  次に、各`CBlockIndex`には祖先が1つだけありますが、子孫がまったくないか複数ある可能性があるため、
  反復処理は依然として簡単ではありません。"
  a4link="https://bitcoincore.reviews/31405#l-136"
%}

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Eclair v0.12.0][]は、このLNノードのメジャーリリースです。
  [BOLT12][]オファーの作成と管理をサポートし、
  [RBF][topic rbf]をサポートする新しいチャネルクローズプロトコルが追加されています。
  また、他の改善やバグ修正に加えて、ピア用に少量のデータ保存（
  [ピアストレージ][topic peer storage]）のサポートも追加されています。
  リリースノートには、いくつかの主要な依存関係が更新されたため、
  ユーザーはEclairの新しいバージョンを展開する前に、それらの更新を行う必要があると記載されています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #31407][]は、`detached-sig-create.sh`スクリプトを更新することで、
  macOSアプリケーションバンドルとバイナリの公証をサポートします。このスクリプトは、
  スタンドアロンのmacOSおよびWindowsバイナリにも署名するようになりました。
  これらのタスクを実行するには、最近更新された[signapple][]ツールが使用されます。

- [Eclair #3027][]は、`routeBlindingPaths`関数を導入することで、
  [BOLT12][topic offers]インボイスを生成する際に、[ブラインドパス][topic rv
  routing]の経路探索機能を追加します。この関数は、ブラインドパスをサポートするノードのみを使用して、
  選択した開始ノードから受信ノードまでのパスを計算します。その後ブラインドパスがインボイスに含められます。

- [Eclair #3007][]は、`channel_reestablish`メッセージに、
  `last_funding_locked` TLVパラメーターを追加し、切断後のチャネル[スプライシング][topic splicing]中の
  ピア間の同期を改善します。これは、ノードが`channel_reestablish`を受信した後、
  `splice_locked`の前に、`channel_update`を送信する競合状態を修正します。
  これは通常のチャネルには無害ですが、ピア間でnonceの交換を必要とする
  [Simple Taproot Channel][topic simple taproot channels]を妨害する可能性があります。

- [Eclair #2976][]は、`createoffer`コマンドを導入することで、
  追加のプラグインなしで[オファー][topic offers]を作成するためのサポートを追加します。
  このコマンドは、説明、量、有効期限（秒）、発行者および`blindedPathsFirstNodeId`のオプションパラメーターを使用して、
  [ブラインドパス][topic rv routing]の開始ノードを定義します。さらにこのPRでは、
  既存のオファーを管理するための`disableoffer`コマンドと`listoffers`コマンドが導入されています。

- [LDK #3608][]は、トランザクションの承認に必要なブロックの予想最大数の2倍を表すように`CLTV_CLAIM_BUFFER`を再定義し、
  [HTLC][topic htlc]が1ブロックの`OP_CHECKSEQUENCEVERIFY` (CSV)
  [タイムロック][topic timelocks]によってトランザクションが遅延する[アンカー][topic anchor outputs]チャネルに適応します。
  以前は、単一の最大承認期間に設定されていましたが、
  HTLCを請求するトランザクションがコミットメントトランザクションと一緒にブロードキャストされる
  アンカーチャネル以前では十分でした。新しい`MAX_BLOCKS_FOR_CONF`定数が基本値として追加されています。

- [LDK #3624][]は、ベースファンディング鍵にスカラー調整値を適用してチャネルの2-of-2
  [マルチシグ][topic multisignature]の鍵を入手することで、
  チャネルの[スプライシング][topic splicing]が成功した後のファンディング鍵のローテションを有効にします。
  これにより、ノードは同じシークレットから追加の鍵を導出できます。調整値の計算は、
  [BOLT3][]の仕様に従いますが、一意性を確保するために`per_commitment_point`を
  スプライシングのファンディングtxidに置き換え、チャネル参加者への導出を制限するために、
  `revocation_basepoint`を使用します。

- [LDK #3016][]は、`xtest`マクロを導入することで、外部プロジェクトが機能テストを実行し、
  signerなどのコンポーネントを置き換えるためのサポートを追加します。
  これには、signerなどの動的テストコンポーネントをサポートする`MutGlobal`ユーティリティや、
  `DynSigner`構造体が含まれ、これらのテストは`_externalize_tests`機能フラグの下で公開され、
  動的にsignerを作成するための`TestSignerFactory`が提供されます。

- [LDK #3629][]は、原因を特定または解釈できないリモート障害のログ記録を改善し、
  これらのエッジケースの可視性を高めます。このPRは、送信者の操作を中断する可能性のある
  原因を特定できないログを記録するように`onion_utils.rs`を変更し、
  復号処理用の`decrypt_failure_onion_error_packet`関数を導入します。
  また、有効なハッシュベースのメッセージ認証符号（HMAC）による
  読み取り不可能な障害がノードに正しく属さないバグも修正されました。
  これは、[高可用性][news342 qos]を通知しながらも
  配信に失敗したノードの使用を送信者が回避できるようにしたことに関係している可能性があります。

- [BDK #1838][]は、`SyncRequest`と`FullScanRequest`に必須の`sync_time`を追加し、
  この`sync_time`を未承認トランザクションの`seen_at`プロパティとして適用し、
  非正規トランザクション（ニュースレター[#335][news335 noncanonical]参照）が
  `seen_at`タイムスタンプを除外できるようにすることで、
  フルスキャンと同期フローの明確さを向上させます。これは、
  トランザクションごとに複数の`seen_at`タイムスタンプをサポートするために
  `TxUpdate::seen_ats`を(Txid, u64)の`HashSet`に更新し、
  `TxGraph`を非網羅的にするなどの変更を加えています。

{% include snippets/recap-ad.md when="2025-03-18 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31407,3027,3007,2976,3608,3624,3016,3629,1838,16974,25717" %}
[virtu traffic]: https://delvingbitcoin.org/t/bitcoin-node-p2p-traffic-analysis/1490/
[saraswathi path]: https://delvingbitcoin.org/t/an-exposition-of-pathfinding-strategies-within-lightning-network-clients/1500
[sk path]: https://arxiv.org/pdf/2410.13784
[linus pp]: https://delvingbitcoin.org/t/emulating-op-rand/1409/10
[eclair v0.12.0]: https://github.com/ACINQ/eclair/releases/tag/v0.12.0
[review club 31405]: https://bitcoincore.reviews/31405
[gh mzumsande]: https://github.com/mzumsande
[signapple]: https://github.com/achow101/signapple
[news335 noncanonical]: /ja/newsletters/2025/01/03/#bdk-1670
[news342 qos]: /ja/newsletters/2025/02/21/#ln
