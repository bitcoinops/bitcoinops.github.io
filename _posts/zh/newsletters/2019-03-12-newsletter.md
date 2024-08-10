---
title: 'Bitcoin Optech Newsletter #37'
permalink: /zh/newsletters/2019/03/12/
name: 2019-03-12-newsletter-zh
slug: 2019-03-12-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 提到一个已过生命周期的 Bitcoin Core 版本中的漏洞，寻求帮助测试下一主要版本的 Bitcoin Core 发布候选版本，提供了 Bitcoin-Dev 邮件列表的更新，描述了列表中的最近讨论，并链接到 Optech 的工作中扩展技术书中的支付批处理章节。此外，还包括对几个流行的比特币基础设施项目中的值得注意的提交的描述。

## 行动项

- **<!--ensure-you-aren-t-running-old-bitcoin-core-versions-->****确保你没有运行旧的 Bitcoin Core 版本：** Suhas Daftuar 披露了一个影响 Bitcoin Core 0.13.0 至 0.13.2 版本的漏洞。（注意：这些版本已经过了[生命周期终止][core eol]几个月。）该漏洞允许攻击者使你的节点认为一个有效的区块是无效的，从而使你脱离共识区块链，并可能诱骗你认为你收到了实际上并不控制的已确认比特币。除了检查你的基础设施中是否存在旧版本的 Bitcoin Core，还建议检查基于受影响的 Bitcoin Core 版本的山寨币节点。更多信息请参见下面的披露详情。

- **<!--help-test-bitcoin-core-0-18-0-rc1-->****帮助测试 Bitcoin Core 0.18.0 RC1：** 下一个主要版本的 Bitcoin Core 的第一个发布候选版本 (RC) 已发布。依赖 Bitcoin Core 的组织和经验丰富的用户被强烈鼓励[测试它][0.18.0]，以防止回归和其他可能影响你在生产中使用的问题。任何测试都是有帮助的，但如果你在为你的特定用例进行测试后有多余的时间，请考虑帮助测试 [0.18 版本的 GUI 更改][gui 0.18]。此界面主要由不太有经验的用户使用，他们不太可能自己测试 RC，但他们会特别受到任何未能发现的问题的影响。

## 新闻

- **<!--bitcoin-dev-mailing-list-status-update-->****Bitcoin-Dev 邮件列表状态更新：** 上周 Newsletter 报告的服务中断已经解决，但列表管理员[计划][bishop list]迁移到其他解决方案。过去两周发送的许多帖子已经转发给了列表订阅者，但有些帖子已丢失。如果你没有在[二月][list feb]或[三月][list mar]存档中看到你的帖子，请重新发送。未来的 Optech Newsletter 将提到订阅者需要采取的任何行动以继续接收协议讨论。

- **<!--bitcoin-core-vulnerability-disclosure-->****Bitcoin Core 漏洞披露：** Suhas Daftuar [披露][merkle disclosure]了一种新颖的方法，用于欺骗较早的 Bitcoin Core 版本拒绝有效的区块。如果攻击者创建一个包含两个交易的区块，这两个交易的 32 字节哈希 (txid) 连接在一起时看起来像是一个 64 字节的交易，则可以创建两种不同的默克尔树解释，一种解释将树指向一个无效的 64 字节交易，另一种解释指向两个有效的交易。（类似的冲突版本也可以用多个交易创建。）

  ![由不同区块数据派生的两个相同的默克尔根图示](/img/posts/2019-03-merkle-ambiguity.svg)

  这会为 Bitcoin Core 创建一个问题，因为通常如果它拒绝一个区块为无效，它会将该区块的头哈希添加到缓存中，以便它不再浪费资源请求或重新处理该区块。这使得攻击者可以将区块的无效形式发送给你的节点，从而防止你的节点处理其有效形式或任何从它派生的区块，使你脱离区块链。

  2012 年披露了一个类似的漏洞作为 [CVE-2012-2459][]，Bitcoin Core 当时被调整为不缓存其默克尔树包含歧义的区块的无效性。然而，在 Bitcoin Core 0.13.0 中实施的一个[优化][bitcoin core #7225]重新引入了这个缓存问题，需要一个[修复][bitcoin core #9765]，此修复包含在 Bitcoin Core 0.14.0 中。Daftuar 的邮件包括一个[非常有用的 PDF][daftuar pdf]，不仅详细描述了这个特定问题，并显示其成本为非常小的 30 比特蛮力工作（尽管你还需要开采一个自定义区块），还描述了比特币的默克尔树可能存在的其他已知漏洞，并计算了利用它们所需的平均蛮力工作量。Daftuar 在当前的共识区块链中没有发现任何攻击实例。

- **<!--cleanup-soft-fork-proposal-discussion-->****清理软分叉提案讨论：** 本周讨论了[上周 Newsletter][newsletter #36 cleanup]中描述的共识清理软分叉[提案][bip-cleanup]。Russell O'Connor [提出担忧][roconnor codesep]，认为无效化 `OP_CODESEPARATOR` 操作码可能会阻止使用该操作码的现有 UTXO 被花费。无法检测到这一点，因为人们可能已经支付了一个 P2SH 地址，其尚未揭示的 redeemScript 使用了不推荐使用的操作码。O'Connor 建议通过增加包含该操作码的交易的权重 (vbytes) 来减轻 `OP_CODESEPARATOR` 被用来增加最坏情况下的区块验证时间的问题。这将减少区块中可能包含的代码分隔符的最大数量，同时也可能减少区块的总体大小和总操作数，使其能够在合理的时间内验证。

  O'Connor 还提出了[类似的担忧][roconnor sighash]，关于软分叉提案使未分配的 sighash 类型字节无效。也无法完全检测到这一点，因为比特币用户可能已经创建了预签名的锁定时间交易，而他们已丢失或销毁了签名密钥，无法创建新签名。与其增加未分配 sighash 字节的权重以限制其使用，他建议使用更复杂的 sighash 缓存（如提案 BIP 中描述的一个选项）。

  Matt Corallo 对 O'Connor 的两个担忧作出回应，指出虽然我们无法检测到这些功能在未广播的花费中是否使用，但我们可以检测到它们在现有链中的任何交易——而这种使用并不存在。“我严重怀疑有人在使用一个高度深奥的方案，并且一直在向其中投入资金而从未测试过或提取过任何资金，”Corallo 说道，然后讨论了如果不禁用这些功能，计算费用和缓存 sighash 的额外复杂性。他的反驳还包括一个请求，请任何使用默认情况下不转发或挖掘的交易功能（“非标准”）的人[联系][core contact] Bitcoin Core 开发者，并让他们了解情况，以便重新考虑政策。

- **<!--feedback-requested-on-signet-->****请求对 signet 的反馈：** Karl-Johan Alm 一直在开发一个[比特币的替代品][signet]，它使用中心签名的区块而不是工作量证明。尽管这不能测试比特币的去中心化性质，但它可以通过提供常规的区块生产时间和对不利事件如区块链重组或费用激增的计划测试，使应用程序开发人员的测试网络更加方便。它还将确保中心签名机构始终有测试币通过其水龙头分发。相比之下，测试网的区块生产有时太快，无法让节点跟上，或者太慢而无法用于测试，水龙头经常为空，捣乱者可以创建在有实际价值的网络中极不可能存在的重组场景。Alm 正在寻求反馈，并希望最终将他的代码合并到 Bitcoin Core（可能也让其他节点实现支持它）。

- **<!--removal-of-bip61-p2p-reject-messages-->****移除 BIP61 P2P `reject` 消息：** Marco Falke 启动了一个[线程][falke bip61]，寻求关于他希望从 Bitcoin Core 中移除 [BIP61][] reject 消息的反馈。当你的节点接收到一个有问题的消息（如交易）时，你的节点将返回一个包含问题描述的 `reject` 消息。BIP61 消息不是无信任的（你的节点可能会撒谎），并且可以从拒绝节点的日志中提取有关问题的相同信息，这使得开发人员能够调查发送到自己节点的消息问题。参见 [Newsletter #13][]，了解我们对 Falke 的 PR 的描述，该 PR 在 Bitcoin Core 中默认禁用 `reject` 消息。

  Andreas Schildbach，一位钱包作者和流行的 BitcoinJ 库的主要维护者，请求保留消息并默认重新启用它们。当他们的交易未通过时，他的用户会通过日志文件向他发送 reject 消息，帮助他调试问题。作为回应，Gregory Maxwell 指出，即使一个诚实的节点接受了交易，也不意味着它的对等节点也会接受。因此，客户端仍需监控交易传播，而无需使用 BIP61，使 BIP61 在这方面显得多余。同样，BIP61 不能合理地用于检测手续费率过低的交易，因为一个支付最低手续费率的已接受交易在默认大小的内存池满时，可能需要几周时间才能确认，比用户期望的时间长得多。最后，验证节点的设计是为了最大化性能，这通常与向随机不受信任的对等节点提供最大有用的调试信息的能力相冲突。

- **<!--extension-fields-to-partially-signed-bitcoin-transactions-psbts-->****部分签名比特币交易（PSBTs）的扩展字段：** Andrew Poelstra [提议][psbt extension]向 PSBTs 添加几个字段，以支持几个新功能。他还提议将一个当前必需的字段改为可选。这些新字段可以帮助客户端确定 `OP_CHECKSEQUENCEVERIFY`（CSV）条件是否满足，支持使用 [miniscript][] 生成的脚本的全部范围，并包括用于 [MuSig][]、pay-to-contract 和 sign-to-contract 协议的额外数据。[BIP174][] 作者 Andrew Chow 对大多数建议持开放态度。

- **<!--review-of-bitcoin-privacy-literature-published-->****发布比特币隐私文献综述：** Chris Belcher 发布了一个扩展的[隐私问题总结][privacy summary]，总结了比特币中存在的各种隐私问题。该页面和 Wiki 的相关[隐私类别][Privacy category]为任何研究比特币隐私问题的人提供了一个很好的起点。

- **<!--version-2-addr-message-proposed-->****版本 2 `addr` 消息提议：** Wladimir van der Laan [提议][addrv2 proposal]为 P2P 协议 `addr` 消息创建一个新的版本 BIP。现有的消息传达节点的 IP 地址或 [OnionCat][] 编码的 Tor 隐藏服务 (.onion) 名称、其端口和节点提供的服务的位图。然而，自原始比特币代码库发布以来，Tor 已将其隐藏服务地址升级为使用 256 比特，无法在比特币的现有 `addr` 消息中使用。还有其他网络覆盖协议，如 I2P，也使用更长的地址。提议的 BIP 如果实施，将提供对这些协议的支持。

- **<!--optech-publishes-book-chapter-about-payment-batching-->****Optech 发布支付批处理的书章节：** 在同一交易中支付多个人可以将每笔付款的平均交易费成本降低 70% 以上。这种技术对于交易所等高频支出者特别方便。作为 Optech 持续工作的单独部署扩展技术指南的一部分，我们正在发布我们的[草稿章节][batching chapter]，详细描述了这种技术及其权衡。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和 [比特币改进提案 (BIPs)][bips repo] 中值得注意的更改。请注意，Bitcoin Core 目前在其主开发分支和即将发布的 0.18 版本分支上都有工作，因此我们注明了每个 Bitcoin Core 合并影响的分支。*

- [Bitcoin Core #15118][] 概括了 Bitcoin Core 如何存储和检索与区块和 UTXO 变化相关的数据，以便更容易为新方法使用相同方式存储和检索其他信息。这是为了允许重用该机制在磁盘上存储 [BIP157][] 紧凑区块过滤器。这目前仅在主开发分支中。

- [Bitcoin Core #15492][] 移除了用于在 regtest 模式中创建区块的已弃用的 `generate` RPC。此 RPC 之前被 `generatetoaddress` RPC 取代，后者不要求节点构建或运行时支持钱包。这仅在主开发分支中。

- [Bitcoin Core #15497][] 更改了多个 RPC 中使用的[输出脚本描述符][output script descriptors]，以使用一致的范围表示法从具有 [BIP32][] HD 钱包路径的描述符中派生多个地址。这是 0.18 分支和 0.18.0RC1 版本的一部分。

- [LND #2690][] 将更多的 gossip 流量放入队列（而不是立即发送），以便更高优先级的信息更有可能迅速处理。gossip 流量用于传达哪些对等节点在网络上以及他们有哪些通道可用。

- [C-Lightning #2391][] 弃用 `newaddr` RPC 中的 `address` 字段，用 `bech32` 字段或 `p2sh-segwit` 字段代替，具体取决于请求的地址类型（如果传递了可选的 `all` 参数，则两个字段都有）。每个字段中的地址类型与其名称一致。


{% include references.md %}
{% include linkers/issues.md issues="7225,9765,15118,15492,15497,2690,2391" %}
[core eol]: https://bitcoincore.org/en/lifecycle/#schedule
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[bishop list]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016700.html
[merkle disclosure]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-February/016697.html
[list feb]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-February/date.html
[list mar]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/date.html
[daftuar pdf]: http://lists.linuxfoundation.org/pipermail/bitcoin-dev/attachments/20190225/a27d8837/attachment-0001.pdf
[roconnor codesep]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016724.html
[roconnor sighash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016725.html
[core contact]: https://bitcoincore.org/en/contact/
[signet]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016734.html
[falke bip61]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016701.html
[bip-cleanup]: https://github.com/TheBlueMatt/bips/blob/cleanup-softfork/bip-XXXX.mediawiki
[psbt extension]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016713.html
[privacy summary]: https://en.bitcoin.it/wiki/Privacy
[privacy category]: https://en.bitcoin.it/wiki/Category:Privacy
[addrv2 proposal]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-February/016687.html
[onioncat]: https://web.archive.org/web/20121122003543/http://www.cypherpunk.at/onioncat/wiki/OnionCat
[batching chapter]: /en/payment-batching/
[gui 0.18]: https://github.com/bitcoin/bitcoin/pulls?utf8=%E2%9C%93&q=is%3Apr+label%3AGUI+milestone%3A0.18.0
[newsletter #36 ml]: /zh/newsletters/2019/03/05/#bitcoin-dev-mailing-list-outage
[newsletter #36 cleanup]: /zh/newsletters/2019/03/05/#cleanup-soft-fork-proposal
[newsletter #13]: /zh/newsletters/2018/09/18/#bitcoin-core-14054
[cve-2012-2459]: https://bitcointalk.org/?topic=102395
[miniscript]: /en/topics/miniscript/
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
[musig]: https://eprint.iacr.org/2018/068
