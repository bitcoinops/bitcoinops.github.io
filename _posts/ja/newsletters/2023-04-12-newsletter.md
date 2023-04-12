---
title: 'Bitcoin Optech Newsletter #246'
permalink: /ja/newsletters/2023/04/12/
name: 2023-04-12-newsletter-ja
slug: 2023-04-12-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LNのスプライシングに関する議論と、
推奨されるトランザクションの用語のためのBIP提案を掲載しています。
また、Bitcoin Core PR Review Clubのミーティングの概要や、
新しいリリースやリリース候補の発表（libsecp256k1のセキュリティアップデートを含む）、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点など、
恒例のセクションも含まれています。

## ニュース

- **<!--splicing-specification-discussions-->スプライシングの仕様に関する議論:**
  LNの開発者たちは、オフチェーンのLNチャネルの資金の一部をオンチェーンで使用したり（スプライス・アウト）、
  オンチェーンの資金をオフチェーンのチャネルに追加したり（スプライス・イン）できるようにする
  [スプライシング][topic splicing]の[ドラフト仕様][bolts #863]の進行状況について、
  今週Lightning-Devメーリングリストに投稿しました。
  オンチェーンのスプライシング・トランザクションが十分な承認数を待つ間も、
  チャネルは継続して動作します。

  {:.center}
  ![スプライシング・トランザクションのフロー](/img/posts/2023-04-splicing1.dot.png)

  今週の議論は次のようなものでした:

  - *<!--which-commitment-signatures-to-send-->どのコミットメント署名を送信するか:*
    スプライスが作成されると、ノードは、保留中のすべてのスプライスに対して、
    元のファンディング・アウトプットから支払いするものと新しいファンディング・アウトプットから支払うものの両方を含む
    並列のコミットメント・トランザクションを保持することになります。
    チャネルの状態が更新されるたびに、すべての並列コミットメント・トランザクションを更新する必要があります。
    これを処理する簡単な方法は、個々のコミットメント・トランザクションに対して送信されるのと同じメッセージを、
    並列コミットメント・トランザクションごとに繰り返し送信する方法です。

    スプライシングの最初のドラフト仕様ではそうなっていました（ニュースレター[#17][news17 splice]および[#146][news146
    splice]参照）。しかし、今週Lisa Neigutが[説明][neigut splice]したように、
    新しいスプライスの作成には、新しい派生コミットメント・トランザクションに署名する必要があります。
    現在のドラフト仕様では、どのような署名でも送信すると、
    他のすべての現在のコミットメント・トランザクションの署名も送信する必要があります。
    これは冗長で、他のコミットメント・トランザクションの署名はすでに送信されています。
    さらに、現在のLNプロトコルで、相手から署名を受け取ったことを確認する方法は、
    前のコミットメント・トランザクションの失効ポイントを送信することです。
    ここでも、その情報はすでに送信されています。署名と古い失効ポイントを再送することは問題ではありませんが、
    余分な帯域幅と処理が必要になります。すべてのケースで同じ操作を実行することの利点は、
    仕様をシンプルに保つことで、実装やテストの複雑さを減らすことができることです。

    代替案は、新しいスプライスが交渉されたときに、新しいコミットメント・トランザクションに必要な最少数の署名と、
    それらが受信されたという確認の応答のみを送信する特別なケースです。
    これは多少複雑さが増しますが、非常に効率的です。LNノードは、
    スプライス・トランザクションが両者が安全だと判断するのに十分な深さまで承認されるまで、
    並列コミットメント・トランザクションを管理するだけでいいというのは注目に値します。
    その後、LNノードは単一のコミットメントの運用に戻ることができます。

  - *<!--relative-amounts-and-zero-conf-splices-->相対量とゼロ承認のスプライス:*
    Bastien Teinturierは、いくつかの仕様の更新案について[投稿しました][teinturier splice]。
    前述のコミットメントの署名の変更に加えて、相対量を使用するスプライスの提案を推奨しています。
    たとえば、「200,000 sat」はアリスがスプライス・インしたい金額を示し、
    「-50,000 sat」はアリスがスプライス・アウトしたい金額を示します。
    彼はまた、ゼロ承認のスプライシングに関する懸念も提起していますが、
    それについて詳細は述べていません。

- **トランザクション用語のためのBIP提案:** Mark "Murch" Erhardtは、
  トランザクションのパーツやそれらに関する概念を参照するために使用する用語を提案する[情報BIP][terms bip]のドラフトを
  Bitcoin-Devメーリングリストに[投稿しました][erhardt terms]。
  この記事を書いている時点で、この提案に対するすべての返信が取り組みを支持していました。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Don't download witnesses for assumed-valid blocks when running in prune mode][review club 27050]は、
Niklas Gögge (dergoegge)によるPRで、[ブロックデータの剪定][docs pruning]と
[assumevalid][docs assume valid]の両方を使用するノードで、
witnessデータをダウンロードしなないようにすることで初期ブロックダウンロード（IBD）のパフォーマンスを向上させます。
この最適化は、最近[stack exchangeの質問][se117057]で議論されたものです。

{% include functions/details-list.md
  q0="<!--if-assume-valid-is-enabled-but-not-pruning-why-does-the-node-need-to-download-non-recent-witness-data-given-that-the-node-won-t-be-checking-this-data-should-this-pr-also-disable-witness-download-in-this-non-pruning-case-->
     assume-validは有効で剪定はしていない場合、ノードがチェックしない（最近のものではない）witnessデータをダウンロードする必要があるのはなぜですか？
     この非剪定ケースでも、このPRはwitnessのダウンロードを無効にするべきですか？"
  a0="ピアが（非剪定ノードとして自身を通知している）ノードに以前のブロックを要求する可能性があるため、
      これらのwitnessデータは必要です。"
  a0link="https://bitcoincore.reviews/27050#l-31"

  q1="<!--how-much-bandwidth-might-be-saved-by-this-enhancement-during-an-ibd-in-other-words-what-is-the-cumulative-size-of-all-witness-data-up-to-a-recent-block-say-height-781213-->
      IBD中のこの改善によってどれくらいの帯域幅が削減されますか？
      つまり、最近のブロック（たとえば高さ781213）までの全witnessデータの累積サイズはどれくらいですか？"
  a1="110.6 GBで、全ブロックデータの約25%になります。ある参加者は、
      110 GBというのは彼の月間ISPダウンロード制限の約10%なので、これはかなりの削減率だと指摘しました。
      参加者はまた、最近のwitnessデータの使用の拡大により、削減率がさらに高まると予想しています。"
  a1link="https://bitcoincore.reviews/27050#l-52"

  q2="<!--would-this-improvement-reduce-the-amount-of-download-data-from-all-blocks-back-to-the-genesis-block-->
        この改善により、ジェネシスブロックまですべてのブロックでダウンロードするデータ量が減りますか？"
  a2="いいえ。segwit有効化（ブロック高481824）以降のデータのみです。segwit前のブロックにはwitnessデータがありません。"
  a2link="https://bitcoincore.reviews/27050#l-73"

  q3="<!--this-pr-implements-two-main-changes-one-to-the-block-request-logic-and-one-to-block-validation-what-are-these-changes-in-more-detail-->
      このPRでは、ブロックの要求ロジックとブロックの検証ロジックの2つの主な変更が実装されています。
      これらの変更点の詳細について教えてください。"
  a3="検証では、スクリプトのチェックをスキップする際、witnessのマークルツリーのチェックもスキップされます。
      ブロックの要求ロジックでは、フェッチフラグから`MSG_WITNESS_FLAG`を削除し、
      ピアがwitnessデータを送信しないようにします。"
  a3link="https://bitcoincore.reviews/27050#l-83"

  q4="<!--without-this-pr-script-validation-is-skipped-under-assume-valid-but-other-checks-that-involve-witness-data-are-not-skipped-what-are-these-checks-that-this-pr-will-cause-to-be-skipped-->
      このPRがない場合、assume-validではスクリプトの検証がスキップされますが、
      witnessデータを含む他のチェックはスキップされません。
      このPRによってスキップされるようになるこれらのチェックは何ですか？"
  a4="コインベースのマークルルート、witnessのサイズ、witnessスタックアイテムの最大数およびブロックweightです。"
  a4link="https://bitcoincore.reviews/27050#l-91"

  q5="<!--the-pr-does-not-include-an-explicit-code-change-for-skipping-all-the-extra-checks-mentioned-in-the-previous-question-why-does-that-work-out-->
      PRには、前の質問で述べた追加のチェックをスキップするための明示的なコード変更が含まれていません。なぜそれがうまくいくのですか？"
  a5="witnessデータを持っていない場合、すべての追加のチェックがパスすることがわかりました。
      これはsegwitがソフトフォークだったことを考慮すると、理にかなっています。
      PRによって、（assume-validのポイントまで）segwit以前のノードであるかのように装っているだけです。"
  a5link="https://bitcoincore.reviews/27050#l-117"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Libsecp256k1 0.3.1][]は、Clangバージョン14以上でコンパイルした場合に、
  定数時間で実行されるべきコードが定数時間で実行されない問題を修正した**セキュリティリリース**です。
  この脆弱性により、影響を受けるアプリケーションはタイミング[サイドチャネル攻撃][topic side channels]を受けやすくなる可能性があります。
  著者は影響を受けるアプリケーションを更新することを強くお勧めします。

- [BDK 1.0.0-alpha.0][]は、[ニュースレター #243][news243 bdk]で紹介したBDKの主な変更のテストリリースです。
  BDKの下流プロジェクトの開発者は、統合テストを開始することが奨励されます。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Core Lightning #6012][]では、CLNプラグインを作成するためのPythonライブラリ（
  [ニュースレター #26][news26 pyln-client]参照）に、CLNのゴシップストアとより良く連携するためのいくつかの重要な改善が実装されています。
  この変更により、ゴシップのより良い分析ツールを構築することができ、
  ゴシップデータを使用するプラグインの開発がより簡単になります。

- [Core Lightning #6124][]では、[commando][commando plugin]でruneをブラックリスト化し、
  すべてのruneのリストを保持する機能が追加されました。これは、侵害されたruneを追跡し、無効化するのに役立ちます。

- [Eclair #2607][]は、ノードが受け取ったすべての支払いを一覧表示する新しい`listreceivedpayments`RPCを追加しました。

- [LND #7437][]は、1つのチャネルだけをファイルにバックアップするためのサポートを追加しました。

- [LND #7069][]では、クライアントが[ウォッチタワー][topic watchtowers]に
  セッションの削除を要求するメッセージを送信できるようになりました。
  これにより、ウォッチタワーは、失効された状態でチャネルを閉じるオンチェーントランザクションの監視を停止することができます。
  これにより、ウォッチタワーとクライアント両方のストレージとCPU要件が軽減されます。

- [BIPs #1372][]は、[Taproot][topic taproot]や
  その他の[BIP340][]互換の[Schnorr署名][topic schnorr signatures]システムで使用できる
  [マルチシグ][topic multisignature]を作成するための[MuSig2][topic musig]プロトコルに[BIP327][]を割り当てました。
  BIPで説明されているように、非対話型の鍵集約と、署名の完成が2ラウンドの通信のみで行えるのが利点です。
  参加者間の追加設定により、非対話型の署名も可能です。このプロトコルは、参加者とネットワークのユーザー双方にとって、
  オンチェーンデータの大幅な削減やプライバシーの強化など、あらゆるマルチシグ方式の利点と互換性があります。

{% include references.md %}
{% include linkers/issues.md v=2 issues="6012,6124,2607,7437,7069,1372,863" %}
[bdk 1.0.0-alpha.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-alpha.0
[news243 bdk]: /ja/newsletters/2023/03/22/#bdk-793
[neigut splice]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-March/003894.html
[teinturier splice]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-March/003895.html
[erhardt terms]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021550.html
[terms bip]: https://github.com/Xekyo/bips/pull/1
[review club 27050]: https://bitcoincore.reviews/27050
[docs pruning]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-0.11.0.md#block-file-pruning
[docs assume valid]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#assumed-valid-blocks
[se117057]: https://bitcoin.stackexchange.com/questions/117057/why-is-witness-data-downloaded-during-ibd-in-prune-mode
[commando plugin]: /ja/newsletters/2022/07/27/#core-lightning-5370
[news26 pyln-client]: /en/newsletters/2018/12/18/#c-lightning-2161
[news17 splice]: /en/newsletters/2018/10/16/#proposal-for-lightning-network-payment-channel-splicing
[news146 splice]: /ja/newsletters/2021/04/28/#draft-specification-for-ln-splicing-ln
[libsecp256k1 0.3.1]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.3.1
