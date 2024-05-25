---
title: 'Bitcoin Optech Newsletter #4'
permalink: /zh/newsletters/2018/07/17/
name: 2018-07-17-newsletter-zh
slug: 2018-07-17-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
version: 1
---
本周的 Newsletter 包括有关 Bitcoin Core 下个主要版本的功能冻结、交易费用上涨、建议的 `SIGHASH_NOINPUT` 标志可能重命名，以及几个值得注意的最近 Bitcoin Core 合并的新闻和行动项。

## 行动项

- **<!--last-chance-to-advocate-->**为即将发布的 Bitcoin Core 0.17 版本中可能包含的几乎准备就绪的新功能进行宣传的最后机会，预计该版本将在 8 月或 9 月发布。[Newsletter #3][newsletter #3] 中提到的功能冻结日期已推迟一周至 7 月 23 日。

## 仪表盘项

- **<!--transaction-fees-increasing-->****交易费用上涨**：对于目标在 12 个区块或更短时间内确认的交易，[建议费用][recommended fees]与上周相比上涨 3 倍。默认设置的节点在其内存池中仍有大量空间，因此这一趋势可能会迅速逆转。建议在费率再次下降或者您可以等待几周时间让合并交易确认之前，谨慎进行低成本的合并交易。

## 新闻

- **<!--coin-selection-groups-discussion-->****币选择组讨论**：本周讨论重点是 Bitcoin Core PR [#12257][]，它为钱包添加了一个选项，使得每次支付给同一地址的任何一个输出时，都会花费支付给该地址的所有输出。这个 PR 的动机是增强隐私，因为否则在不同的交易中花费收到的多个输出将会减少隐私。但这个选项也自动合并输入，经常收到同一地址多次支付的比特币企业可能特别感兴趣。

- **<!--continuing-discussion-about-schnorr-signatures-->****关于 Schnorr 签名的持续讨论**：尚未发现对上周 Newsletter 中[描述][schnorr feature]的提议 BIP 的错误，但两位开发者提出了优化建议，[其中一个][multiparty signatures]因安全考虑而遭到反对，[另一个][rearrange schnorr]可能不会被添加，因为它的微小优化以牺牲另一个微小优化为代价。

- **<!--naming-of-sighash-noinput-->****`SIGHASH_NOINPUT` 的命名**：[BIP118][] 描述了一个新的可选签名哈希标志，不指定它正在花费的比特币集。确定花费是否有效的主要因素是签名脚本（见证人）是否满足公钥脚本（阻碍）的所有条件。

    例如，在旨在增强闪电网络的 [Eltoo][] 智能合约协议中，Alice 和 Bob 用这个新的 sighash 标志签署支付通道中余额的每次变化，这样当他们想关闭通道时，他们中的任何一个人都可以使用最终余额的交易来花费最初余额的交易。

    然而，简单使用这个新 sighash 标志的可能导致意外的资金损失。例如，Alice 收到一些比特币到一个特定地址；然后她使用新的 sighash 标志将这些比特币支付给 Bob。后来，Alice 又收到更多比特币到同一个地址 —— Bob 现在可以通过重用 Alice 之前使用的相同签名来窃取这些比特币。注意，这只影响使用新 sighash 标志的人；它不影响不相关的交易。

    本周在 bitcoin-dev 和 lightning-dev 邮件列表上的[讨论][unsafe sighash]是关于如何命名 sighash 标志，以便开发人员不会在不了解其危险的情况下意外使用它。围绕 `SIGHASH_NOINPUT_UNSAFE` 名称形成了大致的共识。

## 值得注意的 Bitcoin Core 合并

- **<!--n-13072-->****[#13072][]:** `createmultisig` RPC 现在可以创建 P2SH-wrapped 的隔离见证和原生隔离见证地址。

- **<!--n-13543-->****[#13543][]:** 添加了对 RISC-V CPU 架构的支持。

- **<!--n-13386-->****[#13386][]:** 新的专用 SHA256 函数，利用 CPU 扩展和对 Bitcoin Core 使用的特定数据输入的了解（例如非常常见的情况，即输入数据恰好是 64 字节，这在比特币默克尔树的每个计算中都使用）。这可以为新代码适用并且用户的 CPU 支持的情况提供高达 9 倍速提升，与比特币核心 0.16.x 相比。代码主要有助于加速区块验证，无论是在从头同步期间的历史区块还是在正常操作期间的新区块。

- **<!--n-13452-->****[#13452][]:** `verifytxoutproof` RPC 不再容易受到 6 月初公开披露的针对 SPV 证明的特定[昂贵攻击][tx-as-internal-node]的影响。鉴于已知存在大致等效的成本更低的攻击方式，此攻击被认为不太可能。另见合并的 PR [#13451][]，它为 `getblock` RPC 添加了可用于击败该攻击的额外信息。这些都不能缓解实际 SPV 客户端面临的攻击。

- **<!--n-13570-->****[#13570][]:** 新的 `getzmqnotifications` RPC，"返回有关所有活动 ZMQ 通知端点的信息。这对于在 Bitcoin Core 之上构建的软件非常有用。"

- **<!--n-13096-->****[#13096][]:** 将默认转发交易的最大体积从 99,999 vbytes 增加到 100,000 vbytes。

[newsletter #3]: /zh/newsletters/2018/07/10/
[recommended fees]: https://p2sh.info/dashboard/db/fee-estimation?orgId=1&from=now-7d&to=now&var-source=bitcoind
[multiparty signatures]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016215.html
[rearrange schnorr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016211.html
[BIP118]: https://github.com/bitcoin/bips/blob/master/bip-0118.mediawiki
[eltoo]: https://blockstream.com/eltoo.pdf
[unsafe sighash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016187.html
[popular twitter thread]: https://twitter.com/orionwl/status/1014829318986436608
[schnorr feature]: /zh/newsletters/2018/07/10/#特别新闻schnorr-签名提议-bip
[#12257]: https://github.com/bitcoin/bitcoin/pull/12257
[#13072]: https://github.com/bitcoin/bitcoin/pull/13072
[#13543]: https://github.com/bitcoin/bitcoin/pull/13543
[#13386]: https://github.com/bitcoin/bitcoin/pull/13386
[#13452]: https://github.com/bitcoin/bitcoin/pull/13452
[#13451]: https://github.com/bitcoin/bitcoin/pull/13451
[#13570]: https://github.com/bitcoin/bitcoin/pull/13570
[#13096]: https://github.com/bitcoin/bitcoin/pull/13096
[tx-as-internal-node]: https://bitslog.wordpress.com/2018/06/09/leaf-node-weakness-in-bitcoin-merkle-tree-design/