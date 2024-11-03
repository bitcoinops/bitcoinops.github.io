---
title: 'Bitcoin Optech Newsletter #215'
permalink: /ja/newsletters/2022/08/31/
name: 2022-08-31-newsletter-ja
slug: 2022-08-31-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、ウォレットラベルのエクスポートフォーマットの標準化の提案に加えて、
Bitcoin StackExchangeの最近の質問と回答の概要や、新しいリリースおよびリリース候補のリスト、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など恒例のセクションを掲載しています。

## ニュース

- **<!--wallet-label-export-format-->ウォレットラベルのエクスポートフォーマット:** Craig Rawは、Bitcoin-Devメーリングリストに、
  アドレスやトランザクションのラベルをエクスポートするためにウォレットが使用するフォーマットを標準化するためのBIPの提案を[投稿しました][raw interchange]。
  エクスポートフォーマットが標準化されると、理論的には、
  同じ[BIP32][topic bip32]のアカウント階層を使用する2つのウォレットソフトウェアが、
  互いのバックアップを用いて、資金だけでなく、ユーザーがトランザクションについて手動で入力したすべての情報を復元できます。

  BIP32ウォレット間で互換性を持たせるというこれまでの課題を考えると、
  おそらくより実現可能な用途は、ウォレットから取引履歴をエクスポートし、会計プログラムなど他のプログラムでの利用を簡単にすることでしょう。

  開発者のClark MoodyとPavol Rusnakは、[それぞれ][moody slip15]Trezorブランドのウォレット用に開発された
  オープンなエクスポートフォーマットを掲載した[SLIP15][]への[参照][rusnak slip15]を回答しました。
  Craig Rawは、自身が提案するフォーマットが実現しようとしていることと、
  SLIP15が提供していることの間にいくつかの大きな違いがあることを[指摘しました][raw slip15]。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-isn-t-it-possible-to-add-an-op-return-commitment-or-some-arbitrary-script-inside-a-taproot-script-path-with-a-descriptor-->ディスクリプターを使用して、Taprootのscript-path内にOP_RETURNを使ったコミットメント（または任意のスクリプト）を追加できないのは何故ですか？]({{bse}}114948)
  Antoine Poinsotは、[スクリプト・ディスクリプター][topic descriptors]は
  現在Bitcoin Coreで[Miniscript][topic miniscript]を使用するために拡張されており、
  Bitcoin Core 24.0でのリリースが期待されています。
  Miniscriptの初期機能は、segwit v0のサポートのみですが、
  最終的には、[Tapscript][topic tapscript]と[部分的なディスクリプター][Bitcoin Core #24114]のサポートにより、
  `raw()`ディスクリプターを使用することなくTapscript内にコミットメントを追加することが可能になる見込みです。

- [<!--why-does-bitcoin-core-rebroadcast-transactions-->何故Bitcoin Coreはトランザクションを再ブロードキャストするのですか？]({{bse}}114973)
  Amir reza Riahiは、Bitcoin Coreのウォレットがなぜトランザクションを再ブロードキャストするのか、
  そして何故遅延が発生するのか不思議に思っていました。
  Pieter Wuilleは、再ブロードキャストが必要な理由としてP2Pネットワークのトランザクションの伝播保証の欠如を指摘し、
  ウォレットからmempoolへの再ブロードキャストの責任を取り除くために行われた作業について言及しました。
  再ブロードキャストに関心のある方は、[2022年8月24日][prreview 25768]と[2021年4月7日][prreview 21061]、
  [2019年11月27日][prreview 16698]のPR Review Clubのミーティングもご覧ください。

- [<!--when-did-bitcoin-core-deprecate-the-mining-function-->Bitcoin Coreはマイニング機能をいつ非推奨にしたのですか？]({{bse}}114687)
  Pieter Wuilleは、Bitcoin Core内のマイニング関連の機能の歴史的な概要を提供しています。

- [<!--utxo-spendable-by-me-or-deposit-to-exchange-after-5-years-->自分だけが使用できるか、取引所にデポジットして5年後に使用できるUTXOについて]({{bse}}114901)
  Stickies-vは、Bitcoin Scriptの命令の概要を説明し、
  [MAST][topic mast]を可能にした[Taproot][topic taproot]がプライバシーと手数料率の観点から使用条件をどのように改善するかについて説明し、
  現在のスクリプトには[Covenants][topic covenants]の機能がないため、提案された条件はスクリプトだけでは不可能であると指摘しています。
  Vojtěch Strnadは、事前署名されたトランザクションが提案されたた使用条件の実現に役立つと指摘しています。

- [<!--what-was-the-bug-for-the-bitcoin-value-overflow-in-2010-->2010年に発生したBitcoinの値がオーバーフローするバグは何だったのか？]({{bse}}114694)
  Andrew Chowは、[値のオーバーフローバグ][value overflow bug]と、その複数のインフレーションの影響（作成された巨大なアウトプットとトランザクション手数料の計算間違い）をまとめました。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.15.1-beta][]は、「[ゼロ承認チャネル][topic zero-conf channels]、SCID[エイリアス][aliases]および、
  どこでも[Taproot][topic taproot]アドレスを使用するための切り替えを含む」リリースです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #23202][]は、`psbtbumpfee`RPCを拡張し、
  トランザクションのインプットの一部もしくは全部がウォレットに属さない場合でも、
  手数料を引き上げる[PSBT][topic psbt]を作成できるようにしました。
  このPSBTは、その後それに署名できるウォレットと共有することができます。

- [Eclair #2275][]は、[デュアルファンド][topic dual funding]のLNセットアップトランザクションの手数料の引き上げをサポートしました。
  このPRでは、「デュアル・ファンディングがEclairで完全にサポートされます！」と記載されています。
  ただし、デュアル・ファンディングはデフォルトでは無効であり、
  [Core Lightningとの相互互換性][news143 cln df]のテストが将来追加される予定であることも記載されています。

- [Eclair #2387][]は、[Signet][topic signet]をサポートしました。

- [LDK #1652][]は、[Onionメッセージ][topic onion messages]のサポートをアップデートし、
  返信パスを送信し、受信時にそれをデコードできるようになりました。
  Onionメッセージプロトコルでは、Onionメッセージを中継するノードが中継後にそのメッセージに関する情報を追跡する必要がないため、
  元のメッセージが通ってきた経路で自動的に応答を送信することができません。
  そのため、Onionメッセージに対する返信を希望するノードは、返信を送信するためにどのような経路を使用するかのヒントを受信者に提供する必要があることを意味します。

- [HWI #627][]は、BitBox02ハードウェア署名デバイスを使用した[P2TR][topic taproot]のkeypath支払いをサポートしました。

- [BDK #718][]は、ウォレットがECDSAと[Schnorr][topic schnorr signatures]署名の作成後すぐに署名の検証をするようになりました。
  これは、[BIP340][]の推奨で（[ニュースレター #87][news87 verify]参照）、
  [ニュースレター #83][news83 verify]で議論され、
  以前Bitcoin Coreで実装されました（[ニュースレター #175][news175 verify]参照）。

- [BDK #705][]と[#722][bdk #722]は、BDKライブラリを使用するソフトウェアに、
  ElectrumおよびEsploraサービスから利用可能な追加のサーバーサイドメソッドにアクセスする機能を提供します。

{% include references.md %}
{% include linkers/issues.md v=2 issues="23202,2275,2387,1652,627,718,705,722,24114" %}
[lnd 0.15.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.1-beta
[news175 verify]: /ja/newsletters/2021/11/17/#bitcoin-core-22934
[news87 verify]: /ja/newsletters/2020/03/04/#bips-886
[news83 verify]: /ja/newsletters/2020/02/05/#schnorr
[raw interchange]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020887.html
[moody slip15]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020888.html
[rusnak slip15]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020892.html
[raw slip15]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020893.html
[aliases]: /ja/newsletters/2022/07/13/#lnd-5955
[slip15]: https://github.com/satoshilabs/slips/blob/master/slip-0015.md
[news143 cln df]: /ja/newsletters/2021/04/07/#c-lightning-0-10-0
[prreview 25768]: https://bitcoincore.reviews/25768
[prreview 21061]: https://bitcoincore.reviews/21061
[prreview 16698]: https://bitcoincore.reviews/16698
[value overflow bug]: /en/topics/soft-fork-activation/#fix-value-overflow-bug-august-2010
