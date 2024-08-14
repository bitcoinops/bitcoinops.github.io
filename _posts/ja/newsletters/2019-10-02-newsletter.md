---
title: 'Bitcoin Optech Newsletter #66'
permalink: /ja/newsletters/2019/10/02/
name: 2019-10-02-newsletter-ja
slug: 2019-10-02-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、ノードがErlayトランザクションリレープロトコルを実装できるようにするBIPの内容、古いバージョンのライトニング実装に影響する脆弱性の開示内容、最近のOptech schnorrおよびtaprootワークショップのトランスクリプトへのリンク、フィールドレポートBitcoin Exchange BTSEがブロックチェーンスペースを節約し、ユーザーの入金の安全性を確保するために使用している技術の一部について紹介します。また、Bitcoinインフラストラクチャプロジェクトに対するいくつかの注目すべき変更点についても説明します。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

*今週は特になし。*

## News

- **Erlay互換性を有効にするためのBIPドラフト:** [reconciliationによるトランザクションリレーのBIPドラフト][bip-reconcil]が[Erlay][]の共著者であるGleb NaumenkoによってBitcoin-Devメーリングリストに[投稿][reconcil post] されました。現在、ビットコインノードは、新しく表示されたすべてのトランザクションのtxidを各ピアに送信します。その結果、各ノードは、多くの重複したtxidアナウンスを受信します。1日に数万のノード間で数十万トランザクションがやり取りされるビットコインにとっては帯域幅の効率が非常に悪い場合があります。
この問題を[以前のNewsletter][erlay paper],で記載した通り、 minisketch-based set reconciliationが解消します。各ノードは短いtxidのセットのsketchを送信できます。受信ピアは、それと自身がすでに知っている短いtxidと組み合わせることで自身が保持していないtxidを知ることが可能になります。
sketchのサイズは、取得する必要があるtxidのサイズとほぼ等しく、txidアナウンスの帯域幅を削減します。 Erlayは、このメカニズムを使用して帯域幅効率とネットワークの堅牢性の最適な組み合わせを実現する方法を提案する提案です。このドラフトBIPでは、ノード間のminisketchベースのセット調整の実装案について記述しており、Erlayの実装のベースとなるでしょう。フィードバックをお持ちの方は誰でも、BIP作成者に個人的に、またはメーリングリストで連絡することをお勧めします。


- **複数のLN実装に影響する修正された脆弱性の開示内容:** 数週間前、C-Lightning、Eclair、およびLNDの開発者は、最近のリリースで修正された未公開の問題の発見について発表しました。当時、彼らはユーザーにアップグレードすることを強く奨励し（[以前のOptech Newsletter][optech ln warning]参照）将来的にはその内容開示を約束し、現在は、発見者でありC-Lightning開発者であるRusty Russellによる[メール][russell disclosure] および、LND開発者であるOlaoluwa OsuntokunおよびConner Fromknechtによる[ブログ][lnd stay safe]により開示がされています。

    簡潔に説明すると、チャネルオープンの際のトランザクションが正しいスクリプト、金額であるチェックが実装されていなかったことが問題のようです。このため、オンチェーンで実際は確認することができない支払いを受け入れられてしまい、詐欺が可能になっておりました。この記事の執筆時点では、Optechは先月の警告の前にこの問題が悪用されたという報告を認識していません。この問題が公開に伴い[PR][BOLTS #676] が公開され、このチェックが必要であることを示す仕様が更新されました。

- **Optech taproot and schnorr ワークショップ:** 先週、Optechはサンフランシスコとニューヨーク市で、Schnorr署名スキームと、提案された[taproot][bip-taproot] ソフトフォークなどについて開発者向けのワークショップを開催しました。ニューヨークでのワークショップの[トランスクリプト][workshop transcript]を作成してくれたBryan Bishopに感謝します。我々は近い将来、ブログを通じてビデオやその他の教材を公開する予定です。

## 注目すべきコードとドキュメントの変更点

*[Bitcoin Core][bitcoin core repo],[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals(BIPs)][bips repo], および [Lightning BOLTs][bolts repo]における注目すべき変更点
*

- [Bitcoin Core #15558][] は、Bitcoin Coreが照会するDNS Seedの数を変更します。DNS Seedは、リスンしているピア（接続を受け入れるピア）のIPアドレスを返すサーバーです。新しく起動されたノードは、DNS Seedを照会して、ピアの初期セットを見つけます。それらのピアは、他の可能なピアについてノードに通知し、ノードはこの情報を後で使用するためにディスクに保存します（再起動後を含む）。理想的には、ノードがDNSシードを照会するのは、それらが最初に開始されたときに1回だけです。実際には、選択した保存済みピアのいずれも十分に迅速に応答しない場合などに後続のスタートアップでクエリを実行することもあります。

    このマージにより、Bitcoin Coreは、すべてではなく、一度に3つのDNSシードのみを照会します。3つのシードは、ノードが少なくとも1つ正直なピア（ビットコインセキュリティの要件として記述されています）に接続することを保証するためにはのに十分なソースの多様性が必要ですが、直接DNS解決を使用する場合、すべてのシードがクエリノードについて学習するわけではありません。照会するシードは、Bitcoin Coreにハードコーディングされたリストからランダムに選択されます。

- [LND #3523][] 3523で特定のオープンチャネルまたはすべてのオープンチャネルで受け入れるHTLCのリサット値の更新が可能になります。


- [LND #3505][] は、invoiceを7,092バイト（単一のQRコードに収まる最大サイズ）に制限します。invoiceが大きいと、大量のメモリが割り当てられる可能性があります。パッチの作成者がテストした1.7 MBの請求書では、約38.0 MBの割り当てが生成されました。


- [Eclair #1097][] は、funding pubkeyからchannel keysの導出を開始し、すべてのデータが失われた場合でもEclairが[ニュースレター＃31][dlp footnote] で説明されているData Loss Protection（DLP）スキームを使用できるようにします。これには、ユーザーがチャンネルを開いたノードをリコールし、チャンネルID（公開チャンネルの公開情報）を見つける必要があります。
これは、この変更を実装するソフトウェアのバージョンに更新した後に開かれた新しいチャネルにのみ適用されます。古いチャンネルは影響を受けません。 *(注：ニュースレター＃31では、このマージされたPRによってEclairがDLPサポートが追加可能となるであろうと記載していましたが、実際はEclairは既にDLPサポートを持ち、すべてのデータが失われた場合もサポート可能となっておりました。誤記を報告してくださったFabrice Drouinに感謝します。*）

- [C-Lightning #3057][] は、C-Lightningのデータベースマネージャーとしてpostgresの使用を可能にします。

- [C-Lightning #3064][] は、C-Lightningノードが他のノードからのチャネル更新アナウンスを中継する頻度を減らすために、[Newsletter #63][ln daily updates] で説明されている変更を行います。これにより、ノードが使用するゴシップ帯域幅が削減されます。

{% include linkers/issues.md issues="15558,3523,3505,1097,3057,3064,676" %}
[lnd stay safe]: https://blog.lightning.engineering/security/2019/09/27/cve-2019-12999.html
[dlp footnote]: /en/newsletters/2019/01/29/#fn:fn-data-loss-protect
[ln daily updates]: /en/newsletters/2019/09/11/#request-for-comments-on-limiting-ln-gossip-updates-to-once-per-day
[bip-reconcil]: https://github.com/naumenkogs/bips/blob/bip-reconcil/bip-reconcil.mediawiki
[reconcil post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-September/017323.html
[erlay paper]: /en/newsletters/2019/06/05/#erlay-proposed
[optech ln warning]: /en/newsletters/2019/09/04/#upgrade-ln-implementations
[workshop transcript]: http://diyhpl.us/wiki/transcripts/bitcoinops/schnorr-taproot-workshop-2019/notes/
[russell disclosure]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002174.html
[erlay]: https://arxiv.org/pdf/1905.10518.pdf
