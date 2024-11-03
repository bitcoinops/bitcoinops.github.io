---
title: 'Bitcoin Optech Newsletter #293'
permalink: /ja/newsletters/2024/03/13/
name: 2024-03-13-newsletter-ja
slug: 2024-03-13-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、潜在的なソフトフォークに対するトラストレスなオンチェーンでの賭けに関する投稿と、
ビットコイナー向けのChia Lispの概要のリンクを掲載しています。
また、Bitcoin Core PR Review Clubの概要や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など恒例のセクションも掲載しています。

## ニュース

* **<!--trustless-onchain-betting-on-potential-soft-forks-->潜在的なソフトフォークに対するトラストレスなオンチェーンでの賭け:**
  ZmnSCPxjは、特定のソフトフォークが有効になるかどうかを正確に予測する参加者に
  UTXOの制御を与えるためのプロトコルをDelving Bitcoinに[投稿しました][zmnscpxj bet]。
  たとえば、アリスは特定のソフトフォークが有効になると考えており、
  より多くのビットコインを手に入れるのに興味があります。ボブもより多くのビットコインを手に入れるのに興味がありますが、
  ソフトフォークが有効になるとは考えていません。
  両者は、合意した比率（例：1:1）で、二人のビットコインを合算し、
  ある一定の時間までにソフトフォークが有効になった場合はアリスが合算したビットコインを総取りし、
  有効にならなかった場合はボブが総取りすることに同意します。
  期限前に、一方のチェーンがソフトフォークを有効にし、もう一方のチェーンがフォークを禁止する永続的なチェーン分割が発生した場合、
  アリスは有効になったチェーンで合算したビットコインを受け取り、
  ボブは禁止されたチェーンで合算したビットコインを受け取ります。

  基本的なアイディアは以前提案されていますが（[例][rubin bet]）、
  ZmnSCPxjのバージョンでは、少なくとも１つの将来の潜在的なソフトフォーク
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]で予想される仕様を扱っています。
  ZmnSCPxjはまた、他の提案中のソフトフォーク、特に`OP_SUCCESSx` opcodeを
  アップグレードするソフトフォークへの構成を一般化する際の課題についても簡単に考察しています。

- **ビットコイナー向けChia Lispの概要:**
  Anthony Townsは、暗号通貨Chiaで使用されているバージョンの[Lisp][]の概要を
  Delving Bitcoinに[投稿しました][towns lisp]。Townsは以前、
  BitcoinにLispベースのスクリプト言語をソフトフォークで導入する提案をしています（[ニュースレター #191][news191 lisp]参照）。
  このトピックに興味がある方は、彼の投稿を読むことを強くお勧めします。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Re enable `OP_CAT`][review club bitcoin-inquisition 39]は、
Armin Sabouri（GitHub 0xBEEFCAF3）によるPRで、[OP_CAT][topic op_cat] opcodeを再導入するものです。
ただし、[Bitcoin Inquisition][bitcoin inquisition repo]の[signet][topic signet]および
[Tapscript][topic tapscript]（Taproot script）にのみ限定されています。
この操作により、スクリプトの評価スタックの上位２つの要素を、それらの２つの要素を連結したものに置き換えられます。

`OP_CAT`の動機については議論されませんでした。

{% include functions/details-list.md
  q0="`OP_CAT`の実行が失敗するさまざまな条件にはどのようなものがありますか？"
  a0="スタック上の項目が２つ未満の場合や、結果の項目が大きすぎる場合、
      スクリプト検証フラグによって許可されていない場合（たとえばソフトフォークがまだ有効になっていない）、
      （witness version 0やレガシーなど）非Taproot scriptで使われている場合です。"
  a0link="https://bitcoincore.reviews/bitcoin-inquisition-39#l-46"

  q1="`OP_CAT`は、`OP_SUCCESSx` opcodeを再定義しています。
      （過去にソフトフォークのアップグレードの実装にも使用されていた）`OP_NOPx` opcodeの１つで再定義しないのはなぜですか？"
  a1="`OP_SUCCESSx` opcodeと`OP_NOPx` opcodeは両方とも、
      検証ルールを制限するため、再定義してソフトフォークを実装できます
      （これらのopcodeは常に成功しますが、再定義されたopcodeは失敗する可能性があります）。
      `OP_NOP`の後もスクリプトの実行は継続するため、
      再定義された`OP_NOP` opcodeが実行スタックに影響を与えることはできません（そうでなければ、
      失敗していたスクリプトが成功する可能性があり、ルールが緩和されます）。
      再定義された`OP_SUCCESS` opcodeは、`OP_SUCCESS`がスクリプトをすぐに終了（成功）させるため、
      スタックに影響を与えることができます。`OP_CAT`はスタックに影響を与える必要があるため、
      `OP_NOP` opcodeの１つで再定義することはできません。"
  a1link="https://bitcoincore.reviews/bitcoin-inquisition-39#l-33"

  q2="このPRは`SCRIPT_VERIFY_OP_CAT`と`SCRIPT_VERIFY_DISCOURAGE_OP_CAT`の２つを追加しています。
      なぜこの両方が必要なのですか？"
  a2="これによりソフトフォークを段階的に導入できます。まず、ほとんどのネットワークノードがアップグレードされるまで、
      両方を`true`（コンセンサスは有効だがリレーやマイニングは行わない）に設定します。
      次に、`SCRIPT_VERIFY_DISCOURAGE_OP_CAT`を`false`に設定して、実際の使用を可能にします。
      Bitcoin Inquisitionの実験が後で失敗した場合は、プロセスを逆に実行できます。
      両方が`false`の場合、`OP_CAT`は単なる`OP_SUCCESS`です。"
  a2link="https://bitcoincore.reviews/bitcoin-inquisition-39#l-60"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning v24.02.1][]は、このLNノードのマイナーアップデートで、
  「いくつかの小さな修正と、ルーティングアルゴリズムのコスト関数の改善」が含まれています。

- [Bitcoin Core 26.1rc1][]は、ネットワークの主要なフルノード実装のメンテナンスリリースのリリース候補です。

- [Bitcoin Core 27.0rc1][]は、ネットワークの主要なフルノード実装の次期メジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。*

- [LND #8136][]は、インボイスとタイムアウトを受け入れるよう`EstimateRouteFee` RPCを更新します。
  インボイスへの支払い経路が選択され、[ペイメントプローブ][topic payment probes]が送信されます。
  タイムアウトになる前にプローブが正常に完了すると、選択した経路の使用コストが返されます。
  それ以外の場合は、エラーが返されます。

- [LND #8499][]は、[Simple Taproot Channel][topic simple taproot channels]のLNDのAPIを改善するために、
  そのチャネルで使用されるTLV（ Type-Length-Value）タイプに大幅な変更を加えています。
  現在、Simple Taproot Channelを使用している他のLN実装は確認されていませんが、
  使用している場合は、これが破壊的な変更となる可能性があることに注意してください。

- [LDK #2916][]は、ペイメントプリイメージをペイメントハッシュに変換するためのシンプルなAPIを追加しています。
  LNのインボイスにはペイメントハッシュが含まれています。支払いを決済するために、
  最終受信者はそのハッシュに対応するプリイメージをリリースします（そして、
  経路上の各ホップは、下流のピアから受け取ったプリイメージを使用して、上流のピアからの支払いを決済します）。
  ハッシュはプリイメージから導出できるため（その逆は不可能）、受信ノードと転送ノードはプリイメージのみを保管できます。
  このAPIを使用することで、オンデマンドでハッシュを簡単に導出できます。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8136,8499,2916" %}
[zmnscpxj bet]: https://delvingbitcoin.org/t/economic-majority-signaling-for-op-ctv-activation/635
[rubin bet]: https://blog.bitmex.com/taproot-you-betcha/
[news191 lisp]: /ja/newsletters/2022/03/16/#chia-lisp
[towns lisp]: https://delvingbitcoin.org/t/chia-lisp-for-bitcoiners/636
[lisp]: https://ja.wikipedia.org/wiki/LISP
[bitcoin core 26.1rc1]: https://bitcoincore.org/bin/bitcoin-core-26.1/
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[Core Lightning v24.02.1]: https://github.com/ElementsProject/lightning/releases/tag/v24.02.1
[review club bitcoin-inquisition 39]: https://bitcoincore.reviews/bitcoin-inquisition-39
