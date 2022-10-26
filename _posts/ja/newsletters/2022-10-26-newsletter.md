---
title: 'Bitcoin Optech Newsletter #223'
permalink: /ja/newsletters/2022/10/26/
name: 2022-10-26-newsletter-ja
slug: 2022-10-26-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、フルRBFの有効化に関する継続的な議論と、
CoreDev.techミーティングでの議論のいくつかの書き起こし、
LNのようなコントラクトプロトコル用に設計された一時的なアンカーアウトプットの提案を掲載しています。
また、Bitcoin Stack Exchangeから人気のある質問とその回答や、
新しいソフトウェアリリースおよびリリース候補のリスト、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、恒例のセクションも含まれています。

## ニュース

- **フルRBFに関する継続的な議論:** [先週のニュースレター][news222 rbf]で、
  最終的な支払いとしてゼロ承認（zero conf）でトランザクションを受け入れる、
  いくつかのビジネスにとって問題を引き起こす可能性がある新しい`mempoolfullrbf`オプションの組み込みについて、
  Bitcoin-Devメーリングリストでの議論をまとめました。
  今週は、メーリングリストとIRCルーム#bitcoin-core-devの両方で議論が続きました。
  議論のハイライトは次のとおりです:

  - *<!--free-option-problem-->フリーオプション問題:* Sergej Kotliarは、
    あらゆるタイプのトランザクションの置換の最大の問題は、
    無料のアメリカンコールオプションが作成されることだと考えていると[警告しました][kotliar free option]。
    たとえば、顧客アリスがマーチャントのボブからウィジェットを購入する場合、
    ボブは、現在の価格が$20,000 USD/BTCとして、1 BTCのインボイスをアリスに送ります。
    アリスはボブに1 BTCを低手数料率のトランザクションで送金します。
    交換レートが$25,000 USD/BTCになっても、トランザクションが未承認のままの場合、
    アリスは$5,000余分に支払うことを意味します。この時点で、
    アリスはトランザクションを自分に払い戻すものに置換することを合理的に選択し、
    取引を効果的にキャンセルします。しかし、交換レートがアリスに有利な方に変化した場合（たとえば、$15,000 USD/BTC）、
    ボブはアリスの支払いをキャンセルできないため、通常のオンチェーンBitcoinトランザクションでは同じオプションを行使する方法がなく、
    非対称な交換レートのリスクが生じます。それに比べて、トランザクションの置換が不可能な場合、
    アリスとボブは同じ交換レートのリスクを共有することになります。

    Kotliarは、[BIP125][]のオプトイン[RBF][topic rbf]が利用可能な現在も問題は存在すると指摘しつつ、
    フルRBFは問題を悪化させると考えているようです。

    Greg SandersとJeremy Rubinは別々の[メール][rubin cpfp]で、特に[パッケージリレー][topic package relay]が有効になると、
    マーチャントのボブは、[CPFP][topic cpfp]を使用して、顧客アリスの元のトランザクションを承認するようマイナーにインセンティブを
    与えることができると[返信しました][sanders cpfp]。

    Antoine Riardは、LNにも同じリスクが存在することを[指摘しました][riard free option]。
    アリスはマーチャントであるボブのインボイスの有効期限が切れる直前まで支払いを待つことができ、
    交換レートが変わるのを待つ時間を得ることができるからです。
    ただし、この場合、ボブが交換レートの大幅な変化に気づくと、
    ボブは自分のノードに支払いを受け取らないよう指示し、お金をアリスに返すことができます。

  - *Bitcoin Coreは、ネットワークを担当していない:* Gloria Zhaoは、
    IRCの議論で次のように[書いています][zhao no control]。
    「どのような選択肢をとっても、CoreはフルRBFが起こるかどうかをコントロールできないことをユーザーにはっきりと伝えるべきだと思います。
    [25353][bitcoin core #25353]を元に戻しても、まだ発生する可能性があります。[...]」

    ミーティングの後、Zhaoは、状況の詳細な[概要][zhao overview]も投稿しました。

  - *<!--no-removal-means-the-problem-could-happen-->削除しないと問題が発生する可能性がある:* IRCの議論の中でAnthony Townsは、
    先週の彼の指摘を[繰り返しました][towns uncoordinated]、「24.0から`mempoolfullrbf`オプションを削除しなければ、
    未調整のデプロイを行うことになる」。

    Greg Sandersは、「問題は5%以上が変数を設定するか？で、私はそうは思わない」と[疑問を呈しました][sanders doubt]。
    Townsは、「[UASF][topic soft fork activation]の`uacomment`は、わずか2週間で~11%の変数の設定が容易であるあることを実証している」と
    [返信しました][towns uasf]。

  - *<!--should-be-an-option-->オプションにすべき:* Martin Zumsandeは、IRCの議論の中で、次のように[述べています][zumsande option]。
    「かなりの数のノードオペレーターやマイナーが特定のポリシーを望んでいる場合、
    開発者が「今それはできない」というべきではないと思う。開発者は（デフォルトとすることで）推奨を与えることができ、そうすべきだが、
    情報に精通したユーザーに選択肢を提供することは決して問題ではないはずだ。」

  この記事を書いている時点で、明確な解決には至っていません。
  `mempoolfullrbf`オプションはまだ次期バージョンのBitcoin Core 24.0に含まれており、
  ゼロ承認トランザクションに依存しているサービスは、[先週のニュースレター][news222 rbf]にあるリンク先のメールを読むことから始め、
  慎重にリスク評価することがOptechの推奨事項です。

- **CoreDev.techの書き起こし:** The Atlanta Bitcoin Conference（TabConf）に先立って、
  約40人の開発者がCoreDev.techイベントに参加しました。
  このイベントの約半分のミーティングに関する[書き起こし][coredev xs]がBryan Bishopによって提供されています。
  注目すべき議論は次のとおりです:

  - [<!--transport-encryption-->トランスポートの暗号化][p2p encryption]:
    [バージョン2暗号化トランスポートプロトコル][topic v2 p2p transport]
    の提案に対する最近の更新に関する会話（[ニュースレター #222][news222 bip324]参照）。
    このプロトコルは、ネットワークの盗聴者が、どのIPアドレスからトランザクションが発生したか知るのを難しくし、
    正直なノード間の中間者攻撃に対する検知および抵抗する能力を向上させます。

    議論では、プロトコル設計上の考慮点をいくつか取り上げ、
    プロトコルの作者が特定の決定をした理由を疑問に思っている人にはお勧めの読み物です。
    また、以前の[カウンターサイン][topic countersign]認証プロトコルとの関係も検証しています。

  - [<!--fees-->手数料][fee chat]: 過去、現在、未来のトランザクション手数料に関する幅広い議論。
    ブロックは常にいっぱいのように見えるが、mempoolはそうでもない理由についての質問や、
    Bitcoinの長期的な安定性を[心配する必要がでてくる][topic fee sniping]前に重要な手数料市場が発展するまでの期間についての議論、
    問題が存在すると考えられる場合に展開可能なソリューションなどのトピックがありました。

  - [FROST][]: FROST閾値署名方式に関するプレゼンテーション。
    この書き起こしは、設計における暗号の選択に関するいくつかの優れた技術的な質問を記載し、
    特にFROSTまたは暗号プロトコルの設計全般について詳しく学びたい人にとって有益な読み物でしょう。
    Bitcoinのための別の閾値署名方式である[ROAST][]に関するTabConfの書き起こしもご覧ください。

  - [GitHub][github chat]: Bitcoin Coreプロジェクトのgitのホスティング先をGitHubから、
    別の課題・PR管理ソリューションに移行することについての検討と、GitHubを使い続けるメリットについての議論。

  - [BIPにおける証明可能な仕様][hacspec chat]: BIPで[hacspec][]形式仕様記述言語を使用して、
    証明可能な正しい仕様を提供することについての議論。
    TabConfでの関連講演の[書き起こし][hacspec preso]もご覧ください。

  - [パッケージとv3トランザクションリレー][package relay chat]:
    [パッケージトランザクションリレー][topic package relay]を有効にし、
    [Pinning攻撃][topic transaction pinning]を排除するための新しいトランザクションリレールールを使用する提案に関するプレゼンテーションの書き起こし。

  - [Stratum v2][stratum v2 chat]:
    Stratum バージョン2 プールマイニングプロトコルを実装した新しいオープンソースプロジェクトの発表から始まった議論。
    Stratum v2では、認証された接続と、
    （プールがトランザクションを選択するのではなく）個々のマイナー（ローカルのマイニング機器を持つ）がマイニングするトランザクションを選択できるよう改良されています。
    他の多くの利点に加えて、個々のマイナーが自分でブロックテンプレートを選択できることは、
    [Tornado Cash][]の論争のように、マイニングできるトランザクションを政府が強制することを懸念するプールにとって、
    非常に望ましいものになるかもしれないということが議論の中で言及されました。
    議論の大半は、Stratum v2のネイティブサポートを可能にするためにBitcoin Coreに加える必要のある変更に集中していました。
    分散型のプールマイニングプロトコル[Braidpool][braidpool chat]についてのTabConfの書き起こしもご覧ください。

  - [Merging][merging chat]はBitcoin Coreプロジェクトでコードをレビューしてもらうための戦略についての議論ですが、
    多くの提案は他のプロジェクトにも当てはまります。以下のようなアイディアがありました:

    - 大きな変更はいくつかの小さなPRに分割する。

    - レビューアが最終的な目的を理解しやすいようにする。すべてのPRについて、
      動機づけとなるPRの説明を書くことを意味します。インクリメンタルに行われる変更については、
      トラッキングイシューや、プロジェクトボートを使用し、リファクタリングの動機づけとなるPRを公開し、
      そのリファクタリングされたコードを使用して望ましい目標を達成する。

    - 長期的なプロジェクトでは、プロジェクトの前の状態、現在の進捗、結果を達成するために必要なこと、
      ユーザーに提供されるメリットについて説明するハイレベルな説明資料を作成する。

    - 同じプロジェクトやコードサブシステムに興味のある人とワーキンググループを作る。

- **<!--ephemeral-anchors-->一時的なアンカー:** Greg Sandersは、
  v3トランザクションリレーに関する以前の議論（[ニュースレター #220][news220 ephemeral]参照）に続いて、
  新しいタイプの[アンカーアウトプット][topic anchor outputs]に関する提案をBitcoin-Devメーリングリストに[投稿しました][sanders ephemeral]。
  v3トランザクションが支払う手数料はゼロですが、`OP_TRUE`スクリプトへ支払うアウトプットを持ち、
  誰もが子トランザクションでコンセンサスルールの下でそれを使用できるようにします。
  未承認のゼロ手数料の親トランザクションは、
  そのOP_TRUEアウトプットを使用する子トランザクションも含まれているトランザクションパッケージの一部である場合のみ、
  Bitcoin Coreでリレーされマイニングされます。これはBitcoin Coreのポリシーにのみ影響し、コンセンサスルールを変更するものではありません。

  この提案の利点として、[トランザクションのPinning][topic transaction pinning]を防ぐための1ブロックの相対タイムロック（
  これを可能にするために使用されるコードにちなんで`1 OP_CSV`と呼ばれる）を使用する必要性を排除し、
  誰でも親トランザクションの手数料を引き上げられることが挙げられます（以前の[手数料スポンサー][topic fee sponsorship]ソフトフォークの提案と同様）。

  Jeremy Rubinは、この提案を支持する[返信をしました][rubin ephemeral]が、
  v3トランザクションを使用できないコントラクトでは機能しないと指摘しました。
  他の何人かの開発者もコンセプトについて議論し、この記事を書いている時点では、
  全員魅力的に感じているようでした。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-would-someone-use-a-1-of-1-multisig-->1-of-1のマルチシグを使用するのは何故ですか？]({{bse}}115443)
  Vojtěch Strnadは、P2WPKHが安価でより大きな匿名セットを持つにもかかわらず、
  P2WPKHではなく1-of-1のマルチシグを使用するのか？と質問しています。
  Murchは、少なくとも1つのエンティティが年間何百万もの1-of-1のUTXOを使用していることを示すリソースを挙げていますが、
  その動機は依然として不明瞭です。

- [<!--why-would-a-transaction-have-a-locktime-in-the-year-1987-->1987のロックタイムを持つトランザクションがあるのは何故ですか？]({{bse}}115549)
  1440000bytesは、ロックタイムフィールドを「上位8ビットは0x20、下位24ビットは隠されたコミットメントトランザクションの数の下位24bit」として割り当てる
  BOLT 3ライトニング仕様の[セクション][bolt 3 commitment]を参照するChristian Deckerのコメントを指摘しています。

- [UTXOセットのサイズに制限がある場合、それは何ですか？]({{bse}}115439)
  Pieter Wuilleは、UTXOセットのサイズにコンセンサスの制限はなく、UTXOセットの成長率は、
  ブロック内で作成できるUTXOの数を制限するブロックサイズによって制限されると回答しています。
  [関連する回答で][se murch utxo calcs]、Murchは地球上のすべての人にUTXOを作成すると約11年かかると推定しています。

- [デフォルトで`-blockmaxweight`が3996000に設定されているのは何故ですか？]({{bse}}115499)
  Vojtěch Strnadは、Bitcoin Coreの`-blockmaxweight`のデフォルト設定が3,996,000で、
  segwitの上限である4,000,000 weight unit（vbyte）より小さいことを指摘しています。
  Pieter Wuilleは、この差はマイナーが、ブロックテンプレートによって作成されるデフォルトのコインベーストランザクションを超える、
  追加のアウトプットを持つより大きなコインベーストランザクションを追加するためのバッファースペースになると説明しています。

- [<!--can-a-miner-open-a-lightning-channel-with-a-coinbase-output-->マイナーはコインベースアウトプットでライトニングのチャネルを開くことができますか？]({{bse}}115588)
  Murchは、マイナーがコインベーストランザクションのアウトプットを使用してライトニングチャネルを作成する際の課題として、
  コインベースの成熟期間によるチャネルの閉鎖の遅延や、マイニング中にコインベーストランザクションのハッシュが常に変化するため、
  ハッシュ中にチャネルの開設について常に再ネゴシエーションする必要があることを指摘しています。

- [<!--what-is-the-history-on-how-previous-soft-forks-were-tested-prior-to-being-considered-for-activation-->これまでのソフトフォークは、アクティベーションを検討する前にどのようにテストされたのでしょうか？]({{bse}}115434)
  Michael Folksonは、Anthony Townsの[最近のメーリングリストの投稿][aj soft fork testing]を引用し、
  P2SH、CLTV、CSV、segwit、[taproot][topic taproot]、CTVおよび[Drivechain][topic sidechains]の提案に関するテストを説明しました。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LDK 0.0.112][]は、LN対応アプリケーションを構築するためのこのライブラリのリリースです。

- [Bitcoin Core 24.0 RC2][]は、ネットワークで最も広く使われているフルノード実装の次期バージョンの最初のリリース候補です。
  [テストのガイド][bcc testing]が利用できるようになっています。

  **警告:** このリリース候補には、`mempoolfullrbf`設定オプションが含まれており、
  いくつかのプロトコルやアプリケーション開発者は、今週および先週のニュースレターで説明したように、
  マーチャントサービスに対して問題を引き起こす可能性があると考えています。
  Optechは、影響を受ける可能性のあるサービスに対して、RCを評価し、公開討論に参加することを推奨しています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #23443][]は、新しいP2Pプロトコルメッセージ`sendtxrcncl`(send transaction reconciliation)を追加し、
  ノードが[erlay][topic erlay]のサポートをピアに通知できるようにしました。
  このPRは、erlayプロトコルの最初のパーツのみを追加し、これを使用する前に他のパーツが必要です。

- [Eclair #2463][]と[#2461][eclair #2461]は、Eclairの[対話型のデュアルファンディングプロトコル][topic dual funding]の実装を更新し、
  すべてのインプットに対して[RBF][topic rbf]へのオプトインと承認済みであること（つまり、既にブロックチェーン内にあるアウトプットの使用）を求めるようになりました。
  これらの変更により、確実にRBFが使用できるようにし、Eclairユーザーが拠出した手数料がピアの以前のトランザクションの承認のために使用されることはありません。

{% include references.md %}
{% include linkers/issues.md v=2 issues="23443,2463,2461,25353" %}
[bitcoin core 24.0 rc2]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[ldk 0.0.112]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.112
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[news222 rbf]: /ja/newsletters/2022/10/19/#transaction-replacement-option
[kotliar free option]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021056.html
[sanders cpfp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021060.html
[rubin cpfp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021059.html
[riard free option]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021067.html
[zhao no control]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-440
[towns uncoordinated]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-488
[sanders doubt]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-490
[towns uasf]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-492
[zumsande option]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-493
[coredev xs]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/
[p2p encryption]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-10-p2p-encryption/
[news222 bip324]: /ja/newsletters/2022/10/19/#bip324
[fee chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-fee-market/
[frost]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-frost/
[roast]: https://diyhpl.us/wiki/transcripts/tabconf/2022/roast/
[github chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-github/
[hacspec chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-hac-spec/
[hacspec]: https://hacspec.github.io/
[hacspec preso]: https://diyhpl.us/wiki/transcripts/tabconf/2022/hac-spec/
[package relay chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-package-relay/
[stratum v2 chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-stratum-v2/
[tornado cash]: https://www.coincenter.org/analysis-what-is-and-what-is-not-a-sanctionable-entity-in-the-tornado-cash-case/
[braidpool chat]: https://diyhpl.us/wiki/transcripts/tabconf/2022/braidpool/
[merging chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-12-merging/
[news220 ephemeral]: /ja/newsletters/2022/10/05/#dust
[sanders ephemeral]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021036.html
[rubin ephemeral]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021041.html
[bolt 3 commitment]: https://github.com/lightning/bolts/blob/316882fcc5c8b4cf9d798dfc73049075aa89d3e9/03-transactions.md#commitment-transaction
[se murch utxo calcs]: https://bitcoin.stackexchange.com/questions/111234/how-many-useable-utxos-are-possible-with-btc-inside-them/115451#115451
[aj soft fork testing]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020964.html
[zhao overview]: https://github.com/glozow/bitcoin-notes/blob/full-rbf/full-rbf.md
