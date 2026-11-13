---
title: 'Bitcoin Optech Newsletter #101'
permalink: /zh/newsletters/2020/06/10/
name: 2020-06-10-newsletter-zh
slug: 2020-06-10-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 链接到一篇博客文章和一篇论文，内容是利用 日食攻击攻击比特币软件，从 LN 通道中窃取资金；并介绍了影响硬件钱包的手续费超额支付攻击的来龙去脉与影响。此外还有我们的常设栏目：Bitcoin Core PR 审查俱乐部会议摘要、近期软件发布介绍，以及热门比特币基础设施项目近期变更的总结。

## 行动项

- **<!--check-hardware-wallet-compatibility-->****检查硬件钱包兼容性：** 如果你的软件或流程允许用硬件钱包花费 segwit 输入，请检查你的系统是否仍与钱包的最新固件更新兼容。例如，[Trezor 的最新固件][trezor update]要求与其对接的软件一并升级，才能继续处理 segwit 输入；[Ledger 的最新固件][ledger update]在处理来自未升级软件的 segwit 输入时会给出警告。其他硬件钱包未来可能也会发布类似更新；请联系厂商了解其计划。这项变化的动机，请参见下文*新闻*栏目中关于手续费超额支付攻击的条目。

## 新闻

- **<!--time-dilation-attacks-against-ln-->****针对 LN 的时间膨胀攻击：** Gleb Naumenko 和 Antoine Riard 在 Bitcoin-Dev 邮件列表上[发帖][naumenko td]，概述了他们写的一篇[博客文章][td blog]，而该文又总结了两人合著的[论文][td paper]，内容是利用 [日食攻击][topic eclipse attacks]从 LN 通道中窃取资金。这项工作扩展了 Riard 在 [Newsletter #77][news77 eclipse] 中做过的分析。简而言之，攻击者控制了某个 LN 节点与比特币 P2P 网络之间的全部连接，并推迟把新区块公告中继给受害者。等受害者眼中的区块链落后公开共识视图足够远之后，攻击者再以过时的状态关闭与受害者的通道——那个状态分给攻击者的钱比最新状态更多。日食攻击的作用，是让受害者在争议期结束之前看不到这些关闭交易，而此时攻击者已把非法所得转到一个完全由自己控制的地址。

  论文描述的这类攻击，最少只需两小时就能从轻量客户端窃取资金。由于目前为轻量 LN 客户端提供数据的服务器和节点很少，攻击者可能很容易造出足够多的 sybil 来完成攻击。针对由本地比特币全验证节点支撑的 LN 节点，攻击耗时更长——但也仍然只是几小时的事——并且可能需要造出多得多的 sybil。作者指出，这类攻击很可能也适用于其他对时间敏感的合约协议。这个问题的一般性解法是提高抵御 日食攻击的能力，其中一个具体的改进建议，是允许节点自愿启用[替代传输协议][Bitcoin Core #18988]。

- **<!--fee-overpayment-attack-on-multi-input-segwit-transactions-->****针对多输入 segwit 交易的手续费超额支付攻击：** 比特币交易支付的手续费是所花费的 UTXO 金额与创建的 UTXO 金额之间的差额。交易明确声明了创建的 UTXO 金额，但所花费的 UTXO 金额只能通过查找创建这些 UTXO 的先前交易来确定。花费交易仅承诺其要花费的 UTXO 的 txid 和位置，这要求计算手续费的其他软件要么查找每个 UTXO 的先前交易，要么维护一个已验证的 UTXO 数据库。

  硬件钱包不维护 UTXO 集，因此对于使用传统 UTXO 的交易，它们要判断支付了多少手续费，唯一无需信任的办法就是：取得每个传统 UTXO 先前交易的副本，对先前交易做哈希以确认其 txid 与 UTXO 引用匹配，再用验证过的 UTXO 金额完成手续费计算。最坏情况下，传统交易的大小可能接近 1 MB，而一笔花费交易可能引用成千上万笔先前交易，因此金额验证可能要资源有限的硬件钱包处理数 GB 的数据。

  [BIP143][] segwit v0 所做的若干改进之一，就是想用[签名承诺其所花费的 UTXO 金额][bip143 motivation]来消除这一负担。这样一来，任何承诺了错误金额的签名都会无效——Bitcoin Core 和[硬件钱包][palatinus inpatient]的开发者都认为，这能让签名者安全地接受来自不受信任软件的金额。

  不幸的是，只签单个 UTXO 的金额被证明并不够。2017 年，Greg Sanders [描述][sanders attack]了一种攻击，可以诱骗用户大幅超额支付交易手续费。首先，攻击者取得与硬件钱包对接的桌面或移动软件的控制权，等用户发起一笔支付。随后，受损软件为这笔请求的交易造出两个变体，两者都花费用户硬件钱包控制的同样两个 segwit UTXO。在第一笔交易中，受损软件少报其中一个 UTXO 的金额，这会让硬件钱包少算同样数额的交易手续费。在第二笔交易中，受损软件少报第二个 UTXO 的金额，这又会让硬件钱包少算第二笔交易的手续费。

  受损软件把第一笔交易发给硬件钱包。用户核对金额、收款地址和算出的交易手续费，授权签名，签名后的交易被送回受损软件。按 BIP143，这第一笔交易是无效的，因为其中一个签名承诺了错误的 UTXO 金额。受损软件随后谎称出了点小问题导致交易无法广播，告诉用户需要重新签名；但它并没有重发第一笔交易，而是发出第二笔交易。从硬件钱包显示的信息（金额、收款方和手续费）看，第二笔交易与第一笔一模一样，所以用户很可能再次授权签名。这第二笔交易同样因某个签名承诺了错误金额而按 BIP143 无效。不过，两笔交易各自都有一个有效签名，受损软件可以用这两个有效签名拼出一笔有效交易，让手续费被超额支付。

  ![手续费超额支付攻击示意图](/img/posts/2020-06-fee-overpayment-attack.dot.png)

  最坏的情况是：钱包控制着 *n* 个 UTXO，攻击要求用户签名 *n* 次，最终除了合法支付金额之外，钱包的全部资金都被当作手续费花掉。

  与 Sanders 2017 年邮件中描述的另一类攻击类似（见 [Newsletter #97][news97 spk commit]），这种攻击只影响*无状态签名器*，例如需要依赖外部系统告知自己控制哪些 UTXO 的硬件钱包。联网钱包会自行跟踪所收到 UTXO 的金额，不会为错误的 UTXO 金额签名，因此不受此攻击影响。当然，联网钱包也有其他弱点，这正是硬件钱包能提升用户安全性的原因。

  上周，Trezor [宣布][trezor post]，Saleem Rashid 大约三个月前重新发现了这个漏洞。作为应对，Trezor 更新了固件，对 segwit UTXO 也像对传统 UTXO 那样要求提供先前交易的副本。这破坏了与若干对接 Trezor 设备的钱包的兼容性——无论是直接对接还是通过 [HWI][topic hwi] 对接（见 [HWI #340][]）。如果钱包保存了完整的先前交易副本，或者能取得这些副本，那么恢复兼容性只需更新钱包代码。但若钱包并不保存那些曾向自己付款的交易的完整副本，就可能需要重新设计钱包来存储这类数据，并重新扫描区块链中的历史交易。创建或更新[部分签名比特币交易][topic psbt]（PSBT）的软件也需要[升级][Bitcoin Core #19215]，把完整的先前交易副本写入 PSBT。如果 PSBT 存放在容量受限的介质中（例如 QR 码，见 [Newsletter #96][news96 qr]），数据量可能大幅增加，那就可能需要放弃该协议，或改用容量更大的介质。

  Ledger 也做了类似改动，但其[支持文章][ledger update]称，只有在没有完整先前交易副本的情况下花费 segwit UTXO 时才会显示警告。要求提供先前交易固然能把用户抵御此类攻击的安全性提到最高，但也有人主张：应当允许硬件钱包选择继续使用 segwit 中已签名的 UTXO 金额，而不是去破坏现有软件、把额外资源花在类似传统交易的金额验证上：

  - **<!--attack-already-well-known-for-three-years-->****该攻击三年前就已广为人知：** Sanders 近三年前就公开描述了这一攻击，此后在[邮件列表][lau sighash2]、[BIPs][bip341 all amounts]、Newsletter [#11][news11 sighash] 和 [#46][news46 digest changes] 以及其他讨论中，它也被提到或暗示过。当时[有人][wuille minimal impact]认为，“大家都觉得这事太难处理，影响也微乎其微”。而且，能拿到硬件钱包配套软件控制权的攻击者，可能更倾向于发动别的攻击——例如[地址替换攻击][hw security]——直接把钱付给自己，而不是去超额支付手续费。

  - **<!--double-signing-can-also-lead-to-spending-twice-->****双重签名也可能导致重复花费：** 该攻击依赖受损软件让硬件钱包用户授权两笔略有差异、但在用户看来完全相同的交易（每笔有两个输入）。然而，同一套受损软件也完全可以向用户展示两笔截然不同、但看起来一模一样的交易（各花不同的输入），结果就是向同一个收款方付两次钱。这两种攻击从用户角度看无法区分，但针对手续费超额支付的修复并不能解决[重复花费攻击][maxwell spend twice]。

  - **<!--multisig-setups-may-require-multiple-compromises-->****多重签名方案可能需要攻破多个签名者：** 要攻击由多个硬件钱包保护的多重签名资金，必须诱骗达到最低阈值（例如“2-of-3”多重签名中的“2”）所需的每个签名者，都去签同样那两个交易变体。如果阈值中包含一个知道自己所签 UTXO 金额的在线钱包（例如基于策略的远程签名器），那么只有当这个在线钱包也被攻破时，攻击才成立。

  针对该攻击的长期解法，是修改交易摘要，使每个签名都承诺该交易中所有被花费 UTXO 的金额。这样，受损软件只要谎报任何一个 UTXO 的金额，签名就会无效。这一方案由 Johnson Lau 于 2018 年[提出][lau sighash2]（见 [Newsletter #11][news11 sighash]），并从最早的公开草案起就写进了 [taproot][topic taproot] 的 [BIP341][] 规范（见 [Newsletter #46][news46 digest changes]）。如果 taproot 被采用，无状态签名器（如硬件钱包）签署 taproot UTXO 时就不必再核验先前交易，安全性应当会提高。可惜这仍然解决不了重复花费攻击——该问题源自大多数硬件钱包的[无状态设计][wuille stateless]：它们无法在内部跟踪自己的交易历史。

## Bitcoin Core PR 审查俱乐部

_在这个月度栏目中，我们总结最近一次 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议的内容，挑选其中一些重要的问题与回答。点击下面的问题，可以看到会议中相关回答的摘要。_

[连接驱逐逻辑测试][review club #16756]是 Martin Zumsande 提交的一个 PR ([#16756][Bitcoin Core #16756])，它为 Bitcoin 网络的对等节点驱逐逻辑的部分内容添加了缺失的测试覆盖。该测试验证了那些中继交易和区块并迅速响应的入站对等节点不受驱逐影响。

讨论围绕 Bitcoin Core 中的驱逐逻辑和入站对等连接的保护展开：

{% include functions/details-list.md
  q0="**<!--q0-->**当 Bitcoin Core 节点的入站连接达到限制时会发生什么？"
  a0="当节点的连接数已满时，若有新的入站对等节点接入，节点会断开一个已有的入站对等节点连接。这就是所谓的“驱逐”。"

  q1="**<!--q1-->**为什么 Bitcoin Core 驱逐对等节点而不是不再接受新的入站连接？"
  a1="目标是不断筛选出行为良好、来自各种网络、能快速中继区块的对等节点，同时防止恶意方垄断连接名额。最先连上的对等节点未必就是最好的，因此需要一套驱逐机制。"
  a1link="https://bitcoincore.reviews/16756#l-41"

  q2="**<!--q2-->**为什么 Bitcoin Core 保护选定的对等节点免于驱逐？"
  a2="我们希望保留那些已被证明有用的连接，并让恶意方更难驱逐他人、占满所有入站连接。因此，会针对几种各自不同、且难以伪造的特征，各自保护一小部分对等节点。攻击者要想把某个节点割裂出网络，就必须在这些特征上同时比诚实的对等节点更胜一筹。"
  a2link="https://github.com/bitcoin-core-review-club/bitcoin/blob/pr16756/src/net.cpp#L846"

  q3="**<!--q3-->**描述 Bitcoin Core 中入站对等节点驱逐的算法。"
  a3="先选出所有入站对等节点，但排除在 `NO BAN` 列表上的节点和已安排断开连接的节点。然后按这些代价高昂、难以伪造的属性分别挑出（保护）最好的对等节点：网络组、最低的 ping 时间、最近发送过交易和区块、理想的服务标志，以及持续时间长的连接。在剩下的对等节点中，从连接数最多的那个网络组里挑一个驱逐。"
  a3link="https://github.com/bitcoin-core-review-club/bitcoin/blob/pr16756/src/net.cpp#L851"
%}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Bitcoin Core 0.20.0][] 是比特币原始项目的最新大版本。本版本最值得注意的用户可见改进包括：RPC 用户默认使用 [bech32][topic bech32] 地址（GUI 从 0.19 起已默认使用 bech32）、可为不同用户和应用配置 RPC 权限（见 [Newsletter #77][news77 rpcwhitelist]）、在 GUI 中生成 PSBT 的部分基础支持（[#74][news74 psbtgui] 和 [#82][news82 psbtgui]），以及[输出脚本描述符][topic descriptors]语言新增的 `sortedmulti`——它让监控由按字典序排序的密钥生成的多重签名地址更容易，例如 Coldcard 原生多重签名所用的那些地址（[#68][news68 sortedmulti]）。

  此外，代码里还做了许多不那么显眼的改进，用来消除 bug、增强安全性、为未来变更做准备。其中一项备受关注的前瞻性改动，是新增 `asmap` 配置项：它允许使用单独下载的数据库，改善 Bitcoin Core 把连接分散到由许多不同群体控制的各个网络中的能力，从而增强对 [日食攻击][topic eclipse attacks]（例如 [Erebus 攻击][Erebus attack]）的抵御能力（见 [Newsletter #83][news83 asmap]）。不过，该功能的作者之一[指出][wuille asmap]，“它目前还高度实验性，后续如何推进也不明确。收集和编译 ASN [自治系统编号]数据非常不容易，还牵涉信任问题。”

  关于所有变更的更多信息，以及参与这个新版本的 100 多位贡献者名单，请参见项目的[发布说明][core20 rn]。

- [LND 0.10.1-beta][] 是这个热门 LN 节点软件的一个新的小版本发布。发布说明没有宣布重大新功能，但提到若干 bug 修复、“一个新的试运行迁移模式，可在永久应用迁移之前先做测试”，以及对路由子服务器中通道选择/限制的增强。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中值得注意的变更。*

- [Eclair #1440][] 使得可以用 API 一次更新多个通道。这一改动最初是为了帮节点运营者批量更新通道的中继费率，以适应动态变化的链上手续费市场；它同时也支持批量关闭和强制关闭。

- [Eclair #1141][] 增加了对 `option_static_remotekey` 通道的支持。如果 LN 节点发生数据丢失，该功能允许通道对手方把当前余额付给在最初打开通道时约定的未调整密钥，从而关闭通道，并让该节点的钱包能正常花掉自己的资金。该功能的更多细节参见 [Newsletter #67][news67 static_remotekey]。

- [LND #4251][] 使其 REST 接口支持的非流式消息列表与 gRPC 接口对齐。此前，REST 接口只提供其中一部分消息（具体来说是 `Lightning` 子服务器的消息）。该 PR 之后还会跟进 [LND #4141][]，它通过 WebSocket 支持流式响应，使 REST 接口与 gRPC 接口完全对齐。

- [BIPs #920][] 更新了 [BIP341][] 中 [taproot][topic taproot] 的规范，要求签名直接承诺所有被花费 UTXO 的 scriptPubKey。这让硬件钱包更容易安全地参与 [coinjoin][topic coinjoin] 及其他协作构建的交易。详情请参见 [Newsletter #97][news97 spk commit] 中的描述。

## 特别感谢

我们感谢 Pieter Wuille 帮助研究手续费超额支付攻击的历史。感谢 Antoine Riard 提供有关时间膨胀攻击论文的附加信息。任何错误或遗漏均由 Newsletter 作者负责。

{% include references.md %}
{% include linkers/issues.md issues="1440,4251,920,1141,18988,19215,4141,16756" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[lnd 0.10.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.1-beta
[news97 spk commit]: /zh/newsletters/2020/05/13/#request-for-an-additional-taproot-signature-commitment
[news77 eclipse]: /zh/newsletters/2019/12/18/#discussion-of-eclipse-attacks-on-ln-nodes
[hw security]: https://en.bitcoin.it/wiki/Hardware_wallet#Security_risks
[towns benefits]: https://bitcoincore.org/en/2016/01/26/segwit-benefits/#signing-of-input-values
[palatinus inpatient]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2016-October/013248.html
[news11 sighash]: /zh/newsletters/2018/09/04/#proposed-sighash-updates
[naumenko td]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/017920.html
[td blog]: https://discrete-blog.github.io/time-dilation/
[td paper]: https://arxiv.org/abs/2006.01418
[lau sighash2]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016345.html
[maxwell spend twice]: http://www.erisian.com.au/bitcoin-core-dev/log-2020-06-05.html#l-352
[bip143 motivation]: https://github.com/bitcoin/bips/blob/master/bip-0143.mediawiki#motivation
[sanders attack]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-August/014843.html
[news97 spk commit]: /zh/newsletters/2020/05/13/#request-for-an-additional-taproot-signature-commitment
[trezor post]: https://blog.trezor.io/details-of-firmware-updates-for-trezor-one-version-1-9-1-and-trezor-model-t-version-2-3-1-1eba8f60f2dd
[bip341 all amounts]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#cite_note-17
[news96 qr]: /zh/newsletters/2020/05/06/#qr-codes-for-large-transactions
[news46 digest changes]: /zh/newsletters/2019/05/14/#digest-changes
[wuille asmap]: https://twitter.com/pwuille/status/1268296477584965634
[news77 rpcwhitelist]: /zh/newsletters/2019/12/18/#bitcoin-core-12763
[news74 psbtgui]: /zh/newsletters/2019/11/27/#bitcoin-core-16944
[news82 psbtgui]: /zh/newsletters/2020/01/29/#bitcoin-core-17492
[news68 sortedmulti]: /zh/newsletters/2019/10/16/#bitcoin-core-17056
[news83 asmap]: /zh/newsletters/2020/02/05/#bitcoin-core-16702
[core20 rn]: https://bitcoincore.org/en/releases/0.20.0/
[news67 static_remotekey]: /zh/newsletters/2019/10/09/#bolts-642
[trezor update]: https://blog.trezor.io/latest-firmware-updates-correct-possible-segwit-transaction-vulnerability-266df0d2860
[ledger update]: https://support.ledger.com/hc/en-us/articles/360014191540
[erebus attack]: https://erebus-attack.comp.nus.edu.sg/
[wuille minimal impact]: http://www.erisian.com.au/bitcoin-core-dev/log-2020-06-04.html#l-613
[wuille stateless]: http://www.erisian.com.au/bitcoin-core-dev/log-2020-06-05.html#l-395
[hwi #340]: https://github.com/bitcoin-core/HWI/pull/340
