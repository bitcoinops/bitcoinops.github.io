---
title: 'Bitcoin Optech Newsletter #253'
permalink: /ja/newsletters/2023/05/31/
name: 2023-05-31-newsletter-ja
slug: 2023-05-31-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、新しいマネージドJoinpoolプロトコルの提案と、
Nostrプロトコルを使用したトランザクションリレーのアイディアを掲載しています。
また、mempoolポリシーに関する限定週刊シリーズの新しい記事に加えて、
Bitcoin Stack Exchangeに投稿された注目すべき質問とその回答や、
新しいソフトウェアリリースとリリース候補のリスト、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など恒例のセクションも含まれています。

## ニュース

- **マネージドJoinpoolプロトコルの提案:** 今週、Burak Keceliが、
  Bitcoin-Devメーリングリストに _Ark_
  という新しい[Joinpool][topic joinpools]形式のプロトコルのアイディアを[投稿しました][keceli ark]。
  このプロトコルでは、ビットコインの所有者が、
  一定期間内のすべての取引においてカウンターパーティを共同署名者として使用することを選択できます。
  所有者は、タイムロックの有効期限が切れた後に、オンチェーンでビットコインを一方的に引き出すか、
  タムロックの期限が切れる前にカウンターパーティに即座にトラストレスにオフチェーンで転送することができます。

  他のBitcoinユーザーと同様に、カウンターパーティはいつでも自身の資金のみを使用するオンチェーントランザクションを
  ブロードキャストすることができます。そのトランザクションのアウトプットが、
  所有者からカカウンターパーティに資金を転送するオフチェーントランザクションのインプットとして使用された場合、
  オンチェーントランザクションが適切な時間内に承認されない限り、オフチェーン転送が無効になります。
  この場合、カウンターパーティは、署名されたオフチェーントランザクションを受け取るまで、
  オンチェーントランザクションに署名しません。これにより、
  トラストレスなシングルホップ、所有者からカウンターパーティへの単一方向のアトミックな転送プロトコルが提供されます。
  Keceliは、このアトミックな転送プロトコルの3つの用途について説明しています:

  - *<!--mixing-coins-->コインのミキシング:* Joinpool内の複数のユーザーは、
    カウンターパーティの協力の下、現在のオフチェーンの金額と同等の新しいオフチェーンの金額との間で
    アトミックスワップを行うことができます。オンチェーンコンポーネントに障害が発生すると、
    スワップが単に巻き戻され、すべての資金が元の状態に戻るだけなので、これは迅速に実行できます。
    一部の既存の[Coinjoin][topic coinjoin]実装で使用されているものと同様のブラインドプロトコルを使用することで、
    どのユーザーがどのビットコインを手に入れたかをユーザーやカウンターパーティが特定することを防ぐことができます。

  - *<!--making-internal-transfers-->内部送金:* あるユーザーは、
    オフチェーンの資金を同じカウンターパーティの別のユーザーに送金することができます。
    アトミック性により、受取人が資金を受け取るか、支払人が払い戻しを受け取ることが保証されます。
    受取人が支払人とカウンターパーティの両方を信頼していない場合、通常のオンチェーントランザクションと同じくらいの承認を待つ必要があります。

    Keceliとコメンテーターは、二重使用トランザクションの両方のバージョンを観察したマイナーが
    コインを請求することができるFidelity bondとゼロ承認の支払いを組み合わせることで、
    二重使用を経済的に不利にすることができることを説明した[以前の][harding reply0]研究の[リンク][keceli reply0]を掲載しています。
    これにより、受取人は、他の参加者を信頼していなくていも、支払いを数秒以内に受け入れることができます。

  - *<!--paying-ln-invoices-->LNインボイスの支払い:* カウンターパーティがシークレットを知っている場合、
    ユーザーはオフチェーン資金をカウンターパーティに支払うことを即座にコミットすることができ、
    カウンターパーティを通じてLNスタイルの[HTLC][topic HTLC]インボイスに支払うことができます。

    内部送金の問題と同様に、ユーザーはトラストレスに資金を受け取ることはできないため、
    支払いが十分な数の承認を受けるか、説得力のあるFidelity bondで担保されるまで、
    シークレットを明らかにすべきではありません。

  Keceliは、基本プロトコルは、Joinpoolのメンバー間の頻繁なやりとりを利用して、
  現在のBitcoinに実装することができると述べています。
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]や、
  [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]、
  [OP_CAT + OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]などの[Covenant][topic covenants]の提案が実装されれば、
  Joinpoolのメンバーは、Coinjoinに参加したり、支払いをしたり、
  オフチェーン資金のタイムクロックを更新する際にのみカウンターパーティとやりとりする必要があります。

  Coinjoin、支払い、更新のいずれにおいても、オンチェーントランザクション内でコミットメントを公開する必要がありますが、
  基本的に無制限の数の操作をすべて同じ小さなトランザクションにまとめることができます。
  操作を素早く完了させるために、Keceliは、ユーザーがそれ以上待つ必要がないように、
  約5秒毎にオンチェーントランザクションを作ることを提案しています。
  各トランザクションは別個のもので、[Replace-by-Fee][topic rbf]を利用して
  複数のトランザクションのコミットメントを結合するようなことは、
  コミットメントを破壊したり、以前のラウンドに参加したすべてのユーザーの参加を必要としない限り不可能であるため、
  個々のトランザクションは小さいものの、1つのカウンターパーティにつき年間630万件以上のトランザクションを承認しなければならない必要があります。

  メーリングリストに投稿されたプロトコルに関するコメントは以下のとおりです:

  - *<!--a-request-for-more-documentation-->さらにドキュメントを求める声:* [少なくとも][stone reply]2人の[回答者][dryja reply]が、
    メーリングリストに提供されたハイレベルな説明では分析が難しいとして、
    システムの仕組みに関する追加のドキュメントを求めました。
    Keceliはその後、[仕様のドラフト][arc specs]を公開し始めています。

  - *LNと比べて受け取りが遅いという懸念:* [何人かの][dryja reply]メンバーは、
    初期設計では、十分な数の承認を待たずにJoinpoolから（オフチェーンでもオンチェーンでも）
    支払いをトラストレスに受け取ることはできないと[指摘しました][harding reply1]。
    これには数時間かかる可能性があり、一方、多くのLNの支払いは現在1秒未満で完了しています。
    Fidelity bondがあっても、LNの方が平均的には速いでしょう。

  - *<!--concern-that-the-onchain-footprint-is-high-->オンチェーンフットプリントが大きいという懸念:*
    ある[回答][jk_14]は、5秒ごとに1つのトランザクションを作成すると、
    約200のカウンターパーティがブロックの全スペースを消費することになると指摘しました。
    別の[回答][harding reply0]では、カウンターパーティのオンチェーントランザクションは、
    LNのチャネル開設や協調クローズのトランザクションとほぼ同じサイズになると想定しており、
    年間630万件のオンチェーントランザクションを作成する100万人のユーザーを持つカウンターパーティは、
    同数のユーザーが年間平均6.3チャネルを開設またはクローズするのと同じスペースを使用します。
    したがって、大規模なスケールに達するまでは、LNのオンチェーンコストは、
    カウンターパーティを使用するよりも低くなる可能性があります。

  - *<!--concern-about-a-large-hot-wallet-and-the-capital-costs-->多額のホットウォレットと資本コストに関する懸念:*
    カウンターパーティは、ユーザーが近い将来使うかもしれない金額と同量のビットコインを手元に
    （おそらくホットウォレットに）おいておく必要があるという[回答][harding reply0]がありました。
    現在の設計案では、支払い後、カウンターパーティは最大28日間ビットコインを取り戻すことができません。
    カウンターパーティが資本に対して年1.5%の低金利を課した場合、
    これはカウンターパーティの関与で実行されるすべてのトランザクション（Coinjoin、内部送金およびLN支払いを含む）の金額対して、
    0.125%の同等の手数料を課すことになります。これに対し、
    この記事を書いている時点で利用可能な[公開統計][1ml stats]（1MLで収集）によると、
    LN送金のホップごとの手数料率の中央値は0.0026%で、ほぼ50分の1です。

  また、メーリングリストに寄せられたコメントの中には、この提案に興奮し、
  KeceliらがマネージドJoinpoolの設計スペースを探求するのを楽しみにしているというものもありました。

- **Nostrを利用したトランザクションリレー:** Joost Jagerは、
  リレーサービスを提供するBitcoinフルノードのP2Pネットワークでうまく伝播しない可能性のあるトランザクションのリレーに
  [Nostr][]プロトコルを使用するというBen Carmanのアイディアについてのフォードバックを求めるために、
  Bitcoin-Devメーリングリストに[投稿しました][jager nostr]。

  特に、JagerはトランザクションパッケージのリレーにNostrを使用する可能性を検討しています。
  たとえば、最小受け入れ額以下の手数料を持つ祖先のトランザクションを、
  祖先の不足分を補うために十分な手数料を支払う子孫とバンドルしてリレーします。
  これにより、[CPFP][topic cpfp]による手数料の引き上げはより信頼性が高く効率的になります。
  これは、Bitcoin Coreの開発者がBitcoin P2Pネットワークに実装しようとしている
  [パッケージリレー][topic package relay]と呼ばれる機能です。
  パッケージリレーの設計と実装をレビューする際の課題は、
  新しいリレー方法が、個々のノードやマイナー（またはネットワーク全体）に対して
  新しいサービス拒否（DoS）の脆弱性を生じさせないようにすることです。

  Jagerは、Nostrリレーには、トランザクションをリレーするのに少額の支払いを要求するなど、
  P2Pリレーネットワークとは別のタイプのDoS保護を簡単に使用できる機能があると指摘しています。
  悪意あるトランザクションやパッケージがノードのリソースを少し消費する可能性があるとしても、
  パッケージリレーや他の代替トランザクションのリレーを許可することが現実的であることを示唆しています。

  Jagerの投稿には、この機能をデモンストレーションした[動画][jager video]のリンクが含まれていました。
  この記事を書いている時点では、彼の投稿にはまだ数件の返信しかありませんでしたが、
  いずれも好意的なものでした。

## 承認を待つ #3: ブロックスペースの入札

_トランザクションリレーや、mempoolへの受け入れ、マイニングトランザクションの選択に関する限定週刊[シリーズ][policy series]です。
Bitcoin Coreがコンセンサスで認められているよりも制限的なポリシーを持っている理由や、
ウォレットがそのポリシーを最も効果的に使用する方法などが含まれます。_

{% include specials/policy/ja/03-bidding-for-block-space.md %}

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [bitcoindのプルーニングロジックのテスト]({{bse}}118159)
  Lightlikeは、テスト目的でより小さいブロックファイルと小さい最小プルーニング高を使用する
  デバッグ専用の`-fastprune`設定オプションを指摘しました。

- [<!--what-s-the-governing-motivation-for-the-descendent-size-limit-->子孫のサイズを制限する理由は何ですか？]({{bse}}118160)
  Sdaftuarは、マイニングと退去のアルゴリズム（[Newsletter #252][news252 incentives]参照）が、
  祖先や子孫の数に応じて2次関数的にO(n²)の時間を要するため、
  [保守的なポリシー制限][morcos limits]を設けたことを説明しています。

- [デフォルトより大きなmempoolを持つノードを動かすと、Bitcoinネットワークにどのような貢献になりますか？]({{bse}}118137)
  Andrew ChowとMurchは、トランザクションの再ブロードキャストの伝播や、
  非シグナルトランザクションの置換の伝播に悪影響を与える可能性など、
  デフォルトより大きなmempoolの潜在的なマイナス面を指摘しています。

- [<!--what-is-the-maximum-number-of-inputs-outputs-a-transaction-can-have-->トランザクションが持つことのできる最大インプット/アウトプット数はいくつですか？]({{bse}}118452)
  Murchは、Taprootが有効になった後のインプットとアウトプットの数について、
  最大アウトプット数3223 (P2WPKH)と最大インプット数1738 (P2TR keypath)を示しています。

- [xpubが1つなくても、2-of-3のマルチシグの資金を回収することは可能ですか？]({{bse}}118201)
  Murchは、ベアマルチシグを使用しないマルチシグのセットアップの場合、
  以前に同じマルチシグアウトプットスクリプトが使用されていない限り、
  使用するためにはすべての公開鍵が必要であると説明しています。
  また、「マルチシグウォレットのバックアップ戦略は、秘密鍵とアウトプットの条件スクリプトの両方を保持しなければならない」とし、
  条件スクリプトをバックアップする方法として[ディスクリプター][topic descriptors]を推奨しています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 25.0][]は、Bitcoin Coreの次期メジャーバージョンのリリースです。
  このリリースでは、新しい`scanblocks` RPCが追加され、`bitcoin-cli`の使用が簡素化され、
  `finalizepsbt` RPCに[Miniscript][topic miniscript]のサポートが追加され、
  `blocksonly`設定オプションでデフォルトのメモリ使用量が削減され、
  [コンパクトブロックフィルター][topic compact block filters]が有効になっている場合の
  ウォレットの再スキャンが高速化されるなど、多くの新機能、パフォーマンス改善、バグ修正が追加されています。
  詳細は[リリースノート][bcc rn]を参照ください。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #27469][]では、1つ以上のウォレットが使用されている場合のIBD（Initial Block Download）を高速化しました。
  この変更により、ウォレットの誕生日（ウォレット作成時にウォレットに記録された日付）以降にマイニングされたブロックに対してのみ、
  特定のウォレットに一致するトランザクションをスキャンするようになりました。

- [Bitcoin Core #27626][]では、ノードに高帯域幅モードでの
  [コンパクトブロックリレー][topic compact block relay]を使用するよう要求したピアは、
  ノードが配信した最新ブロックから最大3つのトランザクションを要求できるようになりました。
  ノードが最初にコンパクトブロックを提供しなかった場合でも、要求に応じます。
  これにより、他のピアからコンパクトブロックを受信したピアが、不足しているトランザクションを要求できるようになり、
  その他のピアが応答しなくなった場合に役立ちます。これにより、ピアがブロックを迅速に検証できるようになり、
  マイニングなどの時間が重要な機能でより早くブロックを使用できるようになる可能性もあります。

- [Bitcoin Core #25796][]は、後で署名またはファイナライズをするのに役立つ情報で[PSBT][topic psbt]を更新するために使用できる
  新しい`descriptorprocesspsbt`を追加しました。RPCに提供された[ディスクリプター][topic descriptors]は、
  mempoolとUTXOセットから情報を取得するのに使用されます（利用可能な場合は、
  ノードが`txindex`設定オプションで起動した場合、承認されたトランザクションを完了します）。
  そして、取得した情報はPSBTを埋めるために使用されます。

- [Eclair #2668][]は、Eclairがオンチェーンで[HTLC][topic htlc]を解決する際に、
  そのHTLCの解決によって得られる価値よりも多くの手数料を支払おうとするのを防止します。

- [Eclair #2666][]は、[HTLC][topic htlc]を受け取ったリモートピアが、
  そのHTLCを受け入れるために支払わなければならない手数料によって、
  ピアの残高が最小チャネルリザーブを下回ることになる場合でも、その受け入れを許可するようにします。
  チャネルリザーブは、ピアが古い状態でチャネルを閉じようとした場合に、
  少なくとも少額のお金を失うことになることを保証するために存在し、ピアが盗難を試みるのを阻止することを目的としています。
  しかし、リモートピアが成功した場合に支払われるHTLCを受け入れる場合、
  いずれにせよリザーブよりも多くをステークすることになります。成功しなかった場合は、
  その残高は以前の金額に戻り、リザーブを上回ることになります。

  これは、*スタックファンドの問題*の緩和策です。この問題は、手数料の支払い責任を負う参加者が、
  支払いによって、現在利用可能な残高よりも多くの額を支払う必要がある場合に発生します。
  この問題に関する以前の議論については、[ニュースレター #85][news85 stuck funds]を参照ください。

- [BTCPay Server 97e7e][]は、[Payjoin][topic payjoin]の支払いに
  [BIP78][]`minfeerate`（最小手数料率）パラメーターを設定するようになりました。
  このコミットのきっかけになった[バグレポート][btcpay server #4689]もご覧ください。

- [BIPs #1446][]は、Bitcoin関連プロトコルの[Schnorr署名][topic schnorr signatures]の仕様[BIP340][]に
  小さな変更と多くの追加を行いました。この変更は、署名されるメッセージの長さを任意に設定できるようにするものです。
  [ニュースレター #157][news157 libsecp]で説明したLibsecp256k1ライブラリの関連する変更もご覧ください。
  [Taproot][topic taproot]と[Tapscript][topic tapscript]の両方
  （それぞれBIP[341][bip341]と[342][bip342]）で使用される署名は32バイトのメッセージを使用するため、
  この変更はコンセンサスアプリケーションにおけるBIP340の使用には影響しません。

  今回の追加では、任意の長さのメッセージを効果的に使用する方法、
  ハッシュされたタグプレフィックスの使用方法の推奨、
  異なるドメインで同じ鍵を使用する場合（トランザクションへの署名や、
  平文メッセージへの署名など）の安全性を高める推奨事項を説明しています。

{% include references.md %}
{% include linkers/issues.md v=2 issues="27469,27626,25796,2668,2666,4689,1446" %}
[policy series]: /ja/blog/waiting-for-confirmation/
[bitcoin core 25.0]: https://bitcoincore.org/bin/bitcoin-core-25.0/
[1ml stats]: https://1ml.com/statistics
[arc specs]: https://github.com/ark-network/specs
[keceli ark]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021694.html
[keceli reply0]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021720.html
[harding reply0]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021721.html
[harding reply1]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021714.html
[stone reply]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021708.html
[dryja reply]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021713.html
[jk_14]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021717.html
[jager nostr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021700.html
[jager video]: https://twitter.com/joostjgr/status/1658487013237211155
[news252 incentives]: /ja/newsletters/2023/05/24/#承認を待つ-2-インセンティブ
[morcos limits]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-October/011401.html
[news85 stuck funds]: /ja/newsletters/2020/02/19/#c-lightning-3500
[btcpay server 97e7e]: https://github.com/btcpayserver/btcpayserver/commit/97e7e60ceae2b73d63054ee38ea54ed265cc5b8e
[news157 libsecp]: /ja/newsletters/2021/07/14/#libsecp256k1-844
[bcc rn]: https://bitcoincore.org/en/releases/25.0/
