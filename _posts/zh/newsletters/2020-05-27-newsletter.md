---
title: 'Bitcoin Optech Newsletter #99'
permalink: /zh/newsletters/2020/05/27/
name: 2020-05-27-newsletter-zh
slug: 2020-05-27-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了关于允许的最小交易大小的讨论，此外还有我们的常设栏目：Bitcoin Stack Exchange 精选问答、发布与候选发布，以及比特币基础设施项目中值得注意的合并。

## 行动项

*本周无。*

## 新闻

- **<!--minimum-transaction-size-discussion-->****最小交易大小讨论：** Thomas Voegtlin 在 Bitcoin-Dev 邮件列表上[发帖][voegtlin min]，讨论如何构造剥离大小（非见证大小）小到 60 字节的交易。Bitcoin Core 拒绝中继或打包[小于 82 字节的交易][min nonwit]。Gregory Sanders [指出][sanders cve]，这条规则的动机是 [CVE-2017-12842][]（在 [Newsletter #27][news27 cve-2017-12842] 中介绍过）：如果攻击者能让一笔特制的 64 字节交易被确认进区块，就能借此让 SPV 轻量客户端相信另有一笔或多笔任意交易已经确认，例如伪造的、向轻量钱包付款的交易。正如 [Newsletter #36][news36 tree attacks] 中所述，[共识清理软分叉][topic consensus cleanup]提议禁止剥离大小少于 65 字节的交易，从而永久消除发动这种攻击的能力。

  在说明当前中继规则的动机之后，Sanders [询问][sanders 64]这条规则能否简化为只禁止剥离大小恰好为 64 字节的交易。ZmnSCPxj [回复][zmn padding]说，任何小于 64 字节的交易仍可能存在漏洞，但“65 字节及以上”这条规则看起来没问题。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-are-the-sizes-of-single-sig-and-2-of-3-multisig-taproot-inputs-->**[单签和 2-of-3 多重签名的 taproot 输入大小是多少？]({{bse}}96017)
  Murch 列出了多种从 [taproot][topic taproot] 输出中花费的方式及其相关成本。

- **<!--what-if-the-mempool-exceeds-300-mb-->**[如果内存池超过 300 MB 会怎样？]({{bse}}96068)
  Andrew Chow 和 Murch 概述了节点的内存池达到最大容量后的行为。节点会开始丢弃费率最低的交易，并提高其向对等节点通告的 `minMempoolFeeRate`，以便把内存池大小控制在该节点的 `maxmempool` 配置之内。

- **<!--why-isn-t-rfc6979-used-for-schnorr-signature-nonce-generation-->**[为什么 schnorr 签名的随机数生成没有采用 RFC6979？]({{bse}}95762)
  Pieter Wuille 介绍了使用 [RFC6979][] 的一些缺点，以及为什么 [BIP340][] 采用了一种受 [Ed25519][] 启发的更简单的随机数生成算法。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Bitcoin Core 0.20.0rc2][bitcoin core 0.20.0] 是 Bitcoin Core 下一个大版本的最新候选发布。

- [LND 0.10.1-beta.rc2][] 是 LND 下一个维护版本的最新候选发布。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中值得注意的变更。*

*注意：以下提到的 Bitcoin Core 提交针对其 master 开发分支，因此这些变更很可能要到 0.21 版才会发布，也就是在即将发布的 0.20 版发布约六个月之后。*

- [Bitcoin Core #18956][] 使用 Windows 系统上的 API 要求 Windows 7 或更高版本。从 2018 年 10 月发布的 [Bitcoin Core 0.17][0.17 compat] 起，所有发布说明都声明仅支持 Windows 7 或更高版本。

- [Bitcoin Core #18861][] 阻止节点回应一笔交易的 P2P 协议 `getdata` 请求——只要这笔交易尚未通告给发起请求的对等节点。这可以让监控节点无法绕过 Bitcoin Core 已有的隐私增强行为：在向每个对等节点（或每组对等节点）通告新交易之前，先等待时长略有差异的一段时间，使每笔交易沿不同路径在网络中传播。把每笔交易的传播路径随机化之后，监控节点若想假定最先通告某笔交易的节点就是最先收到它的节点，就没那么可靠了。

- [Bitcoin Core #17681][] 允许钱包即使某个 [BIP32][] HD 钱包种子已不再是钱包当前的活动种子，仍能在内部为该种子派生新地址。这样一来，在节点进行初始区块链下载期间（例如在新启动的节点上恢复钱包备份时），改用新的 HD 种子也是安全的。更新后的代码确保钱包能看到任何发往此前由旧 HD 种子派生地址的支付。

- [Bitcoin Core #18895][] 为返回内存池中单笔交易数据的 RPC（例如 `getrawmempool` 和 `getmempoolentry`）增加了一个 `unbroadcast` 字段，用于指明本地节点的对等节点中是否已有节点请求过该交易的副本（广播跟踪的概述见 [Newsletter #96][news96 unbroadcast]）。此外，`getmempoolinfo` RPC 增加了 `unbroadcastcount` 字段，表示未广播交易的数量。出于隐私考虑，只有当交易是由节点钱包或 `sendrawtransaction` RPC 提交时，才会跟踪其广播状态。

- [Bitcoin Core #18677][] 增加了一个新的 `--enable-multiprocess` 构建配置选项，它会在现有的 `bitcoind` 和 `bitcoin-qt` 二进制文件之外再生成一些二进制文件。目前，新旧二进制文件的唯一区别就是名称。不过，如果 [PR #10102][Bitcoin Core #10102] 被合并，新二进制文件会把节点、钱包和 GUI 的功能拆分成彼此独立的可执行文件，在需要时互相通信。该构建选项目前默认关闭。另见 [Newsletter #39][news39 multiprocess]，那是我们上一次谈到多进程子项目。

- [Bitcoin Core #18594][] 允许 `bitcoin-cli -getinfo` 在多钱包模式下打印每个已加载钱包的余额。

- [C-Lightning #3738][] 增加了对 [BIP174][] 部分签名比特币交易（[PSBT][topic psbt]）的初步支持，并利用了 [libwally 的 PSBT 支持][libwally psbt]。唯一用户可见的变化是 `txprepare` RPC 现在返回交易的 PSBT 形式，但该 PR 在 GitHub 上被标记为朝着新通道双向资助迈出的一步（使用 PSBT 交互式构建注资交易的讨论见 [Newsletter #83][news83 interactive]）。

- [LND #4227][] 从多个包中移除处理原始私钥的代码，为支持硬件钱包签名铺平了道路。彻底移除所有私钥处理这一更大工程，可以在[这里][LND #3929]跟踪进展。

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
