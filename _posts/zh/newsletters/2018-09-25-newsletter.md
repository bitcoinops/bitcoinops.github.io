---
title: 'Bitcoin Optech Newsletter #14'
permalink: /zh/newsletters/2018/09/25/
name: 2018-09-25-newsletter-zh
slug: 2018-09-25-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 包括与上周 Bitcoin Core 0.16.3 和 Bitcoin Core 0.17RC4 的安全发布相关的行动项和新闻、过去一个月来自 Bitcoin Stack Exchange 上的热门问题和回答以及对流行的比特币基础设施项目值得注意的合并的简短描述。

- **<!--upgrade-to-bitcoin-core-0-16-3-to-fix-cve-2018-17144-->****升级到 Bitcoin Core 0.16.3 以修复 CVE-2018-17144：** 如上周五（UTC）广泛报道的，上周 Optech Newsletter 中描述的拒绝服务漏洞现在被知道可以让矿工欺骗受影响的系统接受无效的比特币。

    在撰写本文时，据信大多数大型比特币服务和矿工已经升级，这很可能确保任何利用该漏洞的区块将会迅速被最多工作量证明链重组掉——降低了 SPV 客户端和未升级节点的风险。

    如果您不打算升级或者使用 SPV 客户端，您应该考虑等待比平时更多的确认（通常情况下，30 次确认——大约 5 小时——是这种情况下的[推荐][reorg risk recommendation]，因为这足够时间让人们注意到问题并发布警告）。否则，对于任何系统，尤其是处理资金的系统，强烈推荐升级到以下版本之一：

    * [0.16.3][]（当前稳定版本）

    * [0.17.0RC4][bcc 0.17]（下一个主要版本的发布候选版本）

    * [0.15.2][]（回溯到旧版本，可能有其他问题）

    * [0.14.3][]（回溯到旧版本，可能有其他问题）

- **<!--allocate-time-to-test-bitcoin-core-0-17rc4-->****分配时间测试 Bitcoin Core 0.17RC4：** Bitcoin Core 已上传 0.17RC4 的[二进制文件][bcc 0.17]。测试非常受欢迎，并且可以帮助确保最终版本的质量。

## 新闻

- **<!--cve-2018-17144-->****CVE-2018-17144:** 关于此漏洞的最初和后续信息披露是本周唯一的重要新闻。想要获取更多信息，我们建议阅读以下来源：

    - **<!--bitcoin-core-full-disclosure-->**[Bitcoin Core 完整披露][Bitcoin Core full disclosure]

    - **<!--original-confidential-report-->**[最初的机密报告][Original confidential report]， 现在已公开

    - **<!--additional-technical-information-->**由 Andrew Chow 提供的[额外技术信息][bse 79484]（下文也有描述）

    - **<!--cve-2018-17144-entry-->**[CVE-2018-17144 条目][cve-2018-17144], 国家漏洞数据库（NVE）条目，由 Luke Dashjr 更新

    我们知道有几位非常有洞察力的人目前正在反思这个漏洞、其根本原因以及减少未来严重漏洞风险的可能方法。对于 Bitcoin Core 内部讨论来说，特别好的一个场合将是 10 月 8-10 日在东京 Scaling Bitcoin 会议之后的 [CoreDev.tech][] 会议。我们计划跟进并提供任何重要结论的链接。

    Optech 感谢最初的报告者 Awemany 对他负责任的披露，以及以下毫不犹豫地抽出时间迅速确认问题、解决问题，并在尚未公开的通货膨胀风险中默默监控利用尝试的开发者：Pieter Wuille、Gregory Maxwell、Wladimir van der Laan、Cory Fields、Suhas Daftuar、Alex Morcos 和 Matt Corallo。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选地之一——或者当我们有几个空闲时间帮助回答其他人问题时。在这个月度特色中，我们突出展示自上次更新以来得票最多的一些问题和答案。*

- **<!--how-does-cve-2018-17144-work-->**[CVE-2018-17144 是如何工作的？][bse 79484] Andrew Chow 提供了一个详细解释，说明了在受此漏洞影响的版本中，Bitcoin Core 如何可能崩溃或被欺骗接受同一输入的多次花费。

- **<!--why-doesn-t-bitcoin-use-udp-instead-of-tcp-->**[为什么比特币不使用 UDP 而是 TCP？][bse 79175] Gregory Maxwell 描述了一个重要的比特币软件已经在使用 UDP 的案例，然后详细说明了为什么在流行的完整节点软件中没有实现 UDP 支持。他最后描述了一些如果实现了 UDP 支持可能获得的潜在好处。

- **<!--how-likely-are-you-to-get-blacklisted-by-an-exchange-if-you-use-wasabi-wallet-s-coinjoin-mixing-->**[如果你使用 Wasabi 钱包的 CoinJoin 混币，被交易所列入黑名单的可能性有多大？][bse 78654] Wasabi 钱包作者 Adam Ficsor 解释说，没有什么能阻止交易所拒绝通过 Wasabi 混合的资金，但 Wasabi 的几个特点（如要求的匿名集合为 100）可以帮助使封锁用户对业务不利。另外，他链接到一个可能允许用户绕过地址黑名单的工具。

- **<!--what-s-the-minimum-number-for-a-bitcoin-private-key-->**[比特币私钥的最小数是多少？][bse 79472]Mark Erhardt 和 Gregory Maxwell 在彼此一分钟内提供了答案，但截至撰写本文时，Nate Eldredge 对 Maxwell 答案的幽默改写比任何一个答案都获得了更多的赞。

## 值得注意的提交

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo] 和 [C-lightning][core lightning repo] 中的值得注意的提交。提醒：新合并到 Bitcoin Core 的代码是提交到其主开发分支的，不太可能成为即将发布的 0.17 版本的一部分——您可能需要等待大约六个月后的 0.18 版本。*

- [Bitcoin Core #13152][]: 当连接到点对点网络时，节点会共享它们听说过的其他节点的 IP 地址，这些地址被存储在一个数据库中，Bitcoin Core 会在想要打开新连接时查询这个数据库。这个 PR 添加了一个新的 RPC 命令 `getnodeaddresses`，它返回一个或多个这样的地址。这可以与工具如 [bitcoin-submittx][] 结合使用时非常有用。

- [LND #1738][]: 验证通道更新的逻辑已移动到路由包中，使其在路由中（处理失败的支付会话）和 gossiper 中（之前处理）都可用。这修复了可能允许一个节点欺骗它的一个对等点，使其相信另一个对等点有路由故障，从而可能将流量重定向到恶意节点的问题 [#1707][LND #1707]（并为其实现了一个测试用例）。

- [C-Lightning #1945][] 现在提供了一个 `gossipwith` 工具，允许您独立于 lightningd 接收来自节点的 gossip，甚至发送消息给远程节点。此工具用于 lightningd 的 gossip 组件的额外测试。

- [C-Lightning #1954][] 现在遵守 [BOLT7][bolt7] 的更新，通过将之前的 `listchannels` RPC 的 `flags` 字段拆分为两个新字段：`message_flags` 和 `channel_flags`。另外，代码注释和对 [BOLT2][] 和 [BOLT11][] 的引用也已更新。

- [C-Lightning #1905][] 显著扩展了其秘密模块的代码内文档。文档质量非常好（有时相当幽默）。请参阅 [hsmd.c][]。代码注释甚至记录了其他代码注释：

    ```c
    /*~ 你会发现代码中散布着这样的 FIXME。{% comment %}skip-test{% endcomment %}
     * 有时它们建议一些简单的改进，像你自己一样的人应该去实现。有时它们是欺骗性的泥潭，
     * 只会给你带来痛苦。你决定！*/

     /* FIXME: 我们应该缓存这些。*/{% comment %}skip-test{% endcomment %}
     get_channel_seed(&c->id, c->dbid, &channel_seed);
     derive_funding_key(&channel_seed, &funding_pubkey, &funding_privkey);
    ```

- [C-Lightning #1947][] 现在可以并行向 bitcoind 发出多个请求，加快了在慢速系统或执行长时间操作的节点上的操作速度。

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
[original confidential report]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-September/016424.html
[cve-2018-17144]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-17144
[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[coredev.tech]: https://coredev.tech/
[hsmd.c]: https://github.com/ElementsProject/lightning/blob/master/hsmd/hsmd.c
[bitcoin-submittx]: https://github.com/laanwj/bitcoin-submittx
