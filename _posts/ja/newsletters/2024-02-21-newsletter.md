---
title: 'Bitcoin Optech Newsletter #290'
permalink: /ja/newsletters/2024/02/21/
name: 2024-02-21-newsletter-ja
slug: 2024-02-21-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、DNSベースの人が読めるBitcoin支払い指示を提供するための提案と、
mempoolのインセンティブ互換性に関するアイディアを含む投稿の要約、
Cashuおよびecashシステムの設計について議論するスレッドのリンク、
Bitcoinスクリプトの64-bit演算に関する継続的な議論（以前提案されたopcodeの仕様を含む）、
改良された再現可能なASMapの作成プロセスの概要を掲載しています。
また、クライアントとサービスのアップデートや、新しいリリースとリリース候補、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **DNSベースの人が読めるBitcoin支払いの指示:** 以前の議論（[ニュースレター #278][news278 dns]参照）に続き、
  Matt Coralloは、`example@example.com`のような文字列を`example.user._bitcoin-payment.example.com`
  のようなDNSアドレスに解決できるようにする[ドラフトBIP][dns bip]をDelving Bitcoinに[投稿しました][corallo dns]。
  これは、`bitcoin:bc1qexampleaddress0123456`のような[BIP21][] URIを含む[DNSSEC][]署名付きのTXTレコードを返します。
  BIP21 URIは、複数のプロトコルをサポートするよう拡張することができます（
  [BIP70ペイメントプロトコル][topic bip70 payment protocol]を参照）。
  たとえば、以下のTXTレコードは、単純なオンチェーンウォレットがフォールバックとして使用する[bech32m][topic bech32]アドレス、
  [サイレントペイメント][topic silent payments]プロトコルをサポートするオンチェーンウォレットで使用するサイレントペイメントアドレス、
  LN対応ウォレットで使用するLN[オファー][topic offers]を示すことができます:

  ```text
  bitcoin:bc1qexampleaddress0123456?sp=sp1qexampleaddressforsilentpayments0123456&b12=lno1qexampleblindedpathforanoffer...
  ```

  サポートされているさまざまなペイメントプロトコルの詳細は、ドラフトBIPでは定義されていません。
  Coralloは他にLNノードに関連する詳細を記述するための2つのドラフトを作成しており、
  1つは[BOLT][dns bolt]で、もう1つは[BLIP][dns BLIP]です。
  BOLTでは、ドメインの所有者が`omlookup`（[onion message][topic onion messages]ルックアップ）のパラメーターと
  特定のLNノードへの[ブラインドパス][topic rv routing]を含むBIP21 URIを解決する
  `*.user._bitcoin-payment.example.com`のようなワイルドカードレコードを設定できるようにします。
  `example@example.com`にオファーを作成したい支払人は、
  マルチユーザーノードが正しく支払いを処理できるように、受信者の部分（`example`）をそのLNノードに渡します。
  BLIPでは、任意のLNノードがLNの通信プロトコルを介して他のノードへの支払い指示を安全に解決できるようにするオプションについて記述しています。

  この記事の執筆時点では、この提案に関する議論の大半は[BIPリポジトリのPR][bips #1551]で確認できました。
  1つの提案は多くのWeb開発者にとってアクセスしやすいHTTPSソリューションを使用することでしたが、
  追加の依存関係が必要になります。Coralloは、仕様のこの部分は変更しないと述べましたが、
  Web開発者向けにすべての作業を行う[デモWebサイト][dns demo]を備えた[小さなライブラリ][dnssec-prover]を作成しました。
  もう1つの提案は、Electrumなどの一部のBitcoinソフトウェアで既にサポートされている既存の
  [OpenAlias][] DNSベースの支払いアドレス解決システムを使用するというものでした。
  3つめに多く議論されたトピックは、アドレスをどのように表示するかということでした。
  たとえば、`example@example.com`、`@example@example.com`、`example$example.com`など。

- **mempoolのインセンティブ互換性について考える:** Suhas Daftuarは、
  フルノードがどのトランザクションを自分のmempoolに受け入れ、他のノードにリレーし、
  最大の収益を得るためにマイニングするかを選択するために使用できる基準に関するいくつかの洞察を
  Delving Bitcoinに[投稿しました][daftuar incentive]。投稿は、
  最初に原則から始まり、Bitcoin Coreのトランザクションリレーポリシーの設計に興味がある人なら誰でも理解しやすい親しみやすい記述で、
  現在の研究の最先端へと進んでいます。私たちが最も興味深いと感じた洞察は、次のようなものです:

  - *<!--pure-replace-by-feerate-doesn-t-guarantee-incentive-compatibility-->手数料率による純粋な置き換えは、インセンティブの互換性を保証するものではない:*
    手数料率の低いトランザクションを手数料率の高いトランザクションに[置き換える][topic rbf]ことは、
    マイナーにとって厳密な勝利のように思われます。
    Daftuarは、必ずしもそうではない理由を示す簡単な[例を示しています][daftuar feerate rule]。
    手数料率による純粋な置換に関するこれまでに議論については、[ニュースレター #288][news288 rbfr]をご覧ください。

  - *<!--miners-with-different-hashrates-have-different-priorities-->異なるハッシュレートを持つマイナーの優先順位は異なる:*
    ネットワークの総ハッシュレートの1%を持つマイナーが、ブロックテンプレートに特定のトランザクションを含めることを見送り、
    次のブロックを見つけることができても、そのトランザクションを含む可能性のあるすぐ後続のブロックをマイニングできる確率は1%のみです。
    このため、小規模のマイナーは、将来のブロックのマイナー（自分の可能性もある）が得られる手数料の額が
    大幅に減少することになるとしても、今できる限り多くの手数料を集めることが強く奨励されます。

    それと比較して、ネットワークの総ハッシュレートの25%を持つマイナーが、
    次のブロックにトランザクションを含めるのを見送った場合、
    そのトランザクションを含む直後の後続ブロックをマイニングする確率は25%になります。
    この大規模なマイナーは、将来的に得られる手数料が大幅に増加する可能性がある場合、
    今すぐに一部の手数料を徴収することを回避するインセンティブが働きます。

    Daftuarは、2つの競合するトランザクションの[例][daftuar incompatible]を示しています。
    小さなトランザクションでは高手数料率の手数料を支払い、
    大きなトランザクションは支払われる金額がより高くなっています。
    大きなトランザクションの手数料率に近いトランザクションがmempoolにあまり無い場合、
    （手数料率がより高い）小さなトランザクションを含むブロックよりも、
    大きなトランザクションを含むブロックがより多くの手数料をマイナーに支払うことになります。
    しかし、大きなトランザクションと同様の手数料率のトランザクションがmempoolに多数ある場合、
    ネットワークの総ハッシュレートに占める割合が小さいマイナーは、
    （手数料率の高い）小さい方をマイニングして今すぐ多くの手数料を得ようとし、
    総ハッシュレートに占める割合が大きいマイナーは、
    （手数料率の低い）大きなトランザクションをマイニングして利益がでるまで（または、
    支払人が待つのにうんざりしてより手数料率の高いバージョンを作成するまで）待とうとするかもしれません。
    マイナーごとにインセンティブが異なるということは、
    インセンティブの互換性に関する普遍的なポリシーがないことを意味している可能性があります。

  - *DoS攻撃に抵抗できないインセンティブ互換動作を見つけることは有用:*
    Daftuarは、Bitcoin Coreプロジェクトがインセンティブ互換性があり、
    DoS（Denial-of-Service）攻撃に耐性のあるポリシーをどのように[実装][mempool series]しようとしているか説明しています。
    しかし、彼は次のように述べています。「興味深く価値のある研究分野は、
    ネットワーク全体に展開するのにDoS耐性がないインセンティブ互換性のある動作があるかどうかを判断すること（
    そして、存在する場合はその特性を明らかにすること）です。
    もし、そのような動作があれば、それはユーザーがマイナーと直接繋がるインセンティブを導入する可能性があり、
    それらの当事者にとっては相互に有益である可能性がありますが、
    ネットワーク全体でのマイニングの分散化には有害である可能性があります。[...]
    これらのシナリオを理解することは、DoS耐性のあるインセンティブ互換性のあるプロトコルを設計しようとする際にも役立つ可能性があるため、
    可能性の境界がどこにあるのかを知ることができます。」

- **Cashuおよびその他のecashシステム設計の議論:** 数週間前、
  開発者のThunderbiscuitは、残高をsatoshiで表示しBitcoinとLNを使用して資金を送受信できる
  [Cashu][]で使用されている[Chaumian ecash][]システムの背後にある
  [ブラインド署名スキーム][blind signature scheme]の説明をDelving Bitcoinに[投稿しました][thunderbiscuit ecash]。
  開発者のMoonsettlerとZmnscpxjは今週、ブラインド署名の簡易版のいくつかの制約と、
  代替プロトコルがどのように追加の利点を提供できる可能性があるかについて話しました。
  この議論は完全に理論的なものでしたが、ecashスタイルのシステムに興味がある人にとっては興味深い内容だと思います。

- **<!--continued-discussion-about-64-bit-arithmetic-and-op-inout-amount-opcode-->64-bit演算と`OP_INOUT_AMOUNT` opcodeの継続的な議論:**
  Bitcoinに64-bit演算を追加する将来のソフトフォーク（[ニュースレター #285][news285 64bit]参照）の可能性について、
  複数の開発者が[議論を続けています][64bit discuss]。私たちが以前言及して以来、
  ほとんどの議論は、スクリプトで64-bitの値をエンコードする方法にフォーカスし続けており、
  主な違いは、オンチェーンデータを最小化する形式を使用するか、プログラムで操作するのが最も簡単な形式を使用するかの違いです。
  また、符号付き整数を使用するか、符号なし整数のみを許可するかについても議論されました（知らない方のために説明すると、
  自称高度なBitcoinイノベーターも含まれるようですが、符号付き整数は使用する符号を示し（正の符号か負の符号か）、
  符号なし整数はゼロと正数のみを表現できます ）。
  さらに、最大4,160 bit（現在のBitcoinのスタック要素のサイズ制限である520 byteと一致）までの、
  より大きな数値の操作を許可するかどうかについても検討されました。

  今週、Chris Stewartは、当初`OP_TAPLEAF_UPDATE_VERIFY`の一部として提案されたopcode（
  [ニュースレター #166][news166 tluv]参照）の[ドラフトBIP][bip inout]に関する新しい
  [議論のスレッド][stewart inout]を作成しました。`OP_INOUT_AMOUNT`というopcodeは、
  現在のインプットの値（使用するアウトプットの値）と、
  このインプットと同じインデックスのトランザクションアウトプットの値をスタックにプッシュします。
  たとえば、トランザクションの最初のインプットが400万satsで、２つめのインプットが300万sats、
  最初のアウトプットに200万sats支払い、２つめのアウトプットに100万sats支払う場合、
  ２つめのインプットの評価の一部として`OP_INOUT_AMOUNT`が実行されると、
  `3_000_000 1_000_000`がスタックに配置されます（ドラフトBIPを正しく理解していれば、
  64-bitのリトルエンディアンの符号なし整数としてエンコードされます。例：`0xc0c62d0000000000 0x40420f0000000000`）。
  opcodeがソフトフォークでBitcoinに追加された場合、コントラクトは、
  インプットの量とアウトプットの量がコントラクトが期待する範囲内であること検証するのがはるかに簡単になります。
  たとえば、ユーザーが権利のある金額だけを[Joinpool][topic joinpools]から引き出すようなことの検証など。

- **再現可能なASMap作成プロセスの改良:** Fabian Jahrは、
  インターネットの大部分のルーティングをそれぞれが制御する[自律システム][autonomous systems]のマップ（ASMap）の
  作成における進捗について、Delving Bitcoinに[投稿しました][jahr asmap]。
  Bitcoin Coreは現在、グローバルなネームスペースの多様なサブセットのコレクションからピアへの接続を維持しようとしているため、
  攻撃者がノードに対して最も単純なタイプの[エクリプス攻撃][topic eclipse attacks]を実行するためには、
  各サブネットでIPアドレスを取得する必要があります。ただ、一部のISPやホスティングサービスは、
  複数のサブネット上のIPアドレスを制御しており、この保護が弱くなっています。
  ASMapプロジェクトの目的は、どのISPがどのIPアドレスを管理しているかというおおよその情報を
  Bitcoin Coreに提供することです（ニュースレター[#52][news52 asmap]および[#83][news83 asmap]参照）。
  このプロジェクトが直面している大きな課題は、複数のコントリビューターが再現可能な方法でマップを作成し、
  その内容が作成された時点で正確であったことを独立して検証できるようにすることです。

  今週の投稿で、Jahrはツールと手法について説明し、次のように述べています。「5人以上のグループ内では、
  大多数の参加者が同じ結果を得る可能性が高いことが分かりました。[...]
  このプロセスは誰でも開始でき、CoreのPRとよく似ています。合致する結果を持つ参加者は、ACKとして解釈される可能性があります。
  誰かが結果におかしなものを見つけた場合、または単純に合致しなかった場合は、
  さらに調査するために生データの共有を求めることができます。」

  最終的にプロセスが許容できると判断された場合（おそらく追加の改良が加えられた上で）、
  Bitcoin Coreの将来のバージョンには、ASMapが搭載され、この機能がデフォルトで有効になり、
  エクリプス攻撃に対する耐性が向上する可能性があります。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **マルチパーティ調整プロトコルNWCの発表:**
  [Nostr Wallet Connect (NWC)][nwc blog]は、複数の参加者が関与する対話型のユースケースでの通信を容易にする調整プロトコルです。
  NWCの初期の焦点はライトニングですが、[Joinpool][topic joinpools]や[Ark][topic ark]、
  [DLC][topic dlc]、[マルチシグ][topic multisignature]スキームなどの対話型のプロトコルが、
  このプロトコルの恩恵を受ける可能性があります。

- **Mutiny Wallet v0.5.7リリース:**
  [Mutiny Wallet][mutiny github]のリリースでは、[Payjoin][topic payjoin]のサポートが追加され、
  NWCやLSPの機能が改善されています。

- **GroupHugトランザクションバッチサービス:**
  [GroupHug][grouphug github]は、[PSBT][topic psbt]を使用する
  [制限][grouphug blog]のある[バッチ][scaling payment batching]サービスです。

- **BoltzがTaprootスワップを発表:**
  ノンカストディアルのスワップ取引所Boltzは、[Taproot][topic taproot]や[Schnorr署名][topic schnorr signatures]、
  [MuSig2][topic musig]を使用するようアップグレードしたアトミックスワッププロトコルを[発表しました][boltz blog]。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning 24.02rc1][]は、この人気のLNノードの次期メジャーバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。*

- [Bitcoin Core #27877][]は、Bitcoin Coreのウォレットに新しい[コイン選択][topic coin selection]戦略
  CoinGrinder（[ニュースレター #283][news283 coingrinder]参照）を追加しました。
  この戦略は、推定手数料率が長期的なベースラインと比較して高い場合に使用されることを意図しており、
  ウォレットが今すぐ小さなトランザクションを作成できるようにします（その結果、
  後日、手数料率が低くなった時に、より大きなトランザクションを作成する必要が生じる可能性があります）。

- [BOLTs #851][]では、対話型のトランザクション構築プロトコルのサポートと共に、
  LNの仕様に[デュアルファンディング][topic dual funding]のサポートを追加しました。
  対話型の構築により、２つのノードが設定とUTXOの詳細を交換し、ファンディングトランザクションを一緒に構築できるようになります。
  デュアルファンディングにより、トランザクションにどちらか一方もしくは両者のインプットを含めることができます。
  たとえば、アリスがボブとチャネルを開きたい場合、この仕様変更の前は、
  アリスはチャネルの資金をすべて提供する必要がありました。現在は、デュアルファンディングをサポートする実装を使用すると、
  アリスはチャネルの初期状態にボブがすべての資金を提供したり、両者が資金を提供するチャネルを開くことができます。
  これは、まだ仕様に追加されていない実験的な[Liquidity Adsプロトコル][topic liquidity advertisements]と組み合わせることができます。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1551,27877,851" %}
[news283 coingrinder]: /ja/newsletters/2024/01/03/#new-coin-selection-strategies
[news52 asmap]: /en/newsletters/2019/06/26/#differentiating-peers-based-on-asn-instead-of-address-prefix
[news83 asmap]: /ja/newsletters/2020/02/05/#bitcoin-core-16702
[jahr asmap]: https://delvingbitcoin.org/t/asmap-creation-process/548
[autonomous systems]: https://ja.wikipedia.org/wiki/自律システム_(インターネット)
[daftuar feerate rule]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553#feerate-rule-9
[news288 rbfr]: /ja/newsletters/2024/02/07/#pinning
[daftuar incompatible]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553#using-feerate-diagrams-as-an-rbf-policy-tool-13
[daftuar incentive]: https://delvingbitcoin.org/t/mempool-incentive-compatibility/553
[news285 64bit]: /ja/newsletters/2024/01/17/#proposal-for-64-bit-arithmetic-soft-fork-64-bit
[dnssec]: https://ja.wikipedia.org/wiki/DNS_Security_Extensions
[corallo dns]: https://delvingbitcoin.org/t/human-readable-bitcoin-payment-instructions/542/
[dns bip]: https://github.com/TheBlueMatt/bips/blob/d46a29ff4b4ac27210bc81474ae18e4802141324/bip-XXXX.mediawiki
[dns bolt]: https://github.com/lightning/bolts/pull/1136
[dns blip]: https://github.com/lightning/blips/pull/32
[dnssec-prover]: https://github.com/TheBlueMatt/dnssec-prover
[dns demo]: http://http-dns-prover.as397444.net/
[news278 dns]: /ja/newsletters/2023/11/22/#ln
[news166 tluv]: /ja/newsletters/2021/09/15/#amount-introspection
[64bit discuss]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397
[stewart inout]: https://delvingbitcoin.org/t/op-inout-amount/549
[thunderbiscuit ecash]: https://delvingbitcoin.org/t/building-intuition-for-the-cashu-blind-signature-scheme/506
[blind signature scheme]: https://ja.wikipedia.org/wiki/ブラインド署名
[chaumian ecash]: https://en.wikipedia.org/wiki/Ecash
[openalias]: https://openalias.org/
[cashu]: https://github.com/cashubtc/nuts
[bip inout]: https://github.com/Christewart/bips/blob/92c108136a0400b3a2fd66ea6c291ec317ee4a01/bip-op-inout-amount.mediawiki
[mempool series]: /ja/blog/waiting-for-confirmation/
[Core Lightning 24.02rc1]: https://github.com/ElementsProject/lightning/releases/tag/v24.02rc1
[nwc blog]: https://blog.getalby.com/scaling-bitcoin-apps/
[mutiny github]: https://github.com/MutinyWallet/mutiny-web
[grouphug blog]: https://peachbitcoin.com/blog/group-hug/
[grouphug github]: https://github.com/Peach2Peach/groupHug
[boltz blog]: https://blog.boltz.exchange/p/introducing-taproot-swaps-putting
