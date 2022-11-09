---
title: 'Bitcoin Optech Newsletter #225'
permalink: /ja/newsletters/2022/11/09/
name: 2022-11-09-newsletter-ja
slug: 2022-11-09-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin CoreでフルRBFを有効にするための設定オプションに関する継続的な議論と、
BTCDおよびLND、その他のソフトウェアに影響を与えるバグについて掲載しています。
また、Bitcoin Core PR Review Clubミーティングの要約や、
新しいリリースとリリース候補の説明、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **フルRBFの有効化に関する継続的な議論:** 過去数週間のニュースレターで言及したように、
  ユーザーやサービスプロバイダー、Bitcoin Coreの開発者は、
  Bitcoin Coreの開発ブランチとバージョン24.0の現在のリリース候補に`mempoolfullrbf`オプションを含めることを評価してきました。
  これらの以前のニュースレターでは、この[フルRBF][topic rbf]オプションに対する多くのこれまでの議論を要約しています（
  [1][news222 rbf]、[2][news223 rbf]、[3][news224 rbf]）。
  今週、Suhas Daftuarは、「（BIP 125に記載されているように）RBFにオプトインしないトランザクションについては、
  置換を拒否するリレーポリシーを維持し続けるべきで、さらにネットワークの状況が変わらない限り（または変化するまで）、
  Bitcoin Coreの最新のリリース候補から`-mempoolfullrbf`フラグを取り除き、
  そのフラグを持つソフトウェアのリリースを計画すべきではない」とBitcoin-Devメーリングリストに[投稿しました][daftuar rbf]。
  彼は次のように述べています:

  - *<!--opt-in-rbf-already-available-->オプトインRBFは既に利用可能:* RBFの恩恵を受けたい人は誰でも、
    [BIP125][]に記載されている仕組みを使ってオプトインできるようにすべきです。
    ユーザーはオプトインRBFを使えない何らかの理由がある場合にのみフルRBFのサービスを受けることになります。

  - *<!--full-rbf-doesn-t-fix-anything-that-isn-t-broken-in-other-ways-->フルRBFは、他の方法で壊れていないものを修正するものではない:*
    マルチパーティプロトコルの一部のユーザーが、他のユーザーがオプトインRBFを使用することを拒否できる可能性が
    以前[確認されました][riard funny games]が、
    Daftuarは、そのプロトコルは他の安価なもしくは無料の攻撃に対して脆弱で、
    それはフルRBFでは解決できないことを指摘しています。

  - *<!--full-rbf-takes-away-options-->フルRBFは選択肢を奪う:*
    「フルRBFによって解決される問題の他の例がない限り、
    自分のトランザクションがBIP 125のRBFポリシーに従うことを自由に選択できるようになっているRBFユーザーにとって、
    フルRBFがRBFユーザーの何らかの問題を解決するとは思えません。
    この観点から、フルRBFを有効にすることは、実際には、トランザクションの非置換ポリシー性にオプトインするというユーザーの選択肢を奪うだけです。」

  - *<!--offering-non-replacement-doesn-t-introduce-any-issues-for-full-nodes-->非置換を提供することは、フルノードに対して何の問題も引き起こさない:*
    実際、長いトランザクションチェーンの処理が簡素化されます。

  - *<!--determining-incentive-compatibility-isn-t-always-straightforward-->インセンティブの互換性を判断するのは必ずしも容易ではない:*
    Daftuarは、v3トランザクションリレーの提案（[ニュースレター #220][news220 v3tx]参照）を例として挙げています:

    > 数年後、現在フルRBFで議論されているのと同じ理由で、
    > 誰かが私たちのソフトウェアに「-disable_v3_transaction_enforcement」フラグを追加して、
    > ユーザーがポリシーの制限をオフにしてv3トランザクションをv2トランザクションと同じように扱えるようにすることを提案したとしましょう。
    >
    > それは、v3トランザクションのライトニングのユースケースを機能させる上で破壊的です。
    > このポリシーをユーザーが無効にできるようにすべきではありません。なぜなら、
    > そのポリシーが単にオプションで、それを望む人のために機能している限り、
    > 特定のユースケースに対してより厳しいルールを提供することで、誰にも害を及ぼすべきではないからです。
    >
    > フルRBFで起きているのは、まさにこのことだと思います。

  Daftuarは、Bitcoin Coreに`mempoolfullrbf`オプションが含まれることをまだ望んている人への3つの質問でメールを終えています:

  1. 「フルRFBはゼロ承認のビジネス慣習を破壊する以外に何かメリットがあるのでしょうか？もしあるなら、それは何ですか？」

  2. 「BIP 125のRBFルールをすべてのトランザクションに強制することは、
     そのルール自体が必ずしもインセンティブに適合していない場合、合理的ですか？」

  3. 「将来、誰かがv3トランザクションリレーを破壊するコマンドラインオプションを提案したとしたら、
     それに反対する論理的根拠は、現在のフルRBFへの移行と矛盾しませんか？」

  この記事を書いている時点では、Daftuarの質問にメーリングリスト上で答える人はいませんが、
  Daftuarが`mempoolfullrbf`設定オプションの削除を提案するために公開したBitcoin Coreの[PR][bitcoin core #26438]には、
  一連の質問に対する2つの回答が投稿されています。Daftuarは、その後PRを[クローズしました][26438 close]。

  このトピックについて誰かがさらにコメントするかどうかは、記事の執筆時点では明確になっていません。

- **<!--block-parsing-bug-affecting-multiple-software-->複数のソフトウェアに影響するブロックのパースバグ:**
  [ニュースレター #222][news222 bug]で報告されたように、
  BTCDフルノードとLND LNノードに影響を与える深刻なバグが発生し、
  ソフトウェアのユーザーが危険にさらされました。更新されたソフトウェアはすぐにリリースされました。
  このバグが発生した直後、Anthony Townsは、マイナーだけが発生させることができる2つめの関連バグを[発見しました][towns find]。
  Townsは、このバグをBTCDとLNDのリードメンテナーであるOlaoluwa Osuntokunに報告し、
  Olaoluwa Osuntokunはソフトウェアの次のアップデートに含めるためのパッチを用意しました。
  他の変更と一緒にセキュリティの修正を含めることで、脆弱性が修正されていることを隠すことができ、
  悪用される可能性を低くすることができます。TownsもOsuntokunも責任を持って、
  修正パッチが配布されるまで脆弱性を非公開にしていました。

  残念ながら、2つめの関連バグは、それをトリガーするマイナーを発見した何者かによって独自に再発見されました。
  この新しいバグは、再びBTCDとLNDに影響を与えましたが、
  少なくとも[2つの][liquid and rust bitcoin vulns]重要なプロジェクト、サービスにも影響を与えました。
  影響を受けたシステムの全ユーザーは、直ちにアップグレードする必要があります。
  私たちは、3週間前に行った、あらゆるBitcoinソフトウェアを使用している人に、
  そのソフトウェアの開発チームからのセキュリティ通知に登録するようにというアドバイスを繰り返します。

  このニュースレターのリリースに伴い、Optechでは、
  Optechのニュースレターに掲載した[脆弱性を責任を持って開示した素晴らしい人たち][topic responsible disclosures]の名前を
  リストアップする特別なトピックページも追加されました。
  まだ公表されていないためリストアップされていない開示もいくつかあると思われます。
  もちろん、提案やプルリクエストのレビューアの方々の熱心な努力によって、
  無数のセキュリティバグがリリースされるソフトウェアに反映されるのが防がれています。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Relax MIN_STANDARD_TX_NONWITNESS_SIZE to 65 non-witness bytes][review club 26265]は、
instagibbsによるPRで、非witnessトランザクションサイズの制約を緩和するものです。
これはトランザクションが少なくとも85バイトであることを要求する現在のポリシーを置き換えるもので、
65バイトまで小さくすることができます（[ニュースレター #222][news222 min relay size]参照）。

このReview Clubミーティング以降、このPRは、PR[#26398][bitcoin core #26398]に取って代わられ、
64バイトのトランザクションのみを禁止することでポリシーをさらに緩和しています。
この2つの微妙に異なるポリシーの相対的なメリットについて、ミーティング中に議論されました。

{% include functions/details-list.md
  q0="<!--why-was-the-minimum-transaction-size-82-bytes-can-you-describe-the-attack-->最小トランザクションサイズは何故82バイトだったのですか？その攻撃について教えてください。"

  a0="2018年のPR[#11423][bitcoin core #11423]で導入された82バイトの最小値は、
  標準的な支払いトランザクションの最小サイズです。これは、標準ルールのクリーンナップとして発表しました。
  しかし実際には、SPVクライアントに対する[なりすまし支払い攻撃][spoof payment attack]（
  支払いを受け取っていないのに受け取ったと思わせる）が可能だった64バイトのトランザクションを標準とみなさないようにするための変更でした。
  この攻撃は、SPVクライントを騙して、64バイトのトランザクションが、
  同じく64バイトのトランザクションのマークルツリーの内部ノードであると認識させます。"

  a0link="https://bitcoincore.reviews/26265#l-35"

  q1="<!--a-participant-asked-was-it-was-necessary-to-fix-this-vulnerability-covertly-given-that-it-would-be-very-expensive-on-the-order-of-usd-1m-to-carry-out-this-attack-combined-with-the-fact-that-it-seems-unlikely-people-would-use-spv-clients-for-payments-that-large-->参加者から、この攻撃を実行するのは非常に高価（100万ドル規模）であること、
  また、これほど大きな支払いにSPVクライアントを使用する人はまずいないと思われることから、
  この脆弱性を秘密裏に修正する必要があったのでしょうか？という質問がありました。"

  a1="この点については意見が一致しましたが、ある参加者は、この点に関する私たちの直感は間違っている可能性があると指摘しました。"

  a1link="https://bitcoincore.reviews/26265#l-66"

  q2="<!--what-does-non-witness-size-mean-and-why-do-we-care-about-the-non-witness-distinction-->非witnessのサイズの意味と、なぜ非witnessの区別にこだわるのでしょうか？"

  a2="segwitのアップグレードの一環として、マークルルートの計算からwitnessのデータが除外されるため、
  非witnessとの区別を気にします。この攻撃では、悪意あるトランザクションがマークルルートの構築のため64バイトである必要があるため（
  これにより内部ノードのように見える）、witnessデータを除外する必要があります。"

  a2link="https://bitcoincore.reviews/26265#l-62"

  q3="<!--why-does-setting-this-policy-help-to-prevent-the-attack-->このポリシーを設定すると、なぜ攻撃を防ぐことができるのですか？"

  a3="内部のマークルツリーノードは、正確に64バイトなので、
  異なるサイズのトランザクションを内部マークルノードと誤認させることはできません。"

  a3link="https://bitcoincore.reviews/26265#l-84"

  q4="<!--does-it-eliminate-the-attack-vector-entirely-->攻撃ベクトルを完全に排除していますか？"

  a4="標準ルールの変更は、64バイトのトランザクションをmempoolに受け入れたりリレーするのを防ぐだけです。
  しかし、そのようなトランザクションはまだコンセンサス上は有効であり、ブロックにマイニングできます。
  このため、攻撃はまだ可能ですが、マイナーの協力がなければなりません。"

  a4link="https://bitcoincore.reviews/26265#l-84"

  q5="<!--why-might-we-want-to-change-the-minimum-transaction-size-to-65-bytes-apart-from-the-fact-that-it-s-unnecessary-to-obfuscate-the-cve-->CVEを難読化する必要がないという事実を除けば、なぜ最小トランザクションサイズを65バイトにしたいのでしょうか？"

  a5="82バイト未満のトランザクションには正当なユースケースがあります。
  言及された一例は、親のアウトプット全体を手数料に割り当てる[CPFP(Child Pays For Parent)][topic cpfp]トランザクションです
  （そのようなトランザクションは単一のインプットと空の`OP_RETURN`アウトプットを持つでしょう）。"

  a5link="https://bitcoincore.reviews/26265#l-100"

  q6="<!--between-disallowing-sizes-less-than-65-bytes-and-sizes-equal-to-64-bytes-which-approach-do-you-think-is-better-and-why-what-are-the-implications-of-both-approaches-->65バイト未満のサイズを禁止するのと、64バイトのサイズを禁止するのとでは、
  どちらのアプローチがより良いと思いますか？また、その理由は何ですか？
  どちらのアプローチもどのような意味を持ちますか？"

  a6="バイトカウントの議論の後、有効だが非標準のトランザクションは60バイトまで小さくできることが合意されました。
  単一のネイティブsegwitインプットを持つ素の（非witness）は、
  41B + 10Bのヘッダー + 8Bの値 + 1Bの`OP_TRUE`もしくは`OP_RETURN` = 60B"

  a6link="https://bitcoincore.reviews/26265#l-124"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Rust Bitcoin 0.28.2][]は、特定のトランザクションやブロックがデシリアライズに失敗する可能性があるバグの修正が含まれています。
  そのような既知のトランザクションは、どのパブリックブロックチェーンにも存在しません。

- [Bitcoin Core 24.0 RC3][]は、ネットワークで最も広く使われているフルノード実装の次期バージョンのリリース候補です。
  [テストのガイド][bcc testing]が利用できるようになっています。

  **警告:** このリリース候補には、`mempoolfullrbf`設定オプションが含まれており、
  このニュースレターおよび以前のニュースレター[#222][news222 rbf]と[#223][news223 rbf]で説明したように、
  一部のプロトコルおよびアプリケーション開発者は、マーチャントサービスに対して問題を引き起こす可能性があると考えています。
  また、[ニュースレター #224][news224 rbf]に掲載しているように、トランザクションリレーにも問題が発生する可能性があります。
  Optechは、影響を受ける可能性のあるサービスに対して、RCを評価し、公開討論に参加することを推奨しています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #26419][]は、トランザクションがmempoolから削除された理由を詳述する
  検証インターフェースログにコンテキストを追加しました。

- [Eclair #2404][]は、SCID（Short Channel IDentifier）エイリアスと
  [ゼロ承認チャネル][topic zero-conf channels]のサポートを、
  [アンカーアウトプット][topic anchor outputs]を使用しないチャネルステートコミットメントに対しても追加しました。

- [Eclair #2468][]は、[BOLTs #1032][]を実装し、
  支払いの最終受信者（[HTLC][topic HTLC]）が、要求したよりも大きな金額と、
  要求したよりも長い有効期限の時間を受け入れることができるようになりました。
  これまでは、Eclairベースの受信者は、[BOLT4][]の要件である金額と有効期限の差分が、
  要求した値と正確に等しいことを遵守していましたが、その正確さは、
  転送ノードがどちらかの値をほんの少し変更することで、次のホップを調査し、
  それが最終受信者であるかどうかを確認することを意味しました。

- [Eclair #2469][]は、最後の転送ノードが支払いを決済するために次のホップ与えるよう依頼する時間を延長しています。
  最後の転送ノードは、自分が最後の転送ノードであることを知るべきではなく、
  次のホップが支払いの受取人であることを知るべきではありません。
  追加の決済時間は、次のホップが受取人ではなく、ルーティングノードである可能性を示唆します。
  この機能に関するPRの説明では、Core LightningとLDKは既にこの動作を実装していると述べています。
  上記のEclair #2468の説明も参照ください。

- [Eclair #2362][]は、[BOLTs #999][]のチャネルアップデート用の`dont_forward`フラグのサポートを追加しました。
  チャネルアップデートは、チャネルのパラメーターを変更し、
  ネットワーク上の他のノードにチャネルの使用方法を知らせるためにたびたびゴシップされますが、
  チャネルアップデートにこのフラグが含まれている場合、他のノードに転送されないようにする必要があります。

- [Eclair #2441][]は、Eclairが任意のサイズのオニオンラップされたエラーメッセージを受け取れるようになりました。
  [BOLT2][]は現在、256バイトのエラーを推奨していますが、それ以上のエラーメッセージを禁止しておらず、
  [BOLTs #1021][]は、LNの最新のTLV（Type-Length-Value）セマンティクスを使用してエンコードされた
  1024バイトのエラーメッセージの使用を推奨するために公開されています。

- [LND #7100][]は、LNDを（ライブラリとして）最新版のBTCDに更新し、
  上記のニュースセクションに掲載したブロックのパースバグを修正しました。

- [LDK #1761][]は、支払いを送信するメソッドに`PaymentID`パラメーターを追加し、
  呼び出し元が複数の同一の支払いを送信するのを防ぐために使用できるようにしました。
  さらにLDKは、以前のように数ブロック失敗を繰り返すと再試行を停止するのではなく、
  無期限に支払いの再試行を続けることができます。`abandon_payment`メソッドは、
  再試行を防ぐために使用されるかもしれません。

- [LDK #1743][]は、チャネルが使用可能になった際に、新しい`ChannelReady`イベントを提供します。
  注目すべきは、このイベントはチャネルが適切な数の承認を受けた後に発行されるか、
  [ゼロ承認チャネル][topic zero-conf channels]の場合はすぐに発行されることです。

- [BTCPay Server #4157][]は、チェックアウトインターフェースの新バージョンにオプトインのサポートを追加しました。
  PRのスクリーンショットとビデオプレビューをご覧ください。

- [BOLTs #1032][]は、支払いの最終的な受信者（[HTLC][topic HTLC]）が、
  要求したよりも大きな金額と、要求したよりも長い有効期限の受け入れを可能にします。
  これにより、転送ノードが支払いのパラメーターをわずかに調整することで、
  次のホップが受信者であると判断することがより困難になります。
  詳しくは、上記のEclair #2468の説明を参照ください。

{% include references.md %}
{% include linkers/issues.md v=2 issues="26438,26419,5674,2404,2468,2469,2362,2441,7100,1761,1743,4157,1032,1021,999,26398,11423" %}
[bitcoin core 24.0 rc3]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[rust bitcoin 0.28.2]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/0.28.2
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[news222 rbf]: /ja/newsletters/2022/10/19/#transaction-replacement-option
[news223 rbf]: /ja/newsletters/2022/10/26/#rbf
[news224 rbf]: /ja/newsletters/2022/11/02/#mempool
[daftuar rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021135.html
[riard funny games]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-May/003033.html
[news220 v3tx]: /ja/newsletters/2022/10/05/#ln
[news222 bug]: /ja/newsletters/2022/10/19/#btcd-lnd
[liquid and rust bitcoin vulns]: https://twitter.com/Liquid_BTC/status/1587499305664913413
[spoof payment attack]: /en/topics/cve/#CVE-2017-12842
[towns find]: https://twitter.com/roasbeef/status/1587481219981508608
[review club 26265]: https://bitcoincore.reviews/26265
[news222 min relay size]: /ja/newsletters/2022/10/19/#minimum-relayable-transaction-size
[26438 close]: https://github.com/bitcoin/bitcoin/pull/26438#issuecomment-1307715677
