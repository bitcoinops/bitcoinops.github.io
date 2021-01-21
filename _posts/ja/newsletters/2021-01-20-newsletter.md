---
title: 'Bitcoin Optech Newsletter #132'
permalink: /ja/newsletters/2021/01/20/
name: 2021-01-20-newsletter-ja
slug: 2021-01-20-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Payjoinの採用やハードウェアウォレットをより高度なBitcoinの機能と互換性のあるものにすることについて、
Bitcoin-Devメーリングリストへの投稿をまとめています。また、サービスやクライアントソフトウェアの変更点、新しいリリースやリリース候補、
人気のあるBitcoinインフラストラクチャソフトウェアの変更点などの概要をまとめた通常のセクションも含まれます。

## ニュース

- **Payjoinの採用:** Chris Belcherは、Payjoinの送信や受信をサポートするプロジェクトを追跡する[wikiページ][payjoin wiki]と共に、
  [Payjoin][topic payjoin]の採用を増やすための方法があるかどうかBitcoin-Devメーリングリストに[投稿しました][belcher payjoin]。
  Craig Rawによる[提案][raw payjoin]の１つは、受信者がサーバーを運用していなくても機能するようにプロトコルを拡張することでした。

- **ハードウェアウォレットをBitcoinのより高度な機能と互換性のあるものにする:**
  Kevin Loaecは、単一の署名やマルチシグよりも複雑なスクリプトを扱えるようにハードウェアウォレットをどう変更できるかについて、
  Bitcoin-Devメーリングリストで[議論を開始しました][loaec hww]。例えば、ハードウェアウォレットでインチャネルのLN支払いや、
  [vault][topic vaults]からの支払いを扱えるようにすることです。彼の投稿は、最近のハードウェアウォレットが扱えないさまざまな問題を
  うまく説明していますが、必要な「変更は非常に難しいかもしれない」と指摘しています。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **BlockstreamがJadeハードウェアウォレットを発表:**
  Blockstreamの[新しいJadeハードウェアウォレット][blockstream jade blog]はオープンソースで、
  BitcoinとLiquidネットワークをサポートし、Android用のBlockstream Greenと互換性があります。

- **ColdcardがPayjoin署名を追加:**
  Coldcardの[3.2.1のリリース][coldcard 3.2.1]では、[BIP78][] Payjoin署名のサポートと、
  さまざまなマルチシグの改善が追加されています。

- **Mempool v2.0.0 リリース:**
  [mempool.space][mempool.space website]ウェブサイトをサポートするオープンソースの
  [ブロックエクスプローラー][topic block explorers] mempoolは、[バージョン 2.0.0][mempool v2]をリリースしました。
  mempoolはBitcoin Core、ElectrumおよびEsploraのバックエンドをサポートしており、
  APIを介してブロック、トランザクション、アドレスの情報を公開しています。

- **BlueWalletがマルチシグを追加:**
  [BlueWalletのバージョン6.0.0 ][bluewallet 6.0.0. tweet]では、
  エアギャップでnative segwitマルチシグのvaultを作成し管理する機能が追加されました。

- **SparrowがBitcoin Coreへの接続をサポート:**
  [Sparrow 0.9.10][sparrow 0.9.10]では、[Bitcoin Wallet Tracker v0.2.1][bwt 0.2.1]の
  Java Native Interfaceバインディング機能を使って、Bitcoin Coreノードへの直接接続をサポートするようになりました。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 0.21.0][Bitcoin Core 0.21.0]はこのフルノード実装の次のメジャーバージョンと
  それに関連するウォレットと他のソフトウェアの次のメジャーバージョンです。
  [バージョン2 アドレス通知メッセージ][topic addr v2]を使用した新しいTor onionサービスのサポートや、
  [compact block filters][topic compact block filters]を提供するオプション、
  （[taproot][topic taproot]が有効になったデフォルトsignetを含む）[signet][topic signet]のサポートなどが
  主な新機能になります。また、[output script descriptor][topic descriptors]をネイティブに使用するウォレットの
  実験的なサポートも提供しています。変更点の完全なリストについては[リリースノート][bcc 0.21.0 notes]を参照してください。

- [Rust Bitcoin 0.26.0][]は、このライブラリの新しいリリースです。主な新機能には、signetのサポート、
  バージョン2 アドレス通知メッセージおよび[PSBT][topic psbt]のハンドリングの改善などが含まれています。
  詳細は、[リリースノート][rb notes]を参照してください。

- [BTCPay Server 1.0.6.7][]は、先週リリースされた[1.0.6.5][btcpay server 1.0.6.5]への2回目のメンテナンスリリースで、
  "ウォレットセットアップでのoutput descriptorサブセットのサポート"が追加されました
  （以下の*注目すべき変更点*のセクションを参照）。その他の機能やBug Fixも含まれています。

- [C-Lightning 0.9.3rc2][c-lightning 0.9.3]は、このLNノードの次のマイナーバージョンのリリース候補です。

- [LND 0.12.0-beta.rc5][LND 0.12.0-beta] は、このLNノードの次のメジャーバージョンの最新のリリース候補です。

## 注目すべきコードとドキュメントの変更

今週の[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、
[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。

- [Bitcoin Core #19937][]では、[signet][topic signet]ブロックをマイニングするための`miner`スクリプトと
  新しいスタンドアロンの`bitcoin-util`実行ファイルが追加され、新しいsignetネットワークの作成、維持を容易にします。
  また、新しいツール用の広範な[ドキュメント][signet miner tool docs]も含まれています。

- [LND #4917][]は、デフォルトで[anchor output][topic anchor outputs]を無効にします。
  この機能は次の0.12.0-betaでリリースされる予定の機能です。上級ユーザーは、引き続きオプトインでanchorを使用できます。
  コミットメッセージには、"the plan is to enable anchors by default [in a later release]."と記されています。

- [Rust-Lightning #742][]は、署名者が追加のチェックをして署名を提供するために必要なトランザクション毎の情報を提供することで、
  署名者のAPIを改善します。このPRは[ここ][Rust-Lightning #408]のRust-Lightningの外部署名者をサポートするためのより大きな取り組みの一部です。

- [BTCPay Server #2169][]では、[44][BIP44] (P2PKH HDウォレット)、[45][BIP45] (P2SH マルチシグHDウォレット)、
  [49][BIP49] (P2SH-P2WPKH HDウォレット)に従って作成されたウォレットを参照する[output script descriptor][topic descriptors]のデコードをサポートをする機能と、
  他のマルチシグの導出（P2SH-P2WSHおよびP2WSHを使用するためのドキュメント化されていない拡張を含む）のための[BIP44の修正案][bips #253]が追加されています。

{% include references.md %}
{% include linkers/issues.md issues="19937,4917,742,2169,253,408" %}
[bitcoin core 0.21.0]: https://bitcoincore.org/bin/bitcoin-core-0.21.0/
[bcc 0.21.0 notes]: https://bitcoincore.org/en/releases/0.21.0/
[lnd 0.12.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.12.0-beta.rc5
[rust bitcoin 0.26.0]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/0.26.0
[rb notes]: https://github.com/apoelstra/rust-bitcoin/blob/010068ba321268704bc9da9fe311b45b9c0937b6/CHANGELOG.md#0260---2020-12-21
[btcpay server 1.0.6.7]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.0.6.7
[btcpay server 1.0.6.5]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.0.6.5
[c-lightning 0.9.3]: https://github.com/ElementsProject/lightning/releases/tag/v0.9.3rc2
[belcher payjoin]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-January/018356.html
[raw payjoin]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-January/018358.html
[payjoin wiki]: https://en.bitcoin.it/wiki/PayJoin_adoption
[loaec hww]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-January/018352.html
[blockstream jade blog]: https://blockstream.com/2021/01/03/en-secure-your-bitcoin-and-liquid-assets-with-blockstream-jade/
[coldcard 3.2.1]: https://blog.coinkite.com/version-3.2.1-released/
[mempool.space website]: https://mempool.space/
[mempool v2]: https://github.com/mempool/mempool/releases/tag/v2.0.0
[bluewallet 6.0.0. tweet]: https://twitter.com/bluewalletio/status/1338943580245790722
[sparrow 0.9.10]: https://github.com/sparrowwallet/sparrow/releases/tag/0.9.10
[bwt 0.2.1]: https://github.com/bwt-dev/bwt/releases/tag/v0.2.1
[signet miner tool docs]: https://github.com/bitcoin/bitcoin/blob/43f3ada27b835e6b198f9a669e4955d06f5c4d08/contrib/signet/README.md#miner
