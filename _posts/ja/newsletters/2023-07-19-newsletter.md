---
title: 'Bitcoin Optech Newsletter #260'
permalink: /ja/newsletters/2023/07/19/
name: 2023-07-19-newsletter-ja
slug: 2023-07-19-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、mempoolポリシーに関する限定週刊シリーズの最終回に加えて、
クライアントやサービス、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など恒例のセクションを掲載しています。

## ニュース

_今週は、Bitcoin-DevメーリングリストやLightning-Devメーリングリストでは目立ったニュースはありませんでした。_

## 承認を待つ #10: 参加してみよう

_トランザクションリレーや、mempoolへの受け入れ、マイニングトランザクションの選択に関する限定週刊[シリーズ][policy series]の最終回です。
Bitcoin Coreがコンセンサスで認められているよりも制限的なポリシーを持っている理由や、
ウォレットがそのポリシーを最も効果的に使用する方法などが含まれます。_

{% include specials/policy/ja/10-get-involved.md %}

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **<!--wallet-10101-beta-testing-pooling-funds-between-ln-and-dlcs-->ウォレット10101のベータテストでLNとDLCの資金をプール:**
  10101は、LDKとBDKで構築された[ウォレット][10101 github]を発表しました。
  このウォレットを使用すると、ユーザーはLN支払いの送受信、転送にも使用できる[オフチェーンコントラクト][10101 blog2]の
  [DLC][topic dlc]を使用して、非カストディアルなデリバティブ取引ができます。
  DLCは、価格の[証明][10101 blog1]に[アダプター署名][topic adaptor signatures]を使用するオラクルに依存しています。

- **LDK Nodeの発表:**
  LDKチームは、LDK Node [v0.1.0][LDK Node v0.1.0]を[発表しました][ldk blog]。
  LDK Nodeは、LDKとBDKライブラリを使用したライトニングノードのRustライブラリで、
  開発者がさまざまなユースケースに合わせて高度なカスタマイズを提供しながら、
  セルフカストディ型のライトニングノードを素早くセットアップできるようにします。

- **Payjoin SDKの発表:**
  [Payjoin][topic payjoin]機能を統合したいウォレットやサービスで使用するための[BIP78][]を実装したRustライブラリである
  [Payjoin Dev Kit (PDK)][PDK github]が[発表されました][PDK blog]。

- **VLS（Validating Lightning Signer）betaの発表:**
  VLSを使用すると、ライトニングノードとその資金を管理する鍵を分離することができます。
  VLSを使用するライトニングノードは、署名要求をローカルにある鍵ではなく、リモートの署名デバイスにルーティングします。
  [betaリリース][VLS gitlab]では、CLNとLDK、レイヤー1とレイヤー2の検証ルール、
  バックアップ/リカバリー機能をサポートし、参照実装を提供しています。
  [ブログ記事][VLS blog]の発表では、コミュティからのテストや機能リクエスト、フィードバックも呼びかけています。

- **BitGoがMuSig2をサポート:**
  BitGoは、[BIP327][]（[MuSig2][topic musig]）のサポートを[発表し][bitgo blog]、
  サポートされている他のアドレスタイプと比較して、手数料の削減とプライバシー保護が強化されたことを言及しています。

- **PeachがRBFをサポート:**
  ピアーツーピア取引用の[Peach Bitcoin][peach website]モバイルアプリケーションは、
  [RBF（Replace-By-Fee）][topic rbf]による手数料の引き上げのサポートを[発表しました][peach tweet]。

- **Phoenixウォレットがスプライシングをサポート:**
  ACINQは、Phoenixモバイルライトニングウォレットの次期バージョンのベータテストを[発表しました][acinq blog]。
  このウォレットは、[スプライシング][topic splicing]と[Swap-in-Potentiam][news233 sip]技術（[Podcast #259][pod259 phoenix]参照）と
  同様の仕組みを使用してリバランスされる単一のダイナミックチャネルをサポートしています。

- **Mining Development Kitのフィードバックの募集:**
  MDK（Mining Development Kit）に取り組んでいるチームは、
  Bitcoinのマイニングシステム用のハードウェア、ソフトウェアおよびファームフェアの開発の進捗状況に関する最新情報を[投稿しました][MDK blog]。
  この投稿では、ユースケースやスコープ、アプローチについてコミュニティからのフィードバックを募集しています。

- **Binanceがライトニングをサポート:**
  Binanceは、ライトニングネットワークを使用した送金（引き出し）と受け取り（入金）のサポートを[発表しました][binance blog]。

- **NunchukがCPFPをサポート:**
  Nunchukは、トランザクションの送信者と受信者両方に対して
  [CPFP（Child-Pays-For-Parent）][topic cpfp]による手数料の引き上げのサポートを[発表しました][nunchuk blog]。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #27411][]は、ノードがそのTorやI2Pアドレスを
  他のネットワーク（プレーンなIPv4やIPv6など）上のピアに配信するのを防止します。
  また、非[匿名ネットワーク][topic anonymity networks]からTorやI2P上のピアにアドレスを配信することもありません。
  これは、誰かがノードの通常のネットワークアドレスを匿名ネットワーク上のアドレスの1つに関連付けるのを防ぐのに役立ちます。
  現時点では、CJDNSはTorやI2Pとは異なる扱いになっていますが、将来的には変更される可能性があります。

- [Core Lightning #6347][]は、ワイルドカード`*`を使用して
  すべてのイベント通知を購読するプラグインの機能を追加しました。

- [Core Lightning #6035][]は、[P2TR][topic taproot]アウトプットスクリプトで入金を受け取るための
  [bech32m][topic bech32]アドレスをリクエストする機能を追加しました。
  トランザクションのお釣りも、デフォルトでP2TRアウトプットに送信されるようになりました。

- [LND #7768][]は、BOLTs [#1032][bolts #1032]と[#1063][bolts #1063]
  （[ニュースレター #225][news225 bolts1032]参照）を実装し、
  支払い（HTLC）の最終的な受信者が、要求した金額よりも多くの金額を、
  要求したよりも長い有効期限で受け取ることができるようにしました。
  これまでは、LNDベースの受信者は、要求した金額と有効期限の差分が正確に等しいという[BOLT4][]の要件を遵守していましたが、
  その正確さは、どちらかの値をわずかに変更することで、転送ノードが次のホップを調査し、
  それが最終受信者であるかどうかを確認できることを意味していました。

- [Libsecp256k1 #1313][]は、GCCとClangのコンパイラの開発スナップショットを使用した自動テストを開始し、
  特定のlibsecp256k1のコードが可変時間で実行される可能性のある変更を検出できるようにしました。
  非定数時間のコードで秘密鍵やnonceを扱うと、[サイドチャネル攻撃][topic side channels]につながる可能性があります。
  そのようなことが起こった可能性のあることについては[ニュースレター #246][news246 secp]を、
  別の事例とこの種のテストが計画されているという発表は[ニュースレター #251][news251 secp]をご覧ください。

{% include references.md %}
{% include linkers/issues.md v=2 issues="27411,6347,6035,7768,1032,1063,1313" %}
[policy series]: /ja/blog/waiting-for-confirmation/
[news225 bolts1032]: /ja/newsletters/2022/11/09/#bolts-1032
[news246 secp]: /ja/newsletters/2023/04/12/#libsecp256k1-0-3-1
[news251 secp]: /ja/newsletters/2023/05/17/#libsecp256k1-0-3-2
[10101 github]: https://github.com/get10101/10101
[10101 blog1]: https://10101.finance/blog/dlc-to-lightning-part-1/
[10101 blog2]: https://10101.finance/blog/dlc-to-lightning-part-2
[LDK Node v0.1.0]: https://github.com/lightningdevkit/ldk-node/releases/tag/v0.1.0
[LDK blog]: https://lightningdevkit.org/blog/announcing-ldk-node
[PDK github]: https://github.com/payjoin/rust-payjoin
[PDK blog]: https://payjoindevkit.org/blog/pdk-an-sdk-for-payjoin-transactions/
[VLS gitlab]: https://gitlab.com/lightning-signer/validating-lightning-signer/-/releases/v0.9.1
[VLS blog]: https://vls.tech/posts/vls-beta/
[bitgo blog]: https://blog.bitgo.com/save-fees-with-musig2-at-bitgo-3248d690f573
[peach website]: https://peachbitcoin.com/
[peach tweet]: https://twitter.com/peachbitcoin/status/1676955956905902081
[acinq blog]: https://acinq.co/blog/phoenix-splicing-update
[news233 sip]: /ja/newsletters/2023/01/11/#ln
[MDK blog]: https://www.mining.build/update-on-the-mining-development-kit/
[binance blog]: https://www.binance.com/en/support/announcement/binance-completes-integration-of-bitcoin-btc-on-lightning-network-opens-deposits-and-withdrawals-eefbfae2c0ae472d9e1e36f1a30bf340
[nunchuk blog]: https://nunchuk.io/blog/cpfp
[pod259 phoenix]: /en/podcast/2023/07/13/#phoenix
