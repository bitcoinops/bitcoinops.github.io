---
title: 'Bitcoin Optech Newsletter #151'
permalink: /zh/newsletters/2021/06/02/
name: 2021-06-02-newsletter-zh
slug: 2021-06-02-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一个提案，提议修改 Bitcoin Core 的交易选择算法来构建矿工区块模板，以在略微提升矿工利润的同时，为手续费提升（fee bumping）的用户带来更多的集体影响力。此外，我们也照例介绍了新软件版本及候选发布版本，并列出了常用比特币基础设施软件的值得注意的变更内容。

## 新闻

- **<!--candidate-set-based-csb-block-template-construction-->****基于候选集（CSB）的区块模板构建：** Mark Erhardt [公告][erhardt post]到 Bitcoin-Dev 邮件列表，介绍了他与 Clara Shikhelman 对矿工使用的另一种交易选择算法进行的[分析][es analysis]。Bitcoin 的共识规则要求：如果某笔交易包含未确认的祖先交易，那么只有这些祖先交易也在同一个区块中更早地被包含时，该笔交易才能被打包进区块。Bitcoin Core 通过将每笔包含未确认祖先的交易视为同时拥有祖先的费用和大小来解决这一约束。例如，如果交易 B 依赖于未确认的交易 A，那么 Bitcoin Core 会将这两笔交易的费用加在一起，再除以两笔交易合并后的大小，从而在根据实际费率（effective feerate）对比内存池中所有交易时，无论这些交易是否有祖先都能进行公平比较。

  然而，Erhardt 和 Shikhelman 指出，如果使用一种需要稍多 CPU 资源的更复杂算法，或许可以找到与现有算法相比利润更高的关联交易组合。作者在历史内存池数据上测试了他们的算法，发现它几乎在最近所有区块中都能比 Bitcoin Core 目前的简化算法多收集到少量的交易费用。

  如果矿工实现并使用该改进算法，则能够让多个用户（他们分别从一次大型 [Coinjoin][topic coinjoin] 或[批量付款][topic payment batching]中获得输出）为 CPFP (Child-Pays-For-Parent) 提升交易费时，各自仅支付部分总额的所需费用。与当前每个用户的 CPFP 费用独立计入，且多个相关的费用提升操作未必能对祖先交易是否被打包产生叠加影响的情况相比，这是一种改进。

## 发布与候选发布

*适用于常用比特币基础设施项目的新版本与候选发布版本。请考虑升级到新版本，或协助测试候选发布版本。*

- [HWI 2.0.2][]
  这是一个小幅更新版本，新增了对使用 BitBox02 进行消息签名的支持，并且始终使用 `h` 来指示具备强化派生的 [BIP32][] 路径，而不再使用 `'`。同时还包含若干错误修复。

- [LND 0.13.0-beta.rc3][LND 0.13.0-beta]
  这是一个候选发布版本，增加了对修剪过的比特币全节点的支持，允许使用原子多路径支付（Atomic MultiPath，简称 [AMP][topic multipath payments]）来接收和发送付款，并提升了其 [PSBT][topic psbt] 功能，还包含其他改进与错误修复。

## 值得注意的代码和文档更改

*以下是本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中的值得注意的变更：*

- [Bitcoin Core #20833][]
  这是在 Bitcoin Core 中实现[内存池包接收][package mempool accept blog]功能的首个拉取请求（pull request），该改动允许在 `testmempoolaccept` RPC 中一次性接受多笔彼此有依赖关系的交易。未来的拉取请求可能会允许测试 L2 交易链、通过 RPC 将交易包直接提交到内存池以及通过 P2P 网络传播这些交易包。

- [Bitcoin Core #22017][]
  更新了用于 Windows 发布版本的代码签名证书，因为此前的证书已在未说明具体原因的情况下被签发机构吊销。若干近期发布的 Bitcoin Core 版本可能会以略有差异的版本号重新发布，以便其 Windows 可执行文件能使用新的证书。

- [Bitcoin Core #18418][]
  如果钱包启用了 `avoid_reuse` 标志，则增加了同时花费发送到同一地址的 UTXO 数量上限。一次性花费的输出越多，相较于使用默认标志的钱包，对于该笔交易而言可能产生更高的费用，但第三方据此识别用户后续交易的难度也随之增加。

- [C-Lightning #4501][]
  为 C-Lightning 当前大约一半的命令添加了 [JSON 模式][JSON schemas]（计划未来会为剩余的命令添加相应的模式定义）。在运行 C-Lightning 的测试套件时会根据这些模式校验命令输出，以保证一致性。同时也用这些模式自动生成 C-Lightning 文档中关于各命令输出格式的说明。

- [LND #5025][]
  为使用 [signet][topic signet] 提供了基础支持。在 Optech 跟踪的其他闪电网络实现中，C-Lightning 同样提供了对 signet 的支持（参见 [Newsletter #117][news117 cl4068]）。

- [LND #5155][]
  新增了一个配置选项，可随机选择将要在交易中花费的钱包 UTXO，从而随着时间推移降低钱包中的 UTXO 碎片化程度。相比之下，LND 默认的找零算法会优先花费面值较大的 UTXO，再花费面值较小的 UTXO，这虽然能在短期内降低费用，但也可能导致将来当大多数接近或超过单笔交易大小的输入已经被花费后，需要承担更高的交易费用。

- [BOLTs #672][]
  更新了 [BOLT2][]，允许节点协商启用 `option_shutdown_anysegwit` 选项。如果该选项被启用，闪电网络的关闭交易就可以支付给任意 segwit 脚本版本，包括尚未在网络上具有共识含义的脚本类型（例如针对 [taproot][topic taproot] 的地址）。

- [BOLTs #872][]
  更新了 [BOLT3][] 对 [BIP69][] 的使用方式，进一步详细说明了在为承诺交易（commitment transaction）排定输入和输出顺序时应采用的排序规则。有评论者指出，截至目前对 BIP69 的使用已造成三次独立的问题，可能导致通道意外关闭和小额资金被浪费在不必要的链上费用里。该评论者还建议这是进一步摆脱对 BIP69 明确依赖的理由之一（更多原因可参见 [Newsletter #19][news19 bip69]）。

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
