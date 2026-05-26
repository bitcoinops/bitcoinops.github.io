---
title: 'Bitcoin Optech Newsletter #374'
permalink: /ja/newsletters/2025/10/03/
name: 2025-10-03-newsletter-ja
slug: 2025-10-03-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoinのコンセンサスルールの変更に関する議論の要約や、
新しいリリースとリリース候補の発表、人気のBitcoinインフラストラクチャソフトウェアの注目すべき更新など、
恒例のセクションが含まれています。

## ニュース

_今週は、どの[情報源][optech sources]からも重要なニュースは見つかりませんでした。_

## コンセンサスの変更

_Bitcoinのコンセンサスルールの変更に関する提案と議論をまとめた月次セクション_

- **<!--draft-bips-for-script-restoration-->スクリプトを復元するためのBIPドラフト:** Rusty Russellは、
  新しい[Tapscript][topic tapscript]バージョンで、スクリプトの機能を復元する提案の[概要][rr0]と、
  様々な段階にある４つのBIP（[1][rr1]、[2][rr2]、[3][rr3]、[4][rr4]）を
  Bitcoin-Devメーリングリストに投稿しました。Russellは以前にもこれらのアイディアについて
  [講演][rr atx]や[記事を書いています][rr blog]。この提案は、簡単に言うと、
  より範囲を限定した提案で必要とされるトレードオフの一部を回避しながら、
  Bitcoinに（[コベナンツ][topic covenants]の機能を含む）プログラムの拡張を取り戻すことを目的としています。

  - _スクリプト実行時制約用のvaropsバジェット:_ [<!--first-->最初のBIP][rr1]はかなり完成度が高く、
    Segwitのsigopsバジェットに似たコストメトリクスをほぼすべてのスクリプト操作に割り当てることを提案しています。
    スクリプトのほとんどの操作では、コストは単純な実装により
    opcode実行中にノードのRAMに書き込まれるデータのバイト数に基づきます。sigopsバジェットとは異なり、
    各opcodeのコストは、入力のサイズに依存します。これが「varops」と名付けられた理由です。
    この統一コストモデルにより、現在ノードを過剰なスクリプト検証コストから保護するために使われている多くの制限を、
    実用的なスクリプトでは到達不可能またはほぼ不可能なレベルまで引き上げることができます。

  - _無効化されたスクリプト機能の復元（Tapscript v2）:_ [<!--second-->2つめのBIP][rr2]も、
    （参照実装を除いて）かなり完成度が高く、Bitcoinネットワークを過度なスクリプト検証コストから保護するために
    2010年に[削除された][misc changes]opcodeの復元について記述しています。
    varopsバジェットが導入されることで、これらのopcode（またはその更新版）をすべて復元でき、
    その制限を引き上げることができ、数値を任意の長さにすることができます。

  - _OP_TX:_ [<!--third-->3つめのBIP][rr3]は、新しい汎用イントロスペクションopcodeの提案です。
    `OP_TX`により、呼び出し元はトランザクションのほぼすべての要素をスクリプトスタックに取得できるようになります。
    支払いトランザクションへの直接のアクセスを可能にすることで、
    このopcodeは`OP_TEMPLATEHASH`や[`OP_CHECKTEMPLATEVERIFY`][topic op_checktemplateverify]などの
    opcodeで可能なあらゆるコベナンツ機能を実現します。

  - _Tapscript v2用の新しいopcode:_ [<!--last-->最後のBIP][rr4]は、Bitcoinが最初にローンチされた際に欠けていた、
    またはその時点では必要なかった機能を補完するする新しいopcodeを提案しています。たとえば、
    TaptreeやTaprootアウトプットを操作する機能を追加することは、Bitcoin導入時には必要ありませんでしたが、
    スクリプトが復元された世界では、これらの機能を持つことも理にかなっています。Brandon Blackは、
    Taprootアウトプットを完全に構築するために必要なopcodeが不足していることを[指摘しました][bb1]。
    提案されたopcodeのうち2つ（`OP_MULTI`と`OP_SEGMENT`）は、専用の完全なBIPが必要になりそうです。

  `OP_MULTI`は、標準のスタックアイテム数よりも多くのアイテムで動作できるように、後続のopcodeを変更します。
  たとえばスクリプトで可変数のアイテムを加算することが可能になります。これにより、
  スクリプト内でループ構造や`OP_VAULT`スタイルの遅延チェックの必要性を回避しながら、
  値のフロー制御や同様のロジックが可能になります。

  `OP_SEGMENT`（が登場した場合）は、`OP_SUCCESS`の動作を変更します。
  `OP_SUCCESS`が登場した場合、スクリプト全体が成功するのではなく、
  セグメント（スクリプトの開始から`OP_SEGMENT`が登場し、スクリプトの終了）で区切られた部分のみが成功します。
  これにより、`OP_SEGMENT`を含む必須のプレフィックスと、信頼できないサフィックスを持つスクリプトが可能になります。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 30.0rc2][]は、この完全な検証ノードソフトウェアの次期メジャーバージョンのリリース候補です。
  [バージョン30リリース候補のテストガイド][bcc30 testing]をご覧ください。

- [bdk-wallet 2.2.0][]は、ウォレットアプリケーション構築に使用されるこのライブラリのマイナーリリースです。
  アップデート適用時にイベントを返す新機能や、永続性テストのための新しいテスト機能の導入および
  ドキュメントの改善が含まれています。

- [LND v0.20.0-beta.rc1][]は、この人気のLNノード実装の新バージョンのリリース候補です。
  複数のバグ修正、再起動時のノードアナウンス設定の永続化、新しい`noopAdd`[HTLC][topic
  htlc]タイプ、[BOLT11][]インボイスでの[P2TR][topic taproot]フォールバックアドレスのサポート、
  実験的な`XFindBaseLocalChanAlias`エンドポイントおよび、その他多くの変更が導入されています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #33229][]は、プロセス間通信（IPC）（[ニュースレター
  #369][news369 ipc]参照）における自動マルチプロセス選択を実装し、
  IPC引数が渡されたり、IPC設定がされた場合に、ユーザーが起動時に`-m`オプションを指定する必要がなくなりました。
  この変更により、ブロックテンプレートの作成、管理、送信を行う
  外部の[Stratum v2][topic pooled mining]サービスとBitcoin Coreの統合が簡単になります。

- [Bitcoin Core #33446][]は、`getblock`コマンドと`getblockheader`コマンドの応答に
  `target`フィールドを追加した際（[ニュースレター #339][news339 target]参照）に発生したバグを修正しました。
  これまでは常に先端のターゲットを誤って返していましたが、要求されたブロックのターゲットを返すようになりました。

- [LDK #3838][]は、既にサポートしている`lsp_trusts_client`モデルに加えて、
  [BLIP52][] (LSPS2)（[ニュースレター #335][news335 blip]参照）で定義されている
  [JITチャネル][topic jit channels]用の`client_trusts_lsp`モデルもサポートするようになりました。
  新しいモデルでは、LSPは、受信者が[HTLC][topic htlc]の請求に必要なプリイメージを公開するまで、
  オンチェーンファンディングトランザクションをブロードキャストしません。

- [LDK #4098][]は、[BOLTs #1289][]で提案された仕様変更に合わせて、
  [スプライシング][topic splicing]トランザクションの`channel_reestablish`フローにおける
  `next_funding` TLVの実装を更新します。このPRは、
  [ニュースレター #371][news371 splicing]で取り上げられた`channel_reestablish`に関する作業に続くものです。

- [LDK #4106][]は、[非同期支払い][topic async payments]の受信者に代わってLSPが保持する[HTLC][topic htlc]が、
  LSPがHTLCを検出できないために開放されないという競合状態を修正します。これは、
  HTLCがpre-decodeマップから`pending_intercepted_htlcs`マップに移動される前に、
  LSPが`release_held_htlc`[オニオンメッセージ][topic onion messages]（ニュースレター
  [#372][news372 async]および[#373][news373 async]参照）を受信した場合に発生していました。
  LDKは、HTLCが適切に検出され開放されることを確実にするために、
  後者のマップだけでなく両方のマップをチェックするようになりました。

- [LDK #4096][]は、ピア毎のアウトバウンド[ゴシップ][topic channel
  announcements]キューのサイズ制限を24メッセージから128KBに変更しました。
  特定のピアのキューに現在格納されているバイト数の合計がこの制限を超える場合、
  そのピアへの新しいゴシップの転送はキューが空になるまでスキップされます。
  この新しい制限により、転送の失敗が大幅に減少します。特に、メッセージのサイズが変化する場合に有効です。

- [LND #10133][]は、指定されたSCIDエイリアス（[ニュースレター #203][news203 alias]参照）の
  ベースSCIDを返す実験的な`XFindBaseLocalChanAlias` RPCエンドポイントを追加します。
  このPRはまた、エイリアスの作成時に逆マッピングを永続化するようにエイリアスマネージャーを拡張し、
  新しいエンドポイントを有効にします。

- [BDK #2029][]は、`CanonicalView`構造体を導入しました。これは、
  特定のチェーンの先端におけるウォレットの`TxGraph`を一度だけ正規化します。
  このスナップショットは、後続のすべてのクエリに適用され、呼び出しのたびに再度正規化を行う必要がなくなります。
  正規化を必要としていたメソッドには現在`CanonicalView`と同等のものがあり、
  誤りのある`ChainOracle`を引数とする`TxGraph`メソッドは削除されました。
  BDKにおける以前の正規化の作業については、ニュースレター[#335][news335 txgraph]および[#346][news346 txgraph]をご覧ください。

- [BIPs #1911][]では、[BIP21][]が[BIP321][]に置き換えられたことが示され、
  [BIP321][]のステータスが`Draft`から`Proposed`に更新されました。
  [BIP321][]は、Bitcoinの支払い指示を記述するための最新のURIスキームを提案しています。
  詳細は、[ニュースレター #352][news352 bip321]をご覧ください。

{% include snippets/recap-ad.md when="2025-10-07 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33229,33446,3838,4098,4106,4096,10133,2029,1911,1289" %}
[rr0]: https://gnusha.org/pi/bitcoindev/877bxknwk6.fsf@rustcorp.com.au/
[rr1]: https://gnusha.org/pi/bitcoindev/874isonniq.fsf@rustcorp.com.au/
[rr2]: https://gnusha.org/pi/bitcoindev/871pnsnnhh.fsf@rustcorp.com.au/
[rr3]: https://gnusha.org/pi/bitcoindev/87y0q0m8vz.fsf@rustcorp.com.au/
[rr4]: https://gnusha.org/pi/bitcoindev/87tt0om8uz.fsf@rustcorp.com.au/
[rr atx]: https://www.youtube.com/watch?v=rSp8918HLnA
[rr blog]: https://rusty.ozlabs.org/2024/01/19/the-great-opcode-restoration.html
[bb1]: https://gnusha.org/pi/bitcoindev/aNsORZGVc-1_-z1W@console/
[misc changes]: https://github.com/bitcoin/bitcoin/commit/6ac7f9f144757f5f1a049c059351b978f83d1476
[bitcoin core 30.0rc2]: https://bitcoincore.org/bin/bitcoin-core-30.0/
[bcc30 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/30.0-Release-Candidate-Testing-Guide/
[bdk-wallet 2.2.0]: https://github.com/bitcoindevkit/bdk_wallet/releases/tag/wallet-2.2.0
[LND v0.20.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta.rc1
[news369 ipc]: /ja/newsletters/2025/08/29/#bitcoin-core-31802
[news339 target]: /ja/newsletters/2025/01/31/#bitcoin-core-31583
[news335 blip]: /ja/newsletters/2025/01/03/#blips-54
[news371 splicing]: /ja/newsletters/2025/09/12/#ldk-3886
[news372 async]: /ja/newsletters/2025/09/19/#ldk-4045
[news373 async]: /ja/newsletters/2025/09/26/#ldk-4046
[news203 alias]: /ja/newsletters/2022/06/08/#bolts-910
[news335 txgraph]: /ja/newsletters/2025/01/03/#bdk-1670
[news346 txgraph]: /ja/newsletters/2025/03/21/#bdk-1839
[news352 bip321]: /ja/newsletters/2025/05/02/#bips-1555
[optech sources]: /ja/internal/sources