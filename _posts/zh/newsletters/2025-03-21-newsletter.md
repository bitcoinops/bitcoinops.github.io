---
title: 'Bitcoin Optech 周报 #346'
permalink: /zh/newsletters/2025/03/21/
name: 2025-03-21-newsletter-zh
slug: 2025-03-21-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报总结了关于 LND 更新的动态手续费调整系统的讨论。此外还包括我们的常规板块，描述了服务和客户端软件的近期变更，发布新版本和候选版本的公告，以及总结了热门比特币基础设施软件的最新合并。

## 新闻

- **<!--discussion-of-lnd-s-dynamic-feerate-adjustment-system-->关于 LND 动态手续费率调整系统的讨论：** Matt Morehouse 在 Delving Bitcoin 上[发布][morehouse sweep]了对 LND 最近重写的 _sweeper_ 系统的描述，该系统用于确定链上交易的手续费率（包括[手续费替换][topic rbf]调整）。他首先简要描述了闪电网络节点手续费管理的安全关键方面，以及避免手续费过高的自然需求。然后他描述了 LND 使用的两种通用策略：

  * 查询外部手续费率估算器，比如本地 Bitcoin Core 节点或第三方。这主要用于选择初始手续费率和为非紧急交易追加手续费。

  * 指数级手续费提升，在截止期限临近时使用，以确保节点的交易池或其[手续费估算][topic fee estimation]出现问题时不会影响及时确认。例如，Eclair 在截止期限在六个区块以内时使用指数级手续费提升。

  Morehouse 接着描述了这两种策略在 LND 新的 sweeper 系统中是如何结合的：“具有相同截止期限的 [HTLC][topic htlc] 取款被聚合到单个[批量交易][topic payment batching]中。批量交易的预算是通过计算交易中各个 HTLC 预算的总和得出的。基于交易预算和截止期限，计算出一个手续费函数，该函数决定了随着截止期限临近要花费多少预算。默认情况下，使用线性手续费函数，从低手续费开始（由最低中继费率或外部估算器决定），在截止期限还剩一个区块时将全部预算分配给手续费。”

  他还描述了新逻辑如何帮助防御[替代循环][topic replacement cycling]攻击，总结道：“使用 LND 的默认参数，攻击者通常必须花费至少 20 倍于 HTLC 价值的费用才能成功进行替代循环攻击。”他补充说，新系统还改进了 LND 对[交易钉死攻击][topic transaction pinning]的防御。

  最后他用包含许多链接的形式，总结了通过改进逻辑修复的几个“LND 特定的错误和漏洞”。Abubakar Sadiq Ismail [回复][ismail sweep]提出了一些建议，说明所有闪电网络实现（以及其他软件）如何更有效地使用 Bitcoin Core 的手续费估算。其他几位开发者也发表了评论，既补充了细节，也对新方法表示赞赏。

## 服务和客户端软件变更

*在这个月度专题中，我们会重点介绍比特币钱包和服务的有趣更新。*

- **<!--wally-1-4-0-released-->Wally 1.4.0 发布：**
  [libwally-core 1.4.0 版本][wally 1.4.0]增加了对[taproot][topic taproot]的支持，支持派生 [BIP85][] RSA 密钥，以及额外的 [PSBT][topic psbt] 和[描述符][topic descriptors]功能。

- **<!--bitcoin-core-config-generator-announced-->Bitcoin Core 配置生成器发布：**
  [Bitcoin Core 配置生成器][bccg github]项目是一个用于创建 Bitcoin Core `bitcoin.conf` 配置文件的终端界面。

- **<!--a-regtest-development-environment-container-->regtest 开发环境容器：**
  [regtest-in-a-pod][riap github]仓库提供了一个配置了 Bitcoin Core、Electrum 和 Esplora 的 [Podman][podman website] 容器，详情请参见[使用 Podman 容器进行 Regtest 比特币开发][podman bitcoin blog]博文。

- **<!--explora-transaction-visualization-tool-->Explora 交易可视化工具：**
  [Explora][explora github] 是一个基于网络的浏览器，用于可视化和导航交易输入输出之间的关系。

- **<!--hashpool-v0-1-tagged-->Hashpool v0.1 发布：**
  [Hashpool][hashpool github] 是一个基于 [Stratum v2 参考实现][news247 sri]的[矿池][topic pooled mining]，其中挖矿份额被表示为 [ecash][topic ecash] 代币（参见[播客 #337][pod337 hashpool]）。

- **<!--dmnd-launching-pooled-mining-->DMND 启动矿池服务：**
  [DMND][dmnd website] 正在启动 Stratum v2 矿池服务，这是在他们之前的独立挖矿[公告][news281 demand]基础上的进一步发展。

- **<!--krux-adds-taproot-and-miniscript-->Krux 添加 taproot 和 miniscript 支持：**
  [Krux][news273 krux] 利用 [embit][embit website] 库添加了 [miniscript][topic miniscript] 和 taproot 支持。

- **<!--source-available-secure-element-announced-->开源安全元件发布：**
  [TROPIC01][tropic01 website] 是一个基于 RISC-V 构建的安全元件，具有[开放架构][tropicsquare github]以便于审计。

- **<!--nunchuk-launches-group-wallet-->Nunchuk 推出群组钱包：**
  [群组钱包][nunchuk blog]支持[多重签名][topic multisignature]、taproot、币种控制、[Musig2][topic musig]，并通过重新利用 [BIP129][] 比特币安全多重签名设置（BSMS）文件中的输出描述符来实现参与者之间的安全通信。

- **<!--frostr-protocol-announced-->FROSTR 协议发布：**
  [FROSTR][frostr github] 使用 FROST [门限签名方案][topic threshold signature]来实现 nostr 的 k-of-n 签名和密钥管理。

- **<!--bark-launches-on-signet-->Bark 在 signet 上线：**
  [Ark][topic ark] 的实现 [Bark][new325 bark] 现在在 [signet][topic signet] 上[可用][second blog]，并提供水龙头和演示商店供测试。

- **<!--cove-bitcoin-wallet-announced-->Cove 比特币钱包发布：**
  [Cove 钱包][cove wallet github] 是一个基于 BDK 的开源比特币移动钱包，支持 PSBT、[钱包标签][topic wallet labels]、硬件签名设备等技术。

## 新版本和候选版本

_热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [Bitcoin Core 29.0rc2][] 是网络中占主导地位的全节点的下一个主要版本的候选版本。

## 重要代码和文档变更

_以下是[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[闪电网络 BOLTs][bolts repo]、[闪电网络 BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的重要变更。_

- [Bitcoin Core #31649][] 移除了所有检查点逻辑，这在几年前实现的区块头预同步步骤（参见周报 [#216][news216 presync]）之后已不再必要。该预同步使节点在初始区块下载（IBD）期间能够通过将区块头链的总工作量与预定义的阈值 `nMinimumChainWork` 进行比较来确定其有效性。只有总工作量超过此值的链才被认为有效并存储，有效防止了低工作量区块头的内存 DoS 攻击。这消除了对检查点的需求，检查点经常被视为一个中心化元素。

- [Bitcoin Core #31283][] 在 `BlockTemplate` 接口中引入了新的 `waitNext()` 方法，该方法仅在链顶端区块发生变化或交易池手续费超过 `MAX_MONEY` 阈值时才返回新模板。此前，矿工每次请求都会收到新模板，导致不必要的模板生成。这一变更符合 [Stratum V2][topic pooled mining] 协议规范。

- [Eclair #3037][] 增强了 `listoffers` 命令（参见周报 [#345][news345 offers]），返回所有相关的 [offer][topic offers]数据，包括 `createdAt` 和 `disabledAt` 时间戳，而不仅仅是原始的类型-长度-值（TLV）数据。此外，这个 PR 修复了尝试再次注册相同 offer 时导致节点崩溃的错误。

- [LND #9546][] 在 `lncli constrainmacaroon` 子命令（参见周报 [#201][news201 constrain]）中添加了 `ip_range` 标志，允许用户在使用 macaroon（认证令牌）时将资源访问限制在特定的 IP 范围内。此前，macaroon 只能基于特定 IP 地址允许或拒绝访问，而不能基于范围。

- [LND #9458][] 为某些对等节点引入了受限访问槽，可通过 `--num-restricted-slots` 标志配置，以管理服务器上的初始访问权限。对等节点根据其通道历史被分配访问级别：具有已确认通道的获得受保护访问权限，具有未确认通道的获得临时访问权限，其他所有节点获得受限访问权限。

- [BTCPay Server #6581][] 添加了[手续费替换][topic rbf]支持，使得在没有后代交易、所有输入都来自商店钱包且包含商店的找零地址的交易中可以进行手续费提升。用户现在可以在选择提升交易手续费时在 [CPFP][topic cpfp] 和手续费替换之间选择。手续费提升需要 NBXplorer 2.5.22 或更高版本。

- [BDK #1839][] 通过引入新的 `TxUpdate::evicted_ats` 字段来支持检测和处理已取消（双重支付）的交易，该字段更新 `TxGraph` 中的 `last_evicted` 时间戳。如果交易的 `last_evicted` 时间戳超过其 `last_seen` 时间戳，则认为该交易已被驱逐。正统化算法（参见周报 [#335][news335 algorithm]）已更新，忽略被驱逐的交易，除非基于传递性规则存在正统后代。

- [BOLTs #1233][] 更新了节点行为，规定如果节点知道原像，就永远向上游回传 [HTLC][topic htlc] 失败的信息，确保 HTLC 可以正确结算。此前的建议是，如果已确认的承诺中缺少未完成的 HTLC，即使知道原像也要向上游回传失败信息。LND 0.18 版本之前的一个错误导致节点在遭受 DoS 攻击后重启时，尽管知道原像但仍向上游回传 HTLC 失败信息，导致 HTLC 价值损失（参见周报 [#344][news344 lnd]）。

{% include snippets/recap-ad.md when="2025-03-25 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31649,31283,3037,9546,9458,6581,1839,1233" %}
[bitcoin core 29.0rc2]: https://bitcoincore.org/bin/bitcoin-core-29.0/
[morehouse sweep]: https://delvingbitcoin.org/t/lnds-deadline-aware-budget-sweeper/1512
[ismail sweep]: https://delvingbitcoin.org/t/lnds-deadline-aware-budget-sweeper/1512/3
[news216 presync]: /en/newsletters/2022/09/07/#bitcoin-core-25717
[news345 offers]: /zh/newsletters/2025/03/14/#eclair-2976
[news201 constrain]: /zh/newsletters/2022/05/25/#lnd-6529
[news344 lnd]: /zh/newsletters/2025/03/07/#disclosure-of-fixed-lnd-vulnerability-allowing-theft
[news335 algorithm]: /zh/newsletters/2025/01/03/#bdk-1670
[wally 1.4.0]: https://github.com/ElementsProject/libwally-core/releases/tag/release_1.4.0
[bccg github]: https://github.com/jurraca/core-config-tui
[riap github]: https://github.com/thunderbiscuit/regtest-in-a-pod
[podman website]: https://podman.io/
[podman bitcoin blog]: https://thunderbiscuit.com/posts/podman-bitcoin/
[explora github]: https://github.com/lontivero/explora
[hashpool github]: https://github.com/vnprc/hashpool
[news247 sri]: /zh/newsletters/2023/04/19/#stratum-v2
[pod337 hashpool]: /en/podcast/2025/01/21/#continued-discussion-about-rewarding-pool-miners-with-tradeable-ecash-shares-transcript
[news281 demand]: /zh/newsletters/2023/12/13/#stratum-v2
[dmnd website]: https://www.dmnd.work/
[embit website]: https://embit.rocks/
[news273 krux]: /zh/newsletters/2023/10/18/#krux-signing-device-firmware-krux
[tropic01 website]: https://tropicsquare.com/tropic01
[tropicsquare github]: https://github.com/tropicsquare
[nunchuk blog]: https://nunchuk.io/blog/group-wallet
[frostr github]: https://github.com/FROSTR-ORG
[new325 bark]: /zh/newsletters/2024/10/18/#bark-ark-implementation-announced
[second blog]: https://blog.second.tech/try-ark-on-signet/
[cove wallet github]: https://github.com/bitcoinppl/cove
