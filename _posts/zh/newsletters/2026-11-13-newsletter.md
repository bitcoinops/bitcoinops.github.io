---
title: 'Bitcoin Optech 周报 #431'
permalink: /zh/newsletters/2026/11/13/
name: 2026-11-13-newsletter-zh
slug: 2026-11-13-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报链接到防外泄签名的 BIP 草案，总结了影响旧版 Bitcoin Core 的三个漏洞的披露，介绍了挖掘 testnet5 创世区块的计划，以及对致密区块重建性能下降的调查。此外还包括我们的常规栏目：新版本和候选版本的公告，以及流行比特币基础设施软件的重大变更。

## 新闻

- **<!--draft-bips-for-anti-exfil-signing-->****防外泄签名的 BIP 草案：** Connor Avila 在 Bitcoin-Dev 邮件列表上[发帖][anti ex ml]，介绍了一项为硬件设备标准化[防外泄签名（anti-exfil）][topic exfiltration-resistant signing]的提案。由于 nonce 由签名设备选择，遭到入侵的设备可能借此泄露自己的种子。这项提案让主机也能参与 nonce 生成；已有多家制造商使用这种技术，但它一直没有标准化（见[周报 #136][news136 anti ex]）。这个话题此前已有多次讨论：Stepan Snigirev 于 2020 年首次提出了标准化防外泄签名的提案（见[周报 #87][news87 anti ex]）；Pieter Wuille 概述了可用的不同技术（见[周报 #88][news88 anti ex]）；Moonsettler 于 2024 年提出了一项防外泄协议（见[周报 #317][news317 anti ex]）；最近合并的 [BIP461][] 则提供了一种识别签名设备可能试图泄露密钥材料的方法（见[周报 #424][news424 bip461]）。

  Avila 的提案包含两份 BIP 草案。[第一份][anti ex bip]涵盖 [schnorr][topic schnorr signatures] 和 ECDSA 签名的防外泄签名，定义了一项两轮协议：主机为 nonce 生成提供自己的随机性，并检查签名设备是否确实使用了它。[第二份草案][anti ex psbt]为 [PSBT][topic psbt] 增加了三个专用的输入级字段，用来运行防外泄协议。这项提案还提供了测试向量、Python 参考实现，以及一个 libsecp256k1 的 C 模块。

  Avila 指出，Sjors Provoost 此前已发布一份涵盖单签名者 taproot 密钥路径签名的[实验性草案][anti ex sjors]。据 Avila 称，Provoost 计划让自己的实现与 Avila 的规范保持一致。最后，Avila 征求其他开发者的反馈和审查，因为他的提案尚未接受任何密码学审计。

- **<!--disclosure-of-three-vulnerabilities-in-bitcoin-core-->****Bitcoin Core 三个漏洞的披露：** Antoine Poinsot 在 Bitcoin-Dev 邮件列表上[发帖][poinsot adv ml]，公布了三份 Bitcoin Core 安全公告，涉及一个高危漏洞和两个中危漏洞，均已在 Bitcoin Core 29.2 和 30.0 中修复。根据[披露策略][disc pol]（见[周报 #306][news306 disclosures]），中危和高危漏洞会在最后一个受影响版本结束生命周期两周后披露；29.x 系列已于 10 月 27 日结束生命周期。这次披露的三个漏洞如下：

  - **<!--block-template-creation-halted-by-truc-sibling-eviction-during-reorg-->** [重组期间的 TRUC 兄弟交易驱逐导致区块模板创建中止][CVE-2025-62861]：这个高危 bug 只影响用于挖矿的节点，在某些重组之后，节点会无法创建区块模板，直到重启。当已断开区块中的交易重新进入交易池时，[TRUC][topic v3 transaction relay] 的兄弟交易驱逐（sibling eviction）仍会执行，可能将一笔交易驱逐，却留下它的后代交易。这个 bug 影响 28.0 至 29.1 版本。Niklas Gögge 于 2025 年 9 月按[负责任披露][topic responsible disclosures]流程报告了该漏洞，Greg Sanders 则在 [Bitcoin Core #33504][] 中修复了它（见[周报 #375][news375 truc]）。

  - **<!--inbound-tor-connections-wrongly-receive-whitelist-permissions-->** [入站 Tor 连接错误获得 `-whitelist` 权限][CVE-2025-62860]：如果节点的 `-whitelist` 范围包含其 Tor 守护进程的地址，这个中危 bug 就会为每个入站 [Tor][topic anonymity networks] 对等节点解除 DoS 限制和防止隐私泄露的保护；数千个可被连接的节点使用了这种配置。Martin Zumsande 和 Antoine Poinsot 于 2025 年 9 月按负责任披露流程报告了该漏洞，Zumsande 则在 [Bitcoin Core #33395][] 中修复了它。

  - **<!--block-processing-stall-via-witness-malleation-->** [通过见证熔融使区块处理停滞][CVE-2025-62859]：这个中危 bug 让最先通告某个[致密区块][topic compact block relay]的对等节点，可以使节点对该区块的处理停滞长达 10 分钟，并在某些条件下无限重复这种拖延。Eugene Siegel 于 2025 年 4 月按负责任披露流程报告了该漏洞，Greg Sanders 则在 [Bitcoin Core #32646][] 中修复了它。

  前两个漏洞的修复也包含在 Bitcoin Core 28.3 中。所有受影响的版本系列目前都已结束生命周期，仍在使用这些版本的用户应当升级到仍在维护的版本。

- **<!--testnet5-genesis-block-to-be-mined-->****即将挖掘 testnet5 创世区块：** Anthony Towns 在 Bitcoin-Dev 邮件列表上[发帖][towns tn5]，介绍了挖掘 [testnet5][topic testnet] 创世区块的计划。testnet5 是 [BIP95][] 中提出的 testnet4 替代方案（见周报 [#409][news409 testnet5] 和 [#412][news412 bip95]）。挖矿计划在主网于区块 975,744 进行下一次难度调整后开始，预计时间为 11 月 13 日。创世区块会承诺该高度或之后的某个主网区块哈希，使任何人都无法提前挖掘 testnet5 区块。testnet5 的最低难度约为 testnet4 的一百万倍，以防止网络启动后、难度调整前，大量区块被快速挖出。因此，挖掘最初的区块需要 ASIC。Towns [介绍][towns tn5 gist]了一个任何人都可以接入算力的公共矿池，让开发者没有抢先开挖的优势。

  创世区块挖出后，其具体值会替换 BIP95 中的占位值。Towns 指出，在网络可以供公众广泛使用之前，节点软件仍需加入 testnet5 参数和 BIP54 [共识清理][topic consensus cleanup]逻辑，并准备好 DNS 种子节点、水龙头和区块浏览器。

- **<!--continued-discussion-of-compact-block-reconstruction-stats-->****关于致密区块重建统计的后续讨论：** 0xB10C 在自己的 Delving Bitcoin 讨论帖中[发帖][b10c cb summary]（见[周报 #382][news382 cb]），解释了[致密区块中继][topic compact block relay]在 7 月中旬至 10 月中旬表现不佳的原因。9 月，他[报告][b10c cb sept]称，其节点只有 1% 至 5% 的区块能够在无需请求交易的情况下重建，每个区块需要请求约 100 kB 的数据。Gregory Sanders [发现][sanders cb investigation]，他的节点缺失的交易几乎全都属于 rune 铸造交易链，这些交易链比到达其他节点早几分钟到达矿池。

  Bitcoin Network Operations Collective 论坛上的调查（[一][bnoc fleet]、[二][bnoc degradation]）将这些交易链追溯到一个试图尽量降低代币铸造开销的人。每笔交易约为 100 vbytes，包含一个[支付到锚点（P2A）][topic ephemeral anchors]输入，以及 P2A 和 `OP_RETURN` 输出，支付约 10 sat 的手续费。对等节点不先通告这些交易链，就将其直接发送给节点；另一些对等节点则发送交易，花费交易链中间某个 P2A 输出，并将该输出的全部金额用作手续费。在任何接受这种交易的交易池中，它都会[替换][topic rbf]该链余下的部分。节点保留交易链还是替换交易，部分取决于哪一个先到达。交易池内容因此与矿池实际挖入区块的交易产生差异，节点不得不请求缺失的交易。

## 版本和候选版本

_流行比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。_

- [LDK v0.3-rc4][] 是 LDK 下一个主版本的第四个候选版本，接续[周报 #426][news426 ldk rc]介绍的候选版本。这个库用于构建支持闪电网络的钱包和应用。开发者在测试之前应当查阅 [API 与向后兼容性方面的变更][ldk 0.3 notes]，其中包括让此前签发的、带有支付元数据的 [BOLT11][] 发票失效。

- [LDK v0.2.8][] 和 [v0.1.14][ldk v0.1.14] 分别是这个库的 0.2 和 0.1 分支的安全版本。两者都修复了可能导致资金损失或拒绝服务（DoS）攻击的漏洞，以及下文介绍的合作关闭问题和一个路由提示处理问题。0.2.8 还修复了影响静态 [BOLT12][] 发票支付的手续费多付漏洞，以及影响 LSPS2 服务的 DoS 漏洞。

- [LND v0.21.8-beta][] 和 [v0.20.8-beta][lnd v0.20.8-beta] 是这一闪电网络节点实现的维护版本。两者都包含下文介绍的 AMP 恢复、通道注资、恢复通道强制关闭和确认提示（confirmation hint）修复。它们还修复了链路重连时转发 HTLC 的恢复问题，并包含 sweeper 和通道状态方面的修复。

## 重大的代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #36142][] 修复了通过 [Tor][topic anonymity networks] 控制端点进行命令注入的问题。控制或冒充该端点的攻击者，可以返回一个恶意的洋葱服务私钥。Bitcoin Core 随后会保存并复用这个密钥，让攻击者得以注入额外的 Tor 控制命令或参数。现在，Bitcoin Core 会在保存或复用密钥之前验证它们，并检查返回的洋葱服务 ID。如果已有的缓存密钥未通过验证，洋葱服务将不可用。删除缓存密钥并重启，会生成新的洋葱地址。

- [BIPs #2251][] 加入了 [BIP394][]，这份草案规定了此前在[周报 #419][news419 rawtr]中讨论过的 `rawtr()` 输出脚本描述符。`tr()` 从内部密钥和可选的脚本树派生 [taproot][topic taproot] 输出密钥，而 `rawtr()` 直接接受输出密钥，不施加 tweak。这样，钱包无需知道输出的内部结构，就能描述该输出。不过，`rawtr()` [描述符][topic descriptors]不能证明不存在其他花费路径。因此，软件从不受信任的来源导入这种描述符时，应当提醒用户可能存在隐藏的脚本路径。Bitcoin Core 从 24.0 版本起就已支持这个描述符（见[周报 #213][news213 rawtr]）。

- [BIPs #2347][] 更新了 [testnet5][topic testnet] 的规范草案 [BIP95][]（见[周报 #412][news412 bip95]），使拟议中的创世区块更容易通过[矿池基础设施][topic pooled mining]挖掘（见[上文的新闻条目](#testnet5-genesis-block-to-be-mined)）。对近期主网区块哈希的承诺，从 coinbase 输出的公钥字段移到了 coinbase 输入脚本中，以可读文本表示。输出则改用 `OP_RETURN`，明确标记为不可花费，并提供八字节的额外 nonce 空间。草案还允许矿工改变区块版本，以扩大可用的挖矿搜索空间。示例创世区块仍是占位值。

- [BIPs #2342][] 明确了 [BIP34][] 对 coinbase 输入脚本开头的区块高度的编码要求，适用于 [signet][topic signet] 和 [testnet4][topic testnet] 等在创世区块之后立即执行该规则的链。高度 1 至 16 必须使用单字节操作码 `OP_1` 至 `OP_16`，不带长度前缀。此前的措辞可能被理解为要求使用带长度前缀的数字。这项澄清与 Bitcoin Core 的现有行为一致。它还指出，coinbase 输入脚本仍须至少包含两个字节，因此仅有高度操作码并不足够（见[周报 #406][news406 coinbase]）。

- [Core Lightning #9610][] 修复了通道对等节点可以利用过大的 [HTLC][topic htlc] 金额触发的崩溃。对等节点提出一个金额至少约为 9,200 万 BTC 的虚假 HTLC，就会将金额字段的最高位置为 1，从而可能触发这个崩溃。在使用有符号数进行余额检查时，这个值可能被解释为负数，绕过资金是否充足的检查。随后构建承诺交易时会触发断言，终止受影响通道的子进程 `channeld`。现在，CLN 会在进行余额运算之前，拒绝超过 [BOLT1][] 规定的、以毫聪表示的 2,100 万 BTC 上限的金额。

- [LDK #5507][] 和 [#5532][ldk #5532] 修复了合作关闭时可能将不同交易的签名组合在一起的 bug。第一个 PR 确保 LDK 签署对等节点提出的交易，而不是仅仅因为提议的手续费相同，就复用另一笔关闭交易的缓存签名。第二个 PR 在异步签名器不可用之后、对等节点断开连接时，清除待处理的签名状态，防止重连后将旧的对等节点签名与新的本地提议组合起来。此前，这两种情况都可能让 LDK 提交一笔无效的关闭交易进行广播，同时将通道视为已关闭，留下需要恢复的资金。

- [LND #11492][] 修复了强制关闭后，已接收的[原子多路径支付（AMP）][topic amp]的链上恢复。此前，即使 LND 已将支付记录为已结算，仍可能找不到兑现一个未完成 [HTLC][topic htlc] 所需的原像。LND 错误地检查了发票级原像，而非为单个 AMP HTLC 存储的原像。现在，它会获取该 HTLC 的原像。这个 PR 还确保，在恢复期间再次处理已记录的自发 AMP 和 [keysend][topic spontaneous payments] HTLC 时，这些 HTLC 不会被原本针对新支付的到期检查拒绝（LND 到期检查的此前介绍见[周报 #412][news412 cltv]）。

- [LND #11479][] 修复了发布[同时开启多个通道的交易][topic payment batching]时的错误处理（见[周报 #166][news166 batch]）。此前，广播时一旦发生错误，LND 就会放弃待处理的通道，并释放为它们预留的钱包输入，即使交易已经进入网络且仍可能获得确认。现在，一旦尝试发布交易，LND 就会保留待处理通道的状态，保存监视交易和恢复通道所需的信息。如果交易无法确认，保留下来的待处理通道需要手动清理。

- [LND #11340][] 和 [#11374][lnd #11374] 为 LND 实验性的 [BOLT12 要约][topic offers]支持（见[周报 #424][news424 bolt12]）增加了要约创建和发票请求处理。第一个 PR 增加了一个处理器，根据已存储的要约验证请求，并回复已签名的发票。第二个 PR 将该处理器接入收到的[洋葱消息][topic onion messages]，并增加了 `CreateOffer` RPC 和 `lncli createoffer` 命令。不过，这个处理器尚未保留其所签发发票的状态，而结算对应支付需要这些状态。这项功能仅在开发构建中可用，并且需要额外配置。

- [LND #11480][] 修复了尝试强制关闭从[静态通道备份][topic static channel backups]恢复的通道时发生的崩溃。这类备份不包含可用的本地承诺交易，恢复需要对手方发布其承诺交易。此前，强制关闭代码路径检查了本地数据丢失，却没有检查通道是否从备份恢复，因而可能访问一笔不存在的承诺交易并触发 panic。现在，LND 会拒绝这种本地强制关闭尝试，并安全处理交易不可用的情况，包括在重启后继续此前中断的关闭流程时。

- [LND #11481][] 修复了 LND 缓存用于检查交易是否确认的扫描起始区块高度的方式。此前，攻击者可以提出一个虚假的通道注资输出，使用一笔已撤销承诺交易的 txid，却搭配不同的输出脚本。由于 LND 仅按 txid 缓存扫描起始高度，这个虚假注资请求会与跟踪已撤销承诺交易的请求共用缓存条目。无法匹配到输出的注资请求，可能将起始高度推进到已撤销交易的确认区块之后，使后续扫描漏掉它。这可能延迟 LND 发现已撤销承诺交易，以及发布对应[惩罚交易][topic ln-penalty]的时间。现在，LND 会为每一组 txid 和输出脚本分别保存起始高度。这个问题影响历史扫描，包括 Neutrino 和未启用交易索引的 Bitcoin Core 所使用的扫描。

{% include snippets/recap-ad.md when="2026-11-17 17:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="33504,33395,32646,36142,2251,2347,2342,9610,11492,11479,11340,11374,11480,11481,5507,5532" %}

[anti ex ml]: https://groups.google.com/g/bitcoindev/c/cB37_jChkEI/m/3paRGQ_IBgAJ
[news136 anti ex]: /zh/newsletters/2021/02/17/#anti-exfiltration
[anti ex bip]: https://github.com/AvilaLabs/anti-exfil/blob/main/spec/bip-anti-exfil.md
[anti ex psbt]: https://github.com/AvilaLabs/anti-exfil/blob/main/spec/bip-anti-exfil-psbt.md
[news87 anti ex]: /zh/newsletters/2020/03/04/#proposal-to-standardize-an-exfiltration-resistant-nonce-protocol
[news88 anti ex]: /zh/newsletters/2020/03/11/#exfiltration-resistant-nonce-protocols
[news317 anti ex]: /zh/newsletters/2024/08/23/#simple-but-imperfect-anti-exfiltration-protocol
[news424 bip461]: /zh/newsletters/2026/09/25/#bips-2224
[anti ex sjors]: https://github.com/Sjors/bips/pull/2/
[poinsot adv ml]: https://groups.google.com/g/bitcoindev/c/tOLTRSOz87k/m/7eiOFoHIAQAJ
[disc pol]: https://bitcoincore.org/en/security-advisories/
[news306 disclosures]: /zh/newsletters/2024/06/07/#upcoming-disclosure-of-vulnerabilities-affecting-old-versions-of-bitcoin-core
[CVE-2025-62861]: https://bitcoincore.org/en/2026/11/10/disclose-cve-2025-62861/
[CVE-2025-62860]: https://bitcoincore.org/en/2026/11/10/disclose-cve-2025-62860/
[CVE-2025-62859]: https://bitcoincore.org/en/2026/11/10/disclose-cve-2025-62859/
[news375 truc]: /zh/newsletters/2025/10/10/#bitcoin-core-33504
[towns tn5]: https://groups.google.com/g/bitcoindev/c/DmFiHeo-xRw/m/YI3cpl5vAQAJ
[towns tn5 gist]: https://gist.github.com/ajtowns/ebb148819c6028387271e6f0dce5e1da
[news409 testnet5]: /zh/newsletters/2026/06/12/#draft-bip-for-testnet5
[news412 bip95]: /zh/newsletters/2026/07/03/#bips-2196
[b10c cb summary]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/63
[news382 cb]: /zh/newsletters/2025/11/28/#stats-on-compact-block-reconstructions-updates
[b10c cb sept]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/53
[sanders cb investigation]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/56
[bnoc fleet]: https://bnoc.xyz/t/satoshi-31-0-0-peers-with-no-service-flags-and-protocol-70015-pushed-transactions-then-stopped-together-on-oct-18/193/
[bnoc degradation]: https://bnoc.xyz/t/compact-block-reconstruction-degradation-between-september-october-2026/198/

[LDK v0.3-rc4]: https://github.com/lightningdevkit/rust-lightning/tree/v0.3-rc4
[ldk 0.3 notes]: https://github.com/lightningdevkit/rust-lightning/blob/v0.3-rc4/CHANGELOG.md
[LDK v0.2.8]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.2.8
[ldk v0.1.14]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.14
[LND v0.21.8-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.8-beta
[lnd v0.20.8-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.8-beta
[LDK #5507]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5507
[LDK #5532]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5532
[news426 ldk rc]: /zh/newsletters/2026/10/09/#ldk-v0-3-rc3
[news412 cltv]: /zh/newsletters/2026/07/03/#lnd-10927
[news166 batch]: /zh/newsletters/2021/09/15/#lnd-5356
[news424 bolt12]: /zh/newsletters/2026/09/25/#lnd-11146
[news419 rawtr]: /zh/newsletters/2026/08/21/#draft-bip-for-rawtr-output-script-descriptor
[news213 rawtr]: /zh/newsletters/2022/08/17/#bitcoin-core-23480
[news406 coinbase]: /zh/newsletters/2026/05/22/#bitcoin-core-34860
