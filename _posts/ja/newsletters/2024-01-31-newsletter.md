---
title: 'Bitcoin Optech Newsletter #287'
permalink: /ja/newsletters/2024/01/31/
name: 2024-01-31-newsletter-ja
slug: 2024-01-31-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、クラスターmempoolへの移行を容易にするために、
RBFルールを使用してv3トランザクションの置換を可能にする提案と、
一般的に外部的な手数料を必要とすることから`OP_CHECKTEMPLATEVERIFY`に対する反論を掲載しています。
また、Bitcoin Stack Exchangeの主な質問とその回答や、新しいリリースとリリース候補の発表および、
人気のBitcoinインフラストラクチャプロジェクトの注目すべき変更など恒例のセクションも含まれています。

## ニュース

- **<!--kindred-replace-by-fee-->手数料による同類の置換:** Gloria Zhaoは、
  2つのトラランザクションが競合しない場合でも、mempool内のトランザクションの関連トランザクションを置換できるようにすることについて、
  Delving Bitcoinに[投稿しました][zhao v3kindred]。
  2つのトランザクションは、両方が同じブロックチェーン内に存在できない場合、_競合している_ とみなされます。
  これは、通常、両方が同じインプットを使用しようとするためで、
  インプットは特定のブロックチェーン内で１回のみ使用できるというルールに違反します。
  [RBF][topic rbf]のルールは、新しく受信したトランザクションがmempool内のトランザクションと競合しないか比較します。
  Zhaoは、競合ポリシーについて考える理想的な方法を提案しています。
  2つのトランザクションがあり、受け入れられるのは1つだけである場合、最初に到着した方を選択するのではなく、
  目標（実質的に無料のリレーを許可することなくマイナーの収益を最大化するなど）に最も適した方を選択すべきです。
  RBFのルールは、競合に対してこれを行うことを試みており、Zhaoの投稿では、これを競合だけなく関連トランザクションにも拡張しています。

  Bitcoin Coreは、mempoolで同時に許可される関連トランザクションの数とサイズに _ポリシー_ 制限を設けています。
  この制限により、いくつかのDoS攻撃が軽減されますが、前に制限の上限に達した関連トランザクションAを受け取っているため、
  トランザクションBが拒否される可能性があることを意味します。
  これは、Zhaoの原則に反します。代わりに、Bitcoin Coreは、AとBのいずれか実際にその目標に最適なものを受け入れるべきです。

  [v3トランザクションリレー][topic v3 transaction relay]で提案されたルールでは、
  未承認のv3の親は、mempool内に１つの子トランザクションのみを持つことが許可されます。
  どちらのトランザクションもmempool内に他の祖先や依存関係を持つことができないため、
  既存のRBFルールをv3子トランザクションの置き換えに適用するのは簡単で、Zhaoは[それを実装しました][zhao kindredimpl]。
  [先週のニュースレター][news286 imbued]に掲載したように、
  [アンカーアウトプット][topic anchor outputs]を使用する既存のLNのコミットメントトランザクションに自動的にv3ポリシーが登録される場合、
  これによりどちらかの当事者がいつでもコミットメントトランザクションの手数料を引き上げることができます。

  - アリスは、手数料を支払うために子トランザクションを含むコミットメントトランザクションを送信できます。

  - アリスは、後でRBFにより既存の子トランザクションの手数料を増やすことができます。

  - ボブは、より高い手数料を支払う子トランザクションを送信することで、
    同類の置換を利用してアリスの子トランザクションを排除することができます。

  - アリスは、後からより高い手数料を支払う子トランザクションを送信することで、
    ボブの子に対して同類の置換を行うことができます（ボブの子トランザクションを削除します）。

  このポリシーを追加して、現在のLNアンカーに自動的に適用すると、
  [クラスターmempool][topic cluster mempool]の実装に必要な[CPFP carve-outルール][topic cpfp carve out]を削除できるようになります。
  これにより、将来的にはあらゆる種類の置換のインセンティブの互換性が向上するはずです。

  この記事を書いている時点では、フォーラム上でこのアイディアに対する反対意見はありませんでした。
  注目すべき質問の１つは、これにより[エフェメラルアンカー][topic ephemeral anchors]の必要性がなくなるかどうかについてでしたが、
  その提案の作者（Gregory Sanders）は、「エフェメラルアンカーの作業をやめるつもりはありません。
  ゼロsatoshiのアウトプットには、LN以外にも多くの重要なユースケースがあります。」と返信しました。

- **外部的な手数料を要求することを根拠としたCTVへの反対:**
  Peter Toddは、[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]の提案に適用される
  [外部的な手数料][topic fee sourcing]（[ニュースレター #284][news284 ptexogenous]参照）に対する主張を
  Bitcoin-Devメーリングリストに[投稿しました][pt ctv]。彼は、
  「複数の当事者が単一のUTXOを共有できるようにすることを目的とした（ほとんどではないにしても）多くのCTVのユースケースでは、
  考えられるすべての手数料率をカバーするのに十分なCTVのバリエーションを許容することは困難または不可能です。
  CTVは通常、手数料を支払うために[アンカーアウトプット][topic ephemeral anchors]と一緒に使用されることが予想され[...]
  場合によっては[トランザクションスポンサー][topic fee sponsorship]のソフトフォークを介して使用されます。[...]
  すべてのユーザーが手数料を支払うためにUTXOを持つ必要があるというこの要件は、
  CTVを使用したUTXOの共有方式の効率を否定します。[...]唯一の現実的な代替案は、
  UTXOの支払いにサードパーティを使用することです（例：LN支払いを介して）。
  しかし、この点については[帯域外でマイニング手数料][topic out-of-band fees]を支払う方が効率的です。
  もちろん、これはマイニングの集中化の観点から非常に望ましくないことです。」と述べています（
  リンクはOptechが追加しました）。彼は、CTVを放棄し、
  代わりに[RBF][topic rbf]と互換性のある[コベナンツ方式][topic covenants]に取り組むことを推奨しています。

  John Lawは、手数料依存のタイムロックにより（[ニュースレター #283][news283 fdt]参照）、
  一部のコントラクトの決済を不確定期間遅延させるかもしれないが、
  トランザクションの特定のバージョンを期限までに承認する必要がある場合に、
  内部的な手数料を支払うCTVを安全に使用できるようになる可能性があると返信しました。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [現在のBitcoin Coreでは、ブロックの同期はどのように機能しますか？]({{bse}}121292)
  Pieter Wuilleは、ブロックヘッダーツリー、ブロックデータおよびアクティブな先頭のブロックチェーンデータの構造について説明し、
  ヘッダーの同期、ブロックの同期およびブロックのアクティベーションプロセスについて説明しています。

- [<!--how-does-headers-first-prevent-disk-fill-attack-->ヘッダーファーストはディスクフィル攻撃をどのようにして防ぎますか？]({{bse}}76018)
  Pieter Wuilleは、古い質問をフォローアップし、24.0でBitcoin Coreに追加された
  最近のIBD「Headers Presync」（[ニュースレター #216][news216 headers presync]参照）のヘッダースパム軽減策を説明しています。

- [BIP324 v2トランスポートはTorおよびI2P接続では冗長なものですか？]({{bse}}121360)
  Pieter Wuilleは、[匿名ネットワーク][topic anonymity networks]を使用する場合、
  [v2トランスポート][topic v2 p2p transport]の暗号化のメリットがないことを認めていますが、
  v1非暗号化トランスポートよりも計算能力が向上する可能性があると指摘しています。

- [<!--what-s-a-rule-of-thumb-for-setting-the-maximum-number-of-connections-->最大接続数を設定する際の経験則は？]({{bse}}121088)
  Pieter Wuilleは、[アウトバウンド接続とインバウンド接続]({{bse}}121015)を区別し、
  `-maxconnections`に高い値を設定する際の注意点を挙げています。

- [<!--why-isn-t-the-upper-bound-2h-on-the-block-timestamp-set-as-a-consensus-rule-->なぜブロックのタイムスタンプの上限（+2h）はコンセンサスルールとして設定されないのですか？]({{bse}}121248)
  この質問と[その他]({{bse}}121247) の関連する[質問]({{bse}}121253)で、Pieter Wuilleは、
  新しいブロックのタイムスタンプが2時間以内でなければならないという要件と、その要件の重要性、
  「コンセンサスルールはブロックハッシュによってコミットされた情報のみに依存できる」理由について説明しています。

- [Sigop数とそれがトランザクションの選択に与える影響は？]({{bse}}121355)
  ユーザーCosmik Debrisは、署名チェック操作「sigops」の制限がマイナーのブロックテンプレートの構築と
  mempoolベースの[手数料の推定][topic fee estimation]にどのような影響を与えるかを尋ねています。
  ユーザーmononautは、ブロックテンプレートの構築における制限要因であるsigopsの頻度の低さについて説明し、
  `-bytespersigop`オプションについて論じています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [HWI 2.4.0][]は、複数の異なるハードウェア署名デバイスへの共通のインターフェースを提供する
  このパッケージの次期バージョンのリリースです。この新しいリリースでは、
  Trezor Safe 3のサポートが追加され、いくつかの小規模な改善が含まれています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。*

- [Bitcoin Core #29291][]では、`OP_CHECKSEQUENCEVERIFY` opcodeを実行するトランザクションの
  バージョン番号が負であると思われる場合に失敗するテストが追加されています。
  このテストが、代替のコンセンサス実装で実行されていれば、
  [先週のニュースレター][news286 bip68ver]で言及したコンセンサス障害のバグは発見できたでしょう。

- [Eclair #2811][]、[#2813][eclair #2813]、[#2814][eclair #2814]は、
  [トランポリンペイメント][topic trampoline payments]で最終的な受信者に対して
  [ブラインドパス][topic rv routing]を使用する機能を追加しました。
  トランポリンルーティング自体は、通常のOnion暗号化したノードIDを引き続き使用します。
  つまり、各トランポリンノードは次のトランポリンノードのIDを学習します。
  ただし、ブラインドパスが使用されている場合、最後のトランポリンノードは、
  ブラインドパス内の最初の転送ノードのノードIDのみを学習します。
  最終的な受信者のノードIDは学習されません。

  以前は、強力なトランポリンプライバシーは、複数のトランポリン転送者の使用に依存していたため、
  どの転送者も自分が最後の転送者であることを確信できませんでした。
  このアプローチの欠点は、より長いパスが使用されるため、転送が失敗する確率が高まり、
  成功のためにより多くの転送手数料を支払う必要があることです。
  現在は、単一のトランポリンノードを介した支払いの転送でも、
  そのノードが最終的な受信者を学習するのを防止できます。

- [LND #8167][]は、LNDチャネルが、まだ1つ以上の支払い（[HTLC][topic htlc]）の保留があるチャネルの協調クローズを可能にします。
  [BOLT2][]の仕様では、この場合の適切な手順は、一方が`shutdown`メッセージを送信し、
  それ以降新しいHTLCが受け入れられなくなると記載されています。すべての保留中のHTLCがオフチェーンで解決された後、
  両者は交渉して協調クローズトランザクションに署名します。以前は、
  LNDが`shutdown`メッセージを受信すると、チャネルが強制的に閉じられ、
  決済のために追加のオンチェーントランザクションと手数料が必要でした。

- [LND #7733][]は、[ウォッチタワー][topic watchtowers]のサポートを更新し、
  現在LNDによって実験的にサポートされている[Simple Taproot Channel][topic simple taproot channels]の
  バックアップと正しいシャットダウンを強制できるようになりました。

- [LND #8275][]は、[BOLTs #1092][]で定義されているように、
  ピアが特定の普遍的にデプロイされた機能（[ニュースレター #259][news259 lncleanup]参照）をサポートすることを要求するようになりました。

- [Rust Bitcoin #2366][]は、`Transaction`オブジェクトの`.txid`プロパティを廃止し、
  代わりに`.compute_txid`という名前のプロパティを提供するようになりました。
  `.txid`プロパティが呼ばれるたびに、トランザクションのtxidが計算され、
  これは十分なCPUを消費するため、大きなトランザクションや多数の小さなトランザクションで関数を実行している人にとっては問題になります。
  このプロパティの新しい名前は、下流のプログラマーがその潜在的なコストを認識するのに役立つと期待されています。
  `.wtxid`プロパティと`.ntxid`プロパティ（それぞれ[BIP141][]と[BIP140][]に基づく）も同様に、
  `.compute_wtxid`と`.compute_ntxid`にリネームされています。

- [HWI #716][]は、Trezor Safe 3ハードウェア署名デバイスのサポートを追加しました。

- [BDK #1172][]は、ウォレット用にブロック単位のAPIを追加しました。
  ウォレットに影響するトランザクションが含まれていると思われる一連のブロックにアクセスできるユーザーは、
  それらのブロックを反復処理して、ブロック内のトランザクションに基づいてウォレットを更新できます。
  これは、チェーン上のすべてのブロックを反復するために簡単に使用できます。
  あるいは、ソフトウェアはある種のフィルタリング方法（[コンパクトブロックフィルター][topic compact block filters]など）を使用して、
  ウォレットに影響するトランザクションを持つ可能性のあるブロックのみを見つけて、
  ブロックのサブセットを反復処理することも可能です。

- [BINANAs #3][]は、BIPやBOLT、BLIP、SLIP、LNPBPおよびDLCの仕様など、
  Bitcoinに関連する仕様リポジトリのリストを定義した[BIN24-5][]を追加しました。
  他の関連プロジェクトの仕様リポジトリもいくつかリストアップされています。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29291,2811,2813,2814,8167,7733,8275,1092,2366,716,1172,3" %}
[hwi 2.4.0]: https://github.com/bitcoin-core/HWI/releases/tag/2.4.0
[news286 bip68ver]: /ja/newsletters/2024/01/24/#btcd
[news283 fdt]: /ja/newsletters/2024/01/03/#fee-dependent-timelocks
[zhao v3kindred]: https://delvingbitcoin.org/t/sibling-eviction-for-v3-transactions/472
[news259 lncleanup]: /ja/newsletters/2023/07/12/#ln
[news284 ptexogenous]: /ja/newsletters/2024/01/10/#frequent-use-of-exogenous-fees-may-risk-mining-decentralization
[zhao kindredimpl]: https://github.com/bitcoin/bitcoin/pull/29306
[pt ctv]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022309.html
[news286 imbued]: /ja/newsletters/2024/01/24/#v3
[news216 headers presync]: /ja/newsletters/2022/09/07/#bitcoin-core-25717
