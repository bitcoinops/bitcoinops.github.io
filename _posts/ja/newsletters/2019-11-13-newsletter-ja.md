---
title: 'Bitcoin Optech Newsletter #72'
permalink: /ja/newsletters/2019/11/13/
name: 2019-11-13-newsletter-ja
slug: 2019-11-13-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---

今週のニュースレターでは、Bitcoin Coreの一部古いリリースに影響しているセキュリティ情報公開、taprootに関連する新しい開発、LN paymentのデータ形式に関連する潜在的なプライバシー漏洩、そして議論されているLN仕様に対する2つの変更提案について説明していきます。また、レギュラーセクションではBitcoinプロジェクトに関する注目すべきアップデートを共有します。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

*今週は特になし。*

## News

- **CVE-2017-18350 SOCKSプロキシの脆弱性：** Bitcoin Coreバージョン0.11.0（2012年9月）から0.15.1（2017年11月）の脆弱性の全面開示がBitcoin-Devメーリングリストに [共有されました][cve-2017-18350]。この脆弱性はSOCKSプロキシを、信頼できないサーバーを利用したり信頼できないネットワークを介して接続するように設定したユーザーにのみ影響します。影響を受けるほとんどすべてのバージョンは、以前検知された脆弱性、例えばCVE-2016-10724（ [Newsletter #1][news1 alert])参照）やCVE-2018-17144（ [Newsletter #14][news14 cve]参照）の影響も受けるため、ユーザーは既にBitcoin 0.16.3以降にアップグレードしているはずです。

- **Taprootのレビュー、ディスカッション、関連情報：** [Newsletter
  #69][news69 taproot review]で言及されたtaprootのシステマティックレビューに、163名の方々が登録をしました。先週、このグループは [bip-taproot][]の最初の部分と関連するコノンセプトの[レビューを開始][tr week 1]しました。これには、以前にtaprootの設計に貢献したBitcoinの専門家との質疑応答セッションへの参加が含まれます。

    [質問の1つ][why v1 flex]は、taprootがなぜv1 segwit scriptPubKeysで34バイト以外（未満もしくは以上）---
これはPay-to-Taproot（P2TR）のscriptPubKeyに必要な量 --- の使用を許容するのかについてでした。[BIP141][]  v0 native segwit scriptPubKeysがP2WPKHに対してきっかり22バイト、P2WSHに対して34バイトの使用のみ許可しているため、異常に思えます。答えとしては、より少ない制限により、今後のソフトフォークがv1 scriptPubKeysの他での用途をより短く、もしくは長く定義できるようになるから、ということでした。それまでの間、taprootが採用された場合、これらのより短い/長いv1 scriptPubKeysは、今まで通り誰でも使用できます。

    これを機に、[5月に報告され][bech32 length change]、最近[詳細に説明された][bse bech32 extension]bech32アドレスエンコーディングアルゴリズムの問​​題とこの柔軟性がどのように相互作用するかについて、専門家の間で議論が始まりました。 [BIP173][]で指定されているBech32アドレスは、誤ってコピーされたアドレスで最大4つのエラーが検出され、5つ以上のコピーエラーがあった場合、約1/10億の確率で検出されないとされています。残念ながら、これらの試算は、コピーされたアドレスの長さが元のアドレスと同じであるという仮定の下で行われました。コピーされたアドレスが長いか短い場合、bech32はまれに1文字のエラーでさえ検出できないことがあります。

    既存のP2WPKHおよびP2WSH bech32アドレスの場合、v0 scriptPubKeysがきっかり22または34バイトであるという制限は、誤ったP2WPKHアドレスの場合は追加で12バイトを含める、P2WSHアドレスの場合は12バイトを省略する必要があるため、問題になることはほとんどありません。これは、ユーザーが約19文字（もしくはそれ以下）bech32文字を入力する必要があることを意味し、あり得ないほどの大きな間違いとなるためです。

    ただし、P2TRが34バイトのv1 scriptPubKeysに対してのみ定義されており、33バイトおよび35バイトのv1 scriptPubKeysを誰でも使用できる場合は、1文字の間違いをしただけで、送ろうとした金額をすべてを失う可能性があります。 BIP173とtaprootの著者Pieter Wuilleは、問題に対処するためのいくつかの選択肢をBitcoin-Devメーリングリストに[投稿し][wuille bech32 workaround]、どのオプションが実装されることを望むかについてフィードバックを求めました。1つのオプションは、現在ある全てのbech32実装に、22または34バイトのscriptPubKeyにならないnative segwitアドレスを拒否するように制限をかけることです。そしてその後bech32が追加または削除された文字をより適切に検出できるよう、アップグレードバージョンを開発することを提案します。

    1週間のtaprootのレビュー中に、その他多くのクリティカルではない議論もされ、ディスカッションの詳細に興味がある人は誰でもディスカッションログを見ることが出来ます。 ([1][tr meet1], [2][tr meet2])

    {:#x-only-pubkeys}
    他のschnorr / taprootニュースとしては、Jonas Nickはセキュリティレベル下げることなくシリアル化された公開キーのサイズを33バイトから32バイトに減らした[bip-schnorr][]と[bip-schnorr][]の最近の大きな変更に関する [有益なブログ投稿][x-only pubkeys]を公開しました。この最適化の以前の議論については、[Newsletter#59][news59 proposed 32B pubkeys]および[#68][news68 taproot update]を参照してください。

- **LN<!--1-->オニオン形式でのプライバシー漏洩の可能性：** [BOLT4][]で説明されているように、LNは[Sphinx][]プロトコルを使用してLNノード間で支払い情報を通信します。Olaoluwa Osuntokunは今週Lightning-Devメーリングリストに、Sphinxの当初の説明にある[最近公開された][breaking onion routing] 欠陥は、宛先ノードが「パスの長さの下限を推定できる」と[投稿しました][osuntokun sphinx] 。この修正は簡単です。オニオンパケットの一部をゼロバイトで初期化する代わりに、ランダム値のバイトを利用します。 Osuntokunは、LNDが使用するオニオンライブラリでこれを実装する[PR][lnd-onion]と、BOLTリポジトリの[ドキュメント PR][bolts #697]を作成しました。他の実装でも同じ変更が採用されています（以下の [C-Lightning commit][news72 cl onion]コミットを参照）。

- **LNの前払い：** 現在のLNプロトコルは、支払いの試みが失敗した場合、または受信者によって拒否された場合、すべてのお金を支出者に返すため、支払いの試みが成功した場合のみルーティングノードが収入を受け取ります。一部の新しいアプリケーションでは、この費用のかからない障害メカニズムを使用して、利用するバンドワイズを支払わずにLN経由でデータを送信しています。 LNの設計者はこれらが起こることを予想しており、以前からネットワークに前払い料金を追加する方法について考えていました。つまり、支払いの試みが成功したかどうかに関係なくルーティングノードに金額が支払われる仕組みです。

    今週、Rusty RussellはLightning-Devメーリングリストで[スレッド][russell up-front]を立ち上げ、前払い料金の提案について議論しました。Russellは、ノードがルートの長さを推測するために余分な前払い情報を使用するのを防ぐために、料金とhashcashのproof of workを組み合わせたメカニズムを提案しました。 Anthony Townsは、払い戻しメカニズムを使用した支払い金額の管理に焦点を当てた[部分的代替案][towns up-front]を提案しています。

    Joost Jagerは、少額の追加コストでもマイクロペイメントの採算が取れなくなる可能性があるため、前払いは最後の手段としてのみ必要であることを提案しました。彼はノードレピュテーションに基づくレート制限を使用してバンドワイズの浪費するネットワークアクティビティに対処することが可能であることを提案し、前払いの研究はまず流動性濫用（アタッカーが一定期間in-channelファンドを停止させるなど）の解決に焦点を当てる必要があることを提案しました。これによりルーティングノードのバンドワイズ乱用も防ぐことができます。

    最終的な結論はまだ得られておらず、この記事の執筆時点ではこのトピックに関する議論は継続中です。

- **LNオファー用に提案されたBOLT：** Rusty Russellは、ユーザーがLNルーティングプロトコルを介してオファーを送信し、インボイスを受け取ることができる新しいBOLTのドラフトテキストを[投稿][bolt offers]しました。たとえば、アリスはボブが提供するサービスに加入し、毎月ボブに支払いのオファーを送信し、ボブはインボイスで返信し、アリスはインボイスに支払い、ボブはサービスを提供することが出来ます。

    提案に対する初期のフィードバックは [Universal Business Language][]（UBL）など、機械で読み取りが出来る、確立された言語を使用することが提案されています。しかし、完全なUBL仕様を実装することは、LNソフトウェアの開発者にとって過度の負担になるという懸念も上がっています。

- **Optechウェブサイトの新しいトピックインデックス：** Optechウェブサイトにトピックインデックスを追加し、読者が特定のトピックに言及したOptechウェブサイトの全ページを簡単に見つけられるようにすることを[発表][topics announcement]しました。インデックスは40トピックでまずリリースされており、来年には約100トピックに増やしたいと考えています。

## Notable code and documentation changes

*今週の[Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], および [Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #16110][]は、Android Native Development Kit（NDK）のBitcoin Core（GUIを含む）のビルドのサポートを追加します。 Android NDK用の独自のBitcoin Coreバイナリを構築する[Android Bitcoin Core][] (ABCore)のような独立したプロジェクトとは対照的に、Bitcoin Coreプロジェクトに直接サポートを追加すると、テストが簡単になるでしょう。また、将来のPRにおいて、Androidビルドを確定的に生成された実行可能ファイルを追加追加することもできます。これによりユーザーは、コードリポジトリにあるコードと同じレベルの十分にレビューされたものを実行している、というより大きな保証を受けることができます。

- [Bitcoin Core #16899][]は、現在のUTXOセットのコピーを、将来assumeutxoを活用するブートストラップノードで使用するために設計されたシリアル化形式で、ディスクに書き込む`dumptxoutset` RPCを追加します（  [Newsletter #41][news41 assumeutxo]参照）。さらに、プロジェクトのコントリビューターツールにスクリプトが追加されます。このスクリプトは指定されたブロックの高さにブロックチェーンが巻き戻し、その時点でUTXOセットがダンプしてから、ブロックの再処理が正常に再開します。これにはブロックごとに数秒かかる場合があるため、過去に数千ブロックの高さでこのスクリプトを実行すると、非常に長い時間がかかる場合があります。

- [Bitcoin Core #17258][]は、`listsinceblock` RPCを更新し、別のトランザクションが同じ入力の少なくとも1つを使用し、ブロックがRPCコールによって評価される前にブロックチェーンに既に含まれていたために確認できないトランザクションを、リストしないようにします。

- [C-Lightning #3246][] は今週、LNメーリングリストで説明されている潜在的なデータ漏洩の修正を試みます。

- [LND #3442][]により、支払い側は、シンプルマルチパスペイメント（複数に分割され、異なるチャネルを介して独立してルーティングできる支払い）のパケットを手動で構築できます。これは、ユーザーがアクセスするためのものではなく、マルチパス支払いに関連する機能を追加するであろう、今後のリリースのためのものです。マルチパス支払いの詳細については、[Newsletter #27][news27 multipath]をご参照ください。

- [BIPs #857][]は[BIP157][]を編集して、一度に要求できるコンパクトブロックフィルターの最大数を100から1,000に増やします。これは昨年のPRが1,000から100に下げた数を、また戻すものです。

- [BIPs #849][]は[BIP174][]を編集して、標準化されていない（独自の）アプリケーションで使用するために、部分的署名ビットコイントランザクション（Partially Signed Bitcoin Transactions または PSBT）で特定のデータタイプ識別子を割り当てます。さらに、PSBTには、下位互換性のないPSBTへの変更を識別するのに役立つバージョン番号が付与されるようになりました。明示的なバージョン番号を含まない古いPSBTには、暗示的なバージョン番号0をふります。両方の変更は、Bitcoin-Devメールリスト（[Newsletter #58][news58 psbts]を参照）。

- [BIPs #856][] は、現在の用語「Bitcoin address」（ビットコイン アドレス）を「Bitcoin invoice address」（ビットコインインボイスアドレス）または「invoice address」（インボイスアドレス）や「invoice」（インボイス）などの単純なバリエーションに変更することを提案する提案である[BIP179][]を追加します。これは、以前Bitcoin-Devメーリングリストで[議論][bip179 genesis] されています。

- [BIPs #803][]は [BIP325][]に、マイニングブロックの代わりに署名付きブロックに基づいてテストネットを作成するためのシグネットプロトコルの説明を追加します。シグネットはオペレーターがブロックの生成レートとブロックチェーンの再編成の頻度と規模を制御できるようにします（[Newsletter #37][news37 signet]を参照））。

- [BIPs #851][]は、エラープロトコルの一部として使用することを目的としたトランザクションアナウンスメント調整方法の説明を含む[BIP330][]を追加します（[Newsletter #66][news66 erlay]を参照）。この機能がノードソフトウェアに採用された場合、トランザクションアナウンスメントリレーのバンドワイズオーバーヘッド（現在ある典型的なノードの40％以上のバンドワイズ）を大幅に削減する最初のステップになります。

{% include linkers/issues.md issues="16110,16899,17258,3246,3442,857,856,803,851,16442,3649,697,849,699" %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[bitcoin core 0.19.0]: https://bitcoincore.org/bin/bitcoin-core-0.19.0/
[x-only pubkeys]: https://medium.com/blockstream/reducing-bitcoin-transaction-sizes-with-x-only-pubkeys-f86476af05d7
[news1 alert]: /en/newsletters/2018/06/26/#pending-dos-vulnerability-disclosure-for-bitcoin-core-0-12-0-and-earlier-altcoins-may-be-affected
[news63 carve-out]: /en/newsletters/2019/09/11/#bitcoin-core-16421
[news70 simple commits]: /ja/newsletters/2019/10/30/#ln-simplified-commitments
[news14 cve]: /en/newsletters/2018/09/25/#cve-2018-17144
[news71 ln carve-out]: /ja/newsletters/2019/11/06
[news43 core bip158]: /en/newsletters/2019/04/23/#basic-bip158-support-merged-in-bitcoin-core
[news19 bip70]: /en/newsletters/2018/10/30/#bitcoin-core-14451
[news57 bip37]: /en/newsletters/2019/07/31/#bloom-filter-discussion
[news37 bip61]: /en/newsletters/2019/03/12/#removal-of-bip61-p2p-reject-messages
[news63 new wallet]: /en/newsletters/2019/09/11/#bitcoin-core-15450
[news42 core gui bech32]: /en/newsletters/2019/04/16/#bitcoin-core-15711
[news69 taproot review]: /ja/newsletters/2019/10/23
[sphinx]: https://cypherpunks.ca/~iang/pubs/Sphinx_Oakland09.pdf
[news41 assumeutxo]: /en/newsletters/2019/04/09/#discussion-about-an-assumed-valid-mechanism-for-utxo-snapshots
[news27 multipath]: /en/newsletters/2018/12/28/#multipath-payments
[news58 psbts]: /en/newsletters/2019/08/07/#bip174-extensibility
[news37 signet]: /en/newsletters/2019/03/12/#feedback-requested-on-signet
[news66 erlay]: /ja/newsletters/2019/10/02
[cve-2017-18350]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017453.html
[breaking onion routing]: https://arxiv.org/abs/1910.13772
[bech32 length change]: https://github.com/sipa/bech32/issues/51
[lnd-onion]: https://github.com/lightningnetwork/lightning-onion/pull/40
[news72 cl onion]: /ja/newsletters/2019/11/13/#c-lightning-3246
[tr week 1]: https://github.com/ajtowns/taproot-review/blob/master/week-1.md
[why v1 flex]: http://www.erisian.com.au/meetbot/taproot-bip-review/2019/taproot-bip-review.2019-11-05-19.00.log.html#l-88
[wuille bech32 workaround]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-November/017443.html
[tr meet1]: http://www.erisian.com.au/meetbot/taproot-bip-review/2019/taproot-bip-review.2019-11-05-19.00.log.html
[tr meet2]: http://www.erisian.com.au/meetbot/taproot-bip-review/2019/taproot-bip-review.2019-11-07-02.00.log.html
[russell up-front]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002275.html
[towns up-front]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002307.html
[bolt offers]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002276.html
[osuntokun sphinx]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002288.html
[universal business language]: https://en.wikipedia.org/wiki/Universal_Business_Language
[android bitcoin core]: https://github.com/greenaddress/abcore
[bip179 genesis]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-October/017369.html
[news52 avoid_reuse]: /en/newsletters/2019/06/26/#bitcoin-core-13756
[dust flooding]: {{bse}}81509
[news59 proposed 32B pubkeys]: /en/newsletters/2019/08/14/#proposed-change-to-schnorr-pubkeys
[news68 taproot update]: /ja/newsletters/2019/10/16
[news60 16248]: /en/newsletters/2019/08/21/#bitcoin-core-16248
[bse bech32 extension]: {{bse}}91602
[topics announcement]: /en/topics-announcement/

