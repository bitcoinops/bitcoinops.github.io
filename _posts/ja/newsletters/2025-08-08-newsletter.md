---
title: 'Bitcoin Optech Newsletter #366'
permalink: /ja/newsletters/2025/08/08/
name: 2025-08-08-newsletter-ja
slug: 2025-08-08-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、UtreexoのBIPドラフトの発表と、
最小トランザクションリレー手数料率の引き下げに関する継続議論、
mempoolポリシーの相違による問題を軽減するためにノードがブロックテンプレートを共有できるようにする提案を掲載しています。
また、Bitcoin Core PR Review Clubミーティングの概要や、新しいリリースとリリース候補の発表、
人気のBitcoinインフラストラクチャプロジェクトの注目すべき更新など恒例のセクションも含まれています。
さらに、先週のニュースレターの訂正と読者へのお勧めも掲載しています。

## ニュース

- **UtreexoのBIPドラフトの提案:** Calvin Kimは、Tadge DryjaおよびDavidson Souzaと共同で作成した
  [Utreexo][topic utreexo]検証モデルに関する3つのBIPドラフトをBitcoin-Devメーリングリストに[投稿しました][kim bips]。
  [最初のBIP][ubip1]は、Utreexoアキュムレーターの構造を規定しています。
  このアキュムレーターにより、ノードはわずか数KBで、完全なUTXOセットへのコミットメントを簡単に更新、保存できます。
  [2つめのBIP][ubip2]は、従来の使用済みトランザクションアウトプット（STXO、初期のBitcoin Coreとlibbitcoinで使用）や
  未使用トランザクションアウトプット（UTXO：現在のBitcoin Coreで使用）ではなく、
  アキュムレーターを使用してフルノードが新しいブロックとトランザクションを検証する方法を規定しています。
  [3つめのBIP][ubip3]は、Utreexoの検証に必要な追加データの転送を可能にするBitcoinのP2Pプロトコルの変更を規定しています。

  著者たちは概念的なレビューを求めており、今後の進展に基づいてBIPドラフトを更新する予定です。

- **<!--continued-discussion-about-lowering-the-minimum-relay-feerate-->最小リレー手数料率の引き下げに関する議論の続き:**
  Gloria Zhaoは、[デフォルトの最小リレー手数料率][topic default minimum transaction relay feerates]を
  90％引き下げて0.1 sat/vbyteにするという案についてDelving Bitcoinに[投稿しました][zhao minfee]。
  彼女は、このアイディアのコンセプトと、他のソフトウェアに与える影響についての議論を促しました。
  Bitcoin Core固有の懸念事項については、[プリリクエスト][bitcoin core #33106]のリンクを示しました。

- **mempoolポリシーの相違による問題を軽減するためのピアのブロックテンプレートの共有:**
  Anthony Townsは、フルノードピアが[コンパクトブロックリレー][topic compact block relay]
  エンコーディングを使って、次のブロック用の現在のテンプレートを定期的に相互に送信する提案を
  Delving Bitcoinに[投稿しました][towns tempshare]。受信側のピアは、
  テンプレート内の不足しているトランザクションを要求でき、それらをローカルのmempoolに追加するか、
  キャッシュに格納することができます。これによりmempoolポリシーが異なるピア同士でも、
  ポリシーの違いにかかわらずトランザクションを共有できるようになります。
  これは以前提案された弱ブロックを使用する方法（[ニュースレター #299][news299 weak blocks]参照）の代替になります。
  Townsは、[概念実証の実装][towns tempshare poc]も公開しました。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Add exportwatchonlywallet RPC to export a watchonly version of a
wallet][review club 32489]は、[achow101][gh achow101]によるPRで、
監視専用ウォレットの作成に必要な手作業が削減されます。この変更以前は、
`importdescriptors` RPC呼び出しを入力またはスクリプト化したり、
アドレスラベルをコピーしたりする必要がありました。

公開[ディスクリプター][topic descriptors]に加えて、エクスポートされるものには以下が含まれます:
- 必要に応じて導出されたxpubを含むキャッシュ（例：強化導出される導出パスの場合）
- アドレス帳のエントリー、ウォレットフラグ、ユーザーラベル
- 過去のすべてのウォレットトランザクション（再スキャンは不要）

エクスポートされたウォレットデータベースは、`restorewallet` RPCを使ってインポートできます。

{% include functions/details-list.md
  q0="なぜ既存の`IsRange()`/`IsSingleType()`情報では、ディスクリプターが監視専用側で
  展開可能かどうかを判断できないのですか？
  a) 強化導出用の`wpkh(xpub/0h/*)`パスと
  b) `pkh(pubkey)`ディスクリプターについて、`CanSelfExpand()`のロジックを説明してください。"
  a0="`IsRange()`と`IsSingleType()`は、強化導出のチェックをしないため不十分でした。
  強化導出には監視専用ウォレットでは利用できない秘密鍵が必要になります。
  `CanSelfExpand()`は強化導出パスを再帰的に検索するために追加されました。
  強化導出パスが見つかった場合は`false`を返し、監視専用ウォレットがアドレスを導出するには
  事前に設定されたキャッシュをエクスポートする必要があることを示します。
  `pkh(pubkey)`ディスクリプターは範囲指定されておらず、導出もないため、
  常に自己展開可能です"
  a0link="https://bitcoincore.reviews/32489#l-27"

  q1="`ExportWatchOnlyWallet`は、`!desc->CanSelfExpand()`の場合のみディスクリプターキャッシュをコピーします。
  そのキャッシュには具体的に何が格納されていますか？キャッシュが不完全だと、
  監視専用ウォレットのアドレス導出にどのような影響がありますか？"
  a1="キャッシュには、強化導出パスを持つディスクリプター用の`CExtPubKey`オブジェクトが格納されており、
  これらは支払い用のウォレットで事前に導出されています。
  キャッシュが不完全な場合、監視専用ウォレットは必要な秘密鍵を持たないため、
  不足しているアドレスを導出できません。これにより、それらのアドレスに送信されたトランザクションを認識できず、
  残高が正しく表示されなくなります。"
  a1link="https://bitcoincore.reviews/32489#l-52"

  q2="エクスポーターは`create_flags = GetWalletFlags() | WALLET_FLAG_DISABLE_PRIVATE_KEYS`を設定します。
  なぜすべてクリアして新しく始めるのではなく、元のフラグ（例：`AVOID_REUSE`）を保持するのが重要なのですか？"
  a2="フラグを保持することで、支払い用のウォレットと監視専用ウォレット間の動作の一貫性が確保されます。
  たとえば、`AVOID_REUSE`フラグは、どのコインが支払いに利用可能と見なされるかに影響します。
  これを保持しないと、監視専用ウォレットがメインとウォレットとは異なる利用可能残高を報告し、
  ユーザーに混乱を招くことになります。"
  a2link="https://bitcoincore.reviews/32489#l-68"

  q3="なぜエクスポーターは新しいウォレットをブロック0から開始させるのではなく、
  ソースウォレットからロケーターを読み取って新しいウォレットにそのまま書き込むのですか？"
  a3="ブロックロケーターをコピーすることで、新しい監視専用ウォレットが
  ブロックチェーンの新しいトランザクションのスキャンを開始する場所を伝え、
  完全な再スキャンの必要性を回避します。"
  a3link="https://bitcoincore.reviews/32489#l-93"

  q4="マルチシグディスクリプター`wsh(multi(2,xpub1,xpub2))`を考えてみましょう。
  1人の共同署名者が監視専用ウォレットをエクスポートして第三者と共有した場合、
  単にディスクリプター文字列を提供する場合と比べて、その第三者はどのような新しい情報を得ますか？"
  a4="監視専用ウォレットのデータには、アドレス帳、ウォレットフラグ、
  コイン管理ラベルなどの追加のメタデータが含まれています。強化導出ウォレットの場合、
  第三者は監視専用ウォレットのエクスポートを通じてのみ、過去および将来のトランザクションに関する情報を取得でききます。"
  a4link="https://bitcoincore.reviews/32489#l-100"

  q5="`wallet_exported_watchonly.py`では、なぜテストはオンライン/オフラインのペアで
  支払い可能性をチェックする前に、`wallet.keypoolrefill(100)`を呼び出すのですか？"
  a5="`keypoolrefill(100)`呼び出しは、オフライン（支払い）ウォレットに
  強化ディスクリプター用に100個の鍵を事前に導出させ、キャッシュに入力します。
  このキャッシュはその後のエクスポートに含まれ、
  オンラインの監視専用ウォレットがそれら100個のアドレスを生成できるようになります。
  また、オフラインウォレットが署名するPSBTを受信した際に、これらのアドレスを認識できるようになります。"
  a5link="https://bitcoincore.reviews/32489#l-122"
%}

## Optechのお勧め

[Bitcoin++ Insider][]は、読者から資金提供を受けてBitcoinの技術的なトピックに関するニュースの配信を始めました。
無料の週刊ニュースレター「Last Week in Bitcoin」と
「This Week in Bitcoin Core」は、Optechのニュースレターの定期購読者にとって特に興味深い内容となるでしょう。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [LND v0.19.3-beta.rc1][]は、この人気のLNノード実装のメンテナンスバージョンのリリース候補で、
  「重要なバグ修正」が含まれています。最も注目すべきは、「オプションの移行で[...]
  ノードのディスクおよびメモリ要件が大幅に削減される」ことです。

- [BTCPay Server 2.2.0][]は、このセルフホスト型ペイメントソリューションのリリースです。
  ウォレットポリシーと[miniscript][topic miniscript]のサポートが追加され、
  トランザクション手数料の管理と監視に対する追加サポートが提供され、
  その他いくつかの新しい改善とバグ修正も含まれています。

- [Bitcoin Core 29.1rc1][]は、主要なフルノードソフトウェアのメンテナンスバージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #32941][]は、制限を超えた際のOrphanageの自動トリミングを有効にして
  `TxOrphanage`のオーバーホール（[ニュースレター #364][news364 orphan]参照）を完了します。
  `maxorphantx`のユーザーに対して、それが廃止されたことを通知する警告も追加します。
  このPRは、機会的な1P1C（one-parent-one-child）[パッケージリレー][topic package relay]を確実なものにします。

- [Bitcoin Core #31385][]は、`submitpackage` RPCの
  `package-not-child-with-unconfirmed-parents`ルールを緩和し、
  1P1C[パッケージリレー][topic package relay]の使用法を改善します。
  パッケージは、ノードのmempoolに既に存在する親を含める必要がなくなりました。

- [Bitcoin Core #31244][]は、[BIP390][]で定義されている[MuSig2][topic musig]
  [ディスクリプター][topic descriptors]のパースを実装します。
  これは、MuSig2集約鍵を持つ[Taproot][topic taproot]アドレスからの受け取りとインプットの使用の際に必要です。

- [Bitcoin Core #30635][]では、helpコマンドの応答に
  `waitfornewblock`、`waitforblock`、`waitforblockheight` RPCが表示されるようになり、
  これらが一般ユーザー向けであることが示されます。またこのPRでは、
  `waitfornewblock` RPCにオプションの`current_tip`引数が追加され、
  現在のチェーンの先端のブロックハッシュを指定することで、競合状態を軽減します。

- [Bitcoin Core #28944][]は、`send` RPCコマンドおよび`sendall`
  RPCコマンドで送信されるトランザクションに、まだ指定されていない場合は、
  ランダムな先頭相対[ロックタイム][topic timelocks]を追加することで、
  [手数料スナイピング][topic fee sniping]防止保護を追加します。

- [Eclair #3133][]は、[HTLCエンドースメント][topic htlc endorsement]の
  ローカルピアレピュテーションシステム（[ニュースレター #363][news363 reputation]参照）を拡張し、
  着信ピアと同様に発信ピアのレビュテーションもスコアリングします。
  EclairはHTLCを転送する際に両方向で良いレピュテーションを考慮するようになりましたが、
  まだペナルティは実装していません。発信ピアのスコアリングは、
  [チャネルジャミング攻撃][topic channel jamming attacks]の特定の種類である
  シンク攻撃（[ニュースレター #322][news322 sink]参照）を防ぐために必要です。

- [LND #10097][]は、ピアが一度に多くのリクエストを送信した際のデッドロックのリスクを排除するために、
  バックログ[ゴシップ][topic channel announcements]リクエスト（`GossipTimestampRange`）用の
  非同期なピア毎のキューを導入します。ピアが前のリクエストが完了する前にリクエストを送信した場合、
  追加のメッセージは自動的に破棄されます。すべてのピアにわたる同時ワーカー数を制限するために
  新しく`gossip.filter-concurrency`設定（デフォルト5）が追加されます。このPRはまた、
  すべてのゴシップレート制限設定の動作を説明するドキュメントも追加しています。

- [LND #9625][]は、ペイメントハッシュを提供することで、ユーザーがキャンセルされた
  [BOLT11][]インボイス（[ニュースレター #33][news33 canceled]参照）を削除できる
  `deletecanceledinvoice` RPCコマンド（および同等の`lncli`）を追加します。

- [Rust Bitcoin #4730][]は、脆弱なバージョンのBitcoin Core（0.12.1未満）を実行しているピアに、
  彼らのアラートシステムが安全でないことを通知する[最終アラート][final alert]メッセージ用の
  `Alert`型ラッパーを追加します。satoshiは重要なネットワークイベントをユーザーに通知するために
  アラートシステムを導入しましたが、最終アラートメッセージを除いて、
  バージョン0.12.1で[廃止されました][retired]。

- [BLIPs #55][]は、モバイルクライアントがLSPからプッシュ通知を受信するために
  エンドポイント経由でウェブフックに登録する方法を定義する[BLIP55][]を追加します。
  このプロトコルは、クライアントが[非同期支払い][topic async payments]を受信した際に通知を受け取るのに便利で、
  最近LDKに実装されました（[ニュースレター #365][news365 webhook]参照）。

## 訂正

[先週のニュースレター][news365 p2qrh]で、[BIP360][] _pay to quantum-resistant hash_
の更新版について、Tim Ruffingが[論文][ruffing paper]で安全性を示した変更を
「まさにこの変更が行われています」と誤って説明していました。
BIP360が実際に行っているのは、SHA256ベースのマークルルート（プラスkeypathの代替）への楕円曲線コミットメントを
マークルルートへのSHA256コミットメントに直接置き換えることです。Ruffingの論文が示したのは、
現在使用されているTaprootは、[Tapscript][topic tapscript]言語に量子耐性署名スキームが追加され、
keypath支払いが無効化されれば安全であるということでした。
一方、BIP360は、ウォレットにTaprootの（些細な）変種へのアップグレードを要求し、
その変種からkeypathメカニズムを削除し、そのTapleafで使用されるスクリプト言語に量子耐性署名スキームの追加するものです。
Ruffingの論文はBIP360で提案されたtaprootの変種には適用されませんが、
この変種の安全性（コミットメントとして見た場合）は、マークルツリーの安全性から直接導かれます。

誤りについてお詫び申し上げます。また、私たちのミスについて指摘くださったTim Ruffingに感謝します。

{% include snippets/recap-ad.md when="2025-08-12 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33106,32941,31385,31244,30635,28944,3133,10097,9625,4730,55" %}
[bitcoin core 29.1rc1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[bitcoin++ insider]: https://insider.btcpp.dev/
[news365 p2qrh]: /ja/newsletters/2025/08/01/#taproot
[zhao minfee]: https://delvingbitcoin.org/t/changing-the-minimum-relay-feerate/1886/
[towns tempshare]: https://delvingbitcoin.org/t/sharing-block-templates/1906
[towns tempshare poc]: https://github.com/ajtowns/bitcoin/commit/ee12518a4a5e8932175ee57c8f1ad116f675d089
[news299 weak blocks]: /ja/newsletters/2024/04/24/#weak-blocks-proof-of-concept-implementation
[ruffing paper]: https://eprint.iacr.org/2025/1307
[kim bips]: https://mailing-list.bitcoindevs.xyz/bitcoindev/3452b63c-ff2b-4dd9-90ee-83fd9cedcf4an@googlegroups.com/
[ubip1]: https://github.com/utreexo/biptreexo/blob/7ae65222ba82423c1a3f2edd6396c0e32679aa37/utreexo-accumulator-bip.md
[ubip2]: https://github.com/utreexo/biptreexo/blob/7ae65222ba82423c1a3f2edd6396c0e32679aa37/utreexo-validation-bip.md
[ubip3]: https://github.com/utreexo/biptreexo/blob/7ae65222ba82423c1a3f2edd6396c0e32679aa37/utreexo-p2p-bip.md
[btcpay server 2.2.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.2.0
[lnd v0.19.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.3-beta.rc1
[review club 32489]: https://bitcoincore.reviews/32489
[gh achow101]: https://github.com/achow101
[news363 reputation]: /ja/newsletters/2025/07/18/#eclair-2716
[news322 sink]: /ja/newsletters/2024/09/27/#hybrid-jamming-mitigation-testing-and-changes
[news33 canceled]: /en/newsletters/2019/02/12/#lnd-2457
[final alert]: https://bitcoin.org/en/release/v0.14.0#final-alert
[retired]: https://bitcoin.org/en/alert/2016-11-01-alert-retirement#updates
[news365 webhook]: /ja/newsletters/2025/08/01/#ldk-3662
[news364 orphan]: /ja/newsletters/2025/07/25/#bitcoin-core-31829