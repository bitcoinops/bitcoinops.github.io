---
title: 'Bitcoin Optech 周报 #426'
permalink: /zh/newsletters/2026/10/09/
name: 2026-10-09-newsletter-zh
slug: 2026-10-09-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报链接到一份 BIP 草案，让对等节点可以自行选择在 v2 P2P 传输中使用的单字节消息类型 ID；总结了关于 BIP 是否应在带标签哈希的标签中包含自身编号的讨论；并介绍了一项无需共识变更、用于私密链上转账的元协议提案。此外还包括我们的常规栏目：新版本和候选版本的公告，以及流行比特币基础设施软件的重大变更。

## 新闻

- **<!--dynamic-one-byte-message-type-ids-for-bip324-->****BIP324 的动态单字节消息类型 ID：** Anthony Towns 在 Bitcoin-Dev 邮件列表上[发帖][towns set324alias]，介绍了一份 BIP 草案，让每个对等节点都可以为自己通过 [v2 P2P 传输][topic v2 p2p transport]发送的消息，选择单字节的消息类型 ID。[BIP324][] 按一张固定的表分配单字节 ID，因此每一种新消息都需要一个经过全局协调的条目（见[周报 #392][news392 bip324 ids]），否则就必须使用完整的 12 字节名称。借助新的 `set324alias` 消息，节点可以在连接建立时通告自己的别名，让 P2P 层的新消息可以无需这种协调就部署和试验。Towns 还[指出][towns set324alias savings]，仅传输 ping 的连接最多可节省 66% 的空间，典型连接则约为 5%；不过，在部署那些尚无现成单字节 ID 的新消息之前，节省的空间为零。

- **<!--discussion-of-conventions-for-tagged-hash-tags-in-bips-->****关于 BIP 中带标签哈希的标签惯例的讨论：** Fabian Jahr 在 Bitcoin-Dev 邮件列表上[发帖][jahr tagged hash]，询问使用 [BIP340][] 带标签哈希的 BIP，是否应在标签中包含 BIP 编号。BIP324、340、352、374 和 445 都这么做，而 BIP327 和 BIP341 使用的是“TapLeaf”这样的描述性名称。编号可以保证唯一性，但在草案获得编号时更改其标签，会让已有实现和测试向量失效。Jahr 将自己的 [DahLIAS][news415 dahlias] 草案（BIP459）改成带编号的形式后，就遇到了这个问题。Sjors Provoost [回复][provoost tagged hash]说，BIP138 包含了自身编号，重新生成测试向量的开销很小。

- **<!--proposal-for-onchain-private-bitcoin-transfers-with-no-consensus-changes-->****无需共识变更的私密链上比特币转账提案：** Misha Komarov 在 Delving Bitcoin 上[发帖][shield del]，介绍了一种构建在比特币之上的新元协议提案，称为 Shielded Bitcoin，可以在无需共识变更的情况下实现私密转账。Komarov 与 Clara Shikhelman、Aleksei Moskvin 最近共同发表了一篇介绍该协议的完整[论文][shield paper]。

  这项元协议提案的目标是私密地转移比特币，既不暴露转账金额，也不暴露交易双方。它希望无需受信任的运营者、交互，或对参与方持续在线的依赖，就能做到这一点。Shielded Bitcoin 需要一套向元协议转入和转出资金的机制（peg-in / peg-out）。这套流程会在一篇即将发布的配套论文中详细介绍，但 Komarov 指出，它将基于一种称为 PIPEs 的见证加密方案（见[周报 #393][news393 pipes]）。

  Shielded Bitcoin 的转账基于一种名为票据（note）的所有权对象，其作用类似于比特币的 UTXO。票据是加密记录，保存金额和接收者的密钥材料等信息。转账时，Alice 会发布一笔比特币交易，其中包含新的加密票据、每张待花费票据对应的唯一编号（称为作废标识（nullifier）），以及一份证明，证明这些票据存在、她有权花费它们，而且输入与输出的总金额相等。这些证明由一个称为索引器（indexer）的外部程序验证，它还会确保这些票据此前未被花费。如果证明成立，新票据就会加入列表，作废标识则会被记为已使用。任何人都可以运行索引器，因此验证证明无需依赖中心化服务。

  这个元协议是非托管的。钱包从单个种子派生出不同的密钥，每个密钥都有特定用途，例如花费密钥、用于查看收款的只读密钥，以及用于查看付款的只读密钥。只有有效的花费密钥才能授权转移票据；矿工、索引器或外部观察者等第三方都无法窃取资金。

  Komarov 还概述了外部观察者能看到哪些信息，例如创建了多少张票据、手续费、发布数据的大小和时间，以及发生了一次隐蔽转账这一事实。他介绍了其中的限制和取舍，例如需要一次性的初始化仪式（setup ceremony），只要至少有一方诚实参与，所声称的安全性就成立；还有，进入和退出协议会留下可见痕迹。他还将这个设计与其他链上隐私协议提案作了比较，包括 [coinjoin][topic coinjoin]、[payjoin][topic payjoin]、使用[客户端验证][topic client-side validation]的 Shielded CSV（现名 Glass Coins），以及设计最接近、但使用自己区块链的 Zcash。

  在后续讨论中，ZmnSCPxj 指出，外部服务可以减少资源受限的设备在恢复资金时需要扫描的数据，但如果将查看密钥（viewing key）交给该服务，就会产生类似 Electrum 的隐私损失。他还询问，单方转出是否需要将 SPV 证明表达为见证加密方案的一个条件。共同作者 Clara Shikhelman 回复说，转出使用固定面额，所有关于转出的信息都会在即将发布的论文中详细介绍。

## 版本和候选版本

_流行比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。_

- [Bitcoin Core 32.0rc3][] 是这一主流全节点实现下一个主版本的候选版本。已有一份[测试指南][bcc32 testing]可供参考。

- [Core Lightning 26.06.9][] 是这一流行闪电网络节点实现的安全版本，修复了通道重建、[拼接][topic splicing]、[HTLC][topic htlc] 处理和访问控制等方面的漏洞。它还修复了 26.06.8 中的一个回归问题：对等节点发送普通 [gossip][topic channel announcements]、ping 和[洋葱消息][topic onion messages]时，可能被错误限流，从而延迟通道消息。虽然安全修复的测试暂未公开，以增加据此构造可用的漏洞利用代码的难度，但源代码现在就可以获取。项目方强烈建议升级。

- [LDK v0.3-rc3][] 是这一用于构建支持闪电网络的钱包和应用的库下一个主版本的第三个候选版本。它为待处理的[拼接][topic splicing]增加了 [RBF][topic rbf] 手续费追加，并支持在同一次拼接中同时增加和移除资金。它还会默认协商[锚点通道][topic anchor outputs]，并要求应用显式接受入站通道。升级会让此前签发的、带有支付元数据的 [BOLT11][] 发票失效。开发者在测试之前应当查阅 [API 与向后兼容性方面的变更][ldk 0.3 notes]。

- [LDK v0.2.7][] 和 [v0.1.13][ldk v0.1.13] 是这一用于构建支持闪电网络的钱包和应用的库的 0.2 和 0.1 分支的安全版本。两者都包含下文介绍的通道重建资金盗窃漏洞修复，以及基于 Electrum 的同步中的 DoS 修复。0.2.7 还包含下文介绍的 [LSPS2][BLIP52] 金额验证和陈旧通道状态修复。0.1.13 也修复了由无效 [HTLC][topic htlc] 触发的通道管理器反序列化失败，这个问题此前已在 0.2.6 中修复。

- [BTCPay Server 2.4.5][] 是这一自托管支付处理器的安全版本。为了防止服务器端请求伪造，它现在默认禁止闪电网络连接、[LNURL][topic lnurl]、发票通知和 webhooks 所使用的出站 HTTP 请求访问私有网络中的目标。它还收紧了发票和退款权限，并加快了发票创建。配套的 Docker 变更将 Tor 改为需要主动启用，现有部署也包括在内，同时移除了几个无人维护的集成。建议管理员升级并查阅[部署变更][btcpay 2.4.5 announcement]。

## 重大的代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #36277][] 修复了一处可能泄露[交易来源隐私][topic transaction origin privacy]的问题，影响的是需要主动启用的实验性私密广播功能（见周报 [#388][news388 private broadcast] 和 [#425][news425 private broadcast]）。此前，交易通过网络传回节点时，会取消尚未完成的初始私密广播尝试。控制了一个私密广播对等节点的攻击者，可以延迟在该连接上请求交易，同时通过另一条连接将交易中继回疑似发起该交易的节点，从而利用这一行为。如果节点随后关闭了那条尚待完成的私密连接，而没有响应请求，攻击者就能推断该节点是交易的发起者。现在，即使交易已经传播开来，Bitcoin Core 仍会通过 Tor 或 I2P 完成全部三次初始私密广播尝试，同时允许后续重试在适当时候停止。

- [Bitcoin Core #36365][] 修复了[基于交易池的手续费估算器][topic fee estimation]的两个问题（见[周报 #420][news420 fee estimation]）。此前，如果交易池估算器不可用，组合估算器就会返回错误，即使原有的基于确认的估算器有有效估计值。现在，它会回退到后者的估计值，而在两者都可用时，仍然选择较低值。这个 PR 还防止在重启后交易池加载失败时立即使用基于交易池的估算器。此前，保存下来的健康状况统计可能让空交易池被视为健康，从而产生异常偏低的手续费估计值。它还将 `estimatesmartfee` RPC 的 `fee_rate_estimator` 默认值从 `none` 改为 `auto`，并拒绝无法识别的值。

- [Bitcoin Core #36338][] 修复了其 [BIP352][] [静默支付][topic silent payments]实现中的一个 bug：当交易包含一个经过修改、但仍符合共识规则的 P2PKH 输入时，钱包可能漏掉支付（见[周报 #425][news425 silent payments]）。攻击者可以在输入的 `scriptSig` 中插入一个无效签名，以及一个包含不同公钥的条件分支，而不使交易无效。此前，Bitcoin Core 使用虚拟签名检查器来执行 `scriptSig`；这个检查器会接受无效签名，执行该分支并提取错误的公钥，从而可能让扫描器漏掉支付。修复后，它会在 `scriptSig` 中查找一个有效的压缩公钥，其 HASH160 与被花费输出中承诺的哈希相符。这项实现尚未集成到钱包中。

- [Bitcoin Core #32895][] 通过记录最后一个打开钱包的客户端的版本和所支持的功能，为未来自动升级钱包作准备。没有这项跟踪，钱包升级后再用旧版 Bitcoin Core 打开，随后再次升级，就可能混用新旧钱包记录。例如，旧版可能按旧格式创建新记录，而新版会以为钱包已经升级，跳过迁移。新的元数据会让未来的版本识别这些升级、降级、再升级的情形，并执行必要的迁移。它还会单独记录最后一个解密钱包的客户端的功能，因为某些升级需要访问私钥。

- [Core Lightning #9582][] 将 v26.06.8 中包含安全性和可靠性修复的 77 个提交（见[周报 #424][news424 cln release]）移植到了 master 分支。一项修复防止在[拼接][topic splicing]完成后强制关闭通道时，广播过时的承诺交易；这笔交易可能已经被后续通道更新撤销，使对手方可以通过[惩罚][topic ln-penalty]领取资金。另一项修复在处理链上 [HTLC][topic htlc] 时，同时按脚本和金额匹配输出。此前，支付哈希和到期时间相同、但金额不同的 HTLC 可能被混淆，导致 CLN 让入站 HTLC 失败，而对应的出站 HTLC 仍可在链上兑现。这个 PR 还修复了一处权限提升漏洞：获准调用 `makesecret` RPC 的调用者可以派生 master rune 的密码学秘密值，伪造不受限制的 RPC 授权令牌。现在，CLN 会禁止派生这个保留的秘密值。其他修复涉及与 [gossip][topic channel announcements] 相关的 DoS 风险、[双向注资][topic dual funding]处理、拼接的 [RBF][topic rbf] 处理、[锚点][topic anchor outputs]手续费计算、[多路径支付][topic multipath payments]处理、rune 验证和黑名单、[BOLT11][] 和 [BOLT12][topic offers] 消息处理、洋葱路由，以及 REST API 的资源耗尽漏洞。

- [Eclair #3390][] 和 [#3388][eclair #3388] 补上了[双向注资][topic dual funding]和[拼接][topic splicing]时防范过高手续费的漏洞（见[周报 #423][news423 eclair fees]）。第一个 PR 防范的是遭到入侵的 Bitcoin Core 后端：交易由后端构建，密钥则由 Eclair 持有；后端可能虚报手续费或操纵交易输出，让 Eclair 签署手续费高于预期的交易。现在，Eclair 会独立核实实际手续费，并确保重建的注资交易符合预期金额。第二个 PR 防止恶意通道对等节点在 Eclair 向双向注资或拼接的替换交易投入资金时，强加过高的 [RBF][topic rbf] 费率。现在，Eclair 会拒绝超过本地计算上限的提议，除非对等节点通过[购买流动性][topic liquidity advertisements]支付手续费。

- [LDK #5057][] 修复了一处可能让恶意通道对等节点窃取转发 [HTLC][topic htlc] 金额的漏洞。重连时，对等节点可以在 `channel_reestablish` 消息中谎称，自己漏掉了一份其实已经通过 `revoke_and_ack` 确认的承诺。LDK 可能错误地接受这种说法，签署一笔新的有效承诺交易，却没有将其记入 `ChannelMonitor`。随后，对等节点可以将这笔交易发布到链上。如果 LDK 接着结算了这笔转发支付，就可能无法兑现对应的入站 HTLC，即使它知道原像。这让恶意对等节点可以在 HTLC 到期后收回这些资金。现在，LDK 仅在尚未收到对等节点确认时允许重传承诺，否则就强制关闭通道。

- [LDK #5042][] 修复了一个 bug：LSP 处理 [LSPS2][BLIP52] [即时通道][topic jit channels]支付时可能损失资金。此前，LSP 信任付款方洋葱载荷中指定的转发金额，却没有核实入站 HTLC 的金额。恶意付款方可以发送较少的资金，却要求更大的出站支付，让 LSP 用自己的资金补足差额。现在，LSPS2 的 `htlc_intercepted` 处理函数会核实，所请求的出站金额不超过实际入站 HTLC 金额。如果不满足这个条件，LDK 会在开通道或转发资金之前，将 HTLC 失败响应传回。

- [LDK #5046][] 修复了一个 bug：如果转发节点重启时使用的 `ChannelManager` 状态比 `ChannelMonitor` 更旧，就可能损失资金。虽然 LDK 在这种情况下会正确地强制关闭通道，但它可能错误地将一个出站 [HTLC][topic htlc] 视为从未纳入下游通道的承诺交易，并向上游对等节点返回对应入站 HTLC 的失败响应。下游对等节点随后可以在链上兑现出站 HTLC，造成 LDK 自行承担损失。现在，LDK 会在强制关闭之前，检查此前受阻的监控器更新中哪些已经应用，确保将已纳入下游通道承诺交易的 HTLC 留给监控器处理，而不是错误地向上游返回失败。

- [LDK #5028][] 在与支持这一功能的对等节点开启新的[未公告通道][topic unannounced channels]时，默认只通过 SCID 别名转发。这避免了通过发票，或使用真实 SCID 的转发探测暴露通道的注资输出。此前，应用必须启用 `negotiate_scid_privacy` 设置，这项设置现已移除。如果对等节点不支持或不接受，协商仍会回退到没有这种保护的通道。现有通道保持已协商的行为。

- [LND #11290][] 修复了构建带有[盲化支付路径][topic rv routing]的 [BOLT11][] 发票时的一个溢出 bug（见[周报 #315][news315 lnd blinded]）。此前，LND 使用 32 位算术汇总隐藏跳的转发手续费，在相对较低的手续费下就可能溢出（约 4,295 msat 或 4,295 ppm）。这会让发票通告的手续费低于隐藏跳实际收取的手续费，可能使收款方收到的金额小于发票金额，从而导致支付失败。现在，LND 使用带溢出检查的 64 位算术计算总手续费，并排除手续费超过发票格式限制的路径。

{% include snippets/recap-ad.md when="2026-10-13 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="36277,36365,36338,32895,9582,3390,3388,5057,5042,5046,5028,11290" %}

[towns set324alias]: https://groups.google.com/g/bitcoindev/c/YjrkzS_Sjes
[news392 bip324 ids]: /zh/newsletters/2026/02/13/#bips-2092
[towns set324alias savings]: https://groups.google.com/g/bitcoindev/c/YjrkzS_Sjes/m/JHCPpVWaBAAJ
[jahr tagged hash]: https://groups.google.com/g/bitcoindev/c/VQVNZOR3-kg
[news415 dahlias]: /zh/newsletters/2026/07/24/#draft-bip-for-full-aggregation-of-bip340-signatures
[provoost tagged hash]: https://groups.google.com/g/bitcoindev/c/VQVNZOR3-kg/m/OHPZw92DCQAJ
[shield del]: https://delvingbitcoin.org/t/shielded-bitcoin-private-transfers-on-the-bitcoin-l1/2912
[shield paper]: https://www.allocinit.xyz/uploads/shielded-bitcoin.pdf
[news393 pipes]: /zh/newsletters/2026/02/20/#bitcoin-pipes-v2-bitcoin-pipes-v2
[Bitcoin Core 32.0rc3]: https://bitcoincore.org/bin/bitcoin-core-32.0/test.rc3/
[bcc32 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/32.0-Release-Candidate-Testing-Guide
[Core Lightning 26.06.9]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.9
[LDK v0.3-rc3]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.3-rc3
[ldk 0.3 notes]: https://github.com/lightningdevkit/rust-lightning/blob/v0.3-rc3/CHANGELOG.md
[LDK v0.2.7]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.7
[LDK v0.1.13]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.13
[BTCPay Server 2.4.5]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.5
[btcpay 2.4.5 announcement]: https://blog.btcpayserver.org/btcpay-server-2-4-5/
[ldk #5057]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5057
[ldk #5042]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5042
[ldk #5046]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5046
[ldk #5028]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5028
[BLIP52]: https://github.com/lightning/blips/blob/master/blip-0052.md
[news388 private broadcast]: /zh/newsletters/2026/01/16/#bitcoin-core-29415
[news425 private broadcast]: /zh/newsletters/2026/10/02/#bitcoin-core-36312
[news420 fee estimation]: /zh/newsletters/2026/08/28/#bitcoin-core-34075
[news425 silent payments]: /zh/newsletters/2026/10/02/#bitcoin-core-35301
[news424 cln release]: /zh/newsletters/2026/09/25/#core-lightning-26-06-8
[news423 eclair fees]: /zh/newsletters/2026/09/18/#eclair-3376
[news315 lnd blinded]: /zh/newsletters/2024/08/09/#lnd-8735
