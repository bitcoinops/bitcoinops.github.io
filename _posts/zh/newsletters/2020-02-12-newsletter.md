---
title: 'Bitcoin Optech Newsletter #84'
permalink: /zh/newsletters/2020/02/12/
name: 2020-02-12-newsletter-zh
slug: 2020-02-12-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 寻求帮助测试 Bitcoin Core 候选发布版本，并总结了一些关于 BIP119 `OP_CHECKTEMPLATEVERIFY` 提案的讨论。此外，还包括我们常规的代码和文档更改部分。

## 行动项

- **<!--help-test-bitcoin-core-0-19-1rc1-->****帮助测试 Bitcoin Core 0.19.1rc1：** 即将发布的这一维护[版本][bitcoin core 0.19.1]包含若干错误修复。我们鼓励有经验的用户帮助测试，以发现任何回归或其他意外行为。

## 新闻

- **<!--op-checktemplateverify-ctv-workshop-->****`OP_CHECKTEMPLATEVERIFY` (CTV) 研讨会：** 来自最近关于 [BIP119][] CTV 的研讨会的视频（[上午][ctv morning vid]、[下午][ctv afternoon vid]）和[文字记录][ctv transcript]已经发布。如果这个提议的软分叉被采纳，用户将能够使用新的 CTV 操作码创建[约束][topic covenants]，所需的交互将比现有共识规则下的交互更少。研讨会讨论了该操作码的几种可能应用，其中大部分关注点集中在保险库和压缩支付批处理（有时称为*拥堵控制交易*，参见 [Newsletter #48][news48 cc]）。研讨会的重要部分还包括来自观众的批评反馈及对这些批评的回应。最后的讨论涉及如何以及何时尝试推动 BIP119 的激活，包括何时在 Bitcoin Core 仓库中提交 PR、应使用何种激活机制（例如 [BIP9][] versionbits），以及如果使用矿工激活的软分叉机制（如 BIP9），应选择何种激活日期范围。

  在研讨会之后，CTV 提案人 Jeremy Rubin 宣布创建了一个[邮件列表][ctv mailing list]，以帮助协调未来对 BIP119 提案的审查和讨论。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #17585][] 弃用了 `getaddressinfo` RPC 返回结果中的 `label` 字段，因为已经存在 `labels`（复数）字段并提供了相同的功能。`label` 字段预计将在 0.21 版本中移除；为了兼容性，可以在此期间通过启动 `bitcoind` 时使用 `-deprecatedrpc=label` 来重新启用旧行为。此更改是清理 `getaddressinfo` RPC 接口系列更改中的最后一步（包括 [Newsletter #80][news80 label] 中介绍的 PR）。

- [Bitcoin Core #18032][] 扩展了 `createmultisig` 和 `addmultisigaddress` RPC 的结果，新增了 `descriptor` 字段，该字段包含了为创建的多重签名地址提供的[输出脚本描述符][topic descriptors]。提供描述符使用户（或调用该 RPC 的程序）更容易获取所有信息，不仅可以监控接收到创建地址的支付，还可以稍后创建开始花费这些资金的未签名交易。

- [C-Lightning #3475][] 允许插件钩子返回 `{ "result" : "continue" }`，以告知 `lightningd` 按照没有执行钩子的情况处理操作。这使得钩子可以仅在特殊情况下执行，从而提高灵活性。

- [C-Lightning #3372][] 允许用户指定替代程序来替换默认的子守护进程（C-Lightning 系统由多个交互的守护进程组成，称为 `lightningd` 的*子守护进程*）。例如（来自 PR 描述）：

  ```
  # 使用 remote_hsmd 替代 lightning_hsmd 进行签名：
  lightningd --alt-subdaemon=lightning_hsmd:remote_hsmd ...
  ```

  如果替代的子守护进程与正在使用的其他守护进程不完全兼容，此选项可能存在风险，但它也提供了更大的灵活性，并可能简化某些测试。

- [C-Lightning #3465][] 为提款交易实现了防止费用抢先的机制，类似于 LND 的相同机制实现（参见 [Newsletter #18][news18 afs]）。防止费用抢先使用 nLockTime 字段，避免交易被包含在任何高度低于交易生成时区块链顶端高度的区块中。这限制了重新组织（分叉）链的矿工在重新排列交易以最大化其费用收入方面的能力。

- [LND #3957][] 添加了一些代码，以便在后续 PR 中引入原子多路径支付（AMP）。AMP 是另一种[多路径支付][topic multipath payments]，与 C-Lightning、Eclair 和 LND 已支持的“基础”或“基本”类型类似。AMP 更难以被路由节点区分为正常的单一部分支付，并且可以保证接收方要么领取所有支付部分，要么不领取任何部分。

- [BOLTs #684][] 更新了 [BOLT7][]，建议节点在远程对等方请求的过滤器可能抑制该公告时，仍发送自己生成的公告。这有助于确保节点通过其直接对等方向网络发布，而不改变其他过滤方式。

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
