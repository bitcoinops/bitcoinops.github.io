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
本期 Newsletter 包含以下主题的新闻与行动项：Bitcoin Core 下一个主要版本的功能冻结、交易手续费上涨、拟议的 `SIGHASH_NOINPUT` 标志可能改名，以及近期几项值得注意的 Bitcoin Core 合并。

## 行动项

- **<!--last-chance-to-advocate-->**这是为任何即将就绪的新功能争取纳入 Bitcoin Core 0.17 的最后机会，该版本预计在 8 月或 9 月发布。[Newsletter #3][newsletter #3] 中提到的功能冻结日期已推迟一周，至 7 月 23 日。

## 仪表盘项

- **<!--transaction-fees-increasing-->****交易手续费上涨：** 对于目标为 12 个区块内或更快确认的交易，[建议费率][recommended fees]最高已涨到上周同期的 3 倍。采用默认设置的节点，其内存池仍有充裕空间，因此这一趋势可能很快逆转。在费率回落之前，请谨慎发起低手续费的合并交易；除非你能接受合并交易可能要等上数周才确认。

## 新闻

- **<!--coin-selection-groups-discussion-->****选币分组讨论：** 本周讨论的是 Bitcoin Core PR [#12257][]，它为钱包增加了一个选项：只要花费支付给同一地址的任何一个输出，就会同时花费支付给该地址的全部输出。这个 PR 的动机之一是增强隐私，否则在不同交易中分别花费收到同一地址的多个输出，就会在这些交易之间建立起削弱隐私的关联。不过该选项也会自动合并输入，对经常在同一地址收到多笔付款的比特币企业可能特别有用。

- **<!--continuing-discussion-about-schnorr-signatures-->****关于 Schnorr 签名的持续讨论：** 上周 Newsletter [介绍][schnorr feature]的这份 BIP 提案尚未发现缺陷，但两位开发者提出了优化方案：[其中一个][multiparty signatures]因安全方面的考量而受阻，[另一个][rearrange schnorr]则可能不会被采纳，因为这一点小幅优化要以去掉另一项小幅优化为代价。

- **<!--naming-of-sighash-noinput-->****`SIGHASH_NOINPUT` 的命名**：[BIP118][] 描述了一种新的可选签名哈希（sighash）标志，它不指明自己花费的是哪一组比特币。判断这笔花费是否有效，主要看签名脚本（见证）是否满足公钥脚本（encumbrance，即约束条件）的全部条件。

    例如，在旨在增强闪电网络的 [Eltoo][] 智能合约协议中，Alice 和 Bob 用这个新的 sighash 标志为支付通道中每一次余额变化签名，这样当他们想关闭通道时，两人中任何一方都可以用记录最终余额的交易去花费记录初始余额的交易。

    然而，不加思索地使用这个新 sighash 标志可能导致意外的资金损失。例如，Alice 收到一些比特币到一个特定地址，随后她用新的 sighash 标志把这些比特币付给 Bob；后来 Alice 又收到更多比特币到同一地址——Bob 这时可以重复使用 Alice 此前的那份签名，把这些比特币偷走。注意，这只影响使用新 sighash 标志的人，不会影响与此无关的交易。

    本周 bitcoin-dev 和 lightning-dev 邮件列表上的[讨论][unsafe sighash]，焦点在于如何给这个 sighash 标志命名，以免开发者在不知其风险的情况下误用。目前似乎已围绕 `SIGHASH_NOINPUT_UNSAFE` 这个名字形成大致共识。

## 值得注意的 Bitcoin Core 合并

- **<!--n-13072-->****[#13072][]:** `createmultisig` RPC 现在可以创建用 P2SH 包装的隔离见证地址和原生隔离见证地址。

- **<!--n-13543-->****[#13543][]:** 添加了对 RISC-V CPU 架构的支持。

- **<!--n-13386-->****[#13386][]:** 新增专门的 SHA256 函数，利用 CPU 扩展指令，并结合 Bitcoin Core 对特定输入数据的已知情况（例如输入数据恰好为 64 字节这一极常见情形，比特币默克尔树的每次计算都是如此）。在新代码适用且用户 CPU 支持的情况下，相比 Bitcoin Core 0.16.x 最高可提速 9 倍。这段代码主要用于加快区块验证，既包括初次同步时的历史区块，也包括正常运行期间的新区块。

- **<!--n-13452-->****[#13452][]:** `verifytxoutproof` RPC 不再受 6 月初公开披露的一种针对 SPV 证明的[昂贵攻击][tx-as-internal-node]影响。由于已知有成本低得多、效果大致相同的攻击手段，这种攻击被认为不太可能被采用。另见已合并的 PR [#13451][]，它为 `getblock` RPC 添加了可用于挫败该攻击的额外信息。这些措施都不能为真正的 SPV 客户端缓解该攻击。

- **<!--n-13570-->****[#13570][]:** 新增 `getzmqnotifications` RPC，“返回所有活动 ZMQ 通知端点的信息。对于构建在 bitcoind 之上的软件很有用。”

- **<!--n-13096-->****[#13096][]:** 将默认中继交易的最大大小从 99,999 vbytes 提高到 100,000 vbytes。

[newsletter #3]: /zh/newsletters/2018/07/10/
[recommended fees]: https://p2sh.info/dashboard/db/fee-estimation?orgId=1&from=now-7d&to=now&var-source=bitcoind
[multiparty signatures]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016215.html
[rearrange schnorr]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016211.html
[BIP118]: https://github.com/bitcoin/bips/blob/master/bip-0118.mediawiki
[eltoo]: https://blockstream.com/eltoo.pdf
[unsafe sighash]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016187.html
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