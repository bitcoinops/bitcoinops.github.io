---
title: 'Bitcoin Optech Newsletter #261'
permalink: /ja/newsletters/2023/07/26/
name: 2023-07-26-newsletter-ja
slug: 2023-07-26-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LNチャネルの相互クローズに関する通信を簡素化するプロトコルと、
LN開発者の最近のミーティングの要約のノートを掲載しています。また、
Bitcoin Stack Exchangeで人気のある質問と回答、新しいリリースとリリース候補の発表、
人気のBitcoinインフラストラクチャプロジェクトの注目すべき変更など恒例のセクションも含まれています。

## ニュース

- **LNクローズプロトコルの簡素化:** Rusty Russellは、
  2つのLNノードが共有するチャネルを相互クローズするプロセスを簡素化する提案を
  Lightning-Devメーリングリストに[投稿しました][russell closing]。
  新しいクローズプロトコルでは、ノードがピアにチャネルをクローズしたいことを伝え、支払うトランザクション手数料の金額を示します。
  クローズ処理のイニシエーターは手数料全額を負担しますが、通常の相互クローズトランザクションの両方のアウトプットはすぐに使用可能なため、
  通常どちらも[CPFPによる手数料の引き上げ][topic cpfp]が可能です。
  新しいプロトコルは、プライバシーを強化し、オンチェーン手数料コストを低減するLNで開発中のアップグレードの一部である
  [MuSig2][topic musig]ベースの[スクリプトレスマルチシグ][topic multisignature]用の情報交換とも互換性があります。

  この記事の執筆時点では、Russellの提案に関するコメントは、メーリングリストに投稿されていませんでしたが、
  完全な提案と一緒にいくつかの初期コメントが[プルリクエスト][bolts #1096]に投稿されていました。

- **LN Summitノート:** Carla Kirk-Cohenは、
  ニューヨーク市で開催された最近のLN開発者ミーティングでのいくつかの議論の概要をLightning-Devメーリングリストに[投稿しました][kc notes]。
  議論されたトピックには以下が含まれています:

  - *<!--reliable-transaction-confirmation-->信頼性の高いトランザクション承認:*
    [パッケージリレー][topic package relay]や[v3トランザクションリレー][topic v3 transaction relay]、
    [エフェメラルアンカー][topic ephemeral anchors]、[クラスターmempool][topic cluster mempool]および
    トランザクションリレーとマイニングに関連するその他のトピックは、
    LNのオンチェーントランザクションが、[トランザクションのPinning][topic transaction pinning]の脅威や、
    [CPFP][topic cpfp]または[RBF][topic rbf]を使用した手数料の引き上げをする際の手数料の過払いなどなしに、
    より信頼性の高い方法で承認されるようにするための明確な道筋をどのように提供するかという文脈で議論されました。
    ほぼすべてのセカンドレイヤープロトコルに影響を与えるトランザクションリレーポリシーに関心のある読者には、
    現在進行中のいくつかの取り組みについてLN開発者から提供された洞察に満ちたフィードバックのメモを読むことを強くお勧めします。

  - *TaprootとMuSig2チャネル:*
    [P2TR][topic taproot]アウトプットと[MuSig2][topic musig]署名を使用するチャネルの進捗に関する簡単な議論。
    この議論のメモの重要な部分は、簡素化された相互クローズプロトコルに関するもので、
    その議論の結果の1つは、前のニュース項目を参照ください。

  - *<!--updated-channel-announcements-->チャネルアナウンスの更新:* LNゴシッププロトコルは現在、
    2-of-2の`OP_CHECKMULTISIG`スクリプトにコミットするP2WSHアウトプットを使用して資金提供されているチャネルの場合に、
    新しいまたは更新されたチャネルのアナウンスをリレーします。[MuSig2][topic musig]ベースの
    [スクリプトレスマルチシグ][topic multisignature]コミットメントの[P2TR][topic taproot]アウトプットに移行するためには、
    ゴシッププロトコルを更新する必要があります。
    前回のLN開発者の対面ミーティング（[ニュースレター #204][news204 gossip]参照）でも
    議論された[トピック][topic channel announcements]は、
    P2TRアウトプットのサポートを追加するだけの最小限のプロトコルアップデート（v1.5ゴシップと呼ばれる）を行うか、
    どんなタイプのUTXOの有効な署名でもアナウンスに使用することをより広範に許可する
    より一般的なプロトコルアップデート（v2.0と呼ばれる）を行うかということでした。
    どのようなアウトプットでも使用できるようにするということは、
    チャネルのアナウンスに使用されたアウトプットが、実際にチャネルを運用するために使用されるアウトプットである可能性が現在よりも低くなり、
    アウトプットとチャネル資金の間の公開リンクを破壊することになります。

    追加で議論されたのは、金額 _n_ のUTXOが _n_ より大きなキャパシティを持つチャネルをアナウンスすることを許可するかどうかということでした。
    これにより、チャネル参加者は、ファンディングトランザクションの一部を非公開にすることができます。
    たとえば、アリスとボブは互いに2つの別々のチャネルを開くことができ、
    1つのチャネルを使用してチャネルの金額以上のアナウンスを作成し、
    UTXOに関連付けられていない、よりプライベートなもう一方のチャネルを使用して、
    そのチャネルのキャパシティよりも大きいLN支払いを転送できることを明確にしました。
    これにより、LNでゴシップされたことのないアウトプットであっても、
    ネットワーク上のあらゆるアウトプットがLNのチャネルに使用されているという可能性を高めるのに役立ちます。

    ノートには、「任意のスクリプトの使用を許可するが、
    利用可能な金額にはコミットする「v1.75ゴシップ」という妥協案が示されていました。

  - *PTLCと冗長な過払い:* ノートには、主に[署名アダプター][topic adaptor signatures]に関連して、
    プロトコルへの[PTLC][topic ptlc]のサポートが簡単に議論されていました。
    ノートでは、プロトコルの類似部分に影響を与える改善点として、
    [冗長な過払い][topic redundant overpayments]が可能なインボイスと、
    過払いの大部分または全額を返金する機能について、より多くの文章が割かれていました。
    たとえば、アリスが最終的にボブに1 BTCを支払いたい場合。
    アリスは最初に、それぞれ0.1 BTCの20個の[マルチパス支払い][topic multipath payments]をボブに送信します。
    数学（_Boomerang_ と呼ばれる手法を使用、[ニュースレター #86][news86 boomerang]参照）か、
    レイヤー化されたコミットメントと余分な通信ラウンド（_Spear_ と呼ばれる）を使用し、ボブは最大10個分の支払いしか請求できません。
    ボブのノードに到達した他の支払いはすべて拒否されます。
    このアプローチのメリットは、アリスのMPPシャードの最大10個まではボブに届かなくても、遅れることなく支払いができることです。
    デメリットは、余分な複雑さと、（Spearの場合）すべてのシャードがボブに到達する最良のケースよりも処理が遅くなる可能性があることです。
    参加者は、冗長な過払いをサポートするための変更を、PTLCに必要な変更と同時に行うことができるかどうかについて議論しました。

  - *<!--channel-jamming-mitigation-proposals-->チャネルジャミングの緩和提案:*
    ノートのかなりの部分は、[チャネルジャミング攻撃][topic channel jamming attacks]を緩和する提案についての議論を要約したものでした。
    議論は、既知の単一の解決策（レピュテーションや前払い手数料など）は、
    受け入れがたい欠点を生むことなく、それ自体で問題に満足に対処することはできないという主張から始まりました。
    レピューテーション自体は、レピューテーションのない新しいノードや、自然に失敗するHTLCの割合を考慮する必要があります。
    攻撃者が引き起こす被害が現在よりも少ないとしても、それでもいくらかの被害を引き起こすことができます。
    前払い手数料自体は、攻撃者の意欲をそぐのに十分な金額に設定する必要がありますが、
    それが高すぎると誠実なユーザーの意欲もそぎ、ノードが意図的に支払いを転送しないようにする逆のインセンティブを生む可能性があります。
    代わりに、いくつかの方法を併用することで、最悪の場合のコストを発生させることなく、
    メリットを得られる可能性があると提案されました。

    現時点の理解を考察した後、議論のノートでは、
    [ニュースレター #226][news226 jamming]で掲載されたローカルレピューテーション方式のテストと、
    それに伴う低額の前払い手数料というその後の実装のためのステージ設定に関する詳細に焦点が当てられました。
    ノートによると、参加者はこの提案をテストすることを支持しているようでした。

  - *<!--simplified-commitments-->簡略化コミットメント:*
    参加者は、どちらのピアもいつでも新しいコミットメントトランザクションを提案できるようにするのではなく、
    どちらのピアに次のコミットメントトランザクションの変更を提案する責任があるかを定義する、
    簡略化コミットメントプロトコルのアイディア（[ニュースレター #120][news120 commitments]参照）について議論しました。
    1つのピアに担当させることで、アリスとボブの両方が同時に[HTLC][topic htlc]を追加したい場合のような、
    2つの提案がほぼ同時に送信される場合の複雑さが解消されます。
    ノートで議論された特に複雑なケースは、ピアの1つが他のピアの提案を受け入れなくない場合で、
    現在のプロトコルでは対処するのが複雑になります。簡略化コミットメントアプローチの欠点は、
    次の変更を提案する担当でないピアが、処理を進める前に取引相手にその権限を要求する必要があるため、
    場合によってはレイテンシーが増加する可能性があることです。
    ノートには、この議論に対する明確な解決策は示されていませんでした。

  - *<!--the-specification-process-->仕様プロセス:*
    参加者は、現行のBOLTやBLIP、その他のドキュメント化のアイディアを含め、
    仕様化のプロセスとそれが管理するドキュメントを改善するためのさまざまなアイディアについて議論しました。
    議論は多岐にわたり、ノートからは明確な結論は見られませんでした。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [秘密鍵からBitcoinの公開鍵を手動で（紙の上で）計算するにはどうすればいいですか？]({{bse}}118933)
  Andrew Poelstraは、[codex32][news239 codex32]のような手作業の計算による検証技術の概要を説明した後、
  秘密鍵から公開鍵を手作業で導出する方法について説明しています。このプロセスには、
  プロセスの最適化を行っていたとしても、少なくとも1500時間かかると推定しています。

- [native segwitのバージョンが17個あるのはなぜですか？]({{bse}}118974)
  Murchは、[segwit][topic segwit]が[witness version][bip141 witness program]フィールドに17個の値（0−16）を定義したのは、
  [スクリプト][wiki script]にOP_0〜OP_16の定数opcodeが存在するためだと説明しています。
  これ以上値を増やすと、データ効率の悪い`OP_PUSHDATA` opcodeを使用する必要があると指摘しています。

- [<!--does-0-op-csv-force-the-spending-transaction-to-signal-bip125-replaceability-->`0 OP_CSV`は、支払いトランザクションにBIP125の置換可能性の通知を強制しますか？]({{bse}}115586)
  Murchは、`OP_CHECKSEQUENCEVERIFY` (CSV)[タイムロック][topic timelocks]と
  [RBF][topic rbf]（Replace-by-Fee）の両方が`nSequence`フィールドを使って[強制される]({{bse}}87376)ため、
  `0 OP_CSV`を含むアウトプットは、その支払いトランザクションが[BIP125][]の置換可能性を通知する必要があることを確認する
  [議論][rbf csv discussion]を指摘しています。

- [<!--how-do-route-hints-affect-pathfinding-->ルートヒントは経路探索にどう影響しますか？]({{bse}}118755)
  Christian Deckerは、LNの受信者が送信者にルートピントを提供する2つの理由を説明しています。
  理由の1つは、受信者が[非公開チャネル][topic unannounced channels]を使用していて、
  経路を見つけるためにヒントが必要な場合です。もう1つの理由は、
  支払いを完了するのに十分な残高を持つチャネルのリストを送信者に提供するためで、彼はこの手法をルートブーストと呼んでいます。

- [<!--what-does-it-mean-that-the-security-of-256-bit-ecdsa-and-therefore-bitcoin-keys-is-128-bits-->256-bit ECDSA、つまりBitcoinの鍵の安全性が128 bitとういのはどういう意味ですか？]({{bse}}118928)
  Pieter Wuilleは、公開鍵に対して総当り検索よりも効率的に秘密鍵を導出できるアルゴリズムにより、
  256-bit ECDSAでは128-bitの安全性しか提供てきないことを明らかにしました。
  彼は続けて、[シード][topic bip32]の安全性と比較した個々の鍵の安全性の違いを指摘しました。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [HWI 2.3.0][]は、ソフトウェアウォレットがハードウェア署名デバイスと通信できるようにするこのミドルウェアのリリースです。
  DIY Jadeデバイスのサポートと、MacOS 12.0以降のAppleシリコンハードウェアで`hwi`プログラムを実行するためのバイナリが追加されています。

- [LDK 0.0.116][]は、LN対応ソフトウェアを作成するためのこのライブラリのリリースです。
  これには、[アンカーアウトプット][topic anchor outputs]および、
  [keysend][topic spontaneous payments]による[マルチパスペイメント][topic multipath payments]のサポートが含まれています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core GUI #740][]では、[PSBT][topic psbt]の操作ダイアログが更新され、
  自分のウォレットに支払うアウトプットが「own address」とマークされるようになりました。
  これにより、インポートされたPSBTの結果、特にトランザクションが送信者にお釣りを返す場合の評価が容易になります。

{% include references.md %}
{% include linkers/issues.md v=2 issues="740,1096" %}
[russell closing]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004013.html
[kc notes]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-July/004014.html
[news204 gossip]: /ja/newsletters/2022/06/15/#gossip-network-updates
[news86 boomerang]: /ja/newsletters/2020/02/26/#boomerang
[news226 jamming]: /ja/newsletters/2022/11/16/#paper-about-channel-jamming-attacks
[news120 commitments]: /en/newsletters/2020/10/21/#simplified-htlc-negotiation
[news239 codex32]: /ja/newsletters/2023/02/22/#codex32-bip
[bip141 witness program]: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki#witness-program
[wiki script]: https://en.bitcoin.it/wiki/Script#Constants
[rbf csv discussion]: https://twitter.com/SomsenRuben/status/1683056160373391360
[hwi 2.3.0]: https://github.com/bitcoin-core/HWI/releases/tag/2.3.0
[ldk 0.0.116]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.116
