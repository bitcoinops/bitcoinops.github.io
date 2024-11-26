---
title: 'Bitcoin Optech Newsletter #99'
permalink: /zh/newsletters/2020/05/27/
name: 2020-05-27-newsletter-zh
slug: 2020-05-27-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了关于最低允许交易大小的讨论，并包含我们常规的 Bitcoin Stack Exchange 精选问答、发布与候选发布以及比特币基础设施项目中的值得注意的合并。

## 行动项

*本周无。*

## 新闻

- **<!--minimum-transaction-size-discussion-->****最低交易大小讨论：**Thomas Voegtlin 在 Bitcoin-Dev 邮件列表中[发布][voegtlin min]了关于创建剥离大小（非见证大小）小至 60 字节的交易的讨论。Bitcoin Core 拒绝中继或挖掘[小于 82 字节的交易][min nonwit]。Gregory Sanders 指出该规则的动机是[编号 CVE-2017-12842 的漏洞][sanders cve]（在 [Newsletter #27][news27 cve-2017-12842] 中进行了描述），在该漏洞中，如果攻击者能够将一个特别构造的 64 字节交易确认进区块，他们可以利用此漏洞说服 SPV 轻量客户端相信一个或多个其他任意交易已被确认，比如伪造支付给轻量钱包的假交易。正如 [Newsletter #36][news36 tree attacks] 中所描述的，通过禁止剥离大小小于 65 字节的交易，已在[共识清理软分叉][topic consensus cleanup]中提议永久消除该攻击的可能性。

  在描述了当前中继规则的动机之后，Sanders [询问][sanders 64]是否可以简化规则，只禁止剥离大小恰好为 64 字节的交易。ZmnSCPxj [回复][zmn padding]说，任何小于 64 字节的交易仍然可能存在漏洞，但 65 字节或更大的规则似乎是合理的。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者们寻找问题答案的首选地点之一——或者当我们有空闲时间时，我们会帮助一些好奇或困惑的用户。在这个每月特色中，我们精选了一些自上次更新以来获得高票的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-are-the-sizes-of-single-sig-and-2-of-3-multisig-taproot-inputs-->**[单签名和 2-of-3 多重签名的 Taproot 输入大小是多少？]({{bse}}96017)
  Murch 列出了多种从 [Taproot][topic taproot] 输出中花费的方式及其相关费用。

- **<!--what-if-the-mempool-exceeds-300-mb-->**[如果内存池超过 300 MB 会怎样？]({{bse}}96068)
  Andrew Chow 和 Murch 概述了当一个节点的内存池达到最大容量时的行为。节点将开始删除手续费率最低的交易，并增加其向对等节点通告的 `minMempoolFeeRate`，以使内存池大小保持在该节点的 `maxmempool` 配置之内。

- **<!--why-isn-t-rfc6979-used-for-schnorr-signature-nonce-generation-->**[为什么 RFC6979 没有用于 Schnorr 签名的随机数生成？]({{bse}}95762)
  Pieter Wuille 描述了使用 [RFC6979][] 的一些缺点，以及为什么 [BIP340][] 采用了受 [Ed25519][] 启发的更简单的随机数生成算法。

## 发布与候选发布

*流行的比特币基础设施项目的新发布与候选发布。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 0.20.0rc2][bitcoin core 0.20.0] 是下一个 Bitcoin Core 主版本的最新候选发布版本。

- [LND 0.10.1-beta.rc2][] 是下一个 LND 维护版本的最新候选发布版本。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

*注意：以下提到的 Bitcoin Core 提交适用于其 master 开发分支，因此这些更改可能不会发布，直到大约在即将发布的 0.20 版本发布六个月后的 0.21 版本。*

- [Bitcoin Core #18956][] 使用 Windows 系统上的 API 来要求 Windows 7 或更高版本。从 2018 年 10 月发布的 [Bitcoin Core 0.17][0.17 compat] 开始，所有发布说明都宣布仅支持 Windows 7 或更高版本。

- [Bitcoin Core #18861][] 阻止节点对尚未向请求对等节点通告的交易进行 P2P 协议 `getdata` 请求的回应。这防止了监控节点绕过 Bitcoin Core 现有的隐私增强行为，即对每个对等节点（或对等节点组）在通告新交易之前等待不同的时间，使得每个交易通过不同的路径传播。随机化每个交易的传播路径，使得监控节点更难以确定首先通告交易的节点是第一个接收到该交易的节点。

- [Bitcoin Core #17681][] 允许钱包即使在 HD 钱包种子不再是当前活动种子的情况下，仍能为 [BIP32][] HD 钱包种子内部派生新地址。这使得在节点执行初始区块链下载时（例如在新启动的节点上恢复钱包备份时）切换到新 HD 种子变得安全。更新后的代码确保钱包将会看到先前从旧 HD 种子派生的任何地址的支付。

- [Bitcoin Core #18895][] 更新了返回内存池中单个交易数据的 RPC（例如 `getrawmempool` 和 `getmempoolentry`），增加了一个 `unbroadcast` 字段，指示本地节点的任何对等节点是否请求了该交易的副本（见 [Newsletter #96][news96 unbroadcast] 中的广播追踪摘要）。此外，`getmempoolinfo` RPC 还增加了一个 `unbroadcastcount` 字段，指示未广播交易的数量。出于隐私考虑，只有当交易是由节点钱包或 `sendrawtransaction` RPC 提交时，才会跟踪交易的广播状态。

- [Bitcoin Core #18677][] 添加了一个新的 `--enable-multiprocess` 构建配置选项，将在现有的 `bitcoind` 和 `bitcoin-qt` 二进制文件之外生成其他二进制文件。目前，新旧二进制文件的唯一区别是名称。然而，如果 [PR #10102][Bitcoin Core #10102] 被合并，新二进制文件将把节点、钱包和 GUI 的功能拆分为必要时彼此通信的单独可执行文件。该构建选项当前默认禁用。另见 [Newsletter #39][news39 multiprocess] 了解我们上次关于多进程子项目的讨论。

- [Bitcoin Core #18594][] 允许 `bitcoin-cli -getinfo` 在多钱包模式下打印每个加载钱包的余额。

- [C-Lightning #3738][] 增加了对 [BIP174][] 部分签名比特币交易（[PSBT][topic psbt]）的初步支持，利用 [libwally 的 PSBT 支持][libwally psbt]。唯一对用户可见的更改是 `txprepare` RPC 返回的交易为 PSBT 形式，但该拉取请求在 GitHub 上被标记为朝着新通道双重资助（见 [Newsletter #83][news83 interactive] 中关于使用 PSBT 进行互动创建资助交易的讨论）迈进的一步。

- [LND #4227][] 从多个包中移除了对原始私钥的处理，为硬件钱包签名支持铺平了道路。移除所有私钥处理的更大努力可以在[这里][LND #3929]跟踪。

{% include references.md %}
{% include linkers/issues.md issues="18956,18861,3738,4227,17681,18895,18677,10102,18594,3929" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[lnd 0.10.1-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.1-beta.rc2
[0.17 compat]: https://bitcoincore.org/en/releases/0.17.0/#compatibility
[min nonwit]: https://github.com/bitcoin/bitcoin/blob/99813a9745fe10a58bedd7a4cb721faf14f907a4/src/policy/policy.h#L25
[voegtlin min]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017883.html
[sanders cve]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017884.html
[sanders 64]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017885.html
[news27 cve-2017-12842]: /zh/newsletters/2018/12/28/#cve-2017-12842
[news36 tree attacks]: /zh/newsletters/2019/03/05/#merkle-树攻击
[news96 unbroadcast]: /zh/newsletters/2020/05/06/#bitcoin-core-18038
[news39 multiprocess]: /zh/newsletters/2019/03/26/#bitcoin-core-10973
[libwally psbt]: https://github.com/ElementsProject/libwally-core/pull/126
[news83 interactive]: /zh/newsletters/2020/02/05/#psbt-interaction
[zmn padding]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-May/017886.html
[RFC6979]:https://tools.ietf.org/html/rfc6979
[Ed25519]:https://ed25519.cr.yp.to/
[cve-2017-12842]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-12842
