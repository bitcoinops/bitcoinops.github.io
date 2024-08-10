---
title: 'Bitcoin Optech Newsletter #291'
permalink: /zh/newsletters/2024/02/28/
name: 2024-02-28-newsletter-zh
slug: 2024-02-28-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报介绍了免信任矿工费率期货的拟议合约，链接到提供双向注资流动性的闪电网络节点的选币算法，详细介绍了一个使用 `OP_CAT` 的保管库的原型，并讨论了使用闪电网络和 ZKCP 发送和接收 ecash。此外，还包括我们的常规部分：总结 Bitcoin Stack Exchange 中的热门问题和答案，宣布新版本和候选版本，并介绍热门比特币基础设施项目的最新变化。

## 新闻

- **<!--trustless-contract-for-miner-feerate-futures-->矿工费率期货的免信任合约：** ZmnSCPxj 在 Delving Bitcoin 上[发布][zmnscpxj futures]了一组脚本，允许双方根据在未来区块中包含交易的边际费率有条件地相互支付。例如，Alice 是一个用户，他希望在 1,000,000 区块（或其后不久的一个区块）中包含一笔交易。Bob 是一名矿工，他有一定几率在那段时间挖出一个区块。他们各自将部分资金存入一笔_注资交易_中，可以通过以下三种方式之一使用这笔资金：

  1. Bob 通过在区块 1,000,000 （或其后不久的一个区块）中花费注资交易的输出，取回自己的存款，并索要 Alice 的存款。他们使用的脚本要求 Bob 的单边花费必须达到一定的最小规模，比如大于两个典型的花费。

  2. 或者，Alice 在区块 1,000,000 之后的某个时候（例如，一天后的区块 1,000,144）通过花费注资交易的输出来取回自己的存款，并领走 Bob 存入的资金。Alice 的交易体积相对较小。

  3. 另一种选择是，Alice 和 Bob 可以合作，按照他们愿意的各种方式来花费注资交易的输出。这种方法使用 [taproot][topic taproot] 的 keypath 花费，以实现最高效率。

  如果区块 1,000,000 的费率低于预期，Bob 就可以在该区块（或其后不久的另一个区块）中加入他的较大的花费，并从中获利。在全网费率较低时获利，对作为矿工的 Bob 尤为有利，因为费率低意味着他从自己生产的任何区块中赚取的奖励都不会太多。

  如果区块 1,000,000 的手续费比预期的高，Bob 就不想把他的大体积交易包含在一个区块中——因为比起从中能获得的利润，这将花费更多的手续费。这样，Alice 就可以在区块 1,000,144 中（或稍后）加入较小的花费，从而获利。在全网手续费高涨的时候获利，对 Alice 尤为有利，因为这补偿了她计划在区块 1,000,000 中包含常规交易的高额手续费成本。

  此外，如果 Alice 和 Bob 都意识到，将自己的花费包含在区块 1,000,000 中会让 Bob 有利可图，他们可以合作付款给 Bob，创建一个比 Bob 单边版本更小的交易。这对 Bob 有利，因为可以为他节省手续费；对 Alice 也有利，因为可以减少区块 1,000,000 中的数据量，意味着 Alice 可能要为她计划包含在该区块中的交易支付更少的手续费。

  有几个人回复了这个话题。其中一条回复[指出][harding futures]，该合约有一个有趣的特性，那就是不仅不需要信任（这是人们倾向于选择共识强制合约的一个常见原因），而且还能避免腐化交易对手。举例来说，如果有一个集中化的手续费期货市场，Bob 和其他矿工可能会[接受协议外手续费][topic out-of-band fees]，或使用其他技巧来操纵表面上的手续费；但是，有了 ZmnSCPxj 的构造，这就没有风险了：Bob 对是否使用大额花费的选择完全取决于他对当前挖矿和交易池条件的看法。Anthony Towns 还[提供][towns futures]了一个回报表，显示试图对合约耍花样会让使用默认的交易选择算法的矿工获得更大的利润。

- **<!--coin-selection-for-liquidity-providers-->流动性提供者的钱币选择：** Richard Myers 在 Delving Bitcoin 上[发帖][myers cs]，讲述了如何创建一种针对通过[流动性广告][topic liquidity advertisements]来提供流动性的闪电网络节点进行优化的[选币][topic coin selection]算法。他在帖子中描述了他在 Bitcoin Core 的 [PR 草案][bitcoin core #29442]中实现的算法。在测试该算法时，他发现 “与 [Bitcoin Core] 的默认选币相比，链上手续费减少了15%”。Myers 在寻求对这种方法的评论和改进建议。

- **<!--simple-vault-prototype-using-op-cat-->使用 `OP_CAT` 的简单保管库原型：** 开发者 Rijndael 在 Delving Bitcoin 上[发布][rijndael vault]了他为一个[保管库][topic vaults]编写的 Rust 语言概念验证实现，该保管库只依赖于在当前的共识规则上加入提议的 [OP_CAT][topic op_cat] 操作码。举个简单的例子，说明如何使用这个保管库：Alice 使用保管库软件创建的脚本生成一个地址，并收到一笔支付到该地址的款项。此后，由 Alice 或试图窃取其资金的人触发这笔款项的花费。

  - *<!--legitimate-spend-->合法花费：* Alice 通过创建一个有两个输入和两个输出的扳机交易（trigger transaction）来触发花费；两个输入是对保管金额的花费和添加手续费的输入；两个输出是第一个输入的确切金额的分期输出和一个付给最终取款地址的小额输出。经过一定数量的区块后，Alice 通过创建一个有两个输入和一个输出的交易完成取款；输入是之前的第一个扳机输出加上另一个支付手续费的输入；输出是取款地址。

    在第一笔支出中，`OP_CAT` 加上之前描述过的使用 [schnorr 签名][topic schnorr signatures]的技巧（见[周报 #134][news134 cat]）验证正在花费的输出与正在创建的相应输出具有相同的脚本和金额，确保扳机交易不会从金库中提取资金。第二笔交易验证其第一笔输入具有一定数量区块（如 20 个区块）的 [BIP68][] 相对[时间锁][topic timelocks]、输出支付的金额与第一笔输入的金额完全相同、输出支付的地址与扳机交易的第二个地址相同。相对时间锁定提供了一个竞争期（见下文）；精确金额验证确保了资金不会被擅自取走；地址验证确保了窃贼无法在最后一刻将合法取款地址改成自己的地址（据我们所知，所有预签名保管库都存在这个问题，见[周报 #59][news59 vaults]）。

  - *<!--illegitimate-spend-->非法花费：* Mallory 通过创建上述扳机交易来触发消费。Alice 的[瞭望塔][topic watchtowers]意识到，在竞赛期间（例如 20 个区块的延迟）这笔花费是非法的，于是创建了一个有两个输入和一个输出的重新存入保管库的交易；输入是扳机交易的第一个输出和一个手续费输入；输出是返回保管库。由于重新存入保管交易只有一个输出，但脚本的取款条件要求从有两个输出的扳机交易中花费，因此 Mallory 无法完成窃取 Alice 的资金。

    因为钱会返回到开始时的同一个保管库脚本，所以 Mallory 仍然可以创建另一个扳机交易，迫使 Alice 一次又一次地经历相同的循环，从而导致 Mallory 和 Alice 都要支付手续费。Rijndael 在项目的[扩展文档][cat vault readme]中指出，在这种情况下，你可能希望允许 Alice 把钱花到不同的脚本中，他这个构造背后的想法允许这样做，但为了简单起见，目前还没有实现。

  我们可以将这些基于 CAT 的保险库与我们现在无需修改共识即可创建的预签名保管库类型，以及需要通过软分叉支持、来提供一组最为熟知的保管库功能的 [BIP345][] 风格的 `OP_VAULT` 保管库类型进行比较。

  <table>
  <tr>
  <th></th>
  <th>预签名</th>
  <th markdown="span">

  BIP345 `OP_VAULT`

  </th>
  <th markdown="span">

  `OP_CAT` 结合 schnorr

  </th>
  </tr>

  <tr>
  <th>可用性</th>
  <td markdown="span">

  **当前**

  </td>
  <td markdown="span">

  需要 `OP_VAULT` 和 [OP_CTV][topic op_checktemplateverify] 软分叉

  </td>
  <td markdown="span">

  需要 `OP_CAT` 软分叉

  </td>
  </tr>

  <tr>
  <th markdown="span">最后时刻地址替换攻击</th>
  <td markdown="span">受影响</td>
  <td markdown="span">

  **不受影响**

  </td>
  <td markdown="span">

  **不受影响**

  </td>
  </tr>

  <tr>
  <th markdown="span">部分提款</th>
  <td markdown="span">仅当预先规划好时</td>
  <td markdown="span">

  **是**

  </td>
  <td markdown="span">否</td>
  </tr>

  <tr>
  <th markdown="span">静态且非交互的可计算提款地址</th>
  <td markdown="span">否</td>
  <td markdown="span">

  **是**

  </td>
  <td markdown="span">

  **是**

  </td>
  </tr>

  <tr>
  <th markdown="span">批量重新入库/隔离以节省手续费</th>
  <td markdown="span">否</td>
  <td markdown="span">

  **是**

  </td>
  <td markdown="span">否</td>
  </tr>

  <tr>
  <th markdown="span">

  最佳情况下的操作效率，例如只存在合法花费<br>*(only very roughly estimated by Optech)*

  </th>
  <td markdown="span">

  **2x 普通单签的体积**

  </td>
  <td markdown="span">3x 普通单签的体积</td>
  <td markdown="span">4x 普通单签的体积</td>
  </tr>
  </table>

  截至本文撰写之时，该原型在论坛上已获得了少量讨论和分析。

- **使用闪电网络和 ZKCP 发送和接收 ecash：** Anthony Towns 在 Delving Bitcoin 上[发表][towns lnecash]了一篇关于将 “[ecash][topic ecash] 铸币厂与闪电网络连接起来，而不会失去 ecash 的匿名性或增加任何额外的信任”的文章。他提出的实现这一目标的建议是，使用零知识条件支付（[ZKCP][topic acc]）向 ecash 铸币厂的用户发送付款，并使用承诺哈希原像的过程提款到闪电网络。

  [Cashu][] ecash 实现的首席开发者 Calle 在[回复][calle lnecash]中表示了一些担忧，但也对这一想法表示了支持，提到了 Cashu 已经实现的零知识证明系统，并指出他正在积极研究和编写代码，以支持从 ecash 到闪电网络的原子转账。

## Bitcoin Stack Exchange 的精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 的贡献者们寻找答案的首选之地，也是它们有闲暇时会给好奇和困惑的用户帮忙的地方。在这个月度栏目中，我们会列举自上次出刊以来出现的一些高票的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aa
nswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [<!--why-can-t-nodes-have-the-relay-option-to-disallow-certain-transaction-types-->为什么节点不能有禁止某些交易类型的中继选项？]({{bse}}121734)
  Ava Chow 概述了对[交易池和中继政策][policy series]目的的思考、更多同质化交易池的好处（包括[手续费估算][topic fee estimation]和[致密区块中继][topic compact block relay]），并谈到了矿工在[协议外接受手续费][topic out-of-band fees]等政策变通办法。

- [<!--what-is-the-circular-dependency-in-signing-a-chain-of-unconfirmed-transactions-->签署未经确认的交易链中的循环依赖是什么？]({{bse}}121959)
  Ava Chow 解释了在使用未经确认的传统比特币交易时[循环依赖][mastering 06 cds]的担忧。

- [<!--how-does-ocean-s-tides-payout-scheme-work-->Ocean 的 TIDES 支付方案是如何运作的？]({{bse}}120719)
  用户 Lagrang3 解释了 Ocean 矿池使用的区别扩展份额的透明指数（TIDES）矿工支付计划。

- [<!--what-data-does-the-bitcoin-core-wallet-search-for-during-a-blockchain-rescan-->Bitcoin Core 钱包在区块链重新扫描过程中搜索哪些数据？]({{bse}}121563)
  Pieter Wuille 和 Ava Chow 总结了 Bitcoin Core 钱包软件如何识别特定传统或[描述符][topic descriptors]钱包的相关交易。

- [<!--how-does-transaction-rebroadcasting-for-watch-only-wallets-work-->观察钱包的交易重新广播是如何工作的？]({{bse}}121899)
  Ava Chow 指出，无论钱包类型如何，交易重新广播的逻辑都是一样的。不过，要使一个来自观察钱包的交易有资格被节点重新广播，该交易必须在某个时候进入了节点的交易池。

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Core Lightning 24.02][] 是这个流行的闪电网络节点的下一个主要版本的发布。它包括对恢复（`recover`）插件的改进，“使紧急恢复的压力更小”；对[锚点通道][topic anchor outputs]的改进；区块链同步速度提高 50%；以及对在 testnet 上发现的大交易解析的错误修复。

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana
repo]。_

- [LDK #2770][] 开始准备以后增加对[双向注资通道][topic dual funding]的支持。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2770,29442" %}
[Core Lightning 24.02]: https://github.com/ElementsProject/lightning/releases/tag/v24.02
[myers csliq]: https://delvingbitcoin.org/t/liquidity-provider-utxo-management/600
[news134 cat]: /en/newsletters/2021/02/03/#replicating-op-checksigfromstack-with-bip340-and-op-cat
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
[policy series]: /zh/blog/waiting-for-confirmation/
[mastering 06 cds]: https://github.com/bitcoinbook/bitcoinbook/blob/develop/ch06_transactions.adoc#circular-dependencies
