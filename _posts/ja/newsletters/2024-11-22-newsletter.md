---
title: 'Bitcoin Optech Newsletter #330'
permalink: /ja/newsletters/2024/11/22/
name: 2024-11-22-newsletter-ja
slug: 2024-11-22-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、プラグイン可能なチャネルファクトリーを可能にするためのLN仕様の変更案と、
提案中のソフトフォークを使用するデフォルトsignet上のトランザクションを調査したレポートと
新しいウェブサイトのリンク、LNHANCEマルチパートソフトフォーク提案の更新に関する説明、
コンセンサスの変更ではなくグラインドに基づくコベナンツに関する論文についての説明を掲載しています。
また、サービスやクライアントソフトウェア、人気のあるBitcoinインフラストラクチャソフトウェアの
最近の変更をまとめた恒例のセクションも含まれています。

## News

- **<!--pluggable-channel-factories-->プラグイン可能なチャネルファクトリー:**
  ZmnSCPxjは、既存のLNソフトウェアがプラグインを使用して[チャネルファクトリー][topic channel factories]内で
  [LN-Penalty][topic ln-penalty]ペイメントチャネルを管理できるようにするために、
  [BOLT][bolts repo]の仕様に小さな変更を加える提案をDelving Bitcoinに[投稿しました][zmnscpxj plug]。
  この仕様変更により、（ライトニングサービスプロバイダー、LSPなどの）
  ファクトリーマネージャーは、ローカルのファクトリープラグインに渡されるメッセージを
  LNノードに送信できるようになります。多くのファクトリー操作は、
  [スプライシング][topic splicing]の操作に似ているため、
  プラグインはかなりの量のコードを再利用できます。ファクトリー内のLN-Penaltyチャネルの操作は、
  [ゼロ承認チャネル][topic zero-conf channels]に似ているため、
  既存のコードを再利用することもできます。

  ZmnSCPxjの設計は、SuperScalarスタイルのファクトリー（[ニュースレター #327][news327 superscalar]参照）に重点をを置いていますが、
  おそらく他のスタイルのファクトリー（およびおそらく他のマルチマーティコントラクトプロトコル）とも互換性があります。
  Rene Pickhardtは、ファクトリー内のチャネルを[アナウンス][topic channel announcements]できるようにする
  追加の仕様変更について[質問しました][pickhardt plug]が、ZmnSCPxjは、
  仕様変更をできるだけ早く採用できるようにするために、設計では意図的にそれらを考慮しなかったと[答えました][zmnscpxj plug2]。

- **signetのアクティビティレポート:** Anthony Townsは、
  [Bitcoin Inquisition][bitcoin inquisition repo]を介して利用可能な提案中のソフトフォークに関係する
  デフォルト[signet][topic signet]上のアクティビティの概要をDelving Bitcoinに[投稿しました][towns signet]。
  この投稿では、[LN-Symmetry][topic eltoo]のテストや
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]のエミュレーションを含む
  [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]の使用状況を確認しています。
  次に、おそらくいくつかの異なる[Vault][topic vaults]の構成と、いくつかのデータキャリアトランザクションを含む
  `OP_CHECKTEMPLATEVERIFY`の使用状況を直接確認しています。最後に、
  Proof-of-WorkベースのFaucet（[ニュースレター #306][news306 powfaucet]参照）や、
  Vaultまたはその他の[コベナンツ][topic covenants]の可能性があるもの、
  [STARK][]ゼロ知識証明の検証を含む[OP_CAT][topic op_cat]の使用状況を確認しています。

  Vojtěch Strnadは、Townsの投稿に触発されて、
  「デプロイされたソフトフォークを使用するBitcoin signet上で作成された
  [すべてのトランザクション][inquisition.observer]」をリストアップする
  ウェブサイトを作成したと[回答しました][strnad i.o]。

- **LNHANCE提案の更新:** Moonsettlerは、
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]と
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]を含む
  LNHANCEのソフトフォーク提案に追加される新しい`OP_PAIRCOMMIT` opcodeの提案を
  [Delving Bitcoin][moonsettler
  paircommit delving]および[Bitcoin-Dev][moonsettler paircommit list]メーリングリストに投稿しました。
  この新しいopcodeを使用すると、要素のペアに対してハッシュコミットメントを行うことができます。
  これは、提案中の[OP_CAT][topic op_cat]連結opcodeや、
  Elementsベースの[サイドチェーン][topic sidechains]で[使用できる][streaming sha]ストリーミングSHA
  opcodeを使用して実現できることと似ていますが、
  再帰的な[コベナンツ][topic covenants]の有効化を回避するために意図的に制限されています。

  Moonsettlerは、LNHANCEの提案に対するそのほかの小さな潜在的な調整についても
  メーリングリストで[説明しました][moonsettler other lnhance]。

- **<!--covenants-based-on-grinding-rather-than-consensus-changes-->コンセンサスの変更ではなくグラインドベースのコベナンツ:**
  Ethan Heilmanは、Victor Kolobov、Avihu Levy、Andrew Poelstraと共同執筆した[論文][hklp collider]の要約を
  Bitcoin-Devメーリングリストに[投稿しました][heilman collider]。この論文では、
  コンセンサスの変更なしに[コベナンツ][topic covenants]を簡単に作成する方法が説明されていますが、
  コベナンツからの支出には、非標準のトランザクションと数百万ドル（または数十億ドル）相当の特殊なハードウェアと電力が必要になります。
  Heilmanは、この研究の1つの応用として、[量子耐性][topic quantum resistance]が突然必要になり、
  Bitcoinの楕円曲線の署名演算が無効になった場合に安全に使用できる
  バックアップのTaprootの使用条件パスを現在のユーザーが簡単に組み込めるようにすることが挙げられると述べています。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Sparkレイヤー2プロトコルの発表:**
  [Spark][spark website]は、オフチェーンの[ステートチェーン][topic statechains]のようなプロトコルで、
  ライトニングネットワークをサポートします。

- **Unifyウォレットの発表:**
  [Unify][unify github]は、Bitcoin Coreを使用し、nostrを介して[PSBT][topic psbt]の調整をする
  [BIP78][]互換の[Payjoin][topic payjoin]ウォレットです。

- **bitcoinutils.devのローンチ:**
  [bitcoinutils.dev][]ウェブサイトでは、スクリプトのデバッグやさまざまなエンコーディングやハッシュ関数など
  Bitcoinのさまざまなユーティリティを提供します。

- **Great Restored Script Interpreterが利用可能に:**
  [Great Restored Script Interpreter][greatrsi github]は、
  [Great Script Restoration][gsr youtube]提案の実験的なインタプリタです。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #30666][]は、ブロックインデックスを反復処理しベストヘッダーを再計算する
  `RecalculateBestHeader()`関数を追加します。この関数は、`invalidateblock` RPCコマンドや
  `reconsiderblock` RPCコマンドが使用された場合、またはブロックインデックス内の有効なヘッダーが
  完全な検証中に無効であることが判明した場合に、自動的にトリガーされます。これにより、
  これらのイベント後に値が誤ってセットされる問題が修正されます。また、このPRは、
  無効なブロックから拡張されたヘッダーを`BLOCK_FAILED_CHILD`としてマークし、
  `m_best_header`の対象にならないようにします。

- [Bitcoin Core #30239][]は、[エフェメラルダスト][topic ephemeral anchors]アウトプットを標準とし、
  [ダスト][topic uneconomical outputs]アウトプットを持つ手数料ゼロのトランザクションが、
  トランザクション[パッケージ][topic package relay]で同時に使用される場合に、
  mempoolに格納できるようにします。この変更により、コネクターアウトプットや
  キー付きおよびキーなしの（[P2A][topic ephemeral anchors]）アンカーなどの高度な構成のユーザービリティが向上し、
  LNや[Ark][topic ark]、[タイムアウトツリー][topic timeout trees]、
  [BitVM2][topic acc]などのプロトコルの拡張に役立ちます。このアップデートは、
  1P1Cリレーや[TRUC][topic v3 transaction relay]トランザクション、
  [兄弟の排除][topic kindred rbf]など既存の機能に基づいています（[ニュースレター #328][news328 ephemeral]参照）。

- [Core Lightning #7833][]は、[オファー][topic offers]プロトコルをデフォルトで有効にし、
  これまでの実験的ステータスを削除します。これは、
  オファーがBOLTリポジトリにマージされたことによるものです（[ニュースレター #323][news323 offers]参照）。

- [Core Lightning #7799][]は、`askrene`プラグイン（[ニュースレター #316][news316 askrene]参照）と
  `injectpaymentonion` RPCコマンドを使用して、最適な[マルチパスペイメント][topic multipath payments]を構成することで
  支払いを送信する`xpay`プラグインを導入します。このプラグインは、
  [BOLT11][]と[BOLT12][topic offers]の両方のインボイスへの支払い、
  再試行期間と支払い期限の設定、レイヤーを介したルーティングデータの追加および、
  単一のインボイスでマルチパーティが寄与する部分支払いをサポートします。
  このプラグインは、以前の「pay」プラグインよりもシンプルで洗練されていますが、
  そのすべての機能を備えているわけではありません。

- [Core Lightning #7800][]は、CLNノードによって生成されたすべてのビットコインアドレスのリストを返す新しい
  `listaddresses` RPCコマンドを追加します。また、このPRは、
  [アンカーアウトプット][topic anchor outputs]からの支払いおよび
  一方的な閉鎖のお釣り用アドレスのデフォルトのスクリプトタイプとして[P2TR][topic taproot]を設定します。

- [Core Lightning #7102][]は、
  コマンドラインオプションを使用して非対話的に実行できるよう`generatehsm`コマンドを拡張します。
  これまでHSM（Hardware Security Module）のシークレットは、
  ターミナルの対話型プロセスを通じてのみ生成できたため、この変更は自動インストールに特に役立ちます。

- [Core Lightning #7604][]は、bookkeepingプラグインに`bkpr-editdescriptionbypaymentid`
  RPCコマンドと`bkpr-editdescriptionbyoutpoint`RPCコマンドを追加します。これらのコマンドは、
  ペイメントIDまたはOutPointに一致するイベントの説明をそれぞれ更新、設定します。

- [Core Lightning #6980][]は、JSONペイロードまたは
  複雑な[スプライシング][topic splicing]と関連アクションを定義するスプライススクリプトを受け取り、
  これらすべての複数のチャネル操作を1つのトランザクションに統合する新しい`splice`コマンドを導入します。
  このPRでは、ユーザーが[PSBT][topic psbt]に直接インプットを追加できるようにする`addpsbtinput` RPCコマンドも追加されています。
  また、複雑なスプライスアクションを実行する際に重要な、チャネルアクティビティを一時停止したり、
  複数のチャネルを中止して[チャネルコミットメントアップグレード][topic channel commitment upgrades]を有効にしたりできるようにする
  `stfu_channels`RPCコマンドおよび`abort_channels`RPCコマンドも追加されています。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30666,30239,7833,7799,7800,7102,7604,6980,3283" %}
[zmnscpxj plug]: https://delvingbitcoin.org/t/pluggable-channel-factories/1252/
[news327 superscalar]: /ja/newsletters/2024/11/01/#timeout-tree-channel-factories
[pickhardt plug]: https://delvingbitcoin.org/t/pluggable-channel-factories/1252/2
[zmnscpxj plug2]: https://delvingbitcoin.org/t/pluggable-channel-factories/1252/3
[towns signet]: https://delvingbitcoin.org/t/ctv-apo-cat-activity-on-signet/1257
[news306 powfaucet]: /ja/newsletters/2024/06/07/#proof-of-work-op-cat
[stark]: https://en.wikipedia.org/wiki/Non-interactive_zero-knowledge_proof
[moonsettler paircommit delving]: https://delvingbitcoin.org/t/op-paircommit-as-a-candidate-for-addition-to-lnhance/1216
[moonsettler paircommit list]: https://mailing-list.bitcoindevs.xyz/bitcoindev/xyv6XTAFIPmbG1yvB0l2N3c9sWAt6lDTG-xjIbogOZ-lc9RfsFeJ-JPuXuXKzVea8T9TztlCvSrxZOWXKCwogCy9tqa49l3LXjF5K2cLtP4=@protonmail.com/
[streaming sha]: https://github.com/ElementsProject/elements/blob/011feab4c45d6e23985dbd68294e6aeb5a7c0237/doc/tapscript_opcodes.md#new-opcodes-for-additional-functionality
[moonsettler other lnhance]: https://mailing-list.bitcoindevs.xyz/bitcoindev/ZzZziZOy4IrTNbNG@console/
[heilman collider]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAEM=y+W2jyFoJAq9XrE9whQ7EZG4HRST01TucWHJtBhQiRTSNQ@mail.gmail.com/
[hklp collider]: https://eprint.iacr.org/2024/1802
[strnad i.o]: https://delvingbitcoin.org/t/ctv-apo-cat-activity-on-signet/1257/4
[inquisition.observer]: https://inquisition.observer/
[news323 offers]: /ja/newsletters/2024/10/04/#bolts-798
[news316 askrene]: /ja/newsletters/2024/08/16/#core-lightning-7517
[news328 ephemeral]: /ja/newsletters/2024/11/08/#bitcoin-core-pr-review-club
[spark website]: https://www.spark.info/
[unify github]: https://github.com/Fonta1n3/Unify-Wallet
[bitcoinutils.dev]: https://bitcoinutils.dev/
[greatrsi github]: https://github.com/jonasnick/GreatRSI
[gsr youtube]: https://www.youtube.com/watch?v=rSp8918HLnA
