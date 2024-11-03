---
title: 'Bitcoin Optech Newsletter #298'
permalink: /ja/newsletters/2024/04/17/
name: 2024-04-17-newsletter-ja
slug: 2024-04-17-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、2023年にネットワーク上で確認されたすべてのトランザクションを
クラスターmempoolのノードでテストしたらどのように動作したかの分析を掲載しています。
また、クライアントとサービスの最近の更新や、新しいリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **もしクラスターmempoolが1年前に導入されていたらどうなっていたか？**
  Suhas Daftuarは、彼のノードが2023年に受信したすべてのトランザクションを記録し、
  現在それらを[クラスター mempool][topic cluster mempool]を有効にしたBitcoin Coreの開発版で実行し、
  既存版と開発版の違いを定量化したことをDelving Bitcoinに[投稿しました][daftuar cluster]。
  彼の発見には以下のようなものがあります:

  - *<!--the-cluster-mempool-node-accepted-0-01-more-transactions-->クラスターmempoolノードは0.01%ほど多くのトランザクションを受け入れました:*
    「2023年、[ベースラインノード]の祖先/子孫の制限により、ある時点で46,000を超えるトランザクションが拒否されました。
    [...]クラスターのサイズ制限にヒットしたため拒否されたトランザクションは14,000 件以下でした。」
    クラスターmempoolノードによって最初に拒否されたトランザクションのうち約10,000件は（14,000件の70%）、
    祖先の一部が承認された後に再ブロードキャストしたら、後で受け入れられるもので、これは期待されるウォレットの動作です。

  - *RBFの差は僅かでした:* 「2つのシミュレーションで適用されたRBFルールは異なりますが、
    ここでの総受け入れ数への影響は微々たるものでした。」詳細については以下をご覧ください。

  - *<!--cluster-mempool-was-just-as-good-for-miners-as-legacy-transaction-selection-->クラスターmempoolは、マイナーにとって従来のトランザクション選択と同様に優れていました:*
    Daftuarは、現在ほぼすべてのトランザクションがブロックに格納されるため、
    Bitcoin Coreの現在のトランザクション選択とクラスターmempoolのトランザクション選択の両方が、
    実際にほぼ同額の手数料を獲得することになると指摘しています。しかし、
    Daftuarが結果を誇張している可能性が高いと警告している分析では、
    クラスターmempoolは約73%の確率で従来のトランザクション選択よりも多くの手数料を獲得しました。
    従来のトランザクション選択の方が優れていたのは約8%でした。Daftuarは次のように結論づけています。
    「2023年のネットワーク活動に基づくと、
    クラスターmempoolがベースラインより実質的に優れているかどうかについては結論が出ないかもしれませんが、
    クラスターmempoolが実質的に劣っている可能性は非常に低いと思われます。」

  Daftuarはまた、[RBFによるトランザクションの置換][topic rbf]に対するクラスターmempoolの影響についても考察しました。
  彼はまず、Bitcoin Coreの現在のRBFの動作と、
  クラスターmempoolの下でRBFがどのように動作するのかの違いについてまとめています（強調とリンクは原文のまま）:

  > クラスターmempoolのRBFルールは、置換が行われた後で
  > [mempoolのfeerate diagramが改善されるか][feerate diagram]どうかを中心にしていますが、
  > Bitcoin Coreの既存のRBFルールは、BIP125で説明されており、
  > [ここで文書化されている][rbf doc]ものとほぼ同じです。
  >
  > BIP125とは異なり、提案されている[クラスター mempool]RBFルールは、
  > 置換の _結果_ に焦点を当てています。txは実際よりも理論の方が優れている可能性があります。
  > おそらく、理論的にはmempoolにとって良いとされる基準に基づいて受け入れられるべきかもしれませんが、
  > 結果のfeerate diagramが何らかの理由（たとえば、線形化アルゴリズムが最適でないなど）で悪くなるのであれば、
  > 置換は拒否されます。

  私たちは、彼が提供したデータと分析によって十分に立証されていると感じた、
  レポートのそのセクションの彼の結論を繰り返します:

  > 全体として、クラスターmempoolと既存のポリシーのRBFの違いは最小限でした。
  > 異なる点は、提案されている新しいRBFルールは、インセンティブに適合しない置換からmempoolを保護するもので、これは良い変更です。
  > しかし理論的には、理想的な世界では[現在]受け入れられる置換が阻止される可能性があることに注意することも重要です。
  > なぜなら、一見良さそうな置換が、（BIP125ポリシーにより）以前は検出されなかったものの、
  > 新しいルールで検出および防止され、最適でない動作を引き起こす可能性があるためです。

  この記事を書いている時点では、この投稿に対する返信はありませんでした。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **サーバー用のPhoenixの発表:**
  Phoenix Walletは、支払いの送受信に重点を置いた簡素化されたヘッドレスライトニングノード
  [phoenixd][phoenixd github]を発表しました。phoenixdは、
  開発者を対象にしており、既存のPhoenix Walletソフトウェアをベースにし、
  チャネル、ピア、流動性の管理を自動化します。

- **Mercury Layerがライトニングスワップを追加:**
  Mercury Layer[ステートチェーン][topic statechains]は、[ホールドインボイス][topic hold invoices]を使用して、
  ステートチェーンのコインをライトニング支払いとスワップできるようになりました。

- **Stratum V2参照実装v1.0.0リリース:**
  [v1.0.0リリース][sri blog]は「ワーキンググループの協力と厳格なテストによるStratum V2仕様の改善結果」です。

- **Teleport Transactionsのアップデート:**
  [オリジナルのTeleport Transactions][news192 tt]リポジトリのフォークが、
  いくつかの完了したアップデートおよび改善とともに[発表されました][tt tweet]。

- **Bitcoin Keeper v1.2.1リリース:**
  [v1.2.1リリース][bitcoin keeper v.1.2.1]では、[Taproot][topic taproot]ウォレットがサポートされました。

- **BIP-329ラベル管理ソフトウェア:**
  [Labelbase][labelbase blog]のバージョン2リリースには、セルフホストオプションと、
  [BIP329][]インポート/エクスポート機能が含まれています。

- **キーエージェントSigbashのローンチ:**
  [Sigbash][]署名サービスは、ユーザーが指定した特定の条件（ハッシュレートや、Bitcoinの価格、
  アドレス残高、一定期間後）が満たされた場合にのみ[PSBT][topic psbt]の署名を行うマルチシグ設定で使用する
  xpubを購入できるようになります。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 27.0][]は、ネットワークの主要なフルノード実装の次期メジャーバージョンのリリースです。
  この新バージョンでは、libbitcoinconsensusを非推奨とし（ニュースレター[#288][news288 libconsensus]および
  [#297][news297 libconsensus]参照）、
  [v2暗号化P2Pトランスポート][topic v2 p2p transport]をデフォルトで有効にし（[ニュースレター #288][news288 v2 p2p]参照）、
  testnet上でオプトインの[TRUC][topic v3 transaction relay]（Topologically Restricted Until
  Confirmation）トランザクションポリシーの使用を可能にし（[ニュースレター #289][news289 truc]参照）、
  高手数料率の際に使用される新しい[コイン選択][topic coin selection]戦略を追加しました（[ニュースレター #290][news290 coingrinder]参照）。
  主要な変更点の完全なリストについては、[リリースノート][bcc27 rn]をご覧ください。

- [BTCPay Server 1.13.1][]は、このセルフホスト型ペイメントプロセッサーの最新リリースです。
  前回[ニュースレター #262][news262 btcpay]でBTCPay Serverのアップデートを取り上げて以来、
  Webフックの[拡張性を高め][btcpay server #5421]、
  [BIP129][]マルチシグウォレットのインポートをサポートし（[ニュースレター #281][news281 bip129]参照）、
  プラグインの柔軟性を向上させ、すべてのアルトコインサポートをプラグインに移行し始め、
  BBQrエンコードされた[PSBT][topic psbt]のサポート（[ニュースレター #295][news295 bbqr]参照）など、
  多数の新機能とバグ修正が含まれています。

- [LDK 0.0.122][]は、LN対応アプリケーションを構築するためのこのライブラリの最新リリースです。
  これはサービス拒否の脆弱性を修正した[0.0.121][ldk 0.0.121]リリースに続くものです。
  最新リリースでは、いくつかのバグも修正されています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。*

- [LDK #2704][]は、`ChannelManager`クラスに関するドキュメントを大幅に更新および拡張しました。
  チャネルマネージャーは、「ライトニングノードのチャネルステートマシンと支払い管理ロジックで、
  ライトニングチャネルを介した支払いの送信、転送、受信を容易にします。」

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2704,5421" %}
[Bitcoin Core 27.0]: https://bitcoincore.org/bin/bitcoin-core-27.0/
[feerate diagram]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553/1
[rbf doc]: https://github.com/bitcoin/bitcoin/blob/0de63b8b46eff5cda85b4950062703324ba65a80/doc/policy/mempool-replacements.md
[daftuar cluster]: https://delvingbitcoin.org/t/research-into-the-effects-of-a-cluster-size-limited-mempool-in-2023/794
[bcc27 rn]: https://github.com/bitcoin/bitcoin/blob/c7567d9223a927a88173ff04eeb4f54a5c02b43d/doc/release-notes/release-notes-27.0.md
[news288 libconsensus]: /ja/newsletters/2024/02/07/#bitcoin-core-29189
[news297 libconsensus]: /ja/newsletters/2024/04/10/#bitcoin-core-29648
[news288 v2 p2p]: /ja/newsletters/2024/02/07/#bitcoin-core-29347
[news289 truc]: /ja/newsletters/2024/02/14/#bitcoin-core-28948
[news290 coingrinder]: /ja/newsletters/2024/02/21/#bitcoin-core-27877
[news281 bip129]: /ja/newsletters/2023/12/13/#btcpay-server-5389
[news295 bbqr]: /ja/newsletters/2024/03/27/#btcpay-server-5852
[news262 btcpay]: /ja/newsletters/2023/08/02/#btcpay-server-1-11-1
[ldk 0.0.122]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.122
[ldk 0.0.121]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.121
[btcpay server 1.13.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.13.1
[phoenixd github]: https://github.com/ACINQ/phoenixd
[sri blog]: https://stratumprotocol.org/blog/sri-1-0-0/
[news192 tt]: /ja/newsletters/2022/03/23/#coinswap-teleport-transactions
[tt tweet]: https://twitter.com/RajarshiMaitra/status/1768623072280809841
[bitcoin keeper v.1.2.1]: https://github.com/bithyve/bitcoin-keeper/releases/tag/v1.2.1
[labelbase blog]: https://labelbase.space/ann-v2/
[Sigbash]: https://sigbash.com/
