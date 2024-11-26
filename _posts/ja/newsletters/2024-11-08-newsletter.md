---
title: 'Bitcoin Optech Newsletter #328'
permalink: /ja/newsletters/2024/11/08/
name: 2024-11-08-newsletter-ja
slug: 2024-11-08-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin Coreの旧バージョンに影響する脆弱性について掲載しています。
また、Bitcoin Core PR Review Clubミーティングの概要や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など恒例のセクションも含まれています。

## ニュース

- **Bitcoin Coreのバージョン25.1未満に影響する脆弱性の開示:**
  Antoine Poinsotは、Bitcoin Coreの新しい開示ポリシーに先立つ（[ニュースレター #306][news306 disclosure]参照）
  最期の脆弱性の開示をBitcoin-Devメーリングリストで[発表しました][poinsot stall]。
  [詳細な脆弱性レポート][stall vuln]では、Bitcoin Coreのバージョン25.0以前のバージョンは、
  ノードがブロックを再要求するのを最大10分間遅延させる不適切なP2Pプロトコルの応答の影響を受けやすいと指摘しています。
  解決策は、ブロックを「最大3つの高帯域幅のコンパクトブロックピアに同時に要求できるようにすることで、
  そのうちの1つはアウトバウンド接続である必要があります」。バージョン25.1以降にはこの修正が含まれています。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Ephemeral Dust][review club 30239]は、[instagibbs][gh instagibbs]によるPRで、
エフェメラルダストを持つトランザクションを標準とし、
キー付きのアンカーとキーレスのアンカー（[P2A][topic ephemeral anchors]）の両方のユーザービリティを向上させます。
これは、ライトニングネットワークや[Ark][topic ark]、タイムアウトツリーおよび
大規模な事前署名済みツリーやその他の大規模なNパーティスマートコントラクトを含む、
いくつかのオフチェーンコントラクトスキームに関連しています。

エフェメラルダストポリシーの変更により、[ダスト][topic uneconomical outputs]アウトプットを
すぐに使用する有効な[手数料を支払う子][topic cpfp]トランザクションがノードで認識されている場合、
mempoolでゼロ手数料のダストアウトプットを持つトランザクションが許可されます。

{% include functions/details-list.md
  q0="<!--is-dust-restricted-by-consensus-policy-both-->ダストはコンセンサスによって制限されるものですか？またはポリシー？その両方ですか？"
  a0="ダストアウトプットはポリシールールによってのみ制限され、コンセンサスには影響されません。"
  a0link="https://bitcoincore.reviews/30239#l-27"

  q1="<!--how-can-dust-be-problematic-->ダストが問題になる理由は何ですか？"
  a1="ダスト（または非経済的な）アウトプットは、それを使用するのに必要な手数料よりも金額が低いものです。
  それらは使用することができるため、UTXOセットから削除することはできません。
  ただ使用するのに経済的な合理性がないため、そのまま使用されずに残り、UTXOセットのサイズを増加させます。
  UTXOセットのサイズが大きくなると、ノードのリソース要件が高くなります。
  しかし、UTXOは[アンカーアウトプット][topic anchor outputs]の場合のように、
  そのsatoshiの金額以上に外部のインセンティブにより使用されることもあります。"
  a1link="https://bitcoincore.reviews/30239#l-40"

  q2="<!--why-is-the-term-ephemeral-significant-what-are-the-proposed-rules-specific-to-ephemeral-dust-->
  なぜエフェメラルという用語が重要なのですか？エフェメラルダストに特化した提案ルールとは何ですか？"
  a2="「エフェメラル」という用語は、ダストアウトプットがすぐに使用されることを意図していることを示しています。
  エフェメラルダストのルールでは、親トランザクションの手数料が0であることと、
  ダストアウトプットを使用する子トランザクションが1つだけであることが求められます。"
  a2link="https://bitcoincore.reviews/30239#l-50"

  q3="<!--why-is-it-important-to-impose-a-fee-restriction-->手数料の制限を課すことがなぜ重要なのですか？"
  a3="重要な目標は、ダストアウトプットが承認時に未使用のままにならないようにすることです。
  親トランザクションの手数料を0にすることを義務付けると、マイナーは子なしで親をマイニングするインセンティブを失います。
  エフェメラルダストは、コンセンサスルールではなく、ポリシールールであるため、
  経済的なインセンティブが重要な役割を果たします。"
  a3link="https://bitcoincore.reviews/30239#l-56"

  q4="TRUCトランザクションと1P1Cリレーはエフェメラルダストとどう関係しますか？"
  a4="エフェメラルダストのトランザクションは手数料が0である必要があるため、
  単体でリレーすることはできず、[1P1C（1-parent-1-child）][28.0 integration guide]などのメカニズムが不可欠です。
  TRUC（v3）トランザクションは、エフェメラルダストの要件に合わせて、
  未承認の親を1つに制限します。TRUCは現在、
  [`minrelaytxfee`][topic default minimum transaction relay feerates]を
  下回る手数料率のトランザクションを許可する唯一の方法です。"
  a4link="https://bitcoincore.reviews/30239#l-59"

%}

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 27.2][]は、バグ修正を含む以前のリリースシリーズのメンテナンスアップデートです。
  最新バージョンの[28.0][]にすぐにアップグレードしないユーザーは、
  少なくともこの新しいメンテナンスリリースへのアップデートを検討する必要があります。

- [Libsecp256k1 0.6.0][]は、このBitcoin関連の暗号操作のライブラリの最新リリースです。
  「このリリースでは、[MuSig2][topic musig]モジュールが追加され、
  スタックからシークレットをクリアするための非常に堅牢なメソッドが追加され、
  未使用の`secp256k1_scratch_space`関数が削除されます」。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [LDK #3360][]では、公開チャネルが承認されてから1週間、
  6ブロック毎に`channel_announcement`メッセージの再ブロードキャストするようになりました。
  これにより、再ブロードキャストにおけるピアへの依存がなくなり、チャネルが常にネットワークで見えるようになります。

- [LDK #3207][]では、常時オンラインの送信者として静的な[BOLT12][topic offers]インボイスへ支払う際に、
  [非同期支払い][topic async payments]の[Onionメッセージ][topic onion messages]にインボイス要求を含めるサポートを導入しました。
  これは、ニュースレター[#321][news321 invreq]で取り上げたPRには含まれていませんでした。
  支払いのOnionにインボイス要求を含めることは、再試行にも適用されます。
  ニュースレター[#321][news321 retry]をご覧ください。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3360,3207" %}
[news306 disclosure]: /ja/newsletters/2024/06/07/#bitcoin-core
[stall vuln]: https://bitcoincore.org/ja/2024/11/05/cb-stall-hindering-propagation/
[poinsot stall]: https://mailing-list.bitcoindevs.xyz/bitcoindev/uJpfg8UeMOfVUATG4YRiGmyz5MALtZq68FCBXA6PT-BNstodivpqQfDxD1JAv5Qny_vuNr-A1m8jIDNHQLhAQt8hj8Ee9OT6ZFE5Z16O97A=@protonmail.com/
[bitcoin core 27.2]: https://bitcoincore.org/ja/2024/11/04/release-27.2/
[28.0]: https://bitcoincore.org/ja/2024/10/02/release-28.0/
[libsecp256k1 0.6.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.6.0
[news321 invreq]: /ja/newsletters/2024/09/20/#ldk-3140
[news321 retry]: /ja/newsletters/2024/09/20/#ldk-3010
[review club 30239]: https://bitcoincore.reviews/30239
[gh instagibbs]: https://github.com/instagibbs
[28.0 integration guide]: /ja/bitcoin-core-28-wallet-integration-guide/
