---
title: 'Bitcoin Optech Newsletter #385: 2025年振り返り特別号'
permalink: /ja/newsletters/2025/12/19/
name: 2025-12-19-newsletter-ja
slug: 2025-12-19-newsletter-ja
type: newsletter
layout: newsletter
lang: ja

excerpt: >
  第8回となるBitcoin Optech年間振り返り特別号では、2025年のBitcoinの注目すべき進展についてまとめています。
---

{{page.excerpt}} これは[2018年][yirs 2018]、[2019年][yirs 2019]、[2020年][yirs 2020]、
[2021年][yirs 2021]、[2022年][yirs 2022]、[2023年][yirs 2023]、[2024年][yirs 2024]のまとめの続編です。

## 内容

* 1月
  * [ChillDKGドラフトの更新](#chilldkg)
  * [オフチェーンDLC](#offchaindlcs)
  * [コンパクトブロックの再構築](#compactblockstats)
* 2月
  * [Erlayのアップデート](#erlay)
  * [LNエフェメラルアンカースクリプト](#lneas)
  * [確率的な支払い](#probpayments)
* 3月
  * [Bitcoin Forking Guide](#forkingguide)
  * [MEVの集中化を防ぐためのプライベートブロックテンプレートマーケットプレイス](#templatemarketplace)
  * [焼却可能なアウトプットを使用したLNの前払い手数料と保留手数料](#lnupfrontfees)
* 4月
  * [SwiftSyncによるIBDの高速化](#swiftsync)
  * [対話型の集約署名DahLIAS](#dahlias)
* 5月
  * [クラスターmempool](#clustermempool)
  * [Bitcoin CoreのOP_RETURNポリシー制限の引き上げまたは撤廃](#opreturn)
* 6月
  * [セルフィッシュマイニングの危険閾値の計算](#selfishmining)
  * [addrメッセージを使用したノードのフィンガープリンティング](#fingerprinting)
  * [Garbled Lock](#garbledlocks)
* 7月
  * [チェーンコードの委任](#ccdelegation)
* 8月
  * [UtreexoのBIPドラフト](#utreexo)
  * [最小リレー手数料率の引き下げ](#minfeerate)
  * [ピアブロックテンプレートの共有](#templatesharing)
  * [BitcoinとLN実装の差分ファジング](#fuzzing)
* 9月
  * [Simplicityの設計に関する詳細](#simplicity)
  * [BGPインターセプションを使用した分断とエクリプス攻撃](#eclipseattacks)
* 10月
  * [任意のデータに関する議論](#arbdata)
  * [チャネルジャミング緩和のシミュレーション結果とアップデート](#channeljamming)
* 11月
  * [OpenSSLとlibsecp256k1におけるECDSA署名検証のパフォーマンス比較](#secpperformance)
  * [伝播遅延とマイニングの集中化によるステイル率のモデル化](#stalerates)
  * [BIP3とBIPプロセス](#bip3)
  * [Bitcoin Kernel C APIの導入](#kernelapi)
* 12月
  * [スプライシング](#lnsplicing)
* 注目のまとめ
  * [脆弱性](#vulns)
  * [量子](#quantum)
  * [ソフトフォークの提案](#softforks)
  * [Stratum v2](#stratumv2)
  * [人気の基盤プロジェクトのメジャーリリース](#releases)
  * [Bitcoin Optech](#optech)

---

## 1月

{:#chilldkg}

- **<!--updated-chilldkg-draft-->ChillDKGドラフトの更新:** Tim RuffingとJonas Nickは、
  FROST[閾値署名][topic threshold signature]スキームで使用する
  分散鍵生成プロトコル（DKG）に関する研究を[更新しました][news335 chilldkg]。
  ChillDKGは、既存のディスクリプターウォレットと同様の復元機能を提供することを目指しています。

{:#offchaindlcs}

- **オフチェーンDLC:** 開発者のConduitionは、参加者が共同でDLCファクトリーの作成と拡張を行える
  新しいオフチェーンDLC（[Discreet Log Contract][topic dlc]）のメカニズムについて[投稿しました][news offchain dlc]。
  このメカニズムにより、ある参加者がオンチェーンでの解決を選択するまでロールし続ける反復的なDLCを可能にします。
  これはコントラクトのロール毎に対話を必要としていた[以前の][news dlc channels]オフチェーンDLCの研究とは対照的です。

{:#compactblockstats}

- **<!--compact-block-reconstructions-->コンパクトブロックの再構築:** 1月にはまた、
  Bitcoinノードが[コンパクトブロックリレー][topic compact block relay]（BIP152）を使用して
  どれだけ効果的にブロックを再構築できるかについての[過去の研究][news315 compact blocks]を再検討し、
  2025年における複数の投稿の内の最初の投稿が発表されました。以前の測定値が更新され、潜在的な改善点が検討されました。
  [1月に公開された][news339 compact blocks]更新された統計によると、
  mempoolがいっぱいの場合、ノードが不足しているトランザクションを要求する頻度が高くなります。
  オーファンの解決が不十分であることが原因の可能性として特定され、[いくつかの改善][news 338]がすでに行われています。

  今年の後半には、[コンパクトブロックのプレフィリング戦略][news365 compact blocks]によって
  再構築の成功率をさらに向上させることができるかどうかを分析しました。
  テストの結果、ピアのmempoolに欠落している可能性が高いトランザクションを選択的にプレフィリングすることで、
  わずかな帯域幅のトレードオフでフォールバック要求を削減できることが示唆されました。
  その後の研究では、これらの追加の測定結果に加え、[監視ノードの最小リレー手数料率](#minfeerate)の変更前後の
  [実際の再構築測定結果][news382 compact blocks]を更新しました。その結果、
  `minrelayfee`がより低いノードの再構築率が高くなることが示されました。
  著者は、自身のモニタリングプロジェクトのアーキテクチャについても[投稿しました][news368 monitoring]。

## 2月

{:#erlay}

- **<!--erlay-update-->Erlayのアップデート:** Sergi Delgadoは今年、[Erlay][erlay]をBitcoin Coreに実装する取り組みと進行状況について、
  [複数の記事][erlay optech posts]を発表しました。最初の記事では、
  Erlayの提案の概要と、現在のトランザクションリレーのメカニズム（「ファンアウト」）の仕組みを説明しています。
  これらの記事で、Erlayの開発中に発見したさまざまな結果、
  たとえば[トランザクションの知識に基づくフィルタリング][erlay knowledge]は期待したほど効果はなかったなど説明しました。
  また、[何個のピアがファンアウトを受信すべきか][erlay fanout amount]を選択する実験も行い、
  8個のアウトバウンドピアで35%、12個のアウトバウンドピアで45%の帯域幅の削減が見られましたが、
  レイテンシーが240%増加することも判明しました。他の2つの実験では、
  [トランザクションの受信方法に基づいてファンアウト率を決定する方法][erlay transaction received]と、
  [候補ピアを選択するタイミング][erlay candidate peers]を検討しました。
  ファンアウトとリコンシリエーションを組み合わせたこれらの実験は、
  それぞれの手法をいつ使用するかを判断するのに役立ちました。

{:#lneas}

- **LNエフェメラルアンカースクリプト:** [Bitcoin Core 28.0でのmempoolポリシーの複数の更新][28.0 wallet guide]後、
  2月にはLNのコミットメントトランザクションにおける[エフェメラルアンカーアウトプット][topic ephemeral anchors]の設計上の選択肢について
  議論が始まりました。コントリビューターたちは、既存の[アンカーアウトプット][topic anchor outputs]の代替として、
  [TRUC][topic v3 transaction relay]ベースのコミットメントトランザクションのアウトプットの1つに、
  この構成のスクリプトを使用すべきかを[検討しました][news340 lneas]。

  トレードオフには、異なるスクリプトが[CPFP][topic cpfp]による手数料引き上げやトランザクションウェイトおよび、
  アンカーアウトプットが不要になった際に安全に使用または破棄する機能にどう影響するかが含まれていました。
  [継続的な議論][news341 lneas]では、mempoolポリシーやライトニングのセキュリティ仮定との相互作用が強調されました。

{:#probpayments}

- **<!--probabilistic-payments-->確率的な支払い:** Oleksandr Kurbatovは、
  Bitcoinスクリプトからランダムな結果を生成する方法についてDelving Bitcoinで[議論を始めました][delving random]。
  [元々の方法][ok random]は、チャレンジャー/検証者の構成でゼロ知識証明を使用するもので、[PoCも公開されて][random poc]います。
  他の方法も議論され、Taprootのツリー構造を活用する[方法や][waxwing random]、
  予測不可能なビット列を直接生成するために異なるハッシュ関数のシーケンスで表されるビットのXORをスクリプト化する[方法][rl random]などが含まれます。
  このようなランダムなトランザクション結果を使用して、LNにおける少額で[トリムされるHTLC][topic trimmed htlc]の代替として、
  確率的なHTLCが使用できるかどうかが[議論されました][dh random]。

<div markdown="1" class="callout" id="vulns">

## 2025年のまとめ: 脆弱性の開示

2025年、Optechは12件を超える脆弱性の開示をまとめました。脆弱性の報告は、
開発者とユーザーの両方が過去の過ちから学ぶのに役立ち、[責任ある開示][topic responsible disclosures]により、
脆弱性が悪用される前に修正がリリースされることが保証されます。

_注: Optechは、脆弱性の発見者がユーザーへの被害リスクを最小限に抑えるための合理的な努力をしたと思われる場合にのみ、
その名前を公開しています。このセクションで言及されているすべての方々の洞察とユーザーの安全に対する明確な配慮に感謝します。_

1月初旬、Yuval Kogmanは、WasabiとGingerの現在のバージョンおよび、
Samourai、Sparrow、Trezor Suiteの過去のバージョンで使用されている集中型の
[Coinjoin][topic coinjoin]プロトコルにおける長年存在していた複数の非匿名化の脆弱性を[開示しました][news335 coinjoin]。
悪用された場合、集中型のコーディネーターは、ユーザーのインプットとアウトプットを紐付けることができ、
Coinjoinで期待されるプライバシー上の利点を事実上無効にする可能性があります。同様の脆弱性は、
2024年末にも報告されています（[ニュースレター #333][news333 coinjoin]参照）。

1月末、Matt Morehouseは、多数の保留中の[HTLC][topic htlc]がある状態での一方的なチャネル閉鎖時における
LDKの請求プロセスの脆弱性について責任のある開示を[発表しました][news339 ldk]。
LDKは、複数のHTLCの解決をバッチ処理することで手数料を削減することを目指していましたが、
チャネルの相手方の承認済みトランザクションと競合が発生した場合に、
LDKは影響を受けるすべてのバッチを更新できず、資金のスタックや盗難のリスクにつながる可能性がありました。
この問題は、LDK 0.1で修正されました。

同じ週、Antoine Riardは[置換サイクル][topic replacement cycling]攻撃を使った追加の脆弱性を[開示しました][news339 cycling]。
攻撃者は、被害者の未承認トランザクションを[ピンニング][topic transaction pinning]することで、
被害者の手数料引き上げのための置換トランザクションを受信、伝播させず、
被害者の最も手数料が高いバージョンを選択的にマイニングすることで、この脆弱性を悪用できます。
このシナリオは稀な状況下でのみ実行可能で、検知されずに継続するのは困難です。

2月、Morehouseは、LDKの2つめの脆弱性を[開示しました][news340 htlcbug]。
多数のHTLCが同じ金額と同じペイメントハッシュを持っている場合、LDKは1つを除いてすべてのHTLCを決済できず、
誠実な相手方がチャネルを強制閉鎖することになります。これは直接的な盗難を可能にするものではありませんでしたが、
LDK 0.1.1でバグが修正されるまで（[ニュースレター #340][news340 htlcfix]参照）、
追加の手数料とルーティング収入の減少をもたらしました。

3月、Morehouseは、0.18未満のバージョンのLNDにおける修正済みの脆弱性の責任のある開示を[発表しました][news344 lnd]。
被害者とのチャネルを持つ攻撃者が、何らかの方法で被害者のノードを再起動させることができた場合、
LNDに同じHTLCの支払いと払い戻しの両方をさせることができました。これにより、
攻撃者はチャネル金額とほぼ同じ金額を盗むことができました。この開示は、
ライトニング仕様のギャップも明らかにし、後に修正されました（[ニュースレター #346][news346 bolts]参照）。

5月、Ruben Somsenは、BIP30の[重複][topic duplicate transactions]コインベーストランザクションのこれまでの処理に関連する、
理論的なコンセンサス障害のエッジケースについて[説明しました][news353 bip30]。
Bitcoin Coreからチェックポイントが削除されたため（[ニュースレター #346][news346 checkpoints]参照）、
ブロック91,842までの極端なブロック再編成が発生すると、重複したコインベースを観測したかどうかに応じて、
ノードのUTXOセットが異なる状態になる可能性があります。これらの2つの例外に対する特別なケースのロジックを追加するなど、
いくつかのソリューションが議論されましたが、現実的な脅威とはみなされませんでした。

同じく5月、Antoine Poinsotはバージョン29.0未満のBitcoin Coreに影響する、
深刻度の低い脆弱性の責任のある開示を[発表しました][news354 32bit]。この脆弱性は、
過剰なアドレスの通知により32-bitの識別子がオーバーフローし、ノードをクラッシュさせます。
以前の緩和策により、デフォルトのピア制限下では悪用は実用的ではないほど遅くなっていましたが（ニュースレター
[#159][news159 32bit]および[#314][news314 32bit]参照）、
Bitcoin Core 29.0では64-bitの識別子に切り替えることで、この問題は完全に解決されました。

7月、MorehouseはLNDのDoS脆弱性について責任のある開示を[発表しました][news364 lnd]。
この問題は、攻撃者が過去の[ゴシップ][topic channel announcements]メッセージを繰り返し要求することで、
ノードのメモリを使い果たしクラッシュさせることができました。
このバグはLND 0.18.3で修正されました（[ニュースレター #319][news319 lnd]参照）。

9月には、MorehouseはEclairの旧バージョンに脆弱性があることを[開示しました][news373 eclair]。
攻撃者は古いコミットメントトランザクションをブロードキャストすることで、チャネルから現在の資金をすべて盗むことができ、
Eclairはそれを無視するというものでした。Eclairの修正は、同様の潜在的な問題を検出することを目的とした、
より包括的なテストスイートと組み合わせて行われました。

10月、Poinsotは重大度の低い4つのBitcoin Coreの脆弱性の責任ある開示を[発表しました][news378 four]。
ディスク容量を圧迫する2つのバグ、32-bitシステムに影響する非常に可能性の低いリモートクラッシュ、
未承認トランザクションの処理におけるCPU DoS問題です。これらは、29.1で一部修正され、
30.0で完全に修正されました。修正内容の一部については、ニュースレター[#361][news361 four]、[#363][news363 four]および
[#367][news367 four]をご覧ください。

12月、Bruno GarciaはNBitcoinライブラリにおいて`OP_NIP`に関連する理論的なコンセンサス障害を[開示しました][news383 nbitcoin]。
この障害は、特定のフルキャパシティスタックのエッジケースで例外を引き起こす可能性がありました。
これは差分ファジングによって発見され、すぐに修正されました。
NBitcoinを使用しているフルノードは知られていないため、この公開によるチェーン分岐リスクはありませんでした。

12月、Morehouseはまた、2つの資金盗難の脆弱性と1つのサービス拒否の脆弱性を含む、
LNDの3つの重大な脆弱性を[開示しました][news384 lnd]。
</div>

## 3月

{:#forkingguide}

- **Bitcoin Forking Guide:** Anthony Townsは、Bitcoinのコンセンサスルールの変更に関する
  コミュニティの合意形成の方法に関する[ガイド][news344 fork guide]をDelving Bitcoinに投稿しました。
  Townsによると、合意形成のプロセスは、[研究開発][fork guide red]、[パワーユーザーによる調査][fork guide pue]、
  [業界評価][fork guide ie]、[投資家のレビュー][fork guide ir]という4つのステップに分けられます。
  ただし、Townsは読者に対し、このガイドはあくまで高レベルの手順を目的としたもので、
  協力的な環境でのみ機能すると警告しています。

{:#templatemarketplace}

- **MEVの集中化を防ぐためのプライベートブロックテンプレートマーケットプレイス:** 開発者の
  Matt Coralloと7d5x9は、マイニングの集中化につながるMEV（Miner Extractable Value）の一種である
  MEVilがBitcoin上で蔓延するのを防ぐのに役立つ可能性がある[提案][news344 template
  mrkt]をDelving Bitcoinに投稿しました。[MEVpool][mevpool gh]と呼ばれるこの提案は、
  マイナーのブロックテンプレート内の選択されたスペース（例：「トランザクションYが、
  Zで識別されるスマートコントラクトとやりとりする他のトランザクションよりも前に来るのであれば、
  トランザクションYを含めるためにX [BTC]支払います」）を公開市場で入札できるようにします。

  ブロックテンプレート内の優先トランザクションの順序付けのサービスは、
  大規模なマイナーによってのみ提供されることが想定されており、中央集権化につながる一方、
  トラストの低い公開市場では、マイナーは誰でもブラインドブロックテンプレート上で作業することができます。
  ブラインドブロックテンプレートは、マイナーがブロックを公開するために十分なProof of Workを生成するまで、
  完全なトランザクションは公開されません。著者らは、この提案は、
  単一の信頼できるマーケットプレイスによる支配に対抗して分散性を維持するためには、
  複数のマーケットプレイスが競争する必要があると警告しています。

{:#lnupfrontfees}

- **<!--ln-upfront-and-hold-fees-using-burnable-outputs-->焼却可能なアウトプットを使用したLNの前払い手数料と保留手数料:**
  John Lawは、攻撃者がコストをかけずに他のノードが自分の資金を使用するのを妨害できる
  ライトニングネットワークプロトコルの弱点である[チャネルジャミング攻撃][topic channel jamming attacks]に対する
  [ソリューション][news 347 ln fees]を提案しました。この提案は、
  ライトニングノードが支払いの転送に対して追加で2種類の手数料、前払い手数料と保留手数料を課す可能性について
  彼が書いた[論文][ln fees paper]を要約したものです。最終的な送信者は、
  転送ノードが[HTLC][topic htlc]スロットを一時的に使用することに対する補償として前者を支払います。
  一方、後者はHTLCの決済を遅らせるノードによって支払われ、手数料額は遅延の長さに応じて増加します。

## 4月

{:#swiftsync}

- **SwiftSyncによるIBDの高速化:** Sebastian Falbesonerは、
  Ruben Somsenが最初に[提案][swiftsync ruben gh]したアイディアであるSwiftSyncを用いて
  _IBD_（Initial Block Download）を5倍以上高速化するサンプル実装と結果をDelving Bitcoinに[投稿しました][news349 swiftsync]。

  この高速化は、IBD中に、IBDの終了時点でまだUTXOセットに存在するコインのみをUTXOセットに追加することで達成されます。
  最終的なUTXOセットの状態の知識は、最小限の信頼で事前生成されたヒントファイルにコンパクトにエンコードされます。
  chainstateの操作のオーバーヘッドを最小化することに加えて、
  SwiftSyncは並列ブロック検証を可能にすることでさらなるパフォーマンス向上を実現します。

  Rust実装の作業は9月に[発表されました][swiftsync rust impl]。

{:#dahlias}

- **<!--dahlias-interactive-aggregate-signatures-->対話型の集約署名DahLIAS:**
  4月、Jonas NickとTim RuffingおよびYannick Seurinは、
  Bitcoinで既に使用されている暗号プリミティブと互換性のある初の対話型64-byte集約署名スキームである
  [DahLIASの論文][dahlias paper]をBitcoin-Devメーリングリストで[発表しました][news351 dahlias]。
  集約署名は、[CISA][topic cisa]（cross-input signature aggregation）の暗号技術要件で、
  CISAは複数のインプットを持つトランザクションのサイズを削減できるBitcoin向けに提案されている機能で、
  [Coinjoin][topic coinjoin]や[Payjoin][topic payjoin]を含む多くの異なるタイプの支払いのコストを削減できる可能性があります。

<div markdown="1" class="callout" id="quantum">

## 2025年のまとめ: 量子

将来の[量子][topic quantum resistance]コンピューターが、
Bitcoinがコインの所有権を証明するために依存している楕円曲線離散対数（ECDL）の困難性の仮定を
弱めたり破ったりする可能性への注目が高まる中、そのような発展の影響を議論し軽減するために、
年間を通していくつかの議論と提案が行われました。

Clara ShikhelmanとAnthony Miltonは、量子コンピューティングがBitcoinに与える影響をカバーし、
潜在的な緩和戦略を概説する論文を[発表しました][news357 quantum report]。

[BIP360][]が[更新され][news bip360 update]、BIP番号が割り当てられました。
この提案は、Bitcoinの量子耐性化への第一歩として、
また内部鍵を必要としないTaprootのユースケースの最適化として注目を集めています。
今年後半の[研究][news365 quantum taproot]では、これらのTaprootコミットメントが
量子コンピューターによる操作に対して安全であることが確認されました。年末近くに、
この提案はスコープの縮小と汎用性の向上を反映して、以前の名称であるP2QRH（Pay to Quantum Resistant
Hash）からP2TSH（Pay to Tapscript Hash）に改名されました。

Jesse Posnerは、階層的決定性（HD）ウォレットや[サイレントペイメント][topic silent payments]、
鍵集約、[閾値署名][topic threshold signature]などの既存のBitcoinのプリミティブが、
よく参照される量子耐性署名アルゴリズムのいくつかと互換性がある可能性を示す
[既存の研究を強調しました][news364 quantum primatives]。

Augustin Cruzは、量子脆弱なコインを確実に破棄するためのBIPを[提案しました][news qr cruz]。
その後、Jameson Loppは量子脆弱なコインをどう扱うべきかについての[議論を開始し][news qr lopp1]、
量子攻撃者にコインを渡すことから破棄することまで、いくつかのアイディアが生まれました。
Loppは後に、Bitcoinが実装できる具体的な[ソフトフォークのシーケンス][BIPs #1895]を[提案しました][news qr lopp2]。
これは、CRQC（暗号に関連する量子コンピューター）が開発されるずっと前から始まり、
量子攻撃者が突然多くのコインにアクセスできるようになる脅威を段階的に軽減しながら、
保有者がコインを安全にするための時間を確保することを目的としています。

Bitcoinが将来的に量子脆弱な支払いを無効化した場合でも、
既存のコインの大半をリカバリー可能な方法で保護できるようにするための
2つの提案（[1][news qr sha]、[2][news qr cr]）が行われました。
簡単に説明すると、理論上の一連のイベントは、
0) ビットコイン保有者が、現在のウォレットに支払いパスに必要なハッシュされたシークレットを準備し、
1) CRQCが迫っていることが示され、
2) Bitcoinが楕円曲線署名を無効化し、
3) Bitcoinが量子安全な署名スキームを有効化し、
4) Bitcoinがこれらの提案の1つを有効化し、準備していた保有者が量子脆弱なコインを請求できるようにする、
というものです。具体的な実装によっては、あらゆる種類のアドレス（script-pathを持つP2TRを含む）がこれらの方法を利用できます。

開発者のConduitionは、[`OP_CAT`][BIP347]を使用してWinternitz署名を実装できることを実証しました。
これは、インプットあたり約2000 vbyteのコストで量子耐性署名チェックを提供します。
これは以前[提案された][rubin lamport]`OP_CAT`ベースの[ランポート署名][lamport]よりも低コストです。

Matt Coralloは、量子耐性署名チェックopcodeを[Tapscript][topic tapscript]に追加するという一般的なアイディアについて
[議論][news qr corallo]を開始しました。その後、Abdelhamid Bakhtaは
そのようなopcodeの1つとしてネイティブSTARK検証を[提案し][abdel stark]、
Conduitionは別の選択肢としてSLH-DSA (SPHINCS)耐量子署名を最適化する研究について[書きました][conduition sphincs]。
Tapscriptに追加された`OP_CAT`を含むあらゆる耐量子署名検証opcodeは、
[BIP360][]と組み合わせることで、Bitcoinのアウトプットを完全に量子耐性化できます。

Tadge Dryjaは、Bitcoinが汎用的なクロスインプット署名集約を実装する方法の1つを[提案しました][news qr agg]。
これはポスト量子署名の巨大なサイズを部分的に軽減するものです。

年末には、Mikhail KudinovとJonas Nickが、ハッシュベースの署名スキームの概要を示し、
それらをBitcoinのニーズに合わせてどのように適応させることができるかを論じた[論文][hash-based signature schemes]を
[発表しました][nick paper tweet]。

</div>

## 5月

{:#clustermempool}

- **<!--cluster-->クラスターmempool:** 今年初旬、Stefan Richterは、
  1989年の研究論文で最大比率のクロージャー問題に対する効率的なアルゴリズムが
  クラスターリニアライゼーションに適用できることを[発見し][news340 richter ggt]、
  大きな話題を呼びました。Pieter Wuilleは既に初期の候補セット探索の潜在的な改善策として
  線形計画法アプローチを調査しており、3つめの選択肢として最小カットベースのアプローチの探求を研究に取り入れていました。
  その後まもなく、WuilleはBitcoin Core PR Review Clubで、
  トランザクションをウェイト、手数料および関係性のみに絞り込んでmempoolグラフとの効率的なやりとりを可能にする
  新しく導入された`TxGraph`クラスについて[説明しました][news341 pr-review-club txgraph]。
  5月には、Wuilleは3つのクラスターリニアライゼーションアプローチのベンチマークを公開し、
  [トレードオフ][news352 wuille linearization techniques]についても説明しました。その結果、
  どちらの高度なアプローチも単純な候補セットの検索よりもはるかに効率的であるものの、
  彼の線形計画法ベースのスパニング・フォレストリニアライゼーションアルゴリズムは、
  最小カットベースのアプローチよりも実用的であることが判明しました。
  秋には、Abubakar Sadiq Ismailがクラスターmempoolを活用して、
  mempoolの内容が前のブロックテンプレートと比べて大幅に改善されたタイミングを追跡する方法を
  [説明しました][news377 ismail template improvement]。年末近くには、
  クラスターmempoolの実装が[完了し][news382 cluster mempool completed]、
  Bitcoin Core 31.0でリリースされる準備が整いました。
  初期の候補セット探索リニアライゼーションアルゴリズムを
  スパニング・フォレストリニアライゼーションアルゴリズムに置き換える作業は進行中です。

{:#opreturn}

- **Bitcoin CoreのOP_RETURNポリシー制限の引き上げまたは撤廃:** 4月、プロトコル開発者たちは、
  OP_RETURNアウトプットのポリシー制限が、状況によって支払い用のアウトプットにデータを埋め込むという
  誤ったインセンティブを引き起こしていることを発見しました。ポリシーの当初の動機がネットワークの成長に伴い
  時代遅れになっていたという観察に加え、これはOP_RETURN mempoolポリシー制限を撤廃するという提案に繋がりました。
  この提案は、mempoolポリシーの有効性、Bitcoinの目的、そしてBitcoin開発者がBitcoinの使用法を規制する、
  または規制を控える責任について激しい[議論を][news352 OR debate]引き起こしました。
  Bitcoin Coreのコントリビューターたちは、経済的なインセンティブにより
  OP_RETURNアウトプットの使用が劇的に増加する可能性は低いと主張し、
  この変更はインセンティブバグの修正であると考えました。批判者たちは、制限の撤廃をデータの埋め込みの承認と解釈しましたが、
  そのような利用方法は経済的に魅力ではないという点にも同意しました。最終的に、
  Bitcoin Core 30.0のリリースでは、複数のOP_RETURNアウトプットを許可し、
  OP_RETURNアウトプットスクリプトのサイズに関するポリシー制限を撤廃する、
  [更新されたポリシー][Bitcoin Core #32406]が実装されました。リリース後、
  コンセンサスレベルで[データ埋め込み](#arbdata)を抑制することを提案するいくつかのソフトフォーク提案が提出されました。

## 6月

{:#selfishmining}

- **<!--calculating-the-selfish-mining-danger-threshold-->セルフィッシュマイニングの危険閾値の計算:**
  Antoine Poinsotは、この悪用に名前をつけた2013年の[論文][selfish miner paper]に基づいて、
  [セルフィッシュマイニング攻撃][topic selfish mining]の背後にある[数学的根拠][news358 selfish miner]を提供しました。
  Poinsotは、論文の結論の1つを再現することに焦点を当て、
  ネットワーク全体のハッシュレートの33%を支配する不正なマイナーが、
  発見した新しいブロックの一部のアナウンスを選択的に遅らせることで、
  残りのマイナーよりもわずかに収益性を高めることができることを証明しました。

{:#fingerprinting}

- **addrメッセージを使用したノードのフィンガープリンティング:** 開発者の
  Daniela BrozzoniとNaiyomaは、P2Pプロトコルを介してノードが他の潜在的なピアをアナウンスするために送信する
  `addr`メッセージを使用して、複数のネットワーク上で同じノードを識別することに焦点を当てた
  フィンガープリンティング研究の[結果][news360 fingerprinting]を発表しました。
  BrozzoniとNaiyomaは、特定のアドレスメッセージの詳細を使用して個々のノードをフィンガープリントすることができ、
  複数のネットワーク（IPv4や[Tor][topic anonymity networks]など）で実行されている同じノードを識別できました。
  研究者らは、２つの可能な緩和策を提案しています: アドレスメッセージからタイムスタンプを削除するか、
  タイムスタンプを残す場合は、特定のノードに固有にならないようにタイムスタンプをわずかにランダム化することです。

{:#garbledlocks}

- **Garbled Lock:** 6月、Robin Linusは、Jeremy Rubinの[アイディア][delbrag rubin]に基づいて、
  [BitVM][topic acc]スタイルのコントラクトを改良する[提案][news359 bitvm3]を発表しました。
  この新しいアプローチは、[Garbled Circuit][garbled circuits wiki]という暗号プリミティブを活用し、
  オンチェーンのSNARK検証をBitVM2実装よりも1,000倍効率的にし、必要なオンチェーンスペースの大幅な削減を約束します。
  ただし、数TBのオフチェーンセットアップが必要になるというコストが伴います。

  その後8月に、Liam EagenはGlock（Garbled Lock）と呼ばれる、
  Garbled Circuitに基づいて[アカウンタブルコンピューティングコントラクト][topic acc]を作成する
  新しいメカニズムを説明した研究[論文][eagen paper]についてBitcoin-Devメーリングリストに[投稿しました][news369 eagen]。
  このアプローチはLinusの研究と似ていますが、Eagenの研究はLinusの研究とは独立しています。
  Eagenによると、GlockはBitVM2と比較してオンチェーンデータを1/550に削減できるとのことです。

<div markdown="1" class="callout" id="softforks">

## 2025年のまとめ: ソフトフォークの提案

今年はソフトフォークの提案をめぐって、スコープが限定され影響が最小限のものから、
スコープが広く強力なものまで、さまざまな議論が行われました。

- *<!--transaction-templates-->トランザクションテンプレート:*
  トランザクションテンプレートに関連するいくつかのソフトフォークパッケージが議論されました。
  同様のスコープと機能を持つもとしては、CTV+CSFS（[BIP119][]+[BIP348][]）と
  [Taprootネイティブの再バインド可能な署名パッケージ][news thikcs]
  （[`OP_TEMPLATEHASH`][BIPs #1974]+[BIP348][]+[BIP349][]）が挙げられます。
  これらは、再バインド可能な署名（特定のUTXOの支払いにコミットしない署名）と、
  UTXOを特定の次のトランザクションに支払うことへの事前コミットメント
  （等価性[コベナンツ][topic covenants]とも呼ばれることもあります）の両方を可能にするための
  Bitcoin Scriptの最小限の機能拡張を表しています。有効化されると、
  [LN-Symmetry][ctv csfs symmetry]や[シンプルなCTV Vault][ctv vaults]が可能になり、
  [DLCの署名要件を削減][ctv dlcs]し、[Arkのインタラクションを削減][ctv csfs arks]し、
  [PTLCを簡素化][ctv csfs ptlcs]するなどの効果があります。これらの提案の違いの1つは、
  `OP_TEMPLATEHASH`は`scriptSigs`にコミットしないため、
  `OP_TEMPLATEHASH`はCTVが使用できる[BitVM兄弟ハック][ctv csfs bitvm]を使用できないことです。

  [OP_CHECKSIGFROMSTACK][topic OP_CHECKSIGFROMSTACK]を含めることで、
  これらの提案は[キーラダリング（Key Laddering）][rubin key ladder]を介して
  マークルツリーに似たマルチコミットメント（ロックスクリプトまたは支払い（アンロック）スクリプト内で、
  関連する複数の値（オプションで順序付け可能）にコミットすること）も可能にします。
  更新された[LNHANCE][lnhance update]提案には、キーラダリングに必要な
  追加のスクリプトサイズと検証コストなしでマルチコミットを可能にする
  `OP_PAIRCOMMIT` ([BIPs #1699][])が含まれています。マルチコミットメントは、
  LN-Symmetryや複雑な委任などにおいて有用です。

  一部の開発者は、ソフトフォークに向けた進捗が（彼らの観点から見て）遅いことに
  [不満を表明しました][ctv csfs letter]が、このカテゴリの提案に関する議論の多さは、
  関心と熱意が依然として高いことを示唆しています。

- *<!--consensus-cleanup-->コンセンサスクリーンアップ:*
  [コンセンサスクリーンアップ][topic consensus cleanup]提案は、フィードバックと追加研究を基に[更新され][gcc update]、
  [BIPドラフト][gcc bip]が公開され、[BIP54][]としてマージされ、
  現在は[実装とテストベクタが含まれています][gcc impl tests]。今年初め、
  意図しない没収に備えてこのようなクリーンアップを一時的なものにすべきかどうかについて[議論][transitory cleanups]がありましたが、
  [一時的なソフトフォーク][topic transitory soft forks]は期限が切れるたびに再評価する必要があるため魅力的ではありません。

- *Opcode提案:* 前述のバンドルopcodeの提案に加えて、
  2025年にはいくつかの個別のScript opcodeが提案または改良されました。

  `OP_CHECKCONTRACTVERIFY`（CCV）は、特に資金のフローに関するセマンティクスが[改良され][ccv
  semantics]、[BIP443][]と[なりました][ccv bip]。CCVは、
  インプットまたはアウトプットの`scriptPubKey`と金額を特定の方法で制限することで
  リアクティブセキュリティ[Vault][topic vaults]や他の幅広いコントラクトを可能にします。
  `OP_VAULT`提案は、CCVを支持して[取り下げられました][vault withdrawn]。
  CCVのアプリケーションの詳細については、[Optechのトピックエントリ][topic MATT]をご覧ください。

  64-bitの算術opcodeのセットが[提案され][64bit bip]ました。Bitcoinの現在の算術演算は、
  （驚くべきことに）Bitcoinのインプットとアウトプットの金額の全範囲で動作することができません。
  インプット/アウトプットの金額にアクセスおよび/また制約する他のopcodeと組み合わせることで、
  これらの拡張された算術演算は新しいBitcoinウォレット機能を可能にする可能性があります。

  [`OP_TXHASH`][txhash]の[亜種][txhash sponsors]の提案は、
  [トランザクションスポンサーシップ][topic fee sponsorship]を可能にします。

  開発者たちは、`OP_CHECKSIG`およびその関連の演算以外で楕円曲線暗号の演算をScriptで可能にするための
  2つのオプションを提案しました。1つは、Taprootの`scriptPubKey`を構築できるようにするための
  `OP_TWEAKADD`を[提案しています][tweakadd]。もう１つは、同様の機能を持ちながら、
  新しい署名検証やマルチシグ機能など、より幅広い用途への応用が期待される、
  `EC_POINT_ADD`のようなより細かい楕円曲線opcodeを[提案しています][ecmath]。
  これらの提案のいずれかを`OP_TXHASH`および64-bit演算（または同様のopcode）と組み合わせると、
  CCVと同様の機能が有効になります。

- *Script Restoration:* Script Restorationプロジェクトのために4つのBIPが[投稿されました][gsr bips]。
  これらの4つのBIPで提案されているScriptの変更とopcodeにより、上記opcodeで提案されているすべての機能が有効になり、
  スクリプトの表現力も向上します。

</div>

## 7月

{:#ccdelegation}

- **<!--chain-code-delegation-->チェーンコードの委任:** Jurvis Tanは、
  Jesse Posnerと共同で取り組んでいる方法（現在は[Chain Code Delegation][BIPs
  #2004]/BIP89と呼ばれています）について[投稿しました][jt delegation]。
  これは、部分的に信頼された協調カストディプロバイダーではなく、
  顧客がプロバイダーの署名鍵から子鍵を導出するための[BIP32][]チェーンコードを生成する（プライベートに保持する）
  協調カストディ方式です。この方法により、プロバイダーは顧客の完全な鍵ツリーを導出できなくなります。
  この手法は、ブラインド（プロバイダーの鍵セキュリティを活用しながら完全なプライバシーを確保）と
  非ブラインド（プロバイダーがポリシーを強制できるものの、署名対象のトランザクションがプロバイダーに開示される）のいずれかで使用できます。

## 8月

{:#utreexo}

- **UtreexoのBIPドラフト:** Calvin Kim、Tadge DryjaおよびDavidson Souzaは、
  UTXOセット全体を保存せずに、ノードがトランザクションで使用されるUTXOに関する情報を取得・検証できる
  [Utreexo][topic utreexo]と呼ばれる仕組みの[3つのBIPドラフト][news366 utreexo]を共同執筆しました。
  この提案では、マークルツリーのフォレストを用いてすべてのUTXOへの参照を蓄積することで、
  ノードがアウトプットを保存するのを回避できるようにします。

  8月以降、提案はいくつかのフィードバックを受け、BIPに番号が割り当てられました:

  * *[BIP181][bip181 utreexo]*: Utreexoアキュムレーターとその操作を説明します。

  * *[BIP182][bip182 utreexo]*: Utreexoアキュムレーターを使ってブロックとトランザクションを検証するルールを定義します。

  * *[BIP183][bip183 utreexo]*: 使用されるUTXOを確認する包含証明をノードが交換するために必要な変更を定義します。

{:#minfeerate}

- **<!--lowering-the-minimum-relay-feerate-->最小リレー手数料率の引き下げ:**
  最小トランザクションリレー手数料率の引き下げについて過去数年間で[何度か議論された][news340 lowering feerates]後、
  6月下旬に、一部のマイナーが突然、デフォルトの最小リレー手数料率である
  1 sat/vbyteを下回る手数料のトランザクションをブロックに含め始めました。
  7月末までに、[ハッシュレートの85%][mononautical 85]がより低い最小手数料率を採用し、
  ノードオペレーターが手動でより低い制限を設定したことにより、低手数料率のトランザクションが
  （信頼性は低いものの）自然にネットワーク上で伝播していました。8月中旬までに、
  [承認済みトランザクションの30%以上][mononautical 32]が1 sat/vbyteを下回る手数料率でした。
  Bitcoinプロトコルの開発者たちは、低手数料率のトランザクションの欠落率の高さが
  [コンパクトブロックの再構築率の低下を引き起こしている][0xb10c delving]ことを観察し、
  デフォルトの最小リレー手数料率の調整を[提案しました][news366 lower feerate]。
  Bitcoin Core 29.1リリースは、9月初旬にデフォルトの最小リレー手数料率を0.1 sat/vbyteに引き下げました。

{:#templatesharing}

- **<!--peer-block-template-sharing-->ピアブロックテンプレートの共有:**
  Anthony Townsは、ピア間でmempoolポリシーが異なる環境において、
  コンパクトブロックの再構築の有効性を向上させる[方法][news366 templ share]を提案しました。
  この提案により、フルノードはピアにブロックテンプレートを送信でき、
  ピアは自身のmempoolポリシーによって拒否されるはずのトランザクションをキャッシュできるようになります。
  提供されるテンプレートには、[コンパクトブロックリレー][topic compact block relay]で使用されるのと
  同じ形式でエンコードされたトランザクション識別子が含まれています。

  その後8月に、Townsはブロックテンプレート共有の提案を正式に[議論する][news368 templ share]ために
  [BIPs #1937][]を公開しました。議論中、
  複数の開発者がプライバシーと潜在的なノードフィンガープリンティングについての懸念を提起しました。
  10月、Townsはこれらの懸念事項に対処し文書を改良するために[ドラフト][news376
  templ share]を[BINANA（Bitcoin Inquisition Numbers and Names Authority）][binana
  repo]リポジトリに移動することを決めました。ドラフトには[BIN-2025-0002][bin]が付与されました。

{:#fuzzing}

- **BitcoinとLN実装の差分ファジング:** Bruno Garciaは、
  Bitcoinとライトニングの実装およびライブラリのファズテストを実行するライブラリである
  [bitcoinfuzz][]の[進捗と得られた結果][news369 fuzz]についてアップデートしました。
  このライブラリを使用して、開発者たちはbtcd、rust-bitcoin、rust-miniscript、LND
  などのBitcoin関連プロジェクトで35件以上のバグを報告しました。

  Garciaはまた、エコシステムにおける差分ファジングの重要性を強調しました。
  開発者たちは、ファジングをまったく実装していないプロジェクトのバグを発見し、
  Bitcoin実装間の不一致を検出し、ライトニング仕様のギャップを見つけることができます。

  最後に、Garciaはメンテナーに対して、より多くのプロジェクトをbitcoinfuzzに統合し、
  差分ファジングのサポートを拡大することを奨励し、プロジェクトの将来の開発に向けた方向性を提示しました。

<div markdown="1" class="callout" id="stratumv2">

## 2025年のまとめ: Stratum v2

[Stratum v2][topic pooled mining]は、マイナーとマイニングプール間で使われているオリジナルの
Stratumプロトコルを置き換えるために設計されたマイニングプロトコルです。
重要な利点の1つは、個々のプールメンバーがブロックに含めるトランザクションを選択できるようにすることで、
トランザクションの選択を独立したマイナーに分散させることにより、Bitcoinの検閲耐性を向上させることです。

2025年を通して、Bitcoin CoreはStratum v2実装をより良くサポートするためのいくつかの更新をしました。
年初のいくつかの改善は、マイニングRPCに焦点を当て、ブロックテンプレートの構築と検証に有用な
`nBits`、`target`、`next`フィールドでRPCを[アップグレード][news339 sv2fields]しました。

最も重要な作業は、Bitcoin Coreの実験的なプロセス間通信（IPC）インターフェースに焦点を当てたものです。
このインターフェースにより、外部のStratum v2サービスがより遅いJSON-RPCインターフェースを使用せずに
Bitcoin Coreのブロック検証とやりとりできるようになります。
`BlockTemplate`インターフェースに新しい[`waitNext()`][news346 waitnext]メソッドが導入され、
チェーンの先端が変更された際、またはmempool手数料が大幅に増加した際のみ新しいテンプレートを返すようになり、
不要なテンプレート生成が削減されました。次に[`checkBlock`][news360 checkblock]が追加され、
プールがIPC経由でマイナー提供のテンプレートを検証できるようになりました。
IPCはデフォルトで[有効化され][news369 ipc]、新しい`bitcoin-node`およびその他のマルチプロセスバイナリが
リリースビルドに追加されました。増加するバイナリを簡単に発見して起動するための新しい`bitcoin`ラッパー実行ファイルが
[追加され][news357 wrapper]、その後自動マルチプロセス選択が[実装され][news374 ipcauto]、
`-m`起動フラグが不要になりました。今年のIPCの改良は、
マルチプロセスログの[CPU消費を削減し][news377 ipclog]、IPCを介して送信されたブロックの
witnessコミットメントが再検証されることを保証することで[締めくくられました][news381 witness]。

10月にリリースされた[Bitcoin Core 30.0][news376 30]は、昨年最初に[導入された][news323
miningipc]実験的なIPCマイニングインターフェースを含む最初のリリースとなりました。

6月、StarkWareはブロックのトランザクションを明かすことなく
ブロックの手数料が有効なテンプレートに属していることを証明するために、
STARK証明を使用して改良されたStratum v2クライントを[デモしました][news359 starkware]。
またStratum v2ベースの2つの新しいマイニングプールもローンチされました。
マイニングシェアを[ecash][topic ecash]トークンで表す[Hashpool][news346 hashpool]と、
ソロマイニングからプールマイニングへの拡張した[DMND][news346 dmnd]です。

</div>

## 9月

{:#simplicity}

- **<!--details-about-the-design-of-simplicity-->Simplicityの設計に関する詳細:** Liquid Network上での[Simplicity][topic simplicity]のリリース後、
  Russell O'Connorは言語の背後にある[哲学と設計][simplicity 370]について議論するために
  Delving Bitcoinに3つの投稿をしました:

  * *[パート I][simplicity I post]* では、基本的な操作を複雑なものに変換するための3つの主な合成形式を検討しています。

  * *[パート II][simplicity II post]* では、Simplicityの型システムコンビネーターと基本式について深く掘り下げています。

  * *[パート III][simplicity III post]* では、計算的なSimplicityコンビネーターのみを使用して、
    ビットから暗号操作までの論理演算を構築する方法を説明しています。

  9月以降、Delving Bitcoinにさらに2つの投稿が公開されました, [パート
  IV][simplicity IV post]は副作用について説明し、[パート V][simplicity V
  post]はプログラムとアドレスを扱っています。

{:#eclipseattacks}

- **BGPインターセプションを使用した分断とエクリプス攻撃:** cedarcticは、
  フルノードが正直なピアに接続できないようにするために使用される可能性がある
  BGP（Border Gateway Protocol）の欠陥についてDelving Bitcoinに[投稿しました][Cedarctic post]。
  これによりネットワークの分断や[エクリプス攻撃][eclipse attack]が可能になる可能性があります。
  cedarcticはいくつかの緩和策を説明し、議論に参加した他の開発者たちは他の緩和策や攻撃を監視する方法を説明しました。

<div markdown="1" class="callout" id="releases">

## 2025年のまとめ: 人気の基盤プロジェクトのメジャーリリース

- [BDK wallet-1.0.0][]は、このライブラリの最初のメジャーリリースとなりました。
  元の`bdk`クレートは安定したAPIを持つ`bdk_wallet`に改名され、
  下位レイヤーのモジュールは独立したクレートに抽出されました。

- [LDK v0.1][]は、LSPSのチャネル開設ネゴシエーションプロトコルの両側のサポート、
  [BIP353][]のHuman Readable Names解決および、単一チャネルの強制閉鎖時に複数の
  [HTLC][topic htlc]を解決する際のオンチェーン手数料コストの削減を追加しました。

- [Core Lightning 25.02][]は、デフォルトでオフに設定された
  [ピアストレージ][topic peer storage]のサポートを追加しました。

- [Eclair v0.12.0][]は、[BOLT12 オファー][topic offers]の作成と管理のサポート、
  [RBF][topic rbf]をサポートする新しいチャネル閉鎖プロトコル、
  [ピアストレージ][topic peer storage]を介してピアのために少量のデータを保存するサポートを追加しました。

- [BTCPay Server 2.1.0][]は、[RBF][topic rbf]と[CPFP][topic cpfp]による手数料の引き上げのいくつかの改善、
  すべての署名者がBTCPay Serverを使用している場合にマルチシグより良いフロー、
  いくつかのアルトコインのユーザーに対する破壊的な変更を追加しました。

- [Bitcoin Core 29.0][]は、UPnP機能（過去のいくつかのセキュリティ脆弱性の要因）を
  NAT-PMPオプションに置き換え、[パッケージリレー][topic package relay]のための
  オーファーントランザクションの親の取得を改善し、マイナーの[タイムワープ][topic time warp]回避が改善され、
  ビルドシステムが`automake`から`cmake`に移行されました。

- [LND 0.19.0-beta][]は、協調閉鎖用の新しいRBFベースの手数料の引き上げを追加しました。

- [Core Lightning 25.05][]は、Eclairと互換性のある実験的な[スプライシング][topic splicing]をサポートし、
  デフォルトでピアストレージを有効にしました。

- [BTCPay Server 2.2.0][]は、ウォレットポリシーと[miniscript][topic miniscript]をサポートしました。

- [Core Lightning v25.09][]は、[BIP353][]アドレスと[オファー][topic offers]への支払いのための
  `xpay`コマンドをサポートしました。

- [Eclair v0.13.0][]は、[Simple Taproot Channel][topic simple taproot channels]の初期実装、
  最近の仕様の更新に基づく[スプライシング][topic splicing]の改良、より良いBOLT12のサポートを追加しました。

- [Bitcoin Inquisition 29.1][]は、複数の[コベナンツ][topic covenants]提案の一部である
  `OP_INTERNALKEY` opcodeをサポートしました。

- [Bitcoin Core 30.0][]は、複数のデータキャリア（OP_RETURN）アウトプットを標準とし、
  デフォルトの`datacarriersize`を100,000に引き上げ、デフォルトの
  [最小リレー手数料率][topic default minimum transaction relay feerates]を0.1 sat/vbyteに設定し、
  [Stratum v2][topic pooled mining]統合用の実験的なIPCマイニングインターフェースを追加し、
  レガシーウォレットの作成またはロードのサポートを削除しました。レガシーウォレットは、
  [ディスクリプター][topic descriptors]ウォレット形式に移行できます。

- [Core Lightning v25.12][]は、[BIP39][]ニーモニックシードフレーズを新しいデフォルトのバックアップ方法として追加し、
  実験的に[JITチャネル][topic jit channels]をサポートしました。

- [LDK 0.2][]は、（実験的に）[スプライシング][topic splicing]をサポートし、
  [非同期支払い][topic async payments]のための静的インボイスの提供/支払いおよび、
  [エフェメラルアンカー][topic ephemeral anchors]を使用した
  [ゼロ手数料コミットメント][topic v3 commitments]チャネルをサポートしました。

</div>

## 10月

{:#arbdata}

- **<!--discussions-about-arbitrary-data-->任意のデータに関する議論:**
  10月の議論では、Bitcoinトランザクションへの任意のデータの埋め込みと、
  その目的でUTXOセットを使用することの限界について長年の疑問が再検討されました。
  [ある分析では][news375 arb data]、制限的なBitcoinトランザクションルールのセットの下でも、
  UTXOにデータを保存する際の理論的な制約が検証されました。

  年末までのその後の[議論][news379 arb data]では、データキャリアトランザクションに対する
  コンセンサス制限を検討すべきかどうかに焦点が当てられました。

{:#channeljamming}

- **<!--channel-jamming-mitigation-simulation-results-and-updates-->チャネルジャミング緩和のシミュレーション結果とアップデート:**
  Carla Kirk-Cohenは、Clara Shikhelmanとelnoshと共同で、更新したレピュテーションアルゴリズムでの
  [ライトニングジャミングシミュレーションの結果][channel jamming results]を投稿しました。
  更新内容には、送信チャネルのレピュテーションの追跡と、受信チャネルのリソース制限の追跡が含まれています。
  これらの新しい更新によって、[リソース][channel jamming resource]攻撃や、
  [シンク][channel jamming sink]攻撃に対する防御力が依然として有効であることが確認されました。
  この一連の更新とシミュレーションを経て、彼らは[チャネルジャミング攻撃][channel jamming attack]の緩和策が
  実装に十分なポイントに達したと感じています。

## 11月

{:#secpperformance}

- **OpenSSLとlibsecp256k1におけるECDSA署名検証のパフォーマンス比較:**
  Bitcoin CoreがOpenSSLからlibsecp256k1に移行してから10年経ち、Sebastian
  Falbesonerは、署名検証における両暗号ライブラリの性能を比較したベンチマーク分析を[投稿しました][openssl vs libsecp256k1]。
  libsecp256k1は、2015年にBitcoin Coreのために特別に作成され、当時既に2.5倍から5.5倍高速でした。
  Falbesonerは、libsecp256k1が改良を続ける一方でOpenSSLのsecp256k1パフォーマンスは停滞しているため、
  その差は8倍以上に広がっていることを発見しました。
  これは、この曲線がBitcoin以外ではあまり重要ではないことを考えると驚くべきことではありません。

  この議論の中で、libsecp256k1の作者であるPieter Wuilleは、
  ベンチマークには固有のバイアスが存在することを指摘しています。
  すべてのバージョンは最新のハードウェアとコンパイラでテストされていますが、
  過去の最適化は当時のハードウェアとコンパイラを対象としていました。

{:#stalerates}

- **<!--modeling-stale-rates-by-propagation-delay-and-mining-centralization-->伝播遅延とマイニングの集中化によるステイル率のモデル化:**
  Antoine Poinsotは、ブロックの伝播遅延がどのようにして大規模マイナーに体系的に有利に働くかを分析して
  Delving Bitcoinに[投稿しました][Antoine post]。彼はブロックAがステイルになる（古くなる）2つのシナリオをモデル化しました。
  最初のシナリオは、競合するブロックBがAより先に発見され、先に伝播するというもの。
  2つめは、BはAの直後に発見されるものの、同じマイナーが次のブロックも発見するというもの。
  最初のシナリオのほうが可能性が高く、マイナーは自分のブロックを早くブロードキャストすることよりも、
  他者のブロックを早く受信することからより多くの利益を得ることを示唆しています。

  Poinsotは、ステイル率が伝播遅延とともに増加し、小規模マイナーに不均衡に影響することを示しました。
  彼は、10秒の伝播遅延で、年間9100万ドルを稼ぐ5 EH/sの事業者が、最小のプールではなく最大のプールに接続することで、
  約10万ドルの追加収益を得られることを発見しました。マイニングは薄いマージンで運営されているため、
  小さな収益の差が大きな利益への影響に転換する可能性があります。

{:#bip3}

- **BIP3とBIPプロセス:** 2025年、更新されたBIPプロセス提案の作業が大幅に発展しました。
  BIP3は1月に番号が[割り当てられ][news341 bip3 assigned]、2月に公開され、4月にProposedに進みました。
  さらなるレビューの後、いくつかの更新が行われ、SPDXライセンス表現が導入され、
  一部のPreambleヘッダーが更新され、いくつかの明確化が提案に組み込まれました。
  11月、Murchは読者に対して提案を更に4週間以内にレビューし、BIP3を有効化すべきかどうかコメントするよう求めることで、
  提案の[有効化を動議しました][news382 motion to activate bip3]。その後のレビューの殺到により、
  さらにいくつかの改善と、BIPの作成におけるLLMの使用を禁止する物議を醸したガイダンスの取り消しが行われました。
  年末を迎えるにあたり、すべてのレビューが対処され、BIP3は再び有効化のための[ラフコンセンサス][bip3 feedback addressed]を求めています。

{:#kernelapi}

- **Bitcoin Kernel C APIの導入:** [Bitcoin Core #30595][news380 kernel]は、
  [`bitcoinkernel`][Bitcoin Core #27587]のAPIとして機能するCのヘッダーを導入し、
  外部プロジェクトが再利用可能なCのライブラリを介してBitcoin Coreのブロック検証と
  chainstateロジックとインターフェースできるようになります。現在は、ブロックに対する操作に限定されており、
  既に廃止された`libbitcoin-consensus`（[ニュースレター #288][news288 lib]参照）と同等の機能を持っています。

  `bitcoinkernel`のユースケースには、代替ノード実装、Electrumサーバーインデックスビルダー、
  [サイレントペイメント][topic silent payments]スキャナー、ブロック分析ツール、
  スクリプト検証アクセラレーターなどが含まれます。[Rust][kernel rust]や[Go][kernel go]、
  [JDK][kernel jdk]、[C#][kernel csharp]、[Python][kernel python]を含むいくつかのバインディングが開発中です。

<div markdown="1" class="callout" id="optech">

## 2025年のまとめ: Bitcoin Optech

Optechは8年目を迎え、今年は50本の週刊[ニュースレター][newsletters]とこの年次特別号を発行しました。
合計で、Optechは今年Bitcoinソフトウェアの研究開発について8万語以上の英語の記事を公開しました。
これは約255ページの書籍に相当します。

各ニュースレターとブログ記事は、中国語、フランス語、日本語や他の言語でも翻訳が行われ、
2025年には合計150以上の翻訳が行われました。

さらに、今年のすべてのニュースレターには[ポッドキャスト][podcast]エピソードが付随し、
音声形式で合計60時間以上、トランスクリプト形式で50万語以上となりました。
Bitcoinの最先端のコントリビューターの多くが番組のゲストとして出演し、
そのうち何人かは複数のエピソードに出演してくれました。2025年には計75人のゲストが出演してくれました:

- 0xB10C
- Abubakar Sadiq Ismail (x3)
- Alejandro De La Torre
- Alex Myers
- Andrew Toth
- Anthony Towns
- Antoine Poinsot (x5)
- Bastien Teinturier (x3)
- Bob McElrath
- Bram Cohen
- Brandon Black
- Bruno Garcia
- Bryan Bishop
- Carla Kirk-Cohen (x2)
- Chris Stewart
- Christian Kümmerle
- Clara Shikhelman
- Constantine Doumanidis
- Dan Gould
- Daniela Brozzoni (x2)
- Daniel Roberts
- Davidson Souza
- David Gumberg
- Elias Rohrer
- Eugene Siegel (x2)
- Francesco Madonna
- Gloria Zhao (x2)
- Gregory Sanders (x2)
- Hunter Beast
- Jameson Lopp (x2)
- Jan B
- Jeremy Rubin (x2)
- Jesse Posner
- Johan Halseth
- Jonas Nick (x4)
- Joost Jager (x2)
- Jose SK
- Josh Doman (x2)
- Julian
- Lauren Shareshian
- Liam Eagen
- Marco De Leon
- Matt Corallo
- Matt Morehouse (x7)
- Moonsettler
- Naiyoma
- Niklas Gögge
- Olaoluwa Osuntokun
- Oleksandr Kurbatov
- Peter Todd
- Pieter Wuille
- PortlandHODL
- Rene Pickhardt
- Robin Linus (x3)
- Rodolfo Novak
- Ruben Somsen (x2)
- Russell O’Connor
- Salvatore Ingala (x4)
- Sanket Kanjalkar
- Sebastian Falbesoner (x2)
- Sergi Delgado
- Sindura Saraswathi (x2)
- Sjors Provoost (x2)
- Steve Myers
- Steven Roose (x3)
- Stéphan Vuylsteke (x2)
- supertestnet
- Tadge Dryja (x3)
- TheCharlatan (x2)
- Tim Ruffing
- vnprc
- Vojtěch Strnad
- Yong Yu
- Yuval Kogman
- ZmnSCPxj (x3)

Optechは、[Human Rights Foundation][]から私達の活動に対して
2万ドルの貢献を再び受けるという幸運に恵まれたことに、感謝しています。この資金は、
Webホスティング、メールサービス、ポッドキャストの文字起こしおよびその他の経費に使用され、
Bitcoinコミュニティへの技術コンテンツの提供を継続・向上させるための費用に充てられます。

### 心からの感謝

376号連続でBitcoin Optechニュースレターの主要執筆者として執筆を続けてきたDave Hardingは、
今年で定期的な貢献から退きました。8年間にわたりニュースレターを支え、Bitcoinに関する教育、
解説、そしてコミュニティの理解を深めてくれたHardingには、感謝してもしきれません。
心から感謝し、彼の今後の活躍を祈念します。

</div>

## 12月

{:#lnsplicing}

- **<!--splicing-->スプライシング:** 12月、[LDK 0.2][]がリリースされ、
  実験的に[スプライシング][topic splicing]がサポートされました。これにより、
  LDK、EclairおよびCore Lightningという3つの主要なライトニング実装でこの機能が利用可能になりました。
  スプライシングにより、ノードはチャネルを閉じることなく資金をチャネルに補充または引き出しできるようになります。

  これにより、LNのスプライシング機能に向けた1年間の大きな進歩が完了することになります。
  Eclairは2月に[公開チャネルでスプライシングをサポートし][news340 eclairsplice]、
  8月には[Simple Taproot Channelでのスプライシング][news368 eclairtaproot]をサポートしました。
  一方、Core Lightningは5月にEclairとの相互運用性を[完成させ][news355 clnsplice]、
  [Core Lightning 25.05][news359 cln2505]でリリースしました。

  この1年間で、LDK実装に必要なすべての要素が追加されました。これには、
  8月の[スプライスアウトのサポート][news369 ldksplice]、
  9月の静止プロトコルとスプライシングの[統合][news370 ldkquiesce]、
  そして0.2リリース前の数多くの改良が含まれます。

  実装チームは、スプライスの伝播を可能にするためにチャネルをクローズとしてマークするまでの遅延時間の増加（
  [BOLTs #1270][]に従って12ブロックから[72ブロック][news359 eclairdelay]に増加）や、
  [BOLTs #1289][]に従って同期されたスプライス状態の[再接続ロジック][news381 clnreconnect]など、
  仕様の詳細についても調整しました。

  ただし、主要な[スプライシングの仕様][bolts #1160]は年末時点でまだマージされておらず、
  引き続き更新が予定されており、相互互換性の問題の解決も続いています。

*上記に名前が挙がったすべてのBitcoinコントリビューター、そして同様に重要な仕事をした多くの方々に、
また一年を通した素晴らしいBitcoinの開発に対して感謝します。Optechのニュースレターは、
1月2日に通常の金曜日発行のスケジュールに戻ります。*

<style>
#optech ul {
  max-width: 800px;
  display: flex;
  flex-wrap: wrap;
  list-style: none;
  padding: 0;
  margin: 0;
  justify-content: center;
}

#optech li {
  flex: 1 0 220px;
  max-width: 220px;
  box-sizing: border-box;
  padding: 5px;
  margin: 5px;
}

@media (max-width: 720px) {
  #optech li {
    flex-basis: calc(50% - 10px);
  }
}

@media (max-width: 360px) {
  #optech li {
    flex-basis: calc(100% - 10px);
  }
}
</style>

{% include snippets/recap-ad.md when="2025-12-23 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1699,1895,1974,2004,27587,33629,1937,32406" %}
[topics index]: /en/topics/
[yirs 2018]: /en/newsletters/2018/12/28/
[yirs 2019]: /ja/newsletters/2019/12/28/
[yirs 2020]: /en/newsletters/2020/12/23/
[yirs 2021]: /ja/newsletters/2021/12/22/
[yirs 2022]: /ja/newsletters/2022/12/21/
[yirs 2023]: /ja/newsletters/2023/12/20/
[yirs 2024]: /ja/newsletters/2024/12/20/

[newsletters]: /ja/newsletters/
[Human Rights Foundation]: https://hrf.org
[openssl vs libsecp256k1]: /ja/newsletters/2025/11/07/#openssl-libsecp256k1-ecdsa
[channel jamming results]: /ja/newsletters/2025/10/24/#channel-jamming-mitigation-simulation-results-and-updates
[channel jamming resource]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-resource-attacks-3
[channel jamming sink]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-manipulation-sink-attack-9
[channel jamming attack]: /en/topics/channel-jamming-attacks/
[erlay optech posts]: /ja/newsletters/2025/02/07/#erlay
[erlay]: /en/topics/erlay/
[erlay knowledge]: https://delvingbitcoin.org/t/erlay-filter-fanout-candidates-based-on-transaction-knowledge/1416
[erlay fanout amount]: https://delvingbitcoin.org/t/erlay-find-acceptable-target-number-of-peers-to-fanout-to/1420
[erlay transaction received]: https://delvingbitcoin.org/t/erlay-define-fanout-rate-based-on-the-transaction-reception-method/1422
[erlay candidate peers]: https://delvingbitcoin.org/t/erlay-select-fanout-candidates-at-relay-time-instead-of-at-relay-scheduling-time/1418
[news358 selfish miner]: /ja/newsletters/2025/06/13/#calculating-the-selfish-mining-danger-threshold
[selfish miner paper]: https://arxiv.org/pdf/1311.0243
[news360 fingerprinting]: /ja/newsletters/2025/06/27/#addr
[news359 bitvm3]: /ja/newsletters/2025/06/20/#bitvm
[delbrag rubin]: https://rubin.io/bitcoin/2025/04/04/delbrag/
[garbled circuits wiki]: https://en.wikipedia.org/wiki/Garbled_circuit
[news369 eagen]: /ja/newsletters/2025/08/29/#garbled-lock
[eagen paper]: https://eprint.iacr.org/2025/1485
[news351 dahlias]: /ja/newsletters/2025/04/25/#secp256k1
[dahlias paper]: https://eprint.iacr.org/2025/692.pdf
[news344 fork guide]: /ja/newsletters/2025/03/07/#bitcoin-forking-guide
[fork guide red]: https://ajtowns.github.io/bfg/research.html
[fork guide pue]: https://ajtowns.github.io/bfg/power.html
[fork guide ie]: https://ajtowns.github.io/bfg/industry.html
[fork guide ir]: https://ajtowns.github.io/bfg/investor.html
[news344 template mrkt]: /ja/newsletters/2025/03/07/#mev
[mevpool gh]: https://github.com/mevpool/mevpool/blob/0550f5d85e4023ff8ac7da5193973355b855bcc8/mevpool-marketplace.md
[news 347 ln fees]: /ja/newsletters/2025/03/28/#ln
[ln fees paper]: https://github.com/JohnLaw2/ln-spam-prevention
[news349 swiftsync]: /ja/newsletters/2025/04/11/#swiftsync
[swiftsync ruben gh]: https://gist.github.com/RubenSomsen/a61a37d14182ccd78760e477c78133cd
[swiftsync rust impl]: https://delvingbitcoin.org/t/swiftsync-speeding-up-ibd-with-pre-generated-hints-poc/1562/18
[news288 lib]: /ja/newsletters/2024/02/07/#bitcoin-core-29189
[kernel rust]: https://github.com/sedited/rust-bitcoinkernel
[kernel go]: https://github.com/stringintech/go-bitcoinkernel
[kernel jdk]: https://github.com/yuvicc/bitcoinkernel-jdk
[kernel csharp]: https://github.com/janb84/BitcoinKernel.NET
[kernel python]: https://github.com/stickies-v/py-bitcoinkernel
[gcc update]: /ja/newsletters/2025/02/07/#updates-to-cleanup-soft-fork-proposal
[gcc bip]: /ja/newsletters/2025/04/04/#bip
[news thikcs]: /ja/newsletters/2025/08/01/#taproot-op-templatehash
[ctv csfs symmetry]: /ja/newsletters/2025/04/04/#ln-symmetry
[ctv csfs arks]: /ja/newsletters/2025/04/04/#ark
[ctv vaults]: /ja/newsletters/2025/04/04/#vault
[ctv dlcs]: /ja/newsletters/2025/04/04/#dlc
[lnhance update]: /ja/newsletters/2025/12/05/#lnhance
[rubin key ladder]: https://rubin.io/bitcoin/2024/12/02/csfs-ctv-rekey-symmetry/
[ctv csfs ptlcs]: /ja/newsletters/2025/07/04/#ptlc-ctv-csfs
[ctv csfs bitvm]: /ja/newsletters/2025/05/16/#op-ctv-op-csfs-bitvm
[ctv csfs letter]: /ja/newsletters/2025/07/04/#ctv-csfs
[gcc impl tests]: /ja/newsletters/2025/11/07/#bip54-test-vector
[ccv bip]: /ja/newsletters/2025/05/30/#bips-1793
[ccv semantics]: /ja/newsletters/2025/04/04/#op-checkcontractverify
[vault withdrawn]: /ja/newsletters/2025/05/16/#bips-1848
[64bit bip]: /ja/newsletters/2025/05/16/#proposed-bip-for-64-bit-arithmetic-in-script-64-bit-bip
[txhash sponsors]: /ja/newsletters/2025/07/04/#op-txhash
[txhash]: /ja/newsletters/2022/02/02/#ctv-apo
[tweakadd]: /ja/newsletters/2025/09/05/#op-tweakadd-bip
[ecmath]: /ja/newsletters/2025/09/05/#tapscript-bip
[gsr bips]: /ja/newsletters/2025/10/03/#draft-bips-for-script-restoration-bip
[transitory cleanups]: /ja/newsletters/2025/01/03/#transitory-soft-forks-for-cleanup-soft-forks
[simplicity 370]: /ja/newsletters/2025/09/05/#simplicity
[simplicity I post]: https://delvingbitcoin.org/t/delving-simplicity-part-three-fundamental-ways-of-combining-computations/1902
[simplicity II post]: https://delvingbitcoin.org/t/delving-simplicity-part-combinator-completeness-of-simplicity/1935
[simplicity III post]: https://delvingbitcoin.org/t/delving-simplicity-part-building-data-types/1956
[simplicity IV post]: https://delvingbitcoin.org/t/delving-simplicity-part-two-side-effects/2091
[simplicity V post]: https://delvingbitcoin.org/t/delving-simplicity-part-programs-and-addresses/2113
[news339 sv2fields]: /ja/newsletters/2025/01/31/#bitcoin-core-31583
[news346 waitnext]: /ja/newsletters/2025/03/21/#bitcoin-core-31283
[news360 checkblock]: /ja/newsletters/2025/06/27/#bitcoin-core-31981
[news359 starkware]: /ja/newsletters/2025/06/20/#stratum-v2-stark
[news369 ipc]: /ja/newsletters/2025/08/29/#bitcoin-core-31802
[news374 ipcauto]: /ja/newsletters/2025/10/03/#bitcoin-core-33229
[news376 30]: /ja/newsletters/2025/10/17/#bitcoin-core-30-0
[news377 ipclog]: /ja/newsletters/2025/10/24/#bitcoin-core-33517
[news381 witness]: /ja/newsletters/2025/11/21/#bitcoin-core-33745
[news346 hashpool]: /ja/newsletters/2025/03/21/#hashpool-v0-1
[news323 miningipc]: /ja/newsletters/2024/10/04/#bitcoin-core-30510
[news340 richter ggt]: /ja/newsletters/2025/02/07/#discovery-of-previous-research-for-finding-optimal-cluster-linearization
[news341 pr-review-club txgraph]: /ja/newsletters/2025/02/14/#bitcoin-core-pr-review-club
[news352 wuille linearization techniques]: /ja/newsletters/2025/05/02/#comparison-of-cluster-linearization-techniques
[news377 ismail template improvement]: /ja/newsletters/2025/10/24/#mempool
[news382 cluster mempool completed]: /ja/newsletters/2025/11/28/#bitcoin-core-33629
[news bip360 update]: /ja/newsletters/2025/03/07/#bip360-p2qrh-pay-to-quantum-resistant-hash
[news qr sha]: /ja/newsletters/2025/04/04/#sha256-utxo
[news qr cr]: /ja/newsletters/2025/07/04/#commit-reveal-function-for-post-quantum-recovery
[news qr lopp1]: /ja/newsletters/2025/04/04/#should-vulnerable-bitcoins-be-destroyed
[news qr lopp2]: /ja/newsletters/2025/08/01/#migration-from-quantum-vulnerable-outputs
[news qr cruz]: /ja/newsletters/2025/04/04/#bip
[news qr corallo]: /ja/newsletters/2025/01/03/#quantum-computer-upgrade-path
[rubin lamport]: https://gnusha.org/pi/bitcoindev/CAD5xwhgzR8e5r1e4H-5EH2mSsE1V39dd06+TgYniFnXFSBqLxw@mail.gmail.com/
[lamport]: https://ja.wikipedia.org/wiki/ランポート署名
[conduition sphincs]: /ja/newsletters/2025/12/05/#slh-dsa-sphincs
[abdel stark]: /ja/newsletters/2025/11/07/#bitcoin-script-stark
[news364 quantum primatives]: /ja/newsletters/2025/07/25/#bitcoin
[news365 quantum taproot]: /ja/newsletters/2025/08/01/#taproot
[news357 quantum report]: /ja/newsletters/2025/06/06/#quantum-computing-report
[news qr agg]: /ja/newsletters/2025/11/07/#post-quantum-signature-aggregation
[nick paper tweet]: https://x.com/n1ckler/status/1998407064213704724
[hash-based signature schemes]: https://eprint.iacr.org/2025/2203.pdf
[news335 chilldkg]: /ja/newsletters/2025/01/03/#chilldkg
[news offchain dlc]: /ja/newsletters/2025/01/24/#dlc
[news dlc channels]: /ja/newsletters/2023/07/19/#wallet-10101-beta-testing-pooling-funds-between-ln-and-dlcs-10101-ln-dlc
[Cedarctic post]: /ja/newsletters/2025/09/19/#bgp
[eclipse attack]: /en/topics/eclipse-attacks/
[Antoine post]: /ja/newsletters/2025/11/21/#modeling-stale-rates-by-propagation-delay-and-mining-centralization
[news340 lowering feerates]: /ja/newsletters/2025/02/07/#discussion-about-lowering-the-minimum-transaction-relay-feerate
[mononautical 85]: https://x.com/mononautical/status/1949452588992414140
[mononautical 32]: https://x.com/mononautical/status/1958559008698085551
[news366 lower feerate]: /ja/newsletters/2025/08/08/#continued-discussion-about-lowering-the-minimum-relay-feerate
[news315 compact blocks]: /ja/newsletters/2024/08/09/#statistics-on-compact-block-reconstruction
[news339 compact blocks]: /ja/newsletters/2025/01/31/#updated-stats-on-compact-block-reconstruction
[news365 compact blocks]: /ja/newsletters/2025/08/01/#testing-compact-block-prefilling
[news382 compact blocks]: /ja/newsletters/2025/11/28/#stats-on-compact-block-reconstructions-updates
[news368 monitoring]: /ja/newsletters/2025/08/22/#peer-observer
[28.0 wallet guide]: /ja/bitcoin-core-28-wallet-integration-guide/
[news340 lneas]: /ja/newsletters/2025/02/07/#tradeoffs-in-ln-ephemeral-anchor-scripts-ln
[news341 lneas]: /ja/newsletters/2025/02/14/#ln
[news380 kernel]: /ja/newsletters/2025/11/14/#bitcoin-core-30595
[news357 wrapper]: /ja/newsletters/2025/06/06/#bitcoin-core-31375
[news346 dmnd]: /ja/newsletters/2025/03/21/#dmnd
[news341 bip3 assigned]: /ja/newsletters/2025/02/14/#bip
[news382 motion to activate bip3]: /ja/newsletters/2025/11/28/#bip3
[bip3 feedback addressed]: https://groups.google.com/g/bitcoindev/c/j4_toD-ofEc/m/8HTeL2_iAQAJ
[delving random]: https://delvingbitcoin.org/t/emulating-op-rand/1409
[random poc]: https://github.com/distributed-lab/op_rand
[waxwing random]: /ja/newsletters/2025/02/14/#suggested
[ok random]: /ja/newsletters/2025/02/07/#op-rand
[rl random]: /ja/newsletters/2025/03/14/#xor
[dh random]: /ja/newsletters/2025/02/14/#asked
[jt delegation]: /ja/newsletters/2025/07/25/#chain-code-withholding-for-multisig-scripts
[news335 coinjoin]: /ja/newsletters/2025/01/03/#coinjoin
[news333 coinjoin]: /ja/newsletters/2024/12/13/#wasabi
[news340 htlcbug]: /ja/newsletters/2025/02/07/#ldk
[news340 htlcfix]: /ja/newsletters/2025/02/07/#ldk-3556
[news339 ldk]: /ja/newsletters/2025/01/31/#ldk
[news339 cycling]: /ja/newsletters/2025/01/31/#replacement-cycling-attacks-with-miner-exploitation
[news346 bolts]: /ja/newsletters/2025/03/21/#bolts-1233
[news344 lnd]: /ja/newsletters/2025/03/07/#lnd
[news346 checkpoints]: /ja/newsletters/2025/03/21/#bitcoin-core-31649
[news353 bip30]: /ja/newsletters/2025/05/09/#bip30
[news354 32bit]: /ja/newsletters/2025/05/16/#bitcoin-core
[news364 lnd]: /ja/newsletters/2025/07/25/#lnd-dos
[news319 lnd]: /ja/newsletters/2024/09/06/#lnd-9009
[news159 32bit]: /ja/newsletters/2021/07/28/#bitcoin-core-22387
[news314 32bit]: /ja/newsletters/2024/08/02/#addr
[news373 eclair]: /ja/newsletters/2025/09/26/#eclair
[news378 four]: /ja/newsletters/2025/10/31/#bitcoin-core-4
[news361 four]: /ja/newsletters/2025/07/04/#bitcoin-core-32819
[news363 four]: /ja/newsletters/2025/07/18/#bitcoin-core-32604
[news367 four]: /ja/newsletters/2025/08/15/#bitcoin-core-33050
[news383 nbitcoin]: /ja/newsletters/2025/12/05/#nbitcoin
[news384 lnd]: /ja/newsletters/2025/12/12/#lnd-0-19-0
[bdk wallet-1.0.0]: /ja/newsletters/2025/01/03/#bdk-wallet-1-0-0
[ldk v0.1]: /ja/newsletters/2025/01/17/#ldk-v0-1
[core lightning 25.02]: /ja/newsletters/2025/03/07/#core-lightning-25-02
[eclair v0.12.0]: /ja/newsletters/2025/03/14/#eclair-v0-12-0
[btcpay server 2.1.0]: /ja/newsletters/2025/04/11/#btcpay-server-2-1-0
[bitcoin core 29.0]: /ja/newsletters/2025/04/18/#bitcoin-core-29-0
[lnd 0.19.0-beta]: /ja/newsletters/2025/05/23/#lnd-0-19-0-beta
[core lightning 25.05]: /ja/newsletters/2025/06/20/#core-lightning-25-05
[btcpay server 2.2.0]: /ja/newsletters/2025/08/08/#btcpay-server-2-2-0
[core lightning v25.09]: /ja/newsletters/2025/09/05/#core-lightning-v25-09
[eclair v0.13.0]: /ja/newsletters/2025/09/12/#eclair-v0-13-0
[bitcoin inquisition 29.1]: /ja/newsletters/2025/10/10/#bitcoin-inquisition-29-1
[bitcoin core 30.0]: /ja/newsletters/2025/10/17/#bitcoin-core-30-0
[core lightning v25.12]: /ja/newsletters/2025/12/05/#core-lightning-v25-12
[ldk 0.2]: /ja/newsletters/2025/12/05/#ldk-0-2
[news340 eclairsplice]: /ja/newsletters/2025/02/07/#eclair-2968
[news368 eclairtaproot]: /ja/newsletters/2025/08/22/#eclair-3103
[news355 clnsplice]: /ja/newsletters/2025/05/23/#core-lightning-8021
[news359 cln2505]: /ja/newsletters/2025/06/20/#core-lightning-25-05
[news369 ldksplice]: /ja/newsletters/2025/08/29/#ldk-3979
[news370 ldkquiesce]: /ja/newsletters/2025/09/05/#ldk-4019
[news359 eclairdelay]: /ja/newsletters/2025/06/20/#eclair-3110
[news381 clnreconnect]: /ja/newsletters/2025/11/21/#core-lightning-8646
[bolts #1270]: https://github.com/lightning/bolts/pull/1270
[bolts #1289]: https://github.com/lightning/bolts/pull/1289
[bolts #1160]: https://github.com/lightning/bolts/pull/1160
[news366 utreexo]: /ja/newsletters/2025/08/08/#utreexo-bip
[bip181 utreexo]: https://github.com/utreexo/biptreexo/blob/main/bip-0181.md
[bip182 utreexo]: https://github.com/utreexo/biptreexo/blob/main/bip-0182.md
[bip183 utreexo]: https://github.com/utreexo/biptreexo/blob/main/bip-0183.md
[news366 templ share]: /ja/newsletters/2025/08/08/#mempool
[news368 templ share]: /ja/newsletters/2025/08/22/#bip
[news376 templ share]: /ja/newsletters/2025/10/17/#continued-discussion-of-block-template-sharing
[binana repo]: https://github.com/bitcoin-inquisition/binana
[bin]: https://github.com/bitcoin-inquisition/binana/blob/master/2025/BIN-2025-0002.md
[news369 fuzz]: /ja/newsletters/2025/08/29/#bitcoin-ln
[bitcoinfuzz]: https://github.com/bitcoinfuzz/bitcoinfuzz
[news375 arb data]: /ja/newsletters/2025/10/10/#utxo
[news379 arb data]: /ja/newsletters/2025/11/07/#multiple-discussions-about-restricting-data
[news 338]: /ja/newsletters/2025/01/24/#bitcoin-core-31397
[news352 OR debate]: /ja/newsletters/2025/05/02/#bitcoin-core-op-return
[0xb10c delving]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/35