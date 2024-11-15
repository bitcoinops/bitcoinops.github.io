---
title: 'Bitcoin Optech Newsletter #329'
permalink: /ja/newsletters/2024/11/15/
name: 2024-11-15-newsletter-ja
slug: 2024-11-15-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、オフチェーン支払いの新しい解決プロトコルと、
LN支払いの潜在的なIP層の追跡と検閲に関する論文のリンクを掲載しています。また、
新しいリリースとリリース候補の発表や（BTCPay Serverのセキュリティ上の重要な更新を含む）、
人気のBitcoinインフラストラクチャソフトウェアの注目すべき変更の説明も含まれています。

## ニュース

- **MADベースのオフチェーン支払いの解決（OPR）プロトコル:**
  John Lawは、参加者双方が資金を債権に拠出することを要求するマイクロペイメントプロトコルの説明を
  Delving Bitcoinに[投稿しました][law opr]。この債権は、どちらの参加者によっても
  いつでも事実上破壊することができます。これにより両者に、相手をなだめるか、
  債権の相互確証破壊（MAD）のリスクを負うかのインセンティブが生まれます。

  これは、プロトコル違反が起きた場合に、その責任のある参加者のみが資金を失うという
  _トラストレスプロトコル_ との理想とは異なります。ただし、実際には、
  LNなどに導入されたトラストレスプロトコルでは、違反により資金を回収するために、
  プロトコルに準拠している参加者がオンチェーン手数料を支払う必要があることがよくあります。
  Lawはこの事実を利用して、MADベースのプロトコルの利点をいくつか主張しています:

  - 資金が破棄された場合、トラストレスなコントラクトの強制よりもブロックチェーンのスペースがはるかに少なく、
    スケーラビリティが向上します。

  - グローバルなコンセンサスではなく、取引相手との宥和に基づいているため、
    すくなくとも数ブロックという最小値ではなく、ほんの一瞬の短い有効期限を強制できます。
    Lawは、現在LNが支払いを決済するのに最悪の場合、最大2週間を要するのに対し、
    10秒未満で支払いの解決（成功または失敗）が保証される例を挙げています。

  - 2つの取引相手間で、通信障害が長期化した場合、MADベースのプロトコルでは、
    どちらの参加者もデータをオンチェーンに展開する必要はありません（そして、
    債権の保証金の一部を失うことになるため、どちらの参加者もそのようなことをしないインセンティブが働きます）。
    [LN-Penalty][topic ln-penalty]のようなプロトコルでは、
    チャネル内の保留中の[HTLC][topic htlc]を期限までにオンチェーンで決済しなければなりません。

    Lawは、[チャネルファクトリー][topic channel factories]や[タイムアウトツリー][topic timeout trees]、
    または理想的にはネストされた部分をオフチェーンに保持する他のネスト構造内で、
    OPRをより効率的にすることができると強調しました。

  Matt Morehouseは、宥和策は論理的に盗難を遅らせることにつながると[回答しました][morehouse opr]。
  たとえば、マロリーはボブが債権の5%に相当する操作を失敗したと主張します。
  ボブは自分が失敗したかどうかの確証がなかったものの、債権の50%を失うよりはましなのでマロリーに5%を支払うことに同意します。
  マロリーはこれを繰り返します。この問題は、一般的な通信ネットワークでは障害を証明できないためさらに悪化します。
  マロリーとボブが連絡が取れなくなり、障害が発生すると、お互いに相手を責め、MADが発生する可能性があります。
  Morehouseはさらに、OPRでは債権の預託金のためにより多くのユーザー資金を確保する必要があり、
  UXが低下する可能性があると指摘しています。現在のユーザーは、チャネル残高の99%以上は使用できないようにする
  [BOLT2][]の _チャネルリザーブ_ について既に混乱しています。

  この記事の執筆時点で、議論はまだ進行中でした。

- **LN支払いのIP層の検閲に関する論文:** Charmaine Ndoloは、
  LN支払いのプライバシーの低下と検閲の可能性に関する最近の[2つ][atv revelio]の[論文][nt censor]の要約を
  Delving Bitcoinに[投稿しました][ndolo censor]。論文では、
  LNプロトコルのメッセージを含むTCP/IPパケットに関するメタデータ（パケット数やデータ総量など）により、
  それらのメッセージに含まれるペイロードの種類（新しい[HTLC][topic htlc]など）を推測することが
  比較的容易であると指摘しています。複数のノードが使用するネットワークを制御する攻撃者は、
  ノード間を移動するメッセージを観察できる可能性があります。
  攻撃者がそれらのLNノードの１つも制御している場合、送信されているメッセージに関する情報（支払い金額や
  それが[Onionメッセージ][topic onion messages]であることなど）が分かります。
  これを利用することで、一部の支払いを選択的に成功しないようにしたり、
  すぐに失敗させないようにすることで即座に再試行するのを防ぎ、
  チャネルをオンチェーンで強制的に閉鎖させる可能性があります。

  この記事の執筆時点では、返信は投稿されていませんでした。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [BTCPay Server 2.0.3][]と[1.13.7][btcpay server 1.13.7]は、
  特定のプラグインや機能のユーザーにとってセキュリティ上重要な修正を含むメンテナンスリリースです。
  詳細については、リンクのリリースノートをご覧ください。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #30592][]では、ユーザーが[フルRBF][topic rbf]を無効にしてオプトインRBFに戻すことができる
  `mempoolfullrbf`設定オプションを削除しました。フルRBFが広く採用されている現在、
  無効にするメリットがないため、このオプションは削除されました。
  フルRBFは最近デフォルトで有効になりました（ニュースレター[#315][news315 fullrbf]参照）。

- [Bitcoin Core #30930][]では、`netinfo`コマンドにピアサービス列と、
  送信接続のみを表示する`outonly`フィルターオプションが追加されました。
  新しいピアサービス列には、各ピアでサポートされているサービスのリストが表示され、
  フルブロックチェーンデータ (n)、[ブルームフィルター][topic transaction bloom filtering] (b)、
  [segwit][topic segwit] (w)、[コンパクトフィルター][topic compact block filters] (c)、
  最新288ブロックまでの限定ブロックチェーンデータ (l)、
  [バージョン2 P2Pトランスポートプロトコル][topic v2 p2p transport] (2)が含まれます。
  ヘルプテキストもいくつか更新されています。

- [LDK #3283][]では、[BIP353][]を実装し、[BLIP32][]で定義されている
  [BOLT12][][オファー][topic offers]に解決するDNSのベースの人が読めるBitcoin支払い指示への支払いのサポートが追加されました。
  新しい`pay_for_offer_from_human_readable_name`メソッドが`ChannelManager`に追加され、
  ユーザーはHRNへの支払いを直接開始できます。またこのPRでは、
  保留中の解決を処理するための`AwaitingOffer`ペイメントステートと、
  [BLIP32][]クエリを処理するための新しい`lightning-dns-resolver`クレートも導入されています。
  これに関する以前の作業については、ニュースレター[#324][news324 blip32]をご覧ください。

- [LND #7762][]は、コマンドが正常に実行されたことをより明確に示すために、
  空の応答を返す代わりに、ステータスメッセージを返すようにいくつかの`lncli` RPCコマンドを更新しました。
  影響を受けるコマンドには、`wallet releaseoutput`、`wallet accounts import-pubkey`、
  `wallet labeltx`、`sendcustom`、`connect`、`disconnect`、`stop`、`deletepayments`、
  `abandonchannel`、`restorechanbackup`、`verifychanbackup`が含まれます。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30592,30930,3283,7762" %}
[law opr]: https://delvingbitcoin.org/t/a-fast-scalable-protocol-for-resolving-lightning-payments/1233
[morehouse opr]: https://delvingbitcoin.org/t/a-fast-scalable-protocol-for-resolving-lightning-payments/1233/2
[ndolo censor]: https://delvingbitcoin.org/t/research-paper-on-ln-payment-censorship/1248
[atv revelio]: https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=10190502
[nt censor]: https://drops.dagstuhl.de/storage/00lipics/lipics-vol316-aft2024/LIPIcs.AFT.2024.12/LIPIcs.AFT.2024.12.pdf
[btcpay server 2.0.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.0.3
[btcpay server 1.13.7]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.13.7
[news315 fullrbf]: /ja/newsletters/2024/08/09/#bitcoin-core-30493
[news324 blip32]: /ja/newsletters/2024/10/11/#ldk-3179