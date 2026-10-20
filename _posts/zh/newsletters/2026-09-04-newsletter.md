---
title: 'Bitcoin Optech 周报 #421'
permalink: /zh/newsletters/2026/09/04/
name: 2026-09-04-newsletter-zh
slug: 2026-09-04-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报介绍了一个设想：矿池可以在 coinbase 交易里用静默支付给矿工付款；并总结了一个影响旧版本 Core Lightning 的拒绝服务漏洞的负责任披露。此外还包括我们的常规栏目：总结关于修改比特币共识规则的提议和讨论、新版本和候选版本的公告，以及流行比特币基础设施软件的重大变更。

## 新闻

- **<!--using-silent-payments-for-miner-payouts-in-coinbase-transaction-->****在 coinbase 交易中用静默支付向矿工付款：** average_gary 在 Delving Bitcoin 上[发帖][spc del]，介绍了他的一个设想：[矿池][topic pooled mining]如何直接在 coinbase 交易里把款项付到矿工的不同地址上。按现在的做法，矿工要向矿池提供一个 `xpub`，好让矿池为每次付款派生一个新地址；一旦矿池的数据库被攻破，这就会带来隐私问题。换成这个设想，矿工可以通过 Stratum v2 提供的加密通信通道，把一个[静默支付][topic silent payments]地址交给矿池——这种地址是静态的，可以多次使用而不泄露隐私。

  对于 [BIP352][] 静默支付来说，接收方要从交易的输入公钥推导出共享密钥，而 coinbase 交易并没有输入公钥。矿池可以创建一个临时私钥，用它来推导发送方公钥 `A_send`。为了防止矿池研磨出一个恶意的 `a_send` 私钥，`A_send` 会与正在挖的那个区块的高度一起做哈希，以此取代原本由输出点提供的唯一性。最后，这 34 字节的 `A_send` 会放进 coinbase 的 scriptSig 里，占掉所谓的矿池标签（pool tag）的位置，这样矿工就能扫描链上数据找到自己的资金。

  作者正在征求对这个设想的反馈和批评意见，以便把它正式写成一份真正的规范。

- **<!--responsible-disclosure-of-a-denial-of-service-vulnerability-in-cln-->****CLN 中一个拒绝服务漏洞的负责任披露：** Erick Cestari 在 Delving Bitcoin 上[发帖][cln dos del]，负责任地披露了一个影响 [25.09][cln v25.09] 之前各版本 CLN 节点的严重拒绝服务（DoS）漏洞。攻击者原本可以向节点大量发送 `ping` 消息、每条都索要尽可能大的 `pong` 回复，同时从不去读 TCP socket，从而造成内存耗尽（OOM）崩溃；发动这种攻击只需要完成 [BOLT8][] 握手，连通道都不需要。

  这个问题与 CLN 管理连接的方式有关。每个对等节点都会和本节点建立一条 BOLT8 加密的 Noise 信道，而这条连接由一个专门的守护进程 `connectd` 管理。该守护进程负责处理 TCP 连接、解密收到的消息，并把它们路由给管理着与发送方之间那条支付通道的子守护进程。不过，有些消息是由这个守护进程自己在本地处理的，`ping` 消息就是其中之一，而回复的 `pong` 有多大，是由发送方来定的。

  CLN 对那些要路由给子守护进程的消息设有背压机制——`connectd` 会等子守护进程就绪之后再去读下一条消息；但这套机制并不适用于守护进程自身，它会继续读取那些在本地处理的消息。于是攻击者原本可以反复发送 `ping`，每条都索要允许的最大回复长度 65531 字节，并且从不读取回复，先把自己这一侧的 TCP socket 缓冲区填满，接着再填满对方的。这会导致 `peer_outq` 队列排不出去，最终引发 OOM 崩溃。

  修复办法是给 `connectd` 守护进程自己也配上一套背压机制：要等 `peer_outq` 队列真正排空之后，才去读下一条进来的消息。这个修复在 [Core Lightning #8525][] 中做出，随 25.09 版发布。

## 共识变更

_每月栏目，总结关于修改比特币共识规则的提议和讨论。_

- **<!--continued-discussion-of-pqc-output-types-->****PQC 输出类型讨论的后续：** 继上个月[总结][news417 pqout]了 Pieter Wuille 在 Delving Bitcoin 上那个关于[后量子][topic quantum resistance]输出类型的主题帖之后，Wuille [回复][pw delving pqout cisa]了 Conduition 的论点——后者认为把 [CISA][topic cisa] 与 [P2TRv2][news403 pqout] 搭配起来，会强烈激励用户迁移。Wuille 并不认为费率上的节省能撬动长尾用户——他估算这种节省最多也就是把重量降低约 28%，而且只对输入很多的交易才成立。他给出的理由是，真正的瓶颈在于钱包和托管方的支持；CISA 会带来规范和实现上的复杂度，可能拖慢 P2TRv2 软分叉；而且各家机构可能会把所有 PQC 相关的工作一直往后拖，直到能把 P2TRv2 和 CISA 一起交付为止。他仍然倾向于：普通用户默认用 P2TRv2，而想要隐藏 EC 点的高级用户则用 [P2MR][news393 p2mr]。他还指出，Q 日之后基于哈希的签名，很可能需要一套新的见证计费规则，让 CPU 占的权重更大、序列化大小占的权重更小（见[周报 #417][news417 pqwit]）。他另外提醒，如果让第三方中继节点去逐步聚合签名，真实的带宽开销就会被藏进共识层里；而且这会鼓励用户把交易直接递交给矿工，从而进一步巩固现有矿池的地位。Conduition [反驳][c delving pqout cisa]说，可以先采用一种支持 CISA 的输出类型、配上普通的 BIP340 签名，聚合以后再加；他还说，要让基于哈希的签名在手续费上能和 EC 竞争，就得把序列化的区块大小放大 8 倍甚至更多，那样一来，除非能用全区块范围的 SNARK 聚合把见证裁剪掉，否则归档存储每年会涨到以 TB 计。Adam Gibson [认同][ag delving pqout] Wuille 的看法：把 CISA 捆进 P2TRv2，与 P2TRv2 “先求普及”的目标并不相配。

- **<!--dropkick-commit-reveal-pqc-rescue-->****DropKick：承诺-揭示式的 PQC 救援：** Conduition 在 Bitcoin-Dev 邮件列表上[发帖][c ml dropkick]，勾勒了 DropKick 的轮廓：这是一套承诺-揭示式的[后量子][topic quantum resistance]救援协议（另见[周报 #361][news361 pqcr]和[周报 #348][news348 utxo proving]），面向那些到 Q 日为止还没有把币转移到支持 PQC 的输出上的用户。用户把一份承诺藏在某个区块里的某处（例如放进 `OP_RETURN`，或者藏在一个 taproot tweak 里），这份承诺锁定的是自己的后量子公钥和所有权见证（也就是知识不对称的证明）。自己没有 PQ 安全 UTXO 的用户，可以把承诺交给不受信任的聚合方；聚合方会把许多用户的承诺汇总到单个链上默克尔根之下，并且可以选择从救回来的币里收取一笔手续费。延迟一段时间之后，用户再揭示这份证明、一个由其后量子公钥作出的签名，以及一份 SPV 式的打开证明，用来说明该承诺确实出现在更早的某个区块里。如果 DropKick 只对那些具备可判定的知识不对称的 UTXO 施加约束——也就是验证者仅凭输出本身就能看出存在被哈希的公钥这类隐藏数据——那么它可以作为一次不构成没收的软分叉来部署。如果把 BIP32 密钥派生这类不可判定的情形也纳入进来，能救回更多的币，但也可能没收掉一部分。P2PK 的币则无法覆盖。Tadge Dryja 的 Lifeboat 要求每位用户自己得有一个 PQ 安全的 UTXO 才能发布承诺；相比之下，DropKick 去掉了“必须为每一条链上承诺建索引并排序”这项要求，代价是揭示阶段会面临矿工审查的风险。Conduition 认为，一段足够长的延迟（如果用户愿意把 UTXO 的 1% 付给诚实矿工，大约需要 100 个区块），再加上一笔与金额成比例的手续费，就能让审查变得无利可图——前提是审查方没有能力、或者不愿意去重组掉那些会破坏其审查企图的区块。

- **<!--shrincs-draft-bip-->****SHRINCS 的 BIP 草案：** Conduition 代表 SHRINCS 工作组，在 Bitcoin-Dev 邮件列表上[发帖][c ml shrincs]，公布了第一份[草案][shrincs bip]，把 SHRINCS 规范为一种面向比特币的、半有状态的[基于哈希的][news386 jn hash]签名方案（见[周报 #391][news391 shrincs]）。公钥为 48 字节。有状态签名最小为 548 字节；内置的无状态回退方案则会产生 5,777 字节的签名（草案把无状态预算提高到 2^40 个签名，好让闪电网络这类高频协议也能用上这个回退方案）。在有 SHA256 硬件加速的情况下，按每字节计算，验证速度比 [BIP340][] [schnorr 签名][topic schnorr signatures]快 4 到 16 倍；最坏情况下，一个无状态签名需要 2,792 次 SHA256 压缩。相较最初的提案，值得一提的改动包括：黑盒式的 SLH-DSA（FIPS-205）兼容性、结构任意的灵活 XMSS 树，以及更快（但也更大）的有状态参数。这份草案只规范了签名方案本身；至于要通过新的操作码还是新的输出类型来部署这些新签名，则要另行提案。重复使用有状态的计数器会让旁观者能够伪造签名。Antoine Riard [指出][ar ml shrincs]，5,777 字节的无状态签名，其链上开销大约是今天交易的 90 倍——除非对这些字段给予折扣。此外，Jonas Nick 和 remix7531 的 [libshrincs][news419 libshrincs] C 语言库也已单独发布，其中带有经机器检验的 WOTS+C 证明，为想要集成 SHRINCS 的人提供实现上的支持。

- **<!--bip448-and-csfs-ctv-demos-and-applications-->****BIP448 与 CSFS/CTV 的演示和应用：** 围绕 [BIP448][] 的工作还在继续；BIP448 是把 `OP_TEMPLATEHASH`、[`OP_CHECKSIGFROMSTACK`][topic op_checksigfromstack]（CSFS）和 `OP_INTERNALKEY` 打包在一起的那套 [tapscript][topic tapscript] 提案（见[周报 #397][news397 bip448]）。近来出现了几个新站点，用来汇总各类演示、实现和概念验证。一个 [BIP448][bip448 org] GitHub 组织收集了各种实现：Bitcoin Inquisition、一份不含激活逻辑的 Bitcoin Core 补丁、[miniscript 和 PSBT 的集成][news395 thikcs]、[LN-Symmetry][topic eltoo] BOLTs 草案及其 Core Lightning 实现，以及一个 [Ark][topic ark] 的 `OP_TEMPLATEHASH` signet [演示][news419 thark]。该组织提到，随着下一个 Bitcoin Inquisition 版本发布，整套提案将可以在默认的 [signet][topic signet] 上使用。askii21m [发布][askii delving cvd]了 covenants.diy，这是一个浏览器里的编辑器，可以构建 [taproot][topic taproot] 输出，并在可选的操作码集合下单步执行 tapscript；它还带有可用固定链接引用的示例，包括 BIP448 的可重绑定状态、[BIP119][] 保险库与拥堵控制，以及 BIP348 委托。Cofund 的 Jesus Najera（setzeus）[发布][cofund atlas]了一份交互式的限制条款用例图鉴（Covenants Use-Case Atlas），收录了二十多种构造，包括保险库、拥堵控制、Ark 发行和 LN-Symmetry。

  Ademan [发帖][ademan delving lark]，给出了一个与之相关的构造，针对的是 Ark 中轮次之外（out-of-round，OOR）的虚拟交易输出（VTXO）指派——这类指派被用来开启小额的即时（[JIT][topic jit channels]）闪电网络通道。由于 Ark 服务器既是运营方、又是最初的 VTXO 持有者，它目前可以把同一个 VTXO 反复指派很多次。Ademan 设计的重复指派保证金（equivocation bond）则是可罚没的：只要公布两个由指派密钥作出、且经 CSFS 验证的签名，而二者签的是不同的 [BIP341][] sighash，这笔保证金就会被罚没。这笔保证金以及预先分配好的交易树，都需要一种针对下一笔交易的[限制条款][topic covenants]，可以用 [`OP_CHECKTEMPLATEVERIFY`][topic op_checktemplateverify]（CTV），也可以用 `OP_TEMPLATEHASH`。

## 版本和候选版本

_流行比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。_

- [Core Lightning 26.06.7][] 是这一流行闪电网络节点实现当前主版本的安全版本。它修复了若干经负责任披露的漏洞，其中没有已知正在被积极利用的；报告者包括 Erick Cestari，他此前的那次披露见上文“新闻”栏目。项目方强烈建议所有用户升级。如[周报 #420][news420 cln embargo]所述，源代码会在 8 月 28 日发布二进制文件之后再扣留 14 天，以拖慢攻击者对修复内容的逆向工程。等这段时间过去，CLN 的[可复现构建][topic reproducible builds]可以让用户验证这些二进制文件。另外，在 8 月 28 日到 9 月 1 日之间，拉取了 `v26.06.7` 或 `latest` 标签的 Docker 用户，拿到的镜像虽然报告的是新版本号，却并不包含这些修复。这些用户应当检查自己镜像的摘要（digest）并重新拉取。

- [LND v0.21.3-beta][] 是这一流行闪电网络节点实现的维护版本。它包含了下文“重大的代码和文档变更”栏目介绍的对等节点资源限制、`channel_update` 编码修复和粉尘 [HTLC][topic htlc] 处理修复，以及[周报 #420][news420 lnd deadlock]提到的 [PSBT][topic psbt] 注资死锁修复。它还修复了：带有辅助输出的通道（例如 [Taproot Assets][topic client-side validation] 通道）在合作关闭时的手续费 bug、旧式 [AMP][topic amp] 发票在原生 SQL 发票迁移中的失败、REST WebSocket 代理的 panic，以及若干 gossip 查询和合作关闭相关的 bug；此外还新增了实验性的 `XCreateAccount` RPC（见[周报 #419][news419 lnd account]）。

- [LND v0.20.4-beta][] 是 LND 0.20 发布分支的维护版本。它回移植了 0.21.3-beta 中的大部分修复，包括对等节点资源限制、`channel_update` 编码修复和粉尘 HTLC 处理修复；此外，对于入站手续费、[MuSig2][topic musig] nonce 这类固定长度的 TLV 记录，如果其声明的长度不正确，现在会直接拒绝，而不再默默接受并重新编码。

## 重大的代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #36111][] 限制了 `validateaddress` RPC 在为过长的 [bech32][topic bech32] 字符串报错时所占用的内存。此前，对于超出 [BIP173][] 所设 90 字符上限的字符串，上限之后的每一个位置都会作为一个错误位置返回（见[周报 #177][news177 bech32]），并各自转成一个单独的 JSON 值。现在，这个 RPC 只返回位置 90，也就是长度违规开始的地方。在作者的测试中，一个接近 HTTP 请求大小上限的已认证请求，改动前大约用掉 5.7 GiB 内存，改动后是 240 MiB。

- [Bitcoin Core #36032][] 改善了 `createrawtransaction`、`createpsbt`、`sendmany` 以及其他构建交易的 RPC 的性能，把输出解析从平方复杂度降到了线性。此前，解析器会先遍历输出的键，再逐个去查找各自对应的值，每次都要把同一个内部列表重新扫一遍；此外，`sendmany` 在解析期间一直持有钱包锁。现在，解析器按下标把键和值一起走一遍，做法与[周报 #419][news419 gettxspendingprevout]里 `gettxspendingprevout` 的修复类似。作者报告称，在 debug 构建下解析 10,000 个输出，耗时从 1.8 秒降到了 0.5 秒。

- [Core Lightning #9435][] 让 CLN 在对等节点发来 `next_commitment_number` 为零的 `channel_reestablish` 消息时强制关闭通道，这是 [BOLT2][] 的要求。该值为零意味着对等节点已经丢失了自己的通道状态；广播最新的承诺交易，可以让它借助[静态通道备份][topic static channel backups]取回自己的余额。此前，CLN 只在刚刚打开的通道上执行这条规则；对于其他通道，CLN 会先检测到对等节点的 `next_revocation_number` 已经陈旧，发出一条警告，然后就让通道继续开着。

- [Eclair #3368][] 修复了一个 bug：在非 [taproot][topic taproot] 通道上从对等节点收到的 `commitment_signed` 消息，有可能携带 `partial_signature_with_nonce` 这个 TLV，而它本来是[简单 taproot 通道][topic simple taproot channels]用来传递 [MuSig2][topic musig] 局部签名的（见[周报 #404][news404 eclair taproot]）。虽然 Eclair 会正确地验证消息里那个常规的 ECDSA 签名，但它却错误地把这个不请自来的局部签名当作对等节点的签名存了下来。这会导致 Eclair 日后无法强制关闭该通道。现在，Eclair 会先根据通道的承诺格式选出匹配的签名类型再作验证，并且只保存验证通过的那个签名。

- [Eclair #3366][] 加固了[拼接][topic splicing]，以应对不遵守规范的对等节点。如果对等节点在发出自己的 `stfu` [静默][topic channel commitment upgrades]消息之后还发送通道更新，或者在拼接尚在协商时就发来 `commitment_signed` 消息，Eclair 现在会断开与它的连接。如果对等节点试图在拼接正在签名的过程中推进通道已有的承诺，Eclair 会强制关闭通道，而不是接受它。它还会拒绝完成那些承诺编号已经与通道对不上的拼接或[双向注资][topic dual funding] [RBF][topic rbf] 尝试。最后，如果 Eclair 通过[流动性广告][topic liquidity advertisements]出售流动性的那种拼接，在签名开始之后被中止，Eclair 现在会立刻让为此付款的入站 [HTLC][topic htlc] 失败（相关的一处修复见[周报 #379][news379 eclair liquidity]）。

- [LND #11090][] 对入站的 `ping` 消息作了限速，并给每个对等节点的出站消息队列设了上限，从而防止上文“新闻”栏目里描述的那种针对 CLN 的资源耗尽。对每一条对等节点连接，LND 现在会维护两个令牌桶。入站 `ping` 请求桶初始有 200 个令牌，按每秒 10 个的速率补充；把这个桶耗尽会导致该对等节点被断开连接。出站 `pong` 回复桶初始有 20 个令牌，按每秒 1 个的速率补充；把这个桶耗尽会让 LND 停止回复，这是对 [BOLT1][] 的一处有意偏离。每个对等节点的出站队列还被限制在 10,000 条消息或约 16 MiB 以内。此外，这个 PR 修复了 `channel_update` [gossip 消息][topic channel announcements]的编码问题，使 LND 自己那些用来通告[入站手续费][topic inbound forwarding fees]的更新，其签名所覆盖的字节与它实际广播出去的字节完全一致；此前这两者可能有出入，导致对等节点拒绝该更新。而 LND 从其他节点转发过来的更新，现在也会保留其中它不认识的 TLV 记录，而不像以前那样把它们丢掉、让原始发起节点的签名失效（Eclair 上一处类似的修复见[周报 #418][news418 eclair flags]）。

- [LND #11140][] 修复了 LND 对转发中的 [HTLC][topic htlc] 的处理方式，针对的是这种情形：出站通道被强制关闭，而这笔 HTLC 因为是[粉尘][topic uneconomical outputs]，在一方的承诺交易上被[修剪][topic trimmed htlc]掉了，在另一方的承诺交易上却没有。此前，如果这笔 HTLC 在 LND 自己的承诺交易上有输出，而最终确认的却是对方那笔没有该输出的承诺交易，LND 就一直不会把入站 HTLC 失败回去，因为它是按自己的承诺交易来判断的。于是这笔入站 HTLC 会一直挂着，直到上游通道在接近其过期时间时被强制关闭。现在，LND 改为依据实际确认的那笔承诺交易来判断。另外，当出站 HTLC 在 LND 自己的承诺交易上是粉尘、但在对方的承诺交易上有输出时，LND 也不再提前让入站 HTLC 失败，因为对方仍有可能拿着原像去认领那个输出。

- [HWI #792][] 为 `signtx` 命令增加了 `--registration` 选项，用来在签名 [PSBT][topic psbt] 时使用那些此前已经通过 `registerdescriptor` 命令注册到硬件签名设备上的 [BIP388][] 钱包策略（见[周报 #419][news419 hwi]和[周报 #420][news420 hwi]）。这个选项接受 `registerdescriptor` 返回的序列化注册信息，其中包含策略名称、[描述符][topic descriptors]、设备类型，以及 Ledger 的 HMAC 这类设备专有的注册数据。目前已为 BitBox02、Coldcard Edge、Jade 和非旧款的 Ledger 设备实现了支持。

- [BDK #2262][] 修复了一个 bug：重新索引钱包的交易图时，可能会漏掉钱包自己的一部分输出。BDK 的 `KeychainTxOutIndex` 会在它见过的最高 [BIP32][] 派生下标之外，再多盯着一段前瞻的[地址窗口][topic gap limits]；每当在更高的下标处发现输出，这个窗口就会往外扩。此前，重新索引时每个输出只检查一次，于是窗口之外的输出会被判定为不属于该钱包，即便后来有别的输出把窗口撑大了，也不会再回头重新检查它。又因为检查输出的顺序是随机的，同一个钱包在不同次运行中可能显示出不同的余额。现在，重新索引会反复进行，直到窗口不再扩大为止。

{% include snippets/recap-ad.md when="2026-09-08 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="8525,36111,36032,9435,3368,3366,11090,11140,792,2262" %}
[spc del]: https://delvingbitcoin.org/t/silent-payments-coinbase/2833
[cln dos del]: https://delvingbitcoin.org/t/disclosure-crashing-cln-with-a-flood-of-pings/2846
[cln v25.09]: https://github.com/ElementsProject/lightning/releases/tag/v25.09
[news417 pqout]: /zh/newsletters/2026/08/07/#pqc-output-type-discussion
[news417 pqwit]: /zh/newsletters/2026/08/07/#segwit-commitment-to-post-quantum-witness-data
[news403 pqout]: /zh/newsletters/2026/05/01/#discussion-of-a-postquantum-output-type
[news393 p2mr]: /zh/newsletters/2026/02/20/#bips-1670
[pw delving pqout cisa]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/6
[c delving pqout cisa]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/7
[ag delving pqout]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/15
[c ml dropkick]: https://groups.google.com/g/bitcoindev/c/6SqWPfBf-p0
[news361 pqcr]: /zh/newsletters/2025/07/04/#commit-reveal-function-for-post-quantum-recovery
[news348 utxo proving]: /zh/newsletters/2025/04/04/#securely-proving-utxo-ownership-by-revealing-a-sha256-preimage
[c ml shrincs]: https://groups.google.com/g/bitcoindev/c/HbVboXIFiG8
[shrincs bip]: https://github.com/SHRINCS/shrincs-bip/blob/main/SHRINCS.md
[ar ml shrincs]: https://gnusha.org/pi/bitcoindev/b4bb949d-bd35-424d-a1d1-459e6cca263an@googlegroups.com/
[news386 jn hash]: /zh/newsletters/2026/01/02/#hash-based-signatures-for-bitcoins-post-quantum-future
[news391 shrincs]: /zh/newsletters/2026/02/06/#shrincs-324-byte-stateful-post-quantum-signatures-with-static-backups
[news419 libshrincs]: /zh/newsletters/2026/08/21/#libshrincs-formally-verified-hash-based-signatures
[news397 bip448]: /zh/newsletters/2026/03/20/#bips-1974
[news395 thikcs]: /zh/newsletters/2026/03/06/#extensions-to-standard-tooling-for-templatehash-csfs-ik-support
[bip448 org]: https://github.com/bip448
[news419 thark]: /zh/newsletters/2026/08/21/#op-templatehash-ark-demonstration
[askii delving cvd]: https://delvingbitcoin.org/t/covenants-diy-a-node-editor-for-covenant-scripts/2826
[cofund atlas]: https://getcofund.com/research/covenants-use-case-atlas
[ademan delving lark]: https://delvingbitcoin.org/t/improving-the-security-of-lark-oor-channels-with-equivocation-bonds/2816
[news177 bech32]: /zh/newsletters/2021/12/01/#bitcoin-core-16807
[news419 gettxspendingprevout]: /zh/newsletters/2026/08/21/#bitcoin-core-35889
[news379 eclair liquidity]: /zh/newsletters/2025/11/07/#eclair-3206
[news418 eclair flags]: /zh/newsletters/2026/08/14/#eclair-3341
[news419 hwi]: /zh/newsletters/2026/08/21/#hwi-842
[news404 eclair taproot]: /zh/newsletters/2026/05/08/#eclair-3144
[news420 hwi]: /zh/newsletters/2026/08/28/#hwi-841
[Core Lightning 26.06.7]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.7
[LND v0.21.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.3-beta
[LND v0.20.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.4-beta
[news420 cln embargo]: /zh/newsletters/2026/08/28/#prepare-for-an-upcoming-core-lightning-security-release
[news420 lnd deadlock]: /zh/newsletters/2026/08/28/#lnd-11008
[news419 lnd account]: /zh/newsletters/2026/08/21/#lnd-11065
