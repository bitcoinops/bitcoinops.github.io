---
title: 'Bitcoin Optech Newsletter #323'
permalink: /ja/newsletters/2024/10/04/
name: 2024-10-04-newsletter-ja
slug: 2024-10-04-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、計画されているセキュリティの開示についてのお知らせとともに、
新しいリリースおよびリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションが含まれています。

## ニュース

- **差し迫ったbtcdのセキュリティ開示:** Antoine Poinsotは、
  btcdフルノードに影響するコンセンサスバグが10月10日に開示される予定でることを
  Delving Bitcoinに[投稿しました][poinsot btcd]。
  アクティブなフルノードの大まかな調査データから、Poinsotは約36のbtcdノードが脆弱であると推測しています（
  ただ、これらのノードのうち20は、既に開示済みのコンセンサスの脆弱性に対しても脆弱です。
  [ニュースレター #286][news286 btcd vuln]参照）。
  [返信][osuntokun btcd]で、btcdのメンテナーであるOlaoluwa Osuntokunは、
  脆弱性の存在とそれがbtcdのバージョン0.24.2で修正されたことを確認しました。
  旧バージョンのbtcdを実行している場合は、セキュリティ上重要と既に発表されている
  [最新リリース][btcd v0.24.2]にアップグレードすることをお勧めします。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 28.0][]は、主要なフルノード実装の最新のメジャーリリースです。
  これは、[testnet4][topic testnet]、1p1c（Opportunistic one-parent-one-child）[パッケージリレー][topic package relay]、
  オプトインの[TRUC][topic v3 transaction relay]（Topologically Restricted Until Confirmation）トランザクションのデフォルトリレー、
  [pay-to-anchor][topic ephemeral anchors]トランザクションのデフォルトリレー、
  限定パッケージ[RBF][topic rbf]リレーおよび[フルRBF][topic rbf]のデフォルトサポートを含む最初のリリースです。
  [assumeUTXO][topic assumeutxo]のデフォルトパラメーターが追加され、
  Bitcoinネットワークの外部（torrent経由など）からダウンロードしたUTXOセットを`loadtxoutset`
  RPCで使用できるようになりました。[リリースノート][bcc 28.0 rn]に記載されているように、
  このリリースには多くの他の改善やバグ修正も含まれています。

- [BDK 1.0.0-beta.5][]は、ウォレットやその他のBitcoin対応アプリケーションを構築するためのこのライブラリのリリース候補（RC）です。
  この最新のRCは、「RBFをデフォルトで有効にし、レート制限により失敗したサーバー要求を再試行するようにbdk_esploraクライアントを更新します。
  `bdk_electrum`クレートでは、use-openssl機能も提供されるようになりました。」

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #30043][]は、IPv6ピンホールをサポートするために、
  [ポート制御プロトコル（PCP）][rfcpcp]の組み込み実装を導入し、
  ルータ上で手動設定しなくてもノードに到達できるようにします。
  この更新では、IPv4ポートマッピングのための既存の`libnatpmp`依存関係がPCPに置き換えられ、
  [NATポートマッピングプロトコル（NAT-PMP）][rfcnatpmp]へのフォールバックの仕組みも実装されています。
  PCP / NAT-PMP機能はデフォルトで無効になっていますが、今後のリリースで変更される可能性があります。
  ニュースレター[#131][news131 natpmp]をご覧ください。

- [Bitcoin Core #30510][]は、`Mining`インターフェース（ニュースレター[#310][news310 stratumv2]参照）に
  プロセス間通信（IPC）ラッパーを追加し、別の[Stratum v2][topic pooled mining]マイニングプロセスが、
  `bitcoin-node`プロセス（ニュースレター[#320][news320 stratumv2]参照）に接続して制御することで、
  ブロックテンプレートを作成、管理、送信できるようにします。[Bitcoin Core #30409][]は、
  新しいブロックが到着した際にそれを検出し、接続されたクライアントに新しいブロックテンプレートをプッシュする
  新しい`waitTipChanged()`メソッドで`Mining`インターフェースを拡張します。
  `waitfornewblock`、`waitforblock`、`waitforblockheight`のRPCメソッドは、
  これを使用するようにリファクタリングされました。

- [Core Lightning #7644][]は、`hsmtool`ユーティリティに`nodeid`コマンドを追加します。
  このコマンドは、特定の`hsm_secret`バックアップファイルのノード識別子を返し、
  バックアップを特定のノードに一致させ、他のノードとの混同を回避します。

- [Eclair #2848][]は、提案中の[BOLTs #1153][]で定義されている拡張可能な[Liquidity Ads][topic
  liquidity advertisements]を実装します。これにより、流動性の販売者は、
  `node_announcement`メッセージで購入者に流動性を販売するレートを広告でき、
  購入者は接続して流動性を要求できます。これは、[デュアルファンドチャネル][topic dual funding]を作成する際、
  または[スプライシング][topic splicing]を介して既存のチャネルに流動性を追加する際に使用することができます。

- [Eclair #2860][]は、ノードがピアにファンディングトランザクションに使用する許容可能な手数料率を通知するための
  オプションの`recommended_feerates`メッセージを追加します。ノードがピアのファンディング要求を拒否した場合、
  ピアはこれが手数料率によるものであることを理解します。

- [Eclair #2861][]は、[BLIPs #36][]で定義されているオンザフライ・ファンディングを実装し、
  十分な流動性のないクライアントが、[Liquidity Ads][topic liquidity advertisements]プロトコル（上記PR参照）を介して
  ピアに追加の流動性を要求して支払いを受け取ることを可能にします。流動性の購入者は、
  [デュアルファンドチャネル][topic dual funding]または[スプライシング][topic splicing]トランザクションの
  オンチェーントランザクション手数料を負担しますが、これは後で支払いがルーティングされた際に購入者が支払います。
  金額がトランザクションの承認に必要なオンチェーン手数料をカバーするのに十分でない場合、
  販売者はそれを二重使用して、流動性を他の場所で使用できます。

- [Eclair #2875][]は、[BLIPs #41][]で定義されているファンディング手数料クレジットを実装し、
  オンザフライ・ファンディング（上記のPRを参照）クライアントが、
  チャネルのオンチェーン手数料をカバーするには少なすぎる支払いを受け入れられるようにします。
  十分な手数料クレジットが貯まると、その手数料クレジットを使用して
  チャネルファンディングや[スプライシング][topic splicing]などのオンチェーントランザクションが作成されます。
  クライアントは、流動性プロバイダーが将来の取引で手数料クレジットを保証することを期待します。

- [LDK #3303][]は、インバウンド支払い用の新しい`PaymentId`を追加し、冪等性のあるイベント処理を改善します。
  これによりユーザーは、ノードの再起動中にイベントを再生する際に、イベントが既に処理されているかどうかを簡単に確認できます。
  `PaymentHash`に依存していた場合に発生する可能性のある重複処理のリスクが排除されます。
  `PaymentId`は、支払いに含まれる[HTLC][topic htlc]チャネル識別子とHTLC識別子のペアの
  ハッシュベースのメッセージ認証符号（HMAC）です。

- [BDK #1616][]は、`TxBuilder`クラスでデフォルトでオプトイン[RBF][topic rbf]を通知します。
  呼び出し元は、シーケンス番号を変更することで通知を無効にできます。

- [BIPs #1600][]は、（乱数の読み取りを担当する）`drng_reader.read`が評価ではなく第一級関数であることを指定するなど、
  [BIP85][]仕様にいくつかの変更を加えています。この更新では、エンディアン処理の明確化や、
  [testnet][topic testnet]のサポート、Pythonの新しい参照実装、
  [HDウォレット][topic bip32]シードウォレットインポートフォーマット（WIF）が最上位bitを使用することの明確化、
  ポルトガル語の言語コードの追加、テストベクトルの修正も行われています。
  最後に、BIP仕様の新しい代表者が指名されました。

- [BOLTs #798][]は、[BOLT12][]を導入する[オファー][topic offers]プロトコル仕様をマージし、
  [BOLT1][]と[BOLT4][]にもいくつかの更新を行っています。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30043,30510,7644,2875,2861,2860,2848,3303,1616,1600,798,30409,1153,36,41" %}
[BDK 1.0.0-beta.5]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.5
[bitcoin core 28.0]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[poinsot btcd]: https://delvingbitcoin.org/t/non-disclosure-of-a-consensus-bug-in-btcd/1177
[osuntokun btcd]: https://delvingbitcoin.org/t/non-disclosure-of-a-consensus-bug-in-btcd/1177/3
[news286 btcd vuln]: /ja/newsletters/2024/01/24/#btcd
[btcd v0.24.2]: https://github.com/btcsuite/btcd/releases/tag/v0.24.2
[bcc 28.0 rn]: https://github.com/bitcoin/bitcoin/blob/5de225f5c145368f70cb5f870933bcf9df6b92c8/doc/release-notes.md
[rfcpcp]: https://datatracker.ietf.org/doc/html/rfc6887
[rfcnatpmp]: https://datatracker.ietf.org/doc/html/rfc6886
[news131 natpmp]: /ja/newsletters/2021/01/13/#bitcoin-core-18077
[news310 stratumv2]: /ja/newsletters/2024/07/05/#bitcoin-core-30200
[news320 stratumv2]: /ja/newsletters/2024/09/13/#bitcoin-core-30509
