---
title: 'Bitcoin Optech Newsletter #177'
permalink: /ja/newsletters/2021/12/01/
name: 2021-12-01-newsletter-ja
slug: 2021-12-01-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、最近修正された異なるLNソフトウェア間の相互運用性の問題と、
恒例のセクションとして、新しいリリースおよびリリース候補のリストに加えて、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点を掲載しています。

## ニュース

- **LNの相互運用性:** [ニュースレター #165][news165 bolts880]に掲載されているLNの仕様の最近の変更が、
  異なるLNノードによって異なる方法で実装されたため、LNDの最新バージョンを実行しているノードが、
  最新バージョンのC-LightningおよびEclairを実行しているノードとの間で、
  新しいチャネルを開くことができなくなるという問題が発生しました。
  LNDのユーザーは、（下記の*リリースとリリース候補*のセクションに掲載している）バグ修正されたリリースである
  0.14.1へのアップグレードが推奨されます。

    これに関連して、相互運用性のテストの改善についての[議論][xraid interop]が、
    Lightning-Devメーリングリストで始まりました。以前、
    LNの[統合テストフレームワーク][ln integration]の作成・保守をしていたChristian Deckerは、
    基本的な相互運用テストは「最もひどい問題以外は補足できないだろう」と[考えている][decker interop]と述べました。
    議論に参加していたLN開発者は、この種のバグを補足することが、すべての主要な実装がリリース候補（RC）を提供する理由であり、
    運用システムのエキスパートユーザーや管理者がRCのテストに貢献することが推奨される理由であると[述べています][zmn interop]。

    このようなテストへの参加に興味がある人のために、Optechのニュースレーターでは、
    4つの主要なLN実装のRCと、その他のさまざまなBitcoinソフトウェアを掲載しています。
    現在議論されているLNDのバージョンは、ニュースレター[#174][news174 lnd]と[#175][news175 lnd]にRCとして掲載されています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.14.1-beta][]は、上記の*ニュース*セクションおよび以下の*注目すべき変更*セクションの[LND #6026][]で
  詳細に掲載されている問題を修正したメンテナンスリリースです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #16807][]は、アドレスのバリデーションを更新し、
  [ニュースレター #41][news41 bech32 error detection]に掲載されている仕組みを使用して、
  [bech32およびbech32m][topic bech32]アドレスのタイプミスの可能性のある文字のインデックスを返すようにしました。
  2つ以下の置換エラーであればタイポは正しく識別されます。
  また、このプルリクエストでは、テストカバレッジの向上、
  アドレスのバリデーションコードへのドキュメントの追加、
  特にbech32とbech32mの使用を区別するためのデコード失敗時のエラーメッセージの改善がされています。

- [Bitcoin Core #22364][]では、[taproot][bip386]用の[descriptor][topic descriptors]の作成のサポートが追加されています。
  これにより、ウォレットユーザーはP2TRアドレスをインポートするのではなく、
  ウォレットでデフォルトのbech32m descriptorを作成することでP2TRアドレスを生成し使用することができます。

- [LND #6026][]は、[BOLTs #880][]の明示的なチャネルタイプのネゴシエーション（[ニュースレター #165][news165 bolts880]参照）
  の[実装][lnd #5669]に関する問題を修正しました。[提案されている][bolts #906]LN仕様の変更により、
  LNDは最終的に厳密な明示的ネゴシエーションを実装できるようになります。

- [Rust-Lightning #1176][]は、[anchor output][topic anchor outputs]形式の手数料引き上げの初期サポートを追加しました。
  このマージにより、anchor outputのサポートは、我々がカバーする4つのLN実装すべてで実装されました。

- [HWI #475][]では、[Blockstream Jade][news132 jade]ハードウェア署名者の[サポート][hwi support matrix]と、
  [QEMUエミュレーター][qemu website]を使用したテストを追加しました。

{% include references.md %}
{% include linkers/issues.md issues="16807,22364,6026,5669,880,906,1176,475,6026" %}
[lnd 0.14.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.1-beta
[news165 bolts880]: /ja/newsletters/2021/09/08/#bolts-880
[xraid interop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-November/003354.html
[decker interop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-November/003358.html
[zmn interop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-November/003365.html
[ln integration]: https://cdecker.github.io/lightning-integration/
[news174 lnd]: /ja/newsletters/2021/11/10/#lnd-0-14-0-beta-rc3
[news175 lnd]: /ja/newsletters/2021/11/17/#lnd-0-14-0-beta-rc4
[hwi support matrix]: https://hwi.readthedocs.io/en/latest/devices/index.html#support-matrix
[news132 jade]: /ja/newsletters/2021/01/20/#blockstream-jade
[qemu website]: https://www.qemu.org/
[news41 bech32 error detection]: /en/bech32-sending-support/#locating-typos-in-bech32-addresses
