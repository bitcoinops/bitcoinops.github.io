---
title: 'Bitcoin Optech Newsletter #168'
permalink: /ja/newsletters/2021/09/29/
name: 2021-09-29-newsletter-ja
slug: 2021-09-29-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、DLCの仕様に重大な変更をするための提案と、
BIP32のシードのみで閉じたLNチャネルの復元を可能にするためのオプションの検討、
ステートレスなLNインボイスを生成するアイディアについて掲載しています。
また、Bitcoin Stack Exchangeからの人気のある質問と回答や、
Taprootアクティベーションの準備のためのアイディア、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点などの恒例のセクションも含まれています。

## ニュース

- **<!--discussion-about-dlc-specification-breaking-changes-->DLCの仕様の重大な変更に関する議論:**
  Nadav Kohenは、DLC-devメーリングリストに、
  既存のアプリケーションとの互換性を損なう可能性のあるいくつかの変更を加えた[DLC][topic dlc]の仕様の更新について[投稿しました][kohen post]。
  彼は2つの選択肢を提示しました:
  必要に応じて仕様を更新し、どのバージョンを実装しているかアプリケーションに知らせる方法と、
  混乱を最小限に抑えるためにいくつかの変更をまとめて行う方法です。
  DLCのソフトウェアに取り組んでいる開発者からのフィードバックを求めています。

<!-- confirmed on IRC that "ghost43" (all lowercase) is how they'd like to be attributed -->

- **<!--challenges-recovering-ln-close-transactions-using-only-a-seed-->シードのみを使用したLNのクローズトランザクションの復元に関する課題:**
  Electrum Walletの開発者であるghost43は、
  ウォレットのチャネルクローズトランザクションのためにブロックチェーンをスキャンする際のいくつかの課題について、
  Lightning-Devメーリングリストに[投稿しました][ghost43 post]。
  [BIP32][]スタイルの[HD鍵生成][topic bip32]のみでウォレットを復元する際に、
  新しい[anchor output][topic anchor outputs]プロトコルを処理する際の特定の問題についてです。
  ghost43はいくつかの可能性のあるスキームを分析し、
  現在Eclairで使用されているスキームが、可能な最良なものとして推奨されています。
  また、チャネル開設プロトコルの若干の変更を厭わなければ、さらなる改善が期待できます。

- **<!--stateless-ln-invoice-generation-->ステートレスなLNインボイスの生成:** Joost Jagerは、Lightning-Devメーリングリストに、
  認証されていないユーザーに対してLNインボイスを生成するアプリケーションに対するサービス拒否攻撃の可能性について[投稿しました][jager post]。
  具体的には、攻撃者は無制限の数のインボイスを要求することができ、
  インボイスの生成サービスはそれらが期限切れになるまで保存する必要があります。
  Jagerは、データ量の少ないインボイスの場合は、インボイスを作成後すぐに忘れてしまい、
  代わりに要求したユーザーにインボイスのパラメーターを与えることができると提案しました。
  これらのパラメーターは、支払いと共に送信され、サービスはインボイスを再構築し、支払いを受け入れ、
  注文を処理することができます。

  回答者の中には、このアイディアが不要ではないかと[懸念する人もいました][osuntokun reply]。
  別の方法でアプリにリクエストを殺到させることは可能であり、
  それらの問題を解決するためには、インボイスのリクエストの殺到も解決する必要があります。
  しかし、このアイディアは有用であると考える人もいました。
  このアイディアはプロトコルの変更を必要とせず、
  インボイスの生成と再構築を管理するソフトウェア（またはプラグイン）の変更だけで済みます。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-does-the-txid-have-256-bits-when-bitcoin-s-address-security-is-160-bit-->Bitcoinのアドレスの安全性は160 bitなのに、なぜTXIDは256 bitなのですか？]({{bse}}109652)
  Pieter Wuilleは、Bitcoinにおけるビットサイズを検討する際に考慮すべき3つのセキュリティ上の問題点、すなわち、
  原像耐性、衝突耐性、存在的偽造について解説しています。さらに、
  これらの考慮事項に対して、Bitcoinの128 bitのセキュリティレベルの目標がどう達成されるか（あるいは達成されないか）を説明しています。

- [<!--why-are-op-return-transactions-discouraged-does-using-version-or-locktime-make-any-difference-->なぜOP_RETURNトランザクションは推奨されないのか？バージョンとlocktimeの使い分けには何の違いがあるのか？]({{bse}}108389)
  Pieter Wuilleは、`OP_RETURN`がどのように[コインを燃やすのか][se 109747]を技術的な側面から説明すると共に、
  `OP_RETURN`をデータストレージに使用することについての見解を述べています。

- [<!--using-non-standard-version-numbers-in-transactions-->トランザクションで非標準のバージョン番号の使用]({{bse}}108248)
  Andrew ChowとG. Maxwellは、トランザクションの標準バージョン番号は1と2のみであるため、
  マイナーに別のバージョンを受け入れさせることができたとしても、
  将来のコンセンサスルールがそのバージョンに適用されると、
  それらのアウトプットが使用できなくなったり、トランザクション自体が無効なったりする可能性があると説明しています。

- [<!--is-there-historical-data-of-utxos-by-address-type-->アドレスタイプ別のUTXOの履歴データはありますか？]({{bse}}109776)
  Murchは、[transactionfee.info][]のチャートの例をいくつか紹介しています。

- [<!--how-are-op-csv-and-op-cltv-backwards-compatible-->OP_CSVとOP_CLTVの後方互換性はどうなってますか？]({{bse}}109834)
  Andrew Chowは、BIP65とBIP112の両方の[タイムロック][topic timelocks]の歴史的な
  [ソフトフォークのアクティベーション][topic soft fork activation]の仕組みについて説明しています。

## Taprootの準備 #15: まだ必要なsignmessageプロトコル

*ブロック高{{site.trb}}のTaprootのアクティベーションに向けて、
開発者やサービスプロバイダーがどのような準備をすればよいかについての週刊[シリーズ][series preparing for taproot]です。*

{% include specials/taproot/ja/14-signmessage.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 0.21.2][bitcoin core 0.21.2]は、Bitcoin Coreのメンテナンスバージョンのリリースです。
  これには、いくつかのバグ修正と軽微な改善が含まれています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #12677][]では、ウォレットの`listunspent` RPCメソッドが返すトランザクションアウトプットに、
  `ancestorcount`および`ancestorsize`、`ancestorfees`フィールドを追加しました。
  トランザクションアウトプットを作成したトランザクションが未承認の場合、これらのフィールドは、
  そのトランザクションとmempool内のその未承認の祖先すべての合計カウント、サイズ、手数料を示します。
  マイナーはこれらの祖先の手数料率を元にブロックに含めるトランザクションを選択するため、
  祖先のサイズや手数料を知ることはトランザクションの承認時間を推定したり、
  [CPFP][topic cpfp]や[RBF][topic rbf]を使ってトランザクションの手数料を引き上げようとする際に役立ちます。

- [Eclair #1942][]では、経路をキャパシティに基づいて部分的に評価されるよう、
  経路探索アルゴリズムを設定することができます。
  この設定は、ルーティングの成功率を向上させる可能性のある[実験的なパラメーターセット][news166 experiments]として適用できます。
  *[編集: この項目は公開後に修正されました。Thomas Huetからの報告に感謝します。]*

- [LND #5101][]では、RPCリクエストをサーバーに送信する際に、
  それを受信して変更することができる*ミドルウェアインターセプター*を追加しました。
  これにより、LNDの外部にロジックを実装して、ユーザーおよび自動化されたアクションを追跡したり影響を与えたりすることができます。
  セキュリティの観点から、インターセプトをオプトインする認証トークン（macaroons）を明示的に使用するRPCのみをインターセプトできます。

{% include references.md %}
{% include linkers/issues.md issues="12677,1942,5101,2842" %}
[bitcoin core 0.21.2]: https://bitcoincore.org/bin/bitcoin-core-0.21.2/
[kohen post]: https://mailmanlists.org/pipermail/dlc-dev/2021-September/000075.html
[ghost43 post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-September/003229.html
[jager post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-September/003236.html
[osuntokun reply]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-September/003252.html
[se 109747]: https://bitcoin.stackexchange.com/questions/109747/how-does-op-return-burn-coins/109748#109748
[transactionfee.info]: https://transactionfee.info/
[news166 experiments]: /ja/newsletters/2021/09/15/#eclair-1930
[series preparing for taproot]: /ja/preparing-for-taproot/
