---
title: 'Bitcoin Optech Newsletter #230'
permalink: /ja/newsletters/2022/12/14/
name: 2022-12-14-newsletter-ja
slug: 2022-12-14-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、チャネル・ファクトリーとの互換性を改善する可能性のあるLNの修正バージョンの提案と、
LNプロトコルを変更することなくチャネルジャミング攻撃のいくつかの影響を軽減するソフトウェア、
シグナルのないトランザクションの置換を追跡するためのウェブサイトのリンクを掲載しています。
また、新しいクライントとサービスソフトウェアの発表や、
Bitcoin Stack Exchangeの人気のある質問とその回答、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など恒例のセクションも含まれています。

## ニュース

- **ファクトリーに最適化したLNプロトコルの提案:** John Lawは、
  [チャネル・ファクトリー][topic channel factories]の作成に最適化したプロトコルの説明を
  Lightning-Devメーリングリストに[投稿しました][law factory]。
  チャネル・ファクトリーでは、複数のユーザーが1つのオンチェーントランザクションのみで、
  ユーザーのペア間の複数のチャネルをトラストレスに開設することができます。
  たとえば、20人のユーザーが協力し、通常の2者間のチャネル開設の約10倍の規模のオンチェーントランザクションを作成して、
  合計190個のチャネルを開設することができます。

    Lawは、（通常LNペナルティと呼ばれる）既存のLNチャネルプロトコルは、
    ファクトリー内で開設されたチャネルについて2つの問題を生じさせると指摘しています:

    - *HTLCの有効期限の長期化:* トラストレスであるためには、
      ファクトリー内の参加者がファクトリーから退出し、オンチェーンで自身の資金について独占的に管理できるようにする必要があります。
      これは、参加者がファクトリー内の現在の残高の状態をオンチェーンに公開することで実現されます。
      しかし、参加者が以前の状態（たとえば自分がより多くの資金を管理していた状態）を公開するのを防ぐ仕組みが必要です。
      オリジナルのファクトリーの提案では、1つ以上のタイムロックされたトランザクションを使用することで、
      古い状態よりも最新の状態をより迅速に承認できるようにします。

        この結果、Lawが説明したように、チャネル・ファクトリー内のチャネルを経由したLN支払い（[HTLC][topic htlc]）は、
        ファクトリーが一方的に閉鎖できるように、最新の状態のタイムロックが失効するのに十分な時間を提供する必要があります。
        さらにまずいことに、これは支払いがファクトリーを介して転送されるたびに適用されます。
        たとえば支払いが、それぞれ1日の有効期限を持つ10個のファクトリーを経由して転送される場合、
        支払いが偶然もしくは意図的に10日間（他のHTLCの設定によってはそれ以上）[妨害される][topic channel jamming attacks]可能性があります。

    - *<!--all-or-nothing-->オール・オア・ナッシング :* ファクトリーが本当に最高の効率を達成するためには、
      ファクトリー内のすべてのチャネルが、協力して単一のオンチェーントランザクションでクローズされる必要があります。
      参加者のいずれかが応答しなくなった場合、協調クローズは不可能です。
      参加者の数が増えるにつれ、参加者が応答しなくなる確率は100％に近づき、ファクトリーが提供できる最大のメリットは制限されます。

        Lawは、`OP_TAPLEAF_UPDATE_VERIFY`や`OP_EVICT`の提案（ニュースレター[#166][news166 tluv]および[#189][news189 evict]参照）
        のように、参加者の1人が退出したい場合もしくは応答がない場合でもファクトリーの運用を継続できるようにする以前の研究を引用しています。

    この懸念事項に対処するため、Lawは3つのプロトコルを提案しています。
    いずれも10月にLawが[投稿した][law tp]*調整可能なペナルティ*（執行の仕組み（ペナルティ）の管理を他の資金の管理から分離する機能）の提案に由来するものです。
    この以前の提案は、Lightning-Devメーリングリストでまだ議論されていません。
    この記事を書いている時点では、Lawの新しい提案もまだ議論されていません。
    この提案が健全であれば、Bitcoinのコンセンサスルールを変更する必要がないという他の提案よりもメリットがあります。

- **<!--local-jamming-to-prevent-remote-jamming-->リモートジャミングを防ぐためのローカルジャミング:**
  Joost Jagerは、Lightning-Devメーリングリストに彼のプロジェクトである[CircuitBreaker][]のリンクと説明を[投稿しました][jager jam]。
  このプログラムはLNDと互換性を持つように設計されており、ローカルノードが各ピアに転送する保留中の支払い（[HTLC][topic htlc]）の数の制限を強制します。
  たとえば、最悪の場合のHTLCのジャミング攻撃を考えてみましょう:

    ![2種類のジャミング個劇の図解](/img/posts/2020-12-ln-jamming-attacks.png)

    現在のLNプロトコルでは、アリスは基本的に同時に転送可能な保留中のHTLCの数を最大[483個][483 pending HTLCs]に制限しています。
    アリスが代わりにCircuitBreakerを使用すると、マロリーとのチャネルの同時保留HTLCを10個に制限し、
    （図示されていない）ボブとの下流チャネルや他のチャネルは、マロリーが保留している10個のHTLCを除くすべてから保護されます。
    これにより、マロリーは同じ数のHTLCスロットをブロックするのにさらに多くのチャネルを開く必要があるため、
    マロリーの攻撃の有効性が著しく低下する可能性があり、さらにより多くのオンチェーン手数料を支払う必要があるため攻撃コストも増加します。

    CircuitBreakerはもともと上限を超えたチャネルのHTLCの受け入れを単に拒否するだけの実装でしたが、
    Jagerは最近オプションで追加モードを実装し、HTLCをすぐに転送したり拒否するのではなく、
    キューに入れるようにしたと述べています。あるチャネルの同時保留中のHTLCの数がチャネルの制限を下回ると、
    CircuitBreakerはキューから最も古い有効期限の切れていないHTLCを転送します。
    Jagerはこのアプローチの2つの利点を説明しています:

    - *<!--backpressure-->バックプレッシャー:* 経路の途中にあるノードがHTLCを拒否した場合、
      経路内のすべてのノード（下流ノードだけでなく）は、そのHTLCのスロットと資金を別の支払いの転送に使用することができます。
      つまり、アリスがマロリーから10を超えるHTLCを拒否するインセンティブは限定されてます。
      アリスは経路内の後のノードでCircuitBreakerまたは同等のソフトウェアが実行されるのを期待するだけです。

        しかし、後のノード（ボブとします）がCircuitBreakerを使って制限を超えるHTLCをキューに入れると、
        ボブや経路内のそれ以降のノードにとっては現在と同じ利点があったとしても、
        アリスは自身のスロットまたは資金をマロリーによって枯渇させられる可能性があります
        （ただし、場合によってはボブのチャネルクローズコストが増加する可能性があります。
        詳細はJagerのメールやCircuitBreakerのドキュメントを参照ください）。
        これはアリスにCircuitBreakerや同等のソフトウェアを実行することを穏やかに迫ります。

    - *<!--failure-attribution-->失敗の原因:*
      現在のLNプロトコルでは、（多くの場合）支払人はHTLCの転送を拒否したチャネルを特定できます。
      一部のソフトウェアは、将来のHTLCでこれらのチャネルを一定期間使用しないようにします。
      マロリーのような悪意あるユーザーからのHTLCを拒否する場合、これは問題ではありませんが、
      ノードがCircuitBreakerを実行し正直な支払人からのHTLCを拒否した場合、
      拒否したHTLCによる収益が減るだけでなく、その後の支払いの試行から受け取る可能性のあった収益も減少する可能性があります。

        ただし、現在のLNプロトコルにはどのチャネルがHTLCを遅延させたかを判断する広く展開された方法がないため、
        この点については、HTLCの転送を完全に拒否するよりも遅延させた方が影響は少なくなります。
        Jagerは、多くのLN実装がより詳細なオニオンルーティングされたエラーメッセージ（[ニュースレター #224][news224 fat]参照）
        のサポートに取り組んでいるため、この利点がいつか消えるかもしれないと指摘しています。

    JagerはCircuitBreakerを「チャネルジャミングやスパムに対処するための単純だが不完全な方法」としています。
    ジャミング攻撃に関する懸念をより包括的に軽減するプロトコルレベルの変更を発見して展開する研究は続いていますが、
    CircuitBreakerは現在のLNプロトコルと互換性があり、LNDのユーザーが自分の転送ノードにすぐに展開できるという、
    一見妥当な解決策として際立っています。CircuitBreakerはMITライセンスで、概念的にシンプルなので、
    他のLN実装への適用や移植も可能なはずです。

- **フルRBF置換のモニタリング:** 開発者の0xB10Cは、
  BIP125のシグナルを含まないBitcoin Coreノードのmempool内のトランザクションの置換について
  [一般にアクセス可能な][rbf mpo]モニタリングの提供を開始したことをBitcoin-Devメーリングリストに[投稿しました][0xb10c rbf]。
  これらのBitcoin Coreのノードは、`mempoolfullrbf`設定オプションを使用してフルRBFを可能にします（[ニュースレター #208][news208 rbf]参照）。

    ユーザーやサービスは、どの大規模マイニングプールが現在シグナルのない置換トランザクションを承認しているか（承認している場合は）の
    指標としてウェブサイトを使用できます。ただし、マイナーが現在シグナルのない置換をマイニングしていないように見えても、
    未承認トランザクションで受け取った支払いは保証できないことを覚えておいてください。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Lily Walletがコイン選択機能を追加:**
  Lily Wallet [v1.2.0][lily v1.2.0]は、[コイン選択][topic coin selection]機能を追加しました。

- **VortexソフトウェアがCoinJoinからLNチャネルを作成:**
  [Taproot][topic taproot]と共同[CoinJoin][topic coinjoin]トランザクションを使用して、
  ユーザーは[Vortex][vortex github]ソフトウェアを使用してBitcoinのmainnet上で[LNチャネルを開設しました][vortex tweet]。

- **MutinyがブラウザでのLNノードのPoC:**
  開発者は、WASMとLDKを使用して、携帯電話のブラウザで動作するLNノードの実装の[概念実証][mutiny github]を[デモしました][mutiny tweet]。

- **CoinkiteがBinaryWatch.orgをローンチ:**
  [BinaryWatch.org][]は、Bitcoin関連のプロジェクトのバイナリをチェックし、
  変更されていないかチェックするウェブサイトです。
  また、Bitcoin関連のプロジェクトの[再現可能なビルド][topic reproducible builds]をアーカイブするサービス
  [bitcoinbinary.org][]も運営しています。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-is-connecting-to-the-bitcoin-network-exclusively-over-tor-considered-a-bad-practice-->TorのみでBitcoinネットワークに接続するのは、なぜバッドプラクティスだと考えられているのですか？]({{bse}}116146)
  IPv4やIPv6アドレスと比較して、Torアドレスを多数生成するコストは低いため、
  クリアネットのみや[匿名ネットワーク][topic anonymity networks]を組み合わせて運用する場合と比較して、
  Torネットワークのみを使用するBitcoinノードオペレーターは、
  より簡単に[エクリプス攻撃][topic eclipse attacks]を受ける可能性があると説明する回答がいくつかありました。

- [<!--why-aren-t-3-party-or-more-channels-realistically-possible-in-lightning-today-->ライトニングではななぜ三者間（またはそれ以上）のチャネルが現実的に可能ではないのですか？]({{bse}}116257)
  Murchは、LNチャネルは現在、違反があった場合に*すべて*のチャネルの資金を単一の相手に割り当てるLNペナルティの仕組みを使用しており、
  ジャスティス・トランザクションで複数の受取人を扱うようLNペナルティを拡張すると、
  過度に複雑で実装に過剰なオーバーヘッドを伴う可能性があると説明しています。
  続いて、[eltoo][topic eltoo]の仕組みと、それがどうマルティパーティチャネルを扱うかについて説明しています。

- [<!--with-legacy-wallets-deprecated-will-bitcoin-core-be-able-to-sign-messages-for-an-address-->レガシーウォレットの非推奨に伴い、Bitcoin Coreはアドレスに対するメッセージに署名できるのでしょうか？]({{bse}}116187)
  Pieter Wuilleは、Bitcoin Coreが[レガシーウォレットを非推奨とする][news125 legacy descriptor wallets]ことと、
  新しい[ディスクリプター][topic descriptors]ウォレットでもP2PKHアドレスなどの古いアドレスタイプのサポートを継続することを区別しています。
  メッセージの署名は現在P2PKHアドレスに対してのみ可能ですが、
  [BIP322][topic generic signmessage]に関する取り組みにより、
  他のアドレスタイプでもメッセージの署名が可能になる可能性があります。

- [<!--how-do-i-set-up-a-time-decay-multisig-->時間とともに減衰するマルチシグのセットアップ方法について]({{bse}}116035)
  ユーザーYodaは、時間の経過とともに広範な公開鍵のセットで使用することができるようになるUTXOをセットアップする方法を質問しています。
  Michael Folksonは、[ポリシー][news74 policy miniscript]と[Miniscript][topic miniscript]を使った例と、
  関連するリソースのリンクを提供し、現在ユーザーフレンドリーなオプションがないことを指摘しています。

- [<!--when-is-a-miniscript-solution-malleable-->Miniscriptのソリューションにマリアビリティがあるのはいつですか？]({{bse}}116275)
  Antoine Poinsotは、Miniscriptにおけるマリアビリティが何を意味するかを定義し、
  Miniscriptのマリアビリテティの静的分析について説明し、
  元の質問のマリアビリティの例について説明しています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Core 24.0.1][]は、最も広く利用されているフルノードソフトウェアのメジャーリリースです。
  その新機能には、ノードのRBF（[Replace-By-Fee][topic rbf]）ポリシーを設定するオプションや、
  単一のトランザクションでウォレットの資金をすべて簡単に使用するため
  （またはお釣りのアウトプットのないトランザクションを作成するため）の新しい`sendall`RPC、
  トランザクションがウォレットに与える影響を検証するために（たとえば、
  CoinJoinトランザクションが手数料によってウォレットの金額を減少させるだけであること確認するなど）
  使用できる`simulaterawtransaction`RPC、
  他のソフトウェアとの互換性を高めるために[Miniscript][topic miniscript]の式を含む
  監視専用の[ディスクリプター][topic descriptors]を作成する機能、
  GUIで行った特定の設定変更をRPCベースのアクションに自動適用する機能などが含まれています。
  新しい機能とバグ修正の完全なリストについては、[リリースノート][bcc rn]をご覧ください。

    注意：バージョン24.0はタグ付けされバイナリがリリースされましたが、
    プロジェクトのメンテナーはそれを発表せず、他のコントリビューターとともに、
    [直前に見つかった問題][bcc milestone 24.0.1]を解決したため、
    この24.0.1のリリースが24.xブランチの最初に発表されたリリースになりました。

- [libsecp256k1 0.2.0][]は、Bitcoin関連の暗号処理に広く使用されているこのライブラリの最初のタグ付きリリースです。
  このリリースの[発表][libsecp256k1 announce]では、
  「長い間、libsecp256k1の開発にはmasterブランチしかなく、
  APIの互換性と安定性に関して不明確な点がありました。
  今後は関連する改良がマージされた際にタグ付きのリリースを作成し、
  セマンティックバージョニング方式に従います。[...]
  バージョン0.1.0は、何年も前からautotoolsのビルドスクリプトで設定されていたバージョン番号で、
  ソースファイルのセットを一意に識別できないため、スキップすることにしました。
  バイナリリリースは作成しませんが、予想されるABI互換の問題を考慮して、
  リリースノートとバージョニングを作成する予定です。」

- [Core Lightning 22.11.1][]は、一部の開発者からの要望で、
  22.11で非推奨となった機能を一時的に再導入するマイナーリリースです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #25934][]は、`listsinceblock`RPCにオプションの`label`引数を追加しました。
  labelが指定された場合、それにマッチするトランザクションのみが返されます。

- [LND #7159][]は、`ListInvoiceRequest`RPCと`ListPaymentsRequest`RPCに
  新しい`creation_date_start`フィールドと`creation_date_end`フィールドを追加し、
  指定した日時の前か後のインボイスと支払いのフィルタリングに使用できるようにしました。

- [LDK #1835][]は、インターセプトしたHTLCに対して偽のSCID（Short Channel IDentifier）名前空間を追加し、
  LSP（Lightning Service Provider）がエンドユーザーに対して、
  ライトニング支払いを受けるためのJIT（[just-in-time][topic jit routing]）チャネルを作成できるようにします。
  これはエンドユーザーのインボイスに偽のルートヒントを含めることで、
  [ファントム・ペイメント][LDK phantom payments]と同様に、
  インターセプト転送であることをLDKに通知します（[ニュースレター #188][news188 phantom]参照）。
  LDKはその後イベントを発生させ、LSPにJITチャネルを開く機会を与えます。
  LSPは、新しく開設したチャネルで支払いを転送するか、失敗させることができます。

- [BOLTs #1021][]は、オニオンルーティングのエラーメッセージに[TLV][]ストリームを含めることができるようにしました。
  これは、将来、障害に関する追加情報を含めるために使用される可能性があります。
  これは、[BOLTs #1044][]で提案されたように、[ファット・エラー][news224 fat]を実装するための最初のステップです。

## ハッピーホリデー！

これは、Bitcoin Optechの今年最後の定期ニュースレターとなります。
12月21日（水）には、5回目の年間の振り返り特別号を発行します。
通常の発行は、1月4日（水）から再開します。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25934,7159,1835,1021,1044" %}
[bitcoin core 24.0.1]: https://bitcoincore.org/bin/bitcoin-core-24.0.1/
[bcc rn]: https://bitcoincore.org/ja/releases/24.0.1/
[bcc milestone 24.0.1]: https://github.com/bitcoin/bitcoin/milestone/59?closed=1
[libsecp256k1 0.2.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.2.0
[libsecp256k1 announce]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021271.html
[core lightning 22.11.1]: https://github.com/ElementsProject/lightning/releases/tag/v22.11.1
[news224 fat]: /ja/newsletters/2022/11/02/#ln
[law factory]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-December/003782.html
[news166 tluv]: /ja/newsletters/2021/09/15/#covenant-opcode-proposal-covenant-opcode
[news189 evict]: /ja/newsletters/2022/03/02/#utxo-opcode
[law tp]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003732.html
[jager jam]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-December/003781.html
[circuitbreaker]: https://github.com/lightningequipment/circuitbreaker
[0xb10c rbf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-December/021258.html
[rbf mpo]: https://fullrbf.mempool.observer/
[news208 rbf]: /ja/newsletters/2022/07/13/#bitcoin-core-25353
[tlv]: https://github.com/lightning/bolts/blob/master/01-messaging.md#type-length-value-format
[LDK phantom payments]: https://lightningdevkit.org/blog/introducing-phantom-node-payments/
[news125 legacy descriptor wallets]: /en/newsletters/2020/11/25/#how-will-the-migration-tool-from-a-bitcoin-core-legacy-wallet-to-a-descriptor-wallet-work
[news74 policy miniscript]: /ja/newsletters/2019/11/27/#bitcoin-miniscript
[lily v1.2.0]: https://github.com/Lily-Technologies/lily-wallet/releases/tag/v1.2.0
[vortex tweet]: https://twitter.com/benthecarman/status/1590886577940889600
[vortex github]: https://github.com/ln-vortex/ln-vortex
[mutiny tweet]: https://twitter.com/benthecarman/status/1595395624010190850
[mutiny github]: https://github.com/BitcoinDevShop/mutiny-web-poc
[BinaryWatch.org]: https://binarywatch.org/
[bitcoinbinary.org]: https://bitcoinbinary.org/
[483 pending htlcs]: https://github.com/lightning/bolts/blob/master/02-peer-protocol.md#rationale-7
[news188 phantom]: /ja/newsletters/2022/02/23/#ldk-1199
