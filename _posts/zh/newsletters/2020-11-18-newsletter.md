---
title: 'Bitcoin Optech Newsletter #124'
permalink: /zh/newsletters/2020/11/18/
name: 2020-11-18-newsletter-zh
slug: 2020-11-18-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 包含关于后门虚拟机镜像的警告。同时还包括我们的常规部分，总结了对客户端和服务的值得注意的改进、发布与候选发布的公告，以及对流行的比特币基础设施软件的更改。

## 行动项

- **<!--backdoored-vm-images-->****后门虚拟机镜像：** 一位 Reddit 用户[发帖][reddit vm post]称自己在使用了一个已安装并同步到最近区块的比特币全节点 AWS 镜像后丢失了资金。虽然在讨论中未完全确定丢失的具体原因，但有人建议虚拟机镜像或其他软件集合（特别是面向比特币或其他加密货币的软件）可能为传递后门软件提供了有效途径。这提醒我们只能从可信来源安装软件。此外，请记住您的虚拟机提供商及其支持人员可能可以访问您服务器上的任何私钥，即使您在安全的其他方面做到完美无缺。简而言之，请对任何用于创建不可逆转的比特币交易的软件或服务进行额外的审查。

## 新闻

*本周无重要的比特币技术新闻。*

## 服务和客户端软件的更改

*在本月特刊中，我们重点介绍了比特币钱包和服务的有趣更新。*

- **<!--sparrow-wallet-adds-payment-batching-and-payjoin-->****Sparrow Wallet 增加了支付批处理和 payjoin 功能：**
  Sparrow 的最新 [0.9.6][sparrow 0.9.6] 和 [0.9.7][sparrow 0.9.7] 版本分别增加了支付批处理和 [payjoin][topic payjoin] 功能。

- **<!--nunchuk-open-sources-bitcoin-core-backed-multisig-library-->****Nunchuk 开源基于 Bitcoin Core 的多重签名库：**
  开发 [Nunchuk 桌面应用程序][nunchuk website]的团队[发布了 `libnunchuk`][libnunchuk blog]，这是一个利用 Bitcoin Core 现有代码库的 C++ 多重签名库。

## 发布与候选发布

*流行比特币基础设施项目的新版本和候选发布。请考虑升级到新版本或帮助测试候选发布。*

- [C-Lightning 0.9.2rc1][C-Lightning 0.9.2] 是 C-Lightning 下一个维护版本的候选发布，包含新功能、更新选项和错误修复。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [C-Lightning #4168][] 增加了插件能够指定挂钩在另一个插件之前或之后运行的功能。希望确保插件相对加载顺序的插件作者应根据 [此处][C-Lightning getmanifest] 的示例修改其 `getmanifest` 方法的响应。

- [C-Lightning #4171][] 更新了 `hsmtool` 命令，添加了新的 `dumponchaindescriptors` 参数，该参数会打印用于 C-Lightning 链上钱包的密钥和脚本的[输出脚本描述符][topic descriptors]。这些描述符随后可以导入到仅观察钱包中，以跟踪 LN 节点进行的任何链上交易。此功能是为帮助改进 [BTCPay Server's][] 默认热钱包与可选 LN 服务器的集成而[提出的][c-lightning #4110]。

- [Eclair #1599][] 优化了发送[多路径支付][topic multipath payments]时的支出方式，当接收者与支出者共享直接通道时，支出者可明确知道该通道内可发送的具体金额。此更改允许在支付的初始部分分配最多该金额，而无需将其拆分为多个路径。仍需发送的任何余额可继续使用其他路径。

- [LND #4715][] 添加了一个 `--reset-wallet-transactions` 配置参数，将从 LND 钱包中移除所有链上交易，然后重新扫描区块链以重新填充钱包。

- [BOLTs #808][] 增加了一条警告，要求节点不得发布自己的 HTLC 原像，除非它们是支付的最终接收者。此警告可以帮助新的实现避免过早发布原像，这曾导致 CVE-2020-26896（参见 [Newsletter #121][news121 cve-2020-26895]）。

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