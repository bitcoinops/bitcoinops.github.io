---
title: 'Bitcoin Optech Newsletter #349'
permalink: /ja/newsletters/2025/04/11/
name: 2025-04-11-newsletter-ja
slug: 2025-04-11-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin Coreの初期ブロックダウンロードを高速化する提案を掲載しています。
概念実証の実装では、Bitcoin Coreのデフォルト設定と比較して約5倍の高速化が見られています。
また、Bitcoin Core PR Review Clubミーティングの要約や、
新しいリリースとリリース候補の発表、人気のBitcoinインフラストラクチャプロジェクトの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **SwiftSyncによる初期ブロックダウンロードの高速化:** Sebastian Falbesonerが
  _SwiftSync_ のサンプル実装とパフォーマンス結果をDelving Bitcoinに[投稿しました][falbesoner ss1]。
  SwiftSyncは、Ruben Somsenが最近のBitcoin Core開発者ミーティングで[提案し][somsen ssgist]、
  その後メーリングリストに[投稿された][somsen ssml]アイディアです。
  この記事の執筆時点で、スレッドに投稿された[最新の結果では][falbesoner ss2]、
  Bitcoin CoreのIBDのデフォルト設定（[assumevalid][]は使用するが[assumeUTXO][topic assumeutxo]は使用しない）と比較して、
  初期ブロックダウンロード（IBD）が5.28倍高速化され、初期同期時間が約41時間から約8時間に短縮されました。

  SwiftSyncを使用する前に、ノードを最新のブロックまで同期済みの人が、
  そのブロックまでのUTXOセットに含まれるトランザクションアウトプット（つまり未使用のアウトプット）を示すヒントファイルを作成します。
  これは、現在のUTXOセットサイズに合わせて数百MBに効率的にエンコードできます。
  ヒントファイルには、どのブロックで生成されたかも記載されており、これを
  _ターミナルSwiftSyncブロック_ と呼びます。

  SwiftSyncを実行するユーザーはヒントファイルをダウンロードし、
  ターミナルSwiftSyncブロックより前の各ブロックを処理する際にそれを使用します。
  ヒントファイルで、ターミナルSwiftSyncブロックに到達した際にアウトプットがUTXOセットに残ることが示されている場合のみ、
  アウトプットをUTXOデータベースに保存します。これにより、
  IBD中にUTXOデータベースに追加され、その後削除されるエントリーの数が大幅に削減されます。

  ヒントファイルが正しいことを確認するために、UTXOデータベースに保存されていないすべてのアウトプットは、
  [暗号学的アキュムレーター][cryptographic accumulator]に追加されます。
  使用済みのすべてのアウトプットは、アキュムレーターから削除されます。
  ノードがターミナルSwiftSyncブロックに到達すると、アキュムレーターが空であることを確認します。
  つまり、確認したすべてのアウトプットは後で使用されたことを意味します。
  これが失敗した場合、ヒントファイルが正しくなかったことを意味し、
  SwiftSyncを使用せずにIBDを最初からやり直す必要があります。
  このように、ユーザーはヒントファイルの作成者を信頼する必要はありません。
  悪意あるファイルによってUTXOの状態が不正確になることはなく、
  ユーザーのコンピューティングリソースを数時間浪費するだけで済みますね。

  SwiftSyncの未実装の追加機能として、IBD中のブロックの並列検証が挙げられます。
  これは、assumevalidが古いブロックのスクリプトをチェックしないこと、
  ターミナルSwiftSyncブロックより前のエントリーがUTXOデータベースから削除されないこと、
  そして使用されるアキュムレーターが追加（作成）および削除（使用）されたアウトプットの最終的な結果のみを追跡することから可能です。
  これにより、ターミナルSwiftSyncブロックより前のブロック間の依存関係が排除されます。
  IBD中の並列検証は、同様の理由から[Utreexo][topic utreexo]の機能でも採用されています。

  議論では提案のいくつかの側面が検討されました。Falbesonerの元の実装では、
  [一般化された誕生日攻撃][generalized birthday attack]への耐性があることが[示されている][wuille muhash]
  [MuHash][]アキュムレーター（[ニュースレター #123][news123 muhash]参照）が使用されていました。
  Somsenは、より高速な代替アプローチについて[説明しました][somsen ss1]。
  Falbesonerは、この代替アプローチが暗号的に安全かどうか疑問視しましたが、
  シンプルであるため実装し、SwiftSyncの速度がさらに向上することを発見しました。

  James O'Beirneは、assumeUTXOがさらに大幅な高速化をもたらすことを踏まえ、
  SwiftSyncは有用かどうかを[尋ねました][obeirne ss]。Somsenは、
  SwiftSyncはassumeUTXOのバックグラウンド検証を高速化するため、
  assumeUTXOのユーザーにとっても便利な追加機能であると[返信しました][somsen ss2]。
  さらに、assumeUTXOに必要なデータ（特定のブロックのUTXOデータ）をダウンロードする人は、
  そのブロックをターミナルSwiftSyncブロックとして使用する場合、
  別途ヒントファイルを用意する必要がないと述べています。

  Vojtěch Strnadと0xB10CおよびSomsenは、ヒントファイルのデータを圧縮することで、
  約75%の節約が見込まれ、（ブロック850,900の）テストヒントファイルを約88MBに縮小できると[説明しました][b10c ss]。

  この記事の執筆時点で、議論は進行中でした。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Add Fee rate Forecaster Manager][review club 31664]は、
[ismaelsadeeq][gh ismaelsadeeq]によるPRで、トランザクション手数料の予測（[推定][topic fee estimation]とも呼ばれる）
ロジックをアップグレードします。このPRでは、複数の`Forecaster`を登録できる新しい
`ForecasterManager`クラスが導入されます。既存の`CBlockPolicyEstimator`（
承認済みのトランザクションのみを考慮）は、そのようなForecasterの1つとなるようにリファクタリングされました。
注目すべきは新しく`MemPoolForecaster`が導入されたことです。`MemPoolForecaster`は、
mempool内の未承認トランザクションも考慮するため、手数料率の変更に迅速に対応できます。

{% include functions/details-list.md
  q0="なぜ新しいシステムは「Estimator」や「Fee Estimation Manager」ではなく、
  「Forecaster」と「ForecasterManager」と呼ばれるのですか？"
  a0="このシステムは、現在と過去のデータに基づいて将来の結果を予測します。
  ある程度のランダム性をもたせて現在の状況を近似するEstimatorとは異なり、
  Forecasterは将来の出来事を予測します。これは、このシステムの予測的な性質と
  不確実性/リスクレベルの出力と一致しています。"
  a0link="https://bitcoincore.reviews/31664#l-19"

  q1="`CBlockPolicyEstimator`が、PR #12966のアプローチと同様に、
  mempoolの参照を保持するように変更されていないのはなぜですか？
  また、mempoolへの参照を保持するよりも現在のアプローチが優れているのはなぜですか（ヒント：PR #28368参照）？"
  a1="`CBlockPolicyEstimator`は`CValidationInterface`を継承し、
  その仮想メソッドである`TransactionAddedToMempool`、`TransactionRemovedFromMempool`、
  `MempoolTransactionsRemovedForBlock`を実装しています。これにより、
  `CBlockPolicyEstimator`は、参照を介してmempoolに不必要に密結合されることなく、
  必要なmempoolの情報を取得できます。"
  a1link="https://bitcoincore.reviews/31664#l-26"

  q2="新しいアーキテクチャと`CBlockPolicyEstimator`を直接変更した場合のトレードオフは何ですか？"
  a2="複数の`Forecaster`を登録できる`FeeRateForecasterManager`クラスを備えた新しいアーキテクチャは、
  よりモジュール化されたアプローチであり、テストの効率化や、より効果的な関心事の分離を実現します。
  これにより、後から新しい予測戦略を簡単に追加できます。ただし、
  メンテナンスに必要なコードが少し増え、どの推定手法を使用すべきかユーザーが混乱する可能性があります。"
  a2link="https://bitcoincore.reviews/31664#l-43"
%}

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Core Lightning 25.02.1][]は、この人気のLNノードの現在のメジャーバージョンのメンテナンスリリースで、
  いくつかのバグ修正が含まれています。

- [Core Lightning 24.11.2][]は、この人気のLNノードの前のメジャーバージョンのメンテナンスリリースです。
  いくつかのバグ修正が含まれており、そのうちのいくつかは、バージョン25.02.1でリリースされたバグ修正と同じものです。

- [BTCPay Server 2.1.0][]は、このセルフホスト型ペイメントプロセッサソフトウェアのメジャーリリースです。
  いくつかのアルトコインユーザーに対する破壊的な変更と、[RBF][topic rbf]と
  [CPFP][topic cpfp]による手数料の引き上げの改善、
  すべての署名者がBTCPay Serverを使用している場合のマルチシグのより良いフローが含まれています。

- [Bitcoin Core 29.0rc3][]は、ネットワークの主要なフルノードの次期メジャーバージョンのリリース候補です。
  [バージョン29のテストガイド][bcc29 testing guide]をご覧ください。

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

- [LDK #2256][]および[LDK #3709][]は、[BOLTs #1044][]で定義されているように、
  `UpdateFailHTLC`構造体にオプションの`attribution_data`フィールドを追加し、
  `AttributionData`構造体を導入することで、失敗の帰属（ニュースレター[#224][news224 failures]参照）を改善します。
  このプロトコルでは、各転送ノードは失敗メッセージに`hop_payload`フラグ、
  ノードがHTLCを保持していた時間を記録する`duration`フィールド、
  経路上の想定される位置に対応するHMACを付加します。ノードが、失敗メッセージを破損した場合、
  HMACチェーンの不一致は、破損が発生したノードペアを識別するのに役立ちます。

- [LND #9669][]は、[RBF][topic rbf]協調クローズフロー（ニュースレター[#347][news347 coop]参照）が設定されている場合でも、
  [Simple Taproot Channel][topic simple taproot channels]で常に従来の協調クローズフロー使用するようダウングレードします。
  これまでは、両方の機能が設定されているノードは起動に失敗していました。

- [Rust Bitcoin #4302][]は、スクリプトビルダーAPIに相対的[タイムロック][topic timelocks]パラメーターを
  引数に取る新しい`push_relative_lock_time()`メソッドを追加し、
  シーケンス番号をそのまま受け取る`push_sequence()`が非推奨となりました。
  この変更により、開発者がスクリプト内で相対的タイムロックの値ではなく、
  シーケンス番号を誤ってプッシュしてしまう潜在的な混乱が解消されます。
  この値は、`CHECKSEQUENCEVERIFY`を使ってインプットのシーケンス番号と照合されます。

{% include snippets/recap-ad.md when="2025-04-15 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2256,3709,9669,4302,1044" %}
[bitcoin core 29.0rc3]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc2
[wuille muhash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-May/014337.html
[falbesoner ss1]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/
[somsen ssgist]: https://gist.github.com/RubenSomsen/a61a37d14182ccd78760e477c78133cd
[falbesoner ss2]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/7
[assumevalid]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#assumed-valid-blocks
[cryptographic accumulator]: https://en.wikipedia.org/wiki/Accumulator_(cryptography)
[news123 muhash]: /en/newsletters/2020/11/11/#bitcoin-core-pr-review-club
[muhash]: https://cseweb.ucsd.edu/~mihir/papers/inchash.pdf
[generalized birthday attack]: https://www.iacr.org/archive/crypto2002/24420288/24420288.pdf
[somsen ss1]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/2
[obeirne ss]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/5
[somsen ss2]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/6
[b10c ss]: https://delvingbitcoin.org/t/ibd-booster-speeding-up-ibd-with-pre-generated-hints-poc/1562/4
[somsen ssml]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAPv7TjaM0tfbcBTRa0_713Bk6Y9jr+ShOC1KZi2V3V2zooTXyg@mail.gmail.com/T/#u
[core lightning 25.02.1]: https://github.com/ElementsProject/lightning/releases/tag/v25.02.1
[core lightning 24.11.2]: https://github.com/ElementsProject/lightning/releases/tag/v24.11.2
[btcpay server 2.1.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.1.0
[news224 failures]: /ja/newsletters/2022/11/02/#ln
[news347 coop]: /ja/newsletters/2025/03/28/#lnd-8453
[review club 31664]: https://bitcoincore.reviews/31664
[gh ismaelsadeeq]: https://github.com/ismaelsadeeq
[forecastresult compare]: https://github.com/bitcoin-core-review-club/bitcoin/commit/1e6ce06bf34eb3179f807efbddb0e9bca2d27f28#diff-5baaa59bccb2c7365d516b648dea557eb50e63837de71531dc460dbcc62eb9adR74-R77