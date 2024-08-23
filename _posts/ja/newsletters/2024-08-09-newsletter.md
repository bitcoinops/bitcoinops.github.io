---
title: 'Bitcoin Optech Newsletter #315'
permalink: /ja/newsletters/2024/08/09/
name: 2024-08-09-newsletter-ja
slug: 2024-08-09-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Dark Skippy高速シード流出攻撃についての発表と、
ブロック保留攻撃と提案された解決策に関する議論、コンパクトブロックの再構築に関する統計、
Pay-to-Anchorアウトプットを持つトランザクションに対する置換サイクル攻撃についての説明、
FROSTによる閾値署名を定義する新しいBIPへの言及、
提案中の2つのソフトフォークを使用しゼロ知識証明を楽観的に検証できるようにするEftraceの改良に関する発表を掲載しています。

## ニュース

- **<!--faster-seed-exfiltration-attack-->より高速なシード流出攻撃:**
  Lloyd FournierとNick FarrowおよびRobin Linusは、
  Bitcoinの署名デバイスから鍵を流出させる改良された方法である[Dark Skippy][]を発表しました。
  この方法は、前もって約15社のハードウェア署名デバイスベンダーに[責任をもって開示されていました][topic responsible disclosures]。
  鍵の流出は、トランザクションの署名コードが、秘密鍵や[BIP32 HDウォレットのシード][topic bip32]といった
  基盤となる鍵マテリアルに関する情報を漏らすような方法で意図的に署名を作成する際に発生します。
  攻撃者がユーザーのシードを入手すると、いつでもユーザーの資金を盗むことができます（攻撃者が迅速に行動すれば、
  流出につながったトランザクションで使用された資金も含む）。

  著者らは、彼らが知る限り、これまで最高の鍵流出攻撃は、BIP32シードを流出させるために数十の署名が必要だったと述べています。
  Dark Skippyを使用すると、2つの署名でシードを流出させることができます。
  2つの署名は2つのインプットを持つ単一のトランザクションに属している可能性があります。
  つまり、ユーザーが最初に資金を使用しようとした瞬間に、ユーザーの資金すべてが危険にさらされる可能性があります。

  鍵の流出は、ソフトウェアウォレットを含む、署名を作成するロジックであればどれでも使用できますが、
  悪意のあるコードを含むソフトウェアウォレットは、
  そのシードをインターネット経由で攻撃者に送信するだけであることが一般的に予想されます。
  流出は主に、インターネットに直接アクセスできないハードウェア署名デバイスのリスクであると考えられています。
  ファームウェアまたはハードウェアロジックのいずかによってロジックが破損したデバイスは、
  デバイスがコンピューターに接続されていない場合でも（たとえば、すべてのデータがNFCやSDカード、
  QRコードを使用して転送される場合など）シードを素早く流出させることができます。

  Bitcoinで[流出耐性のある署名][topic exfiltration-resistant signing]を実行する方法については議論されており（
  Optechニュースレターの[ニュースレター #87][news87 anti-exfil]など）、
  現在私たちが認識している2つのハードウェア署名デバイスに実装されています（[ニュースレター #136][news136 anti-exfil]参照）。
  その導入された方法では、標準的なシングルシグへの署名と比較して、ハードウェア署名デバイスとの余分な通信の往復が必要になりますが、
  ユーザーが、追加の通信の往復を必要とする[スクリプトレスマルチシグ][topic multisignature]などの他の種類の署名に慣れれば、
  そのデメリットは小さくなるかもしれません。別のトレードオフを提供する流出耐性のある署名の代替方法も知られていますが、
  私たちの知る限り、Bitcoinのハードウェア署名デバイスに実装されているものはありません。

  Optechは、多額の資金を保護するためにハードウェア署名デバイスを使用するすべての人に、
  流出耐性のある署名を使用するか、複数の独立したデバイス（たとえばスクリプトや、スクリプトレスマルチシグや閾値署名など）を使用することで、
  破損したハードウェアやファームウェアから保護することを推奨しています。

- **<!--block-withholding-attacks-and-potential-solutions-->ブロック保留攻撃と潜在的な解決策:**
  Anthony Townsは、[ブロック保留攻撃][topic block withholding]、関連する無効シェア攻撃および、
  両方の攻撃に対する潜在的な解決策（[Stratum v2][topic pooled mining]でのクライアントの作業選択の無効化と
  不明瞭なシェア化を含む）についての議論をBitcoin-Devメーリングリストに[投稿しました][towns withholding]。

  プールマイナーは、 _シェア_ と呼ばれる作業単位の送信に対して報酬を得ます。
  シェアはそれぞれ、一定量のPoW（Proof of Work）を含む _候補ブロック_ です。
  これらのシェアの既知の部分にも、候補ブロックが最もPoWの多いブロックチェーンに含めるのに十分なPoWが含まれていることが期待されます。
  たとえば、シェアのPoWの目標値が有効なブロックのPoW目標値の1/1,000である場合、
  プールは平均して、有効ブロックを生成する毎に1,000シェアに支払うことになります。
  古典的なブロック保留攻撃は、プールマイナーが有効なブロックを生成する1,000 分の1のシェアを送信せず、
  有効ブロックではない999のシェアを送信する場合に発生します。
  これによりマイナーは、作業の99.9%に対して報酬を受け取ることができますが、
  プールはそのマイナーから収入を得ることができません。

  Stratum v2には、マイナーが候補ブロックにプールがマイニングを提案するものとは異なるトランザクションセットを含めることができるように、
  プールが有効にできるオプションモードが含まれています。プールマイナーは、
  プールが持っていないトランザクションのマイニングを試みることもできます。
  各シェアには、プールがまだ確認したことのないトランザクションが最大数MB含まれている可能性があり、
  そのすべてが検証に時間がかかるように設計されている可能性があります。
  これにより、プールのインフラが簡単に圧迫され、正直なユーザーからのシェアを受け入れる能力に影響を及ぼす可能性があります。

  プールは、トランザクションの検証をスキップしてシェアのPoWのみを検証することでこの問題を回避することができますが、
  これによりプールマイナーは無効なシェアを送信したことに対して100%の確率で支払いを回収できるため、
  古典的なブロック保留攻撃から支払いを回収できる確率の約99.9%よりも若干悪くなります。

  このため、プールはクライアントによるトランザクションの選択を禁止にするか、
  プールマイナーに永続的な公開ID（政府発行の文書により検証された名前など）の使用を求めて、
  悪質な行為者を追放するインセンティブが生まれます。

  Townsが提案する1つの解決策は、プールが複数のブロックテンプレートを提供し、
  各マイナーが好みのテンプレートを選択できるようにすることです。
  これは、[Ocean Pool][]が使用している既存のシステムと似ています。
  プールが作成したテンプレートに基づいて送信されたシェアは、最小限の帯域幅で迅速に検証できます。
  これにより100%が支払われる無効なシェア攻撃を防ぐことができますが、
  約99.9%の利益をもたらす、ブロック保留攻撃には役立ちません。

  ブロック保留攻撃に対処するために、Townsは概念的に単純なハードフォークによって、
  プールマイナーが特定のシェアに有効なブロックとなるのに十分なPoWがあるかどうかを知ることを阻止し、
  それらを _不明瞭なシェア_ にする方法を説明した、2011年にMeni Rosenfeldが[最初に提案した][rosenfeld pool]アイディアを更新します。
  有効なブロックのPoWとシェアPoWを区別できない攻撃者は、
  攻撃者がシェアによる収入を奪うのと同じ割合でのみ有効なブロックの収入をプールから奪うことができます。
  このアプローチには以下の欠点があります:

  - *SPVで確認可能なハードフォーク:* すべてのハードフォークの提案は、
    すべてのフルノードのアップグレードを要求します。しかし（[BIP103][]のような単純なブロックサイズの増加提案など）多くの提案は、
    SPV（Simplified Payment Validation）を使用する軽量クライアントのアップグレードを必要としません。
    この提案では、ブロックヘッダーのフィールドの解釈方法が変更されるため、
    すべての軽量クライアントもアップグレードが必要になります。Townsは、
    必ずしも軽量クライアントのアップグレードを必要としない代替案を提示していますが、
    そのセキュリティは大幅に低下します。

  - *<!--requires-pool-miners-to-use-a-private-template-from-the-pool-->プールマイナーにプールのプライベートテンプレートの使用を要求:*
    100%無効なシェア攻撃を防ぐためにテンプレートが必要になるだけでなく、
    そのテンプレートを使用して生成されたすべてのシェアが受信されるまで、
    プールはプールマイナーからそのテンプレートを秘密にしておく必要があります。
    プールはこれを利用してマイナーを騙し、マイナーが反対するトランザクションのPoWを生成させることができます。
    しかし、監査を可能にするために、期限切れのテンプレートを公開することはできます。
    最近のプールのほとんどは、数秒ごとに新しいテンプレートを生成するため、
    監査はほぼリアルタイムで実行でき、悪意あるプールが数秒以上マイナーを騙すのを防止できます。

  - *<!--requires-share-submission-->シェアの送信を求める:*
    （特定の動作モードの）Stratum v2の利点の1つは、プールのブロックを見つけた正直なプールマイナーが、
    それをすぐにBitcoin P2Pネットワークにブロードキャストできるため、
    対応するシェアがプールサーバーに到達する前でも伝播を開始できることです。
    不明瞭なシェアの場合、シェアはプールが受け取り、ブロードキャストする前に完全なブロックに変換される必要があります。

  Townsは、最後にブロック保留攻撃を解決する2つの動機について説明しています。
  この攻撃は大規模なプールよりも小規模なプールに影響を与えること、
  匿名マイナーを許可しているプールを攻撃するコストはほとんどかからないこと、
  一方、マイナーの身元確認を義務付けているプールは既知の攻撃者を禁止できることです。
  ブロック保留を解決することで、Bitcoinマイニングがより匿名化され、分散化される可能性があります。

- **<!--statistics-on-compact-block-reconstruction-->コンパクトブロックの再構築に関する統計:**
  開発者の0xB10Cは、[コンパクトブロック][topic compact block relay]の再構築の最近の信頼性について
  Delving Bitcoinに[投稿しました][0xb10c compact]。2016年にBitcoin Core 0.13.0にこの機能が追加されて以来、
  多くのリレーフルノードが[BIP152][]コンパクトブロックリレーを使用しています。
  これにより、未承認トランザクションを共有している2つのピアは、
  新しいブロックでそれらのトランザクションが承認された際に、トランザクション全体を再送信するのではなく、
  それらのトランザクションへの短い参照を使用できます。これにより帯域幅が大幅に削減され、
  レイテンシーも削減されるため、新しいブロックがより迅速に伝播します。

  新しいブロックの伝播が速くなると、偶発的なブロックチェーンのフォークの数が減少します。
  フォークが減ると、無駄になるPoW（Proof of Work）の量が減り、
  小規模なマイニングプールよりも大規模なマイニングプールに有利な _ブロックレース_ の数も減り、
  Bitcoinのセキュリティと分散性が向上します。

  ただし、新しいブロックには、ノードがまだ見たことのないトランザクションが含まれる場合があります。
  その場合、コンパクトブロックを受信するノードは通常、送信ピアにそれらのトランザクションを要求し、
  ピアが応答するのを待つ必要があります。これによりブロックの伝播が遅くなります。
  ノードがブロック内のすべてのトランザクションを取得するまで、そのブロックを検証することも、
  ピアにリレーすることもできません。これにより、偶発的なブロックチェーンのフォーク頻度が増加し、
  PoWセキュリティが低下し、集中化の圧力が高まります。

  そのため、コンパクトブロックが、追加のトランザクションを要求することなく、
  新しいブロックを検証するために必要なすべての情報を提供する頻度を監視することは有用です。
  これを _成功した再構築_ と呼びます。Gregory Maxwellは最近、
  Bitcoin Coreをデフォルト設定で実行しているノードの成功した再構築が減少したことを[報告しました][maxwell reconstruct]。
  特に、`mempoolfullrbf`設定を有効にして実行しているノードと比較した場合です。

  開発者0xB10Cの今週の投稿では、さまざまな設定の独自のノードを使用して観察した
  成功した再構築の数をまとめており、一部のデータは6ヶ月前まで遡ります。
  `mempoolfullrbf`を有効にした場合の効果に関する最近のデータは、約1週間前までしか遡りませんでしたが、
  Maxwellのレポートと一致しています。これはBitcoin Coreの次期バージョンで`mempoolfullrbf`をデフォルトで有効にするための
  [プルリクエスト][bitcoin core #30493]を検討する動機付けとなりました。

- **Pay-to-Anchorに対する置換サイクル攻撃:** Peter Toddは、
  [エフェメラルアンカー][topic ephemeral anchors]の提案の一部であるP2A（Pay-to-Anchor）アウトプットタイプについて
  Bitcoin-Devメーリングリストに[投稿しました][todd cycle]。P2Aは、
  誰でも使用できるトランザクションアウトプットです。これは特にLNなどのマルチパーティプロトコルで
  [CPFP][topic cpfp]による手数料の引き上げに役立ちます。ただし、
  LNでのCFPFによる手数料の引き上げは現在、悪意ある取引相手が2段階のプロセスで実行する
  [置換サイクル攻撃][topic replacement cycling]に対して脆弱です。彼らは、
  まず正直なユーザーのトランザクションを同じトランザクションの取引相手のバージョンに[置き換えます][topic rbf]。
  次に置き換えたトランザクションを、どちらのユーザーのトランザクションのバージョンとも関係のないトランザクションに置き換えます。
  LNチャネルに未解決の[HTLC][topic htlc]がある場合、置換サイクルが成功すると、
  取引相手がそれを正当な参加者から盗むことができます。

  LNの現在の[アンカーアウトプット][topic anchor outputs]チャネルタイプを使用すると、
  取引相手のみが置換サイクルを実行できます。しかし、Toddは、P2Aでは誰でもアウトプットを使用できるため、
  それを使用するトランザクションに対して誰でも置換サイクル攻撃を実行できると指摘しています。
  それでも攻撃から利益を得ることができるのは取引相手だけであるため、
  第三者がP2Aアウトプットを攻撃する直接的なインセンティブはありません。
  攻撃者が自分のトランザクションを正直なユーザーのP2Aを使用した支払いよりも高い手数料率でブロードキャストすることを計画し、
  攻撃者が途中の状態をマイナーに承認されることなく置換サイクルを正常に完了した場合、攻撃は無料になる可能性があります。
  置換サイクル攻撃に対する既存のLNの緩和策（[ニュースレター #274][news274 cycle mitigate]参照）はすべて、
  P2A置換サイクルの阻止に対して同等に効果があります。

- **スクリプトレス閾値署名用のBIPの提案:** Sivaram Dhakshinamoorthyは、
  Bitcoinの[Schnorr署名][topic schnorr signatures]の実装用の[スクリプトレス閾値署名][topic threshold signature]を作成するため、
  [BIPの提案][frost sign bip]をBitcoin-Devメーリングリストに[投稿しました][dhakshinamoorthy frost]。
  これにより、（[ChillDKG][news312 chilldkg]を使用するなどして）セットアップ手順を既に実行している署名者のセットは、
  それらの証明者の動的なサブセットとのやりとりのみを必要とする署名を安全に作成することができます。
  署名は、シングルシグのユーザーやスクリプトレスマルチシグのユーザーによって作成されたSchnorr署名とオンチェーン上で区別がつかず、
  プライバシーとファンジビリティが向上します。

- **CATとMATTおよびElftraceを使用したゼロ知識証明の楽観的検証:**
  Johan T. Halsethは、彼のツール[Elftrace][]がゼロ知識（ZK）証明を検証できるようになったことを
  Delving Bitcoinに[投稿しました][halseth zkelf]。これをオンチェーンで使用するには、
  [OP_CAT][topic op_cat]と[MATT][topic acc]の両方のソフトフォークがアクティベートされる必要があります。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

  [Add PayToAnchor(P2A), OP_1 <0x4e73>, as standard output script for
  spending][review club 30352]は、[instagibbs][gh instagibbs]によるPRで、
  新しい`TxoutType::ANCHOR`アウトプットスクリプトタイプを導入します。
  アンカーアウトプットは（[`bc1pfeessrawgf`][mempool bc1pfeessrawgf]というアドレスになる）
  `OP_1 <0x4e73>`というアウトプットスクリプトを持ちます。これらのアウトプットを標準にすると、
  アンカーアウトプットを使用するトランザクションの作成とリレーが簡単になります。

{% include functions/details-list.md
  q0="このPRで`TxoutType::ANCHOR`が定義される前は、scriptPubKey`OP_1 <0x4e73>`はどの`TxoutType`に分類されていましたか？"
  a0="これは1 byteのプッシュopcode（`OP_1`）と2 byteのデータプッシュ（`0x4e73`）で構成されているため、
  有効なv1 witnessアウトプットです。ただ32 byteではないため、`WITNESS_V1_TAPROOT`の条件は満たさず、
  デフォルトで`TxoutType::WITNESS_UNKNOWN`になります。"
  a0link="https://bitcoincore.reviews/30352#l-18"

  q1="前の質問の回答に基づくと、このアウトプットタイプを作成することは標準的でしょうか？
  それを使用することはどうでしょうか？（ヒント：[`IsStandard`][gh isstandard]と[`AreInputsStandard`][gh
  areinputsstandard]はこのタイプをどのように扱うでしょう？）"
  a1="（アウトプットをチェックするのに使用される）`IsStandard`は、`TxoutType::NONSTANDARD`のみを非標準とみなすため、
  これを作成するのは標準になります。`AreInputsStandard`は、
  `TxoutType::WITNESS_UNKNOWN`を支払いに使用するトランザクションを非標準とみなすため、
  それを使用するトランザクションは標準にはなりません。"
  a1link="https://bitcoincore.reviews/30352#l-24"

  q2="このPRの前のデフォルトの設定では、標準トランザクションでどのアウトプットタイプを作成できますか？
  これは標準トランザクション内でインプットとして使用されるスクリプトタイプと同じですか？"
  a2="`TxoutType::NONSTANDARD`を除くすべての定義済み`TxoutType`を作成できます。
  `TxoutType::NONSTANDARD`と`TxoutType::WITNESS_UNKNOWN`を除くすべての定義済み`TxoutType`が
  支払いに使用できます（ただし、`TxoutType::NULL_DATA`を支払いに使用することはできません）。"
  a2link="https://bitcoincore.reviews/30352#l-42"

  q3="ライトニングネットワークのトランザクションに触れずにアンカーアウトプットを定義してください（より一般的なものに）"
  a3="アンカーアウトプットは、ブロードキャスト時にCPFPを介して手数料を追加できるようにするために、
  事前署名済みのトランザクションで作成される追加のアウトプットです。詳細については、
  [トピックのアンカーアウトプット][topic anchor outputs]をご覧ください。"
  a3link="https://bitcoincore.reviews/30352#l-48"

  q4="アンカーアウトプットのアウトプットスクリプトのサイズが重要なのはなぜですか？"
  a4="アウトプットスクリプトが大きいと、トランザクションのリレーと優先順位付けのコストが高くなります。"
  a4link="https://bitcoincore.reviews/30352#l-66"

  q5="P2Aアウトプットの作成と使用にはどれくらいの仮想byteが必要ですか？"
  a5="P2Aアウトプットの作成に13 vbyte、使用に41 vbyteが必要です。"
  a5link="https://bitcoincore.reviews/30352#l-120"

  q6="3つめのコミットで`IsWitnessStandard`に`if (prevScript.IsPayToAnchor()) return false`を
  [追加][gh 30352 3rd commit]しています。これは何をするもので、なぜ必要なのですか？"
  a6="アンカーアウトプットがwitnessデータなしでのみ使用できることを保証します。
  これにより、攻撃者が正当な支払いトランザクションを取得して、witnessデータを追加し、
  絶対手数料額は高いが手数料率が低い状態でそれを伝播するのを防止します。
  それが防止されないと正直なユーザーはそれを置換するためにさらに高い手数料を支払わざるを得なくなります。"
  a6link="https://bitcoincore.reviews/30352#l-154"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Libsecp256k1 0.5.1][]は、このBitcoin関連の暗号関数ライブラリのマイナーリリースです。
  署名用の事前計算済みテーブルのデフォルトサイズをBitcoin Coreのデフォルトと一致するように変更し、
  （[バージョン2暗号化P2Pトランスポート][topic v2 p2p transport]で使用されるプロトコルである）
  ElligatorSwiftベースの鍵交換のサンプルコードを追加しています。

- [BDK 1.0.0-beta.1][]は、ウォレットやその他のBitcoin対応アプリケーションを構築するための
  このライブラリのリリース候補です。元の`bdk` Rustクレートの名前が`bdk_wallet`に変更され、
  低レイヤーのモジュールは、`bdk_chain`、`bdk_electrum`、`bdk_esplora`、`bdk_bitcoind_rpc`などの
  独自のクレートに抽出されました。`bdk_wallet`クレートは、「安定した 1.0.0 API を提供する最初のバージョンです」。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #30493][]は、[フルRBF][topic rbf]をデフォルトの設定として有効にし、
  ノードオペレーターがオプトインRBFに戻すオプションを残しています。フルRBFでは、
  [BIP125][bip125 github]の通知に関係なく、未承認のトランザクションを置き換えることができます。
  これは、2022年7月からBitcoin Coreのオプションになっています（ニュースレター[#208][news208 fullrbf]参照）が、
  これまではデフォルトで無効になっていました。フルRBFをデフォルトにすることに関する議論については、
  ニュースレター[#263][news263 fullrbf]をご覧ください。

- [Bitcoin Core #30285][]は、[クラスターmempool][topic cluster mempool]プロジェクトに
  2つの主要な[クラスターリニアライゼーション][wuille cluster]アルゴリズムを追加します。
  既存のリニアライゼーションを組み合わせるための`MergeLinearizations`と、
  追加処理によってリニアライゼーションを改善する`PostLinearize`です。このPRは、
  先週のニュースレター[#314][news314 cluster]で掲載された取り組みに基づいています。

- [Bitcoin Core #30352][]は、新しいアウトプットタイプP2A（Pay-To-Anchor）を導入し、
  その支払いへの使用を標準にします。このアウトプットタイプは鍵が不要（誰でも使用可能）で、
  txidのマリアビリティに耐性のある[CPFP][topic cpfp]による手数料の引き上げ用の
  コンパクトなアンカーを可能にします（[ニュースレター #277][news277 p2a]参照）。
  [TRUC][topic v3 transaction relay]トランザクションと組み合わせることで、
  [CPFP carve-out][topic cpfp carve out]リレールールに基づき、
  LN[アンカーアウトプット][topic anchor outputs]を置き換える
  [エフェメラルアンカー][topic ephemeral anchors]の実装が促進されます。

- [Bitcoin Core #29775][]は、ネットワークを[BIP94][]で定義されている[testnet4][topic testnet]に設定する
  `testnet4`設定オプションを追加します。testnet4には、
  以前のtestnet3でのいくつかの問題の修正が含まれています（[ニュースレター #306][news306 testnet]参照）。
  testnet3を使用する既存のBitcoin Coreの`testnet`設定オプションは引き続き利用可能ですが、
  以降のリリースでは非推奨となり、削除される予定です。

- [Core Lightning #7476][]は、[オファー][topic offers]とインボイスのリクエストで長さがゼロの
  [ブラインドパス][topic rv routing]を拒否する機能を追加することで、
  最新の[BOLT12仕様][bolt12 spec]の更新案をキャッチアップします。さらに、
  ブラインドパスが提供されているオファーで`offer_issuer_id`の欠落を許可します。
  このような場合は、インボイスの署名に使用された鍵が最終的なブラインドパスの鍵として使用されます。
  これは、オファーの発行者がこの鍵にアクセスできると想定しても問題がないためです。

- [Eclair #2884][]は、[HTLCエンドースメント][topic htlc endorsement]用の[BLIP4][]を実装し、
  ネットワーク上の[チャネルジャミング攻撃][topic channel jamming attacks]を部分的に緩和する最初のLN実装となりました。
  このPRにより、受信エンドースメント値のオプションでのリレーが可能になり、
  リレーノードは、インバウンドピアの評判のローカルな判断を使用して、
  [HTLC][topic htlc]を次のホップに転送する際にエンドースメントを含めるかどうかを決定します。
  ネットワークで広く採用されれば、エンドースされたHTLCは、
  流動性やHTLCスロットなどの希少なネットワークリソースへの優先アクセスを得ることができます。
  この実装は、ニュースレター[#257][news257 eclair]に掲載した以前のEclairの取り組みに基づいています。

- [LND #8952][]は、[チャネルコミットメントのアップグレード][topic channel commitment upgrades]の一種である
  ダイナミックコミットメントを実装するPRのシリーズの一部として、
  型付き`List`を使用するよう`lnwallet`の`channel`コンポーネントをリファクタリングしました。

- [LND #8735][]は、`addinvoice`コマンドの`-blind`フラグを使用して、
  [ブラインドパス][topic rv routing]でインボイスを生成する機能を追加します。
  また、このようなインボイスの支払いも可能になります。[BOLT12][topic offers]はまだLNDに実装されていないため、
  これは[BOLT11][]インボイスにのみ実装されていることに注意してください。
  [LND #8764][]は、（特にマルチパスペイメント（[MPP][topic multipath payments]）を実行する）インボイスへの支払いの際に、
  複数のブラインドパスの使用を許可することで、以前のPRを拡張します。

- [BIPs #1601][]は、[BIP94][]をマージし、簡単に実行できるネットワーク攻撃を防止することを目的とした
  コンセンサスルールの改善を含む[testnet][topic testnet]の新しいバージョンtestnet4を導入します。
  これまでのすべてのmainnetのソフトフォークは、testnet4のジェネシスブロックから有効になり、
  使用されるデフォルトポートは`48333`になります。testnet3で問題のある動作を引き起こした課題を
  testnet4がどのように解決するかの詳細については、
  ニュースレター[#306][news306 testnet4]および[#311][news311 testnet4]をご覧ください。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30493,30285,30352,30562,7476,2884,8952,8735,8764,1601,29775" %}
[BDK 1.0.0-beta.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.1
[libsecp256k1 0.5.1]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.5.1
[news274 cycle mitigate]: /ja/newsletters/2023/10/25/#ln
[dark skippy]: https://darkskippy.com/
[news87 anti-exfil]: /ja/newsletters/2020/03/04/#proposal-to-standardize-an-exfiltration-resistant-nonce-protocol
[news136 anti-exfil]: /ja/newsletters/2021/02/17/#anti-exfiltration
[towns withholding]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Zp%2FGADXa8J146Qqn@erisian.com.au/
[0xb10c compact]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052
[maxwell reconstruct]: https://github.com/bitcoin/bitcoin/pull/30493#issuecomment-2260918779
[todd cycle]: https://mailing-list.bitcoindevs.xyz/bitcoindev/ZqyQtNEOZVgTRw2N@petertodd.org/
[dhakshinamoorthy frost]: https://mailing-list.bitcoindevs.xyz/bitcoindev/740e2584-5b6c-47f6-832e-76928bf613efn@googlegroups.com/
[frost sign bip]: https://github.com/siv2r/bip-frost-signing
[halseth zkelf]: https://delvingbitcoin.org/t/optimistic-zk-verification-using-matt/1050
[ocean pool]: https://ocean.xyz/blocktemplate
[rosenfeld pool]: https://bitcoil.co.il/pool_analysis.pdf
[elftrace]: https://github.com/halseth/elftrace
[news306 testnet]: /ja/newsletters/2024/06/07/#testnet4-bip
[news312 chilldkg]: /ja/newsletters/2024/07/19/#frost
[bip125 github]: https://github.com/bitcoin/bips/blob/master/bip-0125.mediawiki
[news208 fullrbf]: /ja/newsletters/2022/07/13/#bitcoin-core-25353
[news263 fullrbf]: /ja/newsletters/2023/08/09/#rbf
[wuille cluster]: https://delvingbitcoin.org/t/introduction-to-cluster-linearization/1032
[news314 cluster]: /ja/newsletters/2024/08/02/#bitcoin-core-30126
[bolt12 spec]: https://github.com/lightning/bolts/pull/798
[news257 eclair]: /ja/newsletters/2023/06/28/#eclair-2701
[news306 testnet4]: /ja/newsletters/2024/06/07/#testnet4-bip
[news311 testnet4]: /ja/newsletters/2024/07/12/#bitcoin-core-pr-review-club
[news277 p2a]: /ja/newsletters/2023/11/15/#eliminating-malleability-from-ephemeral-anchor-spends
[review club 30352]: https://bitcoincore.reviews/30352
[gh instagibbs]: https://github.com/instagibbs
[mempool bc1pfeessrawgf]: https://mempool.space/address/bc1pfeessrawgf
[gh isstandard]: https://github.com/bitcoin/bitcoin/blob/fa0b5d68823b69f4861b002bbfac2fd36ed46356/src/policy/policy.cpp#L7
[gh areinputsstandard]: https://github.com/bitcoin/bitcoin/blob/fa0b5d68823b69f4861b002bbfac2fd36ed46356/src/policy/policy.cpp#L177
[gh 30352 3rd commit]: https://github.com/bitcoin-core-review-club/bitcoin/commit/ccad5a5728c8916f8cec09e838839775a6026293#diff-ea6d307faa4ec9dfa5abcf6858bc19603079f2b8e110e1d62da4df98f4bdb9c0R228-R232
