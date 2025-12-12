---
title: 'Bitcoin Optech Newsletter #384'
permalink: /ja/newsletters/2025/12/12/
name: 2025-12-12-newsletter-ja
slug: 2025-12-12-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LNDの脆弱性の開示と、
組み込みセキュアエレメント内で仮想マシンを実行するプロジェクトについて掲載しています。
また、サービスとクライアントソフトウェアの更新や、Bitcoin Stack Exchangeで人気の質問とその回答、
人気のBitcoin基盤ソフトウェアの更新など、恒例のセクションも含まれています。

## ニュース

- **LND 0.19.0で修正された重大な脆弱性:** Matt Morehouseは、
  LND 0.19.0で修正された重大な脆弱性についてDelving Bitcoinに[投稿しました][morehouse delving]。
  この開示情報では、１件のサービス拒否（DoS）と２件の資金摂取の脆弱性について言及されています。

  - *メッセージ処理におけるメモリ不足によるDoS脆弱性:* この[DoS脆弱性][lnd vln1]は、
    LNDが利用可能なファイルディスクリプタの数だけピア接続を許可していたことを悪用したものです。
    攻撃者は被害者に対して複数の接続を開き、接続を維持したまま64KBの
    `query_short_channel_ids`メッセージをスパム送信し、LNDがメモリ不足になるまで続けることができました。
    この脆弱性の緩和策は、2025年3月12日にLND 0.19.0で実装されました。

  - *<!--loss-of-funds-due-to-new-excessive-failback-vulnerability-->新たな過剰フェイルバック脆弱性による資金喪失:*
    [この攻撃][lnd vln2]は、[過剰フェイルバックバグ][morehouse failback bug]の変種で、
    フェイルバックバグの元の修正はLND 0.18.0で行われましたが、
    攻撃者のではなくLNDのコミットメントを使用してチャネルが強制閉鎖された場合のマイナーな変種が残っていました。
    この脆弱性の緩和策は、2025年3月20日にLND 0.19.0で実装されました。

  - *HTLCスイープにおける資金喪失の脆弱性:* この[資金摂取の脆弱性][lnd vln3]は、
    LNDのスイーパーシステムの弱点を悪用したもので、
    攻撃者はLNDがオンチェーンで期限切れのHTLCを請求する試みを遅らせることができました。
    80ブロック遅らせた後、攻撃者は実質的にチャネル残高すべてを盗むことができました。

  Morehouseは、サービス拒否や資金の喪失を避けるため、
  ユーザーに対し[LND 0.19.0][lnd version]以上にアップグレードするよう呼びかけています。

- **<!--a-virtualized-secure-enclave-for-hardware-signing-devices-->ハードウェア署名デバイス向けの仮想化セキュアエンクレーブ:**
  Salvatoshiは、ハードウェア署名デバイス向けの仮想化セキュアエンクレーブ[Vanadium][vanadium github]について
  Delving Bitcoinに[投稿しました][vanadium post]。VanadiumはRISC-V仮想マシンで、
  「V-Apps」と呼ばれる任意のアプリケーションを組み込みセキュアエレメント内で実行するように設計されており、
  メモリとストレージの必要性を信頼されていないホストに委託します。
  Salvatoshiによると、Vanadiumの目的は、限られたRAMとストレージ、ベンダー固有のSDK、
  遅い開発サイクル、デバッグといった組み込み開発の複雑さを抽象化し、
  セルフカストディにおけるイノベーションをより早く、よりオープンに、そして標準化することです。

  Salvatoshiは、パフォーマンスの観点から、仮想マシンはアプリケーションのビジネスロジックのみを実行し、
  重い処理（暗号処理など）はECALLを介してネイティブに実行されると述べています。

  脅威モデルは既存のハードウェアウォレットと同じですが、Salvatoshiは、
  このアプローチではメモリアクセスパターンの漏洩が可能になり、
  ホストがどのコードページとデータページにアクセスされたか、いつアクセスされたかを観察できる可能性があると指摘しています。
  これは暗号開発者にとって特に重要です。

  このプロジェクトはまだ本番環境で使用できる状態ではなく、パフォーマンスやUXなど、
  いくつかの既知の制限があります。しかし、Salvatoshiは、プロジェクトのロードマップを策定するために、
  開発者に試用とフィードバックの提供を求めています。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **<!--interactive-transaction-visualization-tool-->対話型のトランザクションビジュアライズツール:**
  [RawBit][rawbit delving]は、[Webベース][rawbit website]の[オープンソース][rawbit github]のトランザクションビジュアライズツールです。
  さまざまなトランザクションタイプに関する対話型のレッスンを特徴としており、
  Taprootや[PSBT][topic psbt]、[HTLC][topic htlc]、[coinjoins][topic coinjoin]
  およびコベナンツ提案に関する追加レッスンも計画されています。

- **BlueWallet v7.2.2リリース:**
  BlueWallet [v7.2.2リリース][bluewallet v7.2.2]では、
  送信、受信、監視専用、コインコントロールおよびハードウェア署名デバイス機能を含む
  [Taproot][topic taproot]ウォレットのサポートが追加されました。

- **Stratum v2のアップデート:**
  Stratum v2 [v1.6.0][sv2 v1.6.0]では、Stratum v2リポジトリが再設計され、
  [sv2-appsリポジトリ][sv2-apps]が追加されました。またv0.1リリースでは、
  IPC（[ニュースレター #369][news369 ipc]参照）を使用した未改変のBitcoin Core 30.0との直接通信をサポートしています。
  このリリースには、[マイナー][sv2 wizard miners]と[開発者][sv2 wizard devs]向けのテスト用のWebツールなど、
  さまざまな機能も含まれています。

- **AuradineがStratum v2のサポートを発表:**
  Auradineは、同社のマイナーでStratum v2機能のサポートを[発表しました][auradine tweet]。

- **LDK Node 0.7.0リリース:**
  [LDK Node 0.7.0][ldk node blog]では、[スプライシング][topic splicing]の実験的なサポートと、
  [非同期支払い][topic async payments]用の静的インボイスの提供および支払いのサポートが追加された他、
  その他の機能追加とバグ修正が行われています。

- **BIP-329 Python Library 1.0.0リリース:**
  [BIP-329 Python Library][news273 329 lib]バージョン[1.0.0][bip329 python 1.0.0]は、
  型検証とテストカバレッジを含む[BIP329][]の追加フィールドをサポートしています。

- **Bitcoin Safe 1.6.0リリース:**
  [1.6.0リリース][bitcoin safe 1.6.0]では、[コンパクトブロックフィルター][topic compact block filters]と
  [再現可能なビルド][topic reproducible builds]がサポートされました。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [ライトニングノードへのクリアネット接続にはTLS証明書が必要ですか？]({{bse}}129303)
  Pieter Wuilleは、LNではユーザーがピアに接続する際に公開鍵を指定するため、
  「その公開鍵の正しさを信頼できる第三者が証明する必要はなく、公開鍵を正しく設定するのはユーザーの責任である」と指摘しています。

- [同じ秘密鍵とハッシュに対して、異なる実装が異なるDER署名を生成するのはなぜですか？]({{bse}}129270)
  ユーザーdave_thompson_085は、RFC 6979の決定論的ナンス生成を使用しない限り、
  アルゴリズムは本質的にランダム化されるため、実装によって異なるECDSA署名を生成し得ると説明しています。

- [miniscriptの`after`値が0x80000000に制限されているのはなぜですか？]({{bse}}129253)
  Murchは、Bitcoin Scriptの整数値は４byteの*符号付き*の値であるため、
  [miniscript][topic miniscript]は`after(n)`の時間ベースのCLTVタイムロックを
  最大2<sup>31</sup> - 1（2038年の時刻を表す）に制限していると回答しています。
  一方、ブロック高ベースのロックタイムは2038の閾値を超えることができます。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #33528][]は、[TRUC][topic v3 transaction relay]ポリシー制限を遵守するために、
  未承認の祖先を持つ未承認のTRUCトランザクションのアウトプットをウォレットが使用できないようにしました。
  これまでは、ウォレットはこのようなトランザクションを作成できましたが、
  ブロードキャスト時に拒否されていました。

- [Bitcoin Core #33723][]は、DNSシードのリストから
  `dnsseed.bitcoin.dashjr-list-of-p2p-nodes.us`を削除しました。
  メンテナーは、このシードがBitcoin Coreの新しいバージョン（29および30）を除外している唯一のシードであり、
  「シードの結果は、公開ネットワークから公平に選択され、機能しているBitcoinノードのみで構成する必要がある」
  というポリシーに違反していることを発見しました。

- [Bitcoin Core #33993][]は、`stopatheight`オプションのヘルプ文言を更新し、
  同期を停止するために指定されたターゲットの高さはあくまで推定値であり、
  シャットダウン中にその高さ以降のブロックが処理される可能性があることを明確にしました。

- [Bitcoin Core #33553][]は、以前無効とマークしたブロックのヘッダーを受信した際、
　 データベースの破損の可能性を示す警告メッセージを追加しました。これにより、
  ユーザーはヘッダーの同期ループに陥っている可能性があることに気づくようになります。
  また、このPRにより、IBDでは以前は無効だったフォーク検出の警告メッセージも有効になります。

- [Eclair #3220][]は、既存の`spendFromChannelAddress`ヘルパーを
  [Taprootチャネル][topic simple taproot channels]に拡張し、
  `spendfromtaprootchanneladdress`エンドポイントを追加しました。
  これによりユーザーは、[MuSig2][topic musig]署名を使用する
  [Taproot][topic taproot]チャネルのファンディングアドレスに誤って送信されたUTXOを協調的に使用できるようになります。

- [LDK #4231][]は、ブロックの再編成によってチャネルのファンディングトランザクションが未承認になった場合に、
  [ゼロ承認チャネル][topic zero-conf channels]の強制閉鎖をしないようになりました。
  LDKには、二重使用のリスクがあるため未承認になったロック済みのチャネルを強制閉鎖するメカニズムがあります。
  しかし、ゼロ承認チャネルでは信頼モデルが異なります。このエッジケースでは、
  SCIDの変更も適切に処理されるようになりました。

- [LND #10396][]では、LSP支援ノードを検出するためのルーターのヒューリスティックを厳格にしました。
  公開宛先ノードを持つインボイス、またはルートヒントの宛先ホップがすべてプライベートであるインボイスは、
  通常のノードとして扱われるようになり、プライベートな宛先と少なくとも1つの公開宛先ホップを持つものは、
  LSP支援ノードとして分類されます。これまでは、緩いヒューリスティックによりノードがLSP支援ノードとして誤って分類され、
  プロービングの失敗が増える可能性がありました。現在は、LSP支援ノードが検出されると、
  LNDは最大3つの候補LSPをプロービングし、ワーストケースの経路（手数料とCLTVが最も高い）を使用して、
  保守的な手数料の推定を提供します。

- [BTCPay Server #7022][]は、 `Subscriptions`機能（[ニュースレター #379][news379 btcpay]参照）用のAPIを導入し、
  マーチャントがオファー、プラン、サブスクライバー、チェックアウトを作成、管理できるようになりました。
  各操作ごとに約12個のエンドポイントが追加されました。

- [Rust Bitcoin #5379][]は、既存のP2Aアドレス検証メソッドを補完するために、
  [P2A（Pay-to-Anchor）][topic ephemeral anchors]アドレス構築用のメソッドを追加しました。

- [BIPs #2050][]は、[MuSig2][topic musig]ディスクリプターを規定する[BIP390][]を更新し、
  既に許可されている`tr()`に加えて、`rawtr()`内でも`musig()`キー式を使用できるようにしました。
  これにより、ディスクリプターが既存のテストベクタおよびBitcoin Coreのディスクリプター実装と整合するようになりました。

## ハッピーホリデー！

これは、Bitcoin Optechの今年最後の定期ニュースレターとなります。
12月19日（金）には、8回目の年間の振り返り特別号を発行します。
通常の発行は、1月2日（金）から再開します。

{% include snippets/recap-ad.md when="2025-12-16 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33528,33723,33993,33553,3220,4231,10396,7022,5379,2050" %}
[morehouse delving]: https://delvingbitcoin.org/t/disclosure-critical-vulnerabilities-fixed-in-lnd-0-19-0/2145
[lnd vln1]: https://morehouse.github.io/lightning/lnd-infinite-inbox-dos/
[lnd vln2]: https://morehouse.github.io/lightning/lnd-excessive-failback-exploit-2/
[lnd vln3]: https://morehouse.github.io/lightning/lnd-replacement-stalling-attack/
[lnd version]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta
[morehouse failback bug]: /ja/newsletters/2025/03/07/#lnd
[vanadium post]: https://delvingbitcoin.org/t/vanadium-a-virtualized-secure-enclave-for-hardware-signing-devices/2142
[vanadium github]: https://github.com/LedgerHQ/vanadium
[rawbit delving]: https://delvingbitcoin.org/t/raw-it-the-visual-raw-transaction-builder-script-debugger/2119
[rawbit github]: https://github.com/rawBit-io/rawbit
[rawbit website]: https://rawbit.io/
[bluewallet v7.2.2]: https://github.com/BlueWallet/BlueWallet/releases/tag/v7.2.2
[sv2 v1.6.0]: https://github.com/stratum-mining/stratum/releases/tag/v1.6.0
[sv2-apps]: https://github.com/stratum-mining/sv2-apps/releases/tag/v0.1.0
[news369 ipc]: /ja/newsletters/2025/08/29/#bitcoin-core-31802
[sv2 wizard miners]: https://stratumprotocol.org/get-started
[sv2 wizard devs]: https://stratumprotocol.org/developers
[auradine tweet]: https://x.com/Auradine_Inc/status/1991159535864803665?s=20
[ldk node blog]: https://newreleases.io/project/github/lightningdevkit/ldk-node/release/v0.7.0
[news273 329 lib]: /ja/newsletters/2023/10/18/#bip-329-python-library
[bip329 python 1.0.0]: https://github.com/Labelbase/python-bip329/releases/tag/1.0.0
[bitcoin safe 1.6.0]: https://github.com/andreasgriffin/bitcoin-safe/releases/tag/1.6.0
[news379 btcpay]: /ja/newsletters/2025/11/07/#btcpay-server-6922