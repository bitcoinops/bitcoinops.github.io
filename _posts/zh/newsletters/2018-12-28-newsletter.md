---
title: 'Bitcoin Optech Newsletter #27: 2018 年终特别总结'
permalink: /zh/newsletters/2018/12/28/
name: 2018-12-28-newsletter-zh
slug: 2018-12-28-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 是特别的年终版本，总结了 2018 年比特币中的一些值得注意的发展。尽管这个 Newsletter 篇幅较长，我们遗憾地只能覆盖数百名贡献者在数十个开源项目中投入的工作的一小部分。没有这些低层次的贡献，这个 Newsletter 中描述的高层概念就只是空话，因此我们向今年为比特币开发做出贡献的所有人表示最诚挚的感谢。

## 一月

在今年年初之前，测试网上已经有数百个闪电网络通道开放，但在 2018 年 1 月，少数企业和用户开始使用主网上的比特币进行 LN 支付。先驱者们将自己的行为标记为 *#reckless*（鲁莽），但这并没有阻止其他实验者在这个新兴支付网络上冒险使用真金白银。

本月还发布了由 Gregory Maxwell、Andrew Poelstra、Yannick Seurin 和 Pieter Wuille 撰写的基于 Schnorr 的 [muSig][] 交互式多方签名协议。这提供了与比特币当前多重签名相同的安全性，但通常可以将所需的交易数据量减少到单个普通的公钥和签名。这不仅减少了开销和成本，还通过使基本多重签名交易看起来与单签名交易相同来提高隐私性。

<div markdown="1" class="xoverflow shrink80">

| | 接收脚本 | 支出数据 |
|-|-|-|
| **单签名，当前脚本（P2PK）** | `<pubkey> OP_CHECKSIG` | `<signature>` |
| **裸多重签名，当前脚本** | `2 <pubkey> <pubkey> <pubkey> 3 OP_CHECKMULTISIG` | `OP_0 <signature> <signature>` |
| **多重签名，muSig[^fn-opcodes]** | `<pubkey> OP_CHECKSIG` | `<signature>` |

</div>

{:#taproot}
基于 muSig 或类似的东西在比特币中变得可能的想法，Maxwell 进一步描述了 [Taproot][]——一种对 Merklized Alternative Script Trees[^fn-mast]（[MAST][]）的强大优化。就像 muSig 允许基本多重签名看起来像单签名一样，Taproot 允许即使是最复杂的比特币脚本在其参与者互相合作的情况下也看起来像单签名（但如果他们不合作，他们仍然可以获得他们选择的脚本的全部安全性）。这为更多用户提供了减少开销、降低成本和提高隐私性的机会。

<div markdown="1" class="xoverflow shrink80">

| | 接收脚本 | 支出数据 |
|-|-|-|
| **单用户，当前脚本（P2PK）** | `<pubkey> OP_CHECKSIG` | `<signature>` |
| **合作用户，早期 MAST 提案[^fn-harding-mast]** | `<hash> OP_MAST` | `<signature> <<pubkey> OP_CHECKSIG> <hash> <flags>` |
| **合作用户，Taproot[^fn-opcodes]** | `<pubkey> OP_CHECKSIG` | `<signature>` |

</div>

## 二月

仿佛 Taproot 的潜在好处还不够，二月看到 Gregory Maxwell 描述了一种称为 [Graftroot][] 的构造，它允许当前被授权使用硬币的人创建额外的一套条件来允许使用这些硬币——无需创建新交易。在任何时候，任何授权的条件集都可以用来使用这些硬币。例如，如果一个硬币目前可以通过 Alice 和 Bob 的协议（2-of-2 多重签名）来使用，他们都可以同意允许它通过 Alice、Bob 或他们的律师 Charlie 中的任何两个来使用（2-of-3 多重签名）——他们可以在第一次接收硬币后多年做出这个选择，而无需创建新交易。这可以进一步提高效率和隐私，特别是对于某些链下合约协议。

{:#multipath-payments}
同时，LN 协议开发人员 Olaoluwa Osuntokun 和 Conner Fromknecht 描述了一种在 LN 上进行多路径支付的新方法。多路径支付是通过多个通道分割支付的部分。例如，Alice 可以通过她与 Bob 的通道发送部分支付给 Zed，并通过她与 Charlie 的通道发送另一部分支付。

<div markdown="1" class="xoverflow shrink80">

| 单一路径 | 多路径 |
|-|-|
| Alice → Bob → Zed | Alice → {Bob, Charlie} → Zed |

</div>

作者指出，LN 通过为每部分支付使用相同的承诺预映像（哈希锁）提供了对多路径支付的本地支持，但使用这种机制允许第三方检测他们正在处理同一支付的不同部分。然后他们描述了一种更复杂的协议，可以防止这种关联并可能提供其他好处。无论是使用简单的方法还是复杂的方法，任何一种都可以显著增强 LN 的可用性，消除用户必须拥有一个具有足够资金的单个通道来进行支付的限制。例如，在当前协议中，如果 Alice 有两个通道，每个通道都有略高于 100 美元的可用资金，她只能安全地发送最多 100 美元的单笔支付给 Zed。通过多路径支付，Alice 可以通过分割支付在两个通道上发送 200 美元。

二月以一些历史的平行事件结束。早期比特币贡献者、第一位已知的用比特币买披萨的人 Laszlo Hanyecz 使用 LN [购买][offchain pizza]了两份披萨，花费了 6.49 mBTC——比他在 2010 年 5 月用链上[支付][onchain pizza]的 1000 万 mBTC 购买两份披萨的价格要低得多。

## 三月

许多比特币用户都熟悉能够创建与其比特币地址对应的签名消息。目前还没有标准的方法来使用 P2SH 或 segwit 地址进行签名。三月的讨论最终变成了 [BIP322][]，提出了一个通用格式，能够为任何可支配的比特币脚本创建签名证明。

<div markdown="1" class="callout">

### 2018 年总结<br>热门基础设施项目的主要发布

- [Bitcoin Core 0.16][] 在二月发布，钱包默认支持接收 segwit 地址、支持 [BIP159][] 允许修剪节点信号表示其愿意提供最近区块，并进行了许多性能改进。

- [LND 0.4-beta][] 在三月发布，是第一个针对主网支持的 LND 版本。它还支持使用 Bitcoin Core 作为后端、使用 Tor 进行连接以及许多其他功能。

- [C-Lightning 0.6][] 在六月发布，减少了资源需求，提供了内置钱包，并增加了对 Tor 的支持。

- [LND 0.5-beta][] 在九月发布，包含许多旨在使系统更可靠的更改。它还取消了对完整节点后端保留交易索引的要求，提高了性能并减少了磁盘空间需求。

- [Bitcoin Core 0.17][] 在十月发布，包含可选的部分支出避免功能、动态创建和加载钱包的能力以及 [BIP174][] 支持部分签名比特币交易，以便比特币程序之间进行通信。

</div>

## 四月

LN 协议开发人员 Christian Decker、Rusty Russell 和 Olaoluwa Osuntokun 宣布了 [Eltoo][]，一种 LN 的替代强制机制的提议。当前机制（[LN-penalty][]）要求使以前的链下余额更新变得不安全，以防用户尝试将其放到链上。Eltoo 机制允许在有限的时间窗口内将以前的余额更新链上支付给后来的余额更新。在正常操作中，各方通常只会在链上发布最终通道余额，但即使一方发布了旧余额，其通道对手方也可以简单地发布第二笔交易，将其纠正为最终余额。双方都不会失去任何东西，只有支付的交易费用。

Eltoo 的优势在于用户软件不需要管理使早期余额更新不安全的数据。这简化了备份并降低了与数据丢失相关的风险——但或许最重要的是，它使得支付通道在单笔链上交易中更容易和计算效率更高地在许多用户之间打开。这为其他提案（如 [Channel Factories][]）奠定了基础，这些提案可以使 LN 通道在链上操作中的效率提高 10 倍或更多。

{:#sighash_noinput}
Eltoo 需要一个新的可选签名哈希的软分叉，[BIP118][] SIGHASH_NOINPUT_UNSAFE[^fn-unsafe]。这将允许授权花费 UTXO 的签名表明签名不仅适用于该 UTXO，还适用于任何可以由同一私钥签名花费的 UTXO。此外，Eltoo 的发布机制[可能不可靠安全][eltoo pinning]，因为当前的节点中继策略允许[交易固定][transaction pinning]。尽管如此，协议开发人员对该提案持乐观态度，许多人希望 noinput 功能可以成为未来可能的 Schnorr 和 Taproot 软分叉提案的一部分。

## 五月

<div id="dandelion" markdown="1">

五月，一份[蒲公英协议的草案][BIP156] 发布到 Bitcoin-Dev 邮件列表。蒲公英 可以私密地中继交易，使得无法可靠地确定支出者的 IP 地址。即使不使用类似 Tor 的方法，这也能奏效，并且蒲公英可以与 Tor 结合使用，进一步降低隐私泄露的风险。蒲公英本身仅对中继全节点（非 P2P 轻客户端[^fn-dandelion-lite]）用户完全有利，需要与某种形式的加密结合，以防止 ISP 能够识别支出者。

然而，蒲公英部分依赖中继节点假装它们从未见过之前帮助中继的交易。这使得节点容易受到拒绝服务攻击，攻击者可以浪费节点的带宽和内存——开发人员仍在[解决这些问题][daftuar dandelion]，以便采用该协议。

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

六月，Matt Corallo 公开宣布了他工作了一段时间的新项目：从矿池服务器到个体矿工再到实际工作的 ASIC 的新通信协议。名为 [BetterHash][]，该协议将矿池支付与交易选择分离。为什么这很重要的一个例子是，今年晚些时候，一些传统矿池[威胁][bitcoin.com forced bch mining]将其比特币哈希率重定向到工作在一种替代币上——使用 BetterHash 的矿工可以自动抵制这种行为。Corallo 提供了 BetterHash 的[草案 BIP][betterhash]和[工作实现][betterhash implementation]，包括与主导的 Stratum 挖矿通信协议的向后兼容性。

{:#cve-2017-12842}
与此同时，一个[漏洞][sdl fake spv proof]被无意中公开披露，这是一些比特币协议开发人员长期以来已知的。[CVE-2017-12842][] 使得可以通过专门构造的真实 64 字节交易创建一个不存在的交易的 SPV 证明，并确认在一个区块中。许多依赖 SPV 证明的轻钱包即使在今天仍然容易受到攻击，但攻击成本比中本聪在 2009 年的[比特币白皮书][bitcoin.pdf]第 8 节中描述的针对 SPV 信任钱包的原始攻击更昂贵，因此轻客户端似乎并没有显著降低安全性。对于与完整节点结合使用的其他情况下，如与联合侧链一起使用，比特币核心修改其 RPCs 以执行额外检查或提供额外信息，完全缓解该漏洞（见 PRs [#13451][Bitcoin Core #13451] 和 [#13452][Bitcoin Core #13452]）。

有趣的是，[satoshis.place][] 网站由 Lightning K0ala 创立，迅速流行起来，成为使用 LN 进行实际比特币支付的有趣场所。数百名用户每像素支付一个聪，在共享画布上绘制任何他们想要的东西，提供了 LN 支付速度和便利性的惊人有效实时演示。

## 七月

经过一年多的[提前通知][alert retirement alert]，七月开始[发布][alert key release]之前用于签署通过比特币 P2P 网络传播的警报消息的私钥。警报消息不仅警告用户有关问题，还在软件的某些旧版本中赋予拥有警报密钥的人有效地停止比特币网络上所有商业活动的能力——对于去中心化网络来说，这是一个令人担忧的权力集中。与密钥同时发布的是对使用警报密钥可以执行的多个拒绝服务漏洞的详细信息。

一个积极的消息是，Pieter Wuille 发布了一个[草案 BIP][schnorr bip]，定义了一个基于 Schnorr 的签名方案，目的是允许每个人讨论并希望就将 Schnorr 添加到比特币中的这一方面达成一致，而其他可能的软分叉细节仍在研究中。提议的格式将与现有的比特币私钥和公钥完全兼容，因此 HD 钱包不需要生成新的恢复种子。签名将大约小 10%，稍微增加链上容量。签名还可以在批量验证时比单独验证快约 2 倍，甚至在并行情况下，主要加速了节点追赶区块的验证。

签名方案与一月描述的 muSig 协议（或类似协议）兼容，因此包含了提高效率和隐私的好处。使用 Schnorr 还简化了 Taproot、Graftroot、更私密的 LN 支付通道、更私密的跨链原子交换、同链上的更私密的原子交换（提供改进的 coinjoin）和其他提高效率、隐私或两者的技术的实现。

<div id="p2ep" markdown="1">

与此同时，隐私圆桌会议的参与者描述了一种称为 Pay-to-EndPoint ([P2EP][]) 的方法，可以通过将有限形式的 coinjoin 应用于交互支付显著提高钱包对区块链分析的抵抗力。该提案的[简化形式][bustapay]也已被描述。该协议通过让交易的接收者将一些现有的比特币混入交易中，防止外部观察者能够自动假设交易的所有输入都来自同一个人。使用这种技术的人越多，输入关联假设就越不可靠——提高了所有比特币用户的隐私，而不仅仅是使用 P2EP 的人。

{% capture today-private %}输入：<br>&nbsp;&nbsp;Alice (2 BTC)<br>&nbsp;&nbsp;Alice (2 BTC)<br><br>输出：<br>&nbsp;&nbsp;Alice 的找零 (1 BTC)<br>&nbsp;&nbsp;Bob 的收入 (3 BTC){% endcapture %}
{% capture today-public %}输入：<br>&nbsp;&nbsp;支出者 (2 BTC)<br>&nbsp;&nbsp;支出者 (2 BTC)<br><br>输出：<br>&nbsp;&nbsp;支出者或接收者 (1 BTC)<br>&nbsp;&nbsp;支出者或接收者 (3 BTC){% endcapture %}
{% capture p2ep-private %}输入：<br>&nbsp;&nbsp;Alice (2 BTC)<br>&nbsp;&nbsp;Alice (2 BTC)<br>&nbsp;&nbsp;Bob (3 BTC)<br><br>输出：<br>&nbsp;&nbsp;Alice 的找零 (1 BTC)<br>&nbsp;&nbsp;Bob 的收入和找零 (6 BTC){% endcapture %}
{% capture p2ep-public %}输入：<br>&nbsp;&nbsp;支出者或接收者 (2 BTC)<br>&nbsp;&nbsp;支出者或接收者 (2 BTC)<br>&nbsp;&nbsp;支出者或接收者 (3 BTC)<br><br>输出：<br>&nbsp;&nbsp;支出者或接收者 (1 BTC)<br>&nbsp;&nbsp;支出者或接收者 (6 BTC){% endcapture %}

</div>

<div markdown="1" class="xoverflow shrink80">

| | Alice 和 Bob 知道的内容 | 网络看到的内容 |
|-|-|-|
| **当前规范** | {{today-private}} | {{today-public}} |
| **使用 P2EP** | {{p2ep-private}} | {{p2ep-public}} |

</div>

## 八月

长期致力于将加密技术引入比特币网络协议的工作在八月取得了新进展，Bitcoin Core 开启了一个 [PR][bitcoin core #14032] 并发布了一个修订版的 [BIP151][BIP151]。虽然使用 Tor 可以实现并推荐进行通信加密——这还可以提供其他好处——但默认启用加密可以帮助更多用户免受其 ISP 的窃听。

{:#countersign}
另外，Pieter Wuille 自二月以来一直在基于他、Gregory Maxwell 和其他人开发的协议撰写一个[草案文件][untrackable auth]，允许在加密之上进行可选的认证。类似于 [BIP150][]，这将使在互联网或绑定到可信节点的轻量级钱包中更容易安全地设置白名单节点。值得注意的是，这个当前的想法是启用认证而不向第三方透露身份，以便在匿名网络（如 Tor）上的节点或简单更改 IP 地址的节点不会被追踪其网络身份。尽管 Wuille 发现了他最初记录的提案中的缺陷，但随着开发协议的研究推进，提案已被更新。

<div markdown="1" class="callout">

### 2018 年总结<br>Bitcoin Optech

自五月启动 [Optech][] 以来，我们已经签约了 15 家公司成为会员，举办了两次[研讨会][optech workshops]，制作了 28 期每周 [Newsletter][optech newsletters]，建立了一个[仪表盘][optech dashboard]，并在一本关于可独立部署的扩展技术的书籍上取得了扎实的开端。要了解我们在 2018 年取得的成就以及我们 2019 年的计划，请参阅我们的简短[年度报告][optech annual report]。

</div>

## 九月

九月的主要新闻是发现、[披露][core dup post]、修复和分析了 Bitcoin Core 0.14.0 到 0.16.2 未修补版本中的 [CVE-2018-17144][] 重复输入漏洞。该漏洞允许矿工创建一个区块，多次花费相同的比特币，从而导致比特币数量意外增加。这随后在测试网上被利用（暂时），展示了该漏洞，但没有将真实的比特币置于风险中。没有证据表明有人尝试对比特币主网进行攻击。任何使用 Bitcoin Core 0.16.3 或更高版本的用户不再面临风险。

最终，解决此类问题只能通过增加代码更改的审查和自动测试量来实现——为此，比特币需要更多的审查员、更多的测试编写者以及更多致力于雇用或赞助此类贡献者的组织。

## 十月

十月初举行的第五届 [Scaling Bitcoin 会议][Scaling Bitcoin conference]既介绍了比特币未来的新想法，又完善了现有的想法。在相关活动中，[立即实用的演讲][edge dev++]重点讨论了交易所安全性、钱包安全性以及安全处理区块链重组和分叉的问题。Bitcoin Core 开发者还[举行了会议][coredevtech tokyo]，让每位开发者有机会与其他开发者讨论他们当前的计划。

{:#splicing}
另外，LN 协议开发者 Rusty Russell 提出了一种[拼接][splicing]的方法，允许用户在不暂停该通道中的支付的情况下添加或减少通道中的资金。这特别有助于钱包隐藏管理余额的技术细节。例如，Alice 的钱包可以自动从同一个支付通道中链下使用 LN 通过该支付通道支付给 Bob 或链上使用拼接出（提现）从该支付通道支付给 Bob。

<div markdown="1" class="callout">

### 2018 年总结<br>新的开源基础设施解决方案

- [Electrs][] 于七月发布，提供了用 Rust 编程语言编写的高效重实现的 Electrum 风格的交易查找服务器。资源需求显著低于替代方案。Electrum 风格的服务器为许多钱包和其他服务提供了后端支持。

- [Subzero][] 于十月由 Square 发布，提供了一套工具和文档，用于与硬件安全模块（HSM）一起使用进行密钥管理。它旨在帮助交易所和其他比特币托管机构安全地存储其比特币。

- [Esplora][] 于十二月由 Blockstream 发布，提供了区块浏览器的前端和后端代码。部分基于 Electrs，它支持主网、测试网和 Liquid 侧链。

</div>

## 十一月

LN 协议开发人员在十一月会面，决定为即将到来的闪电网络协议规范 1.1 采用哪些更改。[接受的更改][ln1.1 changes]主要集中在可用性改进上。二月份描述的多路径支付和十月份的拼接（splicing），一起可以使钱包几乎完全隐藏通道余额管理的复杂性。例如，Alice 只需一次点击（理想情况下）就可以从她的任何通道组合中支付给 Bob，几乎达到了她的全部钱包余额，无论她是链下还是链上支付给他。

其他接受的更改包括增加最大通道容量、双向资金通道（dual-funded channels）以帮助企业改善其 LN 用户体验以及隐藏目的地（hidden destinations），即使在为任意不可信的支出者路由支付时也可以帮助节点保持隐藏。邮件列表上的[讨论][ln list november]，这是 Lightning-Dev 邮件列表历史上最繁忙的一个月。

其中一个期望的更改需要对 Bitcoin Core 的中继策略进行调整。LN 开发者希望链下支付在通道使用期间承诺一个最小的链上手续费金额。当通道关闭时，他们希望使用手续费提升（fee bumping）根据当前网络状况设置合适的手续费。由于 Bitcoin Core 中的一些代码用于防止拒绝服务攻击，这使得在对抗性情况下手续费提升不可靠，协议开发者 Matt Corallo 已[提出][cpfp carve out]一项新规则，可能安全地允许在双边 LN 支付情况下进行手续费提升。

## 十二月

{:#libminisketch}
Pieter Wuille、Gregory Maxwell 和 Gleb Naumenko 研究了如何减少用于中继比特币交易的数据量。他们的初步结果是 [libminisketch][]，一个允许一个用户将一组元素（例如 {1, 2, 3}）的缺失元素高效地发送给只有部分该组元素的另一个用户（例如 {1, 3}）的库。无需更改比特币共识——这只是传输相同信息的不同方式。如果实现用于中继，可以在典型情况下将整体节点带宽减少 [40% 到 80%][wuille minisketch savings]。它还保持低带宽，即使连接数增加，也可能允许节点与更多对等方连接，以提高 P2P 中继网络的稳健性。

最后，在 2018 年即将结束时，开发人员继续讨论如何将 Schnorr 签名、Taproot MAST、SIGHASH_NOINPUT_UNSAFE 和其他更改集成到一个具体的软分叉提案中。协议开发者 Anthony Towns 简明[总结][schnorr and more]了如果今天发布提案，可能包含的内容。

<div markdown="1" class="callout">

### 2018 年总结<br>手续费减少技术的使用

![Plot of compressed pubkey, segwit, payment batching, and opt-in RBF use in 2018](/img/posts/2018-12-overall.png)

我们调查了各种[减少交易手续费的技术][techniques for reducing transaction fees]，其使用情况可以通过查看确认的交易轻松跟踪。

- **<!--compressed-pubkeys-->****压缩公钥** 每次使用可节省 32 字节，自 [2012 年以来][Bitcoin Core 0.6] 得到了广泛使用。使用压缩公钥的输入数量从一月份的约 96% 上升到十二月份的 98%。

- **<!--segwit-spends-->****Segwit 支出** 可将见证数据对手续费的影响减少最多 75%，具体取决于 segwit 的使用方式（见下图）。使用 segwit 的输入数量从一月份的约 10% 上升到十二月份的 38%。

- **<!--batched-payments-->****批量支付** 将输入或输入集的大小和手续费开销分摊到更多的输出上，使其成为高频支付者（如交易所）[节省最多 80% 手续费][payment batching]的绝佳方式。全年向三个或更多输出支付的交易数量徘徊在 11% 左右。注意：这个启发法还包括 coinjoin 交易和其他不严格是批量支付的技术。

- **<!--opt-in-rbf-->****选择性 RBF**（Replace-by-Fee） 允许高效的手续费提升，使支付者可以从低手续费开始，然后再增加出价。信号 RBF 的交易数量从一月份的约 4% 上升到十二月份的 6%。

![Plot of wrapped and native segwit use in 2018](/img/posts/2018-12-segwit.png)

Segwit 支出有两类：

- **<!--nested-->****嵌套** Segwit 将扩展机制放在向后兼容的 P2SH 脚本内，使其与几乎所有软件兼容，但无法实现其全部效率。使用嵌套 segwit 的输入数量从一月份的约 10% 上升到十二月份的 33%。

- **<!--native-->****原生** Segwit 更高效，但仅与支持发送到 segwit 地址的钱包兼容。原生 segwit 输入的数量从一月份的几乎 0% 上升到十二月份的约 5%。

![Plot of UTXO set changes per block in 2018](/img/posts/2018-12-utxo.png)

我们调查的最后一种手续费减少技术是未确认交易输出（UTXO）集大小的每块变化。减少表明比特币合并为更大的币，这些币以后可以更高效地使用。总的来说，今年 UTXO 集大小减少了约 1200 万条目。

![Plot of the block size as a percentage of the maximum allowed block size](/img/posts/2018-12-weight.png)

总体而言，今年使用的区块空间平均量很少接近协议允许的最大值，但直到十二月初似乎都在向最大值靠近。如果这种趋势恢复，并且 2019 年区块再次变得持续满载——就像 2017 年那样——手续费可能会上升，实施手续费减少技术的钱包和企业可能能够为其用户提供比未优化竞争对手低得多的成本。

*以上所有图表的数据由每个区块内收集的值组成，使用简单移动平均值平滑处理超过 1000 个区块。空块（仅有一个生成交易的块）未纳入分析。大多数上述统计数据可从 [Optech 仪表盘][Optech Dashboard] 获取，该仪表盘在每个区块后更新。注意：2019 年 1 月 1 日后，我们将更新本文中的图表以反映整个 2018 年，届时将删除此句。*
</div>

## 结论

我们有时会听到人们请求比特币未来发展的路线图，但回顾 2018 年的发展情况表明，发布这样的文档是多么徒劳。上面描述的许多发展都是我们怀疑即使是最先进的协议开发人员也无法在一年前预测的。因此，我们不知道 2019 年比特币开发的具体情况——但我们期待发现。

*Optech Newsletter 将于 1 月 8 日恢复其每周二的常规出版时间表。您可以[通过电子邮件订阅][optech newsletters]或关注我们的 [RSS feed][]。*

## 注释

[^fn-dandelion-lite]:
    使用比特币 P2P 网络的轻客户端不为其他用户中继交易——它们只发送自己的交易。这意味着从 P2P 轻客户端发送的任何交易都可以与客户端的网络身份（例如 IP 地址）相关联。蒲公英只是一个路由协议，因此无法消除这种隐私泄漏。相反，P2P 轻客户端应始终使用匿名网络（如 Tor）发送交易（并且应为每次支出交易使用不同的一次性网络身份）。

[^fn-opcodes]:
    Schnorr 签名提案可能不使用与当前脚本相同的操作码，但单签名、使用类似 muSig 的多重签名以及使用类似 Taproot 的合作 MAST 都可以使用相同的格式。

[^fn-mast]:
    也称为*Merkel 化抽象语法树*，因为 Russell O'Connor 的原始想法将默克尔树的加密承诺结构与抽象语法树的编程语言分析技术结合起来，提供了一种紧凑地承诺复杂脚本的方法，其元素和结果可以从不同的分支组合起来。后来的简化版本删除了这种组合的潜力，因此最近的提案不像抽象语法树，导致 O'Connor 和其他人不鼓励在新想法中使用原始术语。然而，“MAST”这一缩写自 [2013 年至少][todd mast] 已被用来指代基本技术，因此我们选择采用 Anthony Towns 的[提议][mast backronym]的回溯首字母缩略词，*Merkel 化替代脚本树*。

[^fn-unsafe]:
    [BIP118][] SIGHASH_NOINPUT_UNSAFE 接受了不安全的称号，因为其天真的使用可能导致资金丢失。例如，Alice 收到 1 BTC 到她的一个地址。然后她在签名将这些资金支付给 Bob 时使用 noinput。后来，Alice 收到另一个 1 BTC 到同一个地址。这允许之前交易的签名被重用于将 Alice 的新 1 BTC 发送给 Bob。BIP118 的共同作者 Christian Decker [同意][decker unsafe] 将操作码标记为*不安全*，以鼓励开发人员在使用该标志之前了解这一安全问题。一个设计良好的程序可以通过谨慎处理其签名内容和向用户公开的接收地址安全地使用 noinput。

[^fn-harding-mast]:
    此示例不对应于任何特定的 MAST 提案，而是提供了 MAST 工作所需的最少数据的简单视图。有关实际提案，请参阅 BIP [114][BIP114]、[116][BIP116] 和 [117][BIP117]。


{% include linkers/issues.md issues="13451,13452,14032" %}
{% include references.md %}

[alert key release]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016189.html
[alert retirement alert]: https://bitcoin.org/en/alert/2016-11-01-alert-retirement
[betterhash]: https://github.com/TheBlueMatt/bips/blob/master/bip-XXXX.mediawiki
[betterhash implementation]: https://github.com/TheBlueMatt/mining-proxy
[bitcoin core 0.16]: https://bitcoincore.org/en/releases/0.16.0/
[bitcoin core 0.17]: https://bitcoincore.org/en/releases/0.17.0/
[bob ts]: https://diyhpl.us/wiki/transcripts/building-on-bitcoin/2018/
[bpase]: https://cyber.stanford.edu/bpase18
[building on bitcoin]: https://building-on-bitcoin.com/
[bustapay]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016340.html
[chaincode lightning residency]: https://lightningresidency.com/
[channel factories]: https://www.tik.ee.ethz.ch/file/a20a865ce40d40c8f942cf206a7cba96/Scalable_Funding_Of_Blockchain_Micropayment_Networks.pdf
[c-lightning 0.6]: https://github.com/ElementsProject/lightning/releases/tag/v0.6
[coredevtech nyc]: https://coredev.tech/2018_newyork.html
[coredevtech tokyo]: https://coredev.tech/2018_tokyo.html
[coredevtech ts]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/
[core dup post]: https://bitcoincore.org/en/2018/09/20/notice/
[cpfp carve out]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016518.html
[edge dev++]: https://keio-devplusplus-2018.bitcoinedge.org/
[edge dev ts]: http://diyhpl.us/wiki/transcripts/scalingbitcoin/tokyo-2018/edgedevplusplus/
[edge dev vids]: https://www.youtube.com/channel/UCywSzGiWWcUG1gTp45YdPUQ/videos
[electrs]: https://github.com/romanz/electrs
[eltoo]: https://blockstream.com/eltoo.pdf
[eltoo pinning]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-June/001316.html
[esplora]: https://blockstream.com/2018/12/06/esplora-source-announcement/
[graftroot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-February/015700.html
[l2 summit]: https://medium.com/mit-media-lab-digital-currency-initiative/the-importance-of-layer-2-105189f72102
[lightning protocol development summit]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001569.html
[ln1.1 changes]: https://github.com/lightningnetwork/lightning-rfc/wiki/Lightning-Specification-1.1-Proposal-States
[lnd 0.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.4-beta
[lnd 0.5-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.5-beta
[ln list november]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/thread.html
[ln multipath]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-February/000993.html
[ln-penalty]: https://lightning.network/lightning-network-paper.pdf
[ln residency vids]: https://lightningresidency.com/#videos
[mast]: https://bitcointechtalk.com/what-is-a-bitcoin-merklized-abstract-syntax-tree-mast-33fdf2da5e2f
[musig]: https://www.blockstream.com/2018/01/23/musig-key-aggregation-schnorr-signatures/
[offchain pizza]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-February/001044.html
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
[schnorr and more]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016556.html
[schnorr bip]: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki
[sdl fake spv proof]: https://bitslog.wordpress.com/2018/06/09/leaf-node-weakness-in-bitcoin-merkle-tree-design/
[splicing]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001434.html
[subzero]: https://medium.com/square-corner-blog/open-sourcing-subzero-ee9e3e071827
[taproot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-January/015614.html
[transaction pinning]: https://bitcoin.stackexchange.com/questions/80803/what-is-meant-by-transaction-pinning/80804#80804
[untrackable auth]: https://gist.github.com/sipa/d7dcaae0419f10e5be0270fada84c20b
[mast backronym]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016500.html
[todd mast]: https://bitcointalk.org/index.php?topic=255145.msg2757327#msg2757327
[daftuar dandelion]: https://bitcoin.stackexchange.com/a/81504/26940
[bitcoin.com forced bch mining]: https://www.reddit.com/r/Bitcoin/comments/9x2jub/warning_if_you_have_any_bitcoin_hashing_power/
[wuille minisketch savings]: https://twitter.com/pwuille/status/1075460072786935808
[decker unsafe]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016193.html
[bitcoin core 0.6]: https://bitcoin.org/en/release/v0.6.0
[techniques for reducing transaction fees]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees
[payment batching]: https://bitcointechtalk.com/saving-up-to-80-on-bitcoin-transaction-fees-by-batching-payments-4147ab7009fb
[towns consolidation]: /en/xapo-utxo-consolidation/
[cve-2017-12842]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-12842
[cve-2018-17144]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-17144
