---
title: 'Bitcoin Optech Newsletter #73'
permalink: /ja/newsletters/2019/11/20/
name: 2019-11-20-newsletter-ja
slug: 2019-11-20-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---

今週のニュースレターでは、LNDの新しいマイナーバージョンリリースの発表、開発メーリングリストのダウンタイムの報告、Bitcoinサービスとクライアントの最近の更新についての説明、Bitcoinインフラストラクチャプロジェクトの最近の主な変更点をお送りします。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **LND 0.8.1-betaへのアップグレード：** この[リリース][lnd 0.8.1-beta]では、いくつかのマイナーなバグが修正され、今後のBitcoin Core 0.19リリースとの互換性が追加されます。

## News

- **<!--mailing-list-downtime-->メーリングリストのダウンタイム：** Bitcoin-DevおよびLightning-Devのメーリングリストにおいて、先週、予告なしのサーバー移行の影響で[ダウンタイム][bishop migration]が発生しました。この記事の執筆時点では、両方のメーリングリストは復帰しています。

## Changes to services and client software

*この月刊セクションでは、Bitcoinウォレットとサービスの注目すべきアップデートをお送りしています。*

- **Bitfinex bech32アドレスサポート：** Bitfinexは、[最近のブログ投稿][bitfinex bech32 blog]で、Bitfinex交換所においてネイティブbech32アドレスへの送信をサポートすることを発表しました。 Bitfinexユーザーは以前までP2SH-wrappedのsegwitアドレスを使用できましたが、今後は交換所からネイティブsegwitアドレスへの引き落としが可能です。

- **WasabiのBitcoin Coreノード追加：** Wasabiは、Bitcoin Coreを統合するための継続的な取り組みの一環として、Wasabiインターフェイス内で[Bitcoin Coreノード][wasabi bitcoin core bundle] を実行するためのワンクリックサポートをマージしました。 Bitcoin CoreバイナリはWasabiダウンロードにバンドルされており、PGPはWasabiメンテナーによって検証されています。

## Notable code and documentation changes

*今週の[Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], および [Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #17437][] は、`gettransaction`、`listtransactions`、`listsinceblock` RPCを更新します。返却されたトランザクション情報に収容されたブロックの高さを含めます。

- [C-Lightning #3223][] は、`listpeers` RPCを更新します。チャンネルをが閉じた場合、支払われるべきアドレスを表示します。

- [C-Lightning #3186][] は、C-Lightningの他のバイナリと一緒にビルドされる`hsmtool`という名前の新しい機能を追加します。これは、C-Lightningウォレットを暗号化または復号化し、コミットメントトランザクションに関するプライベートな情報をプリントできます。

- [Eclair #1209][] は、オニオン形式の[トランポリンペイメント][topic trampoline payments]の下書き作成と復号化サポートを追加します。これは、トランポリンペイメントのルーティングサポートを今後実装するPRへの下準備となります。

- [Eclair #1153][]は、[マルチパスペイメント][topic multipath payments]の実験的サポートを追加します。これにより、支払いを2つ以上の異なるルートでの分割した送信が可能になり、複数のオープンチャネルを持つユーザーが各チャネルのファンドを支払いに使うことができます。今後、他のLNソフトウェアが独自でのマルチパスペイメントの実装を取りやめて、（ソフトウェア間の互換性を考慮に入れて）このコードに対して修正を行なっていくことで、分割・ルーティングアルゴリズムのパフォーマンスに関する実データが集積されていくことが期待されています。

{% include linkers/issues.md issues="16442,3649,17437,3223,3186,1209,1153,17449" %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[lnd 0.8.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.8.1-beta
[bishop migration]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002335.html
[bitfinex bech32 blog]: https://www.bitfinex.com/posts/427
[wasabi bitcoin core bundle]: https://github.com/zkSNACKs/WalletWasabi/pull/2495

