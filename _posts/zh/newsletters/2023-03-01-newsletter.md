---
title: 'Bitcoin Optech Newsletter #240'
permalink: /zh/newsletters/2023/03/01/
name: 2023-03-01-newsletter-zh
slug: 2023-03-01-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了一场关于不使用电子设备而鉴别 BIP32 种子词备份损坏的最快方法的讨论。此外是我们的常规栏目：软件的新版本和候选版本的公告，以及流行的比特币基础设施软件的重大变更总结。

## 新闻

- **<!--faster-seed-backup-checksums-->更快的种子词备份校验和**：Peter Todd 在关于 Codex32  —— 一种可以创建、验证 [BIP32][BIP32] 种子词并为之使用恢复码的方案（详见[上周的周报][news239 codex32]）—— 的 BIP 草案讨论中[回复][todd codex32]道，Codex32 相比现有方案，一个特别的优势是它只需使用纸、笔、说明书以及一些时间，就可以验证备份的完整性。

    从设计上，Codex32 就为其检测备份错误的能力提供了非常强的保证。Peter Todd 提出，一种便利得多的办法是在制作恢复码时，让恢复码的各部分可以相加、形成一个校验和。如果这个校验和除以一个已知的常数不会产生余数，那就在校验和算法的参数内验证了备份的完整性。Peter Tode 建议使用能以 99.9% 的概率侦测出笔误的算法，他认为这就足够健壮了，而且这种办法应该是易于使用、易于记忆的，这样用户就不需要额外的 Codex32 记录。

    Russell O'Connor [回应][o'connor codex32]道，一份完整的 Codex32 恢复码检查起来可以比完全验证快得多，只要用户愿意容忍少许误差的话。一次只检查两个字母，保证可以检测出恢复码的任何单字母错误，并为其它的置换性错误（subsittution errors）提供 99.9% 的保护。这个过程在一定程度上类似于生成 Peter Todd 所说的那种校验和，不过这需要使用一张特殊的查找表，普通用户是不太可能记得住的。如果验证者愿意每次检查恢复码的时候都使用一张不同的查找表，每多一次验证都会提高他们发现错误的概率，最多可以累加 7 次，这时候他们将获得跟完整的 Codex32 验证相同的概率保证。不需要改变 Codex32 来获得这种不断强化的快速检查特性，只是 Codex32 的说明书需要更新，以提供必要的查找表和工作表。

## 新版本和候选版本。

热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。

- [HWI 2.2.1][] 是这个应用的维护版本。该应用允许软件钱包跟硬件签名设备交互。

- [Core Lightning 23.02rc3][] 是这个热门的闪电节点实现的新维护版本的候选。

- [lnd v0.16.0-beta.rc1][] 是这个热门的闪电节点实现的大版本的候选。

## 重要的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo]。*

- [Bitcoin Core #25943][] 给`sendrawtransaction` RPC 加入了一个参数，用于限制每个输出烧掉的资金数量。如果一笔交易包含了一个输出，其脚本是可猜测出是不可花费的（例如带有 `OP_RETURN`、无效的操作码或者超过了脚本长度的最大限制），而且其价值大于 `maxburnamount`，则这笔交易不会被发送到交易池中。这个数值默认是 0，防止用户以外烧掉资金。

- [Bitcoin Core #26595][] 给 [`migratewallet`][news217 migratewallet] RPC 加入了 `wallet_name` 和 `passphrase` 参数，以支持将加密的老式钱包迁移成[描述符][topic descriptors]钱包。

- [Bitcoin Core #27068][] 更新了 Bitcoin Core 处理 “密语（passphrase）” 条目的方法。以前，一个包含 ASCII 空字符（0x00）的密语也会被接受 —— 但只有第一个空字符以前的部分会被用来加密钱包。这可能会导致钱包的密语比用户预期的更不安全。这个 PR 将使用完整的密语，包括空字符，来加密和解密。如果用户输入了一个包含空字符的密语，而无法解密现在的钱包，这说明他们可能已经在旧模式下设置过密语，他们会得到排查原因的指引。

- [LDK #1988][] 给对等连接和未注资的通道添加了限制，以防止拒绝服务式攻击耗尽本地的资源。新的限制有：

    - 同时最多只能跟 250 个与本地没有注资通道的对等节点分享数据。

    - 同时最多只能跟 50 个对等节点尝试开启通道。

    - 跟同一个对等节点最多只能有 4 条通道等待注资。

- [LDK #1977][] 创建了公开的 its 结构，以序列化和解析 [BOLT12 草案][bolts #798]所定义的 [offers][topic offers]。LDK 还没有支持[盲化路由][topic rv routing]，所以它当前还不能直接接收和发送 offer。但这个 PR 让开发者可以开始实验功能了。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25943,26595,27068,1988,1977,798" %}
[core lightning 23.02rc3]: https://github.com/ElementsProject/lightning/releases/tag/v23.02rc3
[lnd v0.16.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc1
[hwi 2.2.1]: https://github.com/bitcoin-core/HWI/releases/tag/2.2.1
[news239 codex32]: /zh/newsletters/2023/02/22/#codex32-bip
[todd codex32]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021498.html
[o'connor codex32]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021504.html
[news217 migratewallet]: /zh/newsletters/2022/09/14/#bitcoin-core-19602
