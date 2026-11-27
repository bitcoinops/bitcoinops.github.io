---
title: 'Bitcoin Optech Newsletter #37'
permalink: /zh/newsletters/2019/03/12/
name: 2019-03-12-newsletter-zh
slug: 2019-03-12-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 提到一个已停止维护（end-of-life）的 Bitcoin Core 版本中存在漏洞，请求协助测试下一大版本 Bitcoin Core 的候选发布版本，提供 Bitcoin-Dev 邮件列表的最新情况，介绍列表上近期的讨论，并链接到 Optech 正在编写的扩容技术书中关于支付批处理的章节。此外还介绍了热门比特币基础设施项目中若干值得注意的提交。

## 行动项

- **<!--ensure-you-aren-t-running-old-bitcoin-core-versions-->****确保你没有运行旧的 Bitcoin Core 版本：**Suhas Daftuar 披露了一个影响 Bitcoin Core 0.13.0 至 0.13.2 的漏洞。（注意：这些版本停止维护（[end-of-life][core eol]）已有数月。）该漏洞可让攻击者使你的节点把一个有效区块判定为无效，把你的节点分叉到共识区块链之外，并可能诱使你相信自己收到了某笔已确认的比特币，而你实际并不掌控它。除了检查自己的基础设施里是否还有旧版 Bitcoin Core，还建议检查是否有山寨币的节点基于受影响的 Bitcoin Core 版本。更多信息见下方的披露详情。

- **<!--help-test-bitcoin-core-0-18-0-rc1-->****帮助测试 Bitcoin Core 0.18.0 RC1：**Bitcoin Core 下一个大版本的首个候选发布版本（RC）已经发布。我们强烈建议依赖 Bitcoin Core 的组织和有经验的用户[测试它][0.18.0]，检查是否存在回归，以及其他可能影响你生产环境使用的问题。任何测试都有帮助；如果你在测完自己的用例后还有余力，也请考虑帮忙测试 [0.18 对 GUI 的改动][gui 0.18]。这个界面的使用者主要是经验较少的用户，他们不太可能自己去测 RC，但一旦有问题漏了过去，受影响的往往正是他们。

## 新闻

- **<!--bitcoin-dev-mailing-list-status-update-->****Bitcoin-Dev 邮件列表状态更新：**上周 Newsletter 报告的服务中断已经解决，但列表管理员[计划][bishop list]迁移到另一种方案。过去两周发出的许多帖子已经转发给订阅者，但有些已经丢失。如果你在[二月][list feb]或[三月][list mar]的存档里没看到自己的帖子，请重新发送。今后的 Optech Newsletter 会说明订阅者为继续接收协议讨论需要采取哪些行动。

- **<!--bitcoin-core-vulnerability-disclosure-->****Bitcoin Core 漏洞披露：**Suhas Daftuar [披露][merkle disclosure]了一种新方法，可诱使较早的 Bitcoin Core 版本拒收有效区块。如果攻击者构造一个区块，其中两笔交易的 32 字节哈希（txid）拼接起来恰好看起来像一笔 64 字节的交易，那么对区块头所锚定的默克尔树就可以有两种不同的解读：一种解读让树指向一笔无效的 64 字节交易，另一种则指向两笔有效交易。（交易多于两笔时，也能构造出类似的冲突版本。）

  ![由不同区块数据派生的两个相同的默克尔根图示](/img/posts/2019-03-merkle-ambiguity.svg)

  这会给 Bitcoin Core 带来问题：通常情况下，如果它把某个区块判为无效，就会把该区块的区块头哈希加入缓存，以免再浪费资源去请求或重复处理这个区块。这样一来，攻击者只要先把该区块的无效形式发给你的节点，就能让你的节点之后无法处理它的有效形式，也无法处理任何从它延伸出去的区块，从而把你分叉到主链之外。

  2012 年曾披露过一个类似漏洞，编号 [CVE-2012-2459][]。Bitcoin Core 当时做了调整：对于默克尔树存在歧义的区块，不再缓存其无效性。然而，Bitcoin Core 0.13.0 中实现的一项[优化][bitcoin core #7225]又重新引入了这个缓存问题，因此需要一项[修复][bitcoin core #9765]，该修复包含在 Bitcoin Core 0.14.0 中。Daftuar 的邮件附了一份[信息量很大的 PDF][daftuar pdf]，不仅详述了这个具体问题，还说明其代价仅为 30 比特的暴力破解工作量——非常小（不过你还需要挖出一个定制区块）；它也描述了 Bitcoin 默克尔树可能存在的其他已知漏洞，并计算了利用这些漏洞所需的平均暴力破解工作量。Daftuar 至今没有在当前共识区块链中发现任何此类攻击的实例。

- **<!--cleanup-soft-fork-proposal-discussion-->****清理软分叉提案讨论：**本周讨论了[上周 Newsletter][newsletter #36 cleanup]中所述的共识清理软分叉[提案][bip-cleanup]。Russell O'Connor [提出担忧][roconnor codesep]：让 `OP_CODESEPARATOR` 操作码失效，可能导致那些用到了该操作码的现有 UTXO 无法被花费。而这一点无法检测，因为有人可能曾向某个 P2SH 地址付款，而该地址尚未公开的 redeemScript 正用到了这个不被推荐的操作码。O'Connor 建议换一种缓解方式：不再禁止该操作码，而是提高那些求值后的脚本中包含该操作码的交易的权重（vbytes），以此缓解 `OP_CODESEPARATOR` 被用来拉长最坏情况下区块验证时间的问题。这样既能限制一个区块中可包含的代码分隔符上限，又可能同时把区块的总体大小和操作总数压到能在合理时间内完成验证的程度。

  O'Connor 还针对软分叉提案要使未分配的 sighash 类型字节失效这一点，提出了[类似的担忧][roconnor sighash]。这种情况同样无法完全检测，因为比特币用户可能早就创建了预签名的带锁定时间交易，而相关签名密钥已经丢失或销毁，无法再生成新签名。他建议改用更复杂的 sighash 缓存（提案 BIP 中已将其列为一种选项），而不是提高未分配 sighash 字节的权重来限制其使用。

  Matt Corallo 回应了 O'Connor 的两点担忧：虽然对于尚未广播的花费，我们无法察觉这些功能是否被使用，但对于现有链上的任何交易，我们都能查出来——而实际上并不存在这样的使用。“我很怀疑真有人会用这么冷门的方案，一直往里投钱，却从没测试过，也一分钱都没取出来过，”Corallo 说道；随后他讨论了如果不禁用这些功能，计算手续费和缓存 sighash 会多出多少复杂性。他的反驳还包括一个请求：任何用到了默认不会中继或打包的交易功能（“非标准”）的人，请[联系][core contact] Bitcoin Core 开发者说明情况，以便重新考虑相关策略。

- **<!--feedback-requested-on-signet-->****请求对 signet 的反馈：**Karl-Johan Alm 一直在开发 Bitcoin 测试网的一种[替代方案][signet]，它使用中心签名的区块代替工作量证明。虽然这样无法测试 Bitcoin 的去中心化特性，但它大部分时间都能稳定出块，还能按计划演练区块链重组、手续费飙升等不利事件，从而让应用开发者的测试体验方便得多。它还能保证中心签名机构手里始终有测试币，可以通过水龙头分发。相比之下，测试网有时出块太快，对等节点跟不上；有时又太慢，没法用于测试；水龙头常常是空的；捣乱者还能制造出在真正有价值的网络上几乎不可能出现的重组场景。Alm 正在征求反馈，并希望最终把自己的代码并入 Bitcoin Core（大概也会推动其他节点实现支持它）。

- **<!--removal-of-bip61-p2p-reject-messages-->****移除 BIP61 P2P `reject` 消息：**Marco Falke 发起了一个[讨论帖][falke bip61]，就他希望从 Bitcoin Core 中移除 [BIP61][] reject 消息一事征求意见。当你的节点收到某条有问题的消息（例如一笔交易）时，它会返回一条 `reject` 消息，其中说明问题所在。BIP61 消息并非无需信任（你的节点可能撒谎），而且关于问题的相同信息可以从拒绝节点的日志中提取出来，开发者因此能调查发送到自己节点的消息出了什么问题。参见 [Newsletter #13][]，了解我们对 Falke 那个在 Bitcoin Core 中默认禁用 `reject` 消息的 PR 的描述。

  Andreas Schildbach 是一位钱包开发者，也是流行的 BitcoinJ 库的首席维护者。他请求保留这些消息并默认重新启用。他的用户在自己的交易发不出去时，会把包含 reject 消息的日志文件发邮件给他，帮他排查问题。对此 Gregory Maxwell 指出，即使一个诚实的节点接受了某笔交易，也不代表它的对等方也会接受。因此客户端仍然需要在不依赖 BIP61 的情况下监控交易传播，这让 BIP61 在这件事上显得多余。同理，BIP61 也无法可靠地用来检测费率过低的交易：当默认大小的内存池被占满时，一笔按最低费率被接受的交易，确认时间可能比用户期望的晚好几周。最后，验证节点的设计目标是追求最高性能，而这往往与向随机的、不受信任的对等方提供尽可能有用的调试信息相冲突。

- **<!--extension-fields-to-partially-signed-bitcoin-transactions-psbts-->****部分签名比特币交易（PSBT）的扩展字段：**Andrew Poelstra [提议][psbt extension]为 PSBT 增加若干字段，以支持几项新功能。他还提议把一个目前必需出现的字段改为可选。这些新字段可以帮助客户端判断 `OP_CHECKSEQUENCEVERIFY`（CSV）条件是否已满足，支持 [miniscript][] 能够生成的全部脚本范围，并附带供 [MuSig][]、pay-to-contract 和 sign-to-contract 协议使用的额外数据。[BIP174][] 作者 Andrew Chow 对其中大部分建议表示可以接受。

- **<!--review-of-bitcoin-privacy-literature-published-->****发布比特币隐私文献综述：**Chris Belcher 发布了一份篇幅较长的[隐私问题综述][privacy summary]，梳理 Bitcoin 中存在的各种隐私隐患。该页面以及 Wiki 的相关[隐私类别][Privacy category]，为任何研究 Bitcoin 隐私问题的人提供了一个很好的起点。

- **<!--version-2-addr-message-proposed-->****提议第 2 版 `addr` 消息：**Wladimir van der Laan [提议][addrv2 proposal]为 P2P 协议的 `addr` 消息新版本起草一份 BIP。现有消息用于传达节点的 IP 地址或 [OnionCat][] 编码的 Tor 隐藏服务（.onion）名称、端口，以及节点所提供服务的位图。然而自原始 Bitcoin 代码库发布以来，Tor 已把隐藏服务地址升级为 256 位，使其无法用在 Bitcoin 现有的 `addr` 消息中。还有一些网络覆盖协议（例如 I2P）同样使用更长的地址。这份提议的 BIP 若能实施，将为这些协议提供支持。

- **<!--optech-publishes-book-chapter-about-payment-batching-->****Optech 发布关于支付批处理的书稿章节：**在同一笔交易中向多个人付款，可以把每笔付款的平均手续费成本降低 70% 以上。这项技术对交易所这类高频付款方尤其方便。Optech 正在编写一份关于可单独部署的扩容技术的指南；作为这项工作的一部分，我们公开[章节草稿][batching chapter]，详细描述这项技术及其取舍。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案（BIPs）][bips repo]中值得注意的变更。请注意，Bitcoin Core 目前在主开发分支和即将发布的 0.18 版本分支上并行开发，因此我们标出了每个 Bitcoin Core 合并所影响的分支。*

- [Bitcoin Core #15118][] 把 Bitcoin Core 存储和检索区块及 UTXO 变更相关数据的方式通用化，以便新的实现更容易用同样的方式存储和检索其他信息。这样做是为了复用该机制，把 [BIP157][] 紧凑区块过滤器存到磁盘上。目前这仅在主开发分支中。

- [Bitcoin Core #15492][] 移除了已弃用的 `generate` RPC，它用于在 regtest 模式下创建区块。这个 RPC 此前已被 `generatetoaddress` RPC 取代，后者不要求节点在编译或运行时带钱包支持。这仅在主开发分支中。

- [Bitcoin Core #15497][] 修改了多个 RPC 中对[输出脚本描述符][output script descriptors]的用法，改用一致的范围表示法，以便从带 [BIP32][] HD 钱包路径的描述符派生出多个地址。这属于 0.18 分支和 0.18.0RC1 发布的一部分。

- [LND #2690][] 把更多 gossip 流量放入队列（而不是立即发送），以便更高优先级的信息更可能被迅速处理。gossip 流量用于传播哪些对等方在线，以及它们各自有哪些可用通道。

- [C-Lightning #2391][] 弃用了 `newaddr` RPC 中的 `address` 字段，改由 `bech32` 字段或 `p2sh-segwit` 字段取代，具体取决于请求的地址类型（如果传入可选的 `all` 参数，则两个字段都会返回）。每个字段所表示的地址类型都与其名称一致。


{% include references.md %}
{% include linkers/issues.md issues="7225,9765,15118,15492,15497,2690,2391" %}
[core eol]: https://bitcoincore.org/en/lifecycle/#schedule
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[bishop list]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016700.html
[merkle disclosure]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-February/016697.html
[list feb]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-February/date.html
[list mar]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/date.html
[daftuar pdf]: https://gnusha.org/pi/bitcoindev/CAFp6fsGtEm9p-ZQF_XqfqyQGzZK7BS2SNp2z680QBsJiFDraEA@mail.gmail.com/2-BitcoinMerkle.pdf
[roconnor codesep]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016724.html
[roconnor sighash]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016725.html
[core contact]: https://bitcoincore.org/en/contact/
[signet]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016734.html
[falke bip61]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016701.html
[bip-cleanup]: https://github.com/TheBlueMatt/bips/blob/cleanup-softfork/bip-XXXX.mediawiki
[psbt extension]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-March/016713.html
[privacy summary]: https://en.bitcoin.it/wiki/Privacy
[privacy category]: https://en.bitcoin.it/wiki/Category:Privacy
[addrv2 proposal]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-February/016687.html
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
