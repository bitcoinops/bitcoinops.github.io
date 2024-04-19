---
title: 'Bitcoin Optech Newsletter #142'
permalink: /ja/newsletters/2021/03/31/
name: 2021-03-31-newsletter-ja
slug: 2021-03-31-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、LNの確率的な経路選択に関する論文と簡単な議論に、
Bitcoin Stack Exchangeで人気のあった質問と回答および、リリースとリリース候補、
Bitcoinインフラストラクチャソフトウェアの注目すべき変更点などの通常のセクションを掲載しています。

## 要処置事項

- **<!--upgrade-btcpay-server-to-1-0-7-1-->BTCPay Server 1.0.7.1へのアップグレード:**
  プロジェクトのリリースノートによると、この[リリース][btcpay server 1.0.7.1]は、
  "BTCPay Serverのバージョン1.0.7.0およびそれ以前のバージョンに影響を与える１つの重要な脆弱性と、
  いくつかの影響の少ない脆弱性"を修正しています。

## ニュース

- **<!--paper-on-probabilistic-path-selection-->確率的な経路選択に関する論文:**
  René Pickhardtは、Sergei Tikhomirov、Alex BiryukovおよびMariusz Nowostawskiとの共著の[論文][pickhardt et al]を
  Lightning-Devメーリングリストに[投稿しました][pickhardt post]。
  この論文では、それぞれのチャネル・キャパシティの範囲内で残高が一様に分布しているチャネルのネットワークをモデル化しています。
  例えば、アリスとボブの間に1億satoshiのキャパシティを持つチャネルがある場合、
  論文では、そのチャネルでは次のステートがすべて同じように起こりうると仮定し、
  ネットワーク上の他のすべてのチャネルでも同じことが当てはまるとしています:

  | アリス | ボブ |
  | 0 sat | 100,000,000 sat |
  | 1 sat | 99,999,999 sat |
  | ... | ...|
  | 100,000,000 sat | 0 sat |

  この仮定を立てることで、金額と通過するホップ（チャネル）数に基づいて、
  支払いが成功する確率を導き出すことができます。これにより著者は、経路を短くしたり、
  [マルチパス支払い][topic multipath payments]を利用して大きな金額の支払いを小さな金額の支払いに分割するなどの
  いくつかの既知ヒューリスティックの利点を（他の仮定の下で）証明することができます。
  また、このモデルを使用して[bolts #780][]を使用した[Just-In-Time (JIT)リバランシング][topic jit routing]などの
  新しい提案を評価しています。

  この論文では、その結論を使用して、既存のルーティングアルゴリズムを単純化した場合と比較して、
  支払いのリトライを20%削減できるルーティングアルゴリズムを提供しています。
  既存のアルゴリズムがヒュリスティックなアプローチをを使用しているのに対し、
  このアルゴリズムは、より高い成功確率が計算された経路を優先します。
  また、JITリバランシングと組み合わせることで、48%の改善が見込まれています。
  リトライには通常数秒、場合によってはそれ以上時間がかかることを考えると、
  これはユーザーエクスペリエンスの向上につながる可能性があります。
  このアルゴリズムは、約1,000のライブチャネルのスナップショットから抽出されたものを含む、
  いくつかのネットワーク例に対してテストされています。

  この論文では、ルーティング手数料を意図的に考慮していないため、メーリングリストでは、
  ユーザーが過剰な手数料を支払わないようにしつつ結果をどう利用するかという点に焦点があてられました。

- **<!--updated-article-about-payment-batching-->支払いバッチについての記事を更新:**
  Optechは、[ニュースレター #37][news37 batching]で発表した[支払いバッチに関する記事][batching post]を更新して掲載しました。
  支払いバッチは、使用者の取引手数料を約80%節約することができる手法です。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・答えを紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--how-hard-is-it-for-an-exchange-to-adopt-native-->取引所がネイティブSegwitを採用するのはどれくらい難しいですか？]({{bse}}103674)
  Bitcoin開発者のinstagibbsは、アドレスの生成や、使用可能性の確保、サポートやビジネス上の考慮事項、
  ハードウェアセキュリティモジュール（HSM）などの署名インフラとの互換性など、
  ネイティブSegwitを実装する取引所の考慮事項をいくつか挙げています。

- [<!--how-do-you-calculate-when-98-of-bitcoin-will-be-mined-->ビットコインの98%がマイニングされる時期はどのように計算するのですか？]({{bse}}103159)
  Murchは、全ビットコインの98%がマイニングされる時期について、2030〜2031年という予測をしており、
  追加の指標を含む[報酬スケジュールのGoogleシート][reward schedule google sheet]もリンクしています。

- [<!--how-can-i-use-bitcoin-core-with-the-anonymous-network-protocol-->匿名ネットワーク・プロトコルI2PでBitcoin Coreを使うにはどうしたらいいですか？]({{bse}}103402)
  [Bitcoin Core #20685][news139 i2p]のマージにより、BitcoinはI2Pネットワークをサポートしています。
  Michael Folksonは、I2Pを使用するためのBitcoin Coreの設定方法について
  [Jon Atackの元のスレッド][jonatack twitter i2p]を要約しています。

- [<!--will-nodes-with-a-larger-than-default-mempool-retransmit-transactions-that-have-been-dropped-from-smaller-mempools-->デフォルトより大きなmempoolを持つノードは、小さなmempoolからドロップされたトランザクションを再送しますか？]({{bse}}103104)
  Pieter Wuilleは、トランザクションの再ブロードキャストは現在[ウォレットの責任][se 103261]であり、
  おそらくノードは未確認のトランザクションも再ブロードキャストすべきで、
  [Bitcoin Core #21061][]がその目標に向かって取り組んでいることを指摘しています。

- [<!--should-block-height-or-mtp-or-a-mixture-of-both-be-used-in-a-soft-fork-activation-mechanism-->ソフトフォークのアクティベーションの仕組みでは、ブロック高もしくはMTP、或いはその両方を混合したものを使用すべきでしょうか？]({{bse}}103854)
  David A. Hardingは、Bitcoinのタイミングの仕組みとして、Median Time Past (MTP)とブロック高の両方のメリットとデメリットを解説しています。
  MTPはおおよそのクロックタイムに対応していますが、マイナーがシグナリング期間をスキップするよう操作できます。
  ブロック高は時間の均一性はありませんが、MTPのマイナーゲームのようなものはありません。

- [<!--why-is-it-recommended-to-not-send-round-number-amounts-when-making-payments-for-increased-privacy-->プライバシー保護のために"支払い時に丸めた金額を送らない"ことが推奨されるのはなぜですか？]({{bse}}103260)
  ユーザーchytrikは、[丸めた数値のヒューリスティック][wiki privacy round numbers]と、
  丸めた金額の支払いを避けるのがなぜプライバシーに良いのか説明するためにさまざまな例を挙げています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BTCPay Server 1.0.7.1][]は、いくつかのセキュリティ上の脆弱性を修正しています。
  またいくつかの改善とセキュリティ以外のバグ修正も含まれています。

- [HWI 2.0.1][]は、
  Trezor Tのパスフレーズ入力や`hwi-qt`インターフェースのキーボード・ショートカットに関する小さな問題に対応したバグ修正リリースです。

- [C-Lightning 0.10.0-rc2][C-Lightning 0.10.0]は、このLNノードソフトウェアの次期メジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #17227][]では、
  AndroidOS用のbitcoin-qtをパッケージする新しい`make apk`ターゲットをビルドシステムに追加しました。
  これは、Android NDKのパッケージ化のサポートを追加した[以前の作業][news 72 android ndk]の続きです。
  また、Android用のBitcoin Coreをビルドするための[ドキュメント][android build doc]や、
  Androidビルドシステムをテストするための[継続的インテグレーションのジョブ][android ci]も含まれています。

- [Rust-Lightning #849][]では、チャネルの`cltv_expiry_delta`を設定可能にし、
  デフォルト値を72ブロックから36ブロックに下げました。このパラメータは、
  ノードが下流のピアからの支払いが成功したかどうか確認した後、
  上流のピアとの支払いの試行を決済する必要がある期限を設定します。
  必要に応じて、トランザクションをオンチェーンで確認するのに十分な長さでなければなりませんが、
  可能な限り遅延を最小限に抑えようとしている他のノードと競争できる程度には短くなければなりません。
  LNDがその値を40ブロックに下げた[ニュースレター #40][news40 cltv_expiry_delta]も参照ください。

- [C-Lightning #4427][]では、設定オプション`--experimental-dual-fund`を使うことで、
  [デュアル・ファウンド][topic dual funding]ペイメントチャネルの実験が可能になりました。
  デュアル・ファンディングでは、チャネルの初期残高を
  チャネルを開始するノードとチャネルを受け入れるノードの両方から拠出できるようになります。
  これはチャネルの開設が終わるとすぐに支払いの受け取りを始めたいマーチャントや他のユーザーにとって便利です。

- [Eclair #1738][]では、 [Anchor Output][topic anchor outputs]が使用されている際の、
  失効した[HTLC][topic HTLC]のペナルティ実行の仕組みを更新しました。変更はAnchor Outputとは無関係ですが、
  Anchor Outputがプロトコルに追加されると同時に導入され、
  複数の`SIGHASH_SINGLE|SIGHASH_ANYONECANPAY`HTLCアウトプットを１つのトランザクションにまとめることができるようになりました（[ニュースレター #128][news128
  bolts803]参照）。このPRにより、失効鍵で使用可能なすべてのアウトプットを、トランザクション毎に１つだけでなく、
  すべてを同じトランザクションで請求することが保証されます。

- [BIPs #1080][]は、指定された高さになるまでノードがロックインされたソフトフォークの適用を開始する時間を遅らせる`minimum_activation_height`パラメータで[BIP8][]を更新しました。
  これによりBIP8は*Speedy Trial*の提案（[ニュースレター #139][news139 speedy trial]参照）と互換性があり、
  マイナーは[Taproot][topic taproot]をアクティベートできますが、
  Speedy Trialを実装したソフトウェアのリリースから約6ヶ月後までTaprootのルールの適用を開始しません。

{% include references.md %}
{% include linkers/issues.md issues="17227,849,4427,1738,1080,1080,780,21061" %}
[c-lightning 0.10.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.0rc2
[hwi 2.0.1]: https://github.com/bitcoin-core/HWI/releases/tag/2.0.1
[news40 cltv_expiry_delta]: /en/newsletters/2019/04/02/#lnd-2759
[pickhardt post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-March/002984.html
[pickhardt et al]: https://arxiv.org/abs/2103.08576
[news139 speedy trial]: /ja/newsletters/2021/03/10/#a-short-duration-attempt-at-miner-activation
[btcpay server 1.0.7.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.0.7.1
[batching post]: /en/payment-batching/
[news37 batching]: /en/newsletters/2019/03/12/#optech-publishes-book-chapter-about-payment-batching
[news 72 android ndk]: /ja/newsletters/2019/11/13/#bitcoin-core-16110
[android build doc]: https://github.com/bitcoin/bitcoin/blob/11840509/doc/build-android.md
[android ci]: https://github.com/bitcoin/bitcoin/blob/11840509/.cirrus.yml#L184-L192
[reward schedule google sheet]: https://docs.google.com/spreadsheets/d/12tR_9WrY0Hj4AQLoJYj9EDBzfA38XIVLQSOOOVePNm0/edit#gid=0
[news139 i2p]: /ja/newsletters/2021/03/10/#bitcoin-core-20685
[jonatack twitter i2p]: https://twitter.com/jonatack/status/1366764964896075776?s=20
[se 103261]: https://bitcoin.stackexchange.com/questions/103261/does-my-node-rebroadcast-its-mempool-transactions-on-startup/103262#103262
[wiki privacy round numbers]: https://en.bitcoin.it/wiki/Privacy#Round_numbers
[news128 bolts803]: /en/newsletters/2020/12/16/#bolts-803
