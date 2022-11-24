---
title: 'Bitcoin Optech Newsletter #227'
permalink: /ja/newsletters/2022/11/23/
name: 2022-11-23-newsletter-ja
slug: 2022-11-23-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin Stack Exchangeから選ばれた質問と回答、
新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更など
恒例のセクションが含まれています。

## ニュース

*今週は、Bitcoin-DevメーリングリストやLightning-Devメーリングリストには目立ったニュースはありませんでした。*

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--did-the-p2sh-bip-0016-make-some-bitcoin-unspendable-->P2SH BIP-0016で一部のBitcoinが使用不能になりましたか？]({{bse}}115803)
  ユーザーbca-0353f40eは、[BIP16][]のアクティベーションの前に、
  P2SHのスクリプト形式`OP_HASH160 OP_DATA_20 [hash_value] OP_EQUAL`で存在した6つのアウトプットを挙げています。
  これらのアウトプットの内１つは、アクティベーション前の古いルールの下で使用され、P2SHのアクティベーションコード内に
  その単一のブロックのための[例外が作られました][p2sh activation exception]。
  この例外を除いて、アクティベーションはジェネシスブロックまで遡って適用されるため、
  残りのUTXOを使用するにはBIP16のルールを満たす必要がります。

- [<!--what-software-was-used-to-make-p2pk-transactions-->P2PKトランザクションの作成にはどのようなソフトウェアが使用されたのでしょうか？]({{bse}}115962)
  Pieter Wuilleは、P2PKアウトプットはコインベーストランザクションと[pay-to-IPアドレス][wiki p2ip]を使用して送信する際に、
  オリジナルのBitcoinソフトウェアを使用して作成されたと述べています。

- [<!--why-are-both-txid-and-wtxid-sent-to-peers-->なぜtxidとwtxidの両方がピアに送られるのですか？]({{bse}}115907)
  Pieter Wuilleは、[BIP339][]に言及し、wtxidを使用するのがリレーには適しているが（とりわけmalleabilityのため）、
  一部のピアは新しいwtxid識別子をサポートしておらず、後方互換性のためにBIP339以前の古いピアのためにtxidがサポートされていると説明しました。

- [<!--how-do-i-create-a-taproot-multisig-address-->Taprootマルチシグアドレスはどうやったら作れますか？]({{bse}}115700)
  Pieter Wuilleは、Bitcoin Coreの既存の[マルチシグ][topic multisignature]RPC（`createmultisig`や`addmultisigaddress`など）は、
  レガシーウォレットしかサポートしないと指摘し、Bitcoin Core 24.0で、ユーザーは[ディスクリプター][topic descriptors]や
  RPC（`deriveaddresses`や`importdescriptors`など）で新しい`multi_a`ディスクリプターを使用して
  [Taproot][topic taproot]と互換性のあるマルチシグスクリプトを作成できるようになるだろうと説明しています。

- [<!--is-it-possible-to-skip-initial-block-download-ibd-on-pruned-node-->プルーニングノードでIBD（Initial Block Download）をスキップすることは可能ですか？]({{bse}}116030)
  現在Bitcoin Coreではサポートされていませんが、Pieter Wuilleは、
  ハードコードされたハッシュによって検証可能なUTXOセットをフェッチすることで新しいノードのブートストラップを可能にする
  [assumeutxo][topic assumeutxo]プロジェクトについて指摘しています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.15.5-beta.rc2][]は、LNDのメンテナンスリリース用のリリース候補です。
  リリースノートによると、マイナーなバグ修正のみが含まれています。

- [Core Lightning 22.11rc2][]は、CLNの次のメジャーバージョンのリリース候補です。
  CLNのリリースでは引き続き[セマンティック バージョニング][semantic versioning]を使用していますが、
  このリリースは新しいバージョン番号体系を使用する最初のリリースです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #25730][]は、新しい引数で`listunspent`を更新し、
  結果に未成熟のアウトプット（ブロックのマイナーのコインベーストランザクションに含まれ、
  まだ100ブロック未満しか経過していないため使用することのできないアウトプット）を含めることができます。

- [LND #7082][]は、要求金額のないインボイスを作成する方法を更新し、
  支払人が受取人への経路を見つけるのに役立つルートヒントを含められるようになりました。

- [LDK #1413][]は、オリジナルの固定長のオニオンデータフォーマットのサポートを削除しました。
  アップグレードされた可変長フォーマットは、3年以上前に仕様に追加されており、
  旧バージョンのサポートはすでに仕様から削除されています（[ニュースレター #220][news220 bolts962]参照）。
  Core Lightning（[ニュースレター #193][news193 cln5058]）、LND（[ニュースレター #196][news196 lnd6385]）、
  Eclair（[ニュースレター #217][news217 eclair2190]）。

- [HWI #637][]は、Ledgerデバイス用のBitcoin関連ファームフェアのメジャーアップグレードの計画のサポートを追加しました。
  このPRには含まれていませんが、将来の計画的な研究として、
  [ニュースレター #200][news200 policy]で言及したポリシー管理の研究が掲載されています。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25730,7082,1413,637" %}
[bitcoin core 24.0]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[lnd 0.15.5-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.5-beta.rc2
[core lightning 22.11rc2]: https://github.com/ElementsProject/lightning/releases/tag/v22.11rc2
[news220 bolts962]: /ja/newsletters/2022/10/05/#bolts-962
[news217 eclair2190]: /ja/newsletters/2022/09/14/#eclair-2190
[news193 cln5058]: /ja/newsletters/2022/03/30/#c-lightning-5058
[news196 lnd6385]: /ja/newsletters/2022/04/20/#lnd-6385
[news200 policy]: /ja/newsletters/2022/05/18/#miniscript
[semantic versioning]: https://semver.org/spec/v2.0.0.html
[wiki p2ip]: https://en.bitcoin.it/wiki/IP_transaction
[p2sh activation exception]: https://github.com/bitcoin/bitcoin/commit/ce650182f4d9847423202789856e6e5f499151f8
