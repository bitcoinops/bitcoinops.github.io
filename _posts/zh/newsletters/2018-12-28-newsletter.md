---
title: 'Bitcoin Optech Newsletter #27: 2018 年终特别总结'
permalink: /zh/newsletters/2018/12/28/
name: 2018-12-28-newsletter-zh
slug: 2018-12-28-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 是特别的年终版本，回顾 2018 年全年比特币领域值得注意的发展。尽管本刊篇幅较长，我们仍感遗憾的是，它只覆盖了数百名贡献者在数十个开源项目中所做工作的一小部分。没有这些底层的贡献，本刊描述的那些宏大构想就只是空话，因此我们向今年所有为比特币开发做出贡献的人致以最诚挚的感谢。

## 一月

在年初之前，测试网上已经有数百条闪电网络（LN）通道处于开放状态，但到 2018 年 1 月，才开始有少数企业和用户在主网上用真实的比特币进行 LN 支付。这些先驱者把自己的行为标记为 *#reckless*（鲁莽），但这并没有阻止其他实验者在这个刚起步的支付网络上拿真金白银去冒险。

本月还发表了由 Gregory Maxwell、Andrew Poelstra、Yannick Seurin 和 Pieter Wuille 提出的、基于 schnorr 的 [muSig][] 交互式多方签名协议。它提供的安全性与比特币现有的多重签名相同，但通常能把所需的交易数据一路压缩到单个看起来普通的公钥和签名。这不仅降低了开销和成本，还让普通的多重签名交易与单签名交易看起来毫无差别，从而提升了隐私。

<div markdown="1" class="xoverflow shrink80">

| | 接收脚本 | 支出数据 |
|-|-|-|
| **单签名，当前脚本（P2PK）** | `<pubkey> OP_CHECKSIG` | `<signature>` |
| **裸多重签名，当前脚本** | `2 <pubkey> <pubkey> <pubkey> 3 OP_CHECKMULTISIG` | `OP_0 <signature> <signature>` |
| **多重签名，muSig[^fn-opcodes]** | `<pubkey> OP_CHECKSIG` | `<signature>` |

</div>

{:#taproot}
顺着“muSig 或类似方案有可能在比特币中实现”这一想法，Maxwell 又描述了 [Taproot][]——一种针对默克尔化替代脚本树（Merklized Alternative Script Trees[^fn-mast]，[MAST][]）的强大优化。正如 muSig 能让普通多重签名看起来像单签名，taproot 也能让即使最复杂的比特币脚本，在参与者相互配合时看起来像单签名（若他们不配合，仍能获得所选脚本的完整安全性）。这让更大一批用户得以享受更低的开销、更低的成本和更好的隐私。

<div markdown="1" class="xoverflow shrink80">

| | 接收脚本 | 支出数据 |
|-|-|-|
| **单用户，当前脚本（P2PK）** | `<pubkey> OP_CHECKSIG` | `<signature>` |
| **合作用户，早期 MAST 提案[^fn-harding-mast]** | `<hash> OP_MAST` | `<signature> <<pubkey> OP_CHECKSIG> <hash> <flags>` |
| **合作用户，Taproot[^fn-opcodes]** | `<pubkey> OP_CHECKSIG` | `<signature>` |

</div>

## 二月

仿佛 taproot 的潜在好处还不够，二月里 Gregory Maxwell 又描述了一种名为 [Graftroot][] 的构造：它允许当前获授权花费某枚币的人，在不创建新交易的情况下，新增若干组可以花费这枚币的条件。此后任何时刻，任意一组获授权的条件都可以用来花费这枚币。例如，某枚币目前需要 Alice 和 Bob 双方同意才能花费（2-of-2 多重签名），他们可以共同同意此后由 Alice、Bob 或他们的律师 Charlie 三人中的任意两人来花费（2-of-3 多重签名）——而且这个决定可以在他们最初收到这枚币几年之后才做出，无需创建新交易。这能进一步提高效率和隐私，对某些链下合约协议尤其如此。

{:#multipath-payments}
与此同时，LN 协议开发者 Olaoluwa Osuntokun 和 Conner Fromknecht 描述了一种[在 LN 上做多路径支付的新方式][ln multipath]。所谓多路径支付，就是把一笔支付拆成几部分、分别经由多条通道完成——例如 Alice 可以经由她与 Bob 的通道发送一笔支付的一部分给 Zed，再经由她与 Charlie 的通道发送另一部分。

<div markdown="1" class="xoverflow shrink80">

| 单一路径 | 多路径 |
|-|-|
| Alice → Bob → Zed | Alice → {Bob, Charlie} → Zed |

</div>

作者指出，LN 原生支持多路径支付——它让一笔支付的每一部分共用同一个承诺原像（哈希锁）——但采用这种机制会让他人察觉自己正在处理同一笔支付的不同部分。随后他们描述了一套更复杂的协议，可以防止这种关联，还可能带来其他好处。无论采用较简单的办法还是较复杂的办法，都能显著提升 LN 的可用性，因为它消除了“用户必须拥有一条资金足够的单通道才能完成支付”这一限制。例如，在当前的协议下，如果 Alice 有两条通道，每条都有略多于 100 美元的可用额度，她单笔支付最多只能安全地付给 Zed 100 美元；而用多路径支付，Alice 把支付拆到两条通道上，就能付出 200 美元。

二月以一处颇具历史意味的对照收尾。早期比特币贡献者、已知第一位用比特币买披萨的 Laszlo Hanyecz，用 LN [购买][offchain pizza]了两份披萨，花了 6.49 mBTC——按 BTC 计价，这比他 2010 年 5 月[支付][onchain pizza] 1000 万 mBTC 买两份披萨便宜得多。

## 三月

许多比特币用户都熟悉这样一个功能：为自己的比特币地址生成签名消息。但目前还没有标准做法能为 P2SH 或 segwit 地址生成这类签名。三月的讨论最终演变成了 [BIP322][]：一项提出通用格式的提案，可为任何可花费的比特币脚本生成签名证明。

<div markdown="1" class="callout">

### 2018 年总结<br>热门基础设施项目的重要版本发布

- [Bitcoin Core 0.16][] 于二月发布，钱包默认支持接收 segwit 地址，支持 [BIP159][] 让被修剪的节点（pruned node）表明自己愿意提供近期区块，并包含多项性能改进。

- [LND 0.4-beta][] 于三月发布，是第一个面向主网支持的 LND 版本。它还支持使用 Bitcoin Core 作为后端、使用 Tor 建立连接，以及许多其他功能。

- [C-Lightning 0.6][] 于六月发布，降低了资源需求，提供了内置钱包，并增加了对 Tor 的支持。

- [LND 0.5-beta][] 于九月发布，包含许多旨在让系统可靠得多的改动。它还取消了对全节点后端保留交易索引的要求，从而提升性能并降低磁盘空间需求。

- [Bitcoin Core 0.17][] 于十月发布，包含可选的部分花费规避（partial spend avoidance）、动态创建并加载钱包的能力，以及 [BIP174][] 部分签名比特币交易（PSBT）支持，便于比特币程序之间通信。

</div>

## 四月

LN 协议开发者 Christian Decker、Rusty Russell 和 Olaoluwa Osuntokun 宣布了 [Eltoo][]——一种为 LN 提议的替代性执行机制。当前的机制（[LN-penalty][]）要求让旧的链下余额更新变得不安全，从而阻止用户试图把它们放到链上。Eltoo 机制则允许在有限的时间窗口内，用后来的余额更新来取代对某次旧余额更新的链上花费。正常运行时，各方通常只需把最终的通道余额发布到链上；即使某一方发布了旧余额，其通道对手方也只需再发一笔交易，把它更正为最终余额。双方除了已付的交易手续费之外不会有任何损失。

Eltoo 的优势在于，用户软件不必再管理那些“使旧余额更新变得不安全”的数据。这既简化了备份，也降低了数据丢失带来的风险——但或许最重要的是，它让许多用户之间在单笔链上交易中开通支付通道变得容易得多、计算上也高效得多。这为 [Channel Factories][] 等其他提案打下了基础，这些提案有望让 LN 通道的链上操作效率提高 10 倍甚至更多。

{:#sighash_noinput}
Eltoo 需要一次软分叉，新增一种可选的签名哈希：[BIP118][] SIGHASH_NOINPUT_UNSAFE[^fn-unsafe]。这样一来，授权花费某个 UTXO 的签名就可以表示：该签名不只适用于这一个 UTXO，而是适用于任何能用同一私钥的签名花费的 UTXO。此外，由于当前的节点中继策略允许[交易钉住][transaction pinning]，Eltoo 的发布机制[可能并不总能可靠地保证安全][eltoo pinning]。尽管如此，协议开发者对这一提案似乎相当乐观，许多人希望 noinput 特性能够纳入未来某个包含 schnorr 与 taproot 的软分叉提案。

## 五月

<div id="dandelion" markdown="1">

五月，一份蒲公英（Dandelion）协议的[草案 BIP][BIP156] 被发布到 Bitcoin-Dev 邮件列表。蒲公英能够私密地中继交易，使付款方的 IP 地址无法被可靠地识别。即使不使用 Tor 之类的办法，这一点也能成立；蒲公英还可以与 Tor 叠加使用，进一步降低隐私泄露的风险。蒲公英本身只对中继全节点的用户有完整好处（对 P2P 轻客户端[^fn-dandelion-lite]则不然），而且它需要配合某种形式的加密，才能防止 ISP 辨认出付款方。

然而，蒲公英在某种程度上依赖中继节点假装从未见过自己此前帮忙中继的交易。这使节点容易遭受拒绝服务攻击，攻击者可以白白消耗节点的带宽和内存——在采纳这一协议之前，开发者仍在[设法解决这些问题][daftuar dandelion]。

</div>

<div markdown="1" class="callout">

### 2018 年总结<br>值得注意的技术会议和其他事件

- [BPASE][bpase]，一月，斯坦福大学
- **<!--bitcoin-core-developers-meetup-nyc-->**[Bitcoin Core 开发者见面会 NYC][coredevtech nyc]，三月，纽约市（[会议记录][coredevtech ts]）
- [L2 Summit][]，五月，波士顿
- [Building on Bitcoin][]，七月，里斯本（[会议记录][bob ts]）
- [Edge Dev++][]，十月，东京（[视频][edge dev vids]、[会议记录][edge dev ts]）
- [Scaling Bitcoin Conference][]，十月，东京（[视频][scaling bitcoin vids]、[会议记录][scaling bitcoin ts]）
- **<!--bitcoin-core-developers-meetup-tokyo-->**[Bitcoin Core 开发者见面会东京][coredevtech tokyo]，十月，东京（[会议记录][coredevtech ts]）
- [Chaincode Lightning Residency][]，十月，纽约市（[视频][ln residency vids]）
- **<!--lightning-protocol-development-summit-->**[闪电协议开发峰会][lightning protocol development summit]，十一月，阿德莱德

</div>

## 六月

六月，Matt Corallo 公开宣布了他已悄悄做了一段时间的一个项目：一套新的通信协议，用于从矿池服务器向个体矿工、再向真正干活的 ASIC 下发任务。这套协议名为 [BetterHash][]，它把矿池的收益分配与交易选择分开。为什么这一点重要，今年晚些时候就有了例证：几家传统矿池[扬言][bitcoin.com forced bch mining]要把自己的比特币算力转去挖另一种竞争币——如果矿工使用 BetterHash，就能自动抵制这种做法。Corallo 为 BetterHash 提供了[草案 BIP][betterhash]和[可运行的实现][betterhash implementation]，后者还向下兼容目前占主导地位的 Stratum 挖矿通信协议。

{:#cve-2017-12842}
同一时间，一个早已为部分比特币协议开发者所知的[漏洞][sdl fake spv proof]被无意间公开了。[CVE-2017-12842][] 只要精心构造一笔真实的 64 字节交易并让它被打包进区块，就能为一笔并不存在的交易伪造出 SPV 证明。许多依赖 SPV 证明的轻钱包至今仍然受影响，但据估计，这种攻击的成本高于中本聪在 2009 年[比特币白皮书][bitcoin.pdf]第 8 节中描述的、针对信任 SPV 钱包的原始攻击，因此轻客户端的安全性似乎并未比以前明显降低。在其他把 SPV 证明与全节点配合使用的场景中（例如配合联邦侧链），Bitcoin Core 修改了相关 RPC，增加额外检查或提供额外信息，从而完全缓解了这一漏洞（见 PR [#13451][Bitcoin Core #13451] 和 [#13452][Bitcoin Core #13452]）。

有趣的是，由 Lightning K0ala 制作的 [satoshis.place][] 网站突然走红，成为人们用 LN 花掉真实比特币的一个好玩去处。数百名用户每像素支付 1 satoshi，在共享画布上随便画什么，极为生动地实时展示了 LN 支付的速度与便利。

## 七月

在[提前一年多预告][alert retirement alert]之后，七月一开头就[发布][alert key release]了此前用于签署比特币 P2P 网络上传播的警报消息的私钥。警报消息不只是向用户提示问题：在软件的某些较旧版本中，它还让持有警报私钥的人有能力实际上叫停比特币网络上的一切交易——对一个去中心化网络而言，这是令人担忧的权力集中。与这把私钥同时公布的，还有多个可借助警报私钥、针对旧版本节点实施的拒绝服务漏洞的细节。

好消息是，Pieter Wuille 发布了一份[草案 BIP][schnorr bip]，定义了基于 schnorr 的签名方案。其用意是：在可能的软分叉的其他细节仍在敲定之时，先让大家讨论——并希望达成一致——把 schnorr 加入比特币时这一部分该如何运作。所提议的格式将与现有的比特币私钥和公钥完全兼容，因此 HD 钱包无需重新生成恢复种子。签名会比现在大约小 10%，从而略微增加链上容量。签名还可以批量验证，速度约为逐个验证的 2 倍（即使逐个验证是并行进行的），这主要加快了落后节点追块时的区块验证。

这套签名方案与一月描述的 muSig 协议（或类似协议）兼容，因而也涵盖了后者在效率和隐私方面的好处。使用 schnorr 还能简化许多技术的实现，例如 taproot、Graftroot、更私密的 LN 支付通道、更私密的跨链原子交换、同一链上更私密的原子交换（从而改进 coinjoin），以及其他提升效率、隐私或两者兼具的改进。

<div id="p2ep" markdown="1">

与此同时，隐私圆桌会议的参与者描述了一种称为 Pay-to-EndPoint ([P2EP][]) 的方法，可以通过将有限形式的 coinjoin 应用于交互支付显著提高钱包对区块链分析的抵抗力。该提案的[简化形式][bustapay]也已被描述。该协议通过让交易的收款方将一些现有的比特币混入交易中，防止外部观察者能够自动假设交易的所有输入都来自同一个人。使用这种技术的人越多，输入关联假设就越不可靠——提升了所有比特币用户的隐私，而不仅仅是使用 P2EP 的人。

{% capture today-private %}输入：<br>&nbsp;&nbsp;Alice (2 BTC)<br>&nbsp;&nbsp;Alice (2 BTC)<br><br>输出：<br>&nbsp;&nbsp;Alice 的找零 (1 BTC)<br>&nbsp;&nbsp;Bob 的收入 (3 BTC){% endcapture %}
{% capture today-public %}输入：<br>&nbsp;&nbsp;付款方 (2 BTC)<br>&nbsp;&nbsp;付款方 (2 BTC)<br><br>输出：<br>&nbsp;&nbsp;付款方或收款方 (1 BTC)<br>&nbsp;&nbsp;付款方或收款方 (3 BTC){% endcapture %}
{% capture p2ep-private %}输入：<br>&nbsp;&nbsp;Alice (2 BTC)<br>&nbsp;&nbsp;Alice (2 BTC)<br>&nbsp;&nbsp;Bob (3 BTC)<br><br>输出：<br>&nbsp;&nbsp;Alice 的找零 (1 BTC)<br>&nbsp;&nbsp;Bob 的收入和找零 (6 BTC){% endcapture %}
{% capture p2ep-public %}输入：<br>&nbsp;&nbsp;付款方或收款方 (2 BTC)<br>&nbsp;&nbsp;付款方或收款方 (2 BTC)<br>&nbsp;&nbsp;付款方或收款方 (3 BTC)<br><br>输出：<br>&nbsp;&nbsp;付款方或收款方 (1 BTC)<br>&nbsp;&nbsp;付款方或收款方 (6 BTC){% endcapture %}

</div>

<div markdown="1" class="xoverflow shrink80">

| | Alice 和 Bob 知道的内容 | 网络看到的内容 |
|-|-|-|
| **当前常态** | {{today-private}} | {{today-public}} |
| **使用 P2EP** | {{p2ep-private}} | {{p2ep-public}} |

</div>

## 八月

长期致力于将加密技术引入比特币网络协议的工作在八月取得了新进展，Bitcoin Core 开启了一个 [PR][bitcoin core #14032] 并发布了一个修订版的 [BIP151][BIP151]。虽然使用 Tor 可以实现并推荐进行通信加密——这还可以提供其他好处——但默认启用加密可以帮助更多用户免受其 ISP 的窃听。

{:#countersign}
另外，Pieter Wuille 从二月起就在撰写一份[草案文档][untrackable auth]，其基础是他与 Gregory Maxwell 等人一直在开发的协议，目的是在加密之上再加一层可选的认证。与 [BIP150][] 类似，这将让在互联网上安全地配置白名单节点、或让轻量级钱包绑定到可信节点变得更容易。值得注意的是，目前的设计思路是：启用认证但不向第三方暴露身份，从而让身处匿名网络（如 Tor）的节点、或只是换了 IP 地址的节点，其网络身份都无法被追踪。尽管 Wuille 发现自己最初记录的提案存在缺陷，但随着协议研究的推进，该文档已经更新。

<div markdown="1" class="callout">

### 2018 年总结<br>Bitcoin Optech

自五月启动 [Optech][] 以来，我们已经签约了 15 家公司成为会员，举办了两次[工作坊][optech workshops]，制作了 28 期每周 [Newsletter][optech newsletters]，建立了一个[仪表盘][optech dashboard]，并在一本关于可独立部署的扩展技术的书籍上取得了扎实的开端。要了解我们在 2018 年取得的成就以及我们 2019 年的计划，请参阅我们的简短[年度报告][optech annual report]。

</div>

## 九月

九月的主要新闻是发现、[披露][core dup post]、修复和分析了 Bitcoin Core 0.14.0 到 0.16.2 未修补版本中的 [CVE-2018-17144][] 重复输入漏洞。该漏洞允许矿工创建一个区块，多次花费相同的比特币，从而导致比特币数量意外增加。这随后在测试网上被利用（暂时），展示了该漏洞，但没有将真实的比特币置于风险中。没有证据表明有人尝试对比特币主网进行攻击。任何使用 Bitcoin Core 0.16.3 或更高版本的用户不再面临风险。

最终，解决此类问题只能通过增加代码更改的审查和自动测试量来实现——为此，比特币需要更多的审查员、更多的测试编写者以及更多致力于雇用或赞助此类贡献者的组织。

## 十月

十月初举行的第五届 [Scaling Bitcoin 会议][Scaling Bitcoin conference]既介绍了比特币未来的新想法，又完善了现有的想法。在相关活动中，[立即实用的演讲][edge dev++]重点讨论了交易所安全性、钱包安全性以及安全处理区块链重组和分叉的问题。Bitcoin Core 开发者还[举行了会议][coredevtech tokyo]，让每位开发者有机会与其他开发者讨论他们当前的计划。

{:#splicing}
另外，LN 协议开发者 Rusty Russell 提出了一种[拼接][splicing]的方法，允许用户在不暂停该通道中的支付的情况下添加或减少通道中的资金。这特别有助于钱包隐藏管理余额的技术细节。例如，Alice 的钱包可以从同一条支付通道自动付给 Bob：链下就用 LN 通过该支付通道支付，链上就用拼接出（提现）从该支付通道支付。

<div markdown="1" class="callout">

### 2018 年总结<br>新的开源基础设施解决方案

- [Electrs][] 于七月发布，提供了用 Rust 编程语言编写的高效重实现的 Electrum 风格的交易查找服务器。资源需求显著低于替代方案。Electrum 风格的服务器为许多钱包和其他服务提供了后端支持。

- [Subzero][] 于十月由 Square 发布，提供了一套工具和文档，用于与硬件安全模块（HSM）一起使用进行密钥管理。它旨在帮助交易所和其他比特币托管机构安全地存储其比特币。

- [Esplora][] 于十二月由 Blockstream 发布，提供了区块浏览器的前端和后端代码。部分基于 Electrs，它支持主网、测试网和 Liquid 侧链。

</div>

## 十一月

LN 协议开发人员在十一月会面，决定为即将到来的闪电网络协议规范 1.1 采用哪些更改。[接受的更改][ln1.1 changes]主要集中在可用性改进上。二月份描述的多路径支付和十月份的拼接（splicing），一起可以使钱包几乎完全隐藏通道余额管理的复杂性。例如，Alice 只需点击一次（理想情况下），就能从她的任意通道组合中付给 Bob，最多可接近其全部钱包余额，无论这笔支付是链下还是链上。

其他接受的更改包括增加最大通道容量、双向资助通道（dual-funded channels）以帮助企业改善其 LN 用户体验以及隐藏目的地（hidden destinations），即使在为任意不可信的付款方路由支付时也可以帮助节点保持隐藏。这些话题以及其他许多话题，都在 [Lightning-Dev 邮件列表][ln list november] 上讨论过——这是该列表有史以来最繁忙的一个月。

其中一个期望的更改需要对 Bitcoin Core 的中继策略进行调整。LN 开发者希望链下支付在通道使用期间承诺一个最小的链上手续费金额。当通道关闭时，他们希望使用手续费追加（fee bumping）根据当前网络状况设置合适的手续费。由于 Bitcoin Core 中有些防止拒绝服务攻击的代码，会让手续费追加在对抗性情况下变得不可靠，要做到这一点并不容易；不过协议开发者 Matt Corallo 已[提出][cpfp carve out]一项新规则，可能安全地允许在双边 LN 支付的情况下进行手续费追加。

## 十二月

{:#libminisketch}
Pieter Wuille、Gregory Maxwell 和 Gleb Naumenko 研究了如何减少用于中继比特币交易的数据量。他们的初步结果是 [libminisketch][]，一个允许一个用户将一组元素（例如 {1, 2, 3}）的缺失元素高效地发送给只有部分该组元素的另一个用户（例如 {1, 3}）的库。无需更改比特币共识——这只是传输相同信息的不同方式。如果实现用于中继，可以在典型情况下将整体节点带宽减少 [40% 到 80%][wuille minisketch savings]。它还保持低带宽，即使连接数增加，也可能允许节点与更多对等方连接，以提高 P2P 中继网络的稳健性。

最后，在 2018 年即将结束时，开发人员继续讨论如何将 Schnorr 签名、Taproot MAST、SIGHASH_NOINPUT_UNSAFE 和其他更改集成到一个具体的软分叉提案中。协议开发者 Anthony Towns 简明[总结][schnorr and more]了如果今天发布提案，可能包含的内容。

<div markdown="1" class="callout">

### 2018 年总结<br>手续费减少技术的使用

![2018 年压缩公钥、segwit、支付批处理与自愿启用 RBF 的使用情况图](/img/posts/2018-12-overall.png)

我们调查了各种[减少交易手续费的技术][techniques for reducing transaction fees]，其使用情况可以通过查看确认的交易轻松跟踪。

- **<!--compressed-pubkeys-->****压缩公钥** 每次使用可节省 32 字节，自 [2012 年以来][Bitcoin Core 0.6] 得到了广泛使用。使用压缩公钥的输入数量从一月份的约 96% 上升到十二月份的 98%。

- **<!--segwit-spends-->****Segwit 支出** 可将见证数据对手续费的影响减少最多 75%，具体取决于 segwit 的使用方式（见下图）。使用 segwit 的输入数量从一月份的约 10% 上升到十二月份的 38%。

- **<!--batched-payments-->****批量支付** 将输入或输入集的大小和手续费开销分摊到更多的输出上，使其成为高频付款方（如交易所）[节省最多 80% 手续费][payment batching]的绝佳方式。全年向三个或更多输出支付的交易数量徘徊在 11% 左右。注意：这种启发式判断还包括 coinjoin 交易和其他严格来说不属于批量支付的技术。

- **<!--opt-in-rbf-->****自愿启用的 RBF**（Replace-by-Fee） 允许高效的手续费追加，使付款方可以从低手续费开始，然后再增加出价。信号 RBF 的交易数量从一月份的约 4% 上升到十二月份的 6%。

![2018 年包装 segwit 与原生 segwit 的使用情况图](/img/posts/2018-12-segwit.png)

Segwit 支出有两类：

- **<!--nested-->****嵌套** segwit 将扩展机制放在向后兼容的 P2SH 脚本内，使其与几乎所有软件兼容，但无法实现其全部效率。使用嵌套 segwit 的输入数量从一月份的约 10% 上升到十二月份的 33%。

- **<!--native-->****原生** segwit 更高效，但仅与支持发送到 segwit 地址的钱包兼容。原生 segwit 输入的数量从一月份的几乎 0% 上升到十二月份的约 5%。

![2018 年每区块 UTXO 集变化图](/img/posts/2018-12-utxo.png)

我们调查的最后一种手续费减少技术是未确认交易输出（UTXO）集大小的每块变化。减少表明比特币合并为更大的币，这些币以后可以更高效地使用。总的来说，今年 UTXO 集大小减少了约 1200 万条目。

![区块大小占最大允许区块大小百分比的图](/img/posts/2018-12-weight.png)

总体而言，今年使用的区块空间平均量很少接近协议允许的最大值，但直到十二月初似乎都在向最大值靠近。如果这种趋势恢复，并且 2019 年区块再次变得持续满载——就像 2017 年那样——手续费可能会上升，实施手续费减少技术的钱包和企业可能能够为其用户提供比未优化竞争对手低得多的成本。

*以上所有图表的数据由每个区块内收集的值组成，并用覆盖 1,000 个区块的简单移动平均做了平滑处理。空块（仅有一个生成交易的块）未纳入分析。大多数上述统计数据可从 [Optech 仪表盘][Optech Dashboard] 获取，该仪表盘在每个区块后更新。注意：2019 年 1 月 1 日后，我们将更新本文中的图表以反映整个 2018 年，届时将删除此句。*
</div>

## 总结

我们有时会听到人们请求比特币未来发展的路线图，但回顾 2018 年的发展情况表明，发布这样的文档是多么徒劳。上面描述的许多发展都是我们怀疑即使是最先进的协议开发人员也无法在一年前预测的。因此，我们不知道 2019 年比特币开发的具体情况——但我们期待发现。

*Optech Newsletter 将于 1 月 8 日恢复其每周二的常规出版时间表。你可以[通过电子邮件订阅][optech newsletters]或关注我们的 [RSS feed][]。*

## 脚注

[^fn-dandelion-lite]:
    使用比特币 P2P 网络的轻客户端不为其他用户中继交易——它们只发送自己的交易。这意味着从 P2P 轻客户端发送的任何交易都可以与客户端的网络身份（例如 IP 地址）相关联。蒲公英只是一个路由协议，因此无法消除这种隐私泄漏。相反，P2P 轻客户端应始终使用匿名网络（如 Tor）发送交易（并且应为每次支出交易使用不同的一次性网络身份）。

[^fn-opcodes]:
    Schnorr 签名提案可能不使用与当前脚本相同的操作码，但单签名、使用类似 muSig 的多重签名以及使用类似 Taproot 的合作 MAST 都可以使用相同的格式。

[^fn-mast]:
    也称为*Merkle 化抽象语法树*，因为 Russell O'Connor 的原始想法将默克尔树的加密承诺结构与抽象语法树的编程语言分析技术结合起来，提供了一种紧凑地承诺复杂脚本的方法，其元素和结果可以从不同的分支组合起来。后来的简化版本删除了这种组合的潜力，因此最近的提案不像抽象语法树，导致 O'Connor 和其他人不鼓励在新想法中使用原始术语。然而，“MAST”这一缩写至少自 [2013 年][todd mast] 起就已被用来指代这项基本技术，因此我们选择采用 Anthony Towns 的[提议][mast backronym]的回溯首字母缩略词，*Merkle 化替代脚本树*。

[^fn-unsafe]:
    [BIP118][] SIGHASH_NOINPUT_UNSAFE 接受了不安全的称号，因为其天真的使用可能导致资金丢失。例如，Alice 收到 1 BTC 到她的一个地址。然后她在签名将这些资金支付给 Bob 时使用 noinput。后来，Alice 收到另一个 1 BTC 到同一个地址。这允许之前交易的签名被重用于将 Alice 的新 1 BTC 发送给 Bob。BIP118 的共同作者 Christian Decker [同意][decker unsafe] 将操作码标记为*不安全*，以鼓励开发人员在使用该标志之前了解这一安全问题。一个设计良好的程序可以通过谨慎处理其签名内容和向用户公开的接收地址安全地使用 noinput。

[^fn-harding-mast]:
    此示例不对应于任何特定的 MAST 提案，而是提供了 MAST 工作所需的最少数据的简单视图。有关实际提案，请参阅 BIP [114][BIP114]、[116][BIP116] 和 [117][BIP117]。


{% include linkers/issues.md issues="13451,13452,14032" %}
{% include references.md %}

[alert key release]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016189.html
[alert retirement alert]: https://bitcoin.org/en/alert/2016-11-01-alert-retirement
[betterhash]: https://github.com/TheBlueMatt/bips/blob/master/bip-XXXX.mediawiki
[betterhash implementation]: https://github.com/TheBlueMatt/mining-proxy
[bitcoin core 0.16]: https://bitcoincore.org/en/releases/0.16.0/
[bitcoin core 0.17]: https://bitcoincore.org/en/releases/0.17.0/
[bob ts]: https://diyhpl.us/wiki/transcripts/building-on-bitcoin/2018/
[bpase]: https://cyber.stanford.edu/bpase18
[building on bitcoin]: https://building-on-bitcoin.com/
[bustapay]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016340.html
[chaincode lightning residency]: https://lightningresidency.com/
[channel factories]: https://www.tik.ee.ethz.ch/file/a20a865ce40d40c8f942cf206a7cba96/Scalable_Funding_Of_Blockchain_Micropayment_Networks.pdf
[c-lightning 0.6]: https://github.com/ElementsProject/lightning/releases/tag/v0.6
[coredevtech nyc]: https://coredev.tech/2018_newyork.html
[coredevtech tokyo]: https://coredev.tech/2018_tokyo.html
[coredevtech ts]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/
[core dup post]: https://bitcoincore.org/en/2018/09/20/notice/
[cpfp carve out]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016518.html
[edge dev++]: https://keio-devplusplus-2018.bitcoinedge.org/
[edge dev ts]: http://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/edgedevplusplus/
[edge dev vids]: https://www.youtube.com/channel/UCywSzGiWWcUG1gTp45YdPUQ/videos
[electrs]: https://github.com/romanz/electrs
[eltoo]: https://blockstream.com/eltoo.pdf
[eltoo pinning]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-June/001316.html
[esplora]: https://blockstream.com/2018/12/06/esplora-source-announcement/
[graftroot]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-February/015700.html
[l2 summit]: https://medium.com/mit-media-lab-digital-currency-initiative/the-importance-of-layer-2-105189f72102
[lightning protocol development summit]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001569.html
[ln1.1 changes]: https://github.com/lightningnetwork/lightning-rfc/wiki/Lightning-Specification-1.1-Proposal-States
[lnd 0.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.4-beta
[lnd 0.5-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.5-beta
[ln list november]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/thread.html
[ln multipath]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-February/000993.html
[ln-penalty]: https://lightning.network/lightning-network-paper.pdf
[ln residency vids]: https://lightningresidency.com/#videos
[mast]: https://bitcointechtalk.com/what-is-a-bitcoin-merklized-abstract-syntax-tree-mast-33fdf2da5e2f
[musig]: https://www.blockstream.com/2018/01/23/musig-key-aggregation-schnorr-signatures/
[offchain pizza]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-February/001044.html
[onchain pizza]: https://en.bitcoin.it/wiki/Laszlo_Hanyecz
[optech]: /
[optech annual report]: /en/2018-optech-annual-report/
[optech dashboard]: https://dashboard.bitcoinops.org/
[optech newsletters]: /en/newsletters/
[optech workshops]: /en/workshops/
[p2ep]: https://blockstream.com/2018/08/08/improving-privacy-using-pay-to-endpoint/
[satoshis.place]: https://satoshis.place/
[scaling bitcoin conference]: https://tokyo2018.scalingbitcoin.org/
[scaling bitcoin ts]: https://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/
[scaling bitcoin vids]: https://tokyo2018.scalingbitcoin.org/#remote-participation
[schnorr and more]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016556.html
[schnorr bip]: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki
[sdl fake spv proof]: https://bitslog.wordpress.com/2018/06/09/leaf-node-weakness-in-bitcoin-merkle-tree-design/
[splicing]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001434.html
[subzero]: https://medium.com/square-corner-blog/open-sourcing-subzero-ee9e3e071827
[taproot]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-January/015614.html
[transaction pinning]: https://bitcoin.stackexchange.com/questions/80803/what-is-meant-by-transaction-pinning/80804#80804
[untrackable auth]: https://gist.github.com/sipa/d7dcaae0419f10e5be0270fada84c20b
[mast backronym]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016500.html
[todd mast]: https://bitcointalk.org/index.php?topic=255145.msg2757327#msg2757327
[daftuar dandelion]: https://bitcoin.stackexchange.com/a/81504/26940
[bitcoin.com forced bch mining]: https://www.reddit.com/r/Bitcoin/comments/9x2jub/warning_if_you_have_any_bitcoin_hashing_power/
[wuille minisketch savings]: https://twitter.com/pwuille/status/1075460072786935808
[decker unsafe]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016193.html
[bitcoin core 0.6]: https://bitcoin.org/en/release/v0.6.0
[techniques for reducing transaction fees]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees
[payment batching]: https://bitcointechtalk.com/saving-up-to-80-on-bitcoin-transaction-fees-by-batching-payments-4147ab7009fb
[towns consolidation]: /en/xapo-utxo-consolidation/
[cve-2017-12842]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-12842
[cve-2018-17144]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-17144
