---
title: 'Bitcoin Optech Newsletter #332'
permalink: /ja/newsletters/2024/12/06/
name: 2024-12-06-newsletter-ja
slug: 2024-12-06-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、トランザクション検閲の脆弱性の開示の発表と、
コンセンサスクリーンアップソフトフォーク提案に関する議論を掲載しています。
また、新しいリリースとリリース候補の発表や、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **<!--transaction-censorship-vulnerability-->トランザクション検閲の脆弱性:**
  Antoine Riardは、接続されたウォレットに属するトランザクションをノードがブロードキャストするのを防ぐ方法について
  Bitcoin-Devメーリングリストに[投稿しました][riard censor]。接続されたウォレットが、
  ユーザーのLNノードに属している場合、この攻撃はタイムアウトの期限が切れる前に、
  そのユーザーが所持している資金を確保するのを阻止するために使用でき、
  取引相手に資金を盗ませることができます。

  攻撃には2つのバージョンがあり、どちらも一定期間内にブロードキャスト
  または受け入れる未承認トランザクションの最大数に関連するBitcoin Coreの制限を悪用します。
  これらの制限により、ピアに過度の負荷をかけたり、サービス拒否攻撃を受けたりするのが防止されています。

  Riardが _high overflow_ と呼ぶ1つめのバージョンの攻撃では、
  Bitcoin Coreがピアに一度に送信する未承認トランザクションのアナウンスが最大1,000件であるという制限を悪用します。
  1,000件を超えるトランザクションが送信待ちになっている場合、
  最も手数料率の高いトランザクションが先にアナウンスされます。
  アナウンスのバッチを送信後、Bitcoin Coreはアナウンスの最近の平均レートが毎秒7トランザクションになるまで、
  トランザクションを送信するのを待ちます。

  もし1,000件の最初のアナウンスすべてが、被害者がブロードキャストしたいトランザクションよりも高い手数料率を支払い、
  攻撃者がその手数料率を上回る毎秒7件以上のトランザクションを被害ノードに送信し続ければ、
  攻撃者はブロードキャストを無期限に阻止することができます。
  LNに対するほとんどの攻撃では、ブロードキャストを32ブロック（Core Lightningのデフォルト）から
  140ブロック（Eclairのデフォルト）遅延させる必要があります。10 sats/vbyteの場合、
  コストは1.3 BTC（$130,000 USD）から5.9 BTC（$590,000 USD）になりますが、
  Riardは、他のリレーノード（または大規模なマイナーに直接）と十分に接続している注意深い攻撃者は、
  これらのコストを大幅に削減できる可能性があると指摘しています。

  2つめのバージョンの攻撃は、Riardが _low overflow_ と呼んでいるもので、
  要求されていないトランザクションのキューがピア毎に5,000件を超えるのを許可しないという制限を悪用します。
  攻撃者は、被害者に最小限の手数料率で大量のトランザクションを送信します。
  被害者はこれを正直なピアにアナウンスし、そのピアはこのアナウンスをキューに入れます。
  ピアは定期的にトランザクションを要求してキューを空にしようとしますが、
  5,000件のアナウンス制限に達するまで、累積していきます。その時点で、
  ピアはキューが部分的に空になるまで、それ以上のアナウンスを無視します。
  その間に被害者の正直なトランザクションがアナウンスされた場合、ピアはそれを無視します。
  この攻撃は、攻撃者のジャンクトランザクションが最小限のトランザクションリレー手数料を支払うため、
  high overflowバージョンよりも大幅に安価になる可能性があります。ただし、
  この攻撃は信頼性が低い可能性があり、その場合、攻撃者は窃盗で何も得ることなく、
  手数料に費やした資金を失うことになります。

  単純に考えると、この攻撃は懸念されるものではないようです。
  攻撃コストを超える保留中の支払いがあるようなチャネルはほとんどありません。
  Riardは、高額なLNチャネルのユーザーには、インバウンド接続を受け付けないノードや、
  ローカルウォレットから送信された未承認トランザクションのみをリレーすることを保証する
  _ブロックオンリーモード_ を使用するノードを含む追加のフルノードを運用することを推奨しています。
  コストを下げるより巧妙な攻撃や、同じジャンクトランザクションのセットを使用して複数のLNチャネルを同時に攻撃するような攻撃では、
  低額のチャネルに影響を与える可能性があります。Riardは、LN実装に対する緩和策をいくつか提案し、
  この問題に対処しうるBitcoin CoreのP2Pリレープロトコルの変更の可能性を今後の議論に残しています。

  _読者への注記:_ もし上記の記述に誤りがあればお詫びします。
  私たちは今週のニュースレターを発行する直前にこの情報公開を知りました。

- **<!--continued-discussion-about-consensus-cleanup-soft-fork-proposal-->コンセンサスクリーンアップソフトフォーク提案に関する継続的な議論:**
  Antoine Poinsotは、既存のDelving Bitcoinのスレッドに、
  [コンセンサスクリーンアップ][topic consensus cleanup]ソフトフォークの提案について[投稿しました][poinsot time warp]。
  既に提案されている代表的な[タイムワープ脆弱性][topic time warp]の修正に加えて、
  彼は最近発見されたZawy-Murchタイムワープ（[ニュースレター #316][news316 time warp]参照）の修正も含めることを提案しました。
  彼は、もともとMark "Murch" Erhardtによって提案された「難易度期間 _N_ 内の最後のブロックが、
  同じ難易度期間 _N_ 内の最初のブロックよりも高いタイムスタンプを持つことを要求する」という修正を支持しました。

  Anthony Townsは、Zawyが提案した、どのブロックも前のブロックより2時間以上前に生成されたと主張することを禁止する
  別の解決策を[支持しました][towns time warp]。Zawyは、
  彼のブロック毎の解決策は、マイナーが古いソフトウェアを実行することで資金を失うリスクを高めるが、
  タイムロックなどの他の用途では、タイムスタンプの精度がより高まると[指摘しました][zawy time warp]。

  これとは別に、[Delving Bitcoin][poinsot duptx delv]と
  [Bitcoin-Devメーリングリスト][poinsot duptx ml]の両方で、
  Poinsotはブロック1,983,702とそれ以降のいくつかのブロックが
  以前のコインベーストランザクションを[複製する][topic duplicate transactions]ことを防ぐために、
  どの解決策を使用するべきかについてフィードバックを求めました（
  この複製が行われると資金の喪失と攻撃ベクトルの作成につながる可能性があります）。
  提案された解決策は4つありますが、いずれもマイナーに直接影響するものであるため、
  [マイナーからのフィードバック][mining-dev]が特に望まれます。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Eclair v0.11.0][]は、この人気のLNノード実装の最新リリースです。
  「BOLT12 [オファー][topic offers]の公式サポートを追加し、
  流動性管理機能（[スプライシング][topic splicing]、[Liquidity Ads][topic liquidity advertisements]、
  [オンザフライ・ファンディング][topic jit channels]）が進捗しています」。
  このリリースでは、新しく非[アンカーチャネル][topic anchor outputs]の受け入れも停止しています。
  また、最適化やバグ修正も含まれています。

- [LDK v0.0.125][]は、LN対応アプリケーションを構築するためのこのライブラリの最新リリースです。
  いくつかのバグ修正が含まれています。

- [Core Lightning 24.11rc3][]は、この人気のLN実装の次期メジャーバージョンのリリース候補です。

- [LND 0.18.4-beta.rc1][]は、この人気のLN実装のマイナーバージョンのリリース候補です。

- [Bitcoin Core 28.1RC1][]は、主要アンフルノード実装のメンテナンスバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #30708][]では、指定されたブロックハッシュのセット内の[ディスクリプター][topic descriptors]に関連付けられた
  すべてのトランザクションを取得する`getdescriptoractivity` RPCコマンドが追加され、
  ウォレットがステートレスな方法でBitcoin Coreとやりとりできるようになります。
  このコマンドは、ディスクリプターに関連付けられたトランザクションを含むブロックハッシュのセットを識別する
  `scanblocks`（[ニュースレター #222][news222 scanblocks]参照）と組み合わせて使用すると特に便利です。

- [Core Lightning #7832][]では、緊急ではない一方的なクローズトランザクションの場合でも、
  [アンカーアウトプット][topic anchor outputs]からの支払いをします。
  ブロックターゲットは2016ブロック（約2週間）から徐々に12ブロックに縮小されます。
  ブロードキャストした際のタイムスタンプは、再起動しても一貫した動作を保証するために追跡されます。
  これまでは、これらのトランザクションはデフォルトでアンカーアウトプットから支払いをしていなかったため、
  手動でその支払いを追加するのが困難で、[CPFP][topic cpfp]による手数料の引き上げが使用できませんでした。

- [LND #8270][]は、[BOLT2][]で定義されているチャネル静止プロトコル（
  ニュースレター[#309][news309 quiescence]参照）を実装します。これは、
  [ダイナミックコミットメント][topic channel commitment upgrades]と[スプライシング][topic splicing]の前提条件です。
  このプロトコルにより、ノードはピアの静止要求に応答し、新しい`ChannelUpdateHandler`操作を使用してプロセスを開始できます。
  このPRでは、静止状態が解決されずに長時間続く場合に、ピアを切断して処理するための設定可能なタイムアウトの仕組みも追加されています。

- [LND #8390][]は、[チャネルジャミング攻撃][topic channel jamming attacks]防止の研究を目的に、
  `update_add_htlc`メッセージ内に実験的な[HTLCエンドースメント][topic htlc endorsement]の
  シグナリングフィールドの設定とリレーのサポートを導入します。ノードがシグナリングフィールドを含むHTLCを受け取ると、
  フィールドをそのままリレーします。それ以外の場合は、デフォルト値の0を設定します。
  この機能はデフォルトで有効になっていますが、無効にすることもできます。

- [BIPs #1534][]は、Taprootの内部鍵をスタックに配置する新しい[Tapscript][topic tapscript]専用のopcodeである
  `OP_INTERNALKEY`の仕様を定義した[BIP349][]をマージしました。スクリプトの作成者は、
  アウトプットに支払う前に内部鍵を知る必要があり、これは代わりにスクリプト内に直接内部鍵を含めるものです。
  使用のたびに8 vbyteを節約し、スクリプトの再利用性を高めます（[ニュースレター #285][news285 bip349]参照）。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30708,7832,8270,8390,1534" %}
[core lightning 24.11rc3]: https://github.com/ElementsProject/lightning/releases/tag/v24.11rc3
[lnd 0.18.4-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.4-beta.rc1
[news316 time warp]: /ja/newsletters/2024/08/16/#testnet4
[poinsot time warp]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/53
[towns time warp]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/54
[zawy time warp]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/55
[poinsot duptx delv]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/51
[poinsot duptx ml]: https://groups.google.com/g/bitcoindev/c/KRwDa8aX3to
[mining-dev]: https://groups.google.com/g/bitcoinminingdev/c/qyrPzU1WKSI
[eclair v0.11.0]: https://github.com/ACINQ/eclair/releases/tag/v0.11.0
[ldk v0.0.125]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.125
[bitcoin core 28.1RC1]: https://bitcoincore.org/bin/bitcoin-core-28.1/
[riard censor]: https://groups.google.com/g/bitcoindev/c/GuS36ldye7s
[news222 scanblocks]: /ja/newsletters/2022/10/19/#bitcoin-core-23549
[news309 quiescence]: /ja/newsletters/2024/06/28/#bolts-869
[news285 bip349]: /ja/newsletters/2024/01/17/#lnhance
