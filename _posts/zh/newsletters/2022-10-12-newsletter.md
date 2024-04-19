---
title: 'Bitcoin Optech Newsletter #221'
permalink: /zh/newsletters/2022/10/12/
name: 2022-10-12-newsletter-zh
slug: 2022-10-12-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报总结了一份让普通的闪电网络用户可以连续离线长达数月的提议，以及一份让交易信息服务器托管未使用的钱包地址的文档。此外还有我们的常规栏目：Bitcoin Core RP 审核俱乐部、软件的新版本和候选版本（包括 LND 软件的一个重大更新），以及热门的比特币基础设施软件的重大更新。

## 新闻

- **<!--ln-with-long-timeouts-proposal-->超时时间更长的闪电通道提议**：John Law 在 Lightning-Dev 邮件组中[发帖][law post]，列出一份[协议][law pdf]，让普通的闪电网络用户可以离线长达数个月而不必担心在通道中丢失资金。虽然从技术上来说，这在当前的闪电网络协议中也是做得到的，但当前的实现方式为将结算延迟参数设为更高的数值，但这会让恶意用户有机可乘：他们可以让数十条通道的资金锁死几个月；意外也有可能导致这种效果。Law 提出了两项协议层的修改来缓解这个问题：

  - *<!--triggered-htlcs-->带扳机的哈希时间锁合约*：标准的 [HTLC][topic htlc] 的运作方式是：如果 Bob 能揭晓一个已知的哈希指纹的未知 *原像*，Bob 就能拿走 Alice 放在合约中的钱。相反，如果 Bob 不能及时揭晓原像，Alice 就能把合约中的钱回收到自己的钱包。

    Law 的建议是：Bob 依然可以随时通过揭晓原像拿走资金，但 Alice 需要遵守一项额外的约束。当 Alice 要明确警告 Bob 她意图回收资金时，需要在链上发起一笔 *扳机* 交易。只有当扳机交易得到一定数量的区块确认（或被确认一段时间之后），Alice 才能花费合约中的资金。

    这将保证，在扳机交易得到预先约定的确认数量以前，Bob 随时能拿走合约中的资金，即使经过了几个月也不要紧，因为这种 HTLC 不带默认的超时机制。只要 Bob 的等待能得到充分的补偿，Alice 一直离线也没关系。如果支付从 Alice 发起、经过 Bob 流向了远方的节点，那么只有 Alice 和 Bob 之间的通道会受到影响 —— 其它的通道都会立即结算（就像当前的闪电网络协议一样）。

  - *<!--asymmetric-delayed-commitment-transactions-->对称的带延迟的承诺交易*：一条闪电通道的两个参与者都保存着未公开的承诺交易，他们随时可以发布这笔交易并使之得到区块链的确认，但是，双方的交易都花费同一个 UTXO，所以他们彼此竞争 —— 意思是只有一方的交易能最终得到确认。

    这意味着，当 Alice 想关闭通道的时候，她不能单纯广播自己手中的承诺交易、设置合理的费率并等待确认。她必须等待和检查 Bob 有没有发布他手中的承诺交易，如果有的话，Alice 还要采取额外的步骤来验证 Bob 广播出来的交易是否包含最新的通道状态。

    Law 的提议是，Alice 的承诺交易可以跟当前的形式一致，这样她就可以随时发布，但 Bob 的版本就带有时间锁，这样他只能在 Alice 不活跃一段时间后发布。理想情况下，这将允许 Alice 在知晓 Bob 无法发布相互竞争的版本的前提下发布最新的状态，因此她可以在发布之后安全地离线。

  在本刊撰写之时，Law 的提议还在接收初步的反馈。

- **<!--recommendations-for-unique-address-servers-->唯一地址服务端的建议**：Rube Somsen 在 Bitcoin-Dev 邮件组中[发帖][somsen post]列出了一份[文档][somsen gist]，为不想信任第三方服务端、也不想使用当前未受广泛支持的密码学协议（比如 [BIP47][] 和[静默支付][topic silent payments]）、又想避免[输出关联][topic output linking]的用户提出了另一种建议。这个建议尤其是为已经把地址交给了第三方的钱包提出的，比如那些使用公开的[地址检索服务端][topic block explorers]的钱包（人们认为绝大部分轻钱包都是这样做的）。

  举个例子来演示下这种方法是怎么工作的。假设 Alice 在 Example.com 这个 electrum 式的服务端注册了 100 个地址。然后，她在自己的邮件签名中包含了 “example.com/alice”。当 Bob 想要给 Alice 捐钱时，就访问她的 URL，获得一个地址，验证 Alice 签名过这个地址，然后就给这个地址支付。

  这个想法的优点之一是，它可以通过半手动的流程跟当前的钱包广泛兼容，而且可能易于实现自动化的流程。其缺点是，用户已经因为跟服务端分享地址而损失了隐私性，如今将进一步承担隐私损失。

  在本刊撰写之时，邮件组和文档页面中仍然在对这个提议展开讨论。

## Bitcoin Core PR 审核俱乐部

*在这个月度栏目中，我们会总结近一期 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club] 会议的内容，并列出一些重要的问题和回答。点击下文的问题描述将能看到会议中的答案的总结。*

“[让 AddrFetch 连接到固定的种子节点][review club 26114]” 是 Martin Zumsande 提出的一个 PR，让 `AddrFetch` 连接到[固定的种子节点][fixed seeds]（硬编码的 IP 地址），而不是只添加这些地址到 `AddrMan` （对等节点的数据库）。

{% include functions/details-list.md
  q0="当一个新节点从零开始起步时，它必须连接一些对等节点，以执行初次区块下载（IBD）。什么情况下它会连接到固定的种子节点？"
  a0="只有在它无法连接到由硬编码的比特币 DNS 种子节点提供的对等节点时，才会这样做。最场景的情况是节点设置不是 IPv4 和 IPv6 时（举个例子，使用了  ` onlynet=tor ` ）。"
  a0link="https://bitcoincore.reviews/26114#l-27"

  q1="这个 PR 会产生什么样可观察到的行为改变？我们会给 `AddrMan` 添加什么样的地址，会在什么情况下添加呢？"
  a1="应用此 PR 的代码以后，节点不会立即将固定的种子节点添加到 `AddrMan` 并完全连接某一些节点，而是会使用 `AddrFetch` 连接到某一些简单，然后将 *返回的地址* 添加到 ` AddrMan ` 。（ `AddrFetch` 是短期的连接，仅用于拉取地址。）然后，节点会连接到 `AddrMan` 中的一些地址以执行 IBD。这会导致节点对固定种子节点的全面连接更少；相反，节点会尝试在固定种子节点返回的、更大的节点集合中尝试连接。 `AddrFetch` 连接可能返回 *任何* 类型的地址，比如 ` tor ` 地址；所以结果并不限于  IPv4 和 IPv6。"
  a1link="https://bitcoincore.reviews/26114#l-63"

  q2="为什么我们会想要使用 ` AddrFetch ` 连接而不是完全连接到固定的种子节点呢？这也符合固定种子节点背后的运营者的倾向吗？"
  a2=" ` AddrFetch ` 连接让节点可以从更大的节点集合中选择执行 IBD 的对等节点，这会提升整体上的网络连接分散性。固定种子节点的运营者也不太可能同时允许多个 IBD 对等节点，这样做可以降低节点的资源要求。"
  a2link="https://bitcoincore.reviews/26114#l-77"

  q3="人们预期 DNS 种子节点会响应并提供最新的比特币节点地址。为什么这个特性无法帮助 ` -onlynet=tor ` （只使用洋葱网络）的节点？"
  a3="DNS 种子节点只提供 IPv4 和 IPv6 的地址；无法提供其它类型的网络地址。"
  a3link="https://bitcoincore.reviews/26114#l-35"
%}

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND v0.15.2-beta][] 是一个重大的安全性紧急更新，修复了一个解析错误，该错误会导致 LND 无法正确处理特定的区块。所有用户都应该升级。
- [Bitcoin Core 24.0 RC1][] 是这个最常用的全节点实现的第一个候选版本。有一个[测试指南][bcc testing]。

## 重大的代码和文档更新

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo] 和 [Lightning BOLTs][bolts repo]。*

- [LND #6500][] 加入了在硬盘中使用钱包的私钥加密 Tor 私钥的功能（不再是明文存储）。使用  ` --tor.encryptkey ` 标签，LND 就会加密这个私钥，并且加密后的数据会写在硬盘的同一个文件中，这样用户就能继续使用相同的功能模块（例如刷新一个隐藏的服务），同时，运行在不可信任的环境中时可以添加额外的保护。

{% include references.md %}

{% include linkers/issues.md v=2 issues="6500" %}
[review club 26114]: https://bitcoincore.reviews/26114
[bitcoin core 24.0 rc1]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[law post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-October/003707.html
[law pdf]: https://raw.githubusercontent.com/JohnLaw2/ln-watchtower-free/main/watchtowerfree10.pdf
[somsen post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-September/020952.html
[somsen gist]: https://gist.github.com/RubenSomsen/960ae7eb52b79cc826d5b6eaa61291f6
[news113 witasym]: /en/newsletters/2020/09/02/#witness-asymmetric-payment-channels
[lnd v0.15.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.2-beta
[fixed seeds]: https://github.com/bitcoin/bitcoin/tree/master/contrib/seeds
