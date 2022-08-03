---
title: 'Bitcoin Optech Newsletter #211'
permalink: /ja/newsletters/2022/08/03/
name: 2022-08-03-newsletter-ja
slug: 2022-08-03-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、1つのアウトプット・スクリプト・ディスクリプターから複数のパスの導出を可能にする提案と、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更点をまとめた恒例のセクションを掲載しています。

## ニュース

- **<!--multiple-derivation-path-descriptors-->複数の導出パス用のディスクリプター:** Andrew Chowは、
  [HD鍵生成][topic bip32]をするための2つの関連する[BIP32][]パスを1つのディスクリプターで定義できるようにする[BIPの提案][bip-multipath-descs]を
  Bitcoin-Devメーリングリストに[投稿しました][chow desc]。
  最初のパスは、支払いを受け取ることができるアドレスを生成するためのもので、
  2つめのアドレスはウォレット内の内部的な支払い、つまりUTXOを使用した後にお釣りをウォレットに戻すためのものです。

    BIP32で[定義されているように][bip32 wallet layout]、ほとんどのウォレットは、
    プライバシーを強化するために外部アドレスと内部アドレスを生成するのに別々の導出パスを使用します。
    支払いを受け取るために使用される外部パスは、たとえば支払いを受け取るためにウェブサーバーにアップロードするなど、
    信頼性の低いデバイスと共有されるかもしれません。お釣りのためだけに使用される内部パスは、
    秘密鍵を必要とするタイミングでのみ必要とされる可能性が高く、秘密鍵と同じセキュリティを得られます。
    ウェブサーバーが侵害され外部アドレスが流出した場合、攻撃者はユーザーがお金を受け取る度に彼らがいくら受け取ったのかと、
    お金を最初にいつ使ったのかを知ることができます。ただ、最初の支払いで送金された金額を必ずしも知ることはできず、
    お釣りのみで構成される支払いについても知ることはできません。

    [Pavol Rusnak][rusnak desc]と[Craig Raw][raw desc]は、
    Trezor WalletとSparrow Walletが既にChowの提案した方式をサポートしていると回答しました。
    Rusnakはまた、1つのディスクリプターが2つよりも多くの関連パスを記述できるようにすべきかどうか質問しました。
    Dmitry Petukhovは、現在広く使われているのは内部パスと外部パスのみで、
    それ以上のパスは既存のウォレットにとって明確な意味を持たないと[指摘しました][petukhov desc]。
    これは、相互運用性の問題を引き起こす可能性があります。彼は、BIPを2つのパスの導出のみに制限し、
    追加のパスを必要とする人が専用のBIPを書くのを待つことを提案しました。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Core Lightning #5441][]は、CLNの内部ウォレットで使用される[HDシード][topic bip32]に対して[BIP39][]パスフレーズを簡単にチェックできるように
  `hsmtool`を更新しました。

- [Eclair #2253][]は、[BOLTs #765][]で定義された[ブラインド・ペイメント][topic rv routing]のリレーのサポートを追加しています（[ニュースレター #187][news178 eclair 2061]参照）。

- [LDK #1519][]は、[BOLTs #996][]がLNの仕様にマージされた場合に必要となるため、
  `channel_update`メッセージに常に`htlc_maximum_msat`フィールドを含めるようにしました。
  このプルリクエストに記載されている変更の理由は、メッセージのパースを簡素化するためです。

- [Rust Bitcoin #994][]は、nLockTimeフィールドおよび[BIP65][]の`OP_CHECKLOCKTIME`フィールドを使用する`LockTime`タイプを追加しました。
  BitcoinのLocktimeフィールドには、ブロック高か[Unixエポックタイム][Unix epoch time]のいずれかの値を設定できます。

- [Rust Bitcoin #1088][]は、[BIP152][]で定義されている[Compact Block][topic compact block relay]に必要な構造と、
  通常のブロックからCompact Blockを作成するメソッドを追加しました。
  Compact Blockを使用すると、ノードは、そのブロックに含まれるトランザクションをトランザクションの完全なコピーを送信することなくピアに伝えることができます。
  ピアは、未承認トランザクションを以前受信し保存している場合、それらを再度ダウンロードする必要がなくなるため、
  帯域幅を節約し、新しいブロックのリレーを高速化できます。

{% include references.md %}
{% include linkers/issues.md v=2 issues="5441,2253,1519,994,1088,996,765" %}
[bip32 wallet layout]: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#specification-wallet-structure
[chow desc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020791.html
[bip-multipath-descs]: https://github.com/achow101/bips/blob/bip-multipath-descs/bip-multipath-descs.mediawiki
[rusnak desc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020792.html
[raw desc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020799.html
[petukhov desc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020804.html
[unix epoch time]: https://ja.wikipedia.org/wiki/UNIX時間
[news178 eclair 2061]: /ja/newsletters/2021/12/08/#eclair-2061
