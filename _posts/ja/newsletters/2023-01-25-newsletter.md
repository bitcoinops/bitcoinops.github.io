---
title: 'Bitcoin Optech Newsletter #235'
permalink: /ja/newsletters/2023/01/25/
name: 2023-01-25-newsletter-ja
slug: 2023-01-25-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、エフェメラル・アンカーの提案を`SIGHASH_GROUP`と比較した分析と、
LNの非同期支払いを受け入れられたことを証明する方法を調査する研究者への依頼を掲載しています。
また、Bitcoin Stack Exchangeで人気のある質問とその回答や、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **エフェメラル・アンカーと`SIGHASH_GROUP`の比較:** Anthony Townsは、
  最近の[エフェメラル・アンカー][topic ephemeral anchors]の提案と、
  以前からある[`SIGHASH_GROUP`の提案][`SIGHASH_GROUP` proposal]との比較分析を
  Bitcoin-Devメーリングリストに[投稿しました][towns e-vs-shg]。
  `SIGHASH_GROUP`は、インプットが許可するアウトプットを指定することができ、
  トランザクション内の異なるインプットは重複しない限り異なるアウトプットを指定することができます。
  これは、２つ以上のインプットが使用される事前署名されたトランザクションを用いるコントラクトプロトコルにおいて、
  トランザクションに手数料を追加する場合に便利です。これらのトランザクションの事前署名の性質は、
  適切な手数料率が判明した時に後から手数料を追加する必要があることを意味します。
  既存の`SIGHASH_ANYONECANPAY`や`SIGHASH_SINGLE` sighashフラグは、
  単一のインプットやアウトプットにのみコミットするため、
  複数のインプットを持つトランザクションに対して十分に柔軟ではありません。

    エフェメラル・アンカーは、[手数料スポンサーシップ][topic fee sponsorship]と同様に、
    誰でも[CPFP][topic cpfp]によりトランザクションの手数料の引き上げができます。
    手数料が引き上げられるトランザクションは、ゼロ手数料が許可されます。
    誰でもエフェメラル・アンカーを使ってトランザクションの手数料を引き上げることができるため、
    この仕組みは、`SIGHASH_GROUP`のターゲットである複数のインプットを持つ
    事前署名トランザクションの手数料を支払うために使用することもできます。

    `SIGHASH_GROUP`にはまだ2つの利点があります。１つは、
    関連のない複数の署名済みトランザクションを[バッチ処理][topic payment batching]できるため、
    トランザクションサイズのオーバーヘッドが削減でき、ユーザーのコストが削減され、
    ネットワークキャパシティを増加させる可能性があります。２つめは、
    子トランザクションを必要としないため、さらにコストを削減し、キャパシティを増加させることができます。

    Townsは、[v3トランザクションリレー][topic v3 transaction relay]に依存するエフェメラル・アンカーは、
    `SIGHASH_GROUP`の利点のほとんどを捉えており、`SIGHASH_GROUP`のソフトフォークによるコンセンサスの変更よりも、
    はるかに簡単に実運用に入れるという大きな利点を持っていると指摘し、結論付けています。

- **<!--request-for-proof-that-an-async-payment-was-accepted-->非同期支払いが受け入れられたことの証明するための依頼:**
  Valentine Wallaceは、[非同期支払い][topic async payments]を行った人が、
  支払いをした証拠を受け取る方法を調査するよう研究者への依頼をLightning-Devメーリングリストに[投稿しました][wallace pop]。
  従来のLN支払いでは、受信者はハッシュ関数によってダイジェストされるシークレットを生成します。
  このダイジェストは、署名されたインボイスにより支払人に渡されます。
  支払人は、[HTLC][topic htlc]を使って元のシークレットを開示した人に支払いを行います。
  開示されたシークレットは、支払人が、署名されたインボイスに含まれるダイジェストへ支払いをしたことを証明します。

    これに対し、非同期支払いは、受信者がオフラインの時に受け入れられるため、
    シークレットを開示することができず、現在のLNモデルでは支払いの証明を作成することができません。
    Wallaceは、LNの現在のHTLCベースのシステムまたは将来の[PTLC][topic ptlc]へのアップグレードで、
    非同期支払いで支払いの証明を得る方法の調査を検討することを、研究者に求めています。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Bitcoin Coreの署名鍵がリポジトリから削除されました。新しいプロセスとは？]({{bse}}116649)
  Andrew Chowは、署名鍵がBitcoin Coreのリポジトリから[削除された][remove builder keys]一方で、
  [guix][topic reproducible builds]のビルド証明を格納する[guix.sigsリポジトリ][guix.sigs repo]に
  鍵のリストがあると説明しています。

- [signetが一意のbech32プレフィックスを使用しないのは何故ですか？]({{bse}}116630)
  Casey Rodarmorは、なぜtestnetと[signet][topic signet]の両方で
  [アドレスのプレフィックスとして][wiki address prefixes]`tb1`を使用するのか不思議に思っています。
  [BIP325][]の作者の1人であるKalleは、signetは当初別のアドレスプレフィックスを使用していたたものの、
  同じプレフィックスを使用することで代替テストネットワークの使用を簡単にできると考えたと説明しています。

- [witnessに任意のデータを保存？]({{bse}}116875)
  RedGrittyBrickは、大量のwitnessデータを含む最近のいくつかのP2TRトランザクションの[１つ][large witness tx]を指摘しました。
  他のユーザーは、Ordinalsプロジェクトがこのトランザクションにおける[画像][ordinals example]のような任意のデータを
  witnessを使ってBitcoinトランザクションに格納するサービスを提供していると指摘しています。

- [sequenceがインプットレベルで設定されるのに対し、locktimeがトランザクションレベルで設定されるのは何故ですか？]({{bse}}116706)
  RedGrittyBrickは、`nSequence`と`nLockTime`の初期の歴史的背景を、
  Pieter Wuilleは、これらの[タイムロック][topic timelocks]フィールドの意味の変化を説明しています。

- [BLS署名 vs Schnorr署名]({{bse}}116551)
  Pieter Wuilleは、BLS署名と[Schnorr][topic schnorr signatures]署名の間の暗号学的仮定を対比し、
  検証時間についてコメントし、BLSの[マルチシグ][topic multisignature]に関する複雑さと、
  [アダプター署名][topic adaptor signatures]のサポートの欠如について指摘しています。

- [<!--why-exactly-would-adding-further-divisibility-to-bitcoin-require-a-hard-fork-->ビットコインをさらに分割できるようにするためにハードフォークが必要なのは何故ですか？]({{bse}}116584)
  Pieter Wuilleは、トランザクションでsub-satoshiの分割を可能にする4つのソフトフォーク方法を説明しています:

  1. すべての新しいトランザクションが新しいルールに準拠することを要求するコンセンサスルールの変更による[強制ソフトフォーク][forced soft fork]
  2. 上記の1と同様に、新しいルールに従うトランザクションを分離するが、レガシートランザクションも許容する一方向の拡張ブロック
  3. 双方向の拡張ブロック。上記の2に似ているが、新ルールに従ったコインをレガシー側に戻すことも可能。
  4. 現行のコンセンサスルールをを使用するものの、sub-satoshiの量をトランザクション内の別の場所に保存し、
     古いノードではsub-satoshiを切り捨てる方法。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #26325][]は、2つめのパスで偽陽性を除去することで、`scanblocks`RPCの結果を改善します。
  `scanblocks`は、提供したディスクリプターのセットに関連するトランザクションを含むブロックを見つけるのに使用できます。
  フィルターに対するスキャンは、実際に関連するトランザクションを含まないブロックを誤って示すことがあるため、
  このPRでは、別のパスで各ヒットを検証して、呼び出し元に結果を提供する前に、
  ブロックが実際に渡されたディスクリプターに対応するかどうかを確認します。
  パフォーマンス上の理由から、`filter_false_positives`オプションを指定してRPCを呼び出して、
  ２つめのパスを有効にする必要があります。

- [Libsecp256k1 #1192][]は、ライブラリの網羅テストを更新しました。
  secp256k1曲線の`B`パラメーターを`7`から別の数字に変更することで、
  libsecp256k1と互換性がありながらsecp256k1の約2<sup>256</sup>の位数よりもはるかに小さい、
  異なる曲線群を見つけることができます。これらの安全な暗号としては使用できない小さな群上で、
  libsecp256k1のロジックを可能な限りの署名に対して網羅的にテストすることが可能です。
  このPRでは、既存のサイズ13と199に加えてサイズ7の群を追加しましたが、
  暗号学者はまずそのような群の単純な検索アルゴリズムが以前は常に成功するとは限らず、
  特有の代数的特徴を把握する必要がありました。サイズは13がデフォルトのままです。

- [BIPs #1383][]は、標準のウォレットラベルエクスポート形式の提案に[BIP329][]を割り当てました。
  最初の提案（[ニュースレター #215][news215 labels]参照）からの主な違いは、CSVからJSONへのデータ形式の切り替えです。

{% include references.md %}
{% include linkers/issues.md v=2 issues="26325,1383,1192" %}
[news215 labels]: /ja/newsletters/2022/08/31/#wallet-label-export-format
[towns e-vs-shg]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021334.html
[`sighash_group` proposal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019243.html
[wallace pop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003820.html
[forced soft fork]: https://petertodd.org/2016/forced-soft-forks
[remove builder keys]: https://github.com/bitcoin/bitcoin/commit/296e88225096125b08665b97715c5b8ebb1d28ec
[guix.sigs repo]: https://github.com/bitcoin-core/guix.sigs/tree/main/builder-keys
[wiki address prefixes]: https://en.bitcoin.it/wiki/List_of_address_prefixes
[large witness tx]: https://blockstream.info/tx/a6628f32a5b41b359cfe4ab038ff7c4279118ff601b9eca85eca8a64763db40c?expand
[ordinals example]: https://ordinals.com/tx/a6628f32a5b41b359cfe4ab038ff7c4279118ff601b9eca85eca8a64763db40c
