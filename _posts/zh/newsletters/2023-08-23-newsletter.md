---
title: 'Bitcoin Optech Newsletter #265'
permalink: /zh/newsletters/2023/08/23/
name: 2023-08-23-newsletter-zh
slug: 2023-08-23-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了过期备份状态的欺诈证明，并包括我们的常规部分：总结了服务和客户端软件的最新变化，发布了新版本和候选版本，并描述了热门比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--fraud-proofs-for-outdated-backup-state-->过期备份状态的欺诈证明：** Thomas Voegtlin 在 Lightning-Dev 邮件列表中[发布了][voegtlin backups]一个想法，是一种可能因向用户提供除最新版本外的任何备份状态版本而受到惩罚的服务。基本机制很简单：

    - Alice 有一些数据想备份。她将版本号包含在数据中，并为数据创建签名，再把数据和她的签名交给 Bob。

    - 在收到 Alice 的数据之后，Bob 立即向她发送一个签名，并对她的数据版本号和当前时间做出承诺。

    - 后来，Alice 更新了数据，增加了版本号，并向 Bob 提供了更新后的数据和她对其的签名。Bob 返回一个对新的(较高的)版本号与新的(较高的)当前时间的承诺签名。他们多次重复这一步骤。

    - 最后，Alice 请求她的数据以测试 Bob。Bob 发给她一个数据版本和她对数据的签名，允许她证明这确实是她的数据。他还发送给她另一个签名，承诺数据中的版本号和当前时间。

    - 如果 Bob 不诚实，发送了旧的数据和旧的版本号，Alice 可以生成一个_欺诈证明_：她可以表明 Bob 曾签过一个更高的版本号，时间比他刚给她的签名承诺还要早。

  按照目前的描述，这个生成最新状态欺诈证明的机制本身与比特币没有具体关联。然而，Voegtlin 指出，如果在比特币中以软分叉的方式添加 [OP_CHECKSIGFROMSTACK (CSFS) 和 OP_CAT][topic op_checksigfromstack] 操作码，就有可能在链上使用这种欺诈证明。

  例如，Alice 和 Bob 共享一个闪电网络通道，该通道包括一个额外的 [taproot][topic taproot] 条件，如果 Alice 能提供这种欺诈证明，则允许她花费通道中的所有资金。通道的常规操作只需增加一步：在每次更新通道状态后，Alice 给 Bob 一个当前状态(包括状态号)的签名。然后，每次 Alice 有机会重新连接 Bob 时，她都会请求最新的备份并使用上述机制来验证其完整性。如果 Bob 曾经提供过过期的备份，Alice 就可以使用欺诈证明和 CSFS 花费条件花光通道余额。

  这种机制使 Alice 在实际丢失数据的情况下使用 Bob 提供的状态作为通道的最新状态更安全。在当前的闪电网络通道设计(LN-Penalty)中，如果 Bob 欺骗 Alice 使用旧状态，Bob 将能够偷取她在该通道中的全部余额。即使实现了 [LN-Symmetry][topic eltoo] 这样的提议升级，Alice 使用旧状态的话， Bob 仍然能从她那里窃取资金。能在 Bob 篡改最新状态时对其进行经济惩罚，可能会减少他说谎的可能性。

  该提案引发了大量讨论：


  <!-- I've previously confirmed that "ghost43" (all lowercase) is how
  they'd like to be attributed -->

  - *<!--noted-->* Peter Todd [指出][todd backups1]，该基本机制具有普适性。它不特定于闪电网络，可能在各种协议中都很有用。他[还指出][todd backups2]，对 Alice 来说更简单的机制是每次她有机会重新连接 Bob 时，只需从 Bob 那里下载最新状态，而不需要任何欺诈证明。如果他向她提供旧状态，她就关闭通道，拒绝他从她未来的支付中获得任何转发费。这听起来很类似于 [BOLTs #881][] 中描述的[对等存储][topic peer storage]版本，Core Lightning 今年早些时候(见[周报 #238][news238 peer storage])实验性实现的版本，以及(根据 Bastien Teinturier 的[消息][teinturier backups])，Phoenix 钱包为闪电网络实现的该方案版本。

  - *<!--reply-->* ghost43 的[回复][ghost43 backups]解释说，导致经济处罚的欺诈证明对于将数据存储在匿名对等节点上的客户来说是一个强大的工具。大型的流行服务机构可能会很在乎其声誉，避免对其客户撒谎，但匿名对等节点没有任何声誉可失。ghost43 还建议修改该协议，使其对称化，因此除了 Alice 将她的状态存储在 Bob 处(Bob 因撒谎而受到惩罚)之外，Bob 还可以将他的状态存储在 Alice 那里，如果她撒谎也会受到惩罚。

      Voegtlin 进一步提出[警告][voegtlin backups2]，认为钱包软件提供商需要高度声誉，当用户损失资金时，即使软件功能已尽可能完善，他们的声誉也会受损。作为钱包软件的开发者，尽可能减少匿名对等节点能够从使用类似对等备份机制的 Electrum 用户身上偷钱的风险对他来说非常重要。

  讨论没有明确的结果。

## 服务和客户端软件变更

*在这个月度栏目中，我们会重点介绍比特币钱包和服务的有趣更新。*

- **Scaling Lightning 请求反馈：**
  [Scaling Lightning][] 是一个在 regtest 和 signet 上对闪电网络进行测试的工具包。该项目旨在提供工具，以在各种配置和场景中测试不同的闪电网络实现。该项目最近为社区提供了一个[视频更新][sl twitter update]。鼓励闪电网络开发人员、研究人员和基础设施运营商[提供反馈][sl tg]。

- **Torq v1.0 发布：**
  面向企业用户的 LN 节点管理软件 [Torq][torq github] [宣布][torq blog]发布 v1.0 版本，包括闪电服务提供商(LSP)功能、自动化工作流程和大型节点运营商的高级功能。

- **Blixt Wallet v0.6.8 发布：**
  [v0.6.8 版本][blixt v0.6.8]支持[保留发票][topic hold invoices]和[零确认通道][topic zero-conf channels]等其他改进。

- **Sparrow 1.7.8 发布:**
  Sparrow [1.7.8][sparrow 1.7.8] 增加了对 [BIP322][] [消息签名][topic generic signmessage]的支持，包括 P2TR 地址，并对 [RBF][topic rbf] 和 [CPFP][topic cpfp] 手续费加速功能进行了各种改进。

- **开源 ASIC 矿机 bitaxeUltra 原型：**
  [bitaxeUltra][github bitaxeUltra] 是一种使用基于现有商业挖矿硬件的专用集成电路(ASIC)的开源矿机。

- **支持 FROST 的软件 Frostsnap 发布：**
  团队[宣布了][frostsnap blog]在使用实验性 FROST 实现——[secp256kfun][secp256kfun github]的基础上[构建][frostsnap github] FROST [门限签名][topic threshold signature]方案的愿景。

- **发布 Libfloresta 库：**
  在之前基于 [utreexo][topic utreexo] 的 [Floresta][news247 floresta] 节点工作的基础上，[Libfloresta][libfloresta blog] 是一个Rust库，用于向应用程序添加基于 utreexo 的比特币节点功能。

- **Wasabi Wallet 2.0.4 发布：**
  Wasabi [2.0.4][wasabi 2.0.4] 增加了使用 [RBF][topic rbf] 和 [CPFP][topic cpfp] 手续费加速的功能，[coinjoin][topic coinjoin]改进，更快的钱包加载，RPC 增强和其他改进与错误修复。

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [Core Lightning 23.08rc3][] 是此热门 LN 节点实现的下一个主要版本的候选版本。

- [HWI 2.3.1][] 是此用于处理硬件签名设备的工具包的次要版本。


## 重大的代码和文档变更

*本周的重大变更有：[Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、
[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet
Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay
Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement
Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和
[Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Bitcoin Core #27981][] 修复了一个错误，该错误可能导致两个节点无法相互接收数据。如果 Alice 的节点有大量数据排队发送到 Bob 的节点，她会先尝试发送那些数据，而不接受来自 Bob 的数据。如果 Bob 也有大量数据排队发送到 Alice 的节点，他也不会接受来自 Alice 的数据。这可能导致双方都无法从对方那里无限期地接收数据。这个问题最初是在[Elements 项目][elements project]中发现的。

- [BOLTs #919][] 更新了 LN 规范，建议节点停止接受超过某个值的额外修剪 HTLC。修剪 HTLC 是可以转发的支付，不会作为输出添加到通道承诺交易中。相反，等同于修剪 HTLC 价值的金额会分配给交易费用。这使得使用 LN 转发在链上[不经济][topic uneconomical outputs]的支付成为可能。但是，如果通道在修剪 HTLC 待处理时需要关闭，节点无从找回那些资金，所以限制节点遭受那种损失的风险是有意义的。另见我们对各种实现添加此限制的描述：LDK 见[周报 #162][news162 trim]，Eclair 见[周报 #171][news171 trim]，Core Lightning 见[周报 #173][news173 trim]和[周报 #170][news170 trim]的一个相关安全问题。

- [Rust Bitcoin #1990][] 可选择地允许 `bitcoin_hashes` 使用速度较慢但大小仅为原来一半的 SHA256、SHA512 和 RIPEMD160 实现进行编译，这可能使它们更适合不需要频繁哈希的嵌入式设备上的应用程序。

- [Rust Bitcoin #1962][] 添加了在兼容的 x86 架构上使用硬件优化的 SHA256 操作的功能。

- [BIPs #1485][] 对 [BIP300][] 规范的 [drivechains][topic sidechains] 进行了几项更新。主要变化看起来是在某些上下文中将 `OP_NOP5` 重新定义为 `OP_DRIVECHAIN`。

{% include references.md %}
{% include linkers/issues.md v=2 issues="27460,27981,919,1990,1962,1485,881" %}
[core lightning 23.08rc3]: https://github.com/ElementsProject/lightning/releases/tag/v23.08rc3
[news238 peer storage]: /zh/newsletters/2023/02/15/#core-lightning-5361
[news162 trim]: /en/newsletters/2021/08/18/#rust-lightning-1009
[news171 trim]: /en/newsletters/2021/10/20/#eclair-1985
[news173 trim]: /en/newsletters/2021/11/03/#c-lightning-4837
[news170 trim]: /en/newsletters/2021/10/13/#ln-spend-to-fees-cve
[elements project]: https://elementsproject.org/
[voegtlin backups]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004043.html
[todd backups1]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004046.html
[todd backups2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004044.html
[teinturier backups]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004045.html
[ghost43 backups]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004052.html
[voegtlin backups2]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004055.html
[hwi 2.3.1]: https://github.com/bitcoin-core/HWI/releases/tag/2.3.1
[Scaling Lightning]: https://github.com/scaling-lightning/scaling-lightning
[sl twitter update]: https://twitter.com/max_blue__/status/1681781001373065216
[sl tg]: https://t.me/+AytRsS0QKH5mMzM8
[torq github]: https://github.com/lncapital/torq
[torq blog]: https://ln.capital/articles/announcing-torq-V1.0
[blixt v0.6.8]: https://github.com/hsjoberg/blixt-wallet/releases
[sparrow 1.7.8]: https://github.com/sparrowwallet/sparrow/releases/tag/1.7.8
[github bitaxeUltra]: https://github.com/skot/bitaxe/tree/ultra
[frostsnap blog]: https://frostsnap.com/introducing-frostsnap.html
[frostsnap github]: https://github.com/frostsnap/frostsnap
[secp256kfun github]: https://github.com/LLFourn/secp256kfun
[news247 floresta]: /zh/newsletters/2023/04/19/#utreexo-electrum-server
[libfloresta blog]: https://blog.dlsouza.lol/2023/07/07/libfloresta.html
[wasabi 2.0.4]: https://github.com/zkSNACKs/WalletWasabi/releases/tag/v2.0.4
