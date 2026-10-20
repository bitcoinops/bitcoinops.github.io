---
title: 'Bitcoin Optech Newsletter #396'
permalink: /ja/newsletters/2026/03/13/
name: 2026-03-13-newsletter-ja
slug: 2026-03-13-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin Scriptを利用した衝突耐性ハッシュ関数と、
ライトニングネットワークのトラフィック分析に関する継続議論について掲載しています。
また、新しいリリースとリリース候補の発表や、人気のBitcoin基盤ソフトウェアの注目すべき更新など、
恒例のセクションも含まれています。

## ニュース

- **Bitcoinスクリプト用の衝突耐性ハッシュ関数**: Robin Linusは、
  Bitcoin Scriptを使用した新しい衝突耐性ハッシュ関数であるBinohashについてDelving Bitcoinに[投稿しました][bino del]。
  共有された[論文][bino paper]でLinusは、Binohashは新たなコンセンサスの変更を必要とせずに
  限定的なトランザクションイントロスペクションを可能にすると述べています。これにより、
  [BitVM][topic acc]ブリッジのようなプロトコルは、信頼できるオラクルに依存することなく、
  [コベナンツ][topic covenants]のような機能を備えたトラストレスなイントロスペクションを実現できます。

  提案されたハッシュ関数は、２段階のプロセスを経てトランザクションダイジェストを間接的に生成します:

  - トランザクションフィールドの固定: トランザクションフィールドは、
    支払人が複数の署名パズルを解くことを要求することで固定されます。
    各パズルは、`W1` bitの作業を必要とするため、不正な改変を計算コスト的に高価にします。

  - ハッシュの導出: ハッシュは、レガシーな`OP_CHECKMULTISIG`における`FindAndDelete`の挙動を利用して計算されます。
    `n`個の署名でナンスプールが初期化されます。支払人は、`t`個の署名からなるサブセットを生成し、
    `FindAndDelete`を使ってプールから除去した後、残りの署名のsighashを計算します。
    このプロセスは、sighashが要件に合致するパズル署名を生成するまで繰り返されます。
    結果として得られるダイジェスト、すなわちBinohashは、勝利したサブセットの`t`個のインデックスで構成されます。

  この出力ダイジェストは、Bitcoinアプリケーションに関連する3つの特性を備えています。
  Bitcoin Script内で完全に抽出および検証できること、約84 bitの衝突耐性があること、
  そして[ランポート署名][lamport wiki]が可能であるため、BitVMプログラム内でコミットできることです。
  これらの特性により、開発者は既存のスクリプトプリミティブのみを使用して、
  現在のオンチェーン上でトランザクションデータに関する推論を行うプロトコルを構築できます。

- **Gossip Observerトラフィック分析ツールに関する議論の続き**: 11月に、
  Jonathan Harvey-Buschelは、Gossip Observerを[発表しました][news 381 gossip observer]。
  これはLNのゴシップトラフィックを収集し、メッセージフラッディングを
  セット・リコンシリエーションベースのプロトコルに置き換えることを評価するためのメトリクスを計算するツールです。

  それ以降、Rusty Russellらがスケッチの最適な送信方法についての[議論に参加しました][gossip observer delving]。
  具体的には、メッセージのセットキーとしてブロック番号をサフィックスとして使用することで
  `GETDATA`の往復を省略し、受信者が関連するブロックコンテキストを既に推測できる場合に
  不要なリクエスト/レスポンスの交換を回避するというものです。

  これに対し、Harvey-Buschelは、稼働中のGossip Observerのバージョンを[更新し][gossip observer github]、
  引き続きデータを収集しています。彼は１日あたりの平均メッセージ数の分析、
  検出されたコミュニティのモデルおよび伝搬遅延を[投稿しました][gossip observer update]。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [BDK wallet 3.0.0-rc.1][]は、ウォレットアプリケーション構築用ライブラリの新しいメジャーバージョンのリリース候補です。
  主な変更点としては、再起動後も保持されるUTXOロック、チェーンの更新時に返される構造化ウォレットイベント、
  mainnetとtestnetを区別するためのAPI全体での`NetworkKind`の採用などが挙げられます。
  またこのリリースでは、Caravanウォレット形式（[ニュースレター #77][news77 caravan]参照）の
  インポート/エクスポート機能と、バージョン1.0より前のSQLiteデータベース用の移行ユーティリティも追加されています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #26988][]は、`-addrinfo` CLIコマンド（[ニュースレター #146][news146 addrinfo]参照）を更新し、
  品質や新しさによってフィルタリングされたサブセットではなく、既知のアドレスの完全なセットを返すようになりました。
  内部的には、`getnodeaddresses` RPC（[ニュースレター #14][news14 rpc]参照）の代わりに
  `getaddrmaninfo` RPC（[ニュースレター #275][news275 addrmaninfo]参照）が使用されます。
  返されるカウントは、アウトバウンドピアの選択に使用されるフィルタリングされていないセットと一致するようになりました。

- [Bitcoin Core #34692][]は、4 GiB以上のRAMを搭載した64-bitシステムにおけるデフォルトの`dbcache`を
  450 MiBから1 GiBに増やし、それ以外の場合は450 MiBにフォールバックします。この変更は
  `bitcoind`のみに影響し、カーネルライブラリはデフォルトとして450 MiBを維持します。

- [LDK #4304][]は、[HTLC][topic htlc]の転送をリファクタリングし、
  転送毎に複数の着信および送信HTLCをサポートすることで、
  [トランポリン][topic trampoline payments]ルーティングの基盤を整備しました。
  通常の転送とは異なり、トランポリンノードは両側で[MPP][topic
  multipath payments]エンドポイントとして機能できます。つまり、着信HTLCのパーツを蓄積し、
  次のホップへの経路を見つけ、複数の送信HTLCに転送を分割します。
  新しい`HTLCSource::TrampolineForward`が、トランポリン転送のすべてのHTLCを追跡します。
  請求と失敗は適切に処理され、チャネルモニターのリカバリは再起動時にトランポリン転送の状態を再構築するように拡張されました。

- [LDK #4416][]は、両方のピアが同時に[スプライシング][topic splicing]を開始しようとした場合に、
  アクセプターが資金を拠出できるようにし、スプライシングにおける
  [デュアル・ファンディング][topic dual funding]のサポートを実質的に追加しました。
  両側が開始した場合、[静止状態][topic channel commitment upgrades]のタイブレークにより
  一方がイニシエーターとして選択されます。これまではイニシエーターのみが資金を追加でき、
  アクセプターは自身の資金を追加するために次のスプライシングを待つ必要がありました。
  アクセプターはイニシエーターになる準備をしていたため、
  その手数料は（共通のトランザクションフィールドをカバーする）イニシエーターレートからアクセプターレートに調整されます。
  `splice_channel` APIは、最大手数料率をターゲットにするための`max_feerate`パラメーターも受け付けるようになりました。

- [LND #10089][]は、[ニュースレター #377][news377 onion]のメッセージタイプとRPCを基盤として、
  [オニオンメッセージ][topic onion messages]の転送サポートを追加しました。
  オニオンの内部ペイロードをデコードする`OnionMessagePayload`ワイヤータイプと、
  復号と転送の判断を処理するピア毎のアクターを導入しています。この機能は
  `--protocol.no-onion-messages`フラグで無効化できます。
  これはLNDの[BOLT12オファー][topic offers]サポートに向けたロードマップの一部です。

- [Libsecp256k1 #1777][]は、新しい`secp256k1_context_set_sha256_compression()`
  APIを追加し、アプリケーションが実行時にカスタムSHA256圧縮関数を提供できるようにしました。
  このAPIにより、起動時にCPU機能を検出するBitcoin Coreなどの環境が、
  ライブラリを再コンパイルすることなく、libsecp256k1のハッシュ処理を
  ハードウェアアクセラレーションされたSHA256にルーティングできます。

- [BIPs #2047][]は、[サイレントペイメント][topic silent payments]ウォレット用の
  [ディスクリプター][topic descriptors]を定義した[BIP392][]を公開しました。
  新しい`sp()`ディスクリプターは、[BIP352][]で規定された[P2TR][topic taproot]アウトプットである
  サイレントペイメントアウトプットのスキャンと使用方法をウォレットソフトウェアに指示します。
  １つのKEY式を引数として取る形式は、単一の[bech32m][topic bech32]鍵を受け取ります。
  監視専用のスキャン秘密鍵と使用公開鍵をエンコードする`spscan`、
  またはスキャンと使用の両方の秘密鍵をエンコードする`spspend`です。
  ２つの引数を取る`sp(KEY,KEY)`では、最初の式としてスキャン秘密鍵を受け取り、
  ２つめの式として使用鍵を受け取り、使用鍵は公開鍵または秘密鍵のいずれかで、
  [BIP390][]による[MuSig2][topic musig]集約鍵もサポートしています。
  最初のメーリングリストでの議論については、[ニュースレター #387][news387 sp]をご覧ください。

- [BOLTs #1316][]は、[BOLT12オファー][topic offers]において、
  `offer_amount`が存在する場合はゼロより大きくなければならないことを明確にしました。
  ライターは`offer_amount`をゼロより大きい値に設定しなければならず、
  リーダーは金額がゼロのオファーに応答してはなりません。無効なゼロ金額のオファーのテストベクターが追加されました。

- [BOLTs #1312][]は、無効な[bech32][topic bech32]パディングを持つ[BOLT12][topic offers]オファーの
  テストベクターを追加し、そのようなオファーは[BIP173][]のルールに従って拒否されなければならないことを明確にしました。
  この問題は、ライトニング実装間の差分ファジングを通じて発見され、CLNとLDKが無効なパディングを持つオファーを受け入れていた一方、
  EclairとLightning-KMPは正しく拒否していたことが判明しました。
  LDKの修正については[ニュースレター #390][news390 bech32]をご覧ください。

{% include snippets/recap-ad.md when="2026-03-17 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="26988,34692,4304,4416,10089,1777,2047,1316,1312" %}

[bino del]: https://delvingbitcoin.org/t/binohash-transaction-introspection-without-softforks/2288
[bino paper]: https://robinlinus.com/binohash.pdf
[lamport wiki]: https://ja.wikipedia.org/wiki/ランポート署名
[news146 addrinfo]: /ja/newsletters/2021/04/28/#bitcoin-core-21595
[news275 addrmaninfo]: /ja/newsletters/2023/11/01/#bitcoin-core-28565
[news14 rpc]: /en/newsletters/2018/09/25/#bitcoin-core-13152
[news377 onion]: /ja/newsletters/2025/10/24/#lnd-9868
[news387 sp]: /ja/newsletters/2026/01/09/#bip
[news390 bech32]: /ja/newsletters/2026/01/30/#ldk-4349
[news77 caravan]: /ja/newsletters/2019/12/18/#unchained-capital-caravan
[BDK wallet 3.0.0-rc.1]: https://github.com/bitcoindevkit/bdk_wallet/releases/tag/v3.0.0-rc.1
[gossip observer delving]: https://delvingbitcoin.org/t/gossip-observer-new-project-to-monitor-the-lightning-p2p-network/2105
[gossip observer update]: https://delvingbitcoin.org/t/gossip-observer-new-project-to-monitor-the-lightning-p2p-network/2105/23
[gossip observer github]: https://github.com/jharveyb/gossip_observer
[news 381 gossip observer]: /ja/newsletters/2025/11/21/#ln
