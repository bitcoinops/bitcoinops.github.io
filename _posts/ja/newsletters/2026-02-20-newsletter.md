---
title: 'Bitcoin Optech Newsletter #393'
permalink: /ja/newsletters/2026/02/20/
name: 2026-02-20-newsletter-ja
slug: 2026-02-20-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、最近のOP_RETURNの使用状況に関するまとめ、
コンセンサスを変更することなくコベナンツのような使用条件を強制するプロトコルについて掲載しています。
また、サービスとクライアントソフトウェアの最近の更新や、新しいリリースおよびリリース候補の発表、
人気のBitcoin基盤ソフトウェアの最近の更新など、恒例のセクションも含まれています。

## ニュース

- **最近のOP_RETURNアウトプットの統計**: Anthony Townsは、
  Bitcoin Core v30.0のリリース（10月10日）以降のOP_RETURNの統計について
  Delving Bitcoinに[投稿しました][post op_return stats]。このリリースには、
  OP_RETURNアウトプットに対するmempoolポリシー制限の変更（複数のOP_RETURNアウトプットの許可、
  OP_RETURNアウトプットにおける最大100kBまでのデータの許可）が含まれていました。
  彼が調査したブロック高の範囲は、915800から936000までで、以下の結果が得られました:

  - OP_RETURNアウトプットを含むトランザクション：24,362,310件

  - 複数のOP_RETURNアウトプットを持つトランザクション：61件

  - OP_RETURNアウトプットのスクリプトの合計サイズが83 byteを超えるトランザクション：396件

  - 期間中のOP_RETURNアウトプットのスクリプトデータの合計は473,815,552 byte（そのうち、大きなOP_RETURNSの割合は0.44%）

  - OP_RETURNアウトプットでsatsを焼却しているトランザクションは34,283件で、焼却されたsatsの合計は、1,463,488 sats

  - OP_RETURNのデータが43〜83 byteのトランザクションは949,003件で、42 byte以下のトランザクションは23,412,911件

  Townsはまた、大きなOP_RETURNアウトプットを持つ396件のトランザクションのサイズの頻度分布を示すチャートも掲載しました。
  これらのトランザクションの50%は、OP_RETURNのデータが210 byte未満でした。また10%はOP_RETURNのデータが10KBを超えていました。

  彼はその後、MurchがXで[同様の分析][murch twitter]とOP_RETURN統計の[ダッシュボード][murch dashboard]を公開したこと、
  OrangesurfがMempool Research向けにOP_RETURNに関する[レポート][orangesurf report]を公開したことを追記しました。

- **Bitcoin PIPEs v2**: Misha Komarovは、コンセンサスの変更や楽観的なチャレンジメカニズムを必要とせずに
  使用条件を強制できるプロトコルであるBitcoin PIPEsについてDelving Bitcoinに[投稿しました][pipes del]。

  Bitcoinプロトコルは、最小限のトランザクション検証モデルに基づいており、
  これは使用されるUTXOが有効なデジタル署名によって認可されていることを検証するものです。
  そこでBitcoin PIPEsは、Bitcoin Scriptで表現される使用条件に依存する代わりに、
  有効な署名を生成できるかどうかの前提条件を追加します。言い換えれば、
  秘密鍵が事前に定められた条件に基づいて暗号的にロックされます。条件が満たされた場合にのみ、
  秘密鍵が明らかになり、有効な署名が提供できるようになります。Bitcoinプロトコルは、
  1つの[Schnorr署名][topic schnorr signatures]を検証するだけで済み、
  条件ロジックはすべてオフチェーンで処理されます。

  形式的に、Bitcoin PIPEsは主に2つのフェーズで構成されます:

  - *<!--setup-->セットアップ*: 標準的なBitcoinの鍵ペア`(sk, pk)`が生成されます。
    次に`sk`は、witness encryptionを用いて使用条件ステートメントに基づいて暗号化されます。

  - *<!--signing-->署名*: ステートメントにwitness `w`が提供されます。
    `w`が有効な場合、`sk`が明らかになりSchnorr署名が生成できます。そうでない場合は、
    `sk`の復元は計算量的に不可能です。

  Komarovによると、Bitcoin PIPEsは、[コベナンツ][topic covenants]のセマンティクスを再現するために使用できます。
  特に、[Bitcoin PIPEs V2][pipes v2 paper]は、限定的な使用条件にフォーカスしており、
  バイナリコベナンツを強制します。このモデルは、有効なゼロ知識証明の提供や、
  exit条件の充足、Fraud Proofの存在など、結果がバイナリ（二値）である幅広い有用な条件を自然に捉えます。
  基本的に、すべての「条件が満たされているか否か？」という単一の問いに帰着します。

  最後に、Komarovは新しいopcodeの代わりにPIPEsを活用する方法と、
  [BitVM][topic acc]プロトコルの楽観的な検証フローを改善するためにPIPEsをどのように活用できるかについて、
  実際の例を示しました。

## サービスとクライアントソフトウェアの更新

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **SecondがhArkベースのArkソフトウェアをリリース:**
  Secondの[Ark][topic ark]ライブラリは、バージョン[0.1.0-beta.6][second 0.1.0 beta6]で
  hArk（ハッシュロックArk）を使用するようにアップデートされました。この新しいプロトコルは、
  ラウンド中のユーザーの同期的な対話要件を排除しますが、それに伴うトレードオフも存在します。
  このリリースには、互換性を破る変更を含むその他のアップデートも含まれています。

- **AmbossがRailsXを発表:**
  [RailsXの発表][amboss blog]では、LNと[Taproot Assets][topic client-side validation]を使用して
  スワップやその他のさまざまな金融サービスをサポートするプラットフォームの概要が説明されています。

- **Nunchukがサイレントペイメントのサポートを追加:**
  Nunchukが、[サイレントペイメント][topic silent payments]アドレスへの送金のサポートを[発表しました][nunchuk post]。

- **Electrumがサブマリンスワップ機能を追加:**
  [Electrum 4.7.0][electrum release notes]では、ライトニング残高を使ったオンチェーン支払い（
  [サブマリンスワップ][topic submarine swaps]参照）など、さまざまな機能追加と修正が行われました。

- **Sigbash v2発表:**
  [Sigbash v2][sigbash post]では、[MuSig2][topic musig]やWebAssembly（WASM）、
  ゼロ知識証明を使用し、共同署名サービスのプライバシーを強化しています。詳しくは、
  Sigbashに関する[以前の記事][news298 sigbash]をご覧ください。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [BTCPay Server 2.3.5][]は、このセルフホスト型ペイメントソリューションのマイナーリリースです。
  ダッシュボードに複数の仮想通貨ウォレットの残高ウィジェット、チェックアウト用のカスタムテキストボックス、
  新しい為替レートプロバイダーが追加され、いくつかのバグが修正されています。

- [LND 0.20.1-beta][]は、この人気のLNノード実装のメンテナンスリリースです。
  ゴシップメッセージ処理にpanicリカバリー機能を追加し、再編成保護を強化し、
  LSP検出ヒューリスティックを実装し、複数のバグと競合状態を修正しています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #33965][]は、起動時の設定`-blockreservedweight`
  （[ニュースレター #342][news342 weight]参照）が
  マイニングIPCクライアント（[ニュースレター #310][news310 mining]参照）によって設定された
  `block_reserved_weight`値を密かに上書きしてしまうバグを修正しました。今後は、
  IPC呼び出し元が後者を設定した場合、それが優先されます。この値を設定しないRPC呼び出し元は、
  起動時の`-blockreservedweight`設定が常に適用されます。このPRはまた、
  IPC呼び出し元に`MINIMUM_BLOCK_RESERVED_WEIGHT`を強制し、それを下回る値の設定を防止します。

- [Eclair #3248][]は、[HTLC][topic htlc]の転送時に両方の選択肢がある場合、
  パブリックチャネルよりもプライベートチャネルを優先するようになりました。これにより、
  ネットワークで可視であるパブリックチャネルにより多くの流動性が確保されます。
  2つのチャネルが同じ可視性を持つ場合、Eclairは残高がより少ないチャネルを優先するようになりました。

- [Eclair #3246][]は、いくつかの内部イベントに新しいフィールドを追加しました。
  `TransactionPublished`では、単一の`miningFee`フィールドが`localMiningFee`と
  `remoteMiningFee`に分割され、計算された`feerate`と、トランザクションを
  [流動性の購入][topic liquidity advertisements]に紐付ける
  オプションの`LiquidityAds.PurchaseBasicInfo`が追加されました。
  チャネルライフサイクルイベントには、チャネルタイプを記述する`commitmentFormat`が含まれるようになり、
  `PaymentRelayed`には`relayFee`が追加されました。

- [LDK #4335][]は、[BOLT12オファー][topic offers]を使用したファントムノード支払い（
  [ニュースレター #188][news188 phantom]参照）の初期サポートを追加しました。
  [BOLT11][]版では、インボイスに存在しない「ファントム」ノードを指すルートヒントが含まれ、
  各パスの最後のホップが[ステートレスインボイス][topic stateless invoices]を使用して
  支払いを受け入れることができる実際のノードでした。[BOLT12][]版では、
  単純にオファーに各参加ノードで終端する複数の[ブラインドパス][topic rv routing]が含まれます。
  現在の実装では、複数のノードがインボイスリクエストに応答できますが、
  結果として生成されるインボイスは応答したノードにのみ支払われます。

- [LDK #4318][]は、`ChannelHandshakeLimits`構造体から`max_funding_satoshis`フィールドを削除し、
  [wumbo][topic large channels]以前のデフォルトのチャネルサイズ制限を事実上撤廃しました。
  LDKは、既にデフォルトで`option_support_large_channels`機能フラグを通じて
  [ラージチャネル][topic large channels]のサポートを通知しており、
  以前の設定と競合することでピアに対して誤ったサポートシグナルを送る可能性がありました。
  リスクを制限したいユーザーは手動チャネル承認フローを使用できます。

- [LND #10542][]は、ゴシップv1.75（ニュースレター[#261][news261 gossip]および
  [#326][news326 gossip]参照）をサポートするために、グラフデータベース層を拡張し、
  [Simple Taproot Channel][topic simple taproot channels]の
  [チャネルアナウンス][topic channel announcements]を保存および取得できるようになりました。
  ゴシップv1.75は、バリデーションおよびゴシップサブシステムの完成を待って、
  ネットワークレベルでは無効のままです。

- [BIPs #1670][]は、Pay-to-Merkle-Root（P2MR）を規定する[BIP360][]を追加しました。
  これは、[P2TR][topic taproot]と同様に動作しますがkeypath支払いが削除された新しいアウトプットタイプです。
  P2MRアウトプットは、公開鍵ではなくスクリプトツリーのマークルルート（SHA256ハッシュ）に直接コミットするため、
  暗号学的に意味のある量子コンピューター（CRQC）による長時間露出攻撃に耐性があります。
  ただし、トランザクションが未承認の間に秘密鍵を復元するような短時間露出攻撃に対する保護には、
  別途ポスト量子署名の提案が必要です。提案がP2QRHと呼ばれていた頃の以前の記事については[ニュースレター #344][news344 p2qrh]を、
  P2TSHと呼ばれていた頃の記事は[ニュースレター #385][news385 bip360]をご覧ください。

- [BOLTs #1236][]は、[デュアルファンディング][topic dual funding]の仕様を更新し、
  チャネルの確立中にどちらのノードも`tx_init_rbf`を送信できるようにしました。
  これにより、両者がファンディングトランザクションの[手数料の引き上げ][topic rbf]を行えるようになります。
  これまでは、チャネル開設者のみがこれを行えましたが、この変更により
  （どちらの側からも既にRBFを開始できる）[スプライシング][topic splicing]と整合するようになりました。
  このPRはまた、`tx_init_rbf`および`tx_ack_rbf`の送信者が以前の試行から少なくとも1つのインプットを再利用することを必須とし、
  新しいトランザクションがすべての以前の試行を二重使用することを保証します。

- [BOLTs #1289][]は、[デュアルファンディング][topic dual funding]と
  [スプライシング][topic splicing]の両方で使用される対話型のトランザクションプロトコルにおいて、
  再接続時の`commitment_signed`の再送方法を変更しました。これまでは、
  ピアが既に受信済みであっても、再接続時に`commitment_signed`は常に再送されていました。
  今後は、`channel_reestablish`に明示的なビットフィールドが含まれ、
  ノードがまだ必要な場合にのみ`commitment_signed`を要求できるようになります。
  これにより不要な再送が回避され、特に将来の
  [Simple Taproot Channel][topic simple taproot channels]において重要になります。
  これは再送にはノンスの変更に伴う完全な[MuSig2][topic musig]署名ラウンドが必要になるためです。

{% include snippets/recap-ad.md when="2026-02-24 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33965,3248,3246,4335,4318,10542,1670,1236,1289" %}

[post op_return stats]: https://delvingbitcoin.org/t/recent-op-return-output-statistics/2248
[pipes del]: https://delvingbitcoin.org/t/bitcoin-pipes-v2/2249
[pipes v2 paper]: https://eprint.iacr.org/2026/186
[second 0.1.0 beta6]: https://docs.second.tech/changelog/changelog/#010-beta6
[amboss blog]: https://amboss.tech/blog/railsx-first-lightning-native-dex
[nunchuk post]: https://x.com/nunchuk_io/status/2021588854969414119
[electrum release notes]: https://github.com/spesmilo/electrum/blob/master/RELEASE-NOTES
[news298 sigbash]: /ja/newsletters/2024/04/17/#sigbash
[sigbash post]: https://x.com/arbedout/status/2020885323778044259
[BTCPay Server 2.3.5]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.5
[LND 0.20.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.1-beta
[news342 weight]: /ja/newsletters/2025/02/21/#bitcoin-core-31384
[news310 mining]: /ja/newsletters/2024/07/05/#bitcoin-core-30200
[news188 phantom]: /ja/newsletters/2022/02/23/#ldk-1199
[news261 gossip]: /ja/newsletters/2023/07/26/#updated-channel-announcements
[news326 gossip]: /ja/newsletters/2024/10/25/#updates-to-the-version-1-75-channel-announcements-proposal-1-75
[news344 p2qrh]: /ja/newsletters/2025/03/07/#bip360-p2qrh-pay-to-quantum-resistant-hash
[news385 bip360]: /ja/newsletters/2025/12/19/#quantum
[murch dashboard]: https://dune.com/murchandamus/opreturn-counts
[murch twitter]: https://x.com/murchandamus/status/2022930707820269670
[orangesurf report]: https://research.mempool.space/opreturn-report/
