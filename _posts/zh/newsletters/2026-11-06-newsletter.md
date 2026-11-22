---
title: 'Bitcoin Optech 周报 #430'
permalink: /zh/newsletters/2026/11/06/
name: 2026-11-06-newsletter-zh
slug: 2026-11-06-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报总结了关于使用 TCP 打洞让家庭路由器后方的节点可被连接的后续讨论，并介绍了一份 BIP 草案，用于标准化共同签名者在模拟限制条款时执行的花费策略。此外还包括我们的常规栏目：关于改变比特币共识规则的提案和讨论摘要、新版本和候选版本的公告，以及流行比特币基础设施软件的重大变更。

## 新闻

- **<!--continued-discussion-of-tcp-hole-punching-for-home-nodes-->****关于家庭节点 TCP 打洞的后续讨论：** 今年 5 月，我们[总结][news406 holepunch]了 0xB10C 在 Delving Bitcoin 上发起的讨论，探讨通过打洞让家庭路由器后方的节点接受彼此的连接。此后，0xB10C [发帖][b10c holepunch recap]表示，相关规范和实验性 Bitcoin Core 实现的开发已经恢复。家庭节点通常只能主动建立出站连接，而 Bitcoin Core 30.0 默认启用 NAT-PMP 端口映射后，可被连接的家庭节点数量并没有如预期那样增加很多。打洞是指两个家庭节点同时向对方发起连接，使各自的路由器放行对方的流量，可以作为端口转发的一种尽力而为的补充。攻击者的节点更容易被连接；如果有更多诚实节点可被连接，攻击者就更难占满一个节点的出站连接名额。

  0xB10C 回顾了此前讨论过的四种设计，并[提出][b10c holepunch option6]了一个不需要协调器的新方案：节点通过一种新的 [addr v2][topic addr v2] 类型，通告自己可用于打洞的地址和一个临时公钥；每对节点根据共享秘密和每个新区块，派生出相同的候选列表和打洞时机。Anthony Towns 质疑攻击者可以用大量真实地址淹没这套机制，而 0xB10C 随后又发现，不可被连接的节点收到这类公告的可靠性远低于监听节点。针对这些问题，他勾勒了一个“留言板”替代方案，由监听节点保存正在寻找对等节点的家庭节点的已验证地址。

  Towns 质疑随机入站连接是否真能帮助家庭节点，并[认为][aj holepunch goals]，打洞让攻击者更容易直接连接诚实节点，却几乎无法保证节点能连上一个诚实节点。他估计，通告约 10,000 个地址的攻击者会成为大多数诚实节点早期匹配到的对象，并建议改用与随机对等节点建立短时连接的方案，风险更低。Jonathan Harvey-Buschel 援引数据指出，诚实节点比攻击者控制的节点更难被连接，并倾向于通过节点自己的 [Tor][topic anonymity networks] 服务来协调。Towns 后来又[询问][aj holepunch cves]，近期的 TCP 和协议漏洞是否意味着，对家庭用户而言，默认不接受入站连接会更安全。讨论仍在继续。

- **<!--bip-draft-for-standardized-co-signer-spending-policies-->****共同签名者花费策略标准化的 BIP 草案：** Luke Carriere 在 Delving Bitcoin 上[发帖][cosigner pols del]，介绍了一项提案，用于标准化共同签名者在模拟[限制条款][topic covenants]时执行的花费策略。近期的几种设计，包括 Johan Halseth 的[盲化共同签名者][news412 blinded cosigners]和[链码委托][news364 delegation]，各自定义了不同的策略，因此，为一种设计构建的钱包无法使用为另一种设计构建的共同签名者或预言机。Carriere 尚未为这份[草案][cosigner pol draft]申请 BIP 编号，并询问是否应该在这一层进行标准化。

  草案遵循几项设计原则：

  - 凡是能够由比特币脚本强制执行的要求，都必须在脚本中执行；共同签名者策略只定义脚本无法执行的部分。

  - 始终必须提供至少一条无需共同签名者的花费路径。

  - 共同签名者如何验证花费，以及用什么保障其诚实性，都由每项策略自行选择的可插拔配置方案（profile）决定。

  - 共同签名者必须接受 [DLC][topic dlc] 格式的预言机见证，以便无需修改就能复用现有的预言机。

  一项策略由五个部分组成。输出部分定义持有资金的 [taproot][topic taproot] 描述符；共同签名者组规定哪些共同签名者参与，以及需要多少人签名；模板列出共同签名者可以签署的交易及其精确输出；条件规定签署每个模板前必须满足的要求；配置方案则指定验证模式、证据格式和任何问责机制。还有一些问题尚未确定，例如序列化使用 JSON 还是 TLV、现在就规定盲化验证还是等待更多实现经验、在本提案还是在 DLC 规范中规定声明见证的格式，以及后备路径是否必须带有时间锁。

  在后续讨论中，PREDGE 指出，一种名为 `statement-v0` 的证据配置方案缺少最终性标志（finality flag），这意味着共同签名者可能依据一份之后会被修正的临时见证采取行动。此外，tehiyadu 表示，策略哈希应当承诺验证器的确切语义，防止不同实现接受相同字节，却执行不同条件。Carriere 同意这两点，表示会增加最终性标志，并明确验证器规则。

## 共识变更

_这个每月栏目总结了关于改变比特币共识规则的提案和讨论。_

- **<!--continued-discussion-of-bip54-->****关于 BIP54 的后续讨论：** Antoine Riard 在 Bitcoin-Dev 邮件列表上[发帖][ar ml bip54]，介绍了他对[共识清理][topic consensus cleanup]软分叉（[BIP54][]）进展的看法。禁止剥离见证后恰好为 64 字节的交易，仍然是争议最大的规则。一项 Bitcoin Core 实现正在接受审查和测试，也是 BIP 中链接的参考实现（[Bitcoin Core #35793][]）。这个 PR 在 regtest 上启用新规则，不涉及主网激活。他还提到了 btcd 中的互操作性工作（[btcd #2537][]），并表示据他所知，libbitcoin 尚无实现。在他看来，剩余工作包括更多审查和测试，以及完善文档，让钱包了解针对 segwit 之前的脚本所提议的 2,500 次签名操作上限和 64 字节规则；激活逻辑应当留到之后再考虑。他强调这只是个人看法：如果届时社区达成一致，在 2027 年下半年开始考虑激活可能是现实的。

  Pieter Wuille [更新][pw delving timewarp lean]了他在 Delving Bitcoin 上讨论 BIP54 两条时间戳规则如何限制链长度的帖子（见[周报 #425][news425 timewarp]）。首帖现在包含工作量下界的精确公式，链接中的 Lean 代码也已证明该公式及其十进制近似值。

  Riard [回应][ar ml forwardblocks]了设计 BIP54 时提出的一项反对意见：修复[时间扭曲][topic time warp]漏洞，是否会让比特币在今后永远无法采用类似 Mark Friedenbach 的[前向区块][news16 forward]方案的共识变更。由于这项修复只是限制时间戳操纵，而非将其彻底消除，仍然可以实现一个能力大为受限的前向区块提案。他估计，修复后仍允许的 7,200 秒窗口，可以让每个难度调整周期的难度下降约 0.60%，出块速率提高大致相同的幅度，远低于原提案带来的容量增幅。Riard 还认为，即使沿用旧规则，这个思路也不合理：验证节点要先在前向链上处理一次交易，再在交易同步到兼容链时处理一次，却只能获得同一笔手续费，除非用户付两次费；未升级的节点也仍然需要下载额外数据。Riard 将提议在 BIP54 中增加一条简短脚注，说明这些理由，并请 Friedenbach 提出反驳意见。

- **<!--opt-in-replay-protection-prototype-->****选择性加入式重放保护原型：** Sjors Provoost 在 Delving Bitcoin 关于链分裂时选择性加入式重放保护的讨论中[跟进][sj delving replay]（见[周报 #420][news420 replay]），介绍了一个使用新见证版本的原型。[annex][topic annex] 的载荷以字节 0x01 开头，并通过一个 4 字节的高度指定某个区块；该输入上的每个签名都会承诺目标链上这个区块的哈希。哈希本身不出现在交易中。他估算，额外开销为 1.75 vbytes。所指定的区块必须至少已有 100 个区块的深度，与 coinbase 成熟期相同。他表示，如果算力平均分配到两条链上，最坏情况下需要等待两天才能将币拆分到两条链，因为规则只需在其中一条链上满足。他建议将这个见证版本与其他需要新见证版本的提案一起推出，例如 [CISA][topic cisa]（BIP460）、[BIP360][]，或类似 [P2TRv2][news403 pqout] 的、其密钥路径可在日后禁用的输出。

  Anthony Towns [回复][aj delving replay]说，无需新的见证版本，只需仿照 [BIP118][]，为 taproot 签名检查引入一种新的公钥编码就足够了。Provoost [回应][sj delving replay keypath]说，他考虑过这种编码，但认为这是一种取巧的做法，而且据他理解，它无法用于密钥路径花费。

  Moonsettler [质疑][ms delving replay]，在最需要这一功能的链分裂情形中，要求等待 100 个区块是否合适，并建议将这段延迟保留为可以放宽的策略规则。Provoost [回复][sj delving replay maturity]说，当币在较快的链上移动并获得确认后，较慢的链就不再需要这种保护。他还表示，预计这项规则会在有争议的硬分叉之前部署，让两条链都继承它，而且任何一方都无法轻易移除它：区块哈希只存在于签名消息中，因此移除规则意味着要修改交易序列化格式，以携带这个哈希。

- **<!--qsave-for-unmigrated-coins-->****面向尚未迁移钱币的 QSAVE：** James Tagg 在 Bitcoin-Dev 邮件列表上[发帖][jt ml qsave]，公布了 QSAVE（Quantum Secure Asset Verification and Escrow，量子安全资产验证与托管）的[五份 BIP 草案][qsave drafts]，提出一种不销毁钱币的[后量子][topic quantum resistance]过渡方案。他将其描述为 [BIP361][] 和 [Hourglass][news395 hourglass] 的替代方案。从某个执行高度起，任何类型未列入已知后量子类型注册表的输入，都会被视为尚未迁移，包括未知和未来的脚本类型；这项规则可以随时通过软分叉激活。尚未迁移的输入仍须满足其锁定脚本，还须提供第二重验证要素：要么是一份零知识证明，证明被花费的脚本和一个后量子密钥都由同一种子派生；要么是一项在截止时间之前承诺的后量子绑定。如果交易中任何尚未迁移的输入缺少这第二重验证要素，所有可花费输出就必须是恢复输出。QSAVE 不设最终失效期限（sunset），因此缺少第二重验证要素不会销毁钱币，持有人始终可以通过链上证明直接花费，无需第三方。否则，他提出通过链下“失物招领”流程处理，并将其法律和经济处理置于共识之外：一组去中心化托管人持有恢复输出，另设后备托管人和否决控制者，资金可以获得保守的 0.5% 收益，并将收益用于慈善。草案还规定了截止时间之前的水印、一个他称为 QD5 的可选 ML-DSA-87 密钥，以及用于 [BIP360][]（[P2MR][news393 p2mr]）输出的 zk-STARK 花费叶子。

- **<!--proof-of-decay-for-unmigrated-outputs-->****尚未迁移输出的衰减证明（proof-of-decay）：** bitKingAE 在 Delving Bitcoin 上[发帖][bk delving decay]，勾勒了一项方案，让那些在宽限期内未迁移、面临[量子攻击风险][topic quantum resistance]的输出（例如早期 P2PK 钱币）的金额逐渐减少。宽限期结束后，输出金额会按区块高度依照预定计划下降。减少的聪会被销毁或作为挖矿奖励发放，而不是将钱币冻结，或留给任何能够生成签名的人。帖子给出的例子是，每 50,000 个区块按较小的百分比扣减余额。Vinicius Cestari [回复][vc delving decay]提出了三点反对意见：量子攻击者可以等到宽限期结束，在衰减尚未造成太大影响时扫走暴露的输出；量子攻击能力的突然提升，可能更早就将这些输出扫空；衰减计划还会减少未采取行动的持有人的余额，包括密钥已经被盗的持有人。

- **<!--bip300-bundle-censorship-->****BIP300 取款包审查：** Ori Newman 在 Bitcoin-Dev 邮件列表上[发帖][on ml bip300]认为，拥有 26% 算力的矿工可以无限期审查[驱动链][topic sidechains]提案（[BIP300][]）中的有效取款包（withdrawal bundle）。他写道，如果这个拥有 26% 算力的矿工在自己挖出的每个区块中发送 ALARM，那么每个这样的区块都会让所有待处理取款包的得分下降 1。如果其余 74% 算力在每个区块中都为一个取款包投赞成票，在 26,300 个区块的窗口结束时，该包的预期得分为 12,624，达不到要求的 13,150。他建议禁止 ALARM 和任何其他反对票，这样就能恢复诚实多数假设：获得 51% 算力支持的取款包几乎必然通过，只有 49% 算力支持的取款包则几乎必然失败。如果现有规则是有意如此设计的，他希望 BIP 明确写出其采用的是 75% 诚实多数假设。他认为，这与比特币的安全模型存在很大差异；支持这种设计的一个理由是，算力不足 75% 的攻击者会更难窃取资金。

## 版本和候选版本

_流行比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。_

- [LND v0.21.6-beta][] 和 [v0.20.7-beta][lnd v0.20.7-beta] 是这一流行闪电网络节点实现的 0.21 和 0.20 分支的安全版本。两者都包含下文 [LND #11456][] 条目介绍的 Linux 内核漏洞 CVE-2026-98432 缓解措施。Linux 节点运营者应当升级，在主机上禁用 MPTCP 以保护其他服务，并安装已修补的内核，因为 LND 的缓解措施并未修复底层漏洞。

- [Core Lightning 26.06.10][] 是这一流行闪电网络节点实现的安全版本，修复了[双向注资][topic dual funding]、[拼接][topic splicing]、链上 [HTLC][topic htlc] 处理、访问控制和其他组件中的漏洞。安全修复的源代码已经公开，相关测试则暂未公开，以便给用户更多时间升级。项目方强烈建议升级。

- [BTCPay Server 2.4.7][] 是这一自托管支付处理器的安全版本，修复了 Anthropic 的 [OSS Scanner 项目][anthropic oss scanner]报告的 85 项安全问题，涉及付款限额、访问其他商店的数据、身份认证和资源耗尽等方面。它还修复了支付记账和可靠性方面的问题。项目方强烈建议更新，尤其是多个商户共用的服务器。

## 重大的代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #36539][] 将 GUI 导出的未签名交易和手续费追加交易恢复为 PSBTv0 格式。Bitcoin Core 32.1 使用版本 2 导出这些 [PSBT][topic psbt]，使用户无法用只支持版本 0 的工具签署它们。通过 `-signer` 配置的独立外部签名器工作流（见[周报 #138][news138 signer]）仍使用 PSBTv2，因此这些用户需要支持该格式的外部签名器，例如 HWI 2.1.0 或更高版本。

- [Bitcoin Core #35714][] 修复了一个 bug：在将区块数据或撤销数据刷入磁盘失败之后，节点仍可能更新区块索引和 UTXO 数据库。虽然失败会通知节点关闭，但处理这些写入的代码仍可能在节点停止前更新数据库。如果更新成功，数据库就可能记录一个状态，而支撑这个状态的区块或撤销数据尚未安全保存。这可能使节点的本地状态不一致，让恢复更加困难。现在，在刷盘失败的这次尝试中，代码会跳过这些数据库写入。这补充了[周报 #414][news414 flush]介绍的、针对可选索引的较早刷盘顺序保护。

- [Bitcoin Core #35492][] 修复了一个 bug：`bitcoin-wallet dump`（见[周报 #130][news130 dump]）在写出不完整的钱包导出文件后，仍可能报告成功。此前，该命令只检查能否打开目标文件，没有检测之后的写入失败，例如磁盘空间耗尽。因此，用户可能误以为导出已完成，直到尝试恢复钱包时才发现数据缺失。现在，该命令会检查文件的写入、刷盘和关闭操作，报告失败，并删除不完整的导出文件。

- [BIPs #2205][]、[#2210][bips #2210] 和 [#2212][bips #2212] 加入了三份[跨输入签名聚合][topic cisa]规范草案。[BIP458][] 规定了非交互式半聚合，将 `n` 个已有的 [BIP340][] 签名合并为 `32 × (n + 1)` 字节，而非 `64 × n` 字节。[BIP459][] 规定了 DahLIAS，这种交互式协议可以为多个密钥和消息生成一个 64 字节的聚合签名。[BIP460][] 提议将这些方案用于新的见证版本 2 输出的密钥路径花费，同时为脚本路径花费保留独立签名，并允许密钥路径输入选择退出聚合。自[周报 #417][news417 cisa]介绍该提案以来，选择退出的输入已改为使用不带特殊标记的普通 [BIP341][] 签名，让钱包在采用新输出类型时可以复用现有签名逻辑。对于包含多个参与聚合输入的交易，包括 [coinjoin][topic coinjoin] 和 [payjoin][topic payjoin]，这会降低交易重量和手续费。部署所提议的交易聚合需要软分叉。BIP460 尚未规定激活机制和参数。

- [Core Lightning #9419][] 为 `listforwards` RPC 和 `forward_event` 通知增加了可选的 `failure_reason` 字段，用于说明在本地失败的转发尝试。此前，多种不同问题使用同一个协议失败代码，运营者很难判断转发为何失败。新字段可以区分出站流动性不足、出站对等节点离线，以及待处理 [HTLC][topic htlc] 的数量或总金额达到上限等原因。

- [Core Lightning #9592][] 更新了 `xpay`（见[周报 #330][news330 xpay]）：如果某个转发节点两次返回 `unknown_next_peer`，就会在这笔支付剩余的尝试中避开该节点。此前，每次失败只会排除报告的那条通道，后续尝试可能不断选中经过同一节点的其他通道，直到支付重试超时。现在，同一节点第二次返回该失败后，`xpay` 就会通过这笔支付专用的 `askrene` 路由层将其排除。这种启发式做法可能排除可用通道，但能限制经由同一节点反复尝试。

- [LDK #5089][] 更新了强制关闭带有[锚点输出][topic anchor outputs]的通道时的手续费追加处理。如果 LDK 无法取得构建花费锚点输出的 [CPFP][topic cpfp] 子交易所需的资金，现在会单独广播承诺交易。此前，这种失败可能让两笔交易都没有广播，延迟通道资金的恢复。承诺交易本身已包含手续费，如果手续费估算较为保守，或网络需求下降，这笔手续费仍可能足以让交易确认。不过，这种后备做法不适用于[零手续费承诺交易][topic v3 commitments]，因为它们需要一个支付手续费的子交易才能被中继。这个问题由 Project Loupe 报告。

- [LND #11456][] 默认禁用多路径 TCP（MPTCP）监听器，以缓解 Linux 内核漏洞 [CVE-2026-98432][mptcp advisory]；已有演示通过 MPTCP 利用该漏洞实现远程代码执行。Go 1.24 及更高版本会在支持的 Linux 系统上默认启用这些监听器，因此，即使 LND 运营者没有显式配置 MPTCP，也可能受到影响。这项变更在 LND 的 Go 默认设置中加入 `multipathtcp=0`，堵住了已演示的、经由 LND 监听器利用漏洞的路径，但没有修复底层内核 bug。受影响的系统仍然需要安装已修补的内核。使用现有二进制文件的运营者，可以在设置环境变量 `GODEBUG=multipathtcp=0` 后重启 LND，以采用同样的缓解措施。

- [LND #11357][] 根据 [BOLTs #1357][]（见[周报 #428][news428 bolts11]）收紧了 [BOLT11][] 发票验证。它现在会拒绝重复的支付秘密值字段，而非使用第一个、忽略其余字段，避免不同解析器选择不同字段所造成的歧义。这建立在此前拒绝重复支付哈希的变更之上（见[周报 #425][news425 lnd]）。规范更新中新增的测试还发现，一些已有要求并未得到执行。现在，解码器在解析支付哈希、描述哈希、支付秘密值和接收者公钥时，会拒绝长度不正确的字段，而非将其视为不存在。此前，长度错误的接收者公钥字段可能让 LND 回退到从签名中恢复公钥。对于明确包含接收者公钥的发票，现在还要求使用 low-S ECDSA 签名；但从签名恢复公钥的情况不受此限制（见[周报 #381][news381 low-s]）。

- [LND #11413][] 加快了使用 SQLite 或 PostgreSQL 的节点在启动时清理已存储出站支付结果的速度。正常运行期间，对于每次由本地发起、已完成处理的 [HTLC][topic htlc] 尝试，节点都会保存一个结果。启动时，节点会删除不再需要的结果。此前，逐条读取和删除记录需要反复往返访问数据库，使使用远程 PostgreSQL 的繁忙节点可能花数小时完成清理。现在，清理会批量执行数据库操作，同时保留恢复待处理支付所需的结果。

- [LND #11151][] 在接受入站通道时，增加了针对承诺交易费率过高和初始余额不足的检查。LND 现在会取[三块确认费率估计值][topic fee estimation]的十倍和 100 sat/vbyte 中的较大值，拒绝高于这个值的提议费率。它还会执行 [BOLT2][] 的初始储备规则，并单独拒绝双方初始余额均未超过各自必须维持的储备额的通道。虽然承诺交易手续费由发起方支付，但过高的手续费可能耗尽其可用余额，在开通道期间浪费接收方的待处理通道容量，并在注资交易确认后留下一条无法使用的通道。这补充了[周报 #429][news429 lnd fees]介绍的最低费率检查。

- [Rust Bitcoin #7067][] 扩展了 [taproot][topic taproot] 签名哈希（sighash）辅助函数，使其可以接受可选的 [annex][topic annex]。对于脚本路径花费，还可以传入签名检查前最后执行的 [OP_CODESEPARATOR][topic OP_CODESEPARATOR] 的操作码位置。这两项都会影响签名所承诺的消息。此前，这些便捷函数假定不存在 annex，也没有执行过 `OP_CODESEPARATOR`，因此，处理这类花费的调用者必须使用更通用的 sighash 函数，才能避免生成错误的摘要。现在，辅助函数直接接受这些值，但调用者仍须自行确定分隔符位置。对于不带 annex、也没有执行过 `OP_CODESEPARATOR` 的花费，调用者可以为新参数传入 `None`，保留此前的行为。传统花费和 segwit v0 花费相关的 sighash API 变更见[周报 #427][news427 rust bitcoin]。

{% include snippets/recap-ad.md when="2026-11-10 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35793,11456,36539,35714,35492,2205,2210,2212,9419,9592,5089,11357,1357,11413,11151,7067" %}

[news406 holepunch]: /zh/newsletters/2026/05/22/#tcp-hole-punching-for-bitcoin-nodes-behind-nats
[b10c holepunch recap]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497/18
[b10c holepunch option6]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497/22
[aj holepunch goals]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497/25
[aj holepunch cves]: https://delvingbitcoin.org/t/tcp-hole-punching-for-bitcoin-nodes-behind-home-nats/2497/35
[cosigner pols del]: https://delvingbitcoin.org/t/bip-draft-co-signer-spending-policies/2955
[news412 blinded cosigners]: /zh/newsletters/2026/01/02/#building-a-vault-using-blinded-co-signers
[news364 delegation]: /zh/newsletters/2025/07/25/#chain-code-withholding-for-multisig-scripts
[cosigner pol draft]: https://github.com/lukecarriere/bip-cosigner-spending-policies/blob/468fdd1b75647432ed56c3a2b5579cbcfedaec74/bip-cosigner-spending-policies.md
[ar ml bip54]: https://groups.google.com/g/bitcoindev/c/TBBakeBK8_E
[btcd #2537]: https://github.com/btcsuite/btcd/pull/2537
[pw delving timewarp lean]: https://delvingbitcoin.org/t/bounds-on-chain-length-with-bip-54-timewarp-fixes/2899/29
[news425 timewarp]: /zh/newsletters/2026/10/02/#bounds-on-chain-length-with-bip54-time-warp-fixes
[ar ml forwardblocks]: https://groups.google.com/g/bitcoindev/c/T9s8nflvlK0
[news16 forward]: /zh/newsletters/2018/10/09/#前向区块不通过硬分叉实现链上容量增加
[sj delving replay]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792/11
[news403 pqout]: /zh/newsletters/2026/05/01/#discussion-of-a-postquantum-output-type
[news420 replay]: /zh/newsletters/2026/08/28/#discussion-on-universal-opt-in-replay-protection
[aj delving replay]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792/12
[sj delving replay keypath]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792/13
[ms delving replay]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792/14
[sj delving replay maturity]: https://delvingbitcoin.org/t/universal-opt-in-replay-protection/2792/15
[jt ml qsave]: https://groups.google.com/g/bitcoindev/c/5G38b3JL9fA
[qsave drafts]: https://www.qsave.org/legal/bip-suite
[news395 hourglass]: /zh/newsletters/2026/03/06/#hourglass-v2-update
[news393 p2mr]: /zh/newsletters/2026/02/20/#bips-1670
[on ml bip300]: https://groups.google.com/g/bitcoindev/c/7P0_BHRAYQI
[bk delving decay]: https://delvingbitcoin.org/t/a-novel-post-quantum-approach-proof-of-decay-cryptographic-half-life-for-unmigrated-dormant-utxos/2970
[vc delving decay]: https://delvingbitcoin.org/t/a-novel-post-quantum-approach-proof-of-decay-cryptographic-half-life-for-unmigrated-dormant-utxos/2970/2

[LND v0.21.6-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.6-beta
[lnd v0.20.7-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.7-beta
[Core Lightning 26.06.10]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.10
[BTCPay Server 2.4.7]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.7
[anthropic oss scanner]: https://github.com/anthropics/oss-scanner
[mptcp advisory]: https://www.openwall.com/lists/oss-security/2026/10/30/1
[LDK #5089]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5089
[news138 signer]: /zh/newsletters/2021/03/03/#bitcoin-core-16546
[news414 flush]: /zh/newsletters/2026/07/17/#bitcoin-core-34897
[news130 dump]: /zh/newsletters/2021/01/06/#bitcoin-core-19137-adds-dump-and-createfromdump-commands-to-wallet-tool
[news417 cisa]: /zh/newsletters/2026/08/07/#cisa-for-taproot-keypath-spends-bip460
[news330 xpay]: /zh/newsletters/2024/11/22/#core-lightning-7799
[news428 bolts11]: /zh/newsletters/2026/10/23/#bolts-1357
[news425 lnd]: /zh/newsletters/2026/10/02/#lnd-11190
[news381 low-s]: /zh/newsletters/2025/11/21/#bolts-1284
[news429 lnd fees]: /zh/newsletters/2026/10/30/#lnd-11373
[news427 rust bitcoin]: /zh/newsletters/2026/10/16/#rust-bitcoin-6956
