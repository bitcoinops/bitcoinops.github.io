---
title: 'Bitcoin Optech Newsletter #382'
permalink: /ja/newsletters/2025/11/28/
name: 2025-11-28-newsletter-ja
slug: 2025-11-28-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---

今週のニュースレターでは、コンパクトブロック再構築に関する議論の最新情報と、
BIP3のアクティベートの要請を掲載しています。また、Bitcoin Stack Exchangeでよくある質問とその回答や、
新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき更新など
恒例のセクションも含まれています。

## ニュース

- **<!--stats-on-compact-block-reconstructions-updates-->コンパクトブロック再構築に関する統計の更新:**
  0xB10Cは、コンパクトブロック再構築に関する統計について（ニュースレター[#315][news315 cb]および[#339][news339 cb]参照）、
  Delving Bitcoinにその更新を[投稿しました][0xb10c delving]。
  0xB10Cはコンパクトブロック再構築について3つ更新情報を提供しています。

  - <!-- -->
    David Gumbergからの[以前のフィードバック][news365 cb]に応えて、
    要求されたトランザクションの平均サイズ（kB単位）の追跡を始めました。

  - <!-- -->
    自身のノードの1つを[Bitcoin Core #33106][news368 minrelay]で引き下げられた`minrelayfee`設定を適用し、更新後、
    そのノードのブロック再構築率は大幅に改善しました。また、要求されたトランザクションの平均サイズズ（kB単位）にも改善が見られました。

  - その後、他のノードも`minrelayfee`を引き下げて実行するように切り替えたことで、
    ほとんどのノードで再構築率が向上し、ピアに要求するデータ量が減少しました。
    彼はまた、後から考えると、すべてのノードをアップデートせず、一部のノードをv29のままにしておけば、
    ノードのバージョンや設定の比較が容易になっただろうと[述べています][0xb10c third update]。

  全体として、`minrelayfee`の廃止により、ブロック再構築率が向上し、ピアに要求されるデータも減少しました。

- **BIP3のアクティベーション動議**: Murchは、[BIP3][]（[ニュースレター #341][news341 bip3]参照）を
  アクティベートするための正式な動議をBitcoin-Devメーリングリストに[投稿しました][murch ml]。
  この改善提案の目的は、新しいBIPを準備するための新しいガイドラインを提供し、
  現在の[BIP2][]プロセスを置き換えることです。

  作者によると、7ヶ月以上「Proposed」ステータスにあるこの提案には、未対応の異議はなく、
  [BIPs #1820][]上ではコントリビューターによるACKが増え続けています。
  そのため、プロセスBIPをアクティベートするためにBIP2で規定された手順に従い、
  彼は2025年12月2日までの4週間の猶予を与え、その期間内に提案を評価し、PRにACKを付けるか、
  懸念を表明して異議を唱えるためようにしました。この期限以降、BIPプロセスはBIP2に代わりBIP3になります。

  スレッドでは、主にBIP提出プロセスにおけるAI/LLMツールの使用に関する（[ニュースレター #378][news378 bips2006]参照）
  軽微な異議がいくつか定期されており、作者は現在この課題に対応中です。
  Optechの読者には、この提案に目を通してフィードバックの提供をお願いします。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [プルーニングされたノードはwitness inscriptionを保存しますか？]({{bse}}129197)
  Murchは、プルーニングされたノードは古いブロックが最終的に破棄されるまで、
  witnessデータを含むすべてのブロックデータを保持すると説明しています。
  彼はさらに、inscriptionスキームよりもOP_RETURNを使用するトレードオフについて概説しています。

- [<!--increasing-probability-of-block-hash-collisions-when-difficulty-is-too-high-->難易度が高すぎる場合のブロックハッシュの衝突確率の上昇]({{bse}}129265)
  Vojtěch Strnadは、ブロックハッシュの衝突は（SHA256が破られない限り）極めて起こりにくいことを指摘し、
  ブロックヘッダーのハッシュがブロック識別子として機能する理由を説明しています。

- [<!--what-is-the-purpose-of-the-initial-0x04-byte-in-all-extended-public-and-private-keys-->すべての拡張公開鍵と拡張秘密鍵の先頭バイト0x04の目的は何ですか？]({{bse}}129178)
  Pieter Wuilleは、これらの0x04プレフィックスは、それぞれの対象のBase58エンコーディングに基づく単なる偶然であると指摘しています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [LND v0.20.0-beta][]は、この人気のLNノード実装のメジャーリリースで、
  複数のバグ修正や、新しいNoopAdd[HTLC][topic htlc]タイプ、
  [BOLT11][]インボイスにおける[P2TR][topic taproot]フォールバックアドレスのサポート、
  多くのRPCおよび`lncli`機能の追加と改善が含まれています。詳しくは[リリースノート][lnd notes]をご覧ください。

- [Core Lightning v25.12rc1][]は、この主要なLNノード実装の新しいバージョンのリリース候補で、
  新しいバックアップ方法として[BIP39][]ニーモニックシードフレーズの追加や、
  `xpay`の改善、ピアのすべてのチャネルを優先または非優先にする`askrene-bias-node`RPCコマンド、
  ピアに関する情報にアクセスするための`networkevents`、
  実験的な[JITチャネル][topic jit channels]サポート用の`experimental-lsps-client`および
  `experimental-lsps2-service`オプションが追加されています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #33872][]は、以前非推奨にされた`-maxorphantx`オプション（[ニュースレター #364][news364 orphan]参照）を削除します。
  このオプションを使用すると起動に失敗します。

- [Bitcoin Core #33629][]は、mempoolをクラスターに分割することで、
  [クラスターmempool][topic cluster mempool]の実装を完了します。クラスターは、
  デフォルトで101 kvBおよび64トランザクションに制限されます。各クラスターは、
  手数料順のチャンク（サブクラスターの手数料順のグループ）に線形化されます。
  これにより手数料の高いチャンクが最初にブロックテンプレートに含まれ、
  mempoolがいっぱいになった際に手数料の低いチャンクが最初に削除されます。
  このPRは、[CPFP carve out][topic cpfp carve out]ルールと祖先/子孫の制限を削除し、
  トランザクションリレーを更新して高い手数料率のチャンクを優先するようにします。
  最後に、[RBF][topic rbf]ルールを更新し、置換により新しい未承認インプットを導入できないという制限を削除し、
  手数料率ルールはクラスター全体の手数料率ダイアグラムが改善することを要求するように変更され、
  直接競合の制限は直接競合するクラスター制限に置き換えられます。

- [Core Lightning #8677][]は、RPCコマンドとプラグインコマンドの同時処理数を制限し、
  読み取り専用コマンドの不要なデータベーストランザクションを削除し、
  データベースクエリを再構築して数百万件の`chainmoves`/`channelmoves`イベントをより効率的に処理できるようにすることで、
  大規模ノードのパフォーマンスを大幅に向上させます。このPRでは、
  `rpc_command`および`custommsg`フックに`filters`オプションも導入され、
  `xpay`、`comando`、`chanbackup`のようなプラグインが特定の呼び出し時のみ登録できるようになりました。

- [Core Lightning #8546][]は、`fundchannel_complete`に`withhold`オプション（デフォルトはfalse）を追加します。
  このオプションは、`sendpsbt`が呼び出されるかチャネルが閉じられるまで、
  チャネルファンディングトランザクションのブロードキャストを遅延させます。
  これにより、LSPはユーザーがネットワーク手数料をカバーするのに十分な資金を提供するまでチャネルの開設を延期できます。
  これは、[JITチャネル][topic jit channels]で`client-trusts-lsp`モードを有効にするために必要です。

- [Core Lightning #8682][]は、[ブラインドパス][topic rv routing]の構築方法を更新し、
  仕様で要求していない場合も、`option_route_blinding`に加えて、
  ピアが[`option_onion_messages`][topic onion messages]機能を有効にしていることを要求するようにします。
  これにより、この機能が有効になっていないLNDノードが[BOLT12][topic offers]支払いの転送に失敗する問題が解決します。

- [LDK #4197][]は、再接続後にピアの`channel_reestablish`メッセージに応答するために、
  `ChannelManager`に最新の2つの取り消されたコミットメントポイントをキャッシュします。
  これにより、相手方が最大で1コミットメント分高さが前の状態である場合に、
  潜在的にリモートの署名者からポイントをフェッチしてステートマシンを一時停止するのを回避できます。
  ピアが異なる状態を提示した場合、署名者はコミットメントポイントを検証し、
  状態が有効な場合はLDKがクラッシュし、無効な場合はチャネルを強制的に閉鎖します。
  `channel_reestablish`に関するLDKの以前のアップデートについては、
  ニュースレター[#335][news335 ldk]、[#374][news374 ldk]および[#371][news371 ldk]をご覧ください。

- [LDK #4234][]は、`ChannelDetails`イベントと`ChannelPending`イベントにファンディングredeem scriptを追加します。
  これにより、LDKのオンチェーンウォレットはチャネルの`TxOut`を再構築し、
  [スプライシング][topic splicing]トランザクションの構築時に正確な手数料率を推定できます。

- [LDK #4148][]は、`rust-bitcoin`の依存バージョンを0.32.4（[ニュースレター #324][news324 testnet]参照）に更新し、
  [testnet4][topic testnet]をサポートし、`lightning`クレートおよび`lightning-invoice`クレートの
  最小サポートバージョンとしてこれを要求します。

- [BDK #2027][]は、`TxGraph`に `list_ordered_canonical_txs`メソッドを追加します。
  このメソッドは、親トランザクションが常に子トランザクションの前に現れるトポロジカルな順序で正規化されたトランザクションを返します。
  既存の`list_canonical_txs`メソッドおよび`try_list_canonical_txs`メソッドは、
  新しい順序付けられたメソッドに置き換えられ、非推奨となります。BDKにおける以前の正規化作業については、
  ニュースレター[#335][news335 txgraph]、[#346][news346 txgraph]および[#374][news374 txgraph]をご覧ください。

{% include snippets/recap-ad.md when="2025-12-02 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1820,33872,33629,8677,8546,8682,4197,4234,4148,2027" %}
[0xb10c delving]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/35
[news365 cb]: /ja/newsletters/2025/08/01/#testing-compact-block-prefilling
[news339 cb]: /ja/newsletters/2025/01/31/#updated-stats-on-compact-block-reconstruction
[news315 cb]: /ja/newsletters/2024/08/09/#statistics-on-compact-block-reconstruction
[david delving post]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/34
[news368 minrelay]: /ja/newsletters/2025/08/22/#bitcoin-core-33106
[0xb10c third update]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/44
[murch ml]: https://groups.google.com/g/bitcoindev/c/j4_toD-ofEc
[news341 bip3]: /ja/newsletters/2025/02/14/#bip
[news378 bips2006]: /ja/newsletters/2025/10/31/#bips-2006
[LND v0.20.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta
[lnd notes]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.20.0.md
[Core Lightning v25.12rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.12rc1
[news364 orphan]: /ja/newsletters/2025/07/25/#bitcoin-core-31829
[news335 ldk]: /ja/newsletters/2025/01/03/#ldk-3365
[news374 ldk]: /ja/newsletters/2025/10/03/#ldk-4098
[news371 ldk]: /ja/newsletters/2025/09/12/#ldk-3886
[news324 testnet]: /ja/newsletters/2024/10/11/#rust-bitcoin-2945
[news335 txgraph]: /ja/newsletters/2025/01/03/#bdk-1670
[news346 txgraph]: /ja/newsletters/2025/03/21/#bdk-1839
[news374 txgraph]: /ja/newsletters/2025/10/03/#bdk-2029