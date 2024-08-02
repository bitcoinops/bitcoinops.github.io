---
title: 'Bitcoin Optech Newsletter #314'
permalink: /ja/newsletters/2024/08/02/
name: 2024-08-02-newsletter-ja
slug: 2024-08-02-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、旧バージョンのBitcoin Coreに影響する2つの脆弱性の開示の発表と、
クラスターmempool使用時にマイナーのトランザクションの選択を最適化するために提案されたアプローチを掲載しています。
また、新しいリリースとリリース候補の発表や、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **Bitcoin Core 0.21.0以前のバージョンに影響する脆弱性の開示:**
  Niklas Göggeは、少なくとも2022年10月以降にサポートが終了したBitcoin Coreのバージョンに影響する
  2つの脆弱性の発表のリンクをBitcoin-Devメーリングリストに[投稿しました][goegge disclosure]。
  これは先月公開された古い脆弱性の公開（[ニュースレター #310][news310 disclosure]参照）に続くものです。
  以下に開示内容をまとめます:

  - [大量の`addr`メッセージの送信によるリモートクラッシュ][Remote crash by sending excessive `addr` messages]:
    （2021年8月にリリースされた）Bitcoin Core 22.0より前のバージョンでは、2<sup>32</sup>個より多くの他の可能性のあるノードについて通知されたノードは、
    32 bitのカウンターの枯渇によりクラッシュしていました。これは攻撃者が大量の`addr` P2Pメッセージ（
    少なくとも400万件のメッセージ）を送信することで、実現できます。
    Eugene Siegelが責任を持って脆弱性を[開示し][topic responsible disclosures]、
    Bitcoin Core 22.0に修正が組み込まれました。修正の内容については、
    [ニュースレター #159][news159 bcc22387]をご覧ください。
    これは脆弱性にパッチを当てたことを知らずに書かれています。

  - [UPnPが有効になっている場合のローカルネットワークでのリモートクラッシュ][Remote crash on local network when UPnP enabled]:
    Bitcoin Core 22.0より前のバージョンでは、[NATトラバーサル][NAT traversal]を自動的に構成するために[UPnP][]を有効にしたノードは（
    以前の脆弱性のためデフォルトで無効になっています。[ニュースレター #310][news310 miniupnpc]参照）、
    UPnPメッセージの一種を繰り返し送信するローカルネットワーク上の悪意あるデバイスに対して脆弱でした。
    各メッセージにより、ノードがクラッシュするかオペレーティングシステムによって終了されるまで、
    追加のメモリが割り当てられる可能性があります。Bitcoin Coreと依存関係のあるminiupnpcの無限ループバグは、
    Ronald Huveneersによってminiupnpcプロジェクトに報告され、
    Michael Fordがこれを発見し、Bitcoin Coreをクラッシュさせる方法を責任をもって開示しました。
    修正は、Bitcoin Core 22.0に含まれていました。

  Bitcoin Coreの以降のバージョンに影響する追加の脆弱性は、数週間以内に開示される予定です。

- **クラスターmempoolを使用したブロック構築の最適化:** Pieter Wuilleは、
  [クラスターmempool][topic cluster mempool]を使用する際に、
  マイナーのブロックテンプレートに最善のトランザクションのセットが含まれるようにする方法についてDelving
  Bitcoinに[投稿しました][wuille selection]。
  クラスターmempoolの設計では、関連するトランザクションの _クラスター_ は、
  _チャンク_ の順序付きリストに分割され、各チャンクは2つの制約に従います:

  1. チャンク内のトランザクションが他の未承認トランザクションに依存する場合、
     それらのトランザクションはチャンクの一部か、
     順序付けられたチャンクのリスト内の前のチャンクに出現する必要があります。

  2. 各チャンクは、順序付けされたリストの中でその後に来るチャンクと同等かそれ以上の手数料率を持たなければなりません。

  これにより、mempool内のすべてのクラスターのすべてのチャンクを、
  手数料率の順（最も高いものから最も低いもの）に並べた1つのリストに配置できます。
  チャンク化されたmempoolが手数料率順に並んでいる場合、マイナーは各チャンクを反復処理して、
  希望する最大ブロックweight（通常、マイナーのコインベーストランザクションのためのスペースを残すために、
  100万vbyteの制限を少し下回ります）に達するまで、それをテンプレートに含めるだけでブロックテンプレートを構築することができます。

  ただし、クラスターとチャンクのサイズはさまざまで、Bitcoin Coreのクラスターのデフォルトの上限は、
  約10万vbyteと予想されます。これは、マイナーが998,000 vbyteをターゲットとしてブロックテンプレートを構築し、
  その内899,001 vbyteが既に埋まっている場合、99,000 vbyteのチャンクに遭遇しても適合しないため、
  ブロックスペースの10%が未使用のままになる可能性があることを意味します。
  マイナーは99,000 vbyteのチャンクを単純にスキップして、その次のチャンクを含めることはできません。
  その次のチャンクに99,000 vbyteに依存するトランザクションが含まれている可能性があるためです。
  マイナーがブロックテンプレートに依存するトランザクションを含めなかった場合、
  そのテンプレートから生成されるブロックはすべて無効になります。

  このエッジケースの問題を回避するために、Wuilleは、大きなチャンクを、
  手数料率に基づいて残りのブロックスペースに含めるかどうかを検討できる小さな _サブチャンク_ に分割する方法を説明しています。
  サブチャンクは、2つ以上のトランザクションを持つ既存のチャンクまたはサブチャンクの最後のトランザクションを削除するだけで作成できます。
  これにより、元のチャンクよりも小さいサブチャンクが少なくとも1つ生成され、
  場合によっては複数のサブチャンクが生成されます。Wuilleは、チャンクとサブチャンクの数がトランザクションの数と等しく、
  各トランザクションは一意のチャンクまたはサブチャンクに属することを実証しています。
  これにより、各トランザクションのチャンクまたはサブチャンクを事前に計算し、
  それを _アブソープション・セット_ と呼び、トランザクションに関連付けることができます。
  Wuilleは、既存のチャンク化アルゴリズムが各トランザクションのアブソープション・セットを既に計算している方法を示しています。

  マイナーがテンプレートを可能なかぎりすべてのチャンクで埋めたら、
  ブロックにまだ含まれていないトランザクションについて事前計算されたアブソープション・セットを取り出し、
  それらを手数料率順に検討することができます。これに必要なのは、
  mempool内のトランザクションと同じ数（現在のデフォルトでは、ほとんどの場合100万未満）の要素を持つリストに対する
  1回のソート操作のみです。その後、最適な手数料率のアブソープション・セット（チャンクとサブチャンク）を使用して、
  残りのブロックスペースを埋めることができます。そのためには、
  クラスターからこれまでに含まれているトランザクションの数を追跡し、
  適合しないサブチャンクや一部のトランザクションが既に含まれているサブチャンクをスキップする必要があります。

  ただし、チャンクを相互に比較してブロックに含めるための最適な順序は提供できますが、
  チャンクまたはサブチャンク内の個々のトランザクションが、
  それらのトランザクションの一部のみを含めるための最適な順序になっているとは限りません。
  ブロックがほぼいっぱいになると、最適でない選択につながる可能性があります。たとえば、
  300 vbyteしか残っていない場合に、アルゴリズムは、
  4 sats/vbyteの150 vbyteのトランザクション（合計12,00 sats）2つではなく、
  5 sats/vbyteの200 vbyteのトランザクション（合計1,000 sats）を選択する可能性があります。

  Wuilleは、事前計算されたアブソープション・セットがこの場合に役立つ理由を説明しています。
  アブソープション・セットは、これまでに含まれているクラスターからのトランザクションの数を追跡するだけでよいため、
  テンプレート補充アルゴリズムを以前に状態に復元し、以前の選択を別の選択に置き換えて、
  より多くの手数料を徴収できるかどうかを簡単に確認できます。これにより、
  最後のブロックスペースを埋めるさまざまな組み合わせを試して、
  単純なアルゴリズムよりも良い結果を見つけることができる[分枝限定][branch-and-bound]検索を実装できます。

- **Bitcoin P2Pネットワーク用のHyperionネットワークイベントシミュレーター:**
  Sergi Delgadoは、シミュレートされたBitcoinネットワークを通じてデータがどのように伝播するかを追跡する、
  彼が作成したネットワークシミュレーターである[Hyperion][]についてDelving Bitcoinに[投稿しました][delgado hyperion]。
  この研究は、Bitcoinの現在のトランザクションの通知（`inv` inventoryメッセージ）をリレーする方法と、
  提案されている[Erlay][topic erlay]による方法を比較したいという思いから始まりました。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BDK 1.0.0-beta.1][]は、「安定した1.0.0 APIを備えた`bdk_wallet`の最初のベータ版」のリリース候補です。

## 注目すべきコードとドキュメントの変更

_今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #30515][]は、`scantxoutset` RPCコマンドのレスポンスの追加フィールドとして、
  UTXOのブロックハッシュと承認数を追加します。これにより、特に再編成が起こり得るため、
  ブロック高だけよりも、UTXOのブロックのより信頼性の高い識別子が提供されます。

- [Bitcoin Core #30126][]では、[クラスターmempool][topic cluster mempool]プロジェクトの一環として、
  リニアライゼーションを作成または改善するために、関連トランザクションのクラスター上で動作する
  [クラスターリニアライゼーション][wuille cluster]関数`Linearize`を導入しました。
  クラスターリニアライゼーションは、クラスターのトランザクションをブロックテンプレートに追加する際の手数料を最大化する順序（
  または、完全なmempoolから退去させる際の手数料損失を最小化する順序）を提案します。
  これらの機能はまだmempoolに統合されていないため、このPRで動作の変更はありません。

- [Bitcoin Core #30482][]は、切り捨てられたもしくは大きすぎるtxidを拒否して`HTTP_BAD_REQUEST`パースエラーを投げることで、
  `getutxos` RESTエンドポイントのパラメーター検証を改善します。以前もこれは失敗していましたが、密かに処理されていました。

- [Bitcoin Core #30275][]は、`estimatesmartfee` RPCコマンドのデフォルトモードを
  保守的なモードから経済的なモードに変更します。この変更は、[手数料を推定する][topic fee estimation]際に
  保守的なモードは経済的なモードよりも短期的な手数料市場の下落に反応しにくいため、
  トランザクション手数料の過払いにつながることが多いというユーザーと開発者の観察に基づいています。

- [Bitcoin Core #30408][]は、次のRPCのコマンド、`decodepsbt`、`decoderawtransaction`、`decodescript`、
  `getblock`（verbosity=3の場合）、`getrawtransaction`（verbosity=2,3の場合）、`gettxout`のヘルプテキストで、
  `scriptPubKey`を指す言葉を「public key script」から「output script」に置き換えます。
  これは提案中のBIPでトランザクションの用語（ニュースレター[#246][news246 bipterminology]参照）として使用されているのと同じ表現です。

- [Core Lightning #7474][]は、[オファー][topic offers]プラグインを更新し、
  オファー、インボイスリクエスト、インボイスで使用されるTLV（Type-Length-Value）タイプの
  新しく定義された実験的な範囲に対応できるようになりました。これは、BOLTリポジトリにマージされていない
  [BOLT12のプルリクエスト][bolt12 pr]に最近追加されました。

- [LND #8891][]は、外部の[手数料推定][topic fee estimation]APIソースから予想される応答に新しい
  `min_relay_fee_rate`を追加し、サービスが最小リレー手数料率を指定できるようにしました。
  指定されていない場合は、デフォルトの`FeePerKwFloor`である1012 sats/kvB (1.012 sats/vbyte)が使用されます。
  このPRでは、手数料の推定が完全に初期化される前に呼び出された場合に、
  `EstimateFeePerKW`からエラーを返すことで起動時の信頼性も向上します。

- [LDK #3139][]は、[ブラインドパス][topic rv routing]の使用を認証することでBOLT12
  [オファー][topic offers]のセキュリティを向上させます。この認証がないと、
  攻撃者のマロリーは、ボブのオファーを受け取り、ネットワーク上の各ノードにインボイスを要求し、
  そのうちのどれがボブのものかを判別できるため、ブラインドパスを使用するプライバシーの利点が無効になります。
  この問題を解決するために、オファーの暗号化されていないメタデータではなく、
  オファーの暗号化されたブラインドパスに128 bitのnonceが含まれるようになりました。
  この変更により、以前のバージョンで作成された空でないブラインドパスを持つアウトバウンドの支払いや、
  払い戻しは無効になります。一方、以前のバージョンで作成されたオファーは引き続き有効ですが、
  匿名化解除攻撃に対して脆弱であるため、ユーザーはこのパッチを含むLDKのバージョンに更新した後で
  オファーを再生成することをお勧めします。

- [Rust Bitcoin #3010][]では、`sha256::Midstate`に長さフィールドが導入され、
  SHA256ダイジェストをインクリメンタルに生成する際のハッシュの状態をより柔軟かつ正確に追跡できるようになりました。
  この変更は、以前の`Midstate`構造に依存していた既存の実装に影響を与える可能性があります。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30515,30126,30482,30275,30408,7474,8891,3139,3010" %}
[BDK 1.0.0-beta.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.1
[wuille selection]: https://delvingbitcoin.org/t/cluster-mempool-block-building-with-sub-chunk-granularity/1044
[branch-and-bound]: https://ja.wikipedia.org/wiki/分枝限定法
[delgado hyperion]: https://delvingbitcoin.org/t/hyperion-a-discrete-time-network-event-simulator-for-bitcoin-core/1042
[hyperion]: https://github.com/sr-gi/hyperion
[news310 disclosure]: /ja/newsletters/2024/07/05/#bitcoin-core-0-21-0
[Remote crash by sending excessive `addr` messages]: https://bitcoincore.org/ja/2024/07/31/disclose-addrman-int-overflow/
[news159 bcc22387]: /ja/newsletters/2021/07/28/#bitcoin-core-22387
[news310 miniupnpc]: /ja/newsletters/2024/07/05/#miniupnpc
[Remote crash on local network when UPnP enabled]: https://bitcoincore.org/ja/2024/07/31/disclose-upnp-oom/
[upnp]: https://ja.wikipedia.org/wiki/Universal_Plug_and_Play
[nat traversal]: https://ja.wikipedia.org/wiki/NAT_traversal
[wuille cluster]: https://delvingbitcoin.org/t/introduction-to-cluster-linearization/1032
[goegge disclosure]: https://mailing-list.bitcoindevs.xyz/bitcoindev/bf5287e8-0960-45e8-9c90-64ffc5fdc9aan@googlegroups.com/
[news246 bipterminology]: /ja/newsletters/2023/04/12/#bip
[bolt12 pr]: https://github.com/lightning/bolts/pull/798