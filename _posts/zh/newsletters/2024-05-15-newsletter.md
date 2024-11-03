---
title: 'Bitcoin Optech Newsletter #302'
permalink: /zh/newsletters/2024/05/15/
name: 2024-05-15-newsletter-zh
slug: 2024-05-15-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报宣布了支持 utreexo 的全节点的测试版，并总结了 BIP119 `OP_CHECKTEMPLATEVERIFY` 的两个扩展提议。此外，还包括我们的常规部分：其中包括新版本和候选版本的公告，以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **<!--Release-of-utreexod-beta-->utreexod 测试版发布：** Calvin Kim 在 Bitcoin-Dev 邮件列表中[宣布了][kim utreexo]支持 [utreexo][topic utreexo] 的全节点 utreexod 的测试版发布。utreexo 允许节点存储 UTXO 集状态的小型承诺，而不是整个集合本身；例如，最小承诺可以为 32 字节，而当前完整集合约为 12 GB，这使得承诺大约小了 10 亿倍。为了减少带宽，utreexo 可能会存储额外的承诺，增加磁盘使用空间，但仍将其链状态保持在比传统全节点小一百万倍左右的数量级。同时剪枝旧区块的 utreexo 节点可以在少量恒定的磁盘空间中运行，而即使是剪枝的常规完整节点，其链状态也可能超出设备存储容量的范围。

  Kim 发布的版本注释显示，该节点与基于 [BDK][bdk repo] 的钱包兼容，此外通过对 [Electrum 个人服务器][Electrum personal server]的支持，也可以支持许多其他钱包。该节点支持通过扩展 P2P 网络协议来中继 utreexo 证明的交易中继。支持_常规_和 _桥_两种 utreexo 节点；常规 utreexo 节点使用 utreexo 承诺来节省磁盘空间；而桥节点则存储完整的 UTXO 状态以及一些额外数据，并可以为尚不支持 utreexo 的节点和钱包创建的区块和交易附加 utreexo 证明。

  Utreexo 不需要共识更改，utreexo 节点也不会干扰非 utreexo 节点，尽管常规 utreexo 节点只能与其他常规 utreexo 节点和桥节点成为对等节点。

  Kim 在公告中包含了几个警告：“代码和协议尚未经过同行评审[...]将会有重大更改[...] utreexod 是基于 [btcd][] [可能存在]的共识不兼容性”。

- **<!--BIP119-extensions-for-smaller-hashes-and-arbitrary-data-commitments-->BIP119 扩展支持更小的哈希和任意数据承诺：**
  Jeremy Rubin 在 Bitcoin-Dev 邮件列表中 [发布了][rubin bip119e]一个[拟议的 BIP][bip119e]，以扩展提案 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (`OP_CTV`) 并附加两个功能：

  - *支持 HASH160 哈希：* 这些是用于 P2PKH、P2SH 和 P2WPKH 地址的哈希摘要。它们为 20 字节，而基础 [BIP119][] 提案中使用的哈希摘要为 32 字节。在朴素的多方协议中，针对 20 字节哈希的[碰撞攻击][collision attack]可以在大约 2<sup>80</sup> 次暴力操作中执行，这对积极性高的攻击者并非难事。因此，现代比特币操作码通常使用 32 字节哈希摘要。然而，在单方协议或使用 20 字节哈希的精良设计多方协议中，安全性可以提高到不太可能在少于约 2<sup>160</sup> 次暴力操作中被破坏，从而允许这些协议在每个摘要节省约 12 字节。一个可能有用的案例是在 [eltoo][topic eltoo] 协议(见[周报 #284][news284 eltoo])中实现。

  - *<!--support-for-additional-commitments-->支持其他承诺：* 仅当在包含输入和输出的交易中执行 `OP_CTV` 且这些输入和输出的哈希值与提供的哈希摘要相同，它才会被执行成功。其中一个输出可以是 `OP_RETURN` 输出，该输出提交脚本创建者希望发布到区块链的某些数据，例如从备份中恢复 LN 通道状态所需的数据。然而，将数据放在见证字段中的成本会大大降低。更新后的 `OP_CTV` 形式允许脚本创建者要求在对输入和输出进行哈希处理时包含来自见证堆栈的额外数据。该数据将与脚本创建者提供的哈希摘要进行对比检查。这可确保以最小的区块重量将数据发布到区块链。

  截至撰写本文时，该提议尚未在邮件列表中收到任何讨论。

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LDK v0.0.123][] 是用于构建支持 LN 应用程序的热门库的一个版本，它包括对[修剪的（不经济的）HTLC][topic trimmed htlc]设置的更新、对[BOLT12 要约][topic offers]的改进以及许多其他改进。

- [LND v0.18.0-beta.rc2][] 是这个热门的 LN 节点的下一个主要版本的候选版本。

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。_

- [Bitcoin Core #29845][] 更新了多个 `get*info` RPC，以将 `warnings` 字段从字符串更改为字符串数组，以便可以返回多个警告，而不仅仅是一个。

- [Core Lightning #7111][] 通过 libplugin 实用程序将 `check` RPC 命令提供给插件。通过启用使得配置选择生效的 `check setconfig` 来扩展使用范围，并且现存的 `check keysend` 现在验证 hsmd 是否会批准交易。预初始化消息已经被添加了带有预设 HSM 开发标志。有关 `check` 命令的更多参考，见周报[#25][news25 cln check]和[#47][news47 cln check]。

- [Libsecp256k1 #1518][] 添加了一个 `secp256k1_pubkey_sort` 函数，该函数将一组公钥按规范顺序排序。这对于 [MuSig2][topic musig] 和[静默支付][topic silent payments]都很有用，可能还包括许多其他涉及多个密钥的协议。

- [Rust Bitcoin #2707][] 更新了作为 [taproot][topic taproot] 的一部分引入的标记哈希的 API，以期在默认情况下，摘要为_内部字节顺序_。之前，API 期望哈希值为_显示字节顺序_，这种顺序现在可以使用诸如 `#[hash_newtype(backward)]` 的代码获得。由于[历史原因][mb3e byte order]，txid 和 区块标识符哈希摘要在交易和区块内以一种字节顺序（内部字节顺序）出现，但在用户界面中以相反的顺序（显示字节顺序）显示和调用。该 PR 试图防止更多哈希在不同情况下使用不同的字节顺序。

- [BIPs #1389][] 添加了 [BIP388][]，其中描述了“描述符钱包的钱包策略”，这是一组经过模板化的[输出脚本描述符][topic descriptors]，可能更容易被广泛的钱包在代码和用户界面中支持。特别是，在资源和屏幕空间有限的硬件钱包上实现描述符可能具有挑战性。BIP388 钱包策略允许选择加入的软件和硬件对如何使用描述符做出假设简化；这将描述符的范围降到最小，减少了所需的代码量和需要用户验证的细节数量。任何需要描述符全部功能的软件仍然可以独立于 BIP388 使用它们。有关更多信息，见[周报 #200][news200 policies]。

- [BIPs #1567][] 添加了 [BIP387][]，其中包括 `multi_a()` 和 `sortedmulti_a()` 描述符，它们在 [tapscript][topic tapscript] 中提供脚本化的多签名功能。以 BIP 中的一个示例，描述符片段 `multi_a(k,KEY_1,KEY_2,...,KEY_n)` 将生成类似 `KEY_1 OP_CHECKSIG KEY_2 OP_CHECKSIGADD ... KEY_n OP_CHECKSIGADD OP_k
 OP_NUMEQUAL` 的脚本。见周报[#191][news191 multi_a]、[#227][news227 multi_a] 和 [#273][news273 multi_a]。

- [BIPs #1525][] 添加了 [BIP347][]，其中提出了 [OP_CAT][topic op_cat] 操作码，如果在软分叉中[激活][topic soft fork activation]，可以在 [tapscript][topic tapscript] 中使用。另请见周报 [#274][news274 op_cat]、[#275][news275 op_cat] 和 [#293][news293 op_cat]。

## 周报发布日期变更

在接下来的几周内，Optech 将尝试其他发布日期。如果您提前或延迟几天收到周报，请不要感到惊讶。在短暂的实验期间，我们通过电子邮件发送的周报将包括一个跟踪器，以帮助我们确定有多少人阅读了周报。您可以通过在阅读周报之前禁用外部资源的加载来防止跟踪。如果您想要更多的隐私，我们建议您通过临时的 Tor 连接订阅我们的[RSS feed][]。对于给您带来的不便，我们深表歉意。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1525,1567,1389,2707,1518,7111,29845" %}
[lnd v0.18.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.0-beta.rc2
[mb3e byte order]: https://github.com/bitcoinbook/bitcoinbook/blob/6d1c26e1640ae32b28389d5ae4caf1214c2be7db/ch06_transactions.adoc#internal_and_display_order
[news200 policies]: /en/newsletters/2022/05/18/#adapting-miniscript-and-output-script-descriptors-for-hardware-signing-devices
[news191 multi_a]: /en/newsletters/2022/03/16/#bitcoin-core-24043
[news227 multi_a]: /zh/newsletters/2022/11/23/#how-do-i-create-a-taproot-multisig-address-taproot
[news273 multi_a]: /zh/newsletters/2023/10/18/#bitcoin-core-27255
[news274 op_cat]: /zh/newsletters/2023/10/25/#proposed-bip-for-op-cat-op-cat-bip
[news275 op_cat]: /zh/newsletters/2023/11/01/#op-cat
[news293 op_cat]: /zh/newsletters/2024/03/13/#bitcoin-core-pr-审核俱乐部
[kim utreexo]: https://mailing-list.bitcoindevs.xyz/bitcoindev/d5f47120-3397-4f56-93ca-dd310d845f3cn@googlegroups.com/T/#u
[electrum personal server]: https://github.com/chris-belcher/electrum-personal-server
[btcd]: https://github.com/btcsuite/btcd
[rubin bip119e]: https://mailing-list.bitcoindevs.xyz/bitcoindev/35cba1cd-eb67-48d1-9615-e36f2e78d051n@googlegroups.com/T/#u
[bip119e]: https://github.com/bitcoin/bips/pull/1587
[news284 eltoo]: /zh/newsletters/2024/01/10/#ctv
[collision attack]: https://en.wikipedia.org/wiki/Collision_attack
[rss feed]: /feed.xml
[ldk v0.0.123]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.123
[news25 cln check]: /en/newsletters/2018/12/11/#c-lightning-2123
[news47 cln check]: /en/newsletters/2019/05/21/#c-lightning-2631
