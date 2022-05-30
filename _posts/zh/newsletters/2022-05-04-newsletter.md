---
title: 'Bitcoin Optech Newsletter #198'
permalink: /zh/newsletters/2022/05/04/
name: 2022-05-04-newsletter-zh
slug: 2022-05-04-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了一篇关于应用 MuSig2 的文章，转述了一个影响一些旧的 LN 实现的安全问题的披露，讨论了一个通过交易信号来衡量对共识变更的支持的提案，并研究了速率限制对更多带宽效率的闪电网络 gossip 的影响。此外，还包括我们的常规部分，总结新的软件版本和候选版本，以及流行的比特币基础设施项目中值得注意的变更。

## 新闻
- **MuSig2 的应用说明：** Olaoluwa Osuntokun [回复][osuntokun musig2] 了[Newsletter #195][news195 musig2] 中提到的 [MuSig2][topic musig] 的 BIP 草案，并附上了他和其他人为 btcd 和 LND 所做的实现说明。

  - *与 BIP86 的交互：* 由实施 BIP86 的 [BIP32 HD 钱包][topic bip32]创建的密钥遵循 [BIP341][] 的建议，通过对自身的哈希值进行调整来创建仅有密钥路径的密钥。这有助于防止密钥被用于[多签][topic multisignature]，多签可能会允许一个参与者秘密地包括他们控制的脚本路径支出选项，使他们有能力窃取所有资金。然而，如果多签参与者有意要包括一个脚本路径支出选项，他们需要相互分享他们的密钥的未调整版本。

    Osuntokun建议 BIP86 的实现同时返回原始密钥（内部密钥）和调整后的密钥（输出密钥），以便调用函数可以使用适合其上下文的任何一个。

  - *与脚本路径支出的交互：* 与脚本路径支出一起使用的密钥有一个相关连的问题：为了使用脚本路径，支出者必须知道内部密钥。同样，这就需要实现者返回内部密钥，这样它就可以在其他需要它的代码中使用。

  - *最终签名者的捷径：* Osuntokun 还希望澄清 BIP 中的一个部分，该部分描述了最终签名人（而且只有最终签名人）如何使用确定性随机性或质量较低的随机性来源来生成他们的签名随机数。Brandon Black [回答][black musig2]说，他们有一个签字人，他很难安全地管理一个常规的 MuSig2 签字会话，但他们却能一直将其作为最终签字人。

- **衡量用户对共识变更的支持：** Keagan McClelland 在 Bitcoin-Dev 邮件列表中[发布][mcclelland measure]了一个提案，与之前的[提案][bishop signal]类似，通过交易发出信号，表明他们是否[支持][topic soft fork activation]对共识规则的特定改变。在该主题中，还讨论了几个相关的情绪测量想法，但似乎都有问题，如[技术][aronesty signal parse scripts]上的挑战，大大[降低][grant signal chainalysis]了用户的隐私，[有利于][tetrud signal favor]比特币经济的某些部分而不是其他，或[惩罚][ivgi signal hodl voting]早期投票者而不是那些等待参与共识形成的人。

    就像以前讨论这个话题时一样，当它涉及到改变比特币的共识规则的决定时，似乎任何建议的方法都不会产生一个足以被大多数讨论者赞同的结果。

- **LN 锚定输出安全问题：** Bastien Teinturier 在 Lightning-Dev 邮件列表中[发布][teinturier security]了他之前向闪电网络实现的维护者披露的安全问题的公告。该问题影响了旧版本的 Core Lightning（启用了实验性功能）和 LND。强烈建议仍在使用 Teinturier 的帖子中提到的版本的人进行升级。

  在实现[锚定输出][topic anchor outputs]之前，被撤销的 [HTLC][topic HTLC] 交易只包含一个输出，所以许多实现只试图要求该单一输出。LN 的锚定输出的新设计允许将多个被撤销的 HTLC 输出合并到一个交易中，但这只有在实现者认领交易中的所有相关输出时才是安全的。任何在 HTLC 时间锁定到期时还没有被认领的资金都可能被广播撤销的 HTLC 的一方窃取。Teinturier 对 Eclair 的锚定输出的实现使他能够测试其他 LN 的实现并发现该漏洞。

  与之前与锚定输出有关的攻击一样（见 [Newsletter #115][news115 fee stealing]），问题似乎与增加对 `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY` 的签名支持但同时仍然保留了对 `SIGHASH_ALL` 的签名的支持有关。


- **LN gossip 速率限制：** Alex Myers 在 Lightning-Dev 邮件列表中[发布][myers recon]了他的研究，即，使用基于 [minisketch][topic minisketch] 的集合调节来减少节点用于学习 LN 通道图更新的带宽。他的方法假设所有的对等节点都有几乎所有相同的公共通道的信息。然后，一个对等节点可以从其完整的公共网络图中生成一个 minisketch，并将其发送给所有的对等节点，这些对等节点可以使用 minisketch 来查找自其最后一次调节以来对网络的任何更新。这与通过 [erlay][topic erlay] 协议对比特币 P2P 网络使用 minisketch 的方案不同，后者只发送过去几秒钟的更新（新的未确认交易）。

  在所有公共通道上进行调节的一个挑战是，它要求所有 LN 节点保持相同的信息。任何在节点之间的通道图视图中产生持续差异的过滤都会导致带宽开销或协议失败。Matt Corallo [建议][corallo recon]，这个问题可以通过将 erlay 模型应用于 LN 来解决——如果只有新的信息被同步，就不会有持久性差异的担忧，尽管过滤规则的巨大变化仍然可能导致带宽浪费或调节失败。Myers 担心的是只发送更新信息所需的状态跟踪量——Bitcoin Core 节点为它的每个对等节点保持一个单独的状态，以避免重新发送之前发送到该节点的更新信息。在所有通道上进行调节的替代方案消除了对每个对等节点状态的需要，大大简化了 gossip 管理的实施。

  在撰写本摘要时，关于这些方法中隐含的权衡的讨论正在进行。

## 新版本和候选版本

*主流的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本*。

- [BTCPay Server 1.5.1][] 是这个流行的自托管支付处理软件的新版本，其中包括一个新的主页面仪表板，一个新的[转移处理器][btcpay server #3476]功能，以及允许支付和退款的自动批准的能力。

- [BDK 0.18.0][] 是这个钱包库的一个新版本。它包括一个来自它的一个依赖项的[关键安全修复][minimalif bug]，即 rust-miniscript 库。它还包括一些改进和小错误的修复。

## 代码和文档的重大变更
*本周内，[Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Lightning BOLTs][bolts repo] 出现的重大变更。*

- [Bitcoin Core #18554][] 默认情况下防止同一个 Bitcoin Core 钱包文件被用于多个完全独立的区块链上。当 Bitcoin Core 扫描一个新区块的交易影响到它的一个钱包时，它会在钱包中记录该区块头的哈希值。这个 PR 检查最近记录的扫描区块是否与当前使用的区块链是同一个[创世区块][genesis block]的后代。如果不是，会返回一个错误，除非新的 `-walletcrosschain` 配置选项被设置。这可以防止用于一个网络（如 mainnet）的钱包被用于另一个网络（如 testnet），减少意外的金钱损失或隐私泄露的风险。这只影响到 Bitcoin Core 内部钱包的用户，其他比特币钱包软件不受影响。

- [Bitcoin Core #24322][] 是一个更大的工作的一部分，其通过创建一个库来使用 Bitcoin Core 的共识代码，然后逐步修剪模块，使该库更加简约，从而提取出一个共识引擎。也就是说，这个 PR 引入了一个 `libbitcoinkernel` 库，包括了 `bitcoin-chainstate` 可执行文件（在 [Bitcoin Core #24304][] 中引入）需要链接的所有源文件。这个列表包括了一些在逻辑上可能与共识无关的文件，说明了 Bitcoin Core 的共识引擎目前的依赖性。未来的工作将把共识从代码库的其他部分模块化，从 `libbitcoinkernel` 的源代码列表中删除这些文件。

- [Bitcoin Core #21726][] 增加了保持 coinstats 索引的能力，即使在修剪的节点上。Coinstats 包括每个区块的 UTXO 状态的 MuHash 摘要，这允许验证 [AssumeUTXO][topic assumeutxo] 状态。以前，这只保证在存档的完整节点上可用——那些在区块链上存储每一个区块的节点。当启用 `-coinstatsindex` 配置选项时，这个合并的 PR 也使这些信息对修剪过的完整节点（那些在验证后一段时间内删除区块的节点）可用。

- [BDK #557][] 增加了最老硬币优先选择算法。现在有四种硬币选择算法。分支与边界（BnB），单次随机抽取（SRD），最老优先，和最大优先。默认情况下，如果 BnB 没有找到解决方案，BDK 将使用 BnB 和 SRD 作为退路。

- [LDK #1425][] 增加了对[大通道][topic large channels]（"wumbo 通道"）的支持，这些通道支持高额支付。

- [LND #6064][] 增加了新的 `bitcoind.config` 和 `bitcoind.rpccookie` 配置选项，以指定配置和 RPC cookie 文件的非默认路径。

- [LND #6361][] 更新了 `signrpc` 方法，使其能够使用 [MuSig2][topic musig] 算法创建签名。详情请见本合并 PR 中添加的[文档][lnd6361 doc]。请注意，对 MuSig2 的支持是试验性的，可能会发生变化，特别是如果对 MuSig2 的拟议 BIP 有重大改变的话（见 [Newsletter #195][news195 musig2]）。

- [BOLTs #981][] 从规范中删除了关于 LN 网络图的查询和结果被压缩的能力。人们认为压缩功能并没有被使用，放弃支持可以减少 LN 实现的复杂性和依赖的数量。

{% include references.md %}
{% include linkers/issues.md v=2 issues="18554,24322,21726,6064,557,981,6361,1425,3476,24304" %}
[tetrud signal favor]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020350.html
[ivgi signal hodl voting]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020364.html
[aronesty signal parse scripts]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020354.html
[grant signal chainalysis]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020355.html
[bishop signal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020346.html
[news115 fee stealing]: /en/newsletters/2020/09/16/#stealing-onchain-fees-from-ln-htlcs
[osuntokun musig2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020361.html
[news195 musig2]: /en/newsletters/2022/04/13/#musig2-proposed-bip
[black musig2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020371.html
[mcclelland measure]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020344.html
[teinturier security]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-April/003561.html
[myers recon]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-April/003551.html
[corallo recon]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-April/003556.html
[genesis block]: https://en.bitcoin.it/wiki/Genesis_block
[btcpay server 1.5.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.5.1
[minimalif bug]: https://bitcoindevkit.org/blog/miniscript-vulnerability/
[bdk 0.18.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.18.0
[lnd6361 doc]: https://github.com/guggero/lnd/blob/93e069f3bd4cdb2198a0ff158b6f8f43a649e476/docs/musig2.md
