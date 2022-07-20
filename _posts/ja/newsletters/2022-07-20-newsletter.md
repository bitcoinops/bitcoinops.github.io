---
title: 'Bitcoin Optech Newsletter #209'
permalink: /ja/newsletters/2022/07/20/
name: 2022-07-20-newsletter-ja
slug: 2022-07-20-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoinに持続可能な長期的なブロック報酬を提供することに関していくつかの関連する議論を掲載しています。
また、クライアントやサービスの新機能の説明や、新しいリリースおよびリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **<!--long-term-block-reward-ongoing-discussion-->長期的なブロック報酬に関する継続的な議論:**
  Bitcoinの報酬が減少する中、Proof of Work (PoW)に対する確実な支払いについての議論が継続し、
  Bitcoin-Devメーリングリストで2つの新しいスレッドが始まりました:

    - [<!--tail-emission-is-not-inflationary-->テールエミッションはインフレにはならない][todd tail]
      新しく作成されたビットコインをマイナーに永久に支払い続けることは、
      流通するビットコインの量を永遠に増やすことにはつながらないというPeter Toddの議論から始まります。
      代わりに、毎年いくつかのビットコインが失われ、
      最終的にビットコインが失われる速度が新しいビットコインが生成される速度に収束し、
      流通するビットコインの量はほぼ安定すると彼は考えています。
      また、Bitcoinに永久的なブロック報酬を追加するとことはハードフォークになると指摘しています。
      彼の投稿やBitcoinTalkでの[それに関するスレッド][talk tail]には、かなりの人々が返信しています。
      ここでは、最も注目すべきいくつかの返信をまとめてみます。

        - *<!--hard-fork-not-required-->ハードフォークは必要ない:*
          Vjudeuは、ゼロsatoshiを支払うトランザクションアウトプットに特別な意味を持たせることで、
          ソフトフォークで新しいビットコインを生み出すことができると[提案しています][vjudeu sf]。
          たとえば、フォークに参加するノードがゼロsatoshiのアウトプットを確認すると、
          そのノードは実際の送金額についてトランザクションの別の部分を参照することができます。
          これは2種類のビットコインを生み出しますが、おそらくソフトフォークではレガシーなビットコインを
          変更されたビットコインに変換する仕組みが提供されるでしょう。
          Vjudeuは、同様の仕組みを、プライバシーを強化するビットコインの量の秘匿化（
          [Confidential Transaction][confidential transactions]など）にも使用できると指摘しています。

        - *<!--no-reason-to-believe-perpetual-issuance-is-sufficient-->永続的な発行で十分だと考える根拠はない*:
          Anthony Townsは[メーリングリスト][towns pi]で、Gregory Maxwelは[BitcoinTalk][maxwell pi]で、
          マイナーに消失するコインの平均率と同量のコインを支払うことで十分なPoWのセキュリティが得られると考える理由はなく、
          またPoWのセキュリティに対して過大な支払いをするケースもあり得ると述べています。
          永続的な発行がセキュリティを保証できず、新たな問題を引き起こす可能性が高いのであれば、
          セキュリティを保証することはできませんが、少なくとも追加の問題が発生しない現状の有限の報酬を維持することが望ましいと思われます。
          そしてこれは既にすべてのビットコイナーに（暗黙的または明示的に）受け入れられています。

            Maxwellはさらに、Bitcoinのマイナーは、
            報酬、手数料、その他のインセンティブの組み合わせによって
            多くのアルトコインがマイナーに支払っているのよりも、
            平均してトランザクション手数料だけでかなり多くの価値を集めていると述べています。
            これらのアルトコインは基本的なPoWの攻撃を受けておらず、
            これはBitcoinを安全に保つために、トランザクション手数料だけで十分な価値が支払われている可能性があることを意味します。
            つまり、Bitcoinは十分なPoWのセキュリティを獲得するために報酬を必要とする段階を過ぎている可能性があります。
            （ただし、以下のBram Cohenのスレッドのまとめで述べられているように、現時点では報酬は他のメリットも提供しています。）

            Townsは、Peter Toddの結果が、毎年失われるビットコインの平均率が一定であることに依存していることを指摘していますが、
            これはTownsが考える失われるビットコインを最小限に抑えるというシステム全体の目標と矛盾します。
            これに関連して、Maxwellは、たとえば120年間（元の所有者とその相続人の寿命をはるかに超えた期間）移動しなかったコインを寄付するスクリプトの使用を誰でも自動的にオプトインできるようにすることで、
            失われるコインをほぼ完全に無くす方法を説明しています。

        - *<!--censorship-resistance-->検閲耐性:* 開発者のZmnSCPxjは、
          トランザクション手数料がBitcoinの検閲耐性を高めるというEric Voskuilの[主張][voskuil cr]を[展開しました][zmnscpxj cr]。
          たとえば、ブロック報酬の90%が報酬で10%がトランザクション手数料であれば、
          検閲を行うマイナーが直接失う可能性のある最大収益は10%です。しかし90%が手数料で10%が報酬であれば、
          マイナーは最大90%を失う可能性があります。これは検閲を回避するためのとても強力なインセンティブです。

            Peter Toddは、永続的な発行が「小額のトランザクション手数料」よりもPoWのセキュリティのための資金を調達できること、
            また、ブロック報酬が高くなれば、
            攻撃者がトランザクションの検閲のためにマイナーに支払わなければならないコストが増加するという意見を述べ、
            [反論しました][todd cr]。

    - [<!--fee-sniping-->フィー・スナイピング][cohen fs]: Bram Cohenは、
      [フィー・スナイピング][topic fee sniping]の問題について投稿し、
      可能な解決策として、トランザクション手数料をブロック報酬の約10%（残りは報酬）に抑えることを提案しています。
      彼は他の可能な解決策についても簡単に触れていますが、他の人からより詳細に追加の提案が提供されました。

        - *<!--paying-fees-forward-->手数料の前払い:* Russell O'Connorは、
          マイナーがフィー・スナイピングを奨励することなく、
          mempoolの上位のトランザクションから収集できる手数料の最大額を計算できるという古いアイディアを[提案しました][oconnor forward fees]。
          そして集めた追加の手数料を、次のブロックを競争的にではなく協力して構築するための賄賂として、
          次のマイナーに提供することができます。議論の参加者は、
          [この][towns ff]アイディアについて[何度か][oconnor ff2]反復を行いましたが、
          Peter Toddは、この手法の根本的な懸念は、
          小規模なマイナーが大規模のマイナーよりも高い賄賂を支払う必要があり、
          規模の経済を生み出し、Bitcoinのマイニングをさらに集中化する可能性があることだと[指摘しました][todd centralizing]。

        - *<!--improving-market-design-->市場設計の改善:* Anthony Townsは、
          Bitcoinのソフトウェアとユーザープロセスを改善することで、手数料を大幅に平準化し、
          フィー・スナイピングの可能性を低くすることができると[提案しました][towns market design]。
          しかし、彼はさらに、「いくつかのFUDに反論する」だけで、現時点での主要な優先事項とは思えないと指摘しています。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **LNP/BPがStormのベータ版ソフトウェアをリリース:**
  LNP/BP Standards Associationは、LNを使用したメッセージングおよびストレージプロトコルである[Storm][storm github]の
  ベータ版のソフトウェアを[リリースしました][lnpbp tweet]。

- **Robinhoodがbech32をサポート:**
  取引所のRobinhoodは、[bech32][topic bech32]アドレスへの[引き出し（送金）をサポートしました][robinhood withdrawals]。

- **SphinxがVLS署名デバイスを発表:**
  Sphinxチームは、[VLS(Validating Lightning Signer )][vls gitlab]と連携するハードウェア署名デイバスを[発表しました][sphinx vls blog]。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [BDK 0.20.0][]は、Bitcoinウォレットを構築するためのこのライブラリの最新リリースです。
  `ElectrumBlockchain`とディスクリプターテンプレートのバグ修正、
  フィー・スナイピングを阻止する新しいトランザクション構築機能、
  新しいトランザクション署名オプションが含まれています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、および[Lightning BOLTs][bolts repo]の注目すべき変更点。*

- [Bitcoin Core #24148][]は、[Miniscript][topic miniscript]で書かれた
  [Output Script Descriptor][topic descriptors]の*watch-only*サポートを追加しました。
  たとえば、ユーザーは`wsh(and_v(v:pk(key_A),pk(key_B)))`をインポートし、
  このスクリプトに対応するP2WSHアウトプットに受け取ったビットコインを監視できるようになります。
  将来のPRでは、Miniscriptベースのディスクリプターに対する署名のサポートが追加される予定です。

- [Bitcoin Core GUI #471][]は、GUIでウォレットバックアップから復元できる機能を追加しました。
  復元はこれまで、CLIを使用するか、特定のディレクトリにファイルをコピーすることでのみ可能でした。

- [LND #6722][]は、[BIP340][]-互換の[Schnorr署名][topic schnorr signatures]を使用して、
  任意のメッセージに署名するためのサポートを追加しました。
  またSchnorr署名付きのメッセージも検証できるようになりました。

- [Rust Bitcoin #1084][]は、[BIP383][]で定義された順序で公開鍵のリストをソートするために使用できるメソッドを追加しました。

{% include references.md %}
{% include linkers/issues.md v=2 issues="24148,471,6722,6724,1592,1084" %}
[bdk 0.20.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.20.0
[todd tail]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020665.html
[talk tail]: https://bitcointalk.org/index.php?topic=5405755.0
[vjudeu sf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020684.html
[confidential transactions]: https://en.bitcoin.it/wiki/Confidential_transactions
[towns pi]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020693.html
[maxwell pi]: https://bitcointalk.org/index.php?topic=5405755.0
[zmnscpxj cr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020678.html
[voskuil cr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020676.html
[todd cr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020688.html
[cohen fs]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020702.html
[oconnor forward fees]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020704.html
[oconnor ff2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020719.html
[towns ff]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020735.html
[todd centralizing]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020705.html
[towns market design]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020716.html
[lnpbp tweet]: https://twitter.com/lnp_bp/status/1545366480593846275
[storm github]: https://github.com/Storm-WG
[robinhood withdrawals]: https://robinhood.com/us/en/support/articles/cryptocurrency-wallets/#Supportedaddressformatsforcryptowithdrawals
[sphinx vls blog]: https://sphinx.chat/2022/06/27/a-lightning-nodes-problem-with-hats/
[vls gitlab]: https://gitlab.com/lightning-signer/docs
