---
title: 'Bitcoin Optech Newsletter #371'
permalink: /ja/newsletters/2025/09/12/
name: 2025-09-12-newsletter-ja
slug: 2025-09-12-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、証明可能な暗号に特化したワークブックを掲載しています。
また、新しいリリースとリリース候補や、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき更新など
恒例のセクションも含まれています。

## ニュース

- **<!--provable-cryptography-workbook-->証明可能な暗号のワークブック:**
  Jonas Nickは、4日間のイベント用に作成した短いワークブックの発表を
  Delving Bitcoinに[投稿しました][nick workbook]。このワークブックは、
  「開発者に証明可能な暗号の基礎を教えるためのもので[...]暗号学の定義、命題、証明および演習で構成されています」。
  ワークブックは[PDF][workbook pdf]で提供され、[ソース][workbook source]はフリーライセンスで公開されています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 29.1][]は、主要なフルノードソフトウェアのメンテナンスバージョンのリリースです。

- [Eclair v0.13.0][]は、このLNノード実装のリリースです。このリリースには、
  「多くのリファクタリング、Taprootチャネルの初期実装、[...]
  最近の仕様の更新に基づいたスプライシングの改善、BOLT12のサポート強化が含まれています。」
  Taprootチャネルとスプライシング機能はまだ仕様策定段階であるため、
  一般のユーザーは使用しないでください。リリースノートには、
  「これはアンカーアウトプットを使用しないチャネルをサポートするEclairの最後のリリースです。
  アンカーアウトプットを使用しないチャネルがある場合は、そのチャネルを閉じてください」という警告も記載されています。

- [Bitcoin Core 30.0rc1][]は、この完全な検証ノードソフトウェアの次期メジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #30469][]は、`m_total_prevout_spent_amount`、
  `m_total_new_outputs_ex_coinbase_amount`および`m_total_coinbase_amount`の値の型を
  `CAmount`（64 bit）から`arith_uint256`（256 bit）に更新し、
  デフォルト[signet][topic signet]で既に確認されている値のオーバーフローによるバグを防止します。
  coinstatsインデックスの新バージョンは、`/indexes/coinstatsindex/`に保存され、
  アップグレードしたノードはインデックスを再構築するために最初から同期する必要があります。
  旧バージョンはダウングレード保護のために保持されますが、将来のアップデートで削除される可能性があります。

- [Eclair #3163][]は、既に許可されているlow-S署名に加えて、
  high-S署名を持つ[BOLT11][]インボイスから受取人の公開鍵を復元できることを確認するためのテストベクトルを追加しました。
  これは、libsecp256k1および提案中の[BOLTs #1284][]の動作と一致します。

- [Eclair #2308][]は、新しい`use-past-relay-data`オプションを導入します。
  これをtrue（デフォルトはfalse）に設定すると、過去の試行履歴に基づく確率的アプローチを使用して経路探索を改善します。
  これは、チャネル残高の均一性を前提としていた従来の手法に代わるものです。

- [Eclair #3021][]は、[デュアルファンドチャネル][topic dual funding]の非開始者が
  ファンディングトランザクションを[RBF][topic rbf]できるようにします。これは既に
  [スプライシング][topic splicing]トランザクションで許可されています。ただし、
  [Liquidity Ads][topic liquidity advertisements]の購入トランザクションには例外が適用されます。
  この機能は、[BOLTs #1236][]で提案されているものです。

- [Eclair #3142][]は、`forceclose` APIエンドポイントに新しい`maxClosingFeerateSatByte`パラメーターを追加します。
  このパラメーターは、チャネル毎に、緊急でない強制クローズトランザクションのグローバルな手数料率設定を上書きします。
  グローバル設定`max-closing-feerate`は、[Eclair #3097][]で導入されました。

- [LDK #4053][]は、2つのアンカーアウトプットを1つの共有
  [P2A（Pay-to-Anchor）][topic ephemeral anchors]アウトプットに置き換え、
  その金額を240 satsに設定することで、手数料ゼロのコミットメントチャネルを導入します。
  さらに、手数料ゼロのコミットメントチャネルの[HTLC][topic htlc]署名を
  `SIGHASH_SINGLE|ANYONECANPAY`に切り替え、
  HTLCトランザクションを[バージョン3][topic v3 transaction relay]にアップグレードします。

- [LDK #3886][]では、2つの`funding_locked_txid` TLV（ノードが最後に送受信した情報）を使用して
  [スプライシング][topic splicing]用の`channel_reestablish`を拡張し、
  ピアが再接続時にアクティブなファンディングトランザクションを照合できるようにしました。
  さらに、`tx_signatures`の前に`commitment_signed`を再送信し、
  暗黙的な`splice_locked`を処理し、`next_funding`を適用し、必要に応じてアナウンス署名を要求することで、
  再接続プロセスを効率化します。

{% include snippets/recap-ad.md when="2025-09-16 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30469,3163,2308,3021,3142,4053,3886,1284,1236,3097" %}
[bitcoin core 29.1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[bitcoin core 30.0rc1]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[nick workbook]: https://delvingbitcoin.org/t/provable-cryptography-for-bitcoin-an-introduction-workbook/1974
[workbook pdf]: https://github.com/cryptography-camp/workbook/releases
[workbook source]: https://github.com/cryptography-camp/workbook
[Eclair v0.13.0]: https://github.com/ACINQ/eclair/releases/tag/v0.13.0
