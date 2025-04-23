---
title: 'Bitcoin Optech Newsletter #338'
permalink: /ja/newsletters/2025/01/24/
name: 2025-01-24-newsletter-ja
slug: 2025-01-24-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、ディスクリプターで使用不可能な鍵を参照するためのBIPドラフトの発表と、
実装でPSBTv2がどのように使用されているかの調査、新しいオフチェーンDLCプロトコルについて先週の説明の訂正を掲載しています。
また、サービスやクライアントソフトウェアの変更や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの最近の変更など恒例のセクションも含まれています。

## ニュース

- **ディスクリプター内の使用不可能な鍵用のBIPドラフト:** Andrew Tothは、
  [ディスクリプター][topic descriptors]内の使用不可能なことが証明可能な鍵を参照するための
  [BIPのドラフト][bips #1746]を[Delving Bitcoin][toth unspendable delv]と
  [Bitcoin-Devメーリングリスト][toth unspendable ml]に投稿しました。
  これは以前の議論に続くものです（[ニュースレター #283][news283 unspendable]参照）。
  NUMS（_nothing up my sleeve_）ポイントとも呼ばれる、使用できないことが証明可能な鍵を用いるのは、
  特に[Taproot][topic taproot]の内部鍵と関係しています。内部鍵を使用したkeypath支払いができない場合、
  Tapleafを使用した（例：[Tapscript][topic tapscript]）scriptpath支払いのみが可能です。

  この記事の執筆時点では、BIPドラフトの[PR][bips #1746]で活発な議論が行われています。

- **PSBTv2統合テスト:** Sjors Provoostは、
  [PSBT][topic psbt]バージョン2（[ニュースレター #141][news141 psbtv2]参照）のサポートを実装したソフトウェアに関する質問を
  Bitcoin-Devメーリングリストに[投稿しました][provoost psbtv2]。これは、
  Bitcoin Coreでそれをサポートするための[PR][bitcoin core #21283]のテストのためです。
  PSBTv2を使用しているソフトウェアの最新のリストは、Bitcoin Stack
  Exchangeで[確認できます][bse psbtv2]。興味深い回答が2つありました:

  - **<!--merklized-psbtv2-->マークル化されたPSBTv2:** Salvatore Ingalaは、
    Ledger Bitcoin Appは、PSBTv2のフィールドをマークルツリーに変換し、
    そのルートのみをLedgerハードウェア署名デバイスに送信すると[説明しています][ingala psbtv2]。
    特定のフィールドが必要な場合は、適切なマークルプルーフと一緒に送信されます。
    これによりデバイスは、メモリの制約がある中、メモリ上にPSBT全体を保持することなく、
    各情報を独立して検証できます。PSBTv2では、未署名のトランザクションの各パーツが
    個別のフィールドに分離されているため、このようなことが可能です。
    元のPSBTフォーマット（v0）では、追加のパース処理が必要でした。

  - **<!--silent-payments-psbtv2-->サイレントペイメントとPSBTv2:**
    [サイレントペイメント][topic silent payments]を定義する[BIP352][]は、
    PSBTv2の[BIP370][]仕様に明示的に依存しています。Andrew Tothは、
    サイレントペイメントでは、すべての署名者がPSBTを処理するまで、
    使用するアウトプットスクリプトが分からないため、
    v2の`PSBT_OUT_SCRIPT`フィールドが必要であると[説明しています][toth psbtv2]。

- **オフチェーンDLCに関する訂正:** [先週のニュースレター][news337 dlc]でオフチェーンDLCについて説明した際、
  開発者conduitionが提案した[新しいスキーム][conduition factories]と、
  以前公開され実装されたオフチェーン[DLC][topic dlc]スキームを混同していました。
  これらには重要で興味深い違いがあります:

  - ニュースレター[<!--news-->#174][news174 channels]と[#260][news260 channels]で言及されている _DLCチャネル_
    プロトコルは、[LN-Penalty][topic ln-penalty]のコミット＆リボークに似た仕組みを使用します。
    参加者は、署名により新しい状態に _コミット_ し、古い状態がオンチェーンで公開された場合に、
    その古い状態が取引相手によって完全に使用されることになるシークレットを公開することで古い状態を _リボーク_
    します。これにより、参加者間の相互作用を通じてDLCを更新することができます。
    たとえば、アリスとボブは、以下のようなことを行います:

    1. 1ヶ月後のBTC/USD価格のDLCに直ちに合意します。

    2. 3週間後、2ヶ月のBTC/USD価格のDLCに合意し、前のDLCを取り消します。

  - 新しい _DLCファクトリー_ プロトコルは、コントラクトが満了した時点で、
    両参加者がオンチェーンで状態を公開する機能を自動的に取り消します。
    これは、コントラクトのオラクルのアテステーションがシークレットとして機能し、
    オンチェーンで公開された場合に、取引相手がプライベートな状態を完全に使用できるようにするためです。
    事実上、これは古い状態を自動的にキャンセルし、ファクトリーの開始時に、
    それ以上のやりとりをすることなく、連続したDLCに署名できるようにします。
    たとえば、アリスとボブは、以下のようなことを行います:

    1. 1ヶ月後のBTC/USD価格のDLCに直ちに合意します。

    2. また、2ヶ月後のBTC/USD価格に直ちに合意しますが、トランザクションの[タイムロック][topic timelocks]により
       1ヶ月後まで公開できません。これを3ヶ月め、4ヶ月めと繰り返すことができます。

  DLCチャネルプロトコルでは、アリスとボブは最初のコントラクトを取り消す準備ができるまで2つめのコントラクトを作成できません。
  その時点になったら、両者のやりとりが必要です。DLCファクトリープロトコルでは、
  ファクトリー作成時にすべてのコントラクトを作成でき、それ以降のやりとりは必要ありません。
  ただし、どちらの参加者も、現在安全で公開可能なバージョンをオンチェーンに移行することで、
  一連のコントラクトを中断することができます。

  ファクトリーの参加者が、コントラクトの確立後に対話可能な場合は、コントラクトを延長できますが、
  以前署名されたすべてのコントラクトが満了するまで、別のコントラクトや別のオラクルを使用することはできません（オンチェーンに移行しない限り）。
  この欠点は解消できるかもしれませんが、これは現時点では、
  お互いの取り消しによっていつでも任意のコントラクトの変更が可能なDLCチャネルプロトコルと比べて、
  対話性が低下することになるトレードオフです。

  先週のニュースレターで私たちの間違いについてお知らせいただき、
  質問に辛抱強く[答えて][conduition reply]くださったconduitionに感謝します。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Bull Bitcoin Mobile WalletにPayjoinを追加:**
  Bull Bitcoinは、[提案中の][BIPs #1483]BIP77 Payjoinバージョン2：サーバーレスPayjoin仕様で
  概説されている[Payjoin][topic payjoin]の送受信のサポートを[発表しました][bull bitcoin blog]。

- **Bitcoin Keeperがminiscriptをサポート:**
  Bitcoin Keeperは、[v1.3.0のリリース][bitcoin keeper v1.3.0]で[miniscript][topic miniscript]のサポートを
  [発表しました][bitcoin keeper twitter]。

- **NunchukがTaproot MuSig2機能を追加:**
  Nunchukは、[Taproot][topic taproot]のkeypath[マルチシグ][topic multisignature]支払いに対する
  [MuSig2][topic musig]のベータサポートと、k-of-nの[閾値][topic threshold signature]支払いを達成するために
  MuSig2 scriptpathツリーの使用を[発表しました][nunchuk blog]。

- **Jade Plus署名デバイスの発表:**
  [Jade Plus][blockstream blog]ハードウェア署名デバイスには、
  他の機能とともに、[流出防止署名機能][topic exfiltration-resistant signing]とエアギャップ機能が含まれています。

- **Coinswap v0.1.0リリース:**
  [Coinswap v0.1.0][coinswap v0.1.0]は、形式化された[Coinswap][topic coinswap]
  プロトコル[仕様][coinswap spec]に基づいて構築され、[testnet4][topic testnet]をサポートし、
  プロトコルと対話するためのコマンドラインアプリケーションを含むベータソフトウェアです。

- **Bitcoin Safe 1.0.0リリース:**
  [Bitcoin Safe][bitcoin safe website]デスクトップウォレットソフトウェアは、
  [1.0.0リリース][bitcoin safe 1.0.0]でさまざまなハードウェア署名デバイスをサポートします。

- **Bitcoin Core 28.0ポリシーのデモンストレーション:**
  Super Testnetは、Bitcoin Core 28.0リリースの[mempoolポリシー機能][28.0 guide]をデモンストレーションする
  ウェブサイト[Zero Fee Playground][zero fee website]を[発表しました][zero fee sn]。

- **Rust-payjoin 0.21.0リリース:**
  [rust-payjoin 0.21.0][rust-payjoin 0.21.0]リリースでは、
  [トランザクションカットスルー][transaction cut-through]機能（[ポッドキャスト #282][pod282 payjoin]参照）が追加されました。

- **PeerSwap v4.0rc1:**
  ライトニングチャネルの流動性ソフトウェアPeerSwapが、プロトコルのアップグレードを含む
  [v4.0rc1][peerswap v4.0rc1]を公開しました。[PeerSwap FAQ][peerswap faq]では、
  PeerSwapが[サブマリンスワップ][topic submarine swaps]や[スプライシング][topic splicing]、
  [Liquidity Ads][topic liquidity advertisements]とどう違うかが概説されています。

- **CTVを使用したJoinpoolプロトタイプ:**
  [CTVペイメントプール][ctv payment pool github]の概念実証では、
  提案中の[OP_CHECKTEMPLATEVERIFY (CTV)][topic op_checktemplateverify] opcodeを使用して
  [Joinpool][topic joinpools]を作成しています。

- **Rust joinstr ライブラリの発表:**
  実験的な[Rustライブラリ][rust joinstr github]は、joinstr [Coinjoin][topic coinjoin]プロトコルを実装しています。

- **Strataブリッジの発表:**
  [Strataブリッジ][strata blog]は、[サイドチェーン][topic sidechains]との間でビットコインを移動するための
  [BitVM2][topic acc]ベースのブリッジです。
  このインスタンスではValidity Rollupです（[ニュースレター #222][news222 validity rollups]参照）。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [BTCPay Server 2.0.6][]には、「自動ペイアウトプロセッサを使用した
  オンチェーンでの払い戻し/プル支払いを使用するマーチャントのためのセキュリティ修正」が含まれています。
  また、いくつかの新機能とバグ修正も含まれています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #31397][]は、欠落した親トランザクションを提供できる可能性のあるピアを追跡し、
  使用することで[オーファンの解決プロセス][news333 prclub]を改善します。
  これまでは、解決プロセスは、オーファントランザクションを最初に提供したピアのみに依存していました。
  ピアが応答しなかったり、`notfound`メッセージを返した場合、再試行の仕組みはなく、
  結果としてトランザクションのダウンロードに失敗する可能性が高くなっていました。
  新しいアプローチでは、帯域幅効率や検閲耐性および効率的な負荷分散を維持しながら、
  すべての候補ピアから親トランザクションをダウンロードしようとします。
  これは特に、1P1C（one-parent one-child）[パッケージリレー][topic
  package relay]にとって有益で、[BIP331][]の受信者主導の先祖パッケージリレーの舞台を整えるものです。

- [Eclair #2896][]では、将来の[Simple Taproot Channel][topic simple taproot channels]の実装の準備として、
  従来の2-of-2のマルチシグの代わりに、ピアの[MuSig2][topic musig]部分署名を保存できるようにしました。
  これを保存することで、ノードは必要な時に、コミットメントトランザクションを一方的にブロードキャストすることができます。

- [LDK #3408][]では、[BOLTs #1149][]で定義されているように
  [BOLT12][]で[非同期支払い][topic async payments]をサポートするために、
  `ChannelManager`に静的インボイスとそれに対応する[オファー][topic offers]を作成するためのユーティリティが導入されています。
  インボイスリクエストに対応するために受信者がオンラインである必要がある通常のオファー作成ユーティリティとは異なり、
  新しいユーティリティは頻繁にオフラインになる受信者に対処します。このPRでは、
  静的インボイスの支払い関して不足しているテストも追加され（ニュースレター[#321][news321 async]参照）、
  受信者がオンラインに戻った際にインボイスリクエストを取得できることが保証されます。

- [LND #9405][]では、`ProofMatureDelta`パラメーターを設定可能にしました。
  このパラメーターは、[チャネルアナウンス][topic channel announcements]がゴシップネットワークで処理されるまでに必要な
  承認数を決定するものです。デフォルト値は6です。

{% include snippets/recap-ad.md when="2025-01-28 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1746,21283,31397,2896,3408,9405,1149,1483" %}
[news337 dlc]: /ja/newsletters/2025/01/17/#dlc
[conduition factories]: https://conduition.io/scriptless/dlc-factory/
[conduition reply]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000193.html
[news174 channels]: /ja/newsletters/2021/11/10/#ln-dlc
[news260 channels]: /ja/newsletters/2023/07/19/#wallet-10101-beta-testing-pooling-funds-between-ln-and-dlcs-10101-ln-dlc
[condution reply]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000193.html
[news283 unspendable]: /ja/newsletters/2024/01/03/#how-to-specify-unspendable-keys-in-descriptors
[toth unspendable delv]: https://delvingbitcoin.org/t/unspendable-keys-in-descriptors/304/31
[toth unspendable ml]: https://mailing-list.bitcoindevs.xyz/bitcoindev/a594150d-fd61-42f5-91cd-51ea32ba2b2cn@googlegroups.com/
[news141 psbtv2]: /ja/newsletters/2021/03/24/#bips-1059
[provoost psbtv2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/6FDAD97F-7C5F-474B-9EE6-82092C9073C5@sprovoost.nl/
[bse psbtv2]: https://bitcoin.stackexchange.com/a/125393/21052
[ingala psbtv2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAMhCMoGONKFok_SuZkic+T=yoWZs5eeVxtwJL6Ei=yysvA8rrg@mail.gmail.com/
[toth psbtv2]: https://mailing-list.bitcoindevs.xyz/bitcoindev/30737859-573e-40ea-9619-1d18c2a6b0f4n@googlegroups.com/
[btcpay server 2.0.6]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.0.6
[news321 async]: /ja/newsletters/2024/09/20/#ldk-3140
[news333 prclub]: /ja/newsletters/2024/12/13/#bitcoin-core-pr-review-club
[bull bitcoin blog]: https://www.bullbitcoin.com/blog/bull-bitcoin-wallet-payjoin
[bitcoin keeper twitter]: https://x.com/bitcoinKeeper_/status/1866147392892080186
[bitcoin keeper v1.3.0]: https://github.com/bithyve/bitcoin-keeper/releases/tag/v1.3.0
[nunchuk blog]: https://nunchuk.io/blog/taproot-multisig
[blockstream blog]: https://blog.blockstream.com/introducing-the-all-new-blockstream-jade-plus-simple-enough-for-beginners-advanced-enough-for-cypherpunks/
[coinswap v0.1.0]: https://github.com/citadel-tech/coinswap/releases/tag/v0.1.0
[coinswap spec]: https://github.com/citadel-tech/Coinswap-Protocol-Specification
[bitcoin safe website]: https://bitcoin-safe.org/en/
[bitcoin safe 1.0.0]: https://github.com/andreasgriffin/bitcoin-safe
[zero fee sn]: https://stacker.news/items/805544
[zero fee website]: https://supertestnet.github.io/zero_fee_playground/
[28.0 guide]: /ja/bitcoin-core-28-wallet-integration-guide/
[rust-payjoin 0.21.0]: https://github.com/payjoin/rust-payjoin/releases/tag/payjoin-0.21.0
[transaction cut-through]: https://bitcointalk.org/index.php?topic=281848.0
[pod282 payjoin]: /en/podcast/2023/12/21/#payjoin-transcript
[peerswap v4.0rc1]: https://github.com/ElementsProject/peerswap/releases/tag/v4.0rc1
[peerswap faq]: https://github.com/ElementsProject/peerswap?tab=readme-ov-file#faq
[ctv payment pool github]: https://github.com/stutxo/op_ctv_payment_pool
[rust joinstr github]: https://github.com/pythcoiner/joinstr
[strata blog]: https://www.alpenlabs.io/blog/introducing-the-strata-bridge
[news222 validity rollups]: /ja/newsletters/2022/10/19/#validity-rollups
