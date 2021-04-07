---
title: 'Bitcoin Optech Newsletter #143'
permalink: /ja/newsletters/2021/04/07/
name: 2021-04-07-newsletter-ja
slug: 2021-04-07-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、新しいリリースとリリース候補の発表に加えて、
人気のあるBitcoinのインフラストラクチャプロジェクトの注目すべき変更点など恒例のコーナーが含まれています。

## ニュース

*今週は特筆すべきニュースはありませんでした。*

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*


- [C-Lightning 0.10.0][C-Lightning 0.10.0]は、このLNノードソフトウェアの最新のメジャーリリースです。
  APIに対する多くの拡張が含まれており、[デュアル・ファンディング][topic dual funding]の実験的なサポートも含まれています。

- [BTCPay 1.0.7.2][]は、先週のセキュリティリリース後に発見された軽微な問題を修正しています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #20286][]は、RPC `gettxout`、`getrawtransaction`、`decoderawtransaction`、
  `decodescript`、`gettransaction`およびRESTエンドポイント `/rest/tx`、`/rest/getutxos`、
  `/rest/block`のレスポンスから`addresses`フィールドと`reqSigs`フィールドを削除しています。
  明確に定義されたアドレスが存在する場合は、代わりにオプションの`address`フィールドがレスポンスに含まれるようになります。
  非推奨となったフィールドは、現在のネットワークでは実質的に使用されていないベア・マルチシグの文脈で使用されていました。
  非推奨となったフィールドは、Bitcoin Core 23.0でオプションが削除されるまでは、
  `-deprecatedrpc=addresses`設定オプションで出力することができます。

- [Bitcoin Core #20197][]では、最も長く可動しているオニオンピアを保護するために、
  インバウンドピアの排除ロジックを更新することでピア接続の多様性を改善しています。
  また、現在の排除防止ロジックの単体テストのカバレッジも追加しています。
  オニオンピアは、IPv4やIPv6のピアに比べてレイテンシーが高いため、
  これまで排除基準で不利になっており、
  ユーザーに[複数][Bitcoin Core #11537]の[問題][Bitcoin Core #19500]を提起させることになっていました。
  この問題への[最初の対応][news114 core19670]では、オニオンピアのプロキシとしてローカルホストピア用のスロットを確保しました。
  その後、[インバウンドオニオン接続の明示的な検出][news118 core19991]が追加されました。

  この変更により、保護されたスロットの半分が任意のオニオンピアとローカルホストピアに割り当てられ、
  オニオンピアがローカルホストピアよりも優先されます。
  I2PプライバシーネットワークのサポートがBitcoin Coreに追加されたため（[ニュースレター #139][news139 i2p]参照）、
  次のステップは、一般的にオニオンピアよりもレイテンシーの高いI2Pピアに排除防止を拡張することです。

- [Eclair #1750][]では、Electrumのサポートとそれに対応する1万行のコードを削除しました。
  ElectrumはこれまでEclairのモバイルウォレットで使用されていました。
  しかし、モバイルウォレットでは新しい実装である[Eclair-kmp][eclair-kmp github]の使用が推奨され、
  EclairにおけるElectrumのサポートが不要になりました。

- [Eclair #1751][]では、`payinvoice`コマンドに`blocking`オプションが追加され、
  支払いが完了するまで`payinvoice`の呼び出しをブロックできるようになりました。
  これまでは、ユーザーが支払いがいつ完了したか知るのに、非効率な`getsentinfo` APIのポーリングが必要でした。

{% include references.md %}
{% include linkers/issues.md issues="20286,20197,1750,1751,19500,11537,19670,19991" %}
[c-lightning 0.10.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.0
[btcpay 1.0.7.2]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.0.7.2
[news139 i2p]: /ja/newsletters/2021/03/10/#bitcoin-core-20685
[news114 core19670]: /en/newsletters/2020/09/09/#bitcoin-core-19670
[news118 core19991]: /en/newsletters/2020/10/07/#bitcoin-core-19991
[eclair-kmp github]: https://github.com/ACINQ/eclair-kmp
