---
title: 'Bitcoin Optech Newsletter #188'
permalink: /ja/newsletters/2022/02/23/
name: 2022-02-23-newsletter-ja
slug: 2022-02-23-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、手数料の引き上げ方法とトランザクション手数料のスポンサーシップに関する議論、
LNゴシップワイヤープロトコルの更新の提案、`OP_CHECKTEMPLATEVERIFY`のテスト用のsignetの発表について掲載しています。
また、Bitcoin Stack Exchangeから厳選された質問と回答や、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更点についての説明など、
恒例のセクションも含まれています。

## ニュース

- **<!--fee-bumping-and-transaction-fee-sponsorship-->手数料の引き上げ方法とトランザクション手数料のスポンサーシップ:**
  数週間前に始まったReplace-By-Feeの議論（[ニュースレター #186][news186 rbf]参照）とは別に、
  今週James O'Beirneは、手数料の引き上げ方法について議論を[始めました][obeirne bump]。
  特に、O'Beirneは、提案されているトランザクションリレーポリシーの変更の一部が、
  ユーザーやウォレット開発者にとって手数料の引き上げ方法を複雑にしてしまうことを懸念しています。
  代替案として、彼は（以前[ニュースレター #116][news116 sponsorship]で紹介した）
  [トランザクション手数料のスポンサーシップ][topic fee sponsorship]について改めて検討することを求めています。

  このアイディアはメーリングリスト上で大きな議論をよび、
  多くの回答が手数料のスポンサーシップの実装の課題に言及しています。

- **LNゴシップの更新提案:** Rusty Russellは、
  Lightning-Devメーリングリストに、[ニュースレター #55][news55 gossip]に掲載した2019年の彼の提案と同様の、
  新しいLNゴシップメッセージのセットに関する詳細な提案を[投稿しました][russell gossip]。
  新しい提案では、[BIP340][]形式の[Schnorr署名][topic schnorr signatures]と[x-only public key][news72 xonly]が使用されています。
  また、ルーティング用にパブリックチャネルの存在を通知するために使用される既存のLNゴシッププロトコルに対する多くの簡略化も含まれています。
  更新されたプロトコルは、特に[Erlay][topic erlay]のような[Minisketch][topic minisketch]ベースの効率的なゴシッププロトコルと組み合わせた場合に、
  効率が最大化するよう設計されています。

- **CTV signet:** Jeremy Rubinは、
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]を有効にした[signet][topic signet]のパラメーターとコードを[公開しました][rubin ctv signet]。
  これにより、提案されたopcodeの公開実験が簡単になり、そのコードを使用する異なるソフトウェア間の互換性をテストすることが容易になりました。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--will-a-post-subsidy-block-with-no-transactions-include-a-coinbase-transaction-->報酬がなくなった後のトランザクションを含まないブロックにコインベーストランザクションは含まれますか？]({{bse}}112193)
  Pieter Wuilleは、すべてのブロックにコインベーストランザクションが必要であり、
  すべてのトランザクションには少なくとも1つのインプットとアウトプットが必要であるため、
  （手数料も報酬もない）ブロック報酬のないブロックでも、少なくとも1つの値0のアウトプットが必要になると説明しています。

- [Scriptが無効なのにどうしてジェネシスブロックに任意のデータを入れることができるのですか？]({{bse}}112439)
  Pieter Wuilleは、ジェネシスブロックのコインベースの"Chancellor..."というテキストのプッシュが有効な理由を説明しています。
  まず、[ジェネシスブロック][bitcoin se 13122]は定義上有効です。
  次に、コインベースのインプットのScriptが実行されることはありません。
  3つめに、非Taprootのインプットの場合、実行後のスタックに単一の要素のみ残るというのは、コンセンサスルールではなくポリシーのルールに過ぎません。
  最後に、このポリシールールは、インプットのScriptが対応するアウトプットのScriptと一緒に実行された後の最終的なスタックにのみ適用されます。
  コインベーストランザクションのインプットには対応するアウトプットScriptが存在しないため、このポリシーは適用されません。
  Wuilleは、また、ジェネシスブロックが使用不可能な理由は、今回の議論とは無関係であり、
  オリジナルのBitcoinソフトウェアが内部のデータベースに[ジェネシスブロックを追加していない][bitcoin github genesis]ことが関係していると指摘しています。

- [Feeler Connectionとは何ですか？どんな時に使われますか？]({{bse}}112247)
  ユーザーvnprcは、デフォルトの8つのアウトバウント接続と2つのブロックオンリーのアウトバウント接続とは別の、
  一時的なアウトバウント接続であるBitcoin Coreの[Feeler Connection][chaincode p2p]の目的について説明しています。
  Feeler Connectionは、ゴシップネットワークから提案された新しいピアの可能性をテストしたり、
  排除の候補となる以前到達できなかったピアをテストするために使用されています。

- [OP_RETURNトランザクションは、chainstateデータベースに保存されないのですか？]({{bse}}112312)
  Antoine Poinsotは、`OP_RETURN`アウトプットは[使用不可能][bitcoin github unspendable]であるため、
  [chainstateディレクトリ][bitcoin docs data]には保存されないと指摘しています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #24307][]は、`getwalletinfo`RPCのresultオブジェクトを`external_signer`フィールドで拡張しています。
  この新しいフィールドは、ウォレットがハードウェア署名デバイスのような外部署名者を使用するよう設定されているかどうかを示します。

- [C-Lightning #5010][]では、言語バインディング生成ツール`MsgGen`とRustのRPCクライアント`cln-rpc`が追加されました。
  `MsgGen`は、C-LightningのJSON-RPCスキーマを解析し、
  `cln-rpc`がC-LightningのJSON-RPCインターフェースを正しく呼び出すために使用されるRustのバインディングを生成します。

- [LDK #1199][]は、複数のノードのうちどれでも受け入れ可能な支払いでロードバランシングに使用することができる"ファントムノード支払い"のサポートを追加しました。
  これは、同じ存在しない（ファントム）ノードへの複数の経路を提案する[BOLT11][]のルートヒントを使用してLNインボイスを作成する必要があります。
  各経路において、ファントムノードに到達する前の最後のホップは、
  [ステートレスインボイス][topic stateless invoices]の復号化および再構築が可能な（[ニュースレター #181][news181 rl1177]参照）
  ファントムノードの鍵を知っている実ノードで、支払いの[HTLC][topic htlc]の受け入れが可能です。

  {:.center}
  ![Phantom node route hints illustration](/img/posts/2022-02-phantom-node-payments.dot.png)

{% include references.md %}
{% include linkers/issues.md v=1 issues="24307,5010,1199," %}
[news186 rbf]: /ja/newsletters/2022/02/09/#rbf
[obeirne bump]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019879.html
[news116 sponsorship]: /en/newsletters/2020/09/23/#transaction-fee-sponsorship
[russell gossip]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-February/003470.html
[news72 xonly]: /ja/newsletters/2019/11/13/#x-only-pubkeys
[news55 gossip]: /en/newsletters/2019/07/17/#gossip-update-proposal
[rubin ctv signet]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019925.html
[news181 rl1177]: /ja/newsletters/2022/01/05/#rust-lightning-1177
[bitcoin se 13122]: https://bitcoin.stackexchange.com/a/13123/87121
[bitcoin github genesis]: https://github.com/bitcoin/bitcoin/blob/9546a977d354b2ec6cd8455538e68fe4ba343a44/src/main.cpp#L1668
[chaincode p2p]: https://residency.chaincode.com/presentations/bitcoin/ethan_heilman_p2p.pdf#page=18
[bitcoin github unspendable]: https://github.com/bitcoin/bitcoin/blob/280a7777d3a368101d667a80ebc536e95abb2f8c/src/script/script.h#L539-L547
[bitcoin docs data]: https://github.com/bitcoin/bitcoin/blob/master/doc/files.md#data-directory-layout
