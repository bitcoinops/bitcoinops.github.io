---
title: 'Bitcoin Optech Newsletter #266'
permalink: /ja/newsletters/2023/08/30/
name: 2023-08-30-newsletter-ja
slug: 2023-08-30-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、古いLN実装に影響する脆弱性の責任ある開示の発表と、
提案中のCovenant opcodeのマッシュアップ提案を掲載しています。
また、Bitcoin Stack Exchangeから厳選された質問とその回答や、
新しいソフトウェアリリースとリリース候補の発表、
人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **偽のファンディングに関連する過去のLN脆弱性の公開:** Matt Morehouseは、
  彼が過去に[責任ある開示][topic responsible disclosures]を行った脆弱性の概要を
  Lighting-Devメーリングリストに[投稿][morehouse dos]しました。この脆弱性については、
  人気のあるすべてのLN実装の最新バージョンで対処されています。
  この脆弱性を理解するため、ボブがLNノードを実行していると想像してください。
  ボブはマロリーのノードから新しいチャネルを開く要求を受け取り、
  マロリーが資金を提供するトランザクションをブロードキャストする段階までチャネルの開設プロセスを進めます。
  後でそのチャネルを使用するために、ボブはそのチャネルに関連する状態を保存し、
  トランザクションが十分に承認されるまで新しいブロックをスキャンし始める必要があります。
  マロリーがトランザクションをブロードキャストしない場合、ボブのストレージとスキャンのリソースは無駄になります。
  マロリーがこのプロセスを何千回または何百万回も繰り返すと、
  ボブのLNノードは他のこと（資金の損失を防ぐために必要な時間的制約のある処理の実行を含む）が実行できなくなるほど、
  ボブのリソースを浪費する可能性があります。

  Morehouseが自身のノードに対してテストをしたところ、
  Core Lightning、Eclair、LDKおよびLNDで重大な問題を引き起こすことができました。
  そのうち2つのケースでは、（私たちの意見では）多くのノード間で資金の損失につながる可能性があると思われるものでした。
  Morehouseの[完全な説明][morehouse post]は、
  問題が解決されたPRへのリンク（ニュースレター [#237][news237 dos]と[#240][news240 dos]で取り上げたPRを含む）と
  脆弱性に対処したLNリリースのリストを示しています:

  - Core Lightning 23.02
  - Eclair 0.9.0
  - LDK 0.0.114
  - LND 0.16.0

  メーリングリストと[IRC][stateless funding]でフォローアップの議論が行われました。

- **`TXHASH`と`CSFS`を使用したCovenantのマッシュアップ:** Brandon Blackは、
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV)と
  [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] (APO)の個々の提案に対して、
  大幅なオンチェーンコストの追加なしに、そのほとんどの機能を提供する
  `OP_TXHASH`（[ニュースレター #185][news185 txhash]参照）と
  [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]を組み合わせたバージョンの提案を
  Bitcoin-Devメーリングリストに[投稿しました][black mashup]。
  この提案は独立していますが、この提案を作成した動機の一部は、
  「CTVとAPOの個別および組み合わせについて私たちの考えを明確にし、
  将来的にビットコインの驚くべき使用法を可能にする方向での合意に向けて進む可能性がある」ことでした。

  この提案は、メーリングリスト上でいくつかの議論を受け、
  Delving Bitcoinのフォーラムに[追加の修正][delv mashup]が投稿され、議論されました。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [P2WPKHからP2TRに切り替える経済的なインセンティブはありますか？]({{bse}}119301)
  Murchは、P2WPKHおよび[P2TR][topic taproot]のアウトプットタイプのトランザクションインプットとアウトプットのweightを比較しながら、
  一般的なウォレットの使用パターンを説明しています。彼は次のように締めくくっています:
  「全体として、P2WPKHの代わりにP2TRを使用すると、トランザクションの手数料が最大15.4%節約されます。
  受け取る支払いよりも少額の支払いがはるかに多い場合は、P2WPKHを利用することで最大1.5%節約できる可能性があります。」

- [BIP324の暗号化されたパケット構造とは何ですか？]({{bse}}119369)
  Pieter Wuilleは、[BIP324][]で提案されている
  [バージョン2 P2Pトランスポート][topic v2 p2p transport]のネットワークパケット構造の概要を説明しています。
  この提案の進捗状況は[Bitcoin Core #27634][]で追跡されています。

- [<!--what-is-the-false-positive-rate-for-compact-block-filters-->コンパクトブロックフィルターの偽陽性率はどれくらいですか？]({{bse}}119142)
  Murchは、[BIP158][]の[ブロックフィルター][bip158 filters]のパラメーター選択に関するセクションから、
  [コンパクトブロックフィルター][topic compact block filters]の偽陽性率は1/784931であると回答しています。
  これは、約1000個のアウトプットスクリプトを監視するウォレットにとっては、8週間に1ブロックに相当すると指摘しています。

- [MATT提案にはどのようなopcodeが含まれていますか？]({{bse}}119239)
  Salvatoshiは、現在提案されているopcode [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]、
  OP_CHECKCONTRACTVERIFYおよび[OP_CAT][]を含む、彼のMerkleize All The Things ([MATT][merkle.fun])提案（
  ニュースレター[#226][news226 matt]、[#249][news249 matt]および[#254][news254 matt]参照）を説明しています。

- [Bitcoinの最後のブロックは明確に定義されていますか？]({{bse}}119223)
  RedGrittyBrickとPieter Wuilleは、ブロックの高さに制限はないが、
  現在のコンセンサスルールでは、Bitcoinの符号なし32 bitのタイムスタンプの制限（2106年）を超える新しいブロックは
  許可されないと指摘しています。トランザクションの[nLockTime][topic timelocks]の値にも同じ[タイムスタンプの制限]({{bse}}110666)があります。

- [なぜマイナーはコインベーストランザクションのlocktimeを設定するのですか？]({{bse}}110474)
  Bordalixは、長い間公開されていたこの質問に、
  マイナーは何かを通信するためにコインベーストランザクションのlocktimeフィールドを使用しているようだと回答しています。
  マイニングプールの運営者は、「再接続を高速化するためにこの4 byteをStratumのセッションデータを保持するために再利用している」
  と説明し、そのスキームについて[詳しく説明][twitter satofishi]しています。

- [Bitcoin CoreがSchnorr署名を実行する際に補助ランダム性を使用しないのはなぜですか？]({{bse}}119042)
  Matthew Leonは、[BIP340][]で[サイドチャネル][topic side channels]攻撃から保護するために
  [Schnorr署名][topic schnorr signatures]のナンスを生成する際に
  補助的なランダム性を使用することを推奨しているにもかかわらず、Bitcoin Coreが実装で補助ランダム性を提供しない理由を尋ねています。
  Andrew Chowは、現在の実装はまだ安全であり、この推奨事項に対処するためのPRは作られていないと回答しています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning 23.08][]は、この人気のLNノード実装の最新のメジャーリリースです。
  新機能には、ノードを再起動することなくいくつかのノードの設定を変更できるようにする機能や、
  [Codex32][topic codex32]フォーマットの[シード][topic bip32]バックアップとリストアのサポート、
  支払いの経路探索を改善する新しい実験的なプラグイン、[スプライシング][topic splicing]の実験的なサポート、
  ローカルで生成されたインボイスへの支払いを可能にする機能、その他多くの新機能やバグ修正が含まれています。

- [LND v0.17.0-beta.rc1][]は、この人気のLNノード実装の次期メジャーバージョンのリリース候補です。
  このリリースで予定されている主な実験的な新機能は、テストの恩恵を受ける可能性が高そうな、
  _注目すべき変更_ のセクションで説明されている「Simple taproot channel」のサポートです。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #27460][]は、新しい`importmempool`RPCを追加しました。
  このRPCは、`mempool.dat`ファイルをロードし、ロードされたトランザクションをmempoolに追加しようとします。

- [LDK #2248][]は、LDKの下流プロジェクトがゴシップメッセージで参照されるUTXOを追跡するために使用できる組み込みシステムを提供します。
  ゴシップを処理するLNノードは、UTXOに関連付けられた鍵で署名されたメッセージのみを受け入れる必要があります。
  そうしないと、スパムメッセージの処理やリレーを強制されたり、
  存在しないチャネルを介して支払いを転送しようとする（これは常に失敗します）可能性があります。
  新しい組み込みの`UtxoSource`は、ローカルのBitcoin Coreに接続されたLNノードに対して機能します。

- [LDK #2337][]は、ユーザーのウォレットから独立して実行され、
  ユーザーのノードから暗号化されたLNのペナルティトランザクションを受け取ることができる
  [ウォッチタワー][topic watchtowers]を構築するのにLDKを使用するのをより簡単にします。
  ウォッチタワーは、新しいブロックの各トランザクションから情報を抽出し、
  その情報を使って以前受け取った暗号化データの復号を試みることができます。
  復号に成功すると、ウォッチタワーは復号されたペナルティトランザクションをブロードキャストすることができます。
  これにより、ユーザーが利用できないときに相手側が失効したチャネル状態を公開することからユーザーを保護することができます。

- [LDK #2411][]と[#2412][ldk #2412]は、
  [ブラインドペイメント][topic rv routing]のための支払いパスを構築するAPIを追加しました。
  このPRは、（ブラインドパスを使用する）[Onionメッセージ][topic onion messages]用のLKDのコードと、
  ブラインドパス自体を分離するのに役立ちます。後続の[#2413][ldk #2413]では、
  ルートブラインディングのサポートが実際に追加されます。

- [LDK #2507][]では、不必要なチャネルの強制閉鎖につながる別の実装における長年の問題に対する回避策が追加されました。

- [LDK #2478][]では、現在既に決済されている転送された[HTLC][topic htlc]関する情報、
  どのチャネルから来たか、HTLCの金額、およびそのHTLCから徴収した手数料の金額を提供するイベントを追加しています。

- [LND #7904][]は、「Simple taproot channel」の実験的サポートを追加しました。
  これは、LNのファンディングトランザクションおよびコミットメントトランザクションで、両参加者が協力している場合に[MuSig2][topic musig]
  スクリプトレス[マルチシグ][topic multisignature]のサポートが可能な[P2TR][topic taproot]アウトプットを使用できるようにします。
  これにより、チャネルが協調的に閉じられる際のトランザクションweightスペースが削減され、プライバシーも向上します。
  LNDは引き続き[HTLC][topic htlc]のみを使用し、Taprootチャネルで開始された支払いを、
  Taprootチャネルをサポートしない他のLNノードを介して転送し続けることができます。

  <!-- The following linked PRs have titles "1/x", "2/x", etc.  I've
  listed them in that order rather than by PR number -->
  このPRをには、以下のPRからステージングブランチにマージされた134のコミットが含まれています:
  [#7332][lnd #7332]、[#7333][lnd #7333]、[#7331][lnd #7331]、[#7340][lnd #7340]、
  [#7344][lnd #7344]、[#7345][lnd #7345]、[#7346][lnd #7346]、[#7347][lnd #7347]、
  [#7472][lnd #7472]。

{% include references.md %}
{% include linkers/issues.md v=2 issues="27460,2466,2248,2337,2411,2412,2413,2507,2478,7904,7332,7333,7331,7340,7344,7345,7346,7347,7472,27634" %}
[LND v0.17.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc1
[core lightning 23.08]: https://github.com/ElementsProject/lightning/releases/tag/v23.08
[delv mashup]: https://delvingbitcoin.org/t/combined-ctv-apo-into-minimal-txhash-csfs/60/6
[morehouse dos]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004064.html
[morehouse post]: https://morehouse.github.io/lightning/fake-channel-dos/
[news237 dos]: /ja/newsletters/2023/02/08/#core-lightning-5849
[news240 dos]: /ja/newsletters/2023/03/01/#ldk-1988
[black mashup]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021907.html
[news185 txhash]: /ja/newsletters/2022/02/02/#ctv-apo
[stateless funding]: https://gnusha.org/lightning-dev/2023-08-27.log
[bip158 filters]: https://github.com/bitcoin/bips/blob/master/bip-0158.mediawiki#block-filters
[merkle.fun]: https://merkle.fun/
[news254 matt]: /ja/newsletters/2023/06/07/#ctv-joinpool-matt
[news249 matt]: /ja/newsletters/2023/05/03/#matt-vault
[news226 matt]: /ja/newsletters/2022/11/16/#covenant-bitcoin
[twitter satofishi]: https://twitter.com/satofishi/status/1693537663985361038
