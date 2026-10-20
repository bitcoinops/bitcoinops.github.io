---
title: 'Bitcoin Optech Newsletter #33'
permalink: /zh/newsletters/2019/02/12/
name: 2019-02-12-newsletter-zh
slug: 2019-02-12-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布 LND 发布最新版本，简要介绍一个用于生成比特币所有权证明的工具，并链接到 Optech 关于 Replace-by-Fee 可用性的一项研究。此外还包括热门 Bitcoin 基础设施项目值得注意的代码变更摘要。

## 行动项

- **<!--upgrade-to-lnd-0-5-2-->****升级到 LND 0.5.2：**这个次要版本[发布][lnd release]修复了与稳定性相关的 bug，并改善了与其他 LN 软件的兼容性。

## 新闻

- **<!--tool-released-for-generating-and-verifying-bitcoin-ownership-proofs-->****发布用于生成和验证比特币所有权证明的工具：**Blockstream [发布][reserve audit tool]了一个工具，帮助比特币托管方（如交易所）在不创建链上交易的情况下证明自己控制着一定数量的比特币。该工具的原理是构造一笔几乎有效的交易，其中包含一笔有效交易应有的全部信息——从而证明创建者掌握着创建这笔花费所需的全部信息（例如私钥）。该工具用 Rust 编程语言编写，采用越来越流行的 BIP174 部分签名比特币交易（PSBT）格式，以便与 Bitcoin Core 及其他比特币工具互操作。该工具后续计划加入隐私增强。

- **<!--rbf-usability-study-published-->****发布 RBF 可用性研究：**2018 年确认的交易中，只有约 6% 发出信号表示支持 [BIP125][] 自愿启用的手续费替换（RBF）。为此，Optech 贡献者 Mike Schmidt 对近二十个流行的比特币钱包、区块浏览器和其他服务做了一项[考察][rbf report]，了解它们如何处理发送或接收 RBF 交易（包括手续费追加）。报告用截图举例，展示了众多系统处理 RBF 交易的好做法与坏做法。列出问题示例并不是为了批评这些系统的开拓者，而是帮助所有比特币开发者掌握 RBF 提供的强大手续费管理能力。报告最后基于所收集的示例，汇总了给开发者的建议。

## 值得注意的代码变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码变更。*

- [Bitcoin Core #14897][] 在请求交易时引入一种半随机顺序，并让顺序偏向出站连接，使攻击者更难滥用 Bitcoin Core 某项节省带宽的机制。此前，当你的节点从某个对等方收到新交易的通告时，它会向该对等方请求这笔交易。在等待交易发来的期间，它可能又从其他对等方收到同一笔交易的通告。如果第一个对等方在两分钟内没有把交易发来，你的节点会转而向第二个通告该交易的对等方请求，再等两分钟，然后才向下一个对等方请求。这样一来，攻击者只要能对你的节点打开大量连接，就可能使你接收交易的时间被推迟许多个两分钟。

  如果这种攻击在整个网络范围内实施，就可能让某些交易无法到达矿工，进而破坏那些依赖及时确认的协议的安全性（例如 LN 支付通道）。全网范围的攻击还可能让人[更容易][coinscope][测绘][txprobe]网络并重定向交易流量，从而查出某笔交易源自哪个 IP 地址。

  有了这个 PR，只有当你的节点当初主动与该对等方建立连接（即出站对等方）时，它才会立刻向第一个通告该交易的对等方请求交易。如果你最先是从某个主动连接你的对等方（入站对等方）那里听说这笔交易，你会先等两秒钟再请求，以便给出站对等方一个先告诉你的机会。如果你第一个向其请求交易的对等方在一分钟内没有把交易发来，你会再随机选一个对等方请求。若仍不成功，就继续随机挑选对等方请求。这并未彻底解决问题，但确实意味着，想延迟某笔交易的攻击者要达到同样的延迟效果，多半需要运营多得多的节点。基于 [libminisketch][] 之类技术的集合协调，或许能为任何至少有一个诚实对等方的节点提供完整解决方案。

- [Bitcoin Core #14491][] 允许 `importmulti` RPC 导入用[输出脚本描述符][output script descriptors]指定的密钥。以这种方式导入的密钥会被转换成当前的钱包数据结构，但最终计划是让 Bitcoin Core 钱包内部改用描述符。

- [Bitcoin Core #14667][] 添加了一个新的 `deriveaddress` RPC，它接受一个包含密钥路径和扩展公钥的描述符，并返回对应的地址。

- [Bitcoin Core #15226][] 为 `createwallet` RPC 添加了一个 `blank` 参数，允许创建不含 HD 种子或任何私钥的钱包。之后可以向钱包添加私钥或公钥材料（例如用 `sethdseed` 设置 HD 种子，或用 `importaddress` 添加只读地址）。也可以在钱包仍为空白时用 `encryptwallet` RPC 加密。用“blank”一词，是为了把不带密钥的钱包与“empty”钱包（密钥不控制任何比特币）区分开。

- [LND #2457][] 添加了一个 `cancelinvoice` RPC，用于取消尚未结算的发票。如果有一笔针对已取消发票的支付到达你的节点，它会返回与“该发票从未存在”时相同的错误，使这笔支付无法成功，并把全部资金退还给付款方。

- [LND #2572][] 为 `sendpayment` 命令添加了一个 `outgoing_chan_id` 参数。你可以用它指定由自己的哪个通道来走这笔支付的第一跳。

- [Eclair #736][] 添加了对连接 Tor 隐藏服务（.onion）和自身作为隐藏服务运行这两者的支持，并提供了[文档][eclair tor]。

{% include references.md %}
{% include linkers/issues.md issues="736,2572,2457,15226,14491,14667,14897" %}
[lnd release]: https://github.com/lightningnetwork/lnd/releases/tag/v0.5.2-beta
[coinscope]: https://www.cs.umd.edu/projects/coinscope/coinscope.pdf
[txprobe]: https://arxiv.org/pdf/1812.00942.pdf
[reserve audit tool]: https://blockstream.com/2019/02/04/standardizing-bitcoin-proof-of-reserves/
[eclair tor]: https://github.com/ACINQ/eclair/blob/master/TOR.md
[rbf report]: /en/rbf-in-the-wild/
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
