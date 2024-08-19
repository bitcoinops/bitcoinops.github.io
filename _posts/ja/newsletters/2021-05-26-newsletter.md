---
title: 'Bitcoin Optech Newsletter #150'
permalink: /ja/newsletters/2021/05/26/
name: 2021-05-26-newsletter-ja
slug: 2021-05-26-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、いくつかのIRCチャンネルのネットワークの変更の発表とともに、
Optechの150回目のニュースレターを記念しています。
また、Bitcoin Stack Exchangeの人気のある質問と回答や新しいソフトウェアのリリースとリリース候補、
人気のあるBitcoinインフラストラクチャプロジェクトの注目すべき変更などの恒例のセクションも含まれています。

## ニュース

{% comment %}<!-- IRC move would probably be better as an Action Item,
but I'd prefer not to have an empty News section if we can avoid it -harding -->{% endcomment %}

- **IRCチャンネルがLibera.Chatに移動:**
  毎週開催されているBitcoin Core開発者ミーティングで、
  5月27日（木）のミーティングがFreenodeネットワークで行われる最後のミーティングになることが[決まりました][bccdev meeting libera]。
  Botやログ、その他のインフラ、今後のミーティングおよび一般的な議論は[Libera.Chat][]ネットワークの`#bitcoin-core-dev`に移行します。
  このニュースレターの発行直前に起きたFreenodeの管理者のアクションにより、水曜日の早朝（UTC）に移行されるようです。
  BitcoinやLNに関連する他のいくつかのチャンネルも移動しています。
  さまざまなチャンネルの現在のネットワークを見つける場合は、
  Bitcoin Wikiの[IRCチャンネルのリスト][list of IRC channels]をご覧くさだい。
  移行するチャンネルを運営していて、そのリストを自分で更新するためのWikiアカウントを持っていない場合は、
  Liberaの`#bitcoin-wiki`で編集者に知らせてください。

## Optech Newsletter #150 記念
*Optech創設者である[John Newbery][]より*

これは、Bitcoinの技術コミュニティに向けて書いてきた150回めのOptech週刊ニュースレターです。
クリスマス休暇前後の短いお休みだけで、2018年6月から毎週、
BitcoinやLightningの開発における最も重要な出来事のダイジェストを発行してきました。

Optechは、Bitcoin関連の企業がBitcoinのスケーリングを可能にする技術を採用するのを支援すること、
そしてオープンソースのBitcoinコミュニティで行われている凄い技術的な研究を紹介するという、
とてもシンプルな目標を掲げてスタートしました。
3年前にはそれがどんな形になるのか正確に予測はできませんでしたが、
それは私たちが信じ続けているミッションであり、私たちがすべき仕事の指針となっています。
2018年6月から私たちは:

* 150の[ニュースレター][newsletters]、多数の[ブログの投稿][blog posts]およびフィールドレポート、
  [bech32の特別シリーズ][bech32]や、[インタラクティブなTaprootのワークショップ][interactive taproot workshop]を公開しました。
  合計で約250,000語を掲載しており、印刷すると約700ページに相当します。

  <!-- wc _posts/en/newsletters/*md _posts/en/*md
  _includes/articles/*md _includes/specials/2019-exec-briefing/*md
  _includes/specials/bech32/*md-->

* 4,100人のメール購読者と、Twitterのフォロワーは約11,000人に達しました。

* コミュニティのメンバーが私たちのニュースレターを[日本語][Japanese]や[スペイン語][Spanish]に翻訳してくれるようになりました。

* 読者がBitcoinやLightningの提案や改善の進化を追跡できるよう[トピックのインデックス][topics index]を作成、維持しています。

ニュースレターは多くの協力者の手によって作られています。
中でもコンテンツの大半を執筆している[Dave Harding][]は、その筆頭格です。
Daveが多くの執筆をしているというのは控えめな表現で、彼は毎週のように
Bitcoinのエコシステムで起きている非常に多様な研究開発の簡潔で分かりやすい要約を作成しています。
私たちは、彼のような知識を持ち、献身的で謙虚な姿勢を持つ人物がBitcoinを記録してくれることを幸運に思います。
Optechやその他のプロジェクトのために彼が制作した広範な作品は、
現在そして未来のすべてのビットコイナーにとって大きな財産になります。

サポート役は他のOptecherが努めています。[Mike Schmidt][]は、
Stack ExchangeのQ&AとBitcoinソフトウェアとインフラストラクチャの注目すべき変更の恒例のセクションを執筆し、
ニュースレターを時間どおりに皆さんに届けます。[Jon Atack][]は、恒例のBitcoin Core PR Review Clubの要約を担当しています。
MikeやJonと同じく、[Carl Dong][]や[Adam Jonas][]、[Mark Erhardt][]そして私が、時折、
PRの要約を寄稿し、毎週のニュースレターをレビューし作成するコンテンツが正確でかつ明確であるよう努めています。

ニュースレターを日本語に翻訳してくださっている[Shigeyuki Azuchi][]、
そして日本語の資料を翻訳しレビューしてくださっている[Akio Nakamura][]に感謝します。

ニュスレーターをレビューし、コンセプトの理解を支援し、間違いがあったときに課題やPRを作成してくださった、
個別に名前を挙げるのが難しいほど多くのBitcoinコミュニティのメンバーに感謝します。

これらのすべての作業は、[設立スポンサー][founding sponsors]であるWences Casaresや、
John Pfeffer、Alex Morcosを中心とした寛大な[支援者][supporters]によって支えられています。

最後に、読者の皆さま、ありがとうございます。私たちは、このコミュニティの一員として
このエコシステムに寄与することを嬉しく思っています。このリソースが多くの人にとってどれほど価値があるかを知り、
読者からのフィードバックを聞くことは私たちにとって、とてもやりがいのあることです。
協力したいとお考えの方、より良くするためのご提案をお持ちの方は、
遠慮なく[info@bitcoinops.org][info]までご連絡ください。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・答えを紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-are-there-more-than-two-transaction-outputs-in-a-coinbase-transaction-->コインベーストランザクション内に２つ以上のトランザクションアウトプットがあるのはなぜですか？]({{bse}}105831)
  Andrew Chowは、コインベーストランザクションでよくあるアウトプットについて説明しています:

  * 単一のマイナーのブロック報酬の支払い

  * マイニングプールがマイナーに支払うような複数の支払い

  * [BIP141][bip141 commitment]の`OP_RETURN` witness commitment

  * [マージマイニング][se 273 merge mining]や他のプロトコル用の、
    追加の`OP_RETURN`コミットメント

- [<!--fundrawtransaction-what-is-it-->fundrawtransaction - これは何ですか？]({{bse}}105811)
  Pieter Wuilleは、RPCを使ってコインを送金する４つの方法の例を挙げて、
  `fundrawtransaction`RPCが何をするか説明しています。

- [<!--what-previously-existing-technologies-made-bitcoin-possible-->Bitcoinを可能にした既存の技術とは？]({{bse}}106000)
  Murchは、[Bitcoin's Academic Pedigree 論文][bitcoins academic pedigree paper]に基づいて、
  Bitcoinを生み出すために組み合わされた既存の技術要素をまとめています。
  これらの技術はタイムスタンプ/検証可能なログ、ビザンチン障害耐性、proof of work、
  デジタルキャッシュ、アイデンティティとしての公開鍵にリンクされています。

- [<!--how-can-i-follow-the-progress-of-miner-signaling-for-taproot-activation-->Taprootアクティベーションのマイナーのシグナリングの進行状況はどうやって確認できますか？]({{bse}}105853)
  Hampus Sjöbergのウェブサイト[https://taproot.watch][taproot watch website]に加えて、
  Bitcoin Coreのユーザーは、`getblockchaininfo`でシグナリングブロックの数を取得し、
  シグナリングのversion bitが存在する`getblock`のversionhexフィールドでシグナリングを観察できます。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Eclair 0.6.0][]は、ユーザーのセキュリティとプライバシーを強化するいくつかの改良を加えた新しいリリースです。
  また、[Taproot][topic taproot]アドレスを使用する可能性のある将来のソフトウェアとの互換性も提供しています。

- [LND 0.13.0-beta.rc3][LND 0.13.0-beta]は、プルーニングされたBitcoinフルノードの使用をサポートし、
  Atomic MultiPath ([AMP][topic multipath payments])を使用した支払いの送受信を可能にし、
  [PSBT][topic psbt]機能の向上、その他の改善およびバグ修正を行ったリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #21843][]では、`getnodeaddresses` RPCをに`network`引数を追加しています。
  この引数にサポートされているネットワークタイプ
  （`ipv4`、`ipv6`、`onion`もしくは`i2p`）をセットして`getnodeaddresses`を呼ぶと、
  指定されたネットワークの既知のアドレスのみが返されます。
  `network`引数なしで呼び出されると、`getnodeaddresses`はすべてのネットワークの既知のアドレスを返します。

- [Eclair #1810][]では、ピアが`payment_secret` feature bitを通知し準拠することを必須にしています。
  Payment Secret機能は、[受信者の非匿名化攻撃][payment secrets recipient deanon]を阻止し、
  [不適切なイメージの公開][CVE-2020-26896]に対する追加の保護を提供します。
  この機能はすべての主要な実装でサポートされており、[LND][LND paysec]と[Rust-Lightning][RL paysec]への支払いには必須です。

- [Eclair #1774][]は、Javaの組み込み`SecureRandom()` [CSPRNG][]関数を、
  より弱いランダム性の2次ソースで拡張しています。弱いランダム性はハッシュされ、
  ハッシュダイジェストが1次ランダム性とXORされるため、
  将来何らかのバグが発見され`SecureRandom()`が予測可能な結果を生成した場合でも、
  Eclairが引き続き十分なエントロピーを持ち、暗号演算が悪用されないままになる可能性があります。

- [BIPs #1089][]では、マルチシグパラメーターや、使用するアドレスタイプ、
  その他のスクリプトレベルの詳細に関係なく、マルチシグウォレット用の[BIP32][]パスの標準化されたセットを作成するという、
  以前[メーリングリストで議論された][spigler independent]提案に、[BIP87][]を割り当てています。
  その代わり、提案されている標準のユーザーは、それらの詳細を[output script descriptor][topic descriptors]に保存します。
  これによりウォレットは、マルチシグのわずかな違いのために複数の異なる標準を実装したり（例：[BIP45][BIP45]や`m/48'`標準など）、
  descriptorによって処理できるもののために新しい標準を作成したりする必要がなくなります。
  標準化されたスクリプトではなくdescriptorを使用することは、
  より多くのデータをバックアップする必要があることを意味しますが、実際のデータの差は小さく、
  一般的なmultisig descriptorのデータのほとんどはマルチシグの参加者がバックアップする必要のある拡張公開鍵（xpub）です。
  スクリプトテンプレートとdescriptorのチェックサムに関する追加情報は、比較するとわずかなオーバーヘッドしかありません。

- [BIPs #1025][]では、ウォレットがサポートすべきBIP32鍵導出パスを記述するための、
  [ニュースレター #105][news105 path templates]に掲載された標準フォーマットに[BIP88][]を割り当てました。
  パステンプレートは、ユーザーが使用したいパスを指定するためのコンパクトな方法を提供します。
  パステンプレートはコンパクトなため、シードと一緒にテンプレートをバックアップすることが可能で、
  ユーザーの資金喪失を防げます。提案されているパステンプレートの追加機能は、
  導出制限を記述する機能です（例えば、ウォレットは特定のパスでは50,000個以上の鍵を導出してはならない）。
  これにより、リカバリー処理で受け取ったビットコインを可能な限りスキャンするのが実用的になり、
  HDウォレットのGapリミットに関する懸念を解消することができます。

- [BIPs #1097][]では、[ニュースレター #136][news136 bsms]に掲載したBitcoin Secure Multisig Setup
  (BSMS)に[BIP129][]を割り当てており、ウォレット、特にハードウェア署名デバイスが、
  マルチシグウォレットの署名者になるために必要な情報を安全に交換する方法を説明しています。
  交換が必要な情報には、使用するスクリプトテンプレート（例：署名に2-of-3の鍵が必要なP2WSH）や、
  署名に使用する予定のキーパスにある各署名者の[BIP32][]拡張公開鍵(xpub)が含まれます。
  プロトコルはコーディネーターが必要な情報を収集してoutput script descriptorを作成し、
  個々の署名者は自分の鍵が適切に含まれているかどうかを検証します。

{% include references.md %}
{% include linkers/issues.md issues="21843,1810,1774,1089,1025,1097" %}
[LND 0.13.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.0-beta.rc3
[news105 path templates]: /en/newsletters/2020/07/08/#proposed-bip-for-bip32-path-templates
[news136 bsms]: /ja/newsletters/2021/02/17/#securely-setting-up-multisig-wallets
[csprng]: https://ja.wikipedia.org/wiki/%E6%9A%97%E5%8F%B7%E8%AB%96%E7%9A%84%E6%93%AC%E4%BC%BC%E4%B9%B1%E6%95%B0%E7%94%9F%E6%88%90%E5%99%A8
[eclair 0.6.0]: https://github.com/ACINQ/eclair/releases/tag/v0.6.0
[bccdev meeting libera]: http://www.erisian.com.au/bitcoin-core-dev/log-2021-05-20.html#l-582
[libera.chat]: https://libera.chat/
[list of IRC channels]: https://en.bitcoin.it/wiki/IRC_channels
[spigler independent]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018630.html
[john newbery]: https://twitter.com/jfnewbery
[newsletters]: /ja/newsletters/
[blog posts]: /en/blog/
[bech32]: /en/bech32-sending-support/
[interactive taproot workshop]: /ja/schorr-taproot-workshop/
[japanese]: /ja/publications/
[spanish]: /es/publications/
[topics index]: /en/topics/
[dave harding]: https://dtrt.org/
[mike schmidt]: https://twitter.com/bitschmidty
[jon atack]: https://twitter.com/jonatack
[carl dong]: https://twitter.com/carl_dong
[adam jonas]: https://twitter.com/adamcjonas
[mark erhardt]: https://twitter.com/murchandamus
[shigeyuki azuchi]: https://github.com/azuchi
[akio nakamura]: https://github.com/AkioNak
[supporters]: /#supporters
[founding sponsors]: /en/about/#founding-sponsors
[info]: mailto:info@bitcoinops.org
[bip141 commitment]: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki#commitment-structure
[se 273 merge mining]: https://bitcoin.stackexchange.com/questions/273/how-does-merged-mining-work
[bitcoins academic pedigree paper]: https://queue.acm.org/detail.cfm?id=3136559
[taproot watch website]: https://taproot.watch
[CVE-2020-26896]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-26896
[payment secrets recipient deanon]: /ja/newsletters/2019/12/04/#c-lightning-3259
[LND paysec]: /en/newsletters/2020/12/02/#lnd-4752
[RL paysec]: /ja/newsletters/2021/05/05/#rust-lightning-893
