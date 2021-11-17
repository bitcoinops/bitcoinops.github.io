---
title: 'Bitcoin Optech Newsletter #175'
permalink: /ja/newsletters/2021/11/17/
name: 2021-11-17-newsletter-ja
slug: 2021-11-17-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Taprootのアクティベーションに関する情報とともに、
サービスやクライアントソフトウェアの変更点や、新しいリリースおよびリリース候補、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点をまとめた恒例のセクションを掲載しています。

## ニュース

- **Taprootのアクティベート:** 予想どおり、
  [Taproot][topic taproot]のソフトフォークはブロック高{{site.trb}}でアクティベートされました。
  この記事を書いている時点では、いくつかの大規模なマイニングプールはTaprootの支払いを含むブロックをマイニングしていません。
  これは、私たちが[以前警告した][p4tr what happens]リスクである、
  Taprootのルールを提供する準備が出来ていることを偽って通知していたことを示しているのかもしれません。
  或いは、Taproot適用ノードを使って使用するブロックチェーンを選択する一方で、
  旧ノードやカスタムソフトウェアを使用してブロックに含めるトランザクションを選択するというリクスのない方法を採っている可能性もあります。

    ユーザーや企業にとって最も安全な方法は、（Bitcoin Core 22.0のような）自身のTaproot適用ノードを実行し、
    そのノードで承認されたトランザクションのみを受け入れることです。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **bitcoinjがbech32mとP2TRのサポートを追加:**
  Andreas Schildbachは、bitcoinjのリポジトリに[bech32m][topic bech32]の[コミット][bitcoinj bech32m]と
  [P2TRのサポートのコミット][bitcoinj p2tr]を追加しました。

- **libwally-coreがbech32mのサポートを追加:**
  このウォレットのプリミティブライブラリの[0.8.4のリリース][libwally 0.8.4]に[bech32mのサポート][libwally 297]が追加されました。

- **Spark Lightning WalletがBOLT12 offerを追加:**
  Spark [v0.3.0][spark v0.3.0]では、Offerの作成、Offer支払いの送信、プル支払いなどの[Offer][topic offers]機能が追加されました。
  将来のリリースでは、定期的なOffer機能の導入が予定されています。

- **BitGoウォレットがTaprootをサポート:**
  BitGoは、APIを使用した[Taproot][topic taproot]アウトプットへの送信と受信の両方をサポートすることを[発表しました][bitgo taproot blog]。
  将来のアップデートでUIでのTaprootのサポートが予定されています。

- **NthKeyがbech32mへの送信機能をサポート:**
  iOSの署名サービス[NthKey][nthkey website]が、[v1.0.4のリリース][nthkey v1.0.4]でTaprootへの送信をサポートしました。

- **Ledger LiveがTaprootをサポート:**
  LedgerのクライアントソフトウェアであるLedger Liveが、実験的な機能として
  [v2.35.0のリリース][ledger v2.35.0]でTaprootのサポートを発表しました。

- **MuunウォレットがTaprootをサポート:**
  Taprootがアクティベートされた後、MuunウォレットはTaprootアドレスのサポートを有効にし、
  デフォルトでTaprootの受信アドレスを設定できるようになりました。

- **KolliderがLNベースの取引プラットフォームのアルファ版を発表:**
  Kolliderの最新の[発表][kollider blog]では、LNの入出金やLNAUTH、
  LNURLのサポートなどを含むデリバティブプラットフォームの機能の詳細が紹介されています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND 0.14.0-beta.rc4][]は、[エクリプス攻撃][topic eclipse attacks]対策の追加
  （[ニュースレター #164][news164 ping]参照）、リモートデータベースのサポート（[ニュースレター #157][news157 db]参照）、
  経路探索の高速化（[ニュースレター #170][news170 path]参照）、
  Lightning Poolユーザー向けの改善（[ニュースレター #172][news172 pool]参照）、
  再利用可能な[AMP][topic amp]インボイス（[ニュースレター #173][news173 amp]参照）および、
  他の多くの機能やバグ修正が含まれたリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #22934][]では、
  ECDSA署名と[Schnorr署名][topic schnorr signatures]の両方が作成された後の検証ステップが追加されています。
  これにより、誤って生成された署名をソフトフォウェアが公開することで、
  その署名に生成された秘密鍵やnonceの情報が漏洩することを防ぐことができます。
  これは、以前[ニュースレター #83][news83 safety]で紹介した[BIP340][]のアップデート
  （[ニュースレター #87][news87 bips886]参照）で得られたアドバイスに従ったものです。

- [Bitcoin Core #23077][]では、[CJDNS][]によるアドレスのリレーが可能になり、
  CJDNSがIPv4やIPv6、Tor、I2Pと同様に完全にサポートされたネットワークになりました。
  CJDNSがBitcoin Coreの外部でセットアップされると、ノードオペレーターは新しい設定オプション
  `-cjdnsreachable`を切り替えて、Bitcoin Coreが`fc00::/8`アドレスをIPv6アドレスとして解釈するのではなく、
  CJDNSに属していると解釈するようにできます。

- [Eclair #1957][]では、[BOLTs #759][]による[Onionメッセージ][topic onion messages]の基本的なサポートが追加されました。
  Onionメッセージのリレーは可能ですが、Onionメッセージの開始や受信はサポートしていません。

- [Rust Bitcoin #691][]では、公開鍵やオプションの[Tapscript][topic tapscript]のマークルルートから
  [P2TR][topic taproot]の[bech32m][topic bech32]アドレスを作成するAPIを追加しました。

- [BDK #460][]では、トランザクションに`OP_RETURN`アウトプットを追加する新しい関数が追加されました。

- [BIPs #1225][]では、BIP341に[ニュースレター #173][news173 taproot tests]で掲載したTaprootのTest Vectorを追加しました。

{% include references.md %}
{% include linkers/issues.md issues="22934,23077,1957,691,460,1225,759" %}
[lnd 0.14.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.0-beta.rc4
[news164 ping]: /ja/newsletters/2021/09/01/#lnd-5621
[news157 db]: /ja/newsletters/2021/07/14/#lnd-5447
[news170 path]: /ja/newsletters/2021/10/13/#lnd-5642
[news172 pool]: /ja/newsletters/2021/10/27/#lnd-5709
[news173 amp]: /ja/newsletters/2021/11/03/#lnd-5803
[news87 bips886]: /ja/newsletters/2020/03/04/#bips-886
[news83 safety]: /ja/newsletters/2020/02/05/#schnorr
[news173 taproot tests]: /ja/newsletters/2021/11/03/#taproot-test-vectors-taproot-test-vector
[p4tr what happens]: /ja/preparing-for-taproot/#アクティベーション時に何が起こる
[cjdns]: https://github.com/cjdelisle/cjdns
[bitcoinj bech32m]: https://github.com/bitcoinj/bitcoinj/pull/2099
[bitcoinj p2tr]: https://github.com/bitcoinj/bitcoinj/pull/2225
[libwally 0.8.4]: https://github.com/ElementsProject/libwally-core/releases/tag/release_0.8.4
[libwally 297]: https://github.com/ElementsProject/libwally-core/pull/297
[spark v0.3.0]: https://github.com/shesek/spark-wallet/releases/tag/v0.3.0
[bitgo taproot blog]: https://blog.bitgo.com/taproot-support-for-bitgo-wallets-9ed97f412460
[nthkey website]: https://nthkey.com/
[nthkey v1.0.4]: https://github.com/Sjors/nthkey-ios/releases/tag/v1.0.4
[ledger v2.35.0]: https://github.com/LedgerHQ/ledger-live-desktop/releases/tag/v2.35.0
[kollider blog]: https://kollider.medium.com/kollider-alpha-version-h1-3bec739df1d4
