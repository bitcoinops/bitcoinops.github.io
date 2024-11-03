---
title: 'Bitcoin Optech Newsletter #193'
permalink: /ja/newsletters/2022/03/30/
name: 2022-03-30-newsletter-ja
slug: 2022-03-30-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin Coreのmempool内でトランザクションwitnessを置換できるようにする提案と、
LNゴシッププロトコルの更新に関する継続的な議論のまとめを掲載しています。
また、Bitcoin Stack Exchangeから選ばれた質問と回答、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更といった恒例のセクションも含まれています。

## ニュース

- **トランザクションwitnessの置換:** Larry Ruaneは、Bitcoin-Devメーリングリストに、
  txidが同じでより小さいwitnessを持つ（したがってwtxidは異なる）同じトランザクションの置換を許可することについて、
  情報と意見を[求めました][ruane witrep]。
  Ruaneは、トランザクションの他の詳細（アウトプットのアドレスや量など）に変更を加えることなく、
  witnessのサイズが変わる可能性のあるトランザクション（例えば、
  [Taproot][topic taproot]でkeypathの代わりにscriptpathを使用するなど）を作成するアプリケーションに関する情報を求めていました。

  現在もしくは提案中のアプリケーションで、witnessの置換ができると便利なものがある場合、
  Ruaneは、置換を可能にするのにwitnessをどの程度削減する必要があるかについてもフィードバックを求めています。
  必要な削減が多いほど、置換は少なくなり、最悪の場合に攻撃者によって消費される可能性のあるノードの帯域幅を制限することができます。
  しかし、より多くの削減を要求すると、アプリケーションはwitnessの置換によって小規模もしくは中規模の節約はできなくなります。

- **LNゴシッププロトコルの更新に関する継続議論:** [ニュースレター #188][news188 gossip]で報告したように、
  LNプロトコル開発者は、利用可能なペイメントチャネルに関する情報を配信するために使用するLNのゴシッププロトコルをどう改訂するかについて議論しています。
  特に今週は、2つのスレッドが活発でした:

  - *<!--major-update-->メジャーアップデート:* 先月のRusty Russellの[メジャーアップデート][russell gossip2]の提案に対して、
    Olaoluwa Osuntokunは、オンチェーン資金と特定のLNチャネルとの間のリンクに、
    もっともらしい否認を導入する提案の側面に繰り返し懸念を[表明しました][osuntokun gossip1.1]。
    この機能により、非LNユーザーが実際には存在しないかもしれないチャネルの存在を配信することが容易になり、
    ネットワークを介して資金を受け取るノードへの有効な経路を見つけるための送信者の能力が低下する可能性があります。

  - *<!--minor-update-->マイナーアップデート:* Osuntokunは、
    主にTaprootベースのチャネルを可能にすることを目的としたゴシッププロトコルの小さなアップデートのための別の提案を[投稿しました][osuntokun gossip2]。
    この提案では、[MuSig2][topic musig]を使用して、
    関連する4つの公開鍵（2つのノード識別鍵と、2つのチャネル使用鍵）すべてに関連する承認を単一の署名でできるようにし、
    MuSig2を使用してチャネルのセットアップトランザクションを使用可能にする必要があります。

    彼はまた、チャネルアナウンスのメッセージにSPVの部分的なマークルブランチプルーフを追加することが役立つかもしれないと提案しました。
    これにより、チャネルのセットアップトランザクションがブロックに含まれていることが証明され、
    軽量クライアントが、その存在を検証するのにトランザクションを含むブロック全体をダウンロードする必要がなくなります。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--what-are-the-advantages-or-disadvantages-to-address-reuse-->アドレス再利用のメリット、デメリットは何ですか？]({{bse}}112955)
  RedGrittyBrickとPieter Wuilleは、アドレス再利用のデメリットとして
  プライバシーや公開鍵の露出に関する議論の余地のある懸念などを挙げています。
  Wuilleはさらに、新しいアドレスの生成で追加の経済的なコストは発生しないが、
  ウォレットソフトウェアやバックアップ、ユーザービリティが複雑になると述べています。

- [<!--what-is-a-block-relay-only-connection-and-what-is-it-used-for-->block-relay-only接続とは何ですか？また何のために使用されますか？]({{bse}}112828)
  ユーザーvnprcは、block-relay-only接続とは、ブロック情報は中継するが、
  トランザクションや潜在的なピアのネットワークアドレスは中継しないピアのことであると説明しています。
  この接続は、Bitcoinのネットワークトポロジーグラフの決定を困難にすることで、
  分断攻撃（[エクリプス][topic eclipse attacks]とも呼ばれる）からの保護に役立ちます。
  vnprcはさらに、エクリプス攻撃に対してさらに抵抗する、
  ノードの再起動後も持続するblock-relay-only接続であるアンカー接続について説明しています。

- [<!--is-timestamping-needed-for-anything-except-difficulty-adjustment-->タイムスタンプは難易度調整以外に必要ですか？]({{bse}}112929)
  Pieter Wuilleは、ブロックヘッダーの`nTime`タイムスタンプフィールドに関する制限
  （[Median Time Past (MTP)][news146 mtp]より大きく、2時間以上先であってはならない）を説明し、
  ブロックのタイムスタンプが[難易度][wiki difficulty]の計算とトランザクションの[タイムロック][topic timelocks]に使われることを指摘しています。

- [<!--how-are-attempts-to-spend-from-a-timelocked-utxo-rejected-->タイムロックされたUTXOを使用しようとする、どのように拒否されるのですか？]({{bse}}112989)
  Pieter Wuilleは、トランザクションの`nLockTime`フィールドを使用したトランザクションのタイムロックと、
  Scriptの[`OP_CHECKLOCKTIMEVERIFY`][BIP65] opcodeを使用して強制されるタイムロックを区別しています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BDK 0.17.0][]は、Bitcoinのウォレットを構築するためのこのライブラリのリリースです。
  このバージョンの改良により、ウォレットがオフラインの時もアドレスの導出が簡単になります。

- [Bitcoin Core 23.0 RC2][]は、この重要なフルノードソフトウェアの次のメジャーバージョンのリリース候補です。
  [リリースノートのドラフト][bcc23 rn]には、複数の改善点が記載されており、
  上級ユーザーとシステム管理者には最終リリース前の[テスト][test guide]が推奨されます。

- [LND 0.14.3-beta.rc1][]は、この人気のあるLNノードソフトウェアのいくつかのバグ修正を含むリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [C-Lightning #5078][]は、ノードが同じピアへの複数のチャネルを効果的に使用できるようにします。
  これには、代替チャネルの方が適している場合に、
  ルーティングメッセージで指定されたものとは異なるチャネル（ただし同じピア）で支払いをルーティングすることも含まれます。

- [C-Lightning #5103][]では、特定のチャネルのルーティング手数料、
  最小支払い額および最大支払い額を設定する新しい`setchannel`コマンドを追加しています。
  これは現在非推奨となっている`setchannelfee`コマンドに代わるものです。

- [C-Lightning #5058][]では、[BOLTs #962][]でLNの仕様からの削除が提案された、
  オリジナルの固定長のOnionデータフォーマットのサポートが削除されました。
  アップグレードされた可変長フォーマットは、約3年前に[仕様に追加され][bolts #619]、
  BOLTs #962のPRで言及されたネットワークスキャンの結果では、17,000の公開ノードのうち、
  5つを除くすべてのノードでサポートされていることが示されています。

- [LND #5476][]は、`GetTransactions` RPCと `SubscribeTransactions` RPCの結果を更新し、
  支払われる金額とScript、アドレス（Script）が内部ウォレットに属するかどうかなど、
  作成されるアウトプットに関する追加情報を提供します。

- [LND #6232][]は、すべての[HTLC][topic htlc]が、
  HTLCインターセプターフックに登録されたプラグインによって処理されるよう要求できる設定を追加しました。
  これにより、HTLCインターセプターが自身を登録する前に、
  HTLCが受け入れられたり拒否されたりすることがなくなります。
  HTLCインターセプターを使用すると、外部プログラムを呼び出してHTLC（支払い）を検査し、
  それを受理するか拒否するかを決定できるようになります。

{% include references.md %}
{% include linkers/issues.md v=1 issues="5078,5103,5058,962,619,5476,6232" %}
[bitcoin core 23.0 rc2]: https://bitcoincore.org/bin/bitcoin-core-23.0/
[bdk 0.17.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.17.0
[lnd 0.14.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.3-beta.rc1
[bcc23 rn]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Notes-draft
[ruane witrep]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020167.html
[osuntokun gossip2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-March/003526.html
[osuntokun gossip1.1]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-March/003527.html
[news188 gossip]: /ja/newsletters/2022/02/23/#ln
[russell gossip2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-February/003470.html
[test guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Candidate-Testing-Guide
[wiki difficulty]: https://en.bitcoin.it/wiki/Difficulty
[news146 mtp]: /ja/newsletters/2021/04/28/#what-are-the-different-contexts-where-mtp-is-used-in-bitcoin-bitcoin-mtp
