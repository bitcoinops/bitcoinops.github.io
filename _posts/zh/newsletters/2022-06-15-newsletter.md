---
title: 'Bitcoin Optech Newsletter #204'
permalink: /zh/newsletters/2022/06/15/
name: 2022-06-15-newsletter-zh
slug: 2022-06-15-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报总结了关于在比特币点对点网络中支持交易包转发的讨论，分享了一份来自最近的闪电网络开发者会议的总结，还介绍了一种关于闪电网络上的花费者和路由节点如何能以互惠的方式优化可靠性并降低手续费的论述。此外还有我们的常规栏目：软件的新版本和候选版本总结、热门的比特币基础设施软件的重大变更。

## 新闻

- **<!--continued-package-relay-bip-discussion-->关于交易包转发升级提议的持续讨论**：近期的一份关于[交易包转发][topic package relay] 的 BIP 草案（见[周报 #201][news201 relay]）在过去几周了收到了附加性的评论：
  - *<!--policy-limits-->用法局限性*：Anthony Towns [询问][towns relay] 支持交易包转发的两个对等节点间的沟通，是否应该说明各自支持的交易包体积上限和深度上限，不然使用非默认设定的节点将重复收到关于自己不想要的交易包的提醒，浪费带宽。该 BIP 的作者 Gloria Zhao [说明][zhao negotiation]：第一个版本的交易包转发协议应该会使用 25 笔交易和 101,000 vbyte 的体积限制。
  - *<!--package-graph-announcement-only-->仅宣布交易包的图谱*：Eirc Voskuil [再次评论][voskuil graph]道，如果一个节点知道了某笔低费率祖先交易的高手续费后代，应该可以直接通知其对等节点这两笔交易的关系，也就是 “交易图谱”。收到通知的节点可以请求任何本地没有的交易。在这个帖子的一个单独部分中，Towns [指出][towns graph]：除非收集到相关的所有交易，否则交易图是无法验证的，所以还必须保证一个节点无法通过谎报交易图来阻止某一笔交易被转发。
  - *<!--using-short-ids-->使用短标识符*：多个开发者建议使用 [BIP152][] 形式的短标识符（short ids）。Zhao [解释道][zhao sids]：短标识符对区块转发是有用的，因为节点会首先验证新区块的工作量证明（这是难以创造的），所以攻击者想通过这个机制来消耗节点资源的成本是非常高的。但是，如果转发的是很容易创造的数据，短标识符就有可能被不断滥用，变成一种拒绝服务式攻击。
  - *<!--nonstandard-parents-->不标准的祖先交易*：Suhas Daftuar [介绍][daftuar repeat]了一种情景，在此情景中实现了交易包转发的节点可能会不断重复请求相同的数据。如果转发方法在较旧的节点和较新的节点中不同（比如发生了软分叉），这种情景尤为可能出现。
  - *<!--challenges-of-a-block-hash-beacon-->区块哈希信标的挑战*：Daftuar 还指出，这套协议的一个特性可能会给其他软件制造麻烦。当前的 BIP 草案规定了节点在宣布交易包时需要附带本地区块链最新区块的哈希值。这使得接收的节点可以忽略掉很久以前的交易包（以及另一条链上的交易包），因为这些交易包跟接收节点当下的交易池可能没关系了。但是，Daftuar 指出，可能许多用来发送交易的软件 —— 也是最终可能用来发送交易包的软件 —— 并不跟踪当前区块链的最新区块哈希值。
  
- **<!--summary-of-ln-developer-meeting-->闪电网络开发者会议的总结**：Olaoluwa Osuntokun 提供了一份关于上周奥克兰（Oakland）闪电网络开发者会议的[详细总结][osuntokun summary]。其中的主题包括：
  - *<!--taprootbased-ln-channels-->基于 Taproot 的闪电网络通道*：参与者讨论了将闪电网络迁移到完全使用 [taproot][topic taproot] 特性的第一步。后续步骤有可能加入对 “[点时间锁合约（PTLC）][topic ptlc]” 的支持（见[周报 #164][news164 taproot ln]）。
  
  - *<!---tapscript-and-musig2-->Tapscript 和 MuSig2*：作为迁移到基于 taproot 的通道的一部分，我们需要将现有的脚本转化为能够最高效利用区块空间的 tapscript 脚本。此外，还需要在一切可预期双方会则作行动的地方使用 [MuSig2][topic musig] 协议来创建签名。所有这些都需要实现和测试来保证它们的工作情况。
  
  - *<!--recursive-musig2-->递归的 MuSig2*：简单的 MuSig2 将允许 Alice 和 Bob 一起创建一个签名。递归的 MuSig2 将允许（举个例子）Alice 使用她的热钱包和硬件签名设备生成她的那部分签名，而无需 Bob 执行任何特殊的操作，Bob 也不会知道 Alice 在使用多于一个私钥来签名。现在大家讨论的是如何设计闪电网络对 MuSig2 的用法，来保证可以使用递归的 MuSig2。还讨论了递归 MuSig2 的安全性。
  
  - *<!--extension-bolts-->闪电网络技术基础的插件*：另一种说明闪电网络协议规范变化的方法。当前，闪电网络规范的变化是作为一个补丁加入到现有的规范中的。但是，一些开发者倾向于使用 BIP 所用的方法：对协议的重大变更是用一套乃至多套专门说明这些变更的文档作为规范的。这些开发者相信，专门的文档更易于撰写和阅读，因此可以简化和加速开发进度。
  
  - *<!--gossip-network-updates-->闪电网络消息协议升级*：会议还延续了当前对闪电网络 gossip 协议升级的讨论（见[周报 #188][news188 gossip]），这套协议是用来转发关于新通道和通道更新的消息的。根据这份总结，参与者们倾向于在短期内进行微小升级以支持基于 MuSig2 的 taproot 通道，以及将协议升级到完全支持 [TLV][news55 tlv] 语义。
  
  - *<!--minisketchbased-efficient-gossip-->高效消息协议*：如[周报 #198][news198 minisketch] 所述，开发者正在研究使用 [minisketch][topic minisketch] 来降低节点间同步 LN gossip 的带宽，我们还可凭此进一步降低更新通道的最小时间的间隔。
  
  - *<!--onion-message-dos-->洋葱消息拒绝服务式攻击*：多个闪电网络实现已经支持[洋葱消息协议][topic onion messages]，既作为使用 [keysend][topic spontaneous payments] 支付功能来通讯的替代方法，也作为还在提议阶段的 [BOLT12 主动支付协议][topic offers]的通信层。但是，如[周报#190][news190 onion] 所述，一些开发者依然担心洋葱消息无法抵御许多不同类型的拒绝服务式攻击。讨论了多种防止拒绝服务式攻击的方法。
  
  - *<!--blinded-paths-->路径盲化*：一种提议了许多年（见[周报#185][news85 blinded]）并且现在已经用于洋葱消息的协议也在开展实验，用在常规支付中以允许用户在接收支付时无需公开自己的闪电网络节点的身份。这种方法面临的挑战之一是它要沟通更多的路由信息，所以要使用更大数据量的发票。这可能会让路径盲化的高效实现依赖于更新颖的发票管理协议，比如 BOLT12 主动支付协议或者 [LNURL][]。还讨论了许多别的难点。
  
  - *<!--probing-and-balance-sharing-->余额打探及共享*：当前，使用多种技术，你可以 *打探* 出网络中某个通道的余额分布。这样的侦测对执行侦测的节点来说是没有成本的，却会对网络的普通用户造成困扰，还会降低隐私性。对专门的 “[通道干扰攻击][topic channel jamming attacks]” 的缓解措施也能帮助限制侦测，但当前人们还有疑虑，所以参与者们讨论了一些节点设定上的简单变更，让侦测变得更困难。
  
    此外，一个之前大家讨论过的思想实验是，把执行侦测的节点可能获取的信息提取出来并主动、免费地分享。要是每一个节点都这样做，带宽要求和隐私降级都会削弱闪电网络的关键优势 —— 但这会让支付路由高效得多。没有人支持这种想法，但之前的一个研究课题讨论了每个节点都只向自己的直接通道对手分享一些可被侦测的信息的想法。有人主张这会极大地提高支付路由的成功率，比如可以增加 “[柔性的通道再平衡（Just-in-time channel rebalancing）][topic jit routing]” 机制。
  
  - *<!--trampoline-routing-and-mobile-payments-->蹦床路由与移动支付*：[蹦床路由][topic trampoline payments]允许一个花费者将寻路的任务外包给网络中的另一个节点，还可以选择性维持闪电网络通常的隐私性，即防止任何中间节点知道花费者和接收者的身份。这种外包对移动端的闪电网络客户端尤其有用，因为它们本身不打算为其他节点路由支付。会议总结中提到，蹦床支付可以跟 *一跳保管支付（first hop payment holds）*（见[周报 #171][news171 ln offline]）相结合，后者的意思是支付由花费者的直接通道对手保管，直到接收节点下一次上线，他能允许一个经常离线的手机节点可靠地接收来自其他经常离线的手机节点的支付。
  - *<!--lnurl-plus-bolt12-->闪电网络统一资源位置符加闪电网络技术基础十二*：闪电网络统一资源位置符（LNURL）协议允许一个节点向一个互联网服务器（webserver）请求一个 [BOLT11][] 发票；而 BOLT12 [主动支付][topic offers] 协议允许一个节点向网络中的另一个节点请求发票。围绕这些协议的其它侧面，参与者们讨论了这两个协议如何相互兼容，使得节点可以使用其中一个或同时使用两个。
  
- **<!--using-routing-fees-to-signal-liquidity-->使用路由费来说明流动性**：开发者 ZmnSCPxj 在 Lightning-Dev 邮件组中[发帖][zmnscpxj hilolohi]，论证了最便宜和可靠的支付如何可以通过花费者和路由节点之间的博弈理论行为来实现：

  - 花费者要选择路由费更少的路径。
  - 路由节点要随着通道可用容量的降低而收取更高的手续费。例如：假设一条通道的大部分余额都是 Alice 的，她可以可靠地路由支付给 Bob，因此她不应该收太多手续费；但是，随着更多的余额被支付给了 Bob，Alice 路由更多支付的能力会下降，所以她应该收取更高的手续费。

  ZmnSCPxj 使用供给和需求经济学表述了这套论证 —— 随着一个方向上（比如 Alice 到 Bob）的路由支付需求上升，其它方向上可以路由的资金的供给量自然会下降。提高路由费的价格可以遏制需求量的上升，直到供给量因为人们相反方向（从 Bob 到 Alice）的支付而恢复。

  花费者已经会自然而然（在其它条件都相同时）选择更低的手续费了，所以 ZmnSCPxj 认为，任何路由节点，只要使用了 高供给量/低手续费 和 低供给量/高手续费 的策略，都会自动让通道保持合理的平衡，并且因此能够在其通道存活的时间里处理更多的成功支付（相比不使用这种策略的节点）。因为路由节点只能从成功的支付中得到报酬，所以使用这种策略的节点会更有竞争力。

  这种方法的一个关键好处在于它让花费者的寻路变得非常容易 —— 在容量允许的范围内，只需要通过最便宜的路径来支付即可。缺点则是，在这种策略下，每次路由手续费率的变更都暗示了通道平衡的相应变化，因此会暴露最近通过这个通道来路由的支付的面额。举个例子，如果  Alice→Bob、Bob→Carol 和 Carol→Dan 三条通道的可用容量都下降了 1 BTC，那么你可以合理猜测，Alice 或其通道对手路由了 1 BTC 的支付给 Dan 或者 Dan 的通道对手。还有一个问题是，每次通道的手续费率变更都要 gossip 到整个网络中，这会提高带宽要求，也会导致虚假的路由失败（例如，因为花费者 Sally 不知道 Alice 提高了手续费率，所以试图通过 Alice 跟 Bob 的通道来路由一笔支付，但是使用更旧（也即是更低）的费率，然后 Alice 就拒绝掉了）。

  ZmnSCPxj 介绍了多种缓解措施，有一些是无需改变闪电网络协议就可以在节点上实现的，有些则要求略微改变闪电网络的 gsssip 协议。截至本期周报撰写之时，这些缓解策略还未得到邮件组的任何讨论，虽然 Olaoluwa Osuntokun 在闪电网络开发者会议总结中已经提到了它们（已经由 Optech 在上一段中作了进一步总结）。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND 0.15.0-beta.rc6][] 是这个热面的闪电网络节点实现的下一个大版本的候选版本。

## 重大的代码和文献变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 以及 [Lightning BOLTs][bolts repo]。*

- [Bitcoin Core #24171][] 该变了初始化区块下载（IBD）的行为，如果没有连向的对等节点（outbound peer）提供区块数据，就向连入的对等节点（inbound peer）请求区块数据。以前，只有在完全没有连向的对等节点时，节点才会向连入的对等节点请求数据。这种行为可能导致节点暂停，因为其连向的对等节点不提供区块数据。此外，一旦连向的对等节点恢复服务，节点依然会变成仅向他们请求区块。
- [BDK #593][] 开始使用 [rust bitcoin][rust bitcoin repo] 0.28，它包含了对 [taproot][topic taproot] 和 taproot [输出脚本描述符][topic descriptors]的支持。

{% include references.md %}
{% include linkers/issues.md v=2 issues="24171,1505,628,593" %}
[lnd 0.15.0-beta.rc6]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta.rc6
[news201 relay]: /en/newsletters/2022/05/25/#package-relay-proposal
[towns relay]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020496.html
[zhao negotiation]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020512.html
[voskuil graph]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020518.html
[towns graph]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020520.html
[zhao sids]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020539.html
[daftuar repeat]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020542.html
[osuntokun summary]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003600.html
[news164 taproot ln]: /en/newsletters/2021/09/01/#preparing-for-taproot-11-ln-with-taproot
[news188 gossip]: /en/newsletters/2022/02/23/#updated-ln-gossip-proposal
[news55 tlv]: /en/newsletters/2019/07/17/#bolts-607
[news198 minisketch]: /en/newsletters/2022/05/04/#ln-gossip-rate-limiting
[news190 onion]: /en/newsletters/2022/03/09/#paying-for-onion-messages
[news85 blinded]: /en/newsletters/2020/02/19/#decoy-nodes-and-lightweight-rendez-vous-routing
[lnurl]: https://github.com/fiatjaf/lnurl-rfc
[news171 ln offline]: /en/newsletters/2021/10/20/#paying-offline-ln-nodes
[zmnscpxj hilolohi]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003598.html
