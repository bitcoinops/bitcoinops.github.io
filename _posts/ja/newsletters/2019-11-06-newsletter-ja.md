---
title: 'Bitcoin Optech Newsletter #71'
permalink: /ja/newsletters/2019/11/06/
name: 2019-11-06-newsletter-ja
slug: 2019-11-06-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、Bitcoin Coreのリリース候補(RC)についてのテストの呼びかけ
、 LN anchor outputsについての議論の要約、フルノード/軽量クライアントからIPアドレスリレーに参加するために通知を出せるようにするための提案についてお伝えします。また、レギュラーセクションではBitcoinプロジェクトに関する注目すべきアップデートを共有します。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **Bitcoin Coreのリリース候補(RC)についてのテストをお願いします:** 経験のあるBitcoinユーザーは最新版の[Bitcoin Core][Bitcoin Core 0.19.0]のテストを是非お試しください。

## News

- **LN anchor outputsについての継続的議論:** [前回のニュースレター][news70 simplified commitments]でお伝えしたように、LN開発者は、Bitcoin Core 0.19.0に含まれるとされているCPFP (Child Pays For Parent) carve-out mempool policyを活用することで、各ユーザーがCPFP fee bumpを利用したトランザクションを可能にするような取り組みがなされています。[メーリングリスト][jager anchor]や[BOLTs repository][bolts #688]で今週議論されているトピックは以下のようになります。

    - チャネルを一方的に閉じる側（”Local” Party）とその相手側（”Remote” Party）の両方がファンドを要求できるようになる前に同じ遅延を経験するか、チャネル作成時にそれぞれ遅延期間について交渉できるかどうかについて。現在、”Local” Partyのみに遅延が起きており、これにより一部の人々が資金をより早く受け取るために、相手側（”Remote” Party）をチャネルを閉じるように操作する可能性が出てくるとの懸念があります。

    - anchor outputsにどのscriptを利用するかについて。以前、大量の少価値アウトプットによりUTXOセットを汚さないために、一定の遅れの後誰でも支払いが出来るように許可する句（clause）をscriptに含めることが提案されました。ただし、第三者から検知が出来ないユニークなpubkeyを含める必要のあるscriptにより、P2WSHアウトプットを支払うために必要なwitness scriptが誰でも独自に生成できなくなるなどの制限もあり事態が複雑化しています。


    - どれ程のbitcoinをanchor outputsに支払うか。チャネルを開いた人は、この金額を支払う責任があります（現在のプロトコルでは、チャネル開設者が全てのフィーを支払う責任があるため）。そのため、チャネル開設者は支払額を低く抑えたいと考えますが、この額は多数のノードの最小出力量（”dust limit”）より大きくなければなりません。この額が設定可能な量であるかどうかについての議論がありました。

    - 各LN paymentが、異なる公開鍵を支払う必要があるかどうかについて。（pubkey tweakingを利用することで）。必要なstate trackingの量を減らすために、key tweakingを削除することが以前提案されましたが、これによりチャネルステート（channel state）が特定されすぎるという懸念あがっています。例えばチャネルの片側から一連の暗号化されたブリーチレメディトランザクション（breach remedy transactions）を受信したwatchtowerでは必要な分だけのトランザクションだけでなく、そのチャネルにある全てのトランザクションを復号化できるようになります。そのwatchtowerがチャネルの各支払い金額とhash locksを再構築することにより、プライバシーが大幅に低下します。

上記の懸念に対する解決策が提案され、追加のレビューが行われるため、議論は継続中です。

- **<!--signaling-support-for-address-relay-->アドレスリレーのシグナリングサポート**：フルノードは、P2Pプロトコルの”addr”（アドレス）メッセージを利用してピアーから聞いた他のフルノードのIPアドレスを共有し、完全に分散化したピアーの発見を可能にします。 SPVクライアントはこのメカニズムを使用してフルノードについて検出することもできますが、現在ほとんどのSPVクライアントは何らかの集中型形式でピア検出をしているため、これらのクライアントに送信されるaddrメッセージはbandwidthの浪費となります。

   Gleb Naumenkoは、[email][naumenko addr relay]をBitcoin-Devメーリングリストに送信し、各ノードとクライアントは、アドレスリレーに参加したいかどうかをピアーに通知することを提案しました。これにより、アドレスを必要としないクライアントにおけるbandwidthの浪費を避ける事が可能となり、更にアドレスリレーに関与する特定のネットワークビヘイビアによる結果を簡単に判断できます。

    ノードがアドレスリレーに参加するかどうかを通知するために、ノードごとの方法とコネクションごとの方法の2つの方法が提案されています。ノードごとの方法は、addrv2メッセージに対して既に行われている開発（[Newsletter＃37][news37 addrv2]を参照）を活用する事で簡単に実装できますが、コネクションごとの方法よりも柔軟性が低くなります。特に、コネクションごとの方法では、一部のコネクションをトランザクションリレーに、残りをアドレスリレーに充てる事が出来るため、プライバシーの利点が得られます。 Naumenkoのメールでは、フルノードや軽量クライアントの実装者がどちらの方法を好むのか、フィードバックを求めています。

## Notable code and documentation changes

*今週の[Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], および [Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #16943][]は`generatetodescriptor` RPCを追加します。これはregtest modeなどのテスト中に新しく生成されたブロックが[output script descriptor][]によって表されたscriptに支払うことを可能にするものです。これまでは`generatetoaddress` RPCがありましたが、これはP2PKH, P2SH, P2WSHアドレスへの支払いにのみに利用できました。

- [C-Lightning #3220][] はsignatureを毎回*r*から生成して、signatureの最大量を1バイト小さくすることで平均約0.125 vbytes / C-Lightning onchainトランザクションの節約に貢献します。Bitcoin Coreも以前この変更をwalletのsignature-generation codeに採用しています。(参照： [Newsletter #8][news8 lowr]).

- [LND #3558][] は、2つの特定のノード間で複数のチャネルが開いている場合、統合ポリシーを利用・合成し、これらのチャネルを統合ポリシーに基づきルーティングします。
統合ポリシーを合成します。[BOLT4][bolt4 non-strict rec]は、同じノード間の複数のチャネルがすべて同じポリシーを使用することを推奨していますが、これは常に起きるわけではないため、この変更により、ノード間の「全ポリシーの最大公約数」を決定しようとします。単一のポリシーを利用することで、ノードが支払いを行うときに評価する必要のあるルート数が減ります。

- [LND #3556][] は、特定の送金元ノード、送金先ノード、および支払い金額が与えられた場合に、支払いが成功する期待値をリターンする新しい`queryprob` RPCを追加します。これは、以前にquerymc RPCから削除された機能の置き換えとなります。

- [BOLTs #660][] は、[BOLT1][]の更新版で、LN仕様（BOLTドキュメント）で定義された型に対して2<sup>16</sup>未満のType-Length-Value（TLV）型識別子を確保するものです。残りの値は、LN実装によってカスタムレコードとして自由に使用できます。この仕様では、カスタムレコードタイプの番号を選択する方法に関するガイダンスも提供されるようになりました。


{% include linkers/issues.md issues="16943,3558,3556,660,3220,688" %}
[bitcoin core 0.19.0]: https://bitcoincore.org/bin/bitcoin-core-0.19.0/
[bolt4 non-strict rec]: https://github.com/lightningnetwork/lightning-rfc/blob/master/04-onion-routing.md#recommendation
[news37 addrv2]: /en/newsletters/2019/03/12/#version-2-addr-message-proposed
[news8 lowr]: /en/newsletters/2018/08/14/#bitcoin-core-wallet-to-begin-only-creating-low-r-signatures
[naumenko addr relay]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-October/017428.html
[news70 simplified commitments]: /ja/newsletters/2019/10/30
[jager anchor]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002264.html
[output script descriptor]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
