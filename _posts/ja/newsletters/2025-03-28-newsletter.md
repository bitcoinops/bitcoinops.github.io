---
title: 'Bitcoin Optech Newsletter #347'
permalink: /ja/newsletters/2025/03/28/
name: 2025-03-28-newsletter-ja
slug: 2025-03-28-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LNが焼却可能なアウトプットを基に前払い手数料と保留手数料をサポートできるようにする提案と、
testnet 3と4に関する議論（ハードフォークの提案を含む）の要約、
Taproot annexを含む特定のトランザクションのリレーを開始する計画の発表を掲載しています。
また、Bitcoin Stack Exchangeから選択した質問と回答や、新しいリリースとリリース候補の発表、
人気のBitcoinインフラストラクチャプロジェクトの注目すべき変更など恒例のセクションも含まれています。

## ニュース

- **焼却可能なアウトプットを使用したLNの前払い手数料と保留手数料:** John Lawは、
  転送支払いに対して2種類の追加手数料を請求するためにノードが使用できるプロトコルについて書いた
  [論文][law fee paper]の要約をDelving Bitcoinに[投稿しました][law fees]。
  _前払い手数料_ は、転送ノードが _HTLCスロット_（[HTLC][topic htlc]を適用するためにチャネル内で利用できる限られた数の同時割り当ての１つ）
  を一時的に使用することに対する補償として、最終的な支払人が支払います。
  _保留手数料_ は、HTLCの決済を遅らせるノードが支払います。この手数料の金額は、
  HTLCの有効期限が切れたときに最大額となるまで、遅延の長さに応じて変化します。
  彼の投稿と論文では、ニュースレター[#86][news86 reverse upfront]、[#119][news119 trusted upfront]、
  [#120][news120 upfront]、[#122][news122 bi-directional]、[#136][news136 more fee]、
  [#263][news263 dos philosophy]にまとめられているような、
  前払い手数料と保留手数料に関するこれまでの議論がいくつか引用されています。

  提案されているプロトコルは、Lawの _オフチェーン支払い解決_
  （OPR）プロトコル（[ニュースレター #329][news329 opr]参照）のアイディアに基づいています。
  このプロトコルでは、チャネルの共同所有者がそれぞれ、掛け金の100%（つまり合計200%）を、
  どちらかが一方的に破壊できる焼却可能なアウトプットに割り当てます。
  この場合、掛け金は前払い手数料と保留手数料の最大額です。両当事者が後でプロトコルが正しく遵守された（
  すべての手数料が正しく支払われたなど）ことに満足した場合、
  オフチェーントランザクションの将来のバージョンから焼却可能なアウトプットを削除します。
  どちらかの当事者が満足していない場合、チャネルを閉じて焼却可能な資金を破壊します。
  この場合、満足していない当事者は資金を失いますが、もう一方の当事者も資金を失うため、
  どちらもプロトコル違反から利益を得ることはできません。

  Lawは、このプロトコルを[チャネルジャミング攻撃][topic channel jamming attacks]のソリューションであると説明しています。
  チャネルジャミング攻撃は、[約10年前][russell loop]に初めて説明されたLNの弱点で、
  攻撃者がほぼコストをかけずに他のノードが資金の一部またはすべてを使用するのを阻止できます。
  [返信では][harding fee]、保留手数料の追加により、
  [インボイスの保留][topic hold invoices]がネットワークによってより持続可能になる可能性があると指摘されました。

- **testnet3と4の議論:** Sjors Provoostは、
  testnet4が利用可能になってから約半年が経過した現在（[ニュースレター #315][news315 testnet4]参照）、
  testnet3をまだ使用している人がいるかどうかをBitcoin-Devメーリングリストで[尋ねました][provoost testnet3]。
  Andres Schildbachは、少なくとも1年間は彼の人気のウォレットのtestnet版でtestnet3を使い続けるつもりだと
  [返信しました][schildbach testnet3]。Olaoluwa Osuntokunは、
  testnet3は最近testnet4よりはるかに安定していると[述べました][osuntokun testnet3]。
  彼は、[Fork.Observer][]のWebサイトから取得した両方のtestnetのブロックツリーのスクリーンショットを添付して、
  自分の主張を説明しました。以下は、執筆時点でのtestnet4の状態を表す独自のスクリーンショットです:

  ![2025-03-25 の testnet4 のブロックツリーを表示するフォークモニター](/img/posts/2025-03-fork-monitor-testnet3.png)

  Osuntokunの投稿後、Antoine Poinsotはtestnet4の問題にフォーカスした[別のスレッド][poinsot testnet4]を開始しました。
  彼は、testnet4の問題は、難易度リセットルールの結果であると主張しています。
  このルールは、testnetにのみ適用され、ヘッダーの時間が親ブロックより20分遅い場合、
  ブロックは最小難易度で有効になります。Provoostは、この問題についてさらに[詳しく][provoost testnet4]説明しています。
  Poinsotは、このルールを削除するためにtestnet4のハードフォークを提案しています。
  Mark Erhardtは、フォークの日付として2026-01-08を[提案しています][erhardt testnet4]。

- **特定のTaproot annexをリレーする計画:** Peter Toddは、Bitcoin-Devメーリングリストで、
  Bitcoin CoreベースのノードであるLibre Relayを更新して、
  Taprootの[annex][topic annex]を含むトランザクションが以下の特定のルールに従う場合にリレーを開始する計画を[発表しました][todd annex]:

  - _0x00プレフィックス:_ 「すべての空でないannexは0x00で始まり、
    [将来の]コンセンサス関連のannexと区別します」

  - _オール・オア・ナッシング:_ 「すべてのインプットがannexを持ちます。
    これにより、annexの使用がオプトインになり、マルチパーティプロトコルでの
    [トランザクションピンニング][topic transaction pinning]攻撃を防止できます。」

  この計画は、Joost Jagerによる2023年の[プルリクエスト][bitcoin core #27926]に基づいています。
  このプルリクエスト自体は、Jagerが始めた以前の議論に基づいています（[ニュースレター #255][news255 annex]参照）。
  Jagerの言葉を借りれば、以前のプルリクエストでは、「非構造化annexデータの最大サイズを256 byteに制限し、
  [...] annexを使用するマルチパーティトランザクションの参加者をannexのインフレーションからある程度保護しました。」
  Toddのバージョンでは、このルールは含まれていません。彼は、「annexの使用にオプトインする要件で十分なはずだ」と考えています。
  そうでない場合、彼は取引相手のピンニングを防止できる追加のリレーの変更について説明しています。

  この記事の執筆時点で、現在のメーリングリストのスレッドでは、
  annexがどのように使用されることを期待しているのか説明している人はいません。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [witness commitmentがオプションなのは何故ですか？]({{bse}}125948)
  Pieter WuilleとAntoine Poinsotは、[BIP30][]「Duplicate transactions」と
  [BIP34][]「Block v2, Height in Coinbase」および、
  [ブロック1,983,702の問題][topic duplicate transactions]に関する
  [コンセンサスクリーンアップ][topic consensus cleanup]の考慮事項と、
  witness commitmentを必須にすることで問題がどのように解決されるかについて説明しています。

- [<!--can-all-consensus-valid-64-byte-transactions-be-third-party-malleated-to-change-their-size-->コンセンサスとして有効な64 byteトランザクションを（第三者が）細工してサイズを変更することは可能ですか？]({{bse}}125971)
  Sjors Provoostは、[コンセンサスクリーンアップ][topic consensus cleanup]ソフトフォークが有効化された場合に、
  コンセンサスとして無効になる[64-byteトランザクション][news27 64tx]を変異するためのアイディアを検討しています。
  Vojtěch Strnadは、すべての64-byteトランザクションが細工できるわけではないものの、
  それでも64-byteトランザクションのアウトプットは安全ではない（誰でも使用可能）か、
  使用できないことが証明可能なもの（`OP_RETURN`など）になると主張しています。

- [<!--how-long-does-it-take-for-a-transaction-to-propagate-through-the-network-->トランザクションがネットワーク全体に伝播するのにどれくらいの時間がかかりますか？]({{bse}}125776)
  Sr_giは、単一のノードではネットワーク全体のトランザクション伝播時間を測定できず、
  伝播時間を測定して推定するためには、Bitcoinネットワーク全体の複数のノードが必要になると指摘しています。
  彼は、KITの分散システムおよびネットワークサービス研究グループが運営する[Webサイト][dsn kit]を例に挙げ、
  その中でトランザクションの伝播時間を測定し、「トランザクションがネットワークの50%に到達するのに約7秒、
  90%に到達するのに約17秒かかる」と示しています。

- [<!--utility-of-longterm-fee-estimation-->長期の手数料推定の有用性]({{bse}}124227)
  Abubakar Sadiq Ismailは、彼の[手数料推定][topic fee estimation]の研究で、
  長期の手数料推定に依存しているプロジェクトやプロトコル、またはユーザーからのフィードバックを求めています。

- [LNで2つのアンカーアウトプットが使用されるのは何故ですか？]({{bse}}125883)
  Instagibbsは、現在ライトニングで使用されている[アンカーアウトプット][topic anchor outputs]の歴史的背景を説明し、
  [Bitcoin Core 28.0でのポリシー][28.0 wallet guide]変更により、
  [v3コミットメント][topic v3 commitments]への更新が計画されていることを指摘しています。

- [2xxの範囲のBIPがないのは何故ですか？]({{bse}}125914)
  Michael Folksonは、BIP番号200-299は、ある時点でライトニング関連のBIP用に確保されていたと指摘しています。

- [Bech32で文字"b"を使用しないのは何故ですか？]({{bse}}125902)
  Bordalixは、「B」と「8」の見ための類似性が、[bech32およびbech32m][topic bech32]アドレス形式で
  「B」を許可しない理由であると答えています。また、bech32に関するその他のトリビアも提供しています。

- [Bech32のエラー検出および訂正の参照実装]({{bse}}125961)
  Pieter Wuilleは、アドレスエンコーディングで最大4つのエラーを検出し、
  2つの置換エラーを修正できると述べています。

- [<!--how-to-safely-spend-burn-dust-->ダストを安全に使用/破棄するには？]({{bse}}125702)
  Murchは、既存のウォレットから[ダスト][topic uneconomical outputs]を送信しようとする際に考慮すべきことをリストアップしています。

- [Asymmetric Revocable Commitmentsの払い戻しトランザクションはどのように構築されていますか？]({{bse}}125905)
  Biel Castellarnauは、書籍「Mastering Bitcoin」のコミットメントトランザクションの例を順に説明しています。

- [Bitcoin CoreでZMQを使用するアプリケーションは？]({{bse}}125920)
  Sjors Provoostは、[IPC][news320 ipc]がこれらの用途を代替できるかどうかを調査する一環として、
  Bitcoin CoreのZMQサービスのユーザーを探しています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 29.0rc2][]は、ネットワークの主要なフルノードの次期メジャーバージョンのリリース候補です。
  [バージョン29のテストガイド][bcc29 testing guide]をご覧ください。

- [LND 0.19.0-beta.rc1][]は、この人気のLNノードのリリース候補です。
  おそらくテストが必要な主な改善の1つは、以下の注目すべきコードの変更セクションで説明する、
  協調クローズにおける新しいRBFベースの手数料引き上げです。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #31603][]は、`ParsePubkeyInner`パーサーを更新し、
  先頭または末尾に空白がある公開鍵を拒否するようになりました。これは、
  [rust-miniscript][rust miniscript]プロジェクトのパース動作と一致します。
  これまでは、ディスクリプターのチェックサムの保護により、誤って空白を追加することは不可能でした。
  `getdescriptorinfo`および`importdescriptors` RPCコマンドは、
  [ディスクリプター][topic descriptors]の公開鍵の断片にそのような空白が含まれている場合、
  エラーを投げるようになります。

- [Eclair #3044][]は、ブロックの再編成に対するチャネルの安全性のデフォルトの最小承認数を6から8に増やしました。
  また、チャネルの資金量に基づいてこの値をスケーリングしないようにしました。
  これは、[スプライシング][topic splicing]中にチャネルキャパシティが大幅に変更される可能性があるためです。
  これにより、実際には多額の資金が預けられているのに、ノードが低い承認数を受け入れることになります。

- [Eclair #3026][]は、[Simple Taproot Channel][topic simple taproot channels]を実装するための基盤として、
  Eclairが管理する監視専用ウォレットを含む、[P2TR（Pay-to-Taproot）][topic taproot]アドレス使用する
  Bitcoin Coreウォレットのサポートを追加します。P2TRウォレットを使用している場合でも、
  一部の協調クローズトランザクションではP2WPKHスクリプトが依然として必要です。

- [LDK #3649][]では、必要なフィールドを追加して、
  [BOLT12オファー][topic offers]でLSP（Lightning Service Provider）に支払うためのサポートが追加されました。
  これまでは、[BOLT11][]とオンチェーン支払いオプションのみが有効になっていました。
  これは、[BLIPs #59][]でも提案されています。

- [LDK #3665][]では、QRコードに収まる最大バイト数に基づくLNDの制限に合わせて、
  [BOLT11][]インボイスのサイズ制限を1,023 byteから7,089 byteに増やしました。
  PRの作者は、BOLT11インボイスで使用されるエンコーディングと互換性のあるQRコードは
  実際には4,296文字に制限されているが、LDKでは「システム全体の一貫性の方がおそらく重要」であるため、
  7,089という値が選択されたと主張しています。

- [LND #8453][]、[#9559][lnd #9559]、[#9575][lnd #9575]、[#9568][lnd #9568]および[LND #9610][]は、
  [BOLTs #1205][]（[ニュースレター #342][news342 closev2]参照）に基づく
  [RBF][topic rbf]協調クローズフローを導入し、どちらのピアも自身のチャネル資金を使用して手数料率を引き上げることができます。
  これまでは、ピアは相手に手数料の引き上げを説得しなければならないことがあり、
  その結果、試行がよく失敗しました。この機能を有効にするには、`protocol.rbf-coop-close`設定フラグをセットする必要があります。

- [BIPs #1792][]は、[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]を定義する[BIP119][]を更新し、
  より明瞭になるように文言を修正し、アクティベーションロジックを削除し、Eltooを[LN-Symmetry][topic eltoo]に名称変更し、
  新しい[コベナンツ][topic covenants]提案や、`OP_CTV`を使用する[Ark][topic ark]などのプロジェクトについての言及を追加しています。

- [BIPs #1782][]は、[testnet4][topic testnet]のコンセンサスルールを概説する
  [BIP94][]の仕様セクションを、より明瞭で読みやすくなるように修正しました。

{% include snippets/recap-ad.md when="2025-04-01 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31603,3044,3026,3649,3665,9610,1792,1782,27926,8453,9559,9575,9568,1205,59" %}[bitcoin core 29.0rc2]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc1
[news255 annex]: /ja/newsletters/2023/06/14/#taproot-annex
[news315 testnet4]: /ja/newsletters/2024/08/09/#bitcoin-core-29775
[fork.observer]: https://fork.observer/
[law fees]: https://delvingbitcoin.org/t/fee-based-spam-prevention-for-lightning/1524/
[law fee paper]: https://github.com/JohnLaw2/ln-spam-prevention
[news329 opr]: /ja/newsletters/2024/11/15/#mad-opr
[harding fee]: https://delvingbitcoin.org/t/fee-based-spam-prevention-for-lightning/1524/4
[provoost testnet3]: https://mailing-list.bitcoindevs.xyz/bitcoindev/9FAA7EEC-BD22-491E-B21B-732AEA15F556@sprovoost.nl/
[schildbach testnet3]: https://mailing-list.bitcoindevs.xyz/bitcoindev/7c28f8e9-d221-4633-8b71-53b4db07fa78@schildbach.de/
[osuntokun testnet3]: https://groups.google.com/g/bitcoindev/c/jYBlh24OB-Y/m/vbensqcZAwAJ
[poinsot testnet4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/hU75DurC5XToqizyA-vOKmVtmzd3uZGDKOyXuE_ogE6eQ8tPCrvX__S08fG_nrW5CjH6IUx7EPrq8KwM5KFy9ltbFBJZQCHR2ThoimRbMqU=@protonmail.com/
[provoost testnet4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/2064B7F4-B23A-44B0-A361-0EC4187D8E71@sprovoost.nl/
[erhardt testnet4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/7c6800f0-7b77-4aca-a4f9-2506a2410b29@murch.one/
[todd annex]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Z9tg-NbTNnYciSOh@petertodd.org/
[russell loop]: https://diyhpl.us/~bryan/irc/bitcoin/bitcoin-dev/linuxfoundation-pipermail/lightning-dev/2015-August/000135.txt
[news263 dos philosophy]: /ja/newsletters/2023/08/09/#dos
[news136 more fee]: /ja/newsletters/2021/02/17/#renewed-discussion-about-bidirectional-upfront-ln-fees-ln
[news122 bi-directional]: /en/newsletters/2020/11/04/#bi-directional-upfront-fees-for-ln
[news86 reverse upfront]: /ja/newsletters/2020/02/26/#reverse-up-front-payments
[news119 trusted upfront]: /en/newsletters/2020/10/14/#trusted-upfront-payment
[news120 upfront]: /en/newsletters/2020/10/21/#more-ln-upfront-fees-discussion
[news342 closev2]: /ja/newsletters/2025/02/21/#bolts-1205
[rust miniscript]: https://github.com/rust-bitcoin/rust-miniscript
[dsn kit]: https://www.dsn.kastel.kit.edu/bitcoin/#propdelaytx
[28.0 wallet guide]: /ja/bitcoin-core-28-wallet-integration-guide/
[news320 ipc]: /ja/newsletters/2024/09/13/#bitcoin-core-30509
[news27 64tx]: /en/newsletters/2018/12/28/#cve-2017-12842
