---
title: 'Bitcoin Optech Newsletter #214'
permalink: /ja/newsletters/2022/08/24/
name: 2022-08-24-newsletter-ja
slug: 2022-08-24-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、チャネルジャミング攻撃に関するガイドのリンクと、
Silent PaymentのPRに対するいくつかの更新を掲載しています。
また、人気のあるサービスやクライアントの変更や、新しいリリースおよびリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **<!--overview-of-channel-jamming-attacks-and-mitigations-->チャンネルジャミング攻撃の概要とその緩和策:**
  Antoine RiardとGleb Naumenkoは、Lightning-Devメーリングリストに、
  [チャネルジャミング攻撃][topic channel jamming attacks]とそのいくつかの解決策の提案に関するガイドを[公開したこと][rn jam]を
  [発表しました][riard jam]。このガイドでは、Swapプロトコルや短期間の[DLC][topic dlc]など、
  LN上に構築されたプロトコルで、いくつかの解決策がどのように役立つかも考察しています。

- **Silent PaymentのPRの更新:** woltxは、Bitcoin-Devメーリングリストに、
  [Silent Payment][topic silent payments]に関するBitcoin CoreへのPRが更新されたことを[投稿しました][woltx sp]。
  Silent Paymentは、オンチェーンで監視可能な支払いのリンクを作成することなく、
  さまざまな送信者が再利用可能なアドレスを提供します（ただし受信者は、
  その後の行動によってそのプライバシーを弱めないよう注意する必要があります）。
  PRの最も重要な変更は、Silent Payment用に新しい[アウトプット・スクリプト・ディスクリプター][topic descriptors]が追加されたことです。

  新しいディスクリプターの設計は、PRでかなり議論されました。
  ウォレット毎にSilent Paymentディスクリプターを1つだけ許可するのは、
  新しいトランザクションを監視するのに最も効率的ですが、
  多くの場合、悪いユーザー・エクスペリエンスになると指摘されました。
  この問題に対処するために、Silent Paymentの設計に若干の調整をすることが提案されましたが、これにはトレードオフが伴います。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Purse.ioがLightningのサポートを追加:**
  [最近のツイート][purse ln tweet]で、Purse.ioはLightning Networkを使用した入金（受信）と引き出し（送信）をサポートすることを発表しました。

- **Coinjoin実装のProof of Concept joinstr:**
  1440000bytesは、中央のサーバーを持たない公開鍵ベースのリレーネットワークである[nostrプロトコル][nostr github]を利用した
  [Coinjoin][topic coinjoin]のProof of Conceptである[joinstr][joinstr github]を実装しました。

- **Coldcardファームウェア5.0.6をリリース:**
  Coldcardのバージョン5.0.6では、[BIP85][]、`OP_RETURN`スクリプトおよびマルチシグ[ディスクリプター][topic descriptors]のサポートが追加されました。

- **NunchukがTaprootをサポート:**
  [Nunchukのモバイルウォレット][nunchuk appstore]の最新バージョンでは、
  （シングルシグの）[Taproot][topic taproot]、[Signet][topic signet]および、
  拡張[PSBT][topic psbt]のサポートが追加されました。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BDK 0.21.0][]は、ウォレット構築用のこのライブラリの最新リリースです。

- [Core Lightning 0.12.0][]は、この人気のLNノード実装の次のメジャーバージョンリリースです。
  新しい`bookkeeper`プラグイン（[ニュースレター #212][news212 bookkeeper]参照）と
  `commando`プラグイン（[ニュースレター #210][news210 commando])）が含まれ、
  [Static Channel Backup][topic static channel backups]のサポートが追加され、
  明示的に許可したピアがあなたのノードに[ゼロ承認チャネル][topic zero-conf channels]を開く機能が提供されます。
  これらの新しい機能に加えて、他の多くの追加機能やバグ修正が含まれています。

- [LND 0.15.1-beta.rc1][]は、「[ゼロ承認チャネル][topic zero-conf channels]、SCID[エイリアス][aliases]および、
  どこでも[Taproot][topic taproot]アドレスを使用するための切り替えを含む」リリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #25504][]は、`listsinceblock`および`listtransactions`、`gettransactions`のレスポンスを、
  関連するディスクリプターを新しい`parent_descs`フィールドに記述するよう修正しました。
  さらに、`listsinceblock`は、オプションパラメーター`include_change`毎にお釣り用のアウトプットを明示的にリストするよう指定できるようになりました。
  通常、お釣り用のアウトプットは、送金時の暗黙の副産物として省略されますが、
  監視用のディスクリプターでは、それらをリストするのが役立つ場合があります。

- [Eclair #2234][]は、[BOLTs #911][]で許可されたように（[ニュースレター #212][news212 bolts911]参照）、
  通知時にノードにDNS名を関連付けるサポートを追加しました。

- [LDK #1503][]は、[BOLTs #759][]で定義された[Onionメッセージ][topic onion messages]のサポートを追加しました。
  PRは、この変更が後続の[Offer][topic offers]のサポートを追加するための準備であることを示しています。

- [LND #6596][]は、すべてのウォレットアドレスとその現在の残高をリストする新しい`wallet addresses list` RPCを追加しました。

- [BOLTs #1004][]は、ルーティングのためにチャネル情報を保持するノードが、チャネルが閉じられた後、
  少なくとも12ブロック待ってからその情報を削除するよう推奨するようになりました。
  この遅延は、チャネルが実際には閉じられておらず、
  代わりにオンチェーン・トランザクションで資金が追加もしくは削除される[スプライス][topic splicing]の検出をサポートするためのものです。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25504,2234,1503,911,759,6596,1004" %}
[core lightning 0.12.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.12.0
[bdk 0.21.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.21.0
[lnd 0.15.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.1-beta.rc1
[news212 bolts911]: /ja/newsletters/2022/08/10/#bolts-911
[aliases]: /ja/newsletters/2022/07/13/#lnd-5955
[woltx sp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020883.html
[riard jam]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-August/003673.html
[rn jam]: https://jamming-dev.github.io/book/
[news210 commando]: /ja/newsletters/2022/07/27/#core-lightning-5370
[news212 bookkeeper]: /ja/newsletters/2022/08/10/#core-lightning-5071
[joinstr github]: https://github.com/1440000bytes/joinstr
[nostr github]: https://github.com/nostr-protocol/nostr
[nunchuk appstore]: https://apps.apple.com/us/app/nunchuk-bitcoin-wallet/id1563190073
[purse ln tweet]: https://twitter.com/PurseIO/status/1557495102641246210
