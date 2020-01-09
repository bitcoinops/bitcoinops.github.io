---
title: 'Bitcoin Optech Newsletter #76'
permalink: /ja/newsletters/2019/12/11/
name: 2019-12-11-newsletter-ja
slug: 2019-12-11-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、LNDの新しいメンテナンス・リリースの発表、eltooペイメント・チャネル向けのWatchtowerに関するディスカッションのサマリー、主要なBitcoinインフラストラクチャー・プロジェクトに関する注目すべき変更についてお送りします。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **LND 0.8.2-beta RC2のテストのお願い:**この[リリース候補][lnd 0.8.2-beta]には、いくつかのバグ修正とUXのマイナーな改善が含まれており、最も重要なものはStatic channel backupsに関するものです。（これらの改善点の1つは、このニュースレターの後半で[説明][lnd-3698]します。）

## News

- **eltooペイメント・チャネル向けWatchtowers:**[eltoo][topic eltoo]は、LN向けに提案された代替のペイメント・チャネル・レイヤーであり、参加者がペナルティ・トランザクションを生成する必要はありません。[Watchtowers][topic watchtowers]は、Watchtowerの顧客のチャネルが古い状態を用いてクローズされた場合に、事前にプログラムされたトランザクションをブロードキャストするサービスです。これにより、顧客は資金を失うリスクを負うことなくオフラインになることが可能です。

   Conner Fromknechtは[スレッド][fromknecht eltoo tower]を開始し、Watchtowerがeltoo向けにどういったデータを保存する必要があるか、そしてそれらがWatchtowerのスケーラビリティや顧客のプライバシーにどのような影響があるのか質問をしています。１つのオプションは、Watchtowerが最新の更新トランザクションのみを保存することです。これは、チャネル毎に一定量のストレージしか必要としないため、非常にスケーラブルです。また、最終セトルメント・トランザクションのみが、最終更新トランザクションから消費されるため安全です。オフライン・ノードは、数ヶ月または数年後であっても、次にオンラインになった際に、セトルメント・トランザクションをブロードキャストできます。

   議論されているもう１つのオプションは、Watchtowerがセトルメント・トランザクションも保存することです。これにより、ノードの希望の払戻アドレス（コールド・ウォレットのアドレスなど）にファンドを送信することにより、オフライン中にノードがすべてのデータを失った場合の安全性が向上します。しかし、それはWatchtowerのストレージ要件を増やし、さらに悪いことにそれを実装するためには、Watchtowerにユーザーのペイメント・チャネルの過去のペイメントの詳細を知るのに十分なデータを与えることになり、ユーザーのプライバシーを大幅に失います。スレッドの一部の参加者は、プライバシーの損失を軽減しながら安全性の利点を得る方法について議論していますが、執筆時点では明確な結論に達しておりません。

## Notable code and documentation changes

*今週の[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[ビットコイン改善提案（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [C-Lightning #3260][]は、新しく`createonion`および`sendonion`RPCメソッドを追加し、外部ツールまたはC-Lightingプラグインが、ノード自体が必ずしも理解する必要のない暗号化されたLNメッセージを作成および送信できるようにします。PRで記載されている当メカニズムのユースケースは、cross-chain atomic swaps、rendez-vous routing（[Newsletter#22][rendez-vous routing]を参照）、[trampoline payments][topic trampoline payments]、[WhatSat][]と同様のchat-over-LNなどがあります。

- [C-Lightning #3295][]は、`listinvoices`RPCを拡張し、既に支払われたインボイスのペイメント・プリイメージを含む新しいフィールドを追加します。（ペイメントが完了する前にユーザーが誤ってプリイメージを共有することを防ぐため、未払いのインボイスにはプリイメージは表示されません。資金が失われる可能性があるからです）

- [C-Lightning #3155][]は、`--statictor`（static tor）コマンドライン・パラメーターを追加します 。これはユーザーが毎回アドレスを変更する一時的な隠しサービスとしてではなく、常に同じTor v3隠しサービスとして動作できるようにします。静的アドレスはノードの公開識別子（pubkey）から派生するため、ユーザーは追加アドレス情報を保存する必要はありません。その代わりにユーザーは`--torblob`パラメーターで静的アドレスを生成するためのエントロピーを指定します。

- [LND #3788][]は、[先週のニュースレター][payment secrets]で説明した「payment secret」と同じものである「payment addresses」のサポートを追加します。この追加により、[マルチパス支払い][topic multipath payments]の追加部分を受信することを期待している受信ノードへのプライバシーが削減される調査が防止可能になります（詳細は[先週のニュースレター][payment secrets]参照）。

- [LND #3767][]は、LNDが有効なbech32チェックサムを持つ不正な[BOLT11][]インボイスを受け入れないようにします。[以前に報告された][news72 bech32 mutability]ように、`p`で終わるbech32アドレスは、その`p`に先行する`q`文字の追加または削除を検出できません。この問題は、支払ノードがインボイスの末尾に追加された署名から受信ノードの公開鍵を復元するBOLT11インボイスによって悪化します。ここは、このタイプの検出されないbech32が発生しうる箇所です。このマージされたPRのコードコメントによると、「まれに（約3％）[the mutated signature]が有効な署名と見なされるため、公開鍵の復元により、本来意図されたノードとは異なるノードを検出します。」PRは、インボイスの最後のフィールドが予想される長さと一致しない場合、それを拒否することで問題を排除します。

- [LND #3698][]は、ユーザーがStatic channel backups（SCB）を復元しようとするときに警告を出力し、すべてのチャネルが閉じられることを確認します（オンチェーン・フィーが発生します）。`lncli`のユーザーは続行する前にそのプロンプトを確認する必要があります。

- [LND #3655][]は、[BOLT2][]の先行シャットダウン・スクリプトのサポートを追加します。このスクリプトでは、チャネルを開く前にノードの引き出し先アドレスが指定され、そのアドレスはチャネルの存続期間中ロックされます。ノードが後でペイメントを別のアドレスに送信するように要求した場合、相手方はその要求を拒否する必要があります。これにより、ノードを不正アクセスした攻撃者が、攻撃者のオンチェーン・ウォレットに資金を引き出すことが難しくなります（ただし、攻撃者は他の方法で資金を盗む可能性はあります）。

{% include linkers/issues.md issues="3260,3295,3155,3788,3767,3698,3655" %}
[lnd 0.8.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.8.2-beta-rc2
[lnd-3698]: #lnd-3698
[fromknecht eltoo tower]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002349.html
[whatsat]: https://github.com/joostjager/whatsat
[rendez-vous routing]: /en/newsletters/2018/11/20
[payment secrets]: /ja/newsletters/2019/12/04
[news72 bech32 mutability]: /ja/newsletters/2019/11/13
