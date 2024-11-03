---
title: 'Bitcoin Optech Newsletter #33'
permalink: /zh/newsletters/2019/02/12/
name: 2019-02-12-newsletter-zh
slug: 2019-02-12-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 宣布了 LND 的最新版本，简要描述了一个生成比特币所有权证明的工具，并链接到一个关于 Replace-by-Fee 可用性的 Optech 研究。同时还包括对流行 Bitcoin 基础设施项目值得注意的代码更改的摘要。

## 行动项

- **<!--upgrade-to-lnd-0-5-2-->****升级到 LND 0.5.2：**此小版本[发布][lnd release]修复了与稳定性相关的错误并改进了与其他 LN 软件的兼容性。

## 新闻

- **<!--tool-released-for-generating-and-verifying-bitcoin-ownership-proofs-->****发布用于生成和验证比特币所有权证明的工具：**Blockstream 已[发布][reserve audit tool]一个工具，帮助比特币托管方（如交易所）在不创建链上交易的情况下证明他们控制一定数量的比特币。该工具通过创建一个几乎有效的交易来工作，该交易包含所有与有效交易相同的信息——证明交易创建者可以访问创建支出所需的所有信息（例如私钥）。该工具使用 Rust 编程语言编写，并使用越来越流行的 BIP174 部分签名比特币交易（PSBT）格式，以实现与 Bitcoin Core 和其他比特币工具的互操作性。该工具的未来计划包括隐私增强。

- **<!--rbf-usability-study-published-->****发布 RBF 可用性研究：**由于 2018 年只有约 6% 的交易确认支持 [BIP125][] 选择加入 Replace-by-Fee (RBF)，Optech 贡献者 Mike Schmidt 进行了[一个检查][rbf report]，检查了近二十个流行的比特币钱包、区块浏览器和其他服务，以了解它们如何处理发送或接收 RBF 交易（包括费用增加）。他的报告提供了视觉示例，包括系统处理 RBF 交易的好与坏示例。问题示例并非用于批评这些系统的先锋开发者，而是帮助所有比特币开发者掌握 RBF 提供的强大费用管理能力。根据收集的示例，报告总结了对开发者的建议。

## 值得注意的代码更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码更改。*

- [Bitcoin Core #14897][] 引入了一种偏向于出站连接的半随机顺序请求交易，使攻击者更难滥用 Bitcoin Core 的带宽减少措施。之前，当你的节点从一个对等方收到新交易的公告时，它会向该对等方请求该交易。在等待交易发送期间，它可能从其他对等方收到相同交易的公告。如果第一个对等方在两分钟内没有发送交易，你的节点会向第二个宣布交易的对等方请求交易，再次等待两分钟，然后再向下一个对等方请求。这允许一个打开大量连接到你节点的攻击者可能通过多个两分钟的间隔延迟你接收交易。

  如果这种攻击在整个网络中执行，可能会阻止某些交易到达矿工，可能破坏依赖及时确认的协议的安全性（例如 LN 支付通道）。全网攻击也可能使[更容易][coinscope] [映射][txprobe]网络并重定向交易流量以了解哪个 IP 地址发起了交易。

  有了这个 PR，如果你的节点最初选择打开与该对等方的连接（即出站对等方），它将仅立即从第一个宣布的对等方请求交易。如果你首先从连接到你的对等方（入站对等方）听到交易，你会等待两秒钟再请求交易，以便让一个出站对等方首先告诉你交易。如果第一个请求交易的对等方在一分钟内没有发送交易，你会随机选择另一个对等方请求交易。如果这也不起作用，你会继续随机选择对等方请求交易。这不会消除问题，但这意味着一个想要延迟交易的攻击者可能需要操作更多的节点来达到相同的延迟。基于类似 [libminisketch][] 的集合和解技术可能为任何至少有一个诚实对等方的节点提供完整的解决方案。

- [Bitcoin Core #14491][] 允许 `importmulti` RPC 使用[输出脚本描述符][output script descriptors]导入密钥。以这种方式导入的密钥将被转换为当前的钱包数据结构，但最终计划是 Bitcoin Core 的钱包内部使用描述符。

- [Bitcoin Core #14667][] 添加了一个新的 `deriveaddress` RPC，它接受一个包含密钥路径和扩展公钥的描述符并返回相应的地址。

- [Bitcoin Core #15226][] 为 `createwallet` RPC 添加了一个 `blank` 参数，允许创建没有 HD 种子或任何私钥的钱包。然后可以向钱包添加私钥或公钥材料（例如使用 `sethdseed` 的 HD 种子或使用 `importaddress` 的仅监视地址）。钱包仍然为空时也可以使用 `encryptwallet` RPC 加密。使用“blank”一词是为了区分没有密钥的钱包和没有控制任何比特币的“empty”钱包。

- [LND #2457][] 添加了一个 `cancelinvoice` RPC，以取消尚未结算的发票。如果一个已取消发票的支付到达你的节点，它会返回一个错误，就像该发票从未存在一样，防止支付成功并将所有资金返还给付款人。

- [LND #2572][] 为 `sendpayment` 命令添加了一个 `outgoing_chan_id` 参数。你可以使用此参数指定哪一个通道应被用于支付的第一跳。

- [Eclair #736][] 添加了连接 Tor 隐藏服务（.onion）和作为隐藏服务运行的支持。[文档][eclair tor]为用户提供了说明。

{% include references.md %}
{% include linkers/issues.md issues="736,2572,2457,15226,14491,14667,14897" %}
[lnd release]: https://github.com/lightningnetwork/lnd/releases/tag/v0.5.2-beta
[coinscope]: https://www.cs.umd.edu/projects/coinscope/coinscope.pdf
[txprobe]: https://arxiv.org/pdf/1812.00942.pdf
[reserve audit tool]: https://blockstream.com/2019/02/04/standardizing-bitcoin-proof-of-reserves/
[eclair tor]: https://github.com/ACINQ/eclair/blob/master/TOR.md
[rbf report]: /en/rbf-in-the-wild/
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
