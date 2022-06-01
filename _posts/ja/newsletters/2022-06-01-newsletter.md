---
title: 'Bitcoin Optech Newsletter #202'
permalink: /ja/newsletters/2022/06/01/
name: 2022-06-01-newsletter-ja
slug: 2022-06-01-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Silent Paymentに取り組む開発者の実験を掲載しています。
また、新しいリリースおよびリリース候補の概要に加えて、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点など恒例のセクションも含まれています。

## ニュース

- **Silent Paymentの実験:** [ニュースレター #194][news194 silent]に掲載したように、
  *Silent Payment*は、支払われたアドレスの公開記録を作成することなく、
  公開識別子（アドレス）への支払いを可能にします。
  今週、開発者のw0xltはBitcoin-Devメーリングリストに、
  Bitcoin Coreの概念実証の[実装][bitcoin core #24897]を使用して、
  デフォルト[signet][topic signet]でSilent Paymentを作成するための[チュートリアル][sp tutorial]を[投稿しました][w0xlt post]。
  人気のあるウォレットの作者を含む他の複数の開発者は、
  Silent Payment用の[アドレスフォーマットの作成][sp address]など、
  この提案の他の詳細について議論しています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [HWI 2.1.1][]は、LedgerおよびTrezorデバイスに影響する軽微なバグを修正し、
  Ledger Nano S Plusのサポートを追加しています。

- [LND 0.15.0-beta.rc3][]は、この人気のあるLNノードの次のメジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [BTCPay Server #3772][]は、リリース前のライブテスト用に実験的な機能を有効にすることができるようになりました。

- [BTCPay Server #3744][]は、ウォレットのトランザクションをCSVまたはJSONフォーマットでエクスポートする機能を追加しました。

- [BOLTs #968][]は、Bitcoinのtestnetとsignetを使用するノード用にデフォルトのTCPポートを追加しました。

{% include references.md %}
{% include linkers/issues.md v=2 issues="3772,3744,968,24897" %}
[lnd 0.15.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta.rc3
[hwi 2.1.1]: https://github.com/bitcoin-core/HWI/releases/tag/2.1.1
[news194 silent]: /ja/newsletters/2022/04/06/#delinked-reusable-addresses
[w0xlt post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020513.html
[sp tutorial]: https://gist.github.com/w0xlt/72390ded95dd797594f80baba5d2e6ee
[sp address]: https://gist.github.com/RubenSomsen/c43b79517e7cb701ebf77eec6dbb46b8?permalink_comment_id=4177027#gistcomment-4177027
