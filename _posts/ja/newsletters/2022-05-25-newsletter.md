---
title: 'Bitcoin Optech Newsletter #201'
permalink: /ja/newsletters/2022/05/25/
name: 2022-05-25-newsletter-ja
slug: 2022-05-25-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、パッケージリレーのためのBIPドラフトの要約と、
BitcoinのCovenantの設計におけるMiner Extractable Value（MEV）に関する懸念の概要を掲載しています。
また、Bitcoin Stack Exchangeのトップの質問とその回答、
新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **<!--package-relay-proposal-->パッケージリレーの提案:** Gloria Zhaoは、
  Bitcoin-Devメーリングリスに[パッケージリレー][topic package relay]のためのBIPドラフトを[投稿しました][zhao package]。
  これは、子トランザクションが親トランザクションを承認するための手数料の貢献を確実にするために、
  [CPFPによる手数料の引き上げ][topic cpfp]の信頼性を大幅に高めることができる機能です。
  LNを含む、いくつかのコントラクトプロトコルは、既に信頼性の高いCPFPによる手数料の引き上げを必要としており、
  パッケージリレーはそのセキュリティとユーザービリティを向上させるでしょう。
  BIPのドラフトは、BitcoinのP2Pプロトコルに4つの新しいメッセージの追加を提案しています:

- `sendpackages`は、2つのピアがサポートするパッケージの受け入れ機能についてのネゴシエートを可能にします。

- `getpckgtxns`は、パッケージの一部として以前に通知されたトランザクションを要求します。

- `pckgtxns`は、パッケージの一部であるトランザクションを提供します。

- `pckginfo1`は、トランザクション数、各トランザクションの識別子（wtxid）、トランザクションの合計サイズ（weight）、
  トランザクションの総手数料を含む、トランザクションのパッケージに関する情報を提供します。
  パッケージの手数料率は、手数料をweightで割ることで計算できます。

  さらに、既存の`inv`および`getdata`メッセージは、新しいinventory（inv）タイプ`MSG_PCKG1`で更新され、
  ノードはトランザクションに関する`pckginfo1`メッセージを送信する意思があること、
  およびそのピアが特定のトランザクションのために`pckginfo1`メッセージを要求するのに使用できるようにします。

  これらのメッセージを使用すると、ノードは`inv(MSG_PCKG1)`メッセージを使用して、
  あるトランザクションについて`pckginfo1`の受信に関心があることをそのピアに伝えることができます。
  例えば、ピアが他の方法では無視するかもしれない低手数料率の未承認の親トランザクションでも高手数料率の子トランザクションがある場合などです。
  どのピアも`pckginfo1`メッセージを要求した場合、そのメッセージの情報を使用して、
  本当にそのパッケージに興味があるかどうかを判断し、
  高手数料率の子を検証するのにダウンロードする必要のある全てのトランザクションのwtxidを知ることができます。
  実際のトランザクションは、`getpckgtxns`メッセージを使って要求し、
  `pckgtxins`メッセージで受信することができます。

  [BIPのドラフト][bip-package-relay]は、プロトコルにのみフォーカスしていますが、
  Zhaoのメールは追加のコンテキストを提供し、欠陥が見つかった代替設計を簡単に説明し、
  追加の詳細を含む[プレゼンテーション][zhao preso]のリンクを掲載しています。

- **Miner Extractable Valueの議論:** 開発者の/dev/fd0は、
  Bitcoin-Devメーリングリストに[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV)に関する
  [9回めのIRCメーティング][ctv9]の概要を[投稿しました][fd0 ctv9]。
  ミーティングで議論された他のトピックの中で、
  Jeremy Rubinは（CTVでは無効な）再帰的な[Covenant][topic covenants]に関して彼が聞いたいくつかの懸念を挙げました。
  それらの懸念の1つは、Bitcoin Coreが提供するような単純なトランザクション選択アルゴリズムの実行から得られる量を大幅に超える
  Miner Extractable Value (MEV)を作り出すことでした。

  MEVは、パブリックなオンチェーン取引プロトコルの使用により、
  マイナーが取引を先行させることができるEthereumおよび関連プロトコルにおいて、特に懸念されるようになりました。
  例えば、次の2つの未承認トランザクションの両方が次のブロックでマイニング可能であることを想像してみてください:

  * アリスはアセット*x*をボブに1 ETHで売却する
  * ボブは*x*をキャロルに2 ETHで売却する（ボブは1 ETHの利益を得る）

  <br>この2つの交換が、パブリックなオンチェーン取引プロトコルで行われる場合、
  マイナーはボブを取引から切り離すことができます。例えば:

  * アリスはアセット*x*をマイナーのマロリーに1 ETHで売却する
  * マイナーのマロリーは*x*をキャロルに2 ETHで売却する（マロリーは1 ETHの利益を得て、ボブは何も得られない）

  <br>これは明らかにボブにとって問題ですが、ネットワークにもいくつかの問題を引き起こします。
  最初の問題は、マイナーがMEVの機会を見つける必要があることです。上記の単純な例では些細なことですが、
  より複雑な機会は計算量の多いアルゴリズムによってのみ見つけることができます。
  特定の計算量で見つけられる値の量は、各マイナーのハッシュレートとは無関係であるため、
  2人のマイナーが協力すればMEVの獲得に必要な計算量を半分にすることができます。
  これは、マイニングの集中化を促す規模の経済を生み出し、ネットワークがトランザクションの検閲に対してより脆弱になる可能性があります。
  BitMex Researchの[レポート][bitmex flashbots]によると、
  この種のMEVトランザクションを仲介する集中型のサービスは、
  レポートが書かれた時点でEthereumのハッシュレートの90%で使用されていたようです。
  最大のリターンを得るために、そのサービスは競合するトランザクションのマイニングを抑制するよう変更することができ、
  マイナーの100%が使用した場合（または50%以上のマイナーによって使用され、ブロックチェーンの再編成がされた場合）、
  事実上トランザクションを検閲する権限を与えることができます。

  2つめの問題は、マロリーが1 ETHのMEVを獲得するブロックを生成したとしても、
  他のマイナーが自分がMEVを獲得するために代替ブロックを生成できることです。
  このようなブロックの再マイニングの圧力は、[フィー・スナイピング][topic fee sniping]の圧力を悪化させ、
  最悪の場合、トランザクションのファイナリティを決定するための承認スコアが役に立たなくなり、
  ネットワークを保護するためにProof of Workを使用する能力が失われる可能性があります。

  Bitcoinは、Ethereumのようなアカウント型ではなく、UTXOを使用しているため、
  MEVに対して特に脆弱なタイプのプロトコルを実装するのは難しくなっています。
  しかし、CTVのミーティングでJeremy Rubinは、
  再帰的なCovenantによりBitcoinのUTXO上にアカウントベースのシステムを実装することが容易になるため、
  MEVがBitcoinのプロトコル設計にとって重要な将来の懸念事項になる可能性が高くなると指摘しています。

  メーリングリストの/dev/fd0の要約に返信した開発者のZmnSCPxjは、
  最大のオンチェーンプライバシーのために設計されたプロトコルを奨励する仕組みのみを採用することを提案しました。
  そのプライバシーは、マイナーがMEVを行うために必要な情報を否定することになります。
  このニュースレターを書いている時点では、メーリングリストにそれ以上のコメントは寄せられていませんが、
  Twitterやその他の場所での言及から、
  開発者がBitcoinのプロトコル設計におけるMEVの影響をますます考慮するようになっている証拠が見受けられます。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--how-much-entropy-is-lost-alphabetising-your-mnemonics-->ニーモニックをアルファベット順に並べると、どのくらいのエントロピーが失われますか？]({{bse}}113432)
  HansBKKは、12個または24個の単語からなるシードフレーズをアルファベット順に並べた場合、どれだけのエントロピーが失われるか疑問に思っています。
  Pieter Wuilleは、可能性の数、エントロピー、12個と24個のブルート・フォースの平均推測数などの一連の指標を分析し、
  単語の繰り返しについての考察も述べています。

- [<!--taproot-signing-with-psbt-how-to-determine-signing-method-->PSBTによるTaprootの署名: 署名方法をどうやって決定しますか？]({{bse}}113489)
  Guggeroは、Taprootで有効な[Schnorr署名][topic schnorr signatures]を提供する方法として、
  [BIP86][]のコミットメントを伴うkeypathの使用、Scriptツリーのルートへのコミットメントを伴うkeypathの使用、
  scriptpathの使用の3つを挙げています。Andrew Chowは、
  各署名方法が[PSBT][topic psbt]内でどのように示されるかというGuggeroのアウトラインを確認しています。

- [<!--how-would-faster-blocks-cause-mining-centralization-->ブロックの高速化はどのようにマイニングの集中化を引き起こしますか？]({{bse}}113505)
  Murchは、ブロック間隔が短くなると再編成がより頻繁に行われるようになる理由と、
  ブロック伝播の遅延の観点からそれが大規模なマイナーにどのような利益をもたらすかにフォーカスしています。

- [<!--what-does-waste-metric-mean-in-the-context-of-coin-selection-->コイン選択における"waste metric"とはどういう意味ですか？]({{bse}}113622)
  Murchは、コインを使用する際、Bitcoin Coreは「仮想的な長期の手数料率で同じインプットを使用した場合と比較して、
  現在の手数料率でのインプットのセットについて手数料を測定する」ものとして[waste metric][news165 waste]ヒューリスティックを使用すると説明しています。
  このヒューリスティックは、Branch and Bound (BnB)、Single Random Draw (SRD)およびナップザックアルゴリズムから得られる
  [コイン選択][topic coin selection]候補を評価するために使用されています。

- [<!--why-isn-t-op-checkmultisig-compatible-with-batch-verification-of-schnorr-signatures-->なぜ`OP_CHECKMULTISIG`はSchnorr署名のバッチ検証と互換性がないのですか？]({{bse}}113816)
  Pieter Wuilleは、[`OP_CHECKMULTISIG`][wiki op_checkmultisig]は、どの署名がどの公開鍵に対応しているかを示さないため
  バッチ検証と互換性がなく、BIP342の新しい`OP_CHECKSIGADD` opcode導入の[動機][bip342 fn4]となったことを指摘しています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning 0.11.1][]は、一方的なチャネルクローズトランザクションが不必要にブロードキャストされる問題および、
  C-Lightningノードのクラッシュを引き起こす別の問題を解消するバグ修正リリースです。

- [LND 0.15.0-beta.rc3][]は、この人気のあるLNノードの次のメジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #20799][]は、segwitをサポートしていないピアにブロックとトランザクションをより速く、
  より帯域幅効率の良い方法でリレーするバージョン1の[Compact Blockリレー][topic compact block relay]のサポートを削除しました。
  バージョン2は引き続き有効で、segwitをサポートするピアへの高速で効率的なリレーを可能にします。

- [LND #6529][]は、`constrainmacaroon`コマンドを追加し、
  既に作成されたmacaroon（認証トークン）の権限を制限できるようにしました。
  これまでは、権限の変更には新しいmacaroonの作成が必要でした。

- [LND #6524][]は、LNDのaezeedのバックアップスキームのバージョン番号を0から1に上げました。
  これは、aezeedのバックアップから資金をリカバリする将来のソフトウェアに、
  ウォレットに受信した[Taproot][topic taproot]のアウトプットをスキャンするように指示します。

## 特別な感謝

通常のニュースレターの寄稿者に加えて、特に今週はMEVに関する追加情報を提供してくれたJeremy Rubinに感謝します。
誤りや抜けがあった場合は、我々が単独で責任を負います。

{% include references.md %}
{% include linkers/issues.md v=2 issues="20799,6529,6524" %}
[lnd 0.15.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta.rc3
[Core Lightning 0.11.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.11.1
[zhao package]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020493.html
[bip-package-relay]: https://github.com/bitcoin/bips/pull/1324
[zhao preso]: https://docs.google.com/presentation/d/1B__KlZO1VzxJGx-0DYChlWawaEmGJ9EGApEzrHqZpQc/edit#slide=id.p
[fd0 ctv9]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020501.html
[ctv9]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020501.html
[bitmex flashbots]: https://blog.bitmex.com/flashbots/
[news165 waste]: /ja/newsletters/2021/09/08/#bitcoin-core-22009
[wiki op_checkmultisig]: https://en.bitcoin.it/wiki/OP_CHECKMULTISIG
[bip342 fn4]: https://github.com/bitcoin/bips/blob/master/bip-0342.mediawiki#cite_note-4
