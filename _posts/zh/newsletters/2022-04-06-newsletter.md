---
title: 'Bitcoin Optech Newsletter #194'
permalink: /zh/newsletters/2022/04/06/
name: 2022-04-06-newsletter-zh
slug: 2022-04-06-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了关于解除关联的可复用地址的一项提案，总结了如何把 WabiSabi 协议用作 payjoin 的增强型替代方案，审视了在 DLC 规范中添加通信标准的讨论，并关注了关于更新 LN 承诺格式的再度讨论。文末附有常规栏目，概述新软件发布与候选版本，并描述热门比特币基础设施软件中值得注意的变更。

## 新闻

- **<!--delinked-reusable-addresses-->****解除关联的可复用地址：**
  Ruben Somsen 向 Bitcoin-Dev 邮件列表提交了一份[提案][somsen silpay]，允许向一个公共标识符（“地址”）付款而无需在链上使用该标识符。例如，Alice 生成一个由公钥构成的标识符并张贴在她的网站上。Bob 能够使用自己的某个私钥将 Alice 的公钥转换成一个新的比特币地址，并以此地址向 Alice 付款。只有 Alice 和 Bob 掌握着确认该地址是在支付给 Alice 所必需的信息——且只有 Alice 掌握着花费该地址所收资金所必需的信息（即她的私钥）。如果 Carol 之后访问 Alice 的网站并复用 Alice 的公共标识符，她将派生出一个不同的地址来支付 Alice，而 Bob 以及任何其他第三方都无法直接判断该地址属于 Alice。

  以往那些解除关联的可复用地址方案（例如 [BIP47][BIP47] 可复用支付码以及尚未发表的 BIP63 隐匿地址）要么依赖付款方与收款方在区块链之外进行通信，要么依赖包含额外数据、成本高于常规支付的链上交易。相比之下，Somsen 的*静默支付（silent payments）*提案与普通交易相比没有任何额外开销。

  静默支付最大的缺点是，要检查是否收到新交易，就必须扫描每个新区块中的每一笔交易。全节点本来就在做这件事，但该方案还要求维护大量交易的父交易信息——而今天许多全节点并不这样做，并且除了额外的 CPU，还可能带来相当多的额外 I/O 操作。从备份恢复钱包也可能很麻烦。虽然 Somsen 确实描述了一些可以减轻负担的取舍方案，但该方案对大多数想要接收付款的轻钱包来说似乎不太可能有用。不过，几乎所有钱包都应当能仅用几行代码就添加发送静默支付的支持，而且资源需求不会明显上升。这可能让该方案的成本主要由那些最看重其隐私增强效果的用户承担——对那些无法或不愿使用其他机制来防止[地址重用][topic output linking]的用户来说，这种隐私尤其可贵。

  Somsen 正在征求对该提案的反馈，包括对其密码学用法的安全性分析，以及任何能让接收方资源消耗更低的建议（前提是不显著削弱其隐私优势）。

- **<!--wabisabi-alternative-to-payjoin-->****WabiSabi 作为 payjoin 的替代方案：**
  数周前，Wasabi 钱包（同时也是一套 [coinjoin][topic coinjoin] 实现）的开发者们在 Bitcoin-Dev 邮件列表上[宣布][wasabi2]了新版本，支持在 [Newsletter #102][news102 wabisabi] 中描述的 WabiSabi 协议。此前使用的 Chaumian coinjoin 协议允许输入金额任意，但输出金额只能是固定大小；改进后的 WabiSabi 协议则允许输入与输出金额均为任意值（仍需满足其他约束，例如限制最大交易大小、遵守[粉尘限制][topic uneconomical outputs]）。

  本周，Max Hillebrand [发布][hillebrand wormhole]了如何将 WabiSabi 协议用作 [payjoin][topic payjoin] 替代方案的说明。在标准 payjoin 中，付款方与收款方都会向同一笔交易贡献输入，也都会收到输出。虽然双方都会得知对方的输入与输出，但对旁观者而言，链上的所有权信息变得难以分辨——无论是对于参与 payjoin 的用户，还是对于其他多输入交易都是如此。Hillebrand 提出的 wormhole 2.0 协议将利用 WabiSabi 确保一笔支付的付款方与收款方互不知晓对方的输入或输出（前提是同一次 WabiSabi coinjoin 中还有其他尊重保密性的参与者）。这将提供更高的隐私性，但需要使用实现了 WabiSabi 的软件，并等待一次协调好的 WabiSabi coinjoin 交易发生。

- **<!--dlc-messaging-and-networking-->****DLC 消息与网络通信：**
  Thibaut Le Guilly 在 DLC-Dev 邮件列表上[发帖][leguilly dlcmsg]，讨论改进不同 DLC 实现之间通信的方法。目前，各实现使用多种不同方式来寻找并与其他 DLC 节点通信，这些差异导致使用不同实现的节点无法互操作。Le Guilly 指出，制定 DLC 标准的目的正是为了实现互操作，因此他建议将相关细节加入标准。

  讨论涉及多个具体细节。Le Guilly 希望在可能的情况下复用 LN 规范（BOLTs）中的元素。这引出了近期一项关于升级 LN 通道公告的提案（见 [Newsletter #193][news193 major update]）——该提案允许使用任意 UTXO 来做防泛洪的 DoS 保护（而不仅限于看起来像 LN 建立交易的 UTXO），从而使 DLC 及其他二层协议也能使用同样的防 DoS 保护。

- **<!--updating-ln-commitments-->****更新 LN 承诺格式：**
  Olaoluwa Osuntokun 本周在 Lightning-Dev 邮件列表[发帖][osuntokun dyncom]，跟进他先前提出的[升级通道承诺格式][topic channel commitment upgrades]的提案——该提案也涵盖升级其他任何会影响承诺交易的设置。他先前提案的摘要见 [Newsletter #108][news108 upcom]。该提案的目标是，即使在为通道添加新特性（例如[使用 taproot 功能][zmn post]）时，也能让通道保持开放。

  Osuntokun 的提案与 [BOLTs #868][] 中描述的另一种提案形成对比，后者已在 C-Lightning 中做过实验性实现，并在 [Newsletter #152][news152 cl4532] 中提及。两个提案之间一个值得注意的差异是：Osuntokun 的方案即使在仍可能有新支付（[HTLC][topic htlc]）被提出时也能升级通道，而 BOLTs #868 提案则规定了一个可以执行升级的安静期（quiet period）。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Bitcoin Core 23.0 RC2][] 是该主流全节点软件下一主要版本的候选发布。[发布说明草案][bcc23 rn]列出了多项改进，鼓励高级用户与系统管理员在正式发布前先行[测试][test guide]。

- [LND 0.14.3-beta.rc1][] 是这一流行 LN 节点软件的候选版本，包含若干缺陷修复。

- [C-Lightning 0.11.0rc1][] 是这一流行 LN 节点软件下一主要版本的候选发布。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中值得注意的变更。*

- [Bitcoin Core #24118][] 新增 RPC `sendall`，可将钱包中的资金全部发给单一收款地址。该调用的选项可用于指定额外收款人、指定钱包 UTXO 池中要作为输入的一部分，或跳过粉尘输出（而不是留下零碎 UTXO）以最大化收款金额。因此，对于其他 `send*` RPC 的 `fSubtractFeeAmount` 参数所能实现的部分用途，`sendall` 提供了便捷的替代方案；但当收款方需自行承担交易手续费时，`fSubtractFeeAmount` 仍是最佳选择。

- [Bitcoin Core #23536][] 设定验证规则：只要强制执行 segwit，就始终强制执行 [taproot][topic taproot]，包括对历史区块的验证（区块 692261 除外，其中包含一笔在 taproot 激活前花费 v1 见证输出的交易）。这一*埋入式部署*（buried deployment）在 P2SH 与 segwit 软分叉中也曾采用（参见 [Newsletter #60][news60 buried]）；它简化了测试与代码审查，缓解了部署代码中潜在缺陷的部分风险，并为极端场景（节点下载到 taproot 尚未激活的另一条最高工作量链）提供了双保险。

- [Bitcoin Core #24555][] 与 [Bitcoin Core #24710][] 添加了关于在 CJDNS 网络上运行 Bitcoin Core 的[文档][cjdns.md]（见 [Newsletter #175][news175 cjdns]）。

- [C-Lightning #5013][] 增加了通过 gRPC 且使用 mTLS 认证来管理节点的功能。

- [C-Lightning #5121][] 为 `invoice` RPC 新增 `deschash` 参数，可在 [BOLT11][] 发票中包含任意数据的哈希，而不是一个简短的描述字符串。使用该参数后，[LNURL][] 等方案可以通过另一条通信通道发送大型描述（包括图片等数据），从而绕开 BOLT11 的限制。

- [Eclair #2196][] 新增 `channelbalances` API，用于列出节点所有通道的余额，包括已被禁用的通道。

- [LND #6263][] 为 LND 钱包添加了 [taproot][topic taproot] 密钥路径花费支持，现在可以使用默认的 [signet][topic signet] 进行测试。

- [Libsecp256k1 #1089][] 将 `secp256k1_schnorrsig_sign()` 函数重命名为 `..._sign32()`，以更清晰地表明该函数用于签名 32 字节消息（例如 SHA256 摘要）。这与可签名任意长度消息的 `secp256k1_schnorrsig_sign_custom()` 形成对比，更多讨论见 [Newsletter #157][news157 schnorrsig]。

- [Rust Bitcoin #909][] 新增了构建最优 taproot 脚本路径树的支持：传入某个脚本路径会被使用的概率，即可用 [huffman coding][] 构建该树。

- [LDK #1388][] 默认支持通过寻找可更紧凑编码的值来创建比平均水平更小的 ECDSA 签名，这一流程此前已在 Bitcoin Core 与 C-Lightning 的钱包中实现（见 [Newsletters #8][news8 lowr] 与 [#71][news71 lowr]）。这种[低 R 值研磨][topic low-r grinding]在链上交易中可为每个 LDK 对等节点节省约 0.125 vbytes。


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
[zmn post]: /zh/newsletters/2021/09/01/#准备-taproot-11使用-taproot-的闪电网络
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
