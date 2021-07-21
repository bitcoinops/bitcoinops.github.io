---
title: 'Bitcoin Optech Newsletter #158'
permalink: /ja/newsletters/2021/07/21/
name: 2021-07-21-newsletter-ja
slug: 2021-07-21-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、サービスとクライアントソフトウェアの最近の変更点や、
ウォレットがTaprootアドレスを生成する前に待つ必要がある理由、
新しいソフトウェアのリリースとリリース候補のリストおよび、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更の要約を掲載しています。

## ニュース

*今週は重要なニュースはありません。*

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Lightning機能搭載のニュースサイトStacker Newsがスタート:**
  LNURL認証やLNマイクロペイメントによる投票やコメントが可能な
  [オープンソースの][stacker news github]ニュースサイト[Stacker News][stacker.news]が開設されました。

- **SuredbitsがDLCウォレットのアルファリリースを発表:**
  [Suredbitsのbitcoin-s][suredbits blog]ソフトウェアには、GIUが含まれ、
  Bitcoinブロックチェーン上でオラクルを使用したDiscreet Log Contracts (DLCs)を実行することができます。
  発表では、[LN互換のDLC][suredbits blog dlcs ln]を実装するために、
  [Schnorr署名][topic schnorr signatures]と
  [Point Time Locked Contracts (PTLCs)][topic ptlc]を使用することも計画していると述べています。

- **Sparrow 1.4.3がP2TRをサポート:**
  Sparrowの[1.4.3リリース][sparrow 1.4.3]は、[signet][topic signet]およびregtestで、
  [シングルシグのP2TRウォレット][taproot series 4]をサポートします。
  このリリースでは、[P2TRのbech32mアドレスへの送信][taproot series 1]もサポートされています。

- **Coldcard FirmwareがSeed XOR機能を追加:**
  Coldcardの[4.1.0 Firmware][coldcard 4.1.0]は、
  各パーツが独自のウォレットとして機能する[BIP39][]シードを分割/結合する方法である[Seed XOR][seed xor]をサポートします。
  XORで結合されたパーツは、ウォレットとしても機能します。
  これにより、ハニーポッド資金やもっともらしい否認などの機能が可能になります。

- **BlueWalletがLightning Dev Kitを統合:**
  BlueWalletは、[Lightning Dev Kit (LDK)][ldk github]を使用する新しいLightning実装への移行を[発表しました][bluewallet ldk tweet]。

## Taprootの準備 #5: なぜ待つ必要があるのか？

*ブロック高{{site.trb}}のTaprootのアクティベーションに向けて、
開発者やサービスプロバイダーがどのような準備をすればよいかについての週刊[シリーズ][series preparing for taproot]です。*

{% include specials/taproot/ja/04-why-wait.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.13.1-beta]は、0.13.0-betaで導入された機能のマイナーな改善とバグ修正を含むメンテナンスリリースです。

- [Rust-Lightning 0.0.99][]は、いくつかのAPIや設定の変更を行ったリリースです。
  詳細は[リリースノート][rl 0.0.99 rn]をご覧ください。

- [Eclair 0.6.1][]は、パフォーマンスの向上や、
  いくつかの新機能、いくつかのバグ修正を含む新しいリリースです。
  その[リリースノート][eclair 0.6.1]に加えて、
  以下の*注目すべき変更*セクションのEclair #1871 と #1846 の説明をご覧ください。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #22112][]では、[I2P][]アドレスの想定ポートを（
  IPv4およびIPv6アドレスのデフォルトである）8333ではなく0に変更し、
  0以外のポートのI2Pアドレス接続を防止しています。
  （Bitcoin Coreがサポートする）[SAM v3.1仕様][sam specification]には、ポートの概念が含まれていません。
  ポートの概念を含むSAM v3.2をサポートするようBitcoin Coreが更新された場合、
  この制限は解除される可能性があります。

- [C-Lightning #4611][]は、プライグインが提供する`keysend` RPCを更新し、
  [未公開のチャネル][topic unannounced channels]に支払いをルーティングするための情報を提供できる`routehints`パラメーターを追加しました。

- [C-Lightning #4646][]は、古い動作の削除にむけて2つの変更を行いました。
  1つめの変更は、ノードが2019年に追加されたTLVスタイルのエンコーディング
  （[ニュースレター #55][news55 tlv]参照）をサポートしていることを前提とします。
  TLVエンコーディングをサポートしていないことを明示的に示すノードのみが異なる方法で処理されます。
  2つめの変更は、ペイメントシークレットが必要になります（以前の議論については[ニュースレター #75][news75 payment secrets]を、
  LNDが要求を開始した時期については[ニュースレター #126][news126 lnd4752]参照）。

- [C-Lightning #4614][]は、`listchannels`RPCを更新し、
  要求されたノードにつながるチャネルのみを返すのに使用できる新しいオプションの`destination`パラメーターを追加しました。

- [Eclair #1871][]では、SQLiteの設定を変更し、
  1秒間に処理できる[HTLC][topic htlc]の数を5倍に増やし、データ損失に対する堅牢性も高めました。
  このPRでは、さまざまなノードソフトウェアのHTLCのスループットを比較したJoost Jagerの[ブログ記事][jager ln perf]を参照しています。

- [Eclair #1846][]では、
  リモートピアが同意する新しいチャネルをネゴシエートする際にノードが指定するアドレスが、
  後でチャネルを協力して閉じる際に使用できる唯一のアドレスとなる
  *upfront shutdown script*を使用するためのオプトインサポートが追加されました。
  この機能のLNDの実装について掲載している[ニュースレター #76][news76 upfront shutdown]もご覧ください。

- [Rust-Lightning #975][]では、
  ベースの支払い転送手数料をデフォルトの1 satoshi（2021年7月の市場レート）で設定できるようにしました。
  LNのルーティングノードは、支払いをルーティングするために固定のベース手数料と
  ルーティングされた金額のパーセンテージの2つの手数料を請求することができ、多くのノードは両方使用します。
  以前のRust-Lightningは、ベース手数料をHTLCをオンチェーンで決済するために必要な推定手数料に設定していましたが、
  これは1 satよりもはるかに高いものでした。

- [BTCPay Server #2462][]では、インスタンスの運用者が自分の個人的なウォレットを使って返金する場合など、
  別のウォレットから行われた支払いを追跡するためにBTCPayを使用するのが容易になりました。

## Footnotes

{% include references.md %}
{% include linkers/issues.md issues="22112,4611,4646,4614,1871,1846,975,2462" %}
[LND 0.13.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.1-beta
[eclair 0.6.1]: https://github.com/ACINQ/eclair/releases/tag/v0.6.1
[news76 upfront shutdown]: /ja/newsletters/2019/12/11/#lnd-3655
[rl 0.0.99 rn]: https://github.com/rust-bitcoin/rust-lightning/blob/main/CHANGELOG.md#0099---2021-07-09
[news55 tlv]: /en/newsletters/2019/07/17/#bolts-607
[news75 payment secrets]: /ja/newsletters/2019/12/04/#c-lightning-3259
[news126 lnd4752]: /en/newsletters/2020/12/02/#lnd-4752
[jager ln perf]: https://bottlepay.com/blog/bitcoin-lightning-node-performance/
[rust-lightning 0.0.99]: https://github.com/rust-bitcoin/rust-lightning/releases/tag/v0.0.99
[I2P]: https://geti2p.net/en/
[sam specification]: https://geti2p.net/en/docs/api/samv3
[stacker news github]: https://github.com/stackernews/stacker.news
[stacker.news]: https://stacker.news/
[suredbits blog]: https://suredbits.com/dlc-wallet-alpha-release/
[suredbits blog dlcs ln]: https://suredbits.com/discreet-log-contracts-on-lightning-network/
[sparrow 1.4.3]: https://github.com/sparrowwallet/sparrow/releases/tag/1.4.3
[taproot series 4]: /ja/preparing-for-taproot/#p2wpkhからシングルシグのp2trへ
[taproot series 1]: /ja/preparing-for-taproot/#bech32m送信のサポート
[coldcard 4.1.0]: https://blog.coinkite.com/version-4.1.0-released/
[seed xor]: https://seedxor.com/
[bluewallet ldk tweet]: https://twitter.com/bluewalletio/status/1414908931902779394
[ldk github]: https://github.com/lightningdevkit
[series preparing for taproot]: /ja/preparing-for-taproot/
