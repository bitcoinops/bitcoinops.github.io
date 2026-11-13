---
title: 'Bitcoin Optech Newsletter #13'
permalink: /zh/newsletters/2018/09/18/
name: 2018-09-18-newsletter-zh
slug: 2018-09-18-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 包括：与 Bitcoin Core 0.16.3 和 Bitcoin Core 0.17 RC4 安全版本发布相关的行动项、新近提出的 BIP322，以及 Optech 即将在巴黎举行的工作坊；C-Lightning 0.6.1 发布的链接、更多关于 BIP322 的信息，以及 Bustapay 提案的一些细节；此外还有对热门比特币基础设施项目中值得注意合并的简要介绍。

## 行动项

- **<!--upgrade-to-bitcoin-core-0-16-3-to-fix-denial-of-service-vulnerability-->****升级到 Bitcoin Core 0.16.3 以修复拒绝服务漏洞：** Bitcoin Core 0.14.0 引入的一个 bug 影响了其后直到 0.16.2 的所有版本。当节点尝试验证某个区块，而该区块包含一笔试图两次花费同一输入的交易时，Bitcoin Core 就会崩溃。这样的区块是无效的，因此只有愿意放弃出块所得收入（至少 12.5 XBT 或 80,000 美元）的矿工才可能将其制造出来。

    [master][dup txin master] 和 [0.16][dup txin 0.16] 分支的补丁已于昨天提交公开审查，包含该补丁的 0.16.3 版本也已打上标签；一旦足够多的知名贡献者复现了确定性构建（deterministic build），二进制文件即可供[下载][core download]——很可能就是今天（周二）晚些时候。强烈建议立即升级。

- **<!--allocate-time-to-test-bitcoin-core-0-17rc4-->****安排时间测试 Bitcoin Core 0.17 RC4：** Bitcoin Core 很快会上传 0.17 发布候选版本（RC）4 的[二进制文件][bcc 0.17]，其中包含针对上述 DoS 漏洞的同一补丁。所有测试过此前发布候选版本的测试者都应升级。我们非常感谢大家参与测试，这有助于确保最终发布的质量。

- **<!--review-proposed-bip322-for-generic-message-signing-->****审查针对通用消息签名提出的 BIP322：** 这个[新近提出的][BIP322 proposal] BIP 允许用户为目前使用的所有比特币地址类型创建签名消息，包括 P2PKH、P2SH、P2SH 包装的 segwit、P2WPKH 和 P2WSH。它有可能成为几乎所有钱包都会实现的行业标准，也可能被许多服务（例如点对点交易市场）使用，还会用于客户支持，因此 Optech 鼓励你安排一些工程时间，确保该提案与你所在组织的需求相符。详情见下方新闻部分。

- **<!--optech-paris-workshop-workshop-november-12-13-->****[Optech 巴黎工作坊][workshop] 11 月 12–13 日：** 会员公司请[给我们发邮件][optech email]，为你的工程师预留名额。计划讨论的主题包括：两种手续费追加（fee bumping）方法的比较、部分签名比特币交易（[BIP174][]）的讨论、输出脚本描述符简介、闪电网络钱包集成建议，以及高效选币方法（包括输出合并）。

## 新闻

- **<!--c-lightning-0-6-1-released-->****C-Lightning 0.6.1 发布：** 这次小幅更新带来了几项改进，包括“更少的支付卡顿、更好的路由、更少的无故关闭，以及修复了若干恼人的 bug”。[发布公告][c-lightning 0.6.1] 中包含详细信息和下载链接。

- **<!--bip322-generic-signed-message-format-->****BIP322 通用签名消息格式：** 自 2011 年起，许多钱包的用户就能用钱包中 P2PKH 地址对应的公钥签署任意消息。然而，用户想用 P2SH 地址或任何一种隔离见证地址做同样的事，却没有标准化的方法（尽管已有一些功能有限的[非标准方法][trezor p2wpkh message signing]实现）。延续几个月前 Bitcoin-Dev 邮件列表上的一场讨论，Karl-Johan Alm [提出][BIP322 proposal]了一个可适用于任何地址的 BIP（不过对于涉及 OP_CLTV 或 OP_CSV 时间锁的 P2SH 或 P2WSH 地址，它如何运作尚未说明）。

    其基本机制是：某个地址的授权付款方（可能有一位或多位）按照与花费这些资金时几乎相同的方式生成 scriptSigs 和见证数据（包括自己的签名）——区别在于，他们签的不是花费交易，而是自己的任意消息（外加一些预先约定的额外数据，以确保他们不会被诱骗去签署一笔真实交易）。随后，验证方的软件会像判断一笔花费交易是否有效那样验证这些信息。这使得消息签名功能的灵活程度与比特币脚本本身完全一致。

    目前，讨论似乎主要集中在该 BIP 提案的 [PR][BIP322 PR] 上。

- **<!--bustapay-discussion-->****Bustapay 讨论：** Bustapay 是 [Newsletter #8][news8 news] 中介绍的 Pay-to-Endpoint（P2EP）协议的一个简化替代方案。它为付款方和收款方都提供了更好的隐私保护，还让收款方能够在不增加可花费输出数量的前提下接受支付，这相当于一种自动的 UTXO 合并。该提案几周前已向 Bitcoin-Dev 邮件列表[提出][bustapay proposal]，本周又有人[讨论][bustapay sjors]了其中的几个方面。

    尽管 P2EP 和 Bustapay 也许最终只有少数钱包和服务实现，就像 [BIP70][] 支付协议那样，但它们也有可能像钱包支持 [BIP21][] URI 处理器那样被广泛采用。即使没有得到普遍采用，它们的隐私优势也意味着它们可能在小众用户中得到较广的部署。无论哪种情况，都值得投入一些工程时间来跟踪这些提案和概念验证实现，以确保你的组织在需要时能轻松采用它们。

## 值得注意的提交

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo] 和 [C-lightning][core lightning repo] 中值得注意的提交。提醒：新合并进 Bitcoin Core 的代码进入的是其主开发分支，不太可能成为即将发布的 0.17 版本的一部分——你多半要等到大约六个月后的 0.18 版本。*

- [Bitcoin Core #14054][]：此 PR 让节点默认不再发送 [BIP61][] 点对点协议的[拒绝消息][p2p reject]。最初实现这些消息，是为了方便轻客户端开发者就连接和交易中继问题获得反馈。然而，并没有任何要求（也无从要求）节点必须发送拒绝消息，或保证消息内容准确，因此这些消息可以说只是在浪费带宽。

    建议开发者把测试客户端连接到自己的节点，遇到问题时检查节点日志中的错误消息（也许要先启用调试日志）。仍然需要发送 `reject` 消息的用户可以使用 `-enablebip61` 配置选项，不过 `reject` 消息可能会在 0.18 之后的某个版本中被彻底移除。

- [Bitcoin Core #7965][]：这个长期存在的 issue 跟踪的是从 libbitcoin_server 组件中移除“处理钱包是否参与编译”的代码。本周随着 [Bitcoin Core #14168][] 合并，该 issue 终于关闭。这个 issue 与另外一些 issue——如 [Bitcoin Core #10973][]（重构：将钱包与节点分离）和 [Bitcoin Core #14180][]（即使未编译钱包也运行全部测试）——同属一项长期工作：把钱包代码与服务器代码解耦。这样做有诸多好处，包括代码更易维护、更容易对各个组件单独测试，以及把钱包组件移到独立进程后可能带来更高的安全性。

- [LND #1843][]：一个仅用于测试的配置选项（`--noencryptwallet`）已更名为 `--noseedbackup`，被标记为弃用，帮助文本也做了更新，改成几乎全大写的警告文字。开发者担心普通用户会在没意识到风险的情况下启用它——这个选项让用户只要出一次错，就会永久损失资金。

- [LND #1516][]：得益于上游 Tor 守护进程的更新，这个补丁让 LND 在原有的 v2 自动化之外，还能自动创建并配置 v3 洋葱服务。要让自动化生效，用户必须已经安装 Tor 并让它以服务方式运行。

- [C-Lightning #1860][]：为了便于测试，现在引入了一个 RPC 代理，用于简化对各类 RPC 调用的模拟响应，从而更容易测试 lightningd 对费率估算、bitcoind 崩溃等情况的处理。

{% include references.md %}
{% include linkers/issues.md issues="14054,1843,1516,7965,14168,10973,14180,1860" %}

[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[workshop]: /en/workshops
[news8 news]: /zh/newsletters/2018/08/14/#新闻
[c-lightning 0.6.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.6.1
[BIP322 proposal]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-September/016393.html
[BIP322 PR]: https://github.com/bitcoin/bips/pull/725
[trezor p2wpkh message signing]: https://github.com/trezor/trezor-mcu/issues/169
[bustapay proposal]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016340.html
[bustapay sjors]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-September/016383.html
[p2p reject]: https://btcinformation.org/en/developer-reference#reject
[dup txin master]: https://github.com/bitcoin/bitcoin/pull/14247
[dup txin 0.16]: https://github.com/bitcoin/bitcoin/pull/14249
[core download]: https://bitcoincore.org/en/download
