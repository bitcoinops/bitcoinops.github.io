---
title: 'Bitcoin Optech Newsletter #336'
permalink: /ja/newsletters/2025/01/10/
name: 2025-01-10-newsletter-ja
slug: 2025-01-10-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、マイナーに影響を与えるBitcoin Coreの潜在的な影響と、
コントラクトレベルの相対的タイムロックの作成に関する議論、
オプションのペナルティを持つLN-Symmetryバージョンの提案を掲載しています。
また、新しいリリースとリリース候補の発表や、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **Bitcoin Coreのバグを修正する前にマイニングプールの動作を調査:**
  Abubakar Sadiq Ismailは、2021年にAntoine Riardによって発見された、
  ノードがブロックテンプレートでコインベーストランザクション用に
  本来の1,000 vbyteではなく2,000 vbyteを確保してしまう[バグ][bitcoin core #21950]について
  Delving Bitcoinに[投稿しました][ismail double]。この2倍の確保がなくなれば、
  各テンプレートにはさらに約5件の小規模なトランザクションを含めることができます。
  しかしその場合、2倍の確保に依存しているマイナーが無効なブロックを生成し、
  大きな収入減につながる可能性があります。Ismailは、過去のブロックを分析し、
  どのマイニングプールがリスクにさらされているかを判断しました。
  彼は、Ocean.xyzとF2Poolおよび未知のマイナーが非デフォルトの設定を使っている可能性があるものの、
  バグが修正されても、いずれも損失を被るリスクはないようです。
  ただし、リスクを最小化するため、現在、コインベース用に2,000 vbyteをデフォルトで確保する
  新しい起動オプションの導入が提案されています。後方互換性を必要としないマイナーは、
  確保を1,000 vbyte（必要な量が少ない場合はそれ以下）に簡単に削減することができます。

  Jay Beddictは、このメッセージをMining-Devメーリングリストに[伝えました][beddict double]。

- **<!--contract-level-relative-timelocks-->コントラクトレベルの相対的タイムロック:**
  Gregory Sandersは、約1年前に[LN-Symmetry][topic eltoo]の概念実証の実装を作成した際に発見した
  （[ニュースレター #284][news284 deltas]参照）複雑な問題の解決策をDelving Bitcoinに[投稿しました][sanders clrt]。
  このプロトコルでは、各チャネルの状態をオンチェーンで承認することができますが、
  期限前に承認された最後の状態のみがチャネル資金を分配できます。
  通常、チャネルの参加者は最新の状態の承認のみを試みます。ただし、
  アリスがトランザクションに部分署名しそれをボブに送信して新しい状態への更新を開始した場合、
  そのトランザクションを完成させることができるのはボブだけです。もしボブがその時点で動作しなくなると、
  アリスは最後から2つめの状態でしかチャネルを閉じることができません。
  ボブがアリスの最後から2つめの状態が期限に達するまで待ち、それから最終状態を承認すると、
  チャネルを解決するのに期限の約2倍の時間がかかります。これは、_遅延時間2倍問題_ と呼ばれます。
  つまり、LN-Symmetryにおける[HTLC][topic htlc]の[タイムロック][topic timelocks]は、
  最大2倍の長さにする必要があり、攻撃者が（[チャネルジャミング攻撃][topic channel jamming attacks]や
  その他の問題によって）転送ノードが資本から収入を得るのを防止しやすくなります。

  Sandersは、コントラクトの決済に必要なすべてのトランザクションに適用される相対的タイムロックで問題を解決することを提案しています。
  LN-Symmetryにそのような機能があり、アリスが最後から2つめの状態を承認た場合、
  ボブは最後から2つめの状態の期限前に最後の状態を承認する必要があります。
  [その後の投稿][sanders tpp]で、SandersはJohn Lawによるチャネルプロトコル（[ニュースレター
  #244][news244 tpp]参照）へのリンクを示しています。このプロトコルは、
  2つのトランザクションレベルの相対的タイムロックを使用して、
  コンセンサスを変更することなくコントラクトレベルの相対的なタイムロックを提供します。
  ただし、これは各状態が前の状態を使用するLN-Symmetryでは機能しません。

  Sandersは、解決策を概説していますが、そこには欠点があることを指摘しています。
  彼はまた、Chiaの`coinid`機能を使用してこの問題を解決する方法についても言及しています。
  これは、John Lawの2021年のIIDs（Inherited Identifiers）のアイディアに似ています。
  Jeremy Rubinは、彼が昨年提案した、それを作成したトランザクションと同じブロックで使用する必要がある
  _muon_ アウトプットのリンクと、それがどのように解決に貢献できるかを[示しました][rubin muon]。
  Sandersは、Chiaブロックチェーンの`coinid`機能について言及し、
  Anthony Townsはそれを[詳しく説明し][towns coinid]、
  必要なデータを一定量まで削減する方法を示しました。Salvatore Ingalaは、
  開発者のRijndaelから学んだ[OP_CAT][topic op_cat]を使用した同様の仕組みについて[投稿しました][ingala cat]。
  Rijndaelはその後[詳細を説明しました][rijndael cat]。Brandon Blackは、
  LN-Symmetryのペナルティベースのバージョンという代替タイプの解決策について[説明し][black penalty]、
  それに関するDaniel Robertsの研究を引用しました（次のニュース項目参照）。

- **公開される更新を制限するためのペナルティを伴うマルチパーティLN-Symmetryバージョン**
  Daniel Robertsは、悪意あるチャネルの取引相手（マロリー）が、
  正直な取引相手（ボブ）が最終状態の承認に支払っている手数料率よりも高い手数料率で故意に古い状態をブロードキャストすることで、
  チャネルの決済を遅らせることを防止する方法についてDelving Bitcoinに[投稿しました][roberts sympen]。
  理論上、ボブはマロリーの古い状態を最新の状態に再バインドでき、両方のトランザクションが同じブロックで承認されると、
  マロリーは手数料のお金を失い、ボブはもともと支払うつもりだった同じ手数料で最終状態を承認することになります。
  ただし、マロリーが、古い状態のブロードキャストを承認する前にそれをボブに知られないようにできれば、
  チャネル内の[HTLC][topic htlc]が期限切れになりマロリーが資金を盗むことができるまで、
  ボブが反応するのを阻止できます。

  Robertsは、チャネル参加者が1つの状態のみを承認できるスキームを提案しました。
  後の状態が承認された場合、最終状態を送信した参加者と、どの状態も送信しなかった参加者は、
  古い状態を送信した参加者の資金を奪うことができます。

  残念ながら、このスキームを公開した後、Robertsは重大な欠陥を発見し、自ら公開しました。
  _遅延時間2倍問題_ と同様に、最後に署名した参加者は、他の参加者が完了できない状態を完了できるため、
  最終署名者に現在の最終状態への排他的アクセス権が与えられます。他の参加者が前の状態で閉じようとした場合、
  最終署名者が最終状態を使用するとその参加者は損失を被ることになります。

  Robertsは、代替アプローチを調査していますが、このトピックは、
  LN-Symmetryにペナルティの仕組みを追加することが有用かどうかについて興味深い議論を巻き起こしました。
  LN-Symmetryの概念実証の実装によりペナルティの仕組みは不要であると考えるようになったGregory Sanders（
  [ニュースレター #284][news284 sympen]参照）は、古い状態を繰り返す攻撃は、
  [置換サイクル攻撃][topic replacement cycling]に似ていると指摘しました。
  彼は、「この攻撃は非常に弱い。たとえ防御側のリソースがそこそこで、
  マイナーがどのようなトランザクションを承認しようとしているかを全く把握していない場合でも、
  攻撃者は非常に簡単に負のEV[期待値]に追い込まれる可能性があるからだ」と考えています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 28.1][]は、主要なフルノード実装のメンテナンスリリースです。

- [BDK 0.30.1][]は、バグ修正を含む以前のリリースシリーズのメンテナンスリリースです。
  プロジェクトは、先週のニュースレターで発表された[移行ガイド][bdk migration]が提供されている
  BDKウォレット1.0.0へのアップグレードを推奨しています。

- [LDK v0.1.0-beta1][]は、LN対応ウォレットやアプリケーションを構築するためのこのライブラリのリリース候補です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #28121][]は、`testmempoolaccept` RPCコマンドのレスポンスに新しい`reject-details`
  フィールドを追加しました。これは、コンセンサスまたはポリシー違反によりトランザクションが
  mempoolから拒否される場合のみ含まれます。エラーメッセージは、
  `sendrawtransaction`でトランザクションが同様に拒否された場合に返されるものと同じです。

- [BDK #1592][]では、重要な変更を文書化するためにADR（Architectural Decision Record）を導入し、
  対処した問題、決定要因、検討した代替案、長所と短所、最終決定について概説しています。
  これにより、新規参加者はリポジトリの歴史に慣れることができます。このPRは、ADRテンプレートと
  最初の2つのADRを追加しています。1つは`bdk_chain`から`persist`モジュールを削除するもので、
  もう1つは`BDKWallet`をラップする新しい`PersistedWallet`型を導入するものです。

{% include snippets/recap-ad.md when="2025-01-14 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28121,1592,21950" %}
[bitcoin core 28.1]: https://bitcoincore.org/bin/bitcoin-core-28.1/
[ldk v0.1.0-beta1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.0-beta1
[bdk migration]: https://bitcoindevkit.github.io/book-of-bdk/getting-started/migrating/
[ismail double]: https://delvingbitcoin.org/t/analyzing-mining-pool-behavior-to-address-bitcoin-cores-double-coinbase-reservation-issue/1351
[beddict double]: https://groups.google.com/g/bitcoinminingdev/c/aM9SDXSMZDs
[sanders clrt]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/
[news284 deltas]: /ja/newsletters/2024/01/10/#expiry-delta
[sanders tpp]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/2
[news244 tpp]: /ja/newsletters/2023/03/29/#preventing-stranded-capital-with-multiparty-channels-and-channel-factories
[rubin muon]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/3
[towns coinid]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/7
[ingala cat]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/8
[rijndael cat]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/11
[black penalty]: https://delvingbitcoin.org/t/contract-level-relative-timelocks-or-lets-talk-about-ancestry-proofs-and-singletons/1353/12
[roberts sympen]: https://delvingbitcoin.org/t/broken-multi-party-eltoo-with-bounded-settlement/1364/
[news284 sympen]: /ja/newsletters/2024/01/10/#penalties
[bdk 0.30.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.30.1