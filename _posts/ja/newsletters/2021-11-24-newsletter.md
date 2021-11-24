---
title: 'Bitcoin Optech Newsletter #176'
permalink: /ja/newsletters/2021/11/24/
name: 2021-11-24-newsletter-ja
slug: 2021-11-24-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LNユーザーがより高い手数料かより高い信頼性を選択できるようにする
方法についての議論のリンクを掲載しています。また、Bitcoin Stack Exchangeから人気のある質問と回答や、
新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点の要約など、
恒例のセクションも含まれています。

## ニュース

- **LNの信頼性と手数料のパラメータ化:** Joost Jagerは、Lightning-Devメーリングリストで、
  より速い支払いのために多くの手数料を支払うか、節約するために長く待つかを、
  ユーザーが選択できるようにするにはどうしたらいいかという[スレッド][jager params]を立ち上げました。
  このスレッドで議論されている課題の１つは、これらの単一の尺度で表されるユーザーの設定を、
  経路探索アルゴリズムによって返される複数の要素からなる経路に関連付ける方法です。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-is-it-important-that-nonces-when-signing-not-be-related-->署名時にnonceの関連性がないことが重要なのは何故ですか？]({{bse}}110811)
  Pieter Wuilleは、同じ公開鍵に対して2回署名する際に、同じnonce、既知のオフセットを持つnonce、
  既知のファクターを持つnonceを使った場合に、どのように秘密鍵の情報が漏洩するかを数学的に説明しています。
  また、Wuilleは、悪用不可能なnonce生成のための3つの手法と、壊れている2つの手法を挙げ、
  安全であると知られていない技術と壊れていると知られていない技術には大きなギャップがあることを指摘しています。

- [<!--how-could-a-2-byte-witness-program-make-sense-->2バイトのwitness programにはどんな意味がありますか？]({{bse}}110660)
  witness programが2〜40バイトであるという[BIP141][]の要件について議論し、
  Kalle Rosenbaumは、2バイトのサイズのwitness programの潜在的な使用例を検討しています。

- [<!--what-is-the-xpriv-xpub-type-for-p2tr-->P2TRのxpriv/xpubタイプは何ですか？]({{bse}}110733)
  Andrew Chowは、より多様で複雑なScriptが広く使われるようになってきていることと、懸念事項の分離という理由から、
  Taproot版のxpub/ypub/zpubに相当するものは存在しないと指摘しています。
  彼は、「作成するScriptがTaprootであることを示す何らかの情報（例：`tr()` descriptorなど）を付加したxpriv/xpubを使用する」
  ことを推奨しています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.14.0-beta][]は、[エクリプス攻撃][topic eclipse attacks]対策の追加
  （[ニュースレター #164][news164 ping]参照）、リモートデータベースのサポート（[ニュースレター #157][news157 db]参照）、
  経路探索の高速化（[ニュースレター #170][news170 path]参照）、
  Lightning Poolユーザー向けの改善（[ニュースレター #172][news172 pool]参照）、
  再利用可能な[AMP][topic amp]インボイス（[ニュースレター #173][news173 amp]参照）および、
  他の多くの機能やバグ修正が含まれたリリースです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [C-Lightning #4890][]では、ユーザーがウォレットのバックアップ用のsqliteデータベースファイルの構成が可能になりました。
  動作中、すべてのデータはメインのsqliteファイルとバックアップファイルの間で複製されます。
  この新機能に関する[詳細なドキュメント][c-lightning backups]も含まれています。

- [Rust-Lightning #1173][]では、ノードが新しい着信チャネルを受け入れないようにするために使用できる新しい
  `accept_inbound_channels`設定が追加されました。デフォルトはtrueです。

- [Rust-Lightning #1166][]では、HTLCの支払額がチャネルのキャパシティの1/8を超えるチャネルにペナルティを課すことで、
  デフォルトの経路スコアリングのロジックを改善しました。支払額がチャネルキャパシティに達すると、ペナルティは線形増加します。

{% include references.md %}
{% include linkers/issues.md issues="4890,1173,1166" %}
[lnd 0.14.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.0-beta
[news164 ping]: /ja/newsletters/2021/09/01/#lnd-5621
[news157 db]: /ja/newsletters/2021/07/14/#lnd-5447
[news170 path]: /ja/newsletters/2021/10/13/#lnd-5642
[news172 pool]: /ja/newsletters/2021/10/27/#lnd-5709
[news173 amp]: /ja/newsletters/2021/11/03/#lnd-5803
[jager params]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-November/003342.html
[c-lightning backups]: https://github.com/ElementsProject/lightning/blob/163d3a9203922a0493cf6038493bd4b5e078d987/doc/BACKUP.md#sqlite3---walletmainbackup-and-remote-nfs-mount
