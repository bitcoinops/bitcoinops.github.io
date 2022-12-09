---
title: 'Bitcoin Optech Newsletter #229'
permalink: /ja/newsletters/2022/12/07/
name: 2022-12-07-newsletter-ja
slug: 2022-12-07-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、エフェメラル・アンカーの実装に加えて、Bitcoin Core PR Review Clubミーティングの概要や、
新しいリリースおよびリリース候補の発表、人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **<!--ephemeral-anchors-implementation-->エフェメラル・アンカーの実装:** Greg Sandersは、
  エフェメラル・アンカー（[ニュースレター #223][news223 anchors]参照）に関する彼のアイディアを実装したことを
  Bitcoin-Devメーリングリストに[投稿しました][sanders ephemeral]。
  [アンカー・アウトプット][topic anchor outputs]は、Bitcoin Coreの[CPFP carve outs][topic cpfp carve out]によって利用可能になった
  既存の技術で、LNのコントラクトに参加する両参加者が[CPFP][topic cpfp]によりそのコントラクトに関連する
  トランザクションの手数料を引き上げられることを保証するためにLNプロトコルで使用されています。
  アンカー・アウトプットにはいくつか欠点があります。根本的なものもあれば（[ニュースレター #224][news224 anchors]参照）、
  対処可能なものもあります。

    エフェメラル・アンカーは、[v3トランザクションリレーの提案][topic v3 transaction relay]に基づいており、
    v3トランザクションは`OP_TRUE`スクリプトへのゼロ値の支払いのアウトプットを含めることができます。
    これにより、ネットワーク上の誰でも使用可能なUTXOを持っていれば、CPFPでそのトランザクションの手数料を引き上げることができます。
    手数料を引き上げる子トランザクションは、それ自体が他の使用可能なUTXOによってRBFによる手数料の引き上げが可能です。
    v3トランザクションの他のリレーポリシーと組み合わせることで、時間的な制約のあるコントラクトプロトコルのトランザクションに対する
    [トランザクションPinning攻撃][topic transaction pinning]に関してポリシーベースの懸念が解消されることが期待されます。

    さらに、誰でもエフェメラル・アウトプットを含むトランザクションの手数料を引き上げられるため、
    2人以上が参加するコントラクトプロトコルで利用可能です。
    既存のBitcoin Coreのcarve outルールは、参加者が2人の場合のみ機能し、
    これを増やすための[これまでの試み][bitcoin core #18725]では参加者の任意の上限を必要としました。

    Sandersのエフェメラル・アンカーの[実装][bitcoin core #26403]により、
    提案者によって以前実装された他のv3トランザクションリレー動作と共に、このアイディアのテストができるようになりました。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Bump unconfirmed ancestor transactions to target feerate][review club 26152]は、
Xekyo (Murch)とglozowによるPRで、未承認のUTXOをインプットとして選択した場合のウォレットの手数料計算の精度を向上させるものです。
このPRがない場合、インプットとして使用されるいくつかの未承認トランザクションの手数料率が、
構築されるトランザクションの手数料率より低い場合、低すぎる手数料が設定されてしまいます。
このPRでは、このような低手数料のソーストランザクションを
新しいトランザクションのターゲットと同じ手数料率に「促進させる」ために十分な手数料を追加することでこの問題を解決します。

このPRがなくても、コイン選択プロセスは、低手数料率の未承認トランザクションの使用を避けようとする点にご注意ください。
このPRは、これ(低すぎる手数料が設定されてしまう問題)を避けることができない場合に有用です。

こうした先祖のトランザクションを考慮して手数料を調整することは、ブロックに含めるトランザクションを選択することと似ていることが判明したため、
このPRでは`MiniMiner`というクラスを追加しています。

このPRは、[2週間][review club 26152-2]に[わたって][review club 26152]レビューされました。

{% include functions/details-list.md
  q0="<!--what-problem-does-this-pr-address-->このPRはどんな問題を解決しますか？"
  a0="ウォレットの手数料の試算では、ターゲットより低い手数料率を持つすべての未承認の先祖に対して必要な手数料を考慮していません。"
  a0link="https://bitcoincore.reviews/26152#l-30"

  q1="<!--what-does-a-transaction-s-cluster-consist-of-->トランザクションの「クラスター」とは何で構成されたものですか？"
  a1="そのトランザクション自体とそのトランザクションと接続されたすべてのトランザクションで構成されています。
      これには、そのトランザクションのすべての先祖と子孫や、
      兄弟や従兄弟、つまり指定されたトランザクションの先祖や子孫ではない親の子も含まれます。"
  a1link="https://bitcoincore.reviews/26152#l-72"

  q2="<!--this-pr-introduces-miniminer-which-duplicates-some-of-the-actual-miner-s-algorithms-would-it-have-been-better-to-unify-these-two-implementations-through-refactoring-->このPRは実際のマイナーのアルゴリズムといくつか重複する`MiniMiner`を導入しています。
      リファクタリングによって、この2つ実装を統合したほうが良いのでしょうか？"
  a2="mempool全体に対してではなく、クラスターに対してのみ計算をする必要があり、
      また`BlockAssembler`が行っているようなチェックを適用する必要はありません。
      mempoolをロックせずにこの計算を行うことも提案されました。
      また、ブロックテンプレートを構築するのではなく、手数料の引き上げを追跡するようBlockAssemblerを変更する必要があり、
      リファクタリングに必要な量は、書き直しに等しいものでした。"
  a2link="https://bitcoincore.reviews/26152#l-94"

  q3="<!--why-does-the-miniminer-require-an-entire-cluster-why-can-t-it-just-use-the-union-of-each-transaction-s-ancestor-sets-->なぜ`MiniMiner`はすべてのクラスターを必要とするのですか？トランザクションの先祖のセットの和ではできないのでしょうか？"
  a3="先祖の一部の手数料は、すでに他の子孫によって支払われている可能性があり、さらに手数料を引き上げる必要はないかもしれなせん。
      そのため、これらの子孫も計算に含める必要があります。"
  a3link="https://bitcoincore.reviews/26152#l-129"

  q4="<!--if-transaction-x-has-a-higher-ancestor-feerate-than-independent-transaction-y-is-it-possible-for-a-miner-to-prioritize-y-over-x-that-is-mine-y-before-x-->トランザクションXが独立したトランザクションYよりも高い先祖の手数料率を持っている場合、
      マイナーがXよりYを優先する（つまりXよりYをマイニングする）可能性はありますか？"
  a4="はい。Yの低手数料率の先祖の一部に高手数料率の子孫がある場合、Yはその先祖のために手数料を支払う必要はありません。
      Yの先祖のセットは、そのトランザクションを除外するよう更新され、Yの先祖の手数料率を増加させる効果があります。"
  a4link="https://bitcoincore.reviews/26152#l-169"

  q5="<!--can-calculatebumpfees-overestimate-underestimate-both-or-neither-by-how-much-->`CalculateBumpFees()`は手数料を過大評価したり過小評価したり、またはその両方、どちらでもないことがありますか？
      またそれはどれくらいですか？"
  a5="先祖が重複するアウトプットが2つ選択された場合、それぞれが独立して先祖の手数料を引き上げるため（共通の先祖を考慮することなく）過大評価されます。
      参加者は、引き上げ手数料を過小評価することはできないと結論づけました。"
  a5link="https://bitcoincore.reviews/26152#l-194"

  q6="<!--the-miniminer-is-given-a-list-of-utxos-outpoints-that-the-wallet-might-be-interested-in-spending-given-an-outpoint-what-are-its-five-possible-states-->`MiniMiner`には、ウォレットが支払いに関心を持つ可能性のあるUTXO（OutPoint）のリストが与えられます。
      与えられたOutPointの取りうる5つの状態は何ですか？"
  a6="(1) 承認済みで未使用、(2) 承認済みだがmempool内の既存のトランザクションによって既に使用されている、
      (3) 未承認（mempool内）で未使用、(4) 未承認だがmempool内の既存のトランザクションによって既に使用されている、
      (5) 未知のOutPointである可能性があります。"
  a6link="https://bitcoincore.reviews/26152-2#l-21"

  q7="<!--what-approach-is-taken-in-the-bump-unconfirmed-parent-txs-to-target-feerate-commit-->「Bump unconfirmed parent txs to target feerate」のコミットではどんなアプローチが取られていますか？"
  a7="このコミットは、このPRの主な動作変更です。`MiniMiner`を使用して、各UTXOの引き上げ手数料を計算し
      （それぞれの先祖をターゲットの手数料率に引き上げるために必要な手数料）、
      その実効値を差し引きします。その後はこれまでと同様にコインを選択します。"
  a7link="https://bitcoincore.reviews/26152-2#l-100"

  q8="<!--how-does-the-pr-handle-spending-unconfirmed-utxos-with-overlapping-ancestry-->このPRでは、重複する先祖を持つ未承認UTXOの使用をどう処理しますか？"
  a8="コイン選択の後、各コイン選択の結果について`MiniMiner`アルゴリズムを実行し、
      正確な引き上げ手数料を得ます。先祖を共有しているため過剰な引き上げをしている場合、
      お釣り用のアウトプットがある場合はそのお釣りに追加し、ない場合はお釣り用のアウトプットを追加して手数料を削減します。"
  a8link="https://bitcoincore.reviews/26152-2#l-111"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BTCPay Server 1.7.1][]は、最も広く利用されているセルフホスト型のBitcoinのペイメントプロセッサソフトウェアの最新リリースです。

- [Core Lightning 22.11][]は、CLNの次期メジャーバージョンです。
  また、新しいバージョン番号方式[^semver]を使用した最初のリリースでもあります。
  いくつかの新しい機能と、新しいプラグインマネージャー、複数のバグ修正が含まれています。

- [LND 0.15.5-beta][]は、LNDのメンテナンスリリースです。
  リリースノートによると、マイナーなバグ修正のみが含まれています。

- [BDK 0.25.0][]は、ウォレット構築用のこのライブラリの新しいリリースです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #19762][]は、RPC（および、拡張により`bitcoin-cli`）インターフェースを更新し、
  名前付き引数と位置ベースの引数を一緒に使用できるようになりました。この変更により、
  すべてのパラメーターに名前を付けることなく、名前付きパラメーターを使用するのが便利になります。
  PRの説明では、このアプローチにより利便性の向上を示す例と、
  `bitcoin-cli`を頻繁に使用するユーザー向けの便利なシェルエイリアスを提供しています。

- [Core Lightning #5722][]は、GRPCインターフェースプラグインの使用方法の[ドキュメント][grpc doc]を追加しました。

- [Eclair #2513][]は、Bitcoin Coreウォレットの使用方法を更新し、常にP2WPKHにお釣りを送信するようになりました。
  これは[Bitcoin Core #23789][]の結果で（[ニュースレター #181][news181 bcc23789]参照）、
  新しいアウトプットタイプ（[Taproot][topic taproot]など）の採用者のプライバシーの懸念に対処するためのものです。
  これまでは、ウォレットのデフォルトアドレスタイプをTaprootに設定したユーザーは、
  誰かに支払いをする際にTaprootのお釣り用アウトプットも作成していました。
  Taprootを使用しない人に支払う場合、第三者がどれが支払いのアウトプット（非Taprootアウトプット）で
  どれがお釣りのアウトプット（Taprootアウトプット）なのか簡単に判別することができました。
  Bitcoin Coreの変更後は、支払いに使用されたアウトプットと同じタイプがお釣り用のアウトプットとして使用するのがデフォルトになります。
  例えば、ネイティブSegwitアウトプットへの支払いでは、ネイティブSegwitのお釣り用アウトプットが作られます。

    しかし、LNプロトコルは特定のアウトプットタイプを使用します。例えば、
    P2PKHアウトプットはLNチャネルを開くのに使用することはできません。
    この理由から、Bitcoin CoreのEclairユーザーは、LNと互換性のないタイプのお釣り用アウトプットを生成しないようにする必要があります。

- [Rust Bitcoin #1415][]は、RustのBitcoinのコードのいくつかの特性を証明するために、
  [Kani Rust Verifier][]を使用するようになりました。これはFuzzingのような、
  コードに対して実行される他の継続的インテグレーションテストを補完するものです。

- [BTCPay Server #4238][]は
  BTCPayのGreenfield APIに、元のBitPayにインスパイアされたAPIとは異なる、インボイスの払い戻しエンドポイントを追加しました。

## 脚注

[^semver]:
    以前のニュースレターでは、Core Lightningは[セマンティックバージョン][semantic versioning]を使用しており、
    新しいバージョンでもその方式を継続的に使用するとしていました。
    Rusty Russellは、CLNがその方式に完全に準拠できない理由を[説明しました][rusty semver]。
    以前の誤りについて指摘してくれたMatt Whitlockに感謝します。

{% include references.md %}
{% include linkers/issues.md v=2 issues="19762,5722,2513,1415,4238,18725,26403,23789" %}
[lnd 0.15.5-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.5-beta
[core lightning 22.11]: https://github.com/ElementsProject/lightning/releases/tag/v22.11
[btcpay server 1.7.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.7.1
[bdk 0.25.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.25.0
[semantic versioning]: https://semver.org/spec/v2.0.0.html
[grpc doc]: https://github.com/cdecker/lightning/blob/20bc743840bf5d948efbf62d32a21a00ed233e31/plugins/grpc-plugin/README.md
[news181 bcc23789]: /ja/newsletters/2022/01/05/#bitcoin-core-23789
[kani rust verifier]: https://github.com/model-checking/kani
[news223 anchors]: /ja/newsletters/2022/10/26/#ephemeral-anchors
[news224 anchors]: /ja/newsletters/2022/11/02/#anchor-outputs-workaround
[sanders ephemeral]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-November/021222.html
[review club 26152]: https://bitcoincore.reviews/26152
[review club 26152-2]: https://bitcoincore.reviews/26152-2
[rusty semver]: https://github.com/ElementsProject/lightning/issues/5716#issuecomment-1322745630
