---
title: 'Bitcoin Optech Newsletter #161'
permalink: /zh/newsletters/2021/08/11/
name: 2021-08-11-newsletter-zh
slug: 2021-08-11-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 跟进了此前关于 JoinMarket 忠诚债券的报道，并包含我们的常规栏目：Bitcoin Core PR 审查俱乐部会议总结、为 Taproot 做准备的建议、新版本与候选版本的公告，以及热门基础设施项目值得注意的变更的介绍。

## 新闻

- **<!--implementation-of-fidelity-bonds-->****忠诚债券的实现：** [JoinMarket 0.9.0][] 的 [coinjoin][topic coinjoin] 实现加入了[忠诚债券][fidelity bonds doc]的[支持][jm notes]。正如 [Newsletter #57][news57 fidelity bonds] 中所述，忠诚债券提高了 JoinMarket 系统的抗女巫攻击（sybil resistance）能力，使 coinjoin 发起者（“taker”）更容易选到各不相同、彼此独立的流动性提供者（“maker”）。发布后几天内，已有[超过 50 BTC][waxwing toot]（目前价值超过 200 万美元）被投入带时间锁的忠诚债券中。

  尽管具体的实现是 JoinMarket 特有的，但整体设计可能对其他基于比特币构建的去中心化协议有一定的借鉴意义。

## Bitcoin Core PR 审查俱乐部

*在本月的这一部分，我们总结了最近一次 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议，重点介绍了一些重要的问题和答案。点击下面的问题查看会议中的答案总结。*

[Prefer to use txindex if available for GetTransaction][review club #22383] 是 Jameson Lopp 提出的一个 PR，它在可能时利用交易索引（txindex）来提升 `GetTransaction` 的性能（用户的 `getrawtransaction` RPC 也因此受益）。该变更修复了一处意外的性能损失：在启用了 txindex 的节点上，如果调用 `getrawtransaction` 时传入的是包含该交易的区块的哈希，速度会显著变慢。审查俱乐部通过比较使用和不使用 txindex 获取交易的步骤，分析了这一性能问题的成因。

{% include functions/details-list.md

  q0="**<!--q0-->**`GetTransaction` 获取交易的不同方式有哪些？"
  a0="交易可以从内存池中获取（如果未确认），通过从磁盘中获取整个区块并搜索交易，或者使用 txindex 从磁盘中单独获取交易。"
  a0link="https://bitcoincore.reviews/22383#l-33"

  q1="**<!--q1-->**为什么当提供区块哈希（启用 txindex 时）性能较差？"
  a1="参与者猜测瓶颈可能在于区块的反序列化。获取整个区块时还有另一项独有的操作——虽然耗时较少——即线性扫描整个交易列表。"
  a1link="https://bitcoincore.reviews/22383#l-42"

  q2="**<!--q2-->**如果我们通过区块哈希查找交易，步骤是什么？需要反序列化多少数据？"
  a2="我们首先使用区块索引查找访问区块所需的文件和字节偏移量。然后获取并反序列化整个区块，扫描交易列表直到找到匹配项。这涉及反序列化大约 1-2MB 的数据。"
  a2link="https://bitcoincore.reviews/22383#l-56"

  q3="**<!--q3-->**如果我们使用 txindex 查找交易，步骤是什么？需要反序列化多少数据？"
  a3="txindex 将交易 ID 映射到文件、区块位置（类似于区块索引）以及交易在 blk\*.dat 文件中的偏移位置。我们获取并反序列化区块头和交易。区块头为 80B，允许我们返回区块哈希给用户（这是 txindex 中没有存储的信息）。交易大小可以是任意的，但通常比区块小几千倍。"
  a3link="https://bitcoincore.reviews/22383#l-88"

  q4="**<!--q4-->**此 PR 的第一个版本包含一项行为变更：当向 `GetTransaction` 提供错误的 `block_index` 时，仍然借助 txindex 找到并返回该交易。你认为这个变更是一种改进吗？它应该包含在这个 PR 中吗？"
  a4="参与者一致认为这可能有所帮助，但也可能误导用户，把区块哈希输入有误的情况告知用户会更好。他们还指出，性能改进和行为变更最好拆分成不同的 PR。"
  a4link="https://bitcoincore.reviews/22383#l-128"
%}

## 准备 Taproot #8：多重签名的 nonce

*每周一期的[系列][series preparing for taproot]，介绍开发者与服务提供商如何为 Taproot 在区块高度 {{site.trb}} 的激活做准备。*

{% include specials/taproot/zh/07-nonces.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [C-Lightning 0.10.1][] 是一次发布，包含若干新功能、多项错误修复，以及若干处对仍在开发中的协议的更新（包括[双向资助][topic dual funding]和[offers][topic offers]）。

- [Bitcoin Core 22.0rc2][bitcoin core 22.0] 是该全节点实现及其配套钱包和其他软件下一个主要版本的候选版本。这个新版本的主要变更包括：支持 [I2P][topic anonymity networks] 连接、移除对 [版本 2 Tor][topic anonymity networks] 连接的支持，以及加强对硬件钱包的支持。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的值得注意的变更。*

- [Bitcoin Core #21528][] 旨在改善全节点监听地址在 P2P 网络中的传播。节点只有接触到多样化的地址集合，才能免受网络分区（例如[日食攻击][topic eclipse attacks]）的影响。当 Bitcoin Core 节点收到包含 10 个或更少地址的地址消息时，会把它中继给 1 到 2 个对等节点。这是节点公开自身地址的主要手段，因此若把地址发给不会中继这些地址的对等节点，实际上就会让传播停止，或者在这条路径上形成“黑洞”。虽然存在恶意行为时无法避免传播失败，但对于诚实节点（例如仅中继区块的连接或轻客户端），该补丁仍能改善地址传播。

  此次更新判断一条入站连接是否适合中继地址，依据是它是否在该连接上发送过与地址相关的消息，例如 `addr`、`addrv2` 或 `getaddr`。如果网络上有软件依赖接收地址消息、却从不主动发送地址相关消息，这一行为变更就可能带来问题。因此，作者在合并之前特意做了铺垫：先在[邮件列表][addrRelay improvements]上发布这项提案，并研究[其他开源客户端][addr client research]以确认兼容性。

- [LND #5484][] 允许把所有数据存储在一个外部 Etcd 数据库中。集群领导权的切换因此变为瞬时完成，从而改善高可用部署。相应的 LND 集群文档已在 [Newsletter #157][news157 lnd ha] 中介绍过。

- [Rust-Lightning #1004][] 为 `PaymentForwarded` 新增了一个事件，可用于跟踪支付是否已成功转发。成功的转发能为节点赚取手续费，因此用户可以把这笔收入记入自己的账目。

- [BTCPay Server #2730][] 让生成发票时金额变为可选。当运营者把金额的决定权交给用户时（例如用户为账户充值时），这可以简化支付流程。

{% include references.md %}
{% include linkers/issues.md issues="21528,5484,1004,2730,22383" %}
[C-Lightning 0.10.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.1
[joinmarket 0.9.0]: https://github.com/JoinMarket-Org/joinmarket-clientserver/releases/tag/v0.9.0
[jm notes]: https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/release-notes/release-notes-0.9.0.md#fidelity-bond-for-improving-sybil-attack-resistance
[fidelity bonds doc]: https://gist.github.com/chris-belcher/18ea0e6acdb885a2bfbdee43dcd6b5af/
[waxwing toot]: https://x0f.org/@waxwing/106696673020308743
[news57 fidelity bonds]: /zh/newsletters/2019/07/31/#fidelity-bonds-for-improved-sybil-resistance
[addrRelay improvements]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-April/018784.html
[addr client research]: https://github.com/bitcoin/bitcoin/pull/21528#issuecomment-809906430
[news157 lnd ha]: /zh/newsletters/2021/07/14/#lnd-5447
[bitcoin core 22.0]: https://bitcoincore.org/bin/bitcoin-core-22.0/
[series preparing for taproot]: /zh/preparing-for-taproot/
