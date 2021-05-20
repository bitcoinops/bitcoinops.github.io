---
title: 'Bitcoin Optech Newsletter #149'
permalink: /ja/newsletters/2021/05/19/
name: 2021-05-19-newsletter-ja
slug: 2021-05-19-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、以前提案されたトランザクションリレーの信頼性に関するワークショップと、
CVE-2021-31876に関する最新情報をお伝えします。また、
サービスやクライアントソフトウェアのアップデートや、
新しいリリースとリリース候補、人気の高いBitcoinインフラストラクチャソフトウェアの注目すべき変更点などの
恒例のセクションも掲載しています。

## ニュース

- **<!--relay-reliability-workshop-scheduled-->リレーの信頼性に関するワークショップの予定:**
  [ニュースレター #146][news146 workshop]に掲載したように、
  Antoine Riardは、LNやcoinswaps、DLCのようなコントラクトプロトコルにおいて、
  未承認のトランザクションリレーの信頼性を高めるための方法を議論するために、
  IRCベースのミーティングを開催する予定です。スケジュールは:

    - 6月15日 19:00--20:30 UTC: L2プロトコルのオンチェーンセキュリティ設計に関するガイドライン;
      クロスレイヤーのセキュリティの開示の調整; full-RBFの提案

    - 6月22日 (同時刻): 一般的なレイヤー2の手数料引き上げプリミティブ（パッケージリレーのような）

    - 6月29日 (同時刻): 追加の議論のための予備

- **<!--cve-2021-31876-bip125-implementation-discrepancy-follow-up-->CVE-2021-31876 BIP125実装の不一致のフォローアップ:**
  [先週のニュースレター発行後][news148 cve]、
  [BIP125][] opt-in Replace-by-Fee ([RBF][topic rbf])とBitcoin Coreの実装の不一致について追加の議論がありました。
  Olaoluwa Osuntokunは、`btcd`フルノードがBIP125を仕様通りに実装していること、
  つまりシグナリングの継承に基づいて子トランザクションを交換可能にしていることを[確認しました][btcd #1719]。
  Ruben Somsenは、one-wayペグの[サイドチェーン][topic sidechains]の一種であるspacechainsの架空のバリエーションが、
  この問題の影響を受けると[指摘しました][somsen note]。
  一方、Antoine “Darosior” Poinsotは、
  Revault [vault][topic vaults]アーキテクチャは影響を受けないと[述べています][poinsot mention]。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Blockchain.comがsegwitをサポート:**
  Blockchain.comのウォレット[v4.49.1][blockchain v4.49.1]には、
  ネイティブsegwitの送受信サポートを備えたウォレットを作成する機能が追加されています。

- **Sparrow 1.4.0 リリース:**
  [Sparrow 1.4.0][sparrow 1.4.0]には、
  取引一覧画面から[child pays for parent (CPFP)][topic cpfp]トランザクションを作成できる機能や、
  コイン選択の際のユーザー定義の手数料およびその他のさまざまな改善が追加されています。

- **Electrum 4.1.0がLightning機能を強化:**
  [Electrum 4.1.0][electrum 4.1.0]には、[トランポリン支払い][topic trampoline payments]や、
  [マルチパス支払い][topic multipath payments]、チャネルバックアップおよびその他のLightning機能が追加されています。
  さらにこのバージョンのElectrumは[bech32m][topic bech32]をサポートしています。

- **BlueWallet v6.1.0 リリース:**
  BlueWalletの[v6.1.0 release][bluewallet v6.1.0]では、
  Torのサポートや[SLIP39][news86 slip39]のサポートおよび、
  HD watch-onlyウォレットで[PSBT][topic psbt]を使用するための機能が追加されています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.13.0-beta.rc2][LND 0.13.0-beta]は、プルーニングされたBitcoinフルノードの使用をサポートし、
  Atomic MultiPath（[AMP][topic multipath payments]）を使用した支払いの送受信を可能にし、
  [PSBT][topic psbt]の機能を向上させるなどの改良やバグ修正を行ったリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #21462][]では、Guixビルドの出力を証明し、
  これらの証明を他の証明と照合するためのツールが追加されています。
  今回の変更で、GuixビルドがGitianビルドと同等の機能を持つようになるまで、
  WindowsとmacOSのコード署名のみが唯一の不足機能になります。

- [Bitcoin Core GUI #280][]では、エラーダイアログに無効なBitcoinアドレスを表示しなくなりました。
  代わりにシンプルな"invalid address"エラーが表示されるようになります。
  （変更前後のスクリーンショットはPRをご覧ください。）

- [Bitcoin Core #21359][]では、`fundrawtransaction`、`send`および`walletcreatefundedpsbt`
  RPCに新しい`include_unsafe`パラメータを追加し、
  トランザクションで他のユーザーが作成した未承認のUTXOを使用できるようになります。
  これにより[CPFP][topic cpfp]を使用してトランザクションの手数料を引き上げることができるようになるため、
  Eclair LNノードで[Anchor Output][topic anchor outputs]の実装に取り組む開発者によって追加されました。
  このオプションは、他のユーザーが作成した未承認トランザクションを置き換えることができるため、
  必要な場合にのみ使用する必要があります。これにより子トランザクションが確認されなくなる可能性があります。

- [LND #5291][]では、
  ファンディング・トランザクションの[PSBT][topic psbt]がsegwit UTXOのみを使用することをLNDが保証する方法を改善しています。
  LNではtxidのmalleabilityによって払い戻しトランザクションが使用できなくなるのを防ぐため、
  segwit UTXOを必要とします。LNDは以前、PSBTの`WitnessUtxo`フィールドを探してこれをチェックしていましたが、
  このフィールドは技術的にはsegwit UTXOのオプションで、これを提供しないPSBT作成者もいます。
  更新されたコードでは、提供されていればそれを使用し、提供されていなければUTXOセットをスキャンして必要な情報を取得します。

- [LND #5274][]では、[Anchor Output][topic anchor outputs]を使用した
  [CPFP][topic cpfp]による手数料の引き上げを可能にするためにノードが準備する資金の最大量を、
  チャネルごとの金額の10倍に制限します。
  チャネル数が多いノードの場合、これにより必要な資金が制限されます。
  10以上のチャネルを閉じる必要がある場合、
  1つのチャネルを閉じて得た資金を使ってドミノ効果のように次のチャネルを閉じることができます。

- [LND #5256][]では、ファイルからウォレットのパスフレーズを読み込めるようになりました。
  これは主に、パスフレーズが既にファイルに保存されているコンテナベースのセットアップのためのもので、
  そのファイルを直接使用しても追加のセキュリティ問題は発生しません。

- [LND #5253][]では、`SendPayment`や`AddInvoice`、`SubscribeInvoice`などの高レベルのLND RPCコマンドにおいて、
  [Atomic Multipath Payment (AMP)][topic multipath payments]インボイスのサポートを追加しました。
  現在、AMPインボイスはLNDのみの機能で、AMPのfeature bitとAMPペイロードがセットされたHTLCのみを受け入れます。
  これは、`SendPayment`RPCに手動で指定された支払いパラメータを提供することでAMPを使用可能にした
  [以前の作業][news147 lndamp]の拡張です。

- [Libsecp256k1 #850][]に`secp256k1_ec_pubkey_cmp`メソッドが追加されました。
  このメソッドは2つの公開鍵を比較し、どちらの公開鍵がソートした際に先になるか（もしくは同じか）を返します。
  これは[BIP67][]の鍵のソート、特に`sortedmulti`
  [output script descriptor][topic descriptors]で使用するために提案されました。

{% include references.md %}
{% include linkers/issues.md issues="21462,280,21359,5291,5274,5256,5253,850" %}
[LND 0.13.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.0-beta.rc2
[news146 workshop]: /ja/newsletters/2021/04/28/#call-for-topics-in-layer-crossing-workshop
[news147 lndamp]: /ja/newsletters/2021/05/05/#lnd-5159
[news148 cve]: /ja/newsletters/2021/05/12/#cve-2021-31876-discrepancy-between-bip125-and-bitcoin-core-implementation-cve-2021-31876-bip125-bitcoin-core
[btcd #1719]: https://github.com/btcsuite/btcd/pull/1719
[somsen note]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-May/018921.html
[poinsot mention]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-May/018906.html
[blockchain v4.49.1]: https://github.com/blockchain/blockchain-wallet-v4-frontend/releases/tag/v4.49.1
[sparrow 1.4.0]: https://github.com/sparrowwallet/sparrow/releases/tag/1.4.0
[bluewallet v6.1.0]: https://github.com/BlueWallet/BlueWallet/releases/tag/v6.1.0
[news86 slip39]: /ja/newsletters/2020/02/26/#slip39-bip39
[electrum 4.1.0]: https://github.com/spesmilo/electrum/blob/4.1.0/RELEASE-NOTES
