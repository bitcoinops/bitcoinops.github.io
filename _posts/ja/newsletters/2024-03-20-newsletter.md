---
title: 'Bitcoin Optech Newsletter #294'
permalink: /ja/newsletters/2024/03/20/
name: 2024-03-20-newsletter-ja
slug: 2024-03-20-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、軽量クライアント向けのBIP324プロキシを作成するプロジェクトの発表や、
提案されているBTC Lisp言語に関する議論を掲載しています。また、
クライアントやサービスの最近の変更や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など恒例のセクションも含まれています。

## ニュース

- **軽量クライアント向けのBIP324プロキシ:** Sebastian Falbesonerは、
  バージョン1（v1）Bitcoin P2Pプロトコルと[BIP324][]で定義されている[v2プロトコル][topic v2 p2p transport]間の
  変換を行うTCPプロキシの発表をDelving Bitcoinに[投稿しました][falbesoner bip324]。
  これは特に、v1用に作成された軽量クライアントがv2のトラフィックの暗号化を利用できるようにすることを目的としています。

  軽量クライアントは通常、自身のウォレットに属するトランザクションのみをアナウンスするため、
  暗号化されていないv1接続を盗聴できる人は誰でも、軽量クライアントによって送信されたトランザクションが
  発信元IPアドレスを使用している誰かのものであることを合理的に結論付けることができます。
  v2暗号化が使用される場合、軽量クライアントの接続のどれも中間者攻撃の対象になっていないと仮定した場合（
  これは場合によっては検出可能で、[今後のアップグレード][topic countersign]で自動的に防御できる可能性があります）、
  それが軽量クライアントのIPアドレスからのものであることを明確に識別できるのは、トランザクションを受信するフルノードのみです。

  Falbesonerの最初の仕事は、Bitcoin Coreのテストスイート用にPythonで書かれたBIP324関数をまとめたもので、
  その結果、プロキシは「非常に遅く、サイドチャネル攻撃に対して脆弱であり、
  現時点ではテスト以外に使用することは推奨されません」。ただし、
  彼はRustでプロキシを書き直すことに取り組んでおり、その機能の一部またはすべてを
  v2 Bitcoin P2Pプロトコルをネイティブにサポートしたい軽量クライアントや
  その他のソフトウェアのライブラリとして利用できるようにする可能性があります。

- **BTC Lispの概要:** Anthony Townsは、BTC Lispと呼ばれるBitcoin用の
  [Lisp][]言語のバージョンを作成した過去2年間の実験についてDelving Bitcoinに[投稿しました][towns lisp]。
  以前の議論については、ニュースレター[#293][news293 lisp]と[#191][news191 lisp]をご覧ください。
  この投稿では、かなり詳しく説明されています。このアイディアに興味がある方は、直接読むことをお勧めします。
  _結論_ と _将来の作業_ のセクションから簡単に引用します。

  「BTC Lispは、オンチェーンでは少し高価になる可能性がありますが、
  ほとんど何でもできそうです。 [...] Lispインタプリタや、
  それに付随する必要なopcodeを実装することはそんなに難しいことではないと思っていますが、
  高レベルの表現からコンセンサスレベルのopcodeまで変換するコンパイラなしでLispのコードを書くのはかなり面倒です。
  ただ解決できそうです。このような言語を実装し、それをsignet/inquisitionに展開することで、
  さらに発展させることができるでしょう。」

  いつか代替のコンセンサススクリプト言語として考慮されるかもしれない[Simplicity][topic simplicity]
  言語の開発者であるRussell O'Connorは、Bitcoinの現在のスクリプト言語とSimplicity、
  Chia/BTC Lispとのいくつかの比較を交えて[返答しました][oconnor lisp]。
  彼は次のように結論付けています。「Simplicityとclvm（Chia Lisp仮想マシン）は両方とも、
  機械が評価しやすいように意図された低レベル言語ですが、そのため人には読みにくいというトレードオフが生じます。
  これらは、人が読むことができコンセンサスクリティカルでない別の言語からコンパイルされることを目的としています。
  Simplicityとclvmは、環境からのデータのフェッチやデータのbitの組み合わせ、
  条件付きステートメントの実行およびある種の基本的な操作群などを表現する異なる方法です。[...]
  私たちは、効率的な低レベルのコンセンサス言語と高レベルの非コンセンサスな理解しやすい言語間でこの分割をしたいと思っているため、
  低レベル言語の詳細はそれほど重要ではなくなります。つまり、少し努力すれば、
  あなたの高レベルBTC Lisp言語はおそらくSimplicityに変換/コンパイルできるでしょう。[...]
  同様に、SimplicityベースのSimphony（高レベルの非コンセンサス言語）の設計がどこに行き着いても、
  おそらく低レベルのBTC Lisp言語に変換/コンパイルすることができ、
  各トランスレーター/コンパイラ言語のペアは、異なる潜在的な複雑さ/最適化の機会を提供します。」

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **BitGoがRBFをサポート:**
  [最近のブログ][bitgo blog]で、BitGoは彼らのウォレットやAPIで
  [RBF（replace-by-fee ）][topic rbf]を使用した手数料の引き上げのサポートを発表しました。

- **Phoenix Wallet v2.2.0リリース:**
  このリリースにより、Phoenixは静止プロトコル（[ニュースレター #262][news262 eclair2680]参照）を使用してLN支払いを行う際に
  [スプライシング][topic splicing]をサポートできるようになりました。さらにPhoenixは、
  [swaproot][swaproot blog]プロトコルを使用することで、スワップ・イン機能のプライバシーと手数料を改善しました。

- **Bitkeyハードウェア署名デバイスのリリース:**
  [Bitkey][bitkey website]デバイスは、モバイルデバイスとBitkeyのサーバー鍵を使用した
  2-of-3のマルチシグセットアップで使用するよう設計されています。ファームウェアやさまざまなコンポーネントのソースコードは、
  Commons Clause modified MIT Licenseの下で[入手可能です][bitkey github]。

- **Envoy v1.6.0リリース:**
  この[リリース][envoy blog]では、トランザクションの手数料引き上げのための機能とトランザクションのキャンセル機能が追加されており、
  どちらもRBF（replace-by-fee）を使用して有効になります。

- **VLS v0.11.0リリース:**
  この[ベータリリース][vls beta 3]では、同じライトニングノードに対して複数の署名デバイスを使用できるようになりました。
  この機能は[Tag Team Signing][vls blog]と呼ばれています。

- **Portalハードウェア署名デバイスの発表:**
  [最近発表された][portal tweet]Portalデバイスは、
  ハードウェアとソフトウェアが[利用可能][portal github]なNFCを使用してスマートフォンで動作します。

- **Braiinsマイニングプールがライトニングをサポート:**
  Braiinsマイニングプールは、ライトニングを介したマイニングペイアウトのベータ版を[発表しました][braiins tweet]。

- **Ledger Bitcoin App 2.2.0リリース:**
  [2.2.0リリース][ledger 2.2.0]では、[Taproot][topic taproot]用の[miniscript][topic miniscript]のサポートが追加されました。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 26.1rc2][]は、ネットワークの主要なフルノード実装のメンテナンスリリースのリリース候補です。

- [Bitcoin Core 27.0rc1][]は、ネットワークの主要なフルノード実装の次期メジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。*

*注：以下に掲載するBitcoin Coreへのコミットは、master開発ブランチに適用されるため、
これらの変更は次期バージョンの27のリリースから約6ヶ月後までリリースされないでしょう。*

- [Bitcoin Core #27375][]は、ローカルのTCPポートではなくUNIXドメインソケットを使用するための
  `-proxy`および`-onion`機能のサポートを追加します。ソケットはTCPよりも高速で、
  セキュリティのトレードオフも異なります。

- [Bitcoin Core #27114][]は、`whitelist`設定パラメーターに「in」と「out」を追加し、
  特定の受信接続と送信接続に特別なアクセスを与えることができるようにします。デフォルトでは、
  ホワイトリストに挙がっているピアは、ユーザーのローカルノードに接続する際（受信接続）にのみ特別なアクセスを受け取ります。
  「out」を指定することで、ユーザーが`addnode` RPCを呼び出すなど、
  ローカルノードがピアに接続した場合にピアが特別なアクセスを確実に受け取ることができるようにします。

- [Bitcoin Core #29306][]は、未承認の[親のv3][topic v3 transaction relay]から派生したトランザクションに対する
  [兄弟の排除][topic kindred rbf]を追加します。これは、現在[LNのアンカーアウトプット][topic anchor outputs]で使用されている
  [CPFP carve-out][topic cpfp carve out]に対する満足のいく代替となり得ます。
  兄弟の排除を含むv3トランザクションリレーは、現在mainnetでは有効になっていません。

- [LND #8310][]により、`rpcuser`および`rpcpass`（パスワード）設定パラメーターをシステム環境から取得できるようになります。
  これにより、たとえば、プライベートなユーザー名とパスワードを保存することなく、
  非プライベートなリビジョン管理システムを使用して、`lnd.conf`ファイルを管理できるようになります。

- [Rust Bitcoin #2458][]は、Taprootインプットを含む[PSBT][topic psbt]への署名のサポートを追加します。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27375,27114,29306,8310,2458" %}
[bitcoin core 26.1rc2]: https://bitcoincore.org/bin/bitcoin-core-26.1/
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[lisp]: https://en.wikipedia.org/wiki/Lisp_(programming_language)
[news293 lisp]: /ja/newsletters/2024/03/13/#chia-lisp
[news191 lisp]: /ja/newsletters/2022/03/16/#chia-lisp
[falbesoner bip324]: https://delvingbitcoin.org/t/bip324-proxy-easy-integration-of-v2-transport-protocol-for-light-clients-poc/678
[towns lisp]: https://delvingbitcoin.org/t/btc-lisp-as-an-alternative-to-script/682
[oconnor lisp]: https://delvingbitcoin.org/t/btc-lisp-as-an-alternative-to-script/682/7
[bitgo blog]: https://blog.bitgo.com/available-now-for-clients-bitgo-introduces-replace-by-fee-f74e2593b245
[news262 eclair2680]: /ja/newsletters/2023/08/02/#eclair-2680
[swaproot blog]: https://acinq.co/blog/phoenix-swaproot
[bitkey website]: https://bitkey.world/
[bitkey github]: https://github.com/proto-at-block/bitkey
[envoy blog]: https://foundation.xyz/2024/03/envoy-version-1-6-0-is-now-live/
[vls beta 3]: https://gitlab.com/lightning-signer/validating-lightning-signer/-/releases/v0.11.0
[vls blog]: https://vls.tech/posts/tag-team/
[portal tweet]: https://twitter.com/afilini/status/1766085500106920268
[portal github]: https://github.com/TwentyTwoHW
[braiins tweet]: https://twitter.com/BraiinsMining/status/1760319741560856983
[ledger 2.2.0]: https://github.com/LedgerHQ/app-bitcoin-new/releases/tag/2.2.0
