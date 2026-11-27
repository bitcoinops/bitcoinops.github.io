---
title: 'Bitcoin Optech Newsletter #140'
permalink: /zh/newsletters/2021/03/17/
name: 2021-03-17-newsletter-zh
slug: 2021-03-17-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了关于挽救丢失的闪电网络注资交易的讨论，并包含我们的固定栏目：发布与候选发布的公告，以及热门比特币基础设施软件的值得注意的变更。

## 新闻

- **<!--rescuing-lost-ln-funding-transactions-->****挽救丢失的闪电网络注资交易：**
  闪电网络注资交易在存在交易可延展性的情况下并不安全。segwit 消除了第三方可延展性对大多数交易的影响，<!-- by "most", I mean everything signed SIGHASH_ALL -->但并未解决交易创建者自行更改其 txid 的情况，例如使用[手续费替换（RBF）][topic rbf] 来提高注资交易的手续费。如果 txid 发生变化，预先签署的退款交易就无效了，用户无法取回资金。此外，远端节点可能不会自动看到该注资交易，因此也无法协助出资方追回资金。

  本周，Rusty Russell 在 Lightning-Dev 邮件列表上[发布][russell funding rescue]了他在 C-Lightning 中实现的一个快速实验性功能，用来帮助一位遇到此问题的用户挽回资金。他还介绍了针对相关问题的其他可选方案，以及[拟议的][bolts #851]通道双向资助协议会对这一问题产生什么影响。Christian Decker 也[发布][decker funding rescue]了一项针对 LN 规范的[拟议更改][bolts #854]，以协助资金恢复工作。随着 LN 软件增加从外部钱包为通道提供资金的支持（例如 [Newsletter #51][news51 cl2672] 中的 C-Lightning 和 [Newsletter #92][news92 lnd4079] 中的 LND），开发者或许需要更多关注这类失败场景。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [HWI 2.0.0][hwi 2.0.0] 是 HWI 下一个主要版本的正式发布。除其他改进外，它包含对 BitBox02 上多重签名的支持、更完善的文档，以及用 Trezor 支付 OP_RETURN 输出的支持。

- [Rust-Lightning 0.0.13][] 是该闪电网络库的最新版本，包含旨在与[多路径支付][topic multipath payments]以及 [taproot][topic taproot] 等未来脚本升级保持前向兼容的改进。

- [BTCPay Server 1.0.7.0][] 是这款自托管支付处理软件的最新版本。值得注意的改进包括功能更丰富、界面更美观的钱包设置向导，可以导入用 Specter 创建的钱包，以及为 [bech32 地址][topic bech32]提供更高效的二维码。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo] 中的值得注意的变更。*

- [Bitcoin Core #21007][] 增加了一个新的 -daemonwait 配置选项。自早期版本起，就可以通过 -daemon 配置选项启动程序，让 Bitcoin Core 以后台守护进程方式运行。-daemon 选项会使程序立即在后台启动守护进程；新的 -daemonwait 选项与之类似，只是在初始化完成后才把守护进程转入后台。这样，用户或父进程通过观察程序的输出或退出码，就能更容易地判断守护进程是否成功启动。

- [C-Lightning #4404][] 允许 `keysend` RPC（参见 [Newsletter #107][news107 keysend]）即使对未明确表态支持该功能的节点也能发送消息。正如[讨论][fromknecht keysend]中所述，这一信号从未标准化，而 LND 的实现并不依赖该信号，因此这一更改应使 C-Lightning 能够向与 LND 大致相同的一批节点发送。

- [C-Lightning #4410][] 将双向资助通道的实验性实现与最新的[草案规范变更][bolts #851] 保持一致。最值得注意的是，离散对数等价性证明（PODLE）的使用已被移除，至少是暂时移除（关于 PODLE 的最初讨论见 [Newsletter #83][news83 podle]，替代方案的讨论见 [Newsletter #131][news131 podle]）。此次合并之后，又提交了一个[新的 PR][c-lightning #4427]，它去掉了用特殊编译标志编译 C-Lightning 的要求（不过仍需设置一个特殊配置选项），从而让双向资助的实验更容易开展。

- [LND #5083][] 允许从文件而不是从标准输入（stdin）文件描述符读取[部分签名比特币交易（PSBT）][topic psbt]。一些终端对一次能加入 stdin 的字符数（即粘贴的字符数）[有限制][lnd #5080]，这使得超过 4096 个 base64 字符（相当于 3,072 字节二进制数据）的 PSBT 无法使用。<!-- PSBTs are base64 encoded, base64 provides 6 bits per character, so 4096 * 6 / 8 = 3072 = 3 KiB --> 尤其在当前，数款硬件钱包要求 PSBT 中包含 segwit 花费所需的前序交易（参见 [Newsletter #101][news101 segwit overpayment]），因此创建超过 3 KiB 的 PSBT 已很常见。

- [LND #5033][] 增加了一个 `updatechanstatus` RPC，可用于公告某个通道已被禁用（类似于你的节点下线），或已被重新启用（类似于你的节点重新上线）。

- [Rust-Lightning #826][] 对于支付给单方面关闭通道的节点的那个输出，把 `OP_CHECKSEQUENCEVERIFY` 允许的最大延迟提高到 2,016 个区块。这解决了与 LND 建立通道时的互操作性问题：LND 可能要求最长 2016 个区块的延迟，超过了 Rust-Lightning 此前 1008 个区块的上限。

- [HWI #488][] 在配合 `--desc` 选项处理[输出脚本描述符][topic descriptors]时，对 `displayaddress` 命令处理多重签名地址的方式做了破坏性变更。此前，HWI 会根据所用设备的类型自动决定是否应用 [BIP67][] 字典序密钥排序（例如对 Coldcard 设备应用 BIP67，对 Trezor 设备则不应用）。这种实现方式在用户显式指定实现 BIP67 密钥排序的 `sortedmulti` 描述符选项时会出问题。更改后，使用描述符的用户需要为要求字典序密钥排序的设备指定 `sortedmulti`，为不要求的设备指定 `multi`。

{% include references.md %}
{% include linkers/issues.md issues="21007,4404,854,4410,4427,5083,5080,5033,826,488,851" %}
[hwi 2.0.0]: https://github.com/bitcoin-core/HWI/releases/tag/2.0.0
[rust-lightning 0.0.13]: https://github.com/rust-bitcoin/rust-lightning/releases/tag/v0.0.13
[btcpay server 1.0.7.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.0.7.0
[news51 cl2672]: /zh/newsletters/2019/06/19/#c-lightning-2672
[news92 lnd4079]: /zh/newsletters/2020/04/08/#lnd-4079
[russell funding rescue]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-March/002981.html
[decker funding rescue]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-March/002982.html
[news107 keysend]: /zh/newsletters/2020/07/22/#c-lightning-3792
[fromknecht keysend]: https://github.com/ElementsProject/lightning/issues/4299#issuecomment-781606865
[news83 podle]: /zh/newsletters/2020/02/05/#interactive-construction-of-ln-funding-transactions
[news131 podle]: /zh/newsletters/2021/01/13/#ln-dual-funding-anti-utxo-probing
[news101 segwit overpayment]: /zh/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
