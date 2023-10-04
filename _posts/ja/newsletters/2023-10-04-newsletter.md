---
title: 'Bitcoin Optech Newsletter #271'
permalink: /ja/newsletters/2023/10/04/
name: 2023-10-04-newsletter-ja
slug: 2023-10-04-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、ハードウェア署名デバイスを使用してLNノードをリモート制御するための提案や、
LNの転送ノードがLNの支払いを動的に分割できるようにするためのプライバシーに焦点を当てた研究とコードについて説明し、
転送ノードのグループが通常のチャネルとは別に資金をプールできるようにすることでLNの流動性を向上させる提案について考察します。
また、新しいリリースの発表や、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **LNノードの安全なリモート制御:** Bastien Teinturierは、
  ハードウェア署名デバイス（またはその他のウォレット）からLNノードに署名付きのコマンドを送信する方法を定義した
  [BLIPの提案][blips #28]をLightning-Devメーリングリストに[投稿しました][teinturier remote post]。
  署名デバイスはBLIPと[BOLT8][]のピア通信を実装するだけでよく、
  LNノードはBLIPを実装するだけ済みます。これは、LNノードのほぼ完全なリモート制御を可能にする
  Core Lightningの _commando_ プラグイン（[ニュースレター #210][news210 commando]参照）に似ていますが、
  Teinturierは、この機能は主に支払いの承認など、最も機密性の高いノード操作の制御を目的としていると考えています。
  これは、ユーザーがハードウェアセキュリティデバイスに接続しロックを解除し、
  操作を承認するという手間を惜しまないようなタイプの操作です。
  これにより、エンドユーザーはLNの残高をオンチェーン残高と同じハードウェア署名デバイスのセキュリティで保護することが容易になります。

- **<!--payment-splitting-and-switching-->支払いの分割と切り替え:**
  Gijs van Damは、Core Lightning用に作成した[プラグイン][pss plugin]と、
  それに関連する[研究][pss research]についてLightning-Devメーリングリストに[投稿しました][van dam pss post]。
  このプラグインは転送ノードがそのピアに対して _支払いの分割と切り替え_
  （PSS＝Payment Splitting and Switching）をサポートしていることを伝えることができます。
  アリスとボブがチャネルを共有し、両者がPSSをサポートしている場合、
  アリスがボブに転送する支払いを受け取ると、プラグインはその支払いを2つ以上の[ペイメント・パーツ][topic multipath payments]に
  分割することができます。そのうちの1つは通常どおりボブに転送されますが、
  他の支払いは別の経路（たとえばアリスからキャロルを介してボブへ）をたどることがあります。
  ボブはすべてのパーツを受け取るまで待ち、その後通常どおり次のホップに支払いの転送を続けます。

    この方法の主な利点は、第三者がチャネルの残高を追跡するために繰り返し[プローブ][topic payment probes]を行う
    _残高探索攻撃_ （BDA＝Balance Discovery Attack）の実行を困難にすることです。
    プローブが頻繁に行われると、BDAはネットワークを通過する支払いを追跡できる可能性があります。
    PSSが使用されると、攻撃者はアリスとボブのチャネル残高だけでなく、
    アリスとキャロル、キャロルとボブのチャネル残高も追跡する必要があります。
    攻撃者がこれらすべてのチャネルの残高を追跡したとしても、
    それらのチャネルを同時に通過する他のユーザーの支払いの一部が、追跡している支払いの一部と混同される可能性が高くなるため、
    支払いを追跡するための計算の難易度は高まります。
    van Damの[論文][pss research]によると、PSSを導入した場合、
    攻撃者が得られる情報量は62%減少することが示されています。

    PSSに関するvan Damの論文では、LNのスループットの向上と、
    [チャネルジャミング攻撃][topic channel jamming attacks]に対する緩和策の一環という、さらに2つの利点が挙げられています。
    PSSのアイディアは、この記事を書いている時点で、メーリングリスト上で少し議論されていました。

- **<!--pooled-liquidity-for-ln-->LNのプール流動性:** ZmnSCPxjは、
  彼が _サイドプール_ と呼ぶ提案をLightning-Devメーリングリストに[投稿しました][zmnscpxj sidepools1]。
  これは、転送ノードのグループが協力してマルチパーティ・ステート・コントラクト、
  つまり（LNチャネルと同様にオンチェーンにアンカリングされている）オフチェーンコントラクトに資金をデポジットし、
  オンチェーンコントラクトの状態を更新することで参加者間の資金を移動できるようにする提案です。
  たとえば、アリスとボブ、キャロルがそれぞれ1 BTC保持する初期状態を、
  アリスに2 BTC、ボブに0 BTC、キャロルに1 BTCとする新しい状態に更新することができます。

    転送ノードはまた、ノードのペア間で通常のLNチャネルを引き続き使用し、アドバタイズします。
    たとえば、前述の3人のユーザーは、アリスとボブ、ボブとキャロル、アリスとキャロルの3つの個別のチャネルを持つことができます。
    彼らは、現在とまったく同じように、これらのチャネルを通じて支払いを転送するでしょう。

    1つ以上の通常のチャネルの残高が不均衡になった場合（たとえばアリスとボブのチャネルの資金がアリス側に偏っている場合）、
    その不均衡は、ステート・コントラクトでオフチェーン[PeerSwap][peerswap]を実行することで解消できます。
    たとえば、アリスが通常のLNチャネルでボブを介してキャロルに資金を転送することを条件に、
    ステート・コントラクトでキャロルがアリスに資金を提供することで、
    アリスとボブのLNチャネルの不均衡を解消できます。

    この方法の利点の1つは、特定の各コントラクトの参加者以外は誰もステート・コントラクトについて知る必要がないことです。
    すべての通常のLNユーザーや、特定のコントラクトに関与していないすべての転送ノードに対して、
    LNは現在のプロトコルを使用して引き続き動作します。既存のチャネルのリバランス操作と比較したもう1つの利点は、
    ステート・コントラクトのアプローチにより、多数の転送ノードが少量のオンチェーンスペースで直接的なピアの関係を保持できるため、
    これらのピア間のオフチェーンリバランスの手数料が不要になる可能性が高いことです。
    リバランスの手数料を最小限に抑えることで、転送ノードがチャネルの均衡を保つことが容易になり、
    収益性が向上し、LN全体で支払いの送信の信頼性が高まります。

    この方法の欠点は、マルチパーティ・ステート・コントラクトが必要であることで、
    これは（私たちの知る限り）これまで実運用環境に実装されたことがないものです。
    ZmnSCPxjは、[LN-Symmetry][topic eltoo]と[Duplex Payment Channel][duplex payment channels]をベースとして使用するのが有用であると述べています。
    LN-Symmetryはコンセンサスの変更を必要しますが、近い将来実現する可能性は低いと思われるため、
    ZmnSCPxjによる[その後の投稿][zmnscpxj sidepools2]では、
    Duplex Payment Channel（ZmnSCPxjは最初に提案した研究者にちなんで「Decker-Wattenhofer」と呼んでいます）に焦点を当てているようです。
    Duplex Payment Channelの欠点は、チャネルを無期限に開いておくことができないことですが、
    ZmnSCPxjの分析では、コストを効果的に償却するのに十分な期間、
    十分な状態変化を経て開き続けることができる可能性があることを示しています。

    この記事の執筆時点では、投稿に対する公開の返信はありませんでしたが、
    ZmnSCPxjとの私的なやりとりから、彼がこのアイディアのさらなる発展に取り組んでいることが分かりました。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND v0.17.0-beta][]は、この人気のLNノード実装の次期メジャーバージョンのリリースです。
  このリリースに含まれる主な実験的新機能は、「Simple [Taproot][topic taproot] Channel」のサポートです。
  これにより、P2TRアウトプットを使用してオンチェーンでファンディングされた
  [未公表チャネル][topic unannounced channels]の使用が可能になります。
  これは、[Taproot Assets][topic client-side validation]や[PTLC][topic ptlc]など、
  LNDのチャネルに他の機能を追加するための最初のステップです。
  このリリースには、[コンパクト・ブロック・フィルター][topic compact block filters]をサポートする
  Neutrinoバックエンドのユーザー向けの大幅なパフォーマンスの向上や、
  LNDの組み込み[ウォッチタワー][topic watchtowers]機能の改善も含まれています。
  詳細については、[リリースノート][lnd rn]および[リリースのブログ記事][lnd 17 blog]をご覧ください。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Eclair #2756][]では、[スプライシング][topic splicing]操作のモニタリングを導入しています。
  操作の開始者を収集し、スプライス・イン、スプライス・アウト、スプライス・CPFPの3種類のスプライシングを区別します。

- [LDK #2486][]は、1つのトランザクションで複数のチャネルに資金を供給する機能が追加され、
  バッチ化されたすべてのチャネルが、資金を提供されて開かれるか、すべてが閉じられるかのアトミック性を保証します。

- [LDK #2609][]では、過去のトランザクションで支払いを受け取るために使用された
  [ディスクリプター][topic descriptors]を要求できるようになりました。
  以前は、ユーザーが自分でこれを保存しなければなりませんでしたが、
  更新されたAPIでは、他の保存データからディスクリプターを再構築できるようになりました。

{% include references.md %}
{% include linkers/issues.md v=2 issues="2756,2486,2609,28" %}
[LND v0.17.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta
[teinturier remote post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004084.html
[news210 commando]: /ja/newsletters/2022/07/27/#core-lightning-5370
[van dam pss post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004114.html
[pss plugin]: https://github.com/gijswijs/plugins/tree/master/pss
[pss research]: https://eprint.iacr.org/2023/1360
[zmnscpxj sidepools1]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004099.html
[peerswap]: https://github.com/ElementsProject/peerswap
[duplex payment channels]: https://www.tik.ee.ethz.ch/file/716b955c130e6c703fac336ea17b1670/duplex-micropayment-channels.pdf
[zmnscpxj sidepools2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-September/004108.html
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.17.0.md
[lnd 17 blog]: https://lightning.engineering/posts/2023-10-03-lnd-0.17-launch/
