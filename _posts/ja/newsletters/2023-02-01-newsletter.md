---
title: 'Bitcoin Optech Newsletter #236'
permalink: /ja/newsletters/2023/02/01/
name: 2023-02-01-newsletter-ja
slug: 2023-02-01-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、サーバーレスなPayjoinの提案と、
LNの非同期支払いで支払いの証明を可能にするアイディアについて掲載しています。
また、恒例のセクションである、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更も掲載しています。

## ニュース

- **サーバーレスPayjoinの提案:** Dan Gouldは、
  [BIP78][]の[Payjoin][topic payjoin]プロトコルのサーバーレスバージョンの提案と、
  [概念実証の実装][payjoin impl]をBitcoin-Devメーリングリストに[投稿しました][gould payjoin]。

  Payjoinを使用しない場合、通常のBitcoinの支払いは支払人のインプットのみで構成され、
  トランザクションの監視組織がトランザクションのすべてのインプットは同じウォレットに属すると仮定する
  [common input ownershipヒューリスティック][common input ownership heuristic]を採用することになります。
  Payjoinは、受取人が支払いにインプットを提供できるようにすることで、このヒューリスティックを無効にします。
  これにより、Payjoinユーザーのプライバシーを即座に向上し、
  ヒューリスティックの信頼性が低下することで、すべてのBitcoinユーザーのプライバシーが向上します。

  しかし、Payjoinは一般的なBitcoin支払いほど柔軟ではありません。
  ほとんどの支払いは、受取人がオフラインでも送信することが可能ですが、
  Payjoinでは、受取人はインプットに署名するためオンラインである必要があります。
  また、既存のPayjoinプロトコルでは、受取人が支払人がアクセス可能なネットワークアドレスでHTTPリクエストを受け付ける必要があり、
  これは受取人がPayjoin互換ソフトウェアが稼働するWebサーバーをパブリックなIPアドレスで実行することで実現されます。
  [ニュースレター #132][news132 payjoin]に掲載したように、
  Payjoinの利用を促進するための１つの提案は、一般的なエンドユーザー用ウォレット間で
  P2PベースでPayjoinを可能にすることです。

  Gouldは、Payjoin互換ウォレットに、[Noiseプロトコル][noise protocol]による暗号化のサポートと、
  [TURNプロトコル][TURN protocol]を使用して[NAT][]を通過する機能を備えた軽量なHTTPサーバーを組み込むことを提案しています。
  これにより、2つのウォレットは、Payjoinの支払いを作成するために必要な短い間だけ対話的に通信することができ、
  Webサーバーを長期間稼働させる必要がなくなります。これにより受取人がオフラインの場合はPayjoinの作成はできませんが、
  Gouldは「非同期Payjoin」を可能にするための将来の提案として[Nostrプロトコル][nostr protocol]を調査することを提案しています。

  この記事を書いている時点では、メーリングリストに、この提案に対する返信は投稿されていません。

- **LN非同期支払いの証明:**
  [先週のニュースレター][news235 async]で言及したように、LN開発者は、
  支払人が受取人に支払った証拠を提供する[非同期支払い][topic async payments]の送信方法を探しています。
  非同期支払いにより、支払人（アリス）はLN支払いを通常の転送ホップを介して受取人（ボブ）に送ることができます。
  転送ホップには、ボブが一時的にオフラインの場合に支払いを保留しておくLightning Service Provider (LSP)も含まれます。
  ボブがLSPにオンラインに戻ったことを通知すると、LSPはボブへの残りの転送を始めます。

  現在の[HTLC][topic htlc]ベースのLNにおけるこのアプローチの課題は、
  ボブがオフラインの場合、ボブが選択したシークレットを参照する支払いのインボイスをアリスに提供できないことです。
  アリスは代わりに彼女自身でシークレットを選択し、それをボブに送信する非同期支払いに含めます。
  これは[keysend][topic spontaneous payments]支払いと呼ばれますが、
  アリスはkeysendのシークレットを最初から知っているので、その知識をボブへの支払いの証拠として使うことはできません。
  別の方法として、ボブはいくつかの標準的なインボイスを事前に作成し、それをLSPに渡しておくことで、
  LSPはそれをアリスのような支払人に配布することができます。
  このようなインボイスへの支払いでは、ボブが最終的に支払いを受け入れた際に支払いの証拠が得られますが、
  LSPは同じインボイスを複数の支払人に配布することができるため、結果すべての支払人が同じシークレットに支払うことになります。
  ボブが最初の支払いを受け入れ、LSPがそのシークレットを知ると、
  LSPは再利用されたインボイスに対する残りの支払いを盗むことができるようになり、
  HTLC用に事前生成されたインボイスはボブがLSPを信頼する場合にのみ安全ということになります。

  今週、Anthony Townsは[署名アダプター][topic adaptor signatures]に基づくソリューションを[提案しました][towns async]。
  これは、LNが[PTLC][topic ptlc]を使用するようアップグレードする計画に依存しています。
  ボブは、一連の署名nonceを事前に生成し、それを彼のLSPに渡します。
  LSPはアリスに署名nonceを渡し、アリスは支払いの証拠用のメッセージ（たとえば、
  "Alice paid Bob 1000 sats at 2023-02-01 12:34:56Z"のような）を選択し、
  ボブのnonceと彼女のメッセージを使って彼女のPTLC用の署名アダプターを生成します。
  ボブがオンラインに戻ると、LSPはボブに支払いを転送し、ボブはそのnonceが以前使用されていないこと、
  メッセージに同意すること、支払いが有効であること、署名アダプターの計算が有効であることを検証し、
  支払いを受け入れます。アリスは最終的に決済されたPTLCを受け取ると、
  彼女の選択したメッセージにコミットしたボブの署名を得ることができます。

  Townsのソリューションでは、LSPがボブから事前生成されたインボイスを受け取ります。
  これは、HTLCでの安全でない/信頼型のソリューションと似ていますが、
  PTLCの署名アダプターソリューションでは、異なる支払人（アリスなど）からの各支払いは
  異なるPTLC公開鍵ポイントを使用するため、ボブはnonceの再利用を防ぐことができます。
  このため、安全でトラストレスです。各PTLCポイントは、各支払人によって選択された一意なメッセージから導出されるため、
  異なるものになります。ボブは、各支払いを受け入れる前に、
  再利用されたnonceをチェックすることでnonceの再利用を防ぐことができます。

  Townsは、彼の投稿の中で、署名アダプターを使用したLNの支払いの証明について書いた
  2つの[過去の][towns sa1]メーリングリストの投稿を[参照しています][towns sa2]。
  この記事を書いている時点では、このアイディアに対する返信はメーリングリストに投稿されていませんでした。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #26471][]は、ユーザーが`-blocksonly`モードをオンにした場合、
  デフォルトのmempool容量を（300MBから）5MBに削減します。
  未使用のmempoolのメモリはdbcacheと共有されるため、この変更により、
  `-blocksonly`モードのデフォルトのdbcacheサイズも削減されます。
  ユーザーは、`-maxmempool`オプションを使用して、より大きなmempool容量を設定することができます。

- [Bitcoin Core #23395][]は、`bitcoind`に`-shutdownnotify`設定オプションを追加し、
  `bitcoind`が通常どおりシャットダウンする際にカスタムユーザーコマンドを実行できるようにしました
  （クラッシュ時にはこのコマンドは実行されません）。

- [Eclair #2573][]は、Eclairが[ペイメント・シークレット][topic payment secrets]が必須であると通知している場合でも、
  ペイメント・シークレットを含まない[keysend][topic spontaneous payments]支払いを受け入れるようになりました。
  プリクエストの説明によると、LNDとCore Lightningはどちらもペイメント・シークレットのない
  keysend支払いを送信します。ペイメント・シークレットは、
  [マルチパス・ペイメント][topic multipath payments]をサポートするために設計されているため、
  Eclairはシングルパスのkeysend支払いのみを送信することを他のノード実装に委ねています。

- [Eclair #2574][]は、上記のPRに関連し、送信するkeysend支払いにペイメント・シークレットを含めるのを止めました。
  プルリクエストの説明によると、LNDはペイメント・シークレットを含むkeysend支払いを拒否しています。
  ただ、このような拒否はkeysendの[BLIP3][]仕様には記載されていません。

- [Eclair #2540][]は、今後[スプライシング][topic splicing]のサポートを追加するための準備として、
  Eclairがファンディング・トランザクションおよびコミットメント・トランザクションに関するデータを格納する方法に
  いくつかの変更を加えました。スプライシングの実験的なサポートを追加する現在のプルリクエストのドラフトは、
  [#2584][eclair #2584]を参照ください。

- [LND #7231][]は、`lncli`にメッセージへの署名と検証を行うためのRPCとオプションを追加しました。
  P2PKHについては、2011年にBitcoin Coreに最初に追加された`signmessage` RPCと互換性のある形式です。
  P2WPKHとP2SH-P2WPKH（よくネストされたP2PKHやNP2PKHとも呼ばれる）については、
  同じ形式が使用されます。この形式では、署名がECDSA形式であることが想定されており、
  検証では署名から公開鍵を導出する必要があります。
  P2TRアドレスについては、通常は[Schnorr署名][topic schnorr signatures]が使用されますが、
  BitcoinのSchnorr署名のアルゴリズムが使用されている場合、署名から公開鍵を導出することはできません。
  その代わり、P2TRアドレスに対してECDSA署名が生成され、検証されます。

  注: Optechは一般的に、Schnorr署名を使用することを意図した鍵をECDSA署名関数で使用しないことを[推奨しています][p4tr new hd]が、
  LND開発者は、問題を回避するために[特別な予防措置][osuntokun sigs]をとっています。

- [LDK #1878][]は、（グローバルではなく）支払い毎に`min_final_cltv_expiry`の値を設定する機能を追加しました。
  この値は、受取人が支払いの有効期限が切れるまでに支払いを請求する必要がある最大ブロック数を決定します。
  標準のデフォルト値は、18ブロックですが、[BOLT11][]インボイスにパラメーターを設定することで、
  受取人はより長い時間を要求することができます。

  LDKが[ステートレスインボイス][topic stateless invoices]の独自の実装と組み合わせてこの機能をサポートするために、
  LDKは支払人が送信することを義務付けられている[ペイメント・シークレット][topic payment secrets]に
  この値をエンコードしています。有効期限は12ビットで、最大4,096ブロック（約4週間）の有効期限を設定することができます。

- [LDK #1860][]は、[アンカー・アウトプット][topic anchor outputs]を使用するチャネルのサポートを追加しました。

{% include references.md %}
{% include linkers/issues.md v=2 issues="26471,23395,2573,2574,2584,2540,1878,1860,7231" %}
[common input ownership heuristic]: https://en.bitcoin.it/wiki/Privacy#Common-input-ownership_heuristic
[news132 payjoin]: /ja/newsletters/2021/01/20/#payjoin
[gould payjoin]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-January/021364.html
[payjoin impl]: https://github.com/chaincase-app/payjoin/pull/21
[noise protocol]: http://www.noiseprotocol.org/
[turn protocol]: https://en.wikipedia.org/wiki/Traversal_Using_Relays_around_NAT
[nat]: https://en.wikipedia.org/wiki/Network_address_translation
[nostr protocol]: https://github.com/nostr-protocol/nostr
[news235 async]: /ja/newsletters/2023/01/25/#request-for-proof-that-an-async-payment-was-accepted
[towns async]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-January/003831.html
[towns sa1]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-February/001034.html
[towns sa2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001490.html
[osuntokun sigs]: https://github.com/lightningnetwork/lnd/pull/7231#issuecomment-1407138812
[p4tr new hd]: /ja/preparing-for-taproot/#use-a-new-bip32-key-derivation-path-bip32
