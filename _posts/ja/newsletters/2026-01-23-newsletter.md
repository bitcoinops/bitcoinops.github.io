---
title: 'Bitcoin Optech Newsletter #389'
permalink: /ja/newsletters/2026/01/23/
name: 2026-01-23-newsletter-ja
slug: 2026-01-23-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、ペイメントチャネルネットワークの研究に関する論文のリンクを掲載しています。
また、サービスとクライアントソフトウェアの最新アップデート、新しいリリースとリリース候補の発表、
人気のBitcoin基盤ソフトウェアの注目すべき更新など、恒例のセクションも含まれています。

## ニュース

- **<!--a-mathematical-theory-of-payment-channel-networks-->ペイメントチャネルネットワークの数学的理論**: René Pickhardtは、
  「A Mathematical Theory of Payment Channel Network」と題した新しい[論文][channels paper]の公開について
  Delving Bitcoinに[投稿しました][channels post]。この論文でPickhardtは、長年の研究を通じて得られた複数の観察結果を
  単一の幾何学的枠組みの下にまとめています。特にこの論文は、チャネルの枯渇（[ニュースレター #333][news333 depletion]参照）や
  2者間のチャネルの資本効率性といった一般的な現象を分析し、
  それらがどのように相互に関連しているのか、またなぜそうなるのかを評価することを目的としています。

  論文の主な貢献は以下のとおりです:

  - チャネルグラフが与えられたライトニングネットワーク上のユーザーの実現可能な資産分布のモデル

  - 支払いの帯域幅の上限を推定するための公式

  - <!---->
  支払いが実現可能である可能性を推定する方法（[ニュースレター #309][news309 feasibility]参照）

  - <!---->
  チャネル枯渇に対するさまざまな[緩和戦略][mitigation post]の分析

  - 2者間のチャネルは、ネットワークのピア間の流動性の流れに強い制約を課すという結論

  Pickhardtによると、研究から得られた洞察が、Arkをチャネルファクトリーとして使用することについての
  最近の投稿（[ニュースレター #387][new387 ark]参照）の動機となったとのことです。
  Pickhardtはまた、研究の基盤として使用したコード、ノートブック、論文の[コレクション][pickhardt gh]も提供しました。

  最後に、Pickhardtは自身の研究がプロトコル設計にどのような影響を与えうるか、
  またマルチパーティチャネルの最適な活用法について、LN開発者コミュニティからの質問やフィードバックを求めて
  議論をオープンにしました。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **サイレントペイメントのテスト用のElectrumサーバー:**
  [Frigate Electrum Server][frigate gh]は、[BIP352][]の[リモートスキャナー][bip352
  remote scanner]サービスを実装し、クライアントアプリケーションに
  [サイレントペイメント][topic silent payments]のスキャン機能を提供します。
  Frigateはスキャン時間を短縮するために最新のGPU計算も使用しており、
  多数の同時スキャンリクエストを処理するマルチユーザーインスタンスの提供にも役立ちます。

- **BDK WASMライブラリ:**
  [bdk-wasm][bdk-wasm gh]ライブラリは、もともとMetaMask組織によって開発・[使用されて][metamask
  blog]いたもので、WebAssembly (WASM)をサポートする環境でBDKの機能へのアクセスを提供します。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Core Lightning 25.12.1][]は、v25.12で作成されたノードが、
  非[P2TR][topic taproot]アドレスに送金された資金を使用できないという重大なバグ（下記参照）を修正したメンテナンスリリースです。
  また、v25.12で導入された新しいニーモニックベースの`hsm_secret`フォーマット（[ニュースレター #388][news388 cln]参照）における
  リカバリおよび`hsmtool`の互換性の問題も修正しています。

- [LND 0.20.1-beta.rc1][]は、ゴシップメッセージ処理のpanicリカバリーの追加、
  再編成（reorg）保護の改善、LSP検出ヒューリスティックの実装、
  複数のバグと競合状態の修正を含むマイナーバージョンのリリース候補です。
  詳細は[リリースノート][release notes]をご覧ください。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #32471][]は、`private=true`パラメーターを指定して
  `listdescriptors` RPCを呼び出した際（ニュースレター[#134][news134 descriptor]および
  [#162][news162 descriptor]参照）、いずれかの[ディスクリプター][topic
  descriptors]に秘密鍵が欠けていると失敗するバグを修正しました。この問題は、
  非監視専用と監視専用の両方のディスクリプターを含むウォレットおよび、
  すべての秘密鍵を持たないマルチシグディスクリプターに影響していました。このPRにより、
  RPCは利用可能な秘密鍵を正しく返すようになり、ユーザーが適切にバックアップできるようになりました。
  厳密には、監視専用ウォレットで`listdescriptors private=true`を呼び出すと失敗します。

- [Bitcoin Core #34146][]は、ノードの最初の自己アナウンスを自身のP2Pメッセージで送信することで、
  アドレスの伝播を改善します。これまでは、自己アナウンスはピアの`getaddr`要求への応答として
  複数の他のアドレスにバンドルされていたため、破棄されたり他のアドレスが置き換えられたりする可能性がありました。

- [Core Lightning #8831][]は、v25.12で作成されたノードが
  非[P2TR][topic taproot]アドレスに送金された資金を利用できないという重大なバグを修正しました。
  これらのノードではすべてのアドレスタイプが[BIP86][]に基づいて導出されていましたが、
  署名コードはP2TRアドレスに対してのみ[BIP86][]を使用していました。このPRにより、
  すべてのアドレスタイプで署名に[BIP86][]導出が使用されるようになります。

- [LDK #4261][]は、同一トランザクション内でスプライス・インとスプライス・アウトを同時に行える
  ミックスモード[スプライシング][topic splicing]をサポートしました。ファンディングインプットは、
  スプライス・インの場合と同様に適切な手数料を支払います。スプライス・アウトされる金額が、
  スプライス・インされる金額より多い場合、正味の金額はマイナスになる可能性があります。

- [LDK #4152][]は、[ブラインド][topic rv routing]ペイメントパスにダミーホップをサポートしました。
  これは[ニュースレター #370][news370 dummy]で追加されたブラインドメッセージパスの機能と並行しています。
  ホップを追加すると、受信ノードまでの距離やIDの特定が大幅に困難になります。
  これを可能にする以前の作業については[ニュースレター #381][news381 dummy]をご覧ください。

- [LND #10488][]は、`fundMax`オプション（[ニュースレター #246][news246 fundmax]参照）を使って開設されたチャネルが、
  ユーザー設定の`maxChanSize`設定（[ニュースレター #116][news116 maxchan]参照）によってサイズが制限されるバグを修正しました。
  この設定は本来、受信チャネルリクエストのみを制限することを意図したものです。このPRにより、
  `fundMax`オプションは、ユーザーとピアが[ラージチャネル][topic large channels]をサポートしているかどうかに応じて、
  プロトコルレベルの最大チャネルサイズを使用するようになりました。

- [LND #10331][]は、チャネルサイズに基づいてスケールする承認要件を使用することで、
  チャネルの閉鎖がブロックチェーンの再編成を処理する方法を改善しました。
  最小は1承認で、最大は6承認です。チェーンウォッチャーは、ブロックチェーンの再編成をより適切に検出し、
  そのようなシナリオで競合するチャネルクローズトランザクションを追跡するためのステートマシンの導入により刷新されました。
  このPRはまた、ネガティブな承認（承認済みトランザクションが後で再編成により取り消される場合）の監視を追加しましたが、
  それらの処理方法は未解決のままです。このPRは、2016年からのLNDの[最も古い課題][lnd issue]に対処するものです。

- [Rust Bitcoin #5402][]は、[CVE-2018-17144][topic cve-2018-17144]に関連して、
  重複するインプットを持つトランザクションを拒否するためのデコード時の検証を追加しました。
  同じアウトポイントを使用する複数のインプットを含むトランザクションは、コンセンサスにより無効です。

- [BIPs #1820][]は、`Deployed`ステータスで[BIP3][]を更新し、
  BIP（Bitcoin Improvement Proposal）プロセスのガイドラインとして[BIP2][]を置き換えました。
  詳細は、[ニュースレター #388][news388 bip3]をご覧ください。

- [BOLTs #1306][]は、[BOLT12][]仕様において、`offer_chains`フィールドが空の[オファー][topic
  offers]は拒否しなければならないことを明確化しました。このフィールドが存在するものの、
  チェーンハッシュが含まれていないオファーの場合、支払人が`invreq_chain`を
  `offer_chains`のいずれかに設定するという要件を満たせないため、インボイスリクエストが不可能になります。

- [BLIPs #59][]は、（LSPS1としても知られる）[BLIP51][]を更新し、
  既存の[BOLT11][]およびオンチェーンオプションに加えて、LSP（Lightning Service
  Provider）への支払いのオプションとして[BOLT12オファー][topic offers]のサポートを追加しました。
  これは以前LDKで実装されています（[ニュースレター #347][news347 lsp]参照）。

{% include snippets/recap-ad.md when="2026-01-27 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32471,34146,8831,4261,4152,10488,10331,5402,1820,1306,59" %}

[channels post]: https://delvingbitcoin.org/t/a-mathematical-theory-of-payment-channel-networks/2204
[channels paper]: https://arxiv.org/pdf/2601.04835
[news309 feasibility]: /ja/newsletters/2024/06/28/#ln
[mitigation post]: https://delvingbitcoin.org/t/mitigating-channel-depletion-in-the-lightning-network-a-survey-of-potential-solutions/1640/1
[news333 depletion]: /ja/newsletters/2024/12/13/#insights-into-channel-depletion
[new387 ark]: /ja/newsletters/2026/01/09/#ark
[pickhardt gh]: https://github.com/renepickhardt/Lightning-Network-Limitations
[frigate gh]: https://github.com/sparrowwallet/frigate
[bip352 remote scanner]: https://github.com/silent-payments/BIP0352-index-server-specification/blob/main/README.md#remote-scanner-ephemeral
[bdk-wasm gh]: https://github.com/bitcoindevkit/bdk-wasm
[metamask blog]: https://metamask.io/news/bitcoin-on-metamask-btc-wallet
[Core Lightning 25.12.1]: https://github.com/ElementsProject/lightning/releases/tag/v25.12.1
[LND 0.20.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.1-beta.rc1
[news388 cln]: /ja/newsletters/2026/01/16/#core-lightning-8830
[release notes]: https://github.com/lightningnetwork/lnd/blob/v0.20.x-branch/docs/release-notes/release-notes-0.20.1.md
[news134 descriptor]: /ja/newsletters/2021/02/03/#bitcoin-core-20226
[news162 descriptor]: /ja/newsletters/2021/08/18/#bitcoin-core-21500
[news370 dummy]: /ja/newsletters/2025/09/05/#ldk-3726
[news381 dummy]: /ja/newsletters/2025/11/21/#ldk-4126
[news246 fundmax]: /ja/newsletters/2023/04/26/#lnd-6903
[news116 maxchan]: /en/newsletters/2020/09/23/#lnd-4567
[lnd issue]: https://github.com/lightningnetwork/lnd/issues/53
[news388 bip3]: /ja/newsletters/2026/01/16/#bip
[news347 lsp]: /ja/newsletters/2025/03/28/#ldk-3649