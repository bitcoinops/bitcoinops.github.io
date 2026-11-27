---
title: 'Bitcoin Optech Newsletter #151'
permalink: /zh/newsletters/2021/06/02/
name: 2021-06-02-newsletter-zh
slug: 2021-06-02-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一个提案，提议修改 Bitcoin Core 为构建矿工区块模板而采用的交易选择算法，以略微提升矿工利润，并让追加手续费（fee bumping）的用户获得更强的集体影响力。此外，我们也照例介绍了新软件版本及候选发布版本，以及热门比特币基础设施软件的值得注意的变更。

## 新闻

- **<!--candidate-set-based-csb-block-template-construction-->****基于候选集（CSB）的区块模板构建：** Mark Erhardt 在 Bitcoin-Dev 邮件列表上[发帖][erhardt post]，介绍了他与 Clara Shikhelman 对矿工可用的另一种交易选择算法所做的[分析][es analysis]。Bitcoin 的共识规则要求：任何交易都不允许被打包进区块，除非它所有未确认的祖先交易也都更早地包含在同一区块里。Bitcoin Core 处理这一约束的方式，是把每笔带有未确认祖先的交易视为包含了这些祖先的手续费和大小。例如，如果交易 B 依赖于未确认的交易 A，那么 Bitcoin Core 会把两笔交易支付的手续费相加，再除以两笔交易合并后的大小。这样，无论交易是否有祖先，Bitcoin Core 都能依据有效费率（effective feerate）公平地比较内存池中的所有交易。

  然而，Erhardt 和 Shikhelman 指出，一种稍多占用 CPU 的更复杂算法可以找到关联交易的集合，挖这些交易比用 Bitcoin Core 现有的简单算法更有利可图。两位作者在历史内存池数据上测试了该算法，发现在最近几乎所有区块中，它都能比 Bitcoin Core 现有的算法多收集到略多一些的手续费。

  如果矿工实现并使用这一改进算法，那么多个用户——他们各自从一次大型 [coinjoin][topic coinjoin] 或[批量付款][topic payment batching]中收到了一个输出——就可以各自只承担一部分总手续费，这些手续费合起来足以对那笔 coinjoin 或批量付款做一次[子为父付（CPFP）][topic cpfp]手续费追加。目前，每个用户的 CPFP 手续费追加都会被单独考虑，多个相关的追加操作加起来也未必能影响祖先交易是否被打包；相比之下，这将是一种改进。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [HWI 2.0.2][]
  这是一个小幅更新版本，新增了对使用 BitBox02 进行消息签名的支持，并始终用 `h` 而非 `'` 来表示带硬化派生的 [BIP32][] 路径，还包含若干错误修复。

- [LND 0.13.0-beta.rc3][LND 0.13.0-beta]
  这是一个候选发布版本，增加了对修剪过的比特币全节点的支持，允许使用原子多路径支付（Atomic MultiPath，简称 [AMP][topic multipath payments]）来接收和发送付款，并提升了其[部分签名比特币交易（PSBT）][topic psbt]功能，还包含其他改进与错误修复。

## 值得注意的代码与文档变更

*以下是本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]的值得注意的变更：*

- [Bitcoin Core #20833][]
  这是在 Bitcoin Core 中实现[内存池包接收][package mempool accept blog]功能的首个 PR，该改动允许 `testmempoolaccept` RPC 接受多笔交易，其中靠后的交易可以是靠前交易的后代。未来的 PR 可能会允许测试 L2 交易链、通过 RPC 将交易包直接提交到内存池，以及通过 P2P 网络传播交易包。

- [Bitcoin Core #22017][]
  更新了用于 Windows 发布版本的代码签名证书，因为此前的证书已在未说明具体原因的情况下被签发机构吊销。若干近期发布的 Bitcoin Core 版本可能会以略有差异的版本号重新发布，以便其 Windows 可执行文件能使用新的证书。

- [Bitcoin Core #18418][]
  如果钱包设置了 `avoid_reuse` 标志，则提高了发送到同一地址、会被同时花费的 UTXO 数量上限。一次花掉的输出越多，这笔交易的手续费相对使用默认标志的钱包就可能越高；但与此同时，第三方也就越难识别出用户后续的交易。

- [C-Lightning #4501][]
  为 C-Lightning 当前大约一半的命令添加了 [JSON 模式][JSON schemas]（计划未来会为剩余的命令添加相应的模式定义）。在运行 C-Lightning 的测试套件时会根据这些模式校验命令输出，以保证一致性。同时也用这些模式自动生成 C-Lightning 文档中关于各命令输出格式的说明。

- [LND #5025][]
  为使用 [signet][topic signet] 提供了基础支持。在 Optech 跟踪的其他闪电网络实现中，C-Lightning 同样提供了对 signet 的支持（参见 [Newsletter #117][news117 cl4068]）。

- [LND #5155][]
  新增了一个配置选项，可以随机选择交易中要花费哪些钱包 UTXO，从而随着时间推移降低钱包的 UTXO 碎片化程度。相比之下，LND 默认的选币算法会先花面值较高的 UTXO，再花面值较低的 UTXO；这能在短期内把手续费压到最低，但将来那些大小接近甚至超过一笔交易规模的输入都被花掉之后，可能就需要支付更高的手续费。

- [BOLTs #672][]
  更新了 [BOLT2][]，允许节点协商启用 `option_shutdown_anysegwit` 选项。设置该选项后，闪电网络的关闭交易就可以支付给任意 segwit 脚本版本，包括那些在网络上尚无共识含义的脚本类型，例如 [taproot][topic taproot] 地址。

- [BOLTs #872][]
  更新了 [BOLT3][] 对 [BIP69][] 的使用，进一步细化了承诺交易（commitment transaction）的输入与输出应采用的排序规则。有评论者指出，使用 BIP69 迄今已造成三个彼此独立的问题，可能导致通道被意外关闭，少量资金也因不必要的链上手续费而损失。该评论者认为，这是又一个应当摆脱显式使用 BIP69 的理由（其他理由参见 [Newsletter #19][news19 bip69]）。

{% include references.md %}
{% include linkers/issues.md issues="20833,22017,18418,4501,5025,5155,672,872" %}
[LND 0.13.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.0-beta.rc3
[HWI 2.0.2]: https://github.com/bitcoin-core/HWI/releases/tag/2.0.2
[erhardt post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-May/019020.html
[es analysis]: https://gist.github.com/Xekyo/5cb413fe9f26dbce57abfd344ebbfaf2#file-candidate-set-based-block-building-md
[news117 cl4068]: /zh/newsletters/2020/09/30/#c-lightning-4068
[news19 bip69]: /zh/newsletters/2018/10/30/#bip69-discussion
[json schemas]: http://json-schema.org/
[package mempool accept blog]: https://brink.dev/blog/2021/01/21/fellowship-project-package-accept/
