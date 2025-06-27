---
title: 'Bitcoin Optech Newsletter #360'
permalink: /ja/newsletters/2025/06/27/
name: 2025-06-27-newsletter-ja
slug: 2025-06-27-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、P2Pプロトコルのメッセージを使ったフルノードのフィンガープリンティングに関する研究と、
BIP380のディスクリプター仕様におけるBIP32パスで`H`のサポートを削除する可能性についてのフィードバックについて掲載しています。
また、Bitcoin Stack Exchangeで人気の質問とその回答のまとめや、
新しいリリースとリリース候補の発表、人気のBitcoinインフラストラクチャソフトウェアの注目すべき更新など
恒例のセクションも掲載しています。

## ニュース

- **`addr`メッセージを使用したノードのフィンガープリンティング:** Daniela Brozzoniは、
  開発者のNaiyomaと共に行った研究についてDelving Bitcoinに[投稿しました][brozzoni addr]。
  この研究では、ノードが送信する`addr`（アドレス）メッセージを使用して、
  複数のネットワーク上で同じノードを識別することができました。
  ノードは、P2Pプロトコルの`addr`（アドレス）メッセージをピアに送信することで、
  他の潜在的なノードをアナウンスし、ピアが分散型のゴシップシステムを使用してお互いを見つけられるようにしています。
  しかし、BrozzoniとNaiyomaは、個々のノード固有のアドレスメッセージの詳細を使ってフィンガープリンティングを行い、
  複数のネットワーク（IPv4と[Tor][topic anonymity networks]など）上で動作する同一ノードを識別することに成功しました。

  研究者らは、２つの可能な緩和策を提案しています: アドレスメッセージからタイムスタンプを削除するか、
  タイムスタンプを残す場合は、特定のノードに固有にならないようにタイムスタンプをわずかにランダム化することです。

- **ディスクリプターで`H`を使用しているソフトウェアはありますか？** Ava Chow は、
  強化導出の[BIP32][topic bip32]鍵導出ステップを示すために大文字のHを使ってディスクリプターを生成するソフトウェアがあるかどうかを
  Bitcoin-Devメーリングリストで[尋ねました][chow hard]。もしない場合は、
  [アウトプットスクリプトディスクリプター][topic descriptors]の[BIP380][]仕様は、
  強化導出を示すために小文字のhと`'`のみを使用するように変更される可能性があります。
  Chowは、BIP32では大文字のHが許可されているものの、BIP380には以前、
  大文字のHの使用を禁止するテストが含まれており、Bitcoin Coreは現在大文字のHを受け入れていないことを指摘しています。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Bitcoin Knotsノードをピアとしてブロックする方法はありますか？]({{bse}}127456)
  Vojtěch Strnadは、Bitcoin Coreの2つのRPCを使って
  ユーザーエージェントの文字列に基づいてピアをブロックする方法を提供していますが、
  この方法は推奨されておらず、同様の非推奨事項を指摘する関連する[Bitcoin CoreのGitHubの課題][Bitcoin Core #30036]も示されています。

- [OP_CATは整数をどのように処理しますか？]({{bse}}127436)
  Pieter Wuilleは、Bitcoin Scriptのスタック要素にはデータの型情報が含まれておらず、
  opcodeによってスタック要素のbyteの解釈方法が異なると指摘しています。

- [コンパクトブロックリレーによる非同期ブロックリレー（BIP152）について]({{bse}}127420)
  ユーザーbca-0353f40eは、Bitcoin Coreの[コンパクトブロック][topic compact block relay]の処理を概説し、
  欠落したトランザクションがブロックの伝播に与える影響を推定しています。

- [<!--why-is-attacker-revenue-in-selfish-mining-disproportional-to-its-hash-power-->セルフィッシュマイニングにおける攻撃者の収益がハッシュパワーに不相応なのはなぜですか？]({{bse}}53030)
  Antoine Poinsotは、これと[別の]({{bse}}125682) 古い[セルフィッシュマイニング][topic selfish mining]の質問をフォローアップし、
  「難易度調整はステイルブロックを考慮しないため、競合するマイナーの実効ハッシュレートを下げると、
  （十分に長い時間スケールで）自身のハッシュレートを増加させるのと同じくらいマイナーの利益を増加させる」
  と指摘しています（[ニュースレター #358][news358 selfish mining]参照）。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 28.2][]は、主要なフルノード実装の以前のリリースシリーズのメンテナンスリリースです。
  これには複数のバグ修正が含まれています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #31981][]は、プロセス間通信（IPC）`Mining`インターフェース（ニュースレター [#310][news310 ipc]参照）に
  `checkBlock`メソッドを追加します。このメソッドは、`proposal`モードの`getblocktemplate`
  RPCと同じ有効性チェックを実行します。これにより、[Stratum v2][topic pooled mining]を使用するマイニングプールは、
  最大4MBのJSONをRPC経由でシリアライズするのではなく、
  より高速なIPCインターフェースを介してマイナーから提供されたブロックテンプレートを検証できるようになります。
  Proof-of-Workとマークルルートのチェックはオプションで無効化できます。

- [Eclair #3109][]は、[失敗の帰属][topic attributable failures]のサポート（
  ニュースレター[#356][news356 failures]参照）を[トランポリンペイメント][topic trampoline payments]に拡張しました。
  トランポリンノードは、自身に割り当てられた帰属のペイロードの一部を復号して保存し、
  残りのBLOBを次のトランポリンホップ用に準備するようになりました。このPRは、
  トランポリンノードの帰属データのリレーを実装していません。これは後続のPRで予定されています。

- [LND #9950][]は、`DescribeGraph`および`GetNodeInfo`、`GetChanInfo` RPCと
  それらに対応する`lncli`コマンドに新しい`include_auth_proof`フラグを追加します。
  このフラグを含めると、[チャネルアナウンス][topic channel announcements]の署名が返され、
  サードパーティソフトウェアによるチャネルの詳細な検証が可能になります。

- [LDK #3868][]は、タイミングフィンガープリンティングを軽減するため、
  [失敗の帰属][topic attributable failures]（ニュースレター[#349][news349 attributable]参照）のペイロードの
  [HTLC][topic htlc]のホールド時間の精度を1ミリ秒単位から100ミリ秒単位に削減します。
  これにより、LDKは[BOLTs #1044][]ドラフトの最新のアップデートに準拠します。

- [LDK #3873][]は、[スプライシング][topic splicing]の更新を伝播できるようにするため、
  ファンディングアウトプットが使用された後にSCID（Short Channel Identifier）を忘れるまでの遅延を
  12ブロックから144ブロックに引き上げます。これは、Eclairが実装した[BOLTs #1270][]で導入された
  72ブロックの遅延（ニュースレター[#359][news359 eclair]参照）の2倍です。
  このPRでは、`splice_locked`メッセージ交換プロセスにも追加の変更が実装されています。

- [Libsecp256k1 #1678][]は、ライブラリのすべてのオブジェクトファイルを公開する
  `secp256k1_objs` CMakeインターフェースライブラリを追加し、
  Bitcoin Coreで計画されている[libbitcoinkernel][libbitcoinkernel project]などの親プロジェクトから
  これらのオブジェクトを自分の静的ライブラリに直接リンクできるようにします。
  これは、CMakeが静的ライブラリを別のライブラリにリンクするネイティブなメカニズムを欠いている問題を解決し、
  下流ストリームのユーザーが独自の`libsecp256k1`バイナリを提供する必要をなくします。

- [BIPs #1803][]は、すべての一般的な強化導出パスマーカーを許可することで、
  [BIP380][]の[ディスクリプター][topic descriptors]の文法を明確にし、
  [#1871][bips #1871]、[#1867][bips #1867]および[#1866][bips #1866]は、
  key-pathルールを厳格化し、参加者の鍵の繰り返しを許可し、マルチパス子導出を明示的に制限することで、
  [BIP390][]の[MuSig2][topic musig]ディスクリプターを改良します。

{% include snippets/recap-ad.md when="2025-07-01 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31981,3109,9950,3868,3873,1678,1803,1871,1867,1866,30036,1044,1270" %}
[bitcoin core 28.2]: https://bitcoincore.org/bin/bitcoin-core-28.2/
[brozzoni addr]: https://delvingbitcoin.org/t/fingerprinting-nodes-via-addr-requests/1786/
[chow hard]: https://mailing-list.bitcoindevs.xyz/bitcoindev/848d3d4b-94a5-4e7c-b178-62cf5015b65f@achow101.com/T/#u
[news358 selfish mining]: /ja/newsletters/2025/06/13/#calculating-the-selfish-mining-danger-threshold
[news310 ipc]: /ja/newsletters/2024/07/05/#bitcoin-core-30200
[news356 failures]: /ja/newsletters/2025/05/30/#eclair-3065
[news349 attributable]: /ja/newsletters/2025/04/11/#ldk-2256
[news359 eclair]: /ja/newsletters/2025/06/20/#eclair-3110
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/27587
