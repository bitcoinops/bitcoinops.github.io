---
title: 'Bitcoin Optech Newsletter #243'
permalink: /ja/newsletters/2023/03/22/
name: 2023-03-22-newsletter-ja
slug: 2023-03-22-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、サービスとクライアントソフトウェアの変更や、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションを掲載しています。

## ニュース

*今週は、Bitcoin-DevメーリングリストやLightning-Devメーリングリストでは目立ったニュースはありませんでした。*

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Xapo Bankがライトニングをサポート:**
  Xapo Bankは、Lightsparkの基盤インフラを使用して、
  顧客がXapo Bankのモバイルアプリからライトニング支払いを送信できるようになったことを[発表しました][xapo lightning blog]。

- **miniscriptディスクリプター用のTypeScriptライブラリのリリース:**
  TypeScriptベースの[Bitcoin Descriptors Library][github descriptors library]は、
  [PSBT][topic psbt]や[ディスクリプター][topic descriptors]および[miniscript][topic miniscript]をサポートしています。
  これには、直接署名する場合や、特定のハードウェア署名デバイスを使用する場合のサポートが含まれています。

- **BreezがライトニングSDKを発表:**
  最近の[ブログ記事][breez blog]で、Breezは、Bitcoinとライトニング支払いの統合を望むモバイル開発者向けに、
  オープンソースの[Breez SDK][github breez sdk]を発表しました。
  このSDKには、[Greenlight][blockstream greenlight]や
  Lightning Service Provider (LSP)機能などのサポートが含まれています。

- **PSBTベースの取引所OpenOrdexがローンチ:**
  [オープンソースの][github openordex]取引所ソフトウェアで、売り手は[PSBT][topic psbt]を使用して
  Ordinal satoshiのオーダーブックを作成し、買い手はそれに署名してブロードキャストすることで取引を完了することができます。

- **BTCPay Serverがcoinjoinプラグインをリリース:**
  Wasabi Walletの[発表][wasabi blog]では、BTCPay Serverのマーチャントであれば、
  [coinjoin][topic coinjoin]用の[WabiSabi][news101 wabisabi]プロトコルをサポートする
  オプションのプラグインを有効化することができます。

- **mempool.space エクスプローラーがCPFPのサポートを強化:**
  mempool.space [エクスプローラー][topic block explorers]は、
  [CPFP][topic cpfp]関連のトランザクションの[追加サポート][mempool tweet]を発表しました。

- **Sparrow v1.7.3リリース:**
  Sparrow [v1.7.3リリース][sparrow v1.7.3]には、
  マルチシグウォレット用の[BIP129][]のサポート（[ニュースレター #136][news136 bsms]参照）や、
  カスタムブロックエクスプローラーのサポートなどの機能が含まれています。

- **Stack WalletがコインコントロールとBIP47を追加:**
  [Stack Wallet][github stack wallet]の最近のリリースでは、
  [コインコントロール][topic coin selection]の機能と[BIP47][]のサポートが追加されています。

- **Wasabi Wallet v2.0.3リリース:**
  Wasabi [v2.0.3リリース][Wasabi v2.0.3]には、Taprootでのcoinjoinの署名と、
  Taprootのお釣り用アウトプット、送信用のオプトイン手動コイン制御、
  ウォレットのローディング速度の改善などが含まれています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND v0.16.0-beta.rc3][]は、この人気のLN実装の新しいメジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [LND #7448][]では、未承認トランザクションを再送信するための新しいrebroadcasterインターフェースが追加され、
  特にmempoolから排除されたトランザクションに対処できるようになります。
  これを有効にすると、rebroadcasterは未承認トランザクションをブロック毎に1回、
  承認されるまでアタッチされたフルノードに送信します。
  LNDは、Neutrinoモードで動作している際に、既に同様の方法でトランザクションを再ブロードキャストしていました。
  以前取り上げたStack ExchangeのQ&Aにもあるように、
  [Bitcoin Coreは現在トランザクションを再ブロードキャストしません][no rebroadcast]が、
  フルノードの動作が修正され、ノードが前のブロックに含まれると予想していたトランザクションを
  再ブロードキャストするようになれば、プライバシーと信頼性の面で望ましいでしょう。
  それまでは、関心のあるトランザクションがmempoolにあることを確認するのは各ウォレットの責任になります。

- [BDK #793][]は、[bdk_coreサブプロジェクト][bdk_core sub-project]の作業に基づき、
  ライブラリの大規模な再構築を行いました。PRの説明によると、
  「既存のウォレットAPIを可能な限り維持し、追加するものはほとんどない」とのことです。
  PRの説明には、一見マイナーな変更と思われる3つのAPIエンドポイントが記載されています。

{% include references.md %}
{% include linkers/issues.md v=2 issues="7448,793" %}
[lnd v0.16.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc3
[bdk_core sub-project]: https://bitcoindevkit.org/blog/bdk-core-pt1/
[no rebroadcast]: /ja/newsletters/2021/03/31/#will-nodes-with-a-larger-than-default-mempool-retransmit-transactions-that-have-been-dropped-from-smaller-mempools-mempool-mempool
[xapo lightning blog]: https://www.xapobank.com/blog/another-first-xapo-bank-now-supports-lightning-network-payments
[github descriptors library]: https://github.com/bitcoinerlab/descriptors
[breez blog]: https://medium.com/breez-technology/lightning-for-everyone-in-any-app-lightning-as-a-service-via-the-breez-sdk-41d899057a1d
[github breez sdk]: https://github.com/breez/breez-sdk
[blockstream greenlight]: https://blockstream.com/lightning/greenlight/
[github openordex]: https://github.com/orenyomtov/openordex
[wasabi blog]: https://blog.wasabiwallet.io/wasabiwalletxbtcpayserver/
[news101 wabisabi]: /en/newsletters/2020/06/17/#wabisabi-coordinated-coinjoins-with-arbitrary-output-values
[mempool tweet]: https://twitter.com/mempool/status/1630196989370712066
[news136 bsms]: /ja/newsletters/2021/02/17/#securely-setting-up-multisig-wallets
[sparrow v1.7.3]: https://github.com/sparrowwallet/sparrow/releases/tag/1.7.3
[github stack wallet]: https://github.com/cypherstack/stack_wallet
[Wasabi v2.0.3]: https://github.com/zkSNACKs/WalletWasabi/releases/tag/v2.0.3
