---
title: 'Bitcoin Optech Newsletter #291'
permalink: /ja/newsletters/2024/02/28/
name: 2024-02-28-newsletter-ja
slug: 2024-02-28-newsletter-ja
type: newsletter
layout: newsletter
lang: ja
---
今週のニュースレターでは、トラストレスなマイナーの先物手数料率のコントラクトの提案と、
デュアルファンディングの流動性を提供するLNノードのコイン選択アルゴリズムのリンク、
`OP_CAT`を使用したVaultのプロトタイプの詳細、LNとZKCPを使用したecashの送受信の議論を掲載しています。
また、Bitcoin Stack Exchangeから人気のある質問とその回答のまとめ、
新しいリリースとリリース候補の発表、人気のあるBitcoinインフラストラクチャプロジェクトの最近の変更など、
恒例のセクションも含まれています。

## ニュース

- **<!--trustless-contract-for-miner-feerate-futures-->マイナーの将来の手数料率に対するトラストレスなコントラクト:**
  ZmnSCPxjは、将来のブロックにトランザクションを含めるために、
  二者が限界手数料率に基づいて条件付きで互いに支払うことを可能にするスクリプトのセットを
  Delving Bitcoinに[投稿しました][zmnscpxj futures]。
  たとえば、アリスはブロック1,000,000（もしくはその付近のブロック）で
  トランザクションが含まれることを期待するユーザーです。
  そしてボブはその頃にブロックをマイングする可能性があるマイナーです。
  両者は、それぞれ資金の一部を以下の3つの方法のいずれかで使用可能なファンディングトランザクションにデポジットします。

  1. ボブは、ブロック1,000,000（またはその付近のブロック）で、
     ファンディングトランザクションのアウトプットを使用して自分のデポジットを取り戻し、アリスのデポジットも請求します。
     彼らが使用するスクリプトは、ボブによる一方的な回収が（2つの典型的な支払いよりも大きいような）特定の最小サイズであること要求します。

  2. あるいは、アリスはブロック1,000,000以降のいつか（たとえば1日後のブロック1,000,144）で、
     ファンディングトランザクションのアウトプットを使用して自分のデポジットを取り戻し、さらにボブのデポジットも請求します。
     アリスのトランザクションは比較的小さなものです。

  3. さらに別の方法として、アリスとボブは協力して、ファンディングトランザクションのアウトプットを好きなように使用できます。
     これには、効率を最大化するため[Taproot][topic taproot]のkeypath支払いを使用します。

  ブロック1,000,000における手数料率が予想よりも低い場合、
  ボブはそのブロック（もしくはその付近のブロック）にサイズが大きな支払いを含めて利益を得ることができます。
  ネットワーク全体の手数料率が低いタイミングで利益を上げることは、マイナーであるボブにとっては特に有利です。
  手数料率が低いということは、彼が生成するブロックからそれほど多くの報酬を得られないことを意味するからです。

  ブロック1,000,000における手数料率が予想よりも高い場合、
  ボブはそのブロック（もしくはその付近のブロック）にサイズの大きな支払いを含めたくないでしょう。
  彼が得る利益よりも手数料が多くかかることになります。
  これにより、アリスはブロック1,000,144（またはそれ以降）に、
  彼女のサイズの小さな支払いを含めることで利益を得ることができます。
  ネットワーク全体の手数料率が高いタイミングで利益を上げることは、
  ブロック1,000,000に含める予定の通常のトランザクションを含めるための高い手数料コストを相殺するため、
  アリスにとって特に有利です。

  さらにアリスとボブの両者が、ボブへの支払いをブロック1,000,000に含めることが有益であると認識した場合、
  ボブへの支払いに協力して、ボブによる一方的なトランザクションよりも小さなサイズのトランザクションを作成できます。
  これにより、ボブにとっては手数料を節約することができ、
  アリスにとってはブロック1,000,000のデータ量が削減され利益を得られます。つまり、
  そのブロックに含める予定だったトランザクションに対して支払わなければならない手数料が少なくなる可能性があります。

  このトピックについて、いくつかの返信がありました。ある返信では、
  このコントラクトはトラストレスなだけでなく（コンセンサスによる強制を好む一般的な理由）、
  取引相手の不正を回避するという興味深い特性があると[指摘されました][harding futures]。
  たとえば、集中型の手数料率の先物市場があった場合、
  ボブと他のマイナーは[帯域外で手数料を受け入れたり][topic out-of-band fees]、
  他のトリックを使用して見かけの手数料を操作したりする可能性があります。
  しかし、ZmnSCPxjの構成では、そのリスクはなくなります。
  サイズの大きな支払いを使用するかどうかについてのボブの選択は、
  現在のマイニングとmempoolの状況に対する彼の視点によって純粋に決定されます。
  返信ではまた、大規模なマイナーの方が小規模なマイナーよりも有利であるかどうかも検討されており、
  Anthony Townsはデフォルトのトランザクション選択アルゴリズムを使用するマイナーにとって、
  コントラクトゲームを行う試みはより大きな利益をもたらすことを示す収益表を[提供しました][towns futures]。

- **<!--coin-selection-for-liquidity-providers-->流動性プロバイダー向けのコイン選択:**
  Richard Myersは、[Liquidity Ads][topic liquidity advertisements]を介して流動性を提供するLNノードに最適化された
  [コイン選択][topic coin selection]アルゴリズムをDelving Bitcoinに[投稿しました][myers cs]。
  彼の投稿では、Bitcoin Coreの[ドラフトPR][bitcoin core #29442]に実装したアルゴリズムについて説明しています。
  アルゴリズムをテストしたところ、「Bitcoin Coreのデフォルトのコイン選択と比較して、
  オンチェーン手数料が15%削減された」ことが分かりました。Myersは、
  このアプローチに対する批判と改善の提案を求めています。

- **`OP_CAT`を使用したシンプルなVaultのプロトタイプ:** 開発者Rijndaelは、
  既存のコンセンサスルールと提案中の[OP_CAT][topic op_cat] opcodeのみに依存する
  [Vault][topic vaults]用に作成したRust言語の概念実証の実装についてDelving Bitcoinに[投稿しました][rijndael vault]。
  このVaultの使用方法の簡単な例：アリスはVaultソフトウェアで作成されたスクリプトを使用してアドレスを生成し、
  そのアドレスへの支払いを受け取ります。その後、
  彼女か彼女の資金を盗もうとする誰かによってその資金の使用がトリガーされます。

  - *<!--legitimate-spend-->正当な使用:* アリスは、
    2つのインプットと2つのアウトプットを持つトリガートランザクションを作成して、資金の使用をトリガーします。
    インプットは、保管された資金の支払いと手数料を追加するインプットです。
    アウトプットは、最初のインプットの正確に同額のステージングアウトプットと、
    最終的な引き出しアドレスに支払う少額のアウトプットです。一定数のブロックが経過した後、
    アリスは2つのインプットと1つのアウトプットを持つトランザクションを作成して引き出しを完了します。
    インプットは、前のトランザクションの最初のトリガーアウトプットと別の手数料支払い用のインプットです。
    アウトプットは引き出しアドレスです。

    最初の支払いでは、`OP_CAT`と以前説明した[Schnorr署名][topic schnorr signatures]を使用したトリックにより（
    [ニュースレター #134][news134 cat]参照）、支払いに使用されるアウトプットと
    作成される対応するアウトプットが同じスクリプトと金額を持つことを検証し、
    トリガートランザクションによってVaultから資金が引き出されないことを保証します。
    2つめのトランザクションは、最初のインプットに特定のブロック数（例：20ブロック）の
    [BIP68][]相対的[タイムロック][topic timelocks]があること、
    アウトプットについては、支払われるのが最初のインプットと同額であること、
    トリガートランザクションの2つめのアウトプットのアドレスと同じアドレスであることを検証します。
    相対的なタイムロックは、コンテスト期間（後述）を提供します。
    正確に同額であることの検証により、許可なく資金が引き出されることがないことが保証されます。
    またアドレスの検証により、泥棒が最後の瞬間に正当な引き出しアドレスを自分のアドレスに変更できないことを保証します（
    私たちの知るすべての事前署名済みVaultの問題、[ニュースレター #59][news59 vaults]参照）。

  - *<!--illegitimate-spend-->不正使用:* マロリーは、上記のようにトリガートランザクションを作成することで、
    支払いをトリガーします。アリスの[ウォッチタワー][topic watchtowers]は、
    コンテキスト期間中（例：20ブロックの遅延）に不正使用が起こったことを認識し、
    2つのインプットと1つのアウトプットを持つRe-Vaultトランザクションを作成します。
    インプットはトリガートランザクションの最初のアウトプットと手数料支払い用のインプットです。
    アウトプットは資金をVaultに戻します。Re-Vaultトランザクションにはアウトプットが1つしかありませんが、
    スクリプトの引き出し条件には、2つのアウトプットを持つトリガートランザクションからの支払いが必要であるため、
    マロリーはアリスの資金を盗むことができません。

    資金は、トリガーされたのと同じVaultスクリプトに返されるため、マロリーは別のトリガートランザクションを作成し、
    アリスに同じサイクルを何度も強制することができ、その結果、マロリーとアリスの両方に手数料コストが発生します。
    Rijndaelのプロジェクトの[拡張ドキュメント][cat vault readme]によると、
    そのような場合は、おそらくアリスが別のスクリプトに資金を送れるようにしたいでしょうし、
    彼の構成の背後にあるアイディアはそれを可能にしますが、簡素化のため現在は実装されていません。

  これらのCATベースのVaultは、コンセンサスの変更なく現在作成可能な事前署名済みのVaultや、
  ソフトフォークでサポートが追加された場合に最もよく知られたVaultの機能セットを提供する
  [BIP345][]スタイルの`OP_VAULT`を用いたVaultと比較することができます。

  <table>
  <tr>
    <th></th>
    <th>事前署名版</th>
    <th markdown="span">

    BIP345 `OP_VAULT`

    </th>
    <th markdown="span">

    `OP_CAT`とSchnorr

    </th>
  </tr>

  <tr>
    <th>有効性</th>
    <td markdown="span">

    **現在利用可能**

    </td>
    <td markdown="span">

    `OP_VAULT`と[OP_CTV][topic op_checktemplateverify]のソフトフォークが必要

    </td>
    <td markdown="span">

    `OP_CAT`のソフトフォークが必要

    </td>
  </tr>

  <tr>
    <th markdown="span">直前のアドレス置換</th>
    <td markdown="span">脆弱</td>
    <td markdown="span">

    **脆弱ではない**

    </td>
    <td markdown="span">

    **脆弱ではない**

    </td>
  </tr>

  <tr>
    <th markdown="span">一部の引き出し</th>
    <td markdown="span">事前に取り決めがある場合のみ可能</td>
    <td markdown="span">

    **可能**

    </td>
    <td markdown="span">不可能</td>
  </tr>

  <tr>
    <th markdown="span">静的で非対話型の計算可能なデポジットアドレス</th>
    <td markdown="span">不可能</td>
    <td markdown="span">

    **可能**

    </td>
    <td markdown="span">

    **可能**

    </td>
  </tr>

  <tr>
    <th markdown="span">手数料節約のためのRe-Vault/隔離のバッチ化</th>
    <td markdown="span">不可能</td>
    <td markdown="span">

    **可能**

    </td>
    <td markdown="span">不可能</td>
  </tr>

  <tr>
    <th markdown="span">最良（つまり正当な使用）の場合の効率（Optechによる非常に大まかな推定）</th>
    <td markdown="span">

    **通常のシングルシグの2倍のサイズ**

    </td>
    <td markdown="span">通常のシングルシグの3倍のサイズ</td>
    <td markdown="span">通常のシングルシグの4倍のサイズ</td>
  </tr>
  </table>

  このプロトタイプは、この記事の執筆時点で、フォーラムで少しの議論と分析を受けています。

- **LNとZKCPを使用したecashの送受信:** Anthony Townsは、
  「[ecash][topic ecash]の匿名性を失うことなく、または追加の信頼を導入することなく、
  ecashの発行をライトニングネットワークにリンクする」ことについてDelving Bitcoinに[投稿しました][towns lnecash]。
  この目標を達成するための彼の提案では、ecashの発行ユーザーに支払いを送信するためのゼロ知識条件付き支払い（[ZKCP][topic acc]）と、
  ecashの資金をLNに引き出すためのハッシュのプリイメージにコミットするプロセスを使用します。

  ecashの実装[Cashu][]のリード開発者であるCalleは、
  いくつかの懸念を示しながらもこのアイディアへの支持、既にCashuに実装されているゼロ知識証明システムへの言及、
  そしてアトミックなecash-to-LNの転送をサポートするために積極的に調査し書いているコードのメモを[返信しました][calle lnecash]。

## Bitcoin Stack Exchangeから選ばれたQ&A

*[Bitcoin Stack Exchange][bitcoin.se]はOptech Contributor達が疑問に対して答えを探しに（もしくは他のユーザーの質問に答える時間がある場合に）アクセスする、
数少ない情報ソースです。この月刊セクションでは、前回アップデート以降にされた、最も票を集めた質問・回答を紹介しています。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-can-t-nodes-have-the-relay-option-to-disallow-certain-transaction-types-->ノードに特定のトランザクションタイプを禁止するリレーオプションがないのはなぜですか？]({{bse}}121734)
  Ava Chowは、[mempoolとリレーポリシー][policy series]の目的、
  [手数料の推定][topic fee estimation]や、[コンパクトブロックリレー][topic compact block relay]を含む
  より均質なmempoolsの利点についての考えを説明し、
  マイナーが[帯域外の手数料][topic out-of-band fees]を受け付けるようなポリシーの回避策についても触れています。

- [<!--what-is-the-circular-dependency-in-signing-a-chain-of-unconfirmed-transactions-->未承認のトランザクションチェーンに署名する際の循環依存関係とは何ですか？]({{bse}}121959)
  Ava Chowは、未承認のレガシーBitcoinトランザクションを使用する場合の
  [循環依存関係][mastering 06 cds]の懸念について説明しています。

- [OceanのTIDES支払いスキームはどのように機能しますか？]({{bse}}120719)
  ユーザーLagrang3は、Oceanマイニングプールで使用されている
  TIDES（Transparent Index of Distinct Extended Shares）マイナー支払いスキームについて説明しています。

- [Bitcoin Coreのウォレットはブロックチェーンの再スキャン中にどのデータを検索していますか？]({{bse}}121563)
  Pieter WuilleとAva Chowは、Bitcoin Coreのウォレットソフトウェアが
  特定のレガシーウォレットまたは[ディスクリプター][topic descriptors]ウォレットに関連するトランザクションをどのように識別するか要約しています。

- [<!--how-does-transaction-rebroadcasting-for-watch-only-wallets-work-->監視専用ウォレットのトランザクションの再ブロードキャストはどのように機能しますか？]({{bse}}121899)
  Ava Chowは、トランザクションの再ブロードキャストロジックはウォレットの種類に関係なく同じであると指摘しています。
  ただし、監視専用ウォレットで開始されたトランザクションが、ノードによる再ブロードキャストの対象になるには、
  トランザクションがある時点でノードのmempoolに届いている必要があります。

## リリースとリリース候補

*人気のBitcoinインフラストラクチャプロジェクトの新しいリリースとリリース候補。
新しいリリースにアップグレードしたり、リリース候補のテストを支援することを検討してください。*

- [Core Lightning 24.02][]は、この人気のLNノードの次期メジャーバージョンのリリースです。
  これには、「緊急リカバリのストレスを軽減する」`recover`プラグインの改善、
  [アンカーチャネル][topic anchor outputs]の改善、ブロックチェーン同期の50%の高速化、
  testnetで発見された大規模トランザクションのパースのバグ修正が含まれています。

## 注目すべきコードとドキュメントの変更

*今週の[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals（BIP）][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo]および[BINANAs][binana repo]の注目すべき変更点。*

- [LDK #2770][]は、[デュアルファンディングチャネル][topic dual funding]のサポートを後で追加する準備を始めています。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2770,29442" %}
[Core Lightning 24.02]: https://github.com/ElementsProject/lightning/releases/tag/v24.02
[myers csliq]: https://delvingbitcoin.org/t/liquidity-provider-utxo-management/600
[news134 cat]: /ja/newsletters/2021/02/03/#bip340-op-cat-op-checksigfromstack
[news59 vaults]: /en/newsletters/2019/08/14/#bitcoin-vaults-without-covenants
[cashu]: https://github.com/cashubtc/nuts
[zmnscpxj futures]: https://delvingbitcoin.org/t/an-onchain-implementation-of-mining-feerate-futures/547
[harding futures]: https://delvingbitcoin.org/t/an-onchain-implementation-of-mining-feerate-futures/547/2
[myers cs]: https://delvingbitcoin.org/t/liquidity-provider-utxo-management/600
[rijndael vault]: https://delvingbitcoin.org/t/basic-vault-prototype-using-op-cat/576
[cat vault readme]: https://github.com/taproot-wizards/purrfect_vault
[towns lnecash]: https://delvingbitcoin.org/t/ecash-and-lightning-via-zkcp/586
[towns futures]: https://delvingbitcoin.org/t/an-onchain-implementation-of-mining-feerate-futures/547/6?u=harding
[calle lnecash]: https://delvingbitcoin.org/t/ecash-and-lightning-via-zkcp/586/2
[policy series]: /ja/blog/waiting-for-confirmation/
[mastering 06 cds]: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch06_transactions.adoc#circular-dependencies
