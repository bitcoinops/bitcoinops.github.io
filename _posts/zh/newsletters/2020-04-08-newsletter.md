---
title: 'Bitcoin Optech Newsletter #92'
permalink: /zh/newsletters/2020/04/08/
name: 2020-04-08-newsletter-zh
slug: 2020-04-08-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了简化版 ECDSA 适配器签名方面的工作。此外还有我们的常规部分：Bitcoin Core PR 审查俱乐部讨论摘要、发布公告，以及热门比特币基础设施项目的值得注意的变更。

## 行动项

*本周无。*

## 新闻

- **<!--work-on-ptlcs-for-ln-using-simplified-ecdsa-adaptor-signatures-->****使用简化的 ECDSA 适配器签名为 LN 实现 PTLC 的工作：**
  点时间锁定合约（PTLC）是当前用于实现 LN 可路由支付的哈希时间锁定合约（HTLC）的替代方案。现有 HTLC 机制的问题在于，支付路径上每一跳都用同一个哈希摘要来保护其条件支付。这意味着，控制同一路径上两个节点的用户就能确定：这两个节点之间的各跳既不是该支付的最终付款方，也不是最终收款方。这不仅削弱了 LN 洋葱路由所提供的隐私，还让恶意用户可以窃取付给中间各跳的路由手续费（即所谓[虫洞攻击][wormhole attack]）。例如在下面这条路径中，Mallory 既能窃取 Bob 和 Carol 的路由手续费，也能断定他们都不是最终付款方或收款方。

  ```
  Alice → Mallory → Bob → Carol → Mallory' → Dan
  ```

  PTLC 使用适配器签名（表示椭圆曲线上的*点*）而不是哈希，因此每一跳都可以为同一笔支付使用不同的标识符。适配器签名最初是为配合 [Schnorr 签名][topic schnorr signatures]而提出的。已知它们也可以用在比特币当前的 ECDSA 签名方案中（参见 [Newsletter #16][news16 2pecdsa scriptless]），但这一过程依赖双方 ECDSA 签名（2pECDSA），既复杂，又需要额外的安全假设，超出了比特币式 ECDSA 签名通常所需的范围。不过最近 Lloyd Fournier 发表了一篇[论文][fournier otves]，说明只用常规的 2-of-2 比特币多重签名（例如 `OP_CHECKMULTISIG`）和简单的离散对数等价（DLEQ），就能安全地使用适配器签名；去年 11 月有人在 Lightning-Dev 邮件列表上[发帖][uSEkaCIO email]总结了这项成果。

  上周在 [Lightning HackSprint][] 期间，几位开发者围绕这些 2-of-2 多重签名适配器签名[做了工作][ptlc challenge]。成果是一篇关于该主题的优秀[博文][gibson blog]，以及 C 语言 [libsecp256k1][jonasnick otves] 和 Scala [bitcoin-s][nkohen otves] 库的概念验证实现。这些代码目前尚未经过审查，可能并不安全，但它们能帮助开发者开始在 mainnet 上试验适配器签名的用法——既可用于 LN 中的 PTLC，也可用于其他免信任的合约协议。

## Bitcoin Core PR 审查俱乐部

_在本节中，我们总结了一次最近的 Bitcoin Core PR 审查俱乐部会议，重点介绍了一些重要的问答。点击下面的问题以查看会议中答案的摘要。_

[更紧急地重试 `notfound`][review club 18238] 是 Anthony Towns 提出的一个 PR（[#18238][Bitcoin Core #18238]），它改动了点对点行为：节点在请求某笔交易后收到 `notfound` 消息时，将跳过当前的超时等待，改为尽快从另一个对等节点获取该交易。

讨论从提出这个 PR 的根本原因开始：

{% include functions/details-list.md
  q0="为什么更快重试 `notfound` 会有所帮助？"
  a0="防止 DoS 攻击、提升交易传播速度、增强隐私，以及将来移除 `mapRelay`。"

  q1="可能的 DoS 攻击担忧是什么？"
  a1="内存池较小的节点可能宣告一笔交易，随后却无法交付，从而无意中拖慢向对等节点中继交易的速度。"

  q2="<!--tx-propagation-->为什么交易传播速度很重要？"
  a2="几秒钟的短暂延迟不成问题（对隐私甚至可能有益），但几分钟的较长延迟会损害交易的传播和 [BIP152][] 紧凑区块的中继。"

  q3="**<!--q3-maprelay-->**`mapRelay` 最初是什么时候、为什么被添加的？"
  a3="`mapRelay` 在比特币的第一个版本中就已存在。它确保节点宣告某笔交易后，即使该交易在宣告之后、对等节点请求之前已被打包进区块，也仍能下载到它。"

  q4="**<!--q4-maprelay-->**请描述移除 `mapRelay` 会带来的一个问题？"
  a4="在诚实的情况下，被请求的交易也可能更频繁地返回 `notfound`，延迟最长可达 2 分钟，从而影响传播。"
%}

会议后半段讨论了 `TxDownloadState` 数据结构：

{% include functions/details-list.md
  q0="**<!--q0-txdownloadstate-->**请描述 `TxDownloadState` 结构的作用？"
  a0="它是每个对等节点各自的状态机，带有定时器，用来协调向对等节点请求交易。"

  q1="**<!--q1-txdownloadstate-->**我们怎样改进 `TxDownloadState`，以降低今后引入交易中继缺陷的可能性？"
  a1="为该结构加入内部一致性检查，或用接口定义清晰的类替换它。"
%}

随后讨论深入到这个 PR 的实现、潜在问题以及未来的改进，还有它们与 [wtxid 交易中继][wtxid transaction relay]提案的相互影响。更多细节请见[学习笔记与会议记录][review club 18238]。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Eclair 0.3.4][] 已发布，支持开启价值超过 0.168 BTC 的通道（参见 [Newsletter #88][news88 eclair1323]），并支持[可重复构建][topic reproducible builds]（参见 [Newsletter #87][eclair determ]）。此外还包含缺陷修复和许多其他改进。详情请见其[发布说明][eclair 0.3.4]。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络 BOLT 规范][bolts repo]中的值得注意的变更。*

- [C-Lightning #3612][] 新增启动参数 `--large-channels` 和 `--wumbo`（两者等效）。启用后，节点会在其 `init` 消息中宣告支持 `option_support_large_channel`，这意味着它会接受价值高于此前约 0.168 BTC 上限的通道开启。如果远端对等节点也支持该选项，C-Lightning 的 `fundchannel` RPC 将允许用户创建超过此前上限的通道。另见 [Newsletter #88][news88 eclair1323] 中介绍的 Eclair 对该选项的支持。

- [C-Lightning #3600][] 添加了对使用*盲化路径*的*洋葱消息*的实验性支持：

  - **<!--onion-messages-->***洋葱消息*（在 [Newsletter #86][news86 ln dm] 中称为“LN 直接消息”）允许节点在不使用 LN 支付机制的情况下，通过网络发送加密消息。这可以替代 [Whatsat][] 这类应用借助支付传递消息的做法。与借助支付传递消息相比，洋葱消息有几项优势：

    1. 它们有一份[草案规范][onion messages draft spec]，如果被采纳，多个实现支持它们就会更容易。

    2. 它们不需要链上可强制执行的支付通道所提供的安全性，因此即使两个对等节点之间没有建立支付通道，也能在它们之间路由洋葱消息。

    3. 它们不像 HTLC 或错误消息那样需要双向传递信息，因此节点中继一条消息后，就不必保留与该消息相关的任何信息。这种无状态性把节点的内存需求降到最低。如果发送节点希望收到回复，草案规范允许它附带一个盲化的 `reply_path` 字段，接收节点可以用这个字段在新消息中发送回复。

  - **<!--blinded-paths-->***盲化路径*（在 [Newsletter #85][news85 lw rv] 中称为“轻量级会合路由”，现在已有[草案提案][blinded path gist]）使得路由支付或消息时，发起方无需知道目的节点的网络身份，也无需知道所用的完整路径。这通过以下几个步骤实现：

    1. 目的节点从某个中间节点出发，选择一条通向自己的路径，然后用洋葱加密这条路径信息，使得路径上的每一跳只能解密出下一个应当接收消息的节点标识符。目的节点再把这份加密的（“盲化的”）路径信息交给发送节点（例如通过 [BOLT11][] 发票中的某个字段，或使用前面提到的洋葱消息 `reply_path` 字段）。

    2. 发送节点用常规洋葱路由把消息中继给那个中间节点。

    3. 中间节点从盲化路径中解密出自己的下一跳，并将消息发送给它。下一个节点再解密自己的下一跳字段，继续中继消息；如此反复，直到消息抵达目的节点。

    与常规洋葱路由一样，任何路由节点都不应知晓盲化路径的更多信息，只知道是哪个节点把消息发给自己、以及自己之后应当把消息交给哪个节点。与常规路由不同的是，起点节点和终点节点都无需知道对方的身份，也无需知道实际走了哪条路径。这不仅提升了这两个端点的隐私，也提升了盲化路径上任何未公开节点的隐私。

  正如该 PR 所述，“目前还没有为这些消息定义内容，只有路由和回复所必需的部分，但目的是把这一机制用于 offers。”offers 将允许节点通过 LN 请求和发送发票；详情参见 [Newsletter #72][news72 offers]。

- [LND #4087][] 新增支持：如果在[命令行][watchtower tor]启用，就会自动创建瞭望塔的 Tor 隐藏服务。

- [LND #4079][] 新增支持使用[部分签名比特币交易][topic psbt]（PSBT）为通道出资，从而允许任何兼容 PSBT 的钱包为通道开启提供资金。此前，只有 LND 内置钱包才能为通道出资。通道出资完成后，其余操作都由 LND 照常管理。用户可以在 `lncli openchannel` 中提供 `--psbt` 标志，启动交互式对话流程来完成整个出资流程；详情请见[文档][lnd psbt]。

- [LND #3970][] 为 LND 的支付生命周期系统加入了[多路径支付][topic multipath payments]支持，该系统负责跟踪“从任意环节恢复支付所需的、关于支付当前状态的全部信息”。<!-- routing/payment_lifecycle.go --> 这使 LND 距其 0.10 版本的目标——完整支持多路径支付——更近了一步。<!-- Alex Bosworth email, "In 0.10.0 I think the main new feature will be the ability to multipath." -->

{% include references.md %}
{% include linkers/issues.md issues="3612,3600,4087,4079,3970,18238" %}
[news86 ln dm]: /zh/newsletters/2020/02/26/#ln-direct-messages
[news85 lw rv]: /zh/newsletters/2020/02/19/#decoy-nodes-and-lightweight-rendez-vous-routing
[news88 eclair1323]: /zh/newsletters/2020/03/11/#eclair-1323
[news72 offers]: /zh/newsletters/2019/11/13/#proposed-bolt-for-ln-offers
[whatsat]: https://github.com/joostjager/whatsat
[onion messages draft spec]: https://github.com/lightningnetwork/lightning-rfc/pull/759
[blinded path gist]: https://github.com/lightningnetwork/lightning-rfc/blob/route-blinding/proposals/route-blinding.md
[ptlc challenge]: https://wiki.fulmo.org/index.php?title=Challenges#Point_Time_Locked_Contracts_.28PTLC.29
[gibson blog]: https://joinmarket.me/blog/blog/schnorrless-scriptless-scripts/
[wormhole attack]: http://diyhpl.us/wiki/transcripts/stanford-blockchain-conference/2019/privacy-preserving-multi-hop-locks/
[lightning hacksprint]: https://wiki.fulmo.org/index.php?title=Main_Page
[fournier otves]: https://github.com/LLFourn/one-time-VES/blob/master/main.pdf
[news16 2pecdsa scriptless]: /zh/newsletters/2018/10/09/#多方-ecdsa-用于无脚本的闪电网络支付通道
[uSEkaCIO email]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-November/002316.html
[jonasnick otves]: https://github.com/jonasnick/secp256k1/pull/14/
[nkohen otves]: https://github.com/bitcoin-s/bitcoin-s/pull/1302
[lnd psbt]: https://github.com/lightningnetwork/lnd/blob/master/docs/psbt.md
[review club 18238]: https://bitcoincore.reviews/18238.html
[wtxid transaction relay]: https://bitcoincore.reviews/18044
[watchtower tor]: https://github.com/lightningnetwork/lnd/blob/master/docs/watchtower.md#tor-hidden-services
[eclair 0.3.4]: https://github.com/ACINQ/eclair/releases/tag/v0.3.4
[eclair determ]: /zh/newsletters/2020/03/04/#eclair-1307
