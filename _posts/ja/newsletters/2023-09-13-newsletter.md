---
title: 'Bitcoin Optech Newsletter #268'
permalink: /ja/newsletters/2023/09/13/
name: 2023-09-13-newsletter-ja
slug: 2023-09-13-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターは、Taproot Assetsに関する仕様のドラフトのリンクと、
PTLCを使用可能にするのに役立つLNのいくつかの代替メッセージプロトコルの概要を掲載しています。
また、Bitcoin Core PR Review Clubミーティングの要約や、
新しいソフトウェアリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **Taproot Assetsの仕様:** Olaoluwa Osuntokunは、_Taproot Assets_ の
  [Client-Side Validationプロトコル][topic client-side validation]について、
  Bitcoin-DevメーリングリストとLightning-Devメーリングリストに個別に投稿しました。
  Bitcoin-Devメーリングリストには、7つのBIPのドラフトを[発表しました][osuntokun bips]。
  当時 _Taro_ という名称だったプロトコルの最初の発表時（[ニュースレター #195][news195 taro]参照）より１つ増えています。
  Lightning-Devメーリングリストには、
  LNを使用してTaproot Assetsを送受信するための[BLIPのドラフト][osuntokun blip]を[発表しました][osuntokun blip post]。
  このプロトコルは、LND 0.17.0-betaでリリース予定の実験的な「Simple taproot channels」の機能がベースになっています。

    その名前とは裏腹に、Taproot AssetsはBitcoinプロトコルの一部ではなく、
    コンセンサスプロトコルを一切変更しないことに注意してください。
    このプロトコルは、既存の機能を使用して、クライアントプロトコルにオプトインしたユーザーに新しい機能を提供します。

    この記事の執筆時点では、いずれの仕様もメーリングリストでは議論されていませんでした。

- **PTLCのためのLNメッセージの変更:** [P2TR][topic taproot]と[MuSig2][topic musig]を使用したチャネルを実験的にサポートする
  最初のLN実装がまもなくリリースされる予定であるため、Greg Sandersは、
  [HTLC][topic htlc]の代わりに[PTLC][topic ptlc]を使用した支払いの送信をサポートするためのLNメッセージの変更について、
  以前議論されたいくつかの異なる変更の[要約][sanders ptlc]をLightning-Devメーリングリストに[投稿しました][sanders post]。
  ほとんどのアプローチでは、メッセージの変更は大規模また侵襲的なものでもないようですが、
  ほとんどの実装では、おそらく従来のHTLCの転送を処理するためのメッセージのセットを使用し続ける一方で、
  PTLCの転送をサポートするためにアップグレードされたメッセージを提供し、
  HTLCが段階的に廃止されるまで、２つの異なるパスを同時に維持し続ける必要があります。
  メッセージが標準化される前に、一部の実装で実験的なPTLCのサポートが追加された場合、
  実装は、３つ以上の異なるプロトコルを同時にサポートする必要が生じ、すべての実装にとって不利になります。

    この記事の執筆時点では、Sanderの要約に対するコメントはありませんでした。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Transport abstraction][review club 28165]は、最近マージされたPieter Wuille (sipa)によるPRで、
_トランスポート_ の抽象化（インターフェースクラス）を導入するものです。
このクラスの具体的な具象クラスは、（ピア毎の）接続の（既にシリアライズされた）送受信メッセージをワイヤーフォーマットに変換します。
これは、より深いレベルのシリアライズとデシリアライズを実装すると考えることができます。
これらのクラスは、実際の送受信を行いません。

PRでは、`Transport`クラスから`V1Transport`（現在あるもの）と`V2Transport`（ネットワーク上で暗号化されるもの）という
２つの具象クラスを派生しています。このPRは、[BIP324][topic v2 p2p transport]
_バージョン2 P2P暗号化トランスポートプロトコル_ [プロジェクト][v2 p2p tracking pr]の一部です。

{% include functions/details-list.md
  q0="[*net*][net]と[*net_processing*][net_processing]の違いは何ですか？"
  a0="*net*は、ネットワーキングスタックの最下層にあり、ピア間の低レベルの通信を処理します。
      一方、*net_processing*は、*net*レイヤーの最上位にあり、*net*レイヤーのメッセージの処理と検証を行います。"
  a0link="https://bitcoincore.reviews/28165#l-22"

  q1="より具体的に、*net_processing*と関連付けられるクラスや関数の例、またこれに対する*net*の例は？"
  a1="*net_processing*: `PeerManager`、`ProcessMessage`。
      *net*: `CNode`、`ReceiveMsgBytes`、`CConnMan`。"
  a1link="https://bitcoincore.reviews/28165#l-25"

  q2="BIP324には*net*レイヤーの変更や*net_processing*の変更、またはその両方の変更が必要ですか？
      それは、ポリシーやコンセンサスに影響しますか？"
  a2="変更は*net*レイヤーのみであり、コンセンサスには影響しません。"
  a2link="https://bitcoincore.reviews/28165#l-37"

  q3="このPRが（偶発的な）コンセンサスの変更となる可能性がある実装バグの例にはどのようなものがありますか？"
  a3="最大メッセージサイズを4MB未満に制限するバグは、他のノードが有効とみなすブロックをノードが拒否する可能性があります。
      ブロックのデシリアライズに関するバグは、ノードがコンセンサス上有効なブロックを拒否する可能性があります。"
  a3link="https://bitcoincore.reviews/28165#l-45"

  q4="`CNetMsgMaker`と`Transport`は、どちらもメッセージをシリアライズします。これらが行うことの違いは何ですか？"
  a4="`CNetMsgMaker`は、データ構造をバイトにシリアライズします。`Transport`はこれらのバイトを受信し、
      ヘッダーを追加（シリアライズ）し、実際に送信します。"
  a4link="https://bitcoincore.reviews/28165#l-60"

  q5="`CTransactionRef`（トランザクション）のようなアプリケーションオブジェクトをバイト/ネットワークパケットに変換するプロセスでは、
      何が起こりますか？その過程でどのようなデータ構造になるのでしょうか？"
  a5="`msgMaker.Make()`が`SerializeTransaction()`を呼び出して`CTransactionRef`メッセージをシリアライズし、
      `PushMessage()`がシリアライズされたメッセージを`vSendMsg`キューに入れ、
      `SocketSendData()`がヘッダーとチェックサムを追加し（このPRの変更後）、
      送信する次のパケットをトランスポートに要求し、最後に`m_sock->Send()`を呼び出します。"
  a5link="https://bitcoincore.reviews/28165#l-83"

  q6="（簡単な例として、[Erlay][topic erlay]で使用される）`sendtxrcncl`メッセージの場合、何バイトがネットワーク上で送信されますか？"
  a6="36バイト: ヘッダーが24バイト（magicが4バイト、コマンドが12バイト、メッセージサイズが4バイト、チェックサムが4バイト）、
      そしてペイロードが12バイト（バージョンが4バイト、saltが8バイト）です。"
  a6link="https://bitcoincore.reviews/28165#l-86"

  q7="`PushMessage()`から戻った後、このメッセージに対応するバイトを既に送信されましたか（はい/いいえ/おそらく）？それは何故ですか？"
  a7="すべての可能性があります。**はいの場合**: 私たち（*net_processing*）は、メッセージを送信するために何もする必要はありません。
      **いいえの場合**: 関数から戻った時点で、受信者が受信している可能性は非常に低いです。
      **おそらくの場合**: すべてのキューが空の場合は、カーネルソケットレイヤーまで到達しているでしょうが、
      キューが空でなければ、OSに到達する前にキューが空になるのを待つことになります。"
  a7link="https://bitcoincore.reviews/28165#l-112"

  q8="どのスレッドが`CNode::vSendMsg`にアクセスしますか？"
  a8="メッセージが同期的に（楽観的に）送信っされている場合は`ThreadMessageHandler`が、
      キューに入れられ後で取得されて送信される場合は`ThreadSocketHandler`です。"
  a8link="https://bitcoincore.reviews/28165#l-120"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

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

- [Bitcoin Core #26567][]では、署名のdry-runを行う代わりに、
  [ディスクリプター][topic descriptors]から署名されたインプットのweightを推定するようウォレットを更新しました。
  このアプローチは、dry-runアプローチでは不十分であった、より複雑な[Miniscript][topic miniscript]ディスクリプターでも成功します。

{% include references.md %}
{% include linkers/issues.md v=2 issues="26567" %}
[LND v0.17.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc2
[net]: https://github.com/bitcoin/bitcoin/blob/master/src/net.h
[net_processing]: https://github.com/bitcoin/bitcoin/blob/master/src/net_processing.h
[news195 taro]: /ja/newsletters/2022/04/13/#transferable-token-scheme
[osuntokun bips]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-September/021938.html
[osuntokun blip post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004089.html
[osuntokun blip]: https://github.com/lightning/blips/pull/29
[review club 28165]: https://bitcoincore.reviews/28165
[sanders post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004088.html
[sanders ptlc]: https://gist.github.com/instagibbs/1d02d0251640c250ceea1c66665ec163
[v2 p2p tracking pr]: https://github.com/bitcoin/bitcoin/issues/27634
