---
title: 'Bitcoin Optech Newsletter #146'
permalink: /ja/newsletters/2021/04/28/
name: 2021-04-28-newsletter-ja
slug: 2021-04-28-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LNのスプライシングのドラフト仕様、
トランザクションリレーのセキュリティに関するワークショップのお知らせ、
libsecp256k1-zkpへのECDSA署名アダプターサポート追加の発表、
BIPプロセスの変更提案のリンクを掲載しています。
また、Bitcoin Stack Exchangeで人気のあった質問と回答の要約、
ソフトウェアのリリースとリリース候補のお知らせ、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点の説明など、
通常のセクションも含まれています。

## ニュース

- **<!--draft-specification-for-ln-splicing-->LNスプライシングのドラフト仕様:**
  Rusty Russellは、Lightning Specificationリポジトリ("BOLTs")に
  [スプライシング][topic splicing]に対応するために必要なプロトコルの変更を提案する
  [PR][bolts #863]を公開しました。
  また、PRのリンクをLightning-Devメーリングリストに[投稿しました][russell splicing post]。
  スプライシングを利用すると、チャネル参加者は、
  チャネルの資金を使用するのにオンチェーン承認の遅延を待つことなく、
  資金をオンチェーンのアウトプットから既存のペイメントチャネルに、
  もしくは既存のペイメントチャネルから独立したオンチェーン・アウトプットに転送することができます。
  これにより、ウォレットは残高管理の技術的な詳細をユーザーから隠すことができます。
  例えば、アリスのウォレットは同じペイメントチャネルからボブに対して、
  オフチェーンもしくはオンチェーンで自動的に支払いをすることができます。
  オフチェーンではそのペイメントチャネルを介してLNを使用し、
  オンチェーンではそのペイメントチャネルからスプライス・アウト（引き出し）を使用します。

    Russellは以前、2018年にスプライシングのドラフト仕様を[提案していました][russell old splice]（
    [ニュースレター #17][news17 splice]参照）。今回の新しいドラフトでは、C-Lightningが実験的にサポートしている
    [デュアル・ファンディング][topic dual funding]の一部に含まれている対話型のファンディングプロトコルを使用できるという利点があります。

- **<!--call-for-topics-in-layer-crossing-workshop-->クロスレイヤー・ワークショップのトピック募集:**
  Antoine Riardは、LNなどのレイヤー2プロトコルに影響を与えるオンチェーントランザクションリレーの[課題][riard zoology]を議論するために、
  IRCベースのワークショップを開催する予定であることをBitcoin-DevメーリングリストとLightning-Devメーリングリストに[投稿しました][riard workshop]。
  その目的は、どの提案が注目に値するかについて参加者間で技術的なコンセンサスを得て、
  開発者やレビュアーが短期的にそれらの提案に集中できるようにすることです。

    この投稿では、[パッケージリレー][topic package relay]や手数料スポンサー([ニュースレター #116][news116 sponsorship]参照)、
    [BIP125][] opt-in Replace By Fee([RBF][topic rbf])からフルRBFへの移行、
    フルノードなどのオンチェーンプロジェクトとLNノードなどのオフチェーンプロジェクト間のセキュリティ対応の調整の改善、
    レイヤー2プロトコルに合理的に依存できるmempoolとリレーポリシーの定義などのアジェンダが提案されています。
    またRiardは、5月7日を締め切りとして、参加予定者に追加のトピックの提案も求めています。
    ワークショップの開催は6月中旬を予定しています。

- **<!--support-for-ecdsa-signature-adaptors-added-to-libsecp256k1-zkp-->libsecp256k1-zkpにECDSA署名アダプターのサポートを追加:**
  [署名アダプター][topic adaptor signatures]は、もともとAndrew PoelstraがBitcoinのために
  [Schnorr][topic schnorr signatures]ベースの[マルチシグ][topic multisignature]を使って説明したものです。
  これにより１つの署名で最大３つのことを同時にできるようになりました:
  (1) 作成者が特定の秘密鍵にアクセスしたことの証明、
  (2) 他の参加者が事前に選択した暗号鍵を知っていることの証明、
  (3) 事前に選択した暗号鍵を別の参加者に公開。
  これにより、現在Bitcoin Scriptで行っていることの多くを署名だけで行うことができ、
  アダプター署名を使用して"Scriptless Script"を作成することができると考えられます。

    ECDSAで同じことを実現するのは、それほど簡単ではありません。
    しかし、Lloyd Fournierは、ゴール#1（秘密鍵の証明）をゴール#2とゴール#3（暗号鍵の証明と公開、別名アダプター）
    から分離すれば、比較的簡単になると[提案しました][fournier otves]。
    この場合、１つの署名オブジェクトを単なる署名として使用し、
    別の署名オブジェクトをアダプター用に使用する必要があるため、
    `OP_CHECKMULTISIG`を使用することになり、前述したようなScriptlessにはなりません。
    また、この分離した構造では、楕円曲線Diffie Hellman (ECDH)鍵交換とElGamal暗号に関わる鍵の一部を再利用することに関連して、
    [セキュリティ上の警告][ecdh warning]が必要です。それ以上に、
    この技術は今日のBitcoinで署名アダプターを完全に使用可能にするもので、
    それはさまざまな[DLC][topic dlc]プロジェクトで使用されています。

    2020年4月、Jonas NickはドラフトPRでこれらの簡略化されたECDSA署名アダプター
    （[ニュースレター #92][news92 ecdsa adaptor]参照）のサポートを実装しました。
    Jesse Posnerは、より高度な暗号プロトコルをサポートする[libsecp256k1][]のフォークであるlibsecp256k1-zkpに、
    このPRを[移植][libsecp256k1-zkp #117]、拡張しました。更新されたPRは、
    署名アダプターのセキュリティをよりよく理解しようとしている人にとって興味深い
    いくつかの会話を含む詳細なレビュープロセスの後、マージされました。

- **<!--problems-with-the-bips-process-->BIPプロセスの問題:**
  BIPリポジトリでいくつかのドラマ（そしておそらく以前からの不満）があった後、
  [新しいBIP編集者][dashjr alm]の追加、[bot][corallo bot]を使ったBIPのPRのマージ、
  また[中央化されたBIPリポジトリ][corallo ignore repo]の完全放棄について、
  メーリングリストでいくつかの議論が始まりました。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・答えを紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--what-are-the-different-contexts-where-mtp-is-used-in-bitcoin-->BitcoinでMTPが使用される状況は？]({{bse}}105522)
  David A. Hardingは、Median Time Past (MTP)を明確にし、MTPがどのように使用されるか解説しています:

    1. `nTime`フィールドを使ってブロックの有効性を判断し、難易度調整期間を制御します

    2. 時間は前進するだけであることを保証し、BIP9の[状態遷移][bip9 state]を単純化します

    3. [BIP113][bip113 spec]で修正されたように、現在の時刻について嘘をつくことで、個々のマイナーが
       最大未来２時間のlocktimeでトランザクションを承認するインセンティブを排除します。

- [<!--can-taproot-be-used-to-commit-arbitrary-data-to-chain-without-any-additional-footprint-->Taprootを使って、フットプリントを増やすことなく、任意のデータをチェーンにコミットすることはできますか？]({{bse}}105346)
  Pieter Wuilleは、[tapleaf][news46 complex spending]内の`OP_RETURN`を使ってデータをコミットすることは可能だが、
  [Pay-to-Contract][pay-to-contract se]や[Sign-to-Contract][sign-to-contract blog]などの手法が、
  現在Liquidや[OpenTimestamps][opentimestamps]で使われており、より効率的であると指摘しています。

- [<!--why-does-the-mined-block-differ-so-much-from-the-block-template-->なぜマイニングされたブロックはブロックテンプレートと大きく異なるのですか？]({{bse}}105694)
  ユーザーAndyは、ブロック680175が、そのブロックがマイニングされたのと同時間に彼の`getblocktemplate` RPCが出力したものと異なる理由を尋ねています。
  Andrew ChowとMurchは、versionフィールドが異なる理由として[Asicboost][asicboost se]を指摘し、
  ノードに依存しないmempoolとノードの稼働時間がブロックのトランザクションの不一致として考えられます。

- [<!--isn-t-bitcoin-s-hash-target-supposed-to-be-a-power-of-2-->Bitcoinのハッシュ・ターゲットは2のべき乗ではないのですか？]({{bse}}105618)
  Andrew Chowは、難易度ターゲットの'先頭ゼロ'の説明が単純化しすぎていることを説明し、
  chytrikは、先頭ゼロの数が同じである有効なハッシュと無効なハッシュの例を挙げています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 0.21.1rc1][Bitcoin Core 0.21.1]は、
  提案されている[Taproot][topic taproot]ソフトフォークのアクティベーションロジックを含むバージョンのBitcoin Coreのリリース候補です。
  Taprootは、[Schnorr署名][topic schnorr signatures]を使用し、[Tapscript][topic tapscript]を使用可能にします。
  これらはそれぞれ、BIP [341][BIP341]、[340][BIP340]および[342][BIP342]で定義されています。
  また、[BIP350][]で定義された[bech32m][topic bech32]アドレスへの支払いを行う機能も含まれていますが、
  mainnet上でそのようなアドレスに送金されるビットコインは、
  taprootなどのそのようなアドレスを使用するソフトフォークがアクティベートされるまで安全ではありません。
  この他にもバグ修正や小さな改善が行われています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #21595][]では、`bitcoin-cli`実行ファイルに新しい`addrinfo`コマンドが追加されました。
  `bitcoin-cli -addrinfo`を実行すると、ノードが知っている潜在的なピアのネットワークアドレースのカウントが
  ネットワークタイプ毎に分けて返されます。サンプル出力:

    ```
    $ bitcoin-cli -addrinfo
    {
      "addresses_known": {
        "ipv4": 14406,
        "ipv6": 2511,
        "torv2": 5563,
        "torv3": 2842,
        "i2p": 8,
        "total": 25330
      }
    }
    ```

- [Rust-Lightning #844][]は、[LND][LND #192]、[C-Lightning][news69 signcheck rpc]および
  [Eclair][news110 signmessage rpc]と互換性のあるスキームを使用した
  メッセージの署名、署名検証および公開鍵のリカバリーをサポートしました。

- [BTCPay Server #2356][]は、[WebAuthN/FIDO2][]プロトコルを使用した多要素認証をサポートしました。
  [U2F][]を使用したBTCPayの既存の多要素認証は引き続き動作します。

- [Libsecp256k1 #906][]は、可変時間アルゴリズムよりもサイドチャネル攻撃の耐性が高い定数時間アルゴリズムを使用する際に、
  モジュラ逆数の計算に必要な反復回数を724から590に削減しました。アルゴリズムの正しさは、
  [Coq proof assistant][coq]を使用してチェックされ、最も厳密な検証には約66日の実行時間を要しました。
  この改善につながったアルゴリズムの進歩については、[ニュースレター #136][news136 safegcd]をご覧ください。

{% include references.md %}
{% include linkers/issues.md issues="21595,844,2356,906,863,192" %}
[bitcoin core 0.21.1]: https://bitcoincore.org/bin/bitcoin-core-0.21.1/
[webauthn/fido2]: https://en.wikipedia.org/wiki/FIDO2_Project
[u2f]: https://en.wikipedia.org/wiki/Universal_2nd_Factor
[russell splicing post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-April/002999.html
[russell old splice]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001434.html
[news17 splice]: /en/newsletters/2018/10/16/#proposal-for-lightning-network-payment-channel-splicing
[riard workshop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-April/003002.html
[riard zoology]: https://github.com/ariard/L2-zoology
[news116 sponsorship]: /en/newsletters/2020/09/23/#transaction-fee-sponsorship
[fournier otves]: https://github.com/LLFourn/one-time-VES/blob/master/main.pdf
[ecdh warning]: https://github.com/ElementsProject/secp256k1-zkp/pull/117/commits/6955af5ca8930aa674e5fdbc4343e722b25e0ca8#diff-0bc5e1a03ce026e8fea9bfb91a5334cc545fbd7ba78ad83ae5489b52e4e48856R14-R27
[news92 ecdsa adaptor]: /en/newsletters/2020/04/08/#work-on-ptlcs-for-ln-using-simplified-ecdsa-adaptor-signatures
[libsecp256k1-zkp #117]: https://github.com/ElementsProject/secp256k1-zkp/pull/117
[dashjr alm]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-April/018835.html
[corallo bot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-April/018849.html
[corallo ignore repo]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-April/018859.html
[news136 safegcd]: /ja/newsletters/2021/02/17/#faster-signature-operations
[coq]: https://coq.inria.fr/
[news69 signcheck rpc]: /ja/newsletters/2019/10/23/#c-lightning-3150
[news110 signmessage rpc]: /en/newsletters/2020/08/12/#eclair-1499
[bip9 state]: https://github.com/bitcoin/bips/blob/master/bip-0009.mediawiki#state-transitions
[bip113 spec]: https://github.com/bitcoin/bips/blob/master/bip-0113.mediawiki#specification
[news46 complex spending]: /en/newsletters/2019/05/14/#complex-spending-with-taproot
[opentimestamps]: https://opentimestamps.org/
[sign-to-contract blog]: https://blog.eternitywall.com/2018/04/13/sign-to-contract/
[pay-to-contract se]: https://bitcoin.stackexchange.com/a/37208/87121
[asicboost se]: https://bitcoin.stackexchange.com/a/56518/5406
