---
title: 'Bitcoin Optech Newsletter #159'
permalink: /ja/newsletters/2021/07/28/
name: 2021-07-28-newsletter-ja
slug: 2021-07-28-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、恒例のBitcoin Stack Exchangeでの先月の最良の質問と回答や、
Taprootの準備に関する最新のコラム、新しいソフトウェアのリリースとリリース候補のリスト、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点について掲載しています。

## ニュース

*今週は重要なニュースはありません。*

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--what-is-this-unusual-transaction-in-the-bitcoin-blockchain-->Bitcoinのブロックチェーン上のこの変わったトランザクションは何ですか？]({{bse}}107603)
  Murchは、[ブロックエクスプローラー][topic block explorers]で"UNKNOWN"と表示されたアウトプットについて説明しています。
  このアウトプットは、不自然な公開鍵を持つをsegwit version 1のアウトプットです。
  0xb10cが指摘するように、このアウトプットを作成した2019年のトランザクションは、
  [Optechの互換性マトリックス][compat matrix]に対するsegwit v1サポートをテストすることを目的としていました。
  以前警告したように（[ニュースレター #158][news158 taproot]参照）、
  P2TRアウトプットは、0xb10cが実証し[ブログ記事で詳しく説明しているように][0xB10C blog]、
  Taprootのアクティベート前は誰もが使用可能です。

- [<!--what-are-miners-signalling-for-when-the-block-header-nversion-field-ends-in-4-i-e-0x3fffe004-->0x3fffe004のようにブロックヘッダーのnversionフィールドが4で終わっている場合、マイナーは何を通知しているのですか？]({{bse}}107443)
  ASICBoostのovert形式を調査している際に、ユーザーshikaridotaは、
  最近マイニングされたブロックの`nVersion`フィールドにビット 2が設定されている理由を疑問に思っていました。
  Andrew Chowは、[BIP341のデプロイメント][bip341 deployment]セクションで指定されているように、
  [Taproot][topic taproot]がビット 2を使ってアクティベーションの通知を送っていると指摘しました。

- [<!--where-can-i-find-bitcoin-s-alpha-version-with-15-minute-block-time-intervals-->Bitcoinのアルファ版でブロックの時間間隔が15分のものはどこにありますか？]({{bse}}107407)
  Andrew Chowは、Satoshiが作成したとされる[ソースコードの中から][bitcointalk 15min]、
  15分のブロック時間と30日のリターゲット期間が含まれているものを紹介しています。

- [<!--what-s-the-purpose-of-using-guix-within-gitian-doesn-t-that-reintroduce-dependencies-and-security-concerns-->Gitian内でGuixを使用する目的は何ですか？それは依存関係とセキュリティの懸念を再導入することになりませんか？]({{bse}}107638)
  Andrew Chowとfanquakeは、[Gitianビルド][github gitian builds]と
  [Guixを使用したブートストラップ可能なビルド][github contrib guix]の使用を含めた再現可能なビルドの利点を説明し、
  両者の併用についてコメントしています。

- [<!--why-are-there-several-round-number-transactions-with-no-change-->なぜお釣りのない丸めた数値のトランザクションがいくつもあるのですか？]({{bse}}107418)
  Shmは、多くのインプットがあり、
  お釣りのない単一の丸めた数値のアウトプットを持つ一連の関連するトランザクションについて質問しています。
  Murchは、多数のUTXOを持つウォレットの文脈で[お釣りの回避][bitcoin wiki change avoidance]を説明し回答しています。
  お釣りの回避により、より小さなトランザクション、将来の手数料の削減、プライバシーの改善が可能になります。

## Taprootの準備 #6: Taprootを使って学ぶ

*ブロック高{{site.trb}}のTaprootのアクティベーションに向けて、
開発者やサービスプロバイダーがどのような準備をすればよいかについての週刊[シリーズ][series preparing for taproot]です。*

{% include specials/taproot/ja/05-taproot-notebooks.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Rust Bitcoin 0.27.0] (bech32mサポート) は新しいリリースです。
  最も注目すべきは、[bech32m][topic bech32]アドレスの処理をサポートしたことです。

- [C-Lightning 0.10.1rc1][C-Lightning 0.10.1]は、多くの新機能や、いくつかのバグ修正および、
  （[デュアル・ファンディング][topic dual funding]や[Offer][topic offers]を含む）
  開発中のプロトコルのいくつかのアップデートを含むアップグレードのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #22387][]では、各ピアから処理する通知されたアドレスの平均数を10秒に1つに制限します。
  制限を超えるアドレスは無視されます。ピアをホワイトリストに登録し、この制限を超えられるようにすることは可能です。
  また、ノードがピアから明示的に要求するアドレス通知も制限から除外されます。
  この制限は、Bitcoin Coreノードがアドレスを通知する現在のレートの4倍になると推定されます。

- [C-Lightning #4669][]は、[LN offer][topic offers]のパースと検証ロジックのいくつかのバグを修正しました。
  また、ユーザーが同じパラメータで新しいOfferを作成しようとすると、
  以前作成された有効期限の切れていないOfferを返します。
  Offerはデフォルトで有効期限付きで作成されないため、これは特に便利です。

- [C-Lightning #4639][]は、[BOLTs #878][]で提案された流動性の配信を実験的にサポートします。
  これにより、ノードはLNゴシッププロトコルを使って、資金を一定期間貸し出す意思があることを配信し、
  他のノードに即時支払いを受けられるインバウンド・キャパシティを購入する能力を与えることができます。
  配信を確認したノードは、[デュアル・ファンディング][topic dual funding]
  チャネルを開いてインバウンド・キャパシティの支払いと受信を同時に行うことができます。
  配信ノードが実際に支払いをルーティングすることを強制する方法はありませんが、
  この提案には、合意したリース期間が終了するまで配信者が資金を他の目的に使用できないようにするという、
  [Lightning Pool][]でも使用が予定されている以前の[提案][zmn liquidity providers]が組み込まれているため、
  ルーティングを拒否しても、ルーティング手数料を獲得する機会が失われるだけです。
  以下の表は、流動性の配信と[ニュースレター #123][news123 lightning pool]に掲載した同様のLightning Pool市場との比較です。

  <!-- [1]: See "Service-Level Based Lifetime Enforcement" in
  https://lightning.engineering/posts/2020-11-02-pool-deep-dive/ -->

   <table>
    <tr>
     <th></th>
     <th>Lightning Pool</th>
     <th>流動性の配信</th>
    </tr>

    <tr>
     <th>リストの管理</th>
     <td>中央化: キュレーションにより高品質のリストを確保できるが、リストの検閲も可能</td>
     <td>分散化: リストを検閲することはできないが、ユーザーはリースを購入する前に独自の調査が必要</td>
    </tr>

    <tr>
     <th>ライセンス</th>
     <td>オープンソースクライアント、専用サーバー、オープンなプロトコル</td>
     <td>すべてオープンソース</td>
    </tr>

    <tr>
     <th>価格情報</th>
     <td>実際に支払われた価格は、公開オークション結果による公開情報</td>
     <td>配信された価格は、パブリックなゴシップネットワークの公開情報</td>
    </tr>

    <tr>
     <th markdown="span">第三者による流動性の購入("[sidecar channels][]")</th>
     <td>はい。アリスはボブにキャロルとのチャネルの資金の支払いが可能</td>
     <td markdown="span">[おそらく可能]({{bse}}107786)</td>
    </tr>

   </table>

- [BIPs #1072][]は、"Multi-Script Hierarchy for Multi-Sig Wallets"と題された情報 [BIP48][]をマージしました。
  このドキュメントでは、`m/48'`プレフィックスをベースにしたマルチシグのセットアップに参加するウォレットに広く展開されている導出標準について説明し、
  スキームで使用される6つの導出レベルについて詳しく説明しています。

- [BIPs #1139][]は、[Taproot][topic taproot]トランザクションで
  [PBST][topic psbt]（[version 0][BIP174]と[version 2][BIP370]の両方）を使用するための新しいフィールドの仕様を含む[BIP371][]を追加しています。
  これまでの議論は[ニュースレター #155][news155 tr psbts]をご覧ください。

## 謝辞と編集

Bitcoin Core PR #22387 に関する私たちの最初の説明では、
新しいレートの制限は測定されたレートの約40倍であると記載していました。
正しい数値は約4倍です。この誤りを報告してくれたAmiti Uttarwarに感謝します。

{% include references.md %}
{% include linkers/issues.md issues="22387,4669,4639,878,1072,1139" %}
[C-Lightning 0.10.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.1rc1
[rust bitcoin 0.27.0]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/0.27.0
[sidecar channels]: https://lightning.engineering/posts/2021-05-26-sidecar-channels/
[news123 lightning pool]: /en/newsletters/2020/11/11/#incoming-channel-marketplace
[news155 tr psbts]: /ja/newsletters/2021/06/30/#taproot-psbt
[zmn liquidity providers]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001555.html
[lightning pool]: https://lightning.engineering/posts/2020-11-02-pool-deep-dive/
[compat matrix]: /en/compatibility/
[news158 taproot]: /ja/newsletters/2021/07/21/#taprootの準備-5-なぜ待つ必要があるのか
[0xB10C blog]: https://b10c.me/blog/007-spending-p2tr-pre-activation/
[bip341 deployment]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#deployment
[bitcointalk 15min]: https://bitcointalk.org/index.php?topic=382374.msg4108739#msg4108739
[bitcoin wiki change avoidance]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Change_avoidance
[github gitian builds]: https://github.com/bitcoin-core/docs/blob/master/gitian-building.md
[github contrib guix]: https://github.com/bitcoin/bitcoin/blob/master/contrib/guix/README.md
[series preparing for taproot]: /ja/preparing-for-taproot/
