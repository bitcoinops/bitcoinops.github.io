---
title: 'Bitcoin Optech Newsletter #286'
permalink: /ja/newsletters/2024/01/24/
name: 2024-01-24-newsletter-ja
slug: 2024-01-24-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、修正された旧バージョンのbtcdのコンセンサス障害の発表と、
v3トランザクションリレーとエフェメラルアンカーに向けたLNの変更案、
Bitcoin関連の仕様用の新しいリポジトリの発表について掲載しています。
また、サービスとクライアントソフトウェアのアップデートや、
新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **btcdにおける修正されたコンセンサス障害の開示:** Niklas Göggeは、
  以前[責任を持って開示した][topic responsible disclosures]btcdの旧バージョンにおけるコンセンサスの障害を、
  Delving Bitcoinで[発表しました][gogge btcd]。相対的[タイムロック][topic timelocks]は、
  トランザクションのインプットのシーケンス番号にコンセンサスの適用を追加することで、
  ソフトフォークで[Bitcoinに追加されました][topic soft fork activation]。
  フォーク前に作成された署名済みのトランザクションが無効にならないようにするため、
  相対的タイムロックはバージョン番号が2以上のトランザクションにのみ適用され、
  元のデフォルトのバージョン1のトランザクションは、どのインプットに対しても有効なままです。
  ただし、オリジナルのBitcoinソフトウェアでは、バージョン番号は符号付き整数で、負のバージョンが可能です。
  [BIP68][]の参照実装セクションでは、「バージョン2以降」というのは、
  符号付き整数から符号なし整数に[キャスト][cast]されたバージョン番号に適用されることを意図しており、
  バージョン0および1ではないすべてのトランザクションにルールが適用されることが保証されると記述されています。

  Göggeは、btcdがこの符号付きから符号なし整数への変換を実装していないことを発見しました。
  このため、Bitcoin CoreではBIP68ルールに従うもののbtcdではそうではない
  負のバージョン番号を持つトランザクションを構築することが可能でした。
  この場合、あるノードがトランザクション（そしてそのトランザクションを含むブロック）を拒否し、
  別のノードはそのトランザクション（およびそのブロック）を受け入れる可能性があり、
  チェーンの分岐につながります。攻撃者はこれを利用して、
  btcdノード（またはbtcdノードに接続しているソフトウェア）のオペレーターを騙して
  無効なビットコインを受け入れさせる可能性があります。

  このバグはbtcdのメンテナーに非公開で開示され、最近のv0.24.0のリリースで修正されました。
  コンセンサスの適用にbtcdを使用している人には、アップグレードを強く推奨します。
  さらに、Chris Stewartは、bitcoin-sライブラリの同じ障害に対するパッチを
  Delving Bitcoinのスレッドに[返信しました][stewart bitcoin-s]。
  BIP68の相対的タイムロックを検証するために使用される可能性のあるコードの作成者は、
  コードに同じ欠陥がないかどうか確認することをお勧めします。

- **v3リレーおよびエフェメラルアンカーのためのLNの変更提案:** Bastien Teinturierは、
  [v3トランザクションリレー][topic v3 transaction relay]および
  [エフェメラルアンカー][topic ephemeral anchors]を効率的に使用するために
  LN仕様に加える必要があると考えられる変更についてDelving Bitcoinに[投稿しました][teinturier v3]。
  変更はシンプルです:

  - *<!--anchor-swap-->アンカースワップ:* [CPFP carve out][topic cpfp carve out]ポリシーの下、
    [CPFPによる手数料の引き上げ][topic cpfp]機能を保証するために使用されている
    コミットメントトランザクションの2つの現在の[アンカーアウトプット][topic anchor outputs]が削除され、
    代わりに1つのエフェメラルアンカーが追加されます。

  - *<!--reducing-delays-->遅延の削減:* コミットメントトランザクションの余分な1ブロックの遅延が削除されます。
    これらは、CPFP carve outが常に機能することを保証するために追加されましたが、v3リレーポリシーでは必要ありません。

  - *<!--trimming-redirect-->トリミングのリダイレクト:*
    [トリミングされるHTLCの][topic trimmed htlc]のすべての金額を、コミットメントトランザクションの手数料にする代わりに、
    合計された値がアンカーアウトプットの金額に追加され、
    追加手数料がコミットメントとエフェメラルアンカーの両方の承認を保証するために使用されるようになります（
    議論については、[先週のニュースレター][news285 mev]をご覧ください）。

  - *<!--other-changes-->その他の変更:* いくつかの小さな変更と、簡素化が行われます。

  その後の議論では、提案された変更がもたらすいくつかの興味深い結果が検討されました:

  - *UTXO要件の削減:* 余分な1ブロックの遅延がなくなるため、
    正しいチャネル状態を確実にオンチェーン化することが容易になります。
    障害のある参加者が失効したコミットメントトランザクションをブロードキャストした場合、
    もう一方の参加者はそのコミットメントからメインのアウトプットを使用して、
    失効したコミットメントのCPFPによる手数料の引き上げに使用できます。
    その目的のために、別の承認済みUTXOを保持する必要はありません。これを安全に行うため、
    [BOLT2][]で定義されている最低1%では手数料を賄うのに十分ではない可能性があるため、
    参加者は十分な準備金を残高として保持する必要があります。十分な準備金を保持している非転送ノードの場合、
    セキュリティ上の理由から別のUTXOが必要になるのは、支払いを受け入れる時だけです。

  - *v3ロジックの組み込み:* LNがこれらの変更を設計、実装、
    展開するには長い時間がかかるのではないかというLN仕様会議で表明された懸念に応えて、
    Gregory Sandersは、現在のアンカースタイルのLNコミットメントトランザクションのようなトランザクションを一時的に特別扱いし、
    Bitcoin CoreがLN開発によってブロックされることなくクラスターmempoolをデプロイできるようにする中間段階を[提案しました][sanders transition]。
    それらが広く展開され、すべてのLN実装がそれらを使用するようにアップグレードされた時、
    この一時的な特殊ルールは削除することができます。

  - *<!--request-for-max-child-size-->子トランザクションの最大サイズの要求:*
    v3リレーのドラフト提案では、未承認トランザクションの子のサイズを1,000 vbyteに設定しています。
    このサイズを大きくすると、正直なユーザーは[トランザクションのPinning][topic transaction pinning]を克服するために、
    より多くの手数料を支払う必要があります（[ニュースレター #283][news283 v3pin]参照）。
    このサイズを小さくすると、正直なユーザーが手数料を付与するために使用できるインプットが少なくなります。

- **<!--new-documentation-repository-->新しいドキュメントリポジトリ:** Anthony Townsは、
  プロトコル仕様の新しいリポジトリ _[BINANA][binana repo]_ （Bitcoin Inquisition Numbers And Names Authority）の発表を
  Bitcoin-Devメーリングリストに[投稿しました][towns binana]。この記事の執筆時点で、
  以下の4つの仕様がリポジトリで利用可能です:

  - [BIN24-1][] Ethan HeilmanおよびArmin Sabouriによる`OP_CAT`。
    [ニュースレター #274][news274 cat]の彼らのソフトフォークの提案の説明をご覧ください。

  - [BIN24-2][] Anthony TownsによるHeretical Deploymentsでは、
    提案中のソフトフォークやその他の変更のためにデフォルト[signet][topic signet]上での
    [Bitcoin Inquisition][bitcoin inquisition repo]の使用について説明しています。
    [ニュースレター #232][news232 inqui]の詳しい説明をご覧ください。

  - [BIN24-3][] Brandon Blackによる`OP_CHECKSIGFROMSTACK`は、
    [長年提案されてきたアイディア][topic OP_CHECKSIGFROMSTACK]を定義しています。
    このopcodeをLNHANCEのソフトフォークのバンドルの一部にするというBlackの提案については、
    [先週のニュースレター][news285 lnhance]をご覧ください。

  - [BIN24-4][] Brandon Blackによる`OP_INTERNALKEY`は、
    スクリプトインタプリタからTaprootの内部鍵を取得するためのopcodeを定義しています。
    これも、先週のニュースレターにLNHANCEのソフトフォークのバンドルの一部として記載されています。

  Bitcoin Optechは、更新をチェックするドキュメントソースのリスト（BIPやBOLTおよびBLIP）にBINANAリポジトリを追加しました。
  今後の更新は、_注目すべきコードとドキュメントの変更_ セクションに記載されます。

## サービスとクライアントソフトウェアの変更

*この毎月の特集では、Bitcoinのウォレットやサービスの興味深いアップデートを取り上げています。*

- **Envoy 1.5リリース:**
  [Envoy 1.5][]では、バグ修正や[その他の更新][envoy blog]に加えて、
  [Taproot][topic taproot]の送受信のサポートが追加され、
  [経済合理性のないアウトプット][topic uneconomical outputs]の処理方法が変更されています。

- **Liana v4.0リリース:**
  [Liana v4.0][]が[リリースされ][liana blog]、[RBFによる手数料の引き上げ][topic rbf]、
  RBFを利用したトランザクションのキャンセル、自動[コイン選択][topic coin selection]および
  ハードウェア署名デバイスのアドレス検証のサポートが含まれています。

- **Mercury Layerの発表:**
  [Mercury Layer][]は、[MuSig2][topic musig]の[変形][mercury blind musig]を使用して、
  [ステートチェーン][topic statechains]オペレーターによるブラインド署名を実現する
  ステートチェーンの[実装][mercury layer github]です。

- **AQUA walletの発表:**
  [AQUA wallet][]は、Bitcoin、LightningおよびLiquid[サイドチェーン][topic sidechains]をサポートする
  [オープンソースの][aqua github]モバイルウォレットです。

- **Samourai Walletがアトミックスワップ機能を発表:**
  以前の[研究][samourai gitlab comit]に基づいた[クロスチェーンアトミックスワップ][samourai gitlab swap]機能により、
  BitcoinとMoneroのチェーン間でピアツーピアのコインスワップが可能になります。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LDK 0.0.120][]は、LN対応アプリケーションを構築するためのこのライブラリのセキュリティリリースです。
  これは「`UserConfig::manually_accept_inbound_channels`オプションが有効になっている場合に、
  ピアからの信頼できない入力から到達できるサービス拒否の脆弱性が修正されています」。
  他にもいくつかのバグ修正と小さな改善が含まれています。

- [HWI 2.4.0-rc1][]は、複数の異なるハードウェア署名デバイスに共通のインターフェースを提供する、
  このパッケージの次期バージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #29239][]は、`-v2transport`の設定が有効な場合に、
  `addnode` RPCが[v2トランスポートプロトコル][topic v2 p2p transport]で接続するよう更新されました。

- [Eclair #2810][]は、[トランポリンルーティング][topic trampoline payments]の
  Onion暗号化情報で400 byteを超える使用が可能になりました。
  最大サイズは、[BOLT4][]の1,300 byteです。400 byte未満のトランポリンルーティングは、
  400 byteにパディングされます。

- [LDK #2791][]、[#2801][ldk #2801]および[#2812][ldk #2812]は、
  [ルートブラインド][topic rv routing]のサポートの追加を完了し、
  その機能ビットをアドバタイズするようになりました。

- [Rust Bitcoin #2230][]は、インプットの実効値を計算する関数を追加しました。
  これは、インプットの値から使用コストを差し引いたものです。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29239,2810,2791,2801,2812,2230" %}
[teinturier v3]: https://delvingbitcoin.org/t/lightning-transactions-with-v3-and-ephemeral-anchors/418/
[towns binana]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022289.html
[sanders transition]: https://delvingbitcoin.org/t/lightning-transactions-with-v3-and-ephemeral-anchors/418/2
[news283 v3pin]: /ja/newsletters/2024/01/03/#v3-pinning
[news274 cat]: /ja/newsletters/2023/10/25/#op-cat-bip
[news232 inqui]: /ja/newsletters/2023/01/04/#bitcoin-inquisition
[news285 mev]: /ja/newsletters/2024/01/17/#mev-miner-extractable-value
[news285 lnhance]: /ja/newsletters/2024/01/17/#lnhance
[stewart bitcoin-s]: https://delvingbitcoin.org/t/disclosure-btcd-consensus-bugs-due-to-usage-of-signed-transaction-version/455/2
[gogge btcd]: https://delvingbitcoin.org/t/disclosure-btcd-consensus-bugs-due-to-usage-of-signed-transaction-version/455
[hwi 2.4.0-rc1]: https://github.com/bitcoin-core/HWI/releases/tag/2.4.0-rc.1
[ldk 0.0.120]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.120
[cast]: https://ja.wikipedia.org/wiki/型変換
[Envoy 1.5]: https://github.com/Foundation-Devices/envoy/releases/tag/v1.5.1
[envoy blog]: https://foundationdevices.com/2024/01/envoy-version-1-5-1-is-now-live/
[Liana v4.0]: https://github.com/wizardsardine/liana/releases/tag/v4.0
[liana blog]: https://www.wizardsardine.com/blog/liana-4.0-release/
[Mercury Layer]: https://mercurylayer.com/
[mercury blind musig]: https://github.com/commerceblock/mercurylayer/blob/dev/docs/blind_musig.md
[mercury layer github]: https://github.com/commerceblock/mercurylayer/tree/dev/docs
[AQUA Wallet]: https://aquawallet.io/
[aqua github]: https://github.com/AquaWallet/aqua-wallet
[samourai gitlab swap]: https://code.samourai.io/wallet/comit-swaps-java/-/blob/master/docs/SWAPS.md
[samourai gitlab comit]: https://code.samourai.io/wallet/comit-swaps-java/-/blob/master/docs/files/Atomic_Swaps_between_Bitcoin_and_Monero-COMIT.pdf
