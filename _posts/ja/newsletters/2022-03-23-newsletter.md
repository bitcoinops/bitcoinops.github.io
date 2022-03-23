---
title: 'Bitcoin Optech Newsletter #192'
permalink: /ja/newsletters/2022/03/23/
name: 2022-03-23-newsletter-ja
slug: 2022-03-23-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、ソフトフォークのアクティベーションの仕組みであるSpeedy Trialについての議論と、
最適化されたLNの経路探索アルゴリズムのアップデートのリンクを掲載しています。
また、サービスやクライアントソフトウェアの最近の変更についての説明や、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更の概要など、
恒例のセクションも含まれています。

## ニュース

- **Speedy Trialに関する議論:** 提案中の[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]
  opcodeに関する最近のミーティングの要約において、[ソフトフォークのアクティベーション方法][topic soft fork activation]である
  Speedy Trialへの言及がありました。Jorge Timónが議論を呼ぶと思われるソフトフォークに対するSeedy Trialの使用に関して懸念を[示した][timon st]後、
  Bitcoin-Devメーリングリストの別のスレッドにスピンオフして追加の議論が行われました。

    Russell O'Connorは、その懸念がこれまでどう対処されてきたかを[説明しました][oconnor st]。
    Anthony Townsはさらに、望まないソフトフォークのアクティベーションにSpeedy Trialを使用した場合、
    反対するユーザーによってどのように抵抗されるかを[説明しました][towns st]。

- **<!--payment-delivery-algorithm-update-->支払い配送アルゴリズムのアップデート:** René Pickhardtは、
  Lightning-Devメーリングリストに、昨年発表した彼とStefan Richterの経路探索アルゴリズムについて、
  より計算効率の良い近似を見つけたと[投稿しました][pickhardt payment delivery]。
  このアルゴリズムに関する以前の議論については、[ニュースレター #163][news163 pp]をご覧ください。

    Pickhardtのメールでは、[スタックレス・ペイメント][news53 stuckless]の実装や、
    [いくつかの][boomerang]学術[論文][spear]で提案されている[払い戻し可能な過払い][news86 boomerang]を許容するなど、
    迅速な支払いの成功を向上させる方法も提案しています。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Coinswapの実装Teleport Transactionsの発表:**
  Bitcoin-Devメーリングリストの最近の[投稿][belcher teleport]で、
  Chris Belcherは、[Coinswap][topic coinswap]プロトコルを実装したTeleport
  Transactionsのα[バージョン 0.1][teleport transactions 0.1]を発表しました。

- **JoinMarketがTaproot支払いを追加:**
  [JoinMarket v0.9.5][joinmarket v0.9.5]では、[bech32m][topic bech32]アドレスへの支払い機能が追加されました。

- **Mercury WalletがRBFをサポート:**
  Mercury [Statechain][topic statechains]用のウォレットであるMercury walletは、
  引き出し用に[Replace-by-Fee (RBF)][topic rbf]によるトランザクションの置換のサポートを含む
  [v0.6.5][mercury v0.6.5]をリリースしました。

- **Hexa WalletがLightningをサポート:**
  BitcoinのモバイルウォレットであるHexa Walletは、
  [v2.0.71のリリース][hexa v2.0.71]で、
  独自のノードを実行しているLNDユーザー向けにLightning Networkの機能を追加しました。

- **Sparrow がBIP47をサポート:**
  [Sparrow 1.6.0][sparrow 1.6.0] (およびその後のsubsequent 1.6.1 と 1.6.2 リリース) では、
  [BIP47][]の再利用可能な支払いコードの機能と[その機能の説明][sparrow wallet tweet]が追加されました。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [HWI 2.1.0-rc.1][]は、HWIのリリース候補で、
  いくつかのハードウェア署名デバイスに対する[Taproot][topic taproot]のサポートと、
  その他の改善およびバグ修正が追加されています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Eclair #2203][]は、[非公開チャネル][topic unannounced channels]に、
  公開チャネルで使用されるデフォルトとは異なる最小資金をユーザーが指定できるように、
  設定パラメーターを追加しました。

- [LDK #1311][]は、[BOLTs #910][]で提案されたShort Channel Identifier (SCID) `alias`フィールドのサポートを追加しました。
  これによりノードは、チャネルをアンカリングするオンチェーントランザクションから導出した値ではなく、
  任意の値でチャネルを識別するようピアに要求することができるようになります。
  これは、SCIDがノードが作成したトランザクションを第三者に開示することを防ぐため、
  プライバシーの観点で有用です。また、[ニュースレター #156][news156 zcc]で説明したように、
  オプトインのゼロ承認チャネル（*ターボチャネル*とも呼ぶ）の仕様で使用することも提案されています。

- [LDK #1286][]では、[BOLT7が推奨する][bolt7 route rec]支払いのルーティングに使用される
  CLTV (`OP_CHECKLOCKTIMEVERIFY`)の値にオフセットを追加しています。
  これにより、支払いの一部を監視している誰か（例えば、支払いをルーティングしているノードの１つ）が、
  どのノードが意図した受信者であるかを正しく推測することが難しくなります。

- [HWI #584][]では、BitBox02ハードウェア署名デバイスの最近のファームウェアバージョンを使用する場合に、
  [bech32m][topic bech32]アドレスへの支払いをサポートしました。

- [HWI #581][]では、将来のファームウェアバージョンでTrezorを使用する場合、
  外部インプット（例えば[CoinJoin][topic coinjoin]など）を持つトランザクションの署名のサポートを無効にします。
  このPRは、HWIがサポートを実現するために使用していた回避策を破壊するファームウェアの変更に従ったものです。
  後続のPR ([HWI #590][]) は、Trezorが将来そのようなトランザクションに署名する方法をユーザーに提供することを検討していることを示しているようです。

- [BDK #515][]では、内部データベースに使用済みのトランザクションアウトプットを保持するようにりました。
  これは、[置換トランザクション][topic rbf]の作成に有用で、
  [BIP47][]の再利用可能な支払いコードの[実装][bdk #549]を簡素化します。

{% include references.md %}
{% include linkers/issues.md v=1 issues="2203,1311,910,1286,584,581,515,549,590" %}
[hwi 2.1.0-rc.1]: https://github.com/bitcoin-core/HWI/releases/tag/2.1.0-rc.1
[bolt7 route rec]: https://github.com/lightning/bolts/blob/master/07-routing-gossip.md#recommendations-for-routing
[oconnor st]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020106.html
[timon st]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020102.html
[towns st]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020127.html
[pickhardt payment delivery]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-March/003510.html
[news163 pp]: /ja/newsletters/2021/08/25/#zero-base-fee-ln-discussion-ln
[news53 stuckless]: /en/newsletters/2019/07/03/#stuckless-payments
[spear]: https://dl.acm.org/doi/10.1145/3479722.3480997
[news156 zcc]: /ja/newsletters/2021/07/07/#zero-conf-channel-opens
[boomerang]: https://arxiv.org/pdf/1910.01834.pdf
[news86 boomerang]: /ja/newsletters/2020/02/26/#boomerang
[belcher teleport]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/020026.html
[teleport transactions 0.1]: https://github.com/bitcoin-teleport/teleport-transactions/releases/tag/0.1
[joinmarket v0.9.5]: https://github.com/JoinMarket-Org/joinmarket-clientserver/releases/tag/v0.9.5
[mercury v0.6.5]: https://github.com/layer2tech/mercury-wallet/releases/tag/v0.6.5
[hexa v2.0.71]: https://github.com/bithyve/hexa/releases/tag/v2.0.71
[sparrow 1.6.0]: https://github.com/sparrowwallet/sparrow/releases/tag/1.6.0
[sparrow wallet tweet]: https://twitter.com/SparrowWallet/status/1504458210366922759
