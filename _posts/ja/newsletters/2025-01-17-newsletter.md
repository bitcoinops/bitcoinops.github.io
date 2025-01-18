---
title: 'Bitcoin Optech Newsletter #337'
permalink: /ja/newsletters/2025/01/17/
name: 2025-01-17-newsletter-ja
slug: 2025-01-17-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、取引可能なecashシェアでプールマイナーに報酬を与えることについての継続的な議論と、
DLCのオフチェーン解決を可能にする新しい提案を掲載しています。また、
新しいリリースとリリース候補の発表や、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **取引可能なecachシェアでプールマイナーに報酬を与えることについての継続的な議論:**
  [プールマイナー][topic pooled mining]が提出したシェア毎にecashを支払うことについての
  Delving Bitcoinスレッドでの[以前の要約][news304 ecashtides]以降、[議論][ecash tides]が続いています。
  以前、Matt Coralloは、通常のecashのミントを使用して（またはLNを介して）マイナーに支払うだけで済むのに、
  なぜプールが取引可能なecashシェアを処理するために追加のコードと計算を実装するのかと[質問しました][corallo whyecash]。
  David Caseriaは、[TIDES][recap291 tides]のような一部の[PPLNS][topic pplns]（_Pay Per Last N Shares_）方式では、
  マイナーはプールが複数のブロックを見つけるのを待つ必要があり、
  小規模なプールの場合は数日または数週間かかる可能性があると[回答しました][caseria pplns]。
  それを待つ代わりに、ecashのシェアを持つマイナーは、それをオープンマーケットですぐに販売できます（
  プールや第三者に自分のIDに関する情報を開示することなく、マイニング時に使用した一時的なIDさえも開示する必要がありません）。

  Caseriaはまた、既存のマイニングプールは、マイナーがシェアを作成した際に、
  全ブロック報酬（報酬＋トランザクション手数料）に比例した報酬を受け取る
  [FPPS][topic fpps]（_Full Paid Per Share_）方式をサポートするのは財政的に困難であると指摘しています。
  彼は詳しく説明しませんでしたが、問題は手数料のばらつきによりプールが多額の準備金を保有せざるを得ないことだと理解しています。
  たとえば、プールのマイナーがハッシュレートの1%を制御している場合、
  手数料が約1,000 BTCでブロック報酬が3 BTCのテンプレートでシェアを作成する場合、
  プールは約10 BTCを支払う義務があります。しかし、プールがそのブロックをマイニングせず、
  ブロックをマイニングした際の手数料がブロック報酬の何分の一かに下がっていた場合、
  プールが全マイナーに分配できるのは合計3 BTCで、準備金からの支払いを余儀なくされるかもしれません。
  これが何度も発生すると、プールの準備金が枯渇し、廃業することになります。
  プールは、[実際の手数料にプロキシ][news304 fpps proxy]を使用するなど、さまざまな方法でこれに対処しています。

  開発者のvnprcは、PPLNS支払い方式で受け取ったecashシェアに焦点を当てた、
  彼が[構築中の][hashpool]ソリューションについて[説明しました][vnprc ehash]。
  彼は、これが新しいプールの立ち上げに特に役立つ可能性があると考えています。
  現在、プールに最初に参加するマイナーは、ソロマイニングと同じ高い変動に悩まされるため、
  通常、プールを開始できるのは既存の大規模なマイナーか、大規模なハッシュレートを借りたい意思のある人だけです。
  ただ、PPLNS ecashシェアを使用すると、プールをより大きなプールのクライアントとして立ち上げることができるため、
  vnprcは新しいプールに最初に参加するマイナーでも、ソロマイニングよりも変動が少なくなると考えています。
  中間プールはその後、獲得したecashシェアを販売して、マイナーに支払うために選択した支払い方式の資金を調達できます。
  中間プールがかなりの量のハッシュレートを獲得すると、マイナーに適した代替ブロックテンプレートの作成について、
  より大きなプールと交渉するための影響力も得られます。

- **オフチェーンDLC:** 開発者のconduitionは、両参加者が署名したファンディングトランザクションの
  オフチェーン支払いで複数の[DLC][topic dlc]を作成できるコントラクトプロトコルについて、
  DLCメーリングリストに[投稿しました][conduition offchain]。
  （必要なオラクルの署名が入手されたなどして）オフチェーンDLCが決済されると、
  両参加者は新しいオフチェーン支払いに署名し、コントラクトの解決に従って資金を再割り当てできます。
  その後、3つめの代替支払いで資金を新しいDLCに割り当てることができます。

  Kulpreet SinghとPhilipp Hoenischによる返信は、
  同じ資金プールをオフチェーンDLCとLNの両方に使用できるアプローチ（ニュースレター[#174][news174 dlc-ln]および
  [#260][news260 dlc]参照）を含む、この基本的なアイディアの以前の研究と開発にリンクしています。
  conduitionからの[返信][conduition offchain2]では、彼の提案と以前の提案の主な違いが説明されていました。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [LDK v0.1][]は、LN対応ウォレットやアプリケーションを構築するためのこのライブラリのマイルストーンリリースです。
  新機能には、「LSPSチャネル開設ネゴシエーションプロトコルの両サイドのサポート、...
  [BIP353][]の人が読める名前解決のサポート、単一チャネルの強制閉鎖で複数のHTLCを解決する際のオンチェーン手数料コストの削減」が
  含まれています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Eclair #2936][]では、[スプライシング][topic splicing]の更新を伝播できるように（ニュースレター[#214][news214 splicing]および
  Eclair開発者による[動機][tbast splice]の説明参照）、ファンディングアウトプットが使用された後、
  チャネルがクローズされたとマークするまでに12ブロックの遅延が導入されました。
  使用されたチャネルは一時的に新しい`spentChannels`マップで追跡され、
  12ブロック後に削除されるか、スプライシングされたチャネルとして更新されます。
  スプライシングが発生すると、新しいチャネルを作成する代わりに、親チャネルのショートチャネル識別子（SCID）、
  キャパシティおよび残高の境界が更新されます。

- [Rust Bitcoin #3792][]では、[BIP324][]の[v2 P2Pトランスポート][topic v2 P2P transport]メッセージ
  （ニュースレター[#306][news306 v2]参照）をエンコード/デコードする機能を追加します。
  これは、元の`NetworkMessage`列挙型をラップして、v2のエンコード/デコードを提供する
  `V2NetworkMessage`構造体を追加することで実現されています。

- [BDK #1789][]は、デフォルトのトランザクションバージョンを1から2に更新し、
  ウォレットのプライバシーを向上させます。これ以前は、バージョン1を使用しているのはネットワークの15%のみであったため、
  BDKウォレットはより識別可能でした。さらに、バージョン2は、[Taproot][topic taproot]トランザクション用に
  [BIP326][]のnSequenceベースの[アンチ・フィー・スナイピング][topic fee sniping]メカニズムの将来の実装に必要です。

- [BIPs #1687][]は、[PSBT][topic psbt]を使用した[サイレントペイメント][topic
  silent payments]の送信を定義する[BIP375][]をマージしました。複数の独立した署名者がいる場合、
  すべての署名者が自分の秘密鍵を明かすことなく、自分の署名が資金を誤支払いしないことを共同署名者に証明できる
  [DLEQ][topic dleq]プルーフが必要です（[ニュースレター #335][news335 dleq]および[Recap #327][recap327 dleq]参照）。

- [BIPs #1396][]は、[BIP78][]の[Payjoin][topic payjoin]仕様を更新し、
  [BIP174][]の[PSBT][topic psbt]仕様と一致させ、これまでの競合を解決します。
  BIP78では、送信者がデータを必要としている場合でも、受信者はインプットが完成するとUTXOデータを削除していました。
  今回の更新により、UTXOデータは保持されるようになりました。

{% include snippets/recap-ad.md when="2025-01-21 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3792,1789,1687,1396,2936" %}
[ldk v0.1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1
[news174 dlc-ln]: /ja/newsletters/2021/11/10/#ln-dlc
[news260 dlc]: /ja/newsletters/2023/07/19/#wallet-10101-beta-testing-pooling-funds-between-ln-and-dlcs-10101-ln-dlc
[ecash tides]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870
[news304 ecashtides]: /ja/newsletters/2024/05/24/#challenges-in-rewarding-pool-miners
[corallo whyecash]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870/27
[caseria pplns]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870/29
[recap291 tides]: /en/podcast/2024/02/29/#how-does-ocean-s-tides-payout-scheme-work-transcript
[vnprc ehash]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870/32
[hashpool]: https://github.com/vnprc/hashpool
[conduition offchain]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000186.html
[news304 fpps proxy]: /ja/newsletters/2024/05/24/#pps-pay-per-share
[tbast splice]: https://github.com/ACINQ/eclair/pull/2936#issuecomment-2595930679
[conduition offchain2]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000189.html
[news214 splicing]: /ja/newsletters/2022/08/24/#bolts-1004
[news306 v2]: /ja/newsletters/2024/06/07/#rust-bitcoin-2644
[news335 dleq]: /ja/newsletters/2025/01/03/#bips-1689
[recap327 dleq]: /en/podcast/2024/11/05/#draft-bip-for-dleq-proofs