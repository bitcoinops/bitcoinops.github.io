---
title: 'Bitcoin Optech Newsletter #378'
permalink: /ja/newsletters/2025/10/31/
name: 2025-10-31-newsletter-ja
slug: 2025-10-31-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin Coreフルノードの旧バージョンに影響する4つの脆弱性の発表を掲載しています。
また、Bitcoin Stack Exchangeで人気の質問とその回答や、新しいリリースとリリース候補の発表、
人気のBitcoinインフラストラクチャソフトウェアの注目すべき更新など
恒例のセクションも含まれています。

## ニュース

- **Bitcoin Coreにおける重大度の低い4つの脆弱性の開示:**
  Antoine Poinsotは最近、Bitcoin Core 30.0で修正された重大度の低い4つの脆弱性に関する
  Bitcoin CoreセキュリティアドバイザリをBitcoin-Devメーリングリストに[投稿しました][poinsot disc]。
  開示ポリシーに従って（[ニュースレター #306][news306 disclosures]参照）、重大度の低い脆弱性は、
  修正を含むメジャーバージョンのリリースから2週間後に公開されます。公開された4つの脆弱性は以下のとおりです:

  - [<!--disk-filling-from-spoofed-self-connections-->なりすまし自己接続によるディスク容量の枯渇][CVE-2025-54604]:
    このバグにより、攻撃者は自己接続を偽装することで、標的ノードのディスク容量を枯渇させることができます。
    この脆弱性は、2022年3月にNiklas Göggeによって[責任を持って開示されました][topic
    responsible disclosures]。Eugene SiegelとNiklas Göggeは、2025年7月に緩和策をマージしました。

  - [<!--disk-filling-from-invalid-blocks-->無効なブロックによるディスク容量の枯渇][CVE-2025-54605]:
    このバグにより、攻撃者は無効ブロックを繰り返し送信することで標的ノードのディスク容量を枯渇させることができます。
    このバグは、2022年5月にNiklas Göggeによって責任を持って開示され、
    2025年3月にはEugene Siegelによっても独立して開示されました。Eugene SiegelとNiklas Göggeは、
    2025年7月に緩和策をマージしました。

  - [<!--highly-unlikely-remote-crash-on-32-bit-systems-->32-bitシステムで極めて発生しにくいリモートクラッシュ][CVE-2025-46597]:
    このバグにより、ごく稀に、異常なブロックを受信した際にノードがクラッシュする可能性があります。
    このバグは、2025年4月にPieter Wuilleによって責任を持って開示されました。
    Antoine Poinsotが2025年6月に緩和策を実装してマージしました。

  - [<!--cpu-dos-from-unconfirmed-transaction-processing-->未承認トランザクションの処理によるCPU DoS][CVE-2025-46598]:
    このバグにより、未承認トランザクションの処理時にリソース枯渇を引き起こす可能性があります。
    このバグは2025年4月にAntoine Poinsotによってメーリングリストに報告されました。
    Pieter Wuille、Anthony Towns、およびAntoine Poinsotは、2025年8月に緩和策を実装しマージしました。

  最初の3つの脆弱性に対するパッチは、Bitcoin Core 29.1以降のマイナーリリースにも含まれています。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [なぜ-datacarriersizeは2022年に再定義され、2023年の拡張提案はなぜマージされなかったのですか？]({{bse}}128027)
  Pieter Wuilleは、`OP_RETURN`アウトプットに関連するBitcoin Coreの
  `-datacarriersize`オプションの適用範囲について歴史的な概観を提供しています。

- [<!--what-is-the-smallest-valid-transaction-that-can-be-included-in-a-block-->ブロックに含めることができる最小の有効なトランザクションは？]({{bse}}129137)
  Vojtěch Strnadは、最小の有効なBitcoinトランザクションを構成するために必要なフィールドとサイズを列挙しています。

- [なぜBitcoin Coreはwitnessデータがinscriptionで使用されている場合でも、引き続きディスカウントを適用するのでしょうか？]({{bse}}128028)
  Pieter Wuilleは、Segwitのwitnessディスカウントの根拠を説明し、
  Bitcoin CoreソフトウェアがBitcoinの現在のコンセンサスルールを実装していることを強調しています。

- [増え続けるBitcoinブロックチェーンのサイズ？]({{bse}}128048)
  Murchは、現在のUTXOセットのサイズ、プルーニングノードとフルノードのストレージ要件を記載し、
  Bitcoinブロックチェーンの現在の成長率を指摘しています。

- [OP_TEMPLATEHASHはOP_CTVの亜種であると読みましたが、両者の違いは何ですか？]({{bse}}128097)
  Reardenは、[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]と最近提案された
  `OP_TEMPLATEHASH`の提案（[ニュースレター #365][news365 op_templatehash]参照）の機能、
  効率性、互換性、そしてハッシュされるフィールドを比較しています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [LND 0.20.0-beta.rc1][]は、この人気のLNノードのリリース候補です。
  テストによって改善が期待できる改善点の1つは、以下の注目すべきコードの変更セクションで説明されている、
  ウォレット再スキャンが早期に行われる問題の修正です。詳細については[リリースノート][LND notes]をご覧ください。

- [Eclair 0.13.1][]は、このLNノード実装のマイナーリリースです。
  このリリースには、[アンカーアウトプット][topic anchor outputs]以前のチャネルの削除に向けた
  データベースの変更が含まれています。チャネルデータを最新の内部エンコーディングに移行するには、
  まずv0.13.0リリースを実行する必要があります。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #29640][]は、同じ作業量を持つ競合チェーン上のブロックに対して、
  起動時に`nSequenceId`値を最初期化します。以前に認識されていたベストチェーンに属するブロックには0、
  その他のすべてのロードされたブロックには1を設定します。これにより、
  再起動後に`nSequenceId`値が保存されていないために、
  Bitcoin Coreが競合チェーン間のタイブレークを実行できない問題が解決されます。

- [Core Lightning #8400][]は、すべての新規ノードに対してデフォルトで、
  オプションのパスフレーズ付きの`hsm_secret`用の新しい[BIP39][]ニーモニックバックアップ形式を導入します。
  同時に、既存ノードでは従来の32-byteの`hsm_secrets`のサポートを維持します。
  `Hsmtool`も更新され、ニーモニックベースと従来の両方のシークレットをサポートします。
  ウォレット用に新しい標準[Taproot][topic taproot]導出形式が導入されました。

- [Eclair #3173][]は、[アンカーアウトプット][topic anchor outputs]または
  [Taproot][topic taproot]を使用しないレガシーチャネル（`static_remotekey`または`default`チャネルとも呼ばれます）の
  サポートを削除します。バージョン0.13または0.13.1にアップグレードする前に、
  残っているレガシーチャネルをすべて閉じてください。

- [LND #10280][]は、チェーン通知機能（[ニュースレター #31][news31 chain]参照）を起動して
  ウォレットトランザクション用のチェーンの再スキャンを行う前に、ヘッダーの同期を待つようになりました。
  これにより、新しいウォレットの作成時に、ヘッダーの同期中にLNDが早期に再スキャンをトリガーする問題が解決されます。
  この問題は主に、[Neutrinoバックエンド][topic compact block filters]に影響していました。

- [BIPs #2006][]は、[BIP3][]の仕様を更新し（[ニュースレター #344][news344 bip3]参照）、
  独創性と品質に関するガイダンスを追加しました。特に、AI/LLMを用いたコンテンツの生成を控えるように著者に助言し、
  AI/LLMの使用状況を積極的に開示することを推奨しています。

- [BIPs #1975][]は、BitcoinのP2Pネットワークプロトコルにおける`addr`メッセージの新バージョンである
  [addr v2][topic addr v2]を規定する[BIP155][]を更新し、
  [Tor v2][topic anonymity networks]が現在は運用されていないという注記を追加しました。

{% include snippets/recap-ad.md when="2025-11-04 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29640,8400,3173,10280,5516,2006,1975" %}

[poinsot disc]: https://groups.google.com/g/bitcoindev/c/sBpCgS_yGws
[disc pol]: https://bitcoincore.org/ja/security-advisories/
[news306 disclosures]: /ja/newsletters/2024/06/07/#bitcoin-core
[CVE-2025-54604]: https://bitcoincore.org/ja/2025/10/24/disclose-cve-2025-54604/
[CVE-2025-54605]: https://bitcoincore.org/ja/2025/10/24/disclose-cve-2025-54605/
[CVE-2025-46597]: https://bitcoincore.org/ja/2025/10/24/disclose-cve-2025-46597/
[CVE-2025-46598]: https://bitcoincore.org/ja/2025/10/24/disclose-cve-2025-46598/
[LND 0.20.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta.rc2
[LND notes]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.20.0.md
[Eclair 0.13.1]: https://github.com/ACINQ/eclair/releases/tag/v0.13.1
[news31 chain]: /en/newsletters/2019/01/29/#lnd-2314
[news344 bip3]: /ja/newsletters/2025/03/07/#bips-1712
[news365 op_templatehash]: /ja/newsletters/2025/08/01/#taproot-op-templatehash
