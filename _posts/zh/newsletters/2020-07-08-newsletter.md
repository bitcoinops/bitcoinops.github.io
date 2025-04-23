---
title: 'Bitcoin Optech Newsletter #105'
permalink: /zh/newsletters/2020/07/08/
name: 2020-07-08-newsletter-zh
slug: 2020-07-08-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了一个关于基于 BIP32 路径模板的提案 BIP，并包括我们常规的部分，如 Bitcoin Core PR 审查俱乐部会议的总结、发布与候选发布，以及流行的比特币基础设施软件的值得注意的更改。

## 行动项

*本周无。*

## 新闻

- **<!--proposed-bip-for-bip32-path-templates-->****基于 BIP32 路径模板的提案 BIP：** Dmitry Petukhov 在 Bitcoin-Dev 邮件列表中[发布][petukhov path templates]了一份提案 BIP，建议一种标准化的格式来描述钱包应支持的 [BIP32][] 密钥派生路径。如今，许多钱包将用户限制在某些路径上，例如 [BIP44][] 及相关 BIP 描述的路径，不允许使用其他路径或使得使用其他路径变得困难。此限制的优点在于，用户只需重新安装软件钱包或购买兼容的硬件钱包，输入他们的种子或种子短语，即可通过钱包的默认路径恢复任何资金。然而，将特定路径硬编码也将钱包约束于开发人员设想的用例，而不是允许钱包用于其他目的或协议。路径模板为用户提供了一种简洁的方式，向钱包描述他们希望使用的路径。路径模板的紧凑性使得将模板与种子一起备份变得容易，有助于防止用户丢失资金。提案路径模板的另一个功能是能够描述派生限制（例如，钱包在特定路径上应派生不超过 50,000 个密钥），这可以使恢复过程在扫描接收到所有可能钱包密钥的比特币时更具实用性，从而消除 HD 钱包中的间隙限制问题（见 [Newsletter #52][news52 gap]）。

## Bitcoin Core PR 审查俱乐部

*在本月度栏目中，我们总结了最近一次 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club] 会议，重点介绍了一些重要的问题和答案。点击下面的问题以查看会议答案的摘要。*

[缓存 `getaddr` 响应以防止拓扑泄露][review club #18991] 是 Gleb Naumenko 的一个[PR][Bitcoin Core #18991]，旨在使间谍节点更难通过 `addr` 消息 gossip 推断 P2P 网络拓扑。

讨论从覆盖地址 gossip 的基本概念开始，随后重点讨论了目前可能存在的隐私泄露以及该 PR 打算改变的内容。

{% include functions/details-list.md
  q0="`addr` 传播和特别是 `getaddr`/`addr` 协议的重要性是什么？"
  a0="`addr` 传播用于节点在 P2P 网络上寻找新的潜在对等节点。"
  a0link="https://bitcoincore.reviews/18991.html#l-34"

  q1="**<!--q1-->**`addr` 传播的重要属性是什么？"
  a1="节点需要了解一组多样化的、近期在线的具有良好在线时间的对等节点。"
  a1link="https://bitcoincore.reviews/18991.html#l-57"

  q2="**<!--q2-->**间谍如何使用 `addr` 消息推断网络拓扑？"
  a2="推断拓扑的方式可能有多种，但讨论最多的方法是通过抓取节点的地址管理器（addrman）来确定地址记录如何在网络上传播，以及是否有任何节点对该地址记录有独特的时间戳（表明它们可能直接连接到该地址）。这是 [Coinscope 论文][Coinscope paper]中使用的方法。"
  a2link="https://bitcoincore.reviews/18991.html#l-129"

  q3="如果恶意行为者能够映射整个 P2P 网络拓扑，他们可能会做什么？"
  a3="了解整个 P2P 网络拓扑使得进行网络分区攻击或 [eclipse 攻击][topic eclipse attacks]变得更容易。"
  a3link="https://bitcoincore.reviews/18991.html#l-176"

  q4="如果节点缓存 `getaddr` 消息的响应并提供旧记录，这会成为问题吗？"
  a4="观点不同。有人认为 [P2P 网络上没有太多的变化][naumenko churn]，因此旧记录通常仍然有效；而其他人对此[并不确定][wuille churn]。"

  q5="此 PR 是否防止了唯一时间戳的拓扑推断？"
  a5="没有。此 PR 使得抓取节点的地址管理器（addrman）变得更加困难，但并未更改中继的地址记录上的时间戳。未来的 PR 可能会做进一步的更改来解决唯一时间戳的推断问题。"
  a5link="https://bitcoincore.reviews/18991.html#l-263"
%}

## 发布与候选发布

*流行的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Eclair 0.4.1][]：该新版本增加了对 `option_static_remotekey` 的支持（尽管默认情况下禁用），可以简化备份（见 [Newsletter #67][news67 bolts642]）。该版本还默认启用发送[多路径支付][topic multipath payments] (MPP)，使用了新的 MPP 拆分算法，提供了对使用 PostgreSQL 数据库的测试支持，并更好地管理您的节点与对等节点之间的费率不匹配——所有更改都在本 Newsletter 的*值得注意的更改*部分中详细描述。

- [LND 0.10.2-beta.rc4][lnd 0.10.2-beta]：此 LND 维护版本现已发布。它包含了多个错误修复，包括一个与创建备份相关的重要修复。

- [LND 0.10.3-beta.rc1][lnd 0.10.3-beta]：此版本独立于 0.10.2 版本，除 0.10.2 版本提供的错误修复外，还包括了包重构。详情请参阅 LND 开发者 Olaoluwa Osuntokun 的邮件列表[帖子][osuntokun rcs]。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #19204][] 消除了在初始区块下载（IBD）期间浪费带宽的来源。当 Bitcoin Core 处于 IBD 状态时，它通常没有必要的信息来验证当前未确认的交易，因此会忽略中继的交易公告。然而，这些公告仍然会消耗接收 IBD 节点及其发送对等节点的带宽。此 PR 使用 [BIP133][] 的 `feefilter` P2P 消息告诉对等节点该节点不希望接收低于 21 百万 BTC 每 1,000 vbytes 费用的交易公告，从而防止接收任何合法的交易公告。当节点完成跟踪最佳区块链的顶部时，它会发送另一条 `feefilter` 消息，设置其实际的最小中继费率，以便开始接收新公告的交易。

- [Bitcoin Core #19215][] 创建了包含每个先前交易的 [PSBTs][topic psbt]，即使是用于 segwit v0 的 UTXO。在此更改之前，先前的交易仅包含在传统（非 segwit）UTXO 中。此更改是对一些硬件钱包现在要求或推荐访问 segwit UTXO 的先前交易以缓解[手续费过高攻击][fee overpayment attack]的响应。如果 segwit v1（[taproot][topic taproot]）被采用，花费所有 taproot 输入的交易默认情况下不需要这些额外数据。

- [C-Lightning #3775][] 增加了四个用于 [PSBT][topic psbt] 生命周期管理的 RPC 方法，由 C-Lightning 的内部钱包支持。`reserveinputs` RPC 方法通过选择内部钱包中的 UTXO 作为输入来创建 PSBT，以满足用户指定的输出列表，并将选择的 UTXO 标记为已保留。生成的 PSBT 可以提供给 `unreserveinputs` RPC 方法以手动释放保留的 UTXO，或者提供给 `signpsbt` RPC 方法以从内部钱包添加签名。最后，`sendpsbt` RPC 方法会将完全签名的 PSBT 转换为可广播的交易并将其广播到网络。用户应注意，重新启动 C-Lightning 实际上会取消所有先前保留的 UTXO，需要使用 `reserveinputs` 重新创建新的 PSBT，才能使 `signpsbt` 接受它。

- [Eclair #1427][] 和 [#1439][Eclair #1439] 增加了 Eclair 对发送[多路径支付][topic multipath payments]的有效支持——将支付拆分为多个部分，每部分使用不同的路径进行路由。这些 PR 默认将支付拆分为最多六部分，最初为每部分分配 0.00015 BTC，但通过半随机方式增加每部分的值，直到全部支付金额被分配完毕。选定金额后，所有支付部分都会被发送。这不仅高效，还利用机会增加数值功能，以帮助防止看到部分支付的节点猜测全部支付金额，从而提高隐私性。如果您有兴趣了解详情，本周 Eclair 和 C-Lightning 的拆分算法由其作者进行了[讨论][split algos]。

- [Eclair #1249][] 增加了可选支持，允许使用 PostgreSQL 作为数据库后端替代默认的 SQLite。详情请参阅 Eclair 的新 [PostgreSQL 文档][eclair postgresql]。另见 Roman Taranchenko（也是该 PR 的作者）为 Optech 撰写的关于[在生产环境中使用 Eclair][eclair production] 的报告。

- [Eclair #1473][] 更新了 Eclair 的代码，以处理远程通道对等节点选择的链上费率与本地节点认为合适的费率之间的不匹配。此更改之后，如果远程对等节点选择的费率看起来过高，本地节点不会关闭通道，除非该费率比本地节点认为合适的费率高出十倍以上。这是可以接受的，因为远程对等节点支付费用，而高费用应该确保通道快速结算，对双方都有利。然而，如果费率设置低于本地节点期望值的 50%，它将立即关闭通道，以确保任何未结算的支付（HTLC）在费率进一步上升之前能够结算。PR 还确保当没有需要解决的支付时，不会因费用问题关闭通道。

- [LND #4167][] 允许使用 keysend（参见 [Newsletter #94][news94 keysend]）进行的[自发支付][topic spontaneous payments]在结算或取消之前进行检查——基本上，此 PR 为自发支付实现了[保持发票][topic hold invoices]。PR 描述指出了此功能的一个可能用途：“带有嵌入订单的 keysend 支付到达。支付被保留，一个外部应用程序检查支付金额是否足够支付订购的商品。如果不足，则取消支付而无需退款。如果金额足够，则结算支付并处理订单。”

- [HWI #351][] 升级了与 Ledger 硬件钱包交互所用的 [btchip-python][] 库的版本。新库版本解决了最新版本的 Ledger 设备的比特币应用程序中的一个[错误][ledger bug]，该错误在具有多个 segwit 输入的交易中产生了不正确的签名。Electrum 也已更新其库依赖项以修复[相同的问题][electrum update]。这两次升级都是应对[手续费过高攻击][fee overpayment attack] 的一部分。

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
