---
title: 'Bitcoin Optech Newsletter #155'
permalink: /ja/newsletters/2021/06/30/
name: 2021-06-30-newsletter-ja
slug: 2021-06-30-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、Taprootのウォレットサポートに関連する２つのBIP提案の要約と、
Bitcoin Stack Exchangeから厳選された質問とその回答や、Taprootの準備方法、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更点などの恒例のセクションを掲載しています。

## ニュース

- **Taproot用のPSBT拡張:** Andrew Chowは、
  Taprootのアウトプットを使用するもしくは作成する際に使用する[PSBT][topic psbt]の新しいフィールドを定義する
  [BIPの提案][bip-taproot-psbt]をBitcoin-Devメーリングリストに[投稿しました][chow taproot psbt]。
  このフィールドは、元のバージョン0のPSBTと提案されているバージョン2のPSBT（[ニュースレター #128][news128 psbt2]参照）の両方を拡張します。
  keypathおよびscriptpathの両方の使用がサポートされています。

    また、提案されているBIPでは、Taprootがv0 segwitインプットに対する手数料の過払い攻撃への対策をしているため
    （[ニュースレター #101][news101 fee overpayment attack]参照）、
    PSBTのP2TRインプットが参照するトランザクションのコピーを省略できることを推奨しています。

- **P2TRのシングルシグ用の鍵導出パス:** Andrew Chowは
  シングルシグ用のTaprootアドレスを作成するウォレットで使用する[BIP32][]導出パスを提案する2つめの[BIP提案][bip-taproot-bip44]も
  Bitcoin-Devメーリングリストに[投稿しました][chow taproot path]。
  Chowは、このBIPがP2SHでラップしたP2WPKHアドレス用の[BIP49][]や、
  ネイティブP2WPKHアドレス用の[BIP84][]とよく似ていると指摘しています。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・答えを紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [将来のソフトフォークで潜在的に最適でない、または使用されていないopcodeを有効にすることにはどんなデメリットがありますか？]({{bse}}106851)
  G. Maxwellは、コンセンサスに影響を与えるopcodeを有効にする際に考慮すべき点を以下のようにまとめています:

    * 初期および継続的なメンテナンスコスト

    * opcodeのユーザーだけでなくネットワーク全体に対する潜在的なリスク

    * ノードソフトウェアのカスタマイズや再実装の阻害要因となる複雑さの増加

    * 将来のより良い代替機能を邪魔する部分的もしくは非効率な機能

    * 誤って逆方向のインセンティブを生み出す

- [ブロック全体の署名集約がAdaptor Signatureの妨げになるのはなぜですか？]({{bse}}107196)
  Pieter Wuilleは、横断的なインプットの署名集約が[Adaptor Signature][topic adaptor signatures]や、
  Scriptless Scriptのような技術を阻害する要因を次のように説明してます。
  「ブロック全体の署名集約をした場合、ブロック全体に対して単一の署名が存在することになります。
  その単一の署名には、複数の個別のシークレットを複数の個別の参加者に公開するためのスペースは単純に存在しません。」

- [Bitcoin Coreウォレット（または任意のウォレット）は、ユーザーがアクティベーション前にTaprootアドレスに資金を送るのを防ぐべきですか？]({{bse}}107186)
  Murchは、ウォレットソフトウェアがユーザーに将来のBIP173 segwitアウトプットタイプへの送金を許可する必要がある理由を説明しています。
  使用可能なアドレスを提供する責任を受信者に負わせることで、
  エコシステムは[bech32/bech32m][topic bech32]の上位互換性を活用して、
  新しいアウトプットタイプを即座に利用することができます。

- [Schnorr署名でwitnessが分離されているのはどうしてですか？]({{bse}}106930)
  Dalit Sairioは、[Schnorr署名][topic schnorr signatures]はECDSA署名のようなマリアビリティに悩まされないのに、
  Schnorr署名が引き続き分離されている理由について尋ねています。
  Darosiorは、マリアビリティはsegwitの多くの利点の１つに過ぎないと指摘しています。
  Pieter Wuilleは、署名のマリアビリティはより広範なスクリプトのマリアビリティの一部に過ぎないと付け加えています。

- [MuSigで可能な署名の量は？]({{bse}}106929)
  Nicklerは、[MuSig][topic musig]とMuSig2の両方において、
  署名者の数は実質的に無限であることを説明し、100万人の署名者の[ベンチマーク][nickler musig]が
  彼のラップトップ上で約130秒で実行されることを指摘しています。

- [P2WSHでラップされたP2TRアドレスのサポート？]({{bse}}106706)
  [BIP341][bip341 p2sh footnote]の衝突セキュリティの懸念に加えて、
  jnewberyは、追加のアウトプットタイプを持つことによるプライバシーの課題を指摘しています。
  また、bech32が既に広くエコシステムに採用されていることを考えると、
  ラップされたTaprootアウトプットの必要性には疑問が残ります。

## Taprootの準備 #2: Taprootはシングルシグでも価値があるか？

*ブロック高{{site.trb}}のTaprootのアクティベーションに向けて、
開発者やサービスプロバイダーがどのような準備をすればよいかについての週刊シリーズです。*

{% include specials/taproot/ja/01-single-sig.md %}

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #22154][]では、ブロック{{site.trb}}でTaprootがアクティベートされた後に、
  例えば`getnewaddress "" bech32m`を呼び出すことで、
  ユーザーがP2TRスクリプト用の[bech32m][topic bech32]アドレスを生成できるようにするコードが追加されています。
  Taprootのアクティベート後、トランザクションにbech32mアドレスが含まれている場合、
  Descriptor WalletもP2TRのお釣り用アウトプットを使用します。
  この機能は、Taproot descriptorを持つウォレットにのみ適用されます（[ニュースレター #152][news152 p2tr descriptors]参照）。

- [Bitcoin Core #22166][]では、アウトプットからTaprootの`tr()`descriptorを推論する機能が追加され、
  基本的なTaproot descriptorのサポートが完了しました。
  descriptorの推論は、`listunspent`のようなRPCコールへの応答で
  より正確な情報を提供するために使用されます。

- [Bitcoin Core #20966][]は、保存されているbanlistファイルの名前とフォーマットを
  （シリアライズされたP2Pプロトコルの`addr`メッセージをベースにした）`banlist.dat`から`banlist.json`に変更しました。
  ファイルフォーマットの変更により、Tor v3のピアや他のネットワークのピアでオリジナルの
  `addr`メッセージに含められる最大値である128 bit幅を超えるアドレスの禁止エントリを保存できるようになりました。

- [Bitcoin Core #21056][]は、`bitcoin-cli`に新しい`-rpcwaittimeout`パラメーターを追加しました。
  既存の`-rpcwait`パラメーターは、`bitcoind`サーバーが起動するまでコマンド（RPCコール）の送信を遅らせます。
  新しいパラメーターは、指定された秒数後に待機を止め、エラーを返します。

- [C-Lightning #4606][]では、
  LNDでの同様の変更（[ニュースレター #93][news93 lnd4075]参照）と次のセクションで説明する仕様変更を受けて、
  約0.043 BTC以上のインボイスの作成が可能になりました。

- [BOLTs #877][]では、実装のバグによる大きな損失を避けるために導入されたプロトコルレベルでの支払い毎の金額制限を撤廃しました。
  これは、2020年に`option_support_large_channel`が広く実装されたことを受けたもので、
  これが有効になると*チャネル毎の*金額制限がなくなります。
  この2つの制限の詳細については[Large channels][topic large channels]のトピックをご覧ください。

{% include references.md %}
{% include linkers/issues.md issues="22154,22166,20966,21056,4606,877" %}
[news128 psbt2]: /en/newsletters/2020/12/16/#new-psbt-version-proposed
[news101 fee overpayment attack]: /en/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[chow taproot psbt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-June/019095.html
[bip-taproot-psbt]: https://github.com/achow101/bips/blob/taproot-psbt/bip-taproot-psbt.mediawiki
[chow taproot path]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-June/019096.html
[bip-taproot-bip44]: https://github.com/achow101/bips/blob/taproot-bip44/bip-taproot-bip44.mediawiki
[news93 lnd4075]: /en/newsletters/2020/04/15/#lnd-4075
[news152 p2tr descriptors]: /ja/newsletters/2021/06/09/#bitcoin-core-22051
[nickler musig]: https://github.com/jonasnick/musig-benchmark
[bip341 p2sh footnote]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#cite_note-3
