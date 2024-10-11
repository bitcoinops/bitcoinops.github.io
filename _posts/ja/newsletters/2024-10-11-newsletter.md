---
title: 'Bitcoin Optech Newsletter #324'
permalink: /ja/newsletters/2024/10/11/
name: 2024-10-11-newsletter-ja
slug: 2024-10-11-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin Coreフルノードの旧バージョンに影響する3つの脆弱性の発表と、
btcdフルノードの旧バージョンに影響する別の脆弱性の発表、
Bitcoin Core 28.0で追加された複数の新しいP2Pネットワーク機能の使用方法を説明する
寄稿されたOptechガイドへのリンクを掲載しています。また、Bitcoin Core PR Review Clubミーティングの概要や、
新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など、
恒例のセクションも含まれています。

## ニュース

- **Bitcoin Cor 25.0より前のバージョンに影響する脆弱性の開示:**
  Niklas Göggeは、2024年4月以降のサポートが終了したBitcoin Coreのバージョンに影響する
  3つの脆弱性の発表へのリンクをBitcoin-Devメーリングリストに[投稿しました][gogge corevuln]。

  - [CVE-2024-35202リモートクラッシュの脆弱性][CVE-2024-35202 remote crash vulnerability]:
    攻撃者は、ブロックの再構築に失敗するように意図的に設計された[コンパクトブロック][topic compact block relay]
    メッセージを送信できます。プロトコルを正常に使用しても再構築が失敗することはあります。
    その場合、受信ノードは完全なブロックを要求します。

    しかし、攻撃者は完全なブロックを返信する代わりに、同じブロックヘッダーに対して
    2つめのコンパクトブロックメッセージを送信することができます。
    Bitcoin Core 25.0より前のバージョンでは、
    同じコンパクトブロックセッションでコンパクトブロックの再構築コードが複数回実行されないように設計されていたため、
    これによりノードがクラッシュしました。

    この簡単に悪用可能な脆弱性は、任意のBitcoin Coreノードをクラッシュさせるために使用される可能性があり、
    ユーザーから資金を盗むための他の攻撃の一部として使用される可能性がありました。
    たとえば、クラッシュしたBitcoin Coreノードは、チャネルの取引相手が資金を盗もうとしていることを
    接続されたLNノードに警告することができません。

    この脆弱性は、Niklas Göggeによって発見され、[責任を持って開示され][topic
    responsible disclosures]、修正され、Bitcoin Core 25.0で[修正][bitcoin core #26898]がリリースされました。

  - [大規模なinventoryセットによるDoS][DoS from large inventory sets]:
    Bitcoin Coreノードは、ピア毎に、そのピアに送信するトランザクションのリストを保持します。
    リスト内のトランザクションは、手数料率と相互の関係に基づいてソートされ、
    最適なトランザクションが高速にリレーされ、リレーネットワークのトポロジーの調査が困難になるようにします。

    しかし、2023年5月にネットワーク活動が急増した際に、
    複数のユーザーが自分のノードがCPUを過剰に使用していることに気付き始めました。
    開発者の0xB10Cは、CPUがソート機能によって消費されていることを突き止めました。
    開発者のAnthony Townsは、さらに調査を進め、
    需要が高い期間に増加する可変レートでトランザクションがキューから出るようにすることで問題を[修正しました][bitcoin core #27610]。
    この修正は、Bitcoin Core 25.0でリリースされました。

  - [<!--slow-block-propagation-attack-->低速ブロック伝播攻撃][Slow block propagation attack]:
    Bitcoin Core 25.0より前のバージョンでは、
    攻撃者からの無効なブロックにより、Bitcoin Coreが正直なピアからの同じヘッダーを持つ有効なブロックの処理を
    継続できなくなる可能性がありました。これは、追加のトランザクションを要求する必要がある際の
    コンパクトブロックの再構築に影響しました。ノードは、別のピアから無効なブロックを受信すると、
    トランザクションの待機を停止します。後で、トランザクションを受信しても、ノードはそれを無視します。

    Bitcoin Coreが無効なブロックを拒否した後（そしておそらくそれを送信したピアを切断した後）、
    他のピアにブロックの要求を再開します。複数の攻撃ピアがこのサイクルを長時間続ける可能性があります。
    攻撃者として設計されていない可能性のある欠陥のあるピアは、偶然同じ動作を引き起こす可能性があります。

    この問題は、William Casarinやghost43を含む複数の開発者が自分のノードに問題があることを報告したことで発覚しました。
    他の何人かの開発者が調査し、Suhas Daftuarがこの脆弱性を分離しました。
    Daftuarはまた、ブロックが検証をパスしディスクに保存された場合を除いて、
    どのピアも他のピアのダウンロード状態に影響を与えないようにすることでこれを[修正しました][bitcoin core #27608]。
    この修正は、Bitcoin Core 25.0に含まれています。

- **CVE-2024-38365 btcdのコンセンサス障害:**
  [先週のニュースレター][news323 btcd]で発表したように、Antoine PoinsotとNiklas Göggeは、
  btcdフルノードに影響するコンセンサス障害の脆弱性を[公開しました][pg btcd]。
  レガシーなBitcoinトランザクションでは、署名は署名スクリプトフィールドに保存されます。
  ただし、署名は署名スクリプトフィールドにもコミットします。
  署名は署名自体にコミットすることはできないため、署名者は署名スクリプトフィールドの署名以外のすべてのデータにコミットします。
  検証者は、署名コミットメントの正確性をチェックする前に、署名を削除しなければなりません。

  Bitcoin Coreの署名を削除する関数`FindAndDelete`は、署名スクリプトから完全に一致する署名のみを削除します。
  btcdで実装された関数`removeOpcodeByData`は、署名を含む署名スクリプト内のあらゆるデータを削除しました。
  これを使用すると、Bitcoin Coreがコミットメントを検証する前に削除するよりも多くのデータを
  btcdが署名スクリプトから削除することができ、一方のプログラムはコミットメントを有効とみなし、
  もう一方のプログラムは無効とみなすことになります。
  無効なコミットメントを含むトランザクションはすべて無効であり、
  無効なトランザクションを含むブロックはすべて無効であるため、
  Bitcoin Coreとbtcd間でコンセンサスが破られる可能性があります。
  コンセンサスから外れたノードは、無効なトランザクションを受け入れるように騙され、
  ネットワークの残りの部分が承認済みとみなす最新のトランザクションを確認できない可能性があります。
  いずれの場合も、多額の金銭的な損失につながる可能性があります。

  PoinsotとGöggeの責任のある開示により、btcdのメンテナーはこの脆弱性を密かに修正し、
  約3ヶ月前に修正を加えたバージョン0.24.2をリリースすることができました。

- **Bitcoin Core 28.0を採用するウォレット向けのガイド:** [先週のニュースレター][news323 bcc28]で言及したように、
  新しくリリースされたBitcoin Coreのバージョン28.0には、
  1P1C（One Parent One Child）[パッケージリレー][topic package relay]、
  [TRUC][topic v3 transaction relay]（Topologically Restricted Until Confirmation）トランザクションリレー、
  [パッケージRBF][topic rbf]、[兄弟の排除][topic kindred rbf]、
  標準[P2A][topic ephemeral anchors]（Pay-to-Anchor）アウトプットスクリプトタイプなど
  P2Pネットワークのためのいくつかの新機能が含まれています。
  これらの新機能により、いくつかの一般的なユースケースのセキュリティと信頼性が大幅に向上します。

  Gregory Sandersは、Bitcoin Coreを使用してトランザクションを作成、ブロードキャストするウォレットや
  その他のソフトウェアの開発者を対象に、Optech向けの[ガイド][sanders guide]を作成しました。
  このガイドでは、いくつかの機能の使用方法を説明し、シンプルな支払いや、RBFによる手数料の引き上げ、
  LNのコミットメントと[HTLC][topic htlc]、[Ark][topic ark]および[LNのスプライシング][topic splicing]など
  複数のプロトコルでこれらの機能がどのように役立つかを説明しています。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Add getorphantxs][review club 30793]は、[tdb3][gh tdb3]によるPRで、
`getorphantxs`という新しい実験的なRPCメソッドを追加します。
このメソッドは主に開発者向けであるため、非表示になっています。
この新しいメソッドは、呼び出し元に現在のすべてのオーファントランザクションのリストを提供します。
これはオーファンの動作/シナリオを確認する場合（例：`p2p_orphan_handling.py`のような機能テスト）や、
統計/視覚化用の追加データを提供する場合に役立ちます。

{% include functions/details-list.md
  q0="オーファントランザクションとは何ですか？どの時点でorphanageに入るのですか？"
  a0="オーファントランザクションは、インプットが不明または見つからない親トランザクションを参照するトランザクションのことです。
  ピアからトランザクションを受け取り、`ProcessMessage`で`TX_MISSING_INPUTS`により検証が失敗すると、
  トランザクションはorphanageに入ります。"
  a0link="https://bitcoincore.reviews/30793#l-16"

  q1="どのコマンドを使用すれば有効なRPCのリストを取得できますか？"
  a1="`bitcoin-cli help`が利用可能なRPCのリストを提供します。注意:
  `getorphantxs`は開発者専用のRPCとして[非表示とマーク][gh getorphantxs hidden]されているため、
  このリストには表示されません。"
  a1link="https://bitcoincore.reviews/30793#l-26"

  q2="<!--if-an-rpc-has-a-non-string-argument-does-anything-special-need-to-be-done-to-handle-it-->
  RPCに文字列以外の引数がある場合、その引数を処理するために何か特別な操作が必要ですか？"
  a2="RPCに文字列以外の引数がある場合、適切な型変換を確実に行うために`src/rpc/client.cpp`の
  `vRPCConvertParams`リストに追加する必要があります。"
  a2link="https://bitcoincore.reviews/30793#l-72"

  q3="このRPCの結果の最大サイズはどれくらいですか？保持されるオーファントランザクションの数に制限はありますか？
  オーファンがorphanageに留まる期間に制限はありますか？"
  a3="オーファンの最大数は100（`DEFAULT_MAX_ORPHAN_TRANSACTIONS`）です。
  `verbosity=0`の場合、各txidは、32 byteのバイナリ値ですが、JSON-RPCの結果用に
  16進数にエンコードされると64文字の文字列になります（各byteは2つの16進文字で表現されるため）。
  つまり、結果の最大サイズは、6.4 kB（100 txid * 64 byte）です。<br><br>
  `verbosity=2`の場合、16進数にエンコードされたトランザクションが、結果の中で圧倒的に大きなフィールドであるため、
  ここでは計算を簡単にするため、他のフィールドは無視します。トランザクションの最大シリアライズサイズは、
  最大400 kB（witnessデータのみで構成される極端で不可能なケース）、
  または16進数でエンコードされた場合には800 kBです。したがって、結果の最大サイズは、
  約80 MB（100トランザクション * 800 kB）です。<br><br>
  オーファンには時間制限があり、`ORPHAN_TX_EXPIRE_TIME`で定義されているように20分後に削除されます。"
  a3link="https://bitcoincore.reviews/30793#l-94"

  q4="<!--since-when-has-there-been-a-maximum-orphanage-size-->いつからorphanageの最大サイズが設定されたのですか？"
  a4="`MAX_ORPHAN_TRANSACTIONS`変数は、2012年にコミット[142e604][gh commit 142e604]で既に導入されています。"
  a4link="https://bitcoincore.reviews/30793#l-105"

  q5="`getorphantxs` RPCを使用すると、トランザクションがorphanageにどのくらいの期間保存されるかを知ることができますか？
  できる場合、どのように行えますか？"
  a5="はい。`verbosity=1`を使用すると、各オーファーントランザクションの有効期限のタイムスタンプを取得できます。
  `ORPHAN_TX_EXPIRE_TIME`（つまり20分）を減算すると、挿入時間が得られます。"
  a5link="https://bitcoincore.reviews/30793#l-128"

  q6="`getorphantxs` RPCを使用すると、オーファントランザクションのインプットが何か知ることができますか？
  できる場合、どのように行えますか？"
  a6="はい。`verbosity=2`を使用すると、RPCは16進数エンコードされたトランザクションを返します。
  これを  `decoderawtransaction`を使用してデコードすると、インプットが明らかになります。"
  a6link="https://bitcoincore.reviews/30793#l-140"
%}

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Bitcoin Inquisition 28.0][]は、提案中のソフトフォークや他の主要なプロトコルの変更を実験するために設計された
  この[signet][topic signet]フルノードの最新リリースです。更新バージョンは、
  最近リリースされたBitcoin Core 28.0に基づいています。

- [BDK 1.0.0-beta.5][]は、ウォレットやその他のBitcoin対応アプリケーションを構築するための
  このライブラリのリリース候補（RC）です。この最新のRCは、「RBFをデフォルトで有効にし、
  レート制限により失敗したサーバー要求を再試行するようにbdk_esploraクライアントを更新します。
  `bdk_electrum`クレートでは、use-openssl機能も提供されるようになりました。」

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Core Lightning #7494][]では、`channel_hints`に2時間の有効期限が導入され、
  不要な試行をスキップするために、支払いから学習した経路探索情報を将来の試行で再利用できるようになりました。
  利用不可能と判断されたチャネルは徐々に復元され、2時間後に完全に利用可能になります。
  これは、古くなった情報が原因で、その後復元した可能性のある経路がスキップされないようにするためです。

- [Core Lightning #7539][]では、`emergency.recover`ファイルからデータを取得して返すための
  `getemergencyrecoverdata` RPCコマンドが追加されました。これにより、
  APIを使用する開発者は、アプリケーションにウォレットバックアップ機能を追加できるようになります。

- [LDK #3179][]では、[BLIP32][]を実装するためのコア機能として、
  新しい`DNSSECQuery`および`DNSSECProof`[Onionメッセージ][topic onion messages]と、
  これらのメッセージを処理するための`DNSResolverMessageHandler`を導入しました。
  このPRはまた、DNSSECプルーフを検証して[オファー][topic offers]に変換する`OMNameResolver`も追加しています。
  ニュースレター[#306][news306 blip32]をご覧ください。

- [LND #8960][]は、新しい実験的なチャネルタイプとしてTaprootオーバーレイを追加することで、
  カスタムチャネル機能を実装しました。これは[Simple Taproot Channel][topic simple taproot channels]と同じですが、
  チャネルスクリプトの[Tapscript][topic tapscript]のリーフに追加のメタデータをコミットします。
  メインのチャネルステートマシンとデータベースは、カスタムTapscriptリーフを処理および保存するように更新されます。
  Taprootオーバーレイチャネルのサポートを有効にするためには、
  `TaprootOverlayChans`設定オプションを設定する必要があります。
  カスタムチャネル構想は、LNDの[Taproot Assets][topic client-side validation]サポートを強化します。
  ニュースレター[#322][news322 customchans]をご覧ください。

- [Libsecp256k1 #1479][]は、[BIP327][]で定義された[BIP340][]互換のマルチシグスキーム用の
  [MuSig2][topic musig]モジュールを追加しました。このモジュールは、
  [secp256k1-zkp][zkpmusig2]で実装されたものとほぼ同じですが、
  実験的なものでないようにするために[アダプター署名][topic adaptor signatures]のサポートを削除するなど、
  若干の変更が加えられています。

- [Rust Bitcoin #2945][]は、`TestNetVersion`列挙型を追加し、コードをリファクタリングし、
  [testnet4][topic testnet]に必要なパラメーターとブロックチェーンの定数を含めることで、
  testnet4のサポートを導入しました。

- [BIPs #1674][]は、[ニュースレター #323][news323 bip85]に掲載された
  [BIP85][]の仕様変更を元に戻しました。この変更は、展開されたプロトコルのバージョンとの互換性を壊しました。
  PRでの議論では、主要な変更のために新しいBIPの作成が支持されました。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="7494,7539,3179,8960,1479,2945,1674,26898,27610,27608" %}
[BDK 1.0.0-beta.5]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.5
[news323 bip85]: /ja/newsletters/2024/10/04/#bips-1600
[sanders guide]: /ja/bitcoin-core-28-wallet-integration-guide/
[gogge corevuln]: https://mailing-list.bitcoindevs.xyz/bitcoindev/2df30c0a-3911-46ed-b8fc-d87528c68465n@googlegroups.com/
[cve-2024-35202 remote crash vulnerability]: https://bitcoincore.org/ja/2024/10/08/disclose-blocktxn-crash/
[dos from large inventory sets]: https://bitcoincore.org/ja/2024/10/08/disclose-large-inv-to-send/
[slow block propagation attack]: https://bitcoincore.org/ja/2024/10/08/disclose-mutated-blocks-hindering-propagation/
[news323 btcd]: /ja/newsletters/2024/10/04/#btcd
[pg btcd]: https://delvingbitcoin.org/t/cve-2024-38365-public-disclosure-btcd-findanddelete-bug/1184
[news323 bcc28]: /ja/newsletters/2024/10/04/#bitcoin-core-28-0
[bitcoin inquisition 28.0]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v28.0-inq
[review club 30793]: https://bitcoincore.reviews/30793
[gh tdb3]: https://github.com/tdb3
[gh getorphantxs hidden]: https://github.com/bitcoin/bitcoin/blob/a9f6a57b6918b2f92c7d6662e8f5892bf57cc127/src/rpc/mempool.cpp#L1131
[gh commit 142e604]: https://github.com/bitcoin/bitcoin/commit/142e604184e3ab6dcbe02cebcbe08e5623182b81
[news306 blip32]: /ja/newsletters/2024/06/07/#blips-32
[news322 customchans]: /ja/newsletters/2024/09/27/#lnd-9095
[zkpmusig2]: https://github.com/BlockstreamResearch/secp256k1-zkp
