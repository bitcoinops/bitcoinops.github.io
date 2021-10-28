---
title: 'Bitcoin Optech Newsletter #172'
permalink: /ja/newsletters/2021/10/27/
name: 2021-10-27-newsletter-ja
slug: 2021-10-27-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin Stack Exchangeからの人気のある質問と回答や、
Taprootの準備に関する情報、新しいリリースおよびリリース候補のリスト、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更点などの恒例のセクションが含まれています。

## ニュース

*今週は重要なニュースはありません。*

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--where-to-find-the-exact-number-of-hashes-required-to-mine-most-recent-block-->最新のブロックをマイニングするために必要なハッシュの正確な数はどこで分かりますか？]({{bse}}110330)
  Pieter Wuilleは、ブロックを生成するために試行されたハッシュ数は公開されてないが、
  ブロックの[難易度][wiki difficulty]を4,295,032,833倍した式を使えば、
  ブロックを解くために必要なハッシュ数を簡単に見積もることができると述べています。

- [<!--using-a-2-of-3-taproot-keypath-with-schnorr-signatures-->Taprootのkeypathで2-of-3のSchnorr署名を使用していますか？]({{bse}}110249)
  Pieter Wuilleは、[BIP340][]は1つの鍵と1つの署名を求めますが、
  [FROST][frost whitepaper]のような[閾値署名][topic threshold signature]スキームや
  [MuSig][topic musig]のような[マルチシグ][topic multisignature]スキームなどを使用することも可能であると指摘しています。

- [<!--why-coinbase-maturity-is-defined-to-be-100-and-not-50-->コインベースが使用可能になるのに50ではなく100と定義されているのはなぜですか？]({{bse}}110085)
  ユーザーliorkoは、Bitcoinの[コインベースが使用可能になる][se coinbase maturity]期間が、
  50ではなく100という定数が選択された理由を質問しています。
  回答では、この選択には説明がなく、恣意的な選択である可能性があると指摘しています。

- [<!--why-does-bitcoin-use-double-hashing-so-often-->Bitcoinがダブルハッシュを頻繁に使用するのはなぜですか？]({{bse}}110065)
  Pieter Wuilleは、double-SHA256とSHA256+RIPEMD160のダブルハッシュスキームがBitcoinで最初に使用された場所をリストアップし、
  新しい機能で同じスキームが使用された場所を指摘し、
  Satoshiが特定の攻撃を緩和するために、誤って、これらのダブルハッシュスキームを使用したという仮説を立てています。

## Taprootの準備 #19: 将来のコンセンサスの変更

*ブロック高{{site.trb}}のTaprootのアクティベーションに向けて、
開発者やサービスプロバイダーがどのような準備をすればよいかについての週刊[シリーズ][series preparing for taproot]です。*

{% include specials/taproot/ja/19-future.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Rust-Lightning 0.0.102][]は、いくつかのAPIの改善と、
  LNDノードでチャネルを開けないバグの修正を行ったリリースです。

- [C-Lightning 0.10.2rc1][]は、[経済合理性のないアウトプットのセキュリティ問題][news170 unec bug]の修正、
  データベースサイズの縮小、`pay`コマンドの有効性の向上（下記の*注目すべき変更*のセクションを参照）などが[含まれた][decker tweet]リリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #23002][]では、新しいウォレットを作成する際に、
  [descriptor][topic descriptors]ベースのウォレットをデフォルトにします。
  descriptorベースのウォレットは、[Bitcoin Core PR #16528][optech pr16528]で初めて導入されました。
  すべてのウォレットをdescriptorベースのものに移行し、最終的にレガシーウォレットのサポートを終了させるという
  [長期的な計画][Bitcoin Core #20160]があります。

- [Bitcoin Core #22918][]は、`getblock`RPCと`/rest/block/`エンドポイントを拡張し、
  ブロックで使用されている以前作成された各アウトプット（"prevout"）に関する情報を含む
  新しいレベルのverbosity (`3`)を提供します。

    ブロックが新しい未使用トランザクションアウトプット（UTXO）を作成すると、
    Bitcoin Coreはそれをデータベースに保存します。後続のトランザクションがそのUTXOを使おうとすると、
    Bitcoin Coreはそれをデータベースから取得し、それを使用するために必要な条件をすべて満たしているかどうか
    （正しい公開鍵に対する有効な署名が含まれているかなど）検証します。
    ブロック内のすべての支払いが有効な場合、
    Bitcoin CoreはこれらのprevoutのエントリーをUTXOデータベースから*undo*ファイルに移動します。
    このファイルは、その後でブロックが再編成中にチェーンから削除された場合に、
    UTXOデータベースを以前の状態に戻すために使用できます。

    このPRは、undoファイルからprevoutを取得し、ブロックに実際に含まれているか、
    その内容から計算される情報の一部としてそれらを含めます。
    prevoutのデータを必要とするユーザーやアプリケーションにとっては、
    各トランザクションとそのアウトプットを直接調べるよりも、この方法の方がはるかに高速で便利です。
    プルーニングを有効にしているフルノードでは、古いundoファイルは削除されるため、
    これらのブロックに対して新しいverbosityレベル3を使用することはできません。

- [C-Lightning #4771][]は、他の条件が同じであれば、
  より大きな資金量（チャネルキャパシティ）を持つチャネルを含む経路を優先するよう`pay`コマンドを更新しました。
  チャネルの総資金量は公開されていますが、チャネルの各方向にどれだけの資金があるかは公開されていません。
  しかし、2つのチャネルがそれぞれある状態になる[確率が等しい][prob path]場合、
  キャパシティが大きいチャネルの方が小さいチャネルよりも支払いサイズを処理できる可能性が高いと言えます。

- [C-Lightning #4685][]では、[BOLTs #891][]のドラフト仕様に基づいた
  実験的な[websocket][]トランスポートが追加されています。
  これにより、C-Lightning（および、同じプロトコルをサポートする他のLN実装）は、
  ピアとの通信に使用する代替ポートを配信できるようになります。
  基本的なLN通信プロトコルは同じまま、純粋なTCP/IPではなく、バイナリのwebsocketフレームを使って実行されるだけです。

- [Eclair #1969][]は、`findroute*`系のAPIコールに、
  `ignoreNodeIDs`、`ignoreChannelIDs`および`maxFeeMsat`というパラメータを追加しました。
  また、発見した経路に関するすべての情報を返す`full`フォーマットも追加されています。

- [LND #5709][] (元々は [#5549][lnd #5549]) は、
  Lightning Pool（[ニュースレター #123][news123 pool]参照）をサポートするノード間（現在はLNDノードのみ）で使用するための
  新しいコミットメントトランザクションフォーマットを追加しました。
  この新しいフォーマットにより、チャネルのリースをオファーするノードは、
  リース期間が終了するまで、その資金をオンチェーンで使用することができなくなります。
  これによりリース期間中はチャネルを開いておき、
  資金（流動性）を使ってルーティング手数料を稼げるようにするというインセンティブが働きます。
  チャネルのコミットメントトランザクションフォーマットは、チャネルが開いている間、
  その2つのダイレクト・ピア間でのみ確認されるため、ネットワーク上の他のノードに影響を与えること無く、
  どんなフォーマットでも使用することができます。

- [LND #5346][]では、LNDノードとそのピアが、タイプ識別子が32,767以上のカスタムメッセージを交換できる機能を追加しました。
  プルリクエストでは、カスタムメッセージのいくつかの推奨される使用法が提案されています。
  `lncli`コマンドが更新され、カスタムピアメッセージの送信と受け入れが簡単になりました。

- [LND #5689][]では、LNDノードがすべての秘密鍵の操作を、リモートのほとんどオフラインの署名ノードに委譲する機能が追加されました。
  詳細なドキュメントは[こちら][lnd remote signing]です。

- [BTCPay Server #2517][]では、LN経由でのペイアウトや払い戻しの発行が可能になりました。
  管理者は支払い金額を入力し、受信者は自分のノードの詳細を入力して支払いを受け取ることができます。

- [HWI #497][]は、Trezorファームウェアを使用してデバイスに追加情報を送信し、
  お釣り用のアドレスがマルチシグのフェデレーションに属しているか検証できるようにします。
  それ以外の場合、Trezorはお釣りを個別の支払いとして表示し、ユーザーはお釣り用アドレスが正しいか手動で確認する必要があります。

{% include references.md %}
{% include linkers/issues.md issues="23002,22918,4771,4685,1969,5709,5549,5346,5689,2517,497,891,20160" %}
[rust-lightning 0.0.102]: https://github.com/rust-bitcoin/rust-lightning/releases/tag/v0.0.102
[c-lightning 0.10.2rc1]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.2rc1
[news123 pool]: /en/newsletters/2020/11/11/#incoming-channel-marketplace
[websocket]: https://ja.wikipedia.org/wiki/WebSocket
[prob path]: /ja/newsletters/2021/03/31/#paper-on-probabilistic-path-selection
[news170 unec bug]: /ja/newsletters/2021/10/13/#ln-spend-to-fees-cve-ln-cve
[decker tweet]: https://twitter.com/Snyke/status/1452260691939938312
[wiki difficulty]: https://en.bitcoin.it/wiki/Difficulty
[se coinbase maturity]: https://bitcoin.stackexchange.com/a/1992/87121
[frost whitepaper]: https://eprint.iacr.org/2020/852.pdf
[lnd remote signing]: https://github.com/guggero/lnd/blob/d43854aa34ca0c2d0dfa12b06f299def39b512fb/docs/remote-signing.md
[optech pr16528]: /en/newsletters/2020/05/06/#bitcoin-core-16528
[series preparing for taproot]: /ja/preparing-for-taproot/
