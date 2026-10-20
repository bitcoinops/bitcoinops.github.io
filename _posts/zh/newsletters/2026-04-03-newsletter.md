---
title: 'Bitcoin Optech Newsletter #399'
permalink: /zh/newsletters/2026/04/03/
name: 2026-04-03-newsletter-zh
slug: 2026-04-03-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报描述了钱包指纹识别如何损害 payjoin 隐私，并总结了一项钱包备份元数据格式的提案。此外还包括我们的常规栏目：关于改变比特币共识规则的提案和讨论摘要、新版本和候选版本的公告，以及流行比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--wallet-fingerprinting-risks-for-payjoin-privacy-->****钱包指纹识别对 payjoin 隐私的风险：** Armin Sabouri 在 Delving Bitcoin 上[发帖][topic payjoin fingerprinting]讨论了 [payjoin][topic payjoin] 实现之间的差异如何使指纹识别 payjoin 交易成为可能，从而损害 payjoin 的隐私性。

  Sabouri 指出，payjoin 交易应看起来与标准的单方交易无法区分。然而，协作交易可能存在一些可识别的痕迹：

  * 交易内部

    * 在单笔交易中按所有者划分输入和输出。

    * 输入编码方式的差异。

    * 输入的字节长度差异。

  * 交易之间

    * 回溯：每个输入都是由先前的交易创建的，而先前的交易携带着自己的指纹。

    * 前瞻：每个输出可能在未来的交易中被花费，从而暴露指纹。

  然后，他审查了三个 payjoin 实现：Samourai、PDK demo 和 Cake Wallet（发送到 Bull Bitcoin Mobile）。在每个示例中，他都发现了一些差异，使得对这些实现进行指纹识别成为可能。这些差异包括但不限于：

  * 编码后的输入签名之间的差异。

  * 一个输入中包含了 SIGHASH_ALL 字节而另一个没有。

  * 输出金额的分配方式。

  Sabouri 总结说，虽然其中一些钱包指纹很容易消除，但另一些是特定钱包设计选择所固有的。钱包开发者在实现 payjoin 时应当注意这些潜在的隐私泄露。

- **<!--draft-bip-for-a-wallet-backup-metadata-format-->****钱包备份元数据格式的 BIP 草案：** Pythcoiner 在 Bitcoin-Dev 邮件列表上[发帖][wallet bip ml]介绍了一项关于钱包备份元数据通用结构的新提案。该 BIP 草案（见 [BIPs #2130][]）指定了一种标准方式来存储各类元数据，如账户描述符、密钥、[标签][topic wallet labels]、[PSBT][topic psbt] 等，使不同钱包实现之间具有兼容性，并简化钱包迁移和恢复流程。据 Pythcoiner 说，生态系统缺乏通用的规范，该提案旨在填补这一空白。

  从技术角度来看，拟议的格式是一个 UTF-8 编码的文本文件，包含一个有效的 JSON 对象来表示备份结构。该 BIP 列出了 JSON 对象中可以包含的所有不同字段，并指定每个字段都是可选的，且任何钱包实现都可以自由忽略其认为无用的元数据。

## 共识变更

_每月一次的栏目，总结关于改变比特币共识规则的提案和讨论。_

- **<!--compact-isogeny-pqc-can-replace-hd-wallets-key-tweaking-silent-payments-->****紧凑同源映射后量子密码学可以替代 HD 钱包、密钥调整和静默支付：** Conduition 在 Delving Bitcoin 上[撰文][c delving ibc hd]介绍了他对同源映射密码学（Isogeny-Based Cryptography，IBC）作为比特币[后量子][topic quantum resistance]密码系统的适用性研究。虽然椭圆曲线离散对数问题（ECDLP）在后量子世界中可能变得不安全，但椭圆曲线数学本身并没有根本性的缺陷。简而言之，同源映射（isogeny）是从一条椭圆曲线到另一条的映射。IBC 的密码学假设是：计算一条特定类型椭圆曲线到另一条之间的同源映射是困难的，而从基础曲线生成一个同源映射及其映射到的曲线则是容易的。因此，IBC 的私钥是同源映射，公钥是映射后的曲线。

  与 ECDLP 的私钥和公钥类似，可以从相同的盐值（例如一个 [BIP32 派生][topic bip32]步骤）独立计算出新的私钥和公钥，使得生成的私钥能够正确地为生成的公钥进行签名。Conduition 将此称为"重新随机化（rerandomization）"，它从根本上支撑了 [BIP32][]、[BIP341][] 和 [BIP352][]（可能还需要一些额外的密码学创新）。

  迄今为止，IBC 还没有像 [MuSig][topic musig] 和 [FROST][topic threshold signature] 那样的签名聚合协议，Conduition 呼吁比特币开发者和密码学家研究这方面的可能性。

  已知 IBC 密码系统中的密钥和签名大约是依赖 ECDLP 的密码系统中密钥大小的两倍，远小于基于哈希或基于格的密码系统。验证成本即使在桌面机器上也很高（每次验证约 1 毫秒），与基于哈希和基于格的密码系统处于同一量级。

- **<!--varops-budget-and-tapscript-leaf-0xc2-aka-script-restoration-are-bips-440-and-441-->****变长操作码预算和 tapscript 叶子 0xc2（又名 "Script Restoration"）已获编号为 BIP 440 和 441：** Rusty Russell 在 Bitcoin-Dev 邮件列表上[撰文][rr ml gsr bips]称，Great Script Restoration（或 Grand Script Renaissance）的前两个 BIP 已提交编号申请，随后分别获得了 BIP 440 和 441 编号。[BIP440][news374 varops] 通过构建一个对每个操作进行成本核算的系统，使得此前被禁用的 Script 操作码得以恢复，该系统确保最坏情况下的区块级脚本验证成本不会超过验证包含最坏情况数量签名操作的区块的成本。[BIP441][news374 c2] 描述了一个新的 [tapscript][topic tapscript] 版本的验证，该版本恢复了 Satoshi 在 2010 年禁用的操作码。

- **<!--shrimps-2-5-kb-post-quantum-signatures-across-multiple-stateful-devices-->****SHRIMPS：跨多个有状态设备的 2.5 KB 后量子签名：** Jonas Nick 在 Delving Bitcoin 上[撰文][jn delving shrimps]介绍了一种用于后量子比特币的新的半有状态、基于哈希的签名构造。SHRIMPS 利用了 [SPHINCS+][news383 sphincs] 签名大小随给定密钥在保持给定安全级别下所能产生的最大签名数量而变化这一特性。

  与 [SHRINCS][news391 shrincs] 设计类似，一个 SHRIMPS 密钥由两个密钥哈希组合而成。在此方案中，两个密钥都是无状态的 SPHINCS+ 密钥，但参数集不同。第一个密钥仅对少量签名是安全的，旨在用于该密钥所使用的每个签名设备的第一次（或最初几次）签名。第二个密钥对大量签名是安全的（在比特币场景中实际上是无限的），每个设备在经过一定数量（可能由用户选择）的签名后会回退到该密钥。结果是，在常见的比特币使用场景中——任何给定密钥（从单个种子可以派生出许多密钥）只签名少数几次——几乎所有签名都可以小于 2.5 KB，同时如果密钥被大量重复使用，对签名总数也没有实际限制，代价是后续的签名会增大到约 7.5 KB。SHRIMPS 是半有状态的，因为不需要维护全局状态，但每个签名设备必须为其签名的每个 SHRIMPS 密钥记录少量状态（如果每个设备-密钥组合只利用小签名进行第一次签名，则最少只需一个比特）。

## 版本发布和候选版本

_热门比特币基础设施项目的新版本发布和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [Bitcoin Core 31.0rc2][] 是主流全节点实现下一个主要版本的候选发布。[测试指南][bcc31 testing]已提供。

- [Core Lightning 26.04rc2][] 是这个流行闪电网络节点下一个主要版本的最新候选发布，延续了早期候选版本中的拼接更新和 bug 修复。

- [BTCPay Server 2.3.7][] 是这一自托管支付解决方案的小版本更新，将项目迁移到 .NET 10，增加了订阅和发票结账改进，以及其他多项增强和 bug 修复。插件开发者在更新时应参考项目的 [.NET 10 迁移指南][btcpay net10]。

## 重大代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #32297][] 为 `bitcoin-cli` 添加了 `-ipcconnect` 选项，使其可以在 Bitcoin Core 以 `ENABLE_IPC` 构建且节点以 `-ipcbind` 启动时，通过 Unix 套接字上的进程间通信（IPC）连接和控制 `bitcoin-node` 实例，而非使用 HTTP（见周报 [#320][news320 ipc] 和 [#369][news369 ipc]）。即使省略 `-ipcconnect`，`bitcoin-cli` 也会先尝试 IPC，在 IPC 不可用时回退到 HTTP。这是[多进程分离项目][multiprocess]的一部分。

- [Bitcoin Core #34379][] 修复了一个 bug：当钱包包含某个[描述符][topic descriptors]——该描述符拥有部分但非全部私钥时，以 `private=true` 调用 `gethdkeys` RPC（见[周报 #297][news297 rpc]）会失败。与 `listdescriptors` 的修复类似（见[周报 #389][news389 descriptor]），此 PR 返回可用的私钥。对严格的仅供观察钱包调用 `gethdkeys private=true` 仍然会失败。

- [Eclair #3269][] 添加了从闲置通道自动回收流动性的功能。当 `PeerScorer` 检测到某个通道在两个方向上的总支付量低于其容量的 5% 时，会逐步将[中继手续费][topic inbound forwarding fees]降低至配置的最低值。如果手续费已在最低值维持至少五天且交易量仍未回升，Eclair 会在该通道与该对等节点是冗余的情况下关闭它。仅当节点持有至少 25% 的资金且本地余额超过现有的 `localBalanceClosingThreshold` 设置时才会关闭通道。

- [LDK #4486][] 将 `rbf_channel` 端点合并到 `splice_channel` 中，作为新[拼接][topic splicing]和对进行中拼接进行手续费追加的统一入口。当拼接已在进行中时，从 `splice_channel` 返回的 `FundingTemplate` 携带 `PriorContribution`，使用户可以在无需新的[币选择][topic coin selection]的情况下对拼接进行 [RBF][topic rbf]。相关拼接 RBF 行为见[周报 #397][news397 rbf]。

- [LDK #4428][] 添加了通过新的 `create_channel_to_trusted_peer_0reserve` 方法为受信任对等节点开启和接受零通道储备金通道的支持。零储备金通道允许对手方在通道中花费其全部链上余额。该功能同时适用于使用[锚点输出][topic anchor outputs]的通道和零手续费承诺交易通道（见[周报 #371][news371 0fc]）。

- [LND #9982][]、[#10650][lnd #10650] 和 [#10693][lnd #10693] 加强了 [taproot][topic taproot] 通道中 [MuSig2][topic musig] nonce 在线路上的处理：`ChannelReestablish` 新增了 `LocalNonces` 字段，使对等节点可以为[拼接][topic splicing]相关的更新协调多个 nonce；`lnwire` 在 TLV 解码时对携带 nonce 的消息验证 MuSig2 公共 nonce；`LocalNoncesData` 的解码会验证每个 nonce 条目。

- [LND #10063][] 将 [RBF][topic rbf] 协作关闭流程扩展到使用 [MuSig2][topic musig] 的[简单 taproot 通道][topic simple taproot channels]。线路消息携带 [taproot][topic taproot] 专用的 nonce 和部分签名字段，关闭状态机在 `shutdown`、`closing_complete` 和 `closing_sig` 之间使用 MuSig2 会话和即时 nonce 模式（相关 RBF 协作关闭流程的背景见[周报 #347][news347 rbf coop]）。

{% include snippets/recap-ad.md when="2026-04-07 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2130,32297,34379,3269,4486,4428,9982,10650,10693,10063" %}

[topic payjoin]: /en/topics/payjoin/
[topic payjoin fingerprinting]: https://delvingbitcoin.org/t/how-wallet-fingerprints-damage-payjoin-privacy/2354
[c delving ibc hd]: https://delvingbitcoin.org/t/compact-isogeny-pqc-can-replace-hd-wallets-key-tweaking-silent-payments/2324
[rr ml gsr bips]: https://groups.google.com/g/bitcoindev/c/T8k47suwuOM
[news374 varops]: /zh/newsletters/2025/10/03/#varops-budget-for-script-runtime-constraint
[news374 c2]: /zh/newsletters/2025/10/03/#restoration-of-disabled-script-functionality-tapscript-v2
[jn delving shrimps]: https://delvingbitcoin.org/t/shrimps-2-5-kb-post-quantum-signatures-across-multiple-stateful-devices/2355
[news383 sphincs]: /zh/newsletters/2025/12/05/#lh-dsa-post-quantum-signature-optimizations
[news391 shrincs]: /zh/newsletters/2026/02/06/#shrincs-324-byte-stateful-post-quantum-signatures-with-static-backups
[wallet bip ml]: https://groups.google.com/g/bitcoindev/c/ylPeOnEIhO8
[news297 rpc]: /zh/newsletters/2024/04/10/#bitcoin-core-29130
[news320 ipc]: /zh/newsletters/2024/09/13/#bitcoin-core-30509
[news347 rbf coop]: /zh/newsletters/2025/03/28/#lnd-8453
[news369 ipc]: /zh/newsletters/2025/08/29/#bitcoin-core-31802
[news371 0fc]: /zh/newsletters/2025/09/12/#ldk-4053
[news389 descriptor]: /zh/newsletters/2026/01/23/#bitcoin-core-32471
[news397 rbf]: /zh/newsletters/2026/03/20/#ldk-4427
[multiprocess]: https://github.com/bitcoin/bitcoin/issues/28722
[bitcoin core 31.0rc2]: https://bitcoincore.org/bin/bitcoin-core-31.0/test.rc2/
[Core Lightning 26.04rc2]: https://github.com/ElementsProject/lightning/releases/tag/v26.04rc2
[BTCPay Server 2.3.7]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.3.7
[bcc31 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/31.0-Release-Candidate-Testing-Guide
[btcpay net10]: https://blog.btcpayserver.org/migrating-to-net10/
