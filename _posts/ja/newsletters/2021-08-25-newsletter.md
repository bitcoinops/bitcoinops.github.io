---
title: 'Bitcoin Optech Newsletter #163'
permalink: /ja/newsletters/2021/08/25/
name: 2021-08-25-newsletter-ja
slug: 2021-08-25-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LNのチャネルの基本手数料（Base fee）をゼロにすることについての議論の要約と、
Bitcoin Stack Exchangeの人気のある質問と回答、Taprootへの準備方法、新しいリリースとリリース候補、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更点などの恒例のセクションを掲載しています。

## ニュース

- **<!--zero-base-fee-ln-discussion-->基本手数料ゼロに関するLNの議論:** LNプロトコルでは、
  支払人は、支払いを最終的な宛先までうまくルーティングしてくれる各ノードに支払う金額を選択できます。
  一方、ルーティングノードは、十分な手数料を提供しない支払いの試みを拒否することができます。
  このような役割分担を実現するために、ルーティングノードは期待する手数料を支払人に伝える必要があります。
  そのため[BOLT7][]では、`fee_base_msat`（基本手数料）と
  `fee_proportional_millionths`（金額に比例する手数料）という2つの手数料関連のパラメータを、
  ルーティングノードが配信する機能を提供しています。

    René PickhardtとStefan Richterによる[最近の論文][pickhardt richter paper]では、
    支払人が手数料と支払い成功するために必要な支払いの試行回数を最小限に抑えるために利用できる
    新しい経路探索手法が提案されています（他の利点もあります）。しかし、現在のネットワークにこの手法を導入すると、
    LNの基本手数料と[マルチパス支払い][topic multipath payments]に関連する2つの問題が発生します:

    - **<!--more-splits-more-fees-->より多くの分割、より多くの手数料:** 1つの経路での支払いと、
      2つの同等の経路での同じ金額の支払いを比較してみてください:
      どちらも比例手数料は同額ですが（全体の支払い額は同じなので）、
      2つの経路での支払いの基本手数料の合計は2倍になります（2倍のホップを使用するため）。
      経路が`x`個の場合、基本手数料は`x`倍になります。
      このため、マルチパス支払いの使用はコスト高になり、提案された手法など、
      マルチパス支払いを使用する手法にはペナルティが課せられます。

     {% comment %}<!-- The explanation in the paper is unintelligible to
     me, so the following description is deliberately bland in order to
     avoid being wrong.  -->{% endcomment %}

     - **<!--computational-difficulties-->計算の難しさ:** 論文の2.3節で述べられているように、
       提案された経路探索アルゴリズムは、基本手数料がある場合、
       経路と支払いの分割を容易に計算できません。
       長期的にはこの問題をアルゴリズムで解決することができるかもしれませんが、
       アルゴリズムの実装者にとって最も簡単な解決策は基本手数料を無くすことでしょう。

    著者は、[ポッドキャスト][honigdachs podcast]や[Twitter][zbf tweet]で、
    ノード運用者が基本手数料をゼロにすれば、LNプロトコルにすぐに変更を加えることなくこの問題に対処できると提案しました。
    さらに、ノード運用者はこれらの研究がまだプロダクションに展開されてないにも関わらず、
    これをすぐに始めることができると提案しました。
    これをきっかけに、Twitter上でLN開発者同士の議論が行われ、
    Anthony TownsがLightning-Devメーリングリストへの[投稿][towns post]と共に議論の移行を支援しました。

    Townsは、ユーザーが基本手数料をゼロにすることに賛成し、マルチパスによる分割の利点と、
    ノード運用者が残り1つの手数料パラメータである比例手数料を最適化することが容易になることを指摘しました。

    Matt Coralloは、支払いをルーティングするための[HTLC][topic htlc]を作成すると、
    支払い金額に関わらず一定の負担がノードにかかるという懸念を[応えました][corallo post]。
    基本手数料を設定することで、ノードはこれらのコストの補償を要求することができます。
    しかしTownsが反論したように、これらのコストはルーティングに成功した場合も失敗した場合も同じであるにも関わらず、
    LNノードには成功した場合にのみ支払われます。ノードが一部のケースで補償なしにこれらのコストを受け入れるのであれば、
    すべてのケースでそれを受け入れないのはなぜでしょうか？ただし、比例手数料についても同じことが言えます。
    そこで、支払いに失敗した場合でもノードに補償を与えることができる[Upfront fee][topic channel jamming attacks]
    についての簡単な議論が行われました。

    Townsはまた、基本手数料がなくても、一定額以下の支払いのルーティングを拒否するだけで、
    ノードが最低限の手数料を受け取れるようにすることも可能だと提案しました。
    例えば、現在基本手数料が1 satのノードは、0.1%の比例手数料と最低金額1,000 satを設定することで、
    最低でもその金額を受け取ることができます。これはマイクロペイメントを阻害することになりますが、
    LNノードはすでにHTLCを使わずに小額の支払いを処理しているため、固定コストの一部がなくなり、
    純粋な比例コストがより適切になるかもしれませんが、これについては議論が残ります。

    議論の後半では、Olaoluwa Osuntokunが、ノード運用者が
    現在プロダクションで使用する準備ができていない新しい経路探索アルゴリズムのパラメーターを変更する明白な必要性はないという先程の指摘を[強調しました][osuntokun post]。
    彼とCoralloは、基本手数料がゼロ以外の場合でも、
    今後の研究開発によりこのアルゴリズム（もしくは異なる原理に基づく同様のアルゴリズム）が、
    ほぼ同等に機能するようになるかどうかを確認したいと考えています。

    この記事の執筆時点では、この議論に明確な結論はでていません。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-does-bitcoin-core-support-a-transaction-index-but-not-an-address-index-->なぜBitcoin Coreはトランザクションインデックスをサポートし、アドレスインデックスをサポートしないのですか？]({{bse}}107619)
  Andrew Chowは、Bitcoin Coreのトランザクションインデックスがトランザクションを検証する上で歴史的に重要であることを説明し
  （[UTXOデータベースによって置き換えられたため][bitcoin core #1677]）、アドレスインデックス機能をBitcoin Coreに追加することについて、
  メンテナンスのオーバーヘッド、説得力あるユースケースの欠如および、
  そのようなインデックスはBitcoin Coreのプロジェクトのスコープ外であるという懸念などの反対意見を説明しています。

- [<!--is-the-mempool-p2p-message-reliable-->`mempool` P2Pメッセージは信頼できますか？]({{bse}}108229)
  ClarisとPieter Wuilleが、[`mempool`][mempool message] P2Pメッセージの歴史を説明しています。
  ノードのmempoolの内容をSPVピアに公開するために[BIP35][]で導入された後、
  メッセージは、現在[デフォルトで無効になっている][news74 bip37 default]
  [BIP37][]の[Bloom Filter][topic transaction bloom filtering]でアクセスできるように移行されました。
  `mempool`リクエストのサポートは、`-whitelist=mempool`および`-whitebind=mempool`設定オプションを使って、
  個々のピアに対して設定できます。

- [<!--what-is-sighash-anyprevoutanyscript-->SIGHASH_ANYPREVOUTANYSCRIPTとは何ですか？]({{bse}}107797)
  Michael Folksonが、[BIP118][]が提案する[Signature Hash (sighash)][wiki sighash]のChristian Deckerの比較を要約しています。
  `SIGHASH_ANYPREVOUT` sighashは、`scriptPubKey`にはコミットしますが、
  特定のUTXOへのコミットをやめます。`SIGHASH_ANYPREVOUTANYSCRIPT` sighashは、
  インプットの量と特定`scriptPubKey`へのコミットを取りやめます。
  後者は[eltoo][topic eltoo]をサポートするために必要です。

- [<!--will-ln-liquidity-advertisements-and-dual-funding-allow-for-third-party-purchased-liquidity-sidecar-channels-->LNの流動性の配信とデュアル・ファンディングは、第三者による流動性の購入（Sidecar Channel）を可能にしますか？]({{bse}}107786)
  David A. Hardingは、現在はサポートされていませんが、第三者が[流動性の配信][topic liquidity advertisements]と
  [デュアル・ファンディング][topic Dual funding]を利用して流動性を購入するのは可能だと述べています。
  彼は、オンチェーンPSBTワークフローとオフチェーンワークフローに関するLisa Neigutのアイディアを要約しています。

- [<!--are-there-risks-to-using-the-same-private-key-for-both-ecdsa-and-schnorr-signatures-->ECDSAとSchnorr署名の両方に同じ秘密鍵を使用することにリスクはありますか？]({{bse}}107924)
  Pieter Wuilleは、[Schnorr][topic schnorr signatures]とECDSA間で既知の鍵の再利用攻撃はありませんが、
  「証明可能な安全性の範囲内にとどまるためには、ECDSAの鍵とSchnorrの鍵は別々の強化導出手順を使用するのが望ましい」
  と述べています。

## Taprootの準備 #10: PTLC

*ブロック高{{site.trb}}のTaprootのアクティベーションに向けて、
開発者やサービスプロバイダーがどのような準備をすればよいかについての週刊[シリーズ][series preparing for taproot]です。*

{% include specials/taproot/ja/09-ptlcs.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Rust-Lightning 0.0.100][]は、[keysend支払い][topic spontaneous payments]の送受信をサポートした新しいリリースで、
  成功したルーティング支払いの追跡と、ノードがそこから得た手数料収入の記録が容易になりました。

- [Bitcoin Core 22.0rc2][bitcoin core 22.0]は、
  このフルノード実装とそれに付随するウォレットおよび他のソフトウェアの次のメジャーバージョンのリリース候補です。
  この新バージョンの主な変更点は、[I2P][topic anonymity networks]接続のサポート、
  [Tor v2][topic anonymity networks]接続の廃止、ハードウェアウォレットのサポートの強化などです。

- [Bitcoin Core 0.21.2rc1][bitcoin core 0.21.2]は、
  Bitcoin Coreのメンテナンス版のリリース候補です。
  いくつかのバグ修正と小さな改善が含まれています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #22541][]では、ウォレットバックアップをロードするために使用できる
  新しい`restorewallet` RPCコマンドが追加されました。`restorewallet`は、
  現在ロードされているウォレットのコピーをエクスポートする既存の`backupwallet`コマンドを補完します。
  `backupwallet`と`restorewallet`は、
  別のファイルを使用する古い`dumpwallet`と`importwallet` RPCの代替となることに注意してください。
  この作業は、[Bitcoin Core #22523][]のウォレットのバックアップおよび復元のためドキュメントの包括的な更新を伴っています。

- [LND #5442][]では、新しいアウトプットを追加することなく[PSBT][topic psbt]にインプットを追加するこができるようになり、
  これは[CPFPによる手数料の引き上げ][topic cpfp]を作成するのに便利です。

- [Rust-Lightning #1011][]は、まだマージされていない[BOLTs #847][]のサポートを追加しました。
  これにより、2つのチャネルピアが協調クローズトランザクションで支払うべき手数料を調整することができます。
  現在のプロトコルでは、１つの手数料のみが送られ、相手はその手数料を受け入れるか拒否しなければなりません。

- [BOLTs #887][]では、[BOLT11][]を更新し、受信者の`payment_secret` feature bitに関係なく、
  送信者が支払いの際に[payment secret][topic payment secrets]を指定することを要求します。
  簡略化されたマルチパス支払いにおけるプロービング攻撃を防ぐために、payment secretを検証する必要があります。
  この検証は、これまで取り上げた4つのLN実装すべてで以前から実装されています。

{% include references.md %}
{% include linkers/issues.md issues="22541,5442,1011,847,887,22523,1677" %}
[bitcoin core 22.0]: https://bitcoincore.org/bin/bitcoin-core-22.0/
[bitcoin core 0.21.2]: https://bitcoincore.org/bin/bitcoin-core-0.21.2/
[rust-lightning 0.0.100]: https://github.com/rust-bitcoin/rust-lightning/releases/tag/v0.0.100
[pickhardt richter paper]: https://arxiv.org/abs/2107.05322
[towns post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-August/003174.html
[corallo post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-August/003179.html
[osuntokun post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-August/003187.html
[honigdachs podcast]: https://coinspondent.de/2021/07/11/honigdachs-62-pickhardt-payments/
[zbf tweet]: https://twitter.com/renepickhardt/status/1414895869078523910
[mempool message]: https://developer.bitcoin.org/reference/p2p_networking.html#mempool
[news74 bip37 default]: /ja/newsletters/2019/11/27/#deprecated-or-removed-features
[wiki sighash]: https://en.bitcoin.it/wiki/Contract#SIGHASH_flags
[series preparing for taproot]: /ja/preparing-for-taproot/
