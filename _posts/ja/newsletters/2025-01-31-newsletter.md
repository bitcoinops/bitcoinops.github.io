---
title: 'Bitcoin Optech Newsletter #339'
permalink: /ja/newsletters/2025/01/31/
name: 2025-01-31-newsletter-ja
slug: 2025-01-31-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、LDKの旧バージョンに影響する脆弱性と、
2023年に最初に公開された脆弱性の新たに開示された側面、
コンパクトブロックの再構築の統計に関する新たな議論を掲載しています。
また、Bitcoin Stack Exchangeで人気の質問のまとめや、
新しいリリースとリリース候補の発表、人気のBitcoinインフラストラクチャソフトウェアの最近の変更など
恒例のセクションも含まれています。

## ニュース

- **LDKの請求処理の脆弱性:** Matt Morehouseは、
  彼が[責任を持って開示し][topic responsible disclosures]、
  LDKバージョン0.1で修正されたLDKに影響する脆弱性をDelving Bitcoinに[投稿しました][morehouse ldkclaim]。
  チャネルが複数の保留中の[HTLC][topic htlc]がある状態で一方的に閉じられると、
  LDKはトランザクション手数料を節約するため、同じトランザクションで可能な限り多くのHTLCを解決しようとします。
  ただし、チャネルの相手がバッチ化されたHTLCのいずれかを最初に承認できた場合、
  それはバッチトランザクションと競合し、バッチトランザクションは無効になります。その場合、
  LDKは競合を取り除いた更新したバッチトランザクションを正しく作成します。
  残念ながら、取引相手のトランザクションが複数の別々のバッチと競合する場合、
  LDKは誤って最初のバッチのみを更新し、残りのバッチは承認されません。

  ノードは期限までにHTLCを解決する必要があります。さもないと、相手が資金を盗むことができます。
  [タイムロック][topic timelocks]により、相手がそれぞれの期限前にHTLCを使用することが防止されます。
  LDKのほとんどの旧バージョンでは、これらのHTLCを別のバッチにまとめ、
  相手が競合するトランザクションを承認する前に承認されるようにして、資金が盗まれないようにしていました。
  資金は盗まれないものの相手がすぐに解決できるHTLCの場合、相手が資金をスタックさせるリスクがありました。
  Morehouseは、この問題は「LDKバージョン0.1にアップグレードし、
  ロックアップする原因となったコミットメントおよびHTLCの一連のトランザクションをリプレイする」ことで修正できると書いています。

  しかし、リリース候補のLDK 0.1-betaではロジックが変更され（[ニュースレター #335][news335 ldk3340]参照）、
  すべての種類のHTLCをまとめてバッチ処理するようになったため、攻撃者はタイムロックされたHTLCとの競合を作成できるようになりました。
  タイムロックが期限切れになった後も、そのHTLCの解決がスタックしたままであれば、盗難が可能でした。
  LDK 0.1のリリースバージョンにアップグレードすると、この形式の脆弱性も修正されます。

  Morehouseの投稿では、さらに詳細が提供され、同じ根本原因から生じる将来の脆弱性を防ぐための
  可能な方法についても説明されています。

- **<!--replacement-cycling-attacks-with-miner-exploitation-->マイナーの悪用による置換サイクル攻撃:**
  Antoine Riardは、2023年に彼が最初に公開した[置換サイクル][topic replacement cycling]攻撃（
  [ニュースレター #274][news274 cycle]参照）で可能な追加の脆弱性の開示をBitcoin-Dev
  メーリングリストに[投稿しました][riard minecycle]。要約すると:

  1. ボブはマロリー（およびおそらく他の人）に支払うトランザクションをブロードキャストします。

  2. マロリーはボブのトランザクションを[ピン留め][topic transaction pinning]します。

  3. ボブはピン留めされたことに気づかず、（[RBF][topic rbf]または[CPFP][topic cpfp]により）
     手数料を引き上げます。

  4. ボブの最初のトランザクションはピン留めされているので、ボブの手数料の引き上げは伝播されません。
     ただし、マロリーは何らかの方法でそれを受け取ります。手順3と4が繰り返され、
     ボブの手数料が大幅に引き上げられる可能性があります。

  5. マロリーはボブの最も高い手数料の引き上げをマイニングします。
     このトランザクションは伝播されていないので、他の誰もマイニングしようとしません。
     これにより、マロリーは他のマイナーよりも多くての手数料を獲得できます。

  6. マロリーは置換サイクルを使用して、トランザクションのピンを別のトランザクションに移動し、
     追加の資金を割り当てることなく攻撃を繰り返すことができるため（おそらく異なる被害者に対して）、
     攻撃を経済的に効率的に行うことができます。

  私たちはこの脆弱性を重大なリスクとは判断していません。脆弱性を悪用するには特殊な状況が必要で、
  そのような状況は稀で、ネットワークの状態を誤って判断すると攻撃者が資金を失う可能性があります。
  攻撃者がこの脆弱性を定期的に悪用した場合、[ブロック監視ツール][miningpool.observer]を構築、
  使用するコミュニティメンバーによって、その行動は検知されると考えています。

- **<!--updated-stats-on-compact-block-reconstruction-->コンパクトブロックの再構築に関する統計の更新:**
  以前のスレッド（[ニュースレター #315][news315 cb]参照）に続き、
  開発者の0xB10Cは、彼のBitcoin Coreノードが[コンパクトブロック][topic compact block relay]の再構築を実行するために
  追加のトランザクションを要求する必要があった頻度に関する統計の更新をDelving Bitcoinに[投稿しました][b10c cb]。
  ノードがコンパクトブロックを受信すると、そのブロック内のトランザクションの内、
  mempool（またはコンパクトブロックの再構築を支援するための特別な予備である _extrapool_
  ）に含まれていないトランザクションを要求する必要があります。これは、
  ブロックの伝播速度を著しく低下させ、マイナーの集中化を助長します。

  0xB10Cは、mempoolのサイズが大きくなるにつれて、要求の頻度が大幅に増加することを発見しました。
  複数の開発者が、考えられる原因について議論し、最初のデータでは、
  欠落しているトランザクションはオーファン（親が不明な子トランザクション）であることが示されました。
  Bitcoin Coreは、親が短時間に到着する場合に備えて、そのトランザクションを一時的に保存しています。
  最近Bitcoin Coreにマージされた（[ニュースレター #338][news338 orphan]参照）、
  オーファントランザクションの親の追跡と要求の改善によって、この状況を改善できる可能性があります。

  開発者は、他の可能な解決策についても議論しました。攻撃者はオーファントランザクションを無料で作成できるため、
  ノードがオーファントランザクションを長期間保持することは合理的ではありませんが、
  より多くのオーファントランザクションおよびその他の排除されたトランザクションをextrapoolに長期間保持することは可能かもしれません。
  この記事の執筆時点では、議論の結論は出ていません。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [PSBTv2 (BIP370)を使用している、使用したい人はいますか？]({{bse}}125384)
  Bitcoin-Devメーリングリストへの投稿（[ニュースレター #338][news338 psbtv2]参照）に加えて、
  Sjors Provoostは、[PSBTv2][topic psbt]のユーザーと潜在的なユーザーを募集するため、
  Bitcoin Stack Exchangeに投稿しました。[BIP370][]に関心のあるOptechの読者は、
  質問やメーリングリストの投稿に返信してください。

- [Bitcoinのジェネシスブロックでは、どの部分を任意に埋めることができますか？]({{bse}}125274)
  Pieter Wuilleは、[ジェネシスブロック][mempool genesis block]のどのフィールドも
  通常のブロック検証ルールの対象になっていないことを指摘し、
  「文字通り、すべてのフィールドがどのような内容であってもおかしくない。可能な限り通常のブロックのように見えるが、
  その必要はなかった」と述べています。

- [<!--lightning-force-close-detection-->ライトニングの強制閉鎖の検知]({{bse}}122504)
  Sanket1729とAntoine Poinsotは、[ブロックエクスプローラ][topic block explorers]mempool.spaceが、
  [`nLockTime`][topic timelocks]と`nSequence`フィールドを使用して
  ライトニングの強制閉鎖トランザクションであるかどうかを判断する方法について議論しています。

- [すべてのインプットが非witness programタイプであるsegwit形式のトランザクションは有効ですか？]({{bse}}125240)
  Pieter Wuilleは、segwitのコンセンサスの変更とwtxidの計算に関する構造と有効性を定義している[BIP141][]と
  segwitトランザクションの通信用のシリアライゼーションフォーマットを定義している[BIP144][]を区別しています。

- [P2TRセキュリティの質問]({{bse}}125334)
  Pieter Wuilleは、[Taproot][topic taproot]について定義している[BIP341][]から引用して、
  公開鍵が直接アウトプットに含まれる理由と、量子コンピューティングに関連する考慮事項を説明しています。

- [<!--what-exactly-is-being-done-today-to-make-bitcoin-quantum-safe-->Bitcoinを量子安全にするために現在何が行われていますか？]({{bse}}125171)
  Murchは、量子コンピューターの現状、最近の[ポスト量子署名スキーム][topic quantum resistance]、
  そして提案中の[QuBit - Pay to Quantum Resistant Hash][BIPs #1670] BIPについてコメントしています。

- [<!--what-are-the-harmful-effects-of-a-shorter-inter-block-time-->ブロック間の時間を短縮する弊害は何ですか？]({{bse}}125318)
  Pieter Wuilleは、 ブロック伝播時間の結果として、ブロックを発見したばかりのマイナーにもたらされる利点、
  その利点がブロック時間の短縮時によってどのように拡大されるか、およびその利点の潜在的な効果について強調しています。

- [proof-of-workをポリシールールの代わりに使用できますか？]({{bse}}124931)
  Jgmontoyaは、proof-of-workを非標準トランザクションに添付することで、
  mempoolポリシーと同様の[ノードリソース保護][policy series]の目標を達成できるのではないかと考えています。
  Antoine Poinsotは、ブロックテンプレートの効率的な構築、一部のトランザクションタイプの抑制、
  [ソフトフォーク][topic soft fork activation]のアップグレードフックの保護など、
  ノードリソースの保護以外にも、mempoolポリシーの目標があることを指摘しています。

- [実際のBitcoinのシナリオにおいてMuSigはどのように機能しますか？]({{bse}}125030)
  Pieter Wuilleは、[MuSig][topic musig]のバージョン間の違いについて詳しく説明し、
  MuSig1のIAS（Interactive Aggregated Signature）版と
  [CISA（cross-input signature aggregation）][topic cisa]との相互作用について言及し、
  仕様に関する低レベルの質問の答える前に[閾値署名][topic threshold signature]について言及しています。

- [blocks.datファイルを難読化する-blocksxorスイッチはどのように機能しますか？]({{bse}}125055)
  Vojtěch Strnadは、ディスク上のBitcoin Coreのブロックデータファイルを難読化する（[ニュースレター #316][news316 xor]参照）
  `-blocksxor`オプションについて説明しています。

- [Schnorr署名に対する関連鍵攻撃はどのように機能しますか？]({{bse}}125328)
  Pieter Wuilleは、「攻撃は、被害者が関連鍵を選択し、攻撃者がその関係を知っている場合に適用される」と答えており、
  関連鍵は極めて一般的であると述べています。

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [LDK v0.1.1][]は、LN対応アプリケーションを構築するための人気のライブラリのセキュリティリリースです。
  少なくともチャネル資金の1%を犠牲にすることを厭わない攻撃者は、
  被害者を騙して他の無関係なチャネルを閉鎖させることができ、その結果、
  被害者はトランザクション手数料に不必要にお金を使用することになる可能性があります。
  この脆弱性を発見したMatt Morehouseは、この脆弱性についてDelving
  Bitcoinに[投稿しています][morehouse ldk-dos]。Optechは、
  来週のニュースレターで、より詳細な要約を提供する予定です。このリリースには、
  APIの更新とバグ修正も含まれています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #31376][]は、[タイムワープ][topic time warp]バグを悪用したブロックテンプレートを
  マイナーが作成できないようにするチェックを[testnet4][topic testnet]だけではなく、
  すべてのネットワークに適用するよう拡張します。この変更は、
  タイムワープバグを恒久的に修正する可能性のある将来のソフトフォークに備えたものです。

- [Bitcoin Core #31583][]は、`getmininginfo`、`getblock`、`getblockheader`、
  `getblockchaininfo`、`getchainstates` RPCコマンドを更新し、
  `nBits`フィールド（ブロックの難易度ターゲットのコンパクトな表現）と`target`フィールドを返すようにしました。
  さらに、`getmininginfo`は、次のブロックの高さ、`nBits`、難易度およびターゲットを指定する`next`オブジェクトを追加します。
  ターゲットを導出および取得するために、このPRでは、`DeriveTarget()`および`GetTarget()`ヘルパー関数を導入しています。
  これらの変更は、[Stratum V2][topic pooled mining]の実装に役立ちます。

- [Bitcoin Core #31590][]は、`GetPrivKey()`メソッドをリファクタリングし、
  [ディスクリプター][topic descriptors]内の[x-only公開鍵][topic x-only public keys]の秘密鍵を取得する際に、
  両方のパリティビット値について公開鍵をチェックするようにしました。
  これまでは、格納されている公開鍵に正しいパリティビットがない場合、秘密鍵を取得できず、
  トランザクションに署名できませんでした。

- [Eclair #2982][]は、`lock-utxos-during-funding`設定を導入し、
  [Liquidity Ads][topic liquidity advertisements]の販売者が、
  誠実なユーザーがUTXOを長期間使用できないようにする流動性の嫌がらせを行う攻撃の一種を緩和できるようになりました。
  デフォルトの設定はtrueで、UTXOはファンディングプロセス中にロックされ、悪用される可能性があります。
  falseに設定すると、UTXOのロックが無効になり、攻撃を完全に防止できますが、誠実なピアに悪影響を与える可能性があります。
  このPRでは、ピアが応答しなくなった場合に着信チャネルを自動的に中止する、
  設定可能なタイムアウトの仕組みも追加されています。

- [BDK #1614][]では、承認済みのトランザクションをダウンロードするために
  [BIP158][]で定義されている[コンパクトブロックフィルター][topic compact block filters]を使用するためのサポートが追加されました。
  これは、`bdk_bitcoind_rpc`クレートにBIP158モジュールを追加し、
  scriptPubkeyのリストに関係するトランザクションを含むブロックを入手するために使用できる新しい
  `FilterIter`型を追加することで実現されます。

- [BOLTs #1110][]では、[ピアストレージ][topic peer storage]プロトコルの仕様がマージされ、
  ノードは要求したピアのために64kBまでの暗号化されたブロブを保存し、このサービスに課金できるようになります。
  これはすでにCore Lightning（ニュースレター[#238][news238 peer]参照）と
  Eclair（ニュースレター[#335][news335 peer]参照）に実装されています。

{% include snippets/recap-ad.md when="2025-02-04 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31376,31583,31590,2982,1614,1110,1670" %}
[morehouse ldkclaim]: https://delvingbitcoin.org/t/disclosure-ldk-invalid-claims-liquidity-griefing/1400
[news335 ldk3340]: /ja/newsletters/2025/01/03/#ldk-3340
[riard minecycle]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CALZpt+EnDUtfty3X=u2-2c5Q53Guc6aRdx0Z4D75D50ZXjsu2A@mail.gmail.com/
[miningpool.observer]: https://miningpool.observer/template-and-block
[b10c cb]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/5
[news315 cb]: /ja/newsletters/2024/08/09/#statistics-on-compact-block-reconstruction
[news338 orphan]: /ja/newsletters/2025/01/24/#bitcoin-core-31397
[news274 cycle]: /ja/newsletters/2023/10/25/#htlc
[ldk v0.1.1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.1
[morehouse ldk-dos]: https://delvingbitcoin.org/t/disclosure-ldk-duplicate-htlc-force-close-griefing/1410
[news281 griefing]: /ja/newsletters/2023/12/13/#discussion-about-griefing-liquidity-ads
[news238 peer]: /ja/newsletters/2023/02/15/#core-lightning-5361
[news335 peer]: /ja/newsletters/2025/01/03/#eclair-2888
[news338 psbtv2]: /ja/newsletters/2025/01/24/#psbtv2
[mempool genesis block]: https://mempool.space/block/000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f
[policy series]: /ja/blog/waiting-for-confirmation/#ノードリソースの保護に関するポリシー
[news316 xor]: /ja/newsletters/2024/08/16/#bitcoin-core-28052