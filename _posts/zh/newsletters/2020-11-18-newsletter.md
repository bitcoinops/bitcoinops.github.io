---
title: 'Bitcoin Optech Newsletter #124'
permalink: /zh/newsletters/2020/11/18/
name: 2020-11-18-newsletter-zh
slug: 2020-11-18-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 包含一则关于被植入后门的虚拟机镜像的警告。常规部分还包括客户端与服务值得注意的改进总结、发布与候选发布的公告，以及热门比特币基础设施软件的变更。

## 行动项

- **<!--backdoored-vm-images-->****被植入后门的虚拟机镜像：** 一位 Reddit 用户[发帖][reddit vm post]称，自己在使用了一个已经装好比特币全节点、并已同步到近期区块的 AWS 镜像之后丢失了资金。虽然讨论帖中未能完全确定资金损失的来源，但有人提出，虚拟机镜像或其他经过筛选的软件合集——尤其是专为比特币或其他加密货币准备的——是把后门软件投递到有价值服务器上的有效手段。这提醒你：只应从可信来源安装软件。此外请记住，即使你在其他所有安全环节上都做得完美，虚拟机提供商及其支持人员仍很可能可以访问你服务器上的任何私钥。简而言之，对于任何你要托付其创建不可逆比特币交易的软件或服务，请额外做一些尽职调查。

## 新闻

*本周无重要的比特币技术新闻。*

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--sparrow-wallet-adds-payment-batching-and-payjoin-->****Sparrow Wallet 增加支付批处理和 payjoin 功能：**
  Sparrow 近期的 [0.9.6][sparrow 0.9.6] 和 [0.9.7][sparrow 0.9.7] 版本分别加入了支付批处理和 [payjoin][topic payjoin] 能力。

- **<!--nunchuk-open-sources-bitcoin-core-backed-multisig-library-->****Nunchuk 开源由 Bitcoin Core 支撑的多重签名库：**
  开发 [Nunchuk 桌面应用][nunchuk website]的团队[公布了 `libnunchuk`][libnunchuk blog]，这是一个复用 Bitcoin Core 现有代码库的 C++ 多重签名库。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [C-Lightning 0.9.2rc1][C-Lightning 0.9.2] 是 C-Lightning 下一个维护版本的候选发布，包含新功能、选项更新和错误修复。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的变更。*

- [C-Lightning #4168][] 让插件可以指定自己的挂钩（hook）在另一个插件的挂钩之前还是之后运行。想用这种方式确保插件相对加载顺序的插件作者，应按[此处][C-Lightning getmanifest]所示修改其 `getmanifest` 方法的响应。

- [C-Lightning #4171][] 为 `hsmtool` 命令增加了一个新的 `dumponchaindescriptors` 参数，用于打印 C-Lightning 链上钱包所用密钥和脚本的[输出脚本描述符][topic descriptors]。这些描述符随后可以导入仅观察钱包，以跟踪该 LN 节点发起的任何链上交易。这项功能是应[请求][c-lightning #4110]提出的，旨在改善 [BTCPay Server's][] 默认热钱包与可选 LN 服务器之间的集成。

- [Eclair #1599][] 让节点在考虑向通道对手方发送[多路径支付][topic multipath payments]时更智能地安排资金。当收款方与付款方之间直接有通道时，付款方确切知道该通道中还有多少钱可供发送。有了这项改动，最多可以把这笔金额分配给支付的起始部分，而不必把整笔支付拆分到多条路径。仍然需要发送的剩余金额可以继续走其他路径。

- [LND #4715][] 增加了一个 `--reset-wallet-transactions` 配置参数，它会先移除 LND 钱包中的所有链上交易，然后重新扫描区块链以重新填充钱包。

- [BOLTs #808][] 增加了一条警告：除非节点是某笔支付的最终收款方，否则不得泄露自己的 HTLC 原像。这条警告可以帮助新的实现避免过早泄露原像——正是这一问题导致了 CVE-2020-26896（参见 [Newsletter #121][news121 cve-2020-26895]）。

{% include references.md %}
{% include linkers/issues.md issues="4168,4171,1599,4715,808,4110" %}
[C-Lightning 0.9.2]: https://github.com/ElementsProject/lightning/releases/tag/v0.9.2rc1
[reddit vm post]: https://www.reddit.com/r/Bitcoin/comments/jrxgj8/bitcoin_core_node_hacked/
[btcpay server's]: https://github.com/btcpayserver/btcpayserver
[news121 cve-2020-26895]: /zh/newsletters/2020/10/28/#cve-2020-26896-improper-preimage-revelation
[sparrow 0.9.7]: https://github.com/sparrowwallet/sparrow/releases/tag/0.9.7
[sparrow 0.9.6]: https://github.com/sparrowwallet/sparrow/releases/tag/0.9.6
[nunchuk website]: https://nunchuk.io/
[libnunchuk blog]: https://nunchuk.medium.com/announcing-libnunchuk-a-lean-cross-platform-multisig-library-powered-by-bitcoin-core-a2f6e26c54df
[C-Lightning getmanifest]: https://github.com/ElementsProject/lightning/blob/cd7d5cdff9e5efc0dcfb5fdc91e8c80a11daebed/doc/PLUGINS.md#the-getmanifest-method
