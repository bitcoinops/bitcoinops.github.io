---
title: 'Bitcoin Optech Newsletter #249'
permalink: /zh/newsletters/2023/05/03/
name: 2023-05-03-newsletter-zh
slug: 2023-05-03-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报总结了一份关于使用灵活的限制条款设计来实现 `OP_VAULT` 提议的分析、一篇关于适配器签名安全性的文章，还转发了一份招聘公告：对我们的一些读者来说，这份工作可能非常有趣。此外还有我们的常规栏目：软件的新版本和候选版本、热门的比特币基础设施软件的重大变更。

## 新闻

- **<!--mattbased-vaults-->基于 MATT 的保险柜**：Salvatore Ingala 在 Bitcoin-Dev 邮件组中[发帖][ingala vaults]给出了一个跟最近提议的 OP_VAULT 提议（见[周报 #234][news234 op_vault]）有类似效果的 “保险柜（[vault][topic vaults]）” 粗糙实现；但是，这个实现是基于 Ingala 的 “Merklize All The Things（MATT）” 提议的（见[周报 #226][news226 matt]）。MATT 需要软分叉添加少数非常简单的 “限制条款（[covenant][topic covenants]）” 操作码，就可以在比特币上创建非常灵活的合约。

    在本周的帖子中，Ingala 尝试证明 MATT 不仅非常灵活，而且在未来可能经常被使用的交易模板中也非常高效且易于使用。就像最新版本的 `OP_VAULT` 提议一样，Ingala 的工作基于 [BIP119][]，也即 “[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify]（CTV）”。使用两个额外提议的操作码（同时承认它们并没有涵盖所需的所有东西），他提供了一组几乎等价于 `OP_VAULT` 的特性。唯一重大的缺失是 “可以添加一个额外的输出、将资金发回相同的保险柜的选项”。

    截至本文撰写之时，Ingala 的帖子还没收到任何直接的回应，但有一些关于他的 MATT 初始提议（及其允许（几乎）任意复杂程序的运行得到验证的能力）的[持续讨论][halseth matt]。

- **<!--analysis-of-signature-adaptor-security-->适配器签名安全性的分析**：Adam Gibson 在 Bitcoin-Dev 邮件组中[发帖][gibson adaptors]列出了一份关于 “[适配器签名][topic adaptor signatures]” 的安全性的分析，尤其是适配器签名跟 [MuSig][topic musig] 这样的[多签名][topic multisignature]协议的相互作用（多方需要免信任地相互协作以创建适配器）。人们曾经计划在近期内使用适配器签名来升级闪电网络协议，以支持 “[PTLCs][topic ptlc]” 这样的功能、获得更好的效率和隐私性。它也被设想用在许多别的协议中，主要也是为了提高效率或隐私性，或兼而有之。适配器签名是新的、更好的比特币协议的最强大的模块之一，所以对其安全性的细致分析是非常必要的，这样才能保证其正确使用。Gibson 以 Lloyd Founier 及他人的分析（见[周报 #129][news129 adaptors]）为基础，但他也指出了需要进一步分析的领域，并希望自己的贡献得到审核。

- **<!--job-opportunity-for-project-champions-->项目带头人的工作机会**：奖金授予机构 Spiral 的 Stele Lee 在 Bitcoin-Dev 邮件组中[发帖][lee hiring]，请求拥有丰富经验的比特币贡献者申请一个带薪的全职工作、领导可以为比特币的长期可扩展性、安全性、隐私性和灵活性的跨团队项目。详情请见帖子。

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试旧版本。*

- [LND v0.16.2-beta][] 是这个闪电节点实现的小更新，包含了多项 bug 修复，以 “处理上一次小更新带来的性能回落。”

- [Core Lightning 23.05rc2][] 这是个闪电节点实现的下一个版本的候选。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]*。

- [Bitcoin Core #25158][] 给交易细节添加了一个 `abandoned` 字段，以响应来自 `gettransaction`、`listtransactions` 和 `listsinceblock` RPC 的、说明某个交易已被[抛弃][abandontransaction rpc]的消息。

- [Bitcoin Core #26933][] 重新引入了每一笔交易都要符合节点的最低转发手续费（`-minrelaytxfee`）才能进入该节点的交易池的规则，即使作为一个交易包的一部分也不例外。交易包验证规则依然允许在低于动态的交易池最低费率时为交易追加手续费。重新引入这个对策，是为了避免零手续费的交易在替换中失去其追加手续费的后代的风险。如果未来出现了一种防止这类交易的抗 DoS 措施，例如，像 v3 这样的交易包拓扑限制或者对交易池的退出流程的修改，那么这个规则可能又会逆转。

- [Bitcoin Core #25325][] 为 UTXO 缓存引入了一个基于池子的内存资源。这种新的数据结构预先分配并管理一个更大的交易池，以跟踪 UTXO，而不是为每一个 UTXO 单独分配和释放内存。UTXO 检索是内存读取的一大部分，尤其在初次区块下载期间。基准测试显示，重新编制索引的速度因为更高效的内存管理而加速了 20%。

- [Bitcoin Core #25939][] 允许启用了可选交易索引号的节点在使用 `utxoupdatepsbt` RPC 更新一个 [PSBT][topic psbt] 时搜索这样的索引，以使用关于这笔交易正在花费的输出的信息。这个 RPC 最早是在 2019 年实现的（见[周报 #34][news34 psbt]），那时候网络中常见的输出有两种：传统的输出和隔离见证 v0 输出。一个 PSBT 花费的每一个传统输出，都需要包含一个产生该输出的交易的完整拷贝，以便签名者验证这个输出的面额。不验证输出的面额就花费它，可能导致花费者付出高得离谱的手续费，所以验证是很重要的。

    而花费一个隔离见证 v0 输出时，因为签名需要承诺其金额，所以人们尝试让 PSBT 仅携带输出的脚本公钥和数额，而不是前序交易的完整拷贝。人们曾经认为，这可以消除包含完整交易的需要。因为每一笔已经确认的交易的所有未花费的交易输出，都存储在 Bitcoin Core 的 UTXO 集中，`utxoupdatepsbt` 可以为花费一个 UTXO 的 PSBT 添加必要的脚本公钥和面额数据。`utxoupdatepsbt` 以前也会搜索本地节点的交易池，让用户可以花费未确认的交易的 UTXO。

    然而，在 `utxoupdatepsbt` 添加到 Bitcoin Core 之后，多种硬件签名设备都开始要求花费隔离见证 v0 输出时也携带完整的交易，以防止过度支付手续费的变种（可能会因为用户两次签名同一笔交易而出现，见[周报 #101][news101 overpayment]）。这增加了在一个 PSBT 中包含完整交易的需要。

    这个合并的 PR 会搜索交易索引（如果节点启用了）和本地节点的交易池，以获得完整的交易，然后在 PSBT 中包含它们（如果需要的话）。如果没有找到完整的交易，则 UTXO 集将被用户隔离见证输出的花费。注意，Taproot（隔离见证 v1）为至少花费一个 taproot 输出的绝大部分交易消除了过度支付手续费的顾虑，所以我们估计，未来的签名设备升级将在这种情况下停止请求完整的交易。

- [LDK #2222][] 允许使用来自某个节点的 gossip 信息来更新其所在的通道的信息，而无需验证该通道是否与某个 UTXO 对应。闪电网络的 Gossip 消息本来只应在发起消息的节点所属的通道具有可证明的 UTXO 时才被接受，因为这是闪电网络协议设计用来防范拒绝服务攻击（DoS）的办法，但一些闪电节点可能没有能力检索 UTXO，或者有别的办法来防止 DoS 攻击。这个合并的 PR 让他们更容易在没有 UTXO 数据源的情况下使用信息。

- [LDK #2208][] 为被强制关闭的通道中的未决 [HTLCs][topic htlc] 添加了重新广播和追加手续费的方法。这可以帮助解决一些 “[钉死攻击][topic transaction pinning]” 并保证可靠性。亦见[周报 #243][news243 rebroadcast]：LND 添加了自己的重新广播接口；以及[上周的周报][news247 rebroadcast]：CLN 优化了自己的逻辑。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25158,26933,25325,2222,2208,25939" %}
[Core Lightning 23.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc2
[lnd v0.16.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.2-beta
[news101 overpayment]: /en/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[news129 adaptors]: /en/newsletters/2020/12/23/#ptlcs
[news243 rebroadcast]: /zh/newsletters/2023/03/22/#lnd-7448
[news247 rebroadcast]: /zh/newsletters/2023/04/19/#core-lightning-6120
[ingala vaults]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021588.html
[news226 matt]: /zh/newsletters/2022/11/16/#general-smart-contracts-in-bitcoin-via-covenants
[news234 op_vault]: /zh/newsletters/2023/01/18/#vault
[halseth matt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021593.html
[gibson adaptors]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021594.html
[lee hiring]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021589.html
[news34 psbt]: /en/newsletters/2019/02/19/#bitcoin-core-13932
[abandontransaction rpc]: https://developer.bitcoin.org/reference/rpc/abandontransaction.html

