---
title: 'Bitcoin Optech 周报 #429'
permalink: /zh/newsletters/2026/10/30/
name: 2026-10-30-newsletter-zh
slug: 2026-10-30-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报介绍了一项让多方钱包创建静默支付交易的协议，总结了对影响旧版 Core Lightning 的一个拒绝服务漏洞的负责任披露，并说明了 Bitcoin Core 针对容易发现的漏洞更新后的安全策略。此外还包括我们的常规栏目：Bitcoin Stack Exchange 精选问答、新版本和候选版本的公告，以及流行比特币基础设施软件的重大变更。

## 新闻

- **<!--silent-payments-for-multiparty-wallets-->****多方钱包的静默支付：** Oleksandr Kurbatov 在 Delving Bitcoin 上[发帖][sp multi del]，介绍了一项在[静默支付][topic silent payments]交易中使用多方输入的协议。由于缺少安全性证明，[BIP352][] 不建议使用这类输入。这项协议让多方发送者可以将各签名者提供的份额加权求和，计算出 ECDH 份额，同时提供一份称为 AggDLEQ 的聚合 [DLEQ][topic dleq] 证明，证明这个 ECDH 份额确实是从输入密钥正确派生的。该提案适用于 [FROST][BIPs #2070] 和 [MuSig2][topic musig] 等多种多方协议。

  这项协议分为两轮。协调器提供上下文，其中包含签名者集合、签名协议的系数和 tweak、密钥材料、交易，以及会话 ID。第一轮中，每个签名者生成两个随机 nonce，并将 AggDLEQ 所需的消息发回协调器，例如根据自己的密钥片段计算出的 ECDH 份额，以及 nonce 承诺。协调器利用这些消息计算合并后的 ECDH 份额和一个挑战。第二轮中，每个签名者根据收到的挑战生成自己贡献的证明部分。如果响应正确，协调器就将所有响应聚合成一份兼容 [BIP374][] 的证明。

  Kurbatov 表示，这项协议无需修改 BIP352、BIP374、BIP375，或 MuSig2 和 FROST 签名协议，也不需要新的 PSBT 字段，因为 AggDLEQ 消息只通过钱包的协调器通道在签名者之间交换。他说，包含安全性证明的论文正在内部审阅中，但也指出，论文声称遭到控制的签名者和协调器无法伪造证明或签名，这一结论依赖一项假设，而该假设所涉及问题的求解难度仍未确定。

- **<!--cln-self-referential-channel-announcement-dos-disclosure-->****CLN 自引用通道公告 DoS 漏洞披露：** Nishant Bansal 在 Delving Bitcoin 上[发帖][cln selfref dos]，披露了影响 Core Lightning（CLN）25.02 至 26.04 版本的一个拒绝服务漏洞。CLN 从未检查过[通道公告][topic channel announcements]中的两个节点 ID 是否不同，因此，将同一个节点列为通道两端的自引用（self-referential）公告可以通过验证，并先写入磁盘上的 gossip 存储，再加载到内存中的通道图。加载时，同一个未知节点会被添加两次，触发 `gossipd` 中禁止重复节点的断言，导致节点崩溃。已存储的消息随后会让节点每次重启都再次崩溃，直到运营者手动将其移除；仅升级并不会移除这条消息。

  攻击者只需为一个自己控制的 2-of-2 输出注资，并使用这些密钥和一个新的节点密钥签署公告，因此开销仅限于链上手续费。更早的 CLN 版本会接受并中继这类公告，而不会崩溃，所以它们可以将公告传播给攻击者无法直接连接的脆弱节点。

  Bansal 使用一个针对 gossip 的模糊测试目标发现了这个 bug，后来在 [Core Lightning #9115][] 中提出了该测试目标。这个漏洞于 4 月按[负责任披露][topic responsible disclosures]流程报告，并通过 [Core Lightning #9082][] 在 [CLN 26.04.1][cln 26.04.1] 中修复（见[周报 #403][news398 cln 26041]）；修复后，会拒绝任何 `node_id_1` 不严格小于 `node_id_2` 的公告。[BOLTs #1333][] 将同样的接收方要求加入了 [BOLT7][]，此前该规范只要求发送方按顺序排列 ID。仍在使用受影响版本的运营者应当升级到最新版本。

- **<!--bitcoin-core-security-policy-update-->****Bitcoin Core 安全策略更新：** Antoine Poinsot 在 Bitcoin-Dev 邮件列表上[发帖][poinsot policy ml]，表示 Bitcoin Core 已针对被归类为容易发现的漏洞修改了[安全策略][core security policy]（见[周报 #306][news306 disclosure]），例如只需向大语言模型输入简单提示就能发现的漏洞。项目收到的这类 bug 报告有所增加，而这些 bug 可能被他人再次发现，或从未公开说明用途的修复中推断出来。现在，Bitcoin Core 会将修复回移到所有仍在维护的版本分支，尽快发布补丁版本，并同时发布安全公告，不再等待下一个主版本，也不再遵循原策略按严重程度规定的披露禁发期。本期重大代码变更栏目介绍的三个漏洞（[Bitcoin Core #36665][]、[#36667][bitcoin core #36667] 和 [#36669][bitcoin core #36669]）都按这个新类别披露。它们的修复在 32.0 打上标签之后才合并，因此 32.0 从未正式发布，这些修复改随 [Bitcoin Core 32.1][]（下文介绍）以及 31.2、30.4 和 29.5 发布。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者们寻找问题答案时首先会去的地方之一；有闲暇时，他们也会在这里帮助好奇或困惑的用户。在这个每月栏目中，我们会重点介绍自上次更新以来发布的一些高票问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--why-does-bitcoin-use-both-a-transaction-id-and-a-witness-transaction-id-->** [为什么比特币同时使用交易 ID 和见证交易 ID？]({{bse}}131077)
  Pieter Wuille 解释说，[segwit][topic segwit] 将签名和其他具有熔融性的数据移入见证，而 txid 不包含见证，这样预签名的未确认交易链就能继续有效。因此，输入仍然引用 txid。此外，区块还会承诺 wtxid，使节点在收到见证数据遭篡改的区块时，可以将其永久拒绝，而无需重新处理对等节点提供的每一种变体。后来，[BIP339][] 出于类似的拒绝服务防护考虑，将 wtxid 的使用扩展到了交易中继。

- **<!--how-to-sign-a-musig-with-bitcoin-core-->** [如何使用 Bitcoin Core 签署 MuSig？]({{bse}}131086)
  Ava Chow 解释说，[MuSig2][topic musig] 签名需要两轮，因此每个钱包都必须处理 [PSBT][topic psbt] 两次。第一次添加钱包的公开 nonce；等到所有 nonce 都已加入后，再对合并后的 PSBT 进行第二次处理，添加钱包的局部签名，最后由 `finalizepsbt` 生成交易。提问者发布了一个使用 Bitcoin Core 创建 MuSig2 地址并从中花费的[示例][bc musig2]。

- **<!--what-changed-in-bitcoin-p2p-protocol-version-70017-compared-to-70016-->** [比特币 P2P 协议版本 70017 相比 70016 有哪些变化？]({{bse}}131080)
  Ava Chow 解释说，[BIP434][] 分配了这个新版本号，因为它引入了一种在 `version` 握手期间交换的新 `feature` 消息。这种消息让对等节点可以在连接存续期间通告并协商可选功能，取代以往为每个新功能提升协议版本号或定义专用消息的做法（见[周报 #386][news386 bip434]）。Bitcoin Core 已于今年早些时候实现了该消息并提升版本号（见[周报 #410][news410 bip434]），两者都随下文介绍的 [Bitcoin Core 32.1][] 发布。

## 版本和候选版本

_流行比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。_

- [Bitcoin Core 32.1][] 是这一主流全节点实现的最新主版本。32.0 虽然已打上标签，但因最后一刻发现的问题，未完成正式发布。这个版本包含下文介绍的三项安全修复。其他变更包括基于交易池的[手续费估算][topic fee estimation]、默认使用 [PSBT][topic psbt]v2、导出仅观察钱包，以及更快的区块验证。已有的交易索引和交易输出花费者索引仍然兼容，但若想节省磁盘空间，就必须重建这些索引。详情和升级注意事项见[发布说明][bcc32.1 rn]。29.x 及更早版本已经结束生命周期，将不再获得更新。

- [Bitcoin Core 31.2][] 是这一主流全节点实现的维护版本，包含与 32.1 相同的三项安全修复。它还将 [BIP323][] 为矿工保留的额外 nonce 空间所用的版本位，从 [BIP9][] 未知软分叉警告的检查范围中排除（见[周报 #409][news409 bip323]），将 `-privatebroadcast` 队列限制为最多 10,000 笔交易，并定期压实 chainstate 数据库。详情见[发布说明][bcc31.2 rn]。

- [Bitcoin Core 30.4][] 是此前一个主版本系列的维护版本，包含与 32.1 相同的三项安全修复和 BIP323 警告变更，并移除了一个 DNS 种子节点。详情见[发布说明][bcc30.4 rn]。

- [Bitcoin Core 29.5][] 是此前一个主版本系列的维护版本，包含与 32.1 相同的三项安全修复，并移除了一个 DNS 种子节点。详情见[发布说明][bcc29.5 rn]。

- [Eclair 0.14.6][] 是这一闪电网络节点实现的安全版本，包含下文介绍的[拼接][topic splicing]强制关闭修复，以及[即时（on-the-fly）注资][topic jit channels]的手续费跟踪修复。由于恶意对等节点可以利用其中部分已修复的问题，项目方强烈建议升级。

- [LND v0.21.5-beta][lnd0215] 和 [v0.20.6-beta][lnd0206] 是这一流行闪电网络节点实现的维护版本，接续[周报 #428][news428 releases]介绍的候选版本。两者都包含下文介绍的承诺交易费率修复，还修复了解析 TLV 记录时分配过多内存和 SQL 数据库死锁的问题，并加快了使用 SQL 后端的节点在启动时的清理速度。

## 重大的代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #36665][] 修复了一个[内存耗尽漏洞][core tcp oom]，已连接的对等节点可以利用它让运行在 Windows、macOS 或 BSD 上的节点崩溃。虽然 Bitcoin Core 会在某个对等节点的接收队列过大时暂停从该节点读取数据，但其 `select()` 套接字后端仍会监视异常条件。对等节点可以发送 TCP 紧急数据（urgent data），触发更多读取，绕过队列限制。现在，只有在某个套接字启用读取时，才会监视其异常条件。Linux 使用另一种套接字后端，不受影响。

- [Bitcoin Core #36667][] 新增了一项超时限制：如果节点为某个对等节点维护的发送缓冲区连续超过上限达 20 分钟以上，就断开与该对等节点的连接，以缓解[内存无限增长][core paused send oom]的问题。即使超过这个上限，Bitcoin Core 仍会继续将部分交易公告加入队列。通常，ping 超时最终会断开读取缓慢的对等节点，但声称使用早于 [BIP31][] 的协议版本的对等节点可以避开这一点。这让恶意对等节点可以一直保持连接，使队列中的公告逐渐累积。无论对等节点使用哪个协议版本，新的超时限制都会生效。使用 `-blocksonly` 选项的节点受到的影响小得多。

- [Bitcoin Core #36669][] 修复了一处[撤销文件溢出][core undo overflow]问题，它可能损坏重组时断开区块所需的数据。由于撤销数据（undo data）可能大于对应的区块数据，撤销文件可能超过 4 GiB，使其 32 位偏移量回绕，从而覆盖先前的数据。之后发生的重组可能让节点停止运行，需要使用已修复的版本重新索引才能恢复。这项修复将文件偏移量扩展为 64 位，并在 Windows 上使用 64 位文件定位调用；在 Windows 上，即使没有重组，超过 2 GiB 也可能让节点停止运行。利用这个漏洞需要挖出数千个特制区块。若要造成数据损坏，还需让这些区块在目标节点的区块文件中处于精确的位置，然后触发重组。披露公告认为，这在实践中不可行。运行在 32 位系统上，或使用 FAT32 存储区块的节点仍然受影响。

- [BIPs #2130][] 加入了 [BIP139][] 草案“钱包元数据导出格式”，规定了用于导出钱包账户及其[输出脚本描述符][topic descriptors]、签名者信息、[标签][topic wallet labels]、交易、钱币和 [PSBT][topic psbt] 的 JSON 格式（见[周报 #399][news399 metadata]）。这套格式可以在钱包之间转移元数据，并恢复仅靠种子备份无法找回的信息。规范禁止在主网导出文件中包含花费私钥或助记词种子，因此这些导出文件需要与独立的密钥备份配合使用。

- [Core Lightning #9627][] 更新了 `xpay`，在选择支付路由之前，就考虑 [BOLT4][] 对支付洋葱路由信息规定的 1,300 字节上限。此前，即使成功找到了路径，也可能因所选路径超过上限而无法构造洋葱包。这可能导致支付失败，尽管较短的路径或许可以成功。现在，`xpay` 会先计算接收方的最终载荷或发票的[盲化路径][topic rv routing]占用空间后还剩多少空间，再通过 askrene 的 `getroutes` RPC 新增的 `maxhops` 参数，将相应的跳数上限传给 askrene。askrene 的寻路开销计算也会为每一跳增加惩罚值，以优先选择较短的路由。

- [Eclair #3417][] 和 [#3419][eclair #3419] 改进了[拼接交易][topic splicing]尚未确认时的强制关闭处理（见[周报 #427][news427 eclair splicing]）。对于非零确认通道，Eclair 现在会选择满足以下条件的最新一笔承诺交易：其注资交易已确认，或已在 Eclair 所用 Bitcoin 后端的交易池中。当新区块到达或拼接交易发布时，会重新评估这一选择。它还会将未确认的注资祖先交易纳入锚点 [CPFP][topic cpfp] 的手续费计算，并在较早注资状态对应的、未被撤销的远端承诺交易获得一次确认后，开始领取其输出。新增的 `require-confirmed-inputs-for-splicing` 设置默认启用，要求对等节点在拼接时提供已确认的输入，并阻止 Eclair 在上一次拼接确认之前发起下一次拼接。这些变更还确保：如果 Eclair 在切换到另一笔承诺交易后，此前发布的本地承诺交易才确认，Eclair 仍能识别它。此前，Eclair 可能未能领取自己的余额和 [HTLC][topic htlc] 输出。

- [Eclair #3416][] 修复了一个 bug：对等节点可以反复获得[即时注资][topic jit channels]，却不支付约定的[流动性广告][topic liquidity advertisements]手续费。此前，对等节点可以拒绝原本用于抵扣这些手续费的支付，但 Eclair 仍可能完成流动性购买。现在，Eclair 会标记未足额付费的购买，并阻止该对等节点继续使用从未来支付中扣费的方式（`from_future_htlc`）购买流动性。结算[多路径支付][topic multipath payments]的其他部分不会清除这个标记。被标记的对等节点计入现有的可疑对等节点数量上限；一旦达到上限，就会全局禁用这种支付方式。重启、运营者干预，或在注资交易发布前中止交易，都会清除标记。

- [LDK #5314][] 修复了[洋葱消息][topic onion messages]转发中的一处隐私泄露，它可能将[未公告通道][topic unannounced channels]与其链上注资输出关联起来。攻击者可以根据某个输出在区块链上的位置，推导出一个候选的短通道 ID（SCID）。通过连接到疑似通道两端的节点，并经由它们向自己发回一条洋葱消息，攻击者可以利用这个 SCID 识别两者之间的通道。收到消息就能确认该输出与这些节点之间的关联。现在，LDK 在转发洋葱消息时，拒绝将未公告通道的真实 SCID 解析为通道；SCID 别名仍然可用。这补充了[周报 #426][news426 ldk5028]介绍的 HTLC 转发隐私保护。

- [LDK #5412][] 修复了用于[即时通道][topic jit channels]的 [LSPS2][BLIP52] 服务端中的一个拒绝服务 bug。此前，在原请求仍待处理时，客户端可以重复提交相同的请求 ID。每个重复请求都会增加整个服务的待处理请求计数，并替换已存储的条目。计数达到 1,000 个请求的上限后，LSP 就会拒绝其他客户端的请求，尽管实际需要处理的请求远少于这个数量。现在，重复 ID 会被拒绝，既不会增加计数，也不会替换原请求。

- [LND #11164][] 将消息格式更新为符合最新的 [taproot gossip 提案][bolts #1059]，推进了其 gossip-v2 实现；该提案将让节点可以[公告和验证 taproot 通道][topic channel announcements]。签名交换消息现在包含注资交易 ID，用来区分不同的注资尝试，为[拼接][topic splicing]作准备；消息还分别携带节点密钥和注资密钥对应的 [MuSig2][topic musig] 局部签名。这些变更也修正了手续费和容量字段的编码，并保留值为默认值的可选字段。这可以让消息经过解码和重新编码之后，被签名的字节保持不变，从而避免签名验证失败。

- [LND #11373][] 和 [#11380][lnd #11380] 在开通道和更新手续费期间，一致地执行 LND 已有的 253 sat/kw 承诺交易最低费率限制。此前，设置 `max-commit-fee-rate-anchors=1` 会将费率上限设为 1 sat/vbyte，相当于 250 sat/kw，略低于最低值。通道可以按这个费率开启，但在发起方提高费率之前，无法承载 [HTLC][topic htlc]，因为后续的承诺更新会拒绝这个费率。现在，LND 会将本地提出的开通道费率提高到最低值，并拒绝低于最低值的入站提议。它还会在记录或发送手续费更新之前，检查收到和发出的更新是否符合最低费率要求，而非直到签署承诺交易时才拒绝它们。LND 会尝试提高已有的、以低于最低费率开启的通道的费率，但如果发起方无力承担涨幅，这些通道仍然无法承载 HTLC。

- [BTCPay Server #7744][] 和 [#7748][btcpay server #7748] 修复了商户授权应用 API 密钥时的两个错误。商户取消勾选的可选权限仍可能被授予。此外，应用还可以请求一项限定在其他店铺的权限，使授权采用那个范围，而非商户选择的店铺。这些修复会保留商户对权限的选择，先移除应用提供的店铺范围，再按商户选择的店铺设置权限范围。这些变更影响密钥签发环节，接续[周报 #428][news428 btcpay7684]介绍的权限执行修复。此前签发的密钥仍然保留原有权限；如果它们授予了非预期的访问权限，可能需要撤销。

{% include snippets/recap-ad.md when="2026-11-03 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2070,36665,36667,36669,2130,9627,3417,3419,3416,5314,5412,11164,1059,11373,11380,7744,7748,9082,9115,1333" %}

[sp multi del]: https://delvingbitcoin.org/t/silent-payments-for-multiparty-wallets/2960
[Bitcoin Core 32.1]: https://bitcoincore.org/bin/bitcoin-core-32.1/
[bcc32.1 rn]: https://bitcoincore.org/en/releases/32.1/
[Bitcoin Core 31.2]: https://bitcoincore.org/bin/bitcoin-core-31.2/
[bcc31.2 rn]: https://bitcoincore.org/en/releases/31.2/
[news409 bip323]: /zh/newsletters/2026/06/12/#bitcoin-core-34779
[Bitcoin Core 30.4]: https://bitcoincore.org/bin/bitcoin-core-30.4/
[bcc30.4 rn]: https://bitcoincore.org/en/releases/30.4/
[Bitcoin Core 29.5]: https://bitcoincore.org/bin/bitcoin-core-29.5/
[bcc29.5 rn]: https://bitcoincore.org/en/releases/29.5/
[Eclair 0.14.6]: https://github.com/ACINQ/eclair/releases/tag/v0.14.6
[lnd0215]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.5-beta
[lnd0206]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.6-beta
[core tcp oom]: https://bitcoincore.org/en/2026/10/28/disclose-tcp-oom/
[core paused send oom]: https://bitcoincore.org/en/2026/10/28/disclose-fpausesend-oom/
[core undo overflow]: https://bitcoincore.org/en/2026/10/28/disclose-undo-overflow/
[LDK #5314]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5314
[LDK #5412]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5412
[BIP31]: https://github.com/bitcoin/bips/blob/master/bip-0031.mediawiki
[BLIP52]: https://github.com/lightning/blips/blob/master/blip-0052.md
[news399 metadata]: /zh/newsletters/2026/04/03/#draft-bip-for-a-wallet-backup-metadata-format
[news428 releases]: /en/newsletters/2026/10/23/#releases-and-release-candidates
[news426 ldk5028]: /zh/newsletters/2026/10/09/#ldk-5028
[news428 btcpay7684]: /en/newsletters/2026/10/23/#btcpay-server-7684
[news427 eclair splicing]: /zh/newsletters/2026/10/16/#eclair-3396
[cln selfref dos]: https://delvingbitcoin.org/t/cln-self-referential-channel-announcement-dos-disclosure/2974
[cln 26.04.1]: https://github.com/ElementsProject/lightning/releases/tag/v26.04.1
[news398 cln 26041]: /zh/newsletters/2026/05/01/#core-lightning-26-04-1
[poinsot policy ml]: https://groups.google.com/g/bitcoindev/c/70VSp_ARD5Q
[core security policy]: https://bitcoincore.org/en/security-advisories/
[news306 disclosure]: /zh/newsletters/2024/06/07/#upcoming-disclosure-of-vulnerabilities-affecting-old-versions-of-bitcoin-core
[bc musig2]: https://learningbitcoin.blockchaincommons.com/18_3_Using_Bitcoin_With_MuSig2/
[news386 bip434]: /zh/newsletters/2026/01/02/#peer-feature-negotiation
[news410 bip434]: /zh/newsletters/2026/06/19/#bitcoin-core-35221
