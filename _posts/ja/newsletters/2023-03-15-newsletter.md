---
title: 'Bitcoin Optech Newsletter #242'
permalink: /ja/newsletters/2023/03/15/
name: 2023-03-15-newsletter-ja
slug: 2023-03-15-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、Utreexoのテストに使用されるサービスビットに関する発表と、
いくつかの新しいソフトウェアリリースとリリース候補のリンクおよび、
マージされたBitcoin Coreのプルリクエストを掲載しています。

## ニュース

- **Utreexoのサービスビット:** Calvin Kimは、
  現在signetとtestnetで実験用に設計されているソフトウェアがP2Pプロトコルのサービスビット 24を使用することを
  Bitcoin-Devメーリングリストに[投稿しました][kim utreexo]。
  この実験用のソフトウェアは、UTXOセットのコピーを保存しないノードによるトランザクションの完全な検証を可能にするプロトコルである
  [Utreexo][topic utreexo]をサポートしており、最新のBitcoin Coreフルノードと比較して
  （セキュリティを低下させることなく）最大5GBのディスク領域を節約することができます。
  Utreexoノードは、未承認トランザクション（または承認済みトランザクションでいっぱいのブロック）を受信した際に追加データを受け取る必要があるため、
  サービスビットはノードが追加データを提供できるピアを見つけるのに役立ちます。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning v23.02.2][]は、このLNノードソフトウェアのメンテナンスリリースです。
  このリリースでは、他のソフトウェアで問題が発生した`pay` RPCの変更を元に戻し、
  その他いくつかの変更が含まれています。

- [Libsecp256k1 0.3.0][]は、この暗号ライブラリのリリースです。
  ABIの互換性を損なうAPIの変更が含まれています。

- [LND v0.16.0-beta.rc3][]は、この人気のLN実装の新しいメジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #25740][]では、[assumeUTXO][topic assumeutxo]を使用するノードが、
  assumeUTXOの状態が生成されたブロックに到達するまで、
  ベストブロックチェーン上のすべてのブロックとトランザクションを検証し、
  そのブロック時点でのUTXOセット（chainstate）を構築できるようにします。
  そのchainstateがノードの初回起動時にダウンロードしたassumeUTXOの状態と等しい場合、
  その状態は完全に検証されたことになります。ノードは、他のフルノードと同じように、
  ベストブロックチェーン上のすべてのブロックを検証したことになります。
  古いブロックの検証を行うために使用された特別なchainstateは、ノードの次回起動時に削除され、ディスク領域が開放されます。
  [assumeUTXOプロジェクト][assumeUTXO project]には、使用可能になるまでにまだマージする必要がある内容が残っています。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25740" %}
[lnd v0.16.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc3
[libsecp256k1 0.3.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.3.0
[core lightning v23.02.2]: https://github.com/ElementsProject/lightning/releases/tag/v23.02.2
[kim utreexo]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-March/021515.html
[assumeutxo project]: https://github.com/bitcoin/bitcoin/projects/11
