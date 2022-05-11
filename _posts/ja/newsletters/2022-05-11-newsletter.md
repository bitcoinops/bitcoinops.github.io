---
title: 'Bitcoin Optech Newsletter #199'
permalink: /ja/newsletters/2022/05/11/
name: 2022-05-11-newsletter-ja
slug: 2022-05-11-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のショートニュースレターは、Bitcoin Core PR Review Clubのミーティングの概要と、
Rust Bitcoinのアップデートを掲載しています。

## ニュース

今週は、特に大きなニュースはありませんでした。
[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]や[SIGHASH_ANYPREVOUT][topic sighash_anyprevout]など、
以前取り上げたトピックには多くのコメントが寄せられましたが、
その多くは技術的なものでなかったり、広く関連するとは思えない細かい内容でした。
このニュースレターの編集中に、開発者向けのメーリングリストにいくつかの興味深い投稿があったので、
来週詳しくご紹介します。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Improve Indices on pruned nodes via prune blockers][review club pr]は、Fabian JahrによるPRで、
ブロックストレージからブロックをプルーニングしても安全であることを判断するための新しい方法を導入しています。
この新しい方法は、プルーニングノードがCoinstatsインデックスを維持することを可能にし、
検証モジュールのインデックス関連のコードへの依存性を削除します。

{% include functions/details-list.md

  q0="<!--what-indexes-currently-exist-in-bitcoin-core-and-what-do-they-do-->現在Bitcoin Coreにどのようなインデックスが存在し、それらは何をするのですか？"
  a0="ノードは、ディスクからデータを効率的に取得するために、最大3つのオプションのインデックスを維持することができます。
トランザクションインデックス（`-txindex`）は、トランザクションハッシュをトランザクションのあるブロックにマッピングします。
ブロックフィルターインデックス（`-blockfilterindex`）は、各ブロックのBIP157ブロックフィルターのインデックスを作成します。
coin statsインデックス（`-coinstatsindex`）は、UTXOセットの統計情報を格納します。"
  a0link="https://bitcoincore.reviews/21726#l-28"

  q1="<!--what-is-a-circular-dependency-why-do-we-want-to-avoid-them-when-possible-->循環依存性とは何ですか？なぜ可能な限り避けた方がいいのですか？"
  a1="2つのコードモジュール間の循環依存性は、両方が一方なしには使用できない場合に存在します。
循環依存性はセキュリティ上の問題ではありませんが、コードの構成が良くないことを意味し、
特定のモジュールや機能を分離して構築、テストすることが難しくなるため、開発の妨げになります。"
  a1link="https://bitcoincore.reviews/21726#l-44"

  q2="<!--how-do-the-prune-blockers-introduced-in-this-commit-review-club-commit-work-->[このコミット][review club commit]で導入されたプルーニングブロッカーはどのように動作しますか？"
  a2="PRは'prune locks'のリストを導入します。これは各インデックスに対して保持しなければならない最も古いブロック高を表します。
`CChainState::FlushStateToDisk`では、ノードがどのブロックをプルーニングするか決定する際に、
その高さより高いブロックのプルーニングを回避します。インデックスが最適なブロックインデックスのビューを更新する度に、
プルーニングブロックも更新されます。"
  a2link="https://bitcoincore.reviews/21726#l-68"

  q3="<!--what-are-the-benefits-and-costs-of-this-approach-to-pruning-compared-to-the-old-one-->このプルーニングのアプローチはこれまでのものと比べてどんな利点とコストがあるのでしょうか？"
  a3="これまでは、`CChainState::FlushStateToDisk`のロジックは、
プルーニングをやめるブロックを知るために、インデックスにその最高の高さを照会していました。
つまりインデックスと検証ロジックは互いに依存していました。
現在は、プルーニングロックは、積極的に計算されるため、
より頻繁に計算される可能性がありますが、インデックスを照会するための検証は必要なくなりました。"
%}

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Rust Bitcoin #716][]は、単位やその他のユーザー向けの量のための設定可能な表示タイプである`amount::Display`を追加しました。
  このパッチは、デフォルトで数値のすべての表現を最小の幅に縮小し、
  それによって[BIP21][] URIが不必要に長くなったり、
  よくQRコードを必要以上に大きくしたりスキャンしにくくする原因となっていた余分なゼロの使用が削減されます。

{% include references.md %}
{% include linkers/issues.md v=2 issues="716" %}
[review club commit]: https://github.com/bitcoin-core-review-club/bitcoin/commit/527ef4463b23ab8c80b8502cd833d64245c5cfc4
[review club pr]: https://bitcoincore.reviews/21726
