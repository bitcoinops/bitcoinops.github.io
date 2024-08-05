---
title: 'Bitcoin Optech Newsletter #180: 2021年振り返り特別号'
permalink: /ja/newsletters/2021/12/22/
name: 2021-12-22-newsletter-ja
slug: 2021-12-22-newsletter-ja
type: newsletter
layout: newsletter
lang: ja

excerpt: >
  このOptechニュースレターの特別版では、2021年のBitcoinの注目すべき動向についてまとめています。
---

{{page.excerpt}} [2018年][2018 summary]、[2019年][2019 summary]、[2020年][2020 summary]のまとめの続編になります。

## 内容

* 1月
  * [Bitcoin Coreのsignet](#signet)
  * [Bech32mアドレス](#bech32m)
  * [OnionメッセージとOfferプロトコル](#offers)
* 2月
  * [署名の作成と検証の高速化](#safegcd)
  * [チャネルジャミング攻撃](#jamming)
* 3月
  * [量子コンピュータのリスク](#quantum)
* 4月
  * [LNのアトミック・マルチパス・ペイメント](#amp)
* 5月
  * [BIP125 opt-in replace-by-feeの不一致](#bip125)
  * [デュアル・ファンディングチャネル](#dual-funding)
* 6月
  * [ブロック作成時の候補セット](#csb)
  * [手数料によるトランザクション置換のデフォルト](#default-rbf)
  * [mempoolパッケージの受け入れとパッケージリレー](#mpa)
  * [Fast ForwardsによるLNのスピードアップとオフライン受信](#ff)
* 7月
  * [LNの流動性の広告](#liq-ads)
  * [Output Script Descriptor](#descriptors)
  * [ゼロ承認チャネルの開設](#zeroconfchan)
  * [SIGHASH_ANYPREVOUT](#anyprevout)
* 8月
  * [Fidelity bonds](#fibonds)
  * [LNの経路探索](#pathfinding)
* 9月
  * [OP_TAPLEAF_UPDATE_VERIFY](#tluv)
* 10月
  * [トランザクションヘリテージ識別子](#txhids)
  * [PTLCとLNのFast Forwards](#ptlcsx)
* 11月
  * [LN開発者サミット](#lnsummit)
* 12月
  * [高度な手数料の引き上げ方法](#bumping)
* 注目のまとめ
  * [Taproot](#taproot)
  * [人気のあるインフラストラクチャプロジェクトのメジャーリリース](#releases)
  * [Bitcoin Optech](#optech)

## 1月

{:#signet}
数年にわたる議論の末、先行するC-Lightningによる[サポート][cl#2816]やLNDでの[サポート][lnd#5025]に続いて、
1月には[signet][topic signet]をサポートする最初のBitcoin Coreのバージョンが[リリース][bcc21]されました。
signetは、誰もがBitcoinのメインネットワーク（mainnet）をシミュレートするために使用できるテストネットワークで、
現在存在するものと、特定の変更（ソフトフォークによりコンセンサスの変更を有効化したものなど）を含むものが存在します。
signetを実装するほとんどのソフトウェアは、デフォルトsignetもサポートしています。
デフォルトsignetは、さまざまなチームによって開発されたソフトウェアを、
実際のお金がかかっている時の環境に可能な限り近い安全な環境でテストするための便利な手段を提供しています。
また今年は、Bitcoin Coreのデフォルトsignetに意図的なブロックチェーンの再編成を追加し、
開発者がその種の問題に対してソフトウェアをテストできるようにすることについても[議論されました][signet reorgs]。

{:#bech32m}
[bech32m][topic bech32]のドラフトBIPも1月に[発表されました][bech32 bip]。
Bech32mアドレスは、bech32を少し修正したもので、[Taproot][topic taproot]や
将来のプロトコルの拡張で安全に使用できるようにしたものです。
その後、[Bitcoin Wikiページ][bech32m page]が更新され、
ウォレットやサービスのbech32mアドレスの採用状況が追跡できるようになりました。

{:#offers}
新しいプロトコルのもう１つの[最初のリリース][cl 0.9.3]は、
[Onionメッセージ][topic onion messages]と[Offerプロトコル][topic offers]でした。
Onionメッセージは、LNノードが、[HTLC][topic htlc]ベースのメッセージ送信と比べて、
オーバーヘッドを最小限にする方法で他のノードにメッセージを送信することを可能にします。
Offerは、Onionメッセージを使ってあるノードが他のノードに支払いを*オファー*できるようにし、
受信ノードが詳細なインボイスや他の必要な情報を返すことができるようにします。
OnionメッセージとOfferは、今年いっぱいはドラフト仕様のままですが、
これらを[支払いのスタックによる影響を軽減する][offers stuck]ために使用する提案を含め、
さらなる開発が行われる予定です。

## 2月

{:#safegcd}
Bitcoinのコントリビューターは、改良された署名の作成と検証アルゴリズムの研究を[進め][safegcd blog]、
その研究を利用して、さらに改良を加えたバリエーションを作成しました。
libsecp256k1に実装され（[1][secp831]、[2][secp906]）、[その後][bcc21573]Bitcoin Coreに実装されると、
署名検証にかかる時間が約10%短縮されました。これはBitcoinのブロックチェーンで
約10億の署名を検証する際の大きな改善となります。
この変更が数学的に正しく、安全に使用できることを確認するために、複数の暗号学者が作業を行いました。
また、この変更により、低消費電力のハードウェア署名デバイスで安全に署名を作成する速度が大幅に向上します。

{:#jamming}
2015年以来、LNの既知の問題である[チャネルジャミング攻撃][topic channel jamming attacks]は、
年間の継続的な議論の中で、[さまざま][jam1]な[可能な][jam2]解決策が[議論されました][jam3]。
残念ながら広く受け入れられる解決策は見つからず、年末までこの問題は未解決のままです。

{:.center}
![Illustration of jamming attacks](/img/posts/2020-12-ln-jamming-attacks.png)

## 3月

{:#quantum}
3月の重要な[議論][quant]は、Bitcoinに対する量子コンピュータによる攻撃のリスク、
特にTaprootが有効になり広く使用されるようになった場合のリスクの分析に向けられました。
Bitcoinの元々の機能の1つである公開鍵のハッシュは（Bitcoinアドレスを短くするために追加された可能が高い）、
量子コンピュータが突然大きく進歩した場合、限られたユーザーから資金を盗むのを困難にする可能性もあります。
[Taproot][topic taproot]はこの機能を提供しておらず、少なくとも1人の開発者は、
それによる不合理なリスクを懸念していました。
多数の反論が提示され、Taprootに対するコミュニティの支持は変わりませんでした。

<div markdown="1" class="callout" id="taproot-activation">

### 2021年のまとめ<br>Taprootの有効化

2020年の年末に、[Schnorr署名][topic schnorr signatures]と[Tapscript][topic tapscript]のサポートを含む
[Taproot][topic taproot]のソフトフォークの実装がBitcoin Coreに[マージされました][bcc#19953]。
これでプロトコル開発者の作業はほぼ完了し、あとはコミュニティが希望すればTaprootが有効になり、
ウォレット開発者がTaprootおよび[bech32m][topic bech32]アドレスなどの関連技術のサポートを追加し始めるだけになりました。

{% comment %}<!-- comments in bold text below tweak auto-anchors to prevent ID conflicts -->{% endcomment %}

- **１月<!--january-taproot-->** は、Bitcoin Core 0.21.0の[リリース][bcc21]から始まりました。
  これはTaprootが有効になったデフォルト[signet][topic signet]を含むsignetをサポートした最初のリリースで、
  ユーザーと開発者にテストを始めやすい環境を提供するものでした。

- **２月<!--february-taproot-->** には、`##taproot-activation`
  IRCチャネルで予定された[多く][tapa2]の[会議][tapa3]の[最初の][tapa1]会議が開かれました。
  これは、Taprootを有効化する方法について、開発者、ユーザー、マイナーが話し合うための主要なハブになります。

- **３月<!--march-taproot-->** は、多くの会議参加者が*Speedy Trial*という特定の有効化方法を
  [試みる][speedy trial]ことに暫定的に合意したところから始まりました。
  Speedy Trialは、マイナーからの迅速なフィードバックを集めながら、
  ユーザーがTaprootを適用するにあたりソフトウェアをアップグレードするための十分な時間を与えるよう設計されています。
  Speedy Trialは、Taprootを有効化するために使用される実際の[メカニズム][topic soft fork activation]になるでしょう。

  有効化の議論が続く中、その設計上の決定の1つである、公開鍵をそのまま使用することについて、最終的な[議論][quant]がありました。
  これはユーザーの資金が将来の量子コンピュータによって盗まれる危険性が高まるかもしれないという議論でした。
  多くの開発者は、この懸念は杞憂に終わるか、少なくとも誇張されていると主張しました。

  また3月に、Bitcoin Coreが[BIP350][]のサポートをマージし、[bech32m][topic bech32]アドレスへの支払いを可能にしました。
  元々Segwitバージョンのアドレスの支払いに使用されているbech32アドレスへの僅かな変更により、
  非常に稀なケースで、Taprootユーザーが資金を失う原因となる可能性のあったバグが修正されます。
  （bech32アドレスから作られた元のSegwitアウトプットは安全で、バグの影響は受けません。）

  {% comment %}
  /en/newsletters/2021/03/03/#rust-lightning-794
  /en/newsletters/2021/03/10/#documenting-the-intention-to-use-and-build-upon-taproot
  /en/newsletters/2021/03/24/#discussion-of-quantum-computer-attacks-on-taproot
  /en/newsletters/2021/03/24/#bitcoin-core-20861
  /en/newsletters/2021/03/31/#should-block-height-or-mtp-or-a-mixture-of-both-be-used-in-a-soft-fork-activation-mechanism
  {% endcomment %}

- **４月<!--april-taproot-->** は、プロトコル開発者と一部のユーザーが、
  2つの微妙に異なるSpeedy Trialの有効化メカニズムのメリットについて[議論した][tapa4]ため、
  有効化の進捗が脱線しました。しかし、2つの異なるバージョンの異なる実装の作者は、有効化メカニズムとパラメーターを持つ
  Bitcoin Coreの[バージョン][bcctap]をリリースできるようにするという[妥協案][bcc#21377]に合意しました。

- **５月<!--may-taproot-->** になると、
  マイナーはTaprootを適用する準備ができたことを[通知する][signal began]ことが[できるように][signal able]なり、
  通知の進捗を追跡するウェブサイトが[人気に][taproot.watch]なります。

- **６月<!--june-taproot-->** 、マイナーは[Taprootをロックイン][lockin]し、
  推定6ヶ月後のブロック{{site.trb}}で有効化することをコミットしました。
  これは[ウォレット開発者][bcc#22051]や[他のインフラストラクチャ開発者][bolts#672]が、
  彼らの[ソフトウェア][p2trhd]をTaprootに[対応させる][rb#601]ことに[注意][bcc#21365]を[払う][cl#4591]べき[時][rb#589]が来たことを意味し、
  多くの開発者が[対応][bcc#22154]を[行いました][bcc#22166]。
  さらに、オンチェーンのTaprootウォレットが、
  LNや[Coinswaps][topic coinswap]などのさまざまなコントラクトプロトコルを使用して、
  ウォレットのプライバシーに貢献できるようにするための[提案][nsequence default]もされました。
  Optechも、[Taprootの準備][p4tr]シリーズを[始めました][p4tr begins]。

- **７月<!--july-taproot-->** には、Taproot有効化後に、
  ウォレットでTaprootを使用できるようにするために必要なbech32mアドレスフォーマットのサポートを追跡する
  Bitcoin Wiki[ページ][bech32m page]が開設されました。
  多くのウォレットやサービスの開発者が、この機会に立ち上がり、
  有効化されたら誰もがTaprootを使用できるようにするために準備することになりました。
  他の[ソフトフォークの提案][bip118 update]も、Taprootを使用するように更新されたり、
  その有効化から[学んだ知見][bip119 update]を反映しました。

- **８月<!--august-taproot-->** は、Taprootに関連するいくつかの[ドキュメント][reuse risks]が作成されましたが、
  Taprootの開発については静かな時期でした。

- **９月<!--september-taproot-->** には、Bitcoinで最も人気のあるオープンソースのマーチャントソフトウェアが、
  予定された有効化に先立ちTaprootの[サポート][btcpay taproot]を追加しました。
  また、Taprootの機能を利用しScriptベースの[Covenants][topic covenants]を可能にする新しいopcodeも[提案されました][op_tluv]。

- **１０月<!--october-taproot-->** に入り、Taprootの有効化が[近づくにつれ][testing taproot]、
  [新たな][rb#563]開発[活動][rb#644]が始まりました。
  TaprootのBIPは、ウォレットやインフラストラクチャの開発者がその実装を検証できるよう、
  [Test Vectorを拡張して][expanded test vectors]更新されました。

- **１１月<!--november-taproot-->** は[Taprootが有効化されました][taproot activation]。
  ブロック{{site.trb}}とそれに続くいくつかのブロックのマイナーが、
  Taproot支払いのトランザクションをブロックに含めなかったため、当初は混乱がありました。
  しかし、複数の開発者とマイニングプールの管理者の作業のおかげで、
  その後マイニングされたほとんどのブロックで、Taproot支払いのトランザクションを含める準備ができました。
  [Taproot対応][dec cs]ソフトウェアの[開発][nov cs]と[テスト][cbf verification]が[続けられました][rb#691]。

- **１２月<!--december-taproot-->** 、[descriptor wallet][topic descriptors]でTaproot支払いを受け取るための
  [bech32m][topic bech32]アドレスを作成できるようにするPRがBitcoin Coreにマージされました。
  また、LN開発者はTaprootの機能の[活用][ln ptlcs]についてさらに議論しました。

Taprootの有効化メカニズムを選択する際の複雑さと、有効化直後の若干の混乱はありましたが、
BitcoinにTaprootソフトフォークのサポートを追加する最終ステップは全体的にうまくいったようです。
Taprootはこれで終わりという訳ではありません。Optechは、
ウォレットやインフラストラクチャの開発者がその多くの機能を利用し始める今後数年間、
かなりの時間を使ってこのことについて書き続けていくでしょう。

</div>

## 4月

{:#amp}
LNDは4月にアトミック・マルチパス・ペイメント ([AMP][topic amp])を[サポート][lnd#5709]しました。
これは、すべての主要なLN実装が現在サポートしている[簡略化されたマルチパス・ペイメント][topic multipath payments]（SMP）よりも前に
紹介されているためオリジナルAMPとも呼ばれています。
AMPはSMPよりもプライバシー面で有利であり、受信者が支払いを請求する前にすべてのパーツを受け取っていることを保証します。
AMPの欠点は、暗号学的な支払いの証明を生成しないことです。
LNDは、基本的に支払いの証明を提供できない[自発的な支払い][topic spontaneous payments]で使用するためにAMPを実装し、
AMPの1つの重大な欠点を考慮から排除しています。

## 5月

{:#bip125}
[BIP125][]のトランザクションの[置換][topic rbf]の仕様とBitcoin Coreの実装との間の不一致が5月に[開示されました][bip125 discrep]。
私たちが知る限り、これによってビットコインが危険にさらされることはありませんでしたが、
予期しないトランザクションのリレー動作による（LNなどの）コントラクトプロトコルのユーザーのリスクについて、
いくつかの議論が生まれました。

{:#dual-funding}
5月はまた、C-Lightningプロジェクトが、
チャネルの両参加者がある程度の初期資金を提供できる[デュアル・ファンディングチャネル][topic dual funding]を管理するプラグインを
[マージしました][cl#4489]。今年[マージされた][cl#4410]デュアル・ファンディングの作業に加えて、
これにより、チャネルを開設した側が、チャネルの初期状態において、
チャネルを通じて資金を支払うだけでなく受け取ることができるようになります。
このように初期状態で資金を受け取ることができるため、LNの主な用途が送金ではなく支払いの受け取りであるマーチャントにとって、
デュアル・ファンディングは特に有用です。

<div markdown="1" class="callout" id="releases">

### 2021年のまとめ<br>人気のあるインフラストラクチャプロジェクトのメジャーリリース

- [Eclair 0.5.0][]では、スケーラブルなクラスターモード（[ニュースレター #128][news128 akka]参照）、
  ブロックチェーンウォッチドッグ（[ニュースレター #123][news123 watchdog]参照）、
  追加のプラグインフックをサポートしました。

- [Bitcoin Core 0.21.0][]は、[バージョン2のアドレス通知メッセージ][topic addr v2]を使用する
  新しいTor onion serviceのサポート、[Compact Block Filter][topic compact block filters]を提供するオプション機能、
  [signet][topic signet]のサポート（[Taproot][topic taproot]を有効化したデフォルトsignetを含む）を含んでいます。
  また、[Output Script Descriptor][topic descriptors]をネイティブで使用するウォレットの実験的なサポートも提供しています。

- [Rust Bitcoin 0.26.0][]には、signetのサポート、バージョン2のアドレス通知メッセージ、
  [PSBT][topic psbt]処理の改善が含まれています。

- [LND 0.12.0-beta][]には、[Anchor Output][topic anchor outputs]を用いる[Watchtowers][topic watchtowers]の使用のサポートが含まれ、
  [PSBT][topic psbt]を扱うための新しい`psbt`ウォレットサブコマンドが追加されました。

- [HWI 2.0.0][]には、BitBox02でのマルチシグのサポート、
  ドキュメントの改善、Trezorでの`OP_RETURN`アウトプットの支払いのサポートが含まれています。

- [C-Lightning 0.10.0][]には、APIの拡張と、[デュアル・ファンディング][topic dual funding]の実験的なサポートが含まれています。

- [BTCPay Server 1.1.0][]では、[Lightning Loop][news53 lightning loop]のサポート、
  2要素認証オプションとして[WebAuthN/FIDO2][fido2 website]の追加、
  さまざまなUIの改善、バージョン番号の[セマンティックバージョニング][semantic versioning website]への移行が行われました。

- [Eclair 0.6.0][]には、ユーザーのセキュリティとプライバシーを強化するためのいくつかの改良が含まれています。
  また、[bech32m][topic bech32]アドレスを使用する可能性のある将来のソフトウェアとの互換性も提供されています。

- [LND 0.13.0-beta][]では、[Anchor Output][topic anchor outputs]を
  デフォルトのコミットメントトランザクションのフォーマットとすることで、
  手数料率の管理を改善し、プルーニングされたBitcoinのフルノードの使用をサポートし、
  アトミックパルチパス（[AMP][topic amp]）を使用して支払いの受信や送信をできるようにし、
  LNDの[PSBT][topic psbt]機能を向上させました。

- [Bitcoin Core 22.0][]は、[I2P][topic anonymity networks]接続をサポートし、
  [バージョン2のTor][topic anonymity networks]接続のサポートを削除し、
  [ハードウェアウォレット][topic hwi]のサポートを強化しました。

- [BDK 0.12.0][]は、Sqliteを使用してデータを保存する機能を追加しました。

- [LND 0.14.0][]では、追加の[エクリプス攻撃][topic eclipse attacks]対策（[ニュースレター #164][news164 ping]参照）、
  リモートデータベースのサポート（[ニュースレター #157][news157 db]参照）、
  経路探索の高速化（[ニュースレター #170][news170 path]参照）、
  Lightning Poolユーザー向けの改善（[ニュースレター #172][news172 pool]参照）、
  再利用可能な[AMP][topic amp]インボイス（[ニュースレター #173][news173 amp]参照）が含まれています。

- [BDK 0.14.0][]では、トランザクションへの`OP_RETURN`アウトプットの追加を簡略化し、
  Taprootの[bech32m][topic bech32]アドレスへの支払いの送信の改良が含まれています。

</div>

## 6月

{:#csb}
6月に議論された新しい[分析][csb]では、マイナーが作成するブロックにどのトランザクションを含めるか選択するための
代替方法について説明されています。この新しい方法は、短期的にマイナーの収益をわずかに増加させると予測されます。
長期的には、この手法がマイナーに採用されると、
それを知っているウォレットは[CPFPによる手数料の引き上げ][topic cpfp]のトランザクションで協力することができ、
その手法の有効性が高まります。

{:#default-rbf}
手数料の引き上げをより効果的にするもう1つの試みは、
Bitcoin Coreにおける[BIP125][]を使用した置換を許可するオプトインの手法だけでなく、
あらゆる未承認トランザクションを[replaced by fee][topic rbf] (RBF)で置き換えることを許可する[提案][rbf default]です。
これは、マルチパーティプロトコルの手数料引き上げに関するいくつかの問題の解決に役立ち、
またより多くのトランザクションが同じ設定を使用できるようにすることでプライバシーの向上になります。
プライバシーに関連して、別の[提案][nseq default]では、Taproot支払いを作成するウォレットは、
[BIP68][]のコンセンサスが適用されるシーケンス値によって提供される機能を必要としない場合でも、
デフォルトのnSequence値をセットすることが提案されました。
どちら提案でも、大きな反対はほとんどありませんでしたが、あまり進展はなかったようです。

{:#mpa}
6月には、Bitcoin Coreで[mempoolのパッケージ受け入れ][mpa ml]を実装するシリーズの[最初のPR][bcc#20833]がマージされ、
パッケージリレーへの最初の一歩が踏み出されました。[パッケージリレー][topic package relay]は、
リレーノードとマイナーに、関連するトランザクションパッケージを手数料率の目的で単一のトランザクションであるかのように扱わせるものです。
パッケージには手数料率の低い親トランザクションと手数料率の高い子トランザクションが含まれている場合、
子トランザクションの収益性は、マイナーが親トランザクションをマイニングする動機になります。
パッケージマイニングは2016年からBitcoin Coreに[実装されていますが][bitcoin core #7600]、
これまでのところノードがトランザクションをパッケージとしてリレーする方法はありません。
つまり、高手数料率の子を持っていたとしても低手数料率の親トランザクションは、
高手数料の期間中には、マイナーに届かない可能性があります。
このため、LNのような事前署名トランザクションを使用するコントラクトプロトコルでは、
[CPFPによる手数料の引き上げ][topic cpfp]の信頼性が低くなっています。パッケージリレーは、
この重要な安全性の問題を解決することを望むものです。

{:#ff}
もともと2019年にLNのために提案されたアイディアが、6月に新たな命を吹き込まれました。
オジリナルの[Fast Forward][ff orig]のアイディアは、LNウォレットがより少ないネットワークの往復で支払いを受信または中継し、
ネットワーク帯域幅と支払いのレイテンシーを削減する方法を説明したものです。
このアイディアは今年[拡張され][ff expanded]、LNウォレットが支払いのたびに署名鍵をオンラインにすることなく
複数の支払いを受け取り、署名鍵を簡単に保護できるようにする方法を紹介しました。

## 7月

{:#liq-ads}
数年にわたる議論と開発の末、分散型の流動性広告システムの最初の実装がLNの実装に[マージ][cl#4639]されました。
まだドラフトである[liquidity ads][bolts #878]の提案では、
ノードが、LNのゴシッププロトコルを使用して、一定期間資金をリースする意思を広告し、
他のノードは即時に支払いを受け取ることが可能なインバウンドキャパシティを購入できるようになります。
広告を見たノードは、[デュアル・ファンディング][topic dual funding]チャネルを開いて、
支払いとインバウンドキャパシティの受け取りを同時に行うことができます。
広告ノードが実際に支払いをルーティングすることを強制する方法はありませんが、
この提案には、合意したリース期間が終了するまで広告主が他の目的に資金を使用することを防ぐ、
以前の提案（その後Lightning Poolでも[使用][lnd#5709]）が取り入れられています。
つまり、支払いのルーティングを拒否しても何のメリットもなく、
広告ノードがルーティング手数料を得る機会が失われることになります。

{:#descriptors}
Bitcoin Coreに[最初に提案されてから][descriptor gist]3年、
[Output Script Descriptor][topic descriptors]の[ドラフトBIP][descriptor bips1]が[作成されました][descriptor bips2]。
Descriptorは、ウォレットまたは他のプログラムが、特定のScriptや関連するScriptのセット
（例えば、[HDウォレット][topic bip32]のようなアドレスや関連アドレスのセット）に対する支払い、
もしくはそこからの支払いを追跡するために必要なすべての情報を含んでいる文字列です。
Descriptorは、[Miniscript][topic miniscript]と組み合わせて、
ウォレットがさまざまなScriptの追跡と署名を処理できるようにします。
また、[PSBT][topic psbt]と組み合わせると、ウォレットがマルチシグScriptで制御する鍵を決定することができます。
年末までに、Bitcoin CoreはDescriptorベースのウォレットを、新しく作成されるウォレットの[デフォルト][descriptor default] にしました。

{:#zeroconfchan}
7月には、これまでLNプロトコルの一部ではなかった、LNチャネルの一般的な開設方法が[定義され][0conf channels]始めました。
*ターボチャネル*とも呼ばれるゼロ承認チャネルは、資金提供者が初期資金の一部またはすべてを受信者に提供する
新しいシングル・ファンディングチャネルです。これらの資金は、
チャネル開設のトランザクションが十分な数の承認を得るまで安全ではないため、
受領者が標準的なLNプロトコルを使用して資金の一部を資金提供者に戻すことにリスクはありません。
例えば、アリスはボブのカストディアルな取引所の口座に数BTC持っています。
アリスはボブに、アリスに1.0 BTC支払う新しいチャネルを開くよう依頼します。
ボブは自分自身が開設したばかりのチャネルを二重使用しないと信じているので、
チャネル開設トランザクションが１つめの承認を受ける前であっても、
アリスがボブのノードを通じて0.1 BTCを第三者のキャロルに送信できるようにすることができます。
挙動を定義することは、LNノードとこのサービスを提供するマーチャントとの間の相互運用性の向上に役立つはずです。

{:.center}
![Zero-conf channel illustration](/img/posts/2021-07-zeroconf-channels.png)

{:#anyprevout}
新しい署名ハッシュ（sighash）タイプに関する2つの提案が[BIP118][]に[統合されました][sighash combo]。
2017年に提案され、一部は10年前に遡る以前の提案に基づいていた`SIGHASH_NOINPUT`は、
2019年に最初に[提案された][anyprevout proposed]
[`SIGHASH_ANYPREVOUT`と`SIGHASH_ANYPREVOUTANYSCRIPT`][topic sighash_anyprevout]に
取って代わられました。新しいsighashタイプにより、LNや[Vault][topic vaults]などのオフチェーンプロトコルは、
保持する必要のある中間状態の数を減らし、ストレージ要件と複雑さを大幅に軽減することができるようになります。
マルチパーティプロトコルでは、そもそも生成する必要のあるさまざまな状態の数をなくすことで、
メリットがさらに大きくなる可能性があります。

## 8月

{:#fibonds}

Fidelity bondは、サードパーティのシステムでの不正行為の代償として、
ビットコインを一定期間ロックするために、少なくとも2010年には[紹介されている][wiki contract]アイディアです。
ビットコインはそのタイムロックが切れるまで再び使用することができないため、
ロック期間中に禁止されたり他のペナルティを受けた他のシステムのユーザーは、
同じビットコインを使って新しい仮想IDを作れなくなります。
8月、JoinMarketはFidelity bondを初めて大規模かつ分散的に利用するための[本番運用][fi bonds]を開始しました。
リリースから数日で、50 BTC以上がタイムロックされました（当時の価格で$200万USD以上）。

{:#pathfinding}
8月には、LNの新しい経路探索のバリエーションが[議論されました][0base]。
この手法の支持者は、ルーティングノードが各支払いに最小の*基本手数料（Base fee）*を課さずに、
ルーティングされた金額の割合のみに手数料を課す場合に最も効果的であると考えました。
しかし、別の意見もありました。年末までに、この手法の[バリエーション][cl#4771]が
C-Lightningに実装される予定です。

<div markdown="1" class="callout" id="optech">

### 2021年のまとめ<br>Bitcoin Optech

Optechの4年めは、51の週刊[ニュースレター][newsletters]を発行し、
[トピックインデックス][topics index]に30の新しいページをを追加し、
[寄稿ブログ記事][additive batching]を公開し、
[Taprootの準備][p4tr]に関する21部構成のシリーズを（[2人][zmn guest]のゲスト[投稿者][darosior guest]の助けを借りて）
書きました。合計すると、Optechは今年、Bitcoinソフトウェアの研究と開発について8万語以上を公開し、
これはおよそ250ページの本に匹敵します。

<!-- wc -w _posts/en/newsletters/2021-*_includes/specials/taproot/en/* -->

</div>

## 9月

{:#tluv}
Bitcoin開発者が長い間議論してきた機能の1つに、ビットコインをScriptに送ると、
そのビットコインを後で受け取る他のScriptを制限することができる[Covenants][topic covenants]と呼ばれる仕組みがあります。
例えば、アリスがビットコインをScriptで受け取り、このScriptは彼女のホットウォレットで使用できますが、
2つめのScriptに送信することで、彼女のホットウォレットが使用するのを時間的に遅らせることができます。
この遅延時間の間、アリスのコールドウォレットは資金を使用できます。
そうせずに、遅延時間が過ぎると、アリスのホットウォレットは資金を自由に使えるようになります。
9月には、署名（keypath支払い）または[MASTのような][topic mast]Scriptツリー（scriptpath支払い）のいずれかを使用して
資金使用するTaprootの機能の活用する方法で、この種のCovenantsを作成する新しい`OP_TAPLEAF_UPDATE_VERIFY` opcodeが
[提案されました][op_tluv]。この新しいopcodeは、複数のユーザーがUTXOの所有権をトラストレスにシェアできるようにすることで、
プライバシーを大幅に向上できる[Joinpool][topic joinpools]の作成に特に有用です。

## 10月

{:#txhids}
10月、Bitcoinの開発者はトランザクションがどのビットコインのセットを使用したいかを
[識別する][heritage identifiers]ための新しい方法について議論しました。
現在、ビットコインは、最後に使用されたトランザクション内の位置で識別されています。
例えば、「トランザクションfooの0番めのアウトプット」のように。
新しい提案では、ビットコインを使用した以前のトランザクションと、降順階層におけるその位置を使って
ビットコインを識別できるようにします。
例えば、「トランザクションbarの2つめの子の0番めのアウトプット」のように。
これにより[eltoo][topic eltoo]や、[Channel Factories][topic channel factories]、
[Watchtower][topic watchtowers]などの設計に利点がもたらされ、
これらすべてがLNなどのコントラクトプロトコルにメリットをもたらすことが示唆されました。

{:#ptlcsx}
また10月には、LNを改善するための既存のアイディアの組み合わせが、
[SIGHASH_ANYPREVOUT][topic sighash_anyprevout]のソフトフォークやその他のコンセンサスの変更を必要とせずに、
eltooと同じ利点のいくつかをもたらす[1つの提案][ptlcs extreme]にまとめられました。
この提案は、特定の経路上のすべてのルーティングノード間を一方向に移動できるのとほぼ同じ速さまで、
支払いの待ち時間を短縮するものです。
また、ノードがチャネルの作成時に必要なすべての情報をバックアップし、
ほどんどの場合にデータの復元中に他の情報を入手できるようにすることで耐障害性を高めることができます。
また、オフラインの鍵で支払いを受けることができるため、特にマーチャントのノードが
オンラインのコンピュータで鍵を使用する時間を制限することが可能になります。

## 11月

{:#lnsummit}
LN開発者は[2018年以来][2018 ln summit]最初の一般的なLNサミットを開催し、
[PTLC][topic ptlc]や[マルチシグ][topic multisignature]のための[MuSig2][topic musig]、
[eltoo][topic eltoo]などLNでの[Taproot][topic taproot]の利用、
仕様の議論のIRCからビデオチャットへの移行、現在のBOLT仕様モデルへの変更、
[Onionメッセージ][topic onion messages]、[Offer][topic offers]、
[Stuckless payments][stuckless payments]、[チャネルジャミング攻撃][topic channel jamming attacks]とさまざまな緩和策、
[トランポリンルーティング][topic trampoline payments]などのトピックについて[議論しました][2021 ln summit]。

## 12月

{:#bumping}
単一署名のオンチェーントランザクションの場合、マイナーにより早く承認するよう促すために、
トランザクションの手数料率を引き上げるのは比較的簡単な操作です。
しかし、LNや[Vault][topic vaults]のようなコントラクトプロトコルの場合、
手数料の引き上げが必要な場合に、支払いを承認したすべての署名者が協力可能な状態にあるとは限りません。
さらに悪いことに、コントラクトプロトコルでは、特定のトランザクションが期日までに承認される必要がある場合が多く、
そうしないと正直なユーザーがお金を失う可能性があります。
12月には、コントラクトプロトコルにとって効果的な手数料の引き上げメカニズムの選択に関連する研究が[発表され][fee bump research]、
この重要な長期的な問題に対する解決策の議論に拍車がかかっています。

## 最後に

今年のまとめでは、2021年の注目すべき20の開発について、
貢献者の名前を一人も出さずに説明するという、新しい試みを行いました。
私たちはこれらすべての貢献者に感謝し、彼らの素晴らしい業績が認められることを強く望んでいますが、
普段言及されていないすべての貢献者にも感謝したいと思います。

コードレビューに時間を費やしている人、
予期せず変更されないことを保証するために確立された動作のテストを書いている人、
お金が危険にさらされる前に問題を修正するために原因不明の問題のデバッグに力を注いでいる人、
やらなかった場合にニュースになるような多くのタスクに取り組んでいる方々。

2021年のこの最後のニュースレターは彼らに捧げます。
私たちは、このような知られざる貢献者たちの名前を簡単にリストアップする方法を持ち合わせていません。
代わりに、このニュースレターからすべての名前を省略し、Bitcoinの開発はチームの努力であり、
最も重要な仕事のいくつかは、
このニュースレターのどの号にも名前が載ったことのない人々によって行われていることを強調しています。

彼ら、そして2021年にBitcoinに貢献したすべての人々に感謝します。
2022年に彼らがどんなエキサイティングな新展開を見せてくれるのか、待ち遠しい限りです。

*Optechのニュースレターは、1月5日から通常の水曜日の発行に戻ります。*

{% include references.md %}
{% include linkers/issues.md issues="878,7600" %}
[2018 summary]: /en/newsletters/2018/12/28/
[2019 summary]: /ja/newsletters/2019/12/28/
[2020 summary]: /en/newsletters/2020/12/23/
[cl 0.9.3]: /ja/newsletters/2021/01/27/#c-lightning-0-9-3
[safegcd blog]: /ja/newsletters/2021/02/17/#faster-signature-operations
[secp831]: /ja/newsletters/2021/03/24/#libsecp256k1-831
[secp906]: /ja/newsletters/2021/04/28/#libsecp256k1-906
[bcc21573]: /ja/newsletters/2021/06/16/#bitcoin-core-21573
[bcc21]: /ja/newsletters/2021/01/20/#bitcoin-core-0-21-0
[cl#2816]: /en/newsletters/2019/07/24/#c-lightning-2816
[jam1]: /ja/newsletters/2021/02/17/#renewed-discussion-about-bidirectional-upfront-ln-fees-ln
[jam2]: /ja/newsletters/2021/10/20/#lowering-the-cost-of-probing-to-make-attacks-more-expensive
[jam3]: /ja/newsletters/2021/11/10/#ln-summit-2021
[quant]: /ja/newsletters/2021/03/24/#discussion-of-quantum-computer-attacks-on-taproot
[tapa1]: /ja/newsletters/2021/01/27/#taproot
[tapa2]: /ja/newsletters/2021/02/10/#taproot
[tapa3]: /ja/newsletters/2021/02/24/#taproot
[tapa4]: /ja/newsletters/2021/04/14/#taproot-activation-discussion-taproot
[bcctap]: /ja/newsletters/2021/04/21/#taproot-activation-release-candidate-taproot
[speedy trial]: /ja/newsletters/2021/03/10/#taproot-activation-discussion-taproot
[bcc#21377]: /ja/newsletters/2021/04/21/#bitcoin-core-21377
[signal began]: /ja/newsletters/2021/05/05/#miners-encouraged-to-start-signaling-for-taproot-taproot
[signal able]: /ja/newsletters/2021/05/05/#bips-1104
[taproot.watch]: /ja/newsletters/2021/05/26/#how-can-i-follow-the-progress-of-miner-signaling-for-taproot-activation-taproot
[rb#589]: /ja/newsletters/2021/05/12/#rust-bitcoin-589
[bolts#672]: /ja/newsletters/2021/06/02/#bolts-672
[bcc#22051]: /ja/newsletters/2021/06/09/#bitcoin-core-22051
[lockin]: /ja/newsletters/2021/06/16/#taproot
[nsequence default]: /ja/newsletters/2021/06/16/#taproot-nsequence-bip
[cl#4591]: /ja/newsletters/2021/06/16/#c-lightning-4591
[p4tr]: /ja/preparing-for-taproot/
[bcc#21365]: /ja/newsletters/2021/06/23/#bitcoin-core-21365
[rb#601]: /ja/newsletters/2021/06/23/#rust-bitcoin-601
[p2trhd]: /ja/newsletters/2021/06/30/#p2tr
[bcc#22154]: /ja/newsletters/2021/06/30/#bitcoin-core-22154
[bcc#22166]: /ja/newsletters/2021/06/30/#bitcoin-core-22166
[p4tr begins]: /ja/newsletters/2021/06/23/#taprootの準備-1-bech32m送信のサポート
[bech32m page]: /ja/newsletters/2021/07/14/#bech32m
[bip118 update]: /ja/newsletters/2021/07/14/#bips-943
[bip119 update]: /ja/newsletters/2021/11/10/#bips-1215
[reuse risks]: /ja/newsletters/2021/08/25/#are-there-risks-to-using-the-same-private-key-for-both-ecdsa-and-schnorr-signatures-ecdsa-schnorr
[btcpay taproot]: /ja/newsletters/2021/09/15/#btcpay-server-2830
[op_tluv]: /ja/newsletters/2021/09/15/#covenant-opcode-proposal-covenant-opcode
[rb#563]: /ja/newsletters/2021/10/06/#rust-bitcoin-563
[rb#644]: /ja/newsletters/2021/10/06/#rust-bitcoin-644
[testing taproot]: /ja/newsletters/2021/10/20/#testing-taproot-taproot
[expanded test vectors]: /ja/newsletters/2021/11/03/#taproot-test-vectors-taproot-test-vector
[taproot activation]: /ja/newsletters/2021/11/17/#taproot
[rb#691]: /ja/newsletters/2021/11/17/#rust-bitcoin-691
[cbf verification]: /ja/newsletters/2021/11/10/#compact-block-filter
[lnd#5709]: /ja/newsletters/2021/10/27/#lnd-5709
[bitcoin core 0.21.0]: /ja/newsletters/2021/01/20/#bitcoin-core-0-21-0
[eclair 0.5.0]: /en/newsletters/2021/01/06/#eclair-0-5-0
[rust bitcoin 0.26.0]: /ja/newsletters/2021/01/20/#rust-bitcoin-0-26-0
[lnd 0.12.0-beta]: /ja/newsletters/2021/01/27/#lnd-0-12-0-beta
[hwi 2.0.0]: /ja/newsletters/2021/03/17/#hwi-2-0-0
[c-lightning 0.10.0]: /ja/newsletters/2021/04/07/#c-lightning-0-10-0
[btcpay server 1.1.0]: /ja/newsletters/2021/05/05/#btcpay-1-1-0
[eclair 0.6.0]: /ja/newsletters/2021/05/26/#eclair-0-6-0
[lnd 0.13.0-beta]: /ja/newsletters/2021/06/23/#lnd-0-13-0-beta
[bitcoin core 22.0]: /ja/newsletters/2021/09/15/#bitcoin-core-22-0
[bdk 0.12.0]: /ja/newsletters/2021/10/20/#bdk-0-12-0
[lnd 0.14.0]: /ja/newsletters/2021/11/24/#lnd-0-14-0-beta
[bdk 0.14.0]: /ja/newsletters/2021/12/08/#bdk-0-14-0
[csb]: /ja/newsletters/2021/06/02/#candidate-set-based-csb
[rbf default]: /ja/newsletters/2021/06/23/#allowing-transaction-replacement-by-default
[nseq default]: /ja/newsletters/2021/06/16/#taproot-nsequence-bip
[bcc#20833]: /ja/newsletters/2021/06/02/#bitcoin-core-20833
[ff expanded]: /ja/newsletters/2021/06/09/#receiving-ln-payments-with-a-mostly-offline-private-key-ln
[cl#4639]: /ja/newsletters/2021/07/28/#c-lightning-4639
[descriptor bips1]: /ja/newsletters/2021/07/07/#output-script-descriptor-bip
[descriptor bips2]: /ja/newsletters/2021/09/08/#bips-1143
[descriptor default]: /ja/newsletters/2021/10/27/#bitcoin-core-23002
[descriptor gist]: https://gist.github.com/sipa/e3d23d498c430bb601c5bca83523fa82/
[0conf channels]: /ja/newsletters/2021/07/07/#zero-conf-channel-opens
[sighash combo]: /ja/newsletters/2021/07/14/#bips-943
[fi bonds]: /ja/newsletters/2021/08/11/#implementation-of-fidelity-bonds-fidelity-bond
[0base]: /ja/newsletters/2021/08/25/#zero-base-fee-ln-discussion-ln
[newsletters]: /ja/newsletters/
[topics index]: /en/topics/
[additive batching]: /ja/cardcoins-rbf-batching/
[zmn guest]: /ja/newsletters/2021/09/01/#taprootの準備-11-lnとtaproot
[darosior guest]: /ja/newsletters/2021/09/08/#taprootの準備-12-vaultとtaproot
[heritage identifiers]: /ja/newsletters/2021/10/06/#proposal-for-transaction-heritage-identifiers
[ptlcs extreme]: /ja/newsletters/2021/10/13/#multiple-proposed-ln-improvements-ln
[2018 ln summit]: /en/newsletters/2018/11/20/#feature-news-lightning-network-protocol-11-goals
[2021 ln summit]: /ja/newsletters/2021/11/10/#ln-summit-2021
[stuckless payments]: /en/newsletters/2019/07/03/#stuckless-payments
[bcc#19953]: /en/newsletters/2020/10/21/#bitcoin-core-19953
[lnd#5025]: /ja/newsletters/2021/06/02/#lnd-5025
[signet reorgs]: /ja/newsletters/2021/09/15/#signet-reorg-discussion-signet-reorg
[bech32 bip]: /ja/newsletters/2021/01/13/#bech32m
[offers stuck]: /ja/newsletters/2021/04/21/#using-ln-offers-to-partly-address-stuck-payments-ln-offer
[news128 akka]: /en/newsletters/2020/12/16/#eclair-1566
[news123 watchdog]: /en/newsletters/2020/11/11/#eclair-1545
[news53 lightning loop]: /en/newsletters/2019/07/03/#lightning-loop-supports-user-loop-ins
[semantic versioning website]: https://semver.org/
[fido2 website]: https://fidoalliance.org/fido2/fido2-web-authentication-webauthn/
[news164 ping]: /ja/newsletters/2021/09/01/#lnd-5621
[news157 db]: /ja/newsletters/2021/07/14/#lnd-5447
[news170 path]: /ja/newsletters/2021/10/13/#lnd-5642
[news172 pool]: /ja/newsletters/2021/10/27/#lnd-5709
[news173 amp]: /ja/newsletters/2021/11/03/#lnd-5803
[bcc#22364]: /ja/newsletters/2021/12/01/#bitcoin-core-22364
[ln ptlcs]: /ja/newsletters/2021/12/15/#pltc-ln
[anyprevout proposed]: /en/newsletters/2019/05/21/#proposed-anyprevout-sighash-modes
[cl#4489]: /ja/newsletters/2021/05/12/#c-lightning-4489
[cl#4410]: /ja/newsletters/2021/03/17/#c-lightning-4404
[bip125 discrep]: /ja/newsletters/2021/05/12/#cve-2021-31876-discrepancy-between-bip125-and-bitcoin-core-implementation-cve-2021-31876-bip125-bitcoin-core
[wiki contract]: https://en.bitcoin.it/wiki/Contract#Example_1:_Providing_a_deposit
[cl#4771]: /ja/newsletters/2021/10/27/#c-lightning-4771
[fee bump research]: /ja/newsletters/2021/12/08/#fee-bumping-research
[nov cs]: /ja/newsletters/2021/11/17/#サービスとクライアントソフトウェアの変更
[dec cs]: /ja/newsletters/2021/12/15/#サービスとクライアントソフトウェアの変更
[mpa ml]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019464.html
[ff orig]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-April/001986.html
[2020 conclusion]: /en/newsletters/2020/12/23/#conclusion
