---
title: 'Bitcoin Optech Newsletter #80'
permalink: /zh/newsletters/2020/01/15/
name: 2020-01-15-newsletter-zh
slug: 2020-01-15-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 请求帮助测试 LND 的下一个版本，总结了关于软分叉激活机制的讨论，并描述了一些流行的比特币基础设施软件的值得注意的变化。

## 行动项

- **<!--help-test-lnd-0-9-0-beta-rc1-->****帮助测试 LND 0.9.0-beta-rc1：** 该[预发布版本][lnd 0.9.0-beta] 是 LND 下一个主要版本的预发布版，带来了若干新功能和错误修复。鼓励有经验的用户帮助测试该软件，以便在正式发布前发现并修复任何问题。

## 新闻

- **<!--discussion-of-soft-fork-activation-mechanisms-->****软分叉激活机制的讨论：** Matt Corallo 在 Bitcoin-Dev 邮件列表中发起了一项[讨论][corallo sf]，探讨了软分叉激活方法应具备的属性，并提交了一个包含这些属性的机制提案。简而言之，这些属性包括：

  1. 如果遇到对提议的共识规则变更的严重反对，能够中止该提案

  2. 分配足够的时间，在发布更新软件后确保大多数经济节点升级以执行这些规则

  3. 预期网络哈希率在变化前后以及在过渡期间保持大致相同

  4. 尽可能防止创建在新规则下无效的区块，这可能导致未升级节点和 SPV 客户端产生错误确认

  5. 确保中止机制不会被恶意行为者或派系滥用，从而阻止一个没有已知问题的广泛期望的升级

  Corallo 认为，一个使用 [BIP9][] versionbits 激活机制并伴随良好社区参与的精心设计的软分叉可以满足前四个标准——但不能满足第五个标准。而 [BIP8][] 的旗帜日软分叉可以满足第五个标准，但在实现前四个标准时遇到挑战。Corallo 还担心，从软分叉部署开始就使用 BIP8 会给人一种节点软件开发者决定系统规则的印象。

  作为 BIP9 或 BIP8 的替代方案，Corallo 提出了一个三步流程：使用 BIP9 允许在一年内激活提案；如果提案未激活，则暂停六个月的讨论期；如果明确社区仍希望激活提案，则通过 BIP8 的旗帜日在未来两年内强制激活（也可以通过 versionbits 信号实现更快的激活）。节点软件可以通过包括一个配置选项为这个最长 42 个月的过程做准备，即使在其最初版本中，用户也可以手动启用该选项以在必要时执行 BIP8 旗帜日。如果在激活期的前 18 个月没有激活（也没有发现任何阻碍问题），则新版本可以默认启用该选项，剩余 24 个月用于激活。

  在对该帖子的回复中，[Jorge Timón][timon sf] 和 [Luke Dashjr][dashjr sf] 都建议任何类似 BIP8 的机制应使用强制 versionbits 信号，直到旗帜日（类似于 [BIP148][] 提议的 segwit 激活）；Corallo [指出][corallo reply timon]，这与第三和第四个目标相冲突。Jeremy Rubin 在他的[快速分析][rubin sf]中将其先前的[软分叉提案][spork vid]（参见[Newsletter #32][spork summary]）置于五个目标的背景下进行了评估。Anthony Towns 对 Corallo 的提案和 Timón 的回应提供了[清晰的评论][towns sf]。

  该讨论线程未达成明确结论，预计会有进一步的讨论。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的变化。*

- [Bitcoin Core #17578][] 更新了 `getaddressinfo` RPC，返回一个包含地址使用的标签字符串的数组。此前，它返回的数组包含对象，标签字段包括其名称和用途，用途对应生成地址的钱包部分。需要旧行为的用户可以使用 `-deprecatedrpc=labelspurpose` 配置参数，直到 Bitcoin Core 0.21 版本。

- [Bitcoin Core #16373][] 使得在使用已禁用私钥的钱包时，使用 [Replace-by-Fee (RBF)][topic rbf] 的 `bumpfee` RPC 返回[部分签名的比特币交易][topic psbt]（PSBT）。然后可以将 PSBT 复制到外部钱包（如硬件设备或冷钱包）进行签名。

- [Bitcoin Core #17621][] 修复了使用 `avoid_reuse` 钱包标志时的潜在隐私泄露问题。该标志阻止钱包花费已经用于支出的地址接收到的比特币（参见[Newsletter #52][news52 avoid_reuse]）。这通过阻止涉及同一地址的无关交易被关联在一起来增强隐私。然而，Bitcoin Core 当前使用多种不同的地址格式监控其任何公钥的支付，这意味着即使 `avoid_reuse` 行为应防止这种关联，区块链上仍可能将同一公钥的多个支付（例如 P2PKH、P2WPKH、P2SH-P2WPKH）关联在一起。此合并的 PR 修复了 `avoid_reuse` 标志的问题，并且随着[输出脚本描述符][topic descriptors]的采用，预计将消除 Bitcoin Core 监控替代地址的问题。此更改预计将在下一个 Bitcoin Core 维护版本中回溯（参见 [PR #17792][Bitcoin Core #17792]）。

- [LND #3829][] 进行了若干内部更改和文档更新，以便未来更容易添加[锚定输出][anchor outputs]。

{% include references.md %}
{% include linkers/issues.md issues="17578,16373,17621,3829,17792" %}
[lnd 0.9.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.9.0-beta-rc1
[corallo sf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017547.html
[timon sf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017548.html
[dashjr sf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017551.html
[corallo reply timon]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017549.html
[rubin sf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017552.html
[towns sf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017553.html
[spork vid]: https://www.youtube.com/watch?v=J1CP7qbnpqA&feature=youtu.be
[spork summary]: /zh/newsletters/2019/02/05/#probabilistic-bitcoin-soft-forks-sporks
[anchor outputs]: /zh/newsletters/2019/10/30/#ln-simplified-commitments
[news52 avoid_reuse]: /zh/newsletters/2019/06/26/#bitcoin-core-13756
