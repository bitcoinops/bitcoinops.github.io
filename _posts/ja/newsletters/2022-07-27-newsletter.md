---
title: 'Bitcoin Optech Newsletter #210'
permalink: /ja/newsletters/2022/07/27/
name: 2022-07-27-newsletter-ja
slug: 2022-07-27-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、非レガシーアドレス用の署名付きメッセージを作成するために提案されているBIPと、
サービス拒否攻撃の対策のために少量のビットコインを焼却することに関する議論を掲載しています。
また、Bitcoin Stack Exchangeの人気のある質問と回答や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更などの恒例のセクションも含まれています。

## ニュース

- **<!--multiformat-single-sig-message-signing-->マルチフォーマットのシングルシグのメッセージ署名:**
  Bitcoin Coreや他の多くのウォレットは、署名に使用される鍵がP2PKHアドレスに対応したものである場合、
  任意のメッセージへの署名と検証を長い間サポートしています。
  Bitcoin Coreは、シングルシグのP2SH-P2WPKHやネイティブのP2WPKHおよびP2TRアウトプットをカバーするアドレスを含む、
  他のアドレスタイプに対する任意のメッセージへの署名および検証をサポートしていません。以前提案されていた[BIP322][]は、
  任意のScriptに対して機能する[完全に汎用的なメッセージ署名][topic generic signmessage]を提供するものですが、
  まだBitcoin Coreに[マージされておらず][bitcoin core #24058]、
  私たちの知っている他の人気のウォレットにも追加されていません。

    今週、Ali Sheriefは、P2WPKHで使用されているのと同じメッセージ署名アルゴリズムを
    他のアウトプットタイプにも使用することを[提案しました][sherief gsm]。
    検証のために、プログラムは鍵の導出方法を（必要であれば）推測し、
    アドレスタイプを使用して署名を検証する必要があります。
    たとえば、20バイトのデータ要素を持つ[bech32][topic bech32]アドレスが提供された場合、
    それはP2WPKHアウトプットであると仮定します。

    開発者のPeter Grayは、ColdCardウォレットは既にこの方法で署名を作成していると[指摘し][gray cc]、
    開発者のCraig Rawは、Sparrow Walletは[BIP137][]の検証ルールとElectrumに実装されている少し異なるルールセットも加えた上で、
    それらの検証することができると[述べました][raw sparrow]。

    Sheriefは、動作を定義するBIPの作成を計画しています。

- **Proof of micro-burn:** 何人かの開発者は、
  リソースの消費の証明としてビットコインを少しずつ破壊する（焼却する）オンチェーントランザクションのユースケースと設計について[議論しました][pomb]。
  [スレッドにあった][somsen hashcash]Ruben Somsenのユースケースを拡張することで、
  100人のユーザーがそれぞれ$1のビットコインが焼却されたという証明をメールに添付できるようにするものは、
  もともと[hashcash][]の利点として想定されていた類のアンチスパム保護を提供するものです。

    マークルツリーを使用したいくつかのソリューションが議論されましたが、
    ある回答者は、参加者が中央の第三者を信頼（または部分的に信頼）することは、
    不必要な複雑さを回避するための合理的な方法であることを、この小額の金額が示唆していると述べました。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-do-invalid-signatures-in-op-checksigadd-not-push-to-the-stack-->`OP_CHECKSIGADD`で無効な署名がスタックにプッシュされないのはどうしてですか？]({{bse}}114446)
  Chris Stewartは、「無効な署名が見つかった場合、インタプリターは実行を継続するのではなく失敗する」のは何故かと質問しています。
  Pieter Wuilleは、BIP340-342で定義されたこの動作は、
  将来[Schnorr署名][topic schnorr signatures]のバッチ検証をサポートするために設計されたと説明しています。
  Andrew Chowは、この動作の追加の理由として、ある種のマリアビリティに関する懸念もこのアプローチによって軽減されると述べています。

- [<!--what-are-packages-in-bitcoin-core-and-what-is-their-use-case-->Bitcoin Coreにおけるパッケージとは何か、またそのユースケースについて教えてください。]({{bse}}114305)
  Antoine Poinsotは、[パッケージ][bitcoin docs packages]（関連のあるトランザクションのグループ）と、
  [パッケージリレー][topic package relay]との関係性、最近の[パッケージリレーのBIP提案][news201 package relay]について説明しています。

- [<!--how-much-blockspace-would-it-take-to-spend-the-complete-utxo-set-->完全なUTXOセットを支払いに使用するには、どれくらいのブロックスペースが必要ですか？]({{bse}}114043)
  Murchは、既存のUTXOセットを全て統合するという架空のシナリオを検討しています。
  彼は、各アウトプットタイプ毎にブロックススペースを計算し、このプロセスには、約11,500ブロックが必要であるという結論を出しました。

- [<!--does-an-uneconomical-output-need-to-be-kept-in-the-utxo-set-->経済合理性のないアウトプットをUTXOセットに残しておく必要はありますか？]({{bse}}114493)
  Stickies-vは、`OP_RETURN`や、最大Scriptサイズを超えるScriptを含むおそらく使用不可能なUTXOは、
  UTXOセットから削除されますが、[経済合理性のないアウトプット][topic uneconomical outputs]を削除すると、
  Pieter Wuilleが指摘しているように、そのアウトプットが使用された場合にハードフォークなどの問題を引き起こす可能性があると指摘しています。

- [<!--is-there-code-in-libsecp256k1-that-should-be-moved-to-the-bitcoin-core-codebase-->libsecp256k1に、Bitcoin Coreのコードベースに移動すべきコードはありますか？]({{bse}}114467)
  [libbitcoinkernel][libbitcoinkernel project]や[プロセス分離][devwiki process separation]などのBitcoin Coreのコードベースをモジュール化する他の取り組みと同様に、
  Pieter Wuilleは、[libsecp256k1][]プロジェクトの明確な責任範囲である秘密鍵と公開鍵の操作に関わるすべてに注目しています。

- [<!--mining-stale-low-difficulty-blocks-as-a-dos-attack-->DoS攻撃として古くなった低難易度ブロックのマイニング]({{bse}}114241)
  Andrew Chowは、[assumevalid][assumevalid notes]および、
  より最近では[`nMinimumChainWork`][Bitcoin Core #9053]が、難易度の低いチェーン攻撃をフィルタリングするのに役立つと説明しています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BTCPay Server 1.6.3][]は、この人気のあるセルフホスト型のペイメントプロセッサに、
  新機能、改良、バグ修正を追加しています。

- [LDK 0.0.110][]は、LN対応アプリケーションを構築するためのこのライブラリにさまざまな新機能（その多くは以前のニュースレターに掲載済み）を追加しています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #25351][]は、アドレスや鍵およびディスクリプターをウォレットにインポートした後、
  その後の再スキャンがブロックチェーンだけでなくmempool内のトランザクションがウォレットに関係しているかどうかも評価することを保証します。

- [Core Lightning #5370][]は、`commando`プラグインを再実装し、CLNに組み込みました。
  commandoは、ノードがLNメッセージを使用して認可されたピアからコマンドを受信できるようにします。
  ピアは、簡易版の[macaroons][]をベースにしたカスタムCLNプロトコルである*runes*を使用して認可されます。
  commandoは、現在CLNに組み込まれていますが、ユーザーがrune認証トークンを作成した場合のみ操作可能です。
  詳しくは、CLNの[commando][]と[commando-rune][]のマニュアルページをご覧ください。

- [BOLTs #1001][]は、支払い転送ポリシーの変更を通知したノードが、
  古いポリシーで受け取った支払いを10分ほど受け入れ続けることを推奨しています。
  これは、送信者が最近のポリシーの更新について知らなかったという理由で、
  支払いが失敗するのを防ぐためのものです。このようなルールを採用した実装例については、
  [ニュースレター #169][news169 cln4806]をご覧ください。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25351,5370,1001,24058,9053" %}
[BTCPay Server 1.6.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.6.3
[LDK 0.0.110]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.110
[commando]: https://github.com/rustyrussell/lightning/blob/2e13b72f55080be07ea68de77976eb990a043f5d/doc/lightning-commando.7.md
[commando-rune]: https://github.com/rustyrussell/lightning/blob/2e13b72f55080be07ea68de77976eb990a043f5d/doc/lightning-commando-rune.7.md
[news169 cln4806]: /ja/newsletters/2021/10/06/#c-lightning-4806
[sherief gsm]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020759.html
[gray cc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020762.html
[raw sparrow]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020766.html
[pomb]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020745.html
[hashcash]: https://en.wikipedia.org/wiki/Hashcash
[somsen hashcash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020746.html
[macaroons]: https://en.wikipedia.org/wiki/Macaroons_(computer_science)
[bitcoin docs packages]: https://github.com/bitcoin/bitcoin/blob/53b1a2426c58f709b5cc0281ef67c0d29fc78a93/doc/policy/packages.md#definitions
[news201 package relay]: /ja/newsletters/2022/05/25/#package-relay-proposal
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/24303
[devwiki process separation]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/Process-Separation
[assumevalid notes]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#assumed-valid-blocks
