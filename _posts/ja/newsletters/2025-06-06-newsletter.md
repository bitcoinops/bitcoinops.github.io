---
title: 'Bitcoin Optech Newsletter #357'
permalink: /ja/newsletters/2025/06/06/
name: 2025-06-06-newsletter-ja
slug: 2025-06-06-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、古いwitnessなしでフルノードを同期させる方法の分析を共有しています。
また、コンセンサスの変更に関する議論や、新しいリリースとリリース候補の発表、
人気のBitcoinインフラストラクチャソフトウェアの注目すべき更新など、
恒例のセクションも含まれています。

## ニュース

- **witnessなしのフルノードの同期:** Jose SKは、
  特定の設定で新しく起動したフルノードが、過去のブロックチェーンデータのダウンロードを回避した場合の
  セキュリティ上のトレードオフについての[分析][sk nowit gist]の要約をDelving Bitcoinに[投稿しました][sk nowit]。
  Bitcoin Coreはデフォルトで、実行中のBitcoin Coreのバージョンのリリースより1〜2ヶ月以上前に作成されたブロックについて、
  ブロック内のスクリプトの検証をスキップする`assumevalid`設定を使用しています。
  またデフォルトでは無効になっていますが、多くのBitcoin Coreユーザーは、
  ブロックの検証後しばらくしてからそのブロックを削除する`prune`設定を使用しています（
  ブロックの生存期間はブロックのサイズとユーザーが選択した設定によって異なります）。

  SKは、スクリプトの検証に使用されず最終的に削除されるため、
  プルーニングノードはassumevalidの対象のブロックについて、
  スクリプトの検証にだけ使われるwitnessデータをダウンロードしなくていいと主張しています。
  witnessのダウンロードをスキップすることで、「帯域幅の使用量を40%以上削減できる」
  と書いています。

  Ruben Somsenは、これは少なくともセキュリティモデルに何ら化の変化をもたらすと[主張しています][somsen nowit]。
  スクリプトは検証されませんが、ダウンロードされたデータはブロックヘッダーのマークルルートから
  コインベーストランザクション、そしてwitnessデータを含むコミットメントに対して検証されます。
  これにより、ノードが最初に同期された時点でデータが利用可能であり、
  破損していないことが保証されます。もし誰もデータの存在を定期的に検証しなければ、
  少なくとも１つのアルトコインで[発生したように][ripple loss]、データが失われる可能性があります。

  記事の執筆時点で、この議論は継続中でした。

## コンセンサスの変更

_Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめた月次セクション_

- **<!--quantum-computing-report-->量子コンピューターに関するレポート:**
  Clara Shikhelmanは、高速な量子コンピューターがBitcoinユーザーにもたらすリスク、
  [量子耐性][topic quantum resistance]への複数のアプローチの概要、
  Bitcoinプロトコルのアップグレードに伴うトレードオフの分析について、
  Anthony Miltonと共同執筆した[レポート][sm report]をDelving Bitcoinに[投稿しました][shikelman quantum]。
  著者らは、400万BTCから1000万BTCが量子コンピューターによる盗難の潜在的なリスクにさらされていること、
  現在ある程度の緩和策があること、Bitcoinマイニングが短期的または中期的に量子コンピューターの脅威にさらされる可能性は低いこと、
  そしてアップグレードには幅広い合意が必要であることを明らかにしています。

- **没収防止のための例外付きのトランザクションweight制限:**
  Vojtěch Strnadは、ブロック内のほとんどのトランザクションの最大weightを制限するコンセンサス変更のアイディアを
  Delving Bitcoinに[投稿しました][strnad limit]。このシンプルなルールは、
  ブロック内で400,000 weight単位（100,000 vbyte）を超えるトランザクションは、
  そのブロック内でコインベーストランザクションを除いて1つのみ許可するというものです。
  Strnadらは、トランザクションの最大weightを制限する理由を次のように述べています:

  - _ブロックテンプレートの最適化が容易:_
    [ナップサック問題][knapsack problem]に対する最適解に近い解を見つけるのは、
    全体の制限と比較してアイテムが小さいほど容易です。これはアイテムが小さいほど未使用のスペースが少なくなり、
    最終的に残るスペースが最小限に抑えられるためです。

  - _リレーポリシーの簡素化:_ ノード間の未承認トランザクションのリレーポリシーは、
    帯域幅の浪費を避けるために、どのトランザクションがマイニングされるかを予測します。
    巨大なトランザクションは、最上位の手数料率のわずかな変化でも遅延や排除につながる可能性があるため、
    正確な予測を難しくします。

  - _マイニングの集中化の回避:_ リレーフルノードがほぼすべてのトランザクションを処理できるようにすることで、
    特別なトランザクションのユーザーが[帯域外手数料][topic out-of-band fees]を支払う必要がなくなり、
    マイニングの集中化につながるリスクを回避できます。

  Gregory Sandersは、Bitcoin Coreの12年間にわたる一貫したリレーポリシーに基づき、
  例外なく最大weight制限をソフトフォークするのが合理的かもしれないと[指摘しました][sanders limit]。
  Gregory Maxwellは、ソフトフォーク前に作成されたUTXOのみを使用するトランザクションについては、
  没収を防ぐための例外を認めることができ、また[一時的なソフトフォーク][topic transitory soft forks]とすることで、
  コミュニティが更新を望まなければ制限を失効させられると[付け加え][maxwell limit]ました。

  追加の議論では、大規模なトランザクションを求める当事者（主に短期的には[BitVM][topic acc]のユーザーなど）のニーズと、
  彼らが利用可能な代替アプローチがあるかどうかが検討されました。

- **金額と時間に基づいてUTXOセットからアウトプットを削除する:**
  Robin Linusは、一定期間後に金額の小さいアウトプットをUTXOセットから削除するためのソフトフォークの提案を
  Delving Bitcoinに[投稿しました][linus dust]。このアイディアではいくつかのバリエーションが議論され、
  主に以下の2つの代替案が挙げられました:

  - _古くて経済的ではない資金を破棄する:_ 長期間使われていない少額のアウトプットは使用できなくなります。

  - _古くて経済的ではない資金の使用には存在証明を求める:_
    [utreexo][topic utreexo]や同様のシステムを使用することで、
    トランザクションは使用するアウトプットがUTXOセットの一部であることを証明できます。
    古くて[経済合理性のないアウトプット][topic uneconomical outputs]は、
    この証明を含める必要があり、新しくて多額のアウトプットはUTXOセットに引き続き保持されます。

  どちらの解決策も、UTXOセットの最大サイズを実質的に制限します（最小値と2100万ビットコインの制限を想定）。
  これを適用するために、より実用的になる可能性のあるutreexo証明の代替案など、
  設計の興味深い技術的側面がいくつか議論されました。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Core Lightning 25.05rc1][]は、この人気のLNノード実装の次期メジャーバージョンのリリース候補です。

- [LND 0.19.1-beta.rc1][]は、この人気のLNノード実装のメンテナンスバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #32582][]では、
  [コンパクトブロックの再構築][topic compact block relay]のパフォーマンスを測定するための新しいログが追加されました。
  これは、ノードがピアに要求するトランザクション（`getblocktxn`）の合計サイズ、
  ノードがピアに送信する（`blocktxn`）トランザクションの数と合計サイズを追跡し、
  `PartiallyDownloadedBlock::InitData()`の開始時にタイムスタンプを追加することで、
  mempoolのルックアップ手順のみにかかる時間（高帯域幅モードと低帯域幅モードの両方）を追跡します。
  コンパクトブロックの再構築に関する以前の統計レポートについては、ニュースレター[#315][news315 compact]をご覧ください。

- [Bitcoin Core #31375][]では、[マルチプロセス][multiprocess project]バイナリである
  `bitcoin node`（`bitcoind`）、`bitcoin gui`（bitcoinqt）、`bitcoin rpc`（`bitcoin-cli
  -named`）をラップして実行する新しい`bitcoin -m` CLIツールが追加されました。
  現在、これらはモノリシックバイナリと同様に機能しますが、
  `-ipcbind`オプション（ニュースレター[#320][news320 ipc]参照）をサポートしています。
  ただし、将来の改良により、ノードランナーが異なるマシンや環境でコンポーネントを独立して起動・停止できるようになります。
  このPRを取り上げているBitcoin Core PR Review Clubについては、ニュースレター[#353][news353 pr review]をご覧ください。

- [BIPs #1483][]は、送信者と受信者が暗号化されたPSBTをメッセージの保存と転送のみを行う
  payjoinディレクトリサーバーに渡す、非同期サーバーレス版である[payjoin v2][topic payjoin]を提案する
  [BIP77][]をマージしました。ディレクトリサーバーは、ペイロードの読み取りや変更ができないため、
  どちらのウォレットも公開サーバーをホストしたり、同時にオンラインにしたりする必要はありません。
  payjoin v2の詳細については、ニュースレター[#264][news264 payjoin]をご覧ください。

{% include snippets/recap-ad.md when="2025-06-10 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32582,31375,1483" %}
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[ripple loss]: https://x.com/JoelKatz/status/1919233214750892305
[sk nowit]: https://delvingbitcoin.org/t/witnessless-sync-for-pruned-nodes/1742/
[sk nowit gist]: https://gist.github.com/JoseSK999/df0a2a014c7d9b626df1e2b19ccc7fb1
[somsen nowit]: https://gist.github.com/JoseSK999/df0a2a014c7d9b626df1e2b19ccc7fb1?permalink_comment_id=5597316#gistcomment-5597316
[shikelman quantum]: https://delvingbitcoin.org/t/bitcoin-and-quantum-computing/1730/
[sm report]: https://chaincode.com/bitcoin-post-quantum.pdf
[strnad limit]: https://delvingbitcoin.org/t/non-confiscatory-transaction-weight-limit/1732/
[knapsack problem]: https://ja.wikipedia.org/wiki/ナップサック問題
[sanders limit]: https://delvingbitcoin.org/t/non-confiscatory-transaction-weight-limit/1732/2
[maxwell limit]: https://delvingbitcoin.org/t/non-confiscatory-transaction-weight-limit/1732/4
[linus dust]: https://delvingbitcoin.org/t/dust-expiry-clean-the-utxo-set-from-spam/1707/
[lnd 0.19.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.1-beta.rc1
[news315 compact]: /ja/newsletters/2024/08/09/#statistics-on-compact-block-reconstruction
[multiprocess project]: https://github.com/ryanofsky/bitcoin/blob/pr/ipc/doc/design/multiprocess.md
[news320 ipc]: /ja/newsletters/2024/09/13/#bitcoin-core-30509
[news264 payjoin]: /ja/newsletters/2023/08/16/#payjoin
[news353 pr review]: /ja/newsletters/2025/05/09/#bitcoin-core-pr-review-club