---
title: 'Bitcoin Optech Newsletter #171'
permalink: /ja/newsletters/2021/10/20/
name: 2021-10-20-newsletter-ja
slug: 2021-10-20-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、頻繁にオフラインになるLNノードへの支払いに関するスドレッドや、
特定の攻撃をより高価にするめにLNの支払い経路の正確な調査のコストを下げる提案、
signetやtestnetでTaprootトランザクションを作成する際に役立つ方法のリンクを掲載しています。
また、クライアントやサービスの最近の変更や、新しいリリースおよびリリース候補、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更点などの恒例のセクションも含まれています。

## ニュース

- **<!--paying-offline-ln-nodes-->オフラインのLNノードへの支払い:**
  Matt Coralloは、頻繁にオフラインになるLNノード（モバイルデバイスなど）が、
  カストディ型ソリューションを必要とせず、
  また長期間チャネルの流動性をロックすることなく支払いを受け取れるようにする方法についてのブレインストーミングを
  Lightning-Devメーリングリスト上の[スレッド][corallo mobile]で開始しました。
  Coralloは、LNが[PTLC][topic ptlc]をサポートするよう[アップグレードされれば][zmn taproot]、
  信頼できない第三者を含む合理的なソリューションがあると考えていますが、
  PTLCのサポートが追加される前でも展開可能な代替ソリューションの提案も求めています。

- **<!--lowering-the-cost-of-probing-to-make-attacks-more-expensive-->正確な調査のコストを下げ、攻撃をより高価にする:**
  数週間にわたって、開発者のZmnSCPxjとJoost Jagerはそれぞれ、
  支払い経路を調査するために資本をロックアップする必要をなくすという、
  [実質的に][zmn prop]同様の[提案][jager prop]をしました。
  どちらの提案も、支払いの試行が失敗しても送信者にお金がかかる、
  前払いのルーティング手数料をネットワークに追加するための最初のステップとしてこれを提案しています。
  前払い手数料は、[チャネル・ジャミング攻撃][topic channel jamming attacks]の緩和策の1つとして提案されています。

    現在、LNノードは支払い経路を調査するために必ず失敗する支払いを送信することができます。
    例えば、アリスは誰も知らないプリイメージへ支払う[HTLC][topic htlc]を生成したとしましょう。
    彼女はその支払いをボブとチャーリーを介してゼッドにルーティングします。
    ゼッドはプリイメージを知らないため、最終的な受信者が自分であることを示しているにも関わらず、
    支払いを拒否せざるを得ません。アリスはゼッドのノードから拒否のメッセージを受信した場合、
    ボブとチャーリーがゼッドへの支払いを可能にするだけの資金を持っていることを知ることができるので、
    高い確率で成功する実際の支払いを送信することでゼッドの拒否にすぐに反応できます（流動性に関連する失敗の唯一の理由は、
    ボブもしくはチャーリーの残高がその間に変更された場合です）。
    必ず失敗する支払いから開始するアリスのメリットは、複数の経路を並行して調査し、
    最初に成功した経路を使用することで、全体的な支払い時間が短縮できます。
    主なデメリットは、各支払いの調査で、アリスとボブやチャーリーのような中間ノードが保持する資金を一時的にロックすることです。
    アリスが複数の長い経路を並行して調査している場合、彼女は支払額の100倍以上をロックしている可能性があります。
    2つめのデメリットは、この種の支払い経路の調査により、不必要な一方的なチャネル閉鎖と、
    その結果生じるオンチェーン手数料です。

    ZmnSCPxjとJagerは、HTLCの使用やビットコインの一時的なロック、
    チャネル障害のリスクを必要としない特別な調査メッセージの送信を可能にすることを提案しています。
    ZmnSCPxjの提案は、サービス拒否のFlood攻撃を避けるためのいくつかの緩和策を提案していますが、
    メッセージは基本的に無料で送信できます。

    無料の調査により、支払いノードが高い割合で信頼できる経路を見つけることが実際にできるようになれば、
    ZmnSCPxjとJagerは、開発者とユーザーは、
    支払いが失敗する稀なケースでは、ユーザーのコストになる前払い手数料の支払いへの抵抗は少なくなるはずだと主張しています。
    誠実なユーザーにとっては稀に発生する小さなコストが、大規模なジャミング攻撃を実行する不正なノードにとっては大きな保証コストとなり、
    そのような攻撃が発生するリスクを低減することができます（また、持続的な攻撃が発生した場合に、
    ネットワークを改善するために資本を投入するルーティングノードのオペレーターに補償することができます）。

    この記事の執筆時点では、このアイディアは緩やかに議論が行われています。

- **<!--testing-taproot-->Taprootのテスト:**
  Bitcoin-Devメーリングリストでの[リクエスト][schildbach taproot wallet]に応えて、
  Anthony Townsは、[signet][topic signet]またはtestnetで、Bitcoin Coreでのテスト用に
  [bech32m][topic bech32]アドレスを作成するためのステップ・バイ・ステップの手順を[提供しました][towns taproot wallet]。
  この手順は、Taprootをテストする開発者にとって、Optechが[以前提供したもの][p4tr signet]よりも使いやすいかもしれません。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **ZeusウォレットがLN機能を追加:**
  モバイルのBitcoinおよびLightningウォレットアプリケーションであるZeusは、
  [v0.6.0-alpha3][zeus v0.6.0-alpha3]のリリースで、
  [Atomic Multipath Payment (AMP)][topic amp]、[Lightning Addresses][news167 lightning addresses]、
  [コインコントロール][topic coin selection]機能のサポートを追加しました。

- **Sparrowがcoinjoinをサポート:**
  [Sparrow 1.5.0][]は、Samouraiの[Whirlpool][whirlpool]との統合により[coinjoin][topic coinjoin]機能を追加しました。

- **JoinMarket 0.9.2がRBFをサポート:**
  [JoinMarket 0.9.2][joinmarket 0.9.2]は、UIで[Fidelity bond][news161 fidelity bonds]をデフォルトで使用するのに加えて、
  非coinjoinトランザクションでは[replace by fee (RBF)][topic rbf]をサポートしています。

- **Coldcardがdescriptorベースのウォレットをサポート:**
  [Coldcard 4.1.3][coldcard 4.1.3]は、Bitcoin Coreで`importdescriptors`をサポートし、
  Bitcoin Coreで[descriptor][topic descriptors]ウォレットと[PSBT][topic psbt]ワークフローを可能にします。

- **Simple Bitcoin WalletがCPFP、RBF、Holdインボイスを追加:**
  以前Bitcoin Lightning Walletとして知られていたSimple Bitcoin Walletは、
  バージョン2.2.14で、[child pays for parent (CPFP)][topic cpfp]と
  RBF (手数料の引き上げとキャンセル) 機能を追加し、[2.2.15][slw 2.2.15]では[Holdインボイス][topic hold invoices]を追加しました。

- **Electrs 0.9.0リリース:**
  [Electrs 0.9.0][]は、ディスクやJSON RPCからブロックを読み取るのではなく、
  BitcoinのP2Pプロトコルを使用するようになりました。
  アップグレードの詳細については、[アップグレードガイド][Electrs 0.9.0 upgrading guide]をご覧ください。

## Taprootの準備 #18: トリビア

*ブロック高{{site.trb}}のTaprootのアクティベーションに向けて、
開発者やサービスプロバイダーがどのような準備をすればよいかについての週刊[シリーズ][series preparing for taproot]です。*

{% include specials/taproot/ja/18-trivia.md %}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BDK 0.12.0][]は、Sqliteを使ったデータ保存機能の追加などを行ったリリースです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、
[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、
[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、
[Hardware Wallet Interface (HWI)][hwi repo]、
[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、
[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIP）][bips repo]、および
[Lightning BOLTs][bolts repo]の注目すべき変更点。*

<!-- we wouldn't normally cover a small code comment like this, but it
seems worth publicizing the decision to use this value -->
- [Bitcoin Core #22863][]では、P2TRアウトプットにはP2WPKHアウトプットと同じ
  294 satの最低アウトプット量（"dust limit"）を使用するという決定がドキュメント化されています。
  これは、現時点でdust limitを下げることに[反対する][bitcoin core #22779]開発者がいたため、
  P2WPKHアウトプットよりP2TRアウトプットの方が消費コストが低いにも関わらず決定されました。

- [Bitcoin Core #23093][]では、ウォレット内のすべての事前生成されたアドレスに使用済みのマークをつけ、
  新しいアドレスのセットが生成されるようにする`newkeypool`RPCが追加されました。
  ほとんどのユーザーはこれを使用することはないでしょうが、
  古い非[BIP32][]ウォレットから[HD鍵生成][topic bip32]を使用するようにアップグレードした場合、
  この動作はバックグラウンドで使用されます。

- [Bitcoin Core #22539][]では、手数料の見積もりをする際に、ローカルノードで確認された置換トランザクションを考慮します。
  [これまで][bitcoin core #9519]置換トランザクションはほとんど発生しないため考慮されていませんでしたが、
  現在は[全トランザクションの20%][optech rbf]が置換可能な[BIP125][]シグナルを送信しており、
  通常１日に[数千件の][0xb10c stats]置換が発生しています。

- [Eclair #1985][]では、新しい`max-exposure-satoshis`設定項目が追加されました。<!-- full name is
  long:
  eclair.on-chain-fees.feerate-tolerance.dust-tolerance.max-exposure-satoshis
  -->
  未解決の[経済合理性のない支払い][topic uneconomical outputs]を持つチャネルが強制クローズされる際に、
  マイナーへの寄付となる金額の上限を設定できるようにするものです。
  詳細は、[先週のニュースレター][news170 ln cve]のCVE-2021-41591の記載をご覧ください。

- [Rust-Lightning #1124][]は、`get_route`APIを拡張し、
  過去に失敗した経路の再利用を避けるために使用できる追加のパラメーターを渡すことができるようになりました。
  今後予定されている変更で、後の結果の品質を向上させるために、過去のルーティングの成功や失敗を簡単に利用できるようになります。

- [BOLTs #894][]は、推奨されるチェックを仕様に追加しています。
  これらを実装することで、経済合理性のないルーティング支払いがオンチェーンに展開される際に、
  余剰ビットコインをマイナーに寄付するのを防ぐことができます。
  これらのチェックがない場合に起こりうる問題の詳細については、
  [先週のニュースレター][news170 ln cve]をご覧ください。

{% include references.md %}
{% include linkers/issues.md issues="22863,23093,22539,4567,1985,1124,894,22779,9519" %}
[corallo mobile]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-October/003307.html
[zmn taproot]: /ja/preparing-for-taproot/#lnとtaproot
[zmn prop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-September/003256.html
[jager prop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-October/003314.html
[schildbach taproot wallet]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019532.html
[towns taproot wallet]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019543.html
[p4tr signet]: /ja/preparing-for-taproot/#signetでのテスト
[news170 ln cve]: /ja/newsletters/2021/10/13/#ln-spend-to-fees-cve-ln-cve
[BDK 0.12.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.12.0
[0xb10c stats]: https://github.com/bitcoin/bitcoin/pull/22539#issuecomment-885763670
[optech rbf]: https://dashboard.bitcoinops.org/d/ZsCio4Dmz/rbf-signalling?orgId=1
[zeus v0.6.0-alpha3]: https://github.com/ZeusLN/zeus/releases/tag/v0.6.0-alpha3
[news167 lightning addresses]: /ja/newsletters/2021/09/22/#lightning
[sparrow 1.5.0]: https://github.com/sparrowwallet/sparrow/releases/tag/1.5.0
[whirlpool]: https://bitcoiner.guide/whirlpool/
[news161 fidelity bonds]: /ja/newsletters/2021/08/11/#implementation-of-fidelity-bonds-fidelity-bond
[joinmarket 0.9.2]: https://github.com/JoinMarket-Org/joinmarket-clientserver/releases/tag/v0.9.2
[coldcard 4.1.3]: https://blog.coinkite.com/version-4.1.3-released/
[slw 2.2.15]: https://github.com/btcontract/wallet/releases/tag/2.2.15
[Electrs 0.9.0]: https://github.com/romanz/electrs/releases/tag/v0.9.0
[Electrs 0.9.0 upgrading guide]: https://github.com/romanz/electrs/blob/master/doc/usage.md#important-changes-from-versions-older-than-090
[series preparing for taproot]: /ja/preparing-for-taproot/
