---
title: 'Bitcoin Optech Newsletter #15'
permalink: /zh/newsletters/2018/10/02/
name: 2018-10-02-newsletter-zh
slug: 2018-10-02-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 包括：Bitcoin Core 0.17 即将发布的通知；为无法运行较新版本的用户提供 Bitcoin Core 0.15 和 0.14 向后移植版本（用于修复 CVE-2018-17144 重复输入漏洞）的链接；测试网链分裂的简要说明；以及比特币基础设施项目中值得注意的合并链接。

## 行动项

- **<!--upgrade-to-bitcoin-core-0-17-->****升级到 Bitcoin Core 0.17：** 新版本已经打上标签，已有几个人开始复现构建，因此二进制文件和正式发布公告很可能在周二或周三出现在 [BitcoinCore.org][] 上。公告将附上一份发布说明，详细介绍自 0.16.0 发布以来软件的主要变化。

## 新闻

- **<!--bitcoin-core-0-15-2-and-0-14-3-released-->****发布 Bitcoin Core [0.15.2][] 和 [0.14.3][]：** 尽管自 [CVE-2018-17144][] 重复输入漏洞公开披露以来，这些较旧分支的源代码就一直可用，但要让足够多的人认证一次可复现构建仍需额外时间，之后[二进制文件][bcco /bin]才得以提供。

- **<!--cve-2018-17144-duplicate-inputs-bug-exploited-on-testnet-->****在测试网上利用 CVE-2018-17144 重复输入漏洞：** 上周四，测试网上出现了一个区块，其中包含一笔将同一输入花费两次的交易。如预期，被认为易受该漏洞影响的节点接受了这个区块，其他所有节点则拒绝了它，导致共识失败（链分裂）：工作量证明最多的那条链包含重复输入，另一条较弱的链则没有。

    最终，不含重复输入的那条链获得了更多工作量证明，易受攻击的节点尝试切换过去。这使它们试图把重复输入两次重新加入 UTXO 数据库，触发了断言（assert），导致这些节点自行退出。重启后，这些节点的运营者需要手动触发一次耗时的重建索引（reindex），才能修复节点数据库中的不一致。（从重复输入导致的链分裂中恢复时的这一副作用，开发者此前已经知晓。）

    升级到 Bitcoin Core 0.16.3、0.17.0RC4，或运行其他不受该漏洞影响的软件的节点，均未报告问题。然而，许多带有测试网模式的区块浏览器确实接受了这个有漏洞的区块，这也提醒用户：借助第三方来判断交易是否有效时要多加小心。

## 值得注意的代码变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo] 和 [C-lightning][core lightning repo] 中值得注意的代码变更。*

- [Bitcoin Core #14305][]：在发现若干基于 Python 的测试因变量名写错而错误通过之后，项目利用 Python 3 为类提供的 `__slots__` 特性实现了一份变量名白名单。

- [LND #1987][]：`NewWitnessAddress` RPC 已被移除，`NewAddress` RPC 现在仅支持为 P2SH 封装的 P2WKH 和原生 P2WPKH 生成地址。

- [C-Lightning #1982][]：`invoice` RPC 现在通过在发票中加入 [BOLT11][] 的 `r` 参数来实现 [RouteBoost][]，为付款方提供路由信息，指向一条已经打开、且容量足以支付该发票的通道。该参数最初是为了支持私有路由，但也可以这样使用，来服务那些不再愿意接受新入站通道的节点。另外，如果没有可用通道能够支持支付该发票，C-Lightning 会发出警告。

{% include references.md %}
{% include linkers/issues.md issues="14305,1987,1982" %}

[0.16.3]: https://bitcoincore.org/en/2018/09/18/release-0.16.3/
[0.15.2]: https://github.com/bitcoin/bitcoin/releases/tag/v0.15.2
[0.14.3]: https://github.com/bitcoin/bitcoin/releases/tag/v0.14.3
[cve-2018-17144]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-17144
[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[bcco /bin]: https://bitcoincore.org/bin/
[routeboost]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-September/001417.html
