---
title: 'Bitcoin Optech Newsletter #313'
permalink: /ja/newsletters/2024/07/26/
name: 2024-07-26-newsletter-ja
slug: 2024-07-26-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin Coreのフリーリレーと手数料の引き上げ方法のアップグレードに関する幅広い議論を掲載しています。
また、Bitcoin Stack Exchangeで人気のある質問とその回答の共有や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更など恒例のセクションも含まれています。

## ニュース

- **<!--varied-discussion-of-free-relay-and-fee-bumping-upgrades-->フリーリレーと手数料の引き上げ方法に関するさまざまな議論:**
  Peter Toddは、以前Bitcoin Core開発者に[責任を持って開示した][topic responsible disclosures]フリーリレー攻撃の概要を
  Bitcoin-Devメーリングリストに[投稿しました][todd fr-rbf]。これにより、複数の課題と提案が絡み合った議論が行われました。
  議論されたトピックには以下のようなものがります:

  - *<!--free-relay-attacks-->フリーリレー攻撃:*
    [フリーリレー][topic free relay]は、フルノードが
    mempoolの手数料収入が最小リレーレート（デフォルトで1 sat/vbyte）以上増加することなく、
    未承認のトランザクションをリレーする場合に発生します。
    フリーリレーには、ある程度のコストがかかることが多いため、技術的には無料ではありませんが、
    そのコストは正直なユーザーがリレーに支払うコストをはるかに下回ります。

    フリーリレーにより、攻撃者はリレーするフルノードが使用する帯域幅を大幅に増やすことができ、
    リレーノードの数を減らすことができます。独立して運用されるリレーノードの数が少なくなりすぎると、
    支払人は基本的にトランザクションをマイナーに直接送信していることになり、
    [帯域外の手数料][topic out-of-band fees]と同じ集中化のリスクが発生します。

    Toddの説明した攻撃は、マイナーとユーザー間のmempoolポリシーの違いを悪用します。
    多くのマイナーは、[フルRBF][topic rbf]を有効にしているようですが、
    Bitcoin Coreはこれをデフォルトでは有効にしていません（[ニュースレター #263][news263 full-rbf]参照）。
    これにより攻撃者は、フルRBFマイナーと非フルRBFリレーノードで異なる扱いを受ける
    異なるバージョンのトランザクションを作成することができます。
    リレーノードは、承認される可能性の低い複数のバージョンのトランザクションをリレーすることになり、
    リレーノードの帯域幅を浪費することになります。

    フリーリレー攻撃は、攻撃者が他のユーザーの資金を直接盗めるようにするものではありませんが、
    突然または長期にわたる攻撃はネットワークを混乱させ、他のタイプの攻撃を容易にするために使用される可能性があります。
    私たちの知る限り、これまで混乱を引き起こすフリーリレー攻撃は行われていません。

  - *フリーリレーとReplace-by-Feerate:* Peter Toddは以前、
    2つの形式のRBFR（Replace-by-Feerate）を提案しています（[ニュースレター #288][news288 rbfr]参照）。
    RBFRに対する批判の1つは、フリーリレーを可能にするというものでした。
    同程度のフリーリレーは、彼が今週説明した攻撃や類似の攻撃によって既に可能になっているため、
    フリーリレーに関する懸念が、[トランザクションのPinning攻撃][topic transaction pinning]を緩和するために有用な機能の追加を
    妨げるべきではないと彼は主張しました。

    少なくとも1つの[返信][harding rbfr fundamental]では、
    RBFRによって作られるフリーリレーはその設計の基本だが、Bitcoin Coreの設計における他のフリーリレーの問題は、
    解決できる可能性があると主張しました。Toddはこれに[同意しませんでした][todd unsolvable]。

  - *TRUCの有用性:* Peter Toddは、[TRUC][topic v3 transaction relay]は「悪い提案」であると主張しました。
    彼は以前このプロトコルを批判しており（[ニュースレター #283][news283 truc pin]参照）、
    特にTRUCの仕様である[BIP431][]を批判しています。[BIP431][]は、フリーリレーに関する懸念を利用して、
    彼のRBFRの提案よりもTRUCを推奨しています。

    BIP431はまた、ToddのワンショットRBFRのような、（mempoolの最上部に入ると説明されている）
    次の数ブロックでマイニングする最も収益の高いトランザクションになるのに十分な手数料率を支払うことに依存する
    RBFRのバージョンにも反対しています。Bitcoin Coreが[クラスター mempool][topic cluster mempool]を使用し始めれば、
    これはより簡単になるだろうという点は、Toddも他のメンバーも同意していますが、Toddは現在利用可能な代替案も提案しました。
    TRUCは、mempoolの最上部に関する情報を必要としないため、クラスターmempoolや代替方法に依存しません。

    この批判は、[ニュースレター #288][news288 rbfr]で要約され、その後の研究（[ニュースレター #290][news290 rbf]で要約）により、
    どのようなトランザクション置換ルールセットでも、マイナーの収益性を向上させる選択を常に行うことがいかに難しいかが示されています。
    RBFRと比較して、TRUCは（TRUCトランザクションに対して常に置換を許可することを除いて）Bitcoin Coreの置換ルールを変更しないため、
    置換のインセンティブ互換性に関する既存の問題が悪化することはありません。

  - *クラスターmempoolへの道:* [ニュースレター #285][news285 cluster cpfp-co]に掲載されているように、
    [クラスターmempool][topic cluster mempool]の提案では、現在LNの[アンカーアウトプット][topic
    anchor outputs]でペイメントチャネルの多額の資金を保護するために使用されている
    [CPFP carve-out][topic cpfp carve out]（CPFP-CO）を無効にする必要があります。
    [パッケージリレー][topic package relay]（具体的にはパッケージRBF）と組み合わせると、ワンショットRBFRは、
    既にアンカーアウトプットを使用したRBFによる手数料の引き上げを繰り返しているLNソフトウェアを変更することなく、
    CPFP-COを置き換えることができる可能性があります。ただし、ワンショットRBFRは、
    クラスターmempoolなどからmempoolの上位の手数料率を知ることに依存しているため、
    RBFRとクラスターmempoolを同時に展開するか、mempoolの上位の手数料率を決定する別の方法を使用する必要があります。

    比較すると、TRUCはCPFP-COの代替手段を提供しますが、これはオプトイン機能です。
    TRUCをサポートするためにすべてのLNソフトウェアをアップグレードする必要があり、
    既存のすべてのチャネルで[チャネルコミットメントのアップグレード][topic channel commitment upgrades]を行う必要があります。
    これは、かなりの時間がかかる可能性があり、すべてのLNユーザーがアップグレードしたという強力な証拠が得られるまで、
    CPFP-COを無効にすることはできません。CPFP-COが無効になるまで、クラスターmempoolを安全に広く展開することはできません。

    以前のOptechニュースレター[#286][news286 imbued]と[#287][news287 sibling]、[#289][news289 imbued]で言及したように、
    TRUCの採用が遅く、クラスターmempoolがすぐに利用できないことは、
    アンカースタイルのLNのコミットメントトランザクションにTRUCと[兄弟の排除][topic kindred rbf]を自動的に適用する
    _Imbued TRUC_ によって対処することができます。LN開発者やImbued TRUC提案のコントリビューターの中には、
    そのような結果は[避けたい][daftuar prefer not]と[述べる][teinurier hacky]人もいました。
    TRUCへの明示的なアップグレードの方が多くの点で優れており、
    LN開発者がチャネルアップグレードの仕組みに取り組む理由は他にも複数ありますが、
    クラスターmempoolの開発がLNのコミットメントアップグレードの開発を上回った場合、
    Imbued TRUCが再び検討される可能性は十分あります。

    Imbued TRUCとオプトインTRUCの幅広い採用により、CPFP-COを無効にしてクラスターmempoolを展開することが可能になりますが、
    どちらのTRUCシステムもクラスターmempoolやトランザクションのインセンティブ互換性を計算するその他の新しい方法に依存していません。
    そのため、クラスターmempoolとは関係なくTRUCを分析する方が、RBFRを分析するよりも簡単です。

  この記事の執筆時点では、メーリングリストで議論が続いています。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [クラスターmempoolではどうしてmempoolの再構築が必要なのですか？]({{bse}}123682)
  Murchは、Bitcoin Coreの現在のmempoolのデータ構造の問題点と、
  クラスターmempoolがそれらの問題にどのように対処するのか、そして
  [クラスターmempool][topic cluster mempool]がBitcoin Coreにどのように導入されるかについて説明しています。

- [Bitcoin CoreのDEFAULT_MAX_PEER_CONNECTIONSは125ですか？または130ですか？]({{bse}}123645)
  Lightlikeは、Bitcoin Coreの自動ピア接続の最大数は125だが、
  ノードオペレーターは最大8つの接続を手動で追加できることを明確にしています。

- [<!--why-do-protocol-developers-work-on-maximizing-miner-revenue-->なぜプロトコル開発者はマイナーの収益の最大化に取り組むのですか？]({{bse}}123679)
  David A. Hardingは、マイナーが手数料収益を最大化するという仮定を使用して、
  どのトランザクションがブロックに入るのかを予測できることの利点をいくつか挙げ、
  「これにより、支払人は合理的な手数料率を推定でき、ボランティアのリレーノードは適度な帯域幅とメモリで動作し、
  小規模な分散型マイナーは大規模なマイナーと同じだけの手数料収益を得ることができます。」と述べています。

- [P2TRではなくP2WSHを使用する経済的なインセンティブはありますか？]({{bse}}123500)
  Vojtěch Strnadは、P2WSHの特定の用途はP2TRよりも安価になる可能性があるものの、
  マルチシグやLNなどのほとんどのP2WSHのユースケースでは、未使用のスクリプトパスを[Taproot][topic taproot]に隠し、
  [MuSig2][topic musig]やFROSTなどの[Schnorr署名][topic schnorr signatures]の鍵集約スキームを使用することで可能になる
  手数料削減の恩恵を受けるだろうと指摘しています。

- [<!--how-many-blocks-per-second-can-sustainably-be-created-using-a-time-warp-attack-->タイムワープ攻撃を使用して、１秒間にどれだけのブロックを持続的に作成できますか？]({{bse}}123698)
  Murchは、[タイムワープ攻撃][topic time warp]の文脈では、
  「攻撃者は難易度を上げずに1秒あたり6ブロックのリズムを維持できるだろう」と計算しました。

- [tr()にネストされたpkh()は許可されていますか？]({{bse}}123568)
  Pieter Wuilleは、[BIP386][]「tr() Output Script Descriptors」によると、
  `tr()`内にネストされたpkh()は有効なディスクリプターではないが、
  [BIP379][]「Miniscript」ではその構成は許可されており、どの特定のBIPに準拠するかは
  アプリケーション開発者が決定する必要があると指摘しています。

- [<!--can-a-block-more-than-a-week-old-be-considered-a-valid-chain-tip-->１週間以上前のブロックは有効なチェーンの先頭とみなされますか？]({{bse}}123671)
  Murchは、そのようなチェーンの先頭は有効とみなされるものの、
  チェーンの先頭がノードのローカル時間から24時間以上経過しているため、
  ノードは「initialblockdownload」状態のままであると結論づけています。

- [SIGHASH_ANYONECANPAYを介してTxの変更]({{bse}}123429)
  Murchは、オンチェーンのクラウドファンディングで`SIGHASH_ALL | SIGHASH_ANYONECANPAY`を使用する際の課題と、
  [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]がどう役立つかを説明しています。

- [なぜRBFルール#3は存在するのか？]({{bse}}123595)
  Antoine Poinsotは、[RBF][topic rbf]ルール#4（置換トランザクションは、
  元のトランザクションの絶対手数料を超える追加手数料を支払う）が
  ルール#3（置換トランザクションは元のトランザクションで支払われた合計額以上の絶対手数料を支払う）よりも強力であることを確認し、
  ドキュメントにある２つの類似したルールの理由は、コード内の２つの別々のチェックに由来すると指摘しています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BDK 1.0.0-beta.1][]は、「安定した1.0.0 APIを備えた`bdk_wallet`の最初のベータ版」のリリース候補です。

## 注目すべきコードとドキュメントの変更

_今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #30320][]は、[assumeUTXO][topic assumeutxo]の動作を更新し、
  現在のベストヘッダー`m_best_header`の祖先でない場合は、スナップショットをロードしないようにし、
  代わりに通常のノードとして同期します。スナップショットが後でチェーンの再編成によりベストヘッダーの祖先になった場合は、
  assumeUTXOスナップショットのロードが再開されます。

- [Bitcoin Core #29523][]は、トランザクションファンディングRPCコマンド`fundrawtransaction`、
  `walletcreatefundedpsbt`および`send`に`max_tx_weight`オプションを追加しました。
  これにより、結果として得られるトランザクションのweightが指定された制限を超えないことが保証され、
  将来の[RBF][topic rbf]の試行や特定のトランザクションプロトコルに役立ちます。
  オプションがセットされていない場合は、400,000 weight unit（100,000 vbyte）の
  `MAX_STANDARD_TX_WEIGHT`がデフォルトで使用されます。

- [Core Lightning #7461][]では、ノードが[BOLT12オファー][topic offers]とインボイスを
  自己取得および自己支払いするためのサポートが追加されました。
  これにより、[ニュースレター #262][cln self-pay]で説明されているように、
  バックグランドでCLNを呼び出すアカウント管理コードが簡素化される可能性があります。
  このPRはまた、ノード自体が[ブラインドパス][topic rv routing]の先頭であっても、
  ノードがインボイスに支払うことを許可します。
  さらに（[非公表チャネル][topic unannounced channels]を持たない）非公表ノードは、
  最後から２つめのホップがチャネルピアの１つであるブラインドパスを自動的に追加することで、
  オファーを作成できるようになります。

- [Eclair #2881][]では、新しい着信`static_remote_key`チャネルのサポートが削除されましたが、
  既存のチャネルとこのオプションを使用する発信チャネルのサポートは維持されます。
  ノードは着信`static_remote_key`の新しいチャネルが廃止されたとみなされるため、
  代わりに[アンカーアウトプット][topic anchor outputs]を使用する必要があります。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30320,29523,7461,2881" %}
[BDK 1.0.0-beta.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.1
[news263 full-rbf]: /ja/newsletters/2023/08/09/#rbf
[news283 truc pin]: /ja/newsletters/2024/01/03/#v3-pinning
[news288 rbfr]: /ja/newsletters/2024/02/07/#pinning
[news290 rbf]: /ja/newsletters/2024/02/21/#pure-replace-by-feerate-doesn-t-guarantee-incentive-compatibility
[news285 cluster cpfp-co]: /ja/newsletters/2024/01/17/#cpfp-carve-out
[news286 imbued]: /ja/newsletters/2024/01/24/#v3
[news287 sibling]: /ja/newsletters/2024/01/31/#kindred-replace-by-fee
[news289 imbued]: /ja/newsletters/2024/02/14/#what-would-have-happened-if-v3-semantics-had-been-applied-to-anchor-outputs-a-year-ago-1-v3
[todd fr-rbf]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Zpk7EYgmlgPP3Y9D@petertodd.org/
[harding rbfr fundamental]: https://mailing-list.bitcoindevs.xyz/bitcoindev/d57a02a84e756dbda03161c9034b9231@dtrt.org/
[todd unsolvable]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Zp1utYduhnWf4oA4@petertodd.org/
[teinurier hacky]: https://github.com/bitcoin/bitcoin/issues/29319#issuecomment-1968709925
[daftuar prefer not]: https://github.com/bitcoin/bitcoin/issues/29319#issuecomment-1968709925
[cln self-pay]: /ja/newsletters/2023/08/02/#core-lightning-6399
[BIP379]: https://github.com/bitcoin/bips/blob/master/bip-0379.md