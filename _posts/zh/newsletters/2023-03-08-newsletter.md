---
title: 'Bitcoin Optech Newsletter #241'
permalink: /zh/newsletters/2023/03/08/
name: 2023-03-08-newsletter
slug: 2023-03-08-newsletter
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了一项针对 `OP_VAULT` 的替代设计的提案，该提案具有多项益处，并宣布了一个新的每周 Optech 播客。此外还有我们的常规部分，其中包括 Bitcoin Core PR 审核俱乐部会议的总结、新版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **OP_VAULT 的替代设计：** Greg Sanders 向 Bitcoin-Dev 邮件列表 [发布了][sanders vault] 一个替代设计，用于提供 `OP_VAULT`/`OP_UNVAULT` 提案的功能 (详见[周报 #234][news234 vault])。他的替代方案是添加三个操作码而不是两个，举个例子：

    - Alice 通过使用花费 [P2TR 输出][topic taproot] 来将资金存入保险库，该输出包含至少两个 [leafscripts][topic tapscript]，一个可以触发延时解锁过程，另一个可以立即冻结她的资金，例如 `tr(key,{trigger,freeze})`。

      - *trigger leafscript* 包含她不太信任的授权条件（例如需要来自她的热钱包的签名）和一个 `OP_TRIGGER_FORWARD` 操作码。在她创建此 leafscript 时，她为操作码提供了一个 *花费延迟* 函数，例如 1000 个区块的相对时间锁定（大约 1 周）。

      - *freeze leafscript* 包含 Alice 想要指定的任何授权条件（包括根本没有）和 `OP_FORWARD_DESTINATION` 操作码。在她创建这个 leafscript 时，她还选择了她更信任的授权条件（例如需要来自多个冷钱包和硬件签名设备的多个签名）。她以哈希摘要的形式向操作码提供对这些条件的承诺。

    - *Alice触发了一个解锁* 是通过将接收到的输出花费到上面的脚本树（将其用作输入）并选择 the trigger leafscript 达成。此时，她向 `OP_TRIGGER_FORWARD` 操作码提供了两个附加参数，将接收此输入资金的输出索引以及她希望以后如何使用资金的基于哈希的承诺。操作码验证此交易的指定输出花费 P2TR 输出，此输出脚本树类似于被花费的脚本树，除了 the trigger leafscript 被使用 `OP_CHECKSEQUENCEVERIFY` (CSV) 相对延迟等于先前指定的延迟的脚本替换（例如，1000 个区块）和一个 `OP_FORWARD_OUTPUTS` 操作码，其中包含 Alice 的哈希承诺。重建脚本树的方法类似于更早的 [covenant][topic covenants] 提案，`OP_TAPLEAF_UPDATE_VERIFY` (详见[周报 #166][news166 tluv])。

    - *Alice 完成这个解锁* 是通过等到相对时间锁过期然后花费这个解锁的输出，该过程选择带有 `OP_FORWARD_OUTPUTS` 操作码的 tapleaf。操作码验证支出交易的输出金额和脚本的哈希值是否与爱丽丝在之前交易中做出的承诺相同。在这种情况下，Alice 已经成功地将资金存入保险库，也就是开始了一个解锁，并被迫等待至少 1,000 个区块以允许她的监控程序验证她确实想要将资金花费到指定的输出，并完成了花费。

    - 如果出现问题，*Alice 会冻结资金*。从她将资金存入保险库的那一刻起，直到完成解锁，她可以随时执行此操作。要冻结资金，她只需选择从入库交易或触发交易的输出中花费关于冻结的 leafscript。回想一下，Alice 明确地将 freeze leafscript 放在了入库交易中，并注意，它被启动解锁的触发交易隐式地保留了。

  与原始的 `OP_VAULT` 设计相比，这种方法的用户优势之一是 freeze leafscript 可以包含 Alice 想要指定的任何授权条件。在 `OP_VAULT`
  提案中，任何知道 Alice 选择的参数的人都可以将她的资金用于冻结脚本。那不是安全问题，但可能很烦人。在 Sanders 的设计中，Alice 可能（例如）需要来自保护力非常轻微的钱包的签名才能启动冻结——这可能足以防止大多数破坏性攻击的负担，但不足以阻止 Alice 快速在紧急情况下冻结她的资金。

  其他几个优势旨在使共识强制的
  [保管协议][topic vaults] 更容易理解和验证是否安全。在我们写完上面的内容之后，`OP_VAULT` 提案的作者 James O'Beirne 对 Sanders 的想法做出了积极的回应。O'Beirne 还对我们将在未来的周报中描述的其他更改有想法。{% include functions/podcast-callout.md url="pod241 op_vault" %}

- **New Optech 播客：** Twitter Spaces 上每周一次的 Optech Audio Recap 现已作为播客提供。每一集都将在所有流行的播客平台和 Optech 网站上作为文字记录提供。有关更多详细信息，包括为什么我们认为这是 Optech 改善比特币技术交流的使命的重要一步，请参阅我们的 [博客文章][podcast post]。{% include functions/podcast-callout.md url="pod241 podcast" %}

## Bitcoin Core PR 审核俱乐部

*在这个月度部分，我们总结了最近的 [Bitcoin Core PR 审核俱乐部][]会议，强调了一些重要的问题和答案。单击下面的问题以查看会议答案的总结。*

[Bitcoin-inquisition: Activation logic for testing consensus changes][review club bi-16]
是 Anthony Towns 的 PR，它在 [Bitcoin Inquisition][] 项目中添加了一种激活和停用软分叉的新方法，旨在在 [signet][topic signet]
上运行并用于测试。该项目在 [周报 #219][newsletter #219 bi]中有介绍。

具体来说，这个 PR 替换了 [BIP9][] 的区块版本位语义，取而代之的称为 [Heretical Deployments][]。与主网上的共识和中继更改相比——激活起来既困难又耗时，需要仔细建立（人类）共识和精心设计的 [soft fork activation][topic soft fork activation] 机制 -- 在测试网络上激活这些更改可以简化。PR 还实现了一种方法来停用被证明是有问题或不需要的更改，这是与主网的主要背离。{% include
functions/podcast-callout.md url="pod241 pr review" %}

{% include functions/details-list.md
  q0="为什么我们要部署未合并到 Bitcoin Core 的共识更改？将代码合并到 Bitcoin Core 中，然后在 signet 上测试它有什么问题（如果有的话）？
  a0="讨论了几个原因。我们不能要求主网用户升级他们正在运行的 Core 版本，因此即使在修复错误后，一些用户可能会继续运行有错误的版本。仅依赖于 regtest 使得集成测试第三方软件变得更加困难。将共识更改合并到单独的存储库比合并到 Core 的风险要小得多；添加软分叉逻辑，即使没有激活，也可能会引入影响现有行为的错误。"
  a0link="https://bitcoincore.reviews/bitcoin-inquisition-16#l-37"

  q1="Heretical Deployments 通过一系列类似于 BIP9 状态
      (`DEFINED`, `STARTED`, `LOCKED_IN`, `ACTIVE`, and `FAILED`),
      的有限状态机状态移动，但在`ACTIVE` 之后有一个额外的状态称为 `DEACTIVATING`
      (接下来是最终状态，`ABANDONED`)。`DEACTIVATING` 状态的目的是什么？"
  a1="它让用户有机会提取他们可能锁定在软分叉中的资金。一旦分叉被停用或更换，他们可能根本无法使用这些资金——即使他们是任何人都可以花的；如果您的交易因非标准而被拒绝，那将不起作用。与其说担心的是永久损失有限的 signet 资金，不如说是担心 UTXO 集可能会膨胀。"
  a1link="https://bitcoincore.reviews/bitcoin-inquisition-16#l-92"

  q2="为什么 PR 删除了 `min_activation_height`?"
  a2="我们不需要在新状态模型中锁定和激活之间的可配置间隔——使用 Heretical Deployments，它会在下一个 432块（3天）状态机周期开始时自动激活 (这个周期对 Heretical Deployments 是固定的)。"
  a2link="https://bitcoincore.reviews/bitcoin-inquisition-16#l-126"

  q3="为什么 Taproot 被埋没在这个 PR 中?"
  a3="如果你不掩埋它，你就必须把它变成一个 Heretical Deployment,
      这需要一些编码工作；这也意味着它最终会超时，但我们希望 Taproot 永远不会超时。"
  a3link="https://bitcoincore.reviews/bitcoin-inquisition-16#l-147"
%}

## 版本和候选版本

*热门的比特币基础设施项目的新版本与候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Core Lightning 23.02][] 是这个流行的 LN 实现的新版本。它包括对备份数据的对等存储的实验性支持 (详见 [周报 #238][news238 peer storage]) 并更新对 [双重出资][topic dual funding] 和 [BOLT12 发票][topic offers] 的实验性支持。还包括其他一些改进和错误修复。{% include functions/podcast-callout.md url="pod241 cln" %}

- [LDK v0.0.114][] 是该库的新版本，用于构建支持 LN 的钱包和应用程序。它修复了几个与安全相关的错误，并包括解析 [BOLT12 发票][topic
  offers]的能力。{% include functions/podcast-callout.md url="pod241 ldk" %}

- [BTCPay 1.8.2][] 是这款流行的比特币自托管支付处理软件的最新版本。1.8.0 版的发行说明说，“这个版本带来了自定义结账表格、商店品牌选项、重新设计的销售点键盘视图、新的通知图标和地址标签。” {% include functions/podcast-callout.md url="pod241 btcpay" %}

- [LND v0.16.0-beta.rc2][] 是这个流行的 LN 实现的新主要版本的候选版本。{% include functions/podcast-callout.md url="pod241 lnd" %}

## 重大的文档和代码变更


*本周出现的周大变更有：[Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], 和 [Lightning BOLTs][bolts repo]。*

- [LND #7462][] 允许创建具有远程签名和使用无状态初始化功能的只监视钱包。{% include functions/podcast-callout.md url="pod241 lnd7462" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="7462" %}
[core lightning 23.02]: https://github.com/ElementsProject/lightning/releases/tag/v23.02
[lnd v0.16.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc2
[LDK v0.0.114]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.114
[BTCPay 1.8.2]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.8.2
[podcast post]: /en/podcast-announcement/
[sanders vault]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-March/021510.html
[news234 vault]: /zh/newsletters/2023/01/18/#proposal-for-new-vault-specific-opcodes
[news166 tluv]: /en/newsletters/2021/09/15/#covenant-opcode-proposal
[news238 peer storage]: /zh/newsletters/2023/02/15/#core-lightning-5361
[newsletter #219 bi]: /en/newsletters/2022/09/28/#bitcoin-implementation-designed-for-testing-soft-forks-on-signet
[review club bi-16]: https://bitcoincore.reviews/bitcoin-inquisition-16
[bitcoin inquisition]: https://github.com/bitcoin-inquisition/bitcoin
[heretical deployments]: https://github.com/bitcoin-inquisition/bitcoin/wiki/Heretical-Deployments
[bip9]: https://github.com/bitcoin/bips/blob/master/bip-0009.mediawiki
[pod241 op_vault]: /en/podcast/2023/03/09/#alternative-design-for-op-vault
[pod241 podcast]: /en/podcast/2023/03/09/#new-optech-podcast
[pod241 pr review]: /en/podcast/2023/03/09/#bitcoin-inquisition-activation-logic-for-testing-consensus-changes
[pod241 cln]: /en/podcast/2023/03/09/#core-lightning-23-02
[pod241 ldk]: /en/podcast/2023/03/09/#ldk-v0-0-114
[pod241 btcpay]: /en/podcast/2023/03/09/#btcpay-1-8-2
[pod241 lnd]: /en/podcast/2023/03/09/#lnd-v0-16-0-beta-rc2
[pod241 lnd7462]: /en/podcast/2023/03/09/#lnd-7462
