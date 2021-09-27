---
title: 'Bitcoin Optech Newsletter #79'
permalink: /ja/newsletters/2020/01/08/
name: 2020-01-08-newsletter-ja
slug: 2020-01-08-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、オーガナイズされたtaproot reviewに関する最終週のまとめ、各インプットまたはアウトプットが同じ値であるという制約がないコインジョイン・ミキシングに関する議論の説明、エンドユーザー・インターフェイスにおけるoutput script descriptorsをエンコードする提案に関して言及しています。また、主要なBitcoinインフラストラクチャー・プロジェクトに関する注目すべき変更点に関する通常のセクションも含まれています。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- Bitcoin Optechは、2020年2月5日にロンドンで3回目のSchnorrとTaprootセミナーワークショップを開催する予定です。これは、前回の２つの[Schnorr/Taproot workshops][]と同じ内容をカバーします。これらのワークショップで用いる資料は家庭学習用に上記のウェブサイトから利用可能です。

  **エンジニアをワークショップに派遣したいメンバー企業は、[Optechまでご連絡ください][optech email]**。

## News

- **オーガナイズされたTaproot Reviewの最終週:** 12月17日は、taproot reviewグループの最後の[ミーティング][taproot meeting]でした。Pieter Wuilleは、「ほぼ準備ができている」と考えていることを示すテキストを含め、進行状況を要約したプレゼンテーションから[スライド][wuille slides]を投稿しました。また、Wuilleはtapleafのバージョン管理に[軽微な変更][wuille suggestion]を提案しました。また、taprootが改善されたプライバシーとスケーラビリティを提供するためにどのようにLNに統合されるか、Lightning-DevメーリングリストでZmnSCPxjによって開始された[ディスカッション][zmn post]についても簡単に言及しました。

- **<!--coinjoins-without-equal-value-inputs-or-outputs-->各インプットまたはアウトプットの値が等しいわけではないコインジョイン:** Adam Ficsor（nopara73）は、Bitcoin-Devメーリングリストで、等しい値のインプット群またはアウトプット群を用いないコインジョインに関する以前に発行された2つの論文（[1][cashfusion]、[2][knapsack]）について[議論][ficsor non-equal]を開始しました。以前の等しくない値のミキシングの試みは[危殆化しやすい][coinjoin sudoku]ものでしたが、改善された方法が見つかった場合、トランザクションを[支払いバッチ処理][topic payment batching]のように見せることにより、コインジョインのプライバシーを大幅に改善できます。これは、ある大手取引所がWasabi Walletによって作成されたchaumianスタイルのコインジョインに参加しているユーザーを調査しているという報告があるため、特に関連しているように思われます。いくつかのアイディアが議論されましたが、Lucas Ontiveroによる[要約][ontivero summary]は、全体的な結論の本質を捉えていると思います：「要約すると、等しい値のインプット群またはアウトプット群を用いないコインジョインにおいては[knapsack][]は現時点でベストなものです(「しかし」それは等出力トランザクションほど効果的ではありません。)」

- **<!--encoded-descriptors-->エンコードされた記述子:** Chris Belcherは、Base64エンコーディング[出力スクリプト記述子][topic descriptors]を利用して、コピーとペーストが容易になるように（そして通常のユーザがコードのような構文に触れずにすむ）Bitcoin-Devメーリングリストからのフィードバックについて[依頼][belcher descriptors]しました。少なくとも1つの返信がアイデアに反対し、他の返信はそれぞれ異なるエンコード形式を提案したアイデアをサポートしていました。現時点で本議論は、明確な結論には至っておりません。

## Notable code and documentation changes

*今週の[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[ビットコイン改善提案
（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]に関する注目すべき変更点。*

- [C-Lightning #3351][]は、`invoice`RPCを拡張して新しいパラメータ`exposeprivatechannels`を追加します。これは生成された[BOLT11][]インボイスへのプライベート・チャネルのルートヒントの追加をユーザーが要求できるオプションで、ユーザはパブリック・チャネルとプライベート・チャネルの両方を含む、どちらのチャネルにインボイスで通知したいかを指定できます。

- [LND #3647][]は、`listinvoices`RPCにおけるバイナリーデータの表示をbase64から16進数に切り替えます。これはユーザにとってAPIの大幅変更になります。

- [LND #3814][]は、UTXO sweeperがウォレットインプットをスイープトランザクションに追加して、その出力がダスト制限を満たしていることを確認できるようにします。これは、提案されたアンカーアウトプット機能（[Newsletter#70][news70 anchor]を参照）のサポートに役立つように設計されています。アンカーアウトプット機能は、より小額のUTXOを使用できるようにトランザクションにインプットを追加する必要があります。

{% include linkers/issues.md issues="3647,3814,3351" %}
[Schnorr/Taproot workshops]: /ja/schorr-taproot-workshop/
[wuille slides]: https://prezi.com/view/AlXd19INd3isgt3SvW8g/
[wuille suggestion]: http://www.erisian.com.au/meetbot/taproot-bip-review/2019/taproot-bip-review.2019-12-17-19.01.log.html#l-8
[zmn post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-December/002375.html
[ficsor non-equal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-December/017538.html
[cashfusion]: https://github.com/cashshuffle/spec/blob/master/CASHFUSION.md
[knapsack]: https://www.comsys.rwth-aachen.de/fileadmin/papers/2017/2017-maurer-trustcom-coinjoin.pdf
[coinjoin sudoku]: http://www.coinjoinsudoku.com/
[belcher descriptors]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-December/017529.html
[news70 anchor]: /en/newsletters/2019/10/30/#ln-simplified-commitments
[taproot meeting]: http://www.erisian.com.au/meetbot/taproot-bip-review/2019/taproot-bip-review.2019-12-17-19.01.html
[ontivero summary]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-December/017544.html
