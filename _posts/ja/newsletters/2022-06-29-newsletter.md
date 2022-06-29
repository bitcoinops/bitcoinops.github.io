---
title: 'Bitcoin Optech Newsletter #206'
permalink: /ja/newsletters/2022/06/29/
name: 2022-06-29-newsletter-ja
slug: 2022-06-29-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、Bitcoin Stack Exchangeの人気のある質問と回答の要約、
新しいソフトウェアリリースとリリース候補の発表、
Bitcoinインフラストラクチャソフトウェアの最近の変更など恒例のセクションを掲載しています。

## ニュース

*今週は、Bitcoin-DevメーリングリストやLightning-Devメーリングリストには目立ったニュースはありませんでした。*

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--what-is-the-purpose-of-indexing-the-mempool-by-these-five-criteria-->5つの基準でmempoolをインデックス化する目的は何ですか？]({{bse}}114216)
  Murchとglozowは、Bitcoin Coreの異なるmempoolのトランザクションインデックス
  （txid, wtxid, mempool内の時間、祖先の手数料率、子孫の手数料率）とその使用方法について説明しています。

- [<!--bip-341-should-key-path-only-p2tr-be-eschewed-altogether-->key-pathのみのP2TRは完全に避けるべきですか？]({{bse}}113989)
  Pieter Wuilleは、4つの[Taproot][topic taproot]のkeypath支払いオプションを定義し、
  BIP341が「noscript」オプションを[推奨する][bip41 constructing]理由を説明し、
  他のシナリオが好まれる可能性があるシナリオを指摘しています。

- [<!--was-the-addition-of-op-nop-codes-in-bitcoin-0-3-6-a-hard-or-soft-fork-->Bitcoin 0.3.6におけるOP_NOPコードの追加はハードフォークですか？それともソフトフォークですか？]({{bse}}113994)
  Pieter Wuilleは、Bitcoin Core 0.3.6における[`OP_NOP`コード][wiki reserved words]の追加は、
  旧バージョンのソフトウェアが新しく有効になった`OP_NOP`コードを使用したトランザクションを無効とみなすため、
  後方互換のないコンセンサスの変更であったと説明しています。
  しかし、これらの`OP_NOP`コードを使用したトランザクションがそれまでマイニングされていなかったため、実際のフォークは発生しませんでした。

- [<!--what-is-the-largest-multisig-quorum-currently-possible-->現在可能なマルチシグの最大の定足数はいくつですか？]({{bse}}114048)
  Andrew Chowは、考えられるさまざまなマルチシグのタイプ（素のScript、P2SH、P2WSH、P2TR、P2TR＋[MuSig][topic musig]）と、
  それぞれのマルチシグの定足数の制限をリストアプしています。

- [<!--what-is-the-difference-between-blocksonly-and-block-relay-only-in-bitcoin-core-->Bitcoin Coreのblocksonlyとblock-relay-onlyの違いは何ですか？]({{bse}}114081)
  Lightlikeは、block-relay-only接続と`-blocksonly`モードで動作しているノードの違いをリストアップしています。

- [<!--where-are-bips-40-and-41-->BIP 40と41はどこにありますか？]({{bse}}114168)
  ユーザーandrewzは、Stratumワイヤープロトコルに割り当てられたBIP40とStratumマイニングプロトコルに割り当てられたBIP41について、
  [割り当てられたBIP番号][assigned BIP numbers]に対するコンテンツが無い理由を尋ねました。
  [別の回答][se 114179]で、Michael Folksonが作業中のStratumのドキュメントをリンクしています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.15.0-beta][]は、この人気のLNノードの次のメジャーバージョンのリリースです。
  他のプログラム（そして潜在的にはLNDの将来のバージョン）が
  [ステートレスインボイス][topic stateless invoices]をで使用できるメタデータを追加し、
  実験的な[MuSig2][topic musig]のサポートと共に、
  [P2TR][topic taproot]のkeypath支払いに対してビットコインを送受信するための内部ウォレットのサポートを追加しています。

- [Core Lightning 0.11.2][]は、このLNノードのバグ修正のリリースです。
  Core Lightningの開発者は、アップグレードを「強く推奨」しています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Core Lightning #5306][]は、複数のAPIを更新し、millisatoshisの名称を「msat」に統一し、
  これらのフィールドのJSONの値を数値で返すようになりました。
  いくつかのフィールドが、他のフィールドとの一貫性のため名称が変更されています。
  旧来の動作は非推奨になりますが、まだ一時的に利用可能です。

- [LDK #1531][]は、LNのファンディング・トランザクションのために[アンチ・フィー・スナイピング][topic fee sniping]の使用を開始しました。

{% include references.md %}
{% include linkers/issues.md v=2 issues="5306,1531" %}
[lnd 0.15.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta
[core lightning 0.11.2]: https://github.com/ElementsProject/lightning/releases/tag/v0.11.2
[bip41 constructing]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#user-content-constructing_and_spending_taproot_outputs
[wiki reserved words]: https://en.bitcoin.it/wiki/Script#Reserved_words
[se 114179]: https://bitcoin.stackexchange.com/a/114179/87121
[assigned bip numbers]: https://github.com/bitcoin/bips#readme
