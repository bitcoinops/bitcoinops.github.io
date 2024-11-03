---
title: 'Bitcoin Optech Newsletter #319'
permalink: /ja/newsletters/2024/09/06/
name: 2024-09-06-newsletter-ja
slug: 2024-09-06-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Stratum v2プールマイナーがシェアに変換した
ブロックテンプレートに含まれるトランザクション手数料の補償を受け取れるようにする提案と、
提案中の`OP_CAT` opcodeを調査する研究基金の発表、
ソフトフォークの有無にかかわらずマークルツリーの脆弱性を緩和する議論を掲載しています。
また、新しいリリースやリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **手数料収益の分配のためのStratum v2拡張:** Filippo Merliは、
  シェアに個々のマイナーが選択したトランザクションが含まれている場合に、
  シェアに含まれる手数料の金額を追跡できるようにする[Stratum v2][topic pooled mining]の拡張について、
  Delving Bitcoinに[投稿しました][merli stratumfees]。これを使用すると、
  プールからマイナーに支払われる金額を調整することができ、手数料率の高いトランザクションを選択したマイナーには、
  より多くの金額が支払われます。

  Merliは、選択したトランザクションに基づいて異なるマイナーに異なる金額を支払う際の課題のいくつかを検証した、
  共同執筆した[論文][merli paper]のリンクを貼っています。この論文では、
  PPLNS（ _pay per last N shares_ ）プールマイニング支払いスキームと互換性のあるスキームが提案されています。
  彼の投稿には、このスキームの2つの進行中の実装へのリンクがあります。

- **OP_CAT研究基金:** Victor Kolobovは、
  [`OP_CAT`][topic op_cat] opcodeを追加するソフトフォーク案の研究に100万ドルの基金を設ける発表を
  Bitcoin-Devメーリングリストに[投稿しました][kolobov cat]。
  「関心のあるトピックとしては、BitcoinでOP_CATを有効にした場合のセキュリティへの影響、
  Bitcoinでの`OP_CAT`ベースのコンピューティングとロックスクリプトのロジック、
  Bitcoinで`OP_CAT`を利用するアプリケーションとプロトコル、
  `OP_CAT`とその影響に関する一般的な研究が含まれますが、これらに限定はされません。」
  提出は2025年の1月1日までです。

- **<!--mitigating-merkle-tree-vulnerabilities-->マークルツリーの脆弱性の緩和:** Eric Voskuilは、
  [コンセンサスクリーンアップのソフトフォーク提案][topic consensus cleanup]に関するDelving Bitcoinの議論のスレッドに（
  [ニュースレター #296][news296 cleanup]参照）、Bitcoin-Devメーリングリストでの
  最近の[議論][voskuil spv dev]を踏まえた更新の要望を[投稿しました][voskuil spv]。
  特に彼は、「64 byteのトランザクションの無効化の提案には正当性がない」と考えています。
  これは、コンセンサスの変更なしで実行できる他のチェック（実際、それらのチェックは現在実行されています）と比較して、
  64 byteのトランザクションを禁止することで
  CVE-2012-2459のような[マークルツリーの脆弱性][topic merkle tree vulnerabilities]から保護するフルノードのパフォーマンスは向上しないという
  彼の主張に基づいたものです。コンセンサスクリーンアップ提案の推進者であるAntoine Poinsotは、
  このフルノードの側面については[同意している][poinsot cache]ようでした：
  「 64 byteのトランザクションを無効にすることで、より早い段階でブロック障害をキャッシュすることができるという
  私が最初に述べたことは誤りです。」

  しかし、Poinsotらは以前、CVE-2017-12842に対してマークルプルーフを検証するソフトウェアを保護するために、
  64 byteのトランザクションを禁止する提案をしていました。この脆弱性は、
  元の[Bitcoinの論文][Bitcoin paper]に掲載されているように、
  SPV（ _simplified payment verification_ ）を使用する軽量ウォレットに影響します。
  また、SPVを実行する[サイドチェーン][topic sidechains]にも影響し、
  ソフトフォークによるアクティベーションを必要とする[コベナンツ][topic covenants]にも影響する可能性があります。

  CVE-2017-12842の公開以来、ブロック内のコインベーストランザクションの深さをさらにチェックすることで、
  SPVを安全にできることが分かっています。Voskuilは、一般的な最近のブロックで平均576 byteの追加が必要になると推定しています。
  これは帯域幅のわずかな増加です。Poinsotは、議論を[要約し][poinsot spv]、
  Anthony Townsは追加で深さの検証を実行する複雑さに関する議論を[展開しました][towns depth]。

  Voskuilはまた、ブロックヘッダーをマークルツリーの深さにコミットする代替ソフトフォークによるコンセンサスの変更に関する
  Sergio Demian Lernerの以前の[提案][lerner commitment]のリンクも掲載しています。
  これにより、64 byteのトランザクションを禁止することなく、CVE-2017-12842から保護され、
  SPVのプルーフが最大限効率的になります。

  この記事の執筆時点では議論は進行中でした。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning 24.08][]は、この人気のLNノード実装のメジャーリリースで、
  新しい機能とバグ修正が含まれています。

- [LDK 0.0.124][]は、LN対応アプリケーションを構築するこのライブラリの最新リリースです。

- [LND v0.18.3-beta.rc2][]は、この人気のLNノード実装の軽微なバグ修正リリースのリリース候補です。

- [BDK 1.0.0-beta.2][]は、ウォレットやその他のBitcoin対応アプリケーションを構築するためのこのライブラリのリリース候補です。
  元の`bdk` Rustクレートの名前が`bdk_wallet`変更され、 低レイヤーのモジュールは、
  `bdk_chain`、`bdk_electrum`、`bdk_esplora`、`bdk_bitcoind_rpc`などの独自のクレートに抽出されました。
  `bdk_wallet`クレートは、「安定した 1.0.0 API を提供する最初のバージョンです」。

- [Bitcoin Core 28.0rc1][]は、主要なフルノード実装の次期メジャーバージョンのリリース候補です。
  [テストガイド][bcc testing]が利用可能です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

_注: 以下に掲載するBitcoin Coreへのコミットは、master開発ブランチに適用されるため、
これらの変更がリリースされるのは、次期バージョン28のリリースから約6ヶ月後になると思われます。_

- [Bitcoin Core #30454][]と[#30664][bitcoin core #30664]は、
  それぞれCMakeベースのビルドシステム（[ニュースレター #316][news316 cmake]参照）を追加し、
  autotoolsベースのビルドシステムを削除します。後続のPR[#30779][bitcoin core #30779]、
  [#30785][bitcoin core #30785]、[#30763][bitcoin core #30763]、
  [#30777][bitcoin core #30777]、[#30752][bitcoin core #30752]、
  [#30753][bitcoin core #30753]、[#30754][bitcoin core #30754]、
  [#30749][bitcoin core #30749]、[#30653][bitcoin core #30653]、
  [#30739][bitcoin core #30739]、[#30740][bitcoin core #30740]、
  [#30744][bitcoin core #30744]、[#30734][bitcoin core #30734]、
  [#30738][bitcoin core #30738]、[#30731][bitcoin core #30731]、
  [#30508][bitcoin core #30508]、[#30729][bitcoin core #30729]、
  [#30712][bitcoin core #30712]もご覧ください。

- [Bitcoin Core #22838][]は、複数の導出パス[ディスクリプター][topic descriptors]（[BIP389][]）を実装しました。
  これにより、1つのディスクリプター文字列で2つの関連する導出パスを指定できます。1つめは支払いの受け取り用、
  2つめは内部用（お釣りなど）です。ニュースレター[#211][news211 bip389]および[#258][news258 bip389]をご覧ください。

- [Eclair #2865][]では、切断されたモバイルピアの最後の既知のIPアドレスへの接続を試み、
  モバイル通知をプッシュすることで、そのモバイルピアをウェイクアップする機能が追加されました。
  これは、ローカルノードが支払いや[Onionメッセージ][topic onion messages]を保持し、
  ピアがオンラインに戻るとそれが配信されるような[非同期支払い][topic async payments]の文脈で特に有用です。
  ニュースレター[#232][news232 async]をご覧ください。

- [LND #9009][]は、無効なチャネルアナウンス（既に使用されたチャネルや、ファンディングトランザクションがないチャネル、
  ファンディングアウトプットが無効）を送信するピアを禁止する仕組みを導入しました。禁止ピアは、
  関係に応じて異なる方法で処理されます:

  - 共有チャネルのない禁止ピアの場合、ノードはそれらのピアを切断します。

  - 共有チャネルを持つ禁止ピアの場合、ノードは48時間そのピアのチャネルアナウンスをすべて無視します。

- [LDK #3268][]は、突然の手数料の急上昇による不要な強制閉鎖を回避するために、
  相手方の手数料率を確認する際の[dust][topic uneconomical outputs]計算用の
  より保守的な[手数料推定][topic fee estimation]法である`ConfirmationTarget::MaximumFeeEstimate`を追加します。
  このPRはまた、`ConfirmationTarget::OnChainSweep`を`UrgentOnChainSweep`と
  `NonUrgentOnChainSweep`に分割し、時間に敏感な強制閉鎖（[HTLC][topic htlc]の期限切れなど）と
  緊急性のない強制閉鎖を区別します。

- [HWI #742][]は、Trezor Safe 5ハードウェア署名デバイスのサポートを追加します。

- [BIPs #1657][]は、[BIP353][]を使用する場合の[DNSSEC][dnssec]証明用に
  [PSBT][topic psbt]アウトプットに新しい標準フィールドを追加します。ハードウェア署名者などの外部デバイスは、
  PSBTアウトプットを調べて、[RFC 9102][rfc9102]形式の証明を取得することができます。
  これにより、有効な証明のみが受け入れられるように時間的制約が適用されます。
  ニュースレター[#307][news307 bip353]をご覧ください。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30454,30664,30779,30785,30763,30777,30752,30753,30754,30749,30653,30739,30740,30744,30734,30738,30731,30508,30729,30712,22838,2865,9009,3268,742,1657" %}
[Core Lightning 24.08]: https://github.com/ElementsProject/lightning/releases/tag/v24.08
[LND v0.18.3-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta.rc2
[BDK 1.0.0-beta.2]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.2
[bitcoin core 28.0rc1]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[voskuil spv]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/28
[voskuil spv dev]: https://mailing-list.bitcoindevs.xyz/bitcoindev/72e83c31-408f-4c13-bff5-bf0789302e23n@googlegroups.com/
[poinsot cache]: https://mailing-list.bitcoindevs.xyz/bitcoindev/wg_er0zMhAF9ERoYXmxI6aB7rc97Cum6PQj4UOELapsHVBBVWktFeOZT7sHDlyrXwJ5o5s9iMb2LW2Od-qacywsh-86p5Q7dP3XjWASXcMw=@protonmail.com/
[bitcoin paper]: https://bitcoincore.org/bitcoin.pdf
[poinsot spv]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/41
[lerner commitment]: https://bitslog.com/2018/06/09/leaf-node-weakness-in-bitcoin-merkle-tree-design/
[towns depth]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/43
[merli stratumfees]: https://delvingbitcoin.org/t/pplns-with-job-declaration/1099
[merli paper]: https://github.com/demand-open-source/pplns-with-job-declaration/blob/bd7258db08e843a5d3732bec225644eda6923e48/pplns-with-job-declaration.pdf
[kolobov cat]: https://mailing-list.bitcoindevs.xyz/bitcoindev/04b61777-7f9a-4714-b3f2-422f99e54f87n@googlegroups.com/
[news296 cleanup]: /ja/newsletters/2024/04/03/#revisiting-consensus-cleanup
[news316 cmake]: /ja/newsletters/2024/08/16/#bitcoin-core-cmake
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[news211 bip389]: /ja/newsletters/2022/08/03/#multiple-derivation-path-descriptors
[news258 bip389]: /ja/newsletters/2023/07/05/#bips-1354
[news232 async]: /ja/newsletters/2023/01/04/#eclair-2464
[dnssec]: https://ja.wikipedia.org/wiki/DNS_Security_Extensions
[rfc9102]: https://datatracker.ietf.org/doc/html/rfc9102
[news307 bip353]: /ja/newsletters/2024/06/14/#bips-1551
[ldk 0.0.124]: https://github.com/lightningdevkit/rust-lightning/releases
