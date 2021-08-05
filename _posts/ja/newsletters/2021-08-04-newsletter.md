---
title: 'Bitcoin Optech Newsletter #160'
permalink: /ja/newsletters/2021/08/04/
name: 2021-08-04-newsletter-ja
slug: 2021-08-04-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Taprootの準備方法、最新のリリースとリリース候補の要約、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更など、
恒例のセクションを掲載しています。

## ニュース

*今週は重要なニュースはありません。*

## Taprootの準備 #7: マルチシグ

*ブロック高{{site.trb}}のTaprootのアクティベーションに向けて、
開発者やサービスプロバイダーがどのような準備をすればよいかについての週刊[シリーズ][series preparing for taproot]です。*

{% include specials/taproot/ja/06-multisignatures.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [C-Lightning 0.10.1rc2][C-Lightning 0.10.1]は、
  いくつかの新機能やバグ修正、（[デュアル・ファンディング][topic dual funding]や[Offer][topic offers]を含む）
  開発中のプロトコルのいくつかの更新を含むアップグレードのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #22006][]では、[Bitcoin Core #19866][]で追加されたUser-Space、
  Statically Defined Tracing (USDT)
  および最初の３つのトレースポイントのビルドサポートおよびマクロの[ドキュメント][tracing doc]が追加されました。
  eBPFトレースを有効にしてBitcoin Coreをビルドしたユーザーは、
  提供されている[サンプルスクリプト][contrib tracing doc]や独自のトレーススクリプトを記述してトレースポイントにフックし、
  新しいブロックが接続され際や、インバウンドのP2Pメッセージを受信した際、
  アウトバウンドのP2Pメッセージが送信された際にノードの観測性を高めることができます。
  このドキュメントには、使用例や新しいトレースポイントを追加するためのガイドラインも含まれています。

- [Eclair #1893][]では、[未公開のチャネル][topic unannounced channels]や公開されているチャネル、
  [トランポリンリレー][topic trampoline payments]の最小値について、
  それぞれ別の手数料率を設定できるようになりました。
  また、このPRでは、未公開のチャネル(0.01%)と公開されているチャネル(0.02%)とで、
  異なるデフォルト手数料率が設定されています。

- [Rust-Lightning #967][]では、`send_spontaneous_payment`関数呼び出しによる
  [keysend形式のSpontaneous payment][keysend onion]をサポートしました。
  この変更により、我々がカバーする4つのLN実装すべてがkeysendをサポートすることになります。

  著者は、[BLIP][news156 blips] (Bitcoin Lightning Improvement Proposals)として、
  keysend支払いに関して[対応するドキュメント][BOLTs #892]（まだマージされていません）も提出しています。
  これはLN BOLTの仕様の一部に属さない機能やベストプラクティスをドキュメント化するために提案された方法です。

{% include references.md %}
{% include linkers/issues.md issues="22006,19866,1893,967,892" %}
[C-Lightning 0.10.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.1rc2
[tracing doc]: https://github.com/bitcoin/bitcoin/blob/8f37f5c2a562c38c83fc40234ade9c301fc4e685/doc/tracing.md
[contrib tracing doc]: https://github.com/bitcoin/bitcoin/tree/8f37f5c2a562c38c83fc40234ade9c301fc4e685/contrib/tracing
[keysend onion]: /en/topics/spontaneous-payments/#add-data-to-the-routing-packet
[news156 blips]: /ja/newsletters/2021/07/07/#blip
[series preparing for taproot]: /ja/preparing-for-taproot/
