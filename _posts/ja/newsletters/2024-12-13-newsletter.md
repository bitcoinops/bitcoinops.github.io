---
title: 'Bitcoin Optech Newsletter #333'
permalink: /ja/newsletters/2024/12/13/
name: 2024-12-13-newsletter-ja
slug: 2024-12-13-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、さまざまなLN実装の旧バージョンからの窃盗を可能にする脆弱性の説明と、
Wasabiと関連ソフトウェアに影響する非匿名化の脆弱性の発表、LNチャネルの枯渇に関する投稿と議論、
選ばれたコベナンツ提案に関する意見を求める投票のリンク、2種類のインセンティブベースの疑似コベナンツ、
定期的な対面のBitcoin Core開発者ミーティングの要約を掲載しています。
また、Bitcoin Core PR Review Clubミーティングの要約や、
サービスとクライアントソフトウェアの変更のリスト、Bitcoin Stack Exchangeの人気のある質問とその回答、
新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **マイナーの支援でLNチャネルからの窃盗を可能にする脆弱性:**
  David Hardingは、今年初旬に彼が[責任を持って開示した][topic responsible disclosures]脆弱性を
  Delving Bitcoinで[発表しました][harding irrev]。
  Eclair、LDK、LNDの旧バージョンでは、デフォルトの設定で、チャネルを開設した当事者が
  チャネルの金額の最大98%を盗むことができました。Core Lightningは、
  デフォルトではない`--ignore-fee-limits`設定オプションが使用された場合、影響を受けます。
  このオプションはドキュメントには既に危険であることが記載されています。

  発表では、それほど深刻ではないこの脆弱性の2つ亜種についても説明されました。
  上記のすべてのLN実装は、これらの追加リスクを軽減しようとしていますが、
  完全な解決策は、[パッケージリレー][topic package relay]や
  [チャネルアップグレード][topic channel commitment upgrades]および関連プロジェクトでの追加作業を待っています。

  この脆弱性は、LNプロトコルの利点を利用して、古いチャネルステートが、
  手数料の支払い側が最新のステートで制御するよりも多くのオンチェーン手数料をコミットすることがでるところにあります。
  たとえば、マロリーがチャネル残高の99%を保持している状況で、
  彼女は全体の残高の98%を[内部的な][topic fee sourcing]手数料に充てます。
  次に最小限の手数料のみを支払う新しいステートを作成し、チャネル残高の99%をボブに送信します。
  手数料に98%を支払う古いステートを個人的にマイニングすることで、彼女はその手数料を自分で獲得することができます。
  これにより、ボブがオンチェーンで受け取ることができる最大額を、予想される99%から実際の2%に削減することができます。
  マロリーはこの方法で、1ブロックあたり約3,000のチャネル（
  各チャネルは異なる被害者によって制御されている可能性がああります）から同時に盗むことができ、
  チャネルの平均額が約$1,000 USDの場合、ブロック毎に約$300万 USDの盗難が可能になります。

  資金を失う前に攻撃に気付いたユーザーは、マロリーが既に必要なステートを作成していた可能性があるため、
  LNノードをシャットダウンして身を守ることはできなかったでしょう。被害者が最新のステート（
  たとえば、ボブがチャネルの金額の99%を保持している場合）でチャネルを強制的に閉じようとしても、
  マロリーは彼女のチャネルの金額の1%を犠牲にすることで、チャネルの金額の98%を失わせることができます。

  手数料に充てられるチャネル金額の最大値を制限することで、最悪の場合の脆弱性は修正され、
  それほど深刻ではない亜種は部分的に緩和されました。以前のステートの手数料は、
  手数料を支払う側が後のステートで制御する金額よりも高く設定できるため、
  盗難の可能性はまだありますが、金額は制限されています。完全な解決策としては、
  （すべてのステートが同額のコミットメントトランザクション手数料を支払うような）
  手数料の調達を完全に[外部から][topic fee sourcing]にする改善が待たれます。
  これは、BitcoinのP2Pプロトコルにおける[CPFP][topic cpfp]による手数料の引き上げのための
  堅牢なパッケージリレーや、LNのチャネルコミットメントトランザクションのアップグレードに依存します。

- **Wasabiおよび関連ソフトウェアに影響する非匿名化の脆弱性:**
  GingerWalletの開発者が、[CoinJoin][topic coinjoin]コーディネーターが、
  CoinJoin中にユーザーがプライバシーを得るのを防止するのに使用できる方法を[公開しました][drkgry deanon]。
  Bitcoin MagazineのジャーナリストのShinobiに[よると][shinobi deanon]、
  この脆弱性はもともと2021年にYuval Kogmanによって発見され、
  いくつかの他の問題とともにWasabi開発チーム[報告されました][wasabi #5439]。
  Optechは、2022年半ばからKogmanがWasabiの展開バージョンに重大な懸念を抱いていたことを認識していましたが、
  それ以上の調査を怠っていました。この失敗について、KogmanとWasabiユーザーに謝罪します。

- **<!--insights-into-channel-depletion-->チャネルの枯渇に関する洞察:**
  René Pickhardtは、Delving Bitcoinに[投稿し][pickhardt deplete]、
  Christian DeckerとともにOptech Deep Diveに[参加し][dd deplete]て、
  ペイメントチャネルネットワーク（LN）の数学的基礎に関する研究について発表しました。
  彼のDelving Bitcoinの投稿で特に注目されたのは、ネットワーク上の循環パスの一部のチャネルは、
  パスが十分に使用されると最終的に枯渇するという発見でした。チャネルが事実上完全に枯渇すると、
  つまり枯渇した方向に追加の支払いを転送できなくなると、循環パス（サイクル）は壊れます。
  ネットワークグラフの各サイクルが連続的に壊れるにつれ、
  ネットワークはサイクルのない残余グラフ（スパニングツリー）に収束します。
  これは、研究者のGregorio Guidiの[以前の結果][guidi spanning]を再現したものですが、
  Pickhardtは別のアプローチからこの結果に至り、Anastasios Sidiropoulosの未発表の研究でも確認されているようです。

  ![サイクル、枯渇、残余スパニングツリー](/img/posts/2024-12-depletion.png)

  この結果から得られる最も注目すべき洞察は、
  ソースノード（つまり純粋な支払人）とシンクノード（つまり純粋な受取人）が存在しない循環型経済においても、
  広範なチャネルの枯渇が起こるということでしょう。LNが顧客対企業、企業対企業、
  企業対労働者のすべての支払いに使用された場合、それでもスパニングツリーに収束します。

  ノードが自分のチャネルを残余スパニングツリーの一部にしたいと思うかどうかは定かではありません。
  一方で、そのツリーは支払いを転送できるネットワークの最後パーツを表します（ハブ・アンド・スポーク トポロジーに相当）。
  そのため、残余チャネル全体で高い転送手数料を請求できる可能性があります。一方、
  残余チャネルは、他のすべてのチャネルが手数料を徴収して枯渇した後に残るものです。

  転送手数料の高いチャネルは、枯渇する可能性が低いですが（他の条件はすべて同じで）、
  同じサイクル内の他のチャネルの特性が枯渇の可能性に大きく影響するため、
  ノードオペレーターが自分の転送手数料のみを制御して枯渇を防ぐのは困難です。

  また、キャパシティが大きいチャネルはキャパシティが小さいチャネルよりも枯渇する可能性が低くなります。
  これは当然のことのように思えますが、その理由を注意深く考えてみると、
  k>2のマルチパーティ・オフチェーンプロトコルに関する意外な洞察が得られます。
  キャパシティが大きいチャネルは、参加者間でより多くの富の分配をサポートするため、
  同等の支払いをキャパシティの小さいチャネルで行って参加者の残高を使い果たしてしまう場合でも、
  そのチャネルを使用した支払いは実現可能なままです。現在のLNチャネルのように、
  参加者が2人の場合、キャパシティにsatoshiが追加される毎に、富の分配の範囲は1ずつ増えます。
  しかし _k_ 人の参加者間でオフチェーンで資金を移動させることができる
  [チャネルファクトリー][topic channel factories]やその他のマルチパーティ構造では、
  キャパシティにsatoshiが追加される毎に、 _k人の参加者のそれぞれについて_
  富の分配の範囲が1ずつ増加し、実現可能な支払いの数が指数関数的に増加し、枯渇のリスクが減少します。

  アリスがボブとキャロルとチャネルを持ち、彼らもまた互いにチャネルを持つ現在のLNの例（{AB, AC, BC}）を考えてみましょう。
  各チャネルのキャパシティは1 BTCです。この構成では、
  アリスが制御できる（したがって送受信できる）最大額は2 BTCです。
  ボブとキャロルにも同じ制限が適用されます。これらの制限は、
  チャネルファクトリーで3つのチャネルすべてを再現するために合計3 BTCが使用される場合にも適用されます。
  ただし、ファクトリーが稼働状態のままであれば、3者間のオフチェーンのステートの更新によって
  ボブとキャロルのチャネルがゼロになり、アリスが最大3 BTCまで制御できるようになります（
  したがって、アリスは最大3 BTCまで送受信できます）。その後のステートの更新によって、
  ボブとキャロルに対しても同様にでき、最大3 BTCまで送受信できるようになります。
  このようにマルチパーティオフチェーンプロトコルを使用することで、同じ額の資本で、
  枯渇する可能性の低い、より高キャパシティのチャネルに各参加者がアクセスできるようになります。
  Pickhardtが以前にも書いたように（ニュースレター[#309][news309 feasible]および
  [#325][news325 feasible]参照）、枯渇が少なく、実現可能な支払いの範囲が広がることは、
  LNの最大スループットの向上に繋がります。

  Pickhardtは、彼の投稿とOptech Deep Diveの議論の両方で、
  シミュレーション結果の検証に役立つデータ（大規模なLSPなど）を求めています。

- **<!--poll-of-opinions-about-covenant-proposals-->コベナンツの提案に関する意見の投票:**
  /dev/fd0は、選ばれた[コベナンツ][topic covenants]の提案に関する開発者の意見の
  [公開投票][wiki poll]のリンクをBitcoin-Devメーリングリストに[投稿しました][fd0 poll]。
  Yuval Kogmanは、開発者は「[各]提案の技術的なメリット」と「[その]コミュニティの支持に関する雰囲気に基づく意見」
  の両方を評価するよう求められましたが、投票の限られた選択肢では、
  開発者がこの2つの可能な組み合わせをすべて評価することができないと[指摘しました][kogman poll]。
  Jonas Nickは、「技術的評価とコミュニティの支持を分離する」ことを[要求し][nick poll]、
  Anthony Townsは、開発者に各提案について未解決の懸念があるかどうかを単純に尋ねるだけで良いと[提案しました][towns poll]。
  NickとTownsはそれぞれ、開発者たちに自分の意見を裏付ける証拠や論拠へのリンクの提供を推奨しました。

  この議論では、投票の欠陥が強調されましたが、一部の提案に対する支持が他の提案よりも高いことが示されれば、
  コベナンツの研究者が、幅広いコミュニティで検討すべきアイディアの短いリストに収束するのに役立つ可能性があります。

- **<!--incentive-based-pseudo-covenants-->インセンティブに基づく疑似コベナンツ:**
  Jeremy Rubinは、オラクル支援の[コベナンツ][topic covenants]に関して
  彼が執筆した[論文][rubin unfed paper]のリンクをBitcoin-Devメーリングリストに[投稿しました][rubin unfed]。
  このモデルには、 _コベナンツオラクル_ と _整合性オラクル_ という2つのオラクルが含まれます。
  コベナンツオラクルは、資金をFidelity bondに預け、
  プログラムが成功を返した場合にのみトランザクションに署名することに同意します。
  整合性オラクルは、成功を返さないプログラムに対して署名が作成されたことを証明するために
  [アカウンタブルコンピューティング][topic acc]を使用することで、保証金を差し押さえることができます。
  不正が発生した場合、コベナンツオラクルの欺瞞によって資金を失ったユーザーが、
  失った資金を取り戻せる保証はありません。

  Ethan Heilmanは、Fraud Proofを使用して不正な署名を罰することができる異なる構成を
  Bitcoin-Devメーリングリストに独自に[投稿しました][heilman slash]。
  ただし、この場合、資金は差し押さえられるのではなく、破棄されます。
  これにより不正な署名者は罰せられますが、被害者が失った資金を取り戻すことはできません。

- **<!--bitcoin-core-developer-meeting-summaries-->Bitcoin Core開発者ミーティングの要約:** 多くのBitcoin Core開発者が10月に直接集まり、
  そのミーティングの記録がいくつか[公開されました][coredev notes]。
  議論のトピックには、[PayJoinのサポート][adding payjoin support]や、
  相互に通信する[複数のバイナリ][multiple binaries]の作成、
  [マイニングインターフェース][mining interface]と[Stratum v2のサポート][Stratum v2 support]、
  [ベンチマーク][benchmarking]と[フレームグラフ][flamegraphs]の改善、
  [libbitcoinkernelのAPI][API for libbitcoinkernel]、[ブロックストールの防止][block stalling]、
  Core Lightningに触発された[RPCコード][RPC code]の改善、
  [Erlayの開発][development of erlay]の再開、[コベナンツの検討][contemplating covenants]などが含まれていました。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Track and use all potential peers for orphan resolution][review club 31397]は、
[glozow][gh glozow]によるPRで、ノードがオーファンをアナウンスしたピアだけでなく、
すべてのピアに欠落している祖先を要求できるようにすることで、オーファンの解決の信頼性を向上させます。
これは、どのピアがオーファンの解決の候補であるか記憶し、
オーファンの解決要求を行うタイミングをスケジュールする役割を担う`m_orphan_resolution_tracker`を導入することで実現します。
このアプローチは、帯域幅効率が良く、検閲に対して脆弱ではなく、ピア間で負荷分散するように設計されています。

{% include functions/details-list.md
q0="<!--what-is-orphan-resolution-->オーファンの解決とは何ですか？"
a0="あるトランザクションにおいて、支払いに使用しようとしているトランザクションを少なくとも１つ持ってない場合に、
オーファンと呼ばれます。オーファンの解決とは、これらの欠落しているトランザクションを見つけようとするプロセスです。"
a0link="https://bitcoincore.reviews/31397#l-23"

q1="このPR以前は、トランザクションに欠落しているインプットがあることに気付いたら、
オーファン解決のためにどのようなステップを踏みますか？"
a1="ノードがオーファントランザクションを受信すると、そのオーファンを送信した同じピアに親トランザクションを要求します。
他のピアは積極的に照会されませんが、たとえばINVメッセージで通知した場合や、
欠落している同じ親を持つ別のオーファンを送信した場合などは、親を送信することがあります。"
a1link="https://bitcoincore.reviews/31397#l-29"

q2="<!--what-are-the-ways-we-may-fail-to-resolve-an-orphan-with-the-peer-we-request-its-parents-from-what-are-some-reasons-this-may-happen-honest-or-otherwise-->
親を要求したピアとの間でオーファンの解決に失敗する理由は何ですか？
正直かどうかにかかわらず、このようなことが起こる理由にはどんなことがものがありますか？"
a2="正直なピアは単に切断されただけかもしれませんし、自分のmempoolから親を排除したかもしれません。
悪意あるピアは、単に要求に応答しないか、細工された無効なwitnessデータを持つ親を送信し、
期待するtxidを持つものの検証に失敗する可能性があります。"
a2link="https://bitcoincore.reviews/31397#l-49"

q3="攻撃者は現在のオーファン解決の振る舞いを悪用して
ノードが1P1Cパッケージをダウンロードするのをどのように防止することができますか？"
a3="攻撃者は、細工されたオーファントランザクションを一方的にアナウンスできます（前の質問を参照）。
細工されたオーファントランザクションがオーファネージに受け入れられると、
同じtxidを持つ正直なトランザクションは受け入れられなくなります。これによりパッケージがリレーされるのを防止します。
または、攻撃者はオーファントランザクションでノードを溢れさせる可能性があります。
オーファネージのサイズは制限されており、トランザクションはランダムに排除されるため、
ノードが1P1Cパッケージをダウンロードする能力に影響します。"
a3link="https://bitcoincore.reviews/31397#l-64"

q4="<!--what-is-the-pr-s-solution-to-the-problem-in-the-previous-question-->前の質問の問題に対するこのPRの解決策は何ですか？"
a4="オーファンの欠落した親をトランザクションリクエストトラッカーに追加するのではなく、
オーファントランザクションは新しく導入された`m_orphan_resolution_tracker`に追加されます。
このオーファン解決トラッカーは、親トランザクションをさまざまなピアに要求するタイミングをスケジュールし、
それらの要求を通常のトランザクションリクエストトラッカーに追加します。参加者は、
追加の`m_orphan_resolution_tracker`を必要としない代替アプローチを提案し、議論しました。
このアプローチは作成者によってさらに調査される予定です。"
a4link="https://bitcoincore.reviews/31397#l-81"

q5="<!--in-this-pr-which-peers-do-we-identify-as-potential-candidates-for-orphan-resolution-and-why-->
このPRでは、どのピアをオーファン解決の潜在的な候補として特定するのですか？またその理由は？"
a5="オーファントランザクションであることが判明したトランザクションをアナウンスしたすべてのピアが、
オーファン解決の潜在的な候補としてマークされます。"
a5link="https://bitcoincore.reviews/31397#l-127"

q6="<!--what-does-the-node-do-if-a-peer-announces-a-transaction-that-is-currently-a-to-be-resolved-orphan-->
ピアが現在解決が必要なオーファントランザクションをアナウンスした場合、ノードは何をしますか？"
a6="トランザクションをm_txrequestトラッカーに追加する代わりに、ピアがオーファン解決の候補に追加されます。
これは1P1Cパッケージの検閲に関する前の質問で説明したような攻撃を防ぐのに役立ちます。"
a6link="https://bitcoincore.reviews/31397#l-148"

q7="<!--why-might-we-prefer-to-resolve-orphans-with-outbound-peers-over-inbound-peers-->
インバウンドピアよりもアウトバウンドピアでオーファンを解決するのが良いのは何故ですか？"
a7="アウトバウンドピアはノードによって選択されるため、より信頼できるものと見なされます。
アウトバウンドピアが悪意あるものである可能性はありますが、少なくとも
あなたのノードを具体的なターゲットとしている可能性ははるかに低くなります。"
a7link="https://bitcoincore.reviews/31397#l-251"
%}

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **JavaベースのHWIのリリース:**
  [Lark App][larkapp github] は、ハードウェア署名デバイスと対話するためのコマンドラインアプリケーションです。
  Javaプログラミング言語用の[HWI][topic hwi]の移植である[Lark Javaライブラリ][lark github]を使用しています。

- **Bitcoin開発教育ゲームSaving Satoshiの発表:**
  [Saving Satoshi][saving satoshi website]ウェブサイトは、
  Bitcoin開発の初心者向けにインタラクティブな教育演習を提供しています。

- **Neovim Bitcoin Scriptプラグイン:**
  Rust用の[Bitcoin script hints][bsh github] Neovimプラグインは、
  エディター内の各操作に対するBitcoinのスクリプトスタックの状態を表示します。

- **Proton WalletがRBFを追加:**
  Proton Walletユーザーは、[RBF][topic rbf]を使用した[トランザクション][proton blog]の手数料引き上げができるようになりました。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Bitcoin Coreは分岐したチェーンをどのくらいの期間保持しますか？]({{bse}}124973)
  Pieter Wuilleは、プルーニングモードで実行されているBitcoin Coreノードを除き、
  ノードがダウンロードしたブロックは、メインチェーン内のものかどうかに関係なく、
  無期限に保存されると説明しています。

- [<!--what-is-the-point-of-solo-mining-pools-->ソロマイニングプールの意義は何ですか？]({{bse}}124926)
  Murchは、Bitcoinのマイナーが参加者にマイニング報酬を分配しないマイニングプール
  _ソロ・マイニングプール_ を利用する理由について概説しています。

- [script-pathのみを使用する場合、P2WSHではなくP2TRを使用する意味はありますか？]({{bse}}124888)
  Vojtěch Strnadは、P2WSHを使用した場合のコスト削減の可能性を指摘する一方で、
  プライバシー、スクリプトツリーの使用、[PTLC][topic ptlc]の利用可能性などを含む、
  その他の[P2TR][topic taproot]の利点を指摘しています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Core Lightning 24.11][]は、この人気のLN実装の次期メジャーバージョンのリリースです。
  高度な経路選択を使用して支払いを行うための実験的な新しいプラグインが含まれています。
  [オファー][topic offers]への支払いと受け取りはデフォルトで有効になっています。
  また、[スプライシング][topic splicing]に複数の改善が行われ、
  その他の機能やバグ修正もいくつか追加されています。

- [BTCPay Server 2.0.4][]は、このペイメントプロセッサソフトウェアのリリースで、
  複数の新しい機能や改良、バグ修正が含まれています。

- [LND 0.18.4-beta.rc2][]は、この人気のLN実装のマイナーバージョンのリリース候補です。

- [Bitcoin Core 28.1RC1][]は、主流のフルノード実装のメンテナンスバージョンのリリース候補です。

- [BDK 1.0.0-beta.6][]は、`bdk_wallet`の1.0.0リリースに先立ち、
  Bitcoinウォレットやその他のBitcoin対応アプリケーションを構築するための
  このライブラリの最後の計画されたベータテストリリースです。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #31096][]では、`AcceptPackage`関数のロジックを変更し、
  `submitpackage`のチェックを緩和することで、単一のトランザクションのみを含むパッケージを許可しないという、
  `submitpackage` RPCコマンド（[ニュースレター #272][news272 submitpackage]参照）の制限を削除します。
  単一のトランザクションは、[パッケージリレー][topic package relay]の仕様では技術的にパケージとして適格ではありませんが、
  ユーザーがこのコマンドを使用してネットワークポリシーに準拠するトランザクションを送信するのを妨げる理由はありません。

- [Bitcoin Core #31175][]は、ブロックにコインベーストランザクションが含まれているか、
  重複しているかを検証する冗長な事前チェックを`submitblock` RPCコマンドと`bitcoin-chainstate.cpp`から削除します。
  これらのチェックは、既に`ProcessNewBlock`内で行われているためです。この変更により、
  マイニングIPC（[ニュースレター #323][news323 ipc]参照）や`net_processing`などのインターフェース全体の動作が標準化され、
  Bitcoin Coreを[libbitcoinkernel][libbitcoinkernel project] APIプロジェクトに対応させるものです。
  さらに、`submitblock`で送信された重複ブロックは、以前プルーニングされていたとしても、そのデータを保持し、
  ブロックファイルがプルーニング用に選択された際に、`getblockfrompeer`の動作と一致するように、
  最終的に再度プルーニングされます。

- [Bitcoin Core #31112][]は、`CCheckQueue`機能を拡張し、
  マルチスレッドでのスクリプト検証下でのスクリプトエラーのログ記録を改善します。
  これまでは、スレッド間の情報転送が制限されていたため、詳細なエラーレポートは`par=1`
  （シングルスレッドでのスクリプト検証）で実行している場合にのみ利用可能でした。
  さらに、ログ記録にはスクリプトエラーが発生したトランザクションインプットと
  使用されたUTXOの詳細が含まれるようになりました。

- [LDK #3446][]は、[BOLT12][topic offers]インボイスに[トランポリンペイメント][topic
  trampoline payments]フラグを含めるためのサポートを追加します。
  これは、トランポリンルーティングの使用やトランポリンルーティングサービスの提供を完全にサポートするものではありませんが、
  将来の機能のための基礎を築くためのものです。トランポリンペイメントのサポートは、
  LDKが導入を計画している[非同期支払い][topic async payments]の前提条件です。

- [Rust Bitcoin #3682][]は、`hashes`、`io`、`primitives`、`units`
  クレート用の公開APIインターフェースを安定化するためのいくつかのツールを提供します。
  事前生成されたAPIテキストファイル、`cargo check-api`を使用してこれらのテキストファイルを生成するスクリプト、
  APIテキストファイルを簡単にクエリするスクリプト、
  APIコードとそれに対応するテキストファイルを比較して意図しないAPI変更を簡単に検出するCIジョブなどです。
  このPRでは、貢献する開発者に期待されることを概説するためのドキュメントも更新されています。
  これらのクレートのAPIエンドポイントを更新する場合は、テキストファイル生成スクリプトを実行する必要があります。

- [BTCPay Server #5743][]は、マルチシグと監視専用ウォレット用に「保留トランザクション」の概念を導入します。
  これは、即時署名を必要としない[PSBT][topic psbt]です。トランザクションは、
  署名者がオンラインになって署名を提供すると署名を収集し、十分な署名が集まったらブロードキャストされます。
  このPRは、帯域外で署名された際に、トランザクションを自動的に完了とマークし、
  関連するUTXOが他で使用された際に保留中のトランザクションを無効にし、
  手数料率が古くなるのを回避するためにオプションで有効期限を許可します。
  このシステムにより、ペイメントプロセッサは、署名を待っている支払いに対して保留中のトランザクションを作成し、
  支払いが変更されたり署名が収集されない場合は、保留中のトランザクションをキャンセルするか、
  更新されたバージョンに置き換えることができます。この機能はホットウォレットでのみ可能です。
  このシステムを拡張して、保留中のトランザクションが作成された際にメールを送信し、
  署名者にオンラインになるよう警告することができます。

- [BDK #1756][]は、コインベーストランザクションのprevouts（前のトランザクションアウトプット）を照会しないように（存在しないため）、
  `fetch_prev_txout`に例外を追加します。これまでは、この動作により、`bdk_electrum`がクラッシュし、
  同期またはフルスキャンプロセスが失敗していました。

- [BIPs #1535][]は、署名が任意のメッセージに署名しているかどうかを確認できる
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] opcodeの仕様[BIP348][]をマージしました。
  署名、メッセージ、公開鍵をスタックに配置し、署名は公開鍵とメッセージの両方に合致する必要があります。
  これは、数ある[コベナンツ][topic covenants]提案の中の1つです。

- [BOLTs #1180][]は、インボイスリクエストに[BIP353][]の人が読めるBitcoin支払い指示（
  [ニュースレター #290][news290 omdns]参照）をオプションで含められるように[BOLT12][topic offers]を更新します。
  [BLIPs #48][]は、[BOLT12][]への更新を参照するために[BLIP32][]（[ニュースレター #306][news306 blip32]参照）を更新します。

## ハッピーホリデー！

これは、Bitcoin Optechの今年最後の定期ニュースレターとなります。
12月20日（金）には、7回目の年間の振り返り特別号を発行します。
通常の発行は、1月3日（金）から再開します。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31096,31175,31112,3446,3682,5743,1756,1535,1180,48" %}
[core lightning 24.11]: https://github.com/ElementsProject/lightning/releases/tag/v24.11
[lnd 0.18.4-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.4-beta.rc2
[eclair v0.11.0]: https://github.com/ACINQ/eclair/releases/tag/v0.11.0
[ldk v0.0.125]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.125
[bitcoin core 28.1RC1]: https://bitcoincore.org/bin/bitcoin-core-28.1/
[harding irrev]: https://delvingbitcoin.org/t/disclosure-irrevocable-fees-stealing-from-ln-using-revoked-commitment-transactions/1314
[pickhardt deplete]: https://delvingbitcoin.org/t/channel-depletion-ln-topology-cycles-and-rational-behavior-of-nodes/1259/6
[guidi spanning]: https://diyhpl.us/~bryan/irc/bitcoin/bitcoin-dev/linuxfoundation-pipermail/lightning-dev/2019-August/002115.txt
[news309 feasible]: /ja/newsletters/2024/06/28/#ln
[news325 feasible]: /ja/newsletters/2024/10/18/#research-on-fundamental-delivery-limits
[fd0 poll]: https://gnusha.org/pi/bitcoindev/028c0197-5c45-4929-83a9-cfe7c87d17f4n@googlegroups.com/
[wiki poll]: https://en.bitcoin.it/wiki/Covenants_support
[kogman poll]: https://gnusha.org/pi/bitcoindev/CAAQdECALHHysr4PNRGXcFMCk5AjRDYgquUUUvuvwHGoeJDgZJA@mail.gmail.com/
[nick poll]: https://gnusha.org/pi/bitcoindev/941b8c22-0b2c-4734-af87-00f034d79e2e@gmail.com/
[towns poll]: https://gnusha.org/pi/bitcoindev/Z1dPfjDwioa%2FDXzp@erisian.com.au/
[rubin unfed]: https://gnusha.org/pi/bitcoindev/30440182-3d70-48c5-a01d-fad3c1e8048en@googlegroups.com/
[rubin unfed paper]: https://rubin.io/public/pdfs/unfedcovenants.pdf
[heilman slash]: https://gnusha.org/pi/bitcoindev/CAEM=y+V_jUoupVRBPqwzOQaUVNdJj5uJy3LK9JjD7ixuCYEt-A@mail.gmail.com/
[larkapp github]: https://github.com/sparrowwallet/larkapp
[drkgry deanon]: https://github.com/GingerPrivacy/GingerWallet/discussions/116
[shinobi deanon]: https://bitcoinmagazine.com/technical/wabisabi-deanonymization-vulnerability-disclosed
[wasabi #5439]: https://github.com/WalletWasabi/WalletWasabi/issues/5439
[adding payjoin support]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/payjoin
[multiple binaries]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/multiprocess-binaries
[mining interface]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/mining-interface
[stratum v2 support]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/stratumv2
[benchmarking]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/leveldb
[flamegraphs]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/flamegraphs
[api for libbitcoinkernel]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/kernel
[block stalling]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/block-stalling
[rpc code]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/rpc-discussion
[development of erlay]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/erlay
[contemplating covenants]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/covenants
[coredev notes]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10
[dd deplete]: /en/podcast/2024/12/12/
[bdk 1.0.0-beta.6]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.6
[btcpay server 2.0.4]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.0.4
[lark github]: https://github.com/sparrowwallet/lark
[saving satoshi website]: https://savingsatoshi.com/
[bsh github]: https://github.com/taproot-wizards/bitcoin-script-hints.nvim
[proton blog]: https://proton.me/support/speed-up-bitcoin-transactions
[news272 submitpackage]: /ja/newsletters/2023/10/11/#bitcoin-core-27609
[news323 ipc]: /ja/newsletters/2024/10/04/#bitcoin-core-30510
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/24303
[news290 omdns]: /ja/newsletters/2024/02/21/#dns-bitcoin
[news306 blip32]: /ja/newsletters/2024/06/07/#blips-32
[review club 31397]: https://bitcoincore.reviews/31397
[gh glozow]: https://github.com/glozow
