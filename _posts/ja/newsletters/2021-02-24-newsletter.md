---
title: 'Bitcoin Optech Newsletter #137'
permalink: /ja/newsletters/2021/02/24/
name: 2021-02-24-newsletter-ja
slug: 2021-02-24-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレーターでは、Taprootのソフトフォークのアクティベーションパラメーターの選択に関する議論の結果の説明と、
Bitcoin Stack Exchangeから選ばれた質問と回答、リリースとリリース候補および、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点を掲載した通常のセクションを掲載しています。

## ニュース

- **Taprootのアクティベーションに関する議論:** Michael Folksonは、
  [Taproot][topic taproot]のアクティベーションパラメーターに関する2回目のミーティングの[概要][folkson lot]を説明し、
  ノードにフォークのアクティベーションを強制するシグナリングを必要とするかどうかを決定する[BIP8][]のLockinOnTimeout (LOT)パラメーターについては、
  "LOT=trueとするかLOT=falseとするか圧倒的な合意は得られなかった"と結論づけました。
  しかし、他のアクティベーションパラメーターについては、ほぼ全体的な合意があり、
  特にフォークのアクティベーションに必要なシグナルのハッシュレートの量が95%から90%に削減されたことが注目されます。

    LOTパラメーターについては、主にコマンドラインオプションや使用するソフトウェアリリースを選択することで、
    ユーザー自身がオプションを選択するように促す効果について、メーリングリストで議論が続けられました。
    この記事を書いている時点では明確な合意には達しておらず、Taproot自体はほぼ望まれているように見えるものの、
    Taprootをアクティベートするための方法については広く受け入れられていないようです。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・答えを紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--is-sharding-a-good-alternative-to-multisig-->シャーディングはマルチシグの良い代替手段ですか？]({{bse}}102007)
  ユーザーS.O.Sは、シャミアの秘密分散（SSS）のようなシャーディング方式でマルチシグのような機能を実現することの可能性について質問しています。
  Pieter Wuilleは、SSSに対する`OP_CHECKMULTISIG`の利点（アカウンタビリティ、1台のマシン上で秘密鍵を再構築する必要がない）、
  `OP_CHECKMULTISIG`に対するSSSの利点（手数料が少なく、プライバシーは強い）および、
  [Schnorr署名][topic schnorr signatures]を利用した場合の考慮事項（アカウンタビリティは欠如するが、1台のマシンで秘密鍵を再構築する必要はなく、
  手数料が少なく、プライバシーは強い、複雑さは増す）を指摘しています。

- [<!--can-a-channel-be-closed-while-the-funding-tx-is-still-stuck-in-the-mempool-->ファンディング・トランザクションがまだmempoolにある状態で、チャネルを閉じることができますか？]({{bse}}102180)
  LNチャネルを開こうとしたものの、ファンディング・トランザクションの手数料率を低く設定してしまったため、
  PyrolitePancakeは、ファンディング・トランザクションがmempoolに残っている状態でチャネルを閉じることについて質問しています。
  １つの選択肢は、トランザクションを再ブロードキャストするなどして承認を待ちチャネルオープンを続けることですが、
  Rene Pickhardtは、ファンディング・トランザクションのインプットを二重使用することでmempoolから削除されることに言及しています。
  ファンディング・トランザクションを再ブロードキャストする方法、
  二重使用トランザクションを作成する方法のいずれも、cdeckerによってC-lightning用にサンプルコマンドが提供されています。

- [<!--with-peerblockfilters-1-hundreds-of-btcwire-0-5-0-neutrino-connections-are-downloading-tb-from-my-bitcoin-node-->peerblockfilters=1にすると何百もの“btcwire 0.5.0/neutrino”接続が、私のBitcoinノードからTBのダウンロードをします]({{bse}}102263)
  qertoipは、[Compact Block Filter][topic compact block filters]を有効にしてBitcoin Core 0.21.0を実行すると、
  `btcwire 0.5.0/neutrino`というユーザーエージェントから多数の接続（75%）と帯域幅使用量（90%）があることに気付きます。
  Murchは、これらのピアはLNDノードであり、Compact Block FilterはBitcoin Coreの[新機能][news132 0.21.0]で、
  かつ[デフォルトでは無効になっている][news98 18877]ため、現在ネットワーク上でピアにCompact Block Filterを提供するノードが不足しており、
  その結果、それをサポートするノードへのトラフィックが高くなっている可能性があることを指摘しています。

- [<!--is-there-dumpwallet-output-documentation-explanation-->`dumpwallet`の出力に関するドキュメントや説明はありますか？]({{bse}}101767)
  Andrew Chowは、この機会に、`dumpwallet`RPCの出力の説明を回答しています。

- [<!--is-there-something-about-bitcoin-that-prevents-implementing-the-same-privacy-protocols-of-monero-and-zcash-->BitcoinにMoneroやZcashと同様のプライバシープロトコルを実装することを妨げるものはありますか？]({{bse}}101868)
  Pieter Wuilleは、MoneroやZcashが採用しているプライバシー強化のアプローチについて、開発者が取り組むことを選択しない理由や、
  エコシステムがそのサポートを選択しない理由についていくつかの課題を挙げています。
  考慮すべき点としては、"オプトイン"アプローチの欠点や、新しい暗号セキュリティの前提条件の導入、
  スケーラビリティの懸念、供給量の監査可能性の問題などが挙げられています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.12.1-beta][LND 0.12.1-beta]は、LNDの最新のメンテナンスリリースです。
  誤ってチャネルが閉鎖される可能性があるエッジケースと、一部の支払いが不必要に失敗する可能性があるバグの修正に加えて、
  いくつかのマイナーな改善とバグ修正が行われています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #19136][]は、アドレスの公開鍵を含むウォレットの
  [output script descriptor][topic descriptors]を含む新しい`parent_desc`フィールドで
  `getaddressinfo` RPCを拡張しています。ウォレットの[BIP32][]パスは、
  すべての強化導出プレフィックスが除去され、公開鍵の導出手順のみが残ります。
  これにより、アドレスとその兄弟アドレスが受信したビットコインを監視可能な他のウォレットソフトウェアに
  descriptorをインポートすることができます。

- [Bitcoin Core #15946][]では、`prune`と`blockfilterindex`の両方の設定オプションを同時に使用して、
  プルーニングされたノードで[Compact Block Filter][topic compact block filters]を保持することが可能になりました
  （`peerblockfilters`設定オプションが使用されている場合は、フィルターの提供もされます）。LNDの開発者は、
  これは自社のソフトウェアにとって有益で、将来のアップデートではウォレットをインポートするために、ウォレットロジックがBlock Filterを使用して
  プルーニングされたノードが再ダウンロードする必要がある履歴ブロックを判断できるようにすることも可能になると[指摘しています][osuntokun request]。

- [Eclair #1693][]および[Rust-Lightning #797][]は、ノードアドレスの通知の処理方法を変更しています。
  現在の[BOLT7][]の仕様では、通知内のアドレスのソートが必要ですが、一部の実装ではこのルールを使用していなかったり、
  適用していませんでした。Eclairはソートをするよう実装を更新し、Rust-Lightningはソートを要求しないよう実装を更新しました。
  仕様を更新するための[PR][bolts #842]が公開されましたが、具体的にどのような変更を行うべきかはまだ議論中です。

- [HWI #454][]は、`displayaddress`コマンドを更新し、
  BitBox02デバイスでのマルチシグアドレス登録のサポートを追加しています。

- [BIPs #1052][]は、BitcoinのP2Pプロトコルに`disabletx`メッセージを追加する提案に[BIP338][]を割り当てました。
  接続確立中にこのメッセージを送信したノードは、その接続でトランザクションを要求したり通知したりしないことを相手のピアに通知します。
  [ニュースレター #131][news131 disabletx]で説明したように、これによりピアは、現在の最大接続数125を超える追加接続を受け入れるなど、
  無効な中継接続に異なる制限を使用できるようになります。1月12日のP2P開発者ミーティングの[議論の要約][2021-01-12 p2p summary]も参照ください。

{% include references.md %}
{% include linkers/issues.md issues="1052,454,19136,15946,1693,797,842,798" %}
[LND 0.12.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.12.1-beta
[folkson lot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018425.html
[2021-01-12 p2p summary]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/P2P-IRC-meetings#topic-disabletx-p2p-message-sdaftuar
[osuntokun request]: https://github.com/bitcoin/bitcoin/pull/15946#issuecomment-571854091
[news131 disabletx]: /ja/newsletters/2021/01/13/#disabletx
[news132 0.21.0]: /ja/newsletters/2021/01/20/#bitcoin-core-0-21-0
[news98 18877]: /en/newsletters/2020/05/20/#bitcoin-core-18877
