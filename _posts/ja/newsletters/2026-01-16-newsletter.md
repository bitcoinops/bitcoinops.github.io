---
title: 'Bitcoin Optech Newsletter #388'
permalink: /ja/newsletters/2026/01/16/
name: 2026-01-16-newsletter-ja
slug: 2026-01-16-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin Coreにおけるインクリメンタルミューテーションテストに関する検討と、
新しいBIPプロセスの導入について掲載しています。また、新しいリリースやリリース候補の発表、
人気のBitcoin基盤プロジェクトにおける注目すべき更新など恒例のセクションも含まれています。

## ニュース

- **Bitcoin Coreにおけるインクリメンタルミューテーションテストの概要**: Bruno Garciaは、
  Bitcoin Coreの[ミューテーションテスト][news320 mutant]を改善する彼の現在の取り組みについてDelving Bitcoinに[投稿しました][mutant post]。
  ミューテーションテストは、ミュータントと呼ばれるシステムバグを意図的にコードベースに挿入することで、
  開発者がテストの有効性を評価する手法です。テストが失敗した場合、ミュータントは「killed（強制終了）」とみなされ、
  テストがその欠陥を検出できることを示します。そうでない場合、ミュータントは生存し、
  テストに潜在的な問題があることが明らかになります。

  ミューテーションテストは重要な成果をもたらしており、報告されたミュータントの一部に対処するためのPRが作成されています。
  しかし、このプロセスはリソースを大量に消費し、コードベースのサブセットに対してでも完了までに30時間以上かかります。
  そのため、Garciaは現在インクリメンタルミューテーションテストに注力しています。これは、
  前回の分析以降に変更されたコードベースのパーツのみに焦点を当て、ミューテーションテストを段階的に適用する手法です。
  このアプローチはより高速ですが、それでも時間がかかりすぎます。

  そこでGarciaは、Googleの[論文][mutant google]に従って、Bitcoin Coreのインクリメンタルミューテーションテストの効率を改善する取り組みを進めています。
  このアプローチは以下の原則に基づいています:

  - 元のプログラムとは構文は異なるが意味的には同一であるような悪いミュータントを避ける。
    つまり、入力に関わらず常に同じ動作をするミュータントを避ける。

  - 開発者からのフィードバックを収集してミュータントの生成を改良し、ミュータントが役に立たない結果をもたらす傾向がある場所を把握する

  - 開発者に情報価値の低いミュータントを大量に提供しないように、killされなかったミュータントは限られた数のみ報告する（Googleの研究によると７個）

  Garciaはこのアプローチを8つの異なるPRでテストし、フィードバックを収集し、ミュータントに対処するための変更を提案しました。

  最後に、GarciaはBitcoin Coreコントリビューターに対して、ミューテーションテストの実行を希望する場合は
  彼らのPRで自分に通知するよう呼びかけ、また提供されたミュータントに関するフィードバックを報告するよう依頼しました。

- **BIPプロセスの更新**: メーリングリストで[2ヶ月][bip3 motion to activate]以上の[議論][bip3 follow-up to motion]と
  提案へのさらなる[修正][bips #2051]を経て、今週BIP3がラフコンセンサスに達したことが明らかになりました。
  水曜日のBIP3の展開により、BIPプロセスのガイドラインとしてBIP2に取って代わりました。
  BIPプロセスの大部分は変更されていませんが、BIP3はいくつかの簡素化と改善を導入しています。

  その他の変更点として、コメントシステムが廃止され、BIPステータスの数が9つ（
  Draft、Proposed、Active、Final、Rejected、Deferred、Withdrawn、Replaced、Obsolete）から
  4つ（Draft、Complete、Deployed、Closed）に削減され、プリアンブルヘッダーが更新され、
  Standards TrackタイプがSpecificationタイプに置き換えられ、
  これまでBIPエディターに求められていた判断の一部がBIP作成者または読者に委ねられるようになりました。

  [すべての変更の概要][bip2to3]はBIP3で確認できます。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 30.2][]は、名前のないレガシーウォレットを移行する際に
  `wallets`ディレクトリ全体が誤って削除される可能性があるバグ（ニュースレター[#387][news387 wallet]参照）を修正したメンテナンスリリースです。
  他にもいくつかの改善と修正が含まれています。詳細については[リリースノート][release notes]をご覧ください。

- [BTCPay Server 2.3.3][]は、この自己ホスト型ペイメントソリューションのマイナーリリースで、
  `Greenfield`API（下記参照）を介したコールドウォレットトランザクションのサポートが導入され、
  CoinGeckoベースの為替レートソースが削除され、いくつかのバグ修正が含まれています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #33819][]は、`Mining`インターフェース（[ニュースレター #310][news310 mining]参照）に
  新しい`getCoinbaseTx()`メソッドを導入し、クライアントがコインベーストランザクションを構築するために必要な
  すべてのフィールドを含む構造体を返します。既存の`getCoinbaseTx()`は、クライアントがパースして操作する必要がある
  シリアライズされたダミートランザクションを返していましたが、`getCoinbaseRawTx()`に名称変更され、
  `getCoinbaseCommitment()`および`getWitnessCommitmentIndex()`とともに非推奨になりました。

- [Bitcoin Core #29415][]は、`sendrawtransaction` RPCを使用する際に、
  短命な[Tor][topic anonymity networks]またはI2P接続を介してIPv4/IPv6ピアに
  トランザクションをブロードキャストするための新しい`privatebroadcast` bool値オプションを追加しました。
  このアプローチは、IPアドレスを秘匿し、トランザクションごとに個別の接続を使用してリンク可能性を防ぐことで、
  トランザクション発信者のプライバシーを保護します。

- [Core Lightning #8830][]は、`hsmtool`ユーティリティ（[ニュースレター #73][news73 hsmtool]参照）に
  `getsecret`コマンドを追加しました。これは既存の`getsecretcodex`コマンドを置き換え、
  v25.12で導入された変更（[ニュースレター #383][news383 bip39]参照）以降に作成されたノードのリカバリーをサポートします。
  新しいコマンドは、新しいノードの場合は指定された`hsm_secret`ファイルに対する[BIP39][]ニーモニックシードフレーズを出力し、
  レガシーノードの場合は`Codex32`文字列を出力する機能を維持します。`recover`プラグインは、
  ニーモニックを受け入れるよう更新されました。

- [Eclair #3233][]は、ブロックデータが不十分なためにBitcoin Coreが[testnet3][topic testnet]または
  testnet4で手数料を推定できない場合に、設定されたデフォルトの手数料率を使用するようになりました。
  デフォルトの手数料率は、現在の値により適合するよう更新されました。

- [Eclair #3237][]は、チャネルライフサイクルイベントを、
  [スプライシング][topic splicing]と互換性があり[ゼロ承認][topic zero-conf channels]と一貫性のあるものに再構築しました。
  これにより以下が追加されました:
  `channel-confirmed`はファンディングトランザクションまたはスプライシングが承認されたことを通知します。
  `channel-ready`はチャネルでの支払いが可能な状態になったことを通知します。
  `channel-opened`イベントは削除されました。

- [LDK #4232][]は、[BLIPs #67][]および[BOLTs #1280][]で提案された
  [HTLCエンドースメント][topic htlc endorsement]に代わる実験的な`accountable`シグナルのサポートを追加しました。
  LDKは、自身の支払いとシグナルのない転送にゼロ値のシグナルを設定し、
  存在する場合は受信したaccountable値を送信する転送にコピーするようになりました。
  これは、EclairおよびLNDでの同様の変更（[ニュースレター #387][news387 accountable]参照）に続くものです。

- [LND #10296][]は、`EstimateFee`RPCコマンドリクエストに`inputs`フィールドを追加し、
  ウォレットの自動選択させる代わりに特定のインプットを使用したトランザクションの
  [手数料推定][topic fee estimation]を取得できるようになりました。

- [BTCPay Server #7068][]は、`Greenfield`APIを介したコールドウォレットトランザクションのサポートを追加しました。
  これにより、ユーザーは署名されていない[PSBT][topic psbt]を生成し、
  新しいエンドポイントを通じて外部で署名されたトランザクションをブロードキャストできます。
  この機能は自動化された環境でより高いセキュリティを提供し、より厳格な規制コンプライアンス要件を満たす設定を可能にします。

- [BIPs #1982][]は、[Pay-to-Anchor (P2A)][topic ephemeral anchors]標準アウトプットタイプを規定する
  [BIP433][]を追加し、このアウトプットタイプを使った支払いを標準にしました。

{% include snippets/recap-ad.md when="2026-01-20 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33819,29415,8830,3233,3237,4232,67,1280,10296,7068,1982,2051" %}
[mutant post]: https://delvingbitcoin.org/t/incremental-mutation-testing-in-the-bitcoin-core/2197
[news320 mutant]:/ja/newsletters/2024/09/13/#bitcoin-core
[mutant google]: https://research.google/pubs/state-of-mutation-testing-at-google/
[Bitcoin Core 30.2]: https://bitcoincore.org/bin/bitcoin-core-30.2/
[release notes]: https://bitcoincore.org/ja/releases/30.2/
[BTCPay Server 2.3.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.3
[news387 wallet]: /ja/newsletters/2026/01/09/#bitcoin-core-34156
[news310 mining]: /ja/newsletters/2024/07/05/#bitcoin-core-30200
[news73 hsmtool]: /ja/newsletters/2019/11/20/#c-lightning-3186
[news383 bip39]: /ja/newsletters/2025/12/05/#core-lightning-v25-12
[news387 accountable]: /ja/newsletters/2026/01/09/#eclair-3217
[bip2to3]: https://github.com/bitcoin/bips/blob/master/bip-0003.md#changes-from-bip2
[bip3 motion to activate]: https://gnusha.org/pi/bitcoindev/205b3532-ccc1-4b2f-964f-264fc6e0e70b@murch.one/
[bip3 follow-up to motion]: https://gnusha.org/pi/bitcoindev/1d76a085-deff-4df2-8a82-f8bd984fac27@murch.one/
