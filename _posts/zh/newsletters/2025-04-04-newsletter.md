---
title: 'Bitcoin Optech Newsletter #348'
permalink: /zh/newsletters/2025/04/04/
name: 2025-04-04-newsletter-zh
slug: 2025-04-04-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报链接了一个比特币的 secp256k1 曲线的椭圆曲线密码学的教育实现。此外还包括我们的常规部分：描述了关于共识更改的讨论、新版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **<!--educational-and-experimental-based-secp256k1-implementation-->****教育和实验性的 secp256k1 实现：**
  Sebastian Falbesoner、Jonas Nick 和 Tim Ruffing 在 Bitcoin-Dev 邮件列表上[发布][fnr secp]了一个与比特币中使用的密码学相关的各种函数的 Python [实现][secp256k1lab]。他们警告说，该实现是“不安全的”（原文大写）并且“旨在用于原型设计、实验和教育”。

  他们还指出，几个 BIP（[340][bip340]、[324][bip324]、[327][bip327] 和 [352][bip352]）的参考和测试代码已经包含了“自定义且有时微妙不同的 secp256k1 实现”。他们希望未来能改进这种情况，可能从即将推出的 ChillDKG 的 BIP 开始（见[周报 #312][news312 chilldkg]）。

## 共识更改

_在这个月度部分，我们总结了关于更改比特币共识规则的提案和讨论。_

- **<!--multiple-discussions-about-quantum-computer-theft-and-resistance-->关于量子计算机盗窃和抵抗的多项讨论：**
  几场对话探讨了比特币人如何应对量子计算机强大到足以盗取比特币的情况。

  - *<!--should-vulnerable-bitcoins-be-destroyed-->应该销毁易受攻击的比特币吗？* Jameson Lopp 在 Bitcoin-Dev 邮件列表上[发布][lopp destroy]了几个支持在采用[抗量子][topic quantum resistance]升级路径并且用户有时间采用解决方案后销毁易受量子盗窃的比特币的论点。一些论点包括：

    - *<!--argument-from-common-preference-->基于共同偏好的论点：* 他认为大多数人会更愿意他们的资金被销毁而不是被拥有快速量子计算机的人盗取。特别是，他认为，因为小偷将是“少数几个能够早期获得量子计算机的特权人士”。

    - *<!--argument-from-common-harm-->基于共同伤害的论点：* 许多被盗的比特币要么是丢失的币，要么是计划长期持有的币。相比之下，小偷可能会迅速花费他们盗取的比特币，这会降低其他比特币的购买力（类似于货币供应通胀）。他指出，比特币购买力的降低会减少矿工收入，降低网络安全性，并（根据他的观察）导致商家接受比特币的意愿降低。

    - *<!--argument-from-minimal-benefit-->基于最小收益的论点：* 虽然允许盗窃可能会用于资助量子计算的发展，但盗取币并不为比特币协议的诚实参与者提供任何直接利益。

    - *<!--argument-from-clear-deadlines-->基于明确截止日期的论点：* 没有人能够提前很久知道某人拥有量子计算机可以开始盗取比特币的日期，但可以提前很久以完美的精确度宣布易受量子攻击的币将被销毁的特定日期。这个明确的截止日期将为用户提供更多激励，以确保及时重新保护他们的比特币，确保更少的总币量损失。

    - *<!--argument-from-miner-incentives-->基于矿工激励的论点：* 如上所述，量子盗窃可能会减少矿工收入。持续多数的算力可以审查易受量子攻击的比特币的支出，即使其他比特币用户更喜欢不同的结果，他们也可能这样做。

    Lopp 还提供了几个反对销毁易受攻击的比特币的论点，但他的结论支持销毁。

    Nagaev Boris [询问][boris timelock]是否超过升级截止日期的[时间锁定][topic timelocks]的 UTXO 也应该被销毁。Lopp 指出了长时间锁定的现有陷阱，并表示他个人对“锁定资金超过一两年感到有点紧张”。

  - *<!--securely-proving-utxo-ownership-by-revealing-a-sha256-preimage-->**通过揭示 SHA256 原象安全地证明 UTXO 所有权：*
    Martin Habovštiak 在 Bitcoin-Dev 邮件列表上[发布][habovstiak gfsig]了一个想法，即使 ECDSA 和[schnorr 签名][topic schnorr signatures]不安全（例如，在快速量子计算机存在之后），也可以允许某人证明他们控制了一个 UTXO。如果 UTXO 包含一个 SHA256 承诺（或其他抗量子承诺）到一个以前从未被揭示的原象，那么揭示该原象的多步协议可以与共识更改相结合，以防止量子盗窃。这在本质上与 Tim Ruffing 的[先前的提案][ruffing gfsig]相同（见[周报 #141][news141 gfsig]），他了解到这通常被称为 [Guy Fawkes 签名方案][Guy Fawkes signature scheme]。它也是 Adam Back 在 2013 年发明的一个[方案][back crsig]的变体，旨在提高对矿工审查的抵抗力。简而言之，该协议可以这样工作：

    1. Alice 接收到一个以某种方式进行 SHA256 承诺的输出的资金。这可以是直接哈希输出，如 P2PKH、P2SH、P2WPKH 或 P2WSH，或者是带有脚本路径的 [P2TR][topic taproot] 输出。

    2. 如果 Alice 收到多笔支付到同一输出脚本，她必须要么在准备好花费所有这些资金之前不花费任何一笔（对于 P2PKH 和 P2WPKH 肯定需要；对于 P2SH 和 P2WSH 可能也实际上需要），要么非常小心地确保通过她的花费至少有一个原象保持未揭示（使用 P2TR 密钥路径与脚本路径花费很容易实现）。

    3. 当 Alice 准备好花费时，她私下正常创建她的花费交易但不广播它。她还获取一些由量子安全签名算法保护的比特币，以便支付交易费用。

    4. 在花费一些“量子安全”的比特币的交易中，她承诺到要花费的“量子不安全”比特币，并且还承诺到私人花费交易（不揭示它）。她等待这个交易被深度确认。

    5. 在她确信她之前的交易实际上不能被重组后，她揭示她先前私人的原象和“量子不安全”比特币的花费。

    6. 网络上的节点搜索区块链以找到第一个承诺到该原象的交易。如果该交易承诺到 Alice 的“量子不安全”的花费，那么他们执行她的花费。否则，他们什么也不做。

    这确保了 Alice 不必揭示易受量子攻击的信息，直到她已经确保她的花费交易版本将优先于量子计算机操作者的任何尝试花费。有关协议的更精确描述，请参阅 [Ruffing 的 2018 年帖子][ruffing gfsig]。虽然在帖子中没有讨论，但我们相信上述协议可以作为软分叉部署。

    Habovštiak 认为，可以使用此协议安全花费的比特币（例如，其原象尚未被揭示）不应该被销毁，即使社区决定要销毁一般的易受量子攻击的比特币。他还认为，在紧急情况下安全花费一些比特币的能力减少了短期内部署量子抵抗方案的紧迫性。

    Lloyd Fournier [表示][fournier gfsig]，“如果这种方法获得接受，我认为用户可以采取的主要立即行动是转向 taproot 钱包”，因为它能够在当前共识规则下允许密钥路径花费，包括在[地址复用][topic output linking]的情况下，但如果密钥路径花费后来被禁用，也能抵抗量子盗窃。

    在另一个主题中（见下一项），Pieter Wuille [指出][wuille nonpublic]，易受量子盗窃的 UTXO 还包括那些尚未公开使用但为多方所知的密钥，例如在各种形式的多重签名中（包括 LN、[DLC][topic dlc] 和托管服务）。

  - *<!--draft-bip-for-destroying-quantum-insecure-bitcoins-->**销毁“量子不安全”比特币的 BIP 草案：* Agustin Cruz 在 Bitcoin-Dev 邮件列表上[发布][cruz qramp]了一个[BIP 草案][cruz bip]，描述了销毁易受量子盗窃的比特币的一般过程的几个选项（如果这成为预期风险）。Cruz 认为，“通过强制执行迁移截止日期，我们为合法所有者提供了一个明确、不可协商的机会来保护他们的资金 [...] 强制迁移，在充分通知和强大保障的情况下，对保护比特币的长期安全既现实又必要。”

    主题的讨论很少关注 BIP 草案。大多数讨论集中在销毁量子易受攻击的比特币是否是一个好主意上，类似于后来由 Jameson Lopp 开始的主题（在前一个子项中描述）。

- **<!--multiple-discussions-about-a-ctv-csfs-soft-fork-->****关于 CTV+CSFS 软分叉的多项讨论：** 几场对话检验了软分叉引入 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]（CTV）和 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]（CSFS）操作码的各个方面。

  - *<!--criticism-of-ctv-motivation-->**对 CTV 动机的批评：* Anthony Towns [发布][towns ctvmot]了对 [BIP119][] 描述的 CTV 动机的批评，他认为这个动机会被同时向比特币添加 CTV 和 CSFS 所削弱。在讨论开始几天后，BIP119 的作者更新了 BIP119，删除了大部分（可能是全部）有争议的语言；请参阅[周报 #347][news347 bip119]中我们对这一变更的总结，以及 [BIP119 的旧版本][bip119 prechange]作为参考。讨论的一些主题包括：

    - *<!--ctv-csfs-allows-the-creation-of-a-perpetual-covenant-->**CTV+CSFS 允许创建永久限制条款：*
      CTV 的动机说，"限制条款历来被广泛认为不适合比特币，因为它们实现起来太复杂，并且有可能降低受限制条款约束的币的同质化。这个 BIP 引入了一个称为*模板*的简单限制条款，它能够实现一组有限的高价值用例，而没有显著风险。BIP119 模板允许**非递归**完全枚举的限制条款，没有动态状态"（原文强调）。

      Towns 描述了一个同时使用 CTV 和 CSFS 的脚本，并链接到 MutinyNet [signet][topic signet] 上使用它的一个[交易][mn recursive]，该交易只能通过将相同数量的资金发送回脚本本身来花费。虽然对定义有一些争论，但 CTV 的作者[之前描述][rubin recurse]了一个功能上相同的结构为递归限制条款，Optech 在其对该对话的总结中遵循了这一惯例（参见[周报 #190][news190 recursive]）。

      Olaoluwa Osuntokun [为][osuntokun enum] CTV 的动机辩护，认为使用它的脚本仍然是“完全枚举的”和“没有动态状态”的。这似乎类似于 CTV 的作者（Jeremy Rubin）在 2022 年提出的一个[论点][rubin enumeration]，他称 Towns 设计的自我支付限制条款类型为“递归但完全枚举”。Towns [反驳][towns enum]说，添加 CSFS 削弱了完全枚举的声称好处。他要求 CTV 或 CSFS 的 BIP 更新，以描述“那些既可怕又仍然被 CTV 和 CSFS 的组合所阻止的用例”。这可能已经在 BIP119 的最近更新中[完成][ctv spookchain]，其中描述了一个“自我复制的自动机（俗称 SpookChains）”，这在使用 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 时是可能的，但在使用 CTV+CSFS 时是不可能的。

    - *<!--tooling-for-ctv-and-csfs-->**CTV 和 CSFS 的工具：* Towns [指出][towns ctvmot]，他发现使用现有工具开发上述递归脚本很困难，表明部署准备不足。Osuntokun [表示][osuntokun enum]他使用的工具“相当直接”。Towns 和 Osuntokun 都没有提到他们使用了什么工具。Nadav Ivgi [提供][ivgi minsc]了一个使用他的 [Minsc][] 语言的例子，并表示他“一直在努力改进 Minsc，使这类事情更容易。它支持 Taproot、CTV、PSBT、描述符、Miniscript、原始脚本、BIP32 等”。尽管他承认“其中很多仍未形成文档”。

    - *<!--alternatives-->**替代方案：* Towns 将 CTV+CSFS 与他的基本比特币 Lisp 语言（[bll][topic bll]）和 [Simplicity][topic simplicity] 进行了比较，这两者都将提供替代的脚本语言。Antoine Poinsot [建议][poinsot alt]，一种易于推理的替代语言可能比对当前系统的小改动风险更小，而当前系统很难推理。开发者 Moonsettler [认为][moonsettler express]，逐步引入新功能到比特币脚本中使得以后添加更多功能更安全，因为每次增加表达能力都会降低我们遇到意外的可能性。

      Osuntokun 和 James O'Beirne 都[批评][osuntokun enum]了 bll 和 Simplicity 与 CTV 和 CSFS 相比的[准备程度][obeirne readiness]。

  - *<!--ctv-csfs-benefits-->**CTV+CSFS 的好处：* Steven Roose 在 Delving Bitcoin 上[发布][roose ctvcsfs]，建议将 CTV 和 CSFS 添加到比特币作为进一步增加表达能力的其他变更的第一步。大多数讨论集中在限定 CTV、CSFS 或两者一起的可能好处。这包括：

    - *<!--dlcs-->**DLC：* CTV 和 CSFS 单独都可以减少创建 [DLC][topic dlc] 所需的签名数量，特别是对于签署大量合约变体的 DLC（例如，以一美元为增量的 BTC-USD 价格合约）。Antoine Poinsot [链接][poinsot ctvcsfs1]到最近一个 DLC 服务提供商[宣布][10101 shutdown]关闭的消息，作为比特币用户似乎对 DLC 不太感兴趣的证据，并链接到几个月前 Jonas Nick 的一个[帖子][nick dlc]，其中说：“DLC 在比特币上没有实现有意义的采用，其有限使用似乎不是源于性能限制”。回复链接到其他仍在运行的 DLC 服务提供商，包括一个[声称][lava 30m]已经筹集了"3000 万美元融资"的提供商。

    - *<!--vaults-->保管库：* CTV 简化了今天在比特币上使用预签名交易和（可选）私钥删除可能实现的[保管库][topic vaults]的实现。Anthony Towns [认为][towns vaults]这种类型的保管库不是很有趣。James O'Beirne [反驳][obeirne ctv-vaults]说，CTV 或类似的东西是构建更高级类型保险库的先决条件，例如他的 [BIP345][] `OP_VAULT` 保险库。

    - *<!--accountable-computing-contracts-->可问责计算合约：* CSFS 可以通过替代当前需要执行基于脚本的 lamport 签名的需求，消除 [BitVM][topic acc] 等可问责计算合约中的许多步骤。CTV 可能能够减少一些额外的签名操作。Poinsot 再次[询问][poinsot ctvcsfs1]是否对 BitVM 有显著需求。Gregory Sanders [回复][sanders bitvm]说，他会发现它对于代币的双向桥接作为 “暗影[客户端验证][topic client-side validation]” 的一部分很有趣（参见[周报 #322][news322 csv-bitvm]）。然而，他还指出，CTV 和 CSFS 都不会显著改善 BitVM 的信任模型，而其他变更可能能够以其他方式减少信任或减少昂贵操作的数量。

    - *<!--improvement-in-liquid-timelock-script-->**改进 Liquid 时间锁定脚本：* James O'Beirne [转述][obeirne liquid]了两位 Blockstream 工程师的评论，用他的话说，CTV 将“极大地改善 [Blockstream] Liquid 时间锁定回退脚本，该脚本要求定期[移动]币”。在要求澄清后，前 Blockstream 工程师 Sanket Kanjalkar [解释][kanjalkar liquid]说，好处可能是显著节省链上交易费用。O'Beirne 还[分享][poelstra liquid]了 Blockstream 研究总监 Andrew Poelstra 的额外细节。

    - *<!--ln-symmetry-->**LN-Symmetry：* CTV 和 CSFS 一起可以用来实现 [LN-Symmetry][topic eltoo] 的一种形式，它消除了 LN 中当前使用的 [LN-Penalty][topic ln-penalty] 通道的一些缺点，并可能允许创建具有两个以上参与方的通道，这可能改善流动性管理和链上效率。Gregory Sanders，他使用 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]（APO）实现了 LN-Symmetry 的实验版本（参见[周报 #284][news284 lnsym]），[指出][sanders versus]CTV+CSFS 版本的 LN-Symmetry 不如 APO 版本功能丰富，并且需要做出权衡。Anthony Towns [补充][towns nonrepo]说，据所知，没有人更新 Sanders 的 APO 实验代码以在现代软件上运行并使用最近引入的中继功能，如 [TRUC][topic v3 transaction relay] 和[临时锚点][topic ephemeral anchors]，更不用说有人将代码移植到使用 CTV+CSFS，这限制了我们评估该组合用于 LN-Symmetry 的能力。

      Poinsot [询问][poinsot ctvcsfs1]如果软分叉使其成为可能，实现 LN-Symmetry 是否会成为 LN 开发者的优先事项。来自两位 Core Lightning 开发者（也是引入我们现在称为 LN-Symmetry 的论文的共同作者）的引述表明，这对他们来说是一个优先事项。相比之下，LDK 首席开发者 Matt Corallo [之前表示][corallo eltoo]，“我不认为 [LN-Symmetry] 有趣到 ‘我们得马上行动’”。

    - *<!--ark-->**Ark：* Roose 是一家构建 [Ark][topic ark] 实现的企业的 CEO。他说，“CTV 对 Ark 来说是如虎添翼 [...] CTV 对用户体验的好处是不可否认的，毫无疑问，两种 [Ark] 实现都将在 CTV 可用后立即使用它。”Towns [指出][towns nonrepo]，没有人用 APO 或 CTV 实现 Ark 进行测试；Roose 随后编写了[代码][roose ctv-ark]，称其“非常直接”，并表示它通过了现有实现的集成测试。他量化了一些改进：“如果我们切换到 CTV，我们可以净减少约 900 行代码 [...] 并将我们自己的回合协议减少到[两个]而不是三个，[加上]不必传递签名随机数和部分签名的带宽改进。"

      Roose 后来开始了一个单独的帖子，讨论 CTV 对 Ark 用户的好处（见下面我们的总结）。

  - *<!--benefit-of-ctv-to-ark-users-->**CTV 对 Ark 用户的好处：* Steven Roose 在 Delving Bitcoin 上[发布][roose ctv-for-ark]了一个简短描述，介绍了当前部署到 [signet][topic signet] 的 [Ark][topic ark] 协议，称为 [无限制条款的 Ark][clark doc]（clArk），以及 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]（CTV）操作码的可用性如何使使用[限制条款][topic covenants]的协议版本在最终部署到主网时对用户更具吸引力。

    Ark 的一个设计目标是允许[异步支付][topic async payments]：在接收者离线时进行的支付。在 clArk 中，这是通过支付者加上 Ark 服务器扩展支出者现有的预签名交易链来实现的，允许接收者最终接受对资金的独占控制。该支付被称为 Ark [out-of-round][oor doc] 支付（_arkoor_）。当接收者上线时，他们可以选择他们想要做什么：

    - *<!--exit-after-a-delay-->延迟后退出：* 广播整个预签名交易链，退出这个 [joinpool][topic joinpools]（这个 joinpool 就叫 _Ark_）。这需要等待支付者同意的时间锁到期。当预签名交易被确认到适当深度时，接收者可以确定他们对资金免信任控制。然而，他们失去了作为 joinpool 一部分的好处，如快速结算和源自 UTXO 共享的较低费用。他们可能还需要支付交易费用来确认交易链。

    - *<!--nothing-->什么都不做：* 在正常情况下，交易链中的预签名交易最终会到期，允许服务商索取资金。这不是盗窃——这是协议的预期部分——服务商可能选择以某种方式将部分或全部索取的资金返还给用户。在到期临近之前，接收者可以只是等待。

      在病态情况下，服务商和支付者可以（在任何时候）勾结签署另一条交易链以窃取发送给接收者的资金。注意：比特币的隐私属性允许服务商和支付者是同一个人，所以甚至可能不需要勾结。然而，如果接收者保留了服务商共同签署的交易链的副本，他们可以证明服务商窃取了资金，这可能足以阻止其他人使用该服务商。

    - *<!--refresh-->刷新：* 在服务器合作的情况下，接收者可以原子地将支出者共同签署的交易中的资金所有权转移到另一个以接收者为共同签署者的预签名交易。这延长了到期日期，并消除了服务商和先前支付者勾结窃取先前发送资金的能力。然而，刷新需要服务商持有刷新的资金直到它们到期，减少了服务商的流动性，所以服务商向接收者收取利率直到到期（由于到期时间是固定的，所以是预先支付）。

    Ark 的另一个设计目标是允许参与者接收 LN 支付。在他的原始帖子和[回复][roose ctv-ark-ln]中，Roose 描述了现有参与者如果已经在 joinpool 中有资金，如果他们未能执行接收 LN 支付所需的交互，可能会被处罚高达链上交易成本。然而，那些在 joinpool 中还没有资金的人不能被处罚，所以他们可以拒绝执行交互步骤，无成本地为诚实参与者创造问题。这似乎在实质上地阻止了 Ark 用户接收 LN 支付，除非他们已经在他们想要使用的 Ark 服务商处存入了适量的资金。

    Roose 然后描述了 CTV 的可用性如何允许改进协议。主要变化是 Ark 轮次的创建方式。_Ark 轮次_由一个小型链上交易组成，该交易承诺了一棵链下交易树。在 clArk 的情况下，这些是预签名交易，需要该轮次中的所有支付者都可进行签名。如果 CTV 可用，交易树中的每个分支都可以使用 CTV 承诺其后代，无需签名。这允许即使在创建轮次时参与者不可用，也能创建交易，带来以下好处：

    - *<!--in-round-non-interactive-payments-->轮内非交互式支付：* 代替 Ark out-of-round（arkoor）支付，愿意等待下一轮的支付者可以在轮内支付给接收者。对于接收者，这有一个主要优势：一旦轮次确认到适当深度，他们就获得对接收资金的免信任控制（直到到期临近，此时他们可以选择退出或低成本刷新）。接收者可以选择立即信任 Ark 协议创建的激励，让服务器诚实运营（参见[周报 #253][news253 ark 0conf]），而不是等待几次确认。在另一点上，Roose 指出，这些非交互式支付也可以[批量][topic payment batching]支付多个接收者。

    - *<!--in-round-acceptance-of-ln-payments-->**轮内接受 LN 支付：* 用户可以请求将 LN 支付（[HTLC][topic htlc]）发送到 Ark 服务器，服务器随后会[持有][topic hold invoices]该支付直到下一轮，并使用 CTV 在该轮中包含一个 HTLC 锁定的支付给用户——之后用户可以披露 HTLC 原象来领取支付。然而，Roose 指出这仍然需要使用“各种反滥用措施”（我们认为这是因为接收者可能不披露原像，导致服务器的资金保持锁定直到 Ark 轮结束，这可能延续两个月或更长时间）。

      David Harding [回复][harding ctv-ark-ln] Roose 请求更多细节，并将这种情况与 LN [JIT 通道][topic jit channels]进行比较，后者也有类似的 HTLC 原象不披露问题，给闪电服务提供商（LSPs）造成麻烦。LSP 目前通过引入基于信任的机制来解决这个问题（见[周报 #256][news256 ln-jit]）。如果计划在 CTV-Ark 中使用相同的解决方案，这些解决方案似乎也能安全地允许在 clArk 中进行轮内接受 LN 支付。

    - *<!--fewer-rounds-fewer-signatures-and-less-storage-->更少的轮次、更少的签名和更少的存储：* clArk 使用 [MuSig2][topic musig]，每个参与方需要参与多个轮次，生成多个部分签名，并存储完全的签名。使用 CTV，需要生成和存储的数据更少，所需的交互也更少。

- **<!--op-checkcontractverify-semantics-->****OP_CHECKCONTRACTVERIFY 语义：** Salvatore Ingala 在 Delving Bitcoin 上[发布][ingala ccv]了对提议的 [OP_CHECKCONTRACTVERIFY][topic matt]（CCV）操作码语义的描述，链接到一个[首个 BIP 草案][ccv bip]，以及链接到 Bitcoin Core 的[实现草案][bitcoin core #32080]。他的描述从 CCV 行为的概述开始：它允许检查公钥是否承诺了任意数据。它可以检查正在花费的 [taproot][topic taproot] 输出的公钥或正在创建的 taproot 输出的公钥。这可以用来确保从正在花费的输出中的数据被传递到正在创建的输出。在 taproot 中，输出的调整项可以承诺 tapleave，从而可以携带 [tapscripts][topic tapscript]。如果调整项承诺了一个或多个 tapscripts，它会在输出上放置一个 _encumbrance_（花费条件），（然后 CCV 就）允许放置在正在花费的输出上的条件被转移到正在创建的输出上——在比特币术语中通常（但[有争议地][towns anticov]）称为[限制条款][topic covenants]。这种限制条款可能允许满足或修改 encumbrance，这将（分别）终止限制条款或修改其未来迭代的条款。Ingala 描述了这种方法的一些优点和缺点：

  - *<!--benefits-->优点：* taproot 原生，不增加 UTXO 集里 taproot 条目的大小，不需要额外数据的花费路径不需要在其见证栈中包含它（所以在这种情况下没有额外成本）。

  - *<!--drawbacks-->缺点：* 只适用于 taproot，检查调整需要椭圆曲线操作，这比（例如）SHA256 操作更昂贵。

  仅将花费条件从正在花费的输出转移到正在创建的输出可能是有用的，但许多限制条款会希望确保正在花费的输出中的部分或全部比特币被传递到正在创建的输出。Ingala 描述了 CCV 处理值的三个选项。

  - *<!--ignore-->忽略：* 不检查金额。

  - *<!--deduct-->扣除：* 在特定索引（例如，第三个输出）创建的输出的金额从同一索引处花费的输出的金额中扣除，并跟踪剩余值。例如，如果索引三处花费的输出价值 100 BTC，而索引三处创建的输出价值 70 BTC，则代码会跟踪剩余的 30 BTC。如果创建的输出大于花费的输出，则交易被标记为无效（因为这会减少剩余值，可能低于零）。

  - *<!--default-->默认：* 除非在特定索引创建的输出的金额大于花费的输出的金额加上尚未使用 _default_ 检查的任何先前剩余值的总和，否则将交易标记为无效。

  如果任何输出被 _deduct_ 检查多次，或者如果 _deduct_ 和 _default_ 都用于同一输出，则交易有效。

  Ingala 提供了上述操作组合的几个可视化示例。以下是我们对他的“发送部分金额”示例的文字描述，这可能对[保管库][topic vaults]有用：一个交易有一个输入（花费一个输出）价值 100 BTC 和两个输出，一个 70 BTC，另一个 30 BTC。CCV 在交易验证期间运行两次：

  1. CCV 使用 _deduct_ 操作索引 0，从 100 BTC 花费到 70 BTC 创建，得到 30 的剩余值。在 [BIP345][] 风格的保管库中，CCV 将把那 70 BTC 返回到之前保护它的相同脚本。

  2. 第二次，它在索引 1 上使用 _default_。虽然在这个交易中索引 1 处有一个正在创建的输出，但索引 1 处没有相应的正在花费的输出，所以使用隐式金额 `0`。将索引 0 上 _deduct_ 调用的剩余 30 BTC 添加到该零值，要求创建的这个输出等于或大于 30 BTC。在 BIP345 风格的保管库中，CCV 会调整输出脚本，允许在[时间锁][topic timelocks]到期后将此值花费到任意地址，或随时将其返回到用户的主保管库地址。

  Ingala 考虑并放弃的几种替代方法在他的帖子和回复中都有讨论。他写道，“我认为这两种金额行为（default 和 deduct）非常符合人体工程学，并且涵盖了实践中绝大多数理想的金额检查。”

  他还指出，他“使用 `OP_CCV` 加上 [OP_CTV][topic op_checktemplateverify] 实现了功能齐全的保管库，大致相当于 [...[BIP345][]...]。此外，仅使用 `OP_CCV` 的减少功能版本在 `OP_CCV` 的 Bitcoin Core 实现中作为功能测试实现。”

- **<!--draft-bip-published-for-consensus-cleanup-->****共识清理的 BIP 草案发布：** Antoine Poinsot 在 Bitcoin-Dev 邮件列表上[发布][poinsot cleanup]了他为[共识清理][topic consensus cleanup]软分叉提案编写的[BIP 草案][cleanup bip]链接。它包括几个修复：

  - 修复两种不同的[时间扭曲][topic time warp]攻击，这些攻击可能被大多数算力用来加快速率产生区块。

  - 对传统交易的签名操作（sigops）执行限制，以防止创建验证过慢的区块。

  - 修复 [BIP34][] coinbase 交易唯一性，应该完全防止[重复交易][topic duplicate transactions]。

  - 使未来的 64 字节交易（使用剥离大小计算）无效，以防止一种[默克尔树漏洞][topic merkle tree vulnerabilities]。

  技术回复对提案的所有部分都表示赞同，除了两个部分。第一个反对意见，在几个回复中提出，是关于使 64 字节交易无效。这些回复重申了先前的批评（见[周报 #319][news319 64byte]）。存在一种解决默克尔树漏洞的替代方法。该方法对轻量级（SPV）钱包使用相对容易，但可能对智能合约中的 SPV 验证带来挑战，例如比特币和其他系统之间的 _桥_。Sjors Provoost [建议][provoost bridge]实现链上可执行桥的人提供代码，说明能够假设 64 字节交易不存在与必须使用替代方法防止默克尔树漏洞之间的区别。

  第二个反对意见是关于 BIP 中包含的想法的后期变更，这在 Poinsot 在 Delving Bitcoin 上的[帖子][poinsot nsequence]中有描述。该变更要求共识清理激活后生产的区块设置使其 coinbase 交易时间锁可执行的标志。按照先前的提议，激活后区块中的 coinbase 交易将把它们的时间锁设置为它们的区块高度（减 1）。这一变更意味着没有矿工可以产生一个早期比特币区块的替代，同时使用激活后的时间锁并设置执行标志（因为如果他们这样做，由于使用了远期时间锁，他们的 coinbase 交易在包含它的区块中将无效）。无法在过去的 coinbase 交易中使用与未来coinbase 交易中将使用的完全相同的值，防止了重复交易漏洞。对这一提议的反对意见是，尚不清楚所有矿工是否能够设置时间锁执行标志。

## 版本和候选版本

_热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [BDK wallet 1.2.0][] 增加了向自定义脚本发送支付的灵活性，修复了与 coinbase 交易相关的边缘情况，并包括其他几个功能和错误修复。

- [LDK v0.1.2][] 是这个用于构建支持 LN 的应用程序的库的发布版本。它包含几个性能改进和错误修复。

- [Bitcoin Core 29.0rc3][] 是网络中占主导地位的全节点的下一个主要版本的候选版本。请参阅[版本 29 测试指南][bcc29 testing guide]。

- [LND 0.19.0-beta.rc1][] 是这个热门的 LN 节点的候选版本。可能需要测试的主要改进之一是基于 RBF 的合作关闭手续费提升。

## 重要的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Bitcoin Core #31363][] 引入了 `TxGraph` 类（见[周报 #341][news341 pr review]），这是一个轻量级的内存中交易池交易模型，只跟踪手续费率和交易之间的依赖关系。它包括诸如 `AddTransaction`、`RemoveTransaction` 和 `AddDependency` 等变异函数，以及诸如 `GetAncestors`、`GetCluster` 和 `CountDistinctClusters` 等检查函数。`TxGraph` 还支持带有提交和中止功能的变更暂存。这是[族群交易池][topic cluster mempool]项目的一部分，为未来的交易池驱逐、重组处理和族群感知挖矿逻辑的改进做准备。

- [Bitcoin Core #31278][] 弃用了 `settxfee` RPC 命令和 `-paytxfee` 启动选项，这些允许用户为所有交易设置静态手续费率。用户应该改为依赖[手续费估算][topic fee estimation]或设置每笔交易的手续费率。它们被标记为在 Bitcoin Core 31.0 中移除。

- [Eclair #3050][] 更新了当接收者是直接连接的节点时 [BOLT12][topic offers] 支付失败的中继方式，始终转发失败消息而不是用不可读的 `invalidOnionBlinding` 失败覆盖它。如果失败包括 `channel_update`，Eclair 用 `TemporaryNodeFailure` 覆盖它以避免揭示关于[未公告通道][topic unannounced channels]的详细信息。对于涉及其他节点的[盲路由][topic rv routing]，Eclair 继续用 `invalidOnionBlinding` 覆盖失败。所有失败消息都使用钱包的 `blinded_node_id` 加密。

- [Eclair #2963][] 通过在通道强制关闭期间调用 Bitcoin Core 的 `submitpackage` RPC 命令来实现一父一子（1p1c）[包中继][topic package relay]，同时广播承诺交易及其锚点。这允许承诺交易传播，即使它们的手续费率低于交易池最低要求，但需要连接到运行 Bitcoin Core 28.0 或更高版本的对等节点。这一变更消除了动态设置承诺交易手续费率的需要，并确保当节点对当前手续费率有分歧时，强制关闭不会被卡住。

- [Eclair #3045][] 使外部洋葱载荷中的 `payment_secret` 字段对单部分[蹦床支付][topic trampoline payments]是可选的。以前，每个蹦床支付都包括一个 `payment_secret`，即使没有使用[多路径支付][topic multipath payments]（MPP）。由于在处理现代 [BOLT11][] 发票时可能需要支付密钥，如果没有提供，Eclair 在解密时插入一个虚拟密钥。

- [LDK #3670][] 添加了处理和接收[蹦床支付][topic trampoline payments]的支持，但尚未实现提供蹦床路由服务。这是 LDK 计划部署的一种[异步支付][topic async payments]类型的先决条件。

- [LND #9620][] 通过添加必要的参数和区块链常量（如其创世哈希）来添加 [testnet4][topic testnet] 支持。

{% include references.md %}
{% include linkers/issues.md v=2 issues="31363,31278,3050,2963,3045,3670,9620,32080" %}
[bitcoin core 29.0rc3]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[bcc29 testing guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/29.0-Release-Candidate-Testing-Guide
[lnd 0.19.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc1
[back crsig]: https://bitcointalk.org/index.php?topic=206303.msg2162962#msg2162962
[bip119 prechange]: https://github.com/bitcoin/bips/blob/9573e060e32f10446b6a2064a38bdc2047171d9c/bip-0119.mediawiki
[news75 ctv]: /zh/newsletters/2019/12/04/#op-checktemplateverify-ctv
[news190 recursive]: /en/newsletters/2022/03/09/#limiting-script-language-expressiveness
[modern ctv]: /zh/newsletters/2019/12/18/#proposed-changes-to-bip-ctv
[rubin enumeration]: https://gnusha.org/pi/bitcoindev/CAD5xwhjj3JAXwnrgVe_7RKx0AVDDy4X-L9oOnwhswXAQFoJ7Bw@mail.gmail.com/
[towns ctvmot]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Z8eUQCfCWjdivIzn@erisian.com.au/
[mn recursive]: https://mutinynet.com/address/tb1p0p5027shf4gm79c4qx8pmafcsg2lf5jd33tznmyjejrmqqx525gsk5nr58
[rubin recurse]: https://gnusha.org/pi/bitcoindev/CAD5xwhjsVA7k7ZQ_QdrcZOxdi+L6L7dvqAj1Mhx+zmBA3DM5zw@mail.gmail.com/
[osuntokun enum]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAO3Pvs-1H2s5Dso0z5CjKcHcPvQjG6PMMXvgkzLwXgCHWxNV_Q@mail.gmail.com/
[towns enum]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Z8tes4tXo53_DRpU@erisian.com.au/
[ctv spookchain]: https://github.com/bitcoin/bips/pull/1792/files#diff-aaa82c3decf53fb4312de88fbb3cc081da786b72387c9fec7bfb977ad3558b91R589-R593
[ivgi minsc]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAGXD5f3EGyUVBc=bDoNi_nXcKmW7M_-mUZ7LOeyCCab5Nqt69Q@mail.gmail.com/
[minsc]: https://min.sc/
[poinsot alt]: https://mailing-list.bitcoindevs.xyz/bitcoindev/1JkExwyWEPJ9wACzdWqiu5cQ5WVj33ex2XHa1J9Uyew-YF6CLppDrcu3Vogl54JUi1OBExtDnLoQhC6TYDH_73wmoxi1w2CwPoiNn2AcGeo=@protonmail.com/
[moonsettler express]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Gfgs0GeY513WBZ1FueJBVhdl2D-8QD2NqlBaP0RFGErYbHLE-dnFBN_rbxnTwzlolzpjlx0vo9YSgZpC013Lj4SI_WZR0N1iwbUiNze00tA=@protonmail.com/
[obeirne readiness]: https://mailing-list.bitcoindevs.xyz/bitcoindev/45ce340a-e5c9-4ce2-8ddc-5abfda3b1904n@googlegroups.com/
[nick dlc]: https://gist.github.com/jonasnick/e9627f56d04732ca83e94d448d4b5a51#dlcs
[lava 30m]: https://x.com/MarediaShehzan/status/1896593917631680835
[news322 csv-bitvm]: /zh/newsletters/2024/09/27/#shielded-clientside-validation-csv
[news253 ark 0conf]: /zh/newsletters/2023/05/31/#making-internal-transfers
[clark doc]: https://ark-protocol.org/intro/clark/index.html
[oor doc]: https://ark-protocol.org/intro/oor/index.html
[lopp destroy]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CADL_X_cF=UKVa7CitXReMq8nA_4RadCF==kU4YG+0GYN97P6hQ@mail.gmail.com/
[boris timelock]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAFC_Vt54W1RR6GJSSg1tVsLi1=YHCQYiTNLxMj+vypMtTHcUBQ@mail.gmail.com/
[habovstiak gfsig]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CALkkCJY=dv6cZ_HoUNQybF4-byGOjME3Jt2DRr20yZqMmdJUnQ@mail.gmail.com/
[news141 gfsig]: /zh/newsletters/2021/03/24/#taproot-improvement-in-post-qc-recovery-at-no-onchain-cost
[guy fawkes signature scheme]: https://www.cl.cam.ac.uk/archive/rja14/Papers/fawkes.pdf
[fournier gfsig]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CALkkCJYaLMciqYxNFa6qT6-WCsSD3P9pP7boYs=k0htAdnAR6g@mail.gmail.com/T/#ma2a9878dd4c63b520dc4f15cd51e51d31d323071
[wuille nonpublic]: https://mailing-list.bitcoindevs.xyz/bitcoindev/pXZj0cBHqBVPjkNPKBjiNE1BjPHhvRp-MwPaBsQu-s6RTEL9oBJearqZE33A2yz31LNRNUpZstq_q8YMN1VsCY2vByc9w4QyTOmIRCE3BFM=@wuille.net/T/#mfced9da4df93e56900a8e591d01d3b3abfa706ed
[cruz qramp]: https://mailing-list.bitcoindevs.xyz/bitcoindev/08a544fa-a29b-45c2-8303-8c5bde8598e7n@googlegroups.com/
[news347 bip119]: /zh/newsletters/2025/03/28/#bips-1792
[roose ctvcsfs]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/
[poinsot ctvcsfs1]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/4
[10101 shutdown]: https://10101.finance/blog/10101-is-shutting-down
[towns vaults]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/14
[obeirne ctv-vaults]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/23
[sanders bitvm]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/7
[obeirne liquid]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/24
[kanjalkar liquid]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/28
[poelstra liquid]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/32
[news284 lnsym]: /zh/newsletters/2024/01/10/#ln-symmetry-research-implementation-ln-symmetry
[sanders versus]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/7
[towns nonrepo]: https://delvingbitcoin.org/t/ctv-csfs-can-we-reach-consensus-on-a-first-step-towards-covenants/1509/14
[roose ctv-ark]: https://codeberg.org/ark-bitcoin/bark/src/branch/ctv
[roose ctv-for-ark]: https://delvingbitcoin.org/t/the-ark-case-for-ctv/1528/
[roose ctv-ark-ln]: https://delvingbitcoin.org/t/the-ark-case-for-ctv/1528/5
[harding ctv-ark-ln]: https://delvingbitcoin.org/t/the-ark-case-for-ctv/1528/8
[news256 ln-jit]: /zh/newsletters/2023/06/21/#jit
[ruffing gfsig]: https://gnusha.org/pi/bitcoindev/1518710367.3550.111.camel@mmci.uni-saarland.de/
[cruz bip]: https://github.com/chucrut/bips/blob/master/bip-xxxxx.md
[towns anticov]: https://gnusha.org/pi/bitcoindev/20220719044458.GA26986@erisian.com.au/
[ccv bip]: https://github.com/bitcoin/bips/pull/1793
[ingala ccv]: https://delvingbitcoin.org/t/op-checkcontractverify-and-its-amount-semantic/1527/
[news319 64byte]: /zh/newsletters/2024/09/06/#mitigating-merkle-tree-vulnerabilities
[poinsot nsequence]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/79
[provoost bridge]: https://mailing-list.bitcoindevs.xyz/bitcoindev/19f6a854-674a-4e4d-9497-363af306e3a0@app.fastmail.com/
[poinsot cleanup]: https://mailing-list.bitcoindevs.xyz/bitcoindev/uDAujRxk4oWnEGYX9lBD3e0V7a4V4Pd-c4-2QVybSZNcfJj5a6IbO6fCM_xEQEpBvQeOT8eIi1r91iKFIveeLIxfNMzDys77HUcbl7Zne4g=@protonmail.com/
[cleanup bip]: https://github.com/darosior/bips/blob/consensus_cleanup/bip-cc.md
[news312 chilldkg]: /zh/newsletters/2024/07/19/#distributed-key-generation-protocol-for-frost
[fnr secp]: https://mailing-list.bitcoindevs.xyz/bitcoindev/d0044f9c-d974-43ca-9891-64bb60a90f1f@gmail.com/
[secp256k1lab]: https://github.com/secp256k1lab/secp256k1lab
[corallo eltoo]: https://x.com/TheBlueMatt/status/1857119394104500484
[bdk wallet 1.2.0]: https://github.com/bitcoindevkit/bdk/releases/tag/wallet-1.2.0
[ldk v0.1.2]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.2
[news341 pr review]: /zh/newsletters/2025/02/14/#bitcoin-core-pr-审核俱乐部
