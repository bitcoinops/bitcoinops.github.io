---
title: 'Bitcoin Optech Newsletter #294'
permalink: /zh/newsletters/2024/03/20/
name: 2024-03-20-newsletter-zh
slug: 2024-03-20-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报宣布了一个为轻型客户端创建 BIP324 代理的项目，并总结了有关拟议的 BTC Lisp 语言的讨论。此外，还包括我们的常规部分：介绍客户端和服务的最新变化，新版本和候选版本公告，并总结了流行的比特币基础设施软件的显著变化。

## 新闻

- **用于轻客户端的 BIP324 代理：** Sebastian Falbesoner 在 Delving Bitcoin 上[发布][falbesoner bip324]了一个 TCP 代理，用于在版本 1（v1）比特币 P2P 协议和 [BIP324][] 中定义的 [v2 协议][topic v2 p2p transport]之间进行转换。这特别是为了让 v1 编写的轻客户端钱包得以利用上 v2 的流量加密。

  轻客户端通常只公告属于自己钱包的交易，因此任何能够窃听未加密 v1 连接的人都能合理地断定轻客户端发送的交易属于使用原 IP 地址的人。在使用 v2 加密时，只有接收交易的完整节点才能确定交易来自轻客户端的 IP 地址，前提是轻客户端连接没有受到中间人攻击（在某些情况下有可能检测到中间人攻击，[以后的升级][topic countersign]可能会自动防御中间人攻击）。

  Falbesoner 最初的工作是将用 Python 编写的 BIP324 函数整合到 Bitcoin Core 的测试套件中，结果导致代理 “非常慢，而且容易受到侧信道攻击[并且]现在不建议将其用于测试以外的任何用途”。不过，他正在用 Rust 重写该代理，并可能将其部分或全部功能作为库提供给轻客户端或其他希望本地支持 v2 比特币 P2P 协议的软件。

- **BTC Lisp 概述：**Anthony Towns 在 Delving Bitcoin 上[发布][towns lisp]了他在过去几年中为比特币创建 [Lisp][] 语言变体的实验，名为 BTC Lisp。之前的讨论见周报 [#293][news293 lisp] 和 [#191][news191 lisp]。这篇文章非常详细，我们鼓励对这个想法感兴趣的人直接阅读。我们将简要引述其_结论_和_未来工作_部分：

  “[BTC Lisp] 在链上可能有点昂贵，但似乎你可以做几乎任何事情[……]我不认为实现 Lisp 解释器或需要与之配套的一系列操作码太难，[但]如果没有编译器将高级表示转换为共识级的操作码，编写 Lisp 代码是非常恼人的，[尽管]看起来可行。[这]项工作的下一步，[可通过]实现类似这样的语言来推进，并将其部署到 Signet/inquisition 上”。

  [Simplicity][topic simplicity] 语言未来也可能被视为共识脚本语言的替代语言。Russell O'Connor 是该语言的开发者，他在[回答][oconnor lisp]中对比特币当前的脚本语言、Simplicity 和 Chia/BTC Lisp 进行了一些比较。他总结道：“Simplicity 和 clvm（[Chia Lisp 虚拟机]）都是低级语言，旨在方便机器求值，这就造成了人类难以阅读的取舍。它们是被有意设计为从不同的、人类可读的、非共识关键的语言编译而成。Simplicity 和 clvm 用不同的方式表达了同样的老事情：从环境中获取数据、对数据位进行元组化处理、运行条件语句以及各种原始操作。[……] 既然我们希望这种[高效的低级共识语言和高级的非共识可理解语言之间的分裂]无关紧要，那么低级语言的细节就变得不那么重要了。也就是说，只要稍加努力，你的高级 BTC lisp 语言也许可以翻译/编译成 Simplicity 语言[……]同样的，无论[基于 Simplicity 的] [高级非共识语言] Simphony 的设计最终走向何方，它也许都可以翻译/编译[成]你的低级 BTC lisp 语言，每种翻译/编译语言对都提供了不同的潜在复杂性/优化机会”。

## 服务和客户端软件变更

*在这个月度栏目中，我们会标出比特币钱包和服务的有趣更新。*

- **BitGo 新增 RBF 支持：**
  在[最近的一篇博客][bitgo blog]中，BitGo 宣布在其钱包和 API 中支持使用[手续费替换（RBF）][topic rbf]来提高手续费。

- **Phoenix 钱包 v2.2.0 发布：**
  通过此版本，Phoenix 现在可以支持[通道拼接][topic splicing]，同时使用静止协商协议进行闪电网络支付（参见[周报 #262][news262 eclair2680]）。此外，Phoenix 还通过使用其 [swaproot][swaproot blog] 协议改进了换入功能的隐私和手续费。

- **Bitkey 硬件签名设备发布：**
  [Bitkey][bitkey website] 设备旨在与移动设备和 Bitkey 服务器密钥一起用于 2-3 多重签名设置。固件和各种组件的源代码目前[已可用][bitkey github]，是基于修改后的 MIT 许可协议（Commons Clause modified MIT License）。

- **Envoy v1.6.0 发布：**
  该[版本][envoy blog]增加了提升交易手续费和取消交易的功能，都基于手续费替换（RBF）。

- **VLS v0.11.0 发布：**
  该 [beta 版本][vls beta 3]允许在同一个闪电节点上使用多个签名设备。他们称之为[团队搭档签名（tag team signing）][vls blog]。

- **Portal 硬件签名设备发布：**
  [最近发布][portal tweet]的 Portal 设备可与使用 NFC 的智能手机配合使用。硬件和软件源码已[可用][portal github]。

- **Braiins 矿池新增闪电网络支持：**
   Braiins矿池[宣布][braiins tweet]推出通过闪电支付挖矿费用的 beta 应用。

- **Ledger 比特币应用程序 2.2.0 发布：**
  [2.2.0 版本][ledger 2.2.0]增加了对 [taproot][topic taproot] 的 [miniscript][topic miniscript] 支持。

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Bitcoin Core 26.1rc2][] 是这个网络主流全节点实现的维护发布候选版。

- [Bitcoin Core 27.0rc1][] 是这个网络主流全节点实现的下一个主要版本的候选发布版。

## 重大的代码和文档变更

_本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、
[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana
repo]。_

*注意：下面提到的对 Bitcoin Core 的提交适用于其主开发分支，因此这些改动可能要到即将发布的 27 版本发布后大约六个月才会发布。*

- [Bitcoin Core #27375][] 在 `-proxy` 和 `-onion` 功能中添加了对使用 Unix 域套接字而非本地 TCP 端口的支持。套接字可以比 TCP 端口更快，并提供了不同的安全权衡。

- [Bitcoin Core #27114][] 允许在 `whitelist` 配置参数中添加 “in” 和 “out”，以给予特定_传入_和_传出_连接特殊访问权限。默认情况下，白名单中列出的对等节点只有在连接到用户的本地节点（传入连接）时才会获得特殊访问权限。通过指定“传出”，用户现在可以确保对等节点在本地节点连接到它时获得特殊访问权限，例如用户调用 `addnode` RPC 时。

- [Bitcoin Core #29306][] 增加了对未确认 [v3 父交易][topic v3 transaction relay]所产生的交易的[亲属间驱逐][topic kindred rbf]功能。这可以为 [CPFP carve-out][topic cpfp carve out] 提供一个令人满意的替代方案。CPFP carve-out 目前由[闪电网络的锚点输出][topic anchor outputs]使用。主网目前尚未启用 V3 交易中继，包括亲属间驱逐。

- [LND #8310][] 允许从系统环境中检索 `rpcuser` 和 `rpcpass`（口令）配置参数。例如，这样就可以使用非私密的版本控制系统管理 `lnd.conf` 文件，而无需存储私密的用户名和口令。

- [Rust Bitcoin #2458][] 增加了对包含 taproot 输入的 [PSBT][topic psbt] 的签名支持。

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="27375,27114,29306,8310,2458" %}
[bitcoin core 26.1rc2]: https://bitcoincore.org/bin/bitcoin-core-26.1/
[Bitcoin Core 27.0rc1]: https://bitcoincore.org/bin/bitcoin-core-27.0/test.rc1/
[lisp]: https://en.wikipedia.org/wiki/Lisp_(programming_language)
[news293 lisp]: /zh/newsletters/2024/03/13/#overview-of-chia-lisp-for-bitcoiners-chia-lisp
[news191 lisp]: /en/newsletters/2022/03/16/#using-chia-lisp
[falbesoner bip324]: https://delvingbitcoin.org/t/bip324-proxy-easy-integration-of-v2-transport-protocol-for-light-clients-poc/678
[towns lisp]: https://delvingbitcoin.org/t/btc-lisp-as-an-alternative-to-script/682
[oconnor lisp]: https://delvingbitcoin.org/t/btc-lisp-as-an-alternative-to-script/682/7
[bitgo blog]: https://blog.bitgo.com/available-now-for-clients-bitgo-introduces-replace-by-fee-f74e2593b245
[news262 eclair2680]: /zh/newsletters/2023/08/02/#eclair-2680
[swaproot blog]: https://acinq.co/blog/phoenix-swaproot
[bitkey website]: https://bitkey.world/
[bitkey github]: https://github.com/proto-at-block/bitkey
[envoy blog]: https://foundation.xyz/2024/03/envoy-version-1-6-0-is-now-live/
[vls beta 3]: https://gitlab.com/lightning-signer/validating-lightning-signer/-/releases/v0.11.0
[vls blog]: https://vls.tech/posts/tag-team/
[portal tweet]: https://twitter.com/afilini/status/1766085500106920268
[portal github]: https://github.com/TwentyTwoHW
[braiins tweet]: https://twitter.com/BraiinsMining/status/1760319741560856983
[ledger 2.2.0]: https://github.com/LedgerHQ/app-bitcoin-new/releases/tag/2.2.0
