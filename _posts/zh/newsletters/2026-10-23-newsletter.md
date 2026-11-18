---
title: 'Bitcoin Optech 周报 #428'
permalink: /zh/newsletters/2026/10/23/
name: 2026-10-23-newsletter-zh
slug: 2026-10-23-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报介绍了一种单一发行方二层网络的设计，用户无需发行方配合，就能在链上取回比特币；还总结了一项将哈希原像纳入输出脚本描述符的提案。此外还包括我们的常规栏目：服务和客户端软件的近期变化、新版本和候选版本的公告，以及流行比特币基础设施软件的重大变更。

## 新闻

- **<!--trust-minimized-exits-from-a-single-issuer-layer-2-->****单一发行方二层网络的信任最小化退出机制：** Adam Gibson 在 Bitcoin-Dev 邮件列表上[发帖][lichen ml]，介绍了 Lichen 的[论文][lichen paper]和概念验证[代码][lichen repo]。在这个设计中，Gibson 将单一发行方称为枢纽（hub）。枢纽在一个二层账本上发行可与比特币一比一兑换的代币，账本由称为排序器（sequencer）的服务器运行。每个用户都与枢纽持有一份 2-of-2 合约，即使枢纽拒绝配合或离线，用户仍可兑换代币。因此，用户需要信任排序器诚实运行账本，但不必信任枢纽会归还自己的比特币。这个设计建立在 LN-GAP 之上（见[周报 #427][news427 lngap]），但将其依赖诚实多数的见证委员会，替换成了完全在链上解决的争议机制。

  每个用户都将比特币锁定在自己与枢纽共有的 2-of-2 输出中，并在二层账本上获得等量代币；用户可以在账本上互相支付，无需触及链上。退出时，用户将代币交回枢纽，并从自己的输出中取回比特币。由于用户只能从这个输出中取款，枢纽也会向每个输出锁入一部分自己的比特币，额度由双方协商，类似于闪电网络的入站流动性，让用户可以兑换从别人那里收到的代币。超过额度收到的代币，则只能由枢纽自行决定是否兑换。

  如果枢纽配合，它只需为一笔从该输出向用户付款的结算交易签名。如果枢纽拒绝或没有响应，用户就生成一份 Groth16 证明，证明排序器签署了一个记录代币已交回的状态。由于 Script 无法验证这种证明，用户改为在链上主张：某个固定的验证程序会接受这份证明。如果枢纽提出异议，预签名的 [BitVMX][topic acc] 交易会将分歧缩小到 Script 可以检查的单个执行步骤。双方各自锁定一笔储备金，在争议中落败的一方会失去它，以抑制虚假主张和拒绝配合的行为。Gibson 承认，如果排序器遗漏用户交回代币的记录，或签署一个账本从未合法到达的状态，仍可能让用户或枢纽损失资金。他将有效性证明和由多个排序器组成的委员会列为未来工作。

- **<!--descriptor-syntax-for-hash-preimages-->****哈希原像的描述符语法：** João Dias 在 Delving Bitcoin 上[发帖][desc del]，提议扩展 [BIP379][]，为 [miniscript][topic miniscript] 的哈希片段增加一种私有形式。目前，对于花费条件要求提供原像的资金，还没有办法直接将原像交给 Bitcoin Core 钱包来花费。唯一的方式是借助外部工具，将其放进 [PSBT][topic psbt] 的某个哈希字段中（例如 `PSBT_IN_SHA256`）。作者指出，这项提案只涵盖创建描述符时就已知的原像，不涵盖在花费时才获知的原像，例如 [HTLC][topic htlc] 中的情况。

  Dias 解释说，对待原像应当更像对待密钥，而不是签名，并指出了[描述符][topic descriptors]模型中的一处不一致。他希望让钱包从描述符中导入秘密值，直接构建并签署交易。为此，他提出了特定的描述符语法（例如 `sha256(preimage(HEX))`），并设定了几项边界：必须使用专门的标记，而非原始十六进制数据；所有哈希片段的原像都固定为 32 字节；原像必须像其他秘密值一样处理，需要备份、加密，并且绝不能出现在公开的描述符字符串中。

  在将提案正式化之前，Dias 列出了一些尚待解决的问题，例如标记语法应当是什么、修改 BIP379 还是起草新的 BIP、Bitcoin Core 是否需要新增一个管理原像的 RPC、硬件签名设备是否应处理原像秘密值，还是仅由软件钱包来处理，以及大家是否有兴趣从密钥材料中确定性地派生原像。

## 服务和客户端软件的变更

*在这个每月栏目中，我们会重点介绍比特币钱包和服务的有趣更新。*

- **<!--ibis-wallet-v5-0-beta-released-->****Ibis Wallet v5.0-beta 发布：** [Ibis Wallet v5.0-beta][ibis v5.0]（见[周报 #406][news406 ibis]）增加了基于 Bark 的 [Ark][topic ark] 支持、从 Spark [状态链][topic statechains]单方退出的功能，以及使用[静默支付][topic silent payments]地址收款的支持。

- **<!--landfall-wallet-for-lightning-mining-payouts-->****用于闪电网络挖矿奖励支付的 Landfall 钱包：** [Landfall][landfall gh] 是一个概念验证钱包，展示了如今就能实现的用户体验：它从单个种子生成 OCEAN 矿池通过闪电网络支付奖励所需的收款地址、[BOLT12 要约][topic offers]和 [BIP322][topic generic signmessage] 签名，并使用由 Lexe 托管运行的节点（见[周报 #419][news419 lexe]）。它不适合生产环境使用。

- **<!--rbitcoin-0-8-0-released-->****rbitcoin 0.8.0 发布：** [rbitcoin 0.8.0][] 是一个基于 rust-bitcoin、用 Rust 编写的比特币全节点，据称完全由 AI 编写，用作钱包和闪电网络的后端。它用关系型归档（relational archive）替代 UTXO 集，提供 Electrum 和 Esplora 风格的 API，并且仅使用 [BIP324][topic v2 p2p transport]。

## 版本和候选版本

_流行比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。_

- [Eclair 0.14.4][] 和 [0.14.5][Eclair 0.14.5] 是这一闪电网络节点实现的安全版本。0.14.4 修复了[拼接][topic splicing]、[HTLC][topic htlc] 结算、[即时（on-the-fly）注资][topic jit channels]和洋葱解析方面的若干问题，详见[周报 #427][news427 eclair fixes]。它还会拒绝带有 `Origin` 头部的 API 请求，防止有人利用缓存的 HTTP Basic 认证凭据发动跨站请求伪造（见[周报 #423][news423 eclair api]）。基于浏览器的集成现在必须通过自己的后端来调用 Eclair。0.14.5 修复了下文介绍的蹦床路由和 taproot 拼接漏洞，并堵上了一处利用整数溢出绕过洋葱载荷长度验证的漏洞；这项长度验证此前在[周报 #427][news427 eclair onion]中介绍过。项目方强烈建议升级。

- [BDK chain 0.23.4][] 是 BDK 用于构建比特币钱包的库的维护版本。它修复了交易跟踪方面的问题，以及全量扫描在检查完所有此前已向用户提供的地址之前就停止的问题。配套更新修复了重组后的 Bitcoin Core RPC 同步，并包含此前介绍过的 Electrum 修复：[txid 验证][news403 bdk txid]、[首个输出为 `OP_RETURN` 的交易的确认检测][news405 bdk opreturn]，以及[重组后的确认跟踪][news427 bdk reorg]。

- [LND v0.21.5-beta.rc1][] 和 [v0.20.6-beta.rc1][LND v0.20.6-beta.rc1] 是这一流行闪电网络节点实现的维护版本的候选版本。两者都包含[周报 #418][news418 lnd fees]介绍的手续费更新处理和通道消息限制，以及承诺费率、解析 TLV 记录时分配过多内存，以及 SQL 数据库死锁等方面的修复。0.21.5 还包含[周报 #427][news427 lnd aux]介绍的 [Taproot Assets][topic client-side validation] 通道的辅助 [HTLC][topic htlc] 签名验证修复，并修复了区块链重组期间的钱包同步。

## 重大的代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Eclair #3409][] 修复了一处漏洞，恶意付款方可能借此窃取转发[蹦床支付][topic trampoline payments]的节点的资金。Eclair 现在会限制下游路由的 [CLTV 到期增量][topic cltv expiry delta]总和，确保出站 HTLC 早于入站 HTLC 到期（相关修复见[周报 #423][news423 eclair cltv]）。此前，寻路失败时，Eclair 会放宽路由长度和到期时间的限制再重试，让付款方可以提供到期增量过大的路由提示或[盲化路径][topic rv routing]。这样，付款方可以在入站 HTLC 到期后，在链上收回资金，而收款方仍可兑现出站 HTLC。现在，Eclair 只放宽路由长度限制，保留所要求的到期顺序。

- [Eclair #3411][] 修复了一处漏洞，恶意通道对等节点可能通过让 Eclair 签署无效的[拼接][topic splicing]交易来窃取资金（相关修复见[周报 #427][news427 eclair splice]）。对[简单 taproot 通道][topic simple taproot channels]进行拼接时，对等节点可以只提供输入所花费的前序输出的金额和脚本，而不提供完整交易。此前，Eclair 未经验证就信任这些值。对等节点可以在任一字段上撒谎，让 Eclair 签署一笔永远无法确认的拼接交易，因为 taproot 签名承诺的是被花费输入的实际金额和脚本。尽管如此，Eclair 仍会将这笔无效拼接视为最新的通道注资状态。随后，对等节点可以发布一笔此前已签名、花费旧注资输出的承诺交易，在 Eclair 对应的入站 HTLC 已超时并退款后，用支付原像兑现一个出站 [HTLC][topic htlc]，让 Eclair 无法收取其转发支付对应的款项。现在，Eclair 会在签名前，通过自己的比特币后端核实对等节点提供的前序输出信息。

- [LDK #5126][] 修复了一个 bug：使用单跳[盲化路径][topic rv routing]的 [BOLT12][topic offers] 支付，可能因为 HTLC 到期时间太短而被拒绝。此前，由于入口节点同时也是接收者，LDK 忽略了路径的 `cltv_expiry_delta`，却没有考虑其中包含接收者要求的[最终 CLTV 增量][topic cltv expiry delta]。因此，只有当 LDK 的随机 CLTV 偏移量足够大时，支付才能满足接收者的最低要求。这在与 Core Lightning 进行测试时造成了间歇性支付失败。现在，LDK 在构建路由和检查所允许的 CLTV 增量总和上限时，都会计入通告的增量。

- [LND #10919][] 增加了一个实验性的本地声誉系统，用来缓解[通道阻塞攻击][topic channel jamming attacks]。它基于所提议的 HTLC 问责方案（见周报 [#377][news377 jamming] 和 [#387][news387 accountability]），取代此前的 [HTLC 背书][topic htlc endorsement]方案。系统根据过去的转发活动和节点通告的手续费，为出站通道评分；带有问责标记的 [HTLC][topic htlc] 处理耗时过长，会导致评分降低。该系统默认启用，只在日志中记录 HTLC 是否有资格使用受保护的资源，不影响转发决定。声誉会在重启时重置。

- [BTCPay Server #7679][] 修复了一个可能导致重复闪电网络付款的 bug。此前，如果发起付款后，后续支付查询没有返回结果，BTCPay Server 就会取消该笔付款，并丢弃已保存的支付哈希，即使支付其实已经成功。这可能让运维者为一笔已经成功的支付再次付款。现在，BTCPay Server 会保留正在处理中的付款及其支付哈希，以便后续检查。

- [BTCPay Server #7684][] 修复了 Greenfield API 密钥授权中的一处权限提升漏洞。此前，仅限于某个商店的 API 密钥，即使作用范围受限，也能行使服务器或账户范围的权限。此外，获准为其他用户创建 API 密钥的密钥，还能授予比自己更广的权限。现在，BTCPay Server 会在授权请求时执行权限范围限制，并阻止 API 密钥授予其自身并不拥有的权限。现有不受限制的管理员密钥保留其预期能力。

- [BDK #2325][] 和 [#2360][bdk #2360] 修复了两个 bug：钱包可能在没有取得所请求交易数据的情况下，报告同步成功。第一个影响通过 Electrum 同步单个输出点。此前，BDK 在获取相关交易时会忽略所有错误，包括连接失败和超时。这可能让已花费的输出仍被归类为未花费。现在，BDK 在这条处理路径上只忽略 Electrum 协议错误，其他失败则向上传递。第二个 PR 修复了 Electrum 和 Esplora 客户端的 `sync` 和 `full_scan`。此前，将 Electrum 的 `batch_size` 或 Esplora 的 `parallel_requests` 设为零，可能在报告成功的同时，悄悄跳过所请求的扫描或交易获取。现在，两种客户端都会将这两个参数的零值当作一来处理。

- [BOLTs #1357][] 更新了 [BOLT11][]，要求发票读取者仅接受恰好包含一个支付哈希（`p`）字段和一个支付秘密值（`s`）字段的发票。此前，规范建议付款方使用第一个 `p` 字段，而一些发票解析器使用最后一个字段。这种差异[曾被用于攻击 LNP2PBot][lnp2p incident]，该机器人的发票解析器和闪电网络节点选择了不同的支付哈希。因此，机器人将已完成的付款视为尚未支付，让攻击者可以获得重复付款（见[周报 #425][news425 lnd]）。

- [BOLTs #1352][] 修正了[简单 taproot 通道][topic simple taproot channels]规范和测试向量中的若干错误（见[周报 #404][news404 taproot]）。如果按此前的规范实现，taproot 输出密钥派生和控制块构造中的错误可能生成无效花费。这个 PR 还明确，`commitment_signed` 中交换的 [HTLC][topic htlc] 签名使用 `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY`：接收方对等节点在构造见证时，会在 64 字节签名后追加 `0x83`。为了追加手续费而合并二级交易时，每个 HTLC 输入及其对应输出，必须在合并后的交易中处于相同索引。其他修正涉及[锚点花费路径][topic anchor outputs]、[MuSig2][topic musig] nonce 编码和派生，以及本地和远程承诺的测试向量。这些变更让规范与现有 LND 和 Eclair 实现保持一致，不改变协议行为。

{% include snippets/recap-ad.md when="2026-10-27 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3409,3411,5126,10919,7679,7684,2325,2360,1357,1352" %}

[lichen ml]: https://groups.google.com/g/bitcoindev/c/yZEZ5P1lj5E
[lichen paper]: https://github.com/AdamISZ/lichen/blob/master/papers/lichen-v0.1.pdf
[lichen repo]: https://github.com/AdamISZ/lichen
[news427 lngap]: /zh/newsletters/2026/10/16/#offchain-contracts-in-lightning-channels
[ibis v5.0]: https://github.com/aeonBTC/IbisWallet/releases/tag/v5.0.1-beta
[news406 ibis]: /zh/newsletters/2026/05/22/#ibis-wallet
[landfall gh]: https://github.com/vincenzopalazzo/landfall
[news419 lexe]: /zh/newsletters/2026/08/21/#lexe-adds-human-readable-addresses-and-lnurl-withdraw
[rbitcoin 0.8.0]: https://github.com/reardencode/rbitcoin/releases/tag/v0.8.0
[desc del]: https://delvingbitcoin.org/t/descriptor-syntax-for-hash-preimages/2935
[Eclair 0.14.4]: https://github.com/ACINQ/eclair/releases/tag/v0.14.4
[Eclair 0.14.5]: https://github.com/ACINQ/eclair/releases/tag/v0.14.5
[BDK chain 0.23.4]: https://github.com/bitcoindevkit/bdk/releases/tag/chain-0.23.4
[LDK #5126]: https://git.rust-bitcoin.org/lightningdevkit/rust-lightning/pulls/5126
[lnp2p incident]: https://x.com/negrunch/status/2097763741123166576
[news423 eclair api]: /zh/newsletters/2026/09/18/#eclair-3380
[news427 eclair fixes]: /zh/newsletters/2026/10/16/#重大的代码和文档变更
[news427 eclair onion]: /zh/newsletters/2026/10/16/#eclair-3395
[news403 bdk txid]: /zh/newsletters/2026/05/01/#bdk-2188
[news405 bdk opreturn]: /zh/newsletters/2026/05/15/#bdk-2195
[news427 bdk reorg]: /zh/newsletters/2026/10/16/#bdk-2319
[news423 eclair cltv]: /zh/newsletters/2026/09/18/#eclair-3376
[news427 eclair splice]: /zh/newsletters/2026/10/16/#eclair-3396
[news377 jamming]: /zh/newsletters/2025/10/24/#channel-jamming-mitigation-simulation-results-and-updates
[news387 accountability]: /zh/newsletters/2026/01/09/#lnd-10367
[news425 lnd]: /zh/newsletters/2026/10/02/#lnd-11190
[news404 taproot]: /zh/newsletters/2026/05/08/#bolts-995
[LND v0.21.5-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.21.5-beta.rc1
[LND v0.20.6-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.6-beta.rc1
[news418 lnd fees]: /zh/newsletters/2026/08/14/#lnd-11023
[news427 lnd aux]: /zh/newsletters/2026/10/16/#lnd-11068
