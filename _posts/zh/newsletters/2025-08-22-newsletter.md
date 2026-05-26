---
title: 'Bitcoin Optech Newsletter #368'
permalink: /zh/newsletters/2025/08/22/
name: 2025-08-22-newsletter-zh
slug: 2025-08-22-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的新闻部分总结一份关于在全节点之间分享区块模板的 BIP 草稿，并宣布了一个允许脚本求值的受信任委托的代码库（包含了比特币原生的脚本语言无法使用的特性）。此外是我们的常规栏目：服务和客户端软件的近期更新介绍、新发行版和候选发行版的公告、流行的比特币基础设施软件的显著变更介绍。

## 新闻

- **<!--draft-bip-for-block-template-sharing-->** **区块模板分享的 BIP 草稿**：Anthony Towns 在 Bitcoin-Dev 邮件组中[发帖][towns bipshare]，链接了一份关于让节点能跟对等节点们沟通自己会在尝试挖掘的下一个区块中包含哪些交易的 BIP 的[草稿][towns bipdraft]（关于这个想法，可见[周报 #366][news366 templshare]）。这让节点可以分享自己会在交易池中和挖矿策略中接受、对等节点却（根据其自身的策略）通常会拒绝的交易，从而这些对等节点可以缓存这些交易（最终提高 “[致密区块中继][topic compact block relay]” 的效率）。包含在一个节点的区块模板中的交易通常是该节点已知的最为有利可图的未确认交易，所以之前因为策略原因而拒绝了其中一些交易的对等节点可能也会发现它们值得多加考虑。

  这份 BIP 草稿所描述的协议是比较简单的。在初始化一个对等节点连接之后，节点立即发送一条 `sendtemplate` 消息，向对等节点表示自己愿意发送区块模板。此后任何时间，这个对等节点都可以用一条 `gettemplate` 消息来请求一个模板。在响应请求时，该节点回复一条 `template` 消息，包含了一个短交易标识符的列表，这些标识符使用跟 [BIP152][] “致密区块消息” 相同的格式。随后，该对等节点可以在一条 `sendtransactions` 消息中包含交易的短标识符（同样由 BIP 152 规定），从而请求自己想要的交易。这份 BIP 草稿允许模板的大小超出当前区块重量上限的两倍多一些。

  一个关于区块模板分享的 Delving Bitcoin [帖子][delshare] 在本周出现了更多的讨论，关于如何提升这一提议的带宽效率。得到讨论的想法包括：仅发送自上一次模板分享以来的[差异][towns templdiff]部分（预计可节约 90% 的带宽）、使用一种[集合调解][jahr templerlay]协议（就像 “[minisketch][topic minisketch]” 所带来的那样，允许高效分享大得多的模板），以及，对模板使用 Golomb-Rice [编码][wuille templgr]（就像 “[致密区块过滤器][topic compact block filters]” 那样，预计可节约 25% 的带宽）。

- **<!--trusted-delegation-of-script-evaluation-->脚本求值的受信任委托**：Josh Doman 在 Delving Bitcoin 论坛[发布][doman tee]了一个他编写的代码库，使用一种 *受信任的执行环境* （[TEE][]）、仅在包含 [taproot][topic taproot] 密钥路径的交易满足一个脚本时才签名它。这里的脚本可以包含在当前的比特币上没有激活的操作码，甚至是完全不同形式的脚本（例如 [Simplicity][topic simplicity] 或 [bll][topic bll]）。

  这一方法要求用这种脚本接收资金的人信任这个 TEE —— 相信它未来可以签名，并且只会在花费交易满足其承担的脚本时才签名 —— 但这允许使用真实的货币对提议中的比特币新特性运行快速的实验。为了减少对 TEE 的信任同时保持可用，可以包含一个后备花费路径；比如说，一个[时间锁][topic timelocks]花费路径，允许参与者在将资金委托给 TEE 的一年之后单方面花费自己的资金。

  这个库设计成使用亚马逊网络服务（AWS）的 Nitro 飞地。

## 服务和客户端软件的变更

*在这个月度栏目中，我们列出比特币钱包和服务的有趣更新。*

- **<!--zeus-v0113-released-->** **ZEUS v0.11.3 发布**：这个 [v0.11.3][zeus v0.11.3] 版本包括了对对等节点管理、[BOLT12][topic offers] 和 “[潜水艇互换][topic submarine swaps]” 特性的提升。

- **<!--rust-utreexo-resources-->** **Rust 语言的 Utreexo 资源**：Abdelhamid Bakhta [发布][abdel tweet] 了 “[Utreexo][topic utreexo]” 的 Rust 语言资源，包括非交互的[教育材料][rustreexo webapp]和[WASM 绑定][rustreexo wasm]。

- **<!--peerobserver-tooling-and-call-to-action-->对等节点观察员工具和行动号召**：0xB10C [公开][b10c blog]了他的 “[peer-observer][peer-observer github]” 项目的动机、架构、代码、支持库和研究成果。他尝试建立 “一个松散的、去中心化的个人团体，分享对观察比特币网络的兴趣。希望是一个能够分享想法、讨论、数据、工具、洞见等等的团体。”

- **<!--bitcoin-core-kernelbased-node-announced-->** **基于 Bitcoin Core Kernel 的节点发布**：Bitcoin backbone [发布][bitcoin backbone]，演示了一个使用 [Bitcoin Core Kernel][kernel blog] 作为基础的比特币节点。

- **<!--simplicityhl-released-->** **SimplicityHL 发布**：[SimplicityHL][simplcityhl github] 是一个类似于 Rust 的变成语言，可以编译成更低层次的 [Simplicity][simplicity] 语言代码（刚刚在 Liquid 侧链上 [激活][simplicity post]）。想了解更多，请看 [相关的 Delving Bitcoin 帖子][simplicityhl delving]。

- **<!--lsp-plugin-for-btcpay-server-->** **BTCPay Server 的 LSP 插件**：这个 [LSP 插件][lsp btcpay github] 在 BTCPay Server 中实现了 [BLIP51][] （入账通道规范）的客户端验证特性。

- **<!--proto-mining-hardware-and-software-announced-->** **Proto 的挖矿软硬件发布**：Proto [发布][proto blog]新的比特币挖矿硬件和开源的挖矿软件，吸收了[社区反馈][news260 mdk]。

- **<!--oracle-resolution-demo-using-csfs-->** **使用 CSFS 的断言机解析演示**：Abdelhamid Bakhta [发布][abdel tweet2]了一个使用 [CSFS][topic op_checksigfromstack]、nostr 和 MutinyNet 来签名一个事件的结果的见证消息的断言机。

- **<!--relai-adds-taproot-support-->** **Relai 添加了 taproot 支持**：Relai 现在支持发送到 [taproot][topic taproot] 地址。

## 发行和候选发行

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。*

- [LND v0.19.3-beta][] 是这个热门的闪电节点实现的一个维护版本的候选发行，包含了 “重要的 bug 修复”。最重要的是，“一个可选的迁移选项 …… 显著降低了节点的磁盘和内存要求”。

- [Bitcoin Core 29.1rc1][] 是这个主流全节点软件的维护版本的候选发行。

- [Core Lightning v25.09rc2][] 是这个流行的闪电节点实现的一个新的主要版本的候选发行。

## 显著的代码和说明书变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #32896][] 向下列 RPC 添加了一个 `version` 参数：`createrawtransaction`、`createpsbt`、`send`、`sendall` 、 `walletcreatefundedpsbt`；从而支持创建和花费未确认的 “拓扑受限直至确认（[TRUC][topic v3 transaction relay]）” 交易。钱包软件会强制实施 TRUC 交易在重量上限、手足冲突上的限制，并处理未确认 TRUC 交易和非 TRUC 交易之间的不兼容性。

- [Bitcoin Core #33106][] 将默认的 `blockmintxfee` 降低到 1 聪/kvB（也是可能的最低值），而默认的 [`minrelaytxfee`][topic default minimum transaction relay feerates]（最低转发费率）和 `incrementalrelayfee`（手续费追加最低幅度） 则降低到 100 聪/kvB（0.1 聪/vB）。不过，这些数值是可以配置的，用户得到的建议是同时调整 `minrelaytxfee` 和 `incrementalrelayfee` 这两个数值。其他最低费率保持不变，但默认的钱包最低费率预计会在下一个版本中调降。这一变更的动机有：包含低于 1 聪/vB 费率交易的区块的数量显著增加、挖掘这些交易的矿池的数量显著增加，以及比特币对其他货币汇率的上升。

- [Core Lightning #8467][] 延申了 `xpay`（详见 [周报 #330][news330 xpay]），支持支付给 [BIP353][] “人类可读域名（HRN）”（例如 satoshi@bitcoin.com），并使之能够直接支付 [BOLT12 offer][topic offers]，消除了需要先运行 `fetchinnoice` 命令的需要。在这背后，`xpay` 会使用来自 `cln-bip353` 插件（在 [Core Lightning #8362][] 引入）的 `fetchbip353` RPC 命令来获取支付指令。

- [Core Lightning #8354][] 开始为使用 “多路径支付（[MPP][topic multipath payments]）” 的具体支付碎片的状态发布 `pay_part_start` 和 `pay_part_end` 事件通知。`pay_part_end` 通知说明支付的持续时间，以及它是成功还是失败。如果支付失败，会提供一条报错消息；而且，如果报告错误的洋葱消息没有损害，会给出关于失败的额外信息，例如错误的源头和错误码。

- [Eclair #3103][] 加入对 “[简单 taproot 通道][topic simple taproot channels]” 的支持，该特性利用了 [MuSig2][topic musig] 无脚本式[多签名][topic multisignature]来降低交易的重量（节约 15%）并提升交易的隐私性。注资交易和合作式关闭交易将跟其他 [P2TR][topic taproot] 交易没有区别。该 PR 也引入对简单 taproot 通道的 “[双向注资][topic dual funding]” 和 “[通道拼接][topic splicing]” 的支持，并允许启用 “[通道承诺更新][topic channel commitment upgrades]” 特性的通道利用通道拼接交易升级到这种新的 taproot 格式。

- [Eclair #3134][] 在给 “[HTLC 背书][topic htlc endorsement]” 下的对等节点声誉评分时，将卡住 [HTLC][topic htlc] 的惩罚权重乘数换成 [CLTV 过期时间差值][topic cltv expiry delta]（详见 [周报 #363][news363 reputation]），以更好地反映一个卡住的 HTLC 会将流动性绑定多长时间。为了缓解使用最大的 CLTV 过期差值的 HTLC 卡住所带来的巨额惩罚，这个 PR 将声誉降级参数（`half-life`）从 15 天变成了 30 天，并将卡住支付的门槛（`max-relay-duration`）从 12 秒变成了 5 分钟。

- [LDK #3897][] 拓展了其 “[对等节点存储][topic peer storage]” 实现：通过反序列化对等节点的备份并与本地状态相比较，在备份检索期间探测丢失的通道状态。

{% include references.md %}
{% include linkers/issues.md v=2 issues="32896,33106,8467,8354,3103,3134,3897,8362" %}
[bitcoin core 29.1rc1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[lnd v0.19.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.3-beta
[core lightning v25.09rc2]: https://github.com/ElementsProject/lightning/releases/tag/v25.09rc2
[towns bipshare]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aJvZwR_bPeT4LaH6@erisian.com.au/
[towns bipdraft]: https://github.com/ajtowns/bips/blob/202508-sendtemplate/bip-ajtowns-sendtemplate.md
[news366 templshare]: /zh/newsletters/2025/08/08/#peer-block-template-sharing-to-mitigate-problems-with-divergent-mempool-policies
[delshare]: https://delvingbitcoin.org/t/sharing-block-templates/1906/13
[towns templdiff]: https://delvingbitcoin.org/t/sharing-block-templates/1906/7
[jahr templerlay]: https://delvingbitcoin.org/t/sharing-block-templates/1906/6
[wuille templgr]: https://delvingbitcoin.org/t/sharing-block-templates/1906/9
[doman tee]: https://delvingbitcoin.org/t/confidential-script-emulate-soft-forks-using-stateless-tees/1918/
[tee]: https://zh.wikipedia.org/wiki/%E5%8F%AF%E4%BF%A1%E5%9F%B7%E8%A1%8C%E7%92%B0%E5%A2%83
[news330 xpay]: /zh/newsletters/2024/11/22/#core-lightning-7799
[news363 reputation]: /zh/newsletters/2025/07/18/#eclair-2716
[zeus v0.11.3]: https://github.com/ZeusLN/zeus/releases/tag/v0.11.3
[abdel tweet]: https://x.com/dimahledba/status/1951213485104181669
[rustreexo webapp]: https://rustreexo-playground.starkwarebitcoin.dev/
[rustreexo wasm]: https://github.com/AbdelStark/rustreexo-wasm
[b10c blog]: https://b10c.me/projects/024-peer-observer/
[peer-observer github]: https://github.com/0xB10C/peer-observer
[bitcoin backbone]: https://mailing-list.bitcoindevs.xyz/bitcoindev/9812cde0-7bbb-41a6-8e3b-8a5d446c1b3cn@googlegroups.com
[kernel blog]: https://thecharlatan.ch/Kernel/
[simplcityhl github]: https://github.com/BlockstreamResearch/SimplicityHL
[simplicity]: https://blockstream.com/simplicity.pdf
[simplicityhl delving]: https://delvingbitcoin.org/t/writing-simplicity-programs-with-simplicityhl/1900
[simplicity post]: https://blog.blockstream.com/simplicity-launches-on-liquid-mainnet/
[lsp btcpay github]: https://github.com/MegalithicBTC/BTCPayserver-LSPS1
[proto blog]: https://proto.xyz/blog/posts/proto-rig-and-proto-fleet-a-paradigm-shift
[news260 mdk]: /zh/newsletters/2023/07/19/#mining-development-kit-call-for-feedback
[abdel tweet2]: https://x.com/dimahledba/status/1946223544234659877
