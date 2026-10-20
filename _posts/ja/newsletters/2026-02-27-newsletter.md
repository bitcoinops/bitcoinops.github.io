---
title: 'Bitcoin Optech Newsletter #394'
permalink: /ja/newsletters/2026/02/27/
name: 2026-02-27-newsletter-ja
slug: 2026-02-27-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、アウトプットスクリプトディスクリプターに補足情報を含めるためのBIP提案を取り上げています。
また、Bitcoin Stack Exchangeで人気の質問とその回答や、新しいリリースとリリース候補の発表、
人気のBitcoin基盤ソフトウェアの最近の更新など恒例のセクションも含まれています。

## ニュース

- **アウトプットスクリプトディスクリプターのアノテーションに関するBIPドラフト**: Craig Rawは、
  BIP392（[ニュースレター #387][news387 sp]参照）に関する議論で生じたフィードバックに対応するため、
  Bitcoin-Devメーリングリストに新しいBIPのアイディアを[投稿しました][annot ml]。
  Rawによると、ウォレットの誕生日をブロック高で表現するなどのメタデータがあれば、
  [サイレントペイメント][topic silent payments]のスキャンをより効率的にできる可能性があります。
  しかし、メタデータはアウトプットスクリプトを決定するのに技術的には必須ではないため、
  [ディスクリプター][topic descriptors]に含めるのは適切ではないと考えられています。

  Rawが提案するBIPは、有用なメタデータをアノテーションとして提供するもので、
  キー/バリューのペアとして表現され、URLのようなクエリ区切り文字列を使ってディスクリプター文字列に直接付加されます。
  アノテーション付きのディスクリプターは次のようになります:`SCRIPT?key=value&key=value#CHECKSUM`。
  注目すべきことに、`?`、`&`および`=`といった文字は[BIP380][]で既に定義されているため、
  チェックサムアルゴリズムを更新する必要がありません。

  [BIPのドラフト][annot draft]では、Rawはサイレントペイメントのスキャンをより効率的にするための
  3つの初期アノテーションキーも定義しています:

  - ブロック高`bh`: ウォレットが最初に資金を受け取ったブロック高

  - ギャップリミット`gl`: 導出を停止するまでの未使用のアドレス数

  - 最大ラベル`ml`: サイレントペイメントアドレスでスキャンする最大ラベルインデックス

  最後に、Rawはアノテーションを一般的なウォレットバックアッププロセスに使用すべきではなく、
  ディスクリプターが生成するスクリプトを変更することなく、資金の復元をより効率的にするためにのみ使用すべきだと述べました。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [BitcoinのBIP324 v2 P2Pトランスポートはランダムトラフィックと区別可能ですか？]({{bse}}130500)
  Pieter Wuilleは、[BIP324][]の[v2暗号化トランスポート][topic v2 p2p transport]が
  トラフィックパターンをランダムに見せかけるよう整形する機能をサポートしていると指摘しましたが、
  その機能を実装しているソフトウェアは知られておらず、
  「現在の実装は、送信byteのパターンに関するプロトコルシグネチャを無効化するだけで、
  トラフィックパターンについてはそうではない」と結論付けています。

- [マイナーがヘッダーだけをブロードキャストしてブロックを提供しなかったらどうなりますか？]({{bse}}130456)
  ユーザーbigjoshは、P2Pネットワーク上でブロックヘッダーを受信した後、
  ブロックの内容を受信する前にマイナーがどのように行動する可能性があるかを概説しました:
  そのヘッダーの上に空のブロックをマイニングするというものです。Pieter Wuilleは、
  実際には多くのマイナーが、他のマイニングプールがマイナーに与えている作業量を監視することで
  新しいブロックヘッダーを確認しており、これはスパイマイニングとして知られる手法であると説明しました。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 28.4rc1][]は、以前のメジャーリリースシリーズのメンテナンスリリースのリリース候補です。
  主にウォレット移行の修正と、信頼性の低いDNSシードの削除が含まれています。

- [Rust Bitcoin 0.33.0-beta][]は、Bitcoinデータ構造を扱うためのこのライブラリのベータリリースです。
  300以上のコミットを含む大規模な更新で、新しい`bitcoin-consensus-encoding`クレートの導入、
  P2Pネットワークメッセージエンコードトレイトの追加、重複するインプットや
  `MAX_MONEY`を超えるアウトプットを持つトランザクションのデコード時の拒否、
  そしてすべてのサブクレートのメジャーバージョンアップが含まれています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #34568][]は、マイニングIPCインターフェース（[ニュースレター #310][news310 mining]参照）に
  いくつかの破壊的な変更を加えました。非推奨のメソッド`getCoinbaseRawTx()`、`getCoinbaseCommitment()`および
  `getWitnessCommitmentIndex()`（[ニュースレター #388][news388 mining]参照）が削除され、
  `createNewBlock`と`checkBlock`に`context`パラメーターが追加されたことで、
  [Cap'n Proto][capn proto]イベントループをブロックせずに別スレッドで実行できるようになりました。
  またデフォルトオプション値がスキーマで宣言されるようになりました。
  `Init.makeMining`のバージョン番号が引き上げられ、
  古いクライアントが新しいスキーマを暗黙的に誤って解釈するのではなく、
  明確なエラーを受け取るようになりました。スレッドの変更は、次に説明するクールダウン機能の前提条件です。

- [Bitcoin Core #34184][]は、マイニングIPCインターフェースの`createNewBlock()`メソッドに
  オプションのクールダウンを追加しました。これを有効にすると、このメソッドは
  IBD（Initial Block Download）の完了と先端の同期を常に待ってからブロックテンプレートを返します。
  これにより、起動時に[Stratum v2][topic pooled mining]クライアントが急速に古くなるテンプレートで溢れるのを防ぎます。
  また、IPCクライアントがブロッキング中の`createNewBlock()`や`waitTipChanged()`呼び出しをクリーンに中断できるよう、
  新しい`interrupt()`メソッドも追加されました。

- [Bitcoin Core #24539][]は、承認済みの各アウトプットを使用するトランザクションのインデックスを保持する新しい
  `-txospenderindex`オプションを追加しました。これを有効にすると、`gettxspendingprevout`RPCが、
  既存のmempoolのルックアップに加えて、承認済みトランザクションの`spendingtxid`と`blockhash`を返すように拡張されます。
  RPCには2つの新しいオプション引数も追加されました:
  `mempool_only`はインデックスが利用可能な場合でもルックアップをmempoolに制限し、
  `return_spending_tx`は使用トランザクション全体を返します。
  このインデックスは`-txindex`を必要とせず、プルーニングとは互換性がありません。
  これは、ライトニングや他のセカンドレイヤープロトコルが、使用トランザクションのチェーンを追跡する必要がある場合に特に有用です。

- [Bitcoin Core #34329][]は、プライベートトランザクションブロードキャスト（[ニュースレター #388][news388 private]参照）を
  管理するための2つのRPCを追加しました:
  `getprivatebroadcastinfo`は、プライベートブロードキャストキューにある現在のトランザクションに関する情報（
  選択されたピアアドレスや各ブロードキャストの送信時刻など）を返し、`abortprivatebroadcast`は、
  特定のトランザクションのブロードキャストと保留中の接続をキャンセルします。

- [Bitcoin Core #28792][]は、ASMapデータをBitcoin Coreのバイナリに直接バンドルすることで、
  組み込みASMapシリーズのPRを完了しました。これにより、`-asmap`を有効にするユーザーは、
  データファイルを別途入手する必要がなくなります。ビルドオプション`WITH_EMBEDDED_ASMAP`を削除することでデータを除外できます。
  ASMapは、自律システム間でピア接続を多様化することで[エクリプス攻撃][topic eclipse attacks]への耐性を向上させます（ニュースレター
  [#52][news52 asmap]および[#290][news290 asmap]参照）。この機能はデフォルトでオフのままであり、
  有効にするにはユーザーが`-asmap`を指定する必要があります。新しい[ドキュメントファイル][github asmap-data]には、
  データの取得とBitcoin Coreリリースに組み込むプロセスが概説されています。

- [Bitcoin Core #32138][]は、`settxfee` RPCと`-paytxfee`起動オプションを削除しました。
  これらはすべてのトランザクションに静的な手数料率を設定できるもので、
  Bitcoin Core 30.0で非推奨になっていました（[ニュースレター #349][news349 settxfee]参照）。
  ユーザーは代わりに[手数料推定][topic fee estimation]機能を利用するか、
  トランザクション毎に手数料率を設定する必要があります。

- [Bitcoin Core #34512][]は、`getblock`RPCレスポンスの詳細度レベル1以上に
  `coinbase_tx`を追加しました。このフィールドには、コインベーストランザクションの
  `version`、`locktime`、`sequence`、`coinbase`スクリプトおよび`witness`データが含まれます。
  レスポンスをコンパクトに保つために、アウトプットは意図的に除外されています。これまでは、
  コインベースのプロパティにアクセスするには詳細度2が必要で、ブロック内のすべてのトランザクションがデコードされていました。
  これは、[BIP54][]（[コンセンサスクリーンアップ][topic consensus cleanup]）のコインベースロックタイム要件の監視や、
  コインベーススクリプトからマイニングプールを特定するのに便利です。

- [Core Lightning #8490][]は、新しい`payment-fronting-node`設定オプションを追加しました。
  これは着信支払いのエントリーポイントとして常に使用する1つ以上のノードを指定するものです。
  設定すると、[BOLT11][]インボイスのルートヒントや[BOLT12][topic offers]オファーやインボイス、
  インボイスリクエストの[ブラインドパス][topic rv routing]導入ポイントは、
  指定されたフロントノードのみを使用するよう構築されます。これまでは、
  CLNはノードのチャネルピアから自動的に選択していたため、インボイス毎に異なるピアが公開される可能性がありました。
  このオプションはグローバルに設定するか、オファー毎に上書きできます。

- [Eclair #3250][]は、ローカルノードがチャネルタイプを明示的に設定せずにチャネルを開く際に、
  `OpenChannelInterceptor`が自動的に`channel_type`を選択できるようにしました。
  これまでは、自動チャネル作成（例：LSPがクライアントにチャネルを開く場合）は、
  タイプが提供されない限り失敗していました。現在のデフォルトは[アンカーチャネル][topic anchor
  outputs]が優先され、後続のPRで[Simple Taproot Channel][topic simple taproot
  channels]が優先されるようになる予定です。

- [LDK #4373][]は、ローカルノードがインボイスの合計金額の一部のみを支払う[マルチパスペイメント][topic
  multipath payments]の送信サポートを追加しました。`RecipientOnionFields`の
  新しい`total_mpp_amount_msat`フィールドにより、このノードが送信する金額よりも大きいMPP合計を宣言でき、
  複数のウォレットやノードがそれぞれ支払いの一部を負担して、単一のインボイスに対して協力して支払うことが可能になります。
  受信者はすべての参加ノードからHTLCを収集し、全額が到着した時点で支払いを請求します。
  [BOLT12][topic offers]のサポートは後続に委ねられています。

- [BDK #2081][]は、`SpkTxOutIndex`と`KeychainTxOutIndex`に`spent_txouts()`と
  `created_txouts()`メソッドを追加しました。トランザクションを与えると、
  追跡対象のどのアウトプットが使用され、どの新しい追跡対象アウトプットが作成されたかを返します。
  これにより、ウォレットは関心のあるトランザクションに関係するアドレスと金額を容易に判定できるようになります。

{% include snippets/recap-ad.md when="2026-03-03 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="34568,34184,24539,34329,28792,32138,34512,8490,3250,4373,2081" %}

[annot ml]: https://groups.google.com/g/bitcoindev/c/ozjr1lF3Rkc
[news387 sp]: /ja/newsletters/2026/01/09/#bip
[annot draft]: https://github.com/craigraw/bips/blob/descriptorannotations/bip-descriptorannotations.mediawiki
[news310 mining]: /ja/newsletters/2024/07/05/#bitcoin-core-30200
[news388 mining]: /ja/newsletters/2026/01/16/#bitcoin-core-33819
[news388 private]: /ja/newsletters/2026/01/16/#bitcoin-core-29415
[capn proto]: https://capnproto.org/
[news52 asmap]: /en/newsletters/2019/06/26/#differentiating-peers-based-on-asn-instead-of-address-prefix
[news290 asmap]: /ja/newsletters/2024/02/21/#asmap
[github asmap-data]: https://github.com/bitcoin/bitcoin/blob/master/doc/asmap-data.md
[news349 settxfee]: /ja/newsletters/2025/04/04/#bitcoin-core-31278
[Bitcoin Core 28.4rc1]: https://bitcoincore.org/bin/bitcoin-core-28.4/test.rc1/
[Rust Bitcoin 0.33.0-beta]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/bitcoin-0.33.0-beta
