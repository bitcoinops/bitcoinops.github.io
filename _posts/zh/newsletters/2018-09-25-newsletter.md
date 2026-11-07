---
title: 'Bitcoin Optech Newsletter #14'
permalink: /zh/newsletters/2018/09/25/
name: 2018-09-25-newsletter-zh
slug: 2018-09-25-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 包括：与上周 Bitcoin Core 0.16.3 和 Bitcoin Core 0.17RC4 安全发布相关的行动项与新闻；过去一个月 Bitcoin Stack Exchange 上的热门问答；以及对热门比特币基础设施项目值得注意合并的简短介绍。

- **<!--upgrade-to-bitcoin-core-0-16-3-to-fix-cve-2018-17144-->****升级到 Bitcoin Core 0.16.3 以修复 CVE-2018-17144：** 如上周五早些时候（UTC）广泛报道的那样，上周 Optech Newsletter 中描述的拒绝服务漏洞，现在已确认可让矿工诱骗受影响的系统接受无效的比特币。

    在撰写本文时，据信大多数大型比特币服务和矿工已经升级，这很可能确保了任何利用该漏洞的区块都会被迅速从工作量证明最多的链上重组掉——从而降低 SPV 客户端和未升级节点的风险。

    如果你不打算升级，或者你使用的是 SPV 客户端，应考虑等待比平时更多的确认（30 次确认——约合 5 小时——是这类情况下的常规[建议][reorg risk recommendation]，因为这段时间足够让大家发现问题并发布警告）。除此之外，仍强烈建议任何系统、尤其是处理资金的系统，升级到以下版本之一：

    * [0.16.3][]（当前稳定版本）

    * [0.17.0RC4][bcc 0.17]（下一个主要版本的候选发布）

    * [0.15.2][]（向后移植到旧版本，可能还有其他问题）

    * [0.14.3][]（向后移植到旧版本，可能还有其他问题）

- **<!--allocate-time-to-test-bitcoin-core-0-17rc4-->****分配时间测试 Bitcoin Core 0.17RC4：** Bitcoin Core 已上传 0.17RC4 的[二进制文件][bcc 0.17]。我们非常感谢大家参与测试，这有助于确保最终版本的质量。

## 新闻

- **<!--cve-2018-17144-->****CVE-2018-17144：** 关于此漏洞的最初和后续信息披露是本周唯一的重要新闻。想要获取更多信息，我们建议阅读以下来源：

    - **<!--bitcoin-core-full-disclosure-->**[Bitcoin Core 完整披露][Bitcoin Core full disclosure]

    - **<!--original-confidential-report-->**[最初的机密报告][Original confidential report]，现在已公开

    - **<!--additional-technical-information-->**由 Andrew Chow 提供的[额外技术信息][bse 79484]（下文也有描述）

    - **<!--cve-2018-17144-entry-->**[CVE-2018-17144 条目][cve-2018-17144]，国家漏洞数据库（NVE）条目，由 Luke Dashjr 更新

    我们知道，有几位非常有洞察力的人目前正在深入思考这个漏洞、它的根本原因，以及降低未来严重漏洞风险的可能办法。10 月 8 日至 10 日、东京 Scaling Bitcoin 会议之后举行的 [CoreDev.tech][] 会议，将是进行 Bitcoin Core 内部讨论的绝佳场合。我们计划跟进，并提供任何已发表的重要结论的链接。

    Optech 感谢最初的报告者 Awemany 负责任地披露此事，也感谢以下开发者毫不犹豫地抽出时间迅速确认问题、加以解决，并默默全天候监控利用当时尚未披露的通胀风险的尝试：Pieter Wuille、Gregory Maxwell、Wladimir van der Laan、Cory Fields、Suhas Daftuar、Alex Morcos 和 Matt Corallo。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮忙回答他人问题的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

- **<!--how-does-cve-2018-17144-work-->**[CVE-2018-17144 是如何运作的？][bse 79484] Andrew Chow 详细解释了在受此漏洞影响的版本中，Bitcoin Core 如何会被搞崩溃，或被诱骗接受对同一输入的多次花费。

- **<!--why-doesn-t-bitcoin-use-udp-instead-of-tcp-->**[为什么比特币不用 UDP 而用 TCP？][bse 79175] Gregory Maxwell 举出了一个重要比特币软件确实已在使用 UDP 的例子，随后详细说明了为什么流行的完整节点软件没有实现 UDP 支持。最后，他描述了如果支持 UDP 可能带来的一些潜在好处。

- **<!--how-likely-are-you-to-get-blacklisted-by-an-exchange-if-you-use-wasabi-wallet-s-coinjoin-mixing-->**[如果你使用 Wasabi 钱包的 coinjoin 混币，被交易所列入黑名单的可能性有多大？][bse 78654] Wasabi 钱包作者 Adam Ficsor 解释说，没有什么能阻止交易所拒绝经 Wasabi 混合的资金，但 Wasabi 的若干特性（例如强制要求匿名集达到 100）有助于让交易所封锁用户变得不利于其生意。此外，他还给出了一个可能让用户绕过地址黑名单的工具链接。

- **<!--what-s-the-minimum-number-for-a-bitcoin-private-key-->**[比特币私钥的最小数值是多少？][bse 79472] Mark Erhardt 和 Gregory Maxwell 相隔不到一分钟先后给出答案，但截至本文撰写时，Nate Eldredge 对 Maxwell 答案的一句幽默改写，得票比这两个答案都多。

## 值得注意的提交

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo] 和 [C-lightning][core lightning repo] 中值得注意的提交。提醒：合并进 Bitcoin Core 的新代码都进入其 master 开发分支，不太可能成为即将发布的 0.17 版本的一部分——你大概要等到大约六个月后的 0.18 版本。*

- [Bitcoin Core #13152][]：接入点对点网络后，节点会与其他节点分享自己听说过的节点 IP 地址，这些地址保存在一个数据库中，Bitcoin Core 需要建立新连接时就会查询它。这个 PR 新增了一个 RPC 命令 `getnodeaddresses`，用于返回其中一个或多个地址。配合 [bitcoin-submittx][] 之类的工具使用时，它会很有用。

- [LND #1738][]：校验通道更新的逻辑已移入路由包，这样路由模块（用于处理失败的支付会话）和 gossiper（原先负责此事）都能使用它。这修复了问题 [#1707][LND #1707]（并为其补充了测试用例）：该问题可能让某个节点诱骗自己的一个对等节点，使其相信另一个对等节点发生了路由故障，从而可能把流量重定向到恶意节点。

- [C-Lightning #1945][] 现在提供了一个 `gossipwith` 工具，允许你脱离 lightningd，直接接收某个节点的 gossip，甚至向远端节点发送消息。该工具用于对 lightningd 的 gossip 组件做额外测试。

- [C-Lightning #1954][] 现在遵循 [BOLT7][bolt7] 的更新，把 `listchannels` RPC 原先的 `flags` 字段拆成了两个新字段：`message_flags` 和 `channel_flags`。此外，代码注释以及指向 [BOLT2][] 和 [BOLT11][] 的引用也已更新。

- [C-Lightning #1905][] 大幅扩充了其 secrets 模块的代码内文档。文档写得非常好（有时还相当幽默）。请参阅 [hsmd.c][]。代码注释甚至在解释别的代码注释：

    ```c
    /*~ 你会发现代码中散布着这样的 FIXME。{% comment %}skip-test{% endcomment %}
     * 有时它们只是建议一些简单的改进，像你这样的人直接去实现就好。有时它们是骗人的泥潭，
     * 只会给你带来痛苦。你来决定！*/

     /* FIXME: 我们应该缓存这些。*/{% comment %}skip-test{% endcomment %}
     get_channel_seed(&c->id, c->dbid, &channel_seed);
     derive_funding_key(&channel_seed, &funding_pubkey, &funding_privkey);
    ```

- [C-Lightning #1947][] 现在可以向 bitcoind 并发发出多个请求，从而加快慢速系统上或正在执行长时间操作的节点上的处理速度。

{% include references.md %}
{% include linkers/issues.md issues="13152,1738,1707,1945,1954,1905,1947" %}

{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[bse 79484]: {{bse}}79484
[bse 79175]: {{bse}}79175
[bse 78654]: {{bse}}78654
[bse 79472]: {{bse}}79472
[0.16.3]: https://bitcoincore.org/en/2018/09/18/release-0.16.3/
[0.15.2]: https://github.com/bitcoin/bitcoin/releases/tag/v0.15.2
[0.14.3]: https://github.com/bitcoin/bitcoin/releases/tag/v0.14.3
[reorg risk recommendation]: https://btcinformation.org/en/you-need-to-know#instant
[bitcoin core full disclosure]: https://bitcoincore.org/en/2018/09/20/notice/
[original confidential report]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-September/016424.html
[cve-2018-17144]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-17144
[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[coredev.tech]: https://coredev.tech/
[hsmd.c]: https://github.com/ElementsProject/lightning/blob/master/hsmd/hsmd.c
[bitcoin-submittx]: https://github.com/laanwj/bitcoin-submittx
