---
title: 'Bitcoin Optech Newsletter #306'
permalink: /ja/newsletters/2024/06/07/
name: 2024-06-07-newsletter-ja
slug: 2024-06-07-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、Bitcoin Coreの旧バージョンに影響のある脆弱性の今後の開示の発表と、
testnetの新バージョンのBIPドラフト、関数型暗号に基づくコベナンツの提案、
Bitcoin Scriptで64 bit演算を実行するための提案のアップデート、
`OP_CAT` opcodeを用いてsignet上のProof of Workを検証するためのスクリプトのリンク、
BIP21仕様`bitcoin:` URIの更新案を掲載しています。
また、新しいリリースとリリース候補の発表や、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **Bitcoin Coreの旧バージョンに影響する脆弱性の今後の開示:**
  Bitcoin Coreプロジェクトのメンバー数名が、旧バージョンのBitcoin Coreに影響を与える脆弱性の開示[方針案][disclosure policy]について、
  IRC上で[議論しました][irc disclose]。深刻度の低い脆弱性については、
  脆弱性を解消する（または十分に緩和する）Bitcoin Coreのバージョンが最初にリリースされてから約二週間後に詳細を開示します。
  その他のほとんどの脆弱性については、脆弱性の影響を受けるBitcoin Coreの最後のバージョンが
  End-of-Life（リリースから約1年半後）に達した後で詳細が開示されます。まれな重大な脆弱性については、
  Bitcoin Coreのセキュリティチームのメンバーが最も適切な開示のタイムラインについて非公開で議論します。

  この方針についてさらに議論する機会を得た後、Bitcoin Core 24.*以下に影響する脆弱性の開示を始めることがプロジェクトの意図です。
  すべてのユーザーと管理者は、今後二週間以内にBitcoin Core 25.0以上にアップグレードすることを**強く推奨します**。
  可能な場合は常に最新バージョン（執筆時点では27.0）、または特定のリリースシリーズの最新バージョン（例：
  25.xリリースシリーズの場合は25.2、26.xリリースシリーズの場合は26.1）を使用するのが理想的です。

  これまでと同様に、Optechは監視しているインフラプロジェクト（ Bitcoin Coreを含む）に影響する
  すべての重要なセキュリティの開示の要約を提供します。

- **testnet4のBIPと実験的な実装:** Fabian Jahrは、
  既存のtestnet3のいくつかの問題（[ニュースレター #297][news297 testnet]参照）を解消するために設計された
  [testnet][topic testnet]の新バージョンであるtestnet4の[BIPドラフト][bips #1601]の発表を
  Bitcoin-Devメーリングリストに[投稿しました][jahr testnet4]。
  Jahrはまた、提案された実装のBitcoin Coreの[プルリクエスト][bitcoin Core #29775]のリンクも掲載しています。
  testnet4にはtestnet3との顕著な違いが2つあります:

  - *<!--bip-and-experimental-implementation-of-testnet4-->難易度-1への戻りが少ない:*
    （偶然であれ故意であれ）最後から2番めのブロックから20分以上後のタイムスタンプを持つ最後のブロックをマイニングすることで、
    2016ブロックの全期間を最小難易度（難易度-1）に減らすことは簡単でした。
    現在、期間の難易度は、mainnetで使用される通常の方法でのみ下方調整できますが、
    タイムスタンプが前のブロックから20分以上経過している場合、新しい期間の最初のブロックを除く
    すべての個々のブロックを難易度-1でマイニングすることは可能です。[^testnet-fixup]

  - *<!--time-warp-fixed-->タイムワープの修正:*
    testnet3（およびmainnet）では、[タイムワープ攻撃][topic time warp]を悪用することで難易度を上げることなく、
    10分毎に1回よりも大幅に高速にブロックを生成することができました。
    testnet4では、mainnetの[コンセンサスクリーンアップ][topic consensus cleanup]
    ソフトフォークの一部として提案されたタイムワープのソリューションが実装さています。

  BIPのドラフトでは、testnet4について議論されたものの使用されなかった追加の代替案もいくつか言及されています。

- **<!--functional-encryption-covenants-->関数型暗号のコベナンツ:** Jeremy Rubinは、
  理論的には[関数型暗号][functional encryption]を利用することで、コンセンサスを変更することなく、
  Bitcoinにあらゆる[コベナンツ][topic covenants]の振る舞いを追加することができるという[論文][rubin fe paper]を
  Delving Bitcoinに[投稿しました][rubin fe post]。基本的にこれは、
  コベナンツのユーザーが第三者をトラストする必要があるものですが、
  そのトラストは複数の当事者に分散され、特定の時点でその内の1人だけが正直に行動すればよいものです。

  要するに、関数型暗号により、特定のプログラムに対応する公開鍵を作成できます。
  プログラムを満たすことができる当事者は、（対応する秘密鍵について知る必要なく）公開鍵に対応する署名を作成することができます。

  Rubinは、これは既存のコベナンツの提案よりも、（結果の署名検証を除く）すべての操作がオフチェーンで行われ、
  （公開鍵と署名を除く）データをオンチェーンで公開する必要がないという点で優れていると指摘しています。
  これにより、常によりプライベートになり、多くの場合スペースを節約できます。複数の署名チェックを実行することで、
  同じスクリプトで複数のコベナンツプログラムを使用することができます。

  Trusted Setupの必要性に加えて、Rubinは関数型暗号のもう1つの欠点として、
  「暗号技術が未発達なため、現時点で使用するのは現実的ではない」と述べています。

- **<!--updates-to-proposed-soft-fork-for-64-bit-arithmetic-->64 bit演算のソフトフォーク提案のアップデート:** Chris
  Stewartは、Bitcoin Scriptで64 bit整数を扱う機能を追加するという以前の提案（
  ニュースレター[#285][news285 64bit]および[#290][news290 64bit]参照）のアップデートを
  Delving Bitcoinに[投稿しました][stewart 64bit]。
  主な変更点は:

  - *既存のopcodeの更新:* `OP_ADD64`のような新しいopcodeを追加する代わりに、
    既存のopcode（`OP_ADD`など）を64 bitで動作するよう更新しています。
    大きな数値のエンコードは、現在の小さな数値に使用されているエンコードとは異なるため、
    大きな数値を使用するようアップグレードされたスクリプトの断片は、修正が必要になる場合があります。
    Stewartは、`OP_CHECKLOCKTIMEVERIFY`が5バイトのパラメーターではなく8バイトのパラメーターを取る必要がある例を挙げています。

  - *結果にbool値が含まれる:* 演算が成功すると、
    結果がスタックに置かれるだけでなく、演算が成功したことを示すbool値もスタックに置かれます。
    演算が失敗する一般的な理由の1つは、結果が64 bitよりも大きく、フィールドサイズがオーバーフローする場合です。
    コードでは、演算が正常に完了したことを保証するために`OP_VERIFY`を使用できます。

  Anthony Townsは、スクリプトで演算が成功したかをさらに検証するのではなく、
  オーバーフローが発生した場合に、デフォルトのopcodeが失敗するという代替アプローチの主張を[返信しました][towns 64bit]。
  演算によってオーバーフローが発生するかどうかをテストすることが有用な場合は、
  `ADD_OF`などの新しいopcodeが利用できるようにします。

- **Proof of Workを検証する`OP_CAT`スクリプト:** Anthony Townsは、
  [OP_CAT][topic op_cat]を使用して、スクリプトに送られたコインをProof of Work（PoW）を使用して
  誰でも使用できるようにする[signet][topic signet]用のスクリプトについてDelving Bitcoinに[投稿しました][towns powcat]。
  これは分散型のsignet-bitcoinのFaucetとして使用することができます。
  マイナーまたはユーザーが余剰のビットコインを持っている場合、彼らはそれをスクリプトに送金します。
  ユーザーはsignet bitcoinが必要になると、スクリプトへの支払いをしているUTXOを検索し、
  PoWを行い、コインを要求するためにそのPoWを使用するトランザクションを作成します。

  Townsの投稿では、スクリプトといくつかの設計上の選択の動機を掲載しています。

- **BIP21更新の提案:** Matt Coralloは、
  [BIP21][]`bitcoin:` URIの仕様の更新について、Bitcoin-Devメーリングリストに[投稿しました][corallo bip21]。
  以前説明したように（[ニュースレター #292][news292 bip21]参照）、ほぼすべてのBitcoinウォレットは、
  指定されたものとは異なるURIスキームを使用しており、インボイスプロトコルへの追加の変更は、
  BIP21の使用における追加の変更に繋がる可能性があります。[提案][bips #1555]の主な変更点は次のとおりです:

  - *base58check以外:* BIP21では、
    すべてのBitcoinアドレスがbase58checkエンコーディングを使用することが想定されていますが、
    これはP2PKHやP2SHアウトプットのレガシーアドレスのみに使用されます。
    最近のアウトプットは[bech32][topic bech32]やbech32mを使用しています。
    今後の支払いにおいては、[サイレントペイメント][topic silent payments]アドレスや
    LN[オファー][topic offers]プロトコルで受信されることもありますが、
    これらはほぼ確実にBIP21ペイロードとして使用されます。

  - *<!--empty-body-->空のボディ:* 現在BIP21では、
    ペイロードのボディ部にBitcoinアドレスを指定する必要があり、
    クエリパラメーターは追加の情報（支払額など）を指定します。
    [BIP70ペイメントプロトコル][topic bip70 payment protocol]などの以前のペイメントプロトコルでは、
    使用する新しいクエリパラメーターが定義されていました（[BIP72][]参照）が、
    パラメーターを理解していないクライアントでは、ボディ部のアドレスを使用することになります。
    場合によっては、受信者は（サイレントペイメントなどプライバシーを重視するユーザーなど）、
    基本アドレスタイプ（base58check、bech32、bech32m）にフォールバックしたくない場合があります。
    提案されている更新では、ボディフィールドを空にすることができます。

  - *<!--new-query-parameters-->新しいクエリパラメーター:* この更新では、
    [BOLT11][]インボイスの`lightning`（現在使用中）、
    LNオファーの`lno`（提案中）、サイレントペイメント用の`sp`（提案中）という3つの新しいキーを掲載しています。
    また、将来のパラメーター用のキーの命名方法についても説明しています。

  Coralloは投稿の中で、ウォレットは正常に解析できない`bitcoin:` URIを無視または拒否するため、
  この変更はすべての既知の展開済みソフトウェアに対して安全であると述べています。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning 24.05rc2][]は、この人気のLNノード実装の次期メジャーバージョンのリリース候補です。

- [Bitcoin Core 27.1rc1][]は、この主要なフルノード実装のメンテナンスバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

_今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Core Lightning #7252][]は、`lightningd`の動作を変更し、
  協調チャネルクローズ中に`ignore_fee_limits`の設定を無視します。
  これにより、相手がLDKノードである場合に、 Core Lightning (CLN)チャネル開設ノードが手数料を過剰に支払う問題が修正されます。
  このシナリオでは、開設ノードではないLDK（アリス）が協調チャネルクローズを開始し、
  手数料の交渉を始めると、開設ノードであるCLN（ボブ）は`ignore_fee_limits`設定により、
  手数料を`min_sats`から`max_channel_size`までの範囲で設定できると応答します。
  LDKは（BOLTの仕様に反して）「常に最高許容額を選択」[します][ldk #1101]。
  そのためボブは上限を選択し、アリスがそれを受け入れるため、アリスは手数料を大幅に過払いしたトランザクションをブロードキャストします。

- [LDK #2931][]は、経路探索中のログの記録を強化し、直接つながっているチャネルに関する追加データ（
  欠落の有無、最小[HTLC][topic htlc]金額、最大HTLC金額など）を含めるようにしました。
  ログの追加は、各チャネルの利用可能な流動性と制限を可視化することで、
  ルーティングの問題をより適切にトラブルシューティングすることを目的としています。

- [Rust Bitcoin #2644][]は、`bitcoin_hashes`コンポーネントにHKDF
  (HMAC (Hash-based Message Authentication Code) Extract-and-Expand Key Derivation Function)を追加し、
  Rust Bitcoinで[BIP324][]を実装します。HKDFは、キーマテリアルのソースから安全かつ標準化された方法で暗号鍵を導出するために使用されます。
  （[v2 P2Pトランスポート][topic v2 p2p transport]として知られている）BIP324は、
  （Bitcoin Coreでデフォルトで有効になっている）暗号化接続を介して、Bitcoinノードが相互に通信できるようにする方法です。

- [BIPs #1541][]は、標準トランザクションのサブセットである[TRUC][topic v3 transaction relay]（
  Topologically Restricted Until Confirmation）トランザクション（v3トランザクション）の仕様[BIP431][]を追加します。
  これは[トランザクションPinning][topic transaction pinning]攻撃を克服するためのコストを最小限に抑えつつ、
  [トランザクションの置換][topic rbf]を可能にするよう設計された追加ルールを備えています。

- [BIPs #1556][]は、_圧縮トランザクション_ の仕様[BIP337][]を追加します。
  これはBitcoinトランザクションを圧縮し、サイズを最大50%削減するシリアライゼーションプロトコルです。
  これらは、衛星やアマチュア無線、ステガノグラフィーなどの低帯域幅での送信に実用的です。
  `compressrawtransaction`と`decompressrawtransaction`という2つのRPCコマンドが提案されています。
  BIP337の詳細な説明については、ニュースレター[#267][news267 bip337]をご覧ください。

- [BLIPs #32][]は、提案中のDNSベースの人が読めるBitcoin支払い指示（[ニュースレター #290][news290 omdns]参照）を
  [Onionメッセージ][topic onion messages]で使用し、
  `bob@example.com`のようなアドレスに支払いを送信できるようにする方法について記載した[BLIP32][]を追加しています。
  たとえば、アリスはボブに支払いをするよう彼女のLNクライアントに指示します。
  彼女のクライアントはDNSアドレスを安全に直接解決できないかもしれませんが、
  Onionメッセージを使用して、DNS解決サービスを通知しているピアの一つにコンタクトできます。
  そのピアは、`example.com`の`bob`エントリーのDNS TXTレコードを検索し、
  その結果を[DNSSEC][]署名と一緒にアリスへのOnionメッセージの応答に入れます。
  アリスはその情報を検証し、それを使って[オファー][topic offers]プロトコルでボブにインボイスを要求します。

## 脚注

[^testnet-fixup]:
  この段落は公開後に編集されました。[訂正][murch correction]してくださったMark "Murch" Erhardtに感謝します。

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="7252,2931,2644,1541,1556,32,1601,29775,1555,1101" %}
[rubin fe paper]: https://rubin.io/public/pdfs/fedcov.pdf
[core lightning 24.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v24.05rc2
[news290 omdns]: /ja/newsletters/2024/02/21/#dns-bitcoin
[dnssec]: https://ja.wikipedia.org/wiki/DNS_Security_Extensions
[jahr testnet4]: https://mailing-list.bitcoindevs.xyz/bitcoindev/a6e3VPsXJf9p3gt_FmNF_Up-wrFuNMKTN30-xCSDHBKXzXnSpVflIZIj2NQ8Wos4PhQCzI2mWEMvIms_FAEs7rQdL15MpC_Phmu_fnR9iTg=@protonmail.com/
[news297 testnet]: /ja/newsletters/2024/04/10/#testnet
[rubin fe post]: https://delvingbitcoin.org/t/fed-up-covenants/929
[functional encryption]: https://en.wikipedia.org/wiki/Functional_encryption
[stewart 64bit]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397/49
[towns 64bit]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397/50
[news285 64bit]: /ja/newsletters/2024/01/17/#proposal-for-64-bit-arithmetic-soft-fork-64-bit
[news290 64bit]: /ja/newsletters/2024/02/21/#continued-discussion-about-64-bit-arithmetic-and-op-inout-amount-opcode-64-bit-op-inout-amount-opcode
[towns powcat]: https://delvingbitcoin.org/t/proof-of-work-based-signet-faucet/937
[corallo bip21]: https://mailing-list.bitcoindevs.xyz/bitcoindev/93c14d4f-10f3-48af-9756-7e39d61ba3d4@mattcorallo.com/
[news292 bip21]: /ja/newsletters/2024/03/06/#bip21-bitcoin-uri
[irc disclose]: https://bitcoin-irc.chaincode.com/bitcoin-core-dev/2024-06-06#1031717
[disclosure policy]: https://gist.github.com/darosior/eb71638f20968f0dc896c4261a127be6
[Bitcoin Core 27.1rc1]: https://bitcoincore.org/bin/bitcoin-core-27.1/
[news289 v3]: /ja/newsletters/2024/02/14/#bitcoin-core-28948
[news296 v3]: /ja/newsletters/2024/04/03/#bitcoin-core-29242
[news305 v3]: /ja/newsletters/2024/05/31/#bitcoin-core-29873
[news267 bip337]: /ja/newsletters/2023/09/06/#bitcoin
[murch correction]: https://github.com/bitcoinops/bitcoinops.github.io/pull/1714#discussion_r1630230324
