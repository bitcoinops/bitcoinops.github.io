---
title: 'Bitcoin Optech Newsletter #376'
permalink: /ja/newsletters/2025/10/17/
name: 2025-10-17-newsletter-ja
slug: 2025-10-17-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、ノードが現在のブロックテンプレートを共有する提案の最新情報と、
コベナンツが不要なVaultの構成をまとめた論文を掲載しています。
また、新しいリリースとリリース候補の発表や、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき更新など、
恒例のセクションも含まれています。

## ニュース

- **<!--continued-discussion-of-block-template-sharing-->ブロックテンプレートの共有に関する議論の続き:**
  フルノードピアが[コンパクトブロックリレー][topic compact block relay]エンコーディングを用いて
  次ブロックの現在のテンプレートを定期的に相互に送信する提案（[ニュースレター
  #366][news366 block template sharing]および[#368][news368 bts]参照）について、議論が続いています。
  プライバシーとノードのフィンガープリンティングに関する懸念が寄せられたため、
  著者はこれらの懸念に対処し文書を改善するため、現在のドラフトをBINANA（
  [Bitcoin Inquisition Numbers and Names Authority][binana repo]）リポジトリに移管することを決定しました。
  このドラフトには、[BIN-2025-0002][bin]というコードが付与されました。

- **セキュアBitcoin署名レイヤー B-SSL:** Francesco Madonnaは、
  [Taproot][topic taproot]、[`OP_CHECKSEQUENCEVERIFY`][op_csv]および[`OP_CHECKLOCKTIMEVERIFY`][op_cltv]を用いた
  コベナンツが不要な[Vault][topic vaults]モデルというコンセプトをDelving Bitcoinに[投稿しました][francesco post]。
  投稿の中で彼は、既存のBitcoinのプリミティブを使用していると述べており、
  ほとんどのVaultの提案ではソフトフォークが必要となるため、これは重要なポイントです。

  設計上、3つの異なる使用パスがあります:

  1. 通常動作のための高速パスで、オプションのCS（コンビニエンスサービス）が選択された遅延を強制できる

  2. カストディアンBによる1年間のフォールバック

  3. 失踪や相続が発生した場合の3年間のカストディアンパス

  A、A₁、B、B₁、C、CSの6つの異なる鍵があり、B₁とCはカストディアンの管理下に置かれ、
  リカバリーパスと同時にのみ使用されます。

  この設定は、ユーザーが資金をロックアップでき、資金を託したカストディアンが資金を窃盗しないという確証できる環境を作ります。
  これは[コベナンツ][topic covenants]のように資金の移動先を制限するものではありませんが、
  カストディアンを使用した自己管理において、より強固なスキームを提供します。
  投稿の中で、Francescoは、誰かがこのアイディアを実装しようとする前に、
  読者に[ホワイトペーパー][bssl whitepaper]をレビューし議論するよう呼びかけています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 30.0][]は、ネットワークの主要なフルノードの最新バージョンのリリースです。
  [リリースノート][notes30]には、以下のような重要な改善点が記載されています:
  標準トランザクションにおけるレガシーsigopsの上限を2500に設定、
  複数のデータキャリア（OP_RETURN）アウトプットが標準になったこと、
  `datacarriersize`のデフォルト値が100,000に増加、
  [デフォルト最小リレー手数料率][topic default minimum transaction relay feerates]と
  増分リレー手数料率が0.1sat/vbに、トランザクションオーファネージのDDoS保護の改善、新しい`bitcoin`CLIツール、
  [Stratum v2][topic pooled mining]との統合のための実験的なプロセス間通信（IPC）マイニングインターフェース、
  `coinstatsindex`の新しい実装、`natpmp`オプションがデフォルトになったこと、
  [ディスクリプター][topic descriptors]ウォレットへの移行によるレガシーウォレットのサポートの削除、
  [TRUC][topic v3 transaction relay]トランザクションの使用と作成のサポート、その他多数の改善が含まれています。

- [Bitcoin Core 29.2][]は、P2P、mempool、RPC、CI、ドキュメント、
  その他の問題に対するいくつかのバグ修正を含むマイナーリリースです。
  詳細は[リリースノート][notes29.2]をご覧ください。

- [LDK 0.1.6][]は、LN対応アプリケーションを構築するための、この人気のライブラリのリリースです。
  DDoSおよび資金の盗難に関連するセキュリティ脆弱性パッチ、パフォーマンスの改善およびいくつかのバグ修正が含まれています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Eclair #3184][]は、[BOLT2][]で規定されているように、
  切断前に`shutdown`メッセージが送信済みの場合のみ、再接続時に`shutdown`を再送信することで、
  協調的な閉鎖のフローを改善します。[Simple Taproot Channel][topic
  simple taproot channels]の場合、Eclairは再送信用に新しいclosing nonceを生成して保存し、
  ノードが後で有効な`closing_sig`を生成できるようにします。

- [Core Lightning #8597][]は、CLNが`sendonion`または`injectpaymentonion`を介して
  不正な[オニオンメッセージ][topic onion messages]を送信した後、
  直接ピアが`failmsg`応答を返した際に発生するクラッシュを防止します。
  現在、CLNはこれを単純な最初のホップの失敗として扱い、クラッシュするのではなくクリーンなエラーを返します。
  これまでは、これをさらに下流から来た暗号化された`failonion`として扱っていました。

- [LDK #4117][]は、`static_remote_key`を使用した`remote_key`のオプトインの決定論的導出を導入します。
  これにより、ユーザーはバックアップシードフレーズのみを使って、強制クローズの際に資金をリカバリーできます。
  これまでは、`remote_key`はチャネルごとのランダム性に依存しており、
  資金をリカバリーするには、チャネルの状態が必要でした。この新しいスキームは、
  新しいチャネルではオプトインですが、既存のチャネルを[スプライシング][topic splicing]する際は自動的に適用されます。

- [LDK #4077][]は、`SplicePending`イベントおよび`SpliceFailed`イベントを追加します。
  前者は[スプライス][topic splicing]ファンディングトランザクションが交渉され、
  ブロードキャストされ、両サイドでロックされた時点（[RBF][topic rbf]の場合を除く）で発行されます。
  後者のイベントは、`interactive-tx`の失敗、`tx_abort`メッセージ、チャネルシャットダウンまたは
  [静止][topic channel commitment upgrades]状態での切断/再読込により、
  ロック前にスプライシングが中止された際に発行されます。

- [LDK #4154][]は、プリイメージのオンチェーン監視処理を更新し、
  取得プリイメージとペイメントハッシュが一致する[HTLC][topic htlc]に対してのみ
  クレームトランザクションが作成されるようにします。これまでは、
  LDKは請求可能なすべてのHTLC（期限切れのものと既知のプリイメージを持つもの）を請求しようとしていましたが、
  これは無効なクレームトランザクションを作成するリスクがあり、
  相手が別のHTLCを先にタイムアウトさせた場合、資金損失の可能性がありました。

{% include snippets/recap-ad.md when="2025-10-21 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3184,8597,4117,4077,4154" %}
[francesco post]: https://delvingbitcoin.org/t/concept-review-b-ssl-bitcoin-secure-signing-layer-covenant-free-vault-model-using-taproot-csv-and-cltv/2047
[op_cltv]: https://github.com/bitcoin/bips/blob/master/bip-0065.mediawiki
[op_csv]: https://github.com/bitcoin/bips/blob/master/bip-0112.mediawiki
[bssl whitepaper]: https://github.com/ilghan/bssl-whitepaper/blob/main/B-SSL_WP_Oct_11_2025.pdf
[towns tempshare]: https://delvingbitcoin.org/t/sharing-block-templates/1906/13
[news366 block template sharing]: /ja/newsletters/2025/08/08/#mempool
[binana repo]: https://github.com/bitcoin-inquisition/binana
[bin]: https://github.com/bitcoin-inquisition/binana/blob/master/2025/BIN-2025-0002.md
[news368 bts]: /ja/newsletters/2025/08/22/#bip
[Bitcoin Core 30.0]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[notes30]: https://bitcoincore.org/ja/releases/30.0/
[Bitcoin Core 29.2]: https://bitcoincore.org/bin/bitcoin-core-29.2/
[notes29.2]: https://bitcoincore.org/ja/releases/29.2/
[LDK 0.1.6]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.6