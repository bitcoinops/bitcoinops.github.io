---
title: 'Bitcoin Optech Newsletter #341'
permalink: /ja/newsletters/2025/02/14/
name: 2025-02-14-newsletter-ja
slug: 2025-02-14-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、確率的な支払いに関する継続的な議論の要約と、
LNのエフェメラルアンカースクリプトに関する新しい意見、Bitcoin Coreのオーファンプールからの排除に関する統計、
BIPプロセスの改訂に関するドラフトの更新について掲載しています。また、Bitcoin Core PR Review Clubの要約や、
新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも含まれています。

## ニュース

- **<!--continued-discussion-about-probabilistic-payments-->確率的な支払いに関する議論の続き:**
  先週、Oleksandr Kurbatovが Delving Bitcoinに`OP_RAND` opcodeのエミュレートについて[投稿した][kurbatov pp]（
  [ニュースレター #340][news340 pp]参照）のを受け、いくつかの議論が始まりました:

  - _トリムされたHTLCの代替としての適合性:_ Dave Hardingは、
    Kurbatovの方法が、現在[経済的な合理性のない][topic uneconomical outputs]
    [HTLC][topic htlc]をルーティングするために[LN-Penalty][topic ln-penalty]や
    [LN-Symmetry][topic eltoo]のペイメントチャネル内で使用するのに適しているかどうかを[尋ねました][harding pp]。
    今は、保留中にチャネルが強制閉鎖されるとその金額が失われる[トリムされたHTLC][topic trimmed htlc]が使用されています。
    Anthony Townsは、HTLCの解決に使用される対応する役割と逆であるため、
    既存のプロトコルの役割では[機能しないと考えました][towns pp1]。
    しかし、彼はプロトコルに手を加えることで、HTLCと整合させることができるかもしれないと考えました。

  - _必要なセットアップ手順:_ Townsは、
    最初に公開されたプロトコルには手順が1つ欠けていることを[発見しました][towns pp1]。
    Kurbatovも同意しました。

  - _より単純なゼロ知識証明:_ Adam Gibsonは、
    ハッシュされた公開鍵ではなく、[Schnorr][topic schnorr signatures]と
    [Taproot][topic taproot]を使用することで、必要なゼロ知識証明の構築と検証を大幅に簡素化し、
    スピードアップできるかもしれないと[提案しました][gibson pp1]。Townsは、
    暫定的なアプローチを[提案し][towns pp2]、[Gibson][gibson pp2]はそれを分析しました。

  この記事の執筆時点で、議論は続いていました。

- **LNのエフェメラルアンカースクリプトに関する議論の続き:** Matt Morehouseは、
  LNが将来のチャネルでどの[エフェメラルアンカー][topic ephemeral anchors]スクリプトを使用すべきかについてのスレッド（
  [ニュースレター #340][news340 eanchor]参照）に[返信しました][morehouse eanchor]。
  彼は、[P2A][topic ephemeral anchors]アウトプットを使用したトランザクションにおける
  第三者の手数料の荒らし行為について懸念を表明しました。

  Anthony Townsは、チャネルが時間どおりに閉じられなかったり、適切な状態で閉じられなかったりすると、
  相手方が資金を盗む立場になる可能性が高いため、相手方の荒らし行為の方が大きな懸念事項であると[指摘しました][towns eanchor]。
  トランザクションを遅らせたり、手数料率を適度に引き上げようとする第三者は、
  直接利益を得る手段がない中、資金をいくらか失う可能性があります。

  Greg Sandersは、確率的に考えることを[提案しました][sanders eanchor]。
  第三者の荒らし行為が最悪の場合、トランザクションのコストが50%増加するとして、
  荒らし行為に耐性のある方法を使用すると約10%余分にコストがかかる場合、
  5回に1回強制閉鎖するよりも頻繁に第三者の荒らし行為を受けると本当に予想できますか？
  特に、第三者の荒らし行為は資金を失う可能性があり、金銭的な利益を得られないとしたらどうですか？

- **<!--stats-on-orphan-evictions-->オーファンの排除に関する統計:**
  開発者の0xB10Cは、彼のノードでオーファンプールから排除されたトランザクション数に関する統計を
  Delving Bitcoinに[投稿しました][b10c orphan]。オーファントランザクションは、
  ノードがまだそのすべての親トランザクションを持っていない未承認のトランザクションで、
  親トランザクションがなければブロックに含めることができません。Bitcoin Coreでは、
  デフォルトで最大100個までオーファントランザクションを保持します。
  プールがいっぱいになった後に新しいオーファントランザクションが到着すると、
  以前受信したオーファントランザクションが排除されます。

  0xB10Cは、ある日、1,000万を超えるオーファントランザクションが彼のノードから排除され、
  ピーク時には1分間に10万件を超える排除率があったことを発見しました。調査の結果、
  「このうち99%以上が、この[トランザクション][runestone tx]と類似しており、
  Runestoneの発行（カラードコイン（NFT）プロトコル）に関連している」ことをが分かりました。
  同じオーファントランザクションが多数繰り返し要求され、しばらくしてランダムに排除され、
  また要求されているようでした。

- **BIPプロセスの更新の提案:**
  Mark "Murch" Erhardtは、提案されているBIPプロセスの改訂のドラフトBIPに識別子BIP3が割り当てられ、
  追加のレビューの準備が整ったことの発表をBitcoin-Devメーリングリストに[投稿しました][erhardt bip3]。
  これは、マージされアクティベートされる前の最後のレビューラウンドになる可能性があります。
  意見のある方は、[プルリクエスト][bips #1712]にフィードバックを残すことをお勧めします。

## Bitcoin Core PR Review Club

*この毎月のセクションでは、最近の[Bitcoin Core PR Review Club][]ミーティングを要約し、
重要な質問と回答のいくつかに焦点を当てます。
以下の質問をクリックしてミーティングでの回答の要約を確認してください。*

[Cluster mempool: introduce TxGraph][review club 31363]は、[sipa][gh sipa]によるPRで、
`TxGraph`クラスを導入するものです。このクラスは、
すべてのmempoolトランザクション間の（実効）手数料、サイズ、依存関係に関する知識をカプセル化します。
これは、[クラスターmempool][topic cluster mempool]プロジェクトの一部であり、
ミューテーション、インスペクターおよびステージング関数を通じて、
mempoolグラフとの対話を可能にする包括的なインターフェイスを提供します。

特に、`TxGraph`には`CTransaction`、インプット、アウトプット、txid、wtxid、優先順位、
有効性、ポリシールールなどに関する知識はありません。これにより、
クラスの動作を（ほぼ）完全に指定することが容易になり、
PRに含まれているシミュレーションベースのテストが可能になります。

{% include functions/details-list.md
  q0="mempoolグラフとは何ですか？masterのmempoolコードにはどの程度存在しますか？"
  a0="masterでは、mempoolグラフはノードとして`CTxMemPoolEntry`オブジェクトのセットとして暗黙的に存在し、
  それらの祖先/子孫の関係は`GetMemPoolParents()`および`GetMemPoolChildren()`で再帰的にたどることができます。"
  a0link="https://bitcoincore.reviews/31363#l-26"

  q1="`TxGraph`を持つことの利点は何ですか？欠点はありますか？"
  a1="利点は次のとおりです: 1) `TxGraph`は、[クラスターmempool][topic cluster mempool]の実装を可能にし、
  そのすべての利点をもたらします。2) mempoolコードをより効率的なデータ構造でカプセル化できます。3)
  置換を二重カウントしないなどのトポロジーの詳細を抽象化することで、
  mempoolのインターフェースと推論が容易になります。
  <br><br>欠点は次のとおりです: 1) 導入された大きな変更に関連する多大なレビューとテストの労力。2)
  たとえばTRUCや他のポリシーに関連するような、トランザクション毎のトポロジー制限を
  どのように検証で指示できるかが制限されます。3) `TxGraph::Ref*`ポインタとの間の変換に起因する、
  ごくわずかなランタイムパフォーマンスのオーバーヘッド。"
  a1link="https://bitcoincore.reviews/31363#l-54"

  q2="`TxGraph`内で、個々のトランザクションはいくつの`Clusters`に属することができますか？"
  a2="トランザクションは概念的には1つのクラスターにしか属せませんが、
  答えは2つです。これは`TxGraph`が2つの並列グラフ（「main」とオプションで「ステージング」）をカプセル化できるためです。"
  a2link="https://bitcoincore.reviews/31363#l-116"

  q3="`TxGraph`がオーバーサイズとはどういう意味ですか？mempoolがいっぱいになることと同じですか？"
  a3="`TxGraph`は、その`Cluster`の少なくとも1つが、`MAX_CLUSTER_COUNT_LIMIT`を超えると
  オーバーサイズになります。`TxGraph`は1つ以上の`Cluster`を持つことができるので、
  これはmempoolがいっぱいになることとは異なります。"
  a3link="https://bitcoincore.reviews/31363#l-147"

  q4="<!--if-a-txgraph-is-oversized-which-functions-can-still-be-called-and-which-ones-can-t-->`TxGraph`がオーバーサイズになった場合、どの関数が引き続き呼び出され、どの関数が呼び出されないのでしょうか？"
  a4="オーバーサイズになったクラスターを実際に実体化する必要がある操作や、
  O(n<sup>2</sup>)以上の作業を必要とする関数はオーバーサイズの`Cluster`では使用できません。
  これには、トランザクションの祖先/子孫を計算するような操作が含まれます。
  ミュテーション操作（`AddTransaction()`、`RemoveTransaction()`、`AddDependency()`、
  `SetTransactionFee()`）や`Trim()`（おおよそ`O(n log n)`）などの操作はまだ許可されています。"
  a4link="https://bitcoincore.reviews/31363#l-162"
%}

## リリースとリリース候補

_人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。_

- [LND v0.18.5-beta][]は、この人気のLNノード実装のバグ修正リリースです。
  バグ修正は、リリースノートで"important"および"critical"と記載されています。

- [Bitcoin Inquisition 28.1][]は、提案中のソフトフォークやその他の主要なプロトコル変更を
  実験するために設計された、この[signet][topic signet]フルノードのマイナーリリースです。
  Bitcoin Core 28.1に含まれるバグ修正と、[エフェメラルダスト][topic ephemeral anchors]のサポートが含まれています。

## 注目すべきコードとドキュメントの変更

_最近の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。_

- [Bitcoin Core #25832][]では、接続の存続期間、IPおよびネットグループによる再接続頻度、
  ピアの阻止、排除、不良動作などピア接続イベントを監視するための5つの新しいトレースポイントとドキュメントが追加されました。
  Bitcoin Coreユーザーは、提供されているサンプルスクリプトを使用してトレースポイントに接続したり、
  独自のトレーススクリプトを作成したりできます（ニュースレター[#160][news160 ebpf]および[#244][news244 ebpf]参照）。

- [Eclair #2989][]では、ルーターでの[バッチ][topic payment batching]スプライシングのサポートが追加され、
  1回の[スプライシング][topic splicing]トランザクションで使用された複数のチャネルを追跡できるようになりました。
  新しい[チャネルアナウンス][topic channel announcements]をそれぞれのチャネルに決定論的にマッピングできないため、
  ルーターは最初に見つかった一致するチャネルを更新します。

- [LDK #3440][]は、（上流ノードが保持する）[HTLC][topic htlc]のOnionメッセージに埋め込まれた
  送信者のインボイスリクエストを検証し、支払いを請求するための正しい`PaymentPurpose`を生成することで、
  [非同期支払い][topic async payments]の受信のサポートを完了します。
  受信した非同期支払いに絶対的な有効期限が設定され、ノードのオンラインステータスの無期限の探索が防止され、
  受信ノードがオンラインに戻った時に上流ノードが保持するHTLCをリリースするために必要な通信フローが追加されます。
  非同期支払いフローの完全な実装を完了するには、ノードが非同期受信者に代わってインボイスを提供するLSPとしても機能できる必要があります。

- [LND #9470][]は、`BumpFee`および`BumpForceCloseFee`RPCコマンドに`deadline_delta`パラメーターを追加し、
  特定の予算（これも指定）が完全に手数料の引き上げに割り当てられ、[RBF][topic rbf]が実行されるブロック数を指定します。
  さらに、`conf_target`パラメーターが再定義され、上記のRPCコマンドと非推奨となった`BumpCloseFee`の両方について、
  現在の手数料率を取得するために手数料推定で照会する際のブロック数を指定します。

- [BTCPay Server #6580][]は、[LNURL][topic lnurl]支払いの[BOLT11][]インボイスにおける説明のハッシュの存在と
  正当性を検証するチェックを削除します。この変更は、LNURLドキュメント（LUD）仕様で
  [提案されている廃止][ludpr]と一致しています。この要件は、
  セキュリティ上の利点が最小限である一方、LNURL支払いの実装に大きな課題をもたらすと考えられています。
  説明用のハッシュパラメーターフィールドはCore-Lightningで実装されています（ニュースレター
  [#194][news194 deschash]および[#232][news232 deschash]参照）。

## 訂正

先週のニュースレターの[脚注][fn sigops]で、誤って次のように書きました。
「P2SHと提案されているインプットのsigopカウントでは、16個以上の公開鍵を持つOP_CHECKMULTISIGは、
20 sigopsとカウントされるので」これは単純化しすぎでした。実際のルールについては、
今週のAnthony Townsの[投稿][towns sigops]をご覧ください。

{% include snippets/recap-ad.md when="2025-02-18 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="25832,2989,3440,9470,6580,1712" %}
[lnd v0.18.5-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.5-beta
[Bitcoin Inquisition 28.1]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v28.1-inq
[news340 pp]: /ja/newsletters/2025/02/07/#op-rand
[towns sigops]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/69
[kurbatov pp]: https://delvingbitcoin.org/t/emulating-op-rand/1409
[harding pp]: https://delvingbitcoin.org/t/emulating-op-rand/1409/2
[towns pp1]: https://delvingbitcoin.org/t/emulating-op-rand/1409/3
[gibson pp1]: https://delvingbitcoin.org/t/emulating-op-rand/1409/5
[towns pp2]: https://delvingbitcoin.org/t/emulating-op-rand/1409/6
[gibson pp2]: https://delvingbitcoin.org/t/emulating-op-rand/1409/7
[morehouse eanchor]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/8
[news340 eanchor]: /ja/newsletters/2025/02/07/#tradeoffs-in-ln-ephemeral-anchor-scripts-ln
[towns eanchor]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/9
[sanders eanchor]: https://delvingbitcoin.org/t/which-ephemeral-anchor-script-should-lightning-use/1412/11
[b10c orphan]: https://delvingbitcoin.org/t/stats-on-orphanage-overflows/1421/
[runestone tx]: https://mempool.space/tx/ac8990b04469bad8630eaf2aa51561086d81a241deff6c95d96d27e41fa19f90
[erhardt bip3]: https://mailing-list.bitcoindevs.xyz/bitcoindev/25449597-c5ed-42c5-8ac1-054feec8ad88@murch.one/
[fn sigops]: /ja/newsletters/2025/02/07/#fn:2kmultisig
[review club 31363]: https://bitcoincore.reviews/31363
[gh sipa]: https://github.com/sipa
[news244 ebpf]: /ja/newsletters/2023/03/29/#bitcoin-core-26531
[news160 ebpf]: /ja/newsletters/2021/08/04/#bitcoin-core-22006
[ludpr]: https://github.com/lnurl/luds/pull/234
[news232 deschash]: /ja/newsletters/2023/01/04/#btcpay-server-4411
[news194 deschash]: /ja/newsletters/2022/04/06/#c-lightning-5121
