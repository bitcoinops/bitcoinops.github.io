---
title: 'Bitcoin Optech Newsletter #355'
permalink: /zh/newsletters/2025/05/23/
name: 2025-05-23-newsletter-zh
slug: 2025-05-23-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报包括我们的常规部分，描述服务和客户端软件的变更、宣布新版本和候选版本，以及总结热门比特币基础设施软件的近期变更。

## 新闻

*本周在我们的任何[来源][sources]中都没有发现重大新闻。*

## 服务和客户端软件的变更

*在这个月度栏目中，我们重点介绍比特币钱包和服务的有意思的更新。*

- **<!--cake-wallet-added-payjoin-v2-support-->****Cake Wallet 添加 payjoin v2 支持：**
  Cake Wallet [v4.28.0][cake wallet 4.28.0] 添加了[功能][cake blog]，可以使用 [payjoin][topic payjoin] v2 协议接收支付。

- **<!--sparrow-adds-pay-to-anchor-features-->****Sparrow 添加支付到锚点功能：**
  Sparrow [2.2.0][sparrow 2.2.0] 可以显示并发送[支付到锚点（P2A）][topic ephemeral anchors]输出。

- **<!--safe-wallet-1-3-0-released-->****Safe Wallet 1.3.0 发布：**
  [Safe Wallet][safe wallet github] 是一个支持硬件签名设备的多签桌面钱包，在 [1.3.0][safe wallet 1.3.0] 版本中为入账交易添加了 [CPFP][topic cpfp] 手续费追加功能。

- **<!--coldcard-q-v1-3-2-released-->****COLDCARD Q v1.3.2 发布：**
  COLDCARD Q 的 [v1.3.2 版本][coldcard blog] 包括额外的多签[花费策略支持][coldcard ccc]和用于[共享敏感数据][coldcard kt]的新功能。

- **<!--transaction-batching-using-payjoin-->****使用 payjoin 进行交易批处理：**
  [Private Pond][private pond post] 是一个[实验性实现][private pond github]，提供[交易批处理][topic payment batching]服务，使用 payjoin 生成更小且手续费更低的交易。

- **<!--joinmarket-fidelity-bond-simulator-->****JoinMarket Fidelity 债券模拟器：**
  [JoinMarket Fidelity 债券模拟器][jmfbs github] 为 JoinMarket 参与者提供工具，基于 [Fidelity 债券][news161 fb]模拟他们在市场中的表现。

- **<!--bitcoin-opcodes-documented-->****比特币操作码文档：**
  [Opcode Explained][opcode explained website] 网站记录了每个比特币脚本操作码。

- **<!--bitkey-code-open-sourced-->****Bitkey 代码开源：**
  Bitkey 硬件签名设备[宣布][bitkey blog]其[源代码][bitkey github]对非商业用途开源。

## 发布和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND 0.19.0-beta][] 是这个热门闪电网络节点的最新主要版本。它包含许多[改进][lnd rn]和错误修复，包括基于 RBF 的合作式关闭手续费追加功能。

- [Core Lightning 25.05rc1][] 是这个热门闪电网络节点实现的下一个主要版本的候选版本。

## 值得注意的代码和文档变更

*[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]、[闪电网络 BOLTs][bolts repo]、[闪电网络 BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期值得注意的变更。*

- [Bitcoin Core #32423][] 移除了对 `rpcuser/rpcpassword` 的弃用通知，替换为关于在配置文件中存储明文凭证的安全警告。当 [Bitcoin Core #7044][] 引入 `rpcauth` 时，该选项最初被弃用，后者支持多个 RPC 用户并对 cookie 进行哈希处理。该 PR 还为两种方法的凭证添加了随机 16 字节盐值，并在存储到内存前进行哈希处理。

- [Bitcoin Core #31444][] 扩展了 `TxGraph` 类（参见周报 [#348][news348 txgraph]），添加了三个新的辅助函数：`GetMainStagingDiagrams()` 返回主图和暂存图之间族群的差异，`GetBlockBuilder()` 从高到低遍历图块（子族群手续费率排序分组）以优化区块构建，`GetWorstMainChunk()` 定位最低手续费率块以用于驱逐决策。该 PR 是[族群交易池][topic cluster mempool]项目完整初始实现的最后构建块之一。

- [Core Lightning #8140][] 默认启用通道备份的[对等节点存储][topic peer storage]（参见周报 [#238][news238 storage]），通过限制存储到当前或过去有通道的对等节点，在内存中缓存备份和对等节点列表而不是重复调用 `listdatastore`/`listpeerchannels`，将并发备份上传限制为两个对等节点，跳过大于 65 kB 的备份，并在发送时随机选择对等节点，使其适用于大型节点。

- [Core Lightning #8136][] 更新了公告签名的交换时机，从等待六个区块后改为通道就绪时，以符合最近的 [BOLTs #1215][] 规范更新。仍然需要等待六个区块才能[公告通道][topic channel announcements]。

- [Core Lightning #8266][] 为 Reckless 插件管理器（参见周报 [#226][news226 reckless]）添加了 `update` 命令，可以更新指定的插件或所有已安装的插件（如果未指定），但跳过从固定 Git 标签或提交安装的插件。该 PR 还扩展了 `install` 命令，除了插件名称外还可以接受源路径或 URL。

- [Core Lightning #8021][] 完成了与 Eclair 的[拼接][topic splicing]互操作性（参见周报 [#331][news331 interop]）。实现方式是通过修复远程注资密钥的轮换，在通道重新建立时重新发送 `splice_locked` 以覆盖原始遗漏的情况（参见周报 [#345][news345 splicing]），放宽对承诺签名消息到达顺序的要求，启用接收和发起拼接 [RBF][topic rbf] 交易，在需要时自动将出站 [PSBTs][topic psbt] 转换为版本 2，以及其他重构更改。

- [Core Lightning #8226][] 通过添加新的 `signmessagewithkey` RPC 命令实现 [BIP137][]，允许用户通过指定比特币地址使用钱包中的任何密钥签名消息。以前，使用 Core Lightning 密钥签名消息需要找到 xpriv 和密钥索引，使用外部库派生私钥，然后使用 Bitcoin Core 签名消息。

- [LND #9801][] 添加了新的 `--no-disconnect-on-pong-failure` 选项，用于控制在对等节点的 pong 响应延迟或不匹配时是否断开连接。该选项默认为 false，保持 LND 在 pong 消息失败时断开对等节点连接的当前行为（参见周报 [#275][news275 ping]）；否则，LND 只会记录该事件。该 PR 重构了 ping 看门狗，在抑制断开连接时继续其循环。

{% include snippets/recap-ad.md when="2025-05-27 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32423,31444,8140,8136,8266,8021,8226,9801,7044,1215" %}
[lnd 0.19.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta
[sources]: /en/internal/sources/
[lnd rn]: https://github.com/lightningnetwork/lnd/blob/master/docs/release-notes/release-notes-0.19.0.md
[Core Lightning 25.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v25.05rc1
[news348 txgraph]: /zh/newsletters/2025/04/04/#bitcoin-core-31363
[news238 storage]: /zh/newsletters/2023/02/15/#core-lightning-5361
[news226 reckless]: /zh/newsletters/2022/11/16/#core-lightning-5647
[news331 interop]: /zh/newsletters/2024/11/29/#core-lightning-7719
[news345 splicing]: /zh/newsletters/2025/03/14/#eclair-3007
[news275 ping]: /zh/newsletters/2023/11/01/#lnd-7828
[cake wallet 4.28.0]: https://github.com/cake-tech/cake_wallet/releases/tag/v4.28.0
[cake blog]: https://blog.cakewallet.com/bitcoin-privacy-takes-a-leap-forward-cake-wallet-introduces-payjoin-v2/
[sparrow 2.2.0]: https://github.com/sparrowwallet/sparrow/releases/tag/2.2.0
[safe wallet github]: https://github.com/andreasgriffin/bitcoin-safe
[safe wallet 1.3.0]: https://github.com/andreasgriffin/bitcoin-safe/releases/tag/1.3.0
[coldcard blog]: https://blog.coinkite.com/ccc-and-keyteleport/
[coldcard ccc]: https://coldcard.com/docs/coldcard-cosigning/
[coldcard kt]: https://github.com/Coldcard/firmware/blob/master/docs/key-teleport.md
[private pond post]: https://njump.me/naddr1qvzqqqr4gupzqg42s9gsae3lu2cketskuzfp778fh2vg9c5x3elx8ttdpzhfkk25qq2nv5nzddgxxdjtd4u9vwrdv939vmnswfzk6j85dxk
[private pond github]: https://github.com/Kukks/PrivatePond
[jmfbs github]: https://github.com/m0wer/joinmarket-fidelity-bond-simulator
[news161 fb]: /zh/newsletters/2021/08/11/#implementation-of-fidelity-bonds
[opcode explained website]: https://opcodeexplained.com/
[bitkey blog]: https://x.com/BEN0WHERE/status/1918073429791785086
[bitkey github]: https://github.com/proto-at-block/bitkey
