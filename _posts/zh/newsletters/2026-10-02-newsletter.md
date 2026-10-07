---
title: 'Bitcoin Optech 周报 #425'
permalink: /zh/newsletters/2026/10/02/
name: 2026-10-02-newsletter-zh
slug: 2026-10-02-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报总结了影响旧版 Eclair 的两个拒绝服务漏洞的负责任披露，并介绍了一项通过不受信任的存储服务在设备之间同步钱包标签的提案。此外还包括我们的常规栏目：总结关于修改比特币共识规则的提议和讨论、新版本和候选版本的公告，以及流行比特币基础设施软件的重大变更。

## 新闻

- **<!--disclosure-of-two-dos-vulnerabilities-in-eclair-->****Eclair 两个 DoS 漏洞的披露：** Matt Morehouse 在 Delving Bitcoin 上[发帖][mm eclair dos]，[负责任地披露][topic responsible disclosures]了影响 Eclair v0.13.1 及更早版本的两个拒绝服务（DoS）漏洞。这两个漏洞都已在 5 月发布的 [Eclair v0.14.0][news407 eclair] 中修复，仍在运行旧版的用户应当升级。两种攻击都只需要完成 [BOLT8][] 握手，无需建立通道。

  第一个漏洞出在功能位解析上。Eclair 会逐个解析 `init` 消息中的功能位，并为每一位分配多个对象。因此，一条达到最大长度的 `init` 消息就会分配并丢弃约 300 MB 的内存，并占用一个解析线程长达 300 ms。在 Morehouse 的测试中，攻击者用几十条连接反复发送这种消息，就能在一分钟内让节点断开所有对等节点的连接，并在五分钟内耗尽其内存。Morehouse 用自己的闪电网络模糊测试工具 [smite][smite repo] 发现了这个 bug，使用的是其中最基础的测试：将原始字节作为一条消息发送，并检查目标是否仍能及时响应 `ping`。修复在 3 月作为 [Eclair #3264][] 的一部分合并；这个 PR 重构了功能位解析，但没有提到该漏洞。

  第二个漏洞出在 gossip 查询上。[BOLT7][] 在 2022 年 4 月移除了 `query_short_channel_ids` 消息的 zlib 编码，Eclair 在同月停止发送这种编码的消息，却仍然接受它们。zlib 解压没有输出大小限制，因此一条 64 kB 的消息可以膨胀到 64 MB，并产生约 1,700 万个对象；大量这样的消息可以在几秒内让节点下线。发现第一个 bug 后，Morehouse 使用 LLM 搜索 Eclair 代码库，寻找其他能让对等节点以很小开销迫使节点做大量工作的地方，由此发现了这个漏洞。修复见 [Eclair #3263][]。

- **<!--proposal-for-wallet-label-synchronization-->****钱包标签同步提案：** Jakub 在 Bitcoin-Dev 邮件列表上[发帖][label sync ml]，在编写规范之前，先征询大家是否有兴趣将钱包之间通过共享、不受信任的存储服务同步[钱包标签][topic wallet labels]的做法标准化。虽然 [BIP329][] 已经规定了标签导出格式（见[周报 #215][news215 label]），但在使用同一[描述符][topic descriptors]的钱包之间转移标签，例如在协调器和仅观察钱包之间，仍然需要手动导出和导入。因此，选币时就无法利用相关的标签。

  按照这项提案，钱包会从规范化的描述符中派生存储位置和加密密钥，无需使用任何私钥。这样，共享描述符的钱包无需配置，就能找到同一份数据。BIP329 记录保持原样，放在认证加密封装中传输。每条记录都带有写入时间，因此当两个钱包修改同一个标签时，以最新的修改为准。由于 BIP329 没有删除标签的方式，删除操作会以标记的形式记录下来，让其他钱包也移除这个标签。Jakub 提议将 Nostr 作为参考传输方式，但协议只需要一种能存储并返回数据的服务。Bitcoin Safe 钱包已经通过 Nostr 以这种方式同步标签。Jakub 询问，加密密钥应该从描述符中派生，还是从一个单独的秘密值中派生：前者让钱包仅凭描述符就能恢复标签，但也会向任何曾持有这些扩展公钥（xpub）的人暴露标签。他还询问，设备之间应共享一对密钥，还是逐设备配对，以及如何定义描述符的规范形式。

  Craig Raw 回复说，标签同步应当属于一个更广泛的钱包间通信规范，这份规范还应包括 [PSBT][topic psbt]、多签设置和支付确认等其他用例。他也反对将 Nostr 作为参考传输协议，因为交换金融数据应当优先考虑隐私，而非抗审查能力。他还提到，自己正在编写一份关于规范化输出描述符的 BIP。

## 共识变更

_每月栏目，总结关于修改比特币共识规则的提议和讨论。_

- **<!--continued-discussion-of-pqc-output-types-->****关于 PQC 输出类型的持续讨论：** 上个月的[总结][news421 pqout]介绍了 Pieter Wuille 在 Delving Bitcoin 上关于[后量子][topic quantum resistance]输出类型的讨论帖。此后，Antoine Riard [回复][ar delving pqout]表示，可以接受一种 [P2TRv2][news403 pqout] 输出：未来可仅在这一输出类型内禁用其易受量子攻击的花费路径。用户通过向它收款来主动选择加入，这样就避免了全面冻结已有输出。他倾向于不将 [CISA][topic cisa] 与这项变更捆绑，并建议以后推出一种基于 [P2MR][news393 p2mr] 的类型，采用新的见证形式，还可提供可选的叶子版本，让部分资金在其他资金的相应路径被禁用后，仍保留一条由 secp256k1 保护的路径。

  Conduition [认为][c delving pqout deriv]，即便 P2TRv2 也不是简单地提高见证版本号：实际使用后量子路径的钱包，仍需要新的后量子密钥派生标准，来替代 [BIP32][] 式的流程。Wuille [回复][pw delving pqout cisa2]说，对于那些用户不在意手续费或后量子安全的长尾钱包，CISA 不太可能推动它们采用新输出类型。而且，无论 P2TRv2 还是 P2MR，都不是无条件量子安全的输出类型，因为两者都依赖有人决定何时停止使用 secp256k1。P2MR 让所有者自己决定，但 Wuille 认为，地址复用和公钥共享的习惯太根深蒂固，大多数用户难以从中受益。

  Antoine Poinsot [认同][ap delving pqout]，P2TRv2 和 CISA 的作用方向相反：想要 CISA、但预计 secp256k1 不会很快被禁用的用户，可能会拒绝 P2TRv2；更糟的是，他们可能采用 P2TRv2，却不设置后量子花费路径，从而妨碍日后禁用 secp256k1。他还指出，如果将两者作为独立的输出类型推出，并且都得到广泛使用，就可能留下可区分的痕迹。Conduition 和 Wuille 继续讨论了 P2MR 的保护能否在实践中实现，Conduition [提议][c delving pqout both]部署两种输出类型，让用户自行选择。

- **<!--block-wide-signature-aggregation-via-snarks-->****通过 SNARK 聚合整个区块的签名：** Conduition 在 Delving Bitcoin 上[发帖][c delving snark]，给出了一份设计草案，将一个区块中的大量[后量子][topic quantum resistance]签名压缩成单个 SNARK（另见 Ethan Heilman 此前的[提案][eh delving stark]和[周报 #412][news412 stark]）。基于哈希的签名验证开销很低，但体积很大；如果给予足够大的见证折扣，让它们在手续费上有竞争力，那么归档存储的年增量就会达到数 TB（见[周报 #417][news417 pqwit]）。

  Conduition 预计大型矿池会自行生成证明，并认为普通节点不应运行证明器。他的设计采用专用的聚合电路，而非通用虚拟机（VM）；采用单个扁平证明，而非递归证明；采用使用 WOTS+C 的 [SPHINCS][news383 sphincs] 变体，而非 SLH-DSA。验证这个变体时，每个签名所需的哈希运算次数都相同；SLH-DSA 的运算次数则取决于签名者的选择，因此它的电路必须按开销最大的情况设计。最小的基于哈希的 SNARK 证明通常也有 300–500 kB。为了回应对所提议证明的健全性（soundness）的担忧，他概述了几种可根据未来情况恢复或退出的机制。他反对同时允许原始签名和 SNARK 作为有效的区块格式。这种做法虽然可以让矿工在生成证明期间挖掘包含交易的区块，而非空区块，但资源限制就必须按最坏情况设定。根据哈希电路 SNARK 证明器 Flock 的 SHA256 基准测试作简单外推，为一个包含 10,000 个签名的区块生成证明，在使用 10 个线程的 CPU 上大约需要 20 秒，有望降到 10 秒以下。不过，Conduition 指出，还没有人在 Flock 中测试过 SPHINCS 验证电路。

  Jonas Nick [提及][jn delving snark]了一项研究：SNARK 在随机预言机模型下的证明，并不自动涵盖对同一种 SNARK 的递归使用。ZmnSCPxj [警告][zmn delving snark]说，矿工使用的证明器代码若存在 DoS 漏洞，可能会让出块停滞。他建议将证明器随 Bitcoin Core 一起发布，以便接受审查。

- **<!--bounds-on-chain-length-with-bip54-time-warp-fixes-->****BIP54 时间扭曲修复带来的链长度边界：** Pieter Wuille 在 Delving Bitcoin 上[发帖][pw delving timewarp]，证明了[共识清理][topic consensus cleanup]提案（[BIP54][]）中的两条时间戳规则，足以限制具有给定工作量的链最多能挖出多少个区块。这个边界已经由 Lean 进行机器验证，因此只需审查待证明的命题。第一条规则针对经典的[时间扭曲][topic time warp]攻击，要求难度调整周期的第一个区块，其时间戳最多比前一个区块早 7,200 秒。第二条规则是 Murch–Zawy 规则（见[周报 #316][news316 timewarp]），要求一个周期的最后一个区块不能早于第一个区块。两条规则共同将长期出块速率限制在约每 9 分 56 秒一个区块，此外还可通过提高难度换取数量有限的额外区块。

  对于一条高度为 966,270 的链，这个公式给出的上限是 1,012,794 个区块，大约只有不采用这两条规则时的上限的 1/3,300。省略任意一条规则，都会让上限超过 33.4 亿个区块。Wuille 报告的已构造出的最长链有 1,007,326 个区块。

  Wuille 的动机来自 Bitcoin Core 区块头预同步的 [DoS 防护][news216 presync]；在 BIP54 成为埋藏部署（buried deployment）之后，这项防护就可以利用该边界。Zawy 讨论了其他表达形式。Wuille 后来还证明了一个与之互补的下界：在给定时间内生成一条给定长度的链，至少需要多少工作量。

- **<!--comparing-covenant-proposals-for-vaults-->****比较用于保险库的限制条款提案：** Lillian Wang 在 Delving Bitcoin 上[发帖][lw delving vaults]，并将一份[报告][vault report][转发][lw ml vaults]到了 Bitcoin-Dev 邮件列表。报告比较了使用不同方案构造简化[保险库][topic vaults]的方式，包括预签名交易、[`OP_CHECKTEMPLATEVERIFY`][topic op_checktemplateverify]（CTV）、[`SIGHASH_ANYPREVOUT`][topic sighash_anyprevout] / `SIGHASH_ANYPREVOUTANYSCRIPT`（APO/APOAS）、`OP_TXHASH`、[`OP_CHECKCONTRACTVERIFY`][topic matt]（CCV，[BIP443][]），以及基于 [`OP_CAT`][topic op_cat] 的 [Purrfect Vault][news291 cat vault]。

  报告认为，CTV 适合输出已预先计算好的简单保险库，CCV 最能支持部分提款，以及在触发提款时选择提款地址，而 TXHASH 提供了更灵活的承诺能力，代价是设计者需要承担更多责任。如果也看重 APOAS 和 CAT 在保险库之外的广泛用途，它们可能会更有吸引力。

  askii21m [指出][askii delving vaults]，APOAS 签名可以将存入同一个保险库地址的两笔存款合并到一笔交易中，而只创建一次预期输出，让第二笔存款的价值全部变成手续费，这就是半花费（half-spend）。原因在于，APOAS 既不承诺输入数量，也不承诺输入索引。因此，绝不复用保险库地址是一项要求，而不是建议。

- **<!--depots-for-probabilistic-lightning-channels-->****用于概率式闪电通道的资金库：** John Law 在 Delving Bitcoin 上[发帖][jl delving depots]，介绍了一种[协议][depots paper]：由运营者向单个有时限的 taproot 输出注资，这个输出称为资金库（depot），可以为成千上万乃至数百万用户承载闪电通道。用户通过闪电支付向运营者购买这些通道，而不必将自己的资金放到链上。这些余额通常很小，不值得到链上领取，因此资金库将每个用户确定可领取的小额资金，替换为有机会领取的、期望值相同的大额资金，从而限制最终可能进入链上的领取数量。

  每个购买的通道都有一个由用户在零与一个大素数（P）之间选出的秘密猜测值。在资金库到期后，通道有 1/P 的概率“命中”。在到期之前，用户应通过闪电网络支付将资金库中的通道余额转出（也可以转入一个更晚到期的资金库），并揭示自己的猜测值，以撤销这些通道，使其无法命中。到期后，运营者会揭示一个目标值：猜测值与之相同的通道即为命中。如果没有通道命中，运营者收回该输出。如果恰好一个通道命中，该用户可以强制资金库在链上结算，获得其链下余额的 P 倍（以 1/P 的概率获得 P 倍金额，其期望值等于用户实际的余额）。如果两个或更多通道命中，资金库就会被销毁，从而防止用户领取超过资金库余额的金额。

  按 Law 的说法，这将链上占用控制在每位用户每年约 1 或 2 vbytes，并避免大量用户同时被迫发起链上交易，因为无论承载多少用户，资金库都只需固定数量的交易来结算。其安全性依赖[破坏者惩罚（griefer penalization）][news329 opr]：实施破坏的一方（例如拒绝配合转出余额），必须预期会损失其所造成损害的一个预设比例。资金库需要 [`OP_CHECKSIGFROMSTACK`][topic op_checksigfromstack] 和 [`OP_CHECKTEMPLATEVERIFY`][topic op_checktemplateverify]。有了 `OP_PAIRCOMMIT`（[BIP442][]）、`OP_MUL` 和 `OP_MOD`，它们的效率会更高，但并不依赖这些操作码。

  Anzus 询问，如果用户错过到期时间或丢失设备，会发生什么。Law [回复][jl delving depots recover]说，与他的[超时树][topic timeout trees]不同，运营者无法在没有用户提供秘密值的情况下将资金库续期；钱包可以自动提前转出余额；而恢复时除了种子，还需要资金库参数和通道状态。

## 版本和候选版本

_流行比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。_

- [LND v0.21.4-beta.rc1][] 是这一流行闪电网络节点实现的维护版本的候选版本。它包含下文重大代码变更栏目介绍的[通道公告][topic channel announcements]同步修复，以及对新建传统通道的限制。其他修复针对待处理的 [HTLC][topic htlc]、意外取消 [AMP][topic amp] 发票，以及 SQL 图数据库迁移失败等问题。`WalletKit` 现在可以将输出保留到花费它们的交易达到指定的确认深度。这个版本还要求在开启通道时明确指定通道类型。

- [LND v0.20.5-beta.rc1][] 是 LND 0.20 发布分支的维护版本的候选版本。它回移了 0.21.4-beta.rc1 中的多项修复，包括待处理 HTLC、AMP 发票取消和通道同步方面的修复，并为洋葱载荷解析增加了边界限制。

## 重大的代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #29278][] 增加了 `-maxfeerate` 配置项，默认将钱包交易的费率上限设为 0.10 BTC/kvB（10,000 sat/vB）。此前，`-maxtxfee` 的文档将它描述为绝对手续费上限，但某些检查也将同一个数值解释为每 1,000 vB 的手续费（见[周报 #54][news54 maxtxfee]）。新选项将费率限制与总手续费限制分开，并适用于交易创建、[手续费追加][topic rbf]、[CPFP][topic cpfp] 和常规的钱包广播。

- [Bitcoin Core #35984][] 修复了一个 bug：[PSBT][topic psbt] 签名可能在没有对应输出时生成 `SIGHASH_SINGLE` 签名。这种签名哈希类型承诺的是与待签名输入具有相同索引的输出。如果对应输出缺失，传统签名会对一个固定哈希值生成签名（见[周报 #207][news207 single]）。只要对应输出仍然缺失，这个签名就能被复用来花费由同一密钥控制的其他 UTXO。现在，对于传统脚本和 segwit v0，Bitcoin Core 会让这样的输入保持未签名，同时继续签署 PSBT 中的其他输入，将原始交易签名中已有的检查扩展到了 PSBT。

- [Bitcoin Core #35301][] 开始实现 [BIP352][] [静默支付][topic silent payments]，增加了地址编解码、从符合条件的交易输入派生 [taproot][topic taproot] 支付输出，以及扫描交易以查找向某个接收者付款的支持。它还增加了标签支持，用来区分向不同派生地址的支付，并识别找零。这项实现建立在 libsecp256k1 的静默支付模块之上（见[周报 #415][news415 silent]）。不过，这个 PR 尚未让钱包可以通过 RPC 或 GUI 发送或接收静默支付。

- [Bitcoin Core #36312][] 修复了一个隐私泄露问题，影响的是需要主动启用的实验性私密交易广播功能（见[周报 #388][news388 private broadcast]）。此前，[抑制行为不当的对等节点][news106 discouragement]，可能同时断开与同一地址的常规连接和私密广播连接。恶意对等节点可以故意触发这些断连，将私密广播连接与该节点的常规连接关联起来，削弱[交易来源隐私][topic transaction origin privacy]。现在，行为不当的私密广播对等节点会被断开，但不会抑制其地址；抑制常规对等节点时，也会保留与同一地址的私密广播连接。

- [Bitcoin Core #36284][] 修复了一个 bug：通过 `-avoidpartialspends` 选项（见[周报 #6][news6 avoidpartial]）或钱包的 `avoid_reuse` 标志（见[周报 #52][news52 avoid reuse]）启用避免部分花费后，钱包即使有足够的合格资金，也可能拒绝支付。避免部分花费会在[选币][topic coin selection]时，将支付到同一地址的输出分为一组，以减少[输出关联][topic output linking]。此前，如果某一组没能通过资格检查（例如未确认祖先数量限制），它的价值会从可供选择的金额中扣除两次。现在，每个被拒绝的组的价值只会扣除一次。

- [Bitcoin Core #35752][] 修复了加密钱包、修改其加密口令，以及添加私钥时的错误处理。此前，数据库写入失败可能让口令修改看似成功，但重新加载钱包后，只有旧口令可用。加密过程也可能在缺少必要密钥记录，或数据库中仍留有明文私钥的情况下报告成功，而数据库提交失败则可能导致 Bitcoin Core 终止。私钥插入失败可能让密钥只存在于内存中，在重新加载钱包后从钱包中消失。现在，钱包会检查数据库操作，回滚失败的加密更新，并且只有在相应写入成功后才更新内存中的密钥，使失败的操作可以重试。这个 PR 还防止失败的口令修改让原本锁定的钱包处于解锁状态，并将数据库或加密失败与口令错误分开报告。

- [Bitcoin Core #35813][] 增加了 `listrawtransactions` 钱包 RPC，可以列出钱包已知的所有交易，每笔交易返回一条记录，其中包含原始交易的十六进制数据。现有的 `listtransactions` RPC 返回的是会计记录：向自己的收款地址转账，可能同时产生一条发送记录和一条接收记录，而完全转入找零地址的交易则可能被省略。`count` 和 `skip` 参数提供分页，`verbose` 则会增加解码后的交易详情。

- [BIPs #2276][] 和 [#2277][bips #2277] 修正了 [PSBT][topic psbt] 的最终化规则，这些规则可能丢弃后续签名或提取交易所需的信息。第一个 PR 移除了 [BIP376][] 在最终化[静默支付][topic silent payments]输入时删除 `PSBT_IN_WITNESS_UTXO` 的要求（见[周报 #401][news401 bip376]）。同一笔交易中的其他 [taproot][topic taproot] 输入，仍可能需要这个被花费输出的金额和脚本来计算签名。第二个 PR 更新了 [BIP370][]，要求在 PSBTv2 输入最终化后保留前序输出标识符、序列号，以及必需的[锁定时间][topic timelocks]。删除这些字段可能使 PSBT 无效，或改变提取出的交易。它还移除了 [BIP371][] 中一条错误的指示，即在输入最终化时删除输出的 taproot 派生数据。

- [LDK #4993][] 修复了一个 bug：钱包可能在一笔与尚未确认的[拼接][topic splicing]交易相冲突的交易中，花费已经保留的输入。此前，如果 LDK 因为通道已被强制关闭而拒绝一次 [RBF][topic rbf] 手续费追加注资，它可能让钱包释放原始拼接仍然需要的输入。在连续的手续费追加尝试中，钱包还可能收到重复的释放指令，或没有释放已不再需要的预留。现在，每次注资都会记录从先前尝试中继承的输入和输出，因此失败时，只会让钱包释放本次注资自己的预留。这个 PR 还增加了错误信息和预留查询，帮助应用安全地重试失败的注资。

- [LND #11173][] 修复了一个 bug：无效或过大的通道范围响应，可能让[通道公告][topic channel announcements]的初始同步停滞，直到下一次预定的尝试。LND 将每次查询响应中的短通道 ID（SCID）总数限制在 100,000 个以内（见[周报 #417][news417 scids]）。现在，如果有其他符合条件的对等节点，LND 会立即改与它重试同步，并暂时排除失败的对等节点，不再选用它。与失败对等节点的已有连接仍然保持开启。

- [LND #11190][] 更新了 LND，使其拒绝包含多个支付哈希（`p`）字段的 [BOLT11][] 发票，即使这些哈希值相同。此前，LND 按 BOLT11 规范的建议，使用第一个支持的支付哈希并忽略其余字段。然而，其他发票解析器可能选择不同的哈希。如果某个服务的发票解析器和闪电网络节点使用了不同的哈希，该服务就可能将已完成的提现误判为尚未支付，导致支付两次。拒绝重复字段消除了这种歧义。BOLT11 已经要求发票创建者恰好包含一个 `p` 字段；[BOLTs #1357][] 则提议要求读取者拒绝重复字段。

- [LND #11212][] 移除了开启或接受使用传统承诺格式的新通道的支持，与 [BOLT2][] 保持一致（见[周报 #305][news305 commitments]）。传统承诺使用 per-commitment point 来派生支付给对手方的输出（`to_remote`）的密钥。因此，如果节点丢失了通道状态，要从对等节点的承诺交易中恢复资金，就需要该对等节点提供缺失的点。静态远程密钥通道会在通道更新时保持这个输出密钥不变，从而避免这种依赖（见[周报 #67][news67 static remote key]）。现有的传统通道仍可使用。Eclair 去年也做了同样的变更（见[周报 #378][news378 eclair legacy]）。

- [LND #11258][] 修复了一个 bug：如果 LND 在出站通道关闭、其记录被清理之后重启，转发的 [HTLC][topic htlc] 可能一直无法完成处理。此前，收到的结算或失败响应尚未正式记入入站通道状态时，通道清理就可能将其删除。这可能让入站 HTLC 卡住，导致入站通道被不必要地强制关闭，并产生额外的链上手续费。现在，LND 会将待处理的响应与已关闭通道分开保存，保留将其匹配到入站 HTLC 所需的信息，并在启动时重新处理这些响应。

{% include snippets/recap-ad.md when="2026-10-06 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3263,3264,29278,35984,35301,36312,36284,35752,35813,11173,11190,1357,11212,11258,2276,2277,4993" %}

[mm eclair dos]: https://delvingbitcoin.org/t/disclosure-dos-vulnerabilities-fixed-in-eclair-v0-14-0/2914
[news407 eclair]: /zh/newsletters/2026/05/29/#eclair-v0-14-0
[smite repo]: https://github.com/lnfuzz/smite
[label sync ml]: https://groups.google.com/g/bitcoindev/c/p6UUOdGi9YI
[news215 label]: /zh/newsletters/2022/08/31/#wallet-label-export-format
[news421 pqout]: /zh/newsletters/2026/09/04/#continued-discussion-of-pqc-output-types
[news403 pqout]: /zh/newsletters/2026/05/01/#discussion-of-a-postquantum-output-type
[news393 p2mr]: /zh/newsletters/2026/02/20/#bips-1670
[ar delving pqout]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/18
[c delving pqout deriv]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/20
[pw delving pqout cisa2]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/22
[ap delving pqout]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/32
[c delving pqout both]: https://delvingbitcoin.org/t/pqc-output-type-discussion/2749/38
[c delving snark]: https://delvingbitcoin.org/t/block-wide-signature-aggregation-via-snarks/2875
[eh delving stark]: https://delvingbitcoin.org/t/post-quantum-signatures-and-scaling-bitcoin-with-starks/1584
[news383 sphincs]: /zh/newsletters/2025/12/05/#lh-dsa-post-quantum-signature-optimizations
[news412 stark]: /zh/newsletters/2026/07/03/#benchmarking-slh-dsa-stark-aggregation
[news417 pqwit]: /zh/newsletters/2026/08/07/#segwit-commitment-to-post-quantum-witness-data
[jn delving snark]: https://delvingbitcoin.org/t/block-wide-signature-aggregation-via-snarks/2875/8
[zmn delving snark]: https://delvingbitcoin.org/t/block-wide-signature-aggregation-via-snarks/2875/4
[pw delving timewarp]: https://delvingbitcoin.org/t/bounds-on-chain-length-with-bip-54-timewarp-fixes/2899
[news316 timewarp]: /zh/newsletters/2024/08/16/#new-time-warp-vulnerability-in-testnet4
[news216 presync]: /zh/newsletters/2022/09/07/#bitcoin-core-25717
[lw delving vaults]: https://delvingbitcoin.org/t/comparing-bitcoin-covenant-proposals-for-vaults/2877
[lw ml vaults]: https://groups.google.com/g/bitcoindev/c/Tv4k9kK5KYA
[vault report]: https://raw.githubusercontent.com/Skyler-Cloud/Bitcoin-Vault-Comparison/main/bitcoin-vault-comparison.pdf
[askii delving vaults]: https://delvingbitcoin.org/t/comparing-bitcoin-covenant-proposals-for-vaults/2877/4
[news291 cat vault]: /zh/newsletters/2024/02/28/#simple-vault-prototype-using-op-cat-op-cat
[jl delving depots]: https://delvingbitcoin.org/t/depots-theft-proof-self-custodial-bitcoin-for-billions-of-users/2892
[depots paper]: https://github.com/JohnLaw2/ln-depots/blob/main/depots_v1.0.pdf
[jl delving depots recover]: https://delvingbitcoin.org/t/depots-theft-proof-self-custodial-bitcoin-for-billions-of-users/2892/10
[news329 opr]: /zh/newsletters/2024/11/15/#mad-based-offchain-payment-resolution-opr-protocol
[LND v0.21.4-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.4-beta.rc1
[LND v0.20.5-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.5-beta.rc1
[news54 maxtxfee]: /zh/newsletters/2019/07/10/#bitcoin-core-16257
[news207 single]: /zh/newsletters/2022/07/06/#rust-bitcoin-1024
[news388 private broadcast]: /zh/newsletters/2026/01/16/#bitcoin-core-29415
[news106 discouragement]: /zh/newsletters/2020/07/15/#bitcoin-core-19219
[news6 avoidpartial]: /zh/newsletters/2018/07/31/#bitcoin-core-12257
[news52 avoid reuse]: /zh/newsletters/2019/06/26/#bitcoin-core-13756
[news305 commitments]: /zh/newsletters/2024/05/31/#bolts-1092
[news378 eclair legacy]: /zh/newsletters/2025/10/31/#eclair-3173
[news67 static remote key]: /zh/newsletters/2019/10/09/#lnd-3365
[news415 silent]: /zh/newsletters/2026/07/24/#libsecp256k1-1765
[news417 scids]: /zh/newsletters/2026/08/07/#lnd-10992
[LDK #4993]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/4993
[news401 bip376]: /zh/newsletters/2026/04/17/#bips-2089
