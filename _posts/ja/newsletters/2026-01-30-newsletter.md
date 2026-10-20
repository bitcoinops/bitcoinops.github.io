---
title: 'Bitcoin Optech Newsletter #390'
permalink: /ja/newsletters/2026/01/30/
name: 2026-01-30-newsletter-ja
slug: 2026-01-30-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Garbled Circuitに対するより効率的なアプローチと、
LN-Symmetryの最新情報のリンクを掲載しています。また、Bitcoin Stack Exchangeから厳選された質問とその回答や、
新しいソフトウェアリリースとリリース候補の発表、人気のBitcoin基盤ソフトウェアの注目すべき更新など
恒例のセクションも含まれています。

## ニュース

- **Argo: より効率的なオフチェーン計算を行うGarbled Circuit方式**:
  Robin Linusは、[Garbled Locks][news359 rl garbled]を1,000倍効率化する手法が説明されている
  Liam EagenとYing Tong Laiによる新しい[論文][iacr le ytl garbled]について
  Delving Bitcoinに[投稿しました][delving rl garbled]。この新しい手法では、
  Garbled Circuitのワイヤーを楕円曲線上の点としてエンコードする MAC（メッセージ認証符号）を使用します。
  このMACは準同型になるよう設計されており、Garbled Circuit内の多くの演算を楕円曲線上の点の演算として直接表現できます。
  重要な改良点は、Argoがバイナリ回路ではなく算術回路上で動作することです。バイナリ回路では、
  曲線上の点の乗算を表現するために数百万のバイナリゲートが必要ですが、この算術回路では、単一の算術ゲートのみで済みます。
  今回の論文は、この技術をBitcoin上の[BitVM][topic acc]ライクな構成に適用するために必要な複数のピースの最初のピースになります。

- **LN-Symmetryの最新情報**: Gregory Sandersは、
  これまでの[LN-Symmetry][topic eltoo]に関する研究（[ニュースレター #284][news284 ln sym]参照）のアップデートを
  Delving Bitcoinに[投稿しました][symmetry update]。

  Sandersは、[BOLT仕様][bolts fork]と[CLN実装][cln fork]上の以前のPoCを最新のアップデートにリベースしました。
  更新された実装は、[signet][topic signet]上の[Bitcoin Inquisition][bitcoin inquisition repo] 29.xで、
  [TRUC][topic v3 transaction relay]、[エフェメラルダスト、P2A][topic ephemeral anchors]および
  1P1C[パッケージリレー][topic package relay]とともに動作します。協調的なチャネル閉鎖をサポートし、
  ノードの正常な再起動を妨げていたクラッシュを修正し、テストカバレッジを拡充しました。
  Sandersは他の開発者に対し、signetでBitcoin Inquisitionを使用して新しいPoCをテストするよう呼びかけました。

  Sandersはまた、LLMの機能を活用して、APOから
  OP_TEMPLATEHASH+OP_CSFS+IK（[ニュースレター #365][news365 op proposal]参照）への移行作業を行い、
  [BOLTドラフト][bolt th]を変更し、[CLNベースの実装][cln th]を作成しました。ただし、
  OP_TEMPLATEHASHはBitcoin Inquisitionでまだサポートされていないため、
  このアップデートはregtestでのみテスト可能であると付け加えました。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [dbcacheには何がどのような優先度で保存されますか？]({{bse}}130376)
  Murchは、`dbcache`データ構造の目的を全UTXOセットのサブセットを格納するインメモリキャッシュであると説明し、
  その動作を詳しく説明しています。

- [シールドCSVでCoinjoinを行うことはで可能ですか？]({{bse}}130364)
  Jonas Nickは、シールドCSVプロトコルは現在[Coinjoin][topic coinjoin]をサポートしていないものの、
  [Client-Side Validation][topic client-side validation]プロトコルが本質的にそのような機能を妨げることはないと指摘しています。

- [Bitcoin Coreで、新しいトランザクションのみをブロードキャストするためにTorを使用するにはどうすればよいでしょうか？]({{bse}}99442)
  Vasil Dimovは、この以前の質問をフォローアップし、
  新しい`privatebroadcast`オプション（[ニュースレター #388][news388 private broadcast]参照）を使用することで、
  Bitcoin Coreは短命の[プライバシーネットワーク][topic anonymity networks]接続を通じて
  トランザクションをブロードキャストできると指摘しています。

- [Brassard-Høyer-Tapp (BHT)アルゴリズムとBitcoin (BIP360)]({{bse}}130431)
  ユーザー bca-0353f40e は、Brassard-Høyer-Tapp（BHT）[量子][topic quantum resistance]アルゴリズムを用いた
  [マルチシグ][topic multisignature]アドレスへの衝突攻撃によってSHA256のセキュリティを低下させる能力があったとしても、
  その能力が出現する前に作成されたアドレスには影響しないと説明しています。

- [なぜBitHashはsha256とripemd160を交互に使用するのですか？]({{bse}}130373)
  Sjors Provoostは、[BitVM3][topic acc]のBitHash関数（Bitcoinのスクリプト言語に合わせて調整されたハッシュ関数）の
  背後にある理論的根拠を概説しています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Libsecp256k1 0.7.1][]は、Bitcoin関連の暗号操作のためこのライブラリのメンテナンスリリースです。
  このリリースでは、ライブラリがスタックから秘密情報をクリアしようとするケースを増やすセキュリティの改善が含まれています。
  また、新しい単体テストフレームワークの導入と、いくつかのビルドシステムの変更も行われています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #33822][]は、`libbitcoinkernel` APIインターフェース（[ニュースレター #380][news380 kernel]参照）に
  ブロックヘッダーのサポートを追加しました。新しい`btck_BlockHeader`型とその関連メソッドにより、
  ヘッダーの作成、コピー、破棄が可能になり、ハッシュや前のハッシュ、タイムスタンプ、難易度ターゲット、
  バージョン、nonceなどのヘッダーフィールドを取得できます。新しい
  `btck_chainstate_manager_process_block_header()`メソッドは、
  完全なブロックを必要とせずにブロックヘッダーを検証・処理し、
  `btck_chainstate_manager_get_best_entry()`は累積Proof of Workが最も多いブロックツリーエントリーを返します。

- [Bitcoin Core #34269][]は、`createwallet`RPCと`restorewallet`RPCおよび、
  ウォレットツールの`create`コマンドと`createfromdump`コマンド（ニュースレター
  [#45][news45 wallettool]および[#130][news130 wallettool]参照）を使用する際に、
  名前のないウォレットの作成および復元を禁止しました。
  GUIではすでにこの制限が適用されていましたが、RPCと基盤となる関数には適用されていませんでした。
  ウォレット移行では引き続き名前のないウォレットを復元できます。名前のないウォレットに関連するバグについては、
  [ニュースレター #387][news387 unnamed]をご覧ください。

- [Core Lightning #8850][]は、いくつかの非推奨機能を削除しました。
  [アンカーアウトプット][topic anchor outputs]の変更を反映して
  `option_anchors`に名称変更された`option_anchors_zero_fee_htlc_tx`、
  `decodepay`（`decode`に置き換え）、`close`コマンドレスポンスの`tx`および
  `txid`（`txs`と`txids`に置き換え）、`bcli`プラグインが[手数料の推定][topic fee
  estimation]を返すために使用していた元のレスポンスフォーマットである`estimatefeesv1`。

- [LDK #4349][]は、[BIP173][]で指定されているように、[BOLT12オファー][topic offers]をパースする際の
  [bech32][topic bech32]パディングの検証を追加しました。これまでは、
  LDKは無効なパディングを持つオファーを受け入れていましたが、Lightning-KMPやEclairなどの他の実装は
  正しく拒否していました。新しい`InvalidPadding`エラーが`Bolt12ParseError` enumに追加されました。

- [Rust Bitcoin #5470][]は、有効なBitcoinトランザクションには少なくとも1つのアウトプットが必要であるため、
  アウトプットが0個のトランザクションを拒否する検証をデコーダーに追加しました。

- [Rust Bitcoin #5443][]は、アウトプットの金額の合計が`MAX_MONEY`（2,100万ビットコイン）を超えるトランザクションを
  拒否する検証をデコーダーに追加しました。このチェックは、[CVE-2010-5139][topic cves]に関連しており、
  これは攻撃者が極めて大きなアウトプット金額を持つトランザクションを作成できた歴史的な脆弱性です。

- [BDK #2037][]は、`CheckPoint`構造体のMTP（median-time-past）を計算する`median_time_past()`メソッドを追加しました。
  [BIP113][]で定義されているMTPは、直前11ブロックのタイムスタンプの中央値であり、
  [タイムロック][topic timelocks]の検証に使われます。
  これを可能にする以前の作業については[ニュースレター #372][news372 mtp]をご覧ください。

- [BIPs #2076][]は、ピアが新機能のサポートをアナウンスおよびネゴシエートできるP2P
  featureメッセージを定義した[BIP434][]を追加しました。このアイディアは、
  [BIP339][]のメカニズム（[ニュースレター #87][news87 negotiation]参照）を一般化したものですが、
  各機能毎に新しいメッセージタイプを必要とするのではなく、[BIP434][]は複数のP2Pアップグレードを
  アナウンスおよびネゴシエートするための単一の再利用可能なメッセージを提供します。
  これは[テンプレートの共有][news366 template]を含むさまざまな提案中のP2Pユースケースに恩恵をもたらします。
  メーリングリストでの議論については[ニュースレター #386][news386 feature]をご覧ください。

- [BIPs #1500][]は、支払いトランザクションの指定された部分のハッシュダイジェストをスタックにプッシュする
  [Tapscript][topic tapscript]用の`OP_TXHASH`opcodeを定義する[BIP346][]を追加しました。
  これは、[コベナンツ][topic covenants]の作成やマルチパーティプロトコルにおける対話の削減に使用できます。
  このopcodeは、[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]を一般化したもので、
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]と組み合わせることで
  [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]をエミュレートできます。
  これまでの議論については、ニュースレター[#185][news185 txhash]および[#272][news272 txhash]をご覧ください。

{% include snippets/recap-ad.md when="2026-02-03 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33822,34269,8850,4349,5470,5443,2037,2076,1500" %}
[news359 rl garbled]: /ja/newsletters/2025/06/20/#bitvm
[news369 le garbled]: /ja/newsletters/2025/08/29/#garbled-locks-for-accountable-computing-contracts
[delving rl garbled]: https://delvingbitcoin.org/t/argo-a-garbled-circuits-scheme-for-1000x-more-efficient-off-chain-computation/2210
[iacr le ytl garbled]: https://eprint.iacr.org/2026/049.pdf
[symmetry update]: https://delvingbitcoin.org/t/ln-symmetry-project-recap/359/17
[news284 ln sym]: /ja/newsletters/2024/01/10/#ln-symmetry
[bolts fork]: https://github.com/instagibbs/bolts/tree/eltoo_trucd
[cln fork]: https://github.com/instagibbs/lightning/tree/2026-01-eltoo_rebased
[news365 op proposal]: /ja/newsletters/2025/08/01/#taproot-op-templatehash
[news388 private broadcast]: /ja/newsletters/2026/01/16/#bitcoin-core-29415
[bolt th]: https://github.com/instagibbs/bolts/tree/2026-01-eltoo_th
[cln th]: https://github.com/instagibbs/lightning/commits/2026-01-eltoo_templatehash
[Libsecp256k1 0.7.1]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.7.1
[news380 kernel]: /ja/newsletters/2025/11/14/#bitcoin-core-30595
[news45 wallettool]: /en/newsletters/2019/05/07/#new-wallet-tool
[news130 wallettool]: /en/newsletters/2021/01/06/#bitcoin-core-19137
[news387 unnamed]: /ja/newsletters/2026/01/09/#bitcoin-core
[news372 mtp]: /ja/newsletters/2025/09/19/#bdk-1582
[news87 negotiation]: /ja/newsletters/2020/03/04/#improving-feature-negotiation-between-full-nodes-at-startup
[news386 feature]: /ja/newsletters/2026/01/02/#peer-feature-negotiation
[news366 template]: /ja/newsletters/2025/08/08/#mempool
[news185 txhash]: /ja/newsletters/2022/02/02/#ctv-apo
[news272 txhash]: /ja/newsletters/2023/10/11/#op-txhash