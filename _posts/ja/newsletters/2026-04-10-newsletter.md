---
title: 'Bitcoin Optech Newsletter #400'
permalink: /ja/newsletters/2026/04/10/
name: 2026-04-10-newsletter-ja
slug: 2026-04-10-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin Core PR Review Clubミーティングの概要と
人気のBitcoin基盤プロジェクトの注目すべき更新など恒例のセクションを掲載しています。

## ニュース

*今週は、どの[情報源][sources]からも重要なニュースは見つかりませんでした。*

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングの概要をまとめています。*

[Testing Bitcoin Core 31.0 Release Candidates][review club
v31-rc-testing]は、特定のPRをレビューするのではなく、
グループでのテスト活動として開催されたReview Clubのミーティングです。

[Bitcoin Coreのメジャーリリース][major Bitcoin Core release]の前には、
コミュニティによる広範なテストが不可欠だと考えられています。そのため、
ボランティアがリリース候補のテストガイドを執筆し、できるだけ多くの人が
リリースにおける新機能や変更点を個別に調べたり、これらの機能や変更をテストするためのテスト手順を各自で再発明したりすることなく、
生産的にテストができるようにしています。

テストでは、予期しない動作に遭遇した場合、それが実際のバグによるものなのか、
テスト担当者のミスによるものなのかが判断しにくいため、難しい場合があります。
実際にはバグではないものを開発者に報告することは、開発者の時間を浪費することになります。
こうした問題を軽減し、テスト活動を促進するために、特定のリリース候補を対象としてReview Clubのミーティングが開催されます。

[31.0のリリース候補のテストガイド][31.0 testing]は、[svanstaa][gh svanstaa]によって執筆され
（[ポッドキャスト #397][pod397 v31rc1]参照）、同氏はReview Clubミーティングのホストも務めました。

参加者はまた、[31.0のリリースノート][31.0 release notes]を読んでテストのアイディアを得ることも推奨されました。

このテストガイドは、新しいRPCとクラスターの制限を含む[クラスターmempool][topic cluster mempool]
（[ニュースレター #382][news382 bc33629]参照）、プライベートブロードキャスト（[ニュースレター #388][news388 bc29415]参照）、
新しい`coinbase_tx`フィールドが追加されて更新された`getblock` RPC（[ニュースレター #394][news394 bc34512]参照）、
各アウトプットを使用したトランザクションを追跡する新しい`txospenderindex`（[ニュースレター #394][news394 bc24539]参照）、
デフォルトの`-dbcache`サイズの増加（[ニュースレター #396][news396 bc34692]参照）、
ASMapデータの埋め込み（[ニュースレター #394][news394 bc28792]参照）、
新しいREST API`blockpart`エンドポイント（[ニュースレター #386][news386 bc33657]参照）をカバーしています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。*

- [Bitcoin Core #33908][]は、候補ブロックをコンテキストフリーなチェックで検証するため、
  `libbitcoinkernel` C API（[ニュースレター #380][news380 kernel]参照）に
  `btck_check_block_context_free`を追加しました。チェック内容は、
  ブロックのサイズ/ウェイト制限、コインベースのルールおよび、
  chainstate、ブロックインデックス、UTXOセットに依存しないトランザクション毎のチェックです。
  呼び出し側は、このエンドポイントでProof of Workの検証とマークルルートの検証をオプションで有効にできます。

- [Eclair #3283][]は、経路探索に使われる`findroute`、`findroutetonode`、
  `findroutebetweennodes`エンドポイントの完全なフォーマットのレスポンスに
  `fee`フィールド（msats単位）を追加しました。このフィールドは
  経路の合計[転送手数料][topic inbound forwarding fees]を提供し、
  呼び出し側が手動で計算せずに済むようにします。

- [LDK #4529][]は、オペレーターが（チャネルキャパシティの割合として）
  インフライト中のインバウンド[HTLC][topic htlc]の総額を設定する際に、
  アナウンスされたチャネルと[非アナウンスチャネル][topic unannounced channels]に対して異なる上限を設定できるようにしました。
  デフォルトは、アナウンスされたチャネルが25%で、非アナウンスチャネルが100%になっています。

- [LDK #4494][]は、低手数料率における[BIP125][]の置換ルールに準拠するように内部の[RBF][topic rbf]ロジックを更新しました。
  [BOLT2][]で規定されている25/24の手数料率倍率のみを提供するのではなく、
  LDKはその倍率か追加の25 sat/kwuのいずれか大きい方を採用するようになりました。
  関連する仕様の明確化については[BOLTs #1327][]で議論されています。

- [LND #10666][]は、`DeleteForwardingHistory` RPCおよび`lncli deletefwdhistory`コマンドを追加し、
  オペレーターが指定したカットオフタイムスタンプより古い転送イベントを選択的に削除できるようにしました。
  最小1時間の経過時間ガードにより、最新のデータが誤って削除されるのを防ぎます。
  この機能により、ルーティングノードはデータベースをリセットしたりノードをオフラインにしたりすることなく、
  過去の転送記録を削除できます。

- [BIPs #2099][]は、アウトプットスクリプト[ディスクリプター][topic descriptors]のオプションのアノテーション構文を規定した
  [BIP393][]を公開しました。この構文により、ウォレットのスキャン（[サイレントペイメント][topic silent
  payments]のスキャンを含む）を高速化するための誕生ブロック高など、
  ウォレットはリカバリーのヒントを保存できるようになります。このBIPの初期の内容と追加の詳細については
  [ニュースレター #394][news394 bip393]をご覧ください。

- [BIPs #2118][]は、Great Script Restoration（またはGrand Script Renaissance）シリーズ（[ニュースレター
  #399][news399 bips]参照）のBIPのドラフトとして[BIP440][]と[BIP441][]を公開しました。
  [BIP440][]はScriptランタイム制約用のvaropsバジェット（[ニュースレター #374][news374 varops]参照）を提案し、
  [BIP441][]は2010年に無効化された[OP_CAT][topic op_cat]などのopcodeを復活させ（[ニュースレター #374][news374 tapscript]参照）、
  BIP440で導入されたvaropsバジェットに基づいてスクリプトの評価コストを制限する
  新しい[Tapscript][topic tapscript]バージョンについて説明しています。

- [BIPs #2134][]は、[BIP352][]（[サイレントペイメント][topic silent payments]）を更新し、
  [ダスト][topic uneconomical outputs]などのポリシーフィルタリングが、
  一致が見つかった後のスキャンの継続に影響を与えないようにウォレット開発者に警告しています。
  フィルタで除外されたアウトプットを一致がなかったものとして扱うと、ウォレットがスキャンを早期に停止し、
  同じ送信者からの後続のアウトプットを見逃す可能性があります。

{% include snippets/recap-ad.md when="2026-04-14 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33908,3283,4529,4494,10666,2099,2118,2134,1327,33629,29415,34512,24539,34692,28792,33657" %}
[sources]: /ja/internal/sources/
[news380 kernel]: /ja/newsletters/2025/11/14/#bitcoin-core-30595
[news394 bip393]: /ja/newsletters/2026/02/27/#bip
[news399 bips]: /ja/newsletters/2026/04/03/#varops-tapscript-0xc2-script-restoration-bip-440-441
[news374 varops]: /ja/newsletters/2025/10/03/#first-bip
[news374 tapscript]: /ja/newsletters/2025/10/03/#second-2-bip
[BIP393]: https://github.com/bitcoin/bips/blob/master/bip-0393.mediawiki
[BIP440]: https://github.com/bitcoin/bips/blob/master/bip-0440.mediawiki
[BIP441]: https://github.com/bitcoin/bips/blob/master/bip-0441.mediawiki
[review club v31-rc-testing]: https://bitcoincore.reviews/v31-rc-testing
[major bitcoin core release]: https://bitcoincore.org/ja/lifecycle/#versioning
[31.0 release notes]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/31.0-Release-Notes-Draft
[31.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/31.0-Release-Candidate-Testing-Guide
[gh svanstaa]: https://github.com/svanstaa
[pod397 v31rc1]: /en/podcast/2026/03/24/#bitcoin-core-31-0rc1-transcript
[news382 bc33629]: /ja/newsletters/2025/11/28/#bitcoin-core-33629
[news388 bc29415]: /ja/newsletters/2026/01/16/#bitcoin-core-29415
[news394 bc34512]: /ja/newsletters/2026/02/27/#bitcoin-core-34512
[news394 bc24539]: /ja/newsletters/2026/02/27/#bitcoin-core-24539
[news396 bc34692]: /ja/newsletters/2026/03/13/#bitcoin-core-34692
[news394 bc28792]: /ja/newsletters/2026/02/27/#bitcoin-core-28792
[news386 bc33657]: /ja/newsletters/2026/01/02/#bitcoin-core-33657
