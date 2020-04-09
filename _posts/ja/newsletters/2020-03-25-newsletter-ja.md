---
title: 'Bitcoin Optech Newsletter #90'
permalink: /ja/newsletters/2020/03/25/
name: 2020-03-25-newsletter-ja
slug: 2020-03-25-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin StackExchangeからのいくつかの質問と回答のまとめ、Bitcoinインフラプロジェクトの注目すべき変更点をお届けします。

## Action items

*今週は特になし。*

## News

*今週はビットコインのインフラ整備に関する大きなニュースは特になし。*

## Selected Q&A from Bitcoin StackExchange

*[Bitcoin StackExchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・答えを紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [なぜbanscoreはデフォルトで100になっているのですか？]({{bse}}93795)匿名ユーザは`banscore`の背景にある歴史について説明しています。`banscore`は不正な動きを行うピアからノードを守るためのものです。いくつかの違反行為は100ポイント増加となり、該当ピアはデフォルトの`banscore`の設定配下では即座に追放されますが、[`net_processing.cpp`][bitcoin net processing]で詳細に説明されているその他の違反行為は、それぞれスコアが異なります。

- [ブロック<!--why-is-block-620826-s-timestamp-1-second-before-block-620825-->620826のタイムスタンプがブロック620825の1秒前なのはなぜですか？]({{bse}}93696)Andrew ChowとRaghav Soodは、ブロックヘッダのタイムスタンプ・フィールドが以前のブロックよりも大きな値を持つ必要はないことを説明しています。ただし、新しいブロックのタイムスタンプは、過去11ブロックの中央値よりも大きくなければならず、ノードを実行しているコンピュータの時計ベースで現在時刻から2時間以降になってはならないという要件があります。

- [miniscriptポリシー言語仕様書はどこにありますか？]({{bse}}93764)Andrew ChowとPieter Wuilleは、[miniscript][topic miniscript]ポリシー言語がどのようにしてminiscriptにコンパイルされるかについては仕様がなく、現在のC++とRustの実装では、事実上あらゆる可能性を試した結果として最小の`scriptWitness`サイズになるminiscriptを選択していると説明しています。

## Notable code and documentation changes

*今週の[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Eclair #1339][]では、ユーザがhtlc-minimumを0 milli-satoshisに設定することを防ぎます。これは[BOLT2][]<!-- "A
  receiving node [...] receiving an `amount_msat` equal to 0 [...]
SHOULD fail the channel." -->に違反します。新しい下限は1 milli-satoshisとなります。

- [LND #4051][]はピアごとに最大10個のエラーを追跡し、必要に応じて再接続時に保存します。最新のエラーメッセージが`ListPeers`の結果の一部として返されるため、問題の診断が容易になります。

- [BOLTs #751][]は、ノードが指定されたタイプ（IPv4、IPv6、またはTorなど）の複数のIPアドレスをアナウンスできるよう[BOLT7][]を更新します。これにより、マルチホームノードが自分たちのネットワーク状態（アドレス）をより効果的にアナウンスできるようになります。いくつかのLN実装では、すでに複数のアドレスのアナウンスを許可していたので、この変更により、BOLT仕様は現状のLN実装と一致する形になりました。

{% include references.md %}
{% include linkers/issues.md issues="1339,3697,4051,751" %}
[bitcoin net processing]: https://github.com/bitcoin/bitcoin/blob/master/src/net_processing.cpp
