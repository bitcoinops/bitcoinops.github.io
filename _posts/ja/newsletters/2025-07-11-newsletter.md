---
title: 'Bitcoin Optech Newsletter #362'
permalink: /ja/newsletters/2025/07/11/
name: 2025-07-11-newsletter-ja
slug: 2025-07-11-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、QRコードで使用するためにアウトプットスクリプトディスクリプターを
圧縮できる新しいライブラリについて掲載しています。また、Bitcoin Core PR Review Clubミーティングの概要や、
新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき更新など、
恒例のセクションも含まれています。

## ニュース

- **<!--compressed-descriptors-->圧縮ディスクリプター:** Josh Domanが
  [アウトプットスクリプトディスクリプター][topic descriptors]をバイナリ形式にエンコードして
  サイズを約40%削減する[ライブラリ][descriptor-codec]をDelving Bitcoinで[発表しました][dorman descom]。
  これはディスクリプターをQRコードを使ってバックアップするのに便利です。
  彼の投稿では、エンコード方法の詳細が説明されており、
  この圧縮機能を暗号化ディスクリプターバックアップライブラリ（[ニュースレター #358][news358 descencrypt]参照）に
  組み込む予定であると言及されています。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Improve TxOrphanage denial of service bounds][review club 31829]は、
[glozow][gh glozow]によるPRで、`TxOrphanage`の排除ロジックを変更し、
各ピアに少なくとも最大サイズ1パッケージ分のオーファンの解決に必要なリソースを保証するようにします。
この新しい保証により、[1P1C（1-parent-1-child）パッケージリレー][1p1c relay]が大幅に改善され、
特に（ただしこれに限定されませんが）敵対的な状況下で顕著になります。

このPRは、既存のグローバルなオーファン制限を変更し、ピア毎に新しい制限を導入します。
これらを組み合わせることで、過剰なメモリの使用と計算能力の枯渇の両方から保護します。
また、このPRはランダムな排除アプローチを、アルゴリズムによるアプローチに置き換え、
ピア毎にDoSスコアを計算します。

_注: このPRはReview Clubのミーティング以降に、[いくつかの重要な変更が行われています][review club 31829 changes]。
最も重要なのは、アナウンスの制限ではなくレイテンシースコア制限を使用していることです。_

{% include functions/details-list.md
  q0="現在のTxOrphanageのグローバル最大サイズ制限である100トランザクションとランダムな排除には、なぜ問題があるのですか？"
  a0="悪意のあるピアがオーファントランザクションを大量にノードに送りつけ、
  最終的に他のピアからの正当なトランザクションをすべて排除させてしまう可能性があります。
  これは、子がオーファン状態に長く留まることができなくなり、1P1Cトランザクションリレーの成功を阻止するのに使用できます。"
  a0link="https://bitcoincore.reviews/31829#l-12"
  q1="<!--how-does-the-new-eviction-algorithm-work-at-a-high-level-->新しい排除アルゴリズムはどのように機能しますか？"
  a1="排除はランダムではなくなります。新しいアルゴリズムは、
  「DoSスコア」に基づいて「最も動作の悪い」ピアを特定し、
  そのピアから送られた最も古いトランザクションの通知を排除します。
  これにより、動作不良のピアによって正常な動作のピアのトランザクションの子が排除されるのを防ぎます。"
  a1link="https://bitcoincore.reviews/31829#l-19"
  q2="<!--why-is-it-desirable-to-allow-peers-to-exceed-their-individual-limits-while-the-global-limits-are-not-reached-->グローバル制限に達していない間、ピアが個別の制限を超えるのを許可するのが望ましいのはなぜですか？"
  a2="ピアがより多くのリソースを使用しているのは、単にそのピアがCPFPなどの有用なトランザクションをブロードキャストしている
  有用なピアである可能性があります。"
  a2link="https://bitcoincore.reviews/31829#l-25"
  q3="<!--the-new-algorithm-evicts-announcements-instead-of-transactions-what-is-the-difference-and-why-does-it-matter-->新しいアルゴリズムはトランザクションではなくアナウンスを排除します。その違いは何で、なぜ重要なのですか？"
  a3="アナウンスは、トランザクションとそれを送信したピアのペアです。アナウンスを排除することで、
  悪意あるピアは、正直なピアから送信されたトランザクションを排除できなくなります。"
  a3link="https://bitcoincore.reviews/31829#l-34"
  q4="ピアの「DoS」スコアとは何ですか？どのように計算されますか？"
  a4="ピアのDoSスコアは、「メモリスコア」（メモリ使用量/メモリ確保量）と
  「CPUスコア」（アナウンス回数/アナウンス制限）の最大値です。
  単一の複合スコアを使用することで、排除ロジックが単一のループに簡素化され、
  いずれかの制限を最も積極的に超過しているピアをターゲットにできます。"
  a4link="https://bitcoincore.reviews/31829#l-133"
%}

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [LND v0.19.2-beta.rc2][]は、この人気のLNノードのメンテナンスバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Core Lightning #8377][]は、[BOLT11][]インボイスのパース要件を厳格化し、
  [ペイメントシークレット][topic payment secrets]が欠落している場合、またはp（ペイメントハッシュ）、
  h（説明ハッシュ）、s（シークレット）などの必須フィールドの長さが正しくない場合、
  送信者にインボイスへの支払いをしないように義務付けています。これらの変更は、
  最近の仕様の更新（ニュースレター[#350][news350 bolts]および[#358][news358 bolts]参照）に合わせて行われました。

- [BDK #1957][]は、トランザクション履歴、マークルプルーフおよびブロックヘッダーの要求に対するRPCバッチ処理を導入し、
  Electrumバックエンドを使用したフルスキャンと同期のパフォーマンスを最適化します。
  このPRはまた、同期中にSPV（Simple Payment Verification）の再検証（ニュースレター[#312][news312 spv]参照）をスキップするためのアンカーキャッシュも追加されています。
  サンプルデータを使用した結果、作者はフルスキャン時にRPC呼び出しのバッチ処理により8.14秒から2.59秒、
  同期時にキャッシュ処理により1.37秒から0.85秒のパフォーマンスの向上を確認しました。

- [BIPs #1888][]は、[BIP380][]から強化導出パスのマーカーとして`H`を削除し、
  標準的な`h`と`'`のみを残しました。最近のニュースレター[#360][news360 bip380]では、
  文法が明確化され3つのマーカーすべてが使用可能になったと掲載していましたが、
  実際にはこれをサポートしているディスクリプター実装は（あったとしても）ほとんどないため
  （Bitcoin Coreもrust-miniscriptもサポートしていません）、
  仕様が厳格化され使用不可となりました。

{% include snippets/recap-ad.md when="2025-07-15 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8377,1957,1888" %}
[LND v0.19.2-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.2-beta.rc2
[news358 descencrypt]: /ja/newsletters/2025/06/13/#descriptor-encryption-library
[dorman descom]: https://delvingbitcoin.org/t/a-rust-library-to-encode-descriptors-with-a-30-40-size-reduction/1804
[descriptor-codec]: https://github.com/joshdoman/descriptor-codec
[news350 bolts]: /ja/newsletters/2025/04/18/#bolts-1242
[news358 bolts]: /ja/newsletters/2025/06/13/#bolts-1243
[news312 spv]: /ja/newsletters/2024/07/19/#bdk-1489
[news360 bip380]: /ja/newsletters/2025/06/27/#bips-1803
[review club 31829]: https://bitcoincore.reviews/31829
[gh glozow]: https://github.com/glozow
[review club 31829 changes]: https://github.com/bitcoin/bitcoin/pull/31829#issuecomment-3046495307
[1p1c relay]: /ja/bitcoin-core-28-wallet-integration-guide/#1p1cone-parent-one-childリレー
