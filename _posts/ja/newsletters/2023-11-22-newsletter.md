---
title: 'Bitcoin Optech Newsletter #278'
permalink: /ja/newsletters/2023/11/22/
name: 2023-11-22-newsletter-ja
slug: 2023-11-22-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、ライトニングアドレスに似た特定のDNSアドレスを使用して
LNオファーを取得できるようにする提案を掲載しています。また、サービスとクライアントソフトウェアの変更や、
新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **オファー互換のLNアドレス:** Bastien Teinturierは、
  [オファープロトコル][topic offers]の機能を活用した方法で、
  LNユーザー向けにemail形式のアドレスを作成することについてLightning-Devメーリングリストに[投稿しました][teinturier addy]。
  背景として、[LNURL][]をベースにした一般的な[ライトニングアドレス][lightning address]の規格が存在します。
  この規格では、email形式のアドレスをLNインボイスと関連付けるのに、常時利用可能なHTTPサーバーを稼働させる必要があります。
  Teinturierは、これによっていくつかの問題が生じると指摘しています:

    - _プライバシーの欠如:_ サーバーの運営者が支払人と受取人のIPアドレスを知る可能性があります。

    - _盗難のリスク:_ サーバーの運営者が資金を盗むために中間者インボイスを作成する可能性があります。

    - _インフラと依存関係:_ サーバーの運営者はDNSとHTTPSのホスティング環境をセットアップする必要があり、
      支払人のソフトウェアはDNSとHTTPSを使用できなければなりません。

  Teinturierは、オファーに基づいた3つの設計案を提示しています:

    - _ドメインとノードのリンク:_ DNSレコードは、ドメイン（例：example.com）を
      LNノード識別子にマッピングします。支払人は最終的な受信者（例：alice@example.com）へ
      オファーを要求する[オニオンメッセージ][topic onion messages]をそのノードに送信します。
      ドメインノードは、そのノードの鍵で署名されたオファーで応答します。
      この時アリスからのものではないオファーを提供した場合、支払人は後で詐欺を証明することができます。
      支払人はオファープロトコルを使用してアリスからインボイスを要求できるようになります。
      支払人は、alice@example.comをオファーに関連付けることもできるため、
      アリスへの今後の支払いのためにドメインノードに連絡する必要がなくなります。
      Teinturierは、この設計は非常にシンプルだと指摘しています。

    - _ノードアナウンスにおける証明書:_ LNノードがネットワークに自分自身を告知するために使用する既存の仕組みを変更し、
      （認証局により）example.comの所有者が、この特定のノードがalice@example.comによって管理されていることを証明する
      SSL証明書チェーンを告知に含めることができるようにします。Teinturierは、
      これにはLNの実装がSSL互換の暗号を実装する必要があると指摘しています。

  - _オファーをDNSに直接格納する:_ ドメインは、特定のアドレスに対するオファーを直接格納する複数のDNSレコードを持つことができます。
    たとえば、DNSの`TXT`レコード`alice._lnaddress.domain.com`にはアリスのオファーが含まれ、
    別のレコード`bob._lnaddress.domain.com`にはボブのオファーが含まれます。
    Teinturierは、このためには、ドメインの所有者がユーザー毎に１つのDNSレコードを作成する必要があると指摘しています（
    ユーザーがデフォルトのオファーを変更する必要がある場合は、レコードを更新します）。

  このメールは活発な議論を起こしました。注目すべき提案の１つは、
  1つめと3つめの提案（ドメインをノードにリンクする提案と、オファーをDNSに直接格納する提案）の
  両方を使用できるようにする可能性があるというものでした。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **BitMask Wallet 0.6.3リリース:**
  [BitMask][bitmask website]は、Bitcoinおよびライトニング、RGB、[Payjoin][topic payjoin]用の
  ウェブとブラウザ拡張ベースのウォレットです。

- **Opcodeのドキュメントウェブサイトの発表:**
  Bitcoinの多数のopcodeの説明を提供するウェブサイト[https://opcodeexplained.com/]が最近[発表されました][OE tweet]。
  この取り組みは進行中で、[貢献を歓迎します][OE github]。

- **Athena Bitcoinがライトニングのサポートを追加:**
  Bitcoin ATMの[運営会社][athena website]は最近、現金の引き出しのために、
  ライトニング支払いの受信のサポートを[発表しました][athena tweet]。

- **Blixt v0.6.9リリース:**
  [v0.6.9][blixt v0.6.9]のリリースでは、Simple Taproot Channelのサポート、
  [bech32m][topic bech32]受信アドレスのデフォルト設定、
  [ゼロ承認チャネル][topic zero-conf channels]のサポートが追加されました。

- **Durabitホワイトペーパーの発表:**
  [Durabitのホワイトペーパー][Durabit whitepaper]では、
  [タイムロックされた][topic timelocks]BitcoinトランザクションとChaumianスタイルの発行を組み合わせて使用し、
  大容量ファイルをシードするためにインセンティブを与えるプロトコルの概要が説明されています。

- **BitStreamホワイトペーパーの発表:**
  [BitStreamのホワイトペーパー][BitStream whitepaper]と[初期プロトタイプ][bitstream github]は、
  検証とFraud Proofを備えたタイムロックとマークルツリーを使用した
  デジタルコンテンツのホスティングとコインのアトミックスワップを行うプロトコルの概要が説明されています。
  有料データ転送プロトコルに関する以前の議論については、[ニュースレター #53][news53 data]を参照。

- **BitVMの概念実証**
  [BitVM][news273 bitvm]に基づいて構築された2つの概念実証が投稿されました。
  １つは[BLAKE3][]ハッシュ関数を[実装し][bitvm tweet blake3]、
  [もう1つ][bitvm techmix poc]はSHA256を[実装しています][bitvm sha256]。

- **BitkitがTaprootの送信をサポート:**
  モバイルのBitcoinおよびライトニングウォレットである[Bitkit][bitkit website]は、
  [v1.0.0-beta.86][bitkit v1.0.0-beta.86]のリリースで[Taproot][topic taproot]の送信をサポートを追加しました。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND v0.17.2-beta][]は、[LND #8186][]で報告されたバグを修正するための
  小さな変更のみが含まれたメンテナンスリリースです。

- [Bitcoin Core 26.0rc2][]は、主流のフルノード実装の次期メジャーバージョンのリリース候補です。
  [テストのガイド][26.0 testing]が利用可能です。

- [Core Lightning 23.11rc3][]は、このLNノード実装の次期メジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Core Lightning #6857][]は、RESTインターフェースに使用されるいくつかの設定オプションの名前を更新し、
  [c-lightning-rest][]プラグインと競合しないようにしました。

- [Eclair #2752][]により、[オファー][topic offers]内のデータが、
  公開鍵またはチャネルの１つの識別子を使用してノードを参照できるようになります。
  公開鍵はノードを識別する一般的な方法ですが、33バイトを使用します。
  チャネルは[BOLT7][]のショートチャネルID（SCID）を使用して識別でき、この場合8バイトしか使用しません。
  チャネルは２つのノードで共有されるため、2つのノードのうちの1つを特定するための追加ビットがSCIDの先頭に付加されます。
  オファーはサイズに制限のあるメディアで使用されることが多いため、これによりスペースが大幅に節約されます。

{% include snippets/recap-ad.md when="2023-11-22 15:00" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="6857,2752,8186" %}
[bitcoin core 26.0rc2]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Release-Candidate-Testing-Guide
[core lightning 23.11rc3]: https://github.com/ElementsProject/lightning/releases/tag/v23.11rc3
[c-lightning-rest]: https://github.com/Ride-The-Lightning/c-lightning-REST
[teinturier addy]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-November/004204.html
[lnurl]: https://github.com/fiatjaf/lnurl-rfc
[lightning address]: https://lightningaddress.com/
[lnd v0.17.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.2-beta
[bitmask website]: https://bitmask.app/
[https://opcodeexplained.com/]: https://opcodeexplained.com/opcodes/
[OE tweet]: https://twitter.com/thunderB__/status/1722301073585475712
[OE github]: https://github.comc/thunderbiscuit/opcode-explained
[athena website]: https://athenabitcoin.com/
[athena tweet]: https://twitter.com/btc_penguin/status/1722008223777964375
[blixt v0.6.9]: https://github.com/hsjoberg/blixt-wallet/releases/tag/v0.6.9
[Durabit whitepaper]: https://github.com/4de67a207019fd4d855ef0a188b4519c/Durabit/blob/main/Durabit%20-%20A%20Bitcoin-native%20Incentive%20Mechanism%20for%20Data%20Distribution.pdf
[BitStream whitepaper]: https://robinlinus.com/bitstream.pdf
[bitstream github]: https://github.com/robinlinus/bitstream
[news273 bitvm]: /ja/newsletters/2023/10/18/#payments-contingent-on-arbitrary-computation
[bitvm tweet blake3]: https://twitter.com/robin_linus/status/1721969594686926935
[BLAKE3]: https://ja.wikipedia.org/wiki/BLAKE#BLAKE3
[bitvm techmix poc]: https://techmix.github.io/tapleaf-circuits/
[bitvm sha256]: https://raw.githubusercontent.com/TechMiX/tapleaf-circuits/abc38e880872150ceec08a8b67ac2fddaddd06dc/scripts/circuits/bristol_sha256.js
[bitkit website]: https://bitkit.to/
[bitkit v1.0.0-beta.86]: https://github.com/synonymdev/bitkit/releases/tag/v1.0.0-beta.86
[news53 data]: /en/newsletters/2019/07/03/#standardized-atomic-data-delivery-following-ln-payments
