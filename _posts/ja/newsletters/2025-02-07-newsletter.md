---
title: 'Bitcoin Optech Newsletter #340'
permalink: /ja/newsletters/2025/02/07/
name: 2025-02-07-newsletter-ja
slug: 2025-02-07-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LDKに影響する脆弱性の修正の発表と、
LNのチャネルアナウンスのゼロ知識ゴシップに関する議論、
最適なクラスターリニアライゼーションの検出に適用できる先行研究の発見、
トランザクションリレーの帯域幅を削減するためのErlayプロトコルの開発に関する最新情報、
LNのエフェメラルアンカーを実装するためのさまざまなスクリプトのトレードオフの検討、
コンセンサスの変更を必要とせずプライバシーを保護する形で`OP_RAND` opcodeをエミュレートするための提案、
最小トランザクション手数料率の引き下げに関する新たな議論を掲載しています。

## ニュース

- **LDKにおけるチャネル強制閉鎖の脆弱性:** Matt Morehouseは、
  彼が[責任を持って開示し][topic responsible disclosures]、LDKバージョン0.1.1で修正された
  LDKに影響する脆弱性についてDelving Bitcoinに[投稿しました][morehouse forceclose]。
  Morehouseが最近開示したLDKの別の脆弱性（[ニュースレター #339][news339 ldkvuln]参照）と同様に、
  LDKのコード内のループは、問題を処理した最初の時点で終了し、
  同じ問題がさらに発生している場合に処理できなくなっていました。
  今回の場合、LDKは保留中の[HTLC][topic htlc]をチャネルで決済できず、
  最終的に誠実な取引相手がチャネルを強制的に閉じてHTLCをオンチェーンで決済することになります。

  これは、直接の盗難にはつながらないかもしれませんが、被害者が閉鎖されたチャネルの手数料を支払い、
  新しいチャネルを開くために手数料を支払い、被害者が転送手数料を稼ぐ能力を低下させる可能性があります。

  Morehouseの優れた投稿では、さらに詳細が説明されており、同じ根本原因による将来のバグを回避する方法を示しています。

- **LNのチャネルアナウンスのゼロ知識ゴシップ:** Johan Halsethは、
  提案中の[チャネルアナウンス][topic channel announcements]プロトコル1.75の拡張機能を
  Delving Bitcoinに[投稿しました][halseth zkgoss]。この拡張機能により、
  他のノードはチャネルがファンディングトランザクションによって裏付けされていることを検証でき、
  複数の安価なDoS攻撃を防止できますが、どのUTXOがファンディングトランザクションなのかを明かす必要がないため、
  プライバシーを強化することができます。Halsethの拡張機能は、[utreexo][topic utreexo]と
  ゼロ知識（ZK）証明システムを使用する彼の以前の研究（[ニュースレター #321][news321 zkgoss]参照）に基づいています。
  これは、[MuSig2][topic musig]ベースの[Simple Taproot Channel][topic simple taproot channels]に適用されます。

  議論は、Halsethのアイディアと非プライベートなゴシップの継続使用、
  ZK証明を生成するための代替方法のトレードオフに焦点が当てられました。
  懸念事項には、すべてのLNノードが証明を迅速に検証できること、
  すべてのLNノードが証明システムと検証システムを実装する必要があるため、その複雑さなどが挙がっていました。

  この記事の執筆時点では、議論は継続中でした。

- **<!--discovery-of-previous-research-for-finding-optimal-cluster-linearization-->最適なクラスターリニアライゼーションを見つけるための先行研究の発見:**
  Stefan Richterは、1989の研究論文をDelving Bitcoinに[投稿しました][richter cluster]。
  彼が見つけたこの論文には、ブロックに格納された場合に、
  トポロジー的に有効なトランザクショングループの最高手数料率のサブセットを、
  効率的に見つけるために使用できる実証済みのアルゴリズムがあります。
  彼はまた、同様の問題に対する複数の[C++の実装][mincut impl]も発見しました。
  これらのアルゴリズムは、「実際にはさらに高速になるはず」です。

  [クラスターmempool][topic cluster mempool]に関するこれまでの研究は、
  異なるリニアライゼーションを簡単かつ高速に比較し、最適なものを使用できるようにすることに重点が置かれていました。
  これにより、高速なアルゴリズムを使用してクラスターを即座にリニアライズし、
  より低速だがより最適なアルゴリズムを余剰CPUサイクルで実行できるようになります。
  しかし、最大比率のクロージャー問題に対する1989年のアルゴリズム、
  あるいはその問題に対する別のアルゴリズムが十分高速に実行できるのであれば、
  代わりにそれを常に使用することも可能です。しかしそれが中程度に低速であっても、
  余剰CPUサイクルで実行するアルゴリズムとして使用できます。

  Pieter Wuilleは、興奮気味に[応え][wuille cluster]、質問を続けました。
  彼はまた、Bitcoin Research WeekでのDongning GuoとAviv Zoharとの議論を基に、
  クラスターmempoolワーキンググループが開発している新しいクラスターリニアライゼーションアルゴリズムについても
  [説明しました][wuille sp cl]。
  このアルゴリズムは、問題を[線型計画法][linear programming]を使って対処できる問題に変換するもので、
  高速で実装するのが簡単で、（終了する場合）最適なリニアライゼーションを生成します。
  しかし、それが（合理的な時間で）終了することを証明する必要があります。

  Bitcoinとは直接関係ありませんが、RichterがDeepSeek LLM推論を使用して1989年の論文を見つけた方法についての
  [説明][richter deepseek]は興味深いものでした。

  この記事の執筆時点では、議論は継続中で、この問題領域に関する追加の論文が調査されていました。
  Richterは、「私たちの問題、またはむしろ _source-sink-monotone parametric min-cut_
  と呼ばれるその一般化されたソリューションは、マップの簡素化のためのポリゴン集約や、
  コンピュータービジョンにおける他のトピックに応用できるようだ」と書いています。

- **Erlayの最新情報:** Sergi Delgadoは、Bitcoin Coreに[Erlay][topic erlay]を実装するための
  過去1年間の研究についてDelving Bitcoinにいくつか投稿しました。彼は、
  （_fanout_ と呼ばれる）既存のトランザクションリレーがどのように機能するのか、
  そしてErlayがそれをどのように変えようとしているのかについて[説明する][delgado erlay]ところから始めました。
  彼は、すべてのノードがErlayをサポートするネットワークであっても、
  いくつかfanoutが残ると予想されると述べています。これは、
  「受信ノードがアナウンスされているトランザクションを知らない限り、set reconciliationよりも効率的でかなり高速」
  なためです。

  fanoutとreconciliationを組み合わせて使用するには、各メソッドをいつ使用するのか、
  どのピアと使用するのかを選択する必要があるため、彼の研究は、最適な選択をすることに焦点を当てています:

  - [<!--filtering-based-on-transaction-knowledge-->トランザクションの知識に基づくフィルタリング][sd1]では、
    ノードが、ピアが既にトランザクションを持っていることを知っていたとしても、
    そのピアをfanout対象に含める必要があるかどうかを検討しています。
    たとえば、私たちのノードには10個のピアがあり、その内3個のピアはトランザクションを私たちに通知しています。
    トランザクションをさらにfanoutするために3つのピアをランダムに選択する場合、
    10個のピアすべてから選択するべきか、それともトランザクションを通知していない7個のピアからだけ選択するべきでしょうか？
    驚くべきことに、シミュレーション結果は、「選択肢の間に有意差はない」ことを示しています。
    Delgadoはこの驚くべき結果を検討し、すべてのピアから検討する必要がある（つまり、
    フィルタリングはしない）と結論づけています。

  - [fanout候補のピアを選択するタイミング][sd2]は、
    ノードがfanoutトランザクションを受信するピア（残りはErlayのreconciliationを使用）をいつ選択すべきかを検討しています。
    ここでは、2つのオプションが検討されています。ノードが新しいトランザクションを検証して、
    リレー用のキューにいれた直後と、そのトランザクションをリレーするタイミングです（ノードはトランザクションをすぐにはリレーしません。
    ネットワークトポロジーを調べてどのノードがトランザクションを発信したかを推測する（これはプライバシーにとってよくありません）のを困難にするため、
    ランダムに少しだけ待機します）。シミュレーション結果では、
    「有意な違いはない」と示されていますが、「Erlayが部分的にサポートされているネットワークでは、
    結果が異なる場合があります」。

  - [<!--how-many-peers-should-receive-a-fanout-->fanoutを受け取るピアの数][sd3]は、
    fanoutの比率を検討しています。比率が高いほど、トランザクションの伝播は速くなりますが、
    帯域幅の節約は減少します。fanoutの比率のテストに加えて、Delgadoは、
    Erlay採用の目標の1つでもあるアウトバウンドピアの数を増やすこともテストしました。
    シミュレーションでは、現在のErlayのアプローチでは、現在のアウトバウンドピアの制限（8ピア）を使用した場合、
    帯域幅が約35%削減され、アウトバウンドピアを12個にした場合、帯域幅が約45%削減されたことが示されました。
    ただし、トランザクションのレイテンシーは約240%増加しています。投稿では、
    他の多くのトレードオフがグラフ化されています。結果は、現在のパラメーターを選択するのに役立つだけでなく、
    より良いトレードオフを実現できる可能性のある代替fanoutアルゴリズムを評価するのにも役立つと
    Delgadoは指摘しています。

  - [<!--defining-the-fanout-rate-based-on-how-a-transaction-was-received-->トランザクションの受信方法に基づいたfanout比率の定義][sd4]は、
    トランザクションを最初に受信したのがfanoutかreconciliationかによって、
    fanout比率を調整すべきかどうかを検討しています。さらに、調整する必要がある場合、
    どの調整比率を使用すべきか？新しいトランザクションがネットワークを介してリレーされ始めると、
    fanoutはより高速で効率的になりますが、トランザクションが既にほとんどのノードに到達した後では帯域幅が無駄になります。
    ノードが、トランザクションを既に確認した他のノードの数を直接判断する方法はありませんが、
    最初にトランザクションを送信したピアが次のスケジュールされたreconciliationを待つのではなくfanoutを使用した場合、
    トランザクションは伝播の初期段階にある可能性が高くなります。このデータを使用して、
    そのトランザクションのノード自身のfanout比率を適度に増加させ、伝播を高速化できます。
    Delgadoはこのアイディアをシミュレートし、すべてのトランザクションに同じfanout比率を使用するコントロール結果と比較して、
    帯域幅が6.5%増加するだけで伝播時間を18%短縮する修正fanout比率を見つけました。

- **<!--tradeoffs-in-ln-ephemeral-anchor-scripts-->LNのエフェメラルアンカースクリプトのトレードオフ:**
  Bastien Teinturierは、既存の[アンカーアウトプット][topic anchor outputs]の代わりに、
  [TRUC][topic v3 transaction relay]ベースのコミットメントトランザクションのアウトプットの1つとして
  どの[エフェメラルアンカー][topic ephemeral anchors]スクリプトを使用するべきかについて
  Delving Bitcoinで意見を[求めました][teinturier ephanc]。使用するスクリプトによって、
  誰が[CPFP][topic cpfp]によってコミットメントトランザクションを引き上げられるか（およびどんな条件で引き上げることができるか）が決まります。
  彼は4つの選択肢を提示しました:

  - *P2A（pay-to-anchor）スクリプトの使用:* この場合、オンチェーンサイズは最小ですが、
    [トリムされたHTLC][topic trimmed htlc]の金額はすべてマイナーに渡されます（現在行われているのと同じ）

  - *<!--use-a-single-participant-keyed-anchor-->単一参加者による鍵付きアンカーの使用:*
    この場合、チャネルから閉じられた資金を使用できるようになるまで数十ブロック待つことを自ら受け入れた参加者が、
    余剰なトリムされたHTLCを請求できるようになります。チャネルを強制的に閉じたい人は、
    どのみちその時間待たなければなりません。ただし、どちらのチャネル参加者も、
    チャネル資金のすべてを盗まれることなく、第三者に手数料の支払いを委任することはできません。
    あなたと取引相手の両方が余剰金額を請求するために競争する場合、
    いずれにせよその金額はすべてマイナーにわたる可能性が高いでしょう。

  - *<!--use-a-shared-key-anchor-->共有鍵アンカーの使用:* この場合、
    余剰なトリムされたHTLCのリカバリーと委任が可能になりますが、委任された人は誰でも、
    あなたやあなたの取引相手と競争して余剰金額を請求できます。繰り返しますが、
    競争が発生すると、すべての余剰金はマイナーにわたる可能性が高くなります。

  - *<!--use-a-dual-keyed-anchor-->2つの鍵付きアンカーの使用:* この場合、
    各参加者は追加のブロックを待つことなく、余剰なトリムされたHTLCを請求できます。
    ただし、委任はできません。チャネルの2人の当事者は、引き続き互いに競争可能です。

  投稿への返信で、Gregory Sandersは、異なるスキームを異なるタイミングで使用できると[指摘しました][sanders ephanc]。
  たとえば、トリムされるHTLCがない時はP2Aを使用し、それ以外の場合は鍵付きアンカーの１つを使用します。
  トリムされた金額が[ダストの閾値][topic uneconomical outputs]を超えた場合、
  その金額は、アンカーアウトプットではなくLNのコミットメントトランザクションに追加できます。
  さらに、彼は「新たな奇妙さ（取引相手がトリムされた金額を増やし、自らそれを取る誘惑に駆られるかもしれない）」を
  生み出す可能性があることを警告しました。David Hardingは、
  [後の投稿][harding ephanc]でこのテーマについて補足しました。

  Antoine Riardは、マイナーの[トランザクションのPinning][topic transaction pinning]を助長するリスクがあるため、
  P2Aを使用しないよう[警告しました][riard ephanc]（[ニュースレター #339][news339 pincycle]参照）。

  この記事の執筆時点では、議論は継続中でした。

- **OP_RANDのエミュレート:** Oleksandr Kurbatovは、
  2者のどちらも予測できない方法で支払いを行うコントラクトを作成できるようにする対話型のプロトコルについて
  Delving Bitcoinに[投稿しました][kurbatov rand]。これは機能的にはランダムに支払うのと同等です。
  Bitcoinでの _確率的な支払い_ に関する[これまでの研究][dryja pp]では高度なスクリプトが使用されていましたが、
  Kurbatovのアプローチでは、勝者がコントラクトの資金を使用できる特別に構築された公開鍵を使用します。
  これはよりプライベートで、柔軟性が高くなる可能性があります。

  Optechでは、プロトコルを完全に分析することはできませんでしたが、明確な問題は見つかりませんでした。
  このアイディアについてさらに議論されることを期待しています。確率的な支払いには複数の用途があり、
  これには[トリムされたHTLC][topic trimmed htlc]など、
  通常は[経済的ではない][topic uneconomical outputs]金額をユーザーがオンチェーンで送信できるようにすることなどが含まれます。

- **<!--discussion-about-lowering-the-minimum-transaction-relay-feerate-->最小トランザクションリレー手数料率の引き下げに関する議論:**
  Greg Tonoskiは、[デフォルトの最小トランザクションリレー手数料率][topic default minimum transaction relay feerates]の引き下げについて
  Bitcoin-Devメーリングリストに[投稿しました][tonoski minrelay]。このトピックは、
  2018年から繰り返し議論され（Optechで要約されています）、最近では2022年に議論されました（[ニュースレター #212][news212 relay]参照）。
  注目すべきは、最近開示された脆弱性（[ニュースレター #324][news324 largeinv]参照）により、
  過去に設定を下げたユーザーやマイナーに影響を与える可能性のある潜在的な問題が明らかになったことです。
  Optechは、さらに重要な議論がある場合は更新情報を提供します。

## コンセンサスの変更

_Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめた月次セクション_

- **<!--updates-to-cleanup-soft-fork-proposal-->クリーンアップソフトフォーク提案の更新:**
  Antoine Poinsotは、[コンセンサスクリーンアップソフトフォーク][topic consensus cleanup]に関するスレッドに
  パラメーターの変更の提案をいくつか投稿しました:

  - [レガシーインプットsigops制限の導入][ap1]: プライベートスレッドで、
    Poinsotと他の何人かのコントリビューターは、（segwit以前の）レガシートランザクションの検証における
    既知の問題を使用して検証に長い時間がかかるregtest用のブロックの作成を試みました。
    調査の結果、彼は「2019年に[最初に提案された緩和策][ccbip]（[ニュースレター #36][news36 cc]参照
    ）の下でワーストブロックを有効なものに適応させる」ことができることを発見しました。
    これにより、彼は別の緩和策を提案しました。レガシートランザクションの署名操作（sigops）の最大数を2,500に制限します。
    `OP_CHECKSIG`の実行ごとに1 sigopsとしてカウントされ、
    `OP_CHECKMULTISIG`の実行ごとに最大20 sigops（使用される公開鍵の数によって変わります）としてカウントされます。
    彼の分析によると、これにより最悪の場合の検証時間が97.5%短縮されます。

    この種の変更の場合と同様に、新しいルールによって以前署名されたトランザクションが無効になるため、
    [誤って没収される][topic accidental confiscation]リスクがあります。
    2,500を超えるシングルシグの操作、
    または2,125個の鍵を超えるマルチシグ操作[^2kmultisig]を含むトランザクション必要とする人を知っている場合は、
    Poinsotまたは他のプロトコル開発者に通知してください。

  - [<!--increase-timewarp-grace-period-to-2-hours-->タイムワープの猶予期間を2時間に延長][ap2]:
    これまで、クリーンアップ提案では、新しい難易度期間の最初のブロックのブロックヘッターの時間は
    前のブロックの時間より600秒以上前になることを許可されていませんでした。
    つまり、一定量のハッシュレートでは、[タイムワープ][topic time warp]脆弱性を利用して
    10分に1回より速くブロックを生成できませんでした。

    Poinsotは、現在、7,200秒（2時間）の猶予期間の使用を受け入れています。これは、
    Sjors Provoostが当初提案したように、マイナーが誤って無効なブロックを生成する可能性がはるかに低いためです。
    ただし、ネットワークのハッシュレートの50%以上を制御する忍耐強い攻撃者が、
    実際のハッシュレートが一定または増加している場合でも、
    数ヶ月にわたってタイムワープ攻撃を使用して難易度を下げることができます。
    これは公に確認できる攻撃で、ネットワークは対応に数ヶ月かかるでしょう。
    Poinsotは以前の議論を要約し（より簡単な詳細の要約は[ニュースレター #335][news335 cc]参照）、
    「猶予期間の延長に賛成する論拠はかなり弱いが、そうすることのコストは（安全側に回ることを）禁止するものではない」と
    結論づけています。

    猶予期間の延長について議論するスレッドで、開発者のZawyとPieter Wuilleは、
    難易度をゆっくりと最小値まで下げることができるように見える600秒の猶予期間が、
    実際には1回以上の小さな難易度低下を防ぐのに十分であったことを[議論しました][wuille erlang]。
    具体的には、Bitcoinの難易度調整バグ（off-by-one）と[アーラン][erlang]分布の非対称性が
    難易度の正確な再ターゲットに与える影響について調査しました。
    Zawyは「アーランと「2015 hole」の両方の調整が必要ないということではありません。
    前のブロックの600秒前が600秒の嘘ではなく、その600秒後のタイムスタンプを期待したため1,200秒の嘘になったのです」
    と簡潔に結論づけました。

  - [<!--duplicate-transaction-fix-->重複トランザクションの修正][ap3]:
    [重複トランザクション][topic duplicate transactions]問題に対するコンセンサスソリューションの
    潜在的な悪影響に関するマイナーへのフィードバック要請（[ニュースレター #332][news332 cleanup]参照）を受けて、
    Poinsotはクリーンアップ提案に含める特定のソリューションを選択しました。
    各コインベーストランザクションのタイムロックフィールドに前のブロック高を含めるよう求めます。
    この提案には2つの利点があります。
    スクリプトを解析せずにブロックからコミットされたブロックの高さを[抽出できる][corallo duplocktime]ことと、
    ブロック高のコンパクトなSHA256ベースの証明を[作成できる][harding duplocktime]ことです（最悪の場合でも約700バイトで、
    高度な証明システムがない場合に現在必要となる最悪の場合の1MBの証明よりもはるかに少ない）。

    この変更は一般ユーザーには影響しませんが、
    最終的にはマイナーがコインベーストランザクションを生成するために使用するソフトウェアを更新する必要があります。
    この提案に懸念があるマイナーは、Poinsotまたは他のプロトコル開発者に連絡してください。

  Poinsotはまた、彼の研究と提案の現在の状況に関するハイレベルな更新をBitcoin-Devメーリングリストに[投稿しました][ap4]。

- **Braidpoolをサポートするコベナンツの設計のリクエスト:** Bob McElrathは、
  [コベナンツ][topic covenants]の設計に取り組んでいる開発者に、
  彼らのお気に入りの提案や新しい提案が、効率的な分散型[マイニングプール][topic pooled mining]の作成を
  どのように支援できるかの検討の要請をDelving Bitcoinに[投稿しました][mcelrath braidcov]。
  Braidpoolの現在のプロトタイプの設計では、署名者のフェデレーションが使用され、
  署名者はプールへのハッシュレートの貢献に基づいて[閾値署名][topic threshold signature]のシェアを受け取ります。
  この場合、多数派のマイナー（または多数派を構成する複数のマイナーの共謀）が、
  小規模なマイナーへの支払いを盗むことができます。McElrathは、
  各マイナーが貢献に応じてプールから資金を引き出せるようにするコベナンツの使用を希望しています。
  彼は、投稿で具体的な要件のリストを示しており、不可能性の証明も歓迎しています。

  この記事の執筆時点では、返信はありませんでした。

- **コミットされたmempoolからの決定論的なトランザクションの選択:**
  2024年4月のスレッドが先月、新たな注目を集めました。以前、Bob McElrathは、
  マイナーにmempoolのトランザクションにコミットさせ、その後、
  以前のコミットメントから決定論的に選択されたトランザクションのみをブロックに含めることを許可するという
  [投稿をしました][mcelrath dtx]。彼は2つの用途を考えています:

  - _すべてのマイナーに対するグローバル展開:_
    これにより、マイナーが法律、規制およびリスク管理者のアドバイスに従う必要があることが多い世界で、
    「トランザクションの選択のリスクと責任」が排除されます。

  - _単一のプールに対するローカル展開:_
    グローバルな決定論的アルゴリズムの利点のほとんどを備えていますが、実装にコンセンサスの変更は必要ありません。
    さらに、Braidpoolなどの分散型[マイニングプール][topic pooled mining]のピア間の帯域幅を大幅に節約できます。
    アルゴリズムによって候補ブロックに含めるトランザクションが決定されるため、
    そのブロックで生成されたシェアは、プールピアにトランザクションデータを明示的に提供する必要がありません。

  Anthony Townsは、グローバルなコンセンサスの変更オプションの潜在的な問題をいくつか[説明しました][towns dtx]。
  トランザクションの選択を変更するにはコンセンサスの変更（おそらくハードフォーク）が必要であり、
  非標準トランザクションを作成した人は、マイナーの協力があってもそれをマイニングすることができません。
  過去数年間のコンセンサスの変更を必要とするポリシーの変更には、
  [TRUC][topic v3 transaction relay]、更新された[RBF][topic rbf]ポリシー、
  [エフェメラルアンカー][topic ephemeral anchors]が含まれます。Townsは、
  数百万ドル相当の価値が誤って非標準のスクリプトにスタックされ、
  協力的なマイナーがそれを解除できたという[有名なケース][bitcoin core #26348]をリンクしました。

  残りの議論は、Braidpool用に考案されたローカルアプローチに焦点が当てられました。
  異論はなく、難易度調整アルゴリズムに関するトピック（次の項目を参照）に関する追加の議論では、
  トランザクション選択の決定性によって帯域幅、レイテンシーおよび検証コストが大幅に削減される、
  Bitcoinよりもはるかに高いレートでブロックを作成するプールにとって特に役立つ可能性があることが示されました。

- **DAGブロックチェーン用の高速な難易度調整アルゴリズム:**
  開発者のZawyは、有向非巡回グラフ（DAG）型ブロックチェーンのマイニングの
  [難易度調整アルゴリズム][topic daa]（DAA）についてDelving Bitcoinに[投稿しました][zawy daadag]。
  このアルゴリズムは、Braidpoolのピアのコンセンサス（グローバルなBitcoinのコンセンサスではなく）で使用するために設計されましたが、
  議論ではグローバルコンセンサスの側面に繰り返し触れました。

  Bitcoinのブロックチェーンでは、各ブロックは1つの親にコミットします。
  複数の子ブロックが同じ親にコミットする場合がありますが、
  ノードによって _ベストブロックチェーン_ 上で有効とみなされるのはそのうちの1つだけです。
  DAGブロックチェーンでは、各ブロックは1つ以上の親にコミットし、
  親にコミットする子ブロックは0個以上である場合があります。DAGのベストブロックチェーンでは、
  同じ世代の複数のブロックが有効とみなされる場合があります。

  ![DAGブロックチェーンの図](/img/posts/2025-02-dag-blockchain.dot.png)

  提案されたDAAは、最後に確認された100個の有効なブロック内の親の平均数をターゲットにしています。
  親の平均数が増加すると、アルゴリズムは難易度を上げます。親が少ないと難易度は下がります。
  Zawyによると、平均2つの親をターゲットにすると、最も速いコンセンサスが得られます。
  BitcoinのDAAとは異なり、提案されたDAAでは時間を意識する必要はありません。
  ただし、同じ世代の他のブロックよりも大幅に遅れて到着するブロックをピアは無視する必要があります。
  遅延についてコンセンサスを得ることは不可能であるため、最終的には、
  PoW（proof-of-work）が多いDAGの方がPoWが少ないDAGよりも好まれます。
  DAAの開発者であるBob McElrathは、この問題と可能な緩和策を[分析しました][mcelrath daa-latency]。

  Pieter Wuilleは、この提案はAndrew Millerの[2012年のアイディア][miller stale]に似ていると
  [コメントしました][wuille prior]。Zawyもこれに[同意し][zawy prior]、
  McElrathは引用を加えて論文を更新する[予定です][mcelrath prior]。Sjors Provoostは、
  Bitcoin Coreの現在のアーキテクチャでDAGチェーンを処理する複雑さについて[説明しました][provoost dag]が、
  libbitcoinを使用するのがより簡単で、[utreexo][topic utreexo]を使用すると効率的かもしれないと指摘しました。
  Zawyは、プロトコルを徹底的に[シミュレート][zawy sim]し、プロトコルのさまざまなバリエーションについて、
  追加のシミュレーションを行い、トレードオフの最適な組み合わせを見つけようとしていることを示しました。

  議論のスレッドの最後の投稿は、この概要が書かれる約1ヶ月前のものでしたが、
  ZawyとBraidpoolの開発者は引き続きプロトコルの分析と実装を行っていると思われます。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [BDK Wallet 1.1.0][]は、Bitcoin対応アプリケーションを構築するためのこのライブラリのリリースです。
  デフォルトでトランザクションバージョン2を使用します（相対的ロックタイムのサポートにより
  バージョン2トランザクションを使用する必要がある他のウォレットとBDKのトランザクションが混ざるようにすることで
  プライバシーが向上します。[ニュースレター #337][news337 bdk]参照）。
  また、[コンパクトブロックフィルター][topic compact block filters]のサポートも追加されています（
  [ニュースレター #339][news339 bdk-cpf]参照）。さらに「さまざまななバグ修正と改善」がされています。

- [LND v0.18.5-beta.rc1][]は、この人気のLNノード実装のマイナーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #21590][]は、libsecp256k1の実装を基に、
  32-bitと64-bitの両方のアーキテクチャのサポートを追加し、特定のモジュラスに特化しながら、
  MuHash3072用のsafegcdベースの[モジュラ逆数][modularinversion]アルゴリズム実装します（
  ニュースレター[#131][news131 muhash]および[#136][news136 gcd]参照）。
  ベンチマークの結果では、x86_64で約100倍のパフォーマンス向上が見られ、
  MuHashの計算が5.8msから57μsに短縮され、より効率的な状態の検証が可能になりました。

- [Eclair #2983][]は、再接続時のルーティングテーブルの同期を変更し、
  [チャネルアナウンス][topic channel announcements]をノードのトップピア（共有するチャネルキャパシティによって決定）とのみ同期し、
  ネットワークのオーバーヘッドを削減します。さらに、
  同期ホワイトリスト（ニュースレター[#62][news62 whitelist]参照）のデフォルトの動作が更新されました。
  ホワイトリストに登録されていないピアとの同期を無効にするには、
  ユーザーは`router.sync.peer-limit`を0に設定する必要があります（デフォルト値は5）。

- [Eclair #2968][]は、公開チャネルでの[スプライシング][topic splicing]のサポートを追加します。
  スプライシングトランザクションが承認され、両サイドでロックされると、
  ノードはアナウンスの署名を交換し、`channel_announcement`メッセージをネットワークにブロードキャストします。
  最近、Eclairは、このPRの準備としてサードパーティのスプライシングの追跡を導入しました（ニュースレター[#337][news337 splicing]参照）。
  このPRでは、プライベートチャネルでのルーティングでの`short_channel_id`の使用も禁止され、
  代わりに`scid_alias`が優先され、チャネルのUTXOが明らかにされないようにします。

- [LDK #3556][]は、[HTLC][topic htlc]の有効期限が近すぎる場合は、上流のオンチェーンの請求の承認を待つ前に、
  HTLCを積極的に後方で失敗させることで、HTLCの処理を改善します。これまでは、
  ノードは後方のHTLCの失敗をさらに3ブロック遅らせ、請求に承認時間を与えていました。ただし、
  この遅延により、チャネルが強制的に閉じられるリスクがありました。さらに
  チャネルステートをクリーンアップするために`historical_inbound_htlc_fulfills`フィールドが削除され、
  インバウンドチャネルでの重複HTLC IDによる混乱を排除するために新しく`SentHTLCId`が導入されました。

- [LND #9456][]は、次のリリース（0.21）での削除に備えて、
  `SendToRoute`、`SendToRouteSync`、`SendPayment`、`SendPaymentSync`エンドポイントに
  非推奨の警告を追加します。ユーザーは、新しいv2メソッド`SendToRouteV2`、`SendPaymentV2`、
  `TrackPaymentV2`に移行することをお勧めします。

{% include snippets/recap-ad.md when="2025-02-11 15:30" %}

## Footnotes

[^2kmultisig]:
    P2SHと提案されているインプットのsigopカウントでは、16個以上の公開鍵を持つ`OP_CHECKMULTISIG`は、
    20 sigopsとカウントされるので、誰かが毎回17個の鍵で125回`OP_CHECKMULTISIG`を使用すると、
    2,500 sigopsとカウントされます。

{% include references.md %}
{% include linkers/issues.md v=2 issues="21590,2983,2968,3556,9456,26348" %}
[dryja pp]: https://docs.google.com/presentation/d/1G4xchDGcO37DJ2lPC_XYyZIUkJc2khnLrCaZXgvDN0U/mobilepresent?pli=1#slide=id.g85f425098_0_219
[morehouse forceclose]: https://delvingbitcoin.org/t/disclosure-ldk-duplicate-htlc-force-close-griefing/1410
[news339 ldkvuln]: /ja/newsletters/2025/01/31/#ldk
[halseth zkgoss]: https://delvingbitcoin.org/t/zk-gossip-for-lightning-channel-announcements/1407
[news321 zkgoss]: /ja/newsletters/2024/09/20/#utxo
[richter cluster]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/9
[mincut impl]: https://github.com/jonas-sauer/MonotoneParametricMinCut
[wuille cluster]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/10
[linear programming]: https://ja.wikipedia.org/wiki/線型計画法
[wuille sp cl]: https://delvingbitcoin.org/t/spanning-forest-cluster-linearization/1419
[richter deepseek]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/15
[delgado erlay]: https://delvingbitcoin.org/t/erlay-overview-and-current-approach/1415
[sd1]: https://delvingbitcoin.org/t/erlay-filter-fanout-candidates-based-on-transaction-knowledge/1416
[sd2]: https://delvingbitcoin.org/t/erlay-select-fanout-candidates-at-relay-time-instead-of-at-relay-scheduling-time/1418
[sd3]: https://delvingbitcoin.org/t/erlay-find-acceptable-target-number-of-peers-to-fanout-to/1420
[teinturier ephanc]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412
[sanders ephanc]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/2
[harding ephanc]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/4
[riard ephanc]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/3
[news339 pincycle]: /ja/newsletters/2025/01/31/#replacement-cycling-attacks-with-miner-exploitation
[kurbatov rand]: https://delvingbitcoin.org/t/emulating-op-rand/1409
[tonoski minrelay]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAMHHROxVo_7ZRFy+nq_2YzyeYNO1ijR_r7d89bmBWv4f4wb9=g@mail.gmail.com/
[news324 largeinv]: /ja/newsletters/2024/10/11/#inventory-dos
[news212 relay]: /ja/newsletters/2022/08/10/#lowering-the-default-minimum-transaction-relay-feerate
[ap1]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/64
[ap2]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/66
[mcelrath braidcov]: https://delvingbitcoin.org/t/challenge-covenants-for-braidpool/1370/1
[news332 cleanup]: /ja/newsletters/2024/12/06/#continued-discussion-about-consensus-cleanup-soft-fork-proposal
[harding duplocktime]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/26
[corallo duplocktime]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/25
[ap3]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/65
[mcelrath dtx]: https://delvingbitcoin.org/t/deterministic-tx-selection-for-censorship-resistance/842/
[towns dtx]: https://delvingbitcoin.org/t/deterministic-tx-selection-for-censorship-resistance/842/7
[bp pow]: https://github.com/braidpool/braidpool/blob/6bc7785c7ee61ea1379ae971ecf8ebca1f976332/docs/braid_consensus.md#difficulty-adjustment
[miller stale]: https://bitcointalk.org/index.php?topic=98314.msg1075701#msg1075701
[mcelrath daa-latency]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/12
[zawy prior]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/9
[mcelrath prior]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/8
[zawy sim]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/10
[zawy daadag]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331
[wuille prior]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/6
[provoost dag]: https://delvingbitcoin.org/t/fastest-possible-pow-via-simple-dag/1331/13
[ccbip]: https://github.com/TheBlueMatt/bips/blob/7f9670b643b7c943a0cc6d2197d3eabe661050c2/bip-XXXX.mediawiki#specification
[news36 cc]: /en/newsletters/2019/03/05/#prevent-use-of-op-codeseparator-and-findanddelete-in-legacy-transactions
[news335 cc]: /ja/newsletters/2025/01/03/#consensus-cleanup-timewarp-grace-period
[wuille erlang]: https://delvingbitcoin.org/t/timewarp-attack-600-second-grace-period/1326/28?u=harding
[erlang]: https://ja.wikipedia.org/wiki/アーラン分布
[sd4]: https://delvingbitcoin.org/t/erlay-define-fanout-rate-based-on-the-transaction-reception-method/1422
[news136 gcd]: /ja/newsletters/2021/02/17/#faster-signature-operations
[news337 bdk]: /ja/newsletters/2025/01/17/#bdk-1789
[news339 bdk-cpf]: /ja/newsletters/2025/01/31/#bdk-1614
[bdk wallet 1.1.0]: https://github.com/bitcoindevkit/bdk/releases/tag/wallet-1.1.0
[lnd v0.18.5-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.5-beta.rc1
[ap4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/jiyMlvTX8BnG71f75SqChQZxyhZDQ65kldcugeIDJVJsvK4hadCO3GT46xFc7_cUlWdmOCG0B_WIz0HAO5ZugqYTuX5qxnNLRBn3MopuATI=@protonmail.com/
[modularinversion]: https://ja.wikipedia.org/wiki/モジュラ逆数
[news131 muhash]: /ja/newsletters/2021/01/13/#bitcoin-core-19055
[news62 whitelist]: /en/newsletters/2019/09/04/#eclair-954
[news337 splicing]: /ja/newsletters/2025/01/17/#eclair-2936