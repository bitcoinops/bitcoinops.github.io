---
title: 'Bitcoin Optech Newsletter #214'
permalink: /zh/newsletters/2022/08/24/
name: 2022-08-24-newsletter-zh
slug: 2022-08-24-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报链接到有关通道堵塞攻击的指南概述，并总结了对静默支付 PR 的几项更新。此外还有我们的常规部分：软件的新版本和候选版本、流行的比特币基础设施软件的重大变更。

## 新闻

- **<!--overview-of-channel-jamming-attacks-and-mitigations-->通道堵塞攻击和缓解措施概述：**Antoine Riard 和 Gleb Naumenko 在 Lightning-Dev 邮件列表[宣布][riard jam]，他们已经[发布][rn jam]了一份关于[通道堵塞攻击][topic channel jamming attacks]及若干提出的解决方案的指南。该指南还研究了一些解决方案如何使构建在 LN 之上的协议受益，例如互换协议和短期 [DLC][topic dlc]。

- **更新静默支付 PR：**woltx [发表][woltx sp]在 Bitcoin-Dev 邮件列表称，Bitcoin Core 的[静默支付][topic silent payments]的 PR 已更新。静默支付提供了一个可以被不同的支付者重复使用的地址，而不会在这些支出之间建立可在链上观察到的链接（尽管接收者需要小心不要通过他们的后续行动削弱这种隐私性）。该 PR 最显著的变化是为静默支付添加了一种新类型的[输出脚本描述符][topic descriptors]。

    该 PR 的新描述符的设计引起了相当多的讨论。值得注意的是，对于监控新交易，每个钱包只允许一个静默支付描述符是最有效的，但在许多情况下它也会给用户带来不好的体验。有人提议对静默支付设计进行轻微调整以解决该问题，尽管它也需要权衡。

## 服务和客户端软件的更改

*在这个月度专题中，我们重点介绍比特币钱包和服务的有意思的更新。*

- **Purse.io 增加闪电网络支持：**
  Purse.io 在[最近的一个推特][purse ln tweet]中宣布支持使用闪电网络进行存款（接收）和取款（发送）。

- **概念证明 coinjoin 实现 joinstr：**
  1440000bytes 开发了 [joinstr][joinstr github]，一个使用 [nostr 协议][nostr github] 的 [coinjoin][topic coinjoin] 概念证明实现。这是一个基于公钥的、无中心化服务器的中继网络。

- **Coldcard 固件 5.0.6 发布：**
  Coldcard 的 5.0.6 版本增加了对 [BIP85][]、`OP_RETURN` 脚本和多签[描述符][topic descriptors] 的更多支持。

- **Nunchuk 新增 Taproot 支持：**
  最新版本的 [Nunchuk 的手机钱包][nunchuk appstore]增加了对 [taproot][topic taproot]（单签）、[signet][topic signet]的支持，增强了 [PSBT][topic psbt]。

## 软件的新版本和候选版本

*流行比特币基础设施项目的新版本和候选版本。请考虑升级到最新版本或帮助测试候选版本。*

- [BDK 0.21.0][] 是这个用于构建钱包的库的最新发布版本。

- [Core Lightning 0.12.0][] 是这个流行的闪电网络节点实现的下一个主要版本的发布。该发布包括一个新的 `bookkeeper` 插件（参见 [Newsletter #212][news212 bookkeeper]）、一个 `commando` 插件（参见 [Newsletter #210][news210 commando]），增加对[静态通道备份][topic static channel backups]的支持，并让明确允许的对等方能够向您的节点打开[零配置通道][topic zero-conf channels]。这些新功能是对许多其他已添加功能的补充和错误修复。

- [LND 0.15.1-beta.rc1][] 是一个候选发布版本，“包括了支持[零配置通道][topic zero-conf channels]、scid [别名][aliases]以及在任何场景中使用 [taproot][topic taproot] 地址的开关”。

## 重大代码及文档变更

*本周内，[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo] 出现的重大变更。*

- [Bitcoin Core #25504][] 修复了对 `listsinceblock`、`listtransactions` 和 `gettransactions` 的响应，以实现在新字段 `parent_descs` 中声明相关描述符。此外，现在可以指定 `listsinceblock` 根据可选参数 `include_change` 显式地列出找零输出。通常，作为对外支付的隐性副产品，找零输出被省略，但在仅监视描述符的上下文中列出它们可能会很有趣。

- [Eclair #2234][] 添加了对在其公告中将 DNS 名称与节点相关联的支持，正如 [BOLTs #911][] 当前也已支持（参见 [Newsletter #212][news212 bolts911]）。

- [LDK #1503][] 添加了对 [BOLTs #759][] 定义的[洋葱信息][topic onion messages]的支持。 该 PR 表明此更改是为随后增加对[要约][topic offers]的支持做准备的。

- [LND #6596][] 添加了一个新的 `wallet addresses list` RPC，其中列出了所有钱包地址及其当前余额。

- [BOLTs #1004][] 开始建议维护有关路由的通道信息的节点应在通道关闭后至少等待 12 个区块，再删除其信息。此延迟将支持对[拼接][topic splicing]的检测。在这种情况下，通道实际上并未关闭，而是在链上交易中添加或移除了资金。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25504,2234,1503,911,759,6596,1004" %}
[core lightning 0.12.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.12.0
[bdk 0.21.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.21.0
[lnd 0.15.1-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.1-beta.rc1
[news212 bolts911]: /zh/newsletters/2022/08/10/#bolts-911
[aliases]: /zh/newsletters/2022/07/13/#lnd-5955
[woltx sp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020883.html
[riard jam]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-August/003673.html
[rn jam]: https://jamming-dev.github.io/book/
[news210 commando]: /zh/newsletters/2022/07/27/#core-lightning-5370
[news212 bookkeeper]: /zh/newsletters/2022/08/10/#core-lightning-5071
[joinstr github]: https://github.com/1440000bytes/joinstr
[nostr github]: https://github.com/nostr-protocol/nostr
[nunchuk appstore]: https://apps.apple.com/us/app/nunchuk-bitcoin-wallet/id1563190073
[purse ln tweet]: https://twitter.com/PurseIO/status/1557495102641246210
