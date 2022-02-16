---
title: 'Bitcoin Optech Newsletter #187'
permalink: /ja/newsletters/2022/02/16/
name: 2022-02-16-newsletter-ja
slug: 2022-02-16-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、BitcoinにおけるCovenantの議論の続きと、
サービスやクライアントソフトウェアの変更や
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点などをまとめた恒例のセクションを掲載しています。

## ニュース

- **`OP_TXHASH`の簡略化された代替案:**
  [Covenant][topic covenants]を有効にするopcodeに関する継続的な議論で（[ニュースレター #185][news185 composable]参照）、
  Rusty Russellは、`OP_TXHASH`によって提供される機能は、
  既存の`OP_SHA256`opcodeと`OP_TXHASH`と同じインプットを受け入れる新しい`OP_TX`opcodeで提供できると[提案しました][russell op_tx]。
  この新しいopcodeは、支払いトランザクションからシリアライズされたフィールドを[Tapscript][topic tapscript]で利用できるようにします。
  そしてScriptはフィールドを直接テストするか（例えば、トランザクションのversionが`1`より大きいか？など）、
  データをハッシュして以前提案された[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] opcodeで署名と比較します。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Blockchain.comのウォレットがTaprootへの送信を追加:**
  Android用のBlockchain.comのウォレット[v202201.2.0(18481)][blockchain.com v202201.2.0(18481)]で、
  [bech32m][topic bech32]アドレスへの送信のサポートが追加されました。
  執筆時点では、iOS版のウォレットはまだbech32mアドレスへの送信をサポートしていません。

- **Lightningノード実装Senseiがローンチ:**
  現在ベータ版の[Sensei][sensei website]は、
  [Bitcoin Dev Kit (BDK)][bdk website]と[Lightning Dev Kit (LDK)][ldk website]を使用して構築されています。
  このノードには、現在Bitcoin CoreとElectrumサーバーが必要ですが、追加のバックエンドオプションも計画されています。

- **BitMEXがTaprootへの送信を追加:**
  最近の[ブログ記事][bitmex blog]で、BitMEXはbech32mへの引き出しのサポートを発表しました。
  また記事では、[BitMEXユーザーの入金][news141 bitmex bech32 receive]の73%がP2WSHアウトプットで受け取られ、
  約65%の手数料の節約になっていると述べています。

- **BitBox02がTaprootへの送信を追加:**
  [v9.9.0 - Multi][bitbox02 v9.9.0 multi]と[v9.9.0 - Bitcoin-only][bitbox02 v9.9.0 bitcoin]の両方のリリースで、
  bech32mアドレスへの送信のサポートが追加されています。

- **Fulcrum 1.6.0がパフォーマンスを改善:**
  アドレスのインデックスソフトウェアFulcrumは、
  [1.6.0のリリース][fulcrum 1.6.0]で[パフォーマンスが向上][sparrow docs performance]しました。

- **KrakenがProof of Reservesスキームを発表:**
  Krakenは、信頼できる監査人を含むProof of Reserveについて[詳しく説明し][kraken por]、
  欠点と将来の改善についても言及しています。Krakenは、オンチェーンアドレスの所有権を証明するデジタル署名を作成し、
  Krakenのユーザーのアカウント残高でマークルツリーを生成し、
  オンチェーン残高がユーザーのアカウント残高より大きいこと監査人に確認するよう依頼し、
  ユーザーが自分の残高がツリー内に含まれていることを検証するためのツールを提供します。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Eclair #2164][]では、さまざまなコンテストにおけるfeature bitの処理が改善されました。
  特に、インボイス以外の機能を必要とするインボイスが拒否されなくなりました。
  これはインボイス以外の機能がサポートされていなくてもインボイスの履行に影響を与えないためです。

- [BTCPay Server #3395][]は、
  ウォレットによって送信されたインボイスおよびトランザクションに対して受信された
  [CPFP][topic cpfp]による手数料引き上げ支払いのサポートを追加しました。

- [BIPs #1279][]は、[一般的なsignmessageプロトコル][topic generic signmessage]の[BIP322][]仕様を更新し、
  いくつかの明確化とTest Vectorを追加しました。

{% include references.md %}
{% include linkers/issues.md v=1 issues="2164,3395,1279" %}
[russell op_tx]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019871.html
[news185 composable]: /ja/newsletters/2022/02/02/#ctv-apo
[blockchain.com v202201.2.0(18481)]: https://github.com/blockchain/My-Wallet-V3-Android/releases/tag/v202201.2.0(18481)
[sensei website]: https://l2.technology/sensei
[bdk website]: https://bitcoindevkit.org/
[ldk website]: https://lightningdevkit.org/
[bitmex blog]: https://blog.bitmex.com/bitmex-supports-sending-to-taproot-addresses/
[news141 bitmex bech32 receive]: /ja/newsletters/2021/03/24/#bitmex-announces-bech32-support-bitmex-bech32
[bitbox02 v9.9.0 multi]: https://github.com/digitalbitbox/bitbox02-firmware/releases/tag/firmware%2Fv9.9.0
[bitbox02 v9.9.0 bitcoin]: https://github.com/digitalbitbox/bitbox02-firmware/releases/tag/firmware-btc-only%2Fv9.9.0
[fulcrum 1.6.0]: https://github.com/cculianu/Fulcrum/releases/tag/v1.6.0
[sparrow docs performance]: https://www.sparrowwallet.com/docs/server-performance.html
[kraken por]: https://www.kraken.com/proof-of-reserves
