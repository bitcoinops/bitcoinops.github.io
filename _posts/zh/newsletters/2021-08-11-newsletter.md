---
title: 'Bitcoin Optech Newsletter #161'
permalink: /zh/newsletters/2021/08/11/
name: 2021-08-11-newsletter-zh
slug: 2021-08-11-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 跟进了之前关于 JoinMarket 中忠诚债券的描述，并包含了我们常规的部分，包括 Bitcoin Core PR 审查俱乐部会议的总结、关于为 Taproot 做准备的建议、发布与候选发布的公告，以及对流行基础设施项目的值得注意的更改描述。

## 新闻

- **<!--implementation-of-fidelity-bonds-->****忠诚债券的实现：** [JoinMarket 0.9.0][]
  实现了 [coinjoin][topic coinjoin] 支持[忠诚债券][fidelity bonds doc]。正如在 [Newsletter #57][news57 fidelity bonds] 中所描述的，忠诚债券提高了 JoinMarket 系统的 Sybil 抵抗力，增强了 coinjoin 发起者（“takers”）选择独特流动性提供者（“makers”）的能力。发布几天后，[超过 50 BTC][waxwing toot]（目前价值超过 200 万美元）已被投入到时锁定的忠诚债券中。

  尽管具体的实现是 JoinMarket 特有的，但整体设计可能对其他基于比特币构建的去中心化协议有一定的借鉴意义。

## Bitcoin Core PR 审查俱乐部

*在本月的这一部分，我们总结了最近一次 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议，重点介绍了一些重要的问题和答案。点击下面的问题查看会议中的答案总结。*

[Prefer to use txindex if available for GetTransaction][review club #22383] 是 Jameson Lopp 提出的一个 PR，该 PR 通过在可能的情况下利用交易索引（txindex）来提升 `GetTransaction`（以及扩展的 `getrawtransaction` RPC）的性能。这个更改解决了一个意外的性能损失问题，即当在启用 txindex 的节点上通过区块哈希调用 `getrawtransaction` 时，速度显著变慢。审查俱乐部通过比较使用和不使用 txindex 获取交易的步骤来评估该性能问题的原因。

{% include functions/details-list.md

  q0="**<!--q0-->**`GetTransaction` 获取交易的不同方式有哪些？"
  a0="交易可以从内存池中获取（如果未确认），通过从磁盘中获取整个区块并搜索交易，或者使用 txindex 从磁盘中单独获取交易。"
  a0link="https://bitcoincore.reviews/22383#l-33"

  q1="**<!--q1-->**为什么当提供区块哈希（启用 txindex 时）性能较差？"
  a1="参与者猜测瓶颈可能在于区块的反序列化。获取整个区块时的另一个过程 - 尽管消耗时间较少 - 是对整个交易列表进行线性搜索。"
  a1link="https://bitcoincore.reviews/22383#l-42"

  q2="**<!--q2-->**如果我们通过区块哈希查找交易，步骤是什么？需要反序列化多少数据？"
  a2="我们首先使用区块索引查找访问区块所需的文件和字节偏移量。然后获取并反序列化整个区块，扫描交易列表直到找到匹配项。这涉及反序列化大约 1-2MB 的数据。"
  a2link="https://bitcoincore.reviews/22383#l-56"

  q3="**<!--q3-->**如果我们使用 txindex 查找交易，步骤是什么？需要反序列化多少数据？"
  a3="txindex 将交易 ID 映射到文件、区块位置（类似于区块索引）以及交易在 blk\*.dat 文件中的偏移位置。我们获取并反序列化区块头和交易。区块头为 80B，允许我们返回区块哈希给用户（这是 txindex 中没有存储的信息）。交易大小可以是任意的，但通常比区块小几千倍。"
  a3link="https://bitcoincore.reviews/22383#l-88"

  q4="**<!--q4-->**此 PR 的第一个版本包含了一个行为更改：当向 `GetTransaction` 提供错误的 `block_index` 时，仍然使用 txindex 查找并返回交易。你认为这个更改是改进吗？它应该包含在这个 PR 中吗？"
  a4="参与者一致认为这可能有帮助，但可能会误导用户，通知用户错误的区块哈希输入会更好。他们还指出，性能改进和行为更改应该分开在不同的 PR 中进行。"
  a4link="https://bitcoincore.reviews/22383#l-128"
%}

## 准备 Taproot #8：多签随机数

*这是一个关于开发者和服务提供者如何为即将激活的 Taproot 做准备的每周[系列][series preparing for taproot]。*

{% include specials/taproot/zh/07-nonces.md %}

## 发布与候选发布

*流行的比特币基础设施项目的新发布和候选发布。请考虑升级到新发布版本或帮助测试候选发布。*

- [C-Lightning 0.10.1][] 是一个包含若干新功能、几个 bug 修复以及对开发中协议（包括 [dual funding][topic dual funding]和 [offers][topic offers]）的更新的发布。

- [Bitcoin Core 22.0rc2][bitcoin core 22.0] 是下一个主要版本的发布候选版本，包括其完整节点实现及其相关的钱包和其他软件。此版本的主要更改包括支持 [I2P][topic anonymity networks] 连接、移除对 [版本 2 Tor][topic anonymity networks] 连接的支持，并增强了对硬件钱包的支持。

## 值得注意的代码与文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范(BOLTs)][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #21528][] 旨在改善 P2P 传播中的完整节点监听地址。在节点防止网络分区（如 [eclipse 攻击][topic eclipse attacks]）方面，暴露多样化的地址集非常重要。当 Bitcoin Core 节点接收到一个包含 10 个或更少地址的地址消息时，它会将其转发给 1 或 2 个对等节点。这是自我广告地址的主要技术，因此将地址发送给不会转发这些地址的对等节点实际上会停止或“黑洞”网络中的传播。虽然在恶意情况下无法防止传播失败，但此补丁改进了在诚实情况下的地址传播，例如在仅用于区块中继连接或轻客户端的情况下。

  此更新通过识别传入连接是否为转发地址的候选，来改善地址传播，具体是通过检查该连接是否发送过地址相关消息（如 `addr`、`addrv2` 或 `getaddr`）。如果网络中有依赖于接收地址消息但从不主动发送地址相关消息的软件，这一行为更改可能会造成问题。因此，作者在合并该更改之前，采取了在[邮件列表][addrRelay improvements]上发布该提案并研究[其他开源客户端][addr client research]以确认兼容性的措施。

- [LND #5484][] 允许将所有数据存储在一个外部 Etcd 数据库中。这通过使集群领导权的变化变得即时，改善了高可用性部署。相应的 LND 集群文档曾在 [Newsletter #157][news157 lnd ha] 中介绍过。

- [Rust-Lightning #1004][] 为 `PaymentForwarded` 添加了一个新事件，该事件允许追踪支付是否已成功转发。由于成功的转发可能为节点带来费用收入，这使得用户能够跟踪该收入并记录到会计记录中。

- [BTCPay Server #2730][] 在生成发票时使金额变为可选。这简化了支付流程，尤其是在操作员将金额选择委托给用户的情况下，例如当用户为账户充值时。

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
