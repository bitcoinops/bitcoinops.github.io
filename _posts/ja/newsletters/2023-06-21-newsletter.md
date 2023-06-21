---
title: 'Bitcoin Optech Newsletter #256'
permalink: /ja/newsletters/2023/06/21/
name: 2023-06-21-newsletter-ja
slug: 2023-06-21-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、BOLT11インボイスを拡張して2つの支払いを要求することについての議論を掲載しています。
また、mempoolポリシーに関する限定週刊シリーズの新しい記事に加えて、
クライアントとサービスのアップデート、新しいリリースとリリース候補の発表や、
人気のあるBitcoinインフラストラクチャプロジェクトの変更など、恒例のセクションも含まれています。

## ニュース

- **BOLT11インボイスを拡張して2つの支払いを要求する提案:** Thomas Voegtlinは、
  [BOLT11][]インボイスを拡張して、オプションで受信者が支払人に2つの別々の支払いを要求できるようにし、
  それぞれの支払いには別々のシークレットと金額を持たせる提案を、Lightning-Devメーリングリストに[投稿しました][v 2p]。
  Voegtlinは、これが[サブマリン・スワップ][topic submarine swaps]と[JITチャネル][topic jit channels]の両方に
  どう役立つかを説明しています。

    - *<!--submarine-swaps-->サブマリン・スワップ*は、
      オフチェーンでLNインボイスに支払うことで、オンチェーンで資金を受け取ることができます（
      サブマリン・スワップは、オンチェーンからオフチェーンへ逆方向にも機能しますが、ここでは議論しません）。
      オンチェーンの受信者はシークレットを選択し、
      オフチェーンの支払人はそのシークレットのハッシュに対して[HTLC][topic htlc]を支払い、
      これがLN経由でサブマリン・スワップのサービスプロバイダーにルーティングされます。
      サービスプロバイダーは、そのシークレットに対するオフチェーンHTLCを受け取り、
      そのHTLCに支払うオンチェーントランザクションを作成します。
      ユーザーがオンチェーントランザクションが安全であると納得したら、
      オンチェーンHTLCを決済するためにシークレットを開示し、
      サービスプロバイダーがオフチェーンHTLC（および同じシークレットに依存するLN上のすべての転送された支払い）を決済できるようにします。

        しかし、受信者がシークレットを開示しなかった場合、サービスプロバイダーは報酬を受け取ることができず、
        作成したばかりのオンチェーンアウトプットを使用する必要があり、無駄なコストが発生します。
        このような悪用を防ぐため、既存のサブマリン・スワップサービスは、
        サービスがオンチェーントランザクションを作成する前に、支払人にLNで手数料の支払いを求めます（
        サービスはオプションで、オンチェーンHTLCが決済された場合に、この手数料の全額または一部を返金することができます）。
        前払い手数料の金額とサブマリン・スワップの金額は異なる金額で、異なるタイミングで決済する必要があるため、
        異なるシークレットを使用する必要があります。現在のBOLT11インボイスは、
        1つのシークレットと1つの金額に対するコミットメントしか含めることができないため、
        現在サブマリン・スワップを行うウォレットは、サーバーとやりとりするようにプログラムされているか、
        支払人と受信者の双方が複数のステップのワークフローを完了する必要があります。

    - *JIT（Just-in-Time）チャネル*は、チャネル（または流動性）を持たないユーザーが、
      サービスプロバイダーと仮想チャネルを作成します。その仮想チャネルに最初の支払いが到着すると、
      サービスプロバイダーがチャネルに資金を供給しその支払いを含むオンチェーントランザクションを作成します。
      他のLNのHTLCと同様に、オフチェーン支払いは受信者（ユーザー）だけが知っているシークレットに対して行われます。
      ユーザーがJITチャネルのファンディング・トランザクションが安全であると納得したら、
      支払いを請求するためのシークレットを開示します。

        しかし、この場合も、ユーザーがシークレットを開示しなければ、
        サービスプロバイダーは対価を受け取れず、オンチェーンコストが発生し、何の利益も得られません。
        Voegtlinは、既存のJITチャネルのサービスプロバイダーは、
        ファンディング・トランザクションが安全になる前にユーザーにシークレットの開示を要求することで、
        この問題を回避していると考えており、これは法的な問題を引き起こす可能性があり、
        非カストディアルウォレットが同様のサービスを提供することを妨げると述べています。

    Voegtlinは、BOLT11インボイスにそれぞれ異なる2つのシークレットと金額に対するコミットメントを含めることを許可することで、
    一方のシークレットと金額をオンチェーントランザクションのコストを支払う前払い手数料として使用し、
    もう一方のシークレットと金額を実際のサブマリン・スワップまたはJITチャネルの資金に使用できるようになると提案しています。
    この提案には、いくつかのコメントが寄せられており、そのうちのいくつかを要約します:

    - *<!--dedicated-logic-required-for-submarine-swaps-->サブマリン・スワップに必要な専用ロジック:*
      Olaoluwa Osuntokunは、サブマリン・スワップの受信者はシークレットを作成、配布し、
      それに対する支払いをオンチェーンで決済する必要があると[指摘しています][o 2p]。
      それを決済する最も安価な方法は、スワップのサービスプロバイダーと対話することです。
      支払人と受信者が同じエンティティである既存の実装によくあるように、
      支払人と受信者がサービスプロバイダーと対話する場合は、インボイスを使って追加の情報を伝達する必要はありません。
      Voegtlinは、専用のソフトウェアがこのやりとりを処理することで、
      資金を支払うオフチェーンウォレットと資金を受け取るオンチェーンウォレットに追加のロジックが不要になり、
      ただし、これが可能になるのは、LNウォレットが同じインボイスで2つの別々のシークレットと金額を支払うことができる場合に限られると[回答しました][v 2p2]。

    - *BOLT11の硬直化:* Matt Coralloは、
      （[Spontaneous Payment][topic spontaneous payments]を許可するための）金額を含まないインボイスをサポートするために、
      すべてのLN実装がBOLT11サポートを更新することはまだ不可能であり、
      追加フィールドを追加することは現時点では現実的なアプローチとは思えないと[回答しました][c 2p]。
      Bastien Teinturierも[同様のコメント][t 2p]をしており、代わりに
      [オファー][topic offers]にサポートを追加することを提案しています。
      Voegtlinはこれに[反対し][v 2p3]、サポートを追加するのが現実的だと考えています。

    - *<!--splice-out-alternative-->スプライス・アウトという選択肢:* Coralloは、
      [スプライス・アウト][topic splicing]が利用できるようになった場合、
      なぜプロトコルを変更してサブマリン・スワップをサポートする必要があるのかについても尋ねています。
      スレッドでは言及されていませんでしたが、サブマリン・スワップとスプライス・アウトは
      どちらもオフチェーンの資金をオンチェーンのアウトプットに移動させることができます。
      ただし、スプライス・アウトはオンチェーンではより効率的であり、補償されない手数料の問題に対して脆弱ではありません。
      Voegtlinは、サブマリン・スワップにより、LNユーザーは新しいLN支払いを受け取るためのキャパシティを増やすことができるが、
      スプライシングではそれができないと答えています。

    この記事の執筆時点でも議論は続いているようです。

## 承認を待つ #6: ポリシーの一貫性

_トランザクションリレーや、mempoolへの受け入れ、マイニングトランザクションの選択に関する限定週刊[シリーズ][policy series]です。
Bitcoin Coreがコンセンサスで認められているよりも制限的なポリシーを持っている理由や、
ウォレットがそのポリシーを最も効果的に使用する方法などが含まれます。_

{% include specials/policy/ja/06-consistency.md %}

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Greenlightライブラリがオープンソースに:**
  非カストディアルのLNノードサービスプロバイダー[Greenlight][news162 greenlight]は、
  クライアントライブラリと言語バインディングの[リポジトリ][github greenlight]と、
  [テストフレームワークガイド][greenlight testing]を[発表しました][decker twitter]。

- **TapscriptデバッガーTapsim:**
  [Tapsim][github tapsim]は、スクリプト実行のデバッグ（[ニュースレター #254][news254 tapsim]参照）および
  btcdを使用した[Tapscript][topic tapscript]の可視化ツールです。

- **Bitcoin Keeper 1.0.4の発表:**
  [Bitcoin Keeper][]は、マルチシグ、ハードウェア・サイナー、[BIP85][]をサポートするモバイルウォレットで、
  最新のリリースでは、[Whirlpoolプロトコル][gitlab whirlpool]を使用した[Coinjoin][topic coinjoin]をサポートしています。

- **ライトニングウォレットEttaWalletの発表:**
  LDKによって可能になったライトニングの機能を備え、
  Bitcoin Design Communityの[日常的な支払いウォレット][bitcoin design guide]の参照設計から
  インスピレーションを得たユーザービリティ重視のモバイル[EttaWallet][github ettawallet]が最近[発表されました][ettawallet blog]。

- **zkSNARKベースのブロックヘッダー同期のPoCの発表:**
  [BTC Warp][github btc warp]は、zkSNARKsを使用してBitcoinのブロックヘッダーのチェーンの証明および検証を行う
  軽量クライアントの同期の概念実証です。[ブログ記事][btc warp blog]には、採用されたアプローチの詳細が記載されています。

- **lnprototest v0.0.4リリース:**
  [lnprototest][github lnprototest]プロジェクトは、
  「Python3で書かれたテストヘルパーのセットで、ライトニングネットワークプロトコルの変更を提案する際に、
  新しいテストを簡単に書くことができ、また既存の実装をテストできるように設計されている」
  LNのテストスイートです。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Eclair v0.9.0][]は、このLN実装の新しいリリースで、
  「重要な（そして複雑な）ライトニングの機能：[デュアル・ファンディング][topic dual funding]、
  [スプライシング][topic splicing]、[BOLT12 オファー][topic offers]のための多くの準備作業を含んでいます。」
  これらの機能は現時点では実験的なものです。このリリースでは、
  「プラグインがより強力になり、さまざまな種類のDoSに対する緩和策が導入され、
  コードベースの多くの領域でパフォーマンスが向上します」とあります。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [LDK #2294][]は、[Onionメッセージ][topic onion messages]への返信をサポートし、
  LDKの[オファー][topic offers]の完全なサポートに近づけました。

- [LDK #2156][]は、[簡略化されたマルチパスペイメント][topic multipath payments]を使用した
  [keysend支払い][topic spontaneous payments]をサポートしました。
  LDKは以前、この2つの技術の両方をサポートしていましたが、それはそれらが別々に使用されていた場合にのみでした。
  マルチパスペイメントは[ペイメント・シークレット][topic payment secrets]を使用する必要がありますが、
  LDKは以前、ペイメント・シークレットを使用したkeysend支払いを拒否していたため、
  潜在的な問題を軽減するために、説明的なエラーや設定オプションおよびダウングレードに関する警告が追加されました。

{% include references.md %}
{% include linkers/issues.md v=2 issues="2294,2156" %}
[policy series]: /ja/blog/waiting-for-confirmation/
[v 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003977.html
[o 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003978.html
[v 2p2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003979.html
[c 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003980.html
[t 2p]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003982.html
[v 2p3]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-June/003981.html
[eclair v0.9.0]: https://github.com/ACINQ/eclair/releases/tag/v0.9.0
[news162 greenlight]: /ja/newsletters/2021/08/18/#blockstream-ln-greenlight
[decker twitter]: https://twitter.com/Snyke/status/1666096470884515840
[github greenlight]: https://github.com/Blockstream/greenlight
[greenlight testing]: https://blockstream.github.io/greenlight/tutorials/testing/
[github tapsim]: https://github.com/halseth/tapsim
[news254 tapsim]: /ja/newsletters/2023/06/07/#ctv-joinpool-matt
[Bitcoin Keeper]: https://bitcoinkeeper.app/
[gitlab whirlpool]: https://code.samourai.io/whirlpool/whirlpool-protocol
[github ettawallet]: https://github.com/EttaWallet/EttaWallet
[ettawallet blog]: https://rukundo.mataroa.blog/blog/introducing-ettawallet/
[bitcoin design guide]: https://bitcoin.design/guide/daily-spending-wallet/
[github btc warp]: https://github.com/succinctlabs/btc-warp
[btc warp blog]: https://blog.succinct.xyz/blog/btc-warp
[github lnprototest]: https://github.com/rustyrussell/lnprototest
