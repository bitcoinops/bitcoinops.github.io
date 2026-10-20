---
title: 'Bitcoin Optech Newsletter #84'
permalink: /zh/newsletters/2020/02/12/
name: 2020-02-12-newsletter-zh
slug: 2020-02-12-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 请求大家帮助测试 Bitcoin Core 的一个候选发布版，并总结一些关于 BIP119 `OP_CHECKTEMPLATEVERIFY` 提案的讨论。此外还有关于代码与文档值得注意的变更的常规栏目。

## 行动项

- **<!--help-test-bitcoin-core-0-19-1rc1-->****帮助测试 Bitcoin Core 0.19.1rc1：** 即将发布的这一维护[版本][bitcoin core 0.19.1]包含若干错误修复。我们鼓励有经验的用户帮助测试是否存在回归或其他意外行为。

## 新闻

- **<!--op-checktemplateverify-ctv-workshop-->****`OP_CHECKTEMPLATEVERIFY` (CTV) 工作坊：** 最近一场关于 [BIP119][] CTV 的工作坊已放出视频（[上午][ctv morning vid]、[下午][ctv afternoon vid]）和[文字记录][ctv transcript]。如果这个提议的软分叉被采纳，用户就能用新的 CTV 操作码创建[契约][topic covenants]，所需的交互比现行共识规则下更少。工作坊讨论了该操作码的几种可能应用，关注点主要集中在保险库和压缩式支付批处理（有时称为*拥堵控制交易*，参见 [Newsletter #48][news48 cc]）。工作坊的很大一部分内容还包括来自听众的批评意见以及对这些批评的回应。最后一场讨论涉及如何、何时尝试推动 BIP119 激活，包括何时该向 Bitcoin Core 仓库提交 PR、应该采用哪种激活机制（例如 [BIP9][] versionbits），以及如果采用 BIP9 这类由矿工激活的软分叉机制，激活日期定在什么范围比较合适。

  工作坊之后，CTV 提议者 Jeremy Rubin 宣布了一个[邮件列表][ctv mailing list]，用来协调今后对 BIP119 提案的审查和讨论。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络 BOLT][bolts repo] 中值得注意的变更。*

- [Bitcoin Core #17585][] 弃用了 `getaddressinfo` RPC 返回的 `label` 字段，因为 `labels`（复数）字段已经存在，功能相同。`label` 字段预计在 0.21 中移除；为了兼容，过渡期内可以用 `-deprecatedrpc=label` 启动 `bitcoind` 重新启用旧行为。这是清理 `getaddressinfo` RPC 接口的一系列改动中的最后一项（其中还包括 [Newsletter #80][news80 label] 介绍过的 PR）。

- [Bitcoin Core #18032][] 扩展了 `createmultisig` 和 `addmultisigaddress` 两个 RPC 的返回结果，新增 `descriptor` 字段，其中包含为所创建的多重签名地址生成的[输出脚本描述符][topic descriptors]。这里提供描述符，可以让用户（或调用该 RPC 的程序）更容易拿到所需的全部信息：既能监控发往该地址的支付，又能稍后构造未签名交易，着手花掉这笔钱。

- [C-Lightning #3475][] 允许插件钩子返回 `{ "result" : "continue" }`，告诉 `lightningd` 就像没执行过这个钩子一样处理该操作。这让钩子可以只在特殊情况下才真正生效。

- [C-Lightning #3372][] 允许用户指定另一个程序来取代某个默认的子守护进程（C-Lightning 系统由多个互相交互的守护进程组成，这些进程称为 `lightningd` 的*子守护进程*）。例如（摘自 PR 描述）：

  ```
  # 使用 remote_hsmd 替代 lightning_hsmd 进行签名：
  lightningd --alt-subdaemon=lightning_hsmd:remote_hsmd ...
  ```

  如果替代的子守护进程与正在使用的其他守护进程不完全兼容，这个选项可能很危险；但它也带来了更大的灵活性，并可能简化某些测试。

- [C-Lightning #3465][] 为提款交易实现了反手续费狙击，与 LND 对同一机制的实现类似（参见 [Newsletter #18][news18 afs]）。反手续费狙击利用 nLockTime 字段，使交易无法被打包进任何高度低于交易产生时区块链顶端高度的区块。这限制了正在重组（分叉）链的矿工随意重排交易以最大化手续费收入的能力。

- [LND #3957][] 添加了一些代码，可供后续引入原子多路径支付（AMP）的 PR 使用。AMP 是另一种[多路径支付][topic multipath payments]，与 C-Lightning、Eclair 和 LND 已经支持的“基础”或“基本”类型相似。路由节点更难把 AMP 与普通的单部分支付区分开，而且 AMP 可以保证收款方要么领取支付的所有部分，要么一个部分都不领。

- [BOLTs #684][] 更新了 [BOLT7][]，建议节点即使在对端请求的过滤器会抑制某条公告时，也仍然发送自己生成的公告。这有助于确保节点能经由其直接对等节点被通报给整个网络，同时又不必在其他方面改变过滤机制。

{% include references.md %}
{% include linkers/issues.md issues="18032,3475,3372,3465,3957,684,17585" %}
[bitcoin core 0.19.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.1/
[ctv morning vid]: https://twitter.com/JeremyRubin/status/1223672458516938752
[ctv afternoon vid]: https://twitter.com/JeremyRubin/status/1223729378946715648
[news18 afs]: /zh/newsletters/2018/10/23/#lnd-1978
[ctv transcript]: https://diyhpl.us/wiki/transcripts/ctv-bip-review-workshop/
[ctv mailing list]: https://mailman.mit.edu/mailman/listinfo/bip-0119-review
[news48 cc]: /zh/newsletters/2019/05/29/#提议的交易输出承诺
[news80 label]: /zh/newsletters/2020/01/15/#bitcoin-core-17578
