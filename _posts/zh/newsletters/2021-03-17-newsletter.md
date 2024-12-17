---
title: 'Bitcoin Optech Newsletter #140'
permalink: /zh/newsletters/2021/03/17/
name: 2021-03-17-newsletter-zh
slug: 2021-03-17-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了关于挽救丢失的闪电网络资金交易的讨论，并包含我们的常设栏目：发布、候选发布的公告，以及对流行的比特币基础设施软件值得注意的更改。

## 新闻

- **<!--rescuing-lost-ln-funding-transactions-->****关于挽救丢失的闪电网络资金交易：**
  闪电网络资金交易在存在交易延展性的情况下并不安全。Segwit 消除了第三方篡改对于大多数交易的影响（此处“大多数”指所有使用 SIGHASH_ALL 签名的交易），<!-- by "most", I mean everything signed SIGHASH_ALL -->但并未解决交易创建者自行更改其 txid 的情况，例如通过使用 [通过手续费替换][topic rbf] (RBF（Replace-by-Fee）) 来提高资金交易的费用。如果发生 txid 变动，预先签署的退款交易将无效，用户无法取回资金。此外，远端节点可能不会自动看到该资金交易，因此无法协助出资方追回资金。

  本周，Rusty Russell 在 Lightning-Dev 邮件列表中 [发布了][russell funding rescue] 一项快速且实验性的功能，他在 C-Lightning 中实现了该功能以帮助某位用户挽回资金。他还描述了其他针对相关问题的可选解决方案，以及[提议的][bolts #851]双向资助通道协议对这一问题的影响。Christian Decker 也 [发布了][decker funding rescue] 一项 [提议的变更][bolts #854] 至闪电网络规范，以协助资金恢复工作。随着闪电网络软件开始支持由外部钱包提供通道资金（例如 [Newsletter #51][news51 cl2672] 中的 C-Lightning 和 [Newsletter #92][news92 lnd4079] 中的 LND），开发者或许需要更加关注此类失败场景。

## 发布与候选发布

*新版本和候选发布已面世于各类流行的比特币基础设施项目。请考虑升级到新版本或协助测试候选发布。*

- [HWI 2.0.0][hwi 2.0.0] 是 HWI 的下一个主要版本发布。其中包括对 BitBox02 上多重签名的支持、更完善的文档，以及通过 Trezor 支付 OP_RETURN 输出的支持。

- [Rust-Lightning 0.0.13][] 是该闪电网络库的最新发布版，包含旨在与多路径支付（multipath payments）以及未来脚本升级（如 Taproot）保持前向兼容的改进。

- [BTCPay Server 1.0.7.0][] 是这款自托管支付处理软件的最新版本。值得注意的改进包括更完善且更具视觉吸引力的钱包设置向导、对由 Specter 创建的钱包进行导入的能力，以及为 bech32 地址生成更高效的二维码。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的更改。*

- [Bitcoin Core #21007][] 增加了一个新的 -daemonwait 配置选项。自早期版本以来，就可以通过使用 -daemon 选项让 Bitcoin Core 以后台守护进程方式运行。但 -daemon 选项会使程序立即在后台启动守护进程。新的 -daemonwait 选项则类似，只是在初始化完成后才将进程转入后台。这使用户或父进程能够更轻松地通过程序的输出或退出码来判断后台进程是否成功启动。

- [C-Lightning #4404][] 允许 keysend RPC（参见 [Newsletter #107][news107 keysend]）向未明确表明支持该功能的节点发送消息。正如 [讨论][fromknecht keysend] 所示，该信号从未标准化，而 LND 的实现并不依赖信号，因此这一更改应使 C-Lightning 能够与 LND 差不多同样范围的节点进行通信。

- [C-Lightning #4410][] 将针对双向资助通道的实验性实现与最新的[草案规范变更][bolts #851]保持一致。最值得注意的是，暂时移除了离散对数等价证明（PODLE）的使用（有关 PODLE 的最初讨论请参见 [Newsletter #83][news83 podle]，备选方案讨论请参见 [Newsletter #131][news131 podle]）。在此合并后，一个[新的拉取请求][c-lightning #4427]被提出，使得实验双向资助无需特殊编译标志即可进行（尽管仍需特定的配置选项）。

- [LND #5083][] 允许从文件中读取 PSBT（部分签名的比特币交易），而不是从标准输入读取。一些终端对一次性粘贴到 stdin 的字符数有限制（约为 4096 个 base64 字符，对应约 3,072 字节的二进制数据），从而使超过此长度的 PSBT 无法使用。尤其是在当前数款硬件钱包要求 PSBT 中包含用于 segwit 花费的前置交易（参见 [Newsletter #101][news101 segwit overpayment]）的背景下，创建超过 3 KiB 的 PSBT 已十分常见。

- [LND #5033][] 增加了一个 updatechanstatus RPC，可用于声明通道已被禁用（类似于节点下线）或已重新启用（类似节点重新上线）。

- [Rust-Lightning #826][] 将单方面关闭通道节点所支付输出的 `OP_CHECKSEQUENCEVERIFY` 延迟最大值提高到了 2016 个区块。此举解决了在与 LND 建立通道时的互操作性问题，因为 LND 可能要求的延迟上限为 2016 个区块，而之前 Rust-Lightning 的最大值为 1008 个区块。

- [HWI #488][] 在搭配 `--desc` 选项使用 `displayaddress` 命令时，对处理多重签名地址的方式进行了重大变更。在此之前，HWI 会根据所使用的设备自动决定是否应用 [BIP67][] 字典序密钥排序（例如，对 Coldcard 设备应用 BIP67，对 Trezor 设备则不应用）。这种实现方式在用户显式指定实现 BIP67 排序功能的 `sortedmulti` 描述符选项时会引发问题。更改后，使用者需要为需要字典序密钥排序的设备显式使用 `sortedmulti`，而对不需要排序的设备使用 `multi`。

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
