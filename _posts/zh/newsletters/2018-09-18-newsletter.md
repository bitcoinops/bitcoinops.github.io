---
title: 'Bitcoin Optech Newsletter #13'
permalink: /zh/newsletters/2018/09/18/
name: 2018-09-18-newsletter-zh
slug: 2018-09-18-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 包括与 Bitcoin Core 0.16.3 和 Bitcoin Core 0.17RC4 的安全发布相关的行动项，新提出的 BIP322，以及 Optech 即将在巴黎举行的研讨会；C-Lightning 0.6.1 发布的链接，更多关于 BIP322 的信息，以及有关 Bustapay 提案的一些细节；加上在流行的比特币基础设施项目中值得注意的合并的简要描述。

## 行动项

- **<!--upgrade-to-bitcoin-core-0-16-3-to-fix-denial-of-service-vulnerability-->****升级到 Bitcoin Core 0.16.3 以修复拒绝服务漏洞：** 在 Bitcoin Core 0.14.0 中引入的一个错误影响了所有随后的版本，直到 0.16.2，当尝试验证包含试图两次花费同一输入的交易的区块时，会导致 Bitcoin Core 崩溃。这样的区块是无效的，因此只能由愿意放弃创建区块所获得的收入（至少 12.5 XBT 或 80,000 美元）的矿工创建。

    [master][dup txin master] 和 [0.16][dup txin 0.16] 分支的补丁昨天提交了公开审查，0.16.3 版本已被标记包含补丁，并且一旦足够数量的知名贡献者复制了确定性构建，二进制文件将可供[下载][core download]——可能是今天（周二）晚些时候。强烈建议立即升级。

- **<!--allocate-time-to-test-bitcoin-core-0-17rc4-->****分配时间测试 Bitcoin Core 0.17RC4：** Bitcoin Core 将很快上传 0.17RC4 的[二进制文件][bcc 0.17]，包含上述 DoS 漏洞的补丁。所有之前版本候选的测试者都应该升级。测试非常受欢迎，并且可以帮助确保最终发布的质量。

- **<!--review-proposed-bip322-for-generic-message-signing-->****审查建议的 BIP322 用于通用消息签名：** 这个[最近提出的][BIP322 proposal] BIP 将允许用户为所有当前使用的比特币地址类型创建签名消息，包括 P2PKH、P2SH、P2SH 封装的 segwit、P2WPKH 和 P2WSH。它有潜力成为几乎所有钱包将实现的行业标准，并可能被许多服务（如点对点市场）以及客户支持所使用，因此 Optech 鼓励分配一些工程时间以确保该提案与贵组织的需求兼容。有关更多详细信息，请参见下面的新闻部分。

- **<!--optech-paris-workshop-workshop-november-12-13-->****[Optech 巴黎研讨会][workshop] 11 月 12-13 日：** 会员公司应[给我们发送电子邮件][optech email]预留工程师的位置。计划的主题包括比较两种提高交易费用的方法、讨论部分签名的比特币交易（[BIP174][]）、输出脚本描述符的介绍、闪电网络钱包集成的建议以及高效币选择的方法（包括输出合并）。

## 新闻

- **<!--c-lightning-0-6-1-released-->****C-Lightning 0.6.1 发布：** 这个小更新带来了几项改进，包括“更少的支付阻塞，更好的路由，更少的无端关闭，以及修复了几个恼人的错误。” [发布公告][c-lightning 0.6.1] 中包含了详细信息和下载链接。

- **<!--bip322-generic-signed-message-format-->****BIP322 通用签名消息格式：** 从 2011 年起，许多钱包的用户就能够使用与他们钱包中的 P2PKH 地址关联的公钥来签署任意消息。然而，对于使用 P2SH 地址或任何类型的隔离见证地址的用户来说，并没有标准化的方法来做到同样的事情（尽管有一些实现了具有限制功能的[非标准方法][trezor p2wpkh message signing]）。Karl-Johan Alm 从几个月前的 Bitcoin-Dev 邮件列表讨论中提出了一个可以适用于任何地址的 BIP [提案][BIP322 proposal]（尽管它还没有描述它将如何适用于涉及 OP_CLTV 或 OP_CSV 时间锁的 P2SH 或 P2WSH 地址）。

    基本机制是，地址的授权支付者或支付者以与他们支付资金时几乎相同的方式生成 scriptSigs 和见证数据（包括他们的签名）——除了他们不是签署支付交易，而是签署他们的任意消息（加上一些预定的额外数据以确保他们不会被欺骗签署一个实际交易）。然后验证者的软件以与确定支付交易是否有效相同的方式验证这些信息。这允许消息签名功能与比特币脚本本身一样灵活。

    目前，讨论似乎最活跃在 BIP 提案的 [PR][BIP322 PR] 上。

- **<!--bustapay-discussion-->****Bustapay 讨论：** 一个相对于在 [Newsletter #8][news8 news] 中描述的 Pay-to-Endpoint (P2EP) 协议的简化替代方案，Bustapay 为支付者和接收者提供了更好的隐私保护——也允许接收者在不增加他们可支付输出数量的情况下接受支付，这是一种自动的 UTXO 合并形式。尽管几周前向 Bitcoin-Dev 邮件列表[提出][bustapay proposal]，本周还[讨论][bustapay sjors]提案的几个方面。

    尽管 P2EP 和 Bustapay 可能最终只由少数钱包和服务实现，类似于 [BIP70][] 支付协议，但它们也有可能像钱包对 [BIP21][] URI 处理程序的支持一样被广泛采纳。即使它们没有得到普遍采纳，它们的隐私优势意味着它们可能在特定用户群体中得到很好的部署。无论哪种情况，跟踪提案和概念验证实现以确保您的组织在需要时能够轻松采用它们可能都值得投入一些工程时间。

## 值得注意的提交

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo] 和 [C-lightning][core lightning repo] 中的值得注意的提交。提醒：新合并到 Bitcoin Core 的代码是提交到其主开发分支的，不太可能成为即将发布的 0.17 版本的一部分——您可能需要等待大约六个月后的 0.18 版本。*

- [Bitcoin Core #14054][]：此 PR 阻止节点默认发送 [BIP61][] 点对点协议[拒绝消息][p2p reject]。这些消息的实现是为了让轻客户端开发者更容易获取关于连接和交易转发问题的反馈。然而，没有要求（或方法来要求）节点发送拒绝消息或准确的拒绝消息，因此这些消息可能只会浪费带宽。

    建议开发者将其测试客户端连接到自己的节点，并在出现问题时检查节点的日志中的错误消息（可能在启用调试日志后）。仍然需要发送 `reject` 消息的用户可以使用 `-enablebip61` 配置选项，尽管 `reject` 消息可能在 0.18 版本之后的某个版本中被完全移除。

- [Bitcoin Core #7965][]：这个长期存在的问题追踪了在 libbitcoin_server 组件中处理是否编译钱包的代码的移除。通过合并 [Bitcoin Core #14168][]，这个问题在本周最终被关闭。这个问题连同许多其他问题，如 [Bitcoin Core #10973][]（重构：将钱包与节点分离）和 [Bitcoin Core #14180][]（即使钱包没有编译也运行所有测试），都是长期努力将钱包代码与服务器代码解耦的一部分。这样做提供了许多好处，包括更容易维护代码、更好地测试各个组件的机会，以及如果将钱包组件移到自己的进程中，则可能更加安全。

- [LND #1843][]：一个仅用于测试的配置选项（`--noencryptwallet`）已被重命名为 `--noseedbackup`，标记为已弃用，并且其帮助文本已被更新并更改为大部分大写警告文本。开发人员担心普通用户在不了解这将使他们只差一次失败就会永久性地丢失资金的情况下启用了此选项。

- [LND #1516][]：感谢上游 Tor 守护进程的更新，此补丁使得 LND 能够自动创建和设置 v3 洋葱服务，除了其现有的 v2 自动化之外。为了使自动化工作，用户必须已经安装了 Tor 并作为服务运行。

- [C-Lightning #1860][]：为了测试，现在使用 RPC 代理来简化对各种 RPC 调用的模拟响应，使得更容易测试 lightningd 对诸如费用估算和 bitcoind 崩溃等事务的处理。

{% include references.md %}
{% include linkers/issues.md issues="14054,1843,1516,7965,14168,10973,14180,1860" %}

[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[workshop]: /en/workshops
[news8 news]: /zh/newsletters/2018/08/14/#新闻
[c-lightning 0.6.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.6.1
[BIP322 proposal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-September/016393.html
[BIP322 PR]: https://github.com/bitcoin/bips/pull/725
[trezor p2wpkh message signing]: https://github.com/trezor/trezor-mcu/issues/169
[bustapay proposal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016340.html
[bustapay sjors]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-September/016383.html
[p2p reject]: https://btcinformation.org/en/developer-reference#reject
[dup txin master]: https://github.com/bitcoin/bitcoin/pull/14247
[dup txin 0.16]: https://github.com/bitcoin/bitcoin/pull/14249
[core download]: https://bitcoincore.org/en/download
