---
title: 'Bitcoin Optech Newsletter #15'
permalink: /zh/newsletters/2018/10/02/
name: 2018-10-02-newsletter-zh
slug: 2018-10-02-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 包括 Bitcoin Core 0.17 即将发布的通知、为那些无法运行更多最新发布版本的用户提供修复 CVE-2018-17144 重复输入漏洞的 Bitcoin Core 0.15 和 0.14 的回溯版本链接、简要描述了测试网上的链分裂情况以及比特币基础设施项目中值得注意的合并链接。

## 行动项

- **<!--upgrade-to-bitcoin-core-0-17-->****升级到 Bitcoin Core 0.17：** 新版本已经被标记，几个人已经开始重复构建软件，因此二进制文件和正式发布公告可能在周二或周三在 [BitcoinCore.org][] 上可用。公告将包括发布说明的副本，详细介绍自 0.16.0 发布以来软件的主要变化。

## 新闻

- **<!--bitcoin-core-0-15-2-and-0-14-3-released-->****发布 Bitcoin Core [0.15.2][] 和 [0.14.3][] ：** 尽管自公开宣布 [CVE-2018-17144][] 重复输入漏洞以来，这些较旧分支的源代码一直可用，但在[二进制文件][bcco /bin]可用之前，需要额外的时间来获得足够多的人来验证可重复构建。

- **<!--cve-2018-17144-duplicate-inputs-bug-exploited-on-testnet-->****在测试网上利用 CVE-2018-17144 重复输入漏洞：** 上周四，测试网上创建了一个包含两次花费同一输入的交易的区块。如预期，被认为容易受到该漏洞影响的节点接受了该区块，而所有其他节点则拒绝了它，导致共识失败（链分裂），其中包含重复输入的链拥有最多的工作量证明，而较弱的链则没有。

    最终，没有重复输入的链获得了更多的工作量证明，容易受到漏洞影响的节点试图切换到它。这导致易受攻击的节点尝试将重复输入两次重新添加到 UTXO 数据库中，触发了一个断言并导致它们关闭。重启后，容易受到攻击的节点的操作者需要手动触发一个冗长的重建索引过程来修复节点数据库的不一致。（从重复输入链分裂中恢复的这种副作用之前已为开发者所知。）

    升级到 Bitcoin Core 0.16.3、0.17.0RC4 或运行其他未受影响的软件的节点没有报告任何问题。然而，许多具有测试网模式的区块浏览器确实接受了受影响的区块，这提醒用户应谨慎使用第三方来确定交易是否有效。

## 值得注意的代码变更

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo] 和 [C-lightning][core lightning repo] 中的值得注意的代码变更。*

- [Bitcoin Core #14305][]：在发现几个基于 Python 的测试由于使用了错误命名的变量而错误地通过的情况后，使用 Python 3 的 `__slots__` 特性为类实现了一个变量名称白名单。

- [LND #1987][]：`NewWitnessAddress` RPC 已被移除，`NewAddress` RPC 现在仅支持为 P2SH 封装的 P2WKH 和原生 P2WPKH 生成地址。

- [C-Lightning #1982][]：`invoice` RPC 现在通过在发票中包含一个 [BOLT11][] `r` 参数来实现 [RouteBoost][]，为付款方提供已经打开且有能力支付该发票的通道的路由信息。最初，这个参数旨在帮助支持私有路由，但它也可以这样使用，来支持不再想接受新的进入通道的节点。另外，如果没有可用的通道能支持支付发票，C-Lightning 将发出警告。

{% include references.md %}
{% include linkers/issues.md issues="14305,1987,1982" %}

[0.16.3]: https://bitcoincore.org/en/2018/09/18/release-0.16.3/
[0.15.2]: https://github.com/bitcoin/bitcoin/releases/tag/v0.15.2
[0.14.3]: https://github.com/bitcoin/bitcoin/releases/tag/v0.14.3
[cve-2018-17144]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-17144
[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[bcco /bin]: https://bitcoincore.org/bin/
[routeboost]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-September/001417.html
