---
title: 'Bitcoin Optech 周报 #408'
permalink: /zh/newsletters/2026/06/05/
name: 2026-06-05-newsletter-zh
slug: 2026-06-05-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了使 BIP324 传输加密具备抗量子能力的若干思路，并介绍了一项为 miniscript 钱包标准化基于二维码的签名载荷的提案。此外还包括我们的常规栏目：总结关于改变比特币共识规则的提案和讨论、新版本和候选版本的公告，以及流行比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--a-postquantum-path-for-bip324-->****BIP324 的后量子路径：** Olaoluwa Osuntokun 在 Bitcoin-Dev 邮件列表上[发帖][pq bip324 ml]，介绍了他对使 [BIP324][] 具备抗量子能力所需升级的思考。BIP324 为 P2P 协议引入了[传输加密][topic v2 p2p transport]，使对等节点能够以更好的隐私性和安全性在网络上交换消息；其设计还使初始握手和全部流量在外部观察者看来都完全像随机数据。Osuntokun 认为，修改 P2P 协议不像共识变更那样需要广泛共识，因此这可能是让比特币具备抗量子能力的一个较容易的第一步。

  在提出正式 BIP 之前，Osuntokun 邀请大家讨论两个主要设计点。第一是应当使用哪一种[密钥封装机制][wiki kem]（KEM）——混合方案，还是纯后量子方案；两者都利用一种名为 Module-Lattice-based KEM（ML-KEM）的新原语。第二个设计点则是：初始握手是否仍需与随机字节串不可区分。

  对于第一点，作者指出混合方案将当前的 ECDH 算法与 ML-KEM 结合起来，可能提供更强的保障，因为当其中任一算法失效时，另一种算法仍可提供保护。事实上，虽然 ECDH 可能会被未来具备密码学意义的量子计算机（CRQC）攻破，但抗量子算法尚未经受长期实战检验，也可能因数学缺陷而失败。

  对于第二点，Osuntokun 提出了几种备选方案，以应对“握手必须与随机字节串不可区分”这一要求仍需保留的情况。第一种方案是先使用当前 BIP324 握手建立经典信道，再在该信道上协商后量子信道。另一种基于 Outer Encrypts Inner Nested Combiner（OEINC）的方法，则使用一个外层 KEM 加密另一个内层 KEM，从而一步建立后量子信道。

- **<!--discussion-of-qr-signing-payloads-for-miniscript-wallets-->****关于 miniscript 钱包二维码签名载荷的讨论：** Pyth 在 Delving Bitcoin 上[发帖][pyth delving qr]，提出了一项标准化提案，用于规范钱包协调器与隔离网络的签名设备在使用基于 [miniscript][topic miniscript] 的花费策略时，通过二维码交换的数据载荷。现有基于二维码的协议虽然能处理标准的 m-of-n 多重签名，但 miniscript 的可变策略需要当前方案尚未覆盖的额外能力。该提案定义了用于获取 xpub、注册[描述符][topic descriptors]、验证地址和签名的载荷类型。Pyth 正在向签名设备和钱包开发者征求对这些载荷设计的反馈。

## 共识变更

_关于提议和讨论变更比特币共识规则的月度部分。_

- **<!--ctv-only-vault-proof-of-concept-->****仅用 CTV 的保险库概念验证：** Ademan 在 Delving Bitcoin 上[宣布][ademan delving mccv]发布其 [CTV][topic op_checktemplateverify]（[BIP119][]）[保险库][topic vaults]项目 [MCCV][mccv]（More Complicated CTV Vault）的 0.1.0 版本。MCCV 实现了若干关于如何在无需更复杂操作码（如 `OP_VAULT`（[BIP345][]）或 [`OP_CHECKCONTRACTVERIFY`][topic matt]（[BIP443][]））的情况下，构建功能完整的保险库（比 James O'Beirne 的 [simple-ctv-vault][jamesob ctv vault] 更复杂；见[周报 #191][news191 simple vault]）的思路。具体来说，MCCV 使用一个 CTV 交易的有向无环图（DAG）来实现一个单 UTXO 保险库，该保险库可以历经多次交互，最终由保险库恢复密钥来花费。借助一个包含多种可能取款脚本的 [taproot][topic taproot] 脚本树——这些脚本具有不同的金额和[时间锁][topic timelocks]——MCCV 实现了速率限制。该脚本树中还包含存款用的 CTV 哈希，允许向保险库中增加不同金额的额外资金。MCCV 通过使用单个不断扩张和收缩的保险库 UTXO，而非一组保险库 UTXO，避开了 BIP345 和 BIP443 所要解决的一个根本问题——如何合并保险库输入。与所有基于 CTV 的保险库设计一样，可存入和取出的金额必须在创建时精确列举，这一点是 BIP345 和 BIP443 不要求的。不过，MCCV 的速率限制在多 UTXO 保险库中无法完全实现。MCCV 也可以用 `OP_TEMPLATEHASH`（[BIP446][]）来实现。

- **<!--postquantum-lightning-discussion-->****后量子闪电网络讨论：** Olaoluwa Osuntokun（roasbeef）在 Delving Bitcoin 上[发帖][oo delving ln lbl]，分层拆解了一个[后量子][topic quantum resistance]闪电网络可能会呈现的样子。Osuntokun 概述了现有后量子密码系统的全貌，以及闪电网络的各层，并尝试将不同密码系统对应到每一项所需的密码学原语上。后量子闪电网络可以保留其整体结构，但很可能必须放弃当前所依赖的单一节点密钥，因为没有任何单一的后量子密码系统或密钥能够提供所需的全部原语。Osuntokun 发现，基于格的密码学最适合某些闪电网络功能，包括密钥交换。他还指出，由于后量子密码学元素尺寸较大，继续并行使用椭圆曲线密码学可能更合理，以便在多种后量子方案之一出现弱点时提供额外安全保障。

- **<!--quantum-attack-game-theory-->****量子攻击博弈论：** Jameson Lopp 在 Delving Bitcoin 上[发帖][jl delving qag]，介绍了他关于量子攻击博弈论的[博客文章][jl qag]。Lopp 描述了这样一种情形下各类市场参与者可能拥有的激励和行为：如果一种量子计算机被造出来，并能从公钥中恢复比特币私钥。由于量子攻击者可能在无需其他大型持币者所需的工作量证明和资本投入的情况下，迅速获得大量比特币，因此他描述的各种潜在场景都具有高度不确定性。

- **<!--bip54-64-byte-transactions-and-potential-legitimate-uses-->****BIP54 的 64 字节交易及其潜在合法用途：** Jeremy Rubin 在 Bitcoin-Dev 邮件列表上[撰文][jr ml 64]，讨论了 64 字节的剥离见证交易可能具有的合法用途。[共识清理][topic consensus cleanup]（[BIP54][]）提案包含一项变更：使 64 字节的剥离见证交易在共识层面无效。该变更旨在使一类[默克尔树漏洞][topic merkle tree vulnerabilities]不再可能出现，从而让实现简化支付验证钱包以及类似的、基于区块头的支付验证方案更加安全。由于一笔 64 字节交易至多只能包含 1 个输入和 1 个 anyone-can-spend 输出，[BIP54][] 的作者此前认为不值得为这类交易提供保护。Rubin 提出了几种潜在场景，说明当前或未来的协议可能会利用这类交易。

## 版本发布和候选版本

_热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [Core Lightning 26.06][] 是这个流行闪电网络节点实现的一个主要版本。它增加了新的 `graceful`、`sendamount` 和 `xkeysend` RPC，开始弃用 `pay` 并转向 `xpay`，还增加了实验性的 [BOLT12][topic offers] 支付证明支持。更多细节见[changelog][cln 26.06 changelog]。

## 重大代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #35269][] 修复了 [MuSig2][topic musig] [PSBT][topic psbt] 签名：它将每个参与者的公开 nonce 纳入 Bitcoin Core 内部 MuSig2 签名会话标识符中。此前，如果对同一个不含 nonce 的 PSBT 多次调用 `walletprocesspsbt`，就可能生成一个新的公开 nonce，但得到相同的内部会话 ID，从而触发用于防止 nonce 重用的断言。新的会话标识符能够区分使用不同公开 nonce 的签名会话，但如果看起来同一个 nonce 被复用，仍会崩溃，以防止私钥泄露。

- [Bitcoin Core #34644][] 向 Mining IPC 接口添加了 `submitBlock` 方法（见[周报 #310][news310 mining]、[#323][news323 mining]和[#325][news325 ipc]），允许 [Stratum v2][topic pooled mining] 客户端提交一个完整组装好的区块，以供验证和处理。当某个 Stratum v2 job declarator 收到一个已解出的区块，而 Bitcoin Core 又没有相应的 `BlockTemplate` 对象时，这一功能就很有用，因为现有的 `submitSolution` 方法在这种场景下并不足够。这个新方法与 `submitblock` RPC 类似，但它返回布尔结果以及对于重复、结果不确定或无效区块的拒绝细节。与该 RPC 不同，IPC 调用方必须提交完整区块；如果存在 witness commitment，则还必须包括 coinbase witness。

- [Bitcoin Core #34198][] 修复了一个影响极老 legacy 钱包迁移失败的问题：这些钱包创建于 2011 年加入钱包最佳区块记录之前。现在，best block locator 为空的钱包可以迁移到[描述符][topic descriptors]钱包，但在迁移完成前仍需要进行一次完整的链重扫。

- [LND #10813][] 移除了对生成 [Tor][topic anonymity networks] v2 洋葱服务的支持，这种服务已在 LND 0.20 中被弃用（见[周报 #375][news375 tor]）。已弃用的 `tor.v2` 选项被移除，不过 v2 地址仍会保留在对等节点公告中，以便现有的 gossip 消息仍能被验证和重新广播。Tor v2 洋葱服务自 2021 年 10 月起就已过时；用户应改用 Tor v3。

- [Rust Bitcoin #6250][] 开始验证 coinbase 输入是否包含一个 32 字节的 witness reserved value，只要 coinbase 交易包含 witness commitment，就会执行该检查，从而让 rust-bitcoin 的区块验证与 [BIP141][] 保持一致。此前，rust-bitcoin 只有在区块中包含其他[隔离见证][topic segwit]交易时才会执行这项检查，因此它可能接受这样一种区块：coinbase 含有 witness commitment，但没有 coinbase witness reserved value。

- [BOLTs #1338][] 更新了 [BOLT2][]，要求当通道注资交易是一笔 coinbase 交易时，节点在发送 `channel_ready` 之前至少等待 100 个区块，以防矿工立即使用一个尚未成熟的 coinbase 输出来开启通道。

- [BOLTs #1326][] 更新了 [BOLT4][]，允许最终节点（而不仅仅是转发节点）返回 `invalid_onion_version`、`invalid_onion_hmac` 或 `invalid_onion_key` 错误。此前，这些错误被错误地放在一条最终节点不得使用的规则之下。该 PR 还澄清：转发节点不得像最终接收者那样处理那些已经支付过的 payment hash。

{% include snippets/recap-ad.md when="2026-06-09 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35269,34644,34198,10813,6250,1338,1326" %}

[ademan delving mccv]: https://delvingbitcoin.org/t/ctv-only-vault-concept-v0-1-0-release/2539
[jamesob ctv vault]: https://github.com/jamesob/simple-ctv-vault
[news191 simple vault]: /zh/newsletters/2022/03/16/#continued-ctv-discussion
[mccv]: https://github.com/LNHANCE-Expedition/mccv
[oo delving ln lbl]: https://delvingbitcoin.org/t/post-quantum-lightning-layer-by-layer/2479
[jl delving qag]: https://delvingbitcoin.org/t/quantum-attack-game-theory/2524
[jl qag]: https://blog.lopp.net/quantum-attack-game-theory/
[jr ml 64]: https://groups.google.com/g/bitcoindev/c/iCuq6bFKt5Y/m/MCATyQ4zAAAJ
[pq bip324 ml]: https://groups.google.com/g/bitcoindev/c/n_5WuKVYqwI/m/lBooLis3AQAJ
[wiki kem]: https://en.wikipedia.org/wiki/Key_encapsulation_mechanism
[pyth delving qr]: https://delvingbitcoin.org/t/qr-based-signing-flow-payloads-in-miniscript-context/2464
[Core Lightning 26.06]: https://github.com/ElementsProject/lightning/releases/tag/v26.06
[cln 26.06 changelog]: https://github.com/ElementsProject/lightning/blob/v26.06/CHANGELOG.md
[news310 mining]: /zh/newsletters/2024/07/05/#bitcoin-core-30200
[news323 mining]: /zh/newsletters/2024/10/04/#bitcoin-core-30510
[news325 ipc]: /zh/newsletters/2024/10/18/#bitcoin-core-30955
[news375 tor]: /zh/newsletters/2025/10/10/#lnd-10254
