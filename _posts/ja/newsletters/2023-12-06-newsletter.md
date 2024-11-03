---
title: 'Bitcoin Optech Newsletter #280'
permalink: /ja/newsletters/2023/12/06/
name: 2023-12-06-newsletter-ja
slug: 2023-12-06-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、提案中のクラスターmempoolに関するいくつかの議論と、
warnetを使用して実行されたテスト結果を掲載しています。
また、Bitcoin Core PR Review Clubミーティングの要約や、
新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **クラスターmempoolの議論:** [クラスターmempool][topic cluster mempool]に取り組んでいる
  Bitcoin Core開発者は、Delving Bitcoinフォーラムで[ワーキンググループ][wg-cluster-mempool]（WG）を開始しました。
  クラスターmempoolは、トランザクションの必要な順序を尊重しながら、mempool上の操作をはるかに容易にするための提案です。
  Bitcoinトランザクションを有効に順序付けするには、親を子よりも前のブロックに配置するか、
  同じブロックで前に配置することで、親トランザクションを子トランザクションよりも先に承認する必要があります。
  クラスターmempoolの設計では、１つ以上の関連トランザクションの _クラスター_ が、
  手数料率でソートされたチャンクに分割されるように設計されています。
  どのチャンクも、それより前の（より手数料率が高い）未承認のチャンクがすべて同じブロックに含まれている限り、
  ブロックの最大weightまで、ブロックに含めることができます。

  すべてのトランザクションがクラスターに関連付けられ、クラスターがチャンクに分割されると、
  ブロックに含めるトランザクションを選択するのは簡単です。ブロックがいっぱいになるまで、
  最も手数料率の高いチャンクを選択し、次はその次に高いチャンクを選択します。
  このアルゴリズムを使用すると、mempool内の最も手数料率の低いチャンクが、
  ブロックに含まれるチャンクから最も遠いチャンクであることは明白です。
  そのため、mempoolがいっぱいになり、一部のトランザクションを排除する必要がある場合には、
  逆のアルゴリズムを適用できます。ローカルmempoolが意図した最大サイズを下回るまで、
  最も低い手数料率のチャンクを排除し、その次に低いチャンクを排除するということを繰り返します。

  WGのアーカイブは誰でも閲覧できるようになりましたが、投稿できるのは招待されたメンバーのみです。
  これまで議論された注目すべきトピックには以下のようなものがあります:

  - [<!--cluster-mempool-definitions-and-theory-->クラスターmempoolの定義と理論][clusterdef]では、クラスターmempoolの設計で使用される用語を定義しています。
    またこの設計の有用な特性の一部を示す少数の定理についても記述しています。
    このスレッドの１つの投稿（この記事の執筆時点）は、WGによる他の議論を理解するのにとても役立ちますが、
    投稿者（Pieter Wuille）はまだ「非常に不完全」であると[警告しています][wuille incomplete]。

  - [<!--merging-incomparable-linearizations-->比較不可能なリニアライザーションのマージ][cluster merge]では、
    同じトランザクションのセットに対して2つの異なるチャンクのセット（チャンキング）をマージする方法、
    特に _比較不可能_ なチャンキングについて検討しています。
    異なるチャンクのリスト（チャンキング）を比較することで、マイナーにとってどちらがより良いか判断できます。
    チャンキングを比較できるのは、その1つが任意のvbyte（チャンクのサイズに応じて異なる）内で
    常に同じかそれ以上の手数料を蓄積する場合です。たとえば、

    ![Comparable chunkings](/img/posts/2023-12-comparable-chunkings.png)

    チャンキングの一方があるvbyte数内でより多くの手数料を蓄積し、
    もう一方のチャンキングがよりvbyte数が多く手数料の蓄積も多い場合は、チャンキングは比較できません。たとえば、

    ![Incomparable chunkings](/img/posts/2023-12-incomparable-chunkings.png)

    先程のリンクのスレッドの定理の1つでは、「グラフで比較できない2つのチャンキングがある場合、
    その両方よりも厳密に優れた別のチャンキングが存在しなければならない」と述べられています。
    つまり、2つの異なる比較不可能なチャンキングをマージする効果的な方法は、
    マイナーの収益性を向上させる強力なツールになり得るということです。
    たとえば、既にmempoolに存在する他のトランザクションに関連する新しいトランザクションを受信した場合、
    そのクラスターを更新する必要があり、これはチャンキングも更新する必要があることを意味します。
    この更新を行うには、次の2つの異なる方法を両方実行できます:

    1. 更新されたクラスターの新しいチャンキングは最初から計算されます。
       大規模なクラスターの場合、最適なチャンキングを見つけるのは計算上、非現実的である可能性があるため、
       新しいチャンキングは古いチャンキングほど最適ではない可能性があります。

    2. 以前のクラスターの以前のチャンキングは、新しいトランザクションを有効な場所（子の前に親）に挿入することで更新されます。
       これには、変更されていないチャンク内の既存の最適化が保持されるという利点がありますが、
       トランザクションを最適でない場所に配置する可能性があるという欠点があります。

    2つの異なるタイプの更新が行われた後、比較するとどちらか一方の方が厳密に優れていることが判明する場合があり、
    その場合はそれを使用できます。しかし、更新が比較不可能な場合は、同等以上の結果が得られることが保証されているマージ方法を代わりに使用し、
    より良い場合は新しいチャンキングを使用し、最適に近い場合は古いチャンキングを保持することで、
    両方のアプローチの最も優れた側面を取る3つめのチャンキングを生成できます。

  - [クラスター後のパッケージRBF][cluster rbf]では、
    [Replace by Fee][topic rbf]で現在使用されているルールの代替案について議論しています。
    1つ以上のトランザクションの有効な置換を受信すると、それが影響するすべてのクラスターの一時的なバージョンが作成され、
    更新されたチャンキングが導出されます。これは、現在mempoolにある元のクラスター（置換を含まない）のチャンキングと比較できます。
    置換によるチャンキングがvbyte数に対して常に元と同じかそれ以上の手数料を獲得し、
    mempool内の総手数料額がリレー手数料を支払うのに十分な量だけ増加する場合、それをmempoolに含めるべきです。

    このエビデンスに基づいた評価は、トランザクションを置き換えるべきかどうかを決定するために
    Bitcoin Coreで現在使用されているいくつかの[ヒューリスティック][mempool replacements]を置き換えることができ、
    置換のために提案中の[パッケージリレー][topic package relay]を含む、いくつかの領域でRBFルールを改善する可能性があります。
    [他の][cluster rbf-old1]いくつかの[スレッド][cluster rbf-old2]でも[この][cluster rbf-old3]トピックについて議論しています。

- **warnetでのテスト:** Matthew Zipkinは、[warnet][]を使用して実行したいくつかのシミュレーション結果を
  Delving Bitcoinに[投稿しました][zipkin warnet]。warnetは、（通常はテストネットワーク上で）
  定義された接続セットを持つ多数のBitcoinノードを起動するプログラムです。
  Zipkinの結果は、ピア管理のコードに対するいくつかの変更案が（独立して、または一緒に）マージされた場合に使用されるであろう
  余分なメモリを示しています。彼はまた、他の変更案のテストや提案された攻撃の影響を定量化するためにシミュレーションを使用することが楽しみだと述べています。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Testing Bitcoin Core 26.0 Release Candidates][review club v26-rc-testing]は、
特定のPRをレビューするのではなく、グループテストの取り組みでした。

[Bitcoin Coreの各メジャーリリース][major Bitcoin Core release]の前には、
コミュニティによる広範囲なテストが不可欠であると考えられています。
このため、[リリース候補][release candidate]のテストガイドをボランティアが作成しています。
これにより、できるだけ多くの人が、リリースの新機能や変更点を個別に確認したり、
これらの機能や変更をテストするためのさまざまなセットアップ手順を再発明したりすることなく、
生産的にテストできるようになります。

予期しない動作に遭遇した際、それが実際のバグによるものか、それともテスターの間違いによるものなのかが不明瞭なことが多いため、
テストが難しくなります。実際のバグではないものを開発者に報告することは時間の無駄です。
これらの問題を軽減し、テスト作業を促進するために、特定のリリース候補（ここでは26.0rc2）に対して
Review Clubミーティングが開催されます。

[26.0のリリース候補のテストガイド][26.0 testing]は、Max Edwardsによって書かれ、
彼はまたStéphan (stickies-v)の協力を得てReview Clubミーティングを主催しました。

参加者は、[26.0のリリースノート][26.0 release notes]を読むことで、テストのアイディアを得ることが奨励されました。

このReview Clubのセッションでは、
[`getprioritisedtransactions`][PR getprioritisedtransactions]（
[以前のReview Clubミーティングでも取り上げられました][news250 pr review]が、
そのRPCの名前はReview Clubミーティングが開催された後で変更されました）と
[`importmempool`][PR importmempool]という2つのRPCを取り上げました。
リリースノートの[新しいRPC][New RPCs]セクションに、これらのRPCやその他追加されたRPCについて記述されています。
ミーティングでは、[V2トランスポート(BIP324)][topic v2 p2p transport]についても取り上げられ、
[TapMiniscript][PR TapMiniscript]についても取り上げる予定でしたが、
このトピックについては時間的な制限から議論されませんでした。

{% include functions/details-list.md
  q0="どのOSを使用していますか？"
  a0="WSL（Windows subsystem for Linux）上でUbuntu 22.04、macOs 13.4 (M1チップ)。"
  a0link="https://bitcoincore.reviews/v26-rc-testing#l-18"

  q1="`getprioritisedtransactions`のテスト結果はどうでしたか？"
  a1="参加者は期待どおりに動作したと報告しましたが、
      [`prioritisetransaction`][prioritisetransaction]の効果が複合的に作用することに気づいた参加者もいました。
      つまり、同じトランザクションで2回実行すると、手数料が2倍になります。
      fee引数がトランザクションの既存の優先順位に追加されるため、これは期待される動作です。"
  a1link="https://bitcoincore.reviews/v26-rc-testing#l-32"

  q2="`importmempool`のテスト結果はどうでしたか？"
  a2="ある参加者は、「Can only import the mempool after the block download and sync is done」
      というエラーが発生したものの、2分待った後、RPCは成功しました。別の参加者は、完了までに時間がかかると指摘しました。"
  a2link="https://bitcoincore.reviews/v26-rc-testing#l-45"

  q3="インポート中にCLIプロセスを中断し（`bitcoind`を停止せずに）、CLIプロセスを再開するとどうなりますか？"
  a3="これは何も問題がないようでした。2つめのインポートリクエストは期待どおりに完了しました。
      CLIコマンドが中断された後もインポートプロセスは続行され、
      2つめのリクエストによって2つのインポートスレッドが同時に実行されて互いに競合することはなかったようです。"
  a3link="https://bitcoincore.reviews/v26-rc-testing#l-91"

  q4="V2トランスポートを実行した結果はどうでしたか？"
  a4="参加者は、既知のV2対応ノードに接続できませんでした。
      接続要求を受け付けていないようです。すべてのインバウンドスロットが使用されている可能性が示唆されました。
      このため、ミーティング中にはP2Pのテストはできませんでした。"
  a4link="https://bitcoincore.reviews/v26-rc-testing#l-115"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 26.0][]は、主流のフルノード実装の次期メジャーバージョンです。
  このリリースには、[バージョン2トランスポートプロトコル][topic v2 p2p transport]の実験的なサポートや、
  [miniscript][topic miniscript]での[Taproot][topic taproot]のサポート、
  [assumeUTXO][topic assumeutxo]のステートを扱うための新しいRPC、
  トランザクションの[パッケージ][topic package relay]を処理するための実験的なRPC（リレーはまだサポートされていません）および、
  多数の改善とバグ修正が含まれています。

- [LND 0.17.3-beta.rc1][]は、いくつかのバグ修正を含むリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #28848][]は、トランザクションが失敗した場合に役立つように`submitpackage` RPCを更新しました。
  最初の失敗で`JSONRPCError`を投げるのではなく、可能な限り各トランザクションの結果を返すようになりました。

- [LDK #2540][]は、LDKの最近の[ブラインドパス][topic rv routing]の作業（ニュースレター[#257][news257 ldk2120]と
  [#266][news266 ldk2411]参照）に基づき、ブラインドパスのイントロノードとして転送をサポートするもので、
  LDKのBOLT12[オファー][topic offers]の実装に必要な[課題][LDK #1970]の一部です。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28848,2540,1970" %}
[bitcoin core 26.0]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Release-Candidate-Testing-Guide
[wg-cluster-mempool]:  https://delvingbitcoin.org/c/implementation/wg-cluster-mempool/9
[clusterdef]: https://delvingbitcoin.org/t/clustermempool-definitions-theory/202
[cluster merge]: https://delvingbitcoin.org/t/merging-incomparable-linearizations/209/38
[cluster rbf]: https://delvingbitcoin.org/t/post-clustermempool-package-rbf-per-chunk-processing/190
[cluster rbf-old1]: https://delvingbitcoin.org/t/defunct-post-clustermempool-package-rbf/173
[cluster rbf-old2]: https://delvingbitcoin.org/t/defunct-cluster-mempool-package-rbf-sketch/171
[cluster rbf-old3]: https://delvingbitcoin.org/t/cluster-mempool-rbf-thoughts/156
[zipkin warnet]: https://delvingbitcoin.org/t/warnet-simulations/232
[warnet]: https://github.com/bitcoin-dev-project/warnet
[wuille incomplete]: https://github.com/bitcoinops/bitcoinops.github.io/pull/1421#discussion_r1414487021
[mempool replacements]: https://github.com/bitcoin/bitcoin/blob/fa9cba7afb73c01bd2c8fefd662dfc80dd98c5e8/doc/policy/mempool-replacements.md
[LND 0.17.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.3-beta.rc1
[review club v26-rc-testing]: https://bitcoincore.reviews/v26-rc-testing
[major bitcoin core release]: https://bitcoincore.org/ja/lifecycle/#major-releases
[26.0 release notes]: https://github.com/bitcoin/bitcoin/blob/44d8b13c81e5276eb610c99f227a4d090cc532f6/doc/release-notes.md
[new rpcs]: https://github.com/bitcoin/bitcoin/blob/44d8b13c81e5276eb610c99f227a4d090cc532f6/doc/release-notes.md#new-rpcs
[news250 pr review]: /ja/newsletters/2023/05/10/#bitcoin-core-pr-review-club
[release candidate]: https://bitcoincore.org/ja/lifecycle/#versioning
[pr getprioritisedtransactions]: https://github.com/bitcoin/bitcoin/pull/27501
[pr importmempool]: https://github.com/bitcoin/bitcoin/pull/27460
[pr tapminiscript]: https://github.com/bitcoin/bitcoin/pull/27255
[prioritisetransaction]: https://developer.bitcoin.org/reference/rpc/prioritisetransaction.html
[news257 ldk2120]: /ja/newsletters/2023/06/28/#ldk-2120
[news266 ldk2411]: /ja/newsletters/2023/08/30/#ldk-2411
