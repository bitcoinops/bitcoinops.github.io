---
title: 'Bitcoin Optech Newsletter #80'
permalink: /zh/newsletters/2020/01/15/
name: 2020-01-15-newsletter-zh
slug: 2020-01-15-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 请求大家帮助测试 LND 的下一个版本，总结一场关于软分叉激活机制的讨论，并介绍热门比特币基础设施软件的几项值得注意的变更。

## 行动项

- **<!--help-test-lnd-0-9-0-beta-rc1-->****帮助测试 LND 0.9.0-beta-rc1：** LND 下一个主要版本的这一[预发布版][lnd 0.9.0-beta]带来了若干新功能与错误修复。我们鼓励有经验的用户帮助测试该软件，以便在正式发布前发现并修复问题。

## 新闻

- **<!--discussion-of-soft-fork-activation-mechanisms-->****软分叉激活机制的讨论：** Matt Corallo 在 Bitcoin-Dev 邮件列表上发起了一项[讨论][corallo sf]，话题是软分叉激活方法应当具备哪些理想属性；他同时提交了一个包含这些属性的机制提案。简单来说，这些属性是：

  1. 如果对提议的共识规则变更出现严重反对意见，有能力中止该提案

  2. 在更新版软件发布后留出足够时间，确保大多数经济节点都完成升级来执行这些规则

  3. 预期网络哈希率在变更前后以及过渡期间大致保持相同

  4. 尽可能防止产生在新规则下无效的区块，否则未升级节点和 SPV 客户端可能出现虚假确认

  5. 保证中止机制不会被捣乱者或偏袒一方者滥用，用来扣住一项没有已知问题、又被广泛期待的升级

  Corallo 认为，一个精心设计、采用 [BIP9][] versionbits 激活机制并有良好社区参与的软分叉能满足前四条标准——但满足不了第五条。反过来，[BIP8][] 的旗帜日软分叉能满足第五条，却难以满足另外四条。Corallo 还担心，如果软分叉部署一开始就用 BIP8，会给人一种印象：节点软件的开发者有权决定这个系统的规则。

  为了不单靠 BIP9 或 BIP8 中的任何一个，Corallo 提出了一个三步流程：先用 BIP9，让提案在一年窗口内激活；如果未激活，就暂停六个月供社区讨论；如果届时明确社区仍希望激活，就把 BIP8 旗帜日设在两年之后强制激活（也可以借助 versionbits 信号更快激活）。节点软件可以为这个最长 42 个月的过程做好准备：即使是最初的版本，也内置一个配置选项，用户如有需要可以手动启用来强制执行 BIP8 旗帜日。如果激活期的前 18 个月过去仍未激活（但也没发现任何阻碍性问题），新版本可以在激活期余下的 24 个月里默认启用该选项。

  在对该帖的回复中，[Jorge Timón][timon sf] 和 [Luke Dashjr][dashjr sf] 都建议，任何类似 BIP8 的机制都应在旗帜日之前强制进行 versionbits 信号（类似于 [BIP148][] 提议的 segwit 激活方式）；Corallo [指出][corallo reply timon]，这样做与第三、第四个目标冲突。Jeremy Rubin 结合这五个目标，对他先前提出的 [spork 提案][spork vid]（参见 [Newsletter #32][spork summary]）做了一份[简要分析][rubin sf]。Anthony Towns 则就 Corallo 的提案和 Timón 的回应中的若干方面给出了[清晰透彻的评论][towns sf]。

  该讨论帖没有得出明确结论，我们预计相关讨论还会继续。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络 BOLT][bolts repo] 中值得注意的变更。*

- [Bitcoin Core #17578][] 更新了 `getaddressinfo` RPC，改为返回一个字符串数组，对应某个地址所用的标签。此前它返回的是对象数组，其中的标签包含名称与用途两个字段，用途对应钱包中生成该地址的那一部分。需要旧行为的用户可以在 Bitcoin Core 0.21 之前使用 `-deprecatedrpc=labelspurpose` 配置参数。

- [Bitcoin Core #16373][] 让用于[手续费替换（RBF）][topic rbf]手续费追加的 `bumpfee` RPC，在用户试图用一个禁用了私钥的钱包为交易追加手续费时，返回一笔[部分签名比特币交易][topic psbt]（PSBT）。随后可以把这笔 PSBT 复制到外部钱包（例如硬件设备或冷钱包）去签名。

- [Bitcoin Core #17621][] 修复了使用 `avoid_reuse` 钱包标志时的潜在隐私泄露。该标志防止钱包花掉那些被发送到它已用于支出的地址上的比特币（参见 [Newsletter #52][news52 avoid_reuse]）。这可以避免本不相关的交易因为都用过同一地址而被关联起来，从而增强隐私。然而，Bitcoin Core 目前会用几种不同的地址格式监控发往自己任一公钥的支付。这意味着，即使 `avoid_reuse` 本应阻止这类可关联性，同一公钥的多笔支付——但地址不同（例如 P2PKH、P2WPKH、P2SH-P2WPKH）——仍可能在区块链上被关联起来。已合并的这个 PR 修复了 `avoid_reuse` 标志的这一问题；而[输出脚本描述符][topic descriptors]的逐步普及，预计会消除 Bitcoin Core 需要监控其他地址格式这一问题。该变更预计会向后移植到下一个 Bitcoin Core 维护版本（参见 [PR #17792][Bitcoin Core #17792]）。

- [LND #3829][] 做了若干内部改动和文档更新，以便将来更容易加入[锚定输出][anchor outputs]。

{% include references.md %}
{% include linkers/issues.md issues="17578,16373,17621,3829,17792" %}
[lnd 0.9.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.9.0-beta-rc1
[corallo sf]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017547.html
[timon sf]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017548.html
[dashjr sf]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017551.html
[corallo reply timon]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017549.html
[rubin sf]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017552.html
[towns sf]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-January/017553.html
[spork vid]: https://www.youtube.com/watch?v=J1CP7qbnpqA&feature=youtu.be
[spork summary]: /zh/newsletters/2019/02/05/#probabilistic-bitcoin-soft-forks-sporks
[anchor outputs]: /zh/newsletters/2019/10/30/#ln-simplified-commitments
[news52 avoid_reuse]: /zh/newsletters/2019/06/26/#bitcoin-core-13756