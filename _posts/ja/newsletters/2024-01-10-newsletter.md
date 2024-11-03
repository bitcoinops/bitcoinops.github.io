---
title: 'Bitcoin Optech Newsletter #284'
permalink: /ja/newsletters/2024/01/10/
name: 2024-01-10-newsletter-ja
slug: 2024-01-10-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LNアンカーとv3トランザクションリレー提案の要素に関する議論と、
LN-Symmetryの研究実装の発表を掲載しています。また、Bitcoin Core PR Review Clubミーティングの概要や、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など恒例のセクションも含まれています。

## ニュース

- **LNアンカーとv3トランザクションリレー提案に関する議論:**
  Antoine PoinsotがDelving Bitcoinに[投稿し][poinsot v3]、
  [v3トランザクションリレーポリシー][topic v3 transaction relay]と[エフェメラルアンカー][topic
  ephemeral anchors]の提案に関する提案が議論されています。このスレッドは、
  Peter Toddがv3リレーポリシーの批評をブログに[投稿した][todd v3]ことがきっかけになっているようです。
  この議論を任意にいくつかのパーツに分割しました:

  - **<!--frequent-use-of-exogenous-fees-may-risk-mining-decentralization-->外部的な手数料の頻繁な使用はマイニングの分散化のリスクになる:**
    Bitcoinプロトコルの理想的なバージョンは、ハッシュレートに比例して各マイナーに報酬を与えます。
    トランザクションで支払われる暗黙の手数料もその特性を維持します。
    総ハッシュレートの10%を持つマイナーは、次のブロックの手数料を獲得する確率が10%で、
    1%ハッシュレート持つマイナーの確率は1%です。トランザクションの外部でマイナーに直接支払われる
    [帯域外手数料][topic out-of-band fees]と呼ばれる手数料は、その性質に反します。
    共同で55%以上のハッシュレートを管理するマイナーに対して支払うシステムは、
    6ブロック以内にトランザクションが承認される可能性が99%あります。
    その結果、ハッシュレート1%以下の小規模なマイナーに支払うようなことはなくなる可能性が高くなります。
    小規模マイナーの報酬が大規模マイナーの報酬に比例して少なくなる場合、マイニングは自然に集中化され、
    どのトランザクションが承認されるか検閲するために侵害する必要があるエンティティの数が減少します。

    [アンカー付きのLN-Penalty][topic anchor outputs] (LN-Anchors)や[DLC][dlc cpfp]、
    [Client-Side Validation][topic client-side validation]などのプロトコルが積極的に使用されているため、
    オンチェーントランザクションの少なくとも一部で手数料を外部的に支払うことができます。
    つまり、コアなトランザクションで支払われる手数料を追加できるということです。
    手数料は1つ以上の独立したUTXOを使用して支払われます。たとえばLN-Anchorsでは、
    コミットメントトランザクションには、[CPFP][topic cpfp]を使用して（子トランザクションは追加のUTXOを使用します）
    手数料の引き上げを行う各参加者のアウトプットが1つ含まれており、
    HTLC-SuccessトランザクションとHTLC-Failureトランザクションは（HTLC-Xトランザクション）
    `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY`を使用して部分的に署名され、
    手数料を支払うための少なくとも1つの追加インプットを含む単一のトランザクションに集約できます（追加のインプットは別のUTXO）。

    [P2TR][topic taproot]と提案されているエフェメラルアンカーを使用するLNの思考実験バージョンにフォーカスし、
    Peter Toddは、これが外部的な手数料に依存しているため、帯域外の手数料への支払いが大幅に奨励されていると主張しています。
    特に、保留中の支払い（[HTLC][topic htlc]）がないチャネルを一方的に閉じると、
    帯域外の手数料を受け入れる大規模なマイナーは、
    CPFPによる手数料の引き上げによって支払われる帯域内の手数料のみを受け入れる小規模なマイナーが
    ブロックに含めることができるよりも、2倍近いトランザクションをブロックに含めることができます。
    大規模なマイナーは、帯域外で支払うユーザーに適度な割引を提供することで、
    これを奨励し利益を得ることができます。Peter Toddは、これを分散化への脅威と呼んでいます。

    この投稿は、プロトコルで外部的な手数料を使用することはある程度容認できることを示唆しているため、
    懸念されるのは、予想される使用頻度と外部的な手数料の使用と帯域外での支払いの相対的なサイズの違いかもしれません。
    言い換えると、オーバーヘッドが100%で頻繁に発生する保留中の支払いがない一方的なチャネルの閉鎖は、
    保留中のHTLCが20件ある潜在的に稀な一方的な閉鎖よりもリスクが高いと考えられる可能性があります。

  - **<!--implications-of-exogenous-fees-on-safety-scalability-and-costs-->安全性、スケーラビリティおよびコストに及ぼす外部的手数料の影響:**
    Peter Toddの投稿では、[LN-Anchors][topic anchor outputs]などの既存の設計や、
    [エフェメラルアンカー][topic ephemeral anchors]を使用する将来の設計では、
    各ユーザーが手数料の引き上げに使用するためにウォレットに追加のUTXOを保持する必要があることにも言及しました。
    UTXOの作成にはブロックスペースが必要となるため、理論上はプロトコルの独立ユーザーの最大数が半分以上減少します。
    これは、ユーザーがウォレット残高すべてをLNチャネルに安全に割り当てることができないことも意味し、
    LNのユーザー体験が悪化します。最後に、[CPFPによる手数料の引き上げ][topic cpfp]を使用したり、
    トランザクションに追加のインプットを付加して手数料を外部的に支払うには、
    トランザクションのインプットの値から直接手数料を支払う（内部的手数料）よりも、
    より多くのブロックスペースを使用し、より多くのトランザクション手数料を支払う必要があり、
    他の問題の懸念はなくても理論的には高価になります。

  - **<!--ephemeral-anchors-introduce-a-new-pinning-attack-->エフェメラルアンカーにより新たなPinning攻撃が導入される:**
    [先週のニュースレター][news283 pinning]に掲載したように、Peter Toddは、
    エフェメラルアンカーの使用に対する小規模なPinning攻撃について説明しました。
    保留中の支払い（HTLC）がないコミットメントトランザクションの場合、攻撃者は、
    正直なユーザーが意図した手数料率にするために1.5倍から3.7倍の手数料を支払わなければならない状況を作り出すことができます。
    ただし、正直なユーザーが追加手数料を支払うのに[応じなかった][harding pinning]場合、
    攻撃者は結局正直なユーザーの手数料の一部または全額を支払うことになります。
    保留中の支払いがないコミットメントトランザクションには、タイムロックに依存した緊急性がないことを考えると、
    多くの正直なユーザーは忍耐強く、攻撃者の費用でトランザクションを承認させることを選択するかもしれません。
    この攻撃はHTLCが使用されている場合にも機能しますが、
    正直なユーザーが開放されるコストは低くなりますが、それでも攻撃者が損失を被る可能性があります。

  - **代替案: 事前署名されたインクリメンタルなRBFによる引き上げを用いた内部的手数料の使用:**
    Peter Toddは、異なる手数料率で各コミットメントトランザクションの複数のバージョンに署名する代替アプローチを提案、分析しています。
    たとえば、10 sats/vbyteから始まり、1,000 sats/vbyteまで10%ずつ増加する手数料で、
    LN-Penaltyのコミットメントトランザクションの50個の異なるバージョンに署名することを提案しています。
    保留中の支払い（HTLC）のないコミットメントトランザクションの場合、
    彼の分析では署名時間は約5ミリ秒であることが示されています。
    ただし、コミットメントトランザクションにアタッチされたHTLC毎に、署名の数は50個増加し、
    署名時間は5ミリ秒増加します。Bastien Teinturierは、同様のアプローチについて
    彼が開始した[以前の議論][bolts #1036]をリンクしました。

    このアイディアは状況によっては機能するかもしれませんが、Peter Toddの投稿では、
    事前署名されたインクリメンタルな手数料の引き上げによる内部的手数料は、
    すべての場合において外部的手数料の満足のいく代替ではないと述べられています。
    複数のHTLCを含むコミットメントトランザクションの事前署名に必要な遅延に、
    一般的な支払いパスの数ホップを掛けると、[遅延][harding delays]は容易に1秒以上になり、
    少なくとも理論上は、1分以上の遅延にまでおよぶ可能性があります。
    Peter Toddは、提案されている[SIGHASH_ANYPREVOUT][topic sighash_anyprevout] opcode（APO）が利用可能であれば、
    遅延はほぼ一定時間まで短縮できると指摘しています。

    たとえ遅延が一定の5ミリ秒だっとしても、LNの支払人が最終的に[冗長な過払い][topic redundant overpayments]を行うことが予想される影響により、
    内部的手数料を使用する転送ノードの転送手数料の方が、外部的手数料を使用するノードよりも少なくなる[可能性][harding stuckless]があります。
    ミリ秒単位の差であったとしても、遅い転送よりもより速い転送の方が経済的に有利になります。

    さらなる課題は、署名済みのHTLC-SuccessおよびHTLC-Timeoutトランザクション（HTLC-Xトランザクション）に同じ内部的手数料を使用することです。
    APOを使用した場合でも、これは単純に<i>n<sup>2</sup></i>の署名を作成することを意味しますが、
    Peter Toddは、HTLC-Xトランザクションがコミットメントトランザクションと同様の手数料率を支払うと仮定することで、
    署名の数を減らすことができると述べています。

    <!-- Using our tx-calc, 1-in, 22-out for 20 HTLC is 1014 vbytes;
         BOLT3 "expected weights" gives worst-case HTLC-X weight of 705
         = 176.25 vbytes, times 20 is 3525, plus 1014 is 4539. Multiply
         everything by 1,000 s/vb to get total sats -->

     内部的手数料によって過剰な資本が手数料のために留保されるかどうかについては、未解決の[議論][teinturier fees]がありました。
     たとえば、アリスが10 s/vbから1,000 s/vbまでのバージョンに署名した場合、
     アリス自身はその手数料率を支払わなかったとしても、
     取引相手のボブが1,000 s/vbをオンチェーンに展開する可能性に基づいて判断をする必要があります。
     つまり、ボブが1,000 s/vbバージョンに必要なお金を使用するような場合、
     アリスはその支払いを受け入れることができないことを意味します。
     たとえば、20個のHTLCを持つコミットメントトランザクションでは、
     100万sats（執筆時点で$450 USD）が一時的に使用できなくなります。
     HTLC-Xトランザクションにも内部的手数料が使用された場合、
     20個のHTLCを持つコミットメントトランザクションの一時的に使用できなくなる金額は450万sats（$2,050 USD）近くになります。
     それに比べて、ボブが手数料を外部的に支払うことが期待される場合、
     アリスは安全のためにチャネルキャパシティを減らす必要がありません。

  - **<!--overall-conclusions-->全体的な結論:** この記事の執筆時点では、議論は進行中です。
    Peter Toddは次のように結論づけています。「前述のマイナー分散化のリスクのため、
    アンカーアウトプットの既存の使用は段階的に廃止されるべきです。
    新しいアンカーアウトプットのサポートを新しいプロトコルやBitcoin Coreに追加すべきではありません。」
    LN開発者のRusty Russellは、帯域外の手数料に関する懸念を最小限に抑えるため、
    新しいプロトコルでより効率的な形式の外部的な手数料を使用することについて[投稿しました][russell inline]。
    Delving Bitcoinのスレッドでは、LN、v3トランザクションおよびエフェメラルアンカーに取り組んでいる他の開発者が
    アンカーの有用性を擁護しており、今後もv3関連のプロトコルに取り組み続ける可能性が高いように見えました。
    大きな変更があった場合は、今後のニュースレターで最新情報を提供します。

- **LN-Symmetryの研究実装** Gregory Sandersは、
  Core Lightningのソフトウェアフォークを使用して作成した[LN-Symmetry][topic eltoo]プロトコル（当初 _eltoo_ と呼ばれていた）の
  [概念実証実装][poc lns]についてDelving Bitcoinに[投稿しました][sanders lns]。
  LN-Symmetryは、ペナルティトランザクションを必要とせず、最新のチャネル状態をオンチェーンで公開することを保証する
  双方向のペイメントチャネルを提供します。ただ、子トランザクションが親トランザクションのあらゆるバージョンを使用できるようにする必要があり、
  これは[SIGHASH_ANYPREVOUT][topic sighash_anyprevout]のようなソフトフォークによるプロトコル変更によってのみ可能になります。
  Sandersは、彼の取り組みからいくつかのハイライトを提示しています。

  - *<!--simplicity-->シンプルさ:* LN-Symmetryは、現在使用されている
    LN-Penalty/[LN-Anchors][topic anchor outputs]プロトコルよりもはるかにシンプルなプロトコルです。

  - *Pinning:* 「[Pinning][topic transaction pinning]を回避するのは非常に困難です。」
    Sandersはこの問題に取り組むことで、洞察とインスピレーションを得、
    それが[パッケージリレー][topic package relay]への貢献や、
    広く賞賛される[エフェメラルアンカー][topic ephemeral anchors]の提案につながりました。

  - *CTV:* 「[CTV][topic op_checktemplateverify]（エミュレーションを通じて）[...]
    非常にシンプルなFast Forwardsを可能にします。広く採用されれば、支払い時間を短縮できるでしょう。」

  - *<!--penalties-->ペナルティ:* ペナルティは本当に必要ないようでした。
    これはLN-Symmetryの希望でしたが、悪意ある取引相手による盗難を阻止するには
    ペナルティプロトコルが依然として必要であると考えている人もいます。
    ペナルティのサポートは、プロトコルの複雑さを大幅に増加させ、
    ペナルティを支払うために一部のチャネル資金を確保する必要があるため、
    安全のために必要でない場合はサポートを避けるのが望ましいでしょう。

  - *Expiry delta:* LN-Symmetryでは、予想よりも長いCLTV expiry deltaが必要です。
    アリスがHTLCをボブに転送する際、アリスはボブにプリメージを使用してその資金を請求するための特定のブロック数を与えます。
    その時間が経過したら、アリスは資金を取り戻すことができます。ボブがHTLCをさらにキャロルに転送する場合、
    キャロルがプリイメージを公開しなければならないブロック数を減らします。この2つの有効期限の差分が、
    _CLTV expiry delta_ です。Sandersは、取引相手がコミットメントラウンドの途中でプロトコルを中止した場合に利益を得られないように、
    deltaは十分な長さである必要があることを発見しました。

  Sandersは現在、Bitcoin Coreのmempoolとリレーポリシーの改善に取り組んでおり、
  将来的にLN-Symmetryやその他のプロトコルの導入が容易になります。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Nuke adjusted time (attempt 2)][review club 28956]は、
ブロックのタイムスタンプに関連するブロックの有効性チェックを変更するNiklas GöggeによるPRです。
大まかに言うと、（ヘッダーに含まれる）ブロックのタイムスタンプが過去または未来すぎる場合、
ノードはそのブロックを無効として拒否します。タイムスタンプが未来すぎてブロックが無効である場合、
（チェーンは先に進んでいる可能性があるものの）後に有効になる可能性があることに注意してください。

{% include functions/details-list.md
  q0="ブロックヘッダーにタイムスタンプが必要ですか？必要な場合、それはなぜですか？"
  a0="はい。タイムスタンプは難易度調整とトランザクションのタイムロックの検証に使用されます。"
  a0link="https://bitcoincore.reviews/28956#l-39"

  q1="MTP（Median Time Past）とネットワーク調整時間の違いは何ですか？どちらがPRに関係がありますか？"
  a1="MTPは、直近11ブロックの中央値で、ブロックタイムスタンプの有効性の下限です。
      ネットワーク調整時間は、自ノードの時間に、
      自ノードの時間とランダムに選択した199個のアウトバウンドピアの時間とのオフセットの中央値を加えた値です。
      （この中央値はマイナスになることもあります。）ネットワーク調整時間に2時間加算した値が、
      有効なブロックタイムスタンプの最大値となります。このPRに関係するのは、ネットワーク調整時間です。"
  a1link="https://bitcoincore.reviews/28956#l-67"

  q2="なぜこれらの時間は概念的に大きく異なるのですか？"
  a2="MTPは、同じチェーンに同期しているすべてのノードに対して一意に定義されます。
      時間どおりにコンセンサスが得られます。ネットワーク調整時間はノード間で異なる可能性があります。"
  a2link="https://bitcoincore.reviews/28956#l-74"

  q3="なぜすべてにMTPを使用して、ネットワーク調整時間を廃止しないのですか？"
  a3="MTPはブロックタイムスタンプの有効性の下限として使用されますが、
      将来のブロックタイムスタンプは未知であるため、上限としては使えません。"
  a3link="https://bitcoincore.reviews/28956#l-77"

  q4="ブロックヘッダーのタイムスタンプがノードの内部クロックからどの程度「ずれている」ことが許容されるかについて、
      制限が適用されているのはなぜですか？また、時刻の正確な一致を要求しているわけではないので、
      これらの制限をもっと厳しくすることはできますか？"
  a4="ブロックタイムスタンプの範囲は制限されているため、悪意のあるノードが難易度調整やロックタイムを細工する能力は制限されています。
      この種の攻撃は、タイムワープ攻撃と呼ばれます。有効範囲は、
      ある程度まで厳密にすることができますが、厳密にしすぎると、一部のノードが他のノードが受け入れるブロックを拒否する可能性があるため、
      一時的にチェーンが分岐する可能性があります。ブロックのタイムスタンプは正確である必要はありませんが、
      長期にわたって実際の時間を追跡する必要があります。"
  a4link="https://bitcoincore.reviews/28956#l-82"

  q5="<!--before-this-pr-why-would-an-attacker-try-to-manipulate-a-node-s-network-adjusted-time-->このPRの前、攻撃者はなぜノードのネットワーク調整時間を細工しようとしたのでしょうか？"
  a5="ノードがマイナーの場合、マイニングされたブロックがネットワークによって拒否されたり、
      有効なブロックを受け入れないようにして、古い先端でハッシュレートを浪費し続けます（どちらも競合するマイナーにとって利点です）。
      攻撃されたノードを間違ったチェーンをたどるよう仕向けたり、
      タイムロックされたトランザクションがマイニングされるべき時にマイニングされないようにしたり、
      ライトニングネットワークに対して[時間拡張攻撃][time dilation attack]を実行します。"
  a5link="https://bitcoincore.reviews/28956#l-89"

  q6="<!--prior-to-this-pr-how-could-an-attacker-try-to-manipulate-a-node-s-network-adjusted-time-which-network-message-s-would-they-use-->このPR以前は、攻撃者はどのようにしてノードのネットワーク調整時間を細工しようとすることができたのでしょうか？
      どのネットワークメッセージを使用していましたか？"
  a6="攻撃者は、管理する複数のピアから細工されたタイムスタンプを持つversionメッセージを送信する必要があります。
      彼らは私たちの彼らのノードへのアウトバウンド接続の50%以上を確立する必要があるでしょう。
      これは難しいことですが、ノードを完全に覆い隠すよりははるかに簡単です。"
  a6link="https://bitcoincore.reviews/28956#l-100"

  q7="<!--this-pr-uses-the-node-s-local-clock-as-the-upper-bound-block-validation-time-rather-than-network-adjusted-time-can-we-be-sure-that-this-reduces-esoteric-attack-surfaces-rather-than-increasing-them-->このPRは、ネットワーク調整時間ではなく、ノードのローカルクロックをブロック検証の上限として使用します。
      これにより難解な攻撃対象が増加するのではなく、むしろ減少すると確信できますか？"
  a7="攻撃者が（たとえばマルウェアやNTP偽装などを使用して）ノードのピアのセットやその内部クロックに影響を与えるのがより容易であるか、
      明確な決着がないまま議論が続きましたが、ほとんどの参加者はPRが改善であることに同意しました。"
  a7link="https://bitcoincore.reviews/28956#l-102"

  q8="<!--does-this-pr-change-consensus-behavior-if-so-is-this-a-soft-fork-a-hard-fork-or-neither-why-->このPRはコンセンサスの動作を変更しますか？もしそうなら、これはソフトフォークですか？ハードフォークですか？
      それともどちらでもありませんか？"
  a8="コンセンサスルールは、ブロックチェーンの外部からのデータ（各ノード自身のクロックなど）を考慮することができないため、
      このPRはコンセンサスの変更とはみなされません。これは単なるネットワークの受け入れポリシーの変更です。
      しかし、それはオプションであるという意味ではありません。
      ブロックのタイムスタンプがどこまで未来にあるかを制限する何らかのポリシールールを持つことは、
      ネットワークのセキュリティにとって[不可欠です][se timestamp accecptance]。"
  a8link="https://bitcoincore.reviews/28956#l-141"

  q9="<!--which-operations-were-relying-on-network-adjusted-time-prior-to-this-pr-->このPR以前に、ネットワーク調整時間に依存していた操作はどれですか？"
  a9="[`TestBlockValidity`][TestBlockValidity function]、
      [`CreateNewBlock`][CreateNewBlock function]（マイナーがブロックテンプレートを構築するのに使用）、
      [`CanDirectFetch`][CanDirectFetch function]（P2Pレイヤーで使用）。
      これらの用途の多様性は、PRがブロックの有効性に影響を与えるだけでなく、
      他の実装にも影響があり、それを検証する必要があることを示しています。"
  a9link="https://bitcoincore.reviews/28956#l-197"
%}

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [LND #8308][]は、BOLT 02による終端の支払いの推奨に従って`min_final_cltv_expiry_delta`を9から18に引き上げます。
  この値は、`min_final_cltv_expiry`パラメーターを指定しない外部インボイスに影響します。
  この変更により、先週のニュースレターで[言及したように][cln hotfix]、
  CLNがデフォルトの18を使用した際にパラメーターを含めることをやめた後で発見された相互運用性の問題が修正されました。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1036,8308" %}
[poinsot v3]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340
[todd v3]: https://petertodd.org/2023/v3-transactions-review
[dlc cpfp]: https://github.com/discreetlogcontracts/dlcspecs/blob/master/Non-Interactive-Protocol.md
[news283 pinning]: /ja/newsletters/2024/01/03/#v3-pinning
[harding pinning]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340/22
[harding delays]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340/6
[harding stuckless]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340/5
[teinturier fees]: https://github.com/bitcoin/bitcoin/pull/28948#issuecomment-1873793179
[russell inline]: https://rusty.ozlabs.org/2024/01/08/txhash-tx-stacking.html
[sanders lns]: https://delvingbitcoin.org/t/ln-symmetry-project-recap/359
[poc lns]: https://github.com/instagibbs/lightning/tree/eltoo_support
[cln hotfix]: /ja/newsletters/2024/01/03/#core-lightning-6957
[review club 28956]: https://bitcoincore.reviews/28956
[time dilation attack]: /en/newsletters/2020/06/10/#time-dilation-attacks-against-ln
[se timestamp accecptance]: https://bitcoin.stackexchange.com/a/121251/97099
[TestBlockValidity function]: https://github.com/bitcoin/bitcoin/blob/063a8b83875997068b3eb506b5f30f2691d18052/src/validation.cpp#L4228
[CreateNewBlock function]: https://github.com/bitcoin/bitcoin/blob/063a8b83875997068b3eb506b5f30f2691d18052/src/node/miner.cpp#L106
[CanDirectFetch function]: https://github.com/bitcoin/bitcoin/blob/063a8b83875997068b3eb506b5f30f2691d18052/src/net_processing.cpp#L1314
