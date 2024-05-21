---
title: 'Bitcoin Optech Newsletter #299'
permalink: /ja/newsletters/2024/04/24/
name: 2024-04-24-newsletter-ja
slug: 2024-04-24-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、複数の異なるmempoolポリシーを持つネットワークにおいて
コンパクトブロックのパフォーマンスを改善するために弱ブロックをリレーするための提案と、
5名のBIPエディターの追加の発表を掲載しています。また、
Bitcoin Stack Exchangeから選ばれた質問とその回答や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など恒例のセクションも含まれています。

## ニュース

- **<!--weak-blocks-proof-of-concept-implementation-->弱ブロックの概念実証の実装:**
  Greg Sandersは、特にトランザクションリレーとマイニングのポリシーが異なる場合に、
  _弱ブロック_ を使用して[コンパクトブロックリレー][topic compact block relay]を改善することについて
  Delving Bitcoinに[投稿しました][sanders weak]。
  弱ブロックとは、ブロックチェーン上の次のブロックになるにはPoW（Proof-of-Work）が不十分なものの、
  それ以外は有効な構造と有効なトランザクションのセットを持つブロックです。
  マイナーは、それぞれの弱ブロックが必要なPoWに占める割合に比例して弱ブロックを生成します。
  たとえば、マイナーは完全なPoWのブロックを1つ生成するたびに、必要なPoWの10%の弱ブロックを（平均して）9個生成します。

  マイナーは、いつ弱ブロックを生成するか分かりません。彼らが試行するブロック候補はそれぞれ、
  完全なPoWを達成する確率が等しく、そのうちのいくつかは弱ブロックになってしまいます。
  弱ブロックを作成する唯一の方法は、完全なPoWブロックを作成するために必要な作業とまったく同じ作業を行うことです。
  つまり弱ブロックは、弱ブロックが作成された時点でマイナーがマイニングしようとしていたトランザクションを正確に反映します。
  たとえば、無効なトランザクションを弱ブロックに含める唯一の方法は、
  同じ無効なトランザクションを含む完全なPoWブロックを作成するリスクを冒すことです。
  無効なブロックはフルノードが拒否し、マイナーはブロック報酬を受け取ることができなくなります。
  もちろん、マイニングしようとしているトランザクションを通知したくないマイナーは、
  弱ブロックのブロードキャストを単に拒否することもできます。

  10%の弱ブロックを作成するのは難易度が高く、無効なトランザクションを含む弱ブロックを作成するコストは高いため、
  弱ブロックは大量のノードの帯域幅やCPU、メモリを消費しようとする可能性のあるサービス拒否攻撃に対して強力な耐性があります。

  弱ブロックは、PoWがわずかに不足している通常のブロックであるため、通常のブロックと同じサイズになります。
  10年以上前に弱ブロックのリレーが初めて説明された際、10%の弱ブロックをリレーすることは、
  ブロックリレーに使用されるノードの帯域幅が最大10倍増加することを意味していました。
  しかし、何年も前にBitcoin Coreはブロック内のトランザクションを短い識別子を使って置き換え、
  受信ノードがまだ確認したことのないトランザクションのみを要求できるようにするコンパクトブロックリレーを使用し始めました。
  これにより、ブロックのリレーに必要な帯域幅が99%以上削減されます。Sandersは、
  これは弱ブロックに対しても同様に機能すると指摘しています。

  完全なPoWブロックの場合、コンパクトブロックリレーは帯域幅を節約するだけなく、
  新しいブロックの伝播をより速くするのに役立ちます。
  送信する必要があるデータが少ないほど（完全なトランザクションが少ないほど）、
  残りのデータをより速く送信できます。新しいブロックのより高速な伝播は、
  マイニングの分散化にとって重要です。新しいブロックを見つけたマイナーは、すぐに後続ブロックの作業を開始できますが、
  他のマイナーはリレーを通じて新しいブロックを受け取ってからでなければ後続のブロックの作業に取り掛かることができません。
  このため、大規模なマイニングプールが有利になり、
  意図せず一種のセルフィッシュマイニング攻撃が発生する可能性があります（[ニュースレター #244][news244 selfish]参照）。
  この問題は、コンパクトブロックリレーが導入される以前もよく見られ、
  大規模なプールへのマイニングの集中化と、[2015年7月のチェーンの分岐][July 2015 chain forks]の原因となった
  スパイマイニングのような問題のある手法の使用の両方につながりました。

  コンパクトブロックリレーは、主にノードが既に確認したトランザクションで構成される新しいブロックを受信した場合のみ帯域幅を節約し、
  ブロックの伝播を高速化します。しかし、Sandersは、
  現在一部のマイナーはノード間でリレーされていない多くのトランザクションを含むブロックを作成しており、
  コンパクトリレーの利点が減少し、ネットワークをコンパクトブロックリレー以前に存在していた問題のリスクにさらしていると指摘しています。
  彼は解決策として弱ブロックリレーを提案しました:

  - 弱ブロック（たとえば、10%の弱ブロック）を作成するマイナーは、それをカジュアルにノードにリレーします。
    ここで言うカジュアルというのは、リレーが新しいブロックのような優先度の高いトラフィックではなく、
    新しい未承認トランザクションのリレーなどの通常のP2Pネットワークトラフィックのように扱われることを意味します。

  - ノードは弱ブロックをカジュアルに受け入れ検証します。PoWの検証は簡単ですぐに実行されます。
    その後、トランザクションが検証されると、弱ブロックが一時的にメモリに保存されます。
    Bitcoin Coreのポリシールールをパスした弱ブロックの新しいトランザクションはすべてmempoolに追加されます。
    パスしなかったものは、mempoolに追加できなトランザクションを一時的に保存するために
    Bitcoin Coreが使用する既存のキャッシュ（オーファントランザクションキャッシュなど）と同様の特別なキャッシュに保存されます。

  - その後、追加の弱ブロックを受信すると、mempoolとキャッシュを更新することができます。

  - コンパクトブロックリレーを使用して新しい完全なPoWブロックを受信した場合、
    mempoolと弱ブロックのキャッシュの両方のトランザクションを使用できるため、
    追加のリレー時間と帯域幅の必要性を最小限に抑えることができます。これにより、
    ノードとマイナーのポリシーが多様なネットワークにおいても、コンパクトブロックのメリットを享受し続けることができます。

  さらにSandersは、弱ブロックに関する以前の議論（[ニュースレター #173][news173 weak]参照）において、
  弱ブロックがどのように[Pinning攻撃][topic transaction pinning]への対処や
  [手数料率の推定][topic fee estimation]の改善に役立つかを指摘しています。弱ブロックリレーの使用は、
  Nostrプロトコル上でのトランザクションリレーに関する議論（[ニュースレター #253][news253 weak]参照）でも以前言及されました。

  Sandersは、「高レベルのアイディアを実証するための軽いテストの基本的な[概念実証][sanders poc]」を書きました。
  この記事の執筆時点では、このアイディアに関する議論は継続中です。

- **BIPエディターの更新:**
  公開討論（ニュースレター[#292][news292 bips]、[#296][news296 bips]、[#297][news297 bips]）の後、
  以下のコントリビューターがBIPエディターに[任命されました][chow editors]：
  Bryan "Kanzure" Bishop、
  Jon Atack、
  Mark "Murch" Erhardt、
  Olaoluwa "Roasbeef" Osuntokun、
  Ruben Somsen。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--where-exactly-is-the-off-by-one-difficulty-bug-->オフ-バイ-ワンの難易度バグは一体どこにあるのですか？]({{bse}}20597)
  Antoine Poinsotは、[コンセンサス・クリーンアップ][topic consensus cleanup]の提案が解決を目指す（[ニュースレター #296][news296 cc]参照）
  [タイムワープ攻撃][topic time warp]を可能にするBitcoinの難易度の再ターゲット計算におけるオフ-バイ-ワンエラーについて
  説明しています。

- [開発者から見て、P2TRはopcodeを使用するP2PKHとどう異なりますか？]({{bse}}122548)
  Murchは、P2PKHアウトプットスクリプトとして提示されているサンプルBitcoin Scriptは非標準であり、
  P2TRよりも高価だが、コンセンサス上は有効であると結論付けています。

- [置換トランザクションのサイズは、以前のトランザクションや非RBFトランザクションよりも大きくなりますか？]({{bse}}122473)
  Vojtěch Strnadは、[RBF][topic rbf]のシグナリングトランザクションは、
  非シグナリングトランザクションと同じサイズであると指摘し、
  置換トランザクションが置換される元のトランザクションと同じサイズ、大きい場合または小さい場合のシナリオを示しています。

- [Bitcoinの署名は依然としてnonceの再利用に対して脆弱ですか？]({{bse}}122621)
  Pieter Wuilleは、ECDSAと[Schnorr][topic schnorr signatures]署名スキームの両方について（
  [マルチシグ版][topic multisignature]を含む）、[nonceの再利用][taproot nonces]に対して脆弱であることを確認しています。

- [<!--how-do-miners-manually-add-transactions-to-a-block-template-->マイナーはどのようにして手動でブロックテンプレートにトランザクションを追加するのですか？]({{bse}}122725)
  Ava Chowは、Bitcoin Coreの`getblocktemplate`に含まれないトランザクションをブロックに含めるためにマイナーが使用できる
  さまざまなアプローチを概説しています:

  - `sendrawtransaction`を使用してマイナーのmempoolにトランザクションを含め、
    次に`prioritisetransaction`を使用してトランザクションの[認識される絶対手数料][prioritisetransaction fee_delta]を調整します
  - 変更した`getblocktemplate`の実装もしくは別のブロック構築ソフトウェアを使用します

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND v0.17.5-beta][]は、LNDをBitcoin Core 27.xと互換性をもたせるメンテナンスリリースです。

  LND開発者に[報告された][lnd #8571]ように、LNDの旧バージョンは、
  最大手数料率を1,000万 sat/kB（約0.1 BTC/kBに相当）に設定することを意図した[btcd][]の旧バージョンに依存していました。
  しかし、Bitcoin CoreはBTC/kvBで手数料率を受け入れるため、実際には最大手数料率は1,000万BTC/kvBに設定されていました。
  Bitcoin Core 27.0には、特定の問題を防ぎ、より高い値を設定する人はミスをしている可能性が高いという仮定の下、
  最大手数料率を1 BTC/kvBに制限する[PR][bitcoin core #29434]が含まれていました（
  本当に高い値が必要な場合は単にパラメーターを0に設定しチェックを無効化するだけです）。
  この場合、（btcd経由で）LNDは確かにミスをしていましたが、Bitcoin Coreへの変更により、
  LNDはオンチェーントランザクションを送信できなくなり、
  これは時間に敏感なトランザクションを送信する必要があるLNノードにとっては危険性があります。
  このメンテナンスリリースでは、最大値が0.1 BTC/kvBに正しく設定され、
  LNDが新しいバージョンのBitcoin Coreと互換性を持つようになりました。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。*

- [Bitcoin Core #29850][]は、個々のDNSシードから受け入れられるIPアドレスの最大数を1回のクエリにつき32個に制限します。
  UDP経由でDNSクエリを実行する場合、最大パケットサイズによりその数は33に制限されていましたが、
  TCPで代替DNSクエリを実行することで、より多くの結果を返すことができるようになります。
  新しいノードは複数のDNSシードに接続し、IPアドレスのセットを構築します。
  その後、それらのIPアドレスからいくつかをランダムに選択し、ピアとして接続します。
  新しいノードが接続先の各シードからほぼ同じ数のIPアドレスを取得する場合、
  選択したすべてのピアが同じシードノードからのものである可能性は低く、
  ネットワークに対して多様な視点を持つことが保証され、
  [エクリプス攻撃][topic eclipse attacks]に対して脆弱でなくなります。

  しかし、1つのシードが他のどのシードよりもはるかに多くのIPアドレスを返した場合、
  新しいノードがランダムにそのシードからのIPアドレスのセットを選択する可能性が高くなります。
  そのシードが悪意あるものであれば、新しいノードをまっとうなネットワークから孤立させることができます。
  [テストでは][bitcoin core #16070]、最大256個まで許可されていたにも関わらず、
  すべてのシードは50件以下しか返しませんでした。このマージされたPRは、
  現在シードノードが返しているのと同じ量まで最大数を削減しています。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8571,29434,29850,16070" %}
[sanders weak]: https://delvingbitcoin.org/t/second-look-at-weak-blocks/805
[news173 weak]: /ja/newsletters/2021/11/03/#feerate-communication
[news253 weak]: /ja/newsletters/2023/05/31/#nostr
[sanders poc]: https://github.com/instagibbs/bitcoin/commits/2024-03-weakblocks_poc/
[july 2015 chain forks]: https://en.bitcoin.it/wiki/July_2015_chain_forks
[selfish mining attack]: https://bitcointalk.org/index.php?topic=324413.msg3476697#msg3476697
[news244 selfish]: /ja/newsletters/2023/03/29/#bitcoin-core-27278
[btcd]: https://github.com/btcsuite/btcd/pull/2142
[chow editors]: https://gnusha.org/pi/bitcoindev/CAMHHROw9mZJRnTbUo76PdqwJU==YJMvd9Qrst+nmyypaedYZgg@mail.gmail.com/T/#m654f52c426bd5696d88668b3bff25197846e14af
[news292 bips]: /ja/newsletters/2024/03/06/#bip
[news296 bips]: /ja/newsletters/2024/04/03/#bip
[news297 bips]: /ja/newsletters/2024/04/10/#bip2
[LND v0.17.5-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.5-beta
[news296 cc]: /ja/newsletters/2024/04/03/#revisiting-consensus-cleanup
[prioritisetransaction fee_delta]: https://developer.bitcoin.org/reference/rpc/prioritisetransaction.html#argument-3-fee-delta
[taproot nonces]: /ja/preparing-for-taproot/#マルチシグのnonce
