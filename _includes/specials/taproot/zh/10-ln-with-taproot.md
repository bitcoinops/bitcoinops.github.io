*[ZmnSCPxj][]，闪电网络协议开发者*

本文将探讨 Taproot 为闪电网络带来的两大隐私特性:

* 闪电网络上的 [PTLCs][topic ptlc]
* P2TR 通道

### 闪电网络上的 PTLCs

PTLC 可实现[多项功能][suredbits payment points]，其中对闪电网络而言，最大优势在于无需路径随机化即可实现[支付解关联][p4tr ptlcs]。[^route-randomization]在单路径或[多路径支付][topic multipath payments]中，每个节点均可获得用于调整转发 PTLC 的特定参数，实现**支付解关联**，此举可消除各转发节点通过唯一哈希值[关联][news163 htlc problems]具体支付的可能性。

需明确，**PTLC 并非隐私万能解**。若监控节点观察到特定时间锁和金额的支付转发后，短期内发现另一节点转发具有*更短时间锁*及*稍小金额*的支付，这些事件*极可能*为同一支付路径的组成部分(即便无法通过哈希值唯一标识进行关联)。然而，变更带来以下优势:

* 分析难度提升：监控节点依据的关联概率降低，其信息价值相应减少。
* 多路径支付的解关联增强：不同路径间的时间锁与金额关联性大幅减弱，且若闪电网络持续发展，海量支付将削弱时序关联的有效性。
* 成本未增加：相较于 [HTLC][topic htlc]，PTLC 无需额外开销(甚至可能因[多签效率优化][p4tr multisignatures]稍有节约)。

理论而言，无需关闭现有通道即可通过链下交易将预-Taproot 通道升级至支持 PTLC。现有通道可通过将非 Taproot 资金输出转移至含 PTLC 的 Taproot 输出实现兼容。因此，用户无需承担额外成本，仅需节点及其通道对端升级软件即可支持 PTLC。

但 PTLC 的实际使用需支付路径中**所有**节点均支持该协议。这意味着需足够多节点完成升级后方可广泛采用。这些节点未必需支持同一 PTLC 协议(允许存在多个协议)，但均须至少支持一种。协议多样化将增加维护负担，开发者*期望*尽量减少协议数量(理想状态为单一协议)。

### P2TR 通道

提升基础层与闪电网络层解关联的方案之一是[未公开通道][topic unannounced channels]——此类通道不在闪电网络的 gossip 协议中广播。

但当前预-Taproot 的比特币网络中，所有 2-2 多签脚本均需明示编写。闪电网络作为 2-2 多签的最大用户，其通道的关闭交易极易被区块浏览器识别为闪电网络的链上活动，进而被追溯资金流向。任何新生成的 P2WSH 输出极可能为另一未公开通道。因此，未公开通道一旦关闭，仍存在链上识别的可能(伴随误判率)。

Taproot 借助 [schnorr 签名][topic schnorr signatures]使 n-of-n 多签交易与 1-of-1 单签交易在链上表现无异。经技术优化后，[k-of-n][topic threshold signature] 多签交易亦可实现等价匿名性。因此，我们可采用 Taproot 地址(即 P2TR 通道)作为闪电通道的链上基础，提升未公开通道的**链上隐私**。[^two-to-tango]

此(微小)隐私提升同样惠及公开通道。公开通道仅在存续期广播，监控者无法获取历史通道信息。若需追踪所有公开通道，需自行存储全部数据，无法依赖"归档"节点。

此外，Taproot 密钥路径交易比现有闪电网络 P2WSH 交易体积减少 38.5 vbytes(40%)。但需注意，**现有 pre-taproot 通道无法升级至 P2TR 通道**，因现有通道采用 P2WSH 2-2 模式，必须关闭后重新开启 P2TR 通道。

理论上，资金输出形式仅关乎通道双方节点。其他节点无需关心通道保证金的技术细节。但公开通道需通过 gossip 网络广播。节点收到通道信息后，将查询其信任的比特币全节点验证资金 UTXO 的存在性及**地址正确性**。地址验证机制可抵御垃圾通道的传播——需真实资金支撑才能发布通道信息。因此实践中，P2TR 通道仍需一定程度的远程兼容性，否则发送方将因无法验证存在性而忽略此类通道。

### 时间预估

在去中心化开源项目中，最佳时间预测法为参考历史类似功能的开发周期。近期重大特性中，与闪电网络 PTLC 复杂度相当的是 [dual funding][topic dual funding] 协议。Lisa Neigut 在 [BOLTs #524][] 中提出初始方案后，历时两年半完成首个主网 [dual funding 通道][first dual funded tx]。鉴于 PTLC 需全网路径节点兼容(包括接收方)，预估在具体协议提案后需三年零九个月实现广泛采用。

P2TR 通道虽仅需两节点支持，但其收益较低，故开发优先级受限。多数开发者将优先实现 PTLC 支持，预计 P2TR 通道的开发将在 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 或 Decker-Russell-Osuntokun([Eltoo][topic eltoo])方案落地后展开。

[^route-randomization]:
    付款方可选择复杂路径(路径随机化)弱化 HTLC 关联分析，然存在弊端:

    * 复杂路径不仅成本更高且可靠性下降(需要支付更多转发节点费用,同时依赖更多节点*成功*完成转发)。
    * 路径延伸导致支付信息被暴露于*更多*节点,大幅增加遭遇*监控节点*的可能性。
    因此路径随机化非完美隐私解决方案。

[^planning-details]:
    是的，细节很重要，但也不重要：从足够高的视角来看，开发中某些方面的意外困难和其他方面的意外顺利会相互抵消，我们最终会发现每个主要功能大致都在某个平均时间范围内。如果我们想要做出**准确**的估计，而不是**让人感觉良好**的估计，我们应该采用避免[规划谬误][WIKIPEDIAPLANNINGFALLACY]的方法。因此，我们应该只关注一个类似的、已完成的功能，*故意忽略*其细节，仅仅看它实现所花费的时间。

[^two-to-tango]:
    在考虑未公开通道时，记住需要“二人共舞”，如果一个未公开通道被关闭，那么其中一个参与者（例如，一个闪电网络服务提供商）将剩余的资金用于一个*公开*通道，区块链浏览器可以推测这些资金的来源有一定概率是曾经关闭的未公开通道。

{% include references.md %}
{% include linkers/issues.md issues="524" %}
[zmnscpxj]: https://zmnscpxj.github.io/about.html
[suredbits payment points]: https://suredbits.com/payment-points-monotone-access-structures/
[WIKIPEDIAPLANNINGFALLACY]: https://en.wikipedia.org/wiki/Planning_fallacy
[neigut first dual funded]: https://medium.com/blockstream/c-lightning-opens-first-dual-funded-mainnet-lightning-channel-ada6b32a527c
[first dual funded tx]: https://blockstream.info/tx/91538cbc4aca767cb77aa0690c2a6e710e095c8eb6d8f73d53a3a29682cb7581
[russell deployable ln]: https://github.com/ElementsProject/lightning/blob/master/doc/deployable-lightning.pdf
[p4tr ptlcs]: /zh/newsletters/2021/08/25/#准备-taproot-10ptlcs
[p4tr multisignatures]: /zh/newsletters/2021/08/04/#准备-taproot-7多签
[news163 htlc problems]: /zh/newsletters/2021/08/25/#htlc-的隐私问题
