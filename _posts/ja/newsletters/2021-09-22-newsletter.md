---
title: 'Bitcoin Optech Newsletter #167'
permalink: /ja/newsletters/2021/09/22/
name: 2021-09-22-newsletter-ja
slug: 2021-09-22-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、BIPプロセスの変更案と、
Bitcoin Coreにパッケージリレーのサポートを追加するための計画の要約、
DNSにLNノードの情報を追加することについての議論のリンクを掲載しています。
また、サービスやクライアントソフトウェアの変更点や、Taprootへの準備方法、新しいリリースとリリース候補、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点などの恒例のセクションも含まれています。

## ニュース

- **BIPの拡張:** Karl-Johan Almは、Bitcoin-Devメーリングリストに、
  一定の安定性を達成したBIPは、小さな修正を除いて今後は変更できないという提案を[投稿しました][alm bips]。
  安定したBIPの条件の変更は、前のドキュメントを拡張した新しいBIPで行う必要があります。

  Anthony Townsは、この案に[反対し][towns bips]、
  BIPリポジトリにDraftsフォルダを設けたり、BIPのメンテナが特定の提案に付ける番号を選択することをやめるなど、
  現在のプロセスに対するいくつかの代替案を提案しました。

- **mempoolのパッケージの受け入れとパッケージRBF:** Gloria Zhaoは、
  [CPFP][topic cpfp]と[RBF][topic rbf]の両方の手数料の引き上げの柔軟性と信頼性を高める、
  複数の関連トランザクションの[パッケージリレー][topic package relay]の設計について、
  Bitcoin-Devメーリングリストに[投稿しました][zhao post]。
  [初期の実装][bitcoin core #22290]では、パッケージはBitcoin CoreのRPCインターフェースを介してのみ送信できますが、
  最終的な目標は、この機能をP2Pネットワーク上で利用できるようにすることです。
  Zhaoは、Bitcoin Coreのトランザクション受け入れルールの変更案を簡潔にまとめています:

  > - パッケージは既にmempool内のトランザクションに含まれていることがあります。
  > - パッケージは2世代、親が複数で子が１つ。
  > - 手数料関連のチェックはパッケージの手数料率を使用します。これは、ウォレットがCPFPを利用するパッケージを作成できることを意味します。
  > - 親は、[BIP125][]に類似したルールのセットを持つRBF mempoolトランザクションを許可します。
  > これにより、CPFPとRBFの組み合わせが可能になり、トランザクションの子孫の手数料がmempoolの競合を置き換えるために支払われます。

  このメールでは、その機能の利用を想定している開発者や、変更による影響を考えている開発者からの
  提案に対するフィードバックを求めています。

- **LNノードのDNSレコード:** Andy Schroderは、Lightning-Devメーリングリストに、
  ドメイン名からLNノードのIPアドレスを公開鍵を解決するためのDNSレコードのセットの使用法を標準化する提案を[投稿しました][schroder post]。
  この記事を書いている時点では、このアイディアはまだ議論されています。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Lightningアドレスの識別子を発表:**
  André Nevesは、[LNURL-pay][lnurl pay]のフローを使い慣れた[メールのようなアドレス][lightningaddress diagram]にラップする
  [Lightningアドレス][lightningaddress website]プロトコルを[発表しました][tla tweet]。

- **ZEBEDEEがLNウォレットのブラウザ拡張を発表:**
  ZEBEDEEは、[ゲーム用ウォレット][zebedee wallet]と統合するChromeとFirefoxの拡張機能を[発表しました][zbe blog]。

- **Specter v1.6.0がシングルキーのTaprootをサポート:**
  Specterの [v1.6.0][specter v1.6.0]リリースでは、regtestと[signet][topic signet]の両方でTaprootアドレスをサポートしています。

- **ImperviousがLN P2P data APIをリリース:**
  LND上に構築された[Impervious][impervious website]フレームワークにより、
  開発者はLightning Network上でP2Pデータストリーミングアプリケーションを[構築することができます][impervious api]。

- **Fully Noded v0.2.26リリース:**
  macOS/iOS向けのLightningウォレットである[Fully Noded][fully noded website]は、
  [Taproot][topic taproot]、[BIP86][]およびsignetのサポートを追加しました。

## Taprootの準備 #14: Signetでのテスト

*ブロック高{{site.trb}}のTaprootのアクティベーションに向けて、
開発者やサービスプロバイダーがどのような準備をすればよいかについての週刊[シリーズ][series preparing for taproot]です。*

{% include specials/taproot/ja/13-signet.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 0.21.2rc2][bitcoin core 0.21.2]は、Bitcoin Coreのメンテナンスバージョンのリリース候補です。
  いくつかのバグ修正と小さな改善が含まれています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Eclair #1932][]は、[BOLTs #824][]で定義された[Anchor Output][topic anchor outputs]プロトコルの改訂版を実装し、
  事前署名されたHTLC支払いはゼロ手数料になるため、手数料が盗まれることはありません。
  詳細は、[ニュースレター #165][news165 bolts 842]をご覧ください。

- [LND #5405][]は、`updatechanpolicy` RPCを拡張し、
  現在のポリシー（または、チャネルのファンディング・トランザクションが未承認であるなどの他の問題）
  のため使用できないチャネルを報告するようになりました。

- [LND #5304][]により、LND自身が知らない外部権限を持つmacaroonの作成と検証が可能になりました。
  この変更により、[Lightning Terminal][]のようなツールで、1つのmacaroonを使って、
  同じLNDと通信する複数のデーモン間での認証が可能になります。

- [Rust Bitcoin #628][]は、Pay to Taprootのsighash構築のサポートを追加し、
  レガシー、segwit、taprootインプットのsighashキャッシュのストレージを整理しました。

- [Rust Bitcoin #580][]は、[BIP37][]で定義された
  [トランザクションのBloom Filter][topic transaction bloom filtering]のためのP2Pメッセージをのサポートを追加しました。

- [Rust Bitcoin #626][]は、ブロックのストリップサイズ（segwitデータをすべて削除したブロック）と、
  トランザクションのvbyteサイズを取得する関数を追加しました。

- [Rust-Lightning #1034][]は、現在閉鎖処理中のチャネルを含む、
  チャネルの残高の完全なリストを取得するために使用できる関数を追加しました。
  これにより、一部の資金が使用可能になるまで承認を待っている場合でも、
  エンドユーザーのソフトウェアは一貫したユーザーの残高を表示することができます。

{% include references.md %}
{% include linkers/issues.md issues="1932,5405,5304,628,580,626,1034,824,22290" %}
[bitcoin core 0.21.2]: https://bitcoincore.org/bin/bitcoin-core-0.21.2/
[alm bips]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019457.html
[towns bips]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019462.html
[zhao post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019464.html
[schroder post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-September/003224.html
[news165 bolts 842]: /ja/newsletters/2021/09/08/#bolts-824
[lightning terminal]: /en/newsletters/2020/08/19/#lightning-labs-releases-lightning-terminal
[tla tweet]: https://twitter.com/andreneves/status/1425651740502892550
[lnurl pay]: https://github.com/fiatjaf/lnurl-rfc/blob/master/lnurl-pay.md
[lightningaddress website]: https://lightningaddress.com/
[lightningaddress diagram]: https://github.com/andrerfneves/lightning-address/blob/master/README.md#tldr
[zbe blog]: https://blog.zebedee.io/browser-extension/
[zebedee wallet]: https://zebedee.io/wallet
[specter v1.6.0]: https://github.com/cryptoadvance/specter-desktop/releases/tag/v1.6.0
[impervious website]: https://www.impervious.ai/
[impervious api]: https://docs.impervious.ai/
[fully noded website]: https://fullynoded.app/
[series preparing for taproot]: /ja/preparing-for-taproot/
