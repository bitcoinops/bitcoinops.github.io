---
title: 'Bitcoin Optech Newsletter #296'
permalink: /ja/newsletters/2024/04/03/
name: 2024-04-03-newsletter-ja
slug: 2024-04-03-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、コンセンサスクリーンアップソフトフォークの新たな推進に関する議論と、
週末までに新たなBIPエディターを選出する計画の発表を掲載しています。
また、新しいリリースの発表や人気のあるBitcoinインフラストラクチャソフトウェアの変更など
恒例のセクションも含まれています。

## ニュース

- **<!--revisiting-consensus-cleanup-->コンセンサス・クリーンアップの再検討:** Antoine Poinsotは、
  2019年に提案されたMatt Coralloの[コンセンサスクリーンアップ][topic consensus cleanup]（
  [ニュースレター #36][news36 cleanup]参照）の再検討についてDelving Bitcoinに[投稿しました][poinsot cleanup]。
  彼は、この提案が修正するいくつかの問題の最悪のケースを定量化しようと試みています。
  その中には、最新のラップトップで検証するのに3分以上、
  Raspberry Pi 4で検証するのに90分以上かかるブロックを作成することや、
  マイナーが報酬を盗み、約1ヶ月の準備で[タイムワープ攻撃][topic time warp]を使ってLNを危険にさらすこと、
  軽量クライアントを騙して偽のトランザクションを受け入れさせること（[CVE-2017-12842][topic cves]）、
  フルノードを混乱させて有効なブロックを拒否させること（[ニュースレター #37][news37 trees]参照）が含まれます。

  Coralloの元のコンセンサスクリーンアップでの上記の懸念に加えて、
  Poinsotは、ブロック1,983,702でフルノードに影響を及ぼし始める（そして既にtestnetのノードには影響を与えている）
  [重複トランザクション][topic duplicate transactions]の残りの問題に対処することを提案しています。

  上記の問題にはすべて、ソフトフォークで展開できる技術的に簡単な解決策があります。
  以前提案された低速検証ブロックの解決策は、
  理論上、事前署名済みのトランザクションで使用されているスクリプトが無効となり、
  [没収回避][topic accidental confiscation]の開発ポリシーに違反する可能性があることから、
  若干物議を醸しました（[ニュースレター #37][news37 confiscation]参照）。
  最初のコンセンサスクリーンアップの提案以前のBitcoinが存在した10年間でも、
  それ以降の5年間でも、このようなスクリプトが実際に使用されたということは聞いたことがありませんが、
  一部の種類では、事前署名されたトランザクションがブロードキャストされるまで検出することは不可能でしょう。

  この懸念に対処するため、Poinsotは、
  更新されたコンセンサスルールを特定のブロック高以降に作成されたトランザクションアウトプットにのみ適用することを提案しました。
  その高さよりも前に作成されたアウトプットは、旧ルールでも使用可能です。

- **新しいBIPエディターの選択:** Mark "Murch" Erhardtは、
  新しいBIPエディターの追加に関する[スレッド][erhardt bip editors]を継続し、
  「金曜日の終わり（4月5日）までに、このスレッドで候補者の賛否を表明し、いずれかの候補者が幅広い支持を得た場合、
  その候補者は次の月曜日（4月8日）に新しいエディターとしてリポジトリに追加される」ことを提案しました。

  この記事の執筆時点でも議論は続いており、来週のニュースレターで結果を報告できるよう最善を尽くします。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 26.1][]は、ネットワークの主要なフルノード実装のメンテナンスリリースです。
  [リリースノート][26.1 rn]にいくつかのバグ修正が記載されています。

- [Bitcoin Core 27.0rc1][]は、ネットワークの主要なフルノード実装の次期メジャーバージョンのリリース候補です。
  [推奨されるテストトピック][bcc testing]の簡単な概要があります。

- [HWI 3.0.0-rc1][]は、複数の異なるハードウェア署名デバイスに共通のインタフェースを提供する、
  このパッケージの次期バージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。*

*注：以下に掲載するBitcoin Coreへのコミットは、master開発ブランチに適用されるため、
これらの変更は次期バージョンの27のリリースから約6ヶ月後までリリースされないでしょう。*

- [Bitcoin Core #27307][]は、Bitcoin Coreの組み込みウォレットに属するトランザクションと競合する
  mempool内のトランザクションのtxidを追跡するようにします。これには、
  ウォレットのトランザクションの祖先と競合するmempool内のトランザクションが含まれます。
  競合するトランザクションが承認されると、ウォレットのトランザクションをブロックチェーンに含めることはできないため、
  競合について知ることはとても役に立ちます。ウォレットトランザクションについて`gettransaction`を呼び出すと、
  競合するmempoolのトランザクションが新しい`mempoolconflicts`フィールドに表示されるようになります。
  mempoolで競合するトランザクションへのインプットは、手動でそのトランザクションを放棄することなく再使用でき、
  ウォレットの残高にカウントされます。

- [Bitcoin Core #29242][]は、2つの[Feerate Diagrams][sdaftuar incentive compatibility]を比較し、
  最大2つのトランザクションでクラスターを置換した場合のインセンティブ互換性を評価するユーティリティ関数を導入しました。
  これらの関数は、[TRUC（Topologically Restricted Until Confirmation）トランザクション][TRUC BIP draft]
  （別名[v3トランザクション][topic v3 transaction relay]）を含む、
  2つまでのサイズのクラスターによる[パッケージ][topic package relay][RBF][topic rbf]の基礎となります。

- [Core Lightning #7094][]は、Core Lightningの新しい非推奨システム（
  [ニュースレター #288][news288 cln deprecation]参照）を使用して以前非推奨となった複数の機能を削除します。

- [BDK #1351][]は、BDKが[gap制限][topic gap limits]の動作を制御する`stop_gap`パラメーターを解釈する方法に
  いくつかの変更を加えています。特に１つの変更は、他のウォレットの動作と一致させようとするもので、
  `stop_gap`制限を10に設定すると、
  一致するトランザクションが見つからないまま10個の連続したアドレスが生成されるまで、
  BDKがトランザクションをスキャンするための新しいアドレスをし続けます。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27307,29242,7094,1351" %}
[bitcoin core 26.1]: https://bitcoincore.org/bin/bitcoin-core-26.1/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/27.0-Release-Candidate-Testing-Guide
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[poinsot cleanup]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710
[news36 cleanup]: /en/newsletters/2019/03/05/#cleanup-soft-fork-proposal
[news37 confiscation]: /en/newsletters/2019/03/12/#cleanup-soft-fork-proposal-discussion
[erhardt bip editors]: https://gnusha.org/pi/bitcoindev/52a0d792-d99f-4360-ba34-0b12de183fef@murch.one/
[sdaftuar incentive compatibility]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553
[TRUC BIP draft]: https://github.com/bitcoin/bips/pull/1541
[news288 cln deprecation]: /ja/newsletters/2024/02/07/#core-lightning-6936
[26.1 rn]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-26.1.md
[HWI 3.0.0-rc1]: https://github.com/bitcoin-core/HWI/releases/tag/3.0.0-rc.1
[news37 trees]: /en/newsletters/2019/03/12/#bitcoin-core-vulnerability-disclosure
