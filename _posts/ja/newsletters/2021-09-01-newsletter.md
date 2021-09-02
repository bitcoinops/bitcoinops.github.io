---
title: 'Bitcoin Optech Newsletter #164'
permalink: /ja/newsletters/2021/09/01/
name: 2021-09-01-newsletter-ja
slug: 2021-09-01-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、PSBTをデコード・変更するための新しいWebベースのツールと、
eltooベースのLNのペイメントチャネルの概念実証の実装およびブログ記事のリンクを掲載しています。
また、Taprootの準備や新しいソフトウェアのリリース候補の発表、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更点の要約など、
恒例のセクションも含まれています。

## ニュース

- **BIP174.org:** Alekos Filiniは、
  彼とDaniela Brozzoniが作成した[PSBT][topic psbt]を人が読める形式のリストにデコードする
  [ウェブサイト][bip174.org]についてBitcoin-Devメーリングリストに[投稿しました][filini bip174.org]。
  フィールドの内容を編集し、シリアライズされたPSBTに再エンコードすることができ、
  これにより開発者はBIP174実装のテストを素早く作成することができます。
  Christopher Allenは、このツールがQRコード（標準的なQRコードコード、
  または3KB以上のPSBTを扱うための代替 [ニュースレター #96][news96 qr codes]参照）
  の作成にも対応するよう[提案しました][allen qr174]。

- **eltooのチャネル例:** Richard Myersは以前、
  AJ Townsの[SIGHASH_ANYPREVOUT][topic sighash_anyprevout]の実装をベースに、
  Bitcoin Coreの結合テストを使って[eltoo][topic eltoo]チャネルの例を実装しました（[ニュースレター #63][news63 eltoo]参照）。
  Bitcoin-Devメーリングリストで[言及されているように][myers list]、
  彼は現在eltooチャネルが使用できるトランザクションを説明する[詳細なブログ記事][myers blog]を書いています。
  彼の結合テストと組み合わせて、eltooに興味ある人は誰でもそれを試すことができます。
  また、今後の研究に興味ある人のためにeltooの改善点についても解説されています。

## Taprootの準備 #11: LNとTaproot

*ブロック高{{site.trb}}のTaprootのアクティベーションに向けて、
開発者やサービスプロバイダーがどのような準備をすればよいかについての週刊[シリーズ][series preparing for taproot]です。*

{% include specials/taproot/ja/10-ln-with-taproot.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 22.0rc3][bitcoin core 22.0]は、
  このフルノード実装とそれに付随するウォレットおよび他のソフトウェアの次のメジャーバージョンのリリース候補です。
  この新バージョンの主な変更点は、[I2P][topic anonymity networks]接続のサポート、
  [Tor v2][topic anonymity networks]接続の廃止、ハードウェアウォレットのサポートの強化などです。

- [Bitcoin Core 0.21.2rc2][bitcoin core 0.21.2]は、
  Bitcoin Coreのメンテナンス版のリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core GUI #384][]では、
  禁止されたピアテーブルのピアのIP/ネットマスクをコピーするコンテキストメニューオプションが追加されました。
  これにより、GUIユーザーは禁止リストから個々のアドレスをより簡単に共有できるようになります。

    ![Screenshot of GUI Copy IP/Netmask Context Menu Option](/img/posts/2021-09-gui-copy-banned-peer.png)

- [C-Lightning #4674][]では、PluginがC-Lightningデータベースにデータを保存・管理するための
  `datastore`、`deldatastore`、`listdatastore`コマンドが追加されました。
  また各コマンドのセマンティクスを詳細に説明したマニュアルページも含まれています。

- [LND #5410][]では、ノードが[Tor][topic anonymity networks]の背後で実行されていないサービスへの直接接続を確立し、
  ネットワークのTorのみのセグメントとクリアネットのみのセグメントをブリッジできるようになりました。

- [LND #5621][]では、[Pingメッセージ][lightning ping]の`ignored`フィールドの一部として、
  最も作業されているブロックのブロックヘッダを含むようになりました。
  ピアノードはこの情報を、ブロックチェーンのビューが最新であり、
  Bitcoinネットワークから[排除されていないこと][topic eclipse attacks]を確認するための追加チェックとして使用できます。
  将来的には、このデータソースを使用して、ユーザーに警告したり、リカバリーのためのアクションを自動的に取ることができます。

## 脚注

{% include references.md %}
{% include linkers/issues.md issues="384,4674,5410,5621" %}
[bitcoin core 22.0]: https://bitcoincore.org/bin/bitcoin-core-22.0/
[bitcoin core 0.21.2]: https://bitcoincore.org/bin/bitcoin-core-0.21.2/
[pickhardt richter paper]: https://arxiv.org/abs/2107.05322
[news96 qr codes]: /en/newsletters/2020/05/06/#qr-codes-for-large-transactions
[bip174.org]: https://bip174.org/
[news63 eltoo]: /en/newsletters/2019/09/11/#eltoo-sample-implementation-and-discussion
[filini bip174.org]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019355.html
[allen qr174]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019356.html
[myers list]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019342.html
[myers blog]: https://yakshaver.org/2021/07/26/first.html
[lightning ping]: https://github.com/lightningnetwork/lightning-rfc/blob/master/01-messaging.md#the-ping-and-pong-messages
[series preparing for taproot]: /ja/preparing-for-taproot/
