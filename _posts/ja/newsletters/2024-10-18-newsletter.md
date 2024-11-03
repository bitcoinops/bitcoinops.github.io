---
title: 'Bitcoin Optech Newsletter #325'
permalink: /ja/newsletters/2024/10/18/
name: 2024-10-18-newsletter-ja
slug: 2024-10-18-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、最近のLN開発者会議で議論されたいくつかのトピックの概要を紹介します。
また、人気のあるクライアントやサービスの変更や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、恒例のセクションも含まれています。

## ニュース

- **LN Summit 2024ノート:** Olaoluwa Osuntokunは、
  最近のLN開発者会議の[メモ][osuntokun notes]の要約（追加のコメント付き）を
  Delving Bitcoinに[投稿しました][osuntokun summary]。

  - **<!--version-3-commitment-transactions-->バージョン3コミットメントトランザクション:** 開発者は、
    [TRUC][topic v3 transaction relay]トランザクションや[P2A][topic ephemeral anchors]アウトプットを含む
    [新しいP2P機能][bcc28 guide]を使用して、チャネルを一方的に閉鎖するために使用できるLNのコミットメントトランザクションの
    セキュリティを向上させる方法について議論しました。議論は、さまざまな設計上のトレードオフに焦点が当てられました。

  - **PTLC:** LNのプライバシーのアップグレードとして、
    また[スタックレストランザクション][topic redundant overpayments]のような他の目的にも有用であると
    長い間提案されてきましたが、さまざまな[PTLC][topic ptlc]実装のトレードオフに関する最近の研究が議論されました
    （[ニュースレター #268][news268 ptlc]参照）。特に焦点が当てられたのは、
    [署名アダプター][topic adaptor signatures]の構成（スクリプト化されたマルチシグを使用するか、
    スクリプトレスな[MuSig2][topic musig]を使用するかなど）と、
    それがコミットメントプロトコルに与える影響についてでした（次の項目参照）。

  - **<!--state-update-protocol-->ステート更新プロトコル:**
    LNの現在のステート更新プロトコルを、どちらの側からもいつでも更新を提案できるようにするのではなく、
    一度に一方からのみ更新を提案できるようにするという提案（ニュースレター[#120][news120 simcom]および
    [#261][news261 simcom]参照）が議論されました。どちらの側からも更新を提案できるようにすると、
    両者が同時に更新を提案する可能性があり、これは判断が難しく、偶発的なチャネルの強制閉鎖につながる可能性があります。
    代替案は、一度に一方のみが担当する方式です。たとえば、最初はアリスだけがステートの更新を提案できるようにし、
    提案がない場合は、ボブに担当を移すことができます。ボブが更新の提案を終えたら、アリスに担当を戻すことができます。
    これによりプロトコルの判断が簡単になり、同時提案の問題が解消され、
    非担当者が望まない提案を簡単に拒否できるようになります。この新しいラウンドベースのプロトコルは、
    MuSig2ベースの署名アダプターとも相性が良いでしょう。

  - **SuperScalar:** エンドユーザー向けに提案された[チャネルファクトリー][topic
    channel factories]構成の開発者が、提案のプレゼンを行い、フィードバックを募りました。
    Optechは、今後のニュースレターで[SuperScalar][zmnscpxj superscalar]の詳細な説明を公開する予定です。

  - **<!--gossip-upgrade-->ゴシップのアップグレード:** 開発者は、
    [LNのゴシッププロトコル][topic channel announcements]のアップグレードについて議論しました。
    これは、[Simple Taproot Channel][topic simple taproot channels]のような
    新しい種類のファンディングトランザクションをサポートするために最も緊急に必要なものですが、
    他の機能のサポートも追加されるかもしれません。議論された新機能の1つは、
    ファンディングトランザクション（またはスポンサートランザクション）が
    ある時点でブロックに含まれていたことを軽量クライアントが検証できるように、
    チャネルアナウンスのメッセージにSPVプルーフ（またはSPVプルーフへのコミットメント）を含められるようにすることです。

  - **<!--research-on-fundamental-delivery-limits-->基本的な送金限界に関する研究:**
    （キャパシティが十分でないチャネルなど）ネットワークの制限により成功しない支払いフローに関する調査が
    発表されました（[ニュースレター #309][news309 feasible]参照）。LN支払いが実行不可能な場合、
    送信者と受信者はオンチェーン支払いを利用することができます。しかし、
    オンチェーン支払いのレートは、最大ブロックweightで制限されるため、
    BitcoinとLNを組み合わせた最大スループット（1秒あたりの支払いの数）は、
    最大オンチェーンレートを実行不可能なLN支払いのレートで割ることで計算することができます。
    この大まかな指標を用いると、1秒あたり約47,000件の支払いという最大値を達成するには、
    実行不可能率を0.29%未満に抑える必要があります。実行不可能率を低減するために2つの手法が議論されました。
    (1) 2人よりも多くが関与する仮想または実際のチャネル。参加者が増えることで、
    転送に使用できる資金が増え、転送資金が増えると実行可能率が向上します。
    (2) 信頼関係がある参加者間で、オンチェーンでの支払いを強制することなく、
    参加者間で支払いを転送できるクレジットチャネル。他のすべてのユーザーは引き続きトラストレスに支払いを受け取ります。

  Osuntokunは、他の参加者にもこのスレッドに訂正や拡張を投稿するよう促しました。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **CoinbaseがTaprootへの送信をサポート:**
  取引所のCoinbaseは現在、Taprootの[bech32m][topic bech32]アドレスへの
  ユーザーの引き出し（送信）を[サポートしました][coinbase post]。

- **Danaウォレットのリリース:**
  [Danaウォレット][dana wallet github]は、寄付のユースケースにフォーカスした
  [サイレントペイメント][topic silent payments]ウォレットです。開発者は
  [signet][topic signet]の使用を推奨しており、signetの[Faucet][dana wallet faucet]も運営しています。

- **Kyoto BIP157/158軽量クライアントのリリース:**
  [Kyoto][kyoto github]は、ウォレット開発者が使用する
  [コンパクトブロックフィルター][topic compact block filters]を使用したRustの軽量クライアントです。

- **DLCマーケットがmainnetでローンチ:**
  [DLC][topic dlc]ベースのプラットフォームは、
  非カストディアル取引サービスがmainnetで利用可能になったことを[発表しました][dlc markets blog]。

- **Ashigaruウォレットの発表:**
  Ashigaruは、Samourai Walletプロジェクトのフォークで、
  [発表][ashigaru blog]では[バッチ処理][scaling payment batching]、[RBF][topic rbf]のサポート、
  [手数料推定][topic fee estimation]の改善が挙げられています。

- **DATUMプロトコルの発表:**
  [DATUMマイニングプロトコル][datum docs]は、Stratum v2プロトコルと同様に、
  マイナーが[プールマイニング][topic pooled mining]のセットアップの一部として、
  候補ブロックを構築することを可能にします。

- **Bark Ark実装の発表:**
  Secondチームは、[Ark][topic ark]プロトコルの実装[Bark][bark codeberg]を[発表し][bark blog]、
  mainnet上でArkトランザクションを[デモンストレーション][bark demo]しました。

- **Phoenix v2.4.0およびphoenixd v0.4.0のリリース:**
  [Phoenix v2.4.0][phoenix v2.4.0]および[phoenixd v0.4.0][]のリリースでは、
  [BLIP36][blip36]のオンザフライ・ファンディング提案および、
  その他の流動性機能（[ポッドキャスト #323][pod323 eclair]参照）のサポートが追加されました。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BDK 1.0.0-beta.5][]は、ウォレットやその他のBitcoin対応アプリケーションを構築するための
  このライブラリのリリース候補（RC）です。この最新のRCは、「RBFをデフォルトで有効にし、
  レート制限により失敗したサーバー要求を再試行するようにbdk_esploraクライアントを更新します。
  `bdk_electrum`クレートでは、use-openssl機能も提供されるようになりました。」

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #30955][]では、[Stratum V2][topic pooled mining]の要件に沿って、
  `Mining`インターフェース（ニュースレター[#310][news310 mining]参照）に2つの新しいメソッドが導入されました。
  `submitSolution()`メソッドは、ブロック全体ではなく、nonce、タイムスタンプ、
  バージョンフィールド、コインベーストランザクションのみを必要とすることで、
  マイナーがより効率的にブロックのソリューションを提出できるようにします。
  さらに、`getCoinbaseMerklePath()`が導入され、
  `NewTemplate`メッセージで要求されるマークルパスフィールドが構成されます。
  このPRではまた、[Bitcoin Core #13191][]で以前削除された`BlockMerkleBranch`も復活しました。

- [Eclair #2927][]は、推奨値よりも低い手数料率を使用する
  `open_channel2`および`splice_init`メッセージを拒否することで、
  オンザフライ・ファンディング（ニュースレター[#323][news323 fly]参照）用の
  推奨手数料率（ニュースレター[#323][news323 fees]参照）を強制します。

- [Eclair #2922][]は、[BOLTs #1160][]で提案された最新の[スプライシング][topic splicing]プロトコルに準拠するために、
  チャネル静止（ニュースレター[#309][news309 quiescence]参照）のないスプライシングのサポートを削除しました。
  最新のプロトコルでは、スプライシング中にノードが静止プロトコルを使用することが求められます。
  これまでは、スプライシングは、コミットメントが既に静止している場合にスプライシングメッセージが許可される、
  チャネル静止の簡易版として機能する非形式的な仕組みで許可されていました。

- [LDK #3235][]は、`ChannelForceClosed`イベントに、`last_local_balance_msats`フィールドを追加しました。
  このフィールドは、チャネルが強制閉鎖される直前のノードのローカル残高をミリサトシ（msats）単位で提供するもので、
  ユーザーは丸めによって失われたmsatsを知ることができます。

- [LND #8183][]は、強制閉鎖トランザクションを生成するために必要なインプットを格納するために、
  オプションの`CloseTxInputs`フィールドを[静的チャネルバックアップ][topic static channel backups]（SCB）ファイルの
  `chanbackup.Single`に追加しました。これにより、ピアがオフラインになった際に、
  最後の復旧オプションとして`chantools scbforceclose`コマンドを使用して、手動で資金を回収できるようになります。
  ただし、バックアップ作成後にチャネルが更新された場合、この機能によって資金が失われる可能性があるため、
  ユーザーは十分な注意が必要です。さらに、LNDがシャットダウンするたびにチャネルバックアップを更新する
  `ManualUpdate`メソッドが導入されました。

- [Rust Bitcoin #3450][]は、Bitcoin Coreが[TRUC（Topologically Restricted Until
  Confirmation）][topic v3 transaction relay]トランザクションを標準として受け入れたことを受け（
  ニュースレター[#307][news307 truc]参照）、トランザクションバージョンの新しいバリエーションとしてv3を追加しました。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30955,2927,2922,3235,8183,3450,13191,1160" %}
[BDK 1.0.0-beta.5]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.5
[osuntokun summary]: https://delvingbitcoin.org/t/ln-summit-2024-notes-summary-commentary/1198
[osuntokun notes]: https://docs.google.com/document/d/1erQfnZjjfRBSSwo_QWiKiCZP5UQ-MR53ZWs4zIAVcqs/edit?tab=t.0#heading=h.chk08ds793ll
[news268 ptlc]: /ja/newsletters/2023/09/13/#ptlc-ln
[news120 simcom]: /en/newsletters/2020/10/21/#simplified-htlc-negotiation
[news261 simcom]: /ja/newsletters/2023/07/26/#simplified-commitments
[zmnscpxj superscalar]: https://delvingbitcoin.org/t/superscalar-laddered-timeout-tree-structured-decker-wattenhofer-factories/1143
[news309 feasible]: /ja/newsletters/2024/06/28/#ln
[bcc28 guide]: /ja/bitcoin-core-28-wallet-integration-guide/
[coinbase post]: https://x.com/CoinbaseAssets/status/1843712761391399318
[dana wallet github]: https://github.com/cygnet3/danawallet
[dana wallet faucet]: https://silentpayments.dev/
[saving satoshi editor]: https://script.savingsatoshi.com/
[kyoto github]: https://github.com/rustaceanrob/kyoto
[dlc markets blog]: https://blog.dlcmarkets.com/dlc-markets-reshaping-bitcoin-trading/
[ashigaru blog]: https://ashigaru.rs/news/release-wallet-v1-0-0/
[datum docs]: https://ocean.xyz/docs/datum
[bark blog]: https://blog.second.tech/ark-on-bitcoin-is-here/
[bark codeberg]: https://codeberg.org/ark-bitcoin/bark
[bark demo]: https://blog.second.tech/demoing-the-first-ark-transactions-on-bitcoin-mainnet/
[phoenix v2.4.0]: https://github.com/ACINQ/phoenix/releases/tag/android-v2.4.0
[phoenixd v0.4.0]: https://github.com/ACINQ/phoenixd/releases/tag/v0.4.0
[blip36]: https://github.com/lightning/blips/pull/36
[pod323 eclair]: /en/podcast/2024/10/08/#eclair-2848-transcript
[news310 mining]:/ja/newsletters/2024/07/05/#bitcoin-core-30200
[news323 fees]: /ja/newsletters/2024/10/04/#eclair-2860
[news323 fly]: /ja/newsletters/2024/10/04/#eclair-2861
[news309 quiescence]:/ja/newsletters/2024/06/28/#bolts-869
[news307 truc]: /ja/newsletters/2024/06/14/#bitcoin-core-29496
