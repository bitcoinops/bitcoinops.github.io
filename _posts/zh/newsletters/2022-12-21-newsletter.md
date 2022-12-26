---
title: 'Bitcoin Optech Newsletter #231：2022 年度回顾特辑'
permalink: /zh/newsletters/2022/12/21/
name: 2022-12-21-newsletter-zh
slug: 2022-12-21-newsletter-zh
type: newsletter
layout: newsletter
lang: zh

excerpt: >
  这份特别版的 Optech Newsletter 总结了 2022 年全年比特币值得注意的发展。
---
{{page.excerpt}}  这是我们的年终总结系列（[2018][yirs 2018]、[2019][yirs 2019]、[2020][yirs 2020] 以及 [2021][yirs 2021]）的延续。

## 目录

* 一月
  * [无状态发票](#stateless-invoices)
  * [法律辩护基金](#defense-fund)
* February
  * [交易手续费赞助](#fee-sponsorship)
  * [幻影节点支付](#phantom-node-payments)
* March
  * [闪电网络寻路](#ln-pathfinding)
  * [零确认通道](#zero-conf-channels)
* April
  * [静默支付](#silent-payments)
  * [Taro](#taro)
  * [量子安全的密钥交换](#quantum-safe-keys)
* May
  * [MuSig2](#musig2)
  * [包中继](#package-relay)
  * [比特币内核库项目](#libbitcoinkernel)
* June
  * [闪电网络协议开发者会议](#ln-meet)
* July
  * [洋葱消息速率限制](#onion-message-limiting)
  * [Miniscript 描述符](#miniscript-descriptors)
* August
  * [闪电网络交互式充值和双重充值协议](#dual-funding)
  * [防范通道阻塞攻击](#jamming)
  * [在 DLC 中使用 BLS 签名](#dlc-bls)
* September
  * [费率卡](#fee-ratecards)
* October
  * [Version 3 transaction relay](#v3-tx-relay)
  * [Async payments](#async-payments)
  * [Block parsing bugs](#parsing-bugs)
  * [ZK rollups](#zk-rollups)
  * [Encrypted version 2 transport protocol](#v2-transport)
  * [Meeting of Bitcoin protocol developers](#core-meet)
* November
  * [Fat error messages](#fat-errors)
* December
  * [Modifying the LN protocol](#ln-mod)
* Featured summaries
  * [Replace-By-Fee](#rbf)
  * [Major releases of popular infrastructure projects](#releases)
  * [Bitcoin Optech](#optech)
  * [Soft fork proposals](#softforks)

## 一月

{:#stateless-invoices}
一月份，LDK [合并][news181 ldk1177]了一个 “[无状态发票][topic stateless invoices]” 的实现，这种技术允许生成无限数量的发票而不必存储任何相关数据，除非这样的发票得到支付。无状态发票的提议是在 2021 年 9 月提出的，LDK 的实现不同于建议手段，虽然它实现了相同的目标，而且不需要闪电网络协议作出任何变更。稍后，闪电网络规范合并了一项[更新][news182 bolts912]，允许其它类型的无状态发票可以 —— 至少是部分地 —— 添加到 [Eclair][news183 stateless]、[Core Lightning][news195 stateless] 和 [LND][news196 stateless] 诸客户端中。

{:#defense-fund}
同样在一月份，Jack Dorsey、Alex Morcos 和 Martin White [设立][news183 defense fund]了一个比特币法律辩护基金（Bitcoin Legal Defense Fund），这是 “一个非营利的实体，致力于尽可能减少阻遏开发者主动开发比特币和相关项目的法律问题。”

## 二月

{:#fee-sponsorship}
在一月份发生的，关于简化为预签名的交易增加手续费的[讨论][news182 accounts]，在二月份引发了关于 Jeremy Rubin 在 2020 年提出的 “[交易手续费赞助][topic fee sponsorship]” 想法的[新一轮讨论][news188 sponsorship]。人们提出了对这种实现的多项挑战。尽管当时的讨论没有取得太大的精湛，但一种实现了类似目标 —— 而且不像手续费赞助那样需要软分叉 —— 的技术在十月份[出现][news231 v3relay]了。

{:#phantom-node-payments}
LKD 对[无状态发票][topic stateless invoices]的初步支持，使它可以加入一种新的、用于闪电网络节点负载均衡的[简单][news188 ldk1199]方法，称作 “*幻影节点支付*”。

{:.center}
![Illustration of phantom node payment path](/img/posts/2022-02-phantom-node-payments.dot.png)

## 三月

{:#ln-pathfinding}
由 René Pickhardt 和 Stefan Richter 在 2021 年首次推出的闪电网络寻路算法在三月得到了一次[更新][news192 pp]，Pickhardt 指出一项优化使其计算效率提高很多。

{:#zero-conf-channels}
一项与之匹配、允许开设 “[零确认通道][topic zero-conf channels]” 的方法也形成了[规范][news203 zero-conf]，并开始产生实现；LDK 在三月[添加][news192 ldk1311]对相关的 “通道短标识符（SCID）” *昵称* 字段时率先起步，[Eclair][news205 scid]、[Core Lightning][news208 scid cln] 和 [LND][news208 scid lnd] 相继跟上。

{:.center}
![Illustration of zero-conf channels](/img/posts/2021-07-zeroconf-channels.png)

<div markdown="1" class="callout" id="rbf">
### 2022 summary<br>Replace-By-Fee

今年，我们看到了许多关于 “[手续费替换][topic rbf]（RBF）” 的讨论，以及一些重要的行动。我们一月份的周报[总结][news181 rbf]了一项来自 Jeremy Rubin 的提议：任意交易都可以在原版交易到达节点后的一段时间内被更高手续费的替代版本替换；超时之后，再应用现有的规则 —— 仅允许遵循 [BIP125][] 的替代版本替换原版。这将允许商家在替换窗口关闭之后接受未确认的交易，就像现在这样。更重要的是，它也许可以让依赖于可替换性来实现安全性的协议不必担心未携带 BIP125 信号的交易，只要一个协议节点或者瞭望塔拥有合理的机会、在知晓一笔交易后即时响应即可。

在一月底， Gloria Zhao 开始了一场关于 RBF 的新讨论，她[介绍][news186 rbf]了当前的 RBF 策略的背景、过去几年间发现的一些问题（例如 “[交易钉死攻击][topic transaction pinning]”）、RBF 策略如何影响钱包软件的用户界面，以及几种可能的优化措施。在三月上旬，Zhao 追加了两场关于 RBF 的开发者讨论的[总结][news191 rbf]，一场来自线上，一场来自线下。

同样在三月，Larry Ruane 提出了跟 RBF 相关的[问题][news193 witrep]：替换交易的见证数据而不改变交易的其余部分（决定 txid 的部分）。

在七月，Antoine Riard 在 Bitcoin Core 代码库[开启][news205 rbf]了一个 PR，为 Bitcoin Core 添加了一个 `mempoolfullrbf` 配置选项。这个选项默认保持 Bitcoin Core 以前的行为：仅允许包含 [BIP125][] 信号的未确认交易被替换。而额外配置了这个选项的节点则会接受任意替换交易并转发和挖矿，即使原版交易并不包含 BIP125 信号。Riard 也在 Bitcoin-Dev 邮件组中开启了一个帖子以讨论这一变更。几乎所有的 PR 评论都是正面的，而大部分邮件组讨论都是不相关的话题，所以并不意外地，这个 PR 在开启的大约一个月后[合并][news208 rbf]了。

在十月份，Bitcoin Core 项目开始分发 24.0 版本的候选版本 —— 24.0 将是第一个包含 `mempoolfullrbf` 配置选项的。Dario Sneidermanis 看到了候选版本的更新声明中关于这个选项的部分，于是在 Bitcoin-Dev 邮件组中[发帖][news222 rbf]指出，太多用户和矿工启用这个选项会让不带信号的替换交易变成可以依靠的。而更可靠的无信号替换交易也会让接受未确认交易作为支付手段的服务商更容易遭受盗窃、迫使这些服务商改变自己的行为。讨论在接下来的[一周][news223 rbf]和[又一周][news224 rbf]连绵不断。一个月后，Sneidermanis 在邮件组中引起了担忧的苗头，Suhas Daftuar [总结][news225 rbf] 了反对该选项的一些论证，并开启了一个将它从 Bitcoin Core 中移除的 PR。类似的其它 PR 在此前和此后都出现了，但 Daftuar 的 PR 变成了讨论有无可能永久移除这个选项的焦点。

在 Daftuar 的 PR 中出现了许多指出保留 `mempoolfullrbf` 的反面意见。包括许多钱包开发者都提到，有时候他们会遇到希望发起替换、又没有使用 BIP125 信号的用户。

在十一月末，Daftuar 关闭了这个 PR，而且 Bitcoin Core 项目也放出了带有 `mempoolfullrbf` 的 24.0。在十二月，开发者 0xB10C [推出][news230 rbf]了一个网站，用于监控并不包含 BIP125 信号的替换交易；这样的交易如果能得到确认，则表明它可能由一个使用 `mempoolfullrbf` 配置选项（或带有类似特性的其它软件）开启全面 RBF（full-RBF）的矿工经手。至今年年底，全面 RBF 依然在其它的 Bitcoin Core PR 和邮件组帖子中被讨论。

## 四月

{:#silent-payments}
四月份，Ruben Somsen [提出][news194 sp]了 “[静默支付][topic silent payments]” 的想法，它将允许人们给一个公开的标识符（近似于 “地址”）支付，但不必在链上显示出这个标识符。这可以帮助防止[地址复用][topic output linking]。举个例子，Alice 可以在自己的网页中发布一个公开标识符，而 Bob 可以将这个标识符转化为一个独一无二的、只有 Alice 可以花费的比特币地址。如果 Carol 后来访问 Alice 的网站，并复用 Alice 的标识符，她将推导出另一个地址；这个地址无论是 Bob 还是其它第三方，都无法直接断定是否属于 Alice。后来，开发者 W0ltx 为 Bitcoin Core 创建了静默支付的一个[提议实现][news202 sp]，并在稍后取得了[重大进展][news214 sp]。

{:#taro}
Lightning Labs [推出][news195 taro]了 Taro，这个协议（基于以前的提议）允许用户将非比特币的代币的创建和转移承诺到比特币区块链上。Taro 旨在跟闪电网络一起使用，实现可路由的链下转账。类似于以前的闪电网络跨资产转账提议，仅仅转发支付的中间节点不需要理解 Taro 协议，也不需要知道被转移的资产的细节 —— 他们只需使用跟其它闪电支付同样的协议，转移比特币即可。

{:#quantum-safe-keys}
四月份还出现了关于量子安全的密钥交换的[讨论][news196 qc]；未来可能出现快速的量子计算机，但量子安全的密钥交换将允许用户使用可以[抵御][topic quantum resistance]这样的量子计算攻击的密钥来接收比特币。{{page.excerpt}}  这是我们的年终总结系列（[2018][yirs 2018]、[2019][yirs 2019]、[2020][yirs 2020] 以及 [2021][yirs 2021]）的延续。

## 五月

{:#musig2}
用于创建 [schnorr 多签][topic multisignature] 的 [MuSig2][topic musig] 协议在 2022 年取得了一些进展。[提议的一个 BIP][news195 musig2] 在 5 月收到了重要的 [反馈][news198 musig2]。后来，在 10 月，Yannick Seurin、Tim Ruffing、Elliott Jin 和 Jonas Nick 发现了一个 [漏洞][news222 musig2]：该协议在某些方式下可被利用。研究人员宣布他们计划在更新版本中修复该漏洞。

{:#package-relay}
[包中继][topic package relay] 的 BIP 草案由 Gloria Zhao 在 5 月[发布][news201 package relay]。包中继修复了 Bitcoin Core [CPFP 手续费追加][topic cpfp]这一重大问题。这个问题是如果其父交易支付的费率高于节点的动态最低交易池手续费，则各个节点只会接受手续费追加的子交易。这使得 CPFP 对依赖于预签名交易的协议来说不够可靠，例如许多合约协议（包括当前的闪电网络协议）。包中继允许将父交易和子交易看作是一个单位进行评估，从而消除了上述问题——尽管没有消除其他相关问题，例如[交易钉死][topic transaction pinning]。在 6 月份，[有][news204 package relay]更多关于包中继的讨论。

{:#libbitcoinkernel}
在 5 月份，我们还见证了比特币内核库项目（libbitcoinkernel）的[第一次合并][news198 lbk]，试图将尽可能多的 Bitcoin Core 共识代码分离到一个单独的库中，即使该代码仍附带有一些非共识代码。从长远来看，这一目标是精简 libbitcoinkernel 到只包含共识代码，让其他项目可以轻松使用该代码或让审计人员分析对 Bitcoin Core 的共识逻辑的变更。几个额外的 libbitcoinkernel PR 也在今年合并。

<div markdown="1" class="callout" id="releases">
### 2022 总结<br>流行基础设施项目的主要发布

- [Eclair 0.7.0][news185 eclair] 添加了对[锚点输出][topic anchor outputs]、中继[洋葱消息][topic onion messages]以及在生产环境中使用 PostgreSQL 数据库的支持。

- [BTCPay Server 1.4][news189 btcpay] 添加了对 [CPFP 手续费追加][topic cpfp] 的支持、可使用 LN URL 的更多功能以及多个 UI 改进。

- [LDK 0.0.105][news190 ldk] 添加了对幻影节点支付的支持以及支付寻路概率的优化。

- [BDK 0.17.0][news193 bdk] 可更容易地派生地址，甚至是当钱包处于离线状态时。

- [Bitcoin Core 23.0][news197 bcc] 默认为新钱包提供[描述符][topic descriptors]钱包，还允许描述符钱包以轻松支持使用 [taproot][topic taproot] 接收到 [bech32m][topic bech32] 地址。它还增加了对使用非默认 TCP/IP 端口的支持，并开始允许使用 [CJDNS][] 网络覆盖。

- [Core Lightning 0.11.0][news197 cln] 添加了对同一对方节点的多个活跃通道以及支付[无状态发票][topic stateless invoices]的支持。

- [Rust Bitcoin 0.28][news197 rb] 添加了对 [taproot][topic taproot] 的支持并改进了相关 API，例如 [PSBTs][topic psbt]。

- [BTCPay 服务器 1.5.1][news198 btcpay] 添加了一个新的首页仪表板、一个新的转账处理器功能以及可自动批准拉取付款和退款的能力。

- [LDK 0.0.108 和 0.0.107][news205 ldk] 增加了对[大通道][topic large channels]和[零确认通道][topic zero-conf channels]的支持；此外，还提供了可使移动客户端从服务器同步网络路由信息（即 gossip）的代码。

- [BDK 0.19.0][news205 bdk] 通过[描述符][topic descriptors]、[PSBTs][topic psbt] 和其他子系统添加了对 [taproot][topic taproot] 的实验性支持。它还添加了一个新的[选币][topic coin selection]算法。

- [LND 0.15.0-beta][news206 lnd] 添加了对发票元数据的支持。发票元数据可用于[无状态发票][topic stateless invoices]的其他程序（以及 LND 潜在的未来版本）。该版本还支持对内部钱包接收和花费比特币到 [P2TR][topic taproot] keyspend 输出以及实验性的 [MuSig2][topic musig]。

- [Rust Bitcoin 0.29][news213 rb] 添加了[致密区块中继][topic compact block relay]的数据结构（[BIP152][]）并改进了对 [taproot][topic taproot] 和 [PSBT][topic psbt] 的支持。

- [Core Lightning 0.12.0][news214 cln] 添加了一个新的 `bookkeeper` 插件、一个 `commando` 插件以及对[静态通道备份][topic static channel backups]的支持，并明确开始允许对方节点能够打开连接到你节点的[零确认通道][topic zero-conf channels]。

- [LND 0.15.1-beta][news215 lnd] 添加了对[零确认通道][topic zero-conf channels]和通道别名的支持，并可以在任何地方使用 [taproot][topic taproot] 地址。

- [LDK 0.0.111][news217 ldk] 添加了对创建、接收和中继[洋葱消息][topic onion messages]的支持。

- [Core Lightning 22.11][news229 cln] 开始使用新的版本编号方案并添加了新的插件管理器。

- [libsecp256k1 0.2.0][news230 libsecp] 是这个被广泛采用的比特币相关密码学操作库的第一个被打标签的发布版本。

- [Bitcoin Core 24.0.1][news230 bcc] 添加了一个用于配置节点的[费用替换][topic rbf]（RBF）策略的选项、一个新的用于在单笔交易中很容易花费所有钱包资金的 `sendall` RPC、一个可用于验证一笔交易将如何影响钱包的 `simulaterawtransaction` RPC，以及创建仅观察的[描述符][topic descriptors]的能力（其中包含 [miniscript][topic miniscript] 表达式的以提高与其他软件的向前兼容性）。

</div>

## 六月

{:#ln-meet}
6 月，闪电网络开发人员[开会][news204 ln]讨论协议开发的未来。讨论的主题包括基于 [taproot][topic taproot] 的闪电网络通道、[tapscript][topic tapscript] 和 [MuSig2][topic musig]（包括递归 MuSig2）、更新 gossip 协议以公告新通道及已变更通道、[洋葱消息][topic onion messages]，[盲化路径][topic rv routing]、探测（probing）及余额共享、[蹦床（trampoline）路由][topic trampoline payments]、[要约（offers）][topic offers] 和 LNURL 协议。

## 七月

{:#onion-message-limiting}
7 月，Bastien Teinturier [发布][news207 onion]了一篇关于限制[洋葱消息][topic onion messages]以防止拒绝服务攻击想法的摘要。他将该想法归功于 Rusty Russell。但是，Olaoluwa Osuntokun 建议可以重新考虑他在 3 月份的[提案][news190 onion]。该提案通过对数据中继收费来防止滥用洋葱消息。参与讨论的大多数开发人员似乎更愿意在向协议添加额外费用之前先尝试限制速率。

{:#miniscript-descriptors}
本月 Bitcoin Core 还[合并了一个 pull request][news209 miniscript]，添加了对用 [miniscript][topic miniscript] 编写的[输出脚本描述符][topic descriptors]仅观察模式的支持。我们预计未来的 PR 将允许钱包为基于 miniscript 的描述符创建签名。随着其他钱包和签名设备实现 miniscript 支持，在钱包之间转移策略、多个钱包合作花费比特币应该变得更容易，例如多重签名策略或者那些涉及到不同签名者在不同场合下的策略（例如后备签名者）。

## 八月

{:#dual-funding}
8 月，Eclair [合并了][news213 dual funding]一项对交互式充值协议的支持。[双重充值协议][topic dual funding]依赖于该支持。双重充值协议允许两个节点中的任何一个（或共同）为新的闪电网络通道充值。当月晚些时候，另一项[合并][news215 dual funding]使 Eclair 开始对双重充值进行实验性支持。双重充值的开放协议有助于确保商家能够访问那些能立即收到客户付款的通道。

{:#jamming}
Antoine Riard 和 Gleb Naumenko [发布了][news214 jam]了一份关于[通道阻塞攻击][topic channel jamming attacks]及其若干建议解决方案的指南。对于攻击者控制的每个通道，他们可以通过发送永远不会完成的付款使十多个其他通道无法使用——这意味着攻击者不需要支付任何直接成本。该问题自 2015 年以来就已为人所知，但之前提出的解决方案均未获得广泛接受。 在之后的 11 月，Clara Shikhelman 和 Sergei Tikhomirov 将发表他们自己的[论文][news226 jam]。论文中有对此的分析和建议的解决方案，包括基于小额预付费用和基于信誉自动推荐。随后，Riard [发表了][news228 jam]一个使用特定于节点、不可交易令牌的替代解决方案。在之后的 12 月，Joost Jager 将[宣布][news230 jam]一个“简单但不完美”的实用程序，可以帮助节点减轻一些阻塞问题，而无需对闪电网络协议进行任何更改。

{:.center}
![Illustration of the two types of channel jamming attacks](/img/posts/2020-12-ln-jamming-attacks.png)

{:#dlc-bls}
Lloyd Fournier [写了一篇][news213 bls]关于 [DLC][topic dlc] 预言机使用 Boneh-Lynn-Shacham（[BLS][]）签名进行证明的好处。比特币不支持 BLS 签名，需要软分叉才能添加它们，但 Fournier 给出了他合着的一篇论文链接。该论文描述了如何从 BLS 签名中安全地提取信息，将该信息用在与比特币兼容的[签名适配器][topic adaptor signatures]中而不对比特币进行任何变更。这将允许“无状态”预言机，其中合约各方（但不是预言机）可以私下同意他们希望预言机证明哪些信息，例如，通过指定一个程序。而该程序可用他们所知预言机可以运行的任何编程语言来编写。

然后他们可以根据合约分配他们的存款资金，甚至不需要告知预言机他们计划使用它。到了结算合约的时候，每一方都可以自己运行程序。如果他们都同意运行结果，就可以合作结算合约，根本不需要预言机的参与；如果他们不同意，他们中的任何一方都可以将程序发送到预言机（可能需要为其服务支付少量费用）并收到 BLS 对程序源代码的证明以及运行程序的返回值。证明可以转换为允许在链上结算 DLC 的签名。与当前的 DLC 合约一样，预言机无法根据其 BLS 签名知道是哪些链上交易。

<div markdown="1" class="callout" id="optech">
### 2022 总结<br>Bitcoin Optech

在 Optech 的第五年，我们发布了 51 份[周报][newsletters]，并在我们的[主题索引][topics index]中新增了 11 个页面。 Optech 今年总共发表了超过 70,000 字的有关比特币软件研发的文章，大致相当于一本 200 页的书。
<!-- wc -w _posts/en/newsletters/2022-* ; a typical book has about 350 words per page -->

</div>

## 九月

{:#fee-ratecards}
Lisa Neigut 在 Lightning-Dev 邮件列表中[发表了][news219 ratecards]一个费率卡的提案。该提案允许节点宣传其转发费用的四级费率。更好地宣传转发费用，包括在某些情况下设置负费用的能力，可以帮助确保转发节点有足够的容量将付款中继到最终目的地。开发人员 ZmnSCPxj 在今年早些时候曾[发布][news204 lnfees]了他自己基于费用来改进路由的解决方案。这是一种使用费率卡的简单方法，“你可以将价目表建模为相同两个节点间的四个独立通道，每个都有不同的成本。如果成本最低的路径失败了，你只需尝试另一条可能有更多跳数但有效成本较低的路由，或者以更高的成本尝试相同的通道。” René Pickhardt [建议了][news220 flow
control]一个支付流量控制的替代方法。

## October

{:#v3-tx-relay}
In October, Gloria Zhao [proposed][news220 v3] allowing transactions that
used version number 3 to use a modified set of transaction relay
policies.  These policies are based on experience using [CPFP][topic
cpfp] and [RBF][topic rbf], plus ideas for [package relay][topic package
relay], and are designed to help preventing [pinning attacks][topic
transaction pinning] against two-party contract protocols like LN---ensuring
that users can promptly get transactions confirmed for closing channels,
settling payments ([HTLCs][topic htlc]), and enforcing misbehavior
penalties.  Greg Sanders would [follow up][news223 ephemeral] later in
the month with an additional proposal for *ephemeral anchors*, a
simplified form of the [anchor outputs][topic anchor outputs] already
usable with most LN implementations.

{:#async-payments}
Eclair added [support][news220 async] for a basic form of async payments
when [trampoline relay][topic trampoline payments] is used. Async
payments would allow paying an offline node (such as a mobile wallet)
without trusting a third-party with the funds. The ideal mechanism for
async payments depends on [PTLCs][topic ptlc], but a partial
implementation just requires a third party to delay forwarding the funds
until the offline node comes back online. Trampoline nodes can provide
that delay and so this PR makes use of them to allow experimentation
with async payments.

{:#parsing-bugs}
October also saw the [first][news222 bug] of two block parsing bugs that
affected multiple applications.  An accidentally triggered bug in BTCD
prevented it and downstream program LND from processing the latest
blocks.  This could have led to users losing funds, although no such
problems were reported.  A [second][news225 bug] related bug, this time
deliberately triggered, affected BTCD and LND again, along with users of some
versions of Rust-Bitcoin.  Again, there was a potential for users to
lose money, although we are unaware of any reported incidents.

{:#zk-rollups}
John Light [posted][news222 rollups] a research report he prepared about
validity rollups---a type of sidechain where the current sidechain state
is compactly stored on the mainchain. An owner of sidechain bitcoins can
use the state stored on the mainchain to prove how many sidechain
bitcoins they control. By submitting a mainchain transaction with a
validity proof, they can withdraw bitcoins they own from the sidechain
even if the operators or miners of the sidechain try to prevent the
withdrawal.  Light's research describes validity rollups in depth, looks
at how support for them could be added to Bitcoin, and examines various
concerns with their implementation.

{:#v2-transport}
The [BIP324][] proposal for an [encrypted v2 P2P transport
protocol][news222 v2trans] received an update and mailing list
discussion for the first time in three years.  Encrypting the transport
of unconfirmed transactions can help hide their origin from eavesdroppers
who control many internet relays (e.g. large ISPs and governments).  It
can also help detect tampering and possibly make [eclipse attacks][topic
eclipse attacks] more difficult.

{:#core-meet}
A meeting of Bitcoin protocol developers had several sessions
[transcribed][news223 xscribe] by Bryan Bishop, including discussions
about [transport encryption][topic v2 p2p transport], transaction fees
and [economic security][topic fee sniping], the FROST [threshold
signature][topic threshold signature] scheme, the sustainability of
using GitHub for source code and development discussion hosting,
including provable specifications in BIPs, [package relay][topic package
relay] and [v3 transaction relay][topic v3 transaction relay], the
Stratum version 2 mining protocol, and getting code merged into Bitcoin
Core and other free software projects.

<div markdown="1" class="callout" id="softforks">
### 2022 summary<br>Soft fork proposals

January began with Jeremy Rubin [holding][news183a ctv] the first of
several IRC meetings to review and discuss the
[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (CTV) soft fork
proposal.  Meanwhile, Peter Todd [posted][news183b ctv] several concerns
with the proposal to the Bitcoin-Dev mailing list, most notably
expressing concern that it didn't seem to benefit nearly all Bitcoin
users, as he believes previously soft forks have done.

Lloyd Fournier [posted][news185 ctv] to the DLC-Dev and Bitcoin-Dev
mailing lists about how the CTV opcode could radically reduce the number
of signatures required to create certain [Discreet Log Contracts][topic
dlc] (DLCs), as well as reduce the number of some other operations.
Jonas Nick noted that a similar optimization is also possible using the
proposed [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] (APO) signature
hash mode.

Russell O'Connor [proposed][news185 txhash] an alternative to both CTV
and APO---a soft fork adding an `OP_TXHASH` opcode and an
[OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] (CSFS) opcode.  The
TXHASH opcode would specify which parts of a spending transaction should
be serialized and hashed, with the hash digest being put on the
evaluation stack for later opcodes to use. The CSFS opcode would specify
a public key and require a corresponding signature over particular data
on the stack---such as the computed digest of the transaction created by
TXHASH.  This would allow emulation of CTV and APO in a way that might
be simpler, more flexible, and easier to extend through other
subsequent soft forks.

In February, Rusty Russell would [propose][news187 optx] `OP_TX`, an
even simpler version of `OP_TXHASH`.  Meanwhile, Jeremy Rubin
[published][news188 ctv] parameters and code for a [signet][topic signet] with CTV
activated. This simplifies public experimentation with the proposed
opcode and makes it much easier to test compatibility between different
software using the code.  Also in February, developer ZmnSCPxj proposed
a new `OP_EVICT` opcode as an alternative to the
`OP_TAPLEAF_UPDATE_VERIFY` (TLUV) opcode proposed in 2021. Like TLUV,
EVICT is focused on use cases where more than two users share ownership
of a single UTXO, such as [joinpools][topic joinpools], [channel
factories][topic channel factories], and certain [covenants][topic
covenants].  ZmnSCPxj would later [propose][news191 fold] a different new opcode,
`OP_FOLD`, as a more general construct from which EVICT-like behavior
could be built (though that would require some other Script language
changes).

By March, the discussion about CTV and newer opcode proposals led to a
[discussion][news190 recov] about limiting the expressiveness of
Bitcoin's Script language, mainly to prevent *recursive
covenants*---conditions that would need to be fulfilled in every
transaction re-spending those bitcoins or any bitcoins merged with it
for perpetuity.   Concerns included a loss of censorship resistance,
enabling [drivechains][topic sidechains], encouraging unnecessary
computation, and making it possible for users to accidentally lose coins
to recursive covenants.

March also saw yet another idea for a soft fork change to Bitcoin's
Script language, this time to allow future transactions to opt-in to a
completely different language based on Lisp.  Anthony Towns
[proposed][news191 btc-script] the idea and described how it might be
better than both Script and a previously-proposed replacement:
[Simplicity][topic simplicity].

In April, Jeremy Rubin [posted][news197 ctv] to the Bitcoin-Dev mailing
list his plan to release software that will allow miners to begin
signaling whether they intend to enforce the [BIP119][] rules for the
proposed CTV opcode.  This spurred discussion about CTV and similar
proposals, such as APO.  Rubin later announced he wouldn't be releasing
compiled software for activating CTV at the present time as he and other
CTV supporters evaluated the feedback they'd received.

In May, Rusty Russell [updated][news200 ctv] his `OP_TX` proposal.  The
original proposal would allow recursive covenants, which elicited the
concerns mentioned earlier in this section.  Instead, Russell proposed
an initial version of TX that was limited to permitting the behavior of
CTV, which had been specifically designed to prevent recursive
covenants.  This new version of TX could be incrementally updated in the
future to provide additional features, making it more powerful but also
allowing those new features to be independently analyzed.  Additional
discussion in May [examined][news200 cat] the `OP_CAT` opcode (removed
from Bitcoin in 2010), which some developers occasionally suggest might
be a candidate for adding back in the future.

In September, Jeremy Rubin [described][news218 apo] how a trusted setup
procedure could be combined with the proposed APO feature to implement
behavior similar to that proposed by [drivechains][topic sidechains].
Preventing the implementation of drivechains on Bitcoin was one of the
reasons developer ZmnSCPxj suggested earlier in the year that full node
operators might want to oppose soft forks that enable recursive
covenants.

Also in September, Anthony Towns [announced][news219 inquisition] a
Bitcoin implementation designed specifically for testing soft forks on
[signet][topic signet].  Based on Bitcoin Core, Towns's code will
enforce rules for soft fork proposals with high-quality specifications
and implementations, making it simpler for users to experiment with the
proposed changes---including comparing changes to each other or seeing
how they interact.  Towns also plans to include proposed major changes
to transaction relay policy (such as [package relay][topic package
relay]).

In November, Salvatore Ingala [posted][news226 matt] to the Bitcoin-Dev
mailing list a proposal for a new type of covenant (requiring a soft
fork) that would allow using merkle trees to create smart contracts that
can carry state from one onchain transaction to another.  This would be
similar in capability to smart contracts used on some other
cryptocurrency systems but would be compatible with Bitcoin's existing
UTXO-based system.

</div>
## November

{:#fat-errors}
November saw Joost Jager [update][news224 fat] a proposal from 2019 to
improve error reporting in LN for failed payments.  The error would
report the identity of a channel where a payment failed to be forwarded
by a node so that the spender could avoid using channels involving that
node for a limited time.  Several LN implementations would update their
code to support the proposal, even if they didn't immediately begin
using it themselves, including [Eclair][news225 fat] and [Core
Lightning][news226 fat].

## December

{:#ln-mod}
In December, protocol developer John Law posted to the Lightning-Dev
mailing list his third major proposal for the year.  Like his previous
two proposals, he suggested new ways LN offchain transactions could be
designed to enable new features without requiring any changes to
Bitcoin's consensus code.  Altogether, Law proposed ways casual LN users
could [remain offline][news221 ln-mod] for potentially months at a time,
[separating][law tunable] the enforcement for specific payments from the
management of all settled funds to improve compatibility with
[watchtowers][topic watchtowers], and [optimizing][news230 ln-mod] LN
channels for use in [channel factories][topic channel factories] that
could significantly decrease the onchain costs to use LN.

*We thank all of the Bitcoin contributors named above, plus the many
others whose work was just as important, for another incredible year of
Bitcoin development.  The Optech newsletter will return to its regular
Wednesday publication schedule on January 4th.*

{% include references.md %}
{% include linkers/issues.md v=2 issues="" %}
[bls]: https://en.wikipedia.org/wiki/BLS_digital_signature
[cjdns]: https://github.com/cjdelisle/cjdns
[law tunable]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003732.html
[news181 ldk1177]: /en/newsletters/2022/01/05/#rust-lightning-1177
[news181 rbf]: /en/newsletters/2022/01/05/#brief-full-rbf-then-opt-in-rbf
[news182 accounts]: /en/newsletters/2022/01/12/#fee-accounts
[news182 bolts912]: /en/newsletters/2022/01/12/#bolts-912
[news183a ctv]: /en/newsletters/2022/01/19/#irc-meeting
[news183b ctv]: /en/newsletters/2022/01/19/#mailing-list-discussion
[news183 defense fund]: /en/newsletters/2022/01/19/#bitcoin-and-ln-legal-defense-fund
[news183 stateless]: /en/newsletters/2022/01/19/#eclair-2063
[news185 ctv]: /en/newsletters/2022/02/02/#improving-dlc-efficiency-by-changing-script
[news185 eclair]: /en/newsletters/2022/02/02/#eclair-0-7-0
[news185 txhash]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[news186 rbf]: /en/newsletters/2022/02/09/#discussion-about-rbf-policy
[news187 optx]: /en/newsletters/2022/02/16/#simplified-alternative-to-op-txhash
[news188 ctv]: /en/newsletters/2022/02/23/#ctv-signet
[news188 ldk1199]: /en/newsletters/2022/02/23/#ldk-1199
[news188 sponsorship]: /en/newsletters/2022/02/23/#fee-bumping-and-transaction-fee-sponsorship
[news189 btcpay]: /en/newsletters/2022/03/02/#btcpay-server-1-4-6
[news189 evict]: /en/newsletters/2022/03/02/#proposed-opcode-to-simplify-shared-utxo-ownership
[news190 ldk]: /en/newsletters/2022/03/09/#ldk-0-0-105
[news190 onion]: /en/newsletters/2022/03/09/#paying-for-onion-messages
[news190 recov]: /en/newsletters/2022/03/09/#limiting-script-language-expressiveness
[news191 btc-script]: /en/newsletters/2022/03/16/#using-chia-lisp
[news191 fold]: /en/newsletters/2022/03/16/#looping-folding
[news191 rbf]: /en/newsletters/2022/03/16/#ideas-for-improving-rbf-policy
[news192 ldk1311]: /en/newsletters/2022/03/23/#ldk-1311
[news192 pp]: /en/newsletters/2022/03/23/#payment-delivery-algorithm-update
[news193 bdk]: /en/newsletters/2022/03/30/#bdk-0-17-0
[news193 witrep]: /en/newsletters/2022/03/30/#transaction-witness-replacement
[news194 sp]: /en/newsletters/2022/04/06/#delinked-reusable-addresses
[news195 musig2]: /en/newsletters/2022/04/13/#musig2-proposed-bip
[news195 stateless]: /en/newsletters/2022/04/13/#core-lightning-5086
[news195 taro]: /en/newsletters/2022/04/13/#transferable-token-scheme
[news196 qc]: /en/newsletters/2022/04/20/#quantum-safe-key-exchange
[news196 stateless]: /en/newsletters/2022/04/20/#lnd-5810
[news197 bcc]: /en/newsletters/2022/04/27/#bitcoin-core-23-0
[news197 cln]: /en/newsletters/2022/04/27/#core-lightning-0-11-0
[news197 ctv]: /en/newsletters/2022/04/27/#discussion-about-activating-ctv
[news197 rb]: /en/newsletters/2022/04/27/#rust-bitcoin-0-28
[news198 btcpay]: /en/newsletters/2022/05/04/#btcpay-server-1-5-1
[news198 lbk]: /en/newsletters/2022/05/04/#bitcoin-core-24322
[news198 musig2]: /en/newsletters/2022/05/04/#musig2-implementation-notes
[news200 cat]: /en/newsletters/2022/05/18/#when-would-enabling-op-cat-allow-recursive-covenants
[news200 ctv]: /en/newsletters/2022/05/18/#updated-op-tx-proposal
[news201 package relay]: /en/newsletters/2022/05/25/#package-relay-proposal
[news202 sp]: /en/newsletters/2022/06/01/#experimentation-with-silent-payments
[news203 zero-conf]: /en/newsletters/2022/06/08/#bolts-910
[news204 ln]: /en/newsletters/2022/06/15/#summary-of-ln-developer-meeting
[news204 lnfees]: /en/newsletters/2022/06/15/#using-routing-fees-to-signal-liquidity
[news204 package relay]: /en/newsletters/2022/06/15/#continued-package-relay-bip-discussion
[news205 bdk]: /en/newsletters/2022/06/22/#bdk-0-19-0
[news205 ldk]: /en/newsletters/2022/06/22/#ldk-0-0-108
[news205 rbf]: /en/newsletters/2022/06/22/#full-replace-by-fee
[news205 scid]: /en/newsletters/2022/06/22/#eclair-2224
[news206 lnd]: /en/newsletters/2022/06/29/#lnd-0-15-0-beta
[news207 onion]: /en/newsletters/2022/07/06/#onion-message-rate-limiting
[news208 rbf]: /en/newsletters/2022/07/13/#bitcoin-core-25353
[news208 scid cln]: /en/newsletters/2022/07/13/#core-lightning-5275
[news208 scid lnd]: /en/newsletters/2022/07/13/#lnd-5955
[news209 miniscript]: /en/newsletters/2022/07/20/#bitcoin-core-24148
[news213 bls]: /en/newsletters/2022/08/17/#using-bitcoin-compatible-bls-signatures-for-dlcs
[news213 dual funding]: /en/newsletters/2022/08/17/#eclair-2273
[news213 rb]: /en/newsletters/2022/08/17/#rust-bitcoin-0-29
[news214 cln]: /en/newsletters/2022/08/24/#core-lightning-0-12-0
[news214 jam]: /en/newsletters/2022/08/24/#overview-of-channel-jamming-attacks-and-mitigations
[news214 sp]: /en/newsletters/2022/08/24/#updated-silent-payments-pr
[news215 dual funding]: /en/newsletters/2022/08/31/#eclair-2275
[news215 lnd]: /en/newsletters/2022/08/31/#lnd-0-15-1-beta
[news217 ldk]: /en/newsletters/2022/09/14/#ldk-0-0-111
[news218 apo]: /en/newsletters/2022/09/21/#creating-drivechains-with-apo-and-a-trusted-setup
[news219 inquisition]: /en/newsletters/2022/09/28/#bitcoin-implementation-designed-for-testing-soft-forks-on-signet
[news219 ratecards]: /en/newsletters/2022/09/28/#ln-fee-ratecards
[news220 async]: /en/newsletters/2022/10/05/#eclair-2435
[news220 flow control]: /en/newsletters/2022/10/05/#ln-flow-control
[news220 v3]: /en/newsletters/2022/10/05/#proposed-new-transaction-relay-policies-designed-for-ln-penalty
[news221 ln-mod]: /en/newsletters/2022/10/12/#ln-with-long-timeouts-proposal
[news222 bug]: /en/newsletters/2022/10/19/#block-parsing-bug-affecting-btcd-and-lnd
[news222 musig2]: /en/newsletters/2022/10/19/#musig2-security-vulnerability
[news222 rbf]: /en/newsletters/2022/10/19/#transaction-replacement-option
[news222 rollups]: /en/newsletters/2022/10/19/#validity-rollups-research
[news222 v2trans]: /en/newsletters/2022/10/19/#bip324-update
[news223 ephemeral]: /en/newsletters/2022/10/26/#ephemeral-anchors
[news223 rbf]: /en/newsletters/2022/10/26/#continued-discussion-about-full-rbf
[news223 xscribe]: /en/newsletters/2022/10/26/#coredev-tech-transcripts
[news224 fat]: /en/newsletters/2022/11/02/#ln-routing-failure-attribution
[news224 rbf]: /en/newsletters/2022/11/02/#mempool-consistency
[news225 bug]: /en/newsletters/2022/11/09/#block-parsing-bug-affecting-multiple-software
[news225 fat]: /en/newsletters/2022/11/09/#eclair-2441
[news225 rbf]: /en/newsletters/2022/11/09/#continued-discussion-about-enabling-full-rbf
[news226 fat]: /en/newsletters/2022/11/16/#core-lightning-5698
[news226 jam]: /en/newsletters/2022/11/16/#paper-about-channel-jamming-attacks
[news226 matt]: /en/newsletters/2022/11/16/#general-smart-contracts-in-bitcoin-via-covenants
[news228 jam]: /en/newsletters/2022/11/30/#reputation-credentials-proposal-to-mitigate-ln-jamming-attacks
[news229 cln]: /en/newsletters/2022/12/07/#core-lightning-22-11
[news230 bcc]: /en/newsletters/2022/12/14/#bitcoin-core-24-0-1
[news230 jam]: /en/newsletters/2022/12/14/#local-jamming-to-prevent-remote-jamming
[news230 libsecp]: /en/newsletters/2022/12/14/#libsecp256k1-0-2-0
[news230 ln-mod]: /en/newsletters/2022/12/14/#factory-optimized-ln-protocol-proposal
[news230 rbf]: /en/newsletters/2022/12/14/#monitoring-of-full-rbf-replacements
[news231 v3relay]: /en/newsletters/2022/12/21/#v3-tx-relay
[newsletters]: /en/newsletters/
[topics index]: /en/topics/
[yirs 2018]: /en/newsletters/2018/12/28/
[yirs 2019]: /en/newsletters/2019/12/28/
[yirs 2020]: /en/newsletters/2020/12/23/
[yirs 2021]: /en/newsletters/2021/12/22/
