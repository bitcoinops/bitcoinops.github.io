---
title: 'Bitcoin Optech Newsletter #198'
permalink: /zh/newsletters/2022/05/04/
name: 2022-05-04-newsletter-zh
slug: 2022-05-04-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 概述了关于实现 MuSig2 的一篇帖子，传达了对部分旧版 LN 实现影响的安全问题的负责任披露，讨论了通过交易信号来衡量对共识变更支持度的提案，并考察了速率限制对更高带宽效率的 LN gossip 的影响。文末照例总结了新的软件发布与候选发布，以及值得注意的比特币基础设施项目变更。

## 新闻

- **<!--musig2-implementation-notes-->****MuSig2 实现说明：** Olaoluwa Osuntokun 在 [MuSig2][topic musig] 草案 BIP（见 [Newsletter #195][news195 musig2]）下[回复][osuntokun musig2]了他与他人在 btcd 与 LND 中实现 MuSig2 时得到的经验：

  - **<!--interaction-with-bip86-->***与 BIP86 的交互：* 由 [BIP32 HD 钱包][topic bip32]且实现了 [BIP86][] 的密钥，遵循 [BIP341][] 的建议，通过对自身哈希进行微调来创建仅限密钥路径的密钥。这样可以防止该密钥被用于[多签][topic multisignature]，从而阻止参与者暗中嵌入自己控制的脚本路径支出选项并窃取全部资金。然而，如果多签参与者确实希望包含脚本路径支出选项，他们需要彼此共享未微调版本的密钥。

    Osuntokun 建议 BIP86 的实现同时返回原始密钥（内部密钥）和微调后的密钥（输出密钥），以便调用函数根据上下文选择合适的密钥。

  - **<!--interaction-with-scriptpath-spends-->***与脚本路径支出的交互：* 用于脚本路径支出的密钥有类似问题：要使用脚本路径，支出者必须知道内部密钥。因此实现应返回内部密钥，以便其他需要它的代码可以调用。

  - **<!--shortcut-for-final-signer-->***最终签名者的快捷方式：* Osuntokun 还请求澄清 BIP 中的一段描述：只有最终签名者可以使用确定性随机数或质量较低的随机源来生成其签名随机值。Brandon Black [回复][black musig2]解释了该段落的动机——他们有一个签名者难以安全地管理常规 MuSig2 会话，但可以始终被用作最终签名者。

- **<!--measuring-user-support-for-consensus-changes-->****衡量用户对共识变更支持度：** Keagan McClelland 在 Bitcoin-Dev 邮件列表[发帖][mcclelland measure]，提出与[之前的提案][bishop signal]类似的方案，旨在让交易通过信号表示其是否[支持][topic soft fork activation]某项共识规则变更。邮件线程中还讨论了若干相关的情感测量思路，但都存在问题，例如[技术上的挑战][aronesty signal parse scripts]、显著[降低][grant signal chainalysis]用户隐私、[偏向][tetrud signal favor]比特币经济的某些部分，或是使先投票者[处于不利地位][ivgi signal hodl voting]。

  与以往讨论该主题时一样，参与者普遍认为目前尚无足够能被大多数人接受的方法，来为改变比特币共识规则提供有效参考。

- **<!--ln-anchor-outputs-security-issue-->****LN 锚定输出安全问题：** Bastien Teinturier 在 Lightning-Dev 邮件列表[发布][teinturier security]了一则其此前已向 LN 实现维护者负责任披露的安全公告。该问题影响旧版 Core Lightning（开启实验特性时）和 LND。仍在使用 Teinturier 帖子中提到版本的用户强烈建议立即升级。

  在引入[锚定输出][topic anchor outputs]之前，被撤销的 [HTLC][topic HTLC] 交易仅包含一个输出，因此大多数实现只尝试领取那一个输出。LN 的锚定输出新设计允许将多个已撤销的 HTLC 输出合并到一笔交易中，但前提是实现必须领取该交易中的所有相关输出。若在 HTLC 的时间锁到期前未能领取全部输出，广播被撤销 HTLC 的一方可窃取剩余资金。Teinturier 在为 Eclair 实现锚定输出时测试了其他 LN 实现并发现了此漏洞。

  与之前一项锚定输出相关攻击（见 [Newsletter #115][news115 fee stealing]）类似，问题似乎与在保留对 `SIGHASH_ALL` 的兼容支持的同时，新增 `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY` 签名方式有关。

- **<!--ln-gossip-rate-limiting-->****LN gossip 速率限制：** Alex Myers 在 Lightning-Dev 邮件列表[发帖][myers recon]，介绍了他使用 [minisketch][topic minisketch] 集合对账来减少节点获取 LN 通道图更新时带宽消耗的研究。其方法假设所有节点对几乎全部公共通道拥有几乎相同的信息。某节点可从其完整的公共网络图生成一个 minisketch 并发送给所有对等方，对等方可用此 minisketch 找到自上次对账以来的网络更新。这与 [erlay][topic erlay] 协议在比特币 P2P 网络中仅发送最近几秒钟内（新的未确认交易）更新的拟议用法不同。

  在所有公共通道上进行对账的挑战在于要求所有 LN 节点拥有相同信息。任何会导致节点之间通道图长期不一致的过滤，都会造成带宽开销或协议失败。Matt Corallo [建议][corallo recon]可以将 erlay 模式应用到 LN——若仅同步新信息，就无需担心持久差异，尽管过滤规则差异过大仍可能导致带宽浪费或对账失败。Myers 担心仅发送更新需要维护大量状态——Bitcoin Core 节点需为每个对等方维护独立状态以避免重复发送更新。而在全部通道上对账可以免除逐节点状态，大幅简化 gossip 管理实现。

  截至本文撰写时，关于这些方案权衡的讨论仍在继续。

## 发布与候选发布

*面向热门比特币基础设施项目的新发布与候选发布。请考虑升级到新版本，或帮助测试候选版本。*

- **<!--n8-->**[BTCPay Server 1.5.1][] 发布，这是一款流行的自托管支付处理软件的新版本，新增主页仪表盘、新的 [transfer processors][btcpay server #3476] 功能，并支持自动批准拉取付款和退款。

- **<!--n9-->**[BDK 0.18.0][] 发布，这是该钱包库的新版本，包含其依赖 rust-miniscript 的[关键安全修复][minimalif bug]，并带来若干改进和小幅错误修复。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]上值得注意的变更。*

- [Bitcoin Core #18554][] 默认阻止同一 Bitcoin Core 钱包文件被用于多个完全独立的区块链。当 Bitcoin Core 在扫描新区块以查找其钱包相关交易时，会在钱包中记录该区块头的哈希。此 PR 检查最近一次记录的扫描区块是否与当前使用的区块链具有相同的[创世区块][genesis block]。若否，则返回错误，除非设置了新的 `-walletcrosschain` 配置选项。该变更可防止专用于某网络（例如 mainnet）的钱包被用于另一网络（如 testnet），从而降低意外资金损失或隐私泄露风险。此变更仅影响 Bitcoin Core 内部钱包的用户，其他比特币钱包软件不受影响。

- [Bitcoin Core #24322][] 是将共识引擎抽离为独立库的更大工作的一部分。此 PR 新增了 `libbitcoinkernel` 库，列出了 `bitcoin-chainstate` 可执行文件（首次出现在 [Bitcoin Core #24304][] 中）需要链接的所有源文件。其中包括一些乍看与共识无关的文件，揭示了当前 Bitcoin Core 共识引擎的依赖关系。后续工作将继续把共识逻辑模块化，并逐步将这些文件移出 `libbitcoinkernel`。

- [Bitcoin Core #21726][] 允许即便在修剪模式下也能维护 coinstats 索引。Coinstats 在每个区块记录 UTXO 状态的 MuHash 摘要，从而可验证 [assumeUTXO][topic assumeutxo] 状态。此前该功能仅保证在存储完整区块链的归档全节点可用。此合并的 PR 使启用 `-coinstatsindex` 配置选项的修剪全节点也能提供该信息。

- [BDK #557][] 新增 “最旧优先” 找零选择算法。目前共有四种算法：Branch and Bound（BnB）、Single Random Draw（SRD）、最旧优先和最大优先。默认情况下 BDK 先使用 BnB，若无解则回退到 SRD。

- [LDK #1425][] 增加对[大额通道][topic large channels]（“wumbo 通道”）的支持，可用于高价值支付。

- [LND #6064][] 新增 `bitcoind.config` 与 `bitcoind.rpccookie` 配置选项，用于指定非默认的配置文件与 RPC cookie 路径。

- [LND #6361][] 更新 `signrpc` 方法，可使用 [MuSig2][topic musig] 算法创建签名。详细信息见该合并 PR 中的[文档][lnd6361 doc]。请注意，MuSig2 支持仍属实验性质，若 MuSig2 拟议 BIP 有重大调整（见 [Newsletter #195][news195 musig2]），实现也可能随之变更。

- [BOLTs #981][] 从规范中移除了对 LN 网络图查询及结果进行压缩的能力。由于压缩功能几乎未被使用，移除它可降低 LN 实现的复杂度和依赖数量。


{% include references.md %}
{% include linkers/issues.md v=2 issues="18554,24322,21726,6064,557,981,6361,1425,3476,24304" %}
[tetrud signal favor]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020350.html
[ivgi signal hodl voting]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020364.html
[aronesty signal parse scripts]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020354.html
[grant signal chainalysis]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020355.html
[bishop signal]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020346.html
[news115 fee stealing]: /zh/newsletters/2020/09/16/#stealing-onchain-fees-from-ln-htlcs
[osuntokun musig2]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020361.html
[news195 musig2]: /zh/newsletters/2022/04/13/#musig2-proposed-bip
[black musig2]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020371.html
[mcclelland measure]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020344.html
[teinturier security]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-April/003561.html
[myers recon]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-April/003551.html
[corallo recon]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-April/003556.html
[genesis block]: https://en.bitcoin.it/wiki/Genesis_block
[btcpay server 1.5.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.5.1
[minimalif bug]: https://bitcoindevkit.org/blog/miniscript-vulnerability/
[bdk 0.18.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.18.0
[lnd6361 doc]: https://github.com/guggero/lnd/blob/93e069f3bd4cdb2198a0ff158b6f8f43a649e476/docs/musig2.md
