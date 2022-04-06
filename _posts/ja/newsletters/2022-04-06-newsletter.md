---
title: 'Bitcoin Optech Newsletter #194'
permalink: /ja/newsletters/2022/04/06/
name: 2022-04-06-newsletter-ja
slug: 2022-04-06-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、リンク解除された再利用可能なアドレスの提案と、
WabiSabiプロトコルをPayjoinの拡張代替手段として使用する方法の要約、
DLCの仕様に通信標準を追加する議論の検討、
LNのコミットメント形式の更新に関する新たな議論について掲載しています。
また、新しいソフトウェアのリリースとリリース候補の概要や、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点に関する説明など、
恒例のセクションも含まれています。

## ニュース

- **<!--delinked-reusable-addresses-->リンク解除された再利用可能なアドレス:**
  Ruben SomsenはBitcoin-Devメーリングリストに、
  誰かがオンチェーンで識別されることとない公開された識別子（アドレス）への支払いを可能にするための[提案][somsen silpay]を投稿しました。
  たとえば、アリスが公開鍵の形式で識別子を作成し、それを自分のウェブサイトに掲載します。
  ボブは自分の秘密鍵の１つを使用して、アリスの公開鍵をアリスへの支払いに使用する新しいBitcoinアドレスに変換することができます。
  アリスとボブだけが、そのアドレスがアリスへの支払いであることを決定付ける情報を持っており、
  アリスだけがそのアドレスで受け取った資金を使用するのに必要な情報（彼女の秘密鍵）を持っています。
  キャロルが後からアリスのウェブサイトにアクセスし、アリスの公開識別子を再利用しても、
  キャロルはアリスへの支払いに異なるアドレスを導出します。
  ボブも他の第三者もこのアドレスがアリスのものであることを直接判断することはできません。

    [BIP47][]の再利用可能なペイメントコードや、未公開のBIP63 ステルスアドレスなど、
    リンク解除された再利用可能アドレスのこれまでの方式は、ブロックチェーンの外側で送信者と受信者が通信するか、
    通常の支払いよりも高いコストで余分なデータを含むオンチェーントランザクションに依存しています。
    これに対し、Somsenの*サイレントペイメント*の提案は、通常のトランザクションと比べて追加のオーバーヘッドがありません。

    サイレントペイメントの最も大きな欠点は、新しく受信したトランザクションをチェックするのに、
    すべての新しいブロックの全トランザクションをスキャンする必要があることです。
    これはフルノードが既に行っていることですが、この方式では多くのトランザクションの親トランザクションに関する情報も保持する必要があります。
    これは、現在の多くのフルノードでは行われていないため、追加のCPUコストに加えてかなりの追加I/O操作が必要になる可能性があります。
    バックアップからのウォレットの復元も面倒になります。
    Somsenは、負担を軽減する可能性のあるいくつかのトレードオフについて説明していますが、
    この方式が支払いを受け取りたい多くの軽量ウォレットに役立つとは考えられません。
    しかし、ほぼすべてのウォレットは、必要なリソースの明白な増加はないまま、
    わずか数行のコードでサイレントペイメントの送信のサポートを追加することができるでしょう。
    これにより、[アドレスの再利用][topic output linking]を防ぐために他の方式を使用できない、
    または使用したくないユーザーに対して、
    プライバシー保護を強化することを最も望んでいるユーザーがこの仕組みのコストを主に負担することができるかもしれません。

    Somsenは、暗号の使用に関するセキュリティ分析や、（プライバシーの利点を大幅に低下することなく）
    受信者のリソース消費を少なくするための提案など、この提案に関するフィードバックを求めています。

- **Payjoinの代替手段としてのWabiSabi:** 数週間前、Wasabiウォレットと[Coinjoin][topic coinjoin]の実装の開発者は、
  [ニュースレター #102][news102 wabisabi]で紹介したWabiSabiプロトコルをサポートする新しいバージョンをBitcoin-Devメーリングリストで[発表しました][wasabi2]。
  以前使用していたChaumian Coinjoinプロトコルでは、インプットの金額は任意だったものの、アウトプットの金額は固定でした。
  拡張されたWabiSabiプロトコルは、（最大トランザクションサイズや[dust limit][topic uneconomical outputs]の遵守など、
  他の制約の下）インプットの金額もアウトプットの金額も任意の値にすることができます。

    今週、Max Hillebrandは、
    WabiSabiプロトコルを[Payjoin][topic payjoin]プロトコルの代わりに使用する方法についての説明を[投稿しました][hillebrand wormhole]。
    標準のPayjoinでは、送信者と受信者の両方がトランザクションにインプットと受信するアウトプットを提供します。
    両者は、相手のインプットとアウトプットを知ることができますが、
    公開されたブロック上の所有権の情報では、
    Payjoinに参加するユーザーと他の複数のインプットを持つトランザクションのユーザーは混同されます。
    Hillebrandが提案するWormhole 2.0プロトコルは、WabiSabiを利用して、
    （WabiSabi Coinjoinに秘匿性を尊重する他の参加者が含まれている場合）
    支払いの送信者も受信者も互いのインプットやアウトプットを知ることができないようにします。
    これにより、さらにプライバシーが向上しますが、WabiSabiを実装したソフトウェアを使用し、
    調整されたWabiSabi Coinjoinトランザクションの発生を待つ必要があります。

- **DLCのメッセージとネットワーク** Thibaut Le Guillyは、
  異なるDLC実装間の通信の改善についてDLC-Devメーリングリストに[投稿しました][leguilly dlcmsg]。
  現在、個別の実装では、さまざまな異なる方法を使用して、他のDLCノードを見つけて通信しています。
  これらの違いは、ある実装を使用しているノードと別の実装を使用しているノードとの相互運用性を妨げています。
  Le Guillyは、DLCの標準を設けるポイントは相互運用を可能にすることにあると指摘し、
  標準に関連する詳細の追加を提案しました。

    いくつかの詳細について議論が行われました。特に、Le Guillyは、
    可能な場合、LNの仕様（BOLT）の要素の再利用を希望しています。
    このことから、最近提案されたLNチャネルのアナウンスの更新（[ニュースレター #193][news193 major update]参照）により、
    あらゆるUTXOをアンチ・フラッディングDoS対策に使用できるようになれば（LNのセットアップトランザクションのようなUTXOだけでなく）
    DLCやその他のセカンドレイヤープロトコルも同じアンチDoS保護を使用できるようになるという話が出ました。

- **LNのコミットメントの更新:** Olaoluwa Osuntokunは今週Lightning-Devメーリングリストに、
  [チャネルコミットメントフォーマットのアップグレード][topic channel commitment upgrades]、
  またコミットメントトランザクションに影響を与える他の設定のアップグレードに関する以前の提案のフォローアップを[投稿しました][osuntokun dyncom]。
  彼の以前の提案の要約については、[ニュースレター #108][news108 upcom]をご覧ください。
  その目的は、[Taproot機能][zmn post]のような新しい機能がチャネルに追加された場合でも、
  チャネルを開いたままにできるようにすることです。

    Osuntokunの提案は、[BOLTs #868][]で説明されC-Lightningで実験的に実装され、
    [ニュースレター #152][news152 cl4532]で言及された代替案とは対照的です。
    この2つの提案の顕著な違いは、
    Osuntokunの提案は新しい支払い（[HTLC][topic htlc]）が提案されている最中でもチャネルをアップグレードするのに対し、
    BOLTs #868の提案は、アップグレードが可能な静止期間を定義している点です。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 23.0 RC2][]は、この重要なフルノードソフトウェアの次のメジャーバージョンのリリース候補です。
  [リリースノートのドラフト][bcc23 rn]には、複数の改善点が記載されており、
  上級ユーザーとシステム管理者には最終リリース前の[テスト][test guide]が推奨されます。

- [LND 0.14.3-beta.rc1][]は、この人気のあるLNノードソフトウェアのいくつかのバグ修正を含むリリース候補です。

- [C-Lightning 0.11.0rc1][]は、この人気のあるLNノードソフトウェアの次のメジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #24118][]は、1つの受信アドレスの利益のためにウォレットを空にする新しいRPC`sendall`を追加しました。
  この呼び出しのオプションは、追加の受信者の指定、インプットとして使用するウォレットのUTXOプールのサブセットの指定、
  またはUTXOを残さないのではなくdustをスキップすることで受信者の金額を最大化するために使用できます。
  そのため、`sendall`は、他の`send系`RPCへの`fSubtractFeeAmount`引数の一部のアプリケーションを実現するための便利な代替手段を提供しますが、
  `fSubtractFeeAmount`は、トランザクション手数料の責任を負う受信者に支払うためのベストなオプションです。

- [Bitcoin Core #23536][]は、過去のブロックの検証を含め
  （Taprootの有効化前にv1 witnessアウトプットを使用するトランザクションを含むブロック692261を除いて）、
  Segwitが適用される時は常に、[Taproot][topic taproot]を適用する検証ルールを設定します。
  この*埋め込みデプロイ*は、P2SHおよびSegwitのソフトフォークでも行われました（[ニュースレター #60][news60 buried]参照）。
  これにより、テストとコードレビューを簡単にし、デプロイコードに潜在するバグのリスクをある程度軽減し、
  ノードがTaprootが有効になっていない最も計算がされた代替ブロックチェーンをダウンロードするような極限のシナリオに備えた
  ベルトとサスペンダーによる保護を提供します。

- [Bitcoin Core #24555][]と[Bitcoin Core #24710][]は、CJDNS[ネットワーク][topic anonymity networks]上で
  Bitcoin Coreを実行するための[ドキュメント][cjdns.md]を追加しました（[ニュースレター #175][news175 cjdns]参照）。

- [C-Lightning #5013][]は、mTLS認証でgRPCを使用してノードを管理する機能を追加しました。

- [C-Lightning #5121][]は、[BOLT11][]インボイスに短い説明文字列ではなく、
  任意のデータのハッシュを含める新しい`deschash`パラメーターで`invoice`RPCを更新しました。
  これは、BOLT11の制約を受けることなく、
  別の通信チャネルで大きな説明（画像のようなデータを含む）を送信できる[LNURL][]のような方式でサポートされています。

- [Eclair #2196][]は、無効化されたチャネルを含む、ノードのすべてのチャネルの残高をリストアップする`channelbalances`APIを追加しました。

- [LND #6263][]は、LNDのウォレットに[Taproot][topic taproot]のkeypath支払いのサポートを追加しました。
  デフォルト[signet][topic signet]を使用してテストできます。

- [Libsecp256k1 #1089][]は、`secp256k1_schnorrsig_sign()`関数の名前を`..._sign32()`に変更し、
  この関数が32バイトのメッセージ（SHA256ハッシュダイジェストなど）に署名することを明確にします。
  これは、任意の長さのメッセージに署名する`secp256k1_schnorrsig_sign_custom()`関数とは対照的です
  （追加の議論については[ニュースレター #157][news157 schnorrsig]をご覧ください）。

- [Rust Bitcoin #909][]は、特定のscript pathが使用される確率を渡すことで、
  [ハフマン符号][huffman coding]を使用して最適なTaprootのscriptpathツリーを作成するためのサポートを追加しました。

- [LDK #1388][]は、以前Bitcoin CoreとC-Lightningのウォレットで実装されていた、
  よりコンパクトにエンコードできる値を見つけることで平均よりも小さなECDSA署名を作成するためのデフォルトサポートを追加しました
  （[ニュースレター #8][news8 lowr]と[#71][news71 lowr]を参照）。
  この[Low-Rグリンディング][topic low-r grinding]により、オンチェーントランザクションにおいてLDKのピアあたり、
  およそ0.125 vbyteを節約することができます。

{% include references.md %}
{% include linkers/issues.md v=1 issues="868,24118,23536,24555,5013,5121,2196,6263,1089,909,1388,24710" %}
[bitcoin core 23.0 rc2]: https://bitcoincore.org/bin/bitcoin-core-23.0/
[bcc23 rn]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Notes-draft
[test guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Candidate-Testing-Guide
[lnd 0.14.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.3-beta.rc1
[C-Lightning 0.11.0rc1]: https://github.com/ElementsProject/lightning/releases/tag/v0.11.0rc1
[news157 schnorrsig]: /ja/newsletters/2021/07/14/#libsecp256k1-844
[news8 lowr]: /en/newsletters/2018/08/14/#bitcoin-core-wallet-to-begin-only-creating-low-r-signatures
[news71 lowr]: /ja/newsletters/2019/11/06/#c-lightning-3220
[news108 upcom]: /en/newsletters/2020/07/29/#upgrading-channel-commitment-formats
[news152 cl4532]: /ja/newsletters/2021/06/09/#c-lightning-4532
[zmn post]: /ja/newsletters/2021/09/01/#taprootの準備-11-lnとtaproot
[osuntokun dyncom]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-March/003531.html
[somsen silpay]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020180.html
[wasabi2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020032.html
[news102 wabisabi]: /en/newsletters/2020/06/17/#wabisabi-coordinated-coinjoins-with-arbitrary-output-values
[hillebrand wormhole]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020186.html
[leguilly dlcmsg]: https://mailmanlists.org/pipermail/dlc-dev/2022-March/000135.html
[news193 major update]: /ja/newsletters/2022/03/30/#major-update
[lnurl]: https://github.com/fiatjaf/lnurl-rfc
[huffman coding]: https://ja.wikipedia.org/wiki/ハフマン符号
[news60 buried]: /en/newsletters/2019/08/21/#hardcoded-previous-soft-fork-activation-blocks
[news175 cjdns]: /ja/newsletters/2021/11/17/#bitcoin-core-23077
[cjdns.md]: https://github.com/bitcoin/bitcoin/blob/6a02355ae9/doc/cjdns.md
