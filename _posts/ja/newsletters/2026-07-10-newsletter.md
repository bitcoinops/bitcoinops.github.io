---
title: 'Bitcoin Optech Newsletter #413'
permalink: /ja/newsletters/2026/07/10/
name: 2026-07-10-newsletter-ja
slug: 2026-07-10-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、プルーニングノードが初期ブロックダウンロードに貢献できるようにするために
噴水符号を使用する研究を掲載しています。また、新しいリリースとリリース候補の発表や、
人気のBitcoin基盤ソフトウェアの注目すべき更新など恒例のセクションも記載しています。

## ニュース

- **IBDへの噴水符号の利用**: Lucas Limaは、プルーニングノードがストレージ要件を大幅に増やすことなく
  初期ブロックダウンロード（IBD）に貢献できるようにするための、[噴水符号][fount wiki]を使用した最新の研究について
  Delving Bitcoinに[投稿しました][fount del]。

  Limaは専用の[ブログ記事][fount blog]で、この手法の仕組みについて説明しています。
  チェーン全体をエポック(`k`個のブロックで構成される固定長のチャンク)に分割し、
  これらのエポックを噴水符号でエンコードし、ドロップレット（Droplet）と呼ばれるこれらのエンコード結果をブロックヘッダーとともに、
  チェーンを再構築する必要があるノードに送信します。バケットノードと呼ばれる受信側のノードは、
  特定のエポックに属する十分な数のドロップレットを収集してデコードすることで、元の`k`個のブロックを再構築します。
  その後、ブロックヘッダーを使用して受信データが有効であることを検証し、悪意のあるノードによる再構築されたチェーンの改ざんを防止します。

  議論の中ではいくつかの重要な懸念点も指摘されました。特に開発者からは、
  チェーンの再構築を成功させるために多数の接続ピアが必要になること、
  IBDが遅くなること、ノードのフィンガープリンティングのリスクおよびDoS攻撃対象領域が増加する可能性が挙げられました。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [Bitcoin Core 31.1][]は、主要なフルノード実装のメンテナンスリリースです。
  [トランザクションの発信元のプライバシー][topic transaction origin privacy]を損なう可能性のある
  `-privatebroadcast`のIPアドレスの漏洩を修正し([ニュースレター #409][news409 privatebroadcast] 参照)、
  chainstateデータベースのコンパクション、ウォレットのマイグレーション、インプットサイズの推定、
  [MuSig2][topic musig]の鍵集約および[v2 P2Pトランスポート][topic v2 p2p transport]の再接続時のプロキシ処理に関する修正が含まれています。
  詳細は[リリースノート][bcc31.1 rn]をご覧ください。

- [LND v0.20.2-beta][]は、この人気のLNノード実装のメンテナンスリリースです。
  DNSフォールバックのパニックとオンチェーンのフォワードインターセプターの決済バグを修正し、
  先週取り上げた最終ホップの[HTLC][topic htlc]のCLTV期限の検証を追加しています([ニュースレター #412][news412 cltv] 参照)。

## 注目すべきコードとドキュメントの更新

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #32489][]は、現在ロードされているウォレットの監視専用版を新しいウォレットファイルにエクスポートする
  `exportwatchonlywallet` RPCを追加します。エクスポートされたウォレットは、
  `restorewallet` RPCを使用して別のノードでロードできます(ニュースレター [#366][news366 watchonly]参照)。
  エクスポートされたウォレットには、元のウォレットの公開[ディスクリプター][topic descriptors]、トランザクション、
  ラベル、その他のメタデータが含まれますが、秘密鍵は含まれません。これまでは、
  ユーザーは公開ディスクリプターをインポートしてこのようなウォレットを手動で構築する必要がありました。

- [Bitcoin Core #32606][]は、[コンパクトブロックリレー][topic compact block relay]機能を更新し、
  `sendcmpct`でサポートをネゴシエートしていないピアからのコンパクトブロックメッセージ、
  `sendcmpct(1)`による高帯域幅アナウンス用にノードが選択していないピアからのコンパクトブロックメッセージおよび
  ローカルノードが`-blocksonly`モードで動作している場合のコンパクトブロックメッセージを無視するようにします。
  コンパクトブロックは受信者のmempool内のトランザクションを使用して再構築されるため、
  それらを処理すると、受信者がどのトランザクションを持っていないか、あるいはすでに持っているかが明らかになる可能性があります。
  これはblocks-onlyノードにとって特に望ましくありません。というのも、
  そのようなノードのmempool内のトランザクションはローカルで発信されたものである可能性が高いためです。

- [Bitcoin Core #34020][]は、Mining IPCインターフェースに`getTransactionsByTxID()`および
  `getTransactionsByWitnessID()`メソッドを追加します(ニュースレター [#310][news310 mining]および[#323][news323 mining] 参照)。
  各メソッドはtxidまたはwtxidのリストを受け取り、ノードのmempoolから対応するシリアライズされたトランザクションを返します。
  ノードが知らないトランザクションについては空の要素を返します。これは[Stratum v2][topic pooled mining]のカスタムジョブ宣言で有用です。
  プールは、マイナーが提案したブロックテンプレートのうち、まだ自身が持っていないトランザクションのみをリクエストしたい場合があるためです。

- [Core Lightning #9104][]および[#9292][core lightning #9292]は、
  `option_simple_close`協調閉鎖プロトコルの実験的サポートを追加します([ニュースレター #342][news342 simpleclose]参照)。
  従来の協調閉鎖では、ピア同士が単一のクローズトランザクションと手数料について合意する必要があり、
  合意できない場合、チャネルの閉鎖が行き詰まる可能性がありました。「simple close」は、
  各ピアが自分の選んだ手数料を自分自身のアウトプットから差し引いた有効なクローズトランザクションを提案できるようにすることで、
  この問題を回避します。両方のバージョンに署名してブロードキャストでき、競合するトランザクションのうち先に承認された方がチャネルを閉鎖します。
  CLNはこのフローを新しい`simpleclosed`サブデーモンに実装しており、ピアのバージョンの方が高い手数料を支払う場合には、
  自分のバージョンのブロードキャストを遅らせます。[#9292][core lightning #9292]は、
  閉鎖を開始する側の経済合理性のないアウトプットを許容されるゼロ値の`OP_RETURN`に置き換えた
  署名済みsimple-closeトランザクションをCLNが拒否し、強制閉鎖を引き起こしていたエッジケースを修正します。

- [Eclair #3323][]は、CLTV期限が2016ブロック(約2週間)より先の未来にある着信[HTLC][topic htlc]を失敗させるようにします。
  これは、送信HTLCに対するEclairの既存の最大有効期限ポリシーを拡張するもので、
  資金が長期間ロックされるリスクを軽減し、[チャネルジャミング][topic channel jamming attacks]を困難にします。
  Eclairは、問題のあるHTLCを一時的にチャネルコミットメントに受け入れてから失敗させます。
  これは、即座に拒否するとチャネルが強制閉鎖されてしまうためです。

- [LND #10832][]は、`InvoiceRequest`メッセージのサポートを追加することで、
  LNDによる[BOLT12 オファー][topic offers]の実装を進めます([ニュースレター #410][news410 bolt12] 参照)。
  新しいコードはTLVのエンコード、デコードおよび構造の検証を追加し、署名の検証と対応するオファーとの照合は後続のPRに委ねています。

{% include snippets/recap-ad.md when="2026-07-14 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32489,32606,34020,9104,9292,3323,10832" %}
[fount del]: https://delvingbitcoin.org/t/fountain-codes-a-way-to-reduce-blockchain-storage-costs/2624
[fount wiki]: https://en.wikipedia.org/wiki/Fountain_code
[fount blog]: https://lucasdbr05.com/posts/fountain-codes/
[Bitcoin Core 31.1]: https://bitcoincore.org/bin/bitcoin-core-31.1/
[bcc31.1 rn]: https://bitcoincore.org/ja/releases/31.1/
[LND v0.20.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.2-beta
[news366 watchonly]: /ja/newsletters/2025/08/08/#bitcoin-core-pr-review-club
[news310 mining]: /ja/newsletters/2024/07/05/#bitcoin-core-30200
[news323 mining]: /ja/newsletters/2024/10/04/#bitcoin-core-30510
[news342 simpleclose]: /ja/newsletters/2025/02/21/#bolts-1205
[news410 bolt12]: /ja/newsletters/2026/06/19/#lnd-10789
[news409 privatebroadcast]: /ja/newsletters/2026/06/12/#bitcoin-core-35410
[news412 cltv]: /ja/newsletters/2026/07/03/#lnd-10927
