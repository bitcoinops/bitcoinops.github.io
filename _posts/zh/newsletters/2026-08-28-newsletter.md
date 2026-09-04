---
title: 'Bitcoin Optech 周报 #420'
permalink: /zh/newsletters/2026/08/28/
name: 2026-08-28-newsletter-zh
slug: 2026-08-28-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报转达了 Core Lightning 一个计划中的安全版本的预先通知，总结了一场关于为未来可能出现的分叉引入选择性加入式重放保护的讨论，提到硬件钱包接口（HWI）项目即将进入维护模式，并介绍了一份关于使用区块范围过滤器的意见征询。此外还包括我们的常规栏目：新版本和候选版本的公告，以及流行比特币基础设施软件的重大变更。

## 行动项

- **<!--prepare-for-an-upcoming-core-lightning-security-release-->****为即将发布的 Core Lightning 安全版本做好准备：** Christian Decker [介绍][cln v26.06.7]了即将发布的 CLN v26.06.7 安全补丁版本，并指出目前没有已知漏洞正在被积极利用。该项目计划在大约 24 小时内做一次带禁发期（embargo）的发布：先公布二进制文件，但把源代码扣住 14 天，以拖慢攻击者对修复内容的逆向工程。等源代码放出之后，CLN 的[可复现构建][topic reproducible builds]体系可以让用户验证二进制文件与源代码是否一致。如果运维者更愿意等到源代码可用之后再更新，那么应当带 `--offline` 标志重启（这会让节点不再发起或接受对等节点连接，但仍保留针对潜在作弊对等节点的链上强制执行能力）。

## 新闻

- **<!--discussion-on-universal-opt-in-replay-protection-->****关于通用的选择性加入式重放保护的讨论：** Moonsettler 在 Delving Bitcoin 上[发帖][replay del]，讨论了在未来出现分叉时引入一种选择性加入（opt-in）的重放保护机制的可能性。这个想法源自近期的一些事件：某条少数派链遭到了重放攻击。此处说的重放攻击是指，分叉后在其中一条链上有效的已签名交易被重新广播到另一条链上，于是在两个网络上都无意间花掉了对应的币。作者提议利用 [taproot annex][topic annex]，在其中承诺一段 34 字节的载荷，内含前一个区块的哈希（即 `<0xFAF0><32-byte-prior-block-hash>`）。

  随后的讨论中，Anthony Towns 提议改用区块高度加上区块哈希的一段后缀，从而把数据量压缩到 6 字节。Moonsettler 认同这个做法，并补充说，如果节点能为 UTXO 标注上这个区块承诺，把该信息提供给用户，会很有价值。作者还提议给新承诺的深度设一个上限，理想情况下就取 `assumevalid` 高度，并让节点为该承诺保留最多 `100` 个区块的记录。此外，Towns 还提议加入一种类似成熟期约束的机制：显式设置 `nLocktime`，让交易在经过一定数量的区块之前无法被挖出，以应对区块重组。

- **<!--hwi-repository-to-enter-maintenance-mode-->****HWI 仓库将进入维护模式：** Ava Chow（achow101）[宣布][hwi future]，[硬件钱包接口（HWI）][topic hwi]项目将收缩为只做维护性工作，并最终归档。HWI 让 [Bitcoin Core][bitcoin core repo] 及其他软件能够与硬件签名设备通信；它几乎完全由一个人开发，好几年来都没有多少新的开发投入。Chow 说，HWI 基本达成了把硬件钱包支持带给 Bitcoin Core 的最初目标，但它的 Python 代码库让它始终没能完全走到这一步——这份代码无法[可复现地构建][topic reproducible builds]，也无法与 Bitcoin Core 打包在一起。

  在进入维护模式之前，项目会先完成正在进行中的 [MuSig2][topic musig] 支持，并发布一个预计将是其最后一个的版本。此后，除 MuSig2 之外，它不再接受新功能，也不再增加对更多设备的支持。Chow 提到 Wizardsardine 正在开发的 Rust 实现 [BHWI][bhwi]，可以作为潜在的替代品。

- **<!--request-for-comments-on-using-block-range-filters-->****关于使用区块范围过滤器的意见征询：** Optout 在 Delving Bitcoin 上[发帖][rfc del]，就一项提案发起意见征询（RFC）：在使用[致密区块过滤器][topic compact block filters]时，用区块范围过滤器来减少总下载量。与其把每一个单独的区块过滤器都下载下来，不如为一段段区块范围各自创建过滤器。如果在某个范围内匹配到了某个脚本，再去下载这段范围内各个区块的过滤器，之后的流程就和 [BIP157][] 描述的一样。虽然对于匹配上的范围来说，范围过滤器和区块过滤器都要下载，但其余那些范围里的区块过滤器都省掉了，总体上仍然减少了体积。

  初步结果看起来颇有希望。作者在约 3 万个区块的模拟数据上，用不同的范围大小做了仿真。测试用了两组脚本：一组的交易数很少（4-6 笔交易），另一组则多一些（20-30 笔交易）。区块范围过滤器的总体积会随着范围增大而减小。不过，范围一旦拉得太大，省下来的量大部分又会被抵消掉。按作者的说法，最好的取舍似乎出现在 256 个区块的范围上；对于测试用的这两组脚本，它把总下载量减少了约 70–80%。

## 版本和候选版本

_流行比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。_

- [BTCPay Server 2.4.3][] 是这一自托管支付处理器的安全版本。建议用户升级，尤其是当服务器由多个用户共用时。

- [Eclair 0.14.2][] 是这一闪电网络节点实现的安全版本。它修复了支付失败和通道处理方面的 bug（见[周报 #418][news418 eclair fixes]）、缺失的通道储备检查（见[周报 #419][news419 eclair reserves]），以及[即时（on-the-fly）][topic jit channels]注资的问题（见[周报 #419][news419 eclair funding]）。它还限制了 [gossip 查询][topic channel announcements]（见[周报 #419][news419 eclair gossip]）和待处理入站连接所消耗的资源，并包含[洋葱消息][topic onion messages]和 Tor 配置方面的改动。强烈建议升级，因为恶意节点可能利用其中一部分已修复的 bug。运维者应当把 `bitcoind` 和 Eclair 跑在同一台机器上，或者通过加密且经过认证的隧道连接，并查阅[发布说明][eclair 0.14.2 notes]了解配置方面的变更。

## 重大的代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #34075][] 在现有的、基于确认情况的区块策略估算器之外，加入了一个基于交易池的[费率估算器][topic fee estimation]。新的估算器分别取下一个区块中间位置和最后四分之一位置上的[分块（chunk）费率][topic cluster mempool]，作为保守估计和经济估计。如果等待确认的交易太少，它会退回到最低中继费率和交易池最低费率两者中较高的那个。默认情况下，`estimatesmartfee` 现在返回交易池估算值和区块策略估算值中较低的那一个，因此交易池的状况只能压低费率估算，而不会把它抬高。新增的 `fee_rate_estimator` 选项可以用来只按其中一种方法取得估算值。

- [Bitcoin Core #35730][] 增加了 `-rpcmaxconnections` 配置选项（默认值 16），用来限制可以同时连接到其 HTTP 服务器的客户端数量（见[周报 #411][news411 http]）。达到上限之后，多出来的连接会留在操作系统的套接字队列里，不占用应用内存，直到有空位腾出来。Bitcoin Core 现在还能限制并追踪这些连接的文件描述符用量，从而解决一个长期存在的问题：大量使用 RPC 可能耗尽可用的文件描述符，导致不相干的操作失败。这个改动还改进了连接处理方式——每一轮 I/O 循环会一次性接受排队中的所有连接直到上限，而不再是每轮只接受一个连接。

- [Bitcoin Core #35580][] 修复了区块模板构建中的一个 bug：它此前拿一个交易分块经 sigops 调整后的重量（见[周报 #416][news416 sigops]）、而不是其实际的 [BIP141][] 重量，去和区块重量上限作比较。经 sigops 调整的重量是用来按有效费率给分块排序的，而区块有效性对实际重量和 sigop 开销是分开约束的。因此，即便某个 sigop 密集、费率又高的分块其实同时满足这两项限制，此前的行为也可能把它错误地排除在外，从而减少挖矿收入。

- [Bitcoin Core #35665][]、[#36025][bitcoin core #36025] 和 [#35516][bitcoin core #35516] 修复了合并（combine）或拼接（join）[PSBT][topic psbt] 时的几个问题。第一个修复针对的是合并两条全局 xpub 记录时的问题。此前，Bitcoin Core 按密钥来源（指纹和派生路径）给这些记录分组，而 PSBT 序列化其实是按 xpub 来标识它们的。结果是，同一个 xpub 配上相互冲突的来源信息，会被序列化成重复的键，从而产生一个无效的 PSBT，`decodepsbt` RPC 会拒绝它。第二个 PR 修复了 [tapscript][topic tapscript] 记录上同类的不匹配问题：这类记录在内部按叶子脚本分组，序列化时却按控制块来标识。此前，当同一个控制块关联到不同脚本时，合并可能产生重复的键；也可能把同一个脚本的有效控制块丢掉。第三个 PR 解决了 `joinpsbts` RPC 丢掉全局 xpub 和元数据记录的问题，办法是就地打乱合并后的 PSBT，而不是另外构造一个会遗漏部分全局元数据的、打乱过的 PSBT。

- [Bitcoin Core #35933][] 和 [#34697][bitcoin core #34697] 修复了 [MuSig2][topic musig] 的 [PSBT][topic psbt] 处理和[描述符][topic descriptors]方面的几个问题。第一个 PR 防止无效或不一致的 MuSig2 派生元数据导致 `analyzepsbt`、`finalizepsbt` 和 `descriptorprocesspsbt` 这几个 RPC 中止。现在，硬化的公开派生会正常报错失败，而不匹配的聚合密钥则会被跳过，以便再去试另一个能匹配上的密钥。第二个 PR 改进了描述符中重复密钥的检测：在解析描述符时，利用已有的私钥信息来比较带硬化派生的密钥表达式。此前，两个不同的表达式可能都无法解析，于是被错误地当成重复，导致那些以不同派生路径复用同一批参与者的合法 `musig()` 描述符被拒绝。这个 PR 还避免了把某个被复用的 MuSig2 参与者的密钥来源两次前置到 PSBT 中所存的 [taproot][topic taproot] 派生元数据上。

- [Core Lightning #9374][] 修复了一个通道状态错误：当[双向注资][topic dual funding]通道最终确认的是较早一次 [RBF][topic rbf] 尝试、而不是最新那次时，就可能出现这个错误（Eclair 上的类似 bug 见[周报 #418][news418 eclair]）。此前，如果对等节点在 Core Lightning 还没追上区块链进度时就重新连了上来，它可能会以为确认的是最新那次 RBF 尝试，于是把通道锁定到一笔并未确认的注资交易上。现在，Core Lightning 会在相应区块被处理时就立刻记下真正确认的那次注资尝试，并在重建通道时使用这一次。

- [Eclair #3342][] 实现了 [BOLTs #1343][] 所规定的 `option_onion_messages_only_channels` 功能位（见[周报 #416][news416 onion]）。当配置为只为有通道的对等节点中继[洋葱消息][topic onion messages]时，Eclair 现在会通告这个功能位。当为所有对等节点中继时，Eclair 通告的则是 `option_onion_messages` 功能位。

- [Eclair #3321][] 实现了对 `update_fulfill_htlc` 消息中新增的可选 `fulfillment_payload` 字段的支持；该字段由 [BOLTs #1344][] 规定，把[可归因失败][topic attributable failures]扩展到了成功支付的场景（见[周报 #416][news416 fulfillment]）。Eclair 可以中继 fulfillment payload，并把它作为归因数据的一部分加以验证；在自己是付款方时也能解密它，但当自己是收款方时还不会主动生成这样的载荷。该 PR 报告了与 LDK 的互操作性；LDK 此前已经为成功支付的路径加上了归因数据（见[周报 #364][news364 ldk attribution]）。

- [LND #11008][] 修复了 LND 的 [PSBT][topic psbt] 开通道流程中的一个死锁问题。此前，如果 PSBT 注资验证和一笔被取消的通道预留的清理工作同时进行，两边就可能各自等着对方持有的资源。这会让 LND 中唯一的预留处理器卡住，使节点无法开通或接受通道，也让刚刚注资的通道一直卡着，直到重启才能恢复。这个修复改变了访问共享状态的顺序，使这两项操作不会无限期地互相阻塞。

- [HWI #841][] 扩展了 `displayaddress` 命令，使它可以在硬件设备上显示某个已注册的 [BIP388][] 钱包[描述符][topic descriptors]策略所对应的地址；具体是哪个地址，由地址索引以及走接收分支还是找零分支来选定。该命令接受 `registerdescriptor` 命令返回的注册信息，并增加了对 BitBox02、Coldcard、Jade 和 Ledger 设备的支持；它建立在[周报 #419][news419 hwi]介绍过的描述符注册支持之上。

- [HWI #849][] 更新了对 Coldcard 的支持，使其能在 Coldcard Edge 设备上显示单签名的 [taproot][topic taproot] 地址。此外，在用支持 PSBTv2 的 Coldcard 固件签名时，它现在会保留 PSBTv2 格式，而不再一律把 PSBT 转换成版本 0。该 PR 增加了 Coldcard Edge 模拟器的测试覆盖，恢复了单签名交易的签名测试，并把测试所用的 Coldcard 固件更新到 5.6.0 版。

- [Rust Bitcoin #6755][] 修复了 segwit v0 的签名验证问题，涉及的是那些使用了非标准、但在共识上有效的 ECDSA 签名哈希（sighash）值的交易。此前，`EcdsaSighashType` 会把这些值映射到行为等价的标准 sighash 类型（`ALL`、`NONE`、`SINGLE` 和 `ANYONECANPAY`），原始值也就丢失了。而由于这个确切的值本身也会被计入 segwit v0 的签名哈希，这可能导致 Rust Bitcoin 算出错误的 sighash，无法验证那些在共识上有效、且早已确认的交易里的签名。新的表示法会保留原始值；至于那些确实需要标准 sighash 类型的调用方，仍然可以继续使用 `from_standard`（见[周报 #138][news138 sighash]）。

{% include snippets/recap-ad.md when="2026-09-01 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="34075,35730,35580,35665,36025,35516,35933,34697,9374,3342,1343,3321,1344,11008,841,849,6755" %}

[cln v26.06.7]: https://x.com/Snyke/status/2092989040098181170
[replay del]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792
[hwi future]: https://github.com/bitcoin-core/HWI/issues/850
[bhwi]: https://github.com/wizardsardine/bhwi
[BTCPay Server 2.4.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.3
[Eclair 0.14.2]: https://github.com/ACINQ/eclair/releases/tag/v0.14.2
[eclair 0.14.2 notes]: https://github.com/ACINQ/eclair/blob/v0.14.2/docs/release-notes/eclair-v0.14.2.md
[news295 fee]: /zh/newsletters/2024/03/27/#mempoolbased-feerate-estimation
[news349 fee]: /zh/newsletters/2025/04/11/#bitcoin-core-pr-review-club
[news411 http]: /zh/newsletters/2026/06/26/#bitcoin-core-35182
[news416 sigops]: /zh/newsletters/2026/07/31/#bitcoin-core-32800
[news418 eclair]: /zh/newsletters/2026/08/14/#eclair-3346
[news416 onion]: /zh/newsletters/2026/07/31/#bolts-1343
[news416 fulfillment]: /zh/newsletters/2026/07/31/#bolts-1344
[news419 hwi]: /en/newsletters/2026/08/21/#hwi-842
[news364 ldk attribution]: /zh/newsletters/2025/07/25/#ldk-3801
[news138 sighash]: /zh/newsletters/2021/03/03/#rust-bitcoin-573
[news418 eclair fixes]: /zh/newsletters/2026/08/14/#eclair-3346
[news419 eclair reserves]: /en/newsletters/2026/08/21/#eclair-3352
[news419 eclair funding]: /en/newsletters/2026/08/21/#eclair-3351
[news419 eclair gossip]: /en/newsletters/2026/08/21/#eclair-3345
[rfc del]: https://delvingbitcoin.org/t/rfc-block-range-filters-a-k-a-hierarchical-filters/2735
