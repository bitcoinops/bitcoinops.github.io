---
title: 'Bitcoin Optech Newsletter #250'
permalink: /ja/newsletters/2023/05/10/
name: 2023-05-10-newsletter-ja
slug: 2023-05-10-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、PoWswapプロトコルに関する論文と、
Bitcoin Core PR Review Clubミーティングの要約、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など恒例のセクションが含まれています。
また、Bitcoin Optechの5周年と250回目のニュースレターを祝う短いセクションも含まれています。

## ニュース

- **PoWswapプロトコルに関する論文:** Thomas Hartmanは、
  Jeremy Rubinが最初に提案した[PoWSwap][]プロトコルについて、
  彼がGleb NaumenkoとAntoine Riardと共に書いた[論文][hnr powswap]を
  Bitcoin-Devメーリングリストに[投稿][hartman powswap]しました。
  PoWSwapは、ハッシュレートの変化に関連したオンチェーンで強制可能なコントラクトの作成を可能にします。
  基本的なアイデアは、プロトコルによって強制される時間とブロック生成の関係を利用し、
  時間またはブロックのいずれかでタイムロックを表現する能力を利用するものです。たとえば、
  次のようなスクリプトを考えてみましょう。

  ```
  OP_IF
    <アリスの鍵> OP_CHECKSIGVERIFY <time> OP_CHECKLOCKTIMEVERIFY
  OP_ELSE
    <ボブの鍵> OP_CHECKSIGVERIFY <height> OP_CHECKLOCKTIMEVERIFY
  OP_ENDIF
  ```

  現在の時刻が _t_ 、現在のブロック高が _x_ であるとしましょう。
  ブロックが平均10分間隔で生成されているとすると、`<time>`を _t + 1000分_ 、
  `<height>`を _x + 50_ と設定すると、ボブは上記のスクリプトで管理されているアウトプットを、
  アリスがそれを使うことができるよりも平均500分早く使うことができると予想されます。
  しかし、ブロックの生成速度が突然2倍以上になったら、アリスがボブより先にアウトプットを使用できる可能性があります。

  このようなタイプのコントラクトには、いくつかの応用が想定されます:

  - *<!--hashrate-increase-insurance-->ハッシュレート上昇保険:*
    マイナーは、どれだけの収入が得られるかはっきりしないうちに設備を購入しなければなりません。
    たとえば、ネットワークの現在の総報酬の1%を受け取るのに十分な機器を購入したマイナーは、
    他のマイナーもネットワークの総ハッシュレートを2倍にするだけの機器を購入したことに気づき、
    結果そのマイナーは1%ではなく0.5%の報酬しか得られないかもしれません。
    PoWSwapを使うと、マイナーは、ある日までにハッシュレートが増加した場合にマイナーに支払いをする相手と
    トラストレスなコントラクトを作成することができ、マイナーの予想外の低収入を相殺することができます。
    その代わり、マイナーは前払いのプレミアムを支払うか、ネットワーク全体のハッシュレートが同じか減少した場合に、
    より多くの金額を支払うことに同意します。

  - *<!--hashrate-decrease-insurance-->ハッシュレート低下保険:*
    Bitcoinのさまざまな問題により、ネットワーク全体のハッシュレートが大幅に低下する可能性があります。
    マイナーが権力者によって閉鎖させられたり、
    既存のマイナー間で大量の[フィー・スナイピング][topic fee sniping]が突然発生したり、
    マイナーにとってのBTCの価値が突然低下したりすると、ハッシュレートは低下します。
    このような事態に備えたいBTC保有者は、マイナーや第三者とトラストレスなコントラクトを作ることができます。

  - *<!--exchange-rate-contracts-->為替レートコントラクト:*
    一般的に、BTCの購買力が上がれば、マイナーは（受け取る報酬を増やすために）提供するハッシュレートの量を増やしたいと考えます。
    購買力が低下すると、ハッシュレートも低下します。多くの人が、
    Bitcoinの将来の購買力に関連するトラストレスなコントラクトに興味を持つかもしれません。

  PoWSwapのアイディアは数年前から広まっていますが、この論文では、
  これまでに見たことのないより詳細な分析が提供されています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning 23.05rc2][]は、このLN実装の次期バージョンのリリース候補です。

- [Bitcoin Core 24.1rc2][]は、Bitcoin Coreの現在のバージョンのメンテナンスリリースのリリース候補です。

- [Bitcoin Core 25.0rc1][]は、Bitcoin Coreの次期メジャーバージョンのリリース候補です。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Add getprioritisationmap, delete a mapDeltas entry when delta==0][review club 27501]は、
Gloria Zhao (glozow)によるPRで、Bitcoin Coreの機能を改善し、
マイナーが有効なmempool手数料を変更できるようにし、
特定のトランザクションのマイニング優先度（高いか低いか）を変更できるようにします（[prioritisetransaction RPC][]参照）。
手数料の増加（正の場合）または減少（負の場合）は、 _手数料デルタ_ と呼ばれます。
トランザクションの優先順位付けの値は、`mempool.dat`ファイル内のディスクに永続化され、ノードの再起動時に復元されます。

マイナーがトランザクションの優先順位付けをする理由の１つは、
帯域外のトランザクション手数料の支払いを考慮するためです。
マイナーのブロックテンプレートに含めるトランザクションを選択する際に、
影響を受けるトランザクションは、より高い手数料を持つものとして扱われます。

このPRでは、優先順位付けされたトランザクションのセットを返す新しいRPC、`getprioritisationmap`を追加しています。
また、ユーザーがデルタをゼロに戻した場合に発生する可能性のある、不要な優先順位付けエントリを削除します。

{% include functions/details-list.md
  q0="<!--what-is-the-mapdeltas-data-structure-and-why-is-it-needed-->[mapDeltas][]データ構造とは何ですか？どうして必要なのですか？"
  a0="トランザクション毎の優先順付けされた値が格納されます。
      これらの値は、ローカルのマイニングと排除の決定および、祖先と子孫の手数料率の計算に影響します。"
  a0link="https://bitcoincore.reviews/27501#l-26"

  q1="<!--do-transaction-prioritizations-affect-the-fee-estimation-algorithm-->トランザクションの優先順位付けは手数料推定アルゴリズムに影響しますか？"
  a1="いいえ。手数料の推定は、マイナー（この場合、 _他の_ マイナー）の予想される決定を正確に予測する必要があり、
      これらのマイナーは、私達と同じ優先順位を持っていません。優先順位はローカルのものなので。"
  a1link="https://bitcoincore.reviews/27501#l-31"

  q2="<!--how-is-an-entry-added-to-mapdeltas-when-is-it-removed-->`mapDeltas`へのエントリーはどのように追加されますか？
      また、いつ削除されるのですか？"
  a2="`prioritisetransaction` RPCによって追加され、またノードの再起動時には、`mempool.dat`内のエントリーに起因します。
      トランザクションを含むブロックがチェーンに追加された時や、トランザクションが[置換][topic rbf]された際に削除されます。"
  a2link="https://bitcoincore.reviews/27501#l-34"

  q3="<!--why-shouldn-t-we-delete-a-transaction-s-entry-from-mapdeltas-when-it-leaves-the-mempool-because-for-example-it-has-expired-or-been-evicted-due-to-feerate-dropping-below-the-minimum-feerate-->
      トランザクションがmempoolから出る際に（たとえば、期限切れや手数料率が最小手数料率を下回って排除された場合など）、
      そのエントリーを`mapDeltas`から削除すべきでないのは何故ですか？"
  a3="トランザクションは再びmempoolに戻ってくるかもしれません。
      `mapDeltas`のエントリーが削除された場合、ユーザーはトランザクションの優先順位付けを再度行う必要があります。"
  a3link="https://bitcoincore.reviews/27501#l-84"

  q4="<!--if-a-transaction-is-removed-from-mapdeltas-because-it-s-included-in-a-block-but-then-the-block-is-re-orged-out-won-t-the-transaction-s-priority-have-to-be-reestablished-->
      トランザクションがブロックに含まれたため`mapDeltas`から削除され、その後ブロックが再編成された場合、
      そのトランザクションの優先順位は再設定されなければならないのではないでしょうか？"
  a4="はい。しかし再編成は稀であると予想されます。また、帯域外の支払いは実際にはBitcoinトランザクションの形である可能性があるため、
      そちらもやり直しが必要な場合があります。"
  a4link="https://bitcoincore.reviews/27501#l-90"

  q5="<!--why-should-we-allow-prioritizing-a-transaction-that-isn-t-present-in-the-mempool-->なぜ、mempoolに存在しないトランザクションを優先的に処理できるようにしなければならないのでしょう？"
  a5="そのトランザクションがまだmempoolに存在しないかもしれないからです。
      そして、そもそもそのトランザクションは（優先順位付けしなければ）自身の手数料でmempoolに入ることさえできないかもしれません。"
  a5link="https://bitcoincore.reviews/27501#l-89"

  q6="<!--what-is-the-problem-if-we-don-t-clean-up-mapdeltas-->`mapDeltas`をクリーンアップしない場合、どのような問題が起きますか？"
  a6="主な問題は、無駄なメモリ割り当てです。"
  a6link="https://bitcoincore.reviews/27501#l-107"

  q7="<!--when-is-mempool-dat-including-mapdeltas-written-from-memory-to-disk-->`mempool.dat`（`mapDeltas`を含む）は、
      いつメモリからディスクに書き込まれますか？"
  a7="クリーンシャットダウン時か`savemempool`を実行した際です。"
  a7link="https://bitcoincore.reviews/27501#l-114"

  q8="<!--without-the-pr-how-do-miners-clean-up-mapdeltas-that-is-remove-entries-with-a-zero-prioritization-value-->このPRがない場合、
      マイナーはどうやって`mapDeltas`をクリーンアップするのでしょうか（つまり、優先順位がゼロのエントリーを削除するのでしょうか）？"
  a8="唯一の方法はノードを再起動することです。ゼロ値の優先順位付けは、再起動中に`mapDeltas`にロードされないからです。
      PRでは、値がゼロに設定されるとすぐに`mapDeltas`のエントリーが削除されます。
      これには、ゼロ値の優先順位付けがディスクに書き込まれないという利点もあります。"
  a8link="https://bitcoincore.reviews/27501#l-127"
  %}

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #26094][]では、`getbalances`と`gettransaction`、`getwalletinfo`に
  ブロックハッシュと高さのフィールドを追加しました。これらのRPC呼び出しは、
  最新のブロックであることを確認するためchainstateをロックするので、
  有効なブロックハッシュと高さをレスポンスに含めるのは有益です。

- [Bitcoin Core #27195][]では、Bitcoin Coreの内部ウォレットから
  `bumpfee`RPCを使用して[置き換えられる][topic rbf]トランザクションからすべての外部受信者を削除できるようになりました。
  ユーザーは、置換トランザクションの唯一のアウトプットをユーザー自身のアドレスに支払うようにすることでこれを行います。
  置換トランザクションが承認されると、元の受信者のいずれにも支払いが行われなくなるため、
  Bitcoin支払いを「キャンセルする」と表現されることがあります。

- [Eclair #1783][]は、1つ以上のトランザクションを[CPFP][topic cpfp]により手数料を引き上げるための
  `cpfpbumpfees` APIを追加しました。このPRはまた、手数料引き上げのトランザクションの作成が実行可能であることを保証するために、
  Bitcoin Coreを実行するための[推奨パラメーター][eclair bitcoin.conf]のリストを更新しています。

- [LND #7568][]は、ノードの起動時に追加のLN機能ビットを定義する機能を追加しました。
  また、実行中にハードコードまたは定義された機能ビットを無効にする機能も削除しました（ただし、
  追加ビットは追加した後で無効にできます）。[BLIPs #24][]の関連する提案の更新では、
  カスタム[BOLT11][]機能ビットの最大値が5114に制限されることが指摘されています。

- [LDK #2044][]は、[BOLT11][]インボイスに対するLDKのルートヒントにいくつかの変更を加えています。
  ルートヒントは、受信側のLNノードが送信側のノードが使用するルートを提案するために使用できる仕組みです。
  このマージにより、提案されるのは3つのチャネルのみとなり、
  LDKのファントムノードのサポートが改善され（[ニュースレター #188][news188 phantom]参照）、
  選択された3つのチャネルは効率とプライバシーを考慮して選択されます。
  PRの議論では、ルートヒントの提供がプライバシーに与える影響について、
  [いくつか][carman hints]の[示唆に富んだ][corallo hints]コメントが含まれています。

## 祝・Optech Newsletter #250

Bitcoin Optechは、「企業とオープンソースコミュニティの連携を促進する」ことを目的として設立されました。
この週刊ニュースレターは、Bitcoinを使用する企業の幹部や開発者に、
オープンソースコミュニティが構築しているものについてより深く理解してもらうことを目的として開始されました。
そのため、当初は事業に影響を与える可能性のある作業を文書化することに重点を置きました。

しかし、この情報に興味を持つのは、企業の読者だけではないことがすぐにわかりました。
Bitcoinプロジェクトの多くのコントリビューターは、プロトコル開発のメーリングリストの議論をすべて読んだり、
他のプロジェクトの大きな変更を監視したりする時間がなかったのです。
そんな彼らにとって、自分たちが興味を持ちそうな、あるいは自分たちの仕事に影響を与えそうな開発について、
誰かが知らせてくれることはありがたいことでした。

この5年近く、そのようなサービスを提供することができたのが、私たちの喜びです。
私たちは、このシンプルなミッションをさらに発展させるべく、
[ウォレット技術の互換性][compatibility matrix]ガイドや、
100以上の[興味深いトピック][topics]のインデックス、
そして私たちに記事を書く機会を与えてくれた多くのコントリビューターをゲストに迎えた
週刊のディスカッション[ポッドキャスト][podcast]を提供することにしています。

これらはすべて、過去1年間で以下のような多くの貢献者の存在なくしては実現できませんでした:
<!-- アルファベット順 -->
Adam Jonas、
Copinmalin、
David A. Harding、
Gloria Zhao、
Jiri Jakes、
Jon Atack、
Larry Ruane、
Mark "Murch" Erhardt、
Mike Schmidt、
nechteme、
Patrick Schwegler、
Shashwat Vangani、
Shigeyuki Azuchi、
Vojtěch Strnad、
Zhiwei "Jeffrey" Hu、
そして特定のテーマで特別寄稿してくれた他の多くの方々。

また、[創立スポンサー][founding sponsors]であるWences Casares、John Pfeffer、Alex Morcos、
そして多くの[資金援助者][financial supporters]の方々にも感謝しています。

お読みいただきありがとうございます。今後発行する次の250号も、引き続きお読みいただければ幸いです。

{% include references.md %}
{% include linkers/issues.md v=2 issues="26094,27195,1783,7568,24,2044" %}
[Core Lightning 23.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc2
[bitcoin core 24.1rc2]: https://bitcoincore.org/bin/bitcoin-core-24.1/
[bitcoin core 25.0rc1]: https://bitcoincore.org/bin/bitcoin-core-25.0/
[eclair bitcoin.conf]: https://github.com/ACINQ/eclair/pull/1783/files#diff-b335630551682c19a781afebcf4d07bf978fb1f8ac04c6bf87428ed5106870f5
[carman hints]: https://github.com/lightningdevkit/rust-lightning/pull/2044#issuecomment-1448840896
[corallo hints]: https://github.com/lightningdevkit/rust-lightning/pull/2044#issuecomment-1461049958
[hartman powswap]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021605.html
[hnr powswap]: https://raw.githubusercontent.com/blockrate-binaries/paper/master/blockrate-binaries-paper.pdf
[powswap]: https://powswap.com/
[news188 phantom]: /ja/newsletters/2022/02/23/#ldk-1199
[founding sponsors]: /about/#founding-sponsors
[financial supporters]: /#members
[review club 27501]: https://bitcoincore.reviews/27501
[prioritisetransaction rpc]: https://developer.bitcoin.org/reference/rpc/prioritisetransaction.html
[mapDeltas]: https://github.com/bitcoin/bitcoin/blob/fc06881f13495154c888a64a38c7d538baf00435/src/txmempool.h#L450
