---
title: 'Bitcoin Optech Newsletter #270'
permalink: /ja/newsletters/2023/09/27/
name: 2023-09-27-newsletter-ja
slug: 2023-09-27-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Covenantを使用してLNのスケーラビリティを大幅に向上させる提案を掲載しています。
また、Bitcoin Stack Exchangeで人気の質問とその回答の要約や、
新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **Covenantを使用したLNのスケーラビリティの向上:** John Lawは、
  [Covenant][topic covenants]を使用して非常に大規模な[チャネル・ファクトリー][topic channel factories]を作成し、
  これまでに説明したいくつかのプロトコル（ニュースレター[#221][news221 law]、[#230][news230 law]および[#244][news244 law]参照）
  を適用してチャネルを管理する方法について執筆した[論文][law cov paper]の概要を
  Bitcoin-DevメーリングリストとLightning-Devメーリングリストに[投稿しました][law cov post]。

    彼は、[Coinjoin][topic coinjoin]や以前のファクトリーの設計のように、
    多数のユーザーの参加を必要とする署名ベースのプロトコルにおけるスケーラビリティの問題について説明しています。
    たとえば、1,000人のユーザーがプロトコルへの参加に同意したものの、その内の1人が署名中に利用できなくなった場合、
    他の999個の署名は役に立ちません。次の試行中に、別のユーザーが利用できなくなった場合、
    2回めの試行で収集された他の998個の署名も役に立ちません。
    彼は、この問題の解決策として、[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]や
    [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]のようなCovenantを提案しています。
    これらは、1つの小さなトランザクションが、
    その資金を1つ以上の事前に定義された子トランザクションでのみ使用できるように制限できることで知られています。
    その後のトランザクションもCovenantによって制限することができます。

    Lawは、この仕組みを使用して _タイムアウトツリー_ を作成し、
    _ファンディング・トランザクション_ が事前に定義された子トランザクションのツリーに支払いをし、
    それらが最終的にはオフチェーンで多数の個別のペイメントチャネルに支払われます。
    Ark（[ニュースレター #253][news253 ark]参照）で使用されているものと同様の仕組みにより、
    各ペイメントチャネルをオプションでオンチェーンにすることができますが、
    ファクトリーの資金提供者は、有効期限後にオンチェーンに移されていないチャネル資金を回収することもできます。
    これは非常に効率的です。1つの小さなオンチェーントランザクションを使用して、
    何百万ものチャネルに資金を提供するオフチェーンのタイムアウトツリーを作成できます。
    有効期限後、資金はファクトリーの資金提供者によって別の小さなオンチェーントランザクションで回収され、
    個々のユーザーはファクトリーの有効期限が切れる前にLN経由で資金を他のチャネルに引き出すことができます。

    上記のモデルは、現在使用されているLN-Penaltyチャネルの構成と、
    提案中の[LN-Symmetry][topic eltoo]の仕組みと互換性があります。ただ、
    Lawの論文の残りの部分では、Covenantベースのファクトリーの設計にいくつかの利点をもたらす、
    彼が提案したFFO-WF（Fully Factory Optimized Watchtower Free）プロトコルの修正について検討しています。
    以前のニュースレターで説明した、
    _カジュアルなユーザー_ は数ヶ月に数分間だけオンラインになることで済むことや、
    _熱心なユーザー_ はチャネルをまたいで資金をより効率的に使用できることなどの利点に加えて、
    更新された構成の新たな利点により、ファクトリーの資金提供者は、
    カジュアルユーザーの資金をある（特定のオンチェーントランザクションに基づく）ファクトリーから
    （別のオンチェーントランザクションでアンカリングされている）別のファクトリーに、
    ユーザーとのやり取りなしで移動することができます。
    つまり、ファクトリーの6ヶ月の有効期限が切れる前にオンラインになる必要があることを知っているカジュアルユーザーのアリスは、
    5ヶ月めにオンラインになって、有効期限までさらに数ヶ月ある新しいファクトリーに彼女の資金が既にロールオーバーされていることに気づくかもしれません。
    アリスは何もする必要はありません。彼女は自分の資金をトラストレスに完全に管理しています。
    これにより、アリスが有効期限間近にオンラインになり、ファクトリーの資金提供者が一時的に利用できないことが分かり、
    タイムアウトツリーの一部をオンチェーン化せざるを得なくなり、
    トランザクション手数料が発生し、ネットワーク全体のスケーラビリティが低下するといった可能性を減らすことができます。

    Anthony Townsは、大規模な熱心なユーザーの故意または偶発的な障害により、
    他の多くのユーザーが同時に多くの時間的制約のあるトランザクションをオンチェーン化する必要がある
    「Thundering Herd」問題（[LNのオリジナルの論文][ln paper]では
    「forced expiration spam」と呼ばれている）について懸念を[表明しました][towns cov]。
    たとえば、100万人のユーザーがいるファクトリーでは、これらのユーザーが資金を新しいチャネルに戻すのに、
    最大100万件のトランザクションの時間制限のある承認と、
    さらに最大200万件のトランザクションの時間制限のない承認が必要になる場合があります。
    現在、ネットワークが300万件のトランザクションを承認するのに約1週間かかるため、
    100万人のユーザーを持つファクトリーのユーザーは、
    有効期限が切れる数週間前にファクトリーに資金をオールオーバーしてもらいたいと望むかもしれません。
    あるいは、いくつかの100万人規模のファクトリーで同時に問題が発生することを心配する場合、
    数ヶ月前にロールオーバーすることを望むかもしれません。

    LNのオリジナルの論文では、「ブロックがいっぱい」の（たとえば、手数料率が通常の金額を超えている）場合に、
    有効期限を遅らせるGregory Maxwellの[アイディア][maxwell clock stop]を使って、
    この問題に対処できる可能性があることを示唆しています。
    LawはTownsへの[返信][law fee stop]の中で、その種の解決策の具体的な設計に取り組んでおり、
    考えたまとまったら発表すると述べています。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Bitcoin v0.1ではピアの検出はどのように機能していたのか？]({{bse}}119507)
  Pieter Wuilleは、0.1リリースのIRCベースのピア検出から、ハードコードされたIPアドレスを経て、
  現在使用されているDNSのピアシードまで、Bitcoin Coreのピア検出の仕組みの進化について説明しています。

- [<!--would-a-series-of-reorgs-cause-bitcoin-to-break-because-of-the-2-hour-block-time-difference-restriction-->一連の再編成により、2時間のブロックの時間差制限によりBitcoinが壊れる可能性はありますか？]({{bse}}119677)
  ユーザー fiatjafは、[フィー・スナイピング][topic fee sniping]の結果である可能性がある、
  ブロックチェーンの一連の再編成がBitcoinのブロックタイムスタンプの制限の問題を引き起こす可能性があるか尋ねています。
  Antoine PoinsotとPieter Wuilleは、2つのブロックタイムスタンプの制限（
  [MTP（Median Time Past）][news146 mtp]より大きくなければならないことと、
  ノードのローカル時間から2時間以上未来のものであってはならないこと）について説明し、
  どちらの制限の条件も再編成によって悪化するものではないと結論づけています。

- [<!--is-there-a-way-to-download-blocks-from-scratch-without-downloading-block-headers-first-->最初にブロックヘッダーをダウンロードせずに、ブロックを一からダウンロードする方法はありますか？]({{bse}}119503)
  Pieter Wuilleは、ヘッダーなしでブロックをダウンロードできることを確認したが、
  すべてのブロックをダウンロードして処理するまでノードがベストチェーン上にあるかどうか分からないことが欠点だと指摘しています。
  彼はそのアプローチを[ヘッダーファーストの同期][headers first pr]と対比し、
  それぞれのアプローチで交換されるP2Pメッセージの概要を説明しています。

- [<!--where-is-the-bitcoin-source-code-is-the-21-million-hard-cap-stated-->2,100万のハードキャップが記載されているBitcoinのソースコードはどこにありますか？]({{bse}}119475)
  Pieter Wuilleは、報酬の排出スケジュールを定義するBitcoin Coreの`GetBlockSubsidy`関数について説明しています。
  彼はまた、Bitcoinの[20999999.9769 BTC制限]({{bse}}38998)に関する以前のStack Exchangeの議論をリンクし、
  コンセンサスの検証コードでサニティチェックとして使用されている`MAX_MONEY`定数についても指摘しています。

- [<!--are-blocks-containing-non-standard-transactions-relayed-through-the-network-or-not-as-in-the-case-of-non-standard-transactions-->非標準トランザクションを含むブロックは、ネットワークでリレーされますか？それとも非標準トランザクションのようにリレーされませんか？]({{bse}}119693)
  ユーザー fiatjafは、非標準トランザクションは[ポリシー][policy series]に従ってデフォルトではP2Pネットワーク上でリレーされませんが、
  非標準トランザクションを含むブロックは、コンセンサスルールを遵守していればリレーされると回答しています。

- [Bitcoin Coreはどのような場合に"トランザクションを破棄"できるのか？]({{bse}}119771)
  Murchは、Bitcoin Coreでトランザクションを[破棄][rpc abandontransaction]できるようになるために必要な3つの条件を詳しく説明しています:

  - トランザクションが以前に破棄されていない
  - そのトランザクションも競合するトランザクションも承認されていない
  - そのトランザクションがノードのmempoolにない

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND v0.17.0-beta.rc5][]は、この人気のLNノード実装の次期メジャーバージョンのリリース候補です。
  このリリースで予定されている主な実験的な新機能は、テストの恩恵を受ける可能性が高そうな、
  「Simple taproot channel」のサポートです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #28492][]は、[PSBT][topic psbt]の処理結果が
  ブロードキャスト可能なトランザクションになる場合、シリアライズされた完全なトランザクションを含めるよう
  `descriptorprocesspsbt` RPCを更新しました。同様のマージ済みのPRのについては、
  [先週のニュースレター][news269 psbt]をご覧ください。

- [Bitcoin Core GUI #119][]では、GUIのトランザクションのリストが更新され、
  「自分自身への支払い（payment to yourself）」という特別なカテゴリを提供しなくなりました。
  ウォレットに影響を与えるインプットとアウトプットの両方を持つトランザクションは、
  支払いと受け取りで別々の行に表示されるようになりました。
  これにより、[Coinjoin][topic coinjoin]や[Payjoin][topic payjoin]の分かりやすさが向上しますが、
  Bitcoin Coreは現在これらのタイプのトランザクションのどちらもサポートしていません。

- [Bitcoin Core GUI #738][]は、
  BerkeleyDB (BDB)に保存されている鍵と暗黙のアウトプットスクリプトタイプに基づくレガシーウォレットを、
  SQLiteに保存される[ディスクリプター][topic descriptors]を使用する最新のウォレットに移行できるようにするメニューオプションを追加しています。

- [Bitcoin Core #28246][]は、Bitcoin Coreのウォレットが
  トランザクションで支払うべきアウトプットスクリプト（scriptPubKey）を内部的に決定する方法を更新しました。
  これまでは、トランザクションはユーザーが指定したアウトプットスクリプトに支払うだけでしたが、
  [サイレントペイメント][topic silent payments]がBitcoin Coreでサポートされた場合、
  アウトプットスクリプトはトランザクション用に選択されたインプットのデータに基づいて導出する必要があります。
  今回のアップデートにより、それがさらに簡単になりました。

- [Core Lightning #6311][]は、標準のCLNバイナリに追加オプションを備えたバイナリを生成する
  `--developer`ビルドオプションを削除しました。実験的な非デフォルト機能にアクセスするには、
  `--developer`ランタイム設定オプションを指定して`lightningd`を起動します。
  `--enable-debug`ビルドオプションは、引き続きテストに有益な変更が加えられた若干異なるバイナリを生成します。

- [Core Lightning #6617][]は、`showrunes` RPCを更新し、
  _rune_ （認証トークン）が最後に使用された時間を表示する新しいフィールド`last_used`を提供します。

- [Core Lightning #6686][]は、CLNのAPIのRESTインターフェースに対して設定可能な
  CSP（Content-Security-Policy）とCORS（Cross-Origin-Resource-Sharing）ヘッダーが追加されました。

- [Eclair #2613][]により、Eclairは自身の秘密鍵をすべて管理し、
  監視専用ウォレット（公開鍵はあるが秘密鍵は持たないウォレット）のみでBitcoin Coreを使用できるようになりました。
  これは、EclairがBitcoin Coreよりも安全な環境で実行されている場合に特に役立ちます。
  詳細については、このPRで追加された[ドキュメント][eclair keys]をご覧ください。

- [LND #7994][]は、Taprootチャネルを開くためのサポートをリモートサイナーRPCに追加しました。
  これには、公開鍵と[MuSig2][topic musig]の2部構成のnonceを指定する必要があります。

- [LDK #2547][]は、リモートチャネルの流動性のほとんどがチャネルの片側に押し出されている可能性が高いと仮定して、
  確率的経路探索のコードを更新しました。たとえば、アリスとボブの1.00 BTCのリモートチャネルでは、
  可能性が最も低いチャネルの状態は、アリスとボブが0.50 BTCずつ持っている状態です。
  どちらかが0.90 BTC持っている可能性の方が高く、0.99 BTC持っている方がさらに可能性が高いという状態です。

- [LDK #2534][]は、支払いの送信を試みる前に支払いの経路を[調査する（プロービング）][topic payment probes]ための
  `ChannelManager::send_preflight_probes`メソッドを追加しました。
  プロービングは通常のLN支払いと同様に送信者によって生成されますが、
  その[HTLC][topic htlc]のプリイメージの値は使用できない値（たとえば送信者のみが知っている値）が設定されます。
  宛先に到着すると、受信側はプリイメージを知らないため、拒否し、エラーを返します。
  そのエラーを受け取った場合、その送信者は、送信時に支払いをサポートするのに十分な流動性がその経路にあったことを知り、
  同じ金額で同じ経路を通って送信された実際の支払いは成功する可能性が高いでしょう。
  経路の途中のホップの1つが支払いを転送できなかったことを示すエラーのような、異なるエラーを受信した場合、
  実際の支払いを送信する前に、新しい経路を調査することができます。

  プリペイメント（プリフライト）プロービングは、遅延の原因となる可能性のある問題を抱えているホップを見つけるために、
  少額の資金で有用です。数百 sat（またはそれ以下）が数時間滞っても、ほとんどの支払人にとっては大したことではありません。
  しかし、ノードの資本のかなりを占める支払いの全額が滞ってしまうと、非常に迷惑なことになります。
  また、いくつかの経路を同時に調査し、その結果を使用して、数分後に支払いを送信する際に最適な経路を選択することも可能です。

{% include references.md %}
{% include linkers/issues.md v=2 issues="28492,119,738,28246,6311,6617,6686,2613,7994,2547,2534" %}
[LND v0.17.0-beta.rc5]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc5
[news253 ark]: /ja/newsletters/2023/05/31/#joinpool
[maxwell clock stop]: https://www.reddit.com/r/Bitcoin/comments/37fxqd/it_looks_like_blockstream_is_working_on_the/crmr5p2/
[law cov post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004092.html
[law cov paper]: https://github.com/JohnLaw2/ln-scaling-covenants
[towns cov]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004095.html
[ln paper]: https://lightning.network/lightning-network-paper.pdf
[law fee stop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004102.html
[news221 law]: /ja/newsletters/2022/10/12/#ln
[news230 law]: /ja/newsletters/2022/12/14/#ln
[news244 law]: /ja/newsletters/2023/03/29/#preventing-stranded-capital-with-multiparty-channels-and-channel-factories
[eclair keys]: https://github.com/ACINQ/eclair/blob/d3ac58863fbb76f4a44a779a52a6893b43566b29/docs/ManagingBitcoinCoreKeys.md
[news269 psbt]: /ja/newsletters/2023/09/20/#bitcoin-core-28414
[news146 mtp]: /ja/newsletters/2021/04/28/#what-are-the-different-contexts-where-mtp-is-used-in-bitcoin-bitcoin-mtp
[headers first pr]: https://github.com/bitcoin/bitcoin/pull/4468
[policy series]: /ja/blog/waiting-for-confirmation/
