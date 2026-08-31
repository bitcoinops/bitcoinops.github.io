---
title: 'Bitcoin Optech 周报 #417'
permalink: /zh/newsletters/2026/08/07/
name: 2026-08-07-newsletter-zh
slug: 2026-08-07-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报介绍了一份 BIP 草案，用于在对等节点之间中继陈旧的链尖。此外还包括我们的常规栏目：总结关于修改比特币共识规则的提议和讨论，宣布新版本和候选版本，并介绍流行比特币基础设施软件的重大变更。

## 新闻

- **<!--draft-bip-for-stale-tip-relay-->****陈旧链尖中继的 BIP 草案：** Ram 和 w0xlt 在 Bitcoin-Dev 邮件列表上[发帖][stale tip ml]，介绍了一项提案：新增一条可选择加入的 P2P 消息，用于在对等节点之间中继陈旧链尖。目前，陈旧区块率是一项很难监测的指标，因为获胜的那条链一旦中继开来，陈旧区块就不再继续传播。但它又是一个很有用的信号，可以用来检查网络的健康状况。陈旧区块率的变化，可能暴露出验证或中继环节的瓶颈、网络分区，或者[自私挖矿][topic selfish mining]行为。

  这份提议中的 [BIP][stale tip bip] 定义了一条名为 `staletip` 的新消息，用于向对等节点通告近期出现的陈旧链尖。消息本身包含：陈旧分支分叉出去的那个区块高度（即分叉点）、一个装着该陈旧分支各区块头的向量，以及一个标志位，用来表明自己愿意提供这些区块数据。节点只应在与对等节点完成 [BIP434][] 协商之后，才发送这条消息（见[周报 #386][news386 bip434]）。

  作者们正在等待其他开发者的反馈。与此同时，这项提案的[概念验证][stale tip poc]已经可供取用。

## 共识变更

_每月栏目，总结关于修改比特币共识规则的提议和讨论。_

- **<!--cisa-for-taproot-keypath-spends-bip460-->****taproot 密钥路径花费的 CISA（BIP460）：** Fabian Jahr 在 Bitcoin-Dev 邮件列表上[发帖][fj ml cisa]，公布了 BIP460（[BIPs #2212][]）的草案，用于对 [taproot][topic taproot] 式的密钥路径花费做全交易范围的[跨输入签名聚合（CISA）][topic cisa]。该提案引入了一个新的见证版本（v2），其密钥路径花费与 [BIP341][] 基本一致，区别在于每个输入的见证都以一个标记字节开头，用来选择半聚合（BIP458/[BIPs #2205][]）、全聚合（BIP459/[BIPs #2210][]），或者明确选择退出、改为携带一个标准的 [BIP340][] [schnorr][topic schnorr signatures] 签名。半聚合以非交互的方式，把多个 64 字节签名各自压缩到 32 字节，再加上单个 32 字节的聚合部分（见[周报 #208][news208 halfagg]）；全聚合则通过交互式签名，把它们缩减成单个 64 字节的聚合签名（见[周报 #415][news415 dahlias]）。脚本路径花费仍然遵循 BIP341/BIP342、保持不变，也不参与聚合，从而保留了 `OP_SUCCESS` 这一升级通道。在这套提议的方案中，签名会承诺到所使用的聚合模式，因此聚合是选择加入的：第三方无法把一个已选择退出的签名折叠进半聚合分组里。Jahr 指出，这个见证版本与 [BIP360][]（P2MR）相冲突；包括 Mark Erhardt 在内的审阅者认为，两项提案中哪一项先激活，哪一项就占用下一个空闲的版本号。

  Conduition [提问][c ml cisa]：CISA 要如何与[后量子][topic quantum resistance]迁移相衔接？聚合在验证时需要裸的椭圆曲线（EC）公钥，因此把 CISA 与 [P2TRv2][news403 pqout] 搭配使用能最大化手续费节省（全聚合的输入每个最少只需 1 个见证字节），但也会一并继承 P2TRv2 在禁用 EC 的时机上的问题；而把公钥哈希起来（P2MR 或 P2TRH），每个输入大约要付出 32 到 65 个重量单位的开销，节省效果会被削弱。Jahr [回复][fj ml cisa conduition]说，这套交易层面的标记/分组框架应当可以推广到未来其他可聚合的方案；而一种把公钥藏在哈希后面的 CISA 变体，可以另外定义成一种输出类型，并复用其中大部分逻辑。Adam Gibson（waxwing）[质疑][ag ml cisa]了“每种方案只能有一个分组”这一限制：在一笔共享交易里，可能有好几位用户各自只想对自己的那些输入做全聚合。Jahr [回复][fj ml cisa waxwing]说，如果审阅者能给出具体的用例，支持多个分组这条路仍然是敞开的。

- **<!--segwit-commitment-to-post-quantum-witness-data-->****用 segwit 承诺后量子见证数据：** Pieter Wuille 在 Delving Bitcoin 上[发帖][pw delving pqwit]，给出了一套设计：在附加[后量子][topic quantum resistance]见证数据的同时，不必把 [segwit][topic segwit] 当年那套部署开销再走一遍。如果只是简单地再开辟一块见证区域，就需要一个新的交易标识符（pqwtxid）、一份对这些标识符的 coinbase 承诺、挖矿软件栈的改动，以及要同时追踪三种标识符的 P2P 逻辑。Wuille 的替代方案则是：从每个输入现有的见证出发，去承诺该输入的扩展见证数据，这样 wtxid 就已经涵盖了新增的数据。一个展开后的版本引入了针对每个输入的见证“样式”（style）：0 表示 segwit，1 表示 pqdata，2 及以上留给未来的扩展；每种样式都有自己的 P2P 扩展和重量计算函数。对于不支持的样式，可以用一份有效的 style-0 承诺来表示，以兼容尚未升级的节点。Anthony Towns 把这些样式类比成各不相同的授权重量公式；他建议采用基于 annex 的承诺，好让类似 locktime 的断言在没有附加数据时仍然可用；他还主张，为后量子签名预留的容量不应当能被普通数据占用，否则在 Q 日到来之前，区块就会朝着那个更大的容量目标膨胀。Wuille 同意，引入一种样式仍然是软分叉、存储和 P2P 三方面合在一起的一次升级，只不过不必再引入一个新的交易 ID。

- **<!--pqc-output-type-discussion-->****PQC 输出类型的讨论：** Pieter Wuille 在 Delving Bitcoin 上[开了][pw delving pqout]一个主题帖，把关于[后量子][topic quantum resistance]输出类型的讨论集中到一处。他把各个候选方案列成表格，其中包括 [BIP360][]（P2MR）、[P2TRv2][news403 pqout]、P2TRH（类 taproot，但输出密钥经过哈希，并支持公钥恢复，见[周报 #412][news412 pkr]），以及 P2QR（即从一开始就禁用 EC 操作码的 P2MR），还有这些方案的各种变体。他目前倾向于同时部署两者：一是 P2TRv2（配合 [tripwire/miner lockdown][news412 p2xx] 以及一个[基于哈希的 PQC 操作码][news386 jn hash]），让 Q 日之前的迁移变得容易，同时保持今天的手续费水平；二是一种更着眼长期的、基于 P2MR 的类型，配合一种新的见证样式，这样在迁移完成之后，EC 和 PQC 的开销就可以分别定价。jeanpablojp 在 regtest 上的测量[显示][jp delving pqout]：在现有 taproot 机制之上，BIP360 的花费大约需要增加 96 行共识代码；而深度为 1 的 schnorr 树叶，比等价的 P2TR 脚本路径花费大约轻 32 字节。Conduition 指出，Jahr 的 CISA 提案（见上文）让 P2TRv2 加 CISA 在自愿迁移这件事上极具吸引力，但也让日后那次禁用 EC 的软分叉变得更加事关重大；他还提到，把基于哈希的签名做成全区块范围的 PQ-SNARK 聚合，是一条研究路径，有可能让后量子花费在手续费上也具备竞争力。

- **<!--input-triggered-transaction-expiry-->****由输入触发的交易过期：** Josh Doman 在 Delving Bitcoin 上[发帖][jd delving expire htlc]，给出了一种让 [HTLC][topic htlc] 过期、又不会造成[免费中继][topic free relay]的构造；随后他在一篇关于[由输入触发的交易过期][jd delving input expiry]的后续帖中，把这个思路作了推广。像 Peter Todd 的 [`OP_EXPIRE`][news274 expire] 这类绝对过期提案，会让一笔原本有效的交易在之后变得无效；除非策略层面要求交易付出接近下一个区块打包费率的手续费，否则就会让廉价的中继垃圾攻击成为可能。Doman 的做法则不同：如果一笔花费所花的 UTXO，其创建交易确认得太晚，这笔花费就会过期。具体来说，如果 [BIP68][] 的 `nSequence` 施加了一个基于高度的相对时间锁 R，并且第 21 位被置位，那么除非 `nLockTime` 也是基于高度的、且不小于 BIP68 规定的最小打包高度，否则这个输入无法通过验证。由于父交易一旦被挖出，除非发生深度重组，否则不会再变得无效，因此在正常推进的情况下，一笔曾经有效的子交易也不会过期，免费中继问题也就随之消除。适用场景包括：不依赖交易池的 HTLC 转发（通过 chainstate 而不是本地交易池来监控原像，这对低带宽节点或 [Utreexo][topic utreexo] 式节点很有用），以及为 [LN-Symmetry][topic eltoo] 提供准合约层面的相对[时间锁][topic timelocks]。可选的配套改动包括：在 `OP_CSV` 中强制检查第 21 位，以及新增一个 tapscript 的 `OP_LOCKTIME` 内省操作码，好让脚本能够要求一个最大的 locktime。Anthony Towns 把这个想法与通过 `OP_TX` 对币所在高度作内省的做法作了比较，并质疑那个 100 区块的最小延迟（选这个数是为了与 coinbase 成熟期以及 Todd 的提案对齐）是否有必要；Doman 后来同意，小得多的延迟可能就够用了，并把这个原语重新表述为：用户借助 `nLockTime` 对输入的确认情况来断言“现在”，而这种做法同时还能在区块补贴消失之后，抬高深度重组的成本。

- **<!--layered-quantum-recovery-of-hashed-addresses-->****哈希类地址的分层量子恢复：** Shinobi 在 Bitcoin-Dev 邮件列表上[发帖][shinobi ml qr]，并[交叉发布][shinobi delving qr]到 Delving Bitcoin，提出了一套分层的恢复方案：如果日后因为出现[与密码学相关的量子计算机][topic quantum resistance]，而对 secp256k1 花费加以限制，这套方案可以用来恢复那些由哈希类地址（P2PKH、P2SH、P2WPKH、P2WSH 以及类似构造）所保护的币。没有哪一种恢复机制能覆盖所有的密钥生成方式：[BIP32][] 分层证明（Osuntokun 近期[演示过][news403 pqrecovery]）覆盖不到非分层生成的密钥；要求在截止期限前留下带时间戳的、有状态的证明，则覆盖不到不活跃的用户；而承诺-揭示式的迁移，在公钥已经暴露的情况下也无能为力。如果在 secp256k1 被禁用之后，允许上述任意一种恢复方式来授权花费，那么在“公钥和内部脚本路径仍然保密”这一前提下，基本上就能覆盖所有仍然掌握着自己密钥的哈希类地址持有者。为了让这件事在将来更容易做到，Shinobi 建议钱包采用新的派生路径，并使用 Electrum 那样按地址逐个查询余额的方式，避免把 xpub 泄露给服务提供方。Conduition 则把恢复重新表述为：对量子攻击者所不具备的、既有的知识不对称加以验证；被哈希过的脚本和 BIP32 种子就属于这类不对称。他强调，有些 UTXO（尤其是许多早期的 P2PK 币）并不存在这样的不对称，因此只有在截止期限之前主动去创造一个，才能把它们的所有者与攻击者区分开来。他还指出，taproot 内部密钥可以充当 P2TR 密钥路径恢复所需的知识不对称，这一点与哈希类地址的分层方案是相互独立的。

- **<!--segregated-data-segdata-bip-draft-->****隔离数据（SegData）的 BIP 草案：** MrHash 在 Delving Bitcoin 上[发帖][mh delving segdata]，公布了 Segregated Data（隔离数据）的一组配套 BIP 草案；这是一项软分叉，会新增一块可裁剪、且与脚本相隔离的区块区域，用于承载任意数据。其中的条目会通过一个 coinbase 默克尔根来承诺（[BIP141][] 式的做法），按见证折扣计量，并借助不可花费的、金额为零的见证 v2 引用输出与交易绑定；这些输出不会进入 UTXO 集。任何操作码都不得读取条目的内容，这样条目就始终是可裁剪的，也无法用来限制花费；超出保留窗口之后，节点仅凭基础序列化数据就能完成验证。其目标是：为那些脚本无需求值的数据（应用层数据块、各类证明）提供一个结构上的容身之处，让它们可以从 `OP_RETURN` 和往见证里塞数据这两条路子中脱离出来，同时又不改动这些现有的途径。Antoine Poinsot 和 Pieter Wuille 认为，如果全节点不必保留载荷就能接受一个区块，那么这些数据在任何有意义的层面上都不属于比特币共识的一部分，它等同于花手续费去把重量撑大。Mark Erhardt 则质疑：既然开销和见证数据一样，嵌入数据的人为什么会愿意接受更差的可获取性。在 Anthony Towns 说明了“数据是否必须存在取决于深度”这类规则所带来的重组风险之后，MrHash 转而倾向于：共识只检查所承诺的重量/长度，而把载荷的验证放到策略层面。这份草案仍在讨论之中；它在见证版本的分配上，也与上文 BIP360 和 BIP460 的讨论相冲突。

## 版本和候选版本

_流行比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。_

- [Libsecp256k1 0.8.0][] 是这一比特币相关密码学运算库的新版本。它加入了[周报 #415][news415 silent]介绍过的 [BIP352][] [静默支付][topic silent payments]模块，允许应用程序自行提供针对硬件优化的 SHA256 压缩函数实现（见[周报 #396][news396 sha256]），并改进了 64 位域运算，使签名验证在部分 GCC 和 MSVC 构建下最多提速约 11%。这一版本还移除了已废弃的 `secp256k1_schnorrsig_sign` 和 `secp256k1_context_no_precomp` 符号。

## 重大的代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #35501][] 让钱包能够存储同一笔交易的多个见证变体。此前，钱包一旦知道了某个 txid 对应的交易，通常就会忽略另一笔 txid 相同、但 wtxid 不同的交易。现在，钱包会把每个变体分别存进一条 `wtxvariant` 数据库记录，并从中选出一个作为规范变体。选取时优先取已确认的变体，其次是带有见证数据的变体，再次是重量最小的变体。规范变体仍然保存在原有的 `tx` 记录中。`gettransaction`、`listtransactions` 和 `listsinceblock` 这几个 RPC 现在会在新增的 `alternate_wtxids` 字段里报告非规范的变体。关于 txid 相同、wtxid 不同的交易，此前的介绍见[周报 #193][news193 wtxid]和[周报 #304][news304 wtxid]。

- [Core Lightning #9298][] 推进了向 `bwatch` 的迁移；`bwatch` 是一个实验性的区块链监视插件，目的是把区块轮询和交易过滤从 `lightningd` 中移出去。这个 PR 把钱包的交易和 UTXO 追踪迁到了该系统上：新增 `our_outputs` 和 `our_txs` 两张表，从现有的钱包表中回填数据，并把钱包的读取操作切换到新表。启用 `--experimental-bwatch` 之后，脚本公钥监视会侦测到何时收到资金，输出点监视则会侦测到钱包的输出何时被花费，其中也包括对重组的处理。写入操作暂时仍会同步镜像到旧的 `outputs` 和 `transactions` 表，让用户无需重新扫描就能降级。

- [Core Lightning #9353][] 让 `sendpay` 在遇到下面这种情况时返回 RPC 错误：所给定路由的各跳载荷合起来，装不进 [BOLT4][] 所定义的洋葱包中 1,300 字节的 `hop_payloads` 字段。此前，洋葱包构造过程会返回一个空结果，而 `sendpay` 未加检查就把它传给了发送代码，导致 `lightningd` 崩溃。这个问题是在一个由再平衡插件生成的 25 跳路由上观察到的。不过，路由的实际上限取决于每一跳编码后载荷的大小，而不单单取决于跳数。

- [Eclair #3336][] 防止从对等节点收到的重复 [HTLC][topic htlc] 结算消息被多次加入到拟议中的远程承诺交易变更里。此前，对等节点或本地消息队列可能把同一条 `update_fulfill_htlc`、`update_fail_htlc` 或 `update_fail_malformed_htlc` 消息投递不止一次，导致 Eclair 存下重复的承诺交易变更，并可能在双方之后交换 `commit_sig` 消息时强制关闭通道。

- [LND #10942][] 增加了对以下情形的支持：在[盲化支付路径][topic rv routing]上转发 [HTLC][topic htlc] 时，加密的收款方数据用 `next_node_id` 而不是短通道 ID（SCID）来标识下一跳。这个问题是在一笔 Core Lightning 的 [BOLT12][topic offers] 支付中观察到的，当时 LND 是收款方盲化路径中的入口节点。CLN 使用了 [BOLT4][] 允许的 `next_node_id` 形式，但 LND 的 HTLC 转发代码要求必须是 SCID，于是支付失败。现在 LND 会借助已有的非严格转发逻辑，把节点 id 解析为自己与该对等节点之间某条可用的通道；这套逻辑同样支持私有通道和别名通道。

- [LND #10992][] 对同步[通道公告][topic channel announcements]时所占用的内存作了限制：它限制了 [BOLT7][] 中 `reply_channel_range` 响应（用于应答 `query_channel_range` 请求）里可接受的短通道 ID（SCID）数量。此前，压缩过的响应可能导致 LND 在一条或多条 `reply_channel_range` 消息中，解码并缓冲数量不可预测的 SCID。现在，LND 对单条消息最多接受 100,000 个 SCID，对单次查询总计也最多接受 100,000 个。

- [Rust Bitcoin #6364][] 增加了对 [BIP434][] `feature` 消息的 P2P 编码和解码支持（见[周报 #386][news386 bip434]和[周报 #390][news390 bip434]），跟进了 Bitcoin Core 此前的实现（见[周报 #410][news410 bip434]）。它加入了协议版本 `70017` 和 `feature` 这个 `NetworkMessage` 变体，同时对特性标识符和数据强制施加 BIP434 规定的大小限制。这次更新提供的是消息层面的基础设施，并未实现对等节点的特性协商逻辑。

- [Rust Bitcoin #6642][] 对每个交易见证元素施加了 4 MB 的大小上限。这个上限源自 [BIP141][] 的四百万重量单位区块上限——比这更大的见证元素根本装不进一个有效区块。此前在解码交易时，Rust Bitcoin 只对第一个见证元素施加该上限，之后的元素又会重置回 32 MiB 这个更宽松的默认上限。这可能让一个超大的元素在解码时被接受，使见证处于不一致的状态，进而在之后按 [taproot][topic taproot] 花费来解释时引发 panic。这次改动延续了此前针对见证解码内存分配的加固工作（见[周报 #410][news410 witness]）。

- [BTCPay Server #7491][] 修复了 Greenfield API 认证处理器中的一个双因素认证（2FA）绕过问题。该认证处理器虽然会检查 FIDO2 形式的 2FA（见[周报 #146][news146 btcpay mfa]），却没有检查基于时间的一次性密码（TOTP）形式的 2FA。这使得受 TOTP 保护的账户无需提供 2FA 就能访问 API。现在，只要启用了任意一种第二因素，该处理器就会拒绝这种认证方式。

- [BTCPay Server #7488][] 改善了 [PSBT][topic psbt] 的签名兼容性：当 PSBT 中已经包含 `non_witness_utxo` 形式的对应前序交易时，为 [segwit][topic segwit] 输入补上 `witness_utxo`。这解决了 Blockstream Jade 这类签名设备配合较新版 [HWI][topic hwi] 使用时出现的问题，同时保留原有的 `non_witness_utxo`。这个 PR 还修复了待处理多签交易签名状态过期的问题。现在 BTCPay Server 会在加载这些交易时重新计算它们的签名进度，并在签名数量足够、且 PSBT 能够成功最终化时，把它们标记为 `Signed`。

{% include snippets/recap-ad.md when="2026-08-11 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2212,2205,2210,35501,9298,9353,3336,10942,10992,6364,6642,7491,7488" %}

[stale tip ml]: https://groups.google.com/g/bitcoindev/c/AwOPNxF15mU
[stale tip bip]: https://github.com/pseudoramdom/bips/blob/staletip-bip-draft/bip-staletip.md
[stale tip poc]: https://github.com/w0xlt/bitcoin/tree/staletip-v4

[fj ml cisa]: https://groups.google.com/g/bitcoindev/c/1XH6sBLWZuA
[c ml cisa]: https://groups.google.com/g/bitcoindev/c/1XH6sBLWZuA/m/V6PZL7bGAwAJ
[fj ml cisa conduition]: https://groups.google.com/g/bitcoindev/c/1XH6sBLWZuA/m/kF-RpqEgBAAJ
[ag ml cisa]: https://groups.google.com/g/bitcoindev/c/1XH6sBLWZuA/m/-zRSmrFZGQAJ
[fj ml cisa waxwing]: https://groups.google.com/g/bitcoindev/c/1XH6sBLWZuA/m/oOQ7TIEVAgAJ
[news208 halfagg]: /zh/newsletters/2022/07/13/#bip340
[news415 dahlias]: /zh/newsletters/2026/07/24/#draft-bip-for-full-aggregation-of-bip340-signatures
[news403 pqout]: /zh/newsletters/2026/05/01/#discussion-of-a-postquantum-output-type
[pw delving pqwit]: https://delvingbitcoin.org/t/segwit-commitment-to-post-quantum-witness-data/2702
[pw delving pqout]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749
[jp delving pqout]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/3
[news412 pkr]: /zh/newsletters/2026/07/03/#public-key-recovery-for-p2mr-ec-leaves
[news412 p2xx]: /zh/newsletters/2026/07/03/#triggering-ec-disabling-with-a-nums-point-spend-or-hashrate-majority
[news386 jn hash]: /zh/newsletters/2026/01/02/#hash-based-signatures-for-bitcoins-post-quantum-future
[jd delving expire htlc]: https://delvingbitcoin.org/t/expiring-htlcs-without-free-relay/2663
[jd delving input expiry]: https://delvingbitcoin.org/t/input-triggered-transaction-expiry/2667
[news274 expire]: /zh/newsletters/2023/10/25/#op-expire
[shinobi ml qr]: https://groups.google.com/g/bitcoindev/c/gtxpSxgG7E4
[shinobi delving qr]: https://delvingbitcoin.org/t/post-quantum-recovery-of-hashed-addresses-with-no-confiscatory-risk/2714
[news403 pqrecovery]: /zh/newsletters/2026/05/01/#postquantum-bip86-recovery-using-zkstark-proofs-of-bip32-seeds
[mh delving segdata]: https://delvingbitcoin.org/t/bip-draft-segregated-data-a-prunable-script-isolated-block-region-for-data-carriage/2641
[news193 wtxid]: /zh/newsletters/2022/03/30/#transaction-witness-replacement
[news304 wtxid]: /zh/newsletters/2024/05/24/#bitcoin-core-30000
[news386 bip434]: /zh/newsletters/2026/01/02/#peer-feature-negotiation
[news390 bip434]: /zh/newsletters/2026/01/30/#bips-2076
[news410 bip434]: /zh/newsletters/2026/06/19/#bitcoin-core-35221
[news410 witness]: /zh/newsletters/2026/06/19/#rust-bitcoin-6321
[news146 btcpay mfa]: /zh/newsletters/2021/04/28/#btcpay-server-2356
[Libsecp256k1 0.8.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.8.0
[news415 silent]: /zh/newsletters/2026/07/24/#libsecp256k1-1765
[news396 sha256]: /zh/newsletters/2026/03/13/#libsecp256k1-1777
