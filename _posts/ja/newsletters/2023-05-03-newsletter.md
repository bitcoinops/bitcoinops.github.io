---
title: 'Bitcoin Optech Newsletter #249'
permalink: /ja/newsletters/2023/05/03/
name: 2023-05-03-newsletter-ja
slug: 2023-05-03-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、`OP_VAULT`の提案を再実装するために柔軟なCovenantの設計を使用する分析と、
署名アダプターのセキュリティに関する投稿、一部の読者にとって特に興味深いと思われる求人情報を掲載しています。
また、新しいリリースとリリース候補、人気のあるBitcoinインフラストラクチャソフトウェアの注目すべき変更など
恒例のセクションも掲載しています。

## ニュース

- **MATTベースのVault:** Salvatore Ingalaは、
  最近のOP_VAULTの提案（[ニュースレター #234][news234 op_vault]参照）と同様の動作をする
  [Vault][topic vaults]のラフな実装をBitcoin-Devメーリングリストに[投稿][ingala vaults]しました。
  ただしこれは、IngalaのMATT（Merklize All The Things）の提案（[ニュースレター #226][news226 matt]参照）に
  基づいたものです。MATTは、いくつかの非常にシンプルな[Covenant][topic covenants] opcodeをソフトフォークで追加することで、
  Bitcoin上で非常に柔軟なコントラクトを作成できるようにします。

  今週の投稿でIngalaは、MATTは非常に柔軟であるだけでなく、
  いくつかの日常的に使用される可能性のあるトランザクションテンプレートで効率的かつ簡単に使用できることを実証しようとしました。
  これは最近の`OP_VAULT`の提案で行われているように、
  Ingalaは、[BIP119][]の[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]（CTV）の提案を基に構築しています。
  さらに2つの追加opcodeを使用して（必要なすべてを完全にカバーしているわけではないことを認めながら）、
  `OP_VAULT`とほぼ同等の機能セットを提供しています。
  唯一の注目すべき欠点は、「まったく同じVaultに送り返される追加のアウトプットを追加するオプション」です。

  この記事を書いている時点では、Ingalaの投稿には直接の返信はありませんでしたが、
  MATTに対する彼の当初の提案と、（基本的に）任意の複雑なプログラムが実行されたことを検証できる機能については、
  [引き続き議論][halseth matt]が行われています。

- **<!--analysis-of-signature-adaptor-security-->署名アダプターのセキュリティ分析:** Adam Gibsonは、
  [署名アダプター][topic adaptor signatures]のセキュリティの分析、
  特に複数の参加者がトラストレスにアダプターを作成する必要がある[MuSig][topic musig]のような
  [マルチシグ][topic multisignature]プロトコルとどのように相互作用するかについて、
  Bitcoin-Devメーリングリストに[投稿][gibson adaptors]しました。
  署名アダプターは、効率とプライバシーを向上させるために[PTLC][topic ptlc]を使用するよう
  近い将来アップグレードされるLNで使用される予定です。
  また、効率とプライバシーまたはその両方を向上させるために、他の多くのプロトコルでも使用されることが想定されています。
  PTLCは、新しくアップグレードされたBitcoinプロトコルの最も強力な構成要素の１つであるため、
  そのセキュリティ特性を慎重に分析することは、正しく使用されることを保証するために不可欠です。
  Gibsonは、Lloyd Fournierらのこれまでの分析（[ニュースレター #129][news129 adaptors]参照）をベースにしつつ、
  さらなる分析が必要な領域を指摘し、自身の寄稿に対するレビューを求めています。

- **<!--job-opportunity-for-project-champions-->プロジェクトチャンピオンの求人:** Spiralの助成団体のSteve Leeは、
  Bitcoinの長期的なスケーラビリティ、セキュリティ、プライバシー、柔軟性を大幅に向上させる
  クロスチームプロジェクトのチャンピオンとして、経験豊富なBitcoinコントリビューターに応募してほしいという要望を
  Bitcoin-Devメーリングリストに[投稿][lee hiring]しました。
  詳しくは、彼の投稿を参照してください。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [LND v0.16.2-beta][]は、このLN実装のマイナーリリースで、
  「前のマイナーリリースで導入されたパフォーマンスのリグレッション」に対するいくつかのバグ修正が含まれています。

- [Core Lightning 23.05rc2][]は、このLN実装の次期バージョンのリリース候補です。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]および
[Bitcoin Inquisition][bitcoin inquisition repo]の注目すべき変更点。*

- [Bitcoin Core #25158][]は、`gettransaction`RPCおよび、`listtransactions`RPC、
  `listsinceblock`RPCのトランザクション詳細のレスポンスに、
  どのトランザクションが[abandoned][abandontransaction rpc]とマークされたかを示す
  `abandoned`フィールドを追加しました。

- [Bitcoin Core #26933][]では、パッケージとして評価される場合でも、mempoolに受け入れられるために、
  各トランザクションがノードの最小リレー手数料率（`-minrelaytxfee`）を満たすという要件を再導入しました。
  パッケージの検証では、動的なmempoolの最小手数料率よりも低いトランザクションの手数料の引き上げが可能です。
  このポリシーが再導入されたのは、置き換えの際に手数料ゼロのトランザクションが手数料を引き上げる子孫を失うリスクを回避するためです。
  v3のようなパッケージトポロジーの制限や、mempoolの排除プロセスの修正など、
  このようなトランザクションを防止するDoS耐性のある方法が見つかった場合、将来的に元に戻される可能性があります。

- [Bitcoin Core #25325][]では、UTXOキャッシュにプールベースのメモリリソースを導入しました。
  この新しいデータ構造は、各UTXOに大して個別にメモリを割り当てたり開放したりする代わりに、
  UTXOを追跡するためのより大きなメモリプールを事前に割り当てて管理します。
  UTXOのルックアップは、特にIBD中のメモリアクセスの大部分を占めています。
  ベンチマークによると、より効率的なメモリ管理により、インデックスの再作成が20%以上高速化されています。

- [Bitcoin Core #25939][]では、トランザクションインデックスのオプションを有効にしたノードが、
  `utxoupdatepsbt` RPCを使用して[PSBT][topic psbt]を更新する際に、ノードがそのインデックスを検索し、
  使用するトランザクションアウトプットに関する情報をPSBTに追加することができるようになりました。
  このRPCが2019年に最初に実装されたとき（[ニュースレター #34][news34 psbt]参照）、
  ネットワーク上ではレガシーアウトプットとsegwit v0アウトプットの2種類のアウトプットが一般的でした。
  PSBTの各レガシーアウトプットの支払いには、署名者がそのアウトプットの量を検証できるように、
  そのアウトプットを含むトランザクションの完全なコピーを含める必要があります。
  使用されるアウトプットの量を検証せずに支払いをすると、
  支払人がトランザクション手数料を大幅に過払いする可能性があるため、検証は重要です。

  一方、各segwit v0アウトプットの支払いは、PSBTが前のトランザクション全体ではなく、
  アウトプットのscriptPubKeyと量のみを含めることができるように、量にコミットします。
  これによりトランザクション全体を含める必要がなくなると考えられていました。
  承認されたトランザクションの未使用のトランザクションアウトプットは、
  すべてBitcoin CoreのUTXOセットに保存されているため、`utxoupdatepsbt` RPCは、
  UTXOを使用する任意のPSBTに必要なscriptPubKeyと量のデータを追加することができます。
  また`utxoupdatepsbt`は、以前にローカルノードのmempoolを検索してUTXOを探し、
  ユーザーが未承認のトランザクションのアウトプットを使用できるようにしました。

  しかし、`utxoupdatepsbt`がBitcoin Coreに追加された後、
  いくつかのハードウェア署名デバイスは、ユーザーが同じトランザクションに2回署名したように見せることにより生じる
  手数料の過払いを防ぐために、segwit v0アウトプットの使用でも完全なトランザクションを含めることを要求するようになりました
  （[ニュースレター #101][news101 overpayment]参照）。
  そのため、PSBTに完全なトランザクションを含める必要性が高まりました。

  このマージされたPRでは、トランザクションインデックス（有効な場合）とローカルノードのmempoolから完全なトランザクションを検索し、
  必要に応じてPSBTに含めます。完全なトランザクションが見つからない場合は、
  UTXOセットがsegwitアウトプットの支払いに使用されます。Taproot（segwit v1）は、
  少なくとも1つのTaprootアウトプットを使用するほとんどのトランザクションで過払いの懸念が解消されるため、
  今後のハードウェア署名デバイスの更新では、その場合に完全なトランザクションが必要なくなることが予想されます。

- [LDK #2222][]では、チャネルがUTXOに対応していることを検証することなく、
  そのチャネルの関係ノードからゴシップされたメッセージを使用して、チャネルに関する情報を更新できるようになりました。
  LNのゴシップメッセージは、サービス拒否（DoS）攻撃を防ぐためのLNの設計の1つの方法として、
  証明済みのUTXOを持つチャネルに属している場合にのみ受け入れるべきですが、
  一部のLNノードはUTXOを検索する機能を持たず、DoS攻撃を防ぐための他の方法を持つ場合があります。
  このマージされたPRにより、UTXOデータのソースがない場合でも、情報を利用しやすくなります。

- [LDK #2208][]では、強制クローズしたチャネルの未解決の[HTLC][topic htlc]のトランザクションの
  再ブロードキャストと手数料の引き上げを追加しました。
  これは、いくつかの[Pinning攻撃][topic transaction pinning]への対処と信頼性の確保に役立ちます。
  LNDが独自の再ブロードキャストインターフェースを追加した[ニュースレター #243][news243 rebroadcast]や、
  CLNが独自のロジックを改善した[先週のニュースレター][news247 rebroadcast]も参照ください。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25158,26933,25325,2222,2208,25939" %}
[Core Lightning 23.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc2
[lnd v0.16.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.2-beta
[news101 overpayment]: /en/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[news129 adaptors]: /en/newsletters/2020/12/23/#ptlcs
[news243 rebroadcast]: /ja/newsletters/2023/03/22/#lnd-7448
[news247 rebroadcast]: /ja/newsletters/2023/04/19/#core-lightning-6120
[ingala vaults]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021588.html
[news226 matt]: /ja/newsletters/2022/11/16/#covenant-bitcoin
[news234 op_vault]: /ja/newsletters/2023/01/18/#vault-opcode
[halseth matt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021593.html
[gibson adaptors]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021594.html
[lee hiring]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021589.html
[news34 psbt]: /en/newsletters/2019/02/19/#bitcoin-core-13932
[abandontransaction rpc]: https://developer.bitcoin.org/reference/rpc/abandontransaction.html
