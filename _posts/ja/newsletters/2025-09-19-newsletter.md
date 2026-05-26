---
title: 'Bitcoin Optech Newsletter #372'
permalink: /ja/newsletters/2025/09/19/
name: 2025-09-19-newsletter-ja
slug: 2025-09-19-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LNの冗長的な過払いを強化するための提案と、
フルノードに対する潜在的な分断攻撃に関する議論のリンクを掲載しています。また、
サービスとクライアントソフトウェアの最近のアップデートや、
人気のBitcoinインフラストラクチャソフトウェアの注目すべき更新など、
恒例のセクションも含まれています。

## ニュース

- **LSPが資金提供する冗長的な過払い:** 開発者のZmnSCPxjは、
  LSPが[冗長的な過払い][topic redundant overpayments]に必要な追加資金（流動性）を提供できるようにする提案を
  Delving Bitcoinに[投稿しました][zmnscpxj lspstuck]。冗長的な過払いの元々の提案では、
  アリスがゼッドに支払う際に、複数の経路を使って複数の支払いを送信し、
  ゼッドはその内1つの支払いのみを請求できるようにします。残りの支払いはアリスに返金されます。
  このアプローチの利点は、他の支払いの試行がネットワークを通過中であっても、
  ゼッドへの支払いの試行が1つでも到着すれば成功できることで、LN上での支払い速度が向上することです。

  このアプローチの欠点は、アリスが冗長的な支払いをするための追加資本（流動性）を持っている必要があること、
  冗長的な過払いが完了するまでアリスはオンラインであり続ける必要があること、
  そしてスタックした支払いがある場合、その支払いの試行がタイムアウトするまで（一般的な設定では最大2週間）
  アリスがそのお金を使用できなくなることです。

  ZmnSCPxjの提案では、アリスは実際の支払額（手数料を含む）のみを支払い、
  LSP（Lightning service provider）が冗長な支払いの送信に必要な流動性を提供します。
  これにより、アリスは一時的にも、タイムアウトまでも追加の流動性を確保することなく、
  冗長的な過払いによるスピードメリットを得られます。また、
  LSPはアリスがオフラインの場合でも支払いを確定できるため、
  アリスの接続状態が悪くても支払いを完了できます。

  この新しい提案の欠点は、アリスがLSPに対してある程度のプライバシーを失うこと、
  そして冗長的な過払いのサポートに加えて、LNプロトコルに複数の変更が必要になることです。

- **BGPインターセプションを使用した分断とエクリプス攻撃:** 開発者のcedarcticは、
  BGP（Border Gateway Protocol）の欠陥を利用してフルノードがピアに接続できないようにする方法について
  Delving Bitcoinに[投稿しました][cedarctic bgp]。これはネットワークの分断や
  [エクリプス攻撃][topic eclipse attacks]の実行に使用される可能性があります。
  cedarcticによっていくつかの緩和策が説明され、議論に参加した他の開発者たちも
  他の緩和策や攻撃の使用を監視する方法について議論しました。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **<!--zero-knowledge-proof-of-reserve-tool-->準備金のゼロ知識証明ツール:**
  [Zkpoor][zkpoor github]は、所有者のアドレスやUTXOを明かすことなく、
  STARK証明を使用して[準備金の証明（Proof of Reserves）][topic proof of reserves]を生成します。

- **<!--alternative-submarine-swap-protocol-proof-of-concept-->代替サブマリンスワッププロトコルの概念実証:**
  [Papa Swap][papa swap github]プロトコルの概念実証は、
  2つのトランザクションではなく1つのトランザクションで[サブマリンスワップ][topic submarine swaps]機能を実現します。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 30.0rc1][]は、この完全な検証ノードソフトウェアの次期メジャーバージョンのリリース候補です。

- [BDK Chain 0.23.2][]は、ウォレットアプリケーションを構築するためのこのライブラリのリリースで、
  競合トランザクション処理の改善や、[BIP158][]のフィルタリング機能を強化するための`FilterIter` APIの再設計、
  アンカーとブロックの再編成管理の改善が導入されています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #33268][]は、トランザクションインプットの合計が0 satを超える必要があるという要件を削除することで、
  トランザクションがユーザーのウォレットの一部として認識される方法を変更します。
  トランザクションがウォレットから少なくとも1つのアウトプットを使用する限り、
  そのトランザクションはウォレットの一部として認識されます。これにより、
  [P2Aエフェメラルアンカー][topic ephemeral anchors]の使用など、
  ゼロ値のインプットを持つトランザクションがユーザーのトランザクションリストに表示されるようになります。

- [Eclair #3157][]は、再接続時にリモートコミットメントトランザクションに署名してブロードキャストする方法を更新します。
  以前署名されたコミットメントを再送信する代わりに、`channel_reestablish`で取得した最新のナンスで再署名します。
  [Simple Taproot Channel][topic simple taproot channels]で、決定論的ナンスを使用しないピアは、
  再接続時に新しいナンスを持つことになり、以前のコミットメントの署名を無効にします。

- [LND #9975][]は、[BOLTs #1276][]で追加されたテストベクターに従って、
  [BOLT11][]インボイスに[P2TR][topic taproot]フォールバックオンチェーンアドレスのサポートを追加します。
  BOLT11インボイスには、オプションの`f`フィールドがあり、
  LN経由で支払いが完了できない場合にフォールバック用のオンチェーンアドレスを含めることができます。

- [LND #9677][]は、`PendingChannels` RPCコマンドで返される`PendingChannel`応答メッセージに、
  `ConfirmationsUntilActive`と`ConfirmationHeight`フィールドを追加します。
  これらのフィールドは、チャネルのアクティベーションに必要な承認回数と、
  ファンディングトランザクションが承認されたブロック高をユーザーに通知します。

- [LDK #4045][]は、LSPノードによる[非同期支払い][topic async payments]の受信を実装します。
  これは、頻繁にオフラインになる受信者に代わって着信[HTLC][topic htlc]を受け入れ、保持し、
  後でシグナルが通知された際に受信者にリリースすることで実現されます。
  このPRでは、実験的な`HtlcHold`機能ビットを導入し、`UpdateAddHtlc`に新しい`hold_htlc`を追加し、
  リリースパスを定義します。

- [LDK #4049][]は、LSPノードからオンラインの受信者への[BOLT12][topic offers]インボイス要求の転送を実装します。
  受信者は新しいインボイスで返信します。受信者がオフラインの場合、
  LSPノードは[非同期支払い][topic async payments]用のサーバーサイドロジック実装で有効になった（
  ニュースレター [#363][news363 async]参照）フォールバックインボイスで返信できます。

- [BDK #1582][]は、`CheckPoint`、`LocalChain`、`ChangeSet`および`spk_client`型をジェネリックにリファクタリングし、
  ブロックハッシュに固定されていたペイロードを`T`ペイロードとして扱うようにしました。
  これにより、`bdk_electrum`はチェックポイントにブロックヘッダー全体を保存できるようになり、
  ブロックヘッダーの再ダウンロードが回避され、マークルプルーフとMTP（Median Time Past）がキャッシュできるようになります。

- [BDK #2000][]は、リファクタリングされた`FilterIter`構造体（ニュースレター
  [#339][news339 filters]参照）にブロックの再編成処理を追加します。
  このPRでは、フローを複数のメソッドに分割するのではなく、
  すべてを`next()`関数に結びつけることでタイミングリスクを回避します。
  ブロックが古くないこと、BDKが有効なチェーン上にあることを確認するために、
  各ブロック高でチェックポイントが発行されます。`FilterIter`は、
  [BIP158][]で定義された[コンパクトブロックフィルター][topic compact block filters]を使用して、
  すべてのブロックをスキャンし、scriptPubkeyのリストに関連するトランザクションを含むブロックを取得します。

- [BDK #2028][]は、トランザクションが[RBF][topic rbf]によって置き換えられた後、
  mempoolから除外された日時を示す`last_evicted`タイムスタンプフィールドを`TxNode`構造体に追加します。
  このPRではまた、新しいフィールドに置き換わるため、
  `TxGraph::get_last_evicted`メソッド（ニュースレター[#346][news346 evicted]参照）が削除されます。

{% include snippets/recap-ad.md when="2025-09-23 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33268,3157,9975,1276,9677,4045,4049,1582,2000,2028" %}
[bitcoin core 30.0rc1]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[zkpoor github]: https://github.com/AbdelStark/zkpoor
[papa swap github]: https://github.com/supertestnet/papa-swap
[news363 async]: /ja/newsletters/2025/07/18/#ldk-3628
[news339 filters]: /ja/newsletters/2025/01/31/#bdk-1614
[news346 evicted]: /ja/newsletters/2025/03/21/#bdk-1839
[BDK Chain 0.23.2]: https://github.com/bitcoindevkit/bdk/releases/tag/chain-0.23.2
[zmnscpxj lspstuck]: https://delvingbitcoin.org/t/multichannel-and-multiptlc-towards-a-global-high-availability-cp-database-for-bitcoin-payments/1983/
[cedarctic bgp]: https://delvingbitcoin.org/t/eclipsing-bitcoin-nodes-with-bgp-interception-attacks/1965/
