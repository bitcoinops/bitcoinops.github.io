---
title: 'Bitcoin Optech Newsletter #326'
permalink: /ja/newsletters/2024/10/25/
name: 2024-10-25-newsletter-ja
slug: 2024-10-25-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、新しいLNチャネルアナウンスの提案のアップデートと、
PSBTでサイレントペイメントを送信するためのBIPについて掲載しています。
また、Bitcoin Stack Exchangeで人気の質問とその回答や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など恒例のセクションも含まれています。

## ニュース

- **<!--updates-to-the-version-1-75-channel-announcements-proposal-->チャネルアナウンス提案バージョン1.75のアップデート**
  Elle Moutonは、[Simple Taproot Channel][topic simple taproot channels]の通知をサポートする
  [新しいチャネルアナウンス][topic channel announcements]プロトコルで提案されている
  いくつかの変更についての説明をDelving Bitcoinに[投稿しました][mouton chanann]。
  最も重要な変更は、メッセージで現在のスタイルのP2WSHチャネルもアナウンスできるようにすることです。
  これにより、ノードは「ネットワークのほとんどがアップグレードしたと思われる時に、[...]
  レガシープロトコルを切り替え始める」ことができるようになります。

  最近議論された別の追加事項（[ニュースレター #325][news325 chanann]参照）は、
  アナウンスにSPVプルーフを含めるようにすることで、
  最大のProof of Workを持つブロックチェーンのヘッダーをすべて持っているクライアントであれば、
  チャネルのファンディングトランザクションがブロックに含まれていることを検証できるようにすることです。
  現在、軽量クライアントがチャネルアナウンスで同レベルの検証を行うには、
  ブロック全体をダウンロードする必要があります。

  Moutonの投稿では、既存のSimple Taproot Channelのオプトインアナウンスについても簡単に触れています。
  現在、非P2WSHチャネルのアナウンスがサポートされていないため、
  既存のすべてのTaproot Channelは[アナウンスされていません][topic unannounced channels]。
  この提案に追加される可能性のある機能は、アナウンスされていないチャネルを公開チャネルに変換したいことを
  ノードがピアに知らせることができるようにする機能です。

- **PSBTでサイレントペイメントを送信するBIPのドラフト:** Andrew Tothは、
  ウォレットと署名デバイスが[PSBT][topic psbt]を使用して
  [サイレントペイメント][topic silent payments]の作成を調整できるようにするためのBIPのドラフトを
  Bitcoin-Devメーリングリストに[投稿しました][toth sp-psbt]。
  これは、以前のBIPのドラフトに関する議論の続きです（ニュースレター[#304][news304 sp]および[#308][news308 sp]参照）。
  以前のニュースレターで言及したように、サイレントペイメントは、
  他のほとんどのPSBT調整トランザクションに比べて特別な要件があり、
  完全に署名されていないトランザクションのインプットに変更を加えた場合、
  アウトプットを修正する必要があります。

  ドラフトでは、署名者がトランザクション内のすべてのインプットの秘密鍵にアクセスできるという、
  予想される最も一般的な状況のみに対処しています。複数の署名者がいるあまり一般的ではない状況についてTothは、
  「これは後続のBIPで定義される」と書いています。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [blk*.datファイル内に重複ブロックはありますか？]({{bse}}124368)
  Pieter Wuilleは、現在のベストブロックチェーンに加えて、
  ブロックデータファイルには古いブロックや重複ブロックデータも含まれると説明しています。

- [Pay-to-Anchorの構成はどのように決定されたのですか？]({{bse}}124383)
  Antoine Poinsotは、Bitcoin Core 28.0の[ポリシーの変更][bcc28 guide]の一部に含まれている
  [P2A（Pay-to-Anchor）][topic ephemeral anchors]アウトプットの構造について説明しています。
  [bech32m][topic bech32]エンコードされた2 byte長のv1 witness programは、
  `bc1pfeessrawgf`というバニティアドレスとして選択されたものです。

- [BIP324のデコイパケットのメリットは何ですか？]({{bse}}124301)
  Pieter Wuilleは、[BIP324][]の仕様に[デコイパケットを含めること][bip324 decoy packets]に関する設計上の決定を概説しています。
  オプションのデコイパケットを使用すると、トラフィックのパターンを難読化し、
  プロトコルの鍵交換やアプリケーション、プロトコルのバージョンのネゴシエーション中の各フェーズにおいて、
  オブザーバーに認識されないようにすることができます。

- [opcodeの制限が201なのはどうしてですか？]({{bse}}124465)
  Vojtěch Strnadは、2010年にSatoshiが行ったコードの変更で、
  opcodeの制限を200にすることが意図されていたものの、実装ミスにより、
  実際には制限が201に設定されたと指摘しています。

- [トランザクションが最小Txリレー手数料を下回っている場合、私のノードはトランザクションをリレーしますか？]({{bse}}124387)
  Murchは、ノードは自身のmempoolに受け入れたトランザクションのみをリレーすると指摘しています。
  ユーザーはノードの`minTxRelayFee`の値を減らしてローカルのmempoolへの受け入れを許可できますが、
  ブロックに低リレー手数料率のトランザクションを含めるためには、
  最終的にマイナーが同様の設定している必要があり、平均手数料率がその低い手数料率に向かって減少する必要があります。

- [Bitcoin CoreのウォレットがBIP69をサポートしないのはどうしてですか？]({{bse}}124382)
  Murchは、[BIP69][]のトランザクションのインプット/アウトプットの順序仕様の普遍的な実装が
  [ウォレットのフィンガープリンティング][ishaana fingerprinting]を軽減するのに役立つことに同意していますが、
  普遍的な採用の可能性が低いことを考慮すると、BIP69の実装自体がフィンガープリンティングの脆弱性であると指摘しています。

- [Bitcoin Core 28.0を使用してtestnet4を有効にするにはどうすればいいですか？]({{bse}}124443)
  Pieter Wuilleは、[BIP94][]の[testnet4][topic testnet]を有効にする2つの設定オプション
  `chain=testnet4`と`testnet4=1`について言及しています。

- [低エントロピーの鍵を使用して`scriptPubKey`を公開するトランザクションをブロードキャストするるとどのようなリスクがありますか？]({{bse}}124296)
  ユーザー Quuxplusone は、2015年の一連のBitcoinのキーグリンディング[「パズル」][puzzle bitcointalk]に関連する
  最近のトランザクションのリンクを提供しています。このパズルは、
  低エントロピーの鍵を対象にmempoolを監視するボットによって[置換された][topic rbf]という[説][puzzle stackernews]があります。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning 24.08.2][]は、この人気のLN実装のメンテナンスリリースで、
  「いくつかのクラッシュの修正と、支払いのためのチャネルヒントを記憶および更新する機能強化が含まれています」。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Eclair #2925][]では、新しい`rbfsplice` APIコマンドを介して
  [スプライシング][topic splicing]トランザクションで[RBF][topic rbf]を使用するためのサポートが導入されました。
  このコマンドは、ピアがトランザクションの置換に同意するための`tx_init_rbf`および`tx_ack_rbf`メッセージの交換をトリガーします。
  この機能は、[ゼロ承認チャネル][topic zero-conf channels]での資金の盗難を防止するため、
  非ゼロ承認チャネルでのみ有効です。未承認のスプライシングトランザクションのチェーンは、
  ゼロ承認チャネルでは許可されますが、非ゼロ承認チャネルでは許可されません。
  さらに、[Liquidity Ads][topic liquidity advertisements]プロトコルを介した流動性購入トランザクションではRBFがブロックされ、
  売り手が支払いを受け取ることなくチャネルに流動性を追加する可能性があるエッジケースを回避します。

- [LND #9172][]では、決定論的なmacaroon（認証トークン）の生成のために、
  `lncli create`コマンドと`lncli createwatchonly`コマンドに新しく`mac_root_key`フラグを追加し、
  LNDが初期化される前に外部の鍵をLNDをノードに組み込むことができるようになりました。
  これは、[LND #8754][]（[ニュースレター #172][news172 remote]参照）で提案されている
  リバースリモート署名者のセットアップと組み合わせると便利です。

- [Rust Bitcoin #2960][]は、[ChaCha20-Poly1305][rfc8439]認証付き暗号（AEAD）アルゴリズムを
  独自のクレートに変更し、[payjoin V2][topic payjoin]など、
  [BIP324][]で定義された[v2トランスポートプロトコル][topic v2 p2p transport]以外でも使用できるようにします。
  コードは、さまざまなユースケースでパフォーマンスを向上させるために、
  SIMD（Single Instruction, Multiple Data）命令用に最適化されています（[ニュースレター #264][news264 chacha]参照）。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2925,9172,2960,8754" %}
[mouton chanann]: https://delvingbitcoin.org/t/updates-to-the-gossip-1-75-proposal-post-ln-summit-meeting/1202/
[news325 chanann]: /ja/newsletters/2024/10/18/#gossip-upgrade
[toth sp-psbt]: https://mailing-list.bitcoindevs.xyz/bitcoindev/cde77c84-b576-4d66-aa80-efaf4e50468fn@googlegroups.com/
[news304 sp]: /ja/newsletters/2024/05/24/#psbt
[news308 sp]: /ja/newsletters/2024/06/21/#psbt
[core lightning 24.08.2]: https://github.com/ElementsProject/lightning/releases/tag/v24.08.2
[news172 remote]: /ja/newsletters/2021/10/27/#lnd-5689
[rfc8439]: https://datatracker.ietf.org/doc/html/rfc8439
[news264 chacha]: /ja/newsletters/2023/08/16/#bitcoin-core-28008
[bcc28 guide]: /ja/bitcoin-core-28-wallet-integration-guide/
[bip324 decoy packets]: https://github.com/bitcoin/bips/blob/22660ad3078ee9bd106e64d44662a59a1967c4bd/bip-0324.mediawiki?plain=1#L126
[ishaana fingerprinting]: https://ishaana.com/blog/wallet_fingerprinting/
[puzzle bitcointalk]: https://bitcointalk.org/index.php?topic=1306983.0
[puzzle stackernews]: https://stacker.news/items/683489
