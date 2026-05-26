---
title: 'Bitcoin Optech Newsletter #359'
permalink: /zh/newsletters/2025/06/20/
name: 2025-06-20-newsletter-zh
slug: 2025-06-20-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的新闻部分介绍了一个在 Bitcoin Core 代码库中限制公开参与的提议、宣布了一个对 BitVM 式合约的重大改进，并总结了对闪电通道再平衡的研究。此外是我们的常规栏目：客户端和服务端软件近期的变更总结、软件新版本和候选版本的公告、热门的比特币基础设施软件的近期变更介绍。

## 新闻

- **<!--proposal-to-restrict-access-to-bitcoin-core-project-discussion-->** **限制对 Bitcoin Core 项目访问的提议和讨论**：Bryan Bishop 在 Bitcoin-Dev 邮件组中[发帖][bishop priv]建议 Bitcoin Core 项目限制公众参与项目讨论的能力，以减少由非贡献者带来的干扰。他称之为 “私密化 Bitcoin Core”，并指出了这种私密化已经作为一种权宜之计、在多位 Bitcoin Core 贡献者的私人办公室中发生的例子，并警告说，面对面的私密化会疏远远程贡献者。

  Bishop 的帖子提出了一种线上私密化的方法，但 Antoine Poinsot [质疑][poinsot priv]这种办法能否实现目标。Poinsot 还指出，许多私人办公室讨论之所以发生，可能并不是因为对公开批评的畏惧，而是因为 “面对面讨论的天然优势”。

  多个回复都指出，此时作出重大变更可能是不合理的，但对库中的评论作出更强力的调节也许能缓解破坏力最大的干扰类型。不过，其它回复也指出了更强力调节将面临的一些挑战。

  Poinsot、Sebastian "The Charlatan" Kung 和 Russell Yanofsky —— 截至本刊撰写之时，回复此帖的人中仅有的几位高度活跃的 Bitcoin Core 贡献者 —— [表示][kung priv]要么[不认为][yanofsky priv]重大变更是必要的，要么任何变更都应该渐进施行。

- **<!--improvements-to-bitvmstyle-contracts-->** **BitVM 式合约的重大提升**：Robin Linus 在 Delving Bitcoin 中[宣布][linus bitvm3]， [BitVM][topic acc] 式合约在所要求的链上空间数量上取得重大削减。基于 Jeremy Rubin 的一个[想法][rubin garbled]、开发出新的密码学原语后，新方法 “相比于原有的设计，将争议解决的链上开销降低了超过 1000 倍”，反证交易 “只有 200 字节大小”。

  不过，Linus 的论文也指出了这一方法的取舍：它 “的启动设置需要几 TB 的链下数据”。论文给出了一个 SNARK 验证器电路的例子，由 500 万个逻辑门组成，而合理的安全参数需要 5 TB 的链下数据；见证结果需要 56 kB 的链上交易，在一方需要证明这样的结果无效的情形中，只需要提交极小的链上交易（约 200 B）。

- **<!--channel-rebalancing-research-->** **通道再平衡研究**：Rene Pickhardt 在 Delving Bitcoin 论坛中[发布][pickhardt rebalance]了关于再平衡通道来最大化整个网络的支付成功率的想法。他的想法可以跟关注更小的通道集群的想法（比如 “[朋友的朋友再平衡][topic jit routing]”，详见 [周报 #54][news54 foaf rebalance]）相比较。

  Pickhardt 指出全局方法面临许多挑战，并请求感兴趣的参与者回答几个问题，比如这个方法是否值得追求、如何解决特定的实现细节。

## 服务端和客户端软件的变更

*在这个月度栏目中，我们会列出比特币钱包和服务的有趣更新。*

- **<!--cove-v100-released-->** **Cove v1.0.0 发布**：Cove 的[最新版本][cove github]加入了钱币控制功能以及 [BIP329][] 钱包标签特性。

- **<!--liana-v110-released-->** **Liana v11.0 发布**：Liana 的[最新版本][liana github]加入了多钱包特性、钱币控制特性以及对更多硬件签名器的支持；此外还新增了别的特性。

- **<!--stratum-v2-stark-proof-demo-->** **Stratum v2 STARK 证明演示**：StarkWare [演示][starkware tweet]了一个[修改后的 Stratum v2 挖矿客户端][starkware sv2]，使用一个 SATRK 证据来证明属于一个有效的区块模板的手续费，而不必揭开这个区块中的交易。

- **<!--breez-sdk-adds-bolt12-and-bip353-->** **Breez SDK 加入了 BOLT12 和 BIP353**：Breez SDK Nodeless [0.9.0][breez github] 添加了使用 [BOLT12][] 和 [BIP353][] 来收款的特性。

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Core Lightning 25.05][] 是这个热门的闪电节点实现的下一个主要版本的候选发行。该版本降低了转发和解析支付的时延、增强了手续费管理、提供了跟 Eclair 兼容的 “[通道拼接][topic splicing]” 特性，并默认启用[对等节点存储协议][topic peer storage]。注意：其[发行说明书][core lightning 25.05]包含了一个对使用 `--experimental-splicing` 配置选项的用户的警告。

## 显著的代码和说明书变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Eclair #3110][] 将标记一条通道为关闭的时延从其注资输出被花费之后的 12 个区块（详见周报 [#337][news337 delay]）提高到 72 个区块，如 [BOLTs #1270][] 所指定的，以允许[拼接][topic splicing]更新的传播。提高这一数值，是因为一些实现在发送 `splice_locked` 之前默认要等待 8 个区块，而且允许节点运营者提高这个门槛，所以 12 个区块已经被证明是太短了。当前，这一数值在测试用途中是可以配置的，以允许节点运营者等待更长时间。

- [Eclair #3101][] 引入了 `parseoffer` PRC，它会解码 [BOLT12 offer][topic offers] 为明文可读的格式，从而用户可以在将 offer 传递给 `payoffer` PRC 之前看到支付的数额。后者已经扩展成接受以法币单位指定的数额。

- [LDK #3817][] 撤回了对 “[可归因故障][topic attributable failures]”（详见周报 [#349][news349 attributable]）的支持，仅在 test-only 的启动标签下才可使用。这禁用了对等节点的惩罚逻辑，并从传递故障的[洋葱消息][topic onion messages]中移除了特性 TLV。尚未升级的节点被错误地惩罚了，表明更广泛的网络采用是这种技术正常工作的前提。

- [LDK #3623][] 拓展了[对等节点存储协议][topic peer storage]（详见周报 [#342][news342 peer]）以提供自动化的、加密的对等节点备份。每过一个区块，`ChainMonitor` 都会将来自一个带有版本、时间戳且被序列化的 `ChannelMonitor` 结构体的数据打包成一个 `OurPeerStorage` 包裹。然后，它会加密这个数据，并唤起一个 `SendPeerStorage` 事件、将这个包裹作为一条 `peer_storage` 消息转发给每一条通道的对等节点。此外，`ChannelManager` 更新为通过触发一次新的包裹发送来处理 `peer_storage_retrieval` 请求。

- [BTCPay Server #6755][] 强化了钱币控制的用户界面：添加了新的最小数额和最大数额过滤器、创建 早于/晚于 某日期过滤器、这些过滤器的帮助选项、UTXO “全选” 选择框，以及页面大小选择（100 条、200 条或 500 条 UTXO）。

- [Rust libsecp256k1 #798][] 在库中完成了 [MuSig2][topic musig] 实现，为下游项目给出了使用一种健壮的[无脚本多签名][topic multisignature]协议的方法。

{% include references.md %}
{% include linkers/issues.md v=2 issues="3110,3101,3817,3623,6755,1270" %}
[Core Lightning 25.05]: https://github.com/ElementsProject/lightning/releases/tag/v25.05
[bishop priv]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CABaSBax-meEsC2013zKYJnC3phFFB_W3cHQLroUJcPDZKsjB8w@mail.gmail.com/
[poinsot priv]: https://mailing-list.bitcoindevs.xyz/bitcoindev/4iW61M7NCP-gPHoQZKi8ZrSa2U6oSjziG5JbZt3HKC_Ook_Nwm1PchKguOXZ235xaDlhg35nY8Zn7g1siy3IADHvSHyCcgTHrJorMKcDzZg=@protonmail.com/
[kung priv]: https://mailing-list.bitcoindevs.xyz/bitcoindev/58813483-7351-487e-8f7f-82fb18a4c808n@googlegroups.com/
[linus bitvm3]: https://delvingbitcoin.org/t/garbled-circuits-and-bitvm3/1773
[rubin garbled]: https://rubin.io/bitcoin/2025/04/04/delbrag/
[pickhardt rebalance]: https://delvingbitcoin.org/t/research-update-a-geometric-approach-for-optimal-channel-rebalancing/1768
[rust libsecp256k1 #798]: https://github.com/rust-bitcoin/rust-secp256k1/pull/798
[news54 foaf rebalance]: /zh/newsletters/2019/07/10/#brainstorming-just-in-time-routing-and-free-channel-rebalancing
[yanofsky priv]: https://github.com/bitcoin-core/meta/issues/19#issuecomment-2961177626
[cove github]: https://github.com/bitcoinppl/cove/releases
[liana github]: https://github.com/wizardsardine/liana/releases
[breez github]: https://github.com/breez/breez-sdk-liquid/releases/tag/0.9.0
[starkware tweet]: https://x.com/dimahledba/status/1935354385795592491
[starkware sv2]: https://github.com/keep-starknet-strange/stratum
[news337 delay]: /zh/newsletters/2025/01/17/#eclair-2936
[news349 attributable]: /zh/newsletters/2025/04/11/#ldk-2256
[news342 peer]:/zh/newsletters/2025/02/21/#ldk-3575
