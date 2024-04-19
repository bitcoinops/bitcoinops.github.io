---
title: 'Bitcoin Optech Newsletter #183'
permalink: /ja/newsletters/2022/01/19/
name: 2022-01-19-newsletter-ja
slug: 2022-01-19-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin開発者のための新しい法的防衛基金の発表と、
提案中の`OP_CHECKTEMPLATEVERIFY`のソフトフォークに関する最近の議論のまとめを掲載しています。
また、サービスやクライアントソフトウェアの最近の変更のまとめや、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更点の概要など、
恒例のセクションも含まれています。

## ニュース

- **BitcoinとLNの法的防衛基金:** Jack DorseyとAlex MorcosおよびMartin Whiteは、
  Bitcoin-Devメーリングリストに、BitcoinとLNおよび関連技術に取り組む開発者のための法的防衛基金の発表を[投稿しました][dmw legal]。
  この基金は、「ソフトウェア開発者がBitcoinや関連プロジェクトを積極的に開発することを妨げる法的な頭痛の種を最小限に抑えることを目的とした
  非営利団体」とのことです。

- **OP_CHECKTEMPLATEVERIFYの議論:** Bitcoinに[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]
  (CTV) opcodeを追加するソフトフォークの提案は、今週Bitcoin-DevメーリングリストとIRCのミーティングの両方で議論されました。

  - *<!--mailing-list-discussion-->メーリングリストでの議論:* Peter Toddは、
    （彼曰く、これまでの機能追加のソフトフォークのように）ほぼすべてのBitcoinユーザーに利益をもたらすものではないこと、
    新しいサービス拒否のベクトルが発生する可能性があること、CTVの提案されたユースケースの多くは仕様が不明で、
    （おそらく）実際に広く展開するには複雑すぎることなど、この提案に対するいくつかの懸念を[投稿しました][todd ctv]。

    CTVの作者であるJeremy Rubinは、DoS攻撃に関する懸念に対処するためのコードの更新とドキュメントの改善に[言及しました][rubin ctv reply]。
    また、少なくとも2つのウォレットが（そのうち1つは広く使われている）、
    CTVが提供する機能の少なくとも1つを使用する予定であることを指摘しました。
    この記事を書いている時点では、Rubinの回答がPeter Toddの懸念を実質的に満たしているかどうかは不明です。

  - *IRCのミーティング:* [ニュースレター #181][news181 ctv meets]でお知らせしたように、
    RubinはCTVについて議論する一連のミーティングの第一回目を開催しました。
    [ミーティングのログ][log ##ctv-bip-review]とRubinが提供した[まとめ][rubin meeting summary]が公開されています。
    ミーティングの参加指者の何人かは明確にこの提案に賛成していましたが、
    他の何人かは少なくともPeter Toddの前のメールと同様、技術的な疑念を表明していました。
    次回のミーティングでは、CTVのいくつかの適用について詳しく見ていくことが提案されており、
    それが本当に多くのBitcoinユーザーにメリットをもたらす説得力のあるユースケースを提供するかどうかを調査するのに役立つと思われます。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Cash AppがLightningをサポート:**
  Cash AppがLightning Networkを使用した支払いの送信をサポートするようになりました。

- **LNP Nodeが初のmainnetのチャネルを開設:**
  新しいLightning Networkのノードソフトウェア[LNP Node][lnp node github]が、
  [初のLNチャネル][lnp tweet]を開設しました。
  LNP NodeはRustで書かれており、
  LNと将来のLNのアップグレードとLN上の追加プロトコルを可能にする「Bifrost」と総称されるLNの拡張をサポートしています。

- **SamouraiがTaprootをサポート:**
  Samourai [v0.99.98][samourai v0.99.98]およびSamourai [Dojo v1.13.0][samourai dojo v1.13.0]は、
  （[bitcoinjs-lib][bitcoinjs-lib github]ライブラリにより）P2TRの[bech32m][topic bech32]アドレスをサポートしました。

- **ブロックエクスプローラ Mempool v2.3.0 リリース:**
  Mempool [v2.3.0][mempool v2.3.0]および[mempool.space][mempool.space]ウェブサイトでは、
  バージョンとロックタイムのデータ、Hex値のトランザクションのブロードキャスト機能、
  「Taprootアウトプットを使用するトランザクション用のタグ」などの機能が追加されました。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Eclair #2063][]は、[BOLTs #912][]([ニュースレター #182][news182 bolts912]参照)でLNプロトコルに追加された
  新しい`option_payment_metadata`インボイスフィールドをサポートし、
  Eclairで作成されたインボイスに暗号化された支払いのメタデータを含めることができるようになりました。
  新しいフィールドを理解する支払人は、ネットワークを介してルーティングする支払いにそのペイロードを含め、
  Eclairがデータを復号し、そのデータを使用して支払いを受け入れるために必要なすべての情報を再構築できるようにします。
  将来すべての支払人がこの機能をサポートするようになると、
  [ステートレスインボイス][topic stateless invoices]を使用することが可能になり、
  支払いを受け取るまで重要なインボイスの詳細をデータベースに保存することなくEclairを実行し、
  無駄なストレージの消費をなくし、インボイス作成のサービス拒否攻撃を防止することができるようになります。

- [LDK #1013][]は、[BOLTs #950][]([ニュースレター #182][news182 warning msgs]参照)で導入された警告メッセージの作成と処理をサポートします。

- [LND #6006][]は、ユーザーがトランザクションに署名したいだけの場合に、
  LNDがフルノードやNeutrino軽量クライアントに接続する必要性をなくしました。
  これによりLNDの署名処理を、インターネットに直接接続されていないコンピューターで効果的に実行することができます。

- [Rust Bitcoin #590][]は、ECDSA署名と[Schnorr署名][topic schnorr signatures]の両方で
  同じ[HD鍵マテリアル][topic bip32]を使用することを簡単にするAPI互換のない変更を行いました
  （注：アプリケーションは、異なる署名アルゴリズムで異なるHD鍵パスを使用すべきです。[ニュースレター #157][news157 p4tr bip32]参照）。
  [Rust Bitcoin #591][]では、引き続き互換を保持する作業を追加しています。

- [Rust Bitcoin #669][]は、[PSBT][topic psbt]コードを拡張し、
  部分署名（有効なトランザクションを作成するのに必要だが、それだけでは不十分な署名）に関する情報を保持するためのデータタイプを追加しました。
  以前は、署名は単にそのままバイトデータとして保存されていましたが、この新しいデータにより、
  部分署名に対する追加の演算を実行しやすくなりました。PRの議論では、
  署名をしたくない署名者が空のバイト列（["nulldummy"][bip147]）をPSBTに入れるべきかどうかという[興味深いコメント][poelstra nulldummy]もありました。

{% include references.md %}
{% include linkers/issues.md v=1 issues="2063,912,1013,6006,590,591,669,950" %}
[poelstra nulldummy]: https://github.com/rust-bitcoin/rust-bitcoin/pull/669#issuecomment-1008021007
[dmw legal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019741.html
[todd ctv]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019738.html
[rubin ctv reply]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019739.html
[rubin meeting summary]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019744.html
[news181 ctv meets]: /ja/newsletters/2022/01/05/#bip119-ctv
[news182 bolts912]: /ja/newsletters/2022/01/12/#bolts-912
[news157 p4tr bip32]: /ja/newsletters/2021/07/14/#use-a-new-bip32-key-derivation-path-bip32
[log ##ctv-bip-review]: https://gnusha.org/ctv-bip-review/2022-01-11.log
[lnp node github]: https://github.com/LNP-BP/lnp-node
[lnp tweet]: https://twitter.com/dr_orlovsky/status/1473768786750750733
[samourai v0.99.98]: https://docs.samourai.io/en/wallet/releases#v09998
[samourai dojo v1.13.0]: https://code.samourai.io/dojo/samourai-dojo/-/blob/develop/RELEASES.md#samourai-dojo-v1130
[bitcoinjs-lib github]: https://github.com/bitcoinjs/bitcoinjs-lib
[mempool v2.3.0]: https://github.com/mempool/mempool/releases/tag/v2.3.0
[mempool.space]: https://mempool.space/
[news182 warning msgs]: /ja/newsletters/2022/01/12/#bolts-950
