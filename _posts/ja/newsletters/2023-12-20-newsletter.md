---
title: 'Bitcoin Optech Newsletter #282: 2023年振り返り特別号'
permalink: /ja/newsletters/2023/12/20/
name: 2023-12-20-newsletter-ja
slug: 2023-12-20-newsletter-ja
type: newsletter
layout: newsletter
lang: ja

excerpt: >
  このOptechニュースレターの特別版では、2023年のBitcoinの注目すべき動向についてまとめています。
---
{{page.excerpt}} これは、[2018年][yirs 2018]、[2019年][yirs 2019]、[2020年][yirs 2020]、
[2021年][yirs 2021]、[2022年][yirs 2022]のまとめの続編です。

## 内容

* 1月
  * [Bitcoin Inquisition](#inquisition)
  * [Swap-in-Potentiam](#potentiam)
  * [BIP329ウォレットラベルエクスポートフォーマット](#bip329)
* 2月
  * [Ordinalsとinscriptions](#ordinals)
  * [Bitcoin Search、ChatBTC](#chatbtc)
  * [ピアストレージバックアップ](#peer-storage)
  * [LNのサービス品質](#ln-qos)
  * [HTLCエンドースメント](#htlc-endorsement)
  * [Codex32](#codex32)
* 3月
  * [階層型チャネル](#mpchan)
* 4月
  * [ウォッチタワーの責任の証明](#watchaccount)
  * [ルートブラインド](#route-blinding)
  * [MuSig2](#musig2)
  * [RGBとTaproot Assets](#clientvalidation)
  * [チャネルスプライシング](#splicing)
* 5月
  * [LSP仕様](#lspspec)
  * [Payjoin](#payjoin)
  * [Ark](#ark)
* 6月
  * [サイレントペイメント](#silentpayments)
* 7月
  * [Validating Lightning Signer](#vls)
  * [LN開発者ミーティング](#ln-meeting)
* 8月
  * [Onionメッセージ](#onion-messages)
  * [古くなったバックアップの証明](#backup-proofs)
  * [Simple Taproot Channel](#tapchan)
* 9月
  * [圧縮されたBitcoinトランザクション](#compressed-txes)
* 10月
  * [支払いの切り替えと分割](#pss)
  * [サイドプール](#sidepools)
  * [AssumeUTXO](#assumeutxo)
  * [バージョン2 P2Pトランスポート](#p2pv2)
  * [Miniscript](#miniscript)
  * [状態の圧縮とBitVM](#statebitvm)
* 11月
  * [オファー](#offers)
  * [Liquidity Ads](#liqad)
* 12月
  * [クラスターmempool](#clustermempool)
  * [Warnet](#warnet)
* 注目のまとめ
  * [ソフトフォークの提案](#softforks)
  * [セキュリティの開示](#security)
  * [人気のインフラストラクチャプロジェクトのメジャーリリース](#releases)
  * [Bitcoin Optech](#optech)

## 1月

{:#inquisition}
Anthony Townsは、提案中のソフトフォークやその他の重要なプロトコルの変更をテストするために、
デフォルトsignetで使用されるよう設計されたBitcoin Coreのソフトウェアフォークである
Bitcoin Inquisitionを[発表しました][jan inquisition]。
年末までに、いくつかの提案のサポートが含まれています。
[SIGHASH_ANYPREVOUT][topic sighash_anyprevout]、
[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]、
基本的な[エフェメラル・アンカー][topic ephemeral anchors]、
[OP_CAT][]や`OP_VAULT`のサポートおよび[64バイトのトランザクションに対する制限][topic consensus cleanup]を
追加するためのプルリクエストがリポジトリで公開されました。

{:#potentiam}
ZmnSCPxjとJesse Posnerは、ライトニングネットワークのチャネルを開くための非対話型の方法である
_Swap-in-Potentiam_ を[提案し][jan potentiam]、
モバイルデバイスのようなオフラインになることが多いウォレットが直面する課題に対処します。
クライアントは、オフラインの状態でもオンチェーントランザクションで資金を受け取ることができます。
このトランザクションは十分な承認を受けることができるため、クライアントがオンラインに戻ったときに、
事前に選択したピアとのチャネルを（ピアを信頼することなく）直ぐ安全に開設することができます。
この提案から数ヶ月以内に、少なくとも1つの人気のLNウォレットがこのアイディアの実装を使用していました。

{:#bip329}
[ウォレットラベル][topic wallet labels]のエクスポートおよびインポートの標準形式に、
識別子[BIP329][]が[割り当てられました][jan bip329]。
この標準により、[BIP32シード][topic bip32]からは復元できない重要なウォレットデータのバックアップが簡単になるだけでなく、
会計ソフトウェアなどのウォレット以外のプログラムへのトランザクションのメタデータのコピーも簡単になります。
年末までに、いくつかのウォレットがBIP329のエクスポートを実装しました。

## 2月

{:#ordinals}
2月には、トランザクションアウトプットに意味とデータを関連付けるための2つの関連プロトコル
OrdinalsとInscriptionsについて年内まで続く[議論][feb ord2]が[始まりました][feb ord1]。
Andrew Poelstraは、多くのプロトコル開発者の立場を次のようにまとめました。
「さらに悪い行為を奨励したり、正当なユースケースを壊すことなく、人々が
任意のデータをwitnessに保存するのを防ぐ賢明な方法はない。」
Inscriptionsで使用されている方法では大量のデータを保存できるため、
Christopher Allenは`OP_RETURN`プレフィックスがついたアウトプットの
データストレージの83バイト制限を増やす提案をしました。
この提案は、今年後半にPeter Toddによっても[提案されました][aug opreturn]。

{:#chatbtc}
BitcoinSearch.xyzが今年始めに[ローンチされ][feb bitcoinsearch]、
Bitcoinの技術文書と議論用の検索エンジンの提供を始めました。
年末までに、このサイトは、[チャットインターフェース][chatbtc]と
最近の議論の[概要][tldr]を提供するようになりました。

{:#peer-storage}
Core Lightningは、ピアストレージバックアップの実験的なサポートを[追加しました][feb storage]。
これは、ノードがピアのために小さな暗号化されたバックアップファイルを保存することができるようにします。
ピアが、おそらくデータを失った後、再接続する必要がある場合、バックアップファイルを要求することができます。
ピアはウォレットのシードから導出した鍵を使用してファイルを復号し、
その内容を使ってそのチャネルのすべての最新の状態を復元することができます。

{:#ln-qos}
Joost Jagerは、チャネルが信頼性の高い支払いの転送を提供していることを示すことができるようする、
LNチャネルに対する「高可用性」フラグを[提案しました][feb lnflag]。
Christian Deckerは、ノードの遭遇頻度が低いなど、レピュテーションシステムの作成における課題を指摘しました。
以前提案された別のアプローチについても言及されました。それは、
支払いを分割して複数の経路で送信し、可用性の高いチャネルへの依存度を減らす
[回収付きの過払い][topic redundant overpayments]（以前はBoomerangまたは
Refundable Overpaymentと呼ばれていました）です。

{:#htlc-endorsement}
昨年投稿された[論文][jamming paper]のアイディアは、
[LNのチャネルジャミング][topic channel jamming attacks]を軽減するための2023年の取り組みの特に焦点になりました。
2月に、Carla Kirk-Cohenと論文の共著者Clara Shikhelmanは、
論文のアイディアの1つである[HTLCエンドースメント][topic htlc endorsement]を実装する際に使用する
パラメーターの提案に関するフィードバックを[求めました][feb htlcendo]。
4月には、彼らはテスト計画のドラフト仕様を[投稿しました][apr htlcendo]。
7月には、このアイディアと提案がLN開発者ミーティングで[議論され][jul htlcendo]、
攻撃者と誠実なユーザーの両者が支払うコストに、
サービスを提供するノードオペレーターが支払う根本的なコストを反映させる[代替アプローチ][aug antidos]について、
メーリングリストでの議論が行われました。このアプローチにより、
誠実なユーザーにサービスを提供して妥当な利益を得ているノードオペレーターは、
攻撃者がそのサービスを使い始めた場合でも、妥当な利益を得続けることができます。
8月には、Eclair、Core LightningおよびLNDに関連する開発者が、
HTLCエンドースメントプロトコルに関連するデータを収集するために、その一部を実装していると[発表されました][aug htlcendo]。

{:#codex32}
Russell O'ConnorとAndrew Poelstraは、[codex32][topic codex32]と呼ばれる
[BIP32][]シードをバックアップおよび復元するための新しいBIPを[提案しました][feb codex32]。
SLIP39と同様に、設定可能な閾値要件を持つシャミアの秘密分散法を使用して複数のシェアを作成できます。
閾値未満のシェアしか持たない攻撃者は、シードについて何も知ることはできません。
ワードリストを使用する他のリカバリーコードとは異なり、
codex32は[bech32][topic bech32]アドレスと同じアルファベットを使用します。
codex32の主な利点は、（サイコロを使用した）エンコードされたシードの生成を含む
チェックサムによる保護、チェックサム付きのシェアの作成、チェックサムの検証およびシードの復元です。
ユーザーは信頼できるコンピューティングデバイスに依存することなく、個々のシェアの完全性を定期的に検証できます。

## 3月

{:#mpchan}
3月、仮名の開発者John Lawが1つのオンチェーントランザクションから
複数のユーザー向けのチャネル階層を作成する方法を説明した論文を[発表しました][mar mpchan]。
この設計により、チャネルの取引相手の一部がオフラインの場合でも、
すべてのオンラインユーザーが資金を使用することができるようになりますが、これは現在のLNでは不可能です。
この最適化により、常時オンラインのユーザーは資本をより効率的に使用できるようになり、
LNの他のユーザーのコストが削減される可能性があります。
この提案は、LawのTunable Penaltyプロトコルに依存していますが、
2022年に提案されてからソフトウェア開発は行われていません。

![Tunable Penaltyプロトコル](/img/posts/2023-03-tunable-commitment.dot.png)

<div markdown="1" class="callout" id="softforks">

### 2023年のまとめ<br>ソフトフォークの提案

新しい`OP_VAULT`opcodeの[提案][jan op_vault]が、1月にJames O'Beirneによって投稿され、
2月にはBitcoin Inquisition用のドラフトBIPの実装が[続きました][feb op_vault]。
さらに数週間後、Gregory Sandersによる`OP_VAULT`の代替設計の[提案][feb op_vault2]が続きました。

昨年初めて解説されたMATT（Merklize All The Things）提案は、今年も活発でした。
Salvatore Ingalaは提案中の`OP_VAULT` opcodeのほとんどの機能をどう提供できるかを[示しました][may matt]。
Johan Torås Halsethはさらに、MATTバージョンの方がスペース効率は低いものの、
MATT提案のopcodeの1つが提案中の`OP_CHECKTEMPLATEVERIFY` opcodeの主要機能をどう複製できるか[実証しました][jun matt]。
Halsethはまた、この機会を利用して、Bitcoinトランザクションと[Tapscript][topic tapscript]のデバッグを可能にする、
彼が構築したツール[tapsim][]を紹介しました。

6月、Robin Linusは、ユーザーが現在の資金をタイムロックし、それをサイドチェーン上で長期間使用し、
サイドチェーン上の資金の受取人が後で効果的にBitcoin上で資金を引き出すことができる方法を[説明しました][jun specsf]。
ただ、引き出しはBitcoinユーザーが最終的にコンセンサスルールを特定の方法で変更することを決定した場合に限ります。
これにより、金銭的なリスクを負うこと厭わないユーザーは、
希望する新しいコンセンサス機能を備えた資金をすぐに使い始めることができるのと同時に、
それらの資金が後でBitcoinのmainnetに戻る道筋を提供することができます。

8月、Brandon Blackは`OP_TXHASH`と[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]を
組み合わせたバージョンを[提案しました][aug combo]。
この提案は、個々の提案に比べてオンチェーンコストをあまり追加せずに、
[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV)と
[SIGHASH_ANYPREVOUT][topic sighash_anyprevout] (APO)の機能のほとんどを提供します。

9月、John Lawは、コベナンツを使用したLNのスケーラビリティの強化について[発表しました][sep lnscale]。
彼は、[チャネルファクトリー][topic channel factories]と提案中のArkプロトコルと同様の構造を使用して、
オフチェーンの数百万のチャネルに潜在的に資金を供給し、
ユーザーが事前にLN経由で資金を引き出すことで、期限切れ後にファクトリーの資金提供者が資金を取り戻すことができます。
このモデルでは、ユーザーとのやりとりなしでファクトリー間で資金を移動できるため、
オンチェーンの直前の混雑やトランザクション手数料のリスクを軽減することができます。
Anthony Townsは、時間的な制約のあるオンチェーントランザクションが同時に多数強制される可能性のある
_Forced Expiration Flood_ 問題について、懸念を表明しました。
Lawは、トランザクション手数料が高額な期間に有効期限を遅らせる解決策に取り組んでいると返答しています。

10月は、Steven Rooseが新しい`OP_TXHASH` opcodeのドラフトBIPを[投稿した][oct txhash]ことから始まりました。
このopcodeのアイディアは、以前議論されましたが、これはこのアイディアの最初の仕様です。
opcodeがどのように機能するかを正確に説明することに加えて、
opcodeが呼び出されるたびにフルノードで最大数メガバイトのデータをハッシュする必要がある可能性など、
いくつかの欠点も検討されました。BIPのドラフトには、このopcodeのサンプル実装が含まれています。

10月にはまた、Rusty RussellがBitcoinのスクリプト言語への変更を最小限に抑えた汎用的なコベナンツを[研究し][oct generic]、
Ethan Heilmanがスタック上の2つの要素を連結する[OP_CAT][op_cat] opcodeを追加するドラフトBIPを[公開しました][oct op_cat]。
これらの2つのトピックの議論は11月に入っても[続きました][nov cov]。

年末までに、Johan Torås Halsethは、コベナンツスタイルのソフトフォークにより
複数の[HTLC][topic htlc]を1つのアウトプットに集約することが可能になり、
当事者がすべてのプリイメージを知っていればすべてを一度に使用できるようになる[提案][nov
htlcagg]を行いました。もし、当事者がプリイメージのいくつかしか知らない場合は、
それらだけを請求し、残りを相手に返金することができます。これにより、オンチェーンの効率が向上し、
特定の種類の[チャネルジャミング攻撃][topic channel jamming attacks]の実行をより困難にすることができます。

</div>

## 4月

{:#watchaccount}
Sergi Delgado Seguraは、[ウォッチタワー][topic watchtowers]が検出てきたプロトコル違反に対応できなかった場合の
責任の仕組みを[提案しました][apr watchtower]。たとえば、アリスはウォッチタワーに、
LNチャネルの古い状態を検知し承認に応答するためのデータを提供します。その後、
その状態が承認され、ウォッチタワーは反応できませんでした。
アリスはウォッチタワーのオペレーターが適切に対応しなかったことを公に証明することで、
その責任を追求したいと考えています。Delgadoは、ウォッチタワーがコミットメントを作成するために使用できる
暗号学的アキュムレーターに基づく仕組みを提案しました。
ユーザーはこれを後で違反が発生した場合に責任の証明を生成するために使用できます。

{:#route-blinding}
[ルートブラインド][topic rv routing]は3年前に初めて解説され、
4月にLNの仕様に[追加されました][apr blinding]。
これにより、受信者は特定の転送ノードの識別子と、
そのノードから受信者自身のノードまでのOnion暗号化されたパスを送信者に提供することができます。
送信者は、選択された転送ノードに支払いと暗号化されたパス情報を転送します。
転送ノードは、次のホップの情報を復号し、次のホップはまたその次のホップを復号します。
支払いが受信者のノードに到着するまで、どのノードが受信者であるかを（確実に）送信者も転送ノードも知ることはありません。
LNを使用した送金の受け取りのプライバシーが大幅に向上します。

{:#musig2}
4月に[スクリプトレスなマルチシグ][topic multisignature]を作成するための[MuSig2][topic musig]に
[BIP327][]が[割り当てられました][apr musig2]。このプロトコルは、LNDの[signrpc][apr signrpc]や
Lightning Labの[Loop][apr loop]サービス、BitGoの[マルチシグサービス][apr bitgo]、
LNDの実験的な[Simple Taproot Channel][apr taproot channels]および
[PSBT][topic psbt]を拡張するための[ドラフトBIP][apr musig2 psbt]など、
この1年間で複数のプログラムやシステムに実装されることになりました。

{:#clientvalidation}
Maxim Orlovskyは、4月にRGB v0.10のリリースを[発表しました][apr rgb]。
これは、オフチェーンで定義され[検証された][topic client-side validation]コントラクトを使用して
（とりわけ）トークンの作成と転送を可能にするこのプロトコルの新バージョンです。
コントラクトの状態の変更（転送など）は、通常のトランザクションに追加のブロックスペースを使用しない方法で
オンチェーントランザクションに関連付けられ、コントラクトの状態（その存在を含む）に関するすべての情報を
第三者から完全に非公開にすることができます。今年の後半には、
RGBから部分的に派生したTaproot AssetsプロトコルがBIP化を意図した[仕様][sept tapassets]をリリースしました。

{:#splicing}
4月にはまた、資金がチャネルに追加または削除される間もノードがチャネルを使用し続けることができるようにする
[スプライシング][topic splicing]の提案プロトコルに関しても重要な[議論][apr splicing]が見られました。
これは、チャネル内に資金を保持しながら、その残高から即座にオンチェーン支払いを行えるようにする場合に特に便利で、
ウォレットのユーザーインターフェースで単一の残高を表示し、
そこからオンチェーン支払いとオフチェーン支払いのいずれかを行うことができます。年末までに、
Core LightningとEclairの両方がスプライシングをサポートするでしょう。

![スプライシング](/img/posts/2023-04-splicing1.dot.png)

## 5月

{:#lspspec}
LSP（Lightning Service Provider）のドラフト仕様が5月に[リリースされました][may lsp]。
標準化により、クライアントは複数のLSPに簡単に接続できるようになり、
ベンダーロックインが防止され、プライバシーが向上します。
リリースされた最初の仕様には、クライアントがLSPからチャネルを購入できるようにするAPIについて定義し、
[Liquidity Ads][topic liquidity advertisements]と同様の機能を実現します。
2つめは、[JIT（Just in Time）チャネル][topic jit channels]をセットアップおよび管理するためのAPIを定義しています。

{:#payjoin}
Dan Gouldは、今年の大部分を[Payjoin][topic payjoin]プロトコルの強化に費やしました。
このプロトコルは、第三者がトランザクションのインプットとアウトプットを、
支払人または受取人のいずれにかに確実に関連付けることをより困難にするプライバシー強化技術です。
彼は2月に、受取人がパブリックなネットワークインターフェース上で常時稼働のHTTPSサーバーを運用していない場合でも使用可能な
サーバーレスPayjoinプロトコルを[提案しました][feb payjoin]。
5月には、支払いのカットスルーを含むPayjoinを使用したいくつかの高度なアプリケーションについて[議論しました][may payjoin]。
たとえば、アリスがボブに支払うのではなく、アリスはボブのベンダー（キャロル）に支払い、
ボブが彼女に負っている借金を減らします（または、予想される将来の請求を前払いします）。
これにより、ブロックスペースが節約され、標準のPayjoinよりもプライバシーが向上します。
8月には、サーバーレスPayjoinの[ドラフトBIP][aug payjoin]を投稿しました。
ここでは、支払人と受取人が同時にオンラインである必要はありません（ただし、
トランザクションをブロードキャストするには、取引の開始後、それぞれが少なくとも1回オンラインになる必要があります）。
年間を通して、彼はPDK（[Payjoin Development Kit][jul pdk]）および、
Bitcoin CoreでPayjoinを作成するためのアドオンを提供する[payjoin-cli][dec payjoin]プロジェクトのトップコントリビューターでした。

{:#ark}
Burak Keceliは、Arkと呼ばれる新しい[Joinpool][topic joinpools]スタイルのプロトコルを[提案しました][may ark]。
このプロトコルでは、ビットコインの所有者は、一定期間内のすべてのトランザクションにおいて
カウンターパーティを共同署名者として使用することをオプトインできます。所有者は、
タイムロックが切れた後でビットコインをオンチェーンで引き出すことも、
タイムロックが期限切れになる前に即座にトラストレスにオフチェーンでカウンターパーティに転送することもできます。
このプロトコルは、コインのミキシングや内部送金、LNインボイスの支払いなどのさまざまな用途に、
所有者からカウンターパーティへのシングルホップ、単一方向のアトミックな転送プロトコルを提供します。
LNと比較して、オンチェーンのフットプリントが大きいことと、
オペレーターが大量の資金をホットウォレットに保管する必要があることについて懸念が生じました。
しかし、何人かの開発者は、提案されたプロトコルと、
ユーザーにシンプルでトラストレスな体験を提供するその可能性について依然として熱心でした。

## 6月

{:#silentpayments}
Josie BakerとRuben Somsenは、[サイレントペイメント][topic silent payments]のドラフトBIPを[投稿しました][jun sp]。
サイレントペイメントは、再利用可能なペイメントコードの一種で、
使用されるたびに一意のオンチェーンアドレスを生成し、[アウトプットのリンク][topic output linking]を防止します。
アウトプットのリンクは、（取引に直接関与していないユーザーを含む）ユーザーのプライバシーを著しく低下させる可能性があります。
ドラフトでは、提案の利点、トレードオフ、ソフトウェアを効果的に使用する方法について詳しく説明しています。
Bitcoin Coreにサイレントペイメントを実装する進行中の作業も、
Bitcoin Core PR Review Clubミーティングで[議論されました][aug sp]。

<div markdown="1" class="callout" id="security">

### 2023年のまとめ<br>セキュリティの開示

Optechは今年、3つの重大なセキュリティの脆弱性について報告しました:

- [Libbitcoin `bx`のMilk Sad脆弱性][aug milksad]:
  ウォレットを作成するために提案されたコマンドのエントロピーの欠如が広く文書化されていなかったため、
  最終的に複数のウォレットにまたがって相当数のビットコインが盗まれました。

- [LNノードに対する偽のファンディングによるサービス拒否][aug fundingdos]:
  サービス拒否攻撃がMatt Morehouseによって非公開で発見され、[責任を持って開示][topic responsible disclosures]されました。
  影響を受けるノードはすべてアップデートを行うことができ、この記事を書いている時点では、
  この脆弱性が悪用されたことは確認されていません。

- [HTLCに対する置換サイクル][oct cycling]:
  LNおよびおそらく他のプロトコルでも使用されている[HTLC][topic htlc]に対する資金窃取攻撃が、
  Antoine Riardによって非公開で発見され、責任を持って開示されました。
  Optechが追跡しているすべてのLN実装では、緩和策が導入されていましたが、
  それらの緩和策の有効性は議論の対象で、他の緩和策も提案されています。

</div>

## 7月

{:#vls}
VLS（Validating Lightning Signer）プロジェクトは、7月に最初のベータバージョンを[リリースしました][jul vls]。
このプロジェクトでは、LNノードとその資金を管理する鍵を分離することができます。
VLSで動作するLNノードは、署名要求をローカルの鍵ではなくリモート署名デバイスにルーティングします。
ベータリリースでは、CLNとLDK、レイヤー1とレイヤー2の検証ルール、バックアップおよびリカバリー機能をサポートし、
参照実装を提供しています。

{:#ln-meeting}
7月に開催されたLN開発者[ミーティング][jul summit]では、
ベースレイヤーにおける信頼できるトランザクションの承認や、
[Taproot][topic taproot]および[MuSig2][topic musig]チャネル、
更新されたチャネルアナウンス、[PTLC][topic ptlc]と[冗長な過払い][topic redundant overpayments]、
[チャネルジャミングの緩和策の提案][topic channel jamming attacks]、
簡素化されたコミットメント、仕様化のプロセスなど、さまざまなトピックについて議論されました。
同時期に行われた他のLNの議論には、未使用のレガシーな機能を削除するためのLN仕様の[クリーンアップ][jul cleanup]や、
チャネルを閉じるための[プロトコルの簡素化][jul lnclose]などが含まれていました。

## 8月

{:#onion-messages}
[Onionメッセージ][topic onion messages]の[サポート][aug onion]が8月にLN仕様に追加されました。
Onionメッセージは、ネットワークを介して一方向のメッセージ送信を可能にします。
（[HTLC][topic htlc]）支払いと同様に、メッセージはOnion暗号化を使用し、
各転送ノードは、どのピアからメッセージを受け取って、次にメッセージを受け取るのがどのピアかを知るのみです。
メッセージのペイロードも暗号化され、最終的な受信者だけが読めるようになっています。
Onionメッセージは、4月にLN仕様に追加された[ブラインドパス][topic rv routing]を使用し、
Onionメッセージ自体は、提案されている[オファープロトコル][topic offers]で使用されます。

{:#backup-proofs}
Thomas Voegtlinは、古くなったバックアップ状態をユーザーに提供するプロバイダーに
ペナルティを与えられるようにするプロトコルを[提案しました][aug fraud]。
このサービスは、ユーザーであるアリスが、バージョン番号と署名のついたデータを
ボブにバックアップを依頼するというシンプルな仕組みです。ボブは、nonceを追加し、
タイムスタンプ付きの署名で完全なデータにコミットします。
ボブが古くなったデータを提供した場合、アリスはボブが以前より高いバージョン番号に署名していたことを示す
Fraud Proof（不正の証明）を生成することができます。この仕組みはBitcoin固有のものではありませんが、
特定のBitcoinのopcodeを組み込むことで、オンチェーンで利用できるようになる可能性があります。
ライトニングネットワーク（LN）チャネルでは、ボブが古くなったバックアップを提供した場合、
アリスはすべてのチャネル資金を要求できるため、ボブがアリスを騙して彼女の残高を盗むリスクが軽減されます。
この提案は大きな議論を呼びました。Peter Toddは、LNを超える汎用性を指摘し、
Fraud Proofのないより単純な仕組みを提案しました。一方、Ghost43は、
匿名ピアを扱う場合のそのような証明の重要性を強調しました。

{:#tapchan}
LNDは、「Simple Taproot Channel」の[実験的なサポート][aug lnd taproot]を追加しました。
これにより、LNのファンディングおよびコミットメントトランザクションは、双方が協力している場合に、
[MuSig2][topic musig]スタイルの[スクリプトレスなマルチシグの署名][topic multisignature]をサポートする
[P2TR][topic taproot]を使用できるようになります。
P2TRの使用により、チャネルを協調的に閉じる際のトランザクションweightが軽減され、プライバシーが向上します。
LNDは引き続き[HTLC][topic htlc]のみを使用し、Taprootチャネルで開始された支払いが、
Taprootチャネルをサポートしていない他のLNノードを経由して転送され続けるようにします。

## 9月

{:#compressed-txes}
9月、Tom Briarは、圧縮されたBitcoinトランザクションのドラフト仕様と実装を[公開しました][sept compress]。
この提案は、整数の表現を可変長整数に置き換え、
OutPointのtxidの代わりにブロックの高さと位置でトランザクションを参照するようにし、
P2WPKHトランザクションから公開鍵を省略することで、
Bitcoinトランザクションの一様に分散したデータを圧縮するという課題に対処しています。
圧縮形式はスペースを節約しますが、それを使用可能なフォーマットに変換するには、
通常のシリアライズされたトランザクションを処理するのよりも多くのCPU、メモリおよびI/Oが必要になります。
これは、衛星によるブロードキャストやステガノグラフィーによる転送では許容可能なトレードオフです。

<div markdown="1" class="callout" id="releases">

### 2023年のまとめ<br>人気のインフラストラクチャプロジェクトのメジャーリリース

- [Eclair 0.8.0][jan eclair]は、[ゼロ承認チャネル][topic zero-conf channels]と
  SCID（Short Channel IDentifier）エイリアスのサポートを追加しました。

- [HWI 2.2.0][jan hwi]では、BitBox02ハードウェア署名デバイスを使用した
  [P2TR][topic taproot]のkeypathによる支払いのサポートが追加されました。

- [Core Lightning 23.02][mar cln]では、バックアップデータのピアストレージの実験的なサポートが追加され、
  [デュアルファンディング][topic dual funding]および[オファー][topic offers]の実験的サポートが更新されました。

- [Rust Bitcoin 0.30.0][mar rb]では、新しいウェブサイトの発表とともに、
  多数のAPIの変更が行われました。

- [LND v0.16.0-beta][apr lnd]は、この人気のLN実装の新しいメジャーバージョンを提供しました。

- [Libsecp256k1 0.3.1][apr secp]は、定数時間で実行されるべきコードが、
  Clangバージョン14以降でコンパイルされた場合に定数時間で実行されない問題を修正しました。

- [LDK 0.0.115][apr ldk]では、実験的な[オファープロトコル][topic offers]のサポートが強化され、
  セキュリティとプライバシーが向上しました。

- [Core Lightning 23.05][may cln]には、[ブラインドペイメント][topic rv routing]、
  バージョン2 [PSBT][topic psbt]のサポートおよび柔軟な手数料率の管理が含まれています。

- [Bitcoin Core 25.0][may bcc]では、新しい`scanblocks` RPCが追加され、
  `bitcoin-cli`の使用が簡素化され、`finalizepsbt` RPCへの[miniscript][topic miniscript]のサポートが追加され、
  `blocksonly`設定オプションを使用した場合のデフォルトのメモリ使用量が削減され、
  [コンパクトブロックフィルター][topic compact block filters]が有効になっている場合のウォレットの再スキャンが高速化されました。

- [Eclair v0.9.0][jun eclair]は、「重要な（そして複雑な）ライトニング機能：
  [デュアルファンディング][topic dual funding]、[スプライシング][topic splicing]、
  BOLT12[オファー][topic offers]のための多くの準備作業が含まれている」リリースでした。

- [HWI 2.3.0][jul hwi]では、DIY Jadeデバイスのサポートと、
  MacOS12.0以降のApple Siliconハードウェアでメインのhwiプログラムを実行するためのバイナリが追加されました。

- [LDK 0.0.116][jul ldk]には、[アンカーアウトプット][topic anchor outputs]および
  [keysend][topic spontaneous payments]による[マルチパスペイメント][topic multipath payments]のサポートが含まれていました。

- [BTCPay Server 1.11.x][aug btcpay]には、 インボイスレポートの改善、
  チェックアウトプロセスの追加のアップグレードおよびPOS端末の新機能が含まれていました。

- [BDK 0.28.1][aug bdk]では、[ディスクリプター][topic descriptors]で[P2TR][topic taproot]の
  [BIP86][]導出パスを使用するためのテンプレートが追加されました。

- [Core Lightning 23.08][aug cln]には、ノードを再起動することなく複数のノード設定を変更する機能、
  [codex32][topic codex32]形式のシードバックアップと復元のサポート、
  支払いの経路探索を改善する実験的プラグイン、[スプライシング][topic splicing]の実験的なサポートおよび
  ローカルで生成されたインボイスへの支払い機能が含まれていました。

- [Libsecp256k1 0.4.0][sep secp]は、後で[v2 P2Pトランスポートプロトコル][topic v2 p2p transport]に使用される
  ElligatorSwiftエンコーディングの実装を持つモジュールを追加しました。

- [LND v0.17.0-beta][oct lnd]には、
  [P2TR][topic taproot]アウトプットを使用してオンチェーンでファンディングされた
  [非公開チャネル][topic unannounced channels]の使用を可能にする「Simple Taproot Channel」の実験的なサポートが含まれていました。
  これは、Taproot Assetsや[PTLC][topic ptlc]など、LNDのチャネルに他の機能を追加する最初のステップです。
  このリリースには、[コンパクトブロックフィルター][topic compact block filters]を使用するNeutrinoバックエンドの
  ユーザー向けの大幅なパフォーマンスの向上と、LNDの組み込み[ウォッチタワー][topic watchtowers]機能の改善も含まれています。

- [LDK 0.0.117][oct ldk]には、直前のリリースに含まれていた[アンカーのアウトプット][topic anchor outputs]機能に関連する
  セキュリティバグ修正が含まれていました。このリリースでは、経路探索も改善され、
  [ウォッチタワー][topic watchtowers]のサポートの改善および、新しいチャネルの
  [バッチ][topic payment batching]ファンディングも可能になりました。

- [LDK 0.0.118][nov ldk]には、[オファープロトコル][topic offers]の実験的なサポートが含まれていました。

- [Core Lightning 23.11][nov cln]では、_rune_ 認証メカニズムの柔軟性が向上し、
  バックアップの検証が改善され、プラグイン用の新機能が提供されました。

- [Bitcoin Core 26.0][dec bcc]には、[バージョン2トランスポートプロトコル][topic v2 p2p transport]の実験的サポート、
  [miniscript][topic miniscript]での[Taproot][topic taproot]のサポート、
  [assumeUTXO][topic assumeutxo]の状態を操作するための新しいRPCおよび、
  [トランザクションのパッケージ][topic package relay]をローカルノードのmempoolに送信するための実験的なRPCが含まれていました。

</div>

## 10月

{:#pss}
Gijs van Damは、_支払いの分割と切り替え_ （PSS＝Payment Splitting and Switching）に関する
[研究結果とコード][oct pss]を投稿しました。彼のコードを使用すると、
ノードは受信した支払いを[複数のパーツ][topic multipath payments]に分割することができ、
最終的な受信者に到達するまでに複数の経路をたどることができます。たとえば、
アリスからボブの支払いの一部はキャロルを経由することができます。この手法は、
攻撃者がネットワーク全体の支払いを追跡するためにチャネル残高を調査する残高探索攻撃を大幅に防ぐことができます。
Van Damの研究によると、PSSを使用した場合、攻撃者が得る情報は62％減少することが示されました。
さらに、PSSはライトニングネットワークのスループットを向上させ、
[チャネルジャミング攻撃][topic channel jamming attacks]の軽減に役立つ可能性があります。

{:#sidepools}
開発者のZmnSCPxjは、LNの流動性管理を強化することを目的とした _サイドプール_ と呼ばれるコンセプトを[提案しました][oct sidepool]。
サイドプールには、LNチャネルと同様のマルチパーティオフチェーンステートコントラクトに資金を預ける複数の転送ノードが含まれます。
これにより、オフチェーンの参加者間で資金を再配分することができます。たとえば、
アリス、ボブ、キャロルがそれぞれ1 BTCでスタートした場合、
アリスが2 BTC、ボブが0 BTC、キャロルが1 BTCになるように状態を更新できます。
参加者は引き続き通常のLNチャネルを使用、アドバタイズします。これらのチャネルの残高が不均衡になった場合は、
ステートコントラクト内のオフチェーンのPeerSwapを介してリバランスが可能です。
この方法は、参加者にとってプライベートで、オンチェーンスペースが少なくて済み、
オンチェーンでのリバランス手数料が不要になる可能性が高いため、転送ノードの収益の可能性とLN支払いの信頼性が向上します。
ただし、これにはマルチパーティステートコントラクトが必要で、これは運用環境ではテストされていません。
ZmnSCPxjは、[LN-Symmetry][topic eltoo]または、Duplex Payment Channel上に構築することを提案していますが、
どちらにも利点と欠点があります。

{:#assumeutxo}
10月には、[assumeUTXOプロジェクト][topic assumeutxo]の最初のフェーズが[完了しました][oct assumeutxo]。
これには、assumedvalidなスナップショットのchainstateの使用と、バックグラウンドでの完全な検証同期の両方に必要な
残りの変更が含まれています。RPC経由でUTXOスナップションをロードできるようになります。
この機能セットはまだ経験の浅いユーザーが直接使用することはできませんが、
このマージは数年にわたる取り組みの集大成となりました。2018年に提案され、2019年に正式化されたこのプロジェクトは、
ネットワークに最初に参加する新しいフルノードのユーザー体験を大幅に向上させます。

{:#p2pv2}
また、10月に[BIP324][]で定義されている[バージョン2暗号化P2Pトランスポート][topic v2 p2p transport]のサポートが
Bitcoin Coreに[追加されました][oct p2pv2]。この機能は現在デフォルトで無効化されていますが、
`-v2transport`オプションを使用して有効にできます。暗号化トランスポートは、
ノードがどのトランザクションをそのピアにリレーしているかを（ISPのような）受動的な観察者が直接的に決定できなくすることで、
Bitcoinユーザーのプライバシーを向上させるのに役立ちます。また、セッションIDを比較することで、
暗号化トランスポートを使用してアクティブな中間観察者を検出することも可能です。
将来的には、[他の機能][topic countersign]を追加することで、
軽量クライアントがP2P暗号化接続を介して信頼できるノードに安全に接続できるようになる可能性があります。

{:#miniscript}
miniscriptディスクリプターのサポートについて、年間をとおしてBitcoin Coreでいくつかの追加の改善が見られました。
2月には、P2WSHアウトプットスクリプトのminiscriptディスクリプターを作成できる[機能][feb miniscript]が追加されました。
10月には、Tapscript用のminiscriptディスクリプターを含むTaprootをサポートするために
miniscriptのサポートが[更新されました][oct miniscript]。

{:#statebitvm}
ゼロ知識Validity Proofを使用したBitcoinの状態の圧縮方法が5月にRobin LinusとLukas Georgeによって
[説明されました][may state]。これにより、システム内の将来の操作をトラストレスに検証するために
クライアントがダウンロードする必要がある状態の量が大幅に削減されます。たとえば、
ブロックチェーン上で既に承認されているすべてのトランザクションを検証するのではなく、
比較的小さなValidity Proofのみで新しいフルノードを開始できます。
10月、Robin Linusは、Bitcoinのコンセンサスの変更を必要とせずに、
任意のプログラムの実行の成功を条件としてビットコインの支払いを可能にする方法であるBitVMを
[紹介しました][oct bitvm]。BitVMは大量のオフチェーンデータの交換を必要としますが、
合意に必要なのは1つのオンチェーントランザクションのみで、
紛争の場合に必要なのは少数のオンチェーントランザクションのみです。
BitVMは敵対的なシナリオでも、複雑なトラストレスなコントラクトを可能にし、
複数の開発者の注目を集めています。

## 11月

{:#offers}
[ブラインドパス][topic rv routing]と[Onionメッセージ][topic onion messages]の最終仕様と、
複数の人気のLNノードでの実装により、これらに依存する[オファープロトコル][topic offers]の開発が今年大幅に進みました。
オファーにより受取人のウォレットは、支払人のウォレットと共有できる短い _オファー_ を生成できます。
支払人のウォレットはオファーを使用して、LNプロトコル経由で受取人のウォレットに連絡し、
特定のインボイスを要求し、通常の方法で支払うことができます。これにより、
それぞれ異なるインボイスを生成できる再利用可能なオファーや、
支払いの数秒前に現在の情報（為替レートなど）で更新できるインボイス、
同じウォレットで複数回支払い可能な（定期購入など）オファーなどを作成できます。
[Core Lightning][feb cln offers]と[Eclair][feb eclair offers]におけるオファーの既存の実験的実装は、
年間をとおして更新され、オファーのサポートは[LDK][sept ldk offers]にも追加されました。
さらに11月には、オファーと互換性のあるライトニングアドレスの更新版の作成に関する[議論][nov offers]が行われました。

{:#liqad}
11月には[Liquidity Ads][topic liquidity advertisements]の仕様も[更新され][nov liqad]、
ノードが手数料と引き換えに資金の一部を新しい[デュアルファンディングチャネル][topic dual funding]に提供する意思があることを
アナウンスできるようになり、要求側ノードはすぐにLN支払いの受け取りを開始できるようになりました。
Liquidity Adsから作成されたチャネルがタイムロックを含むべきかどうかについて、
12月に入っても議論が[続きましたが][dec liqad]、更新はほとんどが小さなものでした。
タイムロックは、購入者が実際に支払いをした流動性を受け取るというインセンティブに基づく保証を与えることができますが、
悪意のある購入者や配慮のない購入者によって、過剰な量の提供者の資本をロックするために使用される可能性もあります。

<div markdown="1" class="callout" id="optech">

### 2023年のまとめ<br>Bitcoin Optech

{% comment %}<!-- commands to help me create this summary for next year

wc -w _posts/en/newsletters/2023-* _includes/specials/policy/en/*
(1 book page = 350 words)

git log --diff-filter=A --since='1 year ago' --name-only --pretty=format: _topics/en | sort -u | wc -l

wget https://anchor.fm/s/d9918154/podcast/rss
# use vim to delete all podcasts before this year
grep duration rss | sed 's!^.*>\([0-9].*\):..</.*$!\1!' | sed 's/:/ * 60 + /' | bc -l | numsum | echo $(cat) / 60 | bc -l
-->{% endcomment %}

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
    flex: 1 0 180px;
    max-width: 180px;
    box-sizing: border-box;
    padding: 5px; /* Adjust as needed */
    margin: 5px; /* Adjust as needed */
    /* Additional styling here */
}

@media (max-width: 720px) {
    #optech li {
        flex-basis: calc(50% - 10px); /* 2 columns */
    }
}

@media (max-width: 360px) {
    #optech li {
        flex-basis: calc(100% - 10px); /* 1 column */
    }
}
</style>

Optechの6年めは、51回の週刊[ニュースレター][newsletters]を発行し、
[mempoolポリシーに関する][policy series]10部構成のシリーズを発行し、
[トピックインデックス][topics index]に15の新しいページを追加しました。
Optechは今年、Bitcoinソフトウェアの研究開発に関する8万6000以上の英単語を公開し、
これはおそよ250ページの本に相当します。

さらに、今年の各ニュースレターには[ポッドキャスト][podcast]エピソードが付属しており、
音声形式で合計50時間以上、書き起こし形式では450,000ワードに達しました。
Bitcoinのトップコントリビューターの多くが番組にゲスト出演し、そのうち何人かは複数のエピソードに出演しており、
2023年には合計62人のゲストが登場しました:

- Abubakar Ismail
- Adam Gibson
- Alekos Filini
- Alex Myers
- Anthony Towns
- Antoine Poinsot
- Armin Sabouri
- Bastien Teinturier
- Brandon Black
- Burak Keceli
- Calvin Kim
- Carla Kirk-Cohen
- Christian Decker
- Clara Shikhelman
- Dan Gould
- Dave Harding
- Dusty Daemon
- Eduardo Quintana
- Ethan Heilman
- Fabian Jahr
- Gijs van Dam
- Gloria Zhao
- Gregory Sanders
- Henrik Skogstrøm
- Jack Ronaldi
- James O’Beirne
- Jesse Posner
- Johan Torås Halseth
- Joost Jager
- Josie Baker
- Ken Sedgwick
- Larry Ruane
- Lisa Neigut
- Lukas George
- Martin Zumsande
- Matt Corallo
- Matthew Zipkin
- Max Edwards
- Maxim Orlovsky
- Nick Farrow
- Niklas Gögge
- Olaoluwa Osuntokun
- Pavlenex
- Peter Todd
- Pieter Wuille
- Robin Linus
- Ruben Somsen
- Russell O’Connor
- Salvatore Ingala
- Sergi Delgado Segura
- Severin Bühler
- Steve Lee
- Steven Roose
- Thomas Hartman
- Thomas Voegtlin
- Tom Briar
- Tom Trevethan
- Valentine Wallace
- Vivek Kasarabada
- Will Clark
- Yuval Kogman
- ZmnSCPxj

Optechはまた、ビジネスコミュティから寄せられた2つのフィールドレポートも公開しました。
1つはBitGoのBrandon Blackによる手数料コストの削減とプライバシー向上のための
[MuSig2の実装][implementing MuSig2]に関するレポートで、2つめは、
WizardsardineのAntoine Poinsotによる[miniscriptを使用したソフトウェア構築][building software with miniscript]に関するレポートです。

[implementing musig2]: /ja/bitgo-musig2/
[building software with miniscript]: /ja/wizardsardine-miniscript/

</div>

## 12月

{:#clustermempool}
Bitcoin Coreの複数の開発者は、親トランザクションは子トランザクションよりも先に承認されなければならないという
トランザクションの必要な順序を維持しながら、mempoolの操作を簡素化するための新しい
[クラスターmempool][topic cluster mempool]の設計に取り組み[始めました][may cluster]。
トランザクションはクラスターにグループ化され、手数料率でソートされたチャンクに分割され、
手数料率の高いチャンクが最初に承認されるようにします。
これにより、mempool内の最も手数料率の高いチャンクを単純に選択することでブロックテンプレートを作成し、
手数料率の最も低いチャンクをドロップすることでトランザクションを削除することができます。
これは、既存の望ましくない動作の一部（最適ではない削除によりマイナーが手数料収入を失う可能性など）を修正し、
将来的にはmempoolの管理とトランザクションリレーの他の側面を改善できる可能性があります。
彼らの議論のアーカイブは、12月初旬に[公開されました][dec cluster]。

{:#warnet}
12月にはまた、（通常はテストネットワーク上で）定義された接続セットを持つ多数のBitcoinノードを起動するための
新しいツールも[公開されました][dec warnet announce]。これは、少数のノードでは再現するのが難しい動作や、
既知の攻撃やゴシップ情報の伝播など、パブリックネットワーク上で問題を引き起こす動作をテストするために使用できます。
このツールを使用した[公開例][dec zipkin warnet]の1つは、提案された変更の前後で
Bitcoin Coreのメモリ消費量の測定でした。

*私たちは、上記のすべてのBitcoinコントリビューターと、同様に重要な仕事をした他の多くの人々に、
今年もBitcoinの発展の素晴らしい年をもたらしてくれたことに感謝します。
Optechのニュースレターは、1月3日に通常の水曜日の発行スケジュールに戻ります。*

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}
[apr bitgo]: /ja/bitgo-musig2/
[apr blinding]: /ja/newsletters/2023/04/05/#bolts-765
[apr htlcendo]: /ja/newsletters/2023/05/17/#htlc
[apr ldk]: /ja/newsletters/2023/04/26/#ldk-0-0-115
[apr lnd]: /ja/newsletters/2023/04/05/#lnd-v0-16-0-beta
[apr loop]: /ja/newsletters/2023/05/24/#lightning-loop-musig2
[apr musig2 psbt]: /ja/newsletters/2023/10/18/#musig2-psbt-bip
[apr musig2]: /ja/newsletters/2023/04/12/#bips-1372
[apr rgb]: /ja/newsletters/2023/04/19/#rgb
[apr secp]: /ja/newsletters/2023/04/12/#libsecp256k1-0-3-1
[apr signrpc]: /ja/newsletters/2023/02/15/#lnd-7171
[apr splicing]: /ja/newsletters/2023/04/12/#splicing-specification-discussions
[apr taproot channels]: /ja/newsletters/2023/08/30/#lnd-7904
[apr watchtower]: /ja/newsletters/2023/04/05/#watchtower-accountability-proofs
[aug antidos]: /ja/newsletters/2023/08/09/#dos
[aug bdk]: /ja/newsletters/2023/08/09/#bdk-0-28-1
[aug btcpay]: /ja/newsletters/2023/08/02/#btcpay-server-1-11-1
[aug cln]: /ja/newsletters/2023/08/30/#core-lightning-23-08
[aug combo]: /ja/newsletters/2023/08/30/#txhash-csfs-covenant
[aug fraud]: /ja/newsletters/2023/08/23/#fraud-proof
[aug fundingdos]: /ja/newsletters/2023/08/30/#ln
[aug htlcendo]: /ja/newsletters/2023/08/09/#htlc
[aug lnd taproot]: /ja/newsletters/2023/08/30/#lnd-7904
[aug milksad]: /ja/newsletters/2023/08/09/#libbitcoin-bitcoin-explorer
[aug onion]: /ja/newsletters/2023/08/09/#bolts-759
[aug opreturn]: /ja/newsletters/2023/08/09/#bitcoin-core
[aug payjoin]: /ja/newsletters/2023/08/16/#payjoin
[aug sp]: /ja/newsletters/2023/08/09/#bitcoin-core-pr-review-club
[chatbtc]: https://chat.bitcoinsearch.xyz/
[dec bcc]: /ja/newsletters/2023/12/06/#bitcoin-core-26-0
[dec cluster]: /ja/newsletters/2023/12/06/#mempool
[dec liqad]: /ja/newsletters/2023/12/13/#liquidity-ads
[dec payjoin]: /ja/newsletters/2023/12/13/#bitcoin-core-payjoin
[dec warnet announce]: /ja/newsletters/2023/12/13/#bitcoin-warnet
[dec zipkin warnet]: /ja/newsletters/2023/12/06/#warnet
[feb bitcoinsearch]: /ja/newsletters/2023/02/15/#bitcoinsearch-xyz
[feb cln offers]: /ja/newsletters/2023/02/08/#core-lightning-5892
[feb codex32]: /ja/newsletters/2023/02/22/#codex32-bip
[feb eclair offers]: /ja/newsletters/2023/02/22/#eclair-2479
[feb htlcendo]: /ja/newsletters/2023/02/22/#feedback-requested-on-ln-good-neighbor-scoring-ln
[feb lnflag]: /ja/newsletters/2023/02/22/#ln-quality-of-service-flag-ln
[feb miniscript]: /ja/newsletters/2023/02/22/#bitcoin-core-24149
[feb op_vault2]: /ja/newsletters/2023/03/08/#op-vault
[feb op_vault]: /ja/newsletters/2023/02/22/#op-vault-bip
[feb ord1]: /ja/newsletters/2023/02/08/#discussion-about-storing-data-in-the-block-chain
[feb ord2]: /ja/newsletters/2023/02/15/#continued-discussion-about-block-chain-data-storage
[feb payjoin]: /ja/newsletters/2023/02/01/#payjoin
[feb storage]: /ja/newsletters/2023/02/15/#core-lightning-5361
[jamming paper]: /ja/newsletters/2022/11/16/#paper-about-channel-jamming-attacks
[jan bip329]: /ja/newsletters/2023/01/25/#bips-1383
[jan eclair]: /ja/newsletters/2023/01/04/#eclair-0-8-0
[jan hwi]: /ja/newsletters/2023/01/18/#hwi-2-2-0
[jan inquisition]: /ja/newsletters/2023/01/04/#bitcoin-inquisition
[jan op_vault]: /ja/newsletters/2023/01/18/#vault-opcode
[jan potentiam]: /ja/newsletters/2023/01/11/#ln
[jul cleanup]: /ja/newsletters/2023/07/12/#ln
[jul htlcendo]: /ja/newsletters/2023/07/26/#channel-jamming-mitigation-proposals
[jul hwi]: /ja/newsletters/2023/07/26/#hwi-2-3-0
[jul ldk]: /ja/newsletters/2023/07/26/#ldk-0-0-116
[jul lnclose]: /ja/newsletters/2023/07/26/#ln
[jul pdk]: /ja/newsletters/2023/07/19/#payjoin-sdk
[jul summit]: /ja/newsletters/2023/07/26/#ln-summit
[jul vls]: /ja/newsletters/2023/07/19/#vls-validating-lightning-signer-beta
[jun eclair]: /ja/newsletters/2023/06/21/#eclair-v0-9-0
[jun matt]: /ja/newsletters/2023/06/07/#ctv-joinpool-matt
[jun sp]: /ja/newsletters/2023/06/14/#bip
[jun specsf]: /ja/newsletters/2023/06/28/#speculatively-using-hoped-for-consensus-changes
[mar cln]: /ja/newsletters/2023/03/08/#core-lightning-23-02
[mar mpchan]: /ja/newsletters/2023/03/29/#preventing-stranded-capital-with-multiparty-channels-and-channel-factories
[mar rb]: /ja/newsletters/2023/03/29/#rust-bitcoin-0-30-0
[may ark]: /ja/newsletters/2023/05/31/#joinpool
[may bcc]: /ja/newsletters/2023/05/31/#bitcoin-core-25-0
[may cln]: /ja/newsletters/2023/05/24/#core-lightning-23-05
[may cluster]: /ja/newsletters/2023/05/17/#mempool-clustering
[may lsp]: /ja/newsletters/2023/05/17/#lsp
[may matt]: /ja/newsletters/2023/05/03/#matt-vault
[may payjoin]: /ja/newsletters/2023/05/17/#payjoin
[may state]: /ja/newsletters/2023/05/24/#validity-proof
[newsletters]: /ja/newsletters/
[nov cln]: /ja/newsletters/2023/11/29/#core-lightning-23-11
[nov cov]: /ja/newsletters/2023/11/01/#continued-discussion-about-scripting-changes
[nov htlcagg]: /ja/newsletters/2023/11/08/#htlc
[nov ldk]: /ja/newsletters/2023/11/01/#ldk-0-0-118
[nov liqad]: /ja/newsletters/2023/11/29/#liquidity-ads
[nov offers]: /ja/newsletters/2023/11/22/#ln
[oct assumeutxo]: /ja/newsletters/2023/10/11/#bitcoin-core-27596
[oct bitvm]: /ja/newsletters/2023/10/18/#payments-contingent-on-arbitrary-computation
[oct cycling]: /ja/newsletters/2023/10/25/#htlc
[oct generic]: /ja/newsletters/2023/10/25/#research-into-generic-covenants-with-minimal-script-language-changes
[oct ldk]: /ja/newsletters/2023/10/11/#ldk-0-0-117
[oct lnd]: /ja/newsletters/2023/10/04/#lnd-v0-17-0-beta
[oct miniscript]: /ja/newsletters/2023/10/18/#bitcoin-core-27255
[oct op_cat]: /ja/newsletters/2023/10/25/#op-cat-bip
[oct p2pv2]: /ja/newsletters/2023/10/11/#bitcoin-core-28331
[oct pss]: /ja/newsletters/2023/10/04/#payment-splitting-and-switching
[oct sidepool]: /ja/newsletters/2023/10/04/#pooled-liquidity-for-ln-ln
[oct txhash]: /ja/newsletters/2023/10/11/#op-txhash
[policy series]: /ja/blog/waiting-for-confirmation/
[sep lnscale]: /ja/newsletters/2023/09/27/#covenant-ln
[sep secp]: /ja/newsletters/2023/09/06/#libsecp256k1-0-4-0
[sept compress]: /ja/newsletters/2023/09/06/#bitcoin
[sept ldk offers]: /ja/newsletters/2023/09/20/#ldk-2371
[sept tapassets]: /ja/newsletters/2023/09/13/#taproot-assets
[tapsim]: /ja/newsletters/2023/06/21/#tapscript-tapsim
[tldr]: https://tldr.bitcoinsearch.xyz/
[topics index]: /en/topics/
[yirs 2018]: /en/newsletters/2018/12/28/
[yirs 2019]: /ja/newsletters/2019/12/28/
[yirs 2020]: /en/newsletters/2020/12/23/
[yirs 2021]: /ja/newsletters/2021/12/22/
[yirs 2022]: /ja/newsletters/2022/12/21/
