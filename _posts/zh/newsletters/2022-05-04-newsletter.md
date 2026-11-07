---
title: 'Bitcoin Optech Newsletter #198'
permalink: /zh/newsletters/2022/05/04/
name: 2022-05-04-newsletter-zh
slug: 2022-05-04-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 概述了一篇关于实现 MuSig2 的帖子，转述了一项安全问题的负责任披露——该问题影响部分旧版 LN 实现，讨论了通过交易信号来衡量对共识变更支持程度的提案，并考察了速率限制对带宽效率更高的 LN gossip 有何影响。此外还包括本刊的固定栏目：总结新的软件发布与候选发布，以及热门比特币基础设施项目的值得注意的变更。

## 新闻

- **<!--musig2-implementation-notes-->****MuSig2 实现说明：** Olaoluwa Osuntokun [回复][osuntokun musig2]了 [Newsletter #195][news195 musig2] 中提到的 [MuSig2][topic musig] 草案 BIP，附上了他和其他人为 btcd 与 LND 所做实现中的笔记：

  - **<!--interaction-with-bip86-->***与 BIP86 的交互：* 实现了 [BIP86][] 的 [BIP32 HD 钱包][topic bip32] 所创建的密钥，会遵循 [BIP341][] 的建议，用密钥自身的哈希对它进行微调，从而生成只使用密钥路径的密钥。这有助于防止该密钥被用于[多重签名][topic multisignature]——否则某个参与者可能暗中加入一个自己控制的脚本路径支出选项，从而窃取全部资金。然而，如果多重签名参与者确实希望包含脚本路径支出选项，他们需要彼此共享未经微调的密钥。

    Osuntokun 建议 BIP86 的实现同时返回原始密钥（内部密钥）和微调后的密钥（输出密钥），以便调用函数根据上下文选择合适的密钥。

  - **<!--interaction-with-scriptpath-spends-->***与脚本路径支出的交互：* 用于脚本路径支出的密钥有类似问题：要使用脚本路径，支出者必须知道内部密钥。因此实现也应返回内部密钥，以便其他需要它的代码可以使用。

  - **<!--shortcut-for-final-signer-->***最终签名者的快捷方式：* Osuntokun 还就 BIP 中一段描述请求澄清，该段说明最终签名者（且只有最终签名者）可以使用确定性随机数或质量较低的随机源来生成签名随机数。Brandon Black [回复][black musig2]解释了该段落的动机——他们有一个签名者很难安全管理常规的 MuSig2 签名会话，但他们总能把它当作最终签名者使用。

- **<!--measuring-user-support-for-consensus-changes-->****衡量用户对共识变更的支持：** Keagan McClelland 在 Bitcoin-Dev 邮件列表[发帖][mcclelland measure]，提出了一项与[之前的提案][bishop signal]类似的方案，让交易通过信号表示自己是否[支持][topic soft fork activation]某项共识规则变更。帖子讨论中还提出了若干相关的意见测量思路，但似乎都有问题，例如[技术上的挑战][aronesty signal parse scripts]、显著[降低][grant signal chainalysis]用户隐私、[偏向][tetrud signal favor]比特币经济的某些部分而损害其他部分，或是让早投票者相对于等待参与共识形成的人[处于劣势][ivgi signal hodl voting]。

  与以往讨论该主题时一样，似乎没有任何一种建议的方法能得出一个结果，足以让大多数讨论参与者在决定是否改变比特币共识规则时予以重视。

- **<!--ln-anchor-outputs-security-issue-->****LN 锚定输出安全问题：** Bastien Teinturier 在 Lightning-Dev 邮件列表[发布][teinturier security]了一则公告，内容是他此前已向 LN 实现维护者负责任披露的一个安全问题。该问题影响旧版 Core Lightning（开启实验特性时）和 LND。仍在使用 Teinturier 帖子中所提版本的用户，强烈建议升级。

  在实现[锚定输出][topic anchor outputs]之前，被撤销的 [HTLC][topic HTLC] 交易只包含一个输出，因此许多实现也只尝试领取那一个输出。LN 锚定输出的新设计允许把多个已撤销的 HTLC 输出合并进一笔交易，但只有在实现领取了该交易中所有相关输出时，这样做才安全。任何在 HTLC 时间锁到期时仍未被领取的资金，都可能被广播那笔已撤销 HTLC 的一方窃走。Teinturier 为 Eclair 实现锚定输出的工作，让他得以测试其他 LN 实现并发现了这个漏洞。

  与之前一项与锚定输出有关的攻击（见 [Newsletter #115][news115 fee stealing]）类似，该问题似乎与在新增对用 `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY` 签名的支持的同时，仍保留对用 `SIGHASH_ALL` 签名的旧有支持有关。

- **<!--ln-gossip-rate-limiting-->****LN gossip 速率限制：** Alex Myers 在 Lightning-Dev 邮件列表[发帖][myers recon]，介绍了他关于用基于 [minisketch][topic minisketch] 的集合对账来减少节点获知 LN 通道图更新所消耗带宽的研究。他的方法假设所有对等方对几乎全部相同的公共通道拥有几乎相同的信息。某个对等方可以从其完整的公共网络图生成一个 minisketch，发送给它的所有对等方，这些对等方就能用该 minisketch 找到自上次对账以来网络上的任何更新。这与通过 [erlay][topic erlay] 协议把 minisketch 用于比特币 P2P 网络的拟议用法不同：后者只发送最近几秒内的更新（新的未确认交易）。

  在全部公共通道上进行对账的挑战之一是，它要求所有 LN 节点保持相同的信息。任何会让节点之间的通道图视图长期存在差异的过滤，都会带来带宽开销或导致协议失败。Matt Corallo [建议][corallo recon]把 erlay 模式应用到 LN——如果只同步新信息，就不必担心持久差异，不过过滤规则差异过大仍可能造成带宽浪费或对账失败。Myers 则担心只发送更新需要维护的状态量——Bitcoin Core 节点会为每个对等方维护独立的状态，以避免重复发送此前已发给该节点的更新。而在全部通道上进行对账就无需针对每个对等方保存状态，大幅简化了 gossip 管理的实现。

  截至撰写本摘要时，关于这些方案各自权衡的讨论仍在进行。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- **<!--n8-->**[BTCPay Server 1.5.1][] 发布，这是一款流行的自托管支付处理软件的新版本，新增主页仪表盘、新的 [transfer processors][btcpay server #3476] 功能，并支持自动批准拉取付款和退款。

- **<!--n9-->**[BDK 0.18.0][] 发布，这是该钱包库的新版本，包含来自其依赖项 rust-miniscript 库的[关键安全修复][minimalif bug]，并带来若干改进和小幅错误修复。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]上值得注意的变更。*

- [Bitcoin Core #18554][] 默认阻止同一 Bitcoin Core 钱包文件被用于多个完全独立的区块链。当 Bitcoin Core 在扫描新区块以查找其钱包相关交易时，会在钱包中记录该区块头的哈希。此 PR 检查最近一次记录的扫描区块与当前使用的区块链是否源自同一个[创世区块][genesis block]。若否，则返回错误，除非设置了新的 `-walletcrosschain` 配置选项。该变更可防止专用于某网络（例如 mainnet）的钱包被用于另一网络（如 testnet），从而降低意外资金损失或隐私泄露风险。此变更仅影响 Bitcoin Core 内部钱包的用户，其他比特币钱包软件不受影响。

- [Bitcoin Core #24322][] 属于一项更大工作的一部分：抽离出共识引擎。做法是先创建一个原样使用 Bitcoin Core 共识代码的库，再逐步裁剪模块，让该库更加精简。具体来说，此 PR 引入了 `libbitcoinkernel` 库，划出 `bitcoin-chainstate` 可执行文件（在 [Bitcoin Core #24304][] 中引入）链接时需要引用的所有源文件。这份清单包含一些逻辑上似乎与共识无关的文件，恰好说明了 Bitcoin Core 共识引擎目前的依赖关系。后续工作会把共识与代码库的其余部分模块化分离，将这些文件从 `libbitcoinkernel` 的源文件清单中移除。

- [Bitcoin Core #21726][] 新增了在修剪节点上也能维护 coinstats 索引的能力。Coinstats 包含每个区块处 UTXO 状态的 MuHash 摘要，可用来验证 [assumeUTXO][topic assumeutxo] 状态。此前只保证归档全节点（即存储区块链上每个区块的节点）能提供该信息。这个已合并的 PR 还让修剪过的全节点（即在验证区块后过一段时间将其删除的节点）在启用 `-coinstatsindex` 配置选项时也能获得该信息。

- [BDK #557][] 新增“最旧优先”选币算法。目前共有四种选币算法：Branch and Bound（BnB）、Single Random Draw（SRD）、最旧优先和最大优先。默认情况下 BDK 使用 BnB，若 BnB 找不到解则回退到 SRD。

- [LDK #1425][] 增加对[大额通道][topic large channels]（“wumbo 通道”）的支持，也就是支持高价值支付的通道。

- [LND #6064][] 新增 `bitcoind.config` 与 `bitcoind.rpccookie` 配置选项，用于指定非默认的配置文件与 RPC cookie 路径。

- [LND #6361][] 更新 `signrpc` 方法，使其能够使用 [MuSig2][topic musig] 算法创建签名。详细信息见该合并 PR 中的[文档][lnd6361 doc]。请注意，对 MuSig2 的支持仍属实验性质，可能发生变化，尤其是 MuSig2 拟议 BIP 出现重大调整时（见 [Newsletter #195][news195 musig2]）。

- [BOLTs #981][] 从规范中移除了对 LN 网络图查询及结果进行压缩的能力。据信该压缩并未被使用，去掉这项支持可降低 LN 实现的复杂度和依赖数量。


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
