---
title: 'Bitcoin Optech Newsletter #354'
permalink: /zh/newsletters/2025/05/16/
name: 2025-05-16-newsletter-zh
slug: 2025-05-16-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了一个影响旧版本 Bitcoin Core 的已修复漏洞。此外还包括我们的常规部分：总结了近期关于更改比特币共识规则的讨论、新版本和候选版本的公告，以及对热门比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--vulnerability-disclosure-affecting-old-versions-of-bitcoin-core-->****影响旧版本 Bitcoin Core 的漏洞披露：** Antoine Poinsot 在 Bitcoin-Dev 邮件列表上[发布][poinsot addrvuln]了一个影响 29.0 之前版本 Bitcoin Core 的漏洞公告。该漏洞最初由 Eugene Siegel [负责任地披露][topic responsible disclosures]，同时还有另一个在[周报 #314][news314 excess addr]中描述的密切相关的漏洞。攻击者可以发送过多的节点地址广告，迫使 32 位标识符溢出，导致节点崩溃。这一问题部分通过限制每个对等节点每十秒钟只能更新一次来缓解，对于默认约 125 个对等节点的限制，除非节点被持续攻击超过 10 年，否则不会发生溢出。<!-- 2**32 * 10 / 125 / (60 * 60 * 24 * 365) --> 该漏洞已在上个月发布的 Bitcoin Core 29.0 中通过使用 64 位标识符完全修复。

## 共识变更

_每月一次的总结比特币共识规则变更提案和讨论的栏目。_

- **<!--proposed-bip-for-64-bit-arithmetic-in-script-->****Script 中 64 位算术的 BIP 提案：** Chris Stewart 向 Bitcoin-Dev 邮件列表[发布][stewart bippost]了一个[草案 BIP][64bit bip]，提议将比特币现有的操作码升级为支持 64 位数值操作。这是他之前研究的延续（参见周报 [#285][news285 64bit]、[#290][news290 64bit] 和 [#306][news306 64bit]）。与早期讨论的一些变化不同，新提案使用与比特币当前使用的相同 compactSize 数据格式的数字。相关的额外[讨论][stewart inout]发生在 Delving Bitcoin 上的两个[主题][stewart overflow]中。

- **<!--proposed-opcodes-for-enabling-recursive-covenants-through-quines-->****通过自我复制脚本启用递归限制条款的操作码提案：** Bram Cohen 在 Delving Bitcoin 上[发布][cohen quine]了一组简单操作码的建议，这些操作码将通过自我复制脚本（[quines][]）实现递归[限制条款][topic covenants]的创建。Cohen 描述了如何使用这些操作码创建一个简单的[保管库][topic vaults]，并提到了他正在开发的一个更高级的系统。

- **<!--description-of-benefits-to-bitvm-from-op-ctv-and-op-csfs-->****BitVM 从 `OP_CTV` 和 `OP_CSFS` 获得的好处描述：** Robin Linus 在 Delving Bitcoin 上[发布][linus bitvm-sf]了关于如果在软分叉中向比特币添加提议的 [OP_CTV][topic op_checktemplateverify] 和 [OP_CSFS][topic op_checksigfromstack] 操作码，[BitVM][topic acc] 可能获得的几项改进。他描述的好处包括增加操作符数量而没有缺点，“将交易大小减少约 10 倍”（降低最坏情况下的成本），以及允许某些合约的非交互式 peg-in。

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND 0.19.0-beta.rc4][] 是这个热门的闪电网络节点的候选版本。可能需要测试的主要改进之一是在合作关闭场景中新的基于 RBF 的手续费提升。

## 重大的代码和文档变更

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #32155][] 更新了内部矿工，通过将 `nLockTime` 字段设置为当前区块高度减一并要求 `nSequence` 字段不是最终值（以强制执行时间锁定）来对 coinbase 交易进行[时间锁定][topic timelocks]。虽然内置矿工通常不在主网上使用，但更新它鼓励矿池在自己的软件中尽早采用这些变更，为 [BIP54][] 中提出的[共识清理][topic consensus cleanup]软分叉做准备。对 coinbase 交易进行时间锁定解决了[重复交易][topic duplicate transactions]漏洞，并将允许取消成本高昂的 [BIP30][] 检查。

- [Bitcoin Core #28710][] 移除了剩余的传统钱包代码、文档和相关测试。这包括仅限传统钱包的 RPC，如 `importmulti`、`sethdseed`、`addmultisigaddress`、`importaddress`、`importpubkey`、`dumpwallet`、`importwallet` 和 `newkeypool`。作为移除传统钱包的最后一步，BerkeleyDB 依赖和相关函数也被移除。然而，为了执行钱包迁移到[描述符][topic descriptors]钱包，保留了最少量的传统代码和一个独立的 BDB 解析器（参见周报 [#305][news305 bdb]）。

- [Core Lightning #8272][] 禁用了连接守护进程 `connectd` 中的 DNS 种子查询对等节点发现回退，以解决由离线 DNS 种子引起的调用阻塞问题。

- [LND #8330][] 在路径查找双峰概率模型中添加了一个小常数（1/c）以解决数值不稳定问题。在由于舍入错误而导致计算失败并产生零概率的边缘情况下，这种正则化通过使模型恢复为均匀分布提供了一个回退方案。这解决了在涉及非常大的通道或不符合双峰分布的通道的场景中出现的归一化错误。此外，该模型现在跳过不必要的概率计算，并自动纠正过时的通道流动性观察和矛盾的历史信息。

- [Rust Bitcoin #4458][] 用新添加的 `BlockMtp` 和已有的 `BlockHeight` 的显式对替换了 `MtpAndHeight` 结构，使得在相对[时间锁][topic timelocks]中能更好地建模区块高度和中位时间过去（MTP）值。与 `locktime::absolute::MedianTimePast`（限制为 5 亿以上的值，大约 1985 年之后）不同，`BlockMtp` 可以表示任何 32 位时间戳。这使其适用于理论边缘情况，例如具有不寻常时间戳的链。此更新还引入了 `BlockMtpInterval`，并将 `BlockInterval` 重命名为 `BlockHeightInterval`。

- [BIPs #1848][] 将 [BIP345][] 的状态更新为 `Withdrawn`，因为作者[认为][obeirne vaultwithdraw]其提出的 `OP_VAULT` 操作码已被 [`OP_CHECKCONTRACTVERIFY`][topic matt]（OP_CCV）所取代，后者是一种更通用的[保管库][topic vaults]设计和一种新型[限制条款][topic covenants]。

- [BIPs #1841][] 合并了 [BIP172][]，该提案建议正式将比特币的不可分割基本单位定义为“聪”（satoshi），反映当前广泛使用的情况，并帮助在应用程序和文档中标准化术语。

- [BIPs #1821][] 合并了 [BIP177][]，该提案建议将“bitcoin”重新定义为表示最小的不可分割单位（通常称为 1 聪），而不是 100,000,000 个单位。该提案认为，将术语与实际基本单位对齐将减少由任意小数约定引起的混淆。

{% include references.md %}
{% include linkers/issues.md v=2 issues="32155,28710,8272,8330,4458,1848,1841,1821" %}
[lnd 0.19.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc4
[news314 excess addr]: /zh/newsletters/2024/08/02/#addr
[stewart bippost]: https://groups.google.com/g/bitcoindev/c/j1zEky-3QEE
[64bit bip]: https://github.com/Christewart/bips/blob/2025-03-17-64bit-pt2/bip-XXXX.mediawiki
[news285 64bit]: /zh/newsletters/2024/01/17/#proposal-for-64-bit-arithmetic-soft-fork-64
[news290 64bit]: /zh/newsletters/2024/02/21/#continued-discussion-about-64-bit-arithmetic-and-op-inout-amount-opcode-64-op-inout-amount
[news306 64bit]: /zh/newsletters/2024/06/07/#updates-to-proposed-soft-fork-for-64-bit-arithmetic
[stewart inout]: https://delvingbitcoin.org/t/op-inout-amount/549/4
[stewart overflow]: https://delvingbitcoin.org/t/overflow-handling-in-script/1549
[poinsot addrvuln]: https://mailing-list.bitcoindevs.xyz/bitcoindev/EYvwAFPNEfsQ8cVwiK-8v6ovJU43Vy-ylARiDQ_1XBXAgg_ZqWIpB6m51fAIRtI-rfTmMGvGLrOe5Utl5y9uaHySELpya2ojC7yGsXnP90s=@protonmail.com/
[cohen quine]: https://delvingbitcoin.org/t/a-simple-approach-to-allowing-recursive-covenants-by-enabling-quines/1655/
[linus bitvm-sf]: https://delvingbitcoin.org/t/how-ctv-csfs-improves-bitvm-bridges/1591/
[quines]: https://zh.wikipedia.org/wiki/%E8%87%AA%E7%94%A2%E7%94%9F%E7%A8%8B%E5%BC%8F
[news305 bdb]: /zh/newsletters/2024/05/31/#bitcoin-core-26606
[obeirne vaultwithdraw]: https://delvingbitcoin.org/t/withdrawing-op-vault-bip-345/1670/
