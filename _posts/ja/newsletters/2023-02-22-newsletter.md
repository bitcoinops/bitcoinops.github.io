---
title: 'Bitcoin Optech Newsletter #239'
permalink: /ja/newsletters/2023/02/22/
name: 2023-02-22-newsletter-ja
slug: 2023-02-22-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、提案中の`OP_VAULT` opcodeのBIPドラフトのリンクや、
LNノードがチャネルにサービス品質フラグを設定できるようにすることについての議論、
LNの近隣ノードの評価基準に関するフィードバックのリクエスト、
電子機器なしで確実に実行できるシードのバックアップおよびリカバリー方式のBIPドラフトを掲載しています。
また、Bitcoin StackExchangeの人気のある質問とその回答の要約や、
新しいリリースおよびリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **OP_VAULTのBIPドラフト:** James O'Beirneは、彼が以前提案した`OP_VAULT`
  opcodeの[BIPドラフト][bip op_vault]（[ニュースレター #234][news234 vault]参照）のリンクを
  Bitcoin-Devメーリングリストに[投稿しました][obeirne op_vault]。
  彼はまた、Bitcoinのコンセンサスやネットワーク・プロトコルルールへの主な変更をテストするプロジェクトである
  Bitcoin Inquisitionにコードをマージしようとしていることも発表しました。

- **<!--ln-quality-of-service-flag-->LNのサービス品質フラグ:** Joost Jagerは、
  ノードがチャネルが「高可用性」であること（オペレーターが失敗することなく支払いを転送できると信じている状態）を
  通知できるようにする提案をLightning-Devメーリングリストに[投稿しました][jager qos]。
  支払いの転送に失敗した場合、支払人は今後の支払いでそのノードを長期間使用しないことを選択できます。
  この期間は、支払人が高可用性を通知しなかったノードに使用するよりもはるかに長い期間になります。
  （手数料の安さよりも）支払い速度を最大化する支払人は、自己識別された高可用性ノードで構成される支払い経路を優先的に選択します。

    Christian Deckerは、自己評価を含むレピュテーションシステムの問題点について優れた要約を[返信しました][decker qos]。
    彼の懸念の1つは、一般的な支払人は、大規模なペイメントチャネルネットワークにおいて、
    同じノードに頻繁に遭遇するほど多くの支払いを送らないという点です。
    リピート率が高くなければ、一時的にリピートを提供しないという脅しは効果的ではないかもしれません。

    Antoine Riardは、支払いを高速化する別のアプローチである回収付きの過払いを参加者に[リマインド][riard boomerang]しました。
    以前、ブーメラン・ペイメント（[ニュースレター #86][news86 boomerang]参照）や
    払い戻し可能な過払い（[ニュースレター #192][news192 pp]参照）と呼ばれていたこの方法では、
    支払人は支払額と余分な額を、いくつかの[パーツ][topic multipath payments]に分割して、
    さまざまな経路で送信します。インボイスへの支払い額に対して十分な数のパーツが到着したら、
    受取人はそのパーツのみを請求し、後から届いた追加のパーツ（余分な金額分）は拒否します。
    このため、迅速な支払いを望む支払人は、自分のチャネルにある程度の追加資金を保持している必要がありますが、
    選択した経路のいくつかが失敗しても機能します。このため、
    支払人が可用性の高いチャネルを簡単に見つけられる必要性が低くなります。
    この方法の課題は、到着した過払い分を受取人が保持できないようにする仕組みを構築することです。

- **<!--feedback-requested-on-ln-good-neighbor-scoring-->LNの良い近隣ノードのスコア化に関するフィードバックのリクエスト:**
  Carla Kirk-CohenとClara Shikhelmanは、Lightning-Devメーリングリストに、
  チャネルの相手が転送された支払いの適切なソースかどうかをノードが判断するための推奨パラメーターに関する
  フィードバックのリクエストを[投稿しました][ckc-cs reputation]。
  彼らは、判断するためのいくつかの判断基準と各基準に対する推奨デフォルトパラメーターを提案しており、
  その選択についてのフィードバックを求めています。

    ノードがピアの1つを良い近隣ノードと判断し、そのノードが転送された支払いを承認するタグをつけると、
    ノードは非適格な支払いに与えるのよりも多くのリソースへのアクセスを与えることができます。
    また、ノードは支払いを次のチャネルに転送する際に、その支払いを承認することもできます。
    Shikhelmanの共著論文にあるように（[ニュースレター #226][news226 jam]参照）、
    これは[チャネルジャミング攻撃][topic channel jamming attacks]を緩和する提案の一部です。

- **Codex32 シードエンコード方式のBIP提案:** Russell O'ConnorとAndrew Poelstra（名前のアナグラムを使用）は、
  [BIP32][]シードのバックアップとリカバリーを行う新しい方式のBIPを[提案しました][op codex32]。
  [SLIP39][]と同様、オプションで[シャミアの秘密分散法][Shamir's Secret Sharing Scheme] (SSSS)を用いて複数のシェアを作成でき、
  シードをリカバリーするために必要な設定数のシェアを一緒に使用することを求めます。
  攻撃者は、閾値以下の数のシェアを取得してもシードについて何も知ることができません。
  ワードリストを使用するBIP39、Electrum、Aezeed、SLIP39のリカバリーコードと異なり、
  Codex32は[bech32][topic bech32]アドレスと同じアルファベットを使用します。
  BIPドラフトのシェアの例:

    ```text
    ms12namea320zyxwvutsrqpnmlkjhgfedcaxrpp870hkkqrm
    ```

    Codex32が既存のすべての方式と比較して優れているのは、
    すべての操作をペンと紙、説明書と切り抜きだけで実行できることです。
    Codex32には、エンコードされたシードの生成（ここではサイコロが使用可能）、
    チェックサムによるシードの保護、チェックサム付きシェアの生成、
    チェックサムの検証、シードのリカバリーが含まれます。
    特に、シードやシェアのバックアップのチェックサムを手動で検証できるというアイディアは、強力なコンセプトだと思います。
    現在、ユーザーが個々のシードバックアップを検証する唯一の方法は、
    信頼できるコンピューティングデバイスにそれを入力し、期待通りの公開鍵が得られるかどうかを確認するというものですが、
    デバイスが信頼できるかどうかを判断するのは、多くの場合簡単な手順ではありません。
    さらに悪いことに、既存のSSSSシェア（SLIP39など）の完全性を検証するために、
    ユーザーは検証したい各シェアを閾値分の他のシェアと一緒に、信頼できるコンピューティングデバイスに入力しなければなりません。
    つまり、シェアの完全性を検証することは、
    そもそものシェアの大きな利点である情報を複数の場所や人に分散して安全・安心に保つ能力を否定することになります。
    Codex32では、紙とペン、印刷物を使って、各シェアの完全性を数分の時間で定期的に確認することができます。

    メーリングリストでは、主にCodex32と数年前から実運用されているSLIP39の違いについて議論されました。
    Codex32に興味のある方は、[ウェブサイト][codex32 website]を調べたり、
    作者の1人による[動画][codex32 video]をご覧ください。
    BIPのドラフトでは、Codex32でエンコードされたシードを使用するためのサポートがウォレットに追加されることを著者らは期待しています。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-is-witness-data-downloaded-during-ibd-in-prune-mode-->なぜpruneモードのIBD中にwitnessデータがダウンロードされるのですか？]({{bse}}117057)
  Pieter Wuilleは、[pruneモード][prune mode]で動作しているノードについて、
  「(a) assumevalidポイントよりも前で、かつ、(b) pruneポイントを過ぎて十分に埋もれているwitnessデータは、
  実際にそれを持っていても得られるものはほとんどない」と指摘しています。
  現在、これに対応する[PRのドラフト][Bitcoin Core #27050]が公開されており、
  [PR Review Club][pr review 27050]がこの変更案を取り上げています。

- [<!--can-bitcoin-s-p2p-network-relay-compressed-data-->BitcoinのP2Pネットワークは圧縮されたデータをリレーできますか？]({{bse}}116999)
  Pieter Wuilleは、圧縮に関する2つのメーリングリストの議論のリンク（１つは、[ヘッダー同期用の特殊な圧縮][specialized compression for headers sync]で、
  もう１つは、[一般的なLZOベースの圧縮][general LZO-based compression]）を記載し、
  Blockstream Satelliteがカスタムのトランザクション圧縮方式を使用していることを指摘しています。

- [<!--how-does-one-become-a-dns-seed-for-bitcoin-core-->Bitcoin CoreのDNSシードになるにはどうしたらいいですか？]({{bse}}116931)
  ユーザーParoは、新規ノードに最初のピアを提供する[DNSシード][news66 dns seed]になりたい人のための要件を説明しています。

- [<!--where-can-i-learn-about-open-research-topics-in-bitcoin-->Bitcoinのオープンな研究テーマについて、どこで知ることができますか？]({{bse}}116898)
  Michael Folksonは、[Chaincode Labs Research][]や[Bitcoin Problems][]など、
  さまざまなリソースを提供しています。

- [<!--what-is-the-maximum-size-transaction-that-will-be-relayed-by-bitcoin-nodes-using-the-default-configuration-->デフォルトの設定でBitcoinノードでリレーされるトランザクションの最大サイズは？]({{bse}}117277)
  Pieter Wuilleは、Bitcoin Coreの400,000 [weight unit][]の標準ポリシールールと、
  それが現在設定可能ではないことを指摘し、DoS保護などその制限の意図する利点を説明しています。

- [<!--understanding-how-ordinals-work-with-in-bitcoin-what-is-exactly-stored-on-the-blockchain-->BitcoinでOrdinalsがどう機能しているかを理解する]({{bse}}117018)
  Vojtěch Strnadは、Ordinals Inscriptionsが`OP_RETURN`を使用せず、
  以下のスクリプトのように、`OP_PUSHDATAx` opcodeを使用して未実行のスクリプト分岐にデータを埋め込んでいることを明確にしました。

    ```
    OP_0
    OP_IF
    <data pushes>
    OP_ENDIF
    ```

- [<!--why-doesn-t-the-protocol-allow-unconfirmed-transactions-to-expire-at-a-given-height-->なぜプロトコルは未承認トランザクションをある高さで期限切れにさせないのか？]({{bse}}116926)
  Larry Ruaneは、トランザクションに有効期限を指定する一見便利な機能、つまり、
  ある高さでトランザクションがまだマイニングされていない場合無効となる（マイニングされない）機能を持つことが賢明でない理由について、
  Satoshiに言及しています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BDK 0.27.1][]は、「SQLiteのprint関数に大きな文字列を入力すると、
  配列の境界のオーバーフローが発生する場合がある」という脆弱性を修正するセキュリティアップデートです。
  BDKのオプションであるSQLiteのデータベース機能を使用しているソフトウェアのみ、アップデートが必要です。
  詳細は、[脆弱性レポート][RUSTSEC-2022-0090]をご覧ください。

- [Core Lightning 23.02rc3][]は、この人気のあるLN実装の新しいメンテナンスバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。

- [Bitcoin Core #24149][]は、P2WSHベースの
  [Miniscript][topic miniscript]ベースの[アウトプット・ディスクリプター][topic descriptors]に対する署名をサポートします。
  Bitcoin Coreは、必要なプリイメージと鍵がすべて利用可能で、タイムロックが満たされている場合、
  任意のMiniscriptのインプットに署名できるようになります。
  Bitcoin CoreのウォレットでMiniscriptを完全にサポートするには、
  いくつかの機能がまだ不足しています。ウォレットは、
  署名前に一部のディスクリプターのインプットのweightをまだ推定できず、
  一部のエッジケースで[PSBT][topic PSBT]に署名することがまだできません。
  P2TRアウトプット用のMiniscriptサポートもまだ保留中です。

- [Bitcoin Core #25344][]は、RBF（[Replace By Fee][topic rbf]）による手数料の引き上げの作成のために、
  `bumpfee` RPCと`psbtbumpfee` RPCを更新しました。この更新により、
  置換トランザクションのアウトプットを指定することができます。
  置換トランザクションは、置換されるトランザクションとは異なるアウトプットのセットを含むことができます。
  これは、新しいアウトプットを追加したり（例：反復的な[支払いのバッチ処理][topic payment batching]）、
  アウトプットを削除したり（例：未承認支払いのキャンセルの試行）するために使用できます。

- [Eclair #2596][]は、[デュアル・ファンド][topic dual funding]チャネルを開設しようとするピアに対して、
  チャネル開設トランザクションの[RBF][topic rbf]による手数料引き上げ回数を制限し、
  ノードがそれ以上のアップデート受け付けないようにします。
  これは、ノードがチャネル開設トランザクションのすべてのバージョンに関するデータを保存する必要があるため、
  無制限の手数料引き上げを許可すると問題が発生する可能性があることが動機になっています。
  通常、手数料引き上げの回数は、
  各置換トランザクションが追加のトランザクション手数料を支払う必要性があることによって、実際には制限されます。
  しかし、デュアル・ファンディングプロトコルでは、ノードが完全に検証できない手数料引き上げも保存するよう想定しているため、
  攻撃者は承認もされずトランザクション手数料もかからない無効な手数料引き上げトランザクションを無制限に作成することができます。

- [Eclair #2595][]は、[スプライシング][topic splicing]サポートに関するプロジェクトの作業の継続で、
  今回はトランザクションの構築に使用される関数を更新しました。

- [Eclair #2479][]は、次のフローによる[Offer][topic offers]の支払いをサポートします:
  ユーザーがOfferを受け取り、Eclairに支払いを指示、EclairはOfferを使って受信者からインボイスを取得し、
  インボイスに期待されるパラメーターが含まれていることを確認し、インボイスへ支払う。

- [LND #5988][]は、支払い経路を見つけるための新しいオプションの確率推定器を追加しました。
  これは以前の経路探索の研究（[ニュースレター #192][news192 pp]参照）に部分的に基づいており、
  他のアプローチからの追加的なインプットも含まれています。

- [Rust Bitcoin #1636][]は、`predict_weight()`関数を追加しました。
  この関数への入力は、トランザクションを構築するためのテンプレートで、
  出力は予想されるトランザクションのweightです。これは特に、手数料管理に便利です。
  どのインプットをトランザクションに追加すべきか判断するには、
  手数料の金額を知る必要がありますが、手数料の金額を判断するには、トランザクションのサイズを知る必要があります。
  この関数は、実際に候補となるトランザクションを構築することなく、妥当なサイズの推定値を提供することができます。

{% include references.md %}
{% include linkers/issues.md v=2 issues="24149,25344,2596,2595,2479,5988,1636,27050" %}
[core lightning 23.02rc3]: https://github.com/ElementsProject/lightning/releases/tag/v23.02rc3
[news226 jam]: /ja/newsletters/2022/11/16/#paper-about-channel-jamming-attacks
[news86 boomerang]: /ja/newsletters/2020/02/26/#boomerang
[codex32 website]: https://secretcodex32.com/
[codex32 video]: https://www.youtube.com/watch?v=kf48oPoiHX0
[news192 pp]: /ja/newsletters/2022/03/23/#payment-delivery-algorithm-update
[obeirne op_vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021465.html
[bip op_vault]: https://github.com/jamesob/bips/blob/jamesob-23-02-opvault/bip-vaults.mediawiki
[news234 vault]: /ja/newsletters/2023/01/18/#vault-opcode
[jager qos]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-February/003842.html
[decker qos]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-February/003844.html
[riard boomerang]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-February/003852.html
[ckc-cs reputation]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-February/003857.html
[slip39]: https://github.com/satoshilabs/slips/blob/master/slip-0039.md
[shamir's secret sharing scheme]: https://en.wikipedia.org/wiki/Shamir%27s_secret_sharing
[prune mode]: https://bitcoin.org/en/full-node#reduce-storage
[pr review 27050]: https://bitcoincore.reviews/27050
[specialized compression for headers sync]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-March/015851.html
[general LZO-based compression]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-November/011837.html
[news66 dns seed]: /ja/newsletters/2019/10/02/#bitcoin-core-15558
[Chaincode Labs Research]: https://research.chaincode.com/research-intro/
[Bitcoin Problems]: https://bitcoinproblems.org/
[weight unit]: https://en.bitcoin.it/wiki/Weight_units
[op codex32]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021469.html
[RUSTSEC-2022-0090]: https://rustsec.org/advisories/RUSTSEC-2022-0090
[bdk 0.27.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.27.1
