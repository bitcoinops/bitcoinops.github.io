---
title: 'Bitcoin Optech Newsletter #334: 2024年振り返り特別号'
permalink: /ja/newsletters/2024/12/20/
name: 2024-12-20-newsletter-ja
slug: 2024-12-20-newsletter-ja
type: newsletter
layout: newsletter
lang: ja

excerpt: >
  第7回のBitcoin Optech年間振り返り特別号では、2024年のBitcoinの注目すべき動向についてまとめています。
---
{{page.excerpt}}  これは、[2018年][yirs 2018]、[2019年][yirs 2019]、[2020年][yirs 2020]、
[2021年][yirs 2021]、[2022年][yirs 2022]、[2023年][yirs 2023]のまとめの続編です。

## 内容

* 1月
  * [手数料依存のタイムロック](#feetimelocks)
  * [コントラクトプロトコルからの退出の最適化](#optimizedexits)
  * [LN-SymmetryのPoC実装](#poclnsym)
* 2月
  * [Replace by feerate](#rbfr)
  * [人が読める支払い指示](#hrpay)
  * [ASMap生成の改善](#asmap)
  * [LNのデュアルファンディング](#dualfunding)
  * [将来の手数料率に対するトラストレスな賭け](#betfeerates)
* 3月
  * [BINANAとBIP](#binanabips)
  * [強化された手数料の推定](#enhancedfeeestimates)
  * [より効率的なトランザクションスポンサーシップ](#efficientsponsors)
* 4月
  * [コンセンサスクリーンアップ](#consensuscleanup)
  * [BIPプロセスの改革](#bip2reform)
  * [インバウンドルーティング手数料](#inboundrouting)
  * [弱ブロック](#weakblocks)
  * [testnetの再起動](#testnet)
  * [開発者の逮捕](#devarrests)
* 5月
  * [サイレントペイメント](#silentpayments)
  * [BitVMX](#bitvmx)
  * [匿名使用トークン](#aut)
  * [LNチャネルのアップグレード](#lnup)
  * [プールマイナー向けEcash](#minecash)
  * [Miniscriptの仕様](#miniscript)
  * [Utreexoベータ](#utreexod)
* 6月
  * [LN支払いの実行可能性とチャネルの枯渇](#lnfeasibility)
  * [量子耐性のあるトランザクション署名](#quantumsign)
* 7月
  * [BOLT11インボイス用のブラインドパス](#bolt11blind)
  * [閾値署名用のChillDKG鍵生成](#chilldkg)
  * [MuSig用のBIPと閾値署名](#musigthresh)
* 8月
  * [Hyperionネットワークシミュレーター](#hyperion)
  * [フルRBF](#fullrbf)
* 9月
  * [ハイブリッドチャネルジャミングの緩和策のテストと調整](#hybridjamming)
  * [シールドCSV](#shieldedcsv)
  * [LNオフライン支払い](#lnoff)
* 10月
  * [BOLT12オファー](#offers)
  * [マイニングインターフェース、ブロック保留およびシェアの検証コスト](#pooledmining)
* 11月
  * [SuperScalarタイムアウトツリー型チャネルファクトリー](#superscalar)
  * [高速かつ安価なオフチェーン支払いの解決](#opr)
* 12月
* 注目のまとめ
  * [脆弱性の開示](#vulnreports)
  * [クラスターmempool](#cluster)
  * [P2Pトランザクションリレー](#p2prelay)
  * [コベナンツとスクリプトのアップグレード](#covs)
  * [人気のインフラストラクチャプロジェクトのメジャーリリース](#releases)
  * [Bitcoin Optech](#optech)

---

## 1月

{:#feetimelocks}
- **<!--fee-dependent-timelocks-->手数料依存のタイムロック:** John Lawが[手数料依存のタイムロック][news283 feelocks]を提案しました。
これは、ソフトフォークでブロックの手数料率の中央値がユーザーの指定したレベルを下回った場合にのみ
[タイムロック][topic timelocks]を失効させるというものです。
これにより、タイムロックの期限切れ間際に手数料が高騰することで、承認が妨げられるのを防ぐことができます。
その代わり、タイムロックは手数料が下がるまで延長され、大量のチャネル閉鎖が起きた際に、
[強制的に期限切れになる][topic expiration floods]という長年の懸念に対処しています。
この提案は、[チャネルファクトリー][topic channel factories]や
[Joinpool][topic joinpools]のようなマルチユーザー設定のセキュリティを向上させるとともに、
参加者に手数料の高騰を回避するインセンティブを与えます。議論には、
Taprootの[annex][topic annex]内へのパラメーターの格納や、
軽量クライント向けの手数料率のコミットメント、プルーニングノードのサポート、
[帯域外の手数料][topic out-of-band fees]の影響などが含まれました。

{:#optimizedexits}
- **<!--optimized-contract-protocol-exits-->コントラクトプロトコルからの退出の最適化:** Salvatore Ingalaが、Joinpoolやチャネルファクトリーのようなマルチパーティーコントラクトからの
[退出を最適化][news283 exits]する方法を提案しました。提案された方法では、
ユーザーが個別にトランザクションをブロードキャストするのではなく、
単一のトランザクションに調整できるようにします。これにより、
オンチェーンのサイズは少なくとも50%、理想的な状況では最大99%削減されます。
これは手数料が高い場合には特に重要です。そして保証金の仕組みにより正直な実行を保証します。
つまり、参加者の1人がトランザクションを構築しますが、不正が証明された場合は、保証金を失います。
Ingalaは、これを[OP_CAT][topic op_cat]と[MATT][topic acc]のソフトフォークで実装することを提案しており、
[OP_CSFS][topic op_checksigfromstack]と64-bitの算術演算が使用できるとさらに効率化できます。

{:#poclnsym}
- **LN-SymmetryのPoC実装:** Gregory Sandersが、Core Lightningのフォークを使用した[LN-Symmetry][topic eltoo]の
PoC[実装][news284 lnsym]を共有しました。LN-Symmetryは、
ペナルティトランザクションを必要としない双方向のペイメントチャネルを可能にしますが、
子トランザクションが任意のバージョンの親トランザクションを使用できるようにするための
[SIGHASH_ANYPREVOUT][topic sighash_anyprevout]のようなソフトフォークに依存しています。
Sandersは、[LN-Penalty][topic ln-penalty]と比較したそのシンプルさ、
（[パッケージリレー][topic package relay]と[エフェメラルアンカー][topic ephemeral anchors]に関する
彼の研究をきっかけに）[Pinning][topic transaction pinning]を回避することの難しさ、
および[OP_CTV][topic op_checktemplateverify]のエミュレーションによる支払いの高速化の可能性を強調しました。
彼は、ペナルティが不要で、チャネルの実装を簡素化し、チャネルリザーブを回避できることを確認しました。
ただし、LN-Symmetryでは、誤用を防ぐために[CLTVの期限切れのdelta値][topic cltv expiry delta]を長くする必要があります。

## 2月

{:#rbfr}
- **Replace by feerate:** Peter Toddが、標準の[RBF][topic rbf]ポリシーが失敗した場合の
[トランザクションのPinning][topic transaction pinning]に対処するために、
[Replace by Feerate][news288 rbfr]（RBFr）を提案しました。
RBFrには2つのバリエーションがあり、純粋なRBFrでは、
はるかに高い手数料率（たとえば2倍）で無制限の置換が可能です。
ワンショットRBFrでは、置換トランザクションがmempoolの最上位に入った場合に、
適度に高い手数料（たとえば1.25倍）で1回の置換が可能です。Mark Erhardtが最初の問題点を特定し、
他の開発者は利用可能なツールでこのアイディアを完全に分析することの複雑さについて議論しました。
Toddは実験的な実装をリリースし、他の開発者はトランザクションPinningに対処するための代替ソリューションの開発を続けました。
これには、採用されるソリューションの信頼性を高めるために必要なツールの開発も含まれます。

{:#hrpay}
- **<!--human-readable-payment-instructions-->人が読める支払い指示:** Matt Coralloが、DNSベースの[人が読めるBitcoinの支払い指示][news290 dns]のためのBIPを提案しました。
これによりメールアドレスような文字列（例：example@example.com）で、
[BIP21][] URIを含むDNSSEC署名付きのTXTレコードを解決できます。
これは、オンチェーンアドレスや[サイレントペイメント][topic silent payments]、
LN[オファー][topic offers]をサポートし、他のペイメントプロトコルにも簡単に拡張できます。
この[仕様][news307 bip353]は、[BIP353][]として追加されました。
Coralloはまた、LNノード用に[BOLT][news333 dnsbolt]と[BLIP][news306 dnsblip]を起草し、
ワイルドカードDNSレコードとオファーした安全な支払い先の解決を可能にしました。
[実装][news329 dnsimp]は、11月にLDKにマージされました。
このプロトコルとサイレントペイメントの開発を受け、Josie Bakerが
[BIP21][]ペイメントURIの改訂に関する[議論][news292 bip21]を始め、
議論は今年後半まで[続きました][news306 bip21]。

{:#asmap}
- **<!--improved-asmap-generation-->ASMap生成の改善:** Fabian Jahrは、複数の開発者が[独自に同等のASMapを作成できる][news290 asmap]ソフトウェアを作成しました。
これにより、Bitcoin Coreはピアの接続を多様化し、[エクリプス攻撃][topic eclipse attacks]に抵抗できます。
Jahrのツールが広く受け入れられれば、Bitcoin CoreにデフォルトでASMapが組み込まれ、
複数のサブネットを制御する当事者からの攻撃に対する保護が強化される可能性があります。

{:#dualfunding}
- **<!--ln-dual-funding-->LNのデュアルファンディング:** [デュアルファンディング][topic dual funding]の[サポート][news290 dualfund]が
インタラクティブなトランザクション構築プロトコルとともに、LN仕様に追加されました。
インタラクティブな構築により、2つのノードは、
ファンディングトランザクションを一緒に構築するために使用する設定とUTXOの詳細を交換できます。
デュアルファンディングは、トランザクションにどちらか一方または両者のインプットを含めることができます。
たとえば、アリスがボブとチャネルを開きたい場合に、この仕様の変更前は、
アリスはチャネル用の資金を全額提供しなければなりませんでした。
デュアルファンディングをサポートする実装を使用すると、アリスは、
初期のチャネル状態にボブが資金を全額を提供したり、それぞれが資金を提供することもできるチャネルを
ボブと開くことができます。これは、まだ仕様に追加されていない
[Liquidity Ads][topic liquidity advertisements]プロトコルと組み合わせることができます。

{:#betfeerates}
- **<!--trustless-betting-on-future-feerates-->将来の手数料率に対するトラストレスな賭け:** ZmnSCPxjが、2人の参加者が[将来のブロックの手数料率に賭ける][news291 bets]ことができる
トラストレスなスクリプトを提案しました。将来のブロックでトランザクションが承認されることを望むユーザーは、
このスクリプトを使用して、その時点で[手数料率][topic fee estimation]が異常に高くなるリスクを相殺することができます。
ユーザーがトランザクションの承認を必要とする頃にブロックをマイニングすることを期待するマイナーは、
このコントラクトを使用して、その時の手数料率が異常に低くなるリスクを相殺することができます。
マイナーの意思決定は、実際のマイニング状況のみに依存するため、集中型の市場で見られるような操作を防止する設計となっています。
このコントラクトはトラストレスで、協調的な支払いパスにより双方のコストが最小限に抑えられます。

<div markdown="1" class="callout" id="vulnreports">
## 2024年のまとめ: 脆弱性の開示

2024年、Optechは20件を超える脆弱性の開示をまとめました。その大半は、
今年初めて公開されたBitcoin Coreの古い脆弱性の開示でした。
脆弱性の報告は、開発者とユーザーの双方に過去の問題から学ぶ機会を与え、
[責任ある開示][topic responsible disclosures]により、私たち全員が、
慎重に発見を報告してくれた方々に感謝することができます。

_注: Optechは、脆弱性の発見者が、
ユーザーへの危害のリスクを最小化するために合理的な努力をしたと考えられる場合にのみ、発見者の名前を公表しています。
このセクションで名前が上がっている方の洞察力とユーザーの安全に対する明確な配慮に感謝します。_

2023年後半、Niklas Göggeは、彼が2年前に報告しLNDの修正バージョンがリリースされた
2つの脆弱性を[公開しました][news283 lndvuln]。1つめはDoSの脆弱性で、
LNDがメモリ不足でクラッシュする可能性がありました。2つめは検閲の脆弱性で、
攻撃者が、LNDノードがネットワーク全体でターゲットチャネルの更新に関して学習するのを阻止できる可能性があります。
攻撃者はこれを利用して、ノードが支払いを送信する際に特定のルートを選択するように偏向させ、
転送手数料を増やし、ノードが送信した支払いに関するより多くの情報を攻撃者に与えることができます。

1月、Matt Morehouseは、Core Lightningのバージョン23.02から23.05.2に影響する
[脆弱性を発表しました][news285 clnvuln]。彼が以前発見して開示した
フェイクファンディングの修正を実装したノードを再テストした際、
約30秒の作業でCLNをクラッシュさせる競合状態を引き起こすことができました。
LNノードがシャットダウンすると、悪意ある取引相手や動作不良の取引相手からユーザーを保護できず、
ユーザーの資金が危険にさらされます。

1月にはまた、Göggeがbtcdフルノードで発見したコンセンサス障害の脆弱性を[発表しました][news286 btcdvuln]。
このコードは、トランザクションのバージョン番号を誤って解釈し、
相対的タイムロックを使用するトランザクションに誤ったコンセンサスルールを適用する可能性があります。
これにより、btcdフルノードはBitcoin Coreと同じ承認済みトランザクションを確認できなくなり、
ユーザーが資金を失うリスクにされされる可能性があります。

2月には、Eugene Siegelが、約3年前に最初に開示したBitcoin Coreの脆弱性の報告を[公開しました][news288 bccvuln]。
この脆弱性は、Bitcoin Coreが最近のブロックをダウンロードするのを防止するのに使用される可能性があります。
この脆弱性を利用すると、接続されたLNノードが[HTLC][topic htlc]を解決するために必要なプリイメージを知ることができなくなり、
資金が失われる可能性があります。

6月には、Morehouseが再び、0.17.0未満のバージョンのLNDをクラッシュさせる脆弱性を[開示しました][news308 lndvuln]。
前述したように、シャットダウンされたLNノードは、悪意ある取引相手や動作不良の取引相手から
ユーザーを保護することができず、ユーザーの資金を危険にさらすことになります。

7月には、Bitcoin Coreの過去のバージョンに影響する[複数の脆弱性][news310 disclosures]の最初の公開がありました。
Wladimir J.Van Der Laanは、Bitcoin Coreが使用するライブラリで
Aleksandar Nikolicが発見した脆弱性を調査していたところ、
リモートコード実行を可能にする別の脆弱性を[発見しました][news310 wlad]。
この脆弱性は上流のライブラリで修正され、Bitcoin Coreに取り込まれました。
開発者のEvil-Knievelは、多くのBitcoin Coreノードのメモリを使い果たし
クラッシュさせる脆弱性を[発見しました][news310 ek]。これは、
（LNユーザーなどから）資金を盗むたの他の攻撃の一部として使用される可能性があります。
John Newberyは、Amiti Uttarwarによる共同発見を引用し、
未承認トランザクションを検閲するために使用できる脆弱性を[開示しました][news310 jnau]。
この脆弱性も（LNユーザーなどから）資金を盗むための攻撃の一部として使用される可能性があります。
CPUとメモリを過剰に使用しノードのクラッシュにつながる可能性のある脆弱性が[報告されました][news310 unamed]。
開発者のpracticalswiftは、ノードが一定期間正当なブロックを無視する脆弱性を[発見しました][news310 ps]。
これはLNのようなコントラクトプロトコルに影響し、時間的な制約があるイベントへの対応を遅らせる可能性があります。
開発者のsec.eineは、CPUを過剰に消費する脆弱性を[開示しました][news310 sec.eine]。
この脆弱性は、ノードが新しいブロックやトランザクションを処理できないようにするのに使用され、
資金の損失につながる可能性のある複数の問題を引き起こす可能性があります。
John Newberyは、多くのノードのメモリを使い果たし、クラッシュを引き起こす可能性のある別の脆弱性を責任を持って[開示しました][news310 jn1]。
Cory Fieldsは、Bitcoin Coreをクラッシュさせる可能性のある別のメモリ枯渇の脆弱性を[発見しました][news310 cf]。
John Newberyは、帯域幅を浪費し、ユーザーのピア接続スロットの数を制限する可能性のある
3つめの脆弱性を[開示しました][news310 jn2]。Michael Fordは、
[BIP72][] URLをクリックしたすべての人に影響し、ノードをクラッシュさせる可能性のある
メモリ枯渇の脆弱性を[報告しました][news310 mf]。

その後の数ヶ月で、Bitcoin Coreからさらに多くの開示が行われました。
Eugene Siegelは、`addr`メッセージを使用してBitcoin Coreをクラッシュさせる方法を[発見しました][news314 es]。
Ronald Huveneersによるminiupnpcライブラリに関するレポートを調査していたMichael Fordは、
ローカルネットワーク接続を使用してBitcoin Coreをクラッシュさせる別の方法を[発見しました][news314 mf]。
David JaensonとBraydon Fullerおよび複数のBitcoin Core開発者は、
新しく起動したフルノードが最適なブロックチェーンに同期するのを妨げる脆弱性を[発見しました][news322 checkpoint]。
この脆弱性は、Niklas Göggeによるマージ後のバグ修正で解消されました。
Niklas Göggeは、コンパクトブロックメッセージの処理の問題を悪用した
別のリモートクラッシュの脆弱性を[発見しました][news324 ng]。
複数のユーザーからCPUの消費量が多すぎるという[報告][news324 b10caj]があり、
開発者の0xB10CとAnthony Townsが原因を調査し解決策を実装しました。
William Casarinやghost43を含む複数の開発者からノードの問題が報告され、
Suhas DaftuarがBitcoin Coreが長時間ブロックを受け入れられない脆弱性を[特定しました][news324 sd]。
今年最後のBitcoin Coreの脆弱性[レポート][news328 multi]では、
ブロックを10分以上遅らせる方法が説明されていました。

Lloyd FournierとNick FarrowおよびRobin Linusは、
Bitcoin署名デバイスから鍵を盗み出すための改良された方法[Dark Skippyを発表しました][news315 exfil]。
この方法は、以前約15社のハードウェア署名デバイスベンダーに責任を持って公開されていました。
_鍵の抽出_ は、トランザクションに署名するコードが、秘密鍵やBIP32 HDウォレットのシードなど、
基盤となる鍵素材に関する情報を漏らすような方法で意図的に署名を作成する際に発生します。
攻撃者がユーザーのシードを入手すると、彼らはいつでもユーザーの資金を盗むことができます（
攻撃者が迅速に行動すれば、盗み出しにつながるトランザクションで使用される資金も含みます ）。
これにより、[抽出防止署名プロトコル][topic exfiltration-resistant signing]に関する
[新たな議論が起こりました][news317 exfil]。

新しいtestnetの導入により、[新しいタイムワープ脆弱性][news316 timewarp]も発見されました。
testnet4には元々あった[タイムワープ][topic time warp]脆弱性の修正が含まれていましたが、
開発者のZawyが8月に、難易度を約94%減らすことができる新しいエクスプロイトを発見しました。
Mark "Murch" Erhardtは、攻撃の難易度を最小値まで下げられるようさらに開発を進めました。
いくつかの解決策が提案され、それらのトレードオフについては12月時点でもまだ[議論][news332 ccsf]が続いてました。

![タイムワープ脆弱性の図](/img/posts/2024-time-warp/new-time-warp.png)

10月、Antoine PoinsotとNiklas Göggeは、btcdフルノードに影響する
別の[コンセンサス障害の脆弱性][news324 btcd]を公開しました。
Bitcoinのオリジナルのバージョン以来、ハッシュする前にスクリプトから署名を抽出するために使用される
あまり知られていない（しかし重要な）関数が含まれています。btcdの実装は、
Bitcoin Coreに継承されたオリジナルバージョンとは若干異なっており、
攻撃者は、一方のノードでは受け入れられるものの、もう一方のノードでは拒否されるトランザクションを作成することができ、
さまざまな方法でユーザーに損失を与えることができます。

12月には、David Hardingが、デフォルトでEclair、LDK、LND（および非デフォルト設定のCore Lightning）に影響する
脆弱性を[開示しました][news333 if]。チャネルの開設を要求し、チャネルを閉じる際に必要な
[内部的な手数料][topic fee sourcing]を支払う責任がある参加者（開設者）は、
ある状態でチャネルの金額の98%を手数料として支払うことをコミットし、
次の状態で最小限の金額にコミットするよう削減し、チャネルの金額の99%を他の参加者に移動し、
その後98%を手数料として支払う状態でチャネルを閉じることができます。
これにより開設者は、古い状態を使用したことでチャネルの金額の1%を失いますが、
取引相手はチャネルの金額の98%を失います。開設者が自分でトランザクションをマイニングした場合、
手数料として支払われたチャネルの金額の98%を保持できます。
この方法では、ブロック毎に約3,000のチャネルで奪うことができます。

Wasabiと関連ソフトウェアに影響する非匿名化の[脆弱性][news333 deanon]は、Optechが今年まとめた最後の開示でした。
この脆弱性により、WasabiやGingerWalletで使用されるタイプの[Coinjoin][topic coinjoin]コーディネーターは、
匿名であるはずのクレデンシャルをユーザーに提供し、追跡を可能にするために区別できるようすることができます。
クレデンシャルを区別する方法の1つは排除されましたが、コーディネーターが異なるクレデンシャルを生成することを可能にする
より一般的な問題が2021年にYuval Kogmanによって特定され、この記事の執筆時点では未修正のままです。

<!-- Not summarized here but discussed in the P2P improvements section
- https://bitcoinops.org/en/newsletters/2024/03/27/#disclosure-of-free-relay-attack
- https://bitcoinops.org/en/newsletters/2024/07/26/#varied-discussion-of-free-relay-and-fee-bumping-upgrades
-->

</div>

## 3月

{:#binanabips}
- **BINANAとBIP:** BIPのマージに関する継続的な問題により、1月に仕様やその他のドキュメント用に
[新しくBINANAリポジトリ][news286 binana]が作成されました。2月、3月には、
既存のBIPエディターが支援を要請し、[新しいエディターを追加するプロセス][news292 bips]が始まりました。
4月に大規模な公開討論が最高潮に達した後、Bitcoinのコントリビューター数名が[BIPエディター][news299 bips]になりました。

{:#enhancedfeeestimates}
- **<!--enhanced-feerate-estimation-->強化された手数料の推定:** Abubakar Sadiq Ismailが、リアルタイムのmempoolのデータを使用して
[Bitcoin Coreの手数料率の推定][news295 fees]を強化する提案をしました。
現在の推定は、承認済みのトランザクションデータに依存しており、更新は遅いものの細工は困難です。
Ismailは、現在のアプローチと新しいmempoolベースのアルゴリズムを比較する予備的なコードを開発しました。
議論では、mempoolデータが推定値を上下に調整すべきか、それとも下げるだけにすべきかが強調されました。
二重調整により実用性は向上しますが、調整を下げた推定値に限定すると、細工をより効果的に防止できます。

{:#efficientsponsors}
- **<!--more-efficient-transaction-sponsorship-->より効率的なトランザクションスポンサーシップ:** Martin Habovštiakは、taproot annexを使用して[無関係なトランザクションの優先順位を上げる][news295 sponsor]方法を提案し、
以前の[手数料スポンサーシップ][topic fee sponsorship]の方法と比較して、スペース要件を大幅に削減しました。
David Hardingは、署名コミットメントメッセージを使用して、
オンチェーンスペースを必要とせず、ブロックの順序に依存する、さらに効率的なアプローチを提案しました。
重複するスポンサートランザクションについては、HardingとAnthony Townsは、
ブースト毎に0.5 vbyteしか使用しない代替案を提案しました。Townsは、
これらのスポンサーシップの方法は提案中の[クラスターmempool][topic cluster mempool]の設計と互換性があるものの、
最も効果的なバージョンでは、ノードが有効性の情報を事前に計算して保存するのが難しいため、
トランザクションの有効性のキャッシュに若干課題があると指摘しました。
このスポンサーシップのアプローチでは、最小限のコストで動的な手数料の引き上げが可能になるため、
[外部からの手数料][topic fee sourcing]を必要とするプロトコルにとって魅力的ですが、
トラストレスなアウトソースは依然として問題です。Suhas Daftuarは、
スポンサーシップは非参加ユーザーに問題を引き起こす可能性があると警告し、
意図しない影響を避けるために採用する場合はオプトインにすることを提案しました。

## 4月

{:#consensuscleanup}
- **<!--consensus-cleanup-->コンセンサスクリーンアップ:** Antoine PoinsotがMatt Coralloの2019年のコンセンサスクリーンアップ提案を[再検討し][news296 ccsf]、
検証が遅いブロックや、盗難を可能にするタイムワープ攻撃、軽量クライントとフルノードに影響する
[フェイクトランザクションの脆弱性][topic merkle tree vulnerabilities]などの問題に対処します。
Poinsotはまた、ブロック1,983,702でフルノードに影響する[重複トランザクション][topic duplicate transactions]の問題にも焦点を当てました。
すべての問題にはソフトフォークによる解決策がありますが、検証の遅いブロックに対する1つの修正案では、
稀な事前署名済みトランザクションが無効になる可能性があるという懸念がありました。
提案された更新の1つは、軽量クライアントや（場合によっては）フルノードに影響するマークルツリーの脆弱性を軽減する代替方法を検討するもので、
8月、9月に重要な[議論][news319 merkle]が行われました。
Bitcoin Coreは可能な限り脆弱性を軽減しましたが、以前のリファクタリングで重要な保護が削除されたため、
Niklas GöggeはBitcoin Core用に現在検出可能なすべての脆弱性を可能な限り早く検出し、
無効なブロックを拒否するコードを作成しました。12月には、コンセンサスクリーンアップソフトフォークを使用して、
元のコンセンサスクリーンアップ提案用に設計されたルールを[testnet4][topic testnet]に実装した後に発見された
[タイムワープ脆弱性][topic time warp]のZawy-Murchバージョンを修正することについて[議論][news332 zmwarp]が行われました。

{:#bip2reform}
- **<!--reforming-the-bips-process-->BIPプロセスの改革:** 新しいBIPエディターの追加に関する議論から派生して、
新しいBIPの追加と既存のBIPの更新に関する現在のプロセスを規定する[BIP2の改革][news297 bips]が望まれました。
議論は翌月も[続き][news303 bip2]、9月には更新されたプロセス用の[BIPのドラフト][news322 newbip2]が公開されました。

{:#inboundrouting}
- **<!--inbound-routing-fees-->インバウンドルーティング手数料:** LNDが、Joost Jagerが推進する[インバウンドルーティング手数料][news297 inbound]をサポートし、
ノードはピアから受信した支払いに対してチャネル固有の手数料を請求できるようになります。
これにより、ノードは流動性を管理しやすくなり、
たとえば管理の不十分なノードからのインバンド支払いに対してより高い手数料を課すことができます。
インバウンド手数料は、後方互換性があり、最初は旧ノードと連携するためにマイナス（割引など）に設定されています。
数年前に提案されたものの、他のLN実装は、設計上の懸念や互換性の問題を理由にこの機能に抵抗してきました。
この機能はLNDで年間を通して開発が続けられました。

{:#weakblocks}
- **<!--weak-blocks-->弱ブロック:** Greg Sandersが、トランザクションリレーとマイニングのポリシーが異なる中で、
[弱ブロック][news299 weakblocks]（Pow（Proof-of-Work）が不十分なものの有効なトランザクションを含むブロック）を使用して
[コンパクトブロックリレー][topic compact block relay]を改善する提案を行いました。
マイナーは、マイニングしようとするトランザクションを反映して、PoWの割合に比例した弱ブロックを生成します。
弱ブロックは、作成コストが高いため悪用されにくく、過剰な帯域幅を浪費することなく
mempoolとキャッシュを更新することができます。これにより、マイナーが非標準トランザクションをブロックに含めた場合でも、
コンパクトブロックリレーの有効性が維持されます。弱ブロックは、[Pinning攻撃][topic transaction
pinning]への対処や、[手数料率の推定][topic fee estimation]の強化にもなります。
SandersのPoC実装はこのアイディアを実証しています。

{:#testnet}
- **<!--restarting-testnet-->testnetの再起動:** Jameson Loppが、4月に現在のBitcoinの公開[testnet][topic testnet]（testnet3）の問題について議論を開始し、
特殊ケースのコンセンサスルールのセットを使用して、[testnetを再起動する][news297 testnet]ことを提案しました。
5月には、Fabian JahrがBIPのドラフトとtestnet4の実装の提案を[発表しました][news306 testnet]。
[BIP][news315 testnet4bip]とBitcoin Coreの[実装][news315 testnet4imp]は8月にマージされました。

{:#devarrests}
- **<!--developers-arrested-->開発者の逮捕:** 4月は、プライバシーソフトウェアに注力する[2人のBitcoin開発者の逮捕][news300 arrest]と
法的リスクを理由に米国へのサービスを停止する意向を発表した少なくとも2社のニュースで残念な終わりを迎えました。

<div markdown="1" class="callout" id="cluster">
## 2024年のまとめ: クラスターmempool

2023年からの[mempoolの再設計][news251 cluster]のアイディアは、2024年を通して、
複数のBitcoin Core開発者にとって特に焦点となりました。クラスターmempoolを使用すると、
マイナーがローカルノードのmempoolと同じmempoolを持っている場合に、
マイナーが作成するすべてのブロックに対するトランザクションの影響をより簡単に推論できるようになります。
これによりトランザクションの排除がより合理的になり、[置換トランザクション][topic rbf]（またはトランザクションのセット）が
置換元のトランザクションよりも優れているかどうかを判断するのに役立ちます。
これはLNのようなコントラクトプロトコルに影響を及ぼす複数の問題（資金を危険にさらすこともある）に関係する
さまざまなmempoolの制限に対処するのに役立ちます。

さらに、Abubakar Sadiq Ismailの1月の投稿に見られるように、
クラスターmempoolの設計から得られる洞察とツールは、
[Bitcoin Coreにおける手数料の推定を改善する][news283 fees]可能性があります。
現在、Bitcoin Coreは、[CPFPによる手数料の引き上げ][topic cpfp]をサポートするインセンティブ互換の方法として、
祖先の手数料率によるマイニングを実装していますが、手数料の推定は、
個々のトランザクションに対して実行されるため、CPFPによる手数料の引き上げは考慮されません。
クラスターmempoolは、トランザクションのグループをチャンクに分割します。
チャンクはmempool内で一緒に追跡され、マイニングされたブロック内に配置される可能性があるため、
手数料の推定を改善できます（特に、[パッケージリレー][topic package relay]や、
[P2A][topic ephemeral anchors]、[外部からの手数料供給][topic fee sourcing]などの
CPFP関連の技術の使用が増加する場合）。

クラスターmempoolプロジェクトが成熟するのに合わせて、そのアーキテクトによって
複数の説明と概要が作成されました。Suhas Daftuarが1月に[概要][news285 cluster]を示し、
課題の1つである、既存の[CPFP carve-out][topic cpfp carve out]ポリシーと互換性がないことを明らかにしました。
このジレンマを解決するには、carve-outの既存のユーザーが
[TRUCトランザクション][topic v3 transaction relay]にオプトインし、
機能セットを改良することが考えられます。クラスターmempoolの別の[詳細な説明][news312 cluster]が、
7月にPieter Wuilleから投稿されました。この説明では、基本原則や提案されたアルゴリズムについて説明され、
いくつかのプルリクエストがリンクされていました。
[これらのプルリクエスト][news315 cluster]の[いくつか][news314 cluster]と
[他の][news331 cluster]プルリクエストは、その後マージされました。

Daftuarは、クラスターmempoolとTRUCトランザクションなどの関連提案について、
さらに検討と調査を行いました。2月に、彼はreplace-by-feerateなどのアイディアのインセンティブ互換性や、
ハッシュレートが不均衡なマイナーのインセンティブの違いについて[考慮し][news290 incentive]、
DoS耐性のないインセンティブ互換性の動作を探しました。
4月には、もしクラスターmempoolが1年早く導入されていたらどうなっていたかを[調査し][news298 cluster]、
mempoolに若干多くのトランザクションを入れることができ、データ上のトランザクションの置換に大きな影響を与えず、
短期的にはマイナーがより多くの手数料を獲得するのに役立つ可能性があることを発見しました。
Pieter Wuilleは8月に、ブロックを構築するマイナーのために
[ほぼ最適なトランザクションの選択][news314 mine]をするための原則と効率的なアルゴリズムを説明することで、
最後のポイントを構築しました。
</div>

## 5月

{:#silentpayments}
- **<!--silent-payments-->サイレントペイメント:** [サイレントペイメント][topic silent payments]をより[広く利用できるようにするための][news304 sp]取り組みが今年も続きました。
Josie Bakerは、Andrew Tothのドラフト仕様に基づいて、サイレントペイメント（SP）用のPSBT拡張に関する議論を開始しました。
この議論は6月に入っても続き、[ECDH共有を使用してトラストレスな調整][news308 sp]を行うことを検討しました。
それとは別に、Setor Blagogeeは、[軽量クライアントがサイレントペイメントを受け取るのを支援する][news305 splite]プロトコルのドラフト仕様を投稿しました。
6月には基本のSP仕様にいくつかの[調整][news309 sptweak]が加えられ、
提案されたPSBT機能の[2つ][news326 sppsbt]のドラフト[BIP][news327 sppsbt]が作成されました。

{:#bitvmx}
- **<!--bitvmx-->BitVMX:** Sergio Demian Lernerと数人の共著者は、[BitVM][topic acc]の背後にあるアイディアに一部基づいた
新しい仮想CPUアーキテクチャに関する論文を[発表しました][news303 bitvmx]。
彼らのプロジェクトであるBitVMXの目標は、RISC-Vなどの確立されたCPUアーキテクチャ上で実行するためにコンパイルできる
すべてのプログラムの適切な実行を効率的に証明できるようにすることです。
BitVMと同様に、BitVMXでもコンセンサスの変更は必要ありませんが、信頼できる検証者として行動する1人以上の指定された当事者が必要です。
つまり、複数のユーザーが対話的にコントラクトプロトコルに参加することで、
コントラクトで指定された任意のプログラムを当事者が実行しない限り、
当事者の1人（または複数）がコントラクトから資金を引き出すことを阻止できます。

{:#aut}
- **<!--anonymous-usage-tokens-->匿名使用トークン:** Adam Gibsonが、UTXOをkey-pathで使用できる人なら誰でも、
どのUTXOか明らかにすることなく、それを使用できることを証明できるようにするために開発した
[匿名使用トークン][news303 aut]スキームについて説明しました。
彼が強調する用途の1つは、LNチャネルをアナウンスする際に、
そのチャネルのベースとなるUTXOの所有者を特定する必要がないようにすることです。
UTXOの特定は、帯域幅を浪費するサービス拒否攻撃を防止するために現在必須となっています。
Gibsonはまた、サインアップに匿名のプルーフを提供する必要がある概念実証のフォーラムを作成しました。
これにより、誰もがビットコインの所有者であることは分かるものの、
誰も自分自身や自分のビットコインに関する識別情報を提供する必要がない環境を作り出しました。
その後、Johan Halsethは、異なるメカニズムを用いてほぼ同じ目標を達成する概念実証の実装を[発表しました][news321 utxozk]。

{:#lnup}
- **<!--ln-channel-upgrades-->LNチャネルのアップグレード:** 何年もの間、LNの開発者たちは、既存のチャネルをさまざまな方法で[アップグレード][topic channel commitment
upgrades]できるように、LNプロトコルを変更することについて議論してきました。
5月に、Carla Kirk-Cohenは、これらのケースのいくつかを[検証し][news304 lnup]、
アップグレードの3つの異なる提案を比較しました。6月には、
アップグレードやその他の機密性の高い操作をサポートするために、
LN仕様に静止プロトコルが[追加][news309 stfu]されました。
10月には、新しい[Taprootベースのファンディングトランザクション][topic simple taproot channels]をサポートする
チャネルアナウンスプロトコルの更新案の[開発が再開されました][news326 ann1.75]。

{:#minecash}
- **プールマイナー向けEcash:** Ethan Tuttleが、マイニングプールがマイニングしたシェアの数に比例して
[マイナーにecashトークンを報酬として与える][news304 minecash]ことができる提案をDelving Bitcoinに投稿しました。
マイナーは、そのトークンをすぐに売却まはた譲渡するか、プールがブロックをマイニングをするまで待ち、
見つかった時点でsatoshiとトークンを交換することができます。ただし、
Matt Coralloは、大規模なプールで実装されている標準化された支払い方法がないため、
プールマイナーが短期間で支払われるべき金額を計算できないという懸念を提起しました。
つまり、メインプールが支払いを騙し始めた場合、その支払いがecashであれ、
他のメカニズムであれ、マイナーはすぐに別のプールに切り替えることはありません。

{:#miniscript}
- **<!--miniscript-specification-->Miniscriptの仕様:** Ava Chowが5月に、[Miniscript][topic miniscript]のBIPを[提案し][news304 msbip]、
[7月][news310 msbip]に[BIP379][]になりました。

{:#utreexod}
- **Utreexoベータ:** また5月には、utreexodのベータリリースが[公開され][news302 utreexod]、
ユーザーはディスクスペース要件を最小限に抑えるこのフルノード設計を試すことができるようになりました。

## 6月

{:#lnfeasibility}
- **<!--ln-payment-feasibility-and-channel-depletion-->LN支払いの実行可能性とチャネルの枯渇:** René Pickhardtが、チャネルキャパシティ内での可能な富の分配を分析することで、
[LN支払いの実行可能性を][news309 feas]推定する研究を行いました。
たとえば、アリスがボブを経由してキャロルに1 BTCを送金したい場合、成功の可能性は、
アリス-ボブおよびボブ-キャロルのチャネルが送金をサポートできるかどうかによって決まります。
この指標は、実際の支払いの制約を強調し、ウォレットやビジネスソフトウェアがよりスマートなルーティングを決めるのに役立ち、
LN支払いの成功率を向上させます。今年の後半、Pickhardtの研究は、
チャネル枯渇（チャネルが特定の方向に資金を転送できなくなること）の原因と可能性に関する[洞察][news333 deplete]を提供しました。
また、[チャネルファクトリー][topic channel factories]などのk>2のマルチパーティチャネル管理プロトコルにより、
実行可能な支払いの数が大幅に増加し、チャネル枯渇率を低下できることも示しました。

![チャネル枯渇の例](/img/posts/2024-12-depletion.png)

{:#quantumsign}
- **<!--quantum-resistant-transaction-signing-->量子耐性のあるトランザクション署名:** 開発者のHunter Beastは、バージョン3のsegwitアドレスを[量子耐性のある署名アルゴリズム][topic quantum resistance]に割り当てるための
「ラフなドラフト」BIPを[投稿しました][news307 quant]。ドラフトBIPでは、この問題について説明し、
いくつかのアルゴリズム候補とその予想されるオンチェーンサイズをリンクしています。
アルゴリズムの選択と具体的な実装の詳細は今後の議論に委ねられました。

<div markdown="1" class="callout" id="p2prelay">
## 2024年のまとめ: P2Pトランザクションリレー

手数料管理は、分散型のBitcoinプロトコルでは常に課題となっていましたが、
LN-Penaltyなどのコントラクトプロトコルの普及と、より新しく複雑なプロトコルの継続的な研究により、
ユーザーが要求に応じて手数料を支払い、増額できることを保証することがこれまで以上に重要になっています。
Bitcoin Coreのコントリビューターは、この問題に何年も取り組んでおり、
2024年には状況を大幅に改善するいくつかの新機能が公開されました。

1月は、以前導入された[CPFP carve-out][topic cpfp carve out]ポリシーのより堅牢な代替手段を提供する
[TRUC][topic v3 transaction relay]提案の最悪のケースの[Pinning][topic transaction pinning]コストに関する
[議論][news283 trucpin]から始まりました。TRUCの最悪のケースのコストはるかに低いものの、
開発者はいくつかのパラメーターを微調整することでコストをさらに下げることができるかどうかを検討しました。
1月の別の[議論][news284 exo]では、[外部的な手数料の調達][topic fee sourcing]が増えると、
マイナーへの[帯域外の手数料支払い][topic out-of-band fees]を使用する方がオンチェーンより効率的（したがって安価）になり、
マイニングの分散化が危険にさらされるという理論上のリスクが検討されました。
Peter Toddは、この懸念に対処するために、別の手数料管理方法を提案しました。
これは、各決済トランザクションの複数のバリエーションをさまざまな手数料率で事前に署名することで、
手数料を完全に内部的に保持するというものです。しかし、このアプローチには複数の問題が特定されました。

1月にGregory Sandersが行った追加の議論では、
LNプロトコルが[トリムされたHTLC][topic trimmed htlc]の資金を
[P2A][topic ephemeral anchors]アウトプットに入れるのにリスクがあるかどうかが[検討されました][news285 mev]。
これにより、mempoolのトランザクションのマイニングに必要な範囲を超えて特別なソフトウェアを実行するマイナーが、
MEV（_miner extractable value_）を実行できるようになる可能性があります。
Bastien Teinturierは、TRUCおよびP2Aアウトプットを使用するコミットメントトランザクションを処理するために
LNプロトコルにどのような変更が必要かという[議論][news286 lntruc]を開始しました。
これには、Sandersが検討したトリムされたHTLCの提案、不要になる1ブロックの遅延の排除、
オンチェーントランザクションサイズの削減が含まれます。この議論により、
LNの既存のCPFP carve-outの使用に似たトランザクションにTRUCルールを自動的に適用し、
LNソフトウェアをアップグレードすることなくTRUCの利点を提供する[組み込みTRUC][news286 imtruc]の提案も行われました。

1月は、Gloria Zhaoによる、[手数料による兄弟の入れ替え][topic kindred rbf]の[提案][news287 sibrbf]で終わりました。
通常の[RBF][topic rbf]ルールは、競合するトランザクションにのみ適用され、
有効なブロックチェーンには1つのバージョンしか存在できないため、
ノードはmempoolに1つのバージョンのトランザクションのみを受け入れます。
ただし、TRUCでは、ノードは未承認のバージョン3の親トランザクションの子孫を1つだけ受け入れます。
これは、競合トランザクションと非常によく似た状況です。
ある子孫が同じトランザクションの別の子孫を置き換えることを許可するということ、つまり
_兄弟の排除_ は、TRUCトランザクションの手数料の引き上げを改善し、組み込みTRUCが採用された場合に特に有益です。

2月は、LNプロトコルをCPFP carve-outからTRUCに移行することの影響に関する追加の議論から始まりました。
Matt Coralloは、ファンディングトランザクションと即時クローズトランザクションの両方が未承認になる可能性があり、
TRUCの未承認トランザクションが2つという制限により、CPFPによる手数料の引き上げを含む3つめのトランザクションを使用できないため、
既存の[ゼロ承認チャネルの開設][topic zero-conf channels]をTRUCの使用に適応させるのに
[課題][news288 truc0c]があることを発見しました。Teinturierは、
[スプライシング][topic splicing]のチェーンが使用される場合の同様の問題を特定しました。
議論は明確な結論には至りませんでしたが、
各トランザクションにCPFPによる手数料の引き上げ用の（TRUCの前に必要な）独自のアンカーが含まれるようにするという回避策は、
満足のいくものであるように思われ、誰もが[クラスターmempool][topic cluster mempool]によって
将来TRUCルールの一部が緩和され、より柔軟なCPFPによる手数料の引き上げが可能になることを望んでいました。

クラスターmempoolの進歩によるTRUCポリシーの変更について、Gregory Sandersは
[将来のポリシー変更][news289 pcmtruc]に関するいくつかのアイディアを説明しました。
対照的に、Suhas Daftuarは、前年にノードが受信したすべてのトランザクションを[分析し][news289 oldtruc]、
TRUCポリシーが組み込まれた場合、それらのトランザクションの受け入れにどのような影響があったかを確認しました。
CPFP carve-outポリシーで以前受け入れられたトランザクションのほとんどは、
TRUCポリシーが組み込まれた場合でも受け入れられましたが、
組み込みポリシーを採用する前にソフトウェアの変更が必要になる可能性のある例外がいくつかありました。

今年始めの活発な議論の後、5月と6月にはBitcoin Coreに新しいリレー機能のサポートを追加する一連のマージが行われました。
P2Pプロトコルの変更を必要としない[限定的な][news301 1p1c]1P1C（one-parent-one-child）
[パッケージリレー][topic package relay]が追加されました。[その後のマージ][news304 bcc30000]で、
Bitcoin Coreのオーファントランザクションの処理を強化することで1P1Cパッケージリレーの信頼性が向上しました。
TRUCの仕様が[BIP431][]として[BIPのリポジトリにマージされました][news306 bip431]。
TRUCトランザクションは、[別のマージ][news307 bcc29496]によりデフォルトでリレー可能になりました。
（TRUCパッケージを含む）1P1Cクラスターの[RBF][topic rbf]のサポートも[追加されました][news309 1p1crbf]。

2人の長年の開発者が7月にTRUCに対する[詳細な批判][news313 crittruc]を書きましたが、
他の開発者は彼らの懸念に応えました。同じ2人の開発者による[さらなる批判][news315 crittruc]が8月に発表されました。

Bitcoin Core開発者は、リレーの改善に取り組み、8月にP2A（[Pay-to-Anchor][topic ephemeral anchors]）の
[サポート][news315 p2a]をマージし、10月に1P1Cパッケージリレー、TRUCトランザクションリレー、
パッケージRBFと兄弟の入れ替えおよび標準P2Aアウトプットスクリプトタイプをサポートした
Bitcoin Core 28.0をリリースしました。これらすべての機能の開発に貢献したGregory Sandersは、
Bitcoin Coreを使用してトランザクションを作成またはブロードキャストするウォレットやその他のソフトウェアの開発者が
どのように新しい機能を活用できるかを[解説しました][news324 guide]。

今年後半には、P2Aを使用する[エフェメラルダスト][topic ephemeral anchors]のサポートが
[マージされ][news330 dust]標準となりました。これにより、手数料ゼロのトランザクションを、
関連するすべての手数料を支払う子トランザクションによって引き上げることができるようになり、
純粋な外部からの[手数料の調達][topic fee sourcing]が可能になります。

Optechの今年最後のニュースレターでは、1P1Cパッケージリレーのさらなる改善について議論した
Bitcoin Core PR Review Club[ミーティング][news333 prclub]の概要が紹介されました。
</div>

## 7月

{:#bolt11blind}
- **BOLT11インボイス用のブラインドパス:** Elle Moutonが、[BOLT11インボイスにブラインドパスフィールドを追加する][news310 path]BLIPを提案しました。
これにより支払いの受取人は、ノードのIDとチャネルピアを隠すことができます。たとえば、
ボブは彼のインボイスにブラインドパスを追加し、アリスのソフトウェアがそれをサポートしている場合は
プライベートに支払いを行うことができます。サポートしていない場合はエラーになります。
Moutonは、ブラインドパスをネイティブにサポートする[オファー][topic offers]が広く採用されるまでの一時的な解決策として
これを考えています。この提案は、[8月][news317 blip39]に[BLIP39][]となりました。

{:#chilldkg}
- **<!--chilldkg-key-generation-for-threshold-signatures-->閾値署名用のChillDKG鍵生成:** Tim RuffingとJonas Nickが、Bitcoinの[Schnorr署名][topic schnorr signatures]と互換性のある
[FROSTスタイルのスクリプトレスな閾値署名の鍵を安全に生成する][news312 chilldkg]ための
BIPドラフトと参照実装であるChillDKGを提案しました。ChillDKGは、
FROSTのよく知られた鍵生成アルゴリズムと最新の暗号プリミティブを組み合わせて、
整合性と検閲耐性を確保しながら参加者間でランダムな鍵コンポーネントを安全に共有します。
暗号化には楕円曲線ディフィー・ヘルマン（ECDH）を使用し、署名されたセッショントランスクリプトの検証には、
認証されたブロードキャストを使用します。参加者は最終的な公開鍵を受け入れる前にセッションの完全性を確認します。
このプロトコルは鍵管理を簡素化し、ユーザーは自分の秘密のシードといくつかの非機密のリカバリーデータのみをバックアップする必要があります。
シードを使用してリカバリーデータを暗号化する計画は、プライバシーを強化し、
ユーザーのバックアップをさらに簡素化することを目的としています。

{:#musigthresh}
- **MuSig用のBIPと閾値署名:** 7月には、異なるソフトウェアが相互作用して[MuSig2][topic musig]署名を作成するのを助ける
いくつかのBIPが[マージされました][news310 musig]。月の後半には、
Sivaram Dhakshinamoorthyが、Bitcoinの[Schnorr署名][topic schnorr signatures]の実装用に
スクリプトレスな[閾値署名][topic threshold signature]を作成するためのBIPの提案を[発表しました][news315 threshsig]。
これにより、（ChillDKGを使用するなどして）既にセットアップ手順を実行した署名者のセットが、
その署名者の動的なサブセットとの対話のみで署名を安全に作成できるようになります。
この署名は、シングルシグのユーザーによって作成されたSchnorr署名とオンチェーンで区別がつかず、
プライバシーとファンジビリティが向上します。

## 8月

{:#hyperion}
- **<!--hyperion-network-simulator-->Hyperionネットワークシミュレーター:** Sergi Delgadoが、シミュレートされたBitcoinネットワークを通じてデータがどのように伝播されるかを追跡する
ネットワークシミュレーターHyperionを[リリースしました][news314 hyperion]。
この研究は、当初、Bitcoinの現在のトランザクションアナウンス方式と、
提案中の[Erlay][topic erlay]方式を比較したいという思いから始まりました。

{:#fullrbf}
- **フルRBF:** 開発者の0xB10Cが、最近の[コンパクトブロック][topic compact block relay]の再構築の信頼性を[調査しました][news315 cb]。
新しいブロックには、ノードが確認したことのないトランザクションが含まれていることがあります。
その場合、コンパクトブロックを受信するノードは通常、送信ピアにそれらのトランザクションを要求し、
ピアからの応答を待つ必要があります。これによりブロックの伝播が遅くなります。
この研究は、Bitcoin Coreでデフォルトで[mempoolfullrbf][topic rbf]を有効にするためのプルリクエストのきっかけとなり、
後に[マージされました][news315 rbfdefault]。

<div markdown="1" class="callout" id="covs">
## 2024年のまとめ: コベナンツとスクリプトのアップグレード

2024年には、何人かの開発者が、[コベナンツ][topic covenants]やスクリプトのアップグレード、
[Joinpool][topic joinpools]や[チャネルファクトリー][topic channel factories]といった
高度なコントラクトプロトコルをサポートするためのその他の変更に関する提案の推進に多くの時間を割きました。

2023年12月下旬、Johan Torås Halsethは、[MATT][topic acc]ソフトフォーク提案の
`OP_CHECKCONTRACTVERIFY` opcodeを使用して、任意のプログラムが正常に実行された場合に、
コントラクトプロトコルの当事者が資金を請求できる概念実証プログラムを[発表しました][news283 elftrace]。
これは、[BitVM][topic acc]とコンセプトが似ていますが、プログラム実行の検証用に特別に設計されたopcodeを使用するため、
Bitcoinの実装はよりシンプルです。Elftraceは、LinuxのELFフォーマットを使用して
RISC-Vアーキテクチャ用にコンパイルされたプログラムで動作します。
ほとんどのプログラマーがその対象のプログラムを簡単に作成できるため、
Elftraceを使用するのは非常に身近なものとなっています。Halsethは8月に、
[OP_CAT][topic op_cat] opcodeと組み合わせてゼロ知識証明を検証する[機能][news315 elftracezk]をもったElftraceに関する
更新情報を提供しました。

1月には、[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV)と
[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS)の以前の提案と、
Taprootの内部鍵をスタックに配置する`OP_INTERNALKEY`の新しい提案を含む
LNHANCEの組み合わせソフトフォークの提案が[発表されました][news285 lnhance]。
今年の後半には、提案は[更新され][news330 paircommit]、`OP_CAT`に似た機能を提供するものの、
意図的にコンポーザビリティが制限された`OP_PAIRCOMMIT`も含まれるようになります。
この提案は、CTVスタイルの輻輳制御やCSFSスタイルの署名の委任など、
基盤となる提案で説明されている利点に加えて、[LN-Symmetry][topic eltoo]や
[Ark][topic ark]スタイルのJoinpool、署名の削減された[DLC][topic dlc]、
[Vault][topic vaults]の開発を可能にすることを目的としています。

Chris Stewartが、将来のソフトフォークでBitcoin Scriptで64-bitの算術演算を可能にするための
BIPのドラフトを[投稿しました][news285 64bit]。Bitcoinは現在、32-bitの演算のみを許可しています（
符号付き整数を使用しているため、約20億を超える数値は使用できません）。64-bitのサポートは、
アウトプット内で支払われるsatoshiの金額を操作する必要がある構成で特に役立ちます。
これは64-bit整数を使用して定義されているためです。
この提案は、[2月][news290 64bit]と[6月][news306 64bit]に追加の議論が行われました。

2月にはまた、開発者のRijndaelが、現在のコンセンサスルールと提案中の[OP_CAT][topic
op_cat] opcodeにのみ依存する[Vault][topic vaults]の[PoC実装][news291 catvault]を作成しました。
Optechは`OP_CAT` Vaultを、現在可能な事前署名トランザクションによるVaultと、
Bitcoinに[BIP345][] `OP_VAULT`が追加された場合に可能なVaultと比較しました。

<table>
  <tr>
    <th></th>
    <th>事前署名版</th>
    <th markdown="span">

    BIP345 `OP_VAULT`

    </th>
    <th markdown="span">

    `OP_CAT`とSchnorr

    </th>
  </tr>

  <tr>
    <th>有効性</th>
    <td markdown="span">

    **現在利用可能**

    </td>
    <td markdown="span">

    `OP_VAULT`と[OP_CTV][topic op_checktemplateverify]のソフトフォークが必要

    </td>
    <td markdown="span">

    `OP_CAT`のソフトフォークが必要

    </td>
  </tr>

  <tr>
    <th markdown="span">直前のアドレス置換</th>
    <td markdown="span">脆弱</td>
    <td markdown="span">

    **脆弱ではない**

    </td>
    <td markdown="span">

    **脆弱ではない**

    </td>
  </tr>

  <tr>
    <th markdown="span">一部の引き出し</th>
    <td markdown="span">事前に取り決めがある場合のみ可能</td>
    <td markdown="span">

    **可能**

    </td>
    <td markdown="span">不可能</td>
  </tr>

  <tr>
    <th markdown="span">静的で非対話型の計算可能なデポジットアドレス</th>
    <td markdown="span">不可能</td>
    <td markdown="span">

    **可能**

    </td>
    <td markdown="span">

    **可能**

    </td>
  </tr>

  <tr>
    <th markdown="span">手数料節約のためのRe-Vault/隔離のバッチ化</th>
    <td markdown="span">不可能</td>
    <td markdown="span">

    **可能**

    </td>
    <td markdown="span">不可能</td>
  </tr>

  <tr>
    <th markdown="span">最良（つまり正当な使用）の場合の効率（Optechによる非常に大まかな推定）</th>
    <td markdown="span">

    **通常のシングルシグの2倍のサイズ**

    </td>
    <td markdown="span">通常のシングルシグの3倍のサイズ</td>
    <td markdown="span">通常のシングルシグの4倍のサイズ</td>
  </tr>
  </table>

3月、開発者のZmnSCPxjは、特定のソフトフォークがアクティベートされたかどうかを
正しく予測した参加者にUTXOの制御を与えるプロトコルについて[説明しました][news293 forkbet]。
この基本的なアイディアは以前にも提案されていますが、ZmnSCPxjのバージョンは、
少なくとも1つ将来のソフトフォークで期待される仕様、[OP_CHECKTEMPLATEVERIFY][topic
op_checktemplateverify]を扱っています。

3月はまた、Anthony TownsがLisp言語をベースとしたBitcoin用のスクリプト言語の開発に着手しました。
彼は、既にアルトコインChiaで使用されているLispスタイルの言語の[概要][news293 chialisp]を提供し、
BTC Lisp言語を[提案しました][news294 btclisp]。今年の後半、
Bitcoin Scriptと[Miniscript][topic miniscript]の関係に触発された彼は、
Lispプロジェクトを、ソフトフォークでBitcoinに追加可能な低レベルのBitcoin Lisp言語（bll）と、
bllに変換される高水準言語シンボリックbll（symbll）の2つに[分割しました][news331 bll]。
彼はまた、UTXOを特定の金額と使用条件に分割できる、
symbllと（そしておそらく[Simplicity][topic simplicity]とも）互換性のある
汎用的な構成についても[説明しました][news331 earmarks]。
彼は、これらの柔軟なコインの用途指定がどのように使用できるかを示しました。これには、
LNチャネル（[LN-Symmetry][topic eltoo]ベースのチャネルも含む）のセキュリティと
ユーザービリティの改善、[BIP345][]バージョンのVaultの代替、
[ペイメントプール][topic joinpools]の設計が含まれます。

Jeremy Rubinが5月に、`OP_CHECKTEMPLATEVERIFY`の設計の[2つの更新][news302 ctvext]を提案しました。
オプションでより短いハッシュダイジェストのサポートと、追加のコミットメントのサポートです。
これは、[LN-Symmetry][topic eltoo]や同様のプロトコルで重要なデータを復元するのに役立つ可能性のある
データ公開スキームでの使用にCTVを最適化するのに役立ちます。

Pierre Rochardが、同様のコストで同じ機能を多く提供できる提案中のソフトフォークは
相互に排他的であると考えるべきか、あるいは複数の提案をアクティベートして
開発者が好みの代替方法を使用できるようにするのが理にかなっているかを[尋ねました][news305 overlap]。

Jeremy Rubinが、関数型暗号を使用して、コンセンサスの変更を必要とせずに
Bitcoinに完全なコベナンツの動作を追加する理論に関する論文を[公開しました][news306 fecov]。
関数型暗号は、特定のプログラムに対する公開鍵の作成を可能にします。
そのプログラムを満たすことができる参加者は、（対応する秘密鍵を知ることなく）
公開鍵に対応する署名を作成することができます。これは常によりプライベートで、
これまで提案されたコベナンツと比較して、スペースを節約することができます。
残念ながら、Rubinによると、関数型暗号の主な欠点は、
それが「現在のところ実用的ではないほど未発達な暗号」であるということです。

Anthony Townsが、[OP_CAT][topic op_cat]を使用して、
誰でもスクリプトに送られたコインをPoW（Proof of Work）で使用することができる
[signet][topic signet]用の[スクリプト][news306 catfaucet]を投稿しました。
これは分散型のsignet-bitcoin Faucetとして使うことができます。
マイナーやユーザーが余ったsignet bitcoinを手に入れると、それをスクリプトに送信します。
signet bitcoinがほしいユーザーは、そのスクリプトへの支払いをUTXOセットから検索し、
そのコインを入手するためのPoWを行い、トランザクションを作成します。

Victor Kolobovが、`OP_CAT` opcodeを追加するソフトフォーク案の研究に
100万ドルの資金を提供すると[発表しました][news319 catmillion]。
提出期限は2025年の1月1日です。

11月、Townsは、Bitcoin Inquisitionを通じて利用可能なソフトフォーク案に関連する
デフォルトsignet上の活動を[まとめました][news330 sigactivity]。
Vojtěch StrnadはTownsの投稿に触発され、「デプロイされたソフトフォークを使用するBitcoin
signet上で作成された すべてのトランザクション」をリストアップするウェブサイトを作成しました。

Ethan Heilmanが、Victor Kolobov、Avihu LevyおよびAndrew Poelstraと共同執筆した論文を[投稿しました][news330 covgrind]。
この論文では、コンセンサスの変更なしにコベナンツを簡単に作成できる方法について説明していますが、
それらのコベナンツから支払いをする場合、非標準のトランザクションと数百万ドル（または数十億ドル）相当の特殊なハードウェアと
電力が必要になります。Heilmanは、この研究の応用の１つとして、量子耐性が突然必要になり、
Bitcoinの楕円曲線の署名演算が無効になった場合に、
ユーザーが安全に使用できるバックアップのTaproot支払い条件を簡単に組み込めることを示しています。
この研究は、Bitcoin用のランポート署名に関する著者の[以前の研究][news301 lamport]に触発された部分もあるようです。

12月は、選択されたコベナンツの提案に関する[開発者の意見投票][news333 covpoll]で締めくくられました。

_2025年1月から、Optechは毎月最初に発行されるニュースレターの特別セクションで、
コベナンツ、スクリプトのアップグレードおよび関連する変更について、注目すべき研究と開発の掲載を始めます。
私たちは、これらの提案に取り組んでいる皆さんに、
私たちの通常の[情報源][optech sources]にとって興味深いことがあれば、
それについて書けるよう発表することをお勧めします。_

</div>

## 9月

{:#hybridjamming}
- **<!--hybrid-jamming-mitigation-tests-and-tweaks-->ハイブリッドチャネルジャミングの緩和策のテストと調整:** Carla Kirk-Cohenが、もともとClara ShikhelmanとSergei Tikhomirovによって提案された
[ハイブリッドチャネルジャミングの緩和策][news322 jam]のテストと調整について説明しました。
チャネルを1時間妨害する試みは、攻撃者が既知の攻撃を使用するよりも多くの時間を費やしたか、
または意図せずに対象の収入を増やしたため、ほとんど失敗しました。ただし、
シンク攻撃は、より短い経路の支払いを妨害することで、ノードのレピュテーションを効果的に損ないました。
これに対抗するために、双方向のレピュテーションが[HTLCエンドースメント][topic htlc endorsement]に追加され、
この提案は、2018年にJim Posenが最初に提案したアイディアに近づきました。
ノードは、支払いを転送するかどうかを決める際に、送信者と受信者の両方の信頼性を評価するようになりました。
信頼性の高いノードは、エンドースされたHTLCを受け取りますが、
信頼性の低い送信者または受信者は拒否されるか、エンドースされていない転送に直面します。
このテストは、[HTLCエンドースメントの仕様][news316 htlce]と[Eclairでの実装][news315
htlce]に従って行われました。年末直前に[LNDの実装][news332 htlce]も追加されました。

{:#shieldedcsv}
- **シールドCSV:** Jonas NickとLiam Eagen、Robin Linusが、
新しい[Client-Side Validation][topic client-side validation]（CSV）プロトコルである
[シールドCSV][news322 csv]を発表しました。このプロトコルは、
トークンの詳細や転送履歴を公開することなく、BitcoinのProof of Workによって保護されたトークンの転送を可能にします。
クライアントが広範なトークンの履歴を検証する必要がある既存のプロトコルとは異なり、
シールドCSVはゼロ知識証明を使用して、プライバシーを維持しながら、
検証が固定リソースで済むことを保証します。さらにシールドCSVでは、
何千ものトークンの転送をBitcoinのトランザクションあたり64-byteの更新にバンドルすることで、
オンチェーンデータ要件を削減し、スケーラビリティを強化します。
論文では、[BitVM][topic acc]を介したトラストレスなBitcoin-to-CSVブリッジ、
アカウントベースの構造、ブロックチェーンの再編成の処理、未承認トランザクションおよび
潜在的な拡張性についても検討しています。このプロトコルは、他のトークンシステムよりも
大幅な効率性とプライバシーの向上を約束します。

{:#lnoff}
- **<!--ln-offline-payments-->LNオフライン支払い:** Andy Schroderが、オンライン時に認証トークンを生成することで、
[LNのオフライン支払いを可能にする][news321 lnoff]プロセスを概説しました。
これにより、支払人のウォレットは、オフライン時に常時オンラインのノードまたはLSPを介して支払いを承認できます。
トークンはNFCまたはその他のシンプルなプロトコルを介して受信者に転送できるため、
インターネットにアクセスせずに支払いを行うことができます。開発者のZmnSCPxjは代替案を提案し、
Bastien Teinturierは同様のユースケースにおける彼のリモートノードの制御方法を提供し、
スマートカードのようなより限られたリソースのデバイス用のオフライン支払いソリューションを強化しました。

## 10月

{:#offers}
- **BOLT12オファー:** [オファー][topic offers]の仕様[BOLT12][]が[マージされました][news323 offers]。
[当初2019年に提案された][news72 offers]オファーは、
2つのノードが[Onionメッセージ][topic onion messages]を使用してLN上で
インボイスと支払いのネゴシエーションを行えるようにします。
Onionメッセージとオファー互換の支払いはどちらも、送信者が受信者のノードの身元を知るのを防ぐために
[ブラインドパス][topic rv routing]を使用できます。

{:#pooledmining}
- **<!--mining-interfaces-block-withholding-and-share-validation-cost-->マイニングインターフェース、ブロック保留およびシェアの検証コスト:** 各マイナーが独自のトランザクションを選択できるように設定できる
[Stratum v2][topic pooled mining]プロトコルを使用するマイナーをサポートすることを目標に、
Bitcoin Coreに[新しいマイニングインターフェース][news325 mining]が開発されました。
ただし、Anthony Townsは今年初めに、独立したトランザクションの選択によって
マイニングプールの[シェアの検証コストが上昇する][news315 shares]可能性があると指摘しました。
これらのプールが検証を制限することで対応した場合、よく知られている
[ブロック保留攻撃][topic block withholding]に似た、無効なシェア攻撃が発生する可能性があります。
保留攻撃に対する2011年に提案された解決策が議論されましたが、困難なコンセンサスの変更が必要になります。

<div markdown="1" class="callout" id="releases">
## 2024年のまとめ: 人気のインフラストラクチャプロジェクトのメジャーリリース

- [LDK 0.0.119][]では、マルチホップ[ブラインドパス][topic rv routing]への支払いをサポートしました。

- [HWI 2.4.0][]では、Trezor Safe 3をサポートしました。

- [Core Lightning 24.02][]では、`recover`プラグインが改善され
  「緊急時のリカバリーがストレスなく行える」ようになった他、
  [アンカーチャネル][topic anchor outputs]が改善され、
  ブロックチェーンの同期が50%高速化され、testnetで発見された巨大なトランザクションのパース処理のバグが修正されました。

- [Eclair v0.10.0][]では、「[デュアルファンディング機能][topic dual funding]の公式サポート、
  BOLT12[オファー][topic offers]の最新実装、完全に機能する[スプライシング][topic splicing]プロトタイプが
  追加されました」。

- [Bitcoin Core 27.0][]では、libbitcoinconsensusが非推奨となり、
  デフォルトで[v2暗号化P2Pトランスポート][topic v2 p2p transport]が有効になり、
  テストネットワークでオプトインの承認までトポロジーが制限される（[TRUC][topic v3 transaction relay]）トランザクションポリシーが許可され、
  手数料率が高いときに使用する新しい[コイン選択][topic coin selection]戦略が追加されました。

- [BTCPay Server 1.13.1][]（および以前のリリース）では、
  ウェブフックの拡張性が向上し、[BIP129][]マルチシグウォレットインポートをサポートし、
  プラグインの柔軟性が向上し、すべてのアルトコインのサポートがプラグインに移行され、
  BBQrエンコードされた[PSBT][topic psbt]がサポートされました。

- [Bitcoin Inquisition 25.2][]では、signetで[OP_CAT][topic op_cat]をサポートしました。

- [Libsecp256k1 v0.5.0][]では、鍵生成と署名が高速化され、
  コンパイル後のサイズが削減され「開発者は特に組み込みユーザーにメリットがあると予想していました」。

- [LDK v0.0.123][]では、[トリムされたHTLC][topic trimmed htlc]用の設定の更新と、
  [オファー][topic offers]のサポートの改善が含まれています。

- [Bitcoin Inquisition 27.0][]では、[BIN24-1][]および[BIP347][]で定義されている
  [OP_CAT][]のsignetでの適用が追加されました。また、「スクリプトのopcodeの動作をテストするために使用できる
  `bitcoin-util`の新しいサブコマンド`evalscript`」も追加されました。
  `annexdatacarrier`と疑似[エフェメラルアンカー][topic ephemeral anchors]のサポートは廃止されました。

- [LND v0.18.0-beta][]では、_インバウンドルーティング手数料_、
  [ブラインドパス][topic rv routing]用の経路探索、
  [Simple Taproot Channel][topic simple taproot channels]用の[ウォッチタワー][topic watchtowers]の実験的サポートと
  暗号化されたデバッグ情報の効率的な送信が追加されました。

- [Core Lightning 24.05][]では、プルーニングされたフルノードとの互換性が向上し、
  `check` RPCがプラグインで動作できるようになり、[オファー][topic offers]のインボイスがより堅牢に配信できるようになり、
  `ignore_fee_limits`設定オプションが使用された際の手数料の過払いの問題が修正されました。

- [HWI 3.1.0][]では、Trezor Safe 5をサポートしました。

- [Bitcoin Core 28.0][]では、[testnet4][topic testnet]、
  1P1C（opportunistic one-parent-one-child）[パッケージリレー][topic package relay]、
  オプトインの[TRUC][topic v3 transaction relay]（topologically restricted until
  confirmation）トランザクションのデフォルトリレー、
  [pay-to-anchor][topic ephemeral anchors]トランザクションのデフォルトリレー、
  制限付きのパッケージ[RBF][topic rbf]リレーをサポートし、
  [フルRBF][topic rbf]がデフォルトとなりました。[assumeUTXO][topic
  assumeutxo]のデフォルトパラメーターが追加され、
  Bitcoinネットワークの外部（torrent経由など）からダウンロードされたUTXOセットを使用して
  `loadtxoutset` RPCを実行できるようになりました。

- [BTCPay Server 2.0.0][]では、「ローカライゼーションの改善、サイドバーナビゲゲーション、
  オンボーディングフローの改善、ブランディングオプションの改善、プラグイン可能なレートプロバイダーのサポート」が追加されました。
  このアップグレードには、いくつかの破壊的な変更とデータベースのマイグレーションが含まれています。

- [Libsecp256k1 0.6.0][]では、「[MuSig2][topic musig]モジュールと
  スタックからシークレットをクリアするための非常に堅牢なメソッドが追加され、
  未使用の`secp256k1_scratch_space`関数が削除されました。」

- [BDK 0.30.0][]では、ライブラリのバージョン1.0へのアップグレードの準備をしました。

- [Eclair v0.11.0][]では、「BOLT12[オファー][topic offers]を公式サポートし、
  流動性管理機能（[スプライシング][topic splicing]、[Liquidity Ads][topic liquidity
  advertisements]、[オンザフライ・ファンディング][topic jit channels]）を進展させました」。
  このリリースではまた、非[アンカーチャネル][topic anchor outputs]の新しい受付を停止しました。

- [Core Lightning 24.11][]では、高度なルート選択を使用した支払いを行うための新しい実験的なプラグインが含まれ、
  [オファー][topic offers]への支払いおよび受け取りがデフォルトで有効になり、
  [スプライシング][topic splicing]に複数の改良が加えられました。
</div>

## 11月

{:#superscalar}
- **<!--superscalar-timeout-tree-channel-factories-->SuperScalarタイムアウトツリー型チャネルファクトリー:** ZmnSCPxjが、[タイムアウトツリー][topic timeout trees]を使用する
[チャネルファクトリー][topic channel factories]の[SuperScalar設計][news327 superscalar]を提案しました。
これは、トラストレス性を維持しながら、LNユーザーがチャネルを開いて流動性にもっと安価にアクセスできるようにするものです。
この設計では、サービスプロバイダーがツリーをオンチェーンに配置するコストを支払うか、
ツリーに残っている資金を失うことになる階層化されたタイムアウトツリーを使用します。
これにより、サービスプロバイダーは、オンチェーンへの移行を回避するために、
ユーザーが協力してチャネルを閉じるよう奨励します。この設計では、
[Duplexマイクロペイメントチャネル][topic duplex micropayment channels]と
[LN-Penalty][topic ln-penalty]ペイメントチャネルの両方を使用しています。
どちらもコンセンサスの変更なく実行できます。
複数のチャネルタイプを組み合わせてオフチェーンのステートを管理するという複雑さにもかかわらず、
この設計は大規模なプロトコル変更を必要とせずに単一のベンダーによって実装できます。
この設計をサポートするために、ZmnSCPxjは後に、LN仕様に
[プラグイン可能なチャネルファクトリーの調整][news330 plug]を提案しました。

{:#opr}
- **<!--fast-and-cheap-low-value-offchain-payment-resolution-->高速かつ安価なオフチェーン支払いの解決:** John Lawが、参加者双方が資金を債権に拠出することを要求する
オフチェーン支払いの解決（OPR）マイクロペイメントプロトコルを[提案しました][news329 opr]。
この債権は、どちらの参加者によっても いつでも事実上破壊することができます。
これにより両者に、相手をなだめるか、 債権の相互確証破壊（MAD）のリスクを負うかのインセンティブが生まれます。
このプロトコルはトラストレスではありませんが、他の方法よりもスケーラブルで、
迅速な解決が可能であり、タイムロックの期限が切れる前にデータをオンチェーンで公開することを参加者に強いることもありません。
これにより、[チャネルファクトリー][topic channel factories]や[タイムアウトツリー][topic timeout
trees]、または理想的にはネストされた部分をオフチェーンに保持する他のネスト構造内で
OPRをより効率的にすることができます。

<div markdown="1" class="callout" id="optech">
## 2024年のまとめ: Bitcoin Optech

Optechの7年めは、51の週刊[ニュースレター][newsletters]を発行し、
[トピックインデックス][topics index]に35の新しいページを追加しました。
合わせて、Optechは今年Bitcoinソフトウェアの研究開発に関する120,000以上のワードを公開し、
これはおそよ350ページの本に相当します。

各ニュースレターやブログ記事は、中国語、チェコ語、フランス語、日本語に翻訳され、
2024年には合計200以上の翻訳が行われました。

さらに、今年のすべてのニュースレターには[ポッドキャスト][podcast]のエピソードが添えられ、
音声形式では合計59時間以上、トランスクリプト形式では、 488,000語以上になりました。
Bitcoinのトップコントリビューターの多くが番組のゲストとして出演し、
複数のエピソードに出演した人もいました。2024年は、合計75人のゲストが出演しました:

- Abubakar Sadiq Ismail (x2)
- Adam Gibson
- Alex Bosworth
- Andrew Toth (x3)
- Andy Schroder
- Anthony Towns (x5)
- Antoine Poinsot (x5)
- Antoine Riard (x2)
- Armin Sabouri
- Bastien Teinturier (x4)
- Bob McElrath
- Brandon Black (x3)
- Bruno Garcia
- callebtc
- Calvin Kim
- Chris Stewart (x3)
- Christian Decker
- Dave Harding (x3)
- David Gumberg
- /dev/fd0
- Dusty Daemon
- Elle Mouton (x2)
- Eric Voskuil
- Ethan Heilman (x2)
- Eugene Siegel
- Fabian Jahr (x5)
- Filippo Merli
- Gloria Zhao (x10)
- Gregory Sanders (x7)
- Hennadii Stepanov
- Hunter Beast
- Jameson Lopp (x2)
- Jason Hughes
- Jay Beddict
- Jeffrey Czyz
- Johan Torås Halseth
- Jonas Nick (x2)
- Joost Jager
- Josie Baker
- Kulpreet Singh
- Lorenzo Bonazzi
- Luke Dashjr
- Matt Corallo (x3)
- Moonsettler (x2)
- Nicholas Gregory
- Niklas Gögge (x2)
- Oghenovo Usiwoma
- Olaoluwa Osuntokun
- Oliver Gugger
- Peter Todd
- Pierre Corbin
- Pierre Rochard
- Pieter Wuille
- René Pickhardt (x2)
- Richard Myers
- Rijndael
- rkrux
- Russell O’Connor
- Salvatore Ingala (x2)
- Sebastian Falbesoner
- SeedHammer Team
- Sergi Delgado
- Setor Blagogee
- Shehzan Maredia
- Sivaram Dhakshinamoorthy
- Stéphan Vuylsteke
- Steven Roose
- Tadge Dryja
- TheCharlatan
- Tom Trevethan
- Tony Klausing
- Valentine Wallace
- Virtu
- Vojtěch Strnad (x2)
- ZmnSCPxj (x3)

Optechは、[Human Rights Foundation][]から私たちの活動に対して$20,000 USDの寄付を受ける幸運に恵まれ、
感謝しています。この資金は、ウェブホスティング、メールサービス、ポッドキャストの書き起こしおよび、
Bitcoinコミュニティへの技術コンテンツの配信を継続・改善するためのその他の費用に使用されます。

</div>

## 12月

12月には、いくつかの議論が継続し、複数の脆弱性が発表されましたが、これらはすべてこのニュースレター内にまとめています。

*Bitcoin開発の素晴らしい1年を支えてくださった、上記すべてのBitcoinコントリビューターおよび
同様に重要な仕事をしてくださった多くの方々に感謝します。Optechのニュースレターは、
1月3日より通常の金曜日の発行スケジュールに戻ります。*

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

{% include snippets/recap-ad.md when="2024-12-23 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}
[topics index]: /en/topics/
[yirs 2018]: /en/newsletters/2018/12/28/
[yirs 2019]: /ja/newsletters/2019/12/28/
[yirs 2020]: /en/newsletters/2020/12/23/
[yirs 2021]: /ja/newsletters/2021/12/22/
[yirs 2022]: /ja/newsletters/2022/12/21/
[yirs 2023]: /ja/newsletters/2023/12/20/
[news283 feelocks]: /ja/newsletters/2024/01/03/#fee-dependent-timelocks
[news283 exits]: /ja/newsletters/2024/01/03/#fraud-proof-pool
[news284 lnsym]: /ja/newsletters/2024/01/10/#ln-symmetry
[news288 rbfr]: /ja/newsletters/2024/02/07/#pinning
[news290 dns]: /ja/newsletters/2024/02/21/#dns-bitcoin
[news290 asmap]: /ja/newsletters/2024/02/21/#asmap
[news290 dualfund]: /ja/newsletters/2024/02/21/#bolts-851
[news291 bets]: /ja/newsletters/2024/02/28/#trustless-contract-for-miner-feerate-futures
[news295 fees]: /ja/newsletters/2024/03/27/#mempool
[news295 sponsor]: /ja/newsletters/2024/03/27/#transaction-fee-sponsorship-improvements
[news286 binana]: /ja/newsletters/2024/01/24/#new-documentation-repository
[news292 bips]: /ja/newsletters/2024/03/06/#bip
[news296 ccsf]: /ja/newsletters/2024/04/03/#revisiting-consensus-cleanup
[news299 bips]: /ja/newsletters/2024/04/24/#bip
[news297 bips]: /ja/newsletters/2024/04/10/#bip2
[news297 inbound]: /ja/newsletters/2024/04/10/#lnd-6703
[news299 weakblocks]: /ja/newsletters/2024/04/24/#weak-blocks-proof-of-concept-implementation
[news297 testnet]: /ja/newsletters/2024/04/10/#testnet
[news300 arrest]: /ja/newsletters/2024/05/01/#bitcoin
[news308 sp]: /ja/newsletters/2024/06/21/#psbt
[news304 sp]: /ja/newsletters/2024/05/24/#psbt
[news305 splite]: /ja/newsletters/2024/05/31/#light-client-protocol-for-silent-payments
[news309 feas]: /ja/newsletters/2024/06/28/#ln
[news310 path]: /ja/newsletters/2024/07/05/#bolt11
[news312 chilldkg]: /ja/newsletters/2024/07/19/#frost
[news315 htlce]: /ja/newsletters/2024/08/09/#eclair-2884
[news316 htlce]: /ja/newsletters/2024/08/16/#blips-27
[news322 jam]: /ja/newsletters/2024/09/27/#hybrid-jamming-mitigation-testing-and-changes
[news332 htlce]: /ja/newsletters/2024/12/06/#lnd-8390
[news322 csv]: /ja/newsletters/2024/09/27/#client-side-validation-csv
[news321 lnoff]: /ja/newsletters/2024/09/20/#ln
[news323 offers]: /ja/newsletters/2024/10/04/#bolts-798
[news72 offers]: /ja/newsletters/2019/11/13/#ln-bolt
[news324 guide]: /ja/newsletters/2024/10/11/#bitcoin-core-28-0
[news315 shares]: /ja/newsletters/2024/08/09/#block-withholding-attacks-and-potential-solutions
[news327 superscalar]: /ja/newsletters/2024/11/01/#timeout-tree-channel-factories
[news330 plug]: /ja/newsletters/2024/11/22/#pluggable-channel-factories
[news283 lndvuln]: /ja/newsletters/2024/01/03/#lnd
[news285 clnvuln]: /ja/newsletters/2024/01/17/#core-lightning
[news286 btcdvuln]: /ja/newsletters/2024/01/24/#btcd
[news288 bccvuln]: /ja/newsletters/2024/02/07/#ln-bitcoin-core
[news308 lndvuln]: /ja/newsletters/2024/06/21/#lnd
[news310 wlad]: /ja/newsletters/2024/07/05/#miniupnpc
[news310 ek]: /ja/newsletters/2024/07/05/#dos
[news310 jnau]: /ja/newsletters/2024/07/05/#censorship-of-unconfirmed-transactions
[news310 unamed]: /ja/newsletters/2024/07/05/#cpu-dos
[news310 ps]: /ja/newsletters/2024/07/05/#netsplit-from-excessive-time-adjustment
[news310 sec.eine]: /ja/newsletters/2024/07/05/#cpu-dos
[news310 jn1]: /ja/newsletters/2024/07/05/#inv-dos
[news310 cf]: /ja/newsletters/2024/07/05/#memory-dos-using-low-difficulty-headers-dos
[news310 jn2]: /ja/newsletters/2024/07/05/#cpu-wasting-dos-due-to-malformed-requests-cpu-dos
[news310 mf]: /ja/newsletters/2024/07/05/#bip72-uri
[news310 disclosures]: /ja/newsletters/2024/07/05/#bitcoin-core-0-21-0
[news314 es]: /ja/newsletters/2024/08/02/#addr
[news314 mf]: /ja/newsletters/2024/08/02/#upnp
[news322 checkpoint]: /ja/newsletters/2024/09/27/#bitcoin-core-24-0-1
[news324 ng]: /ja/newsletters/2024/10/11/#cve-2024-35202
[news324 b10caj]: /ja/newsletters/2024/10/11/#inventory-dos
[news324 sd]: /ja/newsletters/2024/10/11/#slow-block-propagation-attack
[news328 multi]: /ja/newsletters/2024/11/08/#bitcoin-core-25-1
[news317 exfil]: /ja/newsletters/2024/08/23/#simple-but-imperfect-anti-exfiltration-protocol
[news315 exfil]: /ja/newsletters/2024/08/09/#faster-seed-exfiltration-attack
[news332 ccsf]: /ja/newsletters/2024/12/06/#continued-discussion-about-consensus-cleanup-soft-fork-proposal
[news316 timewarp]: /ja/newsletters/2024/08/16/#testnet4
[news324 btcd]: /ja/newsletters/2024/10/11/#cve-2024-38365-btcd
[news333 if]: /ja/newsletters/2024/12/13/#ln
[news333 deanon]: /ja/newsletters/2024/12/13/#wasabi
[news251 cluster]: /ja/newsletters/2023/05/17/#mempool-clustering
[news283 fees]: /ja/newsletters/2024/01/03/#cluster-fee-estimation
[news285 cluster]: /ja/newsletters/2024/01/17/#mempool
[news312 cluster]: /ja/newsletters/2024/07/19/#introduction-to-cluster-linearization
[news314 cluster]: /ja/newsletters/2024/08/02/#bitcoin-core-30126
[news315 cluster]: /ja/newsletters/2024/08/09/#bitcoin-core-30285
[news314 mine]: /ja/newsletters/2024/08/02/#mempool
[news331 cluster]: /ja/newsletters/2024/11/29/#bitcoin-core-31122
[news290 incentive]: /ja/newsletters/2024/02/21/#mempool
[news298 cluster]: /ja/newsletters/2024/04/17/#mempool-1
[news283 trucpin]: /ja/newsletters/2024/01/03/#v3-pinning
[news284 exo]: /ja/newsletters/2024/01/10/#ln-v3
[news285 mev]: /ja/newsletters/2024/01/17/#mev-miner-extractable-value
[news286 lntruc]: /ja/newsletters/2024/01/24/#v3-ln
[news286 imtruc]: /ja/newsletters/2024/01/24/#v3
[news287 sibrbf]: /ja/newsletters/2024/01/31/#kindred-replace-by-fee
[news288 truc0c]: /ja/newsletters/2024/02/07/#v3
[news289 pcmtruc]: /ja/newsletters/2024/02/14/#mempool
[news289 oldtruc]: /ja/newsletters/2024/02/14/#what-would-have-happened-if-v3-semantics-had-been-applied-to-anchor-outputs-a-year-ago-1-v3
[news301 1p1c]: /ja/newsletters/2024/05/08/#bitcoin-core-28970
[news304 bcc30000]: /ja/newsletters/2024/05/24/#bitcoin-core-30000
[news306 bip431]: /ja/newsletters/2024/06/07/#bips-1541
[news29496]: /ja/newsletters/2024/06/14/#bitcoin-core-29496
[news309 1p1crbf]: /ja/newsletters/2024/06/28/#bitcoin-core-28984
[news313 crittruc]: /ja/newsletters/2024/07/26/#varied-discussion-of-free-relay-and-fee-bumping-upgrades
[news315 crittruc]: /ja/newsletters/2024/08/09/#pay-to-anchor
[news315 p2a]: /ja/newsletters/2024/08/09/#bitcoin-core-30352
[news330 dust]: /ja/newsletters/2024/11/22/#bitcoin-core-30239
[news333 prclub]: /ja/newsletters/2024/12/13/#bitcoin-core-pr-review-club
[news283 elftrace]: /ja/newsletters/2024/01/03/#matt-opcode
[news285 lnhance]: /ja/newsletters/2024/01/17/#lnhance
[news285 64bit]: /ja/newsletters/2024/01/17/#proposal-for-64-bit-arithmetic-soft-fork-64-bit
[news290 64bit]: /ja/newsletters/2024/02/21/#continued-discussion-about-64-bit-arithmetic-and-op-inout-amount-opcode-64-bit-op-inout-amount-opcode
[news306 64bit]: /ja/newsletters/2024/06/07/#updates-to-proposed-soft-fork-for-64-bit-arithmetic-64-bit
[news291 catvault]: /ja/newsletters/2024/02/28/#op-cat-vault
[news293 forkbet]: /ja/newsletters/2024/03/13/#trustless-onchain-betting-on-potential-soft-forks
[news294 btclisp]: /ja/newsletters/2024/03/20/#btc-lisp
[news293 chialisp]: /ja/newsletters/2024/03/13/#chia-lisp
[news331 bll]: /ja/newsletters/2024/11/29/#bitcoin-lisp
[news331 earmarks]: /ja/newsletters/2024/11/29/#flexible-coin-earmarks
[news302 ctvext]: /ja/newsletters/2024/05/15/#bip119
[news305 overlap]: /ja/newsletters/2024/05/31/#should-overlapping-soft-fork-proposals-be-considered-mutually-exclusive
[news306 fecov]: /ja/newsletters/2024/06/07/#functional-encryption-covenants
[newsletters]: /ja/newsletters/
[news306 catfaucet]: /ja/newsletters/2024/06/07/#proof-of-work-op-cat
[topics index]: /en/topics/
[news315 elftracezk]: /ja/newsletters/2024/08/09/#cat-matt-elftrace
[news319 catmillion]: /ja/newsletters/2024/09/06/#op-cat
[news330 sigactivity]: /ja/newsletters/2024/11/22/#signet
[news330 paircommit]: /ja/newsletters/2024/11/22/#lnhance
[news330 covgrind]: /ja/newsletters/2024/11/22/#covenants-based-on-grinding-rather-than-consensus-changes
[news333 covpoll]: /ja/newsletters/2024/12/13/#poll-of-opinions-about-covenant-proposals
[news307 bcc29496]: /ja/newsletters/2024/06/14/#bitcoin-core-29496
[news325 mining]: /ja/newsletters/2024/10/18/#bitcoin-core-30955
[news315 shares]: /ja/newsletters/2024/08/09/#block-withholding-attacks-and-potential-solutions
[news333 dnsbolt]: /ja/newsletters/2024/12/13/#bolts-1180
[news306 dnsblip]: /ja/newsletters/2024/06/07/#blips-32
[news292 bip21]: /ja/newsletters/2024/03/06/#bip21-bitcoin-uri
[news307 bip353]: /ja/newsletters/2024/06/14/#bips-1551
[news306 bip21]: /ja/newsletters/2024/06/07/#bip21
[news329 dnsimp]: /ja/newsletters/2024/11/15/#ldk-3283
[news303 bip2]: /ja/newsletters/2024/05/17/#bip2
[news322 newbip2]: /ja/newsletters/2024/09/27/#bip
[news306 testnet]: /ja/newsletters/2024/06/07/#testnet4-bip
[news315 testnet4imp]: /ja/newsletters/2024/08/09/#bitcoin-core-29775
[news315 testnet4bip]: /ja/newsletters/2024/08/09/#bips-1601
[news309 sptweak]: /ja/newsletters/2024/06/28/#bips-1620
[news326 sppsbt]: /ja/newsletters/2024/10/25/#psbt-bip
[news327 sppsbt]: /ja/newsletters/2024/11/01/#dleq-bip
[news303 bitvmx]: /ja/newsletters/2024/05/17/#bitvm
[news303 aut]: /ja/newsletters/2024/05/17/#anonymous-usage-tokens
[news321 utxozk]: /ja/newsletters/2024/09/20/#utxo
[news304 lnup]: /ja/newsletters/2024/05/24/#ln
[news309 stfu]:  /ja/newsletters/2024/06/28/#bolts-869
[news326 ann1.75]: /ja/newsletters/2024/10/25/#updates-to-the-version-1-75-channel-announcements-proposal-1-75
[news304 minecash]: /ja/newsletters/2024/05/24/#challenges-in-rewarding-pool-miners
[news310 msbip]: /ja/newsletters/2024/07/05/#bips-1610
[news304 msbip]: /ja/newsletters/2024/05/24/#miniscript-bip
[news333 deplete]: /ja/newsletters/2024/12/13/#insights-into-channel-depletion
[news307 quant]: /ja/newsletters/2024/06/14/#bip
[news317 blip39]: /ja/newsletters/2024/08/23/#blips-39
[news319 merkle]: /ja/newsletters/2024/09/06/#mitigating-merkle-tree-vulnerabilities
[news292 merkle]: /ja/newsletters/2024/03/06/#bitcoin-core-29412
[news332 zmwarp]: /ja/newsletters/2024/12/06/#continued-discussion-about-consensus-cleanup-soft-fork-proposal
[news302 utreexod]: /ja/newsletters/2024/05/15/#utreexod
[news301 lamport]: /ja/newsletters/2024/05/08/#ecdsa
[news314 hyperion]: /ja/newsletters/2024/08/02/#bitcoin-p2p-hyperion
[news315 cb]: /ja/newsletters/2024/08/09/#statistics-on-compact-block-reconstruction
[news315 rbfdefault]: /ja/newsletters/2024/08/09/#bitcoin-core-30493
[news329 opr]: /ja/newsletters/2024/11/15/#mad-opr
[news315 threshsig]: /ja/newsletters/2024/08/09/#bip
[news310 musig]: /ja/newsletters/2024/07/05/#bips-1540
[LDK 0.0.119]: /ja/newsletters/2024/01/17/#ldk-0-0-119
[HWI 2.4.0]: /ja/newsletters/2024/01/31/#hwi-2-4-0
[Core Lightning 24.02]: /ja/newsletters/2024/02/28/#core-lightning-24-02
[Eclair v0.10.0]: /ja/newsletters/2024/03/06/#eclair-v0-10-0
[Bitcoin Core 27.0]: /ja/newsletters/2024/04/17/#bitcoin-core-27-0
[BTCPay Server 1.13.1]: /ja/newsletters/2024/04/17/#btcpay-server-1-13-1
[Bitcoin Inquisition 25.2]: /ja/newsletters/2024/05/01/#bitcoin-inquisition-25-2
[Libsecp256k1 v0.5.0]: /ja/newsletters/2024/05/08/#libsecp256k1-v0-5-0
[LDK v0.0.123]: /ja/newsletters/2024/05/15/#ldk-v0-0-123
[Bitcoin Inquisition 27.0]: /ja/newsletters/2024/05/24/#bitcoin-inquisition-27-0
[LND v0.18.0-beta]: /ja/newsletters/2024/05/31/#lnd-v0-18-0-beta
[Core Lightning 24.05]: /ja/newsletters/2024/06/14/#core-lightning-24-05
[HWI 3.1.0]: /ja/newsletters/2024/09/20/#hwi-3-1-0
[Bitcoin Core 28.0]: /ja/newsletters/2024/10/04/#bitcoin-core-28-0
[BTCPay Server 2.0.0]: /ja/newsletters/2024/11/01/#btcpay-server-2-0-0
[Libsecp256k1 0.6.0]: /ja/newsletters/2024/11/08/#libsecp256k1-0-6-0
[BDK 0.30.0]: /ja/newsletters/2024/11/29/#bdk-0-30-0
[Eclair v0.11.0]: /ja/newsletters/2024/12/06/#eclair-v0-11-0
[Core Lightning 24.11]: /ja/newsletters/2024/12/13/#core-lightning-24-11
[Human Rights Foundation]: https://hrf.org
