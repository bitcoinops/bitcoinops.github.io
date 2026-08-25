---
title: 'Bitcoin Optech 周报 #416'
permalink: /zh/newsletters/2026/07/31/
name: 2026-07-31-newsletter-zh
slug: 2026-07-31-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报警告了一个严重漏洞，它影响由 COLDCARD 签名设备生成的钱包；此外还概述了 Core Lightning 中两个拒绝服务漏洞的披露情况，并介绍了一个零知识储备证明的概念验证。本期还包括我们的常规栏目：Bitcoin Stack Exchange 精选问答、新版本和候选版本的公告，以及流行比特币基础设施软件的重要代码变更。

## 行动项

- **<!--move-funds-secured-by-coldcard-generated-keys-->****将由 COLDCARD 所生成密钥保护的资金转移出去：** 如果你曾使用 COLDCARD Mk3 生成钱包，那么该钱包收到的任何资金都面临被盗风险，应尽快谨慎转移到不受影响的钱包中。其他 COLDCARD 型号生成的钱包也可能受到影响。详见下文“新闻”栏目。

## 新闻

- **<!--wallets-generated-by-coldcard-at-risk-of-theft-->****由 COLDCARD 生成的钱包面临被盗风险：** 2026 年 7 月 30 日，一些比特币用户发现，他们的 COLDCARD 钱包中的资金已在 7 月 29 日通过一系列意外交易被盗。一天之内，COLDCARD Mk3 固件中的一个 bug 被查明，它会导致钱包生成时使用的熵不足。在撰写本文时，估计损失已超过 1,000 BTC，而且随着事态发展，这一数字可能继续上升。

  Coinkite 发布的[安全公告][coinkite advisory]指出：只要 COLDCARD Mk3 运行的是 4.0.1（2021 年 3 月）或更新的固件（包括目前最新的正式版），它生成的钱包就有被盗风险；除非种子创建时掺入了足够的外部熵（例如私下掷骰 50 次以上），或者钱包另外设置了强口令。公告还指出，使用 5.6.0 之前版本固件的 Mk4 和 Mk5，以及 1.5.0Q 之前版本固件的 Q 设备所生成的种子也受到影响。

  在后续发布的[技术背景说明][coinkite backgrounder]中，Coinkite 将该 bug 归因于 2021 年的一次代码修改：它无意中让种子生成流程改为使用软件 PRNG，而且该 PRNG 由可预测的、设备唯一的数值初始化，而不是使用设备的硬件 RNG。对于未额外掷骰的受影响 Mk3，其生成种子的有效熵大约只有 40 比特，而原本设计目标是 128 比特。受影响的 Mk4、Mk5 和 Q 设备生成的种子更难攻击，因为其中还混入了安全元件的输出；但是，Block 与匿名研究者合作、并与 Coinkite 协调披露的这份[分析][block analysis]发现，只有其中 32 比特熵真正进入了 PRNG 状态，因此这些种子仍然远低于预期的安全水平。

  在前沿 AI 模型的辅助下，多位开发者都能立即复现这种攻击，因此应假定该漏洞已在被积极利用。Block 的分析还指出，运行 4.x 固件的较老 COLDCARD Mk2 也以与 Mk3 相同的程度受到影响；此外，其他随机生成的秘密数据，例如纸钱包私钥和临时种子，也同样受影响。

  事态仍在发展，预计在本周报发布后还会出现更多信息。读者应持续关注 [Coinkite 博客][coinkite blog]及其他信息源的更新。Bitcoin Optech 建议：凡是钱包可能受影响的 COLDCARD 用户，都应尽快谨慎地将资金转移到不受影响的钱包中。在受影响的设备上生成、且未额外掷骰的种子，应视为已经泄露。Mk4、Mk5 和 Q 设备用户在生成任何新钱包之前，都应先升级到已修复的固件。仅仅升级固件，并不能让已有种子重新变得安全。

- **<!--disclosure-of-two-dos-vulnerabilities-in-core-lightning-->****Core Lightning 中两个 DoS 漏洞的披露：** Chandra Pratap 在 Delving Bitcoin 上[发帖][cln vuln del]，介绍了他在 [Summer of Bitcoin][sob] 实习期间于 Core Lightning 中发现的两个拒绝服务（DoS）漏洞。具体来说，这两个漏洞原本都可以让攻击者通过耗尽节点内存使其崩溃。这些 bug 与 `gossipd` 守护进程的状态机有关，尤其涉及它与 `connectd` 守护进程之间的接口。Pratap 能发现这些漏洞，得益于他为新的模糊测试目标 `fuzz-gossipd-connectd` 所做的工作；这个目标旨在测试这两个模块之间通信的健壮性。

  第一个漏洞与这两个守护进程共用的守护进程间消息队列有关；该队列的目标是存储所有从网络收到的 `channel_update` 消息。攻击者原本可以向节点大量灌入消息，使内部队列无限增长，最终耗尽全部可用 RAM。这个 bug 已在 [Core Lightning #8376][] 中通过允许队列丢弃消息得到简单修复，并把上限设置为 500,000 条消息。

  第二个漏洞是在尝试修复第一个漏洞时发现的。它涉及一个内部映射，该映射用于追踪未知的短通道 ID（SCID），以便向对等节点查询是否存在缺失的通道。攻击者原本可以向节点灌入伪造的 SCID，导致内存消耗持续增长。尽管此前没有人报告过这个 bug，但 Rusty Russell 当时已经在 [Core Lightning #8903][] 上编写补丁；该补丁为这个内部映射引入了更好的垃圾回收机制。

- **<!--proof-of-concept-for-a-zero-knowledge-proof-of-reserves-->****零知识储备证明的概念验证：** fabohax [发帖][zkpoh del]，介绍 zkPoH（“zero-knowledge proof-of-hodl”），这是一个面向比特币的、非托管[储备证明][topic proof of reserves]系统的概念验证。这个原型允许用户在不泄露更多信息的前提下，证明自己控制着一组 UTXO，而且它们的总价值至少为 100,000,000 sats（1 BTC）。

  这个概念验证以链下生成的一份 UTXO 快照作为输入，然后将其承诺到一棵默克尔树中，树根成为公开承诺。证明者从这份快照中选出最多四个 UTXO，并为 [Noir][noir lang] 电路生成见证输入；该电路会验证：所选 UTXO 确实属于这份快照、默克尔路径有效，以及这些 UTXO 的总和至少达到要求金额。验证者只会得知：证明者满足 100,000,000 sats 这一条件。

  在撰写本文时，这个概念验证还没有提供显式的所有权绑定步骤。这意味着，目前还没有办法证明所选 UTXO 确实属于证明者本人。作者正在增加这一能力，方式可能是在电路外检查所有权，也可能是直接在电路内部实现。这个原型目前已发布在一个专门的[代码仓库][zkpoh gh]中。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者查找问题答案的首选之地——也是我们在闲暇时帮助好奇或困惑用户的地方。在这个月度专题中，我们重点介绍自上次更新以来投票最高的部分问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [比特币对“交易中立性”的客观定义是什么？]({{bse}}130849)
  Ava Chow 将中立性界定为：某项变更是否会阻止任何人继续像原来那样使用比特币，例如让原本可花费的脚本变得不可花费，或者破坏一种已经部署的协议。

- [为什么 BIP110 的去中心化收益不足以抵消它对交易中立性的影响？]({{bse}}130848)
  Pieter Wuille 认为，让携带数据的交易模式失效并不会降低节点成本，因为区块重量限制本来就已经给资源使用设定了上界，数据存储字节是最便宜的处理对象之一，而被禁止的模式也只会被其他交易取代。

- [如果 BIP110 节点会拒绝不发信号的区块，为什么它还需要 55% 的发信号门槛？]({{bse}}130885)
  Vojtěch Strnad 解释说，这个门槛适用于强制发信号期开始之前，矿工自愿发信号的阶段（见[周报 #392][news392 bip110]）。如果能提早锁定，就说明支持更广，也能让软分叉更早激活；但一旦进入强制发信号期，执行该规则的节点就会丢弃不发信号的区块。

- [为什么 BIP324 要使用 ElligatorSwift 编码？]({{bse}}130887)
  Pieter Wuille 解释说，将握手所用的公钥编码为均匀随机字节，可以让整个 [v2 传输][topic v2 p2p transport]字节流呈现伪随机特征，从而避免被模式匹配识别出来，并迫使实施审查的防火墙要么发动完整的中间人攻击，要么只能维护一份允许列表（allowlist）。这样也会更容易去模仿其他协议。

- [BIP342 中保留 OP_SUCCESSx 的设计，是否针对某些特定的操作码家族？]({{bse}}130670)
  Murch 将 `OP_SUCCESS` 操作码描述为通用的升级挂钩。由于任何 `OP_SUCCESS` 都会让一个 [tapscript][topic tapscript] 无条件有效，未来的软分叉可以把其中某个操作码重新定义为更受限制的行为，包括那些重新定义后的 `OP_NOP` 操作码永远做不到的栈操作。

- [长期费率与丢弃费率之间有什么区别？]({{bse}}130861)
  Murch 澄清说，这两者不能互换。丢弃费率决定了潜在找零输出在何种数值以下会被视为 dust、并将其价值直接记入手续费；而长期费率决定了钱包在执行[币选择][topic coin selection]时，何时应偏向归集、何时应偏向节省。

- [在已修剪节点上，将传统钱包迁移为描述符钱包的最快方法是什么？]({{bse}}130713)
  Pol Espinasa 解释说，迁移流程会尝试加载迁移后的钱包；如果节点已修剪掉该钱包诞生高度（birthday）之前的区块，这一步就会失败。[Bitcoin Core #35266][]（见[周报 #412][news412 migratewallet]）预计会包含在 32.0 版中，它允许在不加载钱包的情况下完成迁移；不过，要加载迁移后的[描述符][topic descriptors]钱包，仍然需要节点持有相关区块。

- [在高手续费时期，是否有孤块/陈旧区块率的历史数据？]({{bse}}130889)
  0xB10C 给出了 bitcoin-data 项目维护的[陈旧区块数据集][stale blocks site]；它展示了陈旧区块率随时间变化的图表，并提供[原始数据][stale blocks repo]，可据以推导自定义指标。

## 版本和候选版本

_流行比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。_

- [BTCPay Server 2.4.1][] 是这一自托管支付处理器的维护版本。它增加了 [BIP329][] 钱包标签导入（见[周报 #415][news415 labels]）、可编辑的发票备注，以及其他若干改进和 bug 修复。

- [Eclair 0.14.1][] 是这一闪电网络节点实现的维护版本。它现在要求搭配 Bitcoin Core 31.x，禁用了一个实验性的 [BOLT12][topic offers] 盲化路径手续费折扣；该折扣与[多路径支付][topic multipath payments]配合时无法正确工作。这个版本还包含若干 bug 修复和性能改进。使用自定义 offer-handler 插件的运维者应查阅其[发布说明][eclair 0.14.1 notes]。

## 重大的代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #34628][] 用按数量和序列化大小的令牌桶控制的全局入站与出站积压队列，替换了彼此独立、按对等节点维护的交易中继积压队列。这减少了各对等节点之间的重复存储与排序，而重复存储与排序正是此前 CPU 耗尽问题的成因之一（见[周报 #324][news324 inv]）。对于入站对等节点积压队列，中继额度初始为 420 个交易令牌和 12 MB，并按每秒 14 笔交易、20 kB 的速率补充。数量余额上限为 420 个令牌，而大小余额最多可累积到 50 MB。出站方向的补充速率保留了[周报 #373][news373 rate]所描述的 2.5 倍乘数。当中继需求超过可用额度时，交易会在满足依赖关系的前提下按挖矿分数排序。随后，被选中的交易会进入各对等节点各自的小型随机化队列。新的 `getnetworkinfo` 字段会公开每个积压队列及其令牌余额，而仅供调试的 `-txsendrate` 选项允许测试不同的数量速率。

- [Bitcoin Core #28463][] 将默认最大连接数从 125 提高到 200，并增加了 `-inboundrelaypercent` 选项（默认值为 50），用来限制入站槽位中最多可有多大比例被中继交易的对等节点占用。默认情况下，节点有 11 个出站槽位，因此剩下 189 个槽位可供入站连接使用；在默认设置下，其中最多 94 个可由中继交易的对等节点占据。这个限制会在对等节点宣告其中继偏好后执行；如果该对等节点后来通过 [BIP37][] 消息启用了交易中继，也会重新检查这一限制。这为低带宽区块中继保留了容量，并为今后增加更多仅区块中继的出站连接做准备，以提高对[日蚀攻击][topic eclipse attacks]的抵抗力。

- [Bitcoin Core #32800][] 为多个 RPC 增加了显式的 [BIP141][] 交易大小字段，以及按策略调整后的交易大小字段。`vsize_bip141` 报告根据交易重量计算出的虚拟大小，而 `vsize_adjusted` 报告该值与当前 `-bytespersigop` 策略下、由交易 sigops 成本推导出的大小两者中的较大者。调整后的这个值会用于交易池策略和区块模板费率计算。`getmempoolentry`、详细模式的 `getrawmempool`、`testmempoolaccept` 以及 `submitpackage` 现在都会报告这两个字段。现有的 `vsize` 字段，虽然文档一直说它表示 BIP141 虚拟大小，但实际上存放的是按策略调整后的值；这个字段会保留，但已被标记为弃用。此外，如果交易位于交易池中，`getrawtransaction` 也会报告 `vsize_adjusted`，而其现有的 `vsize` 仍表示 BIP141 值。`getorphantxs` 的详细输出现在也增加了显式的 `vsize_bip141` 字段。

- [Bitcoin Core #34683][] 增加了一份自动生成的 [OpenRPC 1.4.1][] RPC 接口描述。新的 `rpc.discover` RPC 会返回公开接口，而 `getopenrpcinfo` 则可以选择性包含隐藏的命令和参数。这份文档会在运行时根据所有已注册 RPC 的 `RPCHelpMan` 元数据生成，描述方法参数、必需值与默认值、返回结果形状以及其他接口细节。

- [Bitcoin Core #33014][] 修复了 `descriptorprocesspsbt`（见[周报 #253][news253 descriptorpsbt]）处理某类 [PSBT][topic psbt] 的方式：这类 PSBT 的最终脚本字段已经填充，但其中包含无效签名。此前，这个 RPC 只检查最终脚本是否存在，于是会把 PSBT 标记为 complete，随后在提取交易失败时返回内部错误。现在，它会在报告完成前验证每一个输入，因此，若某个 PSBT 含有无效签名，就会返回 `complete: false`，且 `hex` 字段中不会包含序列化交易。

- [Eclair #3325][] 现在接受包含 `reply_path` 的 [BOLT12][topic offers] 发票[洋葱消息][topic onion messages]。收款方可以在发票中附加一条[盲化][topic rv routing] reply path，以便付款方在认为发票无效时返回一个 `invoice_error`。Eclair 之前会拒绝这种组合，因此与 LDK 发生互操作性问题；LDK 此前已为发票加入了 reply path（见[周报 #321][news321 replypath]）。

- [BOLTs #1346][] 规定了 [BOLT12][topic offers] payer proof：这是一种收据格式，允许[付款人证明][topic proof of payment]自己支付过某张发票，凭据是支付原像、出票节点的签名以及来自 `invreq_payer_id` 的付款人签名；同时又允许为了隐私省略若干选定的发票字段。该规范分配了 `lnp` 人类可读前缀，并增加了生成与验证测试向量。Core Lightning 曾实验性实现过一个更早的草案版本（见[周报 #405][news405 proof]）。

- [BOLTs #1344][] 将[可归因失败][topic attributable failures]协议扩展到成功支付场景：它在返回支付原像并结算 [HTLC][topic htlc] 的 `update_fulfill_htlc` 消息中，增加了一个可选的 `fulfillment_payload`。目前只定义了一个填充字段，因此这个 PR 建立的是传输通道，为将来承载与成功支付相关的数据做准备，例如带签名的 [keysend][topic spontaneous payments] 收据，但尚未标准化任何具体应用。

- [BOLTs #1343][] 为那些只接受来自通道对等节点的[洋葱消息][topic onion messages]的节点，增加了 `option_onion_messages_only_channels` 特性比特。未通告该特性的节点，应当接受来自非通道对等节点的洋葱消息，尽管它们仍然可以对这些消息限速或直接丢弃。这个特性使发送者能够避开那些已知会失败的中继路径，同时也让运维者能够降低自己暴露在拒绝服务攻击下的风险。关于 LDK 为应对 LND“接收但不转发来自非通道对等节点的洋葱消息”这一行为所采取的变通方案，可参见[周报 #409][news409 onion]。

{% include snippets/recap-ad.md when="2026-08-04 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8376,8903,35266,34628,28463,32800,34683,33014,3325,1346,1344,1343" %}

[news392 bip110]: /zh/newsletters/2026/02/13/#bips-2017
[news412 migratewallet]: /zh/newsletters/2026/07/03/#bitcoin-core-35266
[stale blocks site]: https://bitcoin-data.github.io/stale-blocks/
[stale blocks repo]: https://github.com/bitcoin-data/stale-blocks
[cln vuln del]:https://delvingbitcoin.org/t/vulnerability-disclosure-twin-memory-exhaustion-dos-vulnerabilities-in-core-lightning/2731
[sob]:https://www.summerofbitcoin.org/
[zkpoh del]: https://delvingbitcoin.org/t/zkpoh-zero-knowledge-proof-of-hodl/2699
[noir lang]: https://noir-lang.org/
[zkpoh gh]: https://github.com/fabohax/zkPoH
[BTCPay Server 2.4.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.1
[Eclair 0.14.1]: https://github.com/ACINQ/eclair/releases/tag/v0.14.1
[eclair 0.14.1 notes]: https://github.com/ACINQ/eclair/blob/v0.14.1/docs/release-notes/eclair-v0.14.1.md
[OpenRPC 1.4.1]: https://spec.open-rpc.org/
[news415 labels]: /zh/newsletters/2026/07/24/#btcpay-server-7457
[news324 inv]: /zh/newsletters/2024/10/11/#dos-from-large-inventory-sets
[news373 rate]: /zh/newsletters/2025/09/26/#bitcoin-core-28592
[news253 descriptorpsbt]: /zh/newsletters/2023/05/31/#bitcoin-core-25796
[news321 replypath]: /zh/newsletters/2024/09/20/#ldk-3163
[news405 proof]: /zh/newsletters/2026/05/15/#core-lightning-9116
[news409 onion]: /zh/newsletters/2026/06/12/#ldk-4647
[coinkite advisory]: https://blog.coinkite.com/coldcard-mk3-seed-generation-warning/
[coinkite blog]: https://blog.coinkite.com/
[coinkite backgrounder]: https://blog.coinkite.com/entropy-technical-backgrounder/
[block analysis]: https://engineering.block.xyz/blog/predictable-rng-fallback-and-32-bit-reseed-in-coldcard-firmware
