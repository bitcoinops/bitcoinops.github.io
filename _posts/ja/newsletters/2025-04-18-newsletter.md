---
title: 'Bitcoin Optech Newsletter #350'
permalink: /ja/newsletters/2025/04/18/
name: 2025-04-18-newsletter-ja
slug: 2025-04-18-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、サービスとクライアントソフトウェアの最近の変更や、
新しいリリースとリリース候補の発表、人気のBitcoinインフラストラクチャソフトウェアの注目すべき変更など、
恒例のセクションを掲載しています。また、先週のSwiftSyncに関する記事の一部訂正も含まれています。

## ニュース

*今週は、どの[情報源][sources]からも重要なニュースは見つかりませんでした。*

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Bitcoin Knotsバージョン28.1.knots20250305のリリース:**
  このBitcoin Knots[リリース][knots 28.1]には、Segwit、
  Taprootアドレスに対する[メッセージ署名][topic generic signmessage]のサポートに加えて、
  [BIP137][]および[BIP322][]、Electrumで署名されたメッセージの検証など、
  さまざまな変更が含まれています。

- **PSBTv2エクスプローラーの発表:**
  [Bitcoin PSBTv2 Explorer][bip370 website]は、バージョン2データ形式でエンコードされた
  [PSBT][topic psbt]を確認します。

- **LNbits v1.0.0リリース:**
  [LNbits][lnbits github]ソフトウェアは、ライトニングネットワークのさまざまなウォレット上で、
  アカウント機能や追加機能を提供します。

- **Mempool Open Source Project® v3.2.0リリース:**
  [v3.2.0リリース][mempool 3.2.0]では、[v3トランザクション][topic v3 transaction relay]、
  アンカーアウトプット、[1P1Cパッケージ][topic package relay]のブロードキャスト、
  Stratumマイニングプールジョブの可視化などの機能が追加されました。

- **Coinbase MPCライブラリのリリース:**
  [Coinbase MPC][coinbase mpc blog]プロジェクトは、
  カスタムsecp256k1実装を含む、MPC（マルチパーティコンピューティング）スキームで使用する鍵を保護する
  [C++ライブラリ][coinbase mpc github]です。

- **<!--lightning-network-liquidity-tool-released-->ライトニングネットワークの流動性ツールのリリース:**
  [Hydrus][hydrus github]は、過去のパフォーマンスを含むLNネットワークの状態を用いて、
  LND用のライトニングチャネルを自動的に開閉します。[バッチ処理][topic payment batching]もサポートしています。

- **Versioned Storage Serviceの発表:**
  [Versioned Storage Service (VSS) フレームワーク][vss blog]は、
  非カストディアルウォレットに焦点を当てた、
  ライトニングウォレットとBitcoinウォレットの状態データ用のオープンソースのクラウドストレージソリューションです。

- **Bitcoinノード用のファジングテストツール:**
  [Fuzzamoto][fuzzamoto github]は、P2PやRPCなどの外部インターフェースを介して、
  Bitcoinプロトコルのさまざまな実装におけるバグをファジングテストで検出するためのフレームワークです。

- **Bitcoin Control Boardコンポーネントのオープンソース化:**
  Braiinsは、BCB100マイニングコントロールボードのハードウェアおよびソフトウェアコンポーネントの一部を
  オープンソース化すると[発表しました][braiins tweet]。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 29.0][]は、ネットワークの主要なフルノードの最新のメジャーバージョンです。
  [リリースノート][bcc rn]には、いくつかの重要な改善が記載されています。
  デフォルトでオフになっているUPnP機能（過去のセキュリティの脆弱性の原因の一部）を
  NAT-PMPオプション（これもデフォルトでオフ）に置き換え、
  オーファントランザクションの親の入手方法を改善することで、
  Bitcoin Coreの現在の[パッケージリレー][topic package relay]サポートの信頼性の向上が期待されます。
  また、デフォルトのブロックテンプレートのスペースが若干増加し、マイナーの収益の向上につながる可能性があります。
  さらに、[将来のソフトフォーク][topic consensus cleanup]で[タイムワープ][topic
  time warp]が禁止された場合に、マイナーの収益の損失につながる可能性のある偶発的なタイムワープを回避する機能を改善し、
  ビルドシステムをautotoolsからcmakeに移行しました。

- [LND 0.19.0-beta.rc2][]は、この人気のLNノードのリリース候補です。
  おそらくテストが必要な主な改善の1つは、協調クローズにおける新しいRBFベースの手数料引き上げです。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [LDK #3593][]により、ユーザーは支払い完了時に[BOLT12][topic offers]インボイスを
  `PaymentSent`イベントに含めることで、BOLT12の支払いの証明を提供できるようになります。
  これは、`PendingOutboundPayment::Retryable`列挙型に`bolt12`フィールドを追加することで実現され、
  これを`PaymentSent`イベントにアタッチできます。

- [BOLTs #1242][]により、[BOLT11][]インボイス支払いにおいて、
  `s`（ペイメントシークレット）フィールドがない場合に、
  読み取り側（支払人）は支払いを失敗とみなすことで、
  [ペイメントシークレット][topic payment secrets]を必須にします。
  これまでは、書き込み側（受取人）のみに必須とされており、
  読み取り側は長さが不適切な`s`フィールドを無視できました（ニュースレター[#163][news163 secret]参照）。
  このPRにより、[BOLT9][]におけるペイメントシークレットの機能が`ASSUMED`ステータスに更新されます。

## 訂正

先週のニュースレターでSwiftSyncについて紹介した[記事][news349 ss]には、
いくつかの誤りと混乱を招く記述がありました。

- *<!--no-accumulator-used-->アキュムレーターは使用しない:*
  SwiftSyncは暗号学的アキュムレーターを使用していると説明しましたが、これは誤りです。
  暗号学的アキュムレーターを使用すれば、個々のトランザクションアウトプット（TXO）がセットの一部であるかどうかをテストできます。
  SwiftSyncではそうする必要はありません。代わりに、TXOが作成される際に、
  そのTXOを表す値を集計値に加算し、TXOが破棄（使用）される際に同じ値を減算します。
  SwiftSyncのターミナルブロックより前に使用されるはずのすべてのTXOに対してこれを実行した後、
  ノードは集計値がゼロであることを確認します。これは作成されたすべてのTXOがその後使用されたことを示します。

- *並列ブロック検証ではassumevalidを必要としない:*
  SwiftSyncで並列検証が機能する可能性がある1つの方法について、
  ターミナルSwiftSyncブロックまでのスクリプトは検証されないと説明しました。
  これは、Bitcoin Coreが _assumevalid_ を使用して初期同期を行う現在の方法に似ています。
  しかし、以前のスクリプトはSwiftSyncで検証される可能性があり、
  そのためにはBitcoinのP2Pプロトコルを変更し、オプションでブロックに余分なデータを含める必要があります。
  Bitcoin Coreノードは既にこのデータを保存しているため、
  assumevalidを無効にしてSwiftSyncを使いたい人が多いと予想される場合、
  P2Pメッセージを拡張することは難しいことではないと思われます。

- *並列ブロック検証が可能になるの理由はUtreexoとは異なる:*
  SwiftSyncがブロックの検証を並列して行えるのは[Utreexo][topic utreexo]と同様の理由によると説明しましたが、
  両者は異なるアプローチを採用しています。Utreexoは、UTXOセットへのコミットメントから開始し、
  UTXOセットのすべての変更を実行し、新しいUTXOセットへのコミットメントを生成することで、
  ブロック（または効率性を重視して複数のブロック）を検証します。
  これにより、CPUスレッド数に基づいて検証作業を分割できます。たとえば、
  1つのスレッドで最初の1,000ブロックを検証し、別のスレッドで次の1,000ブロックを検証するといった具合です。
  検証の終わりに、ノードは最初の1,000ブロックの終了時のコミットメントが、
  次の1,000ブロックの開始時のコミットメントと同じであることを確認します。

  SwiftSyncは、加算前に減算を可能にする集約状態を使用します。
  TXOがブロック1で作られて、ブロック2で使用されるとします。
  最初にブロック2を処理する場合、集約からTXOの表現を減算します。後でブロック1を処理する際に、
  集約にTXOの表現を加算します。最終的な結果はゼロであり、これがSwiftSyncの検証の最後に確認されます。

読者のみなさまには、私たちの間違いをお詫びします。また、報告してくれたRuben Somsenに感謝します。

{% include snippets/recap-ad.md when="2025-04-22 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3593,1242" %}
[bitcoin core 29.0]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc2
[sources]: /ja/internal/sources/
[news349 ss]: /ja/newsletters/2025/04/11/#swiftsync
[bcc rn]: https://bitcoincore.org/ja/releases/29.0/
[knots 28.1]: https://github.com/bitcoinknots/bitcoin/releases/tag/v28.1.knots20250305
[bip370 website]: https://bip370.org/
[lnbits github]: https://github.com/lnbits/lnbits
[mempool 3.2.0]: https://github.com/mempool/mempool/releases/tag/v3.2.0
[coinbase mpc blog]: https://www.coinbase.com/blog/innovation-matters-coinbase-breaks-new-ground-with-mpc-security-technology
[coinbase mpc github]: https://github.com/coinbase/cb-mpc
[hydrus github]: https://github.com/aftermath2/hydrus
[vss blog]: https://lightningdevkit.org/blog/announcing-vss/
[fuzzamoto github]: https://github.com/dergoegge/fuzzamoto
[braiins tweet]: https://x.com/BraiinsMining/status/1904601547855573458
[news163 secret]: /ja/newsletters/2021/08/25/#bolts-887
