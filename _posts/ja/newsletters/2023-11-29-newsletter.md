---
title: 'Bitcoin Optech Newsletter #279'
permalink: /ja/newsletters/2023/11/29/
name: 2023-11-29-newsletter-ja
slug: 2023-11-29-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Liquidity Adsの仕様の更新について掲載しています。
また、Bitcoin Stack Exchangeから厳選された質問とその回答や、
新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **Liquidity Adsの仕様の更新:** Lisa Neigutは、
  [Liquidity Ads][topic liquidity advertisements]の仕様の更新の案内を
  Lightning-Devメーリングリストに[投稿しました][neigut liqad]。
  この機能は、Core Lightningに実装され現在Eclairでも開発が進んでいる機能で、
  [デュアル・ファンディングチャネル][topic dual funding]に資金を提供する意思があることを通知することができます。
  別のノードがチャネルの開設を要求してこの申し出を受け入れた場合、
  要求したノードは申し出をしたノードに前払いの手数料を支払わなければなりません。
  これにより、インバウンドの流動性を必要とするノード（例えば、マーチャントなど）は、
  オープンソースのソフトウェアと分散型のLNゴシッププロトコルを使用して、
  その流動性を市場レートで提供することが可能な、よく接続されたピアを見つけることができます。

  この更新には、いくつかの構造上の変更に加えて、契約期間と転送手数料の上限に対する柔軟性の向上が含まれています。
  この投稿についてメーリングリスト上でいくつかの返信があり、[仕様][bolts #878]への追加の変更が予想されます。
  Neigutの投稿では、現在のLiquidity Adsとチャネルアナウンスの構造により、
  当事者が契約に違反しているあるケースを暗号学的に証明することが理論的に可能であることも指摘しています。
  契約遵守を促すために契約履行保証で使用可能な実際のコンパクトなFraud Proofを設計することは未解決の問題です。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Schnorrデジタル署名方式は、マルチシグの対話型方式であり、集約された非対話型方式でもありませんか？]({{bse}}120402)
  Pieter Wuilleは、マルチシグと署名の集約、鍵の集約、Bitcoinのマルチシグの違いを説明し、
  [BIP340][] [Schnorr署名][topic schnorr signatures]や[MuSig2][topic musig]、
  FROSTおよびBellare-Neven 2006など、いくつかの関連方式について言及しています。

- [リリース候補のフルノードをmainnetで運用することは推奨されますか？]({{bse}}120375)
  Vojtěch StrnadとMurchは、Bitcoin Coreのリリース候補をmainnet上で動作させてもBitcoin _ネットワーク_ への脅威はほとんどないものの、
  Bitcoin CoreのAPIやウォレットまたはその他の機能を利用するユーザーは、その設定に対して適切な注意とテストを行う必要があると指摘しています。

- [nLockTimeとnSequenceの関係は？]({{bse}}120256)
  Antoine PoinsotとPieter Wuilleは、`nLockTime`と`nSequence`に関する一連のStack Exchangeの質問に答えています。
  これには、[両者の関係]({{bse}}120273)や[`nLockTime`の本来の目的]({{bse}}120276)、
  [`nSequence`の潜在的な値]({{bse}}120254)、[BIP68]({{bse}}120320)と[`OP_CHECKLOCKTIMEVERIFY`]({{bse}}120259)の関係などが含まれます。

- [OP_CHECKMULTISIGに閾値（m）を超える署名を提供するとどうなりますか？]({{bse}}120604)
  Pieter Wuilleは、以前は可能だったが、[BIP147][]のダミースタック要素のマリアビリティのソフトフォークにより、
  OP_CHECKMULTISIGおよびOP_CHECKMULTISIGVERIFYで追加スタック要素を任意の値にすることができなくなったと説明しています。

- ["(mempool) ポリシー"とは何ですか？]({{bse}}120269)
  Antoine Poinsotは、Bitcoin Coreにおける _ポリシー_ と _標準_ という用語を定義し、
  いくつかの例を示しています。また、Bitcoin Optechのポリシーに関する[承認を待つ][policy series]シリーズもリンクしています。

- [Pay to Contract (P2C)とは何ですか？]({{bse}}120362)
  Vojtěch Strnadは、[Pay-to-Contract (P2C)][topic p2c]について説明し、
  [元の提案][p2c paper]もリンクしています。

- [非segwitトランザクションをsegwitフォーマットでシリアライズできますか？]({{bse}}120317)
  Pieter Wuilleは、Bitcoin Coreのいくつかの古いバージョンでは
  意図せず非segwitトランザクションに対して拡張シリアライズフォーマットが許可されていましたが、
  [BIP144][]では非segwitトランザクションは旧シリアライズフォーマットを使用しなければならないと規定していると指摘しています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning 23.11][]は、このLNノード実装の次期メジャーバージョンのリリースです。
  _rune_ 認証メカニズムへの柔軟性の追加、バックアップの検証の改善、プラグイン用の新機能が追加されています。

- [Bitcoin Core 26.0rc3][]は、主流のフルノード実装の次期メジャーバージョンのリリース候補です。
  [テストのガイド][26.0 testing]が利用可能です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Rust Bitcoin #2213][]は、手数料推定中のP2WPKHインプット処理のweightの予測を修正しました。
  Bitcoin Coreバージョン[0.10.3][bcc 0.10.3]および[0.11.1][bcc 0.11.1]以降、
  High-Sの署名を持つトランザクションは非標準とみなされているため、
  トランザクションの構築プロセスでは、シリアライズされたECDSA署名が、
  これまで使用されていた73バイトではなく、最大72バイト使用すると安全に仮定できます。

- [BDK #1190][]は、ウォレット内のすべてのアウトプット（使用済みと未使用の両方）を取得する新しい
  `Wallet::list_output`メソッドを追加しました。これまでは、未使用のアウトプットのリストを取得するのは簡単でしたが、
  使用済みのアウトプットのリストを取得するのは困難でした。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2213,1190,878" %}
[bitcoin core 26.0rc3]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Release-Candidate-Testing-Guide
[core lightning 23.11]: https://github.com/ElementsProject/lightning/releases/tag/v23.11
[neigut liqad]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-November/004217.html
[policy series]: /ja/blog/waiting-for-confirmation/
[p2c paper]: https://arxiv.org/abs/1212.3257
[bcc 0.11.1]: https://bitcoin.org/en/release/v0.11.1#test-for-lows-signatures-before-relaying
[bcc 0.10.3]: https://bitcoin.org/en/release/v0.10.3#test-for-lows-signatures-before-relaying
