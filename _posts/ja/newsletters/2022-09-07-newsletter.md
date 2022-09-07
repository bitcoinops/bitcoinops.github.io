---
title: 'Bitcoin Optech Newsletter #216'
permalink: /ja/newsletters/2022/09/07/
name: 2022-09-07-newsletter-ja
slug: 2022-09-07-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、人気のあるBitcoinインフラストラクチャソフトウェアについて、いくつかの注目すべき変更点を掲載しています。

## ニュース

*今週は重要なニュースはありませんでした。*

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #25717][]は、サービス拒否（DoS）攻撃を防止し、チェックポイントを削除するためのステップとして、
  IBD（Initial Block Download）中に「Headers Presync」ステップを追加しました。
  事前同期フェーズを使用するノードは、ピアのヘッダーチェーンに十分な作業量があることを検証してからそれらを永続的に保存します。

  IBDの間、敵対的なピアは、同期プロセスを停止させようとしたり、
  最も作業量のあるチェーンに繋がらないブロックを提供したり、単にノードのリソースを使い果たしたりしようとする可能性があります。
  同期速度と帯域幅の使用量はIBD中の重要な懸念事項ですが、設計上の一番の目標はサービス拒否攻撃を回避することです。
  v0.10.0以降のBitcoin Coreノードは、ブロックをダウンロードする前にまずブロックヘッダーを同期し、
  チェックポイントのセットに接続されないブロックヘッダーを拒否します。
  この新しい設計では、ハードコードされた値を使用する代わりに、PoW（Proof of Work）パズル固有のDoS耐性の特性を利用して、
  メインチェーンを見つける前に割り当てられるメモリの量を最小限に抑えます。

  この変更により、ノードはヘッダーの初期同期中に2回ヘッダーをダウンロードします。
  1回めは累積した作業量が所定の閾値に達するまでヘッダーのPoWを検証し（保存はせず）、
  2回めでヘッダーを保存します。攻撃者が事前同期中にメインチェーンを送信して、再ダウンロード中に別の悪意あるチェーンを送信するのを防ぐために、
  ノードは事前同期中にヘッダーチェーンへのコミットメントを保存します。

- [Bitcoin Core #25355][]は、アウトバウンドの[I2P接続][topic anonymity networks]のみが許可されている場合に、
  一時的なI2Pアドレスのサポートを追加しました。I2Pでは、受信者は接続開始側のI2Pアドレスを学習します。
  I2Pのリスニングを行わないノードは、デフォルトでアウトバウンド接続を作成する際に一時的なI2Pアドレスを使用するようになります。

- [BDK #689][]は、`allow_dust`メソッドを追加し、[dust limit][topic uneconomical outputs]に違反するトランザクションの作成を許可します。
  Bitcoin Coreや同じ設定を使用する他のノードは、（`OP_RETURN`を除く）すべてのアウトプットが受け取るsatoshiがdust limitを超えない限り、
  未承認のトランザクションをリレーしません。BDKは通常、作成するトランザクションにdust limitを強制するすることで、
  ユーザーがそのようなリレーされないトランザクションを作成するのを防ぎますが、
  この新しいオプションはそのポリシーを無視するものです。
  PRの作者は、自分たちのウォレットのテストに使用していると述べています。

- [BDK #682][]は、[HWI][topic hwi]と[rust-hwi][rust-hwi github]ライブラリを使用したハードウェア署名デバイス用の署名機能を追加しました。
  このPRでは、テスト用にLedgerデバイスのエミュレーターも導入されています。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25717,25355,689,682" %}
[rust-hwi github]: https://github.com/bitcoindevkit/rust-hwi
