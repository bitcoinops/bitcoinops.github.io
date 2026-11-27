---
title: 'Bitcoin Optech Newsletter #105'
permalink: /zh/newsletters/2020/07/08/
name: 2020-07-08-newsletter-zh
slug: 2020-07-08-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了一份提案 BIP，内容是为基于 BIP32 的路径模板制定标准；我们还照例收录了 Bitcoin Core PR 审查俱乐部会议总结、发布与候选发布，以及热门比特币基础设施软件的值得注意的变更。

## 行动项

*本周无。*

## 新闻

- **<!--proposed-bip-for-bip32-path-templates-->****基于 BIP32 路径模板的提案 BIP：** Dmitry Petukhov 在 Bitcoin-Dev 邮件列表中[发布][petukhov path templates]了一份提案 BIP，建议一种标准化的格式来描述钱包应支持的 [BIP32][] 密钥派生路径。如今，许多钱包将用户限制在某些路径上，例如 [BIP44][] 及相关 BIP 描述的路径，不允许使用其他路径或使得使用其他路径变得困难。此限制的优点在于，用户只需重新安装软件钱包或购买兼容的硬件钱包，输入自己的种子或种子短语，即可通过钱包的默认路径恢复任何资金。然而，将特定路径硬编码也会把钱包限制在仅由其自身开发者设想的那类用例上，而不是允许钱包用于其他目的或协议。路径模板为用户提供了一种简洁的方式，向钱包描述他们希望使用的路径。路径模板的紧凑性使得将模板与种子一起备份变得容易，有助于防止用户丢失资金。所提议的路径模板还有一项功能：可以描述派生上限（例如规定钱包在某个路径上派生的密钥不得超过 50,000 个）。这样，恢复流程就能实际去扫描所有可能的钱包密钥所收到的比特币，从而打消人们对 HD 钱包间隙限制（gap limit）的顾虑（见 [Newsletter #52][news52 gap]）。

## Bitcoin Core PR 审查俱乐部

*在本月度栏目中，我们总结了最近一次 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club] 会议，重点介绍了一些重要的问题和答案。点击下面的问题以查看会议答案的摘要。*

[缓存 `getaddr` 的响应以防止拓扑泄露][review club #18991] 是 Gleb Naumenko 提出的一个 [PR][Bitcoin Core #18991]，旨在让间谍节点更难借 `addr` 消息的闲聊式传播来推断 P2P 网络拓扑。

讨论先介绍了地址传播的基本概念，随后聚焦于目前存在哪些隐私泄露、以及该 PR 打算改变什么。

{% include functions/details-list.md
  q0="`addr` 中继以及具体到 `getaddr`/`addr` 协议，为什么重要？"
  a0="`addr` 中继用于让节点在 P2P 网络上发现新的潜在对等节点。"
  a0link="https://bitcoincore.reviews/18991.html#l-34"

  q1="**<!--q1-->**`addr` 中继有哪些重要属性？"
  a1="节点需要找到一组多样化、近期在线且在线时长良好的对等节点。"
  a1link="https://bitcoincore.reviews/18991.html#l-57"

  q2="**<!--q2-->**间谍如何使用 `addr` 消息推断网络拓扑？"
  a2="推断拓扑的方式可能有多种，但讨论最多的是抓取节点的地址管理器（addrman），据以判断某条地址记录在网络上是如何扩散的，以及是否有节点对该地址记录持有独特的时间戳（若有，说明它们很可能与该地址直接相连）。[Coinscope 论文][Coinscope paper]用的就是这个方法。"
  a2link="https://bitcoincore.reviews/18991.html#l-129"

  q3="如果恶意行为者能够映射整个 P2P 网络拓扑，他们可能会做什么？"
  a3="掌握整个 P2P 网络拓扑，会让发动网络分区或[日食攻击（eclipse attack）][topic eclipse attacks] 之类的攻击更容易。"
  a3link="https://bitcoincore.reviews/18991.html#l-176"

  q4="如果节点缓存了对 `getaddr` 消息的响应并返回旧记录，这会成为问题吗？"
  a4="观点不一。有人认为 [P2P 网络上的节点流动并不大][naumenko churn]，所以旧记录通常仍然有效；也有人[不确定][wuille churn]。"

  q5="此 PR 是否防止了唯一时间戳的拓扑推断？"
  a5="没有。此 PR 使得抓取节点的地址管理器（addrman）变得更加困难，但并未更改中继的地址记录上的时间戳。未来的 PR 可能会做进一步的更改来解决唯一时间戳的推断问题。"
  a5link="https://bitcoincore.reviews/18991.html#l-263"
%}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Eclair 0.4.1][]：这个新版本增加了对 `option_static_remotekey` 的支持（不过默认关闭），可简化备份（见 [Newsletter #67][news67 bolts642]）。该版本还默认启用[多路径支付][topic multipath payments]（MPP）的发送，采用新的 MPP 拆分算法，提供使用 PostgreSQL 数据库的 beta 支持，并更好地处理你的节点与对等节点之间的费率不一致——所有改动都在本 Newsletter 的*值得注意的变更*部分详述。

- [LND 0.10.2-beta.rc4][lnd 0.10.2-beta]：此 LND 维护版本现已发布。它包含了多个错误修复，包括一个与创建备份相关的重要修复。

- [LND 0.10.3-beta.rc1][lnd 0.10.3-beta]：此版本独立于 0.10.2 版本，除 0.10.2 版本提供的错误修复外，还包括了包重构。详情请参阅 LND 开发者 Olaoluwa Osuntokun 的邮件列表[帖子][osuntokun rcs]。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi]、[比特币改进提案（BIPs）][bips repo]和[闪电网络 BOLT 规范][bolts repo]中的值得注意的变更。*

- [Bitcoin Core #19204][] 消除了一处带宽浪费来源，出现在初始区块下载（IBD）期间。当 Bitcoin Core 处于 IBD 时，它往往没有足够的信息去验证当前未确认的交易，于是会忽略中继来的交易公告。但这些公告仍会消耗接收方 IBD 节点及其发送方对等节点的带宽。此 PR 用 [BIP133][] 的 `feefilter` P2P 消息告诉对等节点：本节点不想接收任何手续费低于每 1,000 vbytes 2100 万 BTC 的交易公告，从而避免收到任何合法交易的公告。当节点追平最佳区块链的链尖后，它会再发一条 `feefilter` 消息，给出自己实际的最低中继费率，以便开始接收新公告的交易。

- [Bitcoin Core #19215][] 在生成 [PSBT][topic psbt] 时，会附带每一笔创建了当前交易正被花费的 UTXO 的前序交易——segwit v0 的 UTXO 也不例外。在此更改之前，只有传统（非 segwit）UTXO 才会附上前序交易。此次更改是为了回应一些硬件钱包的新要求：为缓解[手续费超额支付攻击][fee overpayment attack]，它们现在要求或建议能够访问 segwit UTXO 的前序交易。如果 segwit v1（[taproot][topic taproot]）得到采用，花费全部 taproot 输入的交易默认无需这些额外数据。

- [C-Lightning #3775][] 新增了四个用于 [PSBT][topic psbt] 生命周期管理的 RPC 方法，背后由 C-Lightning 的内置钱包支持。`reserveinputs` RPC 方法会从内置钱包中挑选 UTXO 作为输入，凑出用户指定的输出列表，从而创建一笔 PSBT，并把挑中的 UTXO 标记为已预留。生成的 PSBT 可以交给 `unreserveinputs` RPC 方法手动释放那些预留的 UTXO，也可以交给 `signpsbt` RPC 方法，由内置钱包添加签名。最后，`sendpsbt` RPC 方法会把完全签名的 PSBT 转成可直接广播的交易，并广播到网络上。用户需注意：重启 C-Lightning 实际上会取消此前所有预留的 UTXO，必须用 `reserveinputs` 重新创建 PSBT，`signpsbt` 才会接受它。

- [Eclair #1427][] 和 [#1439][Eclair #1439] 为 Eclair 增加了有效发送[多路径支付][topic multipath payments] 的能力——这种支付会被拆成若干部分，每部分走不同路径。这些 PR 默认把支付拆成最多六份，起初每份分配 0.00015 BTC，然后以半随机的方式逐步增加各份金额，直到全款分配完毕。金额确定后，所有分片一起发送。这不仅高效，还利用了这种逐步递增金额的做法，帮助防止只看到部分支付的节点猜出全额，从而提升隐私。如果你关心细节，本周 Eclair 与 C-Lightning 的拆分算法曾由其作者[讨论][split algos]。

- [Eclair #1249][] 增加了可选支持，允许使用 PostgreSQL 作为数据库后端替代默认的 SQLite。详情请参阅 Eclair 的新 [PostgreSQL 文档][eclair postgresql]。另见 Roman Taranchenko（也是该 PR 的作者）为 Optech 撰写的关于[在生产环境中使用 Eclair][eclair production] 的报告。

- [Eclair #1473][] 更新了 Eclair 的代码，用于处理远程通道对等节点选定的链上费率与本地节点认为合适的费率之间的不一致。此更改后，若远程对等节点选定的费率看起来过高，本地节点不会关闭通道，除非该费率超过本地节点认为合适费率的十倍。这可以接受，因为手续费由远程对等节点支付，且高手续费应能确保通道迅速结算，对双方都有利。但如果费率低于本地节点期望值的 50%，本地节点会立即关闭通道，以确保任何待处理的支付（HTLC）能在费率进一步上涨前完成结算。该 PR 还确保在没有需要处理的支付时，不会因手续费问题关闭通道。

- [LND #4167][] 允许在使用 keysend（参见 [Newsletter #94][news94 keysend]）进行[自发支付][topic spontaneous payments] 时，于结算或取消之前先行检查——基本上，这个 PR 为自发支付实现了[挂起发票][topic hold invoices]。PR 描述举出了该功能的一种可能用法：“一笔内嵌订单的 keysend 支付到达。该支付被挂起，外部应用检查支付金额是否足以购买所订购的商品。若不足，则取消该支付，无需退款。若金额足够，则结算该支付并处理订单。”

- [HWI #351][] 升级了它用来与 Ledger 硬件钱包交互的 [btchip-python][] 库版本。新版本规避了 Ledger 设备上最新版 Bitcoin 应用中的一个[错误][ledger bug]：该错误会让含多个 segwit 输入的交易产生不正确的签名。Electrum 也已更新其库依赖，修复了[同一个问题][electrum update]。两次升级都是在应对[手续费超额支付攻击][fee overpayment attack]。

{% include references.md %}
{% include linkers/issues.md issues="19204,19215,3775,1427,1249,1473,4167,351,1439,18991" %}
[lnd 0.10.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.2-beta
[lnd 0.10.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.3-beta
[eclair 0.4.1]: https://github.com/ACINQ/eclair/releases/tag/v0.4.1
[osuntokun rcs]: https://groups.google.com/a/lightning.engineering/forum/#!topic/lnd/jgd1ZC9T5n4
[eclair postgresql]: https://github.com/ACINQ/eclair/blob/b63c4aa5a4c4cb0645d66517942d12151e6b2069/docs/PostgreSQL.md
[news67 bolts642]: /zh/newsletters/2019/10/09/#bolts-642
[fee overpayment attack]: /zh/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[split algos]: https://github.com/ElementsProject/lightning/pull/3773#discussion_r448796405
[news94 keysend]: /zh/newsletters/2020/04/22/#c-lightning-3611
[petukhov path templates]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-July/018024.html
[news52 gap]: /zh/newsletters/2019/06/26/#how-can-i-mitigate-concerns-around-the-gap-limit
[ledger bug]: https://github.com/LedgerHQ/app-bitcoin/issues/154
[electrum update]: https://github.com/spesmilo/electrum/pull/6293#issuecomment-652471789
[eclair production]: /zh/suredbits-enterprise-ln/
[naumenko churn]: https://bitcoincore.reviews/18991.html#l-91
[wuille churn]: https://bitcoincore.reviews/18991.html#l-365
[btchip-python]: https://github.com/LedgerHQ/btchip-python
[coinscope paper]: https://www.cs.umd.edu/projects/coinscope/coinscope.pdf
[hwi]: https://github.com/bitcoin-core/HWI
