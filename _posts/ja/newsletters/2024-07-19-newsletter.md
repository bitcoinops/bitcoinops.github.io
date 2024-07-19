---
title: 'Bitcoin Optech Newsletter #312'
permalink: /ja/newsletters/2024/07/19/
name: 2024-07-19-newsletter-ja
slug: 2024-07-19-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、FROSTスクリプトレス閾値署名スキーム用の分散鍵生成プロトコルと、
クラスターリニアライゼーションの包括的な紹介のリンクを掲載しています。また、
クライアントやサービスおよび人気のBitcoinインフラストラクチャプロジェクトの最近の変更など
恒例のセクションも含まれています。

## ニュース

- **FROST用の分散鍵生成プロトコル:** Tim RuffingとJonas Nickは、
  Bitcoinの[Schnorr署名][topic schnorr signatures]と互換性のある
  [FROST][]スタイルの[スクリプトレスな閾値署名][topic threshold signature]で使用する鍵を
  安全に生成するためのプロトコルであるChillDKGの[参照実装][chilldkg ref]を含む[BIPドラフト][chilldkg bip]を
  Bitcoin-Devメーリングリストに[投稿しました][ruffing nick post]。

  スクリプトレスな閾値署名は、`n`個の鍵を生成し、そのうちの任意の`t`個を使用して有効な署名を作成することができます。
  たとえば、2-of-3のスキームでは、3個の鍵が作成され、そのうちの2つを使用して有効な署名を生成することができます。
  スクリプトレスであるため、このスキームは、Bitcoinに組み込まれているスクリプト化された閾値署名演算（`OP_CHECKMULTISIG`の使用など）とは異なり、
  コンセンサスやブロックチェーンの外部の演算に完全に依存します。

  通常のBitcoinの秘密鍵の生成と同様に、スクリプトレスな閾値署名の鍵を生成する各ユーザーは、
  巨大なランダムな数値を生成し、その数値を他の人に開示してはいけません。
  ただ、各ユーザーは、その数値の導出シェアを他のユーザーに配布し、
  その鍵が利用できない場合に、閾値分の数のユーザーが署名を作成できるようにする必要があります。
  各ユーザーは、他のすべてのユーザーから受け取った情報が正しく生成されたことを検証する必要があります。
  これらの手順を実行するための鍵生成プロトコルはいくつか存在しますが、
  鍵を生成するユーザーが、個々のユーザーペア間で暗号化および認証され、
  かつ各ユーザーから他の全ユーザーへの検閲不能な認証済みブロードキャストも可能な通信チャネルにアクセスできることを前提としています。
  ChillDKGプロトコルは、FROSTのよく知られた鍵生成アルゴリズムと、追加の最新の暗号プリミティブおよび単純なアルゴリズムを組み合わせて、
  必要な安全で認証された、検閲されていないことが証明可能な通信を提供します。

  参加者間の暗号化と認証は、[楕円曲線ディフィー・ヘルマン][ecdh]（ECDH）鍵交換から始まります。
  検閲されていないことの証明は、各参加者がベースの鍵を使用して、
  セッションの開始からスクリプトレスな閾値公開鍵が生成される（セッションの終了）までの記録に署名することで得られます。
  閾値公開鍵を正しいものとして受け入れる前に、各参加者は他のすべての参加者の署名済みセッション記録を検証します。

  目標は、FROSTベースのスクリプトレスな閾値署名の鍵を生成する必要があるすべてのケースで使用できる、
  完全に汎用化されたプロトコルを提供することです。さらに、このプロトコルは、
  バックアップをシンプルに保つのに役立ちます。ユーザーに必要なのは、秘密のシードと、
  セキュリティ上重要ではない（ただしプライバシーには影響がある）リカバリーデータのみです。
  [フォローアップのメッセージ][nick follow-up]で、Jonas Nickは、
  シードから導出した鍵でリカバリーデータを暗号化するようプロトコルを拡張することを検討していると述べました。
  これにより、ユーザーが秘密にしておく必要があるデータはシードのみになります。

- **<!--introduction-to-cluster-linearization-->クラスターリニアライゼーションの導入:** Pieter Wuilleは、
  [クラスターmempool][topic cluster mempool]の基礎となる
  クラスターリニアライゼーションの主要部分のすべての詳細な説明をDelving Bitcoinに[投稿しました][wuille cluster]。
  以前のOptechのニュースレターでは、重要なコンセプトが開発され公開されるにつれてこのテーマを紹介しようとしましたが、
  この概要はとても包括的です。基本的なコンセプトから実装されている特定のアルゴリズムまで、読者に順を追って説明しています。
  最後に、クラスターmempoolの一部を実装しているいくつかのBitcoin Coreのプルリクエストのリンクが掲載されています。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **ZEUSがBOLT12オファーとBIP353をサポート:**
  [v0.8.5][zeus v0.8.5]リリースでは、[TwelveCash][twelve cash website]サービスを利用して、
  [オファー][topic offers]と[BIP353][]（[ニュースレター #307][news307 bip353]参照）をサポートします。

- **PhoenixがBOLT12オファーとBIP353をサポート:**
  [Phoenix 2.3.1][phoenix 2.3.1]リリースではオファーのサポートが、
  [Phoenix 2.3.3][phoenix 2.3.3]では[BIP353][]のサポートが追加されました。

- **Stack WalletがRBFとCPFPをサポート:**
  Stack Walletの[v2.1.1][stack wallet v2.1.1]リリースでは、
  [RBF][topic rbf]と[CPFP][topic cpfp]を使用した手数料の引き上げと、[Tor][topic anonymity
  networks]のサポートが追加されました。

- **BlueWalletがサイレントペイメントへの送信をサポート:**
  BlueWalletは、[v6.6.7][bluewallet v6.6.7]リリースで、
  [サイレントペイメント][topic silent payments]アドレスへ送信する機能が追加されました。

- **BOLT12 Playgroundの発表:**
  Strikeは、BOLT12オファーのテスト環境を[発表しました][strike bolt12 playground]。
  このプロジェクトはDockerを使用して、さまざまなLN実装間でウォレット、チャネル、支払いを自動化します。

- **Moosigテストリポジトリの発表:**
  Ledgerは、[MuSig2][topic musig]と[BIP388][]ウォレット[ポリシーをディスクリプターウォレットで][news302 bip388]使用するための
  Pythonベースのテスト[リポジトリ][moosig github]を公開しました。

- **リアルタイムStratum可視化ツールのリリース:**
  [stratum.workウェブサイト][stratum.work]は、[以前の研究を基に][b10c nostr]、
  さまざまなBitcoinマイングプールからのStratumメッセージをリアルタイムで表示するもので、
  [ソースコードも公開されています][stratum work github]。

- **BMM 100 Mini Minerの発表:**
  Braiinsの[マイニングハードウェア][braiins mini miner]は、
  デフォルトで[Stratum V2][topic pooled mining]の機能のサブセットが有効になっています。

- **ColdcardがURLベースのトランザクションブロードキャスト仕様を公開:**
  この[プロトコル][pushtx spec]により、HTTP GETリクエストを使用したBitcoinトランザクションのブロードキャストを可能にし、
  NFCベースのハードウェア署名デバイスなどで使用できます。

## 注目すべきコードとドキュメントの変更

_今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #26596][]では、レガシーウォレットを[ディスクリプター][topic descriptors]ウォレットに移行するために
  新しい読み取り専用のレガシーデータベースを使用します。この変更によって、レガシーウォレットや
  従来の`BerkeleyDatabase`が廃止されることはありません。
  移行のためにレガシーウォレットをロードするのに必要な必須データと関数のみを含む新しい`LegacyDataSPKM`クラスが作成されました。
  `BerkeleyRODatabase`の導入については、ニュースレター[#305][news305 bdb]をご覧ください。

- [Core Lightning #7455][]は、`short_channel_id`（SCID）と`node_id`の両方による転送を実装することで、
  `connectd`の[Onionメッセージ][topic onion messages]の処理を強化しました（LDKに対する同様の変更については、
  [ニュースレター #307][news307 ldk3080]をご覧ください）。
  Onionメッセージは、常に有効になり、受信メッセージは1秒あたり4件に制限されます。

- [Eclair #2878][]では、[ルートブラインド][topic rv routing]機能とチャネル静止機能がオプションになりました。
  これは、これらの機能が完全に実装され、BOLT仕様の一部となったためです（ニュースレター[#245][news245 blind]および[#309][news309 stfu]参照）。
  Eclairノードは、これらの機能のサポートをピアに通知しますが、
  [トランポリンルーティング][topic trampoline payments]を使用しない[ブラインドペイメント][topic rv routing]を転送しないため、
  `route_blinding`はデフォルトでは無効になっています。

- [Rust Bitcoin #2646][]では、スクリプトおよびwitnessの構造に対する新しいインスペクターがいくつか導入されました。
  P2SHの使用に関する[BIP16][]のルールへの準拠を確認する`redeem_script`や、
  [BIP341][]ルールへの準拠を確認するための`taproot_control_block`および`taproot_annex`、
  P2WSHのwitness scriptが[BIP141][]ルールに準拠していることを確認するための`witness_script`などです。
  ニュースレター[#309][news309 p2sh]をご覧ください。

- [BDK #1489][]では、SPV（Simplified Payment Verification）に対してマークルプルーフを使用するよう`bdk_electrum`が更新されました。
  トランザクションと共にマークルプルーフとブロックヘッダーを取得し、
  アンカーを挿入する前にトランザクションが承認済みのブロック内にあることを検証し、
  `full_scan`から再編成の処理を削除します。このPRではまた、
  以前の型に代わる新しいアンカー型として`ConfirmationBlockTime`が導入されています。

- [BIPs #1599][]では、JoinMarketスタイルの[Coinjoin][topic coinjoin]のマーケットマッチングで使用する[Fidelity
  bond][news161 fidelity]に使用される[タイムロックされた][topic timelocks]アドレスを作成する
  HDウォレットの導出スキームのための[BIP46][]を追加しました。Fidelity bondは、ビットコインをタイムロックすることで
  メイカーが意図的に資金の時間的価値を犠牲にしていることを証明するレピュテーションシステムを作成し、プロトコルのシビル耐性を向上させます。

- [BOLTs #1173][]は、失敗の[Onionメッセージ][topic onion messages]内の`channel_update`フィールドをオプションにしました。
  ノードは、[HTLC][topic htlc]送信者の識別を防止するために、現在の支払い以外ではこのフィールドを無視するようになりました。
  この変更は、古いゴシップデータを持つノードが必要に応じて更新の恩恵を受けられるようにしつつ、
  古いチャネルパラメーターによる支払いの遅延を抑制することを目的としています。

- [BLIPs #25][]は、エンコードされたOnionの値よりも低い金額を支払うHTLCの転送を許可する方法を定義する[BLIP25][]を追加しました。
  たとえば、アリスはボブにライトニングインボイスを提供しますが、ペイメントチャネルを持っていないため、
  ボブが支払う際、（アリスのLSPである）キャロルがその場でチャネルを作成します。
  [JITチャネル][topic jit channels]を作成する最初のオンチェーン手数料のコストをカバーするのに、
  キャロルがアリスから手数料を取れるようにするためにこのプロトコルが使用され、
  アリスにはOnionの値よりも少ない金額を支払うHTLCが転送されます。LDKでのこの実装に関する以前の議論については、
  [ニュースレター #257][news257 jit htlc]をご覧ください。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="26596,7455,2878,2646,1489,1599,1173,25" %}
[ruffing nick post]: https://mailing-list.bitcoindevs.xyz/bitcoindev/8768422323203aa3a8b280940abd776526fab12e.camel@timruffing.de/T/#u
[chilldkg bip]: https://github.com/BlockstreamResearch/bip-frost-dkg
[chilldkg ref]: https://github.com/BlockstreamResearch/bip-frost-dkg/tree/master/python/chilldkg_ref
[nick follow-up]: https://groups.google.com/g/bitcoindev/c/HE3HSnGTpoQ/m/DC90IMZiBgAJ
[wuille cluster]: https://delvingbitcoin.org/t/introduction-to-cluster-linearization/1032
[frost]: https://eprint.iacr.org/2020/852.pdf
[ecdh]: https://ja.wikipedia.org/wiki/楕円曲線ディフィー・ヘルマン鍵共有
[zeus v0.8.5]: https://github.com/ZeusLN/zeus/releases/tag/v0.8.5
[twelve cash website]: https://twelve.cash/
[news307 bip353]: /ja/newsletters/2024/06/14/#bips-1551
[phoenix 2.3.1]: https://github.com/ACINQ/phoenix/releases/tag/android-v2.3.1
[phoenix 2.3.3]: https://github.com/ACINQ/phoenix/releases/tag/android-v2.3.3
[stack wallet v2.1.1]: https://github.com/cypherstack/stack_wallet/releases/tag/build_235
[bluewallet v6.6.7]: https://github.com/BlueWallet/BlueWallet/releases/tag/v6.6.7
[strike bolt12 playground]: https://strike.me/blog/bolt12-playground/
[moosig github]: https://github.com/LedgerHQ/moosig
[news302 bip388]: /ja/newsletters/2024/05/15/#bips-1389
[stratum.work]: https://stratum.work/
[stratum work github]: https://github.com/bboerst/stratum-work
[b10c nostr]: https://primal.net/e/note1qckcs4y67eyaawad96j7mxevucgygsfwxg42cvlrs22mxptrg05qtv0jz3
[braiins mini miner]: https://braiins.com/hardware/bmm-100-mini-miner
[pushtx spec]: https://pushtx.org/#url-protocol-spec
[news305 bdb]: /ja/newsletters/2024/05/31/#bitcoin-core-26606
[news309 p2sh]: /ja/newsletters/2024/06/28/#rust-bitcoin-2794
[news161 fidelity]: /ja/newsletters/2021/08/11/#implementation-of-fidelity-bonds-fidelity-bond
[news257 jit htlc]: /ja/newsletters/2023/06/28/#ldk-2319
[news307 ldk3080]: /ja/newsletters/2024/06/14/#ldk-3080
[news245 blind]: /ja/newsletters/2023/04/05/#bolts-765
[news309 stfu]: /ja/newsletters/2024/06/28/#bolts-869
