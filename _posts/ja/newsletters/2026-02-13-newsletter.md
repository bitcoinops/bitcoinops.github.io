---
title: 'Bitcoin Optech Newsletter #392'
permalink: /ja/newsletters/2026/02/13/
name: 2026-02-13-newsletter-ja
slug: 2026-02-13-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、サイレントペイメントのスキャンパフォーマンスのワーストケースの改善に関する議論と、
単一の鍵で複数の支払い条件を可能にするアイディアを掲載しています。また、新しいリリースおよびリリース候補の発表、
人気のBitcoin基盤ソフトウェアの注目すべき更新など、恒例のセクションも含まれています。

## ニュース

- **<!--proposal-to-limit-the-number-of-per-group-silent-payment-recipients-->グループ毎のサイレントペイメント受信者数の制限提案**:
  Sebastian Falbesonerは、[サイレントペイメント][topic silent payments]受信者に対する理論的な攻撃の発見と
  その緩和策をBitcoin-Devメーリングリストに[投稿しました][kmax mailing list]。この攻撃は、
  攻撃者が同一のエンティティを標的とした多数のTaprootアウトプット（現在のコンセンサスルールでは1ブロックあたり
  最大23,255アウトプット）を持つトランザクションを構成した場合に発生します。
  グループサイズに制限がない場合、処理に数十秒ではなく、数分かかることになります。

  これを受けて、単一トランザクション内のグループ毎の受信者数を制限する新しいパラメーター
  `K_max`を追加する緩和策が提案されました。理論上、この変更には後方互換性はありませんが、
  実際には十分に大きな`K_max`を設定すれば、既存のサイレントペイメントウォレットに影響が及ぶことはないはずです。
  Falbesonerは`K_max=1000`を提案しています。

  Falbesonerは、提案された制限に対するフィードバックや懸念を求めています。
  また、ほとんどのサイレントペイメントウォレットの開発者には既に通知済みであり、
  この問題を認識しているとも述べています。

- **BLISK（Boolean circuit Logic Integrated into the Single Key）**:
  Oleksandr Kurbatovは、ブール論理を用いて複雑な認可ポリシーを表現するために設計されたプロトコルである
  BLISKについてDelving Bitcoinに[投稿しました][blisk del]。たとえば、
  [MuSig2][topic musig]のようなプロトコルは効率的でプライバシーを保護するものの、
  カーディナリティ（k-of-n）しか表現できず、「誰が」支払えるかを特定することができません。

  BLISKはシンプルなAND/ORブール回路を構成し、論理ゲートを既知の暗号技術にマッピングします。
  具体的には、ANDゲートはn-of-nマルチシグの構成を適用することで実現され、
  各参加者が有効な署名を提供する必要があります。一方、ORゲートは[ECDH][ecdh wiki]などの
  鍵合意プロトコルを活用することで実現され、参加者は誰でも自分の秘密鍵と他の参加者の公開鍵を用いて共有シークレットを導出できます。
  また、[非対話型ゼロ知識証明][nizk wiki]を適用することで、回路の解決を検証可能にし、不正行為を防止します。
  BLISKは、回路を単一の署名検証鍵に帰着させます。これは、1つの公開鍵に対して
  1つの[Schnorr][topic schnorr signatures]署名を検証すればいいことを意味します。

  他のアプローチと比較したBLISKのもう1つの重要な利点は、新しい鍵ペアを生成する必要がないことです。
  実際に、既存の鍵を特定の署名インスタンスに接続することが可能です。

  Kurbatovは、このプロトコルの[概念実証][blisk gh]を提供していますが
  フレームワークはまだ運用環境に提供できる成熟度には達していないと述べています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 29.3][]は、以前のメジャーリリースシリーズに対するメンテナンスリリースで、
  複数のウォレット移行の修正（ニュースレター[#387][news387 wallet]参照）、
  レガシースクリプトにおける二次的なsighashの影響を軽減するインプット毎のsighashの中間状態のキャッシュ（ニュースレター
  [#367][news367 sighash]参照）、コンセンサスで無効なトランザクションに対するピア排除の廃止（ニュースレター
  [#367][news367 discourage]参照）が含まれています。すべての詳細は[リリースノート][bcc29.3 rn]をご覧ください。

- [LDK 0.2.2][]は、LN対応アプリケーションを構築するためのこのライブラリのメンテナンスリリースです。
  `SplicePrototype`機能フラグを本番用の機能ビット（63）に更新し、非同期の
  `ChannelMonitorUpdate`永続化操作が再起動時にハングして強制閉鎖につながる可能性がある問題を修正し、
  ピアから無効なスプライシングメッセージを受信した際に発生するデバッグアサーション障害を修正しています。

- [HWI 3.2.0][]は、複数のハードウェア署名デバイスに共通インターフェースを提供するこのパッケージのリリースです。
  新しいリリースでは、Jade PlusやBitBox02 Novaデバイスのサポート、
  [testnet4][topic testnet]、Jade用のネイティブ[PSBT][topic psbt]署名および、
  [BIP373][]で規定された[MuSig2][topic musig] PSBTフィールドのサポートが追加されています。

- [Bitcoin Inquisition 29.2][]は、提案中のソフトフォークやその他の主要なプロトコル変更を実験するために設計された
  [signet][topic signet]フルノードのリリースです。Bitcoin Core 29.3r2をベースとし、
  このリリースでは[BIP54][]（[コンセンサスクリーンアップ][topic consensus cleanup]）提案を実装し、
  [testnet4][topic testnet]を無効化しています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #32420][]は、マイニングIPCインターフェース（[ニュースレター #310][news310 mining]参照）を更新し、
  コインベースの`scriptSig`にダミーの`extraNonce`を含めないようにしました。
  `CreateNewBlock()`に新しく`include_dummy_extranonce`オプションが追加され、
  IPCコードパスではこれに`false`が設定されます。[Stratum v2][topic pooled mining]クライアントは、
  `scriptSig`でコンセンサスで必要な[BIP34][]の高さのみを受け取り、
  余分なデータを除去したり無視したりする必要がなくなります。

- [Core Lightning #8772][]は、レガシーオニオン支払いフォーマットのサポートを削除しました。
  CLNは2022年にレガシーオニオンの作成を止めましたが（[ニュースレター #193][news193 legacy]参照）、
  LNDの旧バージョンが生成するわずかに残ったレガシーオニオンを処理するために、
  v24.05で変換レイヤーを追加していました。LND v0.18.3以降、これらは生成されなくなったため、サポートが不要になりました。
  レガシーフォーマットは2022年にBOLT仕様から削除されています（[ニュースレター #220][news220 bolts]参照）。

- [LND #10507][]は、`GetInfo` RPCレスポンスに新しい`wallet_synced`ブールフィールドを追加しました。
  これはウォレットが現在のチェーンの先端へのキャッチアップを完了したかどうかを示します。
  既存の`synced_to_chain`ブールフィールドとは異なり、この新しいフィールドはtrueを返す前に、
  （[チャネルアナウンス][topic channel announcements]を検証する）チャネルグラフルーターや、
  （ブロック駆動イベントを調整するサブシステムである）blockbeat dispatcherの同期を必要としません。

- [LDK #4387][]は、[スプライシング][topic splicing]の機能フラグを暫定ビット155から
  運用ビット63に切り替えました。LDK v0.2はビット155を使用していましたが、
  Eclairも現在のドラフト仕様より前に作られた互換性のないPhoenix固有のスプライシング実装にこのビットを使用しています。
  これにより、EclairノードがLDKノードに接続する際に自身のプロトコルでスプライシングを試行し、
  デシリアライゼーションの失敗と再接続が発生していました。

- [LDK #4355][]は、[スプライシング][topic splicing]および[デュアル・ファンディング][topic dual
  funding]チャネルのネゴシエーション中に交換されるコミットメント署名の非同期署名サポートを追加しました。
  `EcdsaChannelSigner::sign_counterparty_commitment`を受信すると、
  非同期署名者は即座にリターンし、署名の準備ができた時点で`ChannelManager::signer_unblocked`を介してコールバックします。
  デュアルファンディングチャネルで非同期署名を完全にサポートするには、まだ追加の作業が必要です。

- [LDK #4354][]は、`negotiate_anchors_zero_fee_htlc_tx`設定オプションをデフォルトでtrueに設定することで、
  [アンカーアウトプット][topic anchor outputs]を持つチャネルをデフォルトにしました。
  自動チャネル受け入れは削除され、すべてのインバウンドチャネル要求は手動で承認する必要があります。
  これにより、強制閉鎖が発生した場合に、ウォレットが手数料を賄うのに十分なオンチェーン資金を確保できるようにします。

- [LDK #4303][]は、`ChannelManager`の再起動後に[HTLC][topic htlc]が二重転送される可能性がある2つのバグを修正しました。
  1つはアウトバウンドHTLCがまだ保留中セル（内部キュー）にあるが見落とされるケース、
  もう1つは既に転送・決済されてアウトバウンドチャネルから削除されているが、
  インバウンド側の保留中セルにまだ解決エントリーが残っているケースです。
  このPRはまた、インバウンドHTLCのオニオンが取り消し不能な形で転送された後にプルーニングする処理も追加しています。

- [HWI #784][]は、[BIP327][]で規定された[MuSig2][topic musig]フィールドの
  [PSBT][topic psbt]シリアライゼーションおよびデシリアライゼーションサポートを追加しました。
  これには、インプットとアウトプットの両方に対する参加者の公開鍵、公開ナンス、部分署名が含まれます。

- [BIPs #2092][]は、[BIP434][]の`feature`メッセージに1 byteの[v2 P2Pトランスポート][topic v2 p2p
  transport]メッセージタイプIDを割り当て、開発者が競合を回避できるように
  BIP間で1 byteのIDの割り当てを追跡する補助ファイルを[BIP324][]に追加します。このファイルには、
  BIP183で提案された[Utreexo][topic utreexo]の割り当ても記録されています。

- [BIPs #2004][]は、Chain Code Delegation（[ニュースレター #364][news364 delegation]参照）に関する
  [BIP89][]を追加しました。これは協調カストディの手法であり、代理人は委任者の[BIP32][]チェーンコードを知らず、
  どのアドレスが資金を受け取ったかを知ることなく署名を生成するのに必要な情報のみを委任者と共有します。

- [BIPs #2017][]は、コンセンサスレベルでデータ伝送トランザクションフィールドを約1年間一時的に制限する提案である
  RDTS（Reduced Data Temporary Softfork）を規定する[BIP110][]を追加します。
  このルールでは、（83 byteまでのOP_RETURNを除いて）34 byteを超えるscriptPubKey、
  256 byteを超えるpushdataおよびwitnessスタック要素、未定義のwitnessバージョンの使用、
  [Taproot][topic taproot] annex、257 byteを超えるコントロールブロック、
  `OP_SUCCESS` opcodeおよび、[Tapscript][topic tapscript]内の`OP_IF`/`OP_NOTIF`が無効化されます。
  アクティベーション前に作成されたUTXOを使用するインプットは除外されます。
  アクティベーションでは、マイナーのシグナリングの閾値を55%に引き下げ、
  2026年9月頃までに強制ロックインを行う、修正版の[BIP9][]デプロイメントが使用されます。
  この提案に関する以前の記事については、[ニュースレター #379][news379 rdts]をご覧ください。

- [Bitcoin Inquisition #99][]では、[signet][topic signet]に[BIP54][]
  [コンセンサスクリーンアップ][topic consensus cleanup]ソフトフォークルールの実装が追加されました。
  実装された4つの緩和策は、トランザクション毎の潜在的に実行されるレガシーsigops数の制限、
  2時間の猶予期間によるタイムワープ攻撃の防止（および負の難易度調整インターバルの防止）、
  コインベーストランザクションのブロック高へのタイムロックの義務化および
  64 byteトランザクションの無効化です。

{% include snippets/recap-ad.md when="2026-02-17 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32420,8772,10507,4387,4355,4354,4303,784,2092,2004,2017,99" %}
[kmax mailing list]: https://groups.google.com/g/bitcoindev/c/tgcAQVqvzVg
[blisk del]: https://delvingbitcoin.org/t/blisk-boolean-circuit-logic-integrated-into-the-single-key/2217
[ecdh wiki]: https://ja.wikipedia.org/wiki/楕円曲線ディフィー・ヘルマン鍵共有
[nizk wiki]: https://en.wikipedia.org/wiki/Non-interactive_zero-knowledge_proof
[blisk gh]: https://github.com/zero-art-rs/blisk
[Bitcoin Core 29.3]: https://bitcoincore.org/bin/bitcoin-core-29.3/
[bcc29.3 rn]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-29.3.md
[Bitcoin Inquisition 29.2]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v29.2-inq
[HWI 3.2.0]: https://github.com/bitcoin-core/HWI/releases/tag/3.2.0
[LDK 0.2.2]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.2
[news387 wallet]: /ja/newsletters/2026/01/09/#bitcoin-core
[news367 sighash]: /ja/newsletters/2025/08/15/#bitcoin-core-32473
[news367 discourage]: /ja/newsletters/2025/08/15/#bitcoin-core-33050
[news310 mining]: /ja/newsletters/2024/07/05/#bitcoin-core-30200
[news193 legacy]: /ja/newsletters/2022/03/30/#c-lightning-5058
[news220 bolts]: /ja/newsletters/2022/10/05/#bolts-962
[news364 delegation]: /ja/newsletters/2025/07/25/#chain-code-withholding-for-multisig-scripts
[news379 rdts]: /ja/newsletters/2025/11/07/#temporary-soft-fork-to-reduce-data
[BIP89]: https://github.com/bitcoin/bips/blob/master/bip-0089.mediawiki
