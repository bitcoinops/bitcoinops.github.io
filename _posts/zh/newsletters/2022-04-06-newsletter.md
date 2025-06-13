---
title: 'Bitcoin Optech Newsletter #194'
permalink: /zh/newsletters/2022/04/06/
name: 2022-04-06-newsletter-zh
slug: 2022-04-06-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了解除关联的可重用地址的提案，总结了 WabiSabi 协议如何作为增强版 payjoin 的替代方案，审视了在 DLC 规范中添加通信标准的讨论，并关注了关于更新 LN 承诺格式的再度讨论。文末附有常规板块，概述了新软件发布与候选版本，并描述了流行的比特币基础设施软件的值得注意的更改。

## 新闻

- **<!--delinked-reusable-addresses-->****可解除关联的可重用地址：**
  Ruben Somsen 向 Bitcoin-Dev 邮件列表提交了一份[提案][somsen silpay]，允许向一个公共标识符（“地址”）付款而无需在链上直接使用该标识符。例如，Alice 生成一个由公钥构成的标识符并张贴在她的网站上。Bob 能够使用自己的某个私钥将 Alice 的公钥转换成一个新的比特币地址，并以此地址向 Alice 付款。只有 Alice 和 Bob 掌握足够的信息来确认该地址是支付给 Alice 的——且只有 Alice 拥有花费该地址上资金所必需的私钥。如果 Carol 之后访问 Alice 的网站并复用 Alice 的公共标识符，她将派生出一个不同的地址来支付 Alice，而 Bob 以及任何其他第三方都无法直接判断该地址属于 Alice。

  之前的解除关联可重用地址方案（例如 [BIP47][BIP47] 可重用支付码以及尚未发表的 BIP63 隐匿地址）依赖于支付方与接收方在区块链之外进行通信，或依赖包含额外数据、成本高于常规支付的链上交易。相比之下，Somsen 的 *silent payments* 提案在链上并不需要比普通交易更多的开销。

  Silent payments 的最大缺点是接收方需要在每个新出块时扫描每一笔交易，以检测是否收到付款。全节点本就会扫描区块中的交易，但该方案还要求节点维护大量交易的父交易信息——这并不是多数全节点目前的默认行为，且可能需要显著额外的 I/O 操作及 CPU 开销。从备份恢复钱包也可能变得繁重。虽然 Somsen 描述了一些可降低负担的折衷方案，但该方案似乎并不适用于想要接收付款的大多数轻量钱包。不过，几乎所有钱包都能仅用少量代码就添加发送 silent payment 的支持，而不会带来明显的资源需求增长。这意味着方案的成本主要由最需要其增强隐私性的用户来承担，尤其是那些无法或不愿通过其他手段避免[地址重用][topic output linking]的用户。

  Somsen 目前寻求对该提案的反馈，包括其密码学安全性的分析，以及在不显著削弱隐私优势的前提下，降低接收方资源消耗的任何建议。

- **<!--wabisabi-alternative-to-payjoin-->****WabiSabi 作为 payjoin 的替代方案：**
  数周前，Wasabi 钱包及其 [coinjoin][topic coinjoin] 实现的开发者在 Bitcoin-Dev 邮件列表上[宣布][wasabi2]了新版本，并支持在 [Newsletter #102][news102 wabisabi] 中描述的 WabiSabi 协议。先前使用的 Chaumian coinjoin 协议允许输入金额任意，但输出金额固定；改进后的 WabiSabi 协议则允许输入与输出金额均为任意值（仍需满足最大交易尺寸、遵守[粉尘限制][topic uneconomical outputs]等约束）。

  本周，Max Hillebrand [发布][hillebrand wormhole]了如何将 WabiSabi 协议用作 [payjoin][topic payjoin] 替代方案的说明。在标准 payjoin 中，付款方与收款方都会向同一笔交易贡献输入并各自接收输出。虽然双方都会得知对方的输入与输出，但链上的所有权信息被打乱，从而为参与 payjoin 的用户及其他多输入交易带来混淆。Hillebrand 提出的 wormhole 2.0 协议将利用 WabiSabi 确保付款方与收款方互不知晓对方的输入或输出（前提是同一次 WabiSabi coinjoin 中还有其他尊重保密性的参与者）。这将提供更高的隐私性，但需要使用实现 WabiSabi 的软件并等待协调完成一次 WabiSabi coinjoin 交易。

- **<!--dlc-messaging-and-networking-->****DLC 消息与网络通信：**
  Thibaut Le Guilly 在 DLC-Dev 邮件列表上[发帖][leguilly dlcmsg]，讨论改进不同 DLC 实现之间通信的方法。目前，各实现使用多种不同方式来寻找并与其他 DLC 节点通信，这些差异导致使用不同实现的节点无法互操作。Le Guilly 指出，制定 DLC 标准的目的正是为了实现互操作，因此他建议将相关细节加入标准。

  讨论涉及多个具体细节。Le Guilly 希望在可能的情况下复用 LN 规范（闪电网络规范（BOLTs））中的元素。这引出了近期一项关于升级 LN 通道公告的提案（见 [Newsletter #193][news193 major update]），该提案允许使用任意 UTXO 进行抗洪泛滥 DoS 保护（而不仅限于看起来像 LN 建立交易的 UTXO），从而使 DLC 及其他二层协议也能使用同样的 Anti-DoS 机制。

- **<!--updating-ln-commitments-->****更新 LN 承诺：**
  Olaoluwa Osuntokun 本周在 Lightning-Dev 邮件列表[发帖][osuntokun dyncom]，作为他先前关于[升级通道承诺格式][topic channel commitment upgrades]（或升级影响承诺交易的任何设置）提案的跟进，相关摘要见 [Newsletter #108][news108 upcom]。目标是在为通道添加诸如[使用 taproot 功能][zmn post]等新特性时，仍能保持通道开放。

  Osuntokun 的提案与 [BOLTs #868][] 中描述的替代方案形成对比，后者已在 C-Lightning 中进行实验性实现，并在 [Newsletter #152][news152 cl4532] 中提及。一个值得注意的差异是，Osuntokun 的方案在仍可能提出新支付（[HTLCs][topic htlc]）的同时升级通道，而 BOLTs #868 提案则规定了在升级期间必须保持安静期。

## 发布与候选发布

*新版本与候选版本的比特币基础设施项目。请考虑升级到新版本，或帮助测试候选版本。*

- [Bitcoin Core 23.0 RC2][] 是该主流全节点软件下一主要版本的候选发布。[草稿发布说明][bcc23 rn]列出了多项改进，鼓励高级用户与系统管理员在正式发布前先行[测试][test guide]。

- [LND 0.14.3-beta.rc1][] 是这一流行 LN 节点软件的候选版本，包含若干漏洞修复。

- [C-Lightning 0.11.0rc1][] 是这一流行 LN 节点软件下一主要版本的候选发布。

## 值得注意的代码与文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #24118][] 新增 RPC `sendall`，可将钱包中的余额全部发送给单一收款地址。该调用可通过选项指定额外收款人、限定钱包 UTXO 集的子集作为输入，或在跳过粉尘输出而非留零碎 UTXO 的情况下最大化收款金额。因此，`sendall` 为实现其他 `send*` RPC 中 `fSubtractFeeAmount` 参数的部分应用场景提供了便捷替代，但当收款方需承担手续费时，`fSubtractFeeAmount` 仍是最佳选择。

- [Bitcoin Core #23536][] 设定验证规则，只要启用 segwit，就始终强制执行 [taproot][topic taproot]（包括对历史区块的验证，除去区块 692261，其中包含在 taproot 激活前花费 v1 见证输出的交易）。这一*埋入式部署*已在 P2SH 与 segwit 软分叉中采用（参见 [Newsletter #60][news60 buried]）；它简化了测试与代码审查，降低了部署代码中潜在漏洞的风险，并为极端场景（节点下载到 taproot 未激活的另类最高工作量链）提供双保险。

- [Bitcoin Core #24555][] 与 [Bitcoin Core #24710][] 添加了关于在 CJDNS 网络上运行 Bitcoin Core 的[文档][cjdns.md]（见 [Newsletter #175][news175 cjdns]）。

- [C-Lightning #5013][] 增加了通过 gRPC 且使用 mTLS 认证来管理节点的功能。

- [C-Lightning #5121][] 为 `invoice` RPC 新增 `deschash` 参数，可在 [BOLT11][] 发票中包含任意数据的哈希，而非简短描述字符串。这可通过 [LNURL][] 等方案在 BOLT11 受限之外的信道中传递大型描述（例如图片）。

- [Eclair #2196][] 新增 `channelbalances` API，用于列出节点所有通道的余额，包括已被禁用的通道。

- [LND #6263][] 为 LND 钱包添加了 [taproot][topic taproot] 密钥路径支出支持，可在默认 [signet][topic signet] 上进行测试。

- [Libsecp256k1 #1089][] 将 `secp256k1_schnorrsig_sign()` 函数重命名为 `..._sign32()`，以更清晰地表明该函数用于签名 32 字节消息（例如 SHA256 摘要）。这与可签名任意长度消息的 `secp256k1_schnorrsig_sign_custom()` 形成对比，更多讨论见 [Newsletter #157][news157 schnorrsig]。

- [Rust Bitcoin #909][] 通过传入特定脚本路径被使用的概率，使用 [huffman coding][] 来创建最优 taproot 脚本路径树。

- [LDK #1388][] 默认支持通过寻找可更紧凑编码的值来创建平均更小的 ECDSA 签名，这一流程此前已在 Bitcoin Core 与 C-Lightning 钱包中实现（见 [Newsletters #8][news8 lowr] 与 [#71][news71 lowr]）。这种[低 R 值磨碎][topic low-r grinding] 在链上交易中可为每个 LDK 对等方节省约 0.125 vbyte。


{% include references.md %}
{% include linkers/issues.md v=1 issues="868,24118,23536,24555,5013,5121,2196,6263,1089,909,1388,24710" %}
[bitcoin core 23.0 rc2]: https://bitcoincore.org/bin/bitcoin-core-23.0/
[bcc23 rn]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Notes-draft
[test guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Candidate-Testing-Guide
[lnd 0.14.3-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.3-beta.rc1
[C-Lightning 0.11.0rc1]: https://github.com/ElementsProject/lightning/releases/tag/v0.11.0rc1
[news157 schnorrsig]: /zh/newsletters/2021/07/14/#libsecp256k1-844
[news8 lowr]: /zh/newsletters/2018/08/14/#bitcoin-core-wallet-to-begin-only-creating-low-r-signatures
[news71 lowr]: /zh/newsletters/2019/11/06/#c-lightning-3220
[news108 upcom]: /zh/newsletters/2020/07/29/#upgrading-channel-commitment-formats
[news152 cl4532]: /zh/newsletters/2021/06/09/#c-lightning-4532
[zmn post]: /zh/newsletters/2021/09/01/##准备-taproot-11使用-taproot-的闪电网络
[osuntokun dyncom]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-March/003531.html
[somsen silpay]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020180.html
[wasabi2]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020032.html
[news102 wabisabi]: /zh/newsletters/2020/06/17/#wabisabi-coordinated-coinjoins-with-arbitrary-output-values
[hillebrand wormhole]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-March/020186.html
[leguilly dlcmsg]: https://mailmanlists.org/pipermail/dlc-dev/2022-March/000135.html
[news193 major update]: /zh/newsletters/2022/03/30/#major-update
[lnurl]: https://github.com/fiatjaf/lnurl-rfc
[huffman coding]: https://en.wikipedia.org/wiki/Huffman_coding
[news60 buried]: /zh/newsletters/2019/08/21/#hardcoded-previous-soft-fork-activation-blocks
[news175 cjdns]: /zh/newsletters/2021/11/17/#bitcoin-core-23077
[cjdns.md]: https://github.com/bitcoin/bitcoin/blob/6a02355ae9/doc/cjdns.md
