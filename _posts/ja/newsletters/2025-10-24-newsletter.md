---
title: 'Bitcoin Optech Newsletter #377'
permalink: /ja/newsletters/2025/10/24/
name: 2025-10-24-newsletter-ja
slug: 2025-10-24-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、クラスターmempoolを使用してブロックテンプレートの手数料率の上昇を検出するアイディアと、
チャネルジャミングを緩和するシミュレーション結果の最新情報を掲載しています。また、
サービスとクライアントソフトウェアの最近の更新や、新しいリリースとリリース候補の発表、
人気のBitcoinインフラストラクチャソフトウェアの注目すべき更新など、
恒例のセクションも含まれています。

## ニュース

- **クラスターmempoolを使用したブロックテンプレートの手数料率上昇の検出:**
  Abubakar Sadiq Ismailは最近、mempoolの更新による潜在的な手数料増加を追跡し、
  手数料率の改善が正当化される場合にのみマイナーに新しいブロックテンプレートを提供する可能性について
  Delving Bitcoinに[投稿しました][ismail post]。このアプローチにより、
  冗長なブロックテンプレートの構築回数が削減され、トランザクション処理やピアへのリレーの遅延を防ぐことができます。
  この提案は、ブロックテンプレートの完全な再構築を必要とせずに、
  潜在的な手数料率の改善が見込めるかを評価するためにクラスターmempoolを活用しています。

  新しいトランザクションがmempoolに入ると、0個以上の既存クラスターに接続され、
  影響を受けたクラスターの再リニアライゼーション（詳細についてはニュースレター[#312][news312 lin]参照）がトリガーされ、
  古い（更新前）のと新しい（更新後）手数料率ダイアグラムが生成されます。
  古いダイアグラムはブロックテンプレートから排除させる可能性のあるチャンクを識別し、
  新しいダイアグラムは追加候補となる高手数料率のチャンクを識別します。その後、
  システムは以下の4段階のプロセスに従って影響をシミュレートします。

  1. 排除: テンプレートのコピーから一致するチャンクを削除し、変更後の手数料とサイズを更新します。

  2. 単純マージ: ブロックのウェイト制限を守りながら候補チャンクを貪欲に追加し、潜在的な手数料利益（ΔF）を推定します。

  3. 反復マージ: 単純な推定が決定的でない場合、より詳細なシミュレーションを使用してΔFを精微化します。

  4. 決定: ΔFと閾値を比較し、閾値を超えた場合は完全なブロックテンプレートを再構築してマイナーに送信します。
     そうでない場合は、不要な計算を避けるためスキップします。

  現在の提案はまだ議論の段階で、プロトタイプはまだ利用できません。

- **<!--channel-jamming-mitigation-simulation-results-and-updates-->チャネルジャミング緩和策のシミュレーション結果と更新:**
  Carla Kirk-Cohenは、Clara Shikhelmanおよびelnoshと協力して、
  彼らの[チャネルジャミングの緩和提案][channel jamming bolt]のレピュテーションアルゴリズムのシミュレーション結果と更新について
  Delving Bitcoinに[投稿しました][carla post]。注目すべき変更として、
  レピュテーションは送信チャネルで追跡され、リソースは受信チャネルで制限される点が挙げられます。
  Bitcoin Optechはこれまでに、[ライトニングチャネルジャミング攻撃][topic channel jamming attacks]と、
  Carlaによる以前の[Delving Bitcoinへの投稿][carla earlier delving post]を取り上げています。
  ライトニングチャネルジャミングの基本的な理解のためには、これらの記事をお読みください。

  この最新の更新では、彼らはシミュレーターを使用して[リソース攻撃][resource attacks]と
  [シンク攻撃][sink attacks]の両方を実行しました。新しい更新により、リソース攻撃に対する保護は維持され、
  シンク攻撃では攻撃ノードが不正な動作をした際に迅速に遮断されることが分かりました。
  攻撃者がレピュテーションを構築してから、複数のノードを標的にした場合、
  補償されるのは最後のノードのみであることが指摘されています。しかし、複数のノードを標的とするには、
  攻撃者にとって大きなコストがかかることになります。

  記事では、[チャネルジャミング][topic channel jamming attacks]の緩和策は十分なレベルに達していると結論付けており、
  読者にシミュレーターを使って攻撃をテストするよう勧めています。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **BULLウォレットのローンチ:**
  オープンソースの[BULLモバイルウォレット][bull blog]は、BDK上に構築されており、
  [ディスクリプター][topic descriptors]、[ラベリング][topic wallet labels]とコイン選択、
  ライトニング、[payjoin][topic payjoin]、Liquid、ハードウェアウォレット、
  監視専用ウォレットなど、その他多くの機能をサポートしています。

- **Sparrow 2.3.0リリース:**
  [Sparrow 2.3.0][sparrow github]は、[サイレントペイメント][topic silent payments]アドレスへの送金と、
  人が読める[BIP353][] Bitcoin支払い指示のサポートを追加し、その他の機能追加とバグ修正も含まれています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Core Lightning 25.09.1][]は、この人気のLNノードの現在のメジャーバージョンのメンテナンスリリースで、
  いくつかのバグ修正が含まれています。

- [Bitcoin Core 28.3][]は、この主要なフルノード実装の以前のリリースシリーズのメンテナンスリリースです。
  複数のバグ修正と`blockmintxfee`、`incrementalrelayfee`および`minrelaytxfee`の新しいデフォルト値が含まれています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #33157][]は、単一のトランザクションクラスター用に`SingletonClusterImpl`型を導入し、
  いくつかの`TxGraph`内部構造をコンパクト化することで、
  [mempoolクラスター][topic cluster mempool]内のメモリ使用量を最適化しています。
  このPRは、`TxGraph`のメモリ使用量を推定する`GetMainMemoryUsage()`関数も追加しています。

- [Bitcoin Core #29675][]は、`musig(0)`[ディスクリプター][topic descriptors]をインポートしたウォレットにおいて、
  [MuSig2][topic musig]集約鍵によって管理される[Taproot][topic taproot]アウトプットの受信と使用をサポートします。
  以前の有効化の作業については、[ニュースレター #366][news366 musig2]をご覧ください。

- [Bitcoin Core #33517][]と[Bitcoin Core #33518][]は、
  ログレベルとカテゴリを追加することでマルチプロセスログのCPU使用量を削減します。
  これにより、破棄されるプロセス間通信（IPC）ログメッセージのシリアライズを回避します。
  作者によると、このPR以前は、ログの処理が
  [Stratum v2][topic pooled mining]クライアントアプリケーションのCPU時間の50%、
  Bitcoinノードのプロセスの10%を占めていたことを発見しました。
  現在はほぼ0%にまで低下しました。追加の文脈については、
  ニュースレター[#323][news323 ipc]と[#369][news369 ipc]をご覧ください。

- [Eclair #2792][]は、各経路のキャパシティと成功確率を考慮してパーツを経路間に割り当てる
  新しい[MPP][topic multipath payments]分割戦略`max-expected-amount`を追加します。
  新しい`mpp.splitting-strategy`設定オプションが3つのオプションと共に追加されました:
  `max-expected-amount`、経路のキャパシティのみを考慮する`full-capacity`、
  ランダムに分割する`randomize`（デフォルト）です。後者の2つは既に`randomize-route-selection`
  のブール設定を通じてアクセス可能です。このPRは、リモートチャネルの[HTLC][topic htlc]最大制限の実施を追加します。

- [LDK #4122][]は、ピアがオフラインの間、[スプライス][topic splicing]リクエストをキューイングし、
  再接続時にネゴシエーションを開始できるようにします。[ゼロ承認][topic
  zero-conf channels]のスプライスの場合、LDKは`tx_signatures`の交換直後に
  ピアに`splice_locked`メッセージを送信するようになりました。また、LDKは並行スプライス中にスプライスをキューイングし、
  他のスプライスがロックされ次第、試行するようになります。

- [LND #9868][]は、`OnionMessage`型を定義し、2つの新しいRPCエンドポイントを追加します。
  `SendOnionMessage`は特定のピアにオニオンメッセージを送信し、
  `SubscribeOnionMessages`は受信するオニオンメッセージのストリームを購読します。
  これらは[BOLT12 オファー][topic offers]をサポートするために必要な最初のステップです。

- [LND #10273][]は、従来のスイーパー`utxonursery`が
  [ロックタイム][topic timelocks]（高さヒント）が0の[HTLC][topic htlc]をスイープしようとした際にLNDがクラッシュする問題を修正します。
  現在、LNDはチャネルのクローズの高さからヒントを導出することで、これらのHTLCを正常にスイープします。

{% include snippets/recap-ad.md when="2025-10-28 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33157,29675,33517,33518,2792,4122,9868,10273" %}
[carla post]: https://delvingbitcoin.org/t/outgoing-reputation-simulation-results-and-updates/2069
[channel jamming bolt]: https://github.com/lightning/bolts/pull/1280
[resource attacks]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-resource-attacks-3
[sink attacks]: https://delvingbitcoin.org/t/hybrid-jamming-mitigation-results-and-updates/1147#p-3212-manipulation-sink-attack-9
[bull blog]: https://www.bullbitcoin.com/blog/bull-by-bull-bitcoin
[sparrow github]: https://github.com/sparrowwallet/sparrow/releases/tag/2.3.0
[ismail post]: https://delvingbitcoin.org/t/determining-blocktemplate-fee-increase-using-fee-rate-diagram/2052
[carla earlier delving post]: /ja/newsletters/2024/09/27/#hybrid-jamming-mitigation-testing-and-changes
[Core Lightning 25.09.1]: https://github.com/ElementsProject/lightning/releases/tag/v25.09.1
[Bitcoin Core 28.3]: https://bitcoincore.org/ja/2025/10/17/release-28.3/
[news366 musig2]: /ja/newsletters/2025/08/08/#bitcoin-core-31244
[news323 ipc]: /ja/newsletters/2024/10/04/#bitcoin-core-30510
[news369 ipc]: /ja/newsletters/2025/08/29/#bitcoin-core-31802
[news312 lin]: /ja/newsletters/2024/07/19/#introduction-to-cluster-linearization