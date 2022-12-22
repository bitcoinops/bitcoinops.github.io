---
title: 'Bitcoin Optech Newsletter #231: 2022年振り返り特別号'
permalink: /ja/newsletters/2022/12/21/
name: 2022-12-21-newsletter-ja
slug: 2022-12-21-newsletter-ja
type: newsletter
layout: newsletter
lang: ja

excerpt: >
  このOptechニュースレターの特別版では、2022年のBitcoinの注目すべき動向についてまとめています。
---
{{page.excerpt}} これは、[2018年][yirs 2018]、[2019年][yirs 2019]、[2020年][yirs 2020]、[2021年][yirs 2021]の
まとめの続編です。

## 内容

* 1月
  * [ステートレスインボイス](#stateless-invoices)
  * [法的防衛基金](#defense-fund)
* 2月
  * [手数料スポンサーシップ](#fee-sponsorship)
  * [ファントムノードペイメント](#phantom-node-payments)
* 3月
  * [LNの経路探索](#ln-pathfinding)
  * [ゼロ承認チャネル](#zero-conf-channels)
* 4月
  * [サイレントペイメント](#silent-payments)
  * [Taro](#taro)
  * [量子安全な鍵交換](#quantum-safe-keys)
* 5月
  * [MuSig2](#musig2)
  * [パッケージリレー](#package-relay)
  * [Bitcoin Kernel Library](#libbitcoinkernel)
* 6月
  * [LNプロトコル開発者ミーティング](#ln-meet)
* 7月
  * [オニオンメッセージのレート制限](#onion-message-limiting)
  * [Miniscriptディスクリプター](#miniscript-descriptors)
* 8月
  * [LNの対話型のデュアル・ファンディング](#dual-funding)
  * [Channelジャミング攻撃の緩和](#jamming)
  * [DLCのためのBLS署名](#dlc-bls)
* 9月
  * [手数料レートカード](#fee-ratecards)
* 10月
  * [バージョン3トランザクションリレー](#v3-tx-relay)
  * [非同期支払い](#async-payments)
  * [ブロックのパースバグ](#parsing-bugs)
  * [ZKロールアップ](#zk-rollups)
  * [バージョン2の暗号化P2Pトランスポートプロトコル](#v2-transport)
  * [Bitcoinプロトコル開発者のミーティング](#core-meet)
* 11月
  * [ファットエラーメッセージ](#fat-errors)
* 12月
  * [LNプロトコルの変更](#ln-mod)
* 注目のまとめ
  * [Replace-By-Fee](#rbf)
  * [人気のあるインフラストラクチャプロジェクトのメジャーリリース](#releases)
  * [Bitcoin Optech](#optech)
  * [ソフトフォークの提案](#softforks)

## 1月

{:#stateless-invoices}
LDKは1月に[ステートレスインボイス][topic stateless invoices]の実装を[マージし][news181 ldk1177]、
支払いが成功しない限りインボイスに関するデータを一切保存することなく無限にインボイスを生成できるようにしました。
ステートレスインボイス自体は2021年9月に提案され、LDKの実装は提案された方法とは異なりますが、
同じ目標を達成し、LNプロトコルの変更も必要ありません。同じ月末に、LNの仕様の[更新][news182 bolts912]が
マージされ、他の種類のステートレスインボイスのサポートが可能になり、
少なくとも一部のサポートが[Eclair][news183 stateless]、[Core Lightning][news195 stateless]、
[LND][news196 stateless]に追加されました。

{:#defense-fund}
また1月に、Jack DorseyとAlex Morcos、Martin Whiteによって
Bitcoin Legal Defense Fundが[発表されました][news183 defense fund]。
これは、「ソフトウェア開発者がBitcoinや関連プロジェクトを積極的に開発することを妨げる
法的問題を最小限に抑えることを目的とした非営利団体」です。

## 2月

{:#fee-sponsorship}
1月に行われた事前署名されたトランザクションに手数料を追加しやすくすることについての[議論][news182 accounts]から、
2月には、Jeremy Rubinの2020年の[トランザクション手数料のスポンサーシップ][topic fee sponsorship]構想が
[再び議論されるようになりました][news188 sponsorship]。その実装にはいくつかの課題が挙げられました。
当面の議論はあまり進展しませんでしたが、同様の目標を達成しつつ、
スポンサーシップと違ってソフトフォークを必要としない手法が10月に[提案される][news231 v3relay]ことになります。

{:#phantom-node-payments}
LDKが[ステートレスインボイス][topic stateless invoices]を早期にサポートしたことで、
*ファントムノードペイメント*と呼ばれる
LNノードの負荷分散を図るための新しく[シンプルな][news188 ldk1199]方法を追加することができました。

{:.center}
![ファントムノードペイメントの図](/img/posts/2022-02-phantom-node-payments.dot.png)

## 3月

{:#ln-pathfinding}
René PickhardtとStefan Richterが2021年に最初に発表したLNの経路探索アルゴリズムが
3月に[更新され][news192 pp]、Pickhardtは、計算効率を大幅に向上させた改善について言及しています。

{:#zero-conf-channels}
[ゼロ承認チャネル][topic zero-conf channels]を可能にする一貫した方法が[定義され][news203 zero-conf]、
実装のサポートが見られるようになりました。3月に、
LDKの関連するSCID（Short Channel IDentifier）*エイリアス*フィールドのサポートから始まり、
[Eclair][news205 scid]、[Core Lightning][news208 scid cln]、[LND][news208 scid lnd]が続きました。

{:.center}
![ゼロ承認チャネルの図](/img/posts/2021-07-zeroconf-channels.png)

<div markdown="1" class="callout" id="rbf">
### 2022年のまとめ<br>Replace-By-Fee

今年は、RBF（[Replace By Fee][topic rbf]）に関して多くの議論といくつかの重要なアクションがありました。
1月のニュースレターでは、Jeremy Rubinによる、元のトランザクションがノードで最初に確認されてからしばらくの間は、
どのトランザクションであってもより高い手数料の代替トランザクションに置き換えることができ、
その期間が経過すると、既存のルールが適用され[BIP125][]をオプトインしたトランザクションのみ置換可能になるという提案を[掲載しました][news181 rbf]。
これにより、マーチャントは置換可能な時間が経過した後も、今と同じように未承認トランザクションを受け入れることができるようになる可能性があります。
さらに重要なことは、セキュリティのために置換可能性に依存しているプロトコルは、
プロトコルのノードやウォッチタワーがトランザクションを最初に確認した後すぐに対応する妥当な機会がある限り、
非オプトインのトランザクションについて心配する必要がないことです。

1月末に、Gloria Zhaoは現在のRBFポリシーの背景や、長年にわたって発見されたいくつかの問題
（[Pinning攻撃][topic transaction pinning]など）、
ポリシーがウォレットのユーザーインターフェースに与える影響の検証および、
いくつかの可能な改善についての説明を[投稿し][news186 rbf]、RBFに関する新しい議論を始めました。
3月初旬に、Zhaoは多くの開発者が行ったRBFに関する2つの議論（1つは対面での議論、
もう1つはオンラインでの議論）の[要約][news191 rbf]をフォローアップしました。

3月にはまた、Larry RuaneがRBFに関連して、トランザクションのtxidの一部となる部分を変更することなく、
トランザクションのwitnessを置き換えることについて[質問を][news193 witrep]投げかけました。

6月、Antoine RiardはBitcoin Coreに`mempoolfullrbf`設定オプションを追加するプルリクエストを[公開しました][news205 rbf]。
このオプションは、[BIP125][]のシグナルを含む場合のみ未承認トランザクションの置換を許可するという
Bitcoin Coreのこれまでの動作がデフォルトに設定されています。
このオプションが別の値に設定されたノードは、置換するトランザクションがBIP125のオプトインシグナルを含まない場合でも、
リレーやマイニングのために置換トランザクションを受け入れるようになります。
Riardはまた、Bitcoin-Devメーリングリストにスレッドを立ち上げ、
この変更について議論を始めました。プルリクエストのほぼすべてのコメントは、
肯定的なもので、メーリングリストでの議論のほとんどは関係のない話題だったため、
プルリクエストが公開されてから約1ヶ月で[マージされた][news208 rbf]のは当然のことでした。

10月、Bitcoin Coreプロジェクトは、`mempoolfullrbf`設定オプションを最初に含むことになる
バージョン24.0のリリース候補の配布を開始しました。
Dario Sneidermanisは、このオプションに関するリリースノートのドラフトを見て、
多くのユーザーやマイナーがこのオプションを有効にしたら、シグナルの無い置換が信頼できるものになるだろうと
Bitcoin-Devメーリングリストに[投稿しました][news222 rbf]。
シグナルの無い置換の信頼性が高くなると、
未承認トランザクションを最終的なものとして受け入れるサービスからの盗難の信頼性も高めることになり、
これらのサービスは動作を変更する必要がでてきます。
議論は、[翌週][news223 rbf]も[翌々週][news224 rbf]も続きました。
Sneidermanisがメーリングリストで最初の懸念を提起してから1ヶ月後、
Suhas Daftuarがこのオプションに対するいくつかの議論を[まとめ][news225 rbf]、
Bitcoin Coreからこのオプションを削除するプルリクエストを公開しました。
他の同様のプルリクエストがそれより前や後に公開されましたが、
Daftuarのプルリクエストはオプションを永久に削除する可能性についての議論の焦点になりました。

Daftuarのプルリクエストでは、`mempoolfullrbf`オプションを維持することに賛成する多くの反論が行われました。
その中には、何人かのウォレット開発者が、BIP125をオプトインしていないにもかかわらず
置換を希望するユーザーに遭遇することがあると指摘したものも含まれています。

11月末までに、DaftuarはPRを閉じ、Bitcoin Coreプロジェクトは`mempoolfullrbf`オプション付きの
バージョン24.0をリリースしました。12月、開発者の0xB10Cは、
BIP125シグナルを含まないトランザクションの置換を監視するウェブサイトを[公開しました][news230 rbf]。
これは、承認されたトランザクションのいずれかが、
`mempoolfullrbf`オプション（もしくは他のソフトウェアの同様の機能）を使用して
フルRBFを有効にするマイナーによって処理された可能性があることを示しています。
この年末、フルRBFは、他のBitcoin CoreのPRやメーリングリストでまだ議論されています。

</div>

## 4月

{:#silent-payments}
4月、Ruben Somsenが[サイレントペイメント][topic silent payments]のアイディアを[提案しました][news194 sp]。
これは、オンチェーンで識別されることのない公開識別子（アドレス）への支払いを可能にし、
[アドレスの再利用][topic output linking]を防止するのに役立つでしょう。
たとえば、アリスは自身のウェブサイトに公開識別子を掲載し、
ボブはそれを新しい一意なBitcoinアドレスに変換します。このアドレスのコインを使用できるのはアリスだけです。
後でキャロルがアリスのウェブサイトにアクセスし、アリスの公開識別子を再利用した場合、
キャロルはアリスへの支払いのために異なるアドレスを導出するでしょう。
このアドレスについて、ボブも他の第三者も、それがアリスのアドレスだと直接判断することはできません。
その後、開発者のW0ltxは、Bitcoin Core用のサイレントペイメントの[実装案][news202 sp]を作成し、
年内に[大幅なアップデート][news214 sp]を行いました。

{:#taro}
Lightning Labsは、ユーザーがBitcoinのブロックチェーン上でビットコインではないトークンの作成と転送に
コミットできるようにするための（以前の提案に基づいた）プロトコル案、Taroを[発表しました][news195 taro]。
Taroは、ルーティング可能なオフチェーン転送のためにLNと一緒に使用されることを意図しています。
LN上のクロスアセット転送に関するこれまでの提案と同様に、支払いを転送するだけの中間ノードは、
Taroのプロトコルや転送されるアセットの詳細を認識する必要はありません。中間ノードは、
他のLN支払いと同じプロトコルを使用してビットコインを転送するだけです。

{:#quantum-safe-keys}
4月にはまた、量子安全な鍵交換についても[議論され][news196 qc]、
将来実現する可能性のある高速な量子コンピューターの攻撃にも[耐えられる][topic quantum resistance]鍵で
保護されたビットコインの受け取りを可能にします。

## 5月

{:#musig2}
[Schnorrのマルチシグ][topic multisignature]を作成するための[MuSig2][topic musig]プロトコルは、
2022年にいくつかの進展が見られました。[提案されたBIP][news195 musig2]は、
5月に重要な[フィードバック][news198 musig2]を受けました。
その後10月に、Yannick SeurinとTim Ruffing、Elliott JinおよびJonas Nickが、
プロトコルのいくつかの使用方法に[脆弱性][news222 musig2]を発見し、
研究者は更新版で修正する予定であると発表しました。

{:#package-relay}
5月にGloria Zhaoが[パッケージリレー][topic package relay]のBIPドラフトを[投稿しました][news201 package relay]。
パッケージリレーは、親トランザクションがノードの動的最小mempool手数料を支払っている場合にのみ、
個々のノードが手数料の引き上げを行う子トランザクションを受け入れるという、
Bitcoin Coreの[CPFPによる手数料の引き上げ][topic cpfp]の重大な問題を修正するものです。
この問題のため、多くのコントラクトプロトコル（現在のLNプロトコルを含む）など、
事前署名されたトランザクションに依存するプロトコルでは、CPFPの信頼性が不十分となります。
パッケージリレーは、親トランザクションと子トランザクションを1つの単位として評価可能にすることで、
この問題を解消します。ただし、[トランザクションのPinning][topic transaction pinning]など、
関連する他の問題は解消されません。6月に、パッケージリレーに関する追加の議論が[行われました][news204 package relay]。

{:#libbitcoinkernel}
5月はまた、Bitcoin Kernel Library Project (libbitcoinkernel)の[最初のマージ][news198 lbk]も行われました。
これは、Bitcoin Coreのコンセンサスコードを可能な限り別のライブラリに分離する試みで、
現在のコードにはまだ非コンセンサスコードが付属しています。
長期的な目標は、コンセンサスコードのみを含むようlibbitcoinkernelを削減することで、
他のプロジェクトがそのコードを使用したり、
監査人がBitcoin Coreのコンセンサスロジックの変更の分析を容易にできるようにすることです。
いくつかの追加のPRが今年中にマージされるでしょう。

<div markdown="1" class="callout" id="releases">
### 2022年のまとめ<br>人気のあるインフラストラクチャプロジェクトのメジャーリリース

- [Eclair 0.7.0][news185 eclair]は、[アンカー・アウトプット][topic anchor outputs]や
  [オニオンメッセージ][topic onion messages]のリレー、運用環境でのPostgreSQLデータベースの使用をサポートしました。

- [BTCPay Server 1.4][news189 btcpay]は、[CPFPによる手数料の引き上げ][topic cpfp]をサポートし、
  LN URLの追加機能を使用できるようになり、さらに複数のUIが改善されました。

- [LDK 0.0.105][news190 ldk]は、ファントムノードペイメントをサポートし、
  確率的な支払い経路探索が改善されました。

- [BDK 0.17.0][news193 bdk]では、ウォレットがオフラインの時でも簡単にアドレスを導出できるようになりました。

- [Bitcoin Core 23.0][news197 bcc]は、新しいウォレットにデフォルトで
  [ディスクリプター][topic descriptors]ウォレットを提供し、
  ディスクリプターウォレットが[Taproot][topic taproot]を使用して[bech32m][topic
  bech32]アドレスへの受信を簡単にサポートできるようにしました。
  また、デフォルト以外のTCP/IPポートのサポートを強化し、
  [CJDNS][]ネットワークオーバーレイが使用できるようになりました。

- [Core Lightning 0.11.0][news197 cln]は、同じピアへの複数のアクティブチャネルと、
  [ステートレスインボイス][topic stateless invoices]への支払いをサポートしました。

- [Rust Bitcoin 0.28][news197 rb]では、[Taproot][topic taproot]がサポートされ、
  [PSBT][topic psbt]などの関連APIが改善されました。

- [BTCPay Server 1.5.1][news198 btcpay]は、新しいメインページダッシュボードや
  新しい転送処理機能、プル支払いと払い戻しを自動的に承認できる機能を追加しました。

- [LDK 0.0.108および0.0.107][news205 ldk]は、
  [ラージチャネル][topic large channels]と[ゼロ承認チャネル][topic zero-conf channels]をサポートし、
  モバイルクライアントがサーバーからネットワークのルーティング情報（ゴシップ）を同期できるようにするコードを提供しました。

- [BDK 0.19.0][news205 bdk]は、[ディスクリプター][topic descriptors]、
  [PSBT][topic psbt]およびその他のサブシステムを介した[Taproot][topic taproot]の実験的なサポートを追加しました。
  また、新しい[コイン選択][topic coin selection]アルゴリズムも追加されました。

- [LND 0.15.0-beta][news206 lnd]は、[ステートレスインボイス][topic stateless invoices]のために、
  他のプログラム（およびLNDの将来のバージョン）で使用できるインボイスのメタデータをサポートし、
  [P2TR][topic taproot]のkey-pathで使用可能なアウトプットへのビットコインの送受信のため内部ウォレットのサポートおよび、
  実験的な[MuSig2][topic musig]のサポートを追加しました。

- [Rust Bitcoin 0.29][news213 rb]は、[コンパクトブロックリレー][topic
  compact block relay]のデータ構造（[BIP152][]）を追加し、
  [Taproot][topic taproot]と[PSBT][topic psbt]のサポートが改善されました。

- [Core Lightning 0.12.0][news214 cln]は、新しい`bookkeeper`プラグイン、
  `commando`プラグインを追加し、[Static Channel Backup][topic static channel backups]をサポートしました。
  さらに、ピアがあなたのノードに[ゼロ承認チャネル][topic zero-conf channels]を開くことを明示的に許可するようになりました。

- [LND 0.15.1-beta][news215 lnd]は、[ゼロ承認チャネル][topic zero-conf channels]と、
  チャネルエイリアスのサポートを追加し、あらゆるところで[Taproot][topic taproot]アドレスを使用するようになりました。

- [LDK 0.0.111][news217 ldk]は、[オニオンメッセージ][topic onion messages]の作成、
  受信、リレーをサポートしました。

- [Core Lightning 22.11][news229 cln]は、新しいバージョン番号体系を使い始め、
  新しいプラグインマネージャーを追加しました。

- [libsecp256k1 0.2.0][news230 libsecp]は、Bitcoin関連の暗号処理で広く使用されている
  このライブラリの最初のタグ付きリリースです。

- [Bitcoin Core 24.0.1][news230 bcc]は、
  ノードのRBF（[Replace-By-Fee][topic rbf]）ポリシーを設定するオプションや、
  単一のトランザクションでウォレットのすべての資金を簡単に送信できる新しい`sendall`RPC、
  トランザクションがウォレットにどう影響するかを確認するために使用できる`simulaterawtransaction`RPC、
  他のソフトウェアとの互換性を向上するための[Miniscript][topic miniscript]の式を含む
  監視専用の[ディスクリプター][topic descriptors]を作成する機能を追加しています。

</div>

## 6月

{:#ln-meet}
6月、LN開発者はプロトコル開発の将来について議論するために[集まりました][news204 ln]。
議論されたトピックには、[Taproot][topic taproot]ベースのLNチャネル、
[Tapscript][topic tapscript]と[MuSig2][topic musig] (再帰的なMuSig2を含む)、
新しいチャネルと変更されたチャネルを公表するためのゴシッププロトコルの更新、
[オニオンメッセージ][topic onion messages]、[ブラインドパス][topic rv routing]、
プロービング、バランスの共有、[トランポリンルーティング][topic trampoline payments]、
[Offer][topic offers]、LNURLプロトコルが含まれていました。

## 7月

{:#onion-message-limiting}
7月、Bastien Teinturierは、
DoS攻撃を防ぐための[オニオンメッセージ][topic onion messages]のレート制限について、
Rusty Russellによるものだとするアイディアの概要を[投稿しました][news207 onion]。
しかし、Olaoluwa Osuntokunは、データのリレーに課金することでオニオンメッセージの悪用を防ぐという
3月の彼の[提案][news190 onion]について再考を提案しました。
議論に参加したほとんどの開発者は、プロトコルに追加の手数料を加える前にレート制限を試してみることを好んだようでした。

{:#miniscript-descriptors}
この月、Bitcoin Coreに、[Miniscript][topic miniscript]で書かれた
監視専用の[アウトプット・スクリプト・ディスクリプター][topic descriptors]のサポートを追加する
[プルリクエストがマージされました][news209 miniscript]。将来のPRでは、ウォレットが
Miniscriptベースのディスクリプターを支払いで使用するための署名を作成できるようにする予定です。
他のウォレットや署名デバイスがMiniscriptをサポートすると、
マルチシグポリシーや異なる場面で異なる署名者が含まれるポリシー（例：フォールバック用の署名者）など、
ウォレット間でポリシーを転送したり、複数のウォレットが協力してビットコインを使用することが簡単になるはずです。

## 8月

{:#dual-funding}
8月、Eclairは2つノードのどちら（または両方）が新しいLNチャネルに資金を提供することができる
[デュアルファンディングプロトコル][topic dual funding]と依存関係のある
対話型のファンディングプロトコルの[サポートをマージしました][news213 dual funding]。
月末には、別の[マージ][news215 dual funding]によってEclairがデュアルファンディングを実験的にサポートするようになりました。
デュアルファンディングのチャネルオープンプロトコルは、
マーチャントが顧客からの支払いをすぐに受け取れるチャネルへのアクセスを確保するのに役立ちます。

{:#jamming}
Antoine RiardとGleb Naumenkoは、[チャネルジャミング攻撃][topic channel jamming attacks]と
いくつかの解決策の提案についてのガイドを[公開しました][news214 jam]。
攻撃者が制御するチャネル毎に完了しない支払いを送信することで、多数の他のチャネルを使用不能にすることができます。
つまり、攻撃者は直接コストを払う必要がありません。この問題は2015年から知られていましたが、
以前提案された解決策は広く受け入れられませんでした。11月には、
Clara ShikhelmanとSergei Tikhomirovは、少額の前払い手数料と
自動化されたレピュテーションベースの紹介に基づく分析と解決策を提案した[論文][news226 jam]を公開しました。
その後、Riardが、取引不可能なノード固有のトークンを含む代わりの解決策を[発表しました][news228 jam]。
12月には、Joost Jagerが、LNプロトコルに変更を加えることなく、
ノードがジャミングの問題を軽減するのに役立つ「単純だが不完全な」ユーティリティを[発表しました][news230 jam]。

{:.center}
![2種類のチャネルジャミング攻撃の図](/img/posts/2020-12-ln-jamming-attacks.png)

{:#dlc-bls}
Lloyd Fournierは、[DLC][topic dlc]のオラクルが[BLS][]（Boneh-Lynn-Shacham）署名を使用して、
証明を作成することの利点について[投稿しました][news213 bls]。
BitcoinはBLS署名をサポートしておらず、追加するためにはソフトフォークが必要ですが、
Fournierは、BLS署名から情報を安全に抽出し、
Bitcoinに変更を加えることなくBitcoin互換の[署名アダプター][topic adaptor signatures]を使用する方法について説明している
共著の論文へのリンクを掲載しました。これにより、契約の参加者（オラクルではない）は、
オラクルが実行できるプログラミング言語で書かれたプログラムを指定するなどして、
オラクルに証明してほしい情報について非公開で合意することができるステートレスオラクルを実現することができます。
そして参加者は、オラクルに対してオラクルを利用する予定であることを伝えることなく、
契約にしたがってデポジットする資金を割り当てることができます。
契約の清算タイミングが来たら、各参加者が自分でプログラムを実行し、
その結果に参加者全員が合意すれば、オラクルを一切介さずに協力的に契約を清算することができます。
合意しなかった場合は、参加者の誰かがオラクルにプログラムを送信し（おそらくそのサービスに対して少額の支払いが発生する）、
プログラムのソースコードとそれを実行した結果に対するBLSの証明を返送してもらいます。
証明は署名に変換され、DLCをオンチェーンで清算することができます。現在のDLCコントラクトと同様に、
オラクルはどのオンチェーントランザクションがそのBLS署名に基づくものなのか知りません。

<div markdown="1" class="callout" id="optech">
### 2022年のまとめ<br>Bitcoin Optech

Optechの5年めは、51の週間[ニュースレター][newsletters]を発行し、
[トピック・インデックス][topics index]に11の新しいページを追加しました。
またOptechは今年、Bitcoinのソフトウェアの研究開発について、
全体で7万文字以上を公開しました。ざっと200ページの書籍に相当します。

</div>

## 9月

{:#fee-ratecards}
Lisa Neigutは、ノードが4段階の転送手数料を配信できるようにする手数料レートカードの提案を
Lightning-Devメーリングリストに[投稿しました][news219 ratecards]。
転送手数料の配信を改善し、場合によっては負の手数料を設定できるようにすれば、
転送ノードが最終的な宛先に向けて支払いを中継するのに十分なキャパシティを確保できるようになります。
開発者のZmnSCPxjは、今年の初めにルーティングを改善するための独自の手数料ベースの解決策を[投稿しており][news204 lnfees]、
レートカードを使用するための簡単な方法を説明しています。
「レートカードは、同じ２つのノード間で、それぞれ異なるコストを持つ4つの別々のチャネルとしてモデル化することができます。
最も低コストの経路が失敗すると、ホップ数は増えるが実効コストの低い別の経路を試すか、より高いコストで同じチャネルを試すだけです。」
René Pickhardtからは、支払いのフロー制御のための別の方法が[提案されました][news220 flow control]。

## 10月

{:#v3-tx-relay}
10月、Gloria Zhaoはバージョン番号3を使用するトランザクションに、
変更したトランザクションリレーポリシーのセットを使用できるようにすることを[提案しました][news220 v3]。
これらのポリシーは、[CPFP][topic cpfp]と[RBF][topic rbf]の使用経験を基に、
さらに[パッケージリレー][topic package relay]に関するアイディアを加えたもので、
LNのような2者間のコントラクトプロトコルに対する[Pinning攻撃][topic transaction pinning]を防ぐのに役立つよう設計されています。
チャネルの閉鎖や支払いの決済（[HTLC][topic htlc]）、不正行為に対するペナルティの適用のために、
ユーザーがトランザクションの迅速な承認を得られるようにします。
Greg Sandersは、月の後半に、ほとんどのLN実装で既に使用可能な[アンカー・アウトプット][topic anchor outputs]を簡略化した
*エフェメラル・アンカー*に関する追加の提案を[行いました][news223 ephemeral]。

{:#async-payments}
Eclairは、[トランポリン・リレー][topic trampoline payments]が使用されている際に、
非同期支払いの基本形を[サポート][news220 async]するようにしました。
非同期支払いは、資金を第三者に託すことなく、オフラインのノード（モバイルウォレットなど）への支払いを可能にします。
非同期支払いの理想的な仕組みは[PTLC][topic ptlc]に依存しますが、
部分的な実装では、オフラインのノードがオンラインに戻るまでサードパーティが転送を遅らせるだけですみます。
トランポリンノードは、この遅延を提供できるため、今回のPRでトランポリンノードを利用して非同期支払いを実験することができます。

{:#parsing-bugs}
10月はまた、複数のアプリケーションに影響を与えた2つのブロックのパースバグのうちの[１つ][news222 bug]が発生しました。
BTCDで誤って発生したバグによって、BTCDと下流プログラムであるLNDが最新のブロックを処理できなくなりました。
このバグによりユーザーが資金を失う可能性がありましたが、そのような問題は報告されていません。
[2つめ][news225 bug]の関連バグの方は意図的に引き起こされ、
再びBTCDとLNDおよびRust-Bitcoinの一部のバージョンのユーザーに影響を与えました。
ここでもユーザーが資金を失う可能性がありましたが、報告された事件はありませんでした。

{:#zk-rollups}
John Lightは、現在のサイドチェーンの状態をメインチェーンにコンパクトに格納するサイドチェーンの一種である
Validity Rollupについて作成した研究レポートを[投稿しました][news222 rollups]。
サイドチェーン上のビットコインの所有者は、メインチェーンに格納されている状態を使用して、
自分が管理しているサイドチェーン上のビットコインの量を証明することができます。
Validity Proofを持つメインチェーンのトランザクションを送信することで、
サードチェーンの運営者やマイナーが引き出しを阻止しようとしても、
自分が所有するビットコインをサードチェーンから引き出すことができます。
Lightの研究は、Validity Rollupを深く説明し、そのサポートをどうやってBitcoinに追加できるかを説明し、
その実装に関するさまざまな懸念事項を検証しています。

{:#v2-transport}
[暗号化されたv2 P2Pトランスポートプロトコル][news222 v2trans]の[BIP324][]の提案は、
3年ぶりに更新されメーリングリストで議論が行われました。
未承認トランザクションの転送を暗号化することは、多くのインターネットの中継を制御する盗聴者（たとえば大規模なISPや政府）から、
その出所を隠すのに役立ちます。また、改ざんを検知しやすくなり、[エクリプス攻撃][topic
eclipse attacks]をより困難にする可能性もあります。

{:#core-meet}
Bitcoinプロトコル開発者のミーティングでは、
[トランスポートの暗号化][topic v2 p2p transport]、
トランザクション手数料と[経済的なセキュリティ][topic fee sniping]、
FROST[閾値署名][topic threshold signature]方式、
ソースコードと開発の議論のホスティングにGitHubを使用することの持続可能性、BIPの証明可能な仕様、
[パッケージリレー][topic package relay]と[v3トランザクションリレー][topic v3 transaction relay]、
Stratumバージョン2マイニングプロトコル、
コードをBitcoin Coreや他のフリーソフトウェアプロジェクトにマージしてもらうことを含む、
Bryan Bishopによって[書き起こされた][news223 xscribe]いくつかのセッションがありました。

<div markdown="1" class="callout" id="softforks">
### 2022年のまとめ<br>ソフトフォークの提案

1月、Jeremy Rubinが[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV)のソフトフォークの提案を
検討・議論するIRCミーティングの第一回めを[開催する][news183a ctv]ことから始まりました。
一方、Peter Toddは、この提案に対するいくつかの懸念をBitcoin-Devメーリングリストに[投稿し][news183b ctv]、
特に、以前のソフトフォークがそうであったように、ほぼすべてのBitcoinユーザーに利益をもたらすとは思えないという懸念を表明しました。

Lloyd Fournierは、DLC-DevメーリングリストとBitcoin-Devメーリングリストの両方に、
CTV opcodeが特定のDLC（[Discreet Log Contract][topic dlc]）の作成に必要な署名の数を根本的に削減し、
また他のいくつかの操作の数も削減できると[投稿しました][news185 ctv]。
Jonas Nickは、提案中の[SIGHASH_ANYPREVOUT][topic sighash_anyprevout] (APO)署名ハッシュモードを使用しても
同様の最適化が可能であることを指摘しました。

Russell O'Connorは、CTVとAPOの両方に代わる方法として、
`OP_TXHASH` opcodeと[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS) opcodeを
追加するソフトフォークを[提案しました][news185 txhash]。
TXHASH opcodeは、支払いトランザクションのどの部分をシリアライズしてハッシュすべきかを指定し、
ハッシュダイジェストは後のopcodeが使用できるように評価スタックに置かれます。
CSFS opcodeは公開鍵を指定し、
それに対応するスタック上の特定のデータ（TXHASHによって作成されたトランザクションの計算ダイジェストなど）に対する署名を要求します。
これにより、CTVとAPOのエミュレーションを、より単純でより柔軟性があり、
その後のソフトフォークによる拡張が容易な方法で行うことができるようになります。

2月には、Rusty Russellが`OP_TXHASH`のよりシンプルなバージョンである`OP_TX`を[提案しました][news187 optx]。
一方、Jeremy RubinはCTVを有効にした[signet][topic signet]用のパラメーターとコードを[公開しました][news188 ctv]。
これにより、提案されたopcodeの公開実験が簡単になり、そのコードを使用する異なるソフトウェア間の互換性のテストがより簡単になりました。
2月にはまた、開発者のZmnSCPxjが、2021年に提案された`OP_TAPLEAF_UPDATE_VERIFY` (TLUV) opcodeに代わる、
新しい`OP_EVICT` opcodeを提案しました。TLUVと同様に、EVICTは、
[Joinpool][topic joinpools]や[チャネル・ファクトリー][topic channel factories]、
特定の[Covenant][topic covenants]など、2人以上のユーザーが1つのUTXOの所有権を共有するユースケースにフォーカスしています。
ZmnSCPxjはその後、EVICTのような動作を構築できるより一般的な構成として（ただし、それには他のスクリプト言語の変更を必要とする）
`OP_FOLD`という別の新しいopcodeを[提案しました][news191 fold]。

3月までに、CTVと新しいopcodeの提案に関する議論は、
Bitcoinのスクリプト言語の表現力を制限する[議論][news190 recov]につながりました。
これは主に、*再帰的なCovenant*（これらのビットコインを使用する、もしくはこれらにマージされたビットコインを
再利用するすべてのトランザクションで永久に満たす必要のある条件）を防ぐためのものです。
懸念されたのは、検閲耐性が失われること、[ドライブチェーン][topic sidechains]の実現、
不必要な計算の促進、再帰的なCovenantによってユーザーが誤ってコインを失う可能性があることなどです。

3月にはまた、Bitcoinのスクリプト言語に対する変更に関する別のアイディアも見られました。
今回は、将来のトランザクションがLispをベースにした全く別の言語をオプトインできるようにするというものです。
Anthony Townsは、アイディアを[提案し][news191 btc-script]、
スクリプトと以前提案された代替案である[Simplicity][topic simplicity]より優れいている可能性があると説明しました。

4月、Jeremy Rubinは、マイナーが提案されているCTV opcodeの
[BIP119][]ルールを適用するかどうかを通知できるようにするソフトウェアをリリースする計画を
Bitcoin-Devメーリングリストに[投稿しました][news197 ctv]。
これはCTVやAPOのような類似の提案についての議論を引き起こしました。
Rubinはその後、他のCTV支持者と共に受け取ったフィードバックを評価するため、
現時点ではCTVを有効化するためのコンパイル済みのソフトウェアをリリースしないと発表しました。

5月、Rusty Russellは彼の`OP_TX`の提案を[更新しました][news200 ctv]。
元の提案は、再帰的なCovenantを許可していたため、このセクションで述べたような懸念がありました。
代わりに、Russellは、再帰的なCovenantを防ぐために特別に設計された、
CTVの動作を許可することに限定したOP_TXの初期バージョンを提案しました。
この新バージョンのOP_TXは、将来、段階的にアップグレードして機能を追加することで、
より強力なものになると同時に、新しい機能を独自に分析することも可能にします。
5月には、（2010年にBitcoinから削除された）`OP_CAT` opcodeについても[議論され][news200 cat]、
一部の開発者は、将来追加する可能性があることを示唆しています。

9月、Jeremy Rubinは、Trusted Setupの手順と提案されているAPOを組み合わせることで、
[ドライブチェーン][topic sidechains]が提案するのと同様の動作を実装できることを[説明しました][news218 apo]。
Bitcoinでドライブチェーンの実装を防止することは、開発者のZmnSCPxjが今年の初めに、
フルノードのオペレーターは再帰的なCovenantを可能にするソフトフォークに反対した方がいいかもしれないと示唆した理由の1つでした。

9月にはまた、Anthony Townsが[signet][topic signet]でソフトフォークをテストするために
特別に設計されたBitcoinの実装を[発表しています][news219 inquisition]。
Bitcoin CoreをベースにしたTownsのコードは、高品質の仕様と実装を備えたソフトフォークの提案ルールを適用し、
ユーザーが提案された変更を簡単に実験できるようにします（それぞれの変更を比較したり、
どのように作用するか確認したりすること含めて）。また、Townsは、
（[パッケージリレー][topic package relay]など）トランザクションリレーポリシーに対する大きな変更案も含める予定です。

11月、Salvatore Ingalaは、（ソフトフォークを必要とする）
新しいタイプのCovenantの提案をBitcoin-Devメーリングリストに[投稿しました][news226 matt]。
この提案では、あるオンチェーントランザクションから別のトランザクションに状態を運ぶことができる
スマートコントラクトをマークルツリーを使って作成することが可能になります。
これは他の暗号通貨システムで使用されているスマートコントラクトと同様の機能を持ち、
Bitcoinの既存のUTXOベースのシステムと互換性があるものです。

</div>

## 11月

{:#fat-errors}
11月、Joost Jagerは、失敗した支払いに関するLNのエラー報告を改善するための2019年の提案を[更新しました][news224 fat]。
エラーは、ノードによる支払いの転送に失敗したチャネルの身元を報告し、
送信者がそのノードを含むチャネルを一定期間使用しないようにするものです。
[Eclair][news225 fat]や[Core Lightning][news226 fat]など、
いくつかのLN実装は、すぐにその提案を使い始めないまでも、コードを更新して提案をサポートする予定です。

## 12月

{:#ln-mod}
12月、プロトコル開発者のJohn Lawは、今年3回目の重要な提案をLightning-Devメーリングリストに投稿しました。
彼の以前の2つの提案と同様に、Bitcoinのコンセンサスコードを変更することなく、
LNのオンチェーントランザクションを設計して新しい機能を有効にする方法を提案しました。
Lawの3つの提案は、カジュアルなLNユーザーが一度に数ヶ月[オフラインでいられる][news221 ln-mod]方法、
[ウォッチタワー][topic watchtowers]との互換性を向上するために特定の支払いの執行を
すべての決済資金の管理から[分離する][law tunable]方法、
LNを使用するためのオンチェーンコストを大幅に削減できる[チャネル・ファクトリー][topic channel factories]を使用するための
LNチャネルの[最適化][news230 ln-mod]などを提案しています。

*私たちは、上記のすべてのBitcoinコントリビューターと、同様に重要な仕事をした多くの方々、
Bitcoin開発の驚くべき一年に感謝します。
Optechのニュースレターは、1月4日に通常の水曜日の発行スケージュールに戻ります。*

{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}
[bls]: https://ja.wikipedia.org/wiki/ボネ・リン・シャチャム署名
[cjdns]: https://github.com/cjdelisle/cjdns
[law tunable]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003732.html
[news181 ldk1177]: /ja/newsletters/2022/01/05/#rust-lightning-1177
[news181 rbf]: /ja/newsletters/2022/01/05/#full-rbf-rbf
[news182 accounts]: /ja/newsletters/2022/01/12/#fee-accounts
[news182 bolts912]: /ja/newsletters/2022/01/12/#bolts-912
[news183a ctv]: /ja/newsletters/2022/01/19/#irc
[news183b ctv]: /ja/newsletters/2022/01/19/#mailing-list-discussion
[news183 defense fund]: /ja/newsletters/2022/01/19/#bitcoin-ln
[news183 stateless]: /ja/newsletters/2022/01/19/#eclair-2063
[news185 ctv]: /ja/newsletters/2022/02/02/#script-dlc
[news185 eclair]: /ja/newsletters/2022/02/02/#eclair-0-7-0
[news185 txhash]: /ja/newsletters/2022/02/02/#ctv-apo
[news186 rbf]: /ja/newsletters/2022/02/09/#rbf
[news187 optx]: /ja/newsletters/2022/02/16/#op-txhash
[news188 ctv]: /ja/newsletters/2022/02/23/#ctv-signet
[news188 ldk1199]: /ja/newsletters/2022/02/23/#ldk-1199
[news188 sponsorship]: /ja/newsletters/2022/02/23/#fee-bumping-and-transaction-fee-sponsorship
[news189 btcpay]: /ja/newsletters/2022/03/02/#btcpay-server-1-4-6
[news190 ldk]: /ja/newsletters/2022/03/09/#ldk-0-0-105
[news190 onion]: /ja/newsletters/2022/03/09/#onion
[news190 recov]: /ja/newsletters/2022/03/09/#script
[news191 btc-script]: /ja/newsletters/2022/03/16/#chia-lisp
[news191 fold]: /ja/newsletters/2022/03/16/#looping-folding
[news191 rbf]: /ja/newsletters/2022/03/16/#rbf
[news192 pp]: /ja/newsletters/2022/03/23/#payment-delivery-algorithm-update
[news193 bdk]: /ja/newsletters/2022/03/30/#bdk-0-17-0
[news193 witrep]: /ja/newsletters/2022/03/30/#witness
[news194 sp]: /ja/newsletters/2022/04/06/#delinked-reusable-addresses
[news195 musig2]: /ja/newsletters/2022/04/13/#musig2-bip
[news195 stateless]: /ja/newsletters/2022/04/13/#core-lightning-5086
[news195 taro]: /ja/newsletters/2022/04/13/#transferable-token-scheme
[news196 qc]: /ja/newsletters/2022/04/20/#quantum-safe-key-exchange
[news196 stateless]: /ja/newsletters/2022/04/20/#lnd-5810
[news197 bcc]: /ja/newsletters/2022/04/27/#bitcoin-core-23-0
[news197 cln]: /ja/newsletters/2022/04/27/#core-lightning-0-11-0
[news197 ctv]: /ja/newsletters/2022/04/27/#ctv
[news197 rb]: /ja/newsletters/2022/04/27/#rust-bitcoin-0-28
[news198 btcpay]: /ja/newsletters/2022/05/04/#btcpay-server-1-5-1
[news198 lbk]: /ja/newsletters/2022/05/04/#bitcoin-core-24322
[news198 musig2]: /ja/newsletters/2022/05/04/#musig2
[news200 cat]: /ja/newsletters/2022/05/18/#op-cat-covenants
[news200 ctv]: /ja/newsletters/2022/05/18/#op-tx
[news201 package relay]: /ja/newsletters/2022/05/25/#package-relay-proposal
[news202 sp]: /ja/newsletters/2022/06/01/#silent-payment
[news203 zero-conf]: /ja/newsletters/2022/06/08/#bolts-910
[news204 ln]: /ja/newsletters/2022/06/15/#ln
[news204 lnfees]: /ja/newsletters/2022/06/15/#using-routing-fees-to-signal-liquidity
[news204 package relay]: /ja/newsletters/2022/06/15/#bip
[news205 bdk]: /ja/newsletters/2022/06/22/#bdk-0-19-0
[news205 ldk]: /ja/newsletters/2022/06/22/#ldk-0-0-108
[news205 rbf]: /ja/newsletters/2022/06/22/#rbf
[news205 scid]: /ja/newsletters/2022/06/22/#eclair-2224
[news206 lnd]: /ja/newsletters/2022/06/29/#lnd-0-15-0-beta
[news207 onion]: /ja/newsletters/2022/07/06/#onion-message-rate-limiting
[news208 rbf]: /ja/newsletters/2022/07/13/#bitcoin-core-25353
[news208 scid cln]: /ja/newsletters/2022/07/13/#core-lightning-5275
[news208 scid lnd]: /ja/newsletters/2022/07/13/#lnd-5955
[news209 miniscript]: /ja/newsletters/2022/07/20/#bitcoin-core-24148
[news213 bls]: /ja/newsletters/2022/08/17/#dlc-bitcoin-bls
[news213 dual funding]: /ja/newsletters/2022/08/17/#eclair-2273
[news213 rb]: /ja/newsletters/2022/08/17/#rust-bitcoin-0-29
[news214 cln]: /ja/newsletters/2022/08/24/#core-lightning-0-12-0
[news214 jam]: /ja/newsletters/2022/08/24/#overview-of-channel-jamming-attacks-and-mitigations
[news214 sp]: /ja/newsletters/2022/08/24/#silent-payment-pr
[news215 dual funding]: /ja/newsletters/2022/08/31/#eclair-2275
[news215 lnd]: /ja/newsletters/2022/08/31/#lnd-0-15-1-beta
[news217 ldk]: /ja/newsletters/2022/09/14/#ldk-0-0-111
[news218 apo]: /ja/newsletters/2022/09/21/#apo-trusted-setup-drivechain
[news219 inquisition]: /ja/newsletters/2022/09/28/#signet-bitcoin
[news219 ratecards]: /ja/newsletters/2022/09/28/#ln
[news220 async]: /ja/newsletters/2022/10/05/#eclair-2435
[news220 flow control]: /ja/newsletters/2022/10/05/#ln
[news220 v3]: /ja/newsletters/2022/10/05/#ln
[news221 ln-mod]: /ja/newsletters/2022/10/12/#ln
[news222 bug]: /ja/newsletters/2022/10/19/#btcd-lnd
[news222 musig2]: /ja/newsletters/2022/10/19/#musig2
[news222 rbf]: /ja/newsletters/2022/10/19/#transaction-replacement-option
[news222 rollups]: /ja/newsletters/2022/10/19/#validity-rollups
[news222 v2trans]: /ja/newsletters/2022/10/19/#bip324
[news223 ephemeral]: /ja/newsletters/2022/10/26/#ephemeral-anchors
[news223 rbf]: /ja/newsletters/2022/10/26/#rbf
[news223 xscribe]: /ja/newsletters/2022/10/26/#coredev-tech
[news224 fat]: /ja/newsletters/2022/11/02/#ln
[news224 rbf]: /ja/newsletters/2022/11/02/#mempool
[news225 bug]: /ja/newsletters/2022/11/09/#block-parsing-bug-affecting-multiple-software
[news225 fat]: /ja/newsletters/2022/11/09/#eclair-2441
[news225 rbf]: /ja/newsletters/2022/11/09/#rbf
[news226 fat]: /ja/newsletters/2022/11/16/#core-lightning-5698
[news226 jam]: /ja/newsletters/2022/11/16/#paper-about-channel-jamming-attacks
[news226 matt]: /ja/newsletters/2022/11/16/#covenant-bitcoin
[news228 jam]: /ja/newsletters/2022/11/30/#ln
[news229 cln]: /ja/newsletters/2022/12/07/#core-lightning-22-11
[news230 bcc]: /ja/newsletters/2022/12/14/#bitcoin-core-24-0-1
[news230 jam]: /ja/newsletters/2022/12/14/#local-jamming-to-prevent-remote-jamming
[news230 libsecp]: /ja/newsletters/2022/12/14/#libsecp256k1-0-2-0
[news230 ln-mod]: /ja/newsletters/2022/12/14/#ln
[news230 rbf]: /ja/newsletters/2022/12/14/#rbf
[news231 v3relay]: /ja/newsletters/2022/12/21/#v3-tx-relay
[newsletters]: /ja/newsletters/
[topics index]: /en/topics/
[yirs 2018]: /en/newsletters/2018/12/28/
[yirs 2019]: /ja/newsletters/2019/12/28/
[yirs 2020]: /en/newsletters/2020/12/23/
[yirs 2021]: /ja/newsletters/2021/12/22/
