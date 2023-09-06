---
title: 'Bitcoin Optech Newsletter #267'
permalink: /ja/newsletters/2023/09/06/
name: 2023-09-06-newsletter-ja
slug: 2023-09-06-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、Bitcoinのトランザクションを圧縮する新しい手法と、
トランザクションの共同署名のプライバシーを強化するアイディアを掲載しています。
また、新しいリリースとリリース候補の発表や、人気のあるBitcoinインフラストラクチャソフトウェアの
注目すべき変更など恒例のセクションも含まれています。

## ニュース

- **Bitcoinトランザクションの圧縮:** Tom Briarは、
  圧縮したBitcoinトランザクションの[ドラフト仕様][compress spec]と[実装案][compress impl]を
  Bitcoin-Devメーリングリストに[投稿しました][briar compress]。
  より小さなトランザクションは、衛星やステガノグラフィー（トランザクションをビットマップ画像にエンコードするような）など、
  帯域幅に制限のある媒体を介してリレーするのにより実用的です。
  従来の圧縮アルゴリズムは、他の要素よりも頻繁に出現するいくつかの要素を持つ構造化データを利用します。
  しかし、一般的なBitcoinのトランザクションは、
  ランダムな値に見える公開鍵やハッシュダイジェストなど、均一な要素で構成されています。

    Briarの提案は、いくつかのアプローチを使ってこれに対処しています:

    - 現在整数が4バイトで表現されているトランザクションの部分（トランザクションのバージョンやOutPointのインデックス）を、
      2ビット程度の可変長整数に置き換えます。

    - 各インプット内の一様に分散した32バイトのOutPointのtxidは、
      ブロックの高さとブロック内の位置を使って、ブロックチェーンにおけるそのトランザクションの位置への参照に置き換えます。
      たとえば、`123456`と`789`は、ブロック123,456の789番目のトランザクションを示します。
      特定の高さのブロックは、ブロックチェーンの再編成によって変更される可能性があるため（参照が壊れ、トランザクションを展開できなくなります）、
      この方法は参照されるトランザクションに少なくとも100回の承認がある場合にのみ使用されます。

    - 署名と33バイトの公開鍵をwitnessに含める必要があるP2WPKHトランザクションの場合、
      公開鍵は省略され、代わりに署名から公開鍵を再構築する手法が使用されます。

    他のいくつかの手法は、典型的なトランザクションにおいて数バイトの余分なスペースを節約するために使用されます。
    この提案の一般的な欠点は、圧縮されたトランザクションをフルノードや他のソフトウェアが使用できるように変換するのに、
    通常のシリアライズされたトランザクションよりも多くのCPU、メモリおよびI/Oが必要になることです。
    つまり、高帯域幅の接続では引き続き通常のトランザクション形式を使用し、
    低帯域幅の送信のみが圧縮されたトランザクションを使用することになるでしょう。

    このアイディアについては、適度な議論が行われましたが、そのほとんどは、
    インプット毎に追加されるスペースを少しでも節約するためのアイディアについてでした。

- **<!--privacy-enhanced-co-signing-->共同署名のプライバシーの強化:** Nick Farrowは、
  [FROST][]のような[スクリプトレスな閾値署名方式][topic threshold signature]が、
  共同署名サービスを利用する人々のプライバシーをどのように向上させることができるかについて、
  Bitcoin-Devメーリングリストに[投稿しました][farrow cosign]。
  共同署名サービスの一般的なユーザーは、セキュリティのために別々に保管された複数の署名鍵を持っています。
  しかし、通常の支払いを簡単にするため、自分の一部の鍵と、
  何らかの方法でユーザーを認証した後にのみ署名する1つまたは複数のサービスプロバイダーが保持する1つまたは複数の鍵の組み合わせによって、
  アウトプットを使用することを許可しています。ユーザーは、必要であればサービスプロバイダーを迂回することもできますが、
  ほとんどの場合、サービスプロバイダーは運用を簡単にします。

    2-of-3の`OP_CHECKMULTISIG`のようなスクリプトによる閾値署名方式では、
    サービスの公開鍵は支払いに使用するアウトプットに関連付けられる必要があるため、
    どのサービスもオンチェーンデータを見ることで、署名したトランザクションを見つけることができ、
    ユーザーに関するデータを蓄積することができます。さらに悪いことに、
    現在使用されているプロトコルはすべて、
    サービスプロバイダーが署名する前にユーザーのトランザクションを直接明かしてしまうため、
    サービス側は特定のトランザクションへの署名を拒否することができます。

    Farrowが説明するように、FROSTは、アウトプットスクリプトの生成から署名、
    完全に署名されたトランザクションの公開に至るまで、プロセスのすべての段階で、
    サービスに署名済みトランザクションを隠すことができます。
    サービスが知ることができるのは、いつ署名したかと、
    ユーザーがサービスとの認証のために提供したデータだけです。

    このアイディアは、メーリングリストでいくつか議論されました。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Libsecp256k1 0.4.0][]は、Bitcoin関連の暗号操作のためのこのライブラリの最新リリースです。
  新バージョンには、ElligatorSwiftエンコーディングを実装したモジュールが含まれています。
  詳細は、プロジェクトの[変更履歴][libsecp cl]をご覧ください。

- [LND v0.17.0-beta.rc2][]は、この人気のLNノード実装の次期メジャーバージョンのリリース候補です。
  このリリースで予定されている主な実験的な新機能は、テストの恩恵を受ける可能性が高そうな、
  「Simple taproot channel」のサポートです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #28354][]は、testnetの`-acceptnonstdtxn`のデフォルト値を0に変更しました。
  この変更は、アプリケーションがmainnetのデフォルトノードで拒否される非標準トランザクションを作成するのを回避するのに役立つ可能性があります。

- [LDK #2468][]により、ユーザーはインボイスリクエストのメタデータフィールドに暗号化された`payment_id`を指定できるようになりました。
  LDKは受け取ったインボイスのメタデータをチェックし、そのIDを認識し、まだ別のインボイスで支払いをしていない場合にのみ支払いを行います。
  このPRは、[BOLT12][topic offers]の実装に向けた[LDKの作業][ldk bolt12]の一部です。

{% include references.md %}
{% include linkers/issues.md v=2 issues="28354,2468" %}
[LND v0.17.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc2
[briar compress]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021924.html
[compress spec]: https://github.com/TomBriar/bitcoin/blob/2023-05--tx-compression/doc/compressed_transactions.md
[compress impl]: https://github.com/TomBriar/bitcoin/pull/3
[farrow cosign]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021917.html
[frost]: https://eprint.iacr.org/2020/852
[libsecp cl]: https://github.com/bitcoin-core/secp256k1/blob/master/CHANGELOG.md
[libsecp256k1 0.4.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.4.0
[ldk bolt12]: https://github.com/lightningdevkit/rust-lightning/issues/1970
