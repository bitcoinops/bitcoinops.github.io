---
title: 'Bitcoin Optech Newsletter #71'
permalink: /zh/newsletters/2019/11/06/
name: 2019-11-06-newsletter-zh
slug: 2019-11-06-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 请求帮助测试 Bitcoin Core 候选版本，汇总了关于 LN 锚定输出的持续讨论，并描述了一个允许全节点和轻量级客户端信号支持 IP 地址中继的提议。还包括我们关于值得注意的比特币基础设施项目更改的常规部分。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--help-test-bitcoin-core-release-candidate-->****帮助测试 Bitcoin Core 候选版本：**鼓励有经验的用户帮助测试即将发布的 [Bitcoin Core][Bitcoin Core 0.19.0] 版本的最新候选版本。

## 新闻

- **<!--continued-discussion-of-ln-anchor-outputs-->****关于 LN 锚定输出的持续讨论：**正如[上周的 Newsletter][news70 simplified commitments]中所述，LN 开发者正在努力允许通道的任一方通过 CPFP 提高结算交易的费用，利用预计将在 Bitcoin Core 0.19.0 版本中发布的 CPFP carve-out 内存池策略。本周在[邮件列表][jager anchor]和 [BOLTs 仓库][bolts #688] 中讨论的主题包括：

  - 无论是单方面关闭通道的一方（“本地”一方）还是另一方（“远程”），是否都应在能够领取其资金之前经历相同的延迟，或者他们是否应该在通道创建过程中协商当他们是远程方时使用的延迟时长。目前，只有本地一方存在延迟，担心的是这可能会导致某些人试图操纵另一方关闭通道，以便操纵者能更快地收到他们的资金。

  - 使用何种脚本来处理锚定输出。之前提议的脚本应包含一个条款，允许任何人在适当的延迟后花费它，以防止使用许多小额输出污染 UTXO 集。然而，这被脚本可能需要包含一个第三方无法知道的唯一公钥所复杂化，阻止他们独立生成花费 P2WSH 输出所需的见证脚本。

  - 锚定输出的比特币金额是多少。发起通道打开的一方负责支付这一金额（因为他们负责支付当前协议中的所有费用），所以他们可能希望将其保持较低，但金额必须大于大多数节点的最小输出金额（“粉尘限制”）。讨论是否应将此金额设为可配置。

  - 每笔 LN 支付是否应支付给不同的公钥（使用公钥调整）。提议移除公钥调整以减少所需的状态跟踪量，但有人担心这会使通道状态过于确定。这可能会导致接收到来自通道一方的一系列加密的违规补救交易的看守塔不仅能解密所需的违规补救交易，还能解密该通道中的所有其他违规补救交易，从而使看守塔能够重建每笔支付的金额和哈希锁，显著降低隐私。

  关于上述问题的讨论仍在继续，正在提出解决方案并对该提议进行更多的审查。

- **<!--signaling-support-for-address-relay-->****为地址中继提供支持信号：**全节点使用 P2P 协议的 `addr`（地址）消息与其对等节点共享他们所知道的其他全节点的 IP 地址，从而实现完全去中心化的对等节点发现。SPV 客户端也可以使用此机制了解全节点，尽管大多数客户端目前使用某种形式的集中式节点发现，因此发送给这些客户端的 `addr` 消息浪费了带宽。

  Gleb Naumenko 向 Bitcoin-Dev 邮件列表发送了一封[邮件][naumenko addr relay]，建议节点和客户端应该向他们的对等节点发出信号，表示他们是否希望参与地址中继。这将避免在不需要地址的客户端上浪费带宽，并且可以更容易确定与地址中继相关的某些网络行为的影响。

  提出了两种允许节点指示他们是否希望参与地址中继的方法——每节点方法和每连接方法。每节点方法可以轻松地基于已经为 addrv2 消息所做的工作（参见 [Newsletter #37][news37 addrv2]），但它的灵活性较低。特别是，每连接方法可以允许一个节点专门用于交易中继的连接和用于地址中继的连接，从而产生可能的隐私优势。Naumenko 的邮件请求开发全节点和轻量级客户端的实现者对哪种方法更合适提出反馈。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #16943][] 添加了一个 `generatetodescriptor` RPC，允许在测试期间生成的新区块（例如在 regtest 模式下）支付给一个由[输出脚本描述符][output script descriptor]表示的脚本。在此更改之前，只有 `generatetoaddress` RPC 可用，并且它只能支付给 P2PKH、P2SH 或 P2WSH 地址。

- [C-Lightning #3220][] 开始始终使用低 *r* 值创建签名，减少了签名的最大大小 1 个字节，并平均每个 C-Lightning 对等节点在链上交易中节省约 0.125 vbytes。Bitcoin Core 也早已在其钱包的签名生成代码中采用了这一更改（参见 [Newsletter #8][news8 lowr]）。

- [LND #3558][] 为两个特定节点之间有多个通道的任何情况综合了一个统一的政策，并在考虑通过这些通道中的任一个进行路由时使用这一统一政策。[BOLT4][bolt4 non-strict rec] 建议同一节点之间的多个通道应使用相同的政策，但这并不总是发生，因此此更改尝试确定节点之间所有政策的“最大公约数”。使用单一政策减少了节点在进行支付时需要评估的路由数量。

- [LND #3556][] 添加了一个新的 `queryprob` RPC，返回给定源节点、目标节点和支付金额的支付成功预期概率。这取代了之前从 `querymc` RPC 中删除的功能。

- [BOLTs #660][] 更新了 [BOLT1][]，为 LN 规范（BOLT 文档）中定义的类型保留了小于 2<sup>16</sup> 的类型-长度-值（TLV）类型标识符。剩余的值可以由任何 LN 实现自由用作自定义记录。更新后的规范还提供了有关如何选择自定义记录类型编号的指导。

{% include linkers/issues.md issues="16943,3558,3556,660,3220,688" %}
[bitcoin core 0.19.0]: https://bitcoincore.org/bin/bitcoin-core-0.19.0/
[bolt4 non-strict rec]: https://github.com/lightningnetwork/lightning-rfc/blob/master/04-onion-routing.md#recommendation
[news37 addrv2]: /zh/newsletters/2019/03/12/#version-2-addr-message-proposed
[news8 lowr]: /zh/newsletters/2018/08/14/#bitcoin-core-wallet-to-begin-only-creating-low-r-signatures
[naumenko addr relay]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-October/017428.html
[news70 simplified commitments]: /zh/newsletters/2019/10/30/#ln-simplified-commitments
[jager anchor]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002264.html
[output script descriptor]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
