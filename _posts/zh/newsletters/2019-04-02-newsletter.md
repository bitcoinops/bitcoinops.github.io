---
title: 'Bitcoin Optech Newsletter #40'
permalink: /zh/newsletters/2019/04/02/
name: 2019-04-02-newsletter-zh
slug: 2019-04-02-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 提到了交易费用估算的激增、描述了 LN 蹦床支付，并宣布 Bitcoin Core 计划在 0.20 版或更早版本中将其内置钱包的接收地址默认设置为 bech32。此外，还包括有关 bech32 发送支持和流行的 Bitcoin 基础设施项目中的值得注意的代码更改的常规部分。

{% include references.md %}

## 行动项

- **<!--help-test-bitcoin-core-0-18-0-rc2-->****帮助测试 Bitcoin Core 0.18.0 RC2：** 下一个 Bitcoin Core 主要版本的第二个候选版本（RC）已经[发布][0.18.0]。仍然需要计划在生产环境中运行新版本的 Bitcoin Core 的组织和有经验的用户进行测试。使用[这个问题][Bitcoin Core #15555]报告反馈。

## 网络状态

- **<!--fee-increases-for-fast-confirmation-->****快速确认的费用增加：** 在过去一年多的时间里，大多数 Bitcoin 交易确认速度相当快，只要他们支付的费率高于默认最低中继费（除了在[短暂的特殊时期][Newsletter #22]），在过去的一周中，出现了一个适度的积压，导致需要在接下来的几个区块内确认其交易的人的费率提高。愿意等待更长时间的支出者仍然可以节省费用。例如，在撰写本文时，Bitcoin Core 的费用估算器建议每 1,000 vbytes 的 2 个区块内确认费用为 0.00059060 BTC，而 50 个区块内确认费用仅为 0.00002120——节省了超过 95% 的费用，最多等待额外 8 小时。有关更多信息，我们推荐 [Johoe 的内存池统计数据][Johoe's mempool statistics]和 [P2SH.info 的费用估算跟踪][P2SH.info's fee estimate tracker]。

## 新闻

- **<!--trampoline-payments-for-ln-->****LN 的蹦床支付：** Pierre-Marie Padiou 在 Lightning-Dev 邮件列表中启动了一个[线程][trampoline thread]，建议 Alice 可以通过首先向一个中间节点（Dan）发送支付并要求 Dan 找出到 Zed 的剩余路径来向 Zed 发送支付，即使她不知道到他节点的路径。这将特别有利于 Alice，如果她运行一个不试图跟踪整个网络的轻量级 LN 节点。为了增加隐私，Alice 可以使用多个中间节点而不仅仅是一个（每个节点收到 Alice 加密的自己的指令）。电子邮件中描述的一个缺点是，Alice 只能大致猜测所需的费用，因为她不知道实际路径，所以她可能最终支付的费用比她自己选择路线时要多。

- **<!--bitcoin-core-schedules-switch-to-default-bech32-receiving-addresses-->****Bitcoin Core 计划将默认接收地址切换到 bech32：** 自 [0.16.0 版本][0.16.0 segwit]以来，Bitcoin Core 的内置钱包在用户希望接收支付时默认为生成 P2SH 包裹的 segwit 地址。这些地址与所有广泛使用的软件向后兼容。正如在[问题][Bitcoin Core #15560]和[项目的每周会议][core meeting segwit]中讨论的那样，从 Bitcoin Core 0.20 开始（预计约一年后），Bitcoin Core 将默认使用本机 segwit 地址（bech32），提供额外的费用节省和其他好处。目前，许多钱包和服务[已经支持发送到 bech32 地址][bech32 adoption]，如果 Bitcoin Core 项目在接下来的六个月中看到足够的额外采用，它将提前切换到 bech32 接收地址。在 GUI 或通过 RPC 请求时，P2SH 包裹的 segwit 地址将继续提供，如果用户不想要更新，也可以配置他们的默认地址类型。（同样，先锋用户现在可以在任何 Bitcoin Core 0.16.0 及以上版本中设置 `addresstype=bech32` 配置选项以更改其默认值。）

## Bech32 发送支持

*第 3 周，共 24 周。在 2019 年 8 月 24 日 segwit 软分叉锁定的二周年纪念日前，Optech Newsletter 将包含此每周部分，为开发人员和组织提供有关实现 bech32 发送支持（支付本机 segwit 地址的能力）的信息。这[不需要实现 segwit][bech32 series]本身，但确实允许你支付的人访问 segwit 的所有多个好处。*

{% include specials/bech32/zh/03-python-ref.md %}

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和 [Bitcoin Improvement Proposals (BIPs)][bips repo] 中的值得注意的更改。注意：所有描述的 Bitcoin Core 合并都是在其主开发分支上；有些可能也会回移到 0.18 分支以便发布 0.18.0 版本。*

- [Bitcoin Core #15620][] 停止 `maxtxfee` 配置参数影响 `sendrawtransaction` 和 `testmempoolaccept` RPC。之前这些 RPC 会默认拒绝支付费用高于配置最大值的交易。现在使用硬编码的默认值 0.1 BTC 作为可接受的上限。`maxtxfee` 配置参数仍由 Bitcoin Core 的内置钱包使用；它只是与节点特定的 RPC 分开使用。此更改是[钱包配置选项清理][Bitcoin Core #13044]的一部分，也是节点和钱包分离的一部分（两者在此更改之前都使用该设置）。

- [Bitcoin Core #15643][] 更改了 Bitcoin Core 开发人员用于合并提交的 Python 脚本，以便 git 合并消息中包含批准（ACKed）合并版本的开发人员列表。（这个内部项目更改本身可能并不值得注意，但该工具的另一个功能——将完整的 PR 描述复制到合并消息中——使得本节作者编写这些合并摘要变得更加容易，因此他鼓励其他 Bitcoin 项目调查使用此工具的优势，以自动创建更好的基于 git 的文档，以及提高他们的安全性和可审核性。）

- [Bitcoin Core #15519][] 添加了 [Poly1305][] 实现到 Bitcoin Core，但没有使用它。预计稍后将用于实现[P2P 协议加密][P2P protocol encryption]。

- [Bitcoin Core #15637][] 修改了与内存池相关的 RPC（例如 `getrawmempool`）以将 `size` 字段重命名为 `vsize`。以前的值也是 vsize，因此计算没有变化。此合并的 PR 只是明确这是一个 vsize 而不是一个剥离的大小。为了向后兼容，可以使用 `deprecatedrpc=size` 参数启动 Bitcoin Core 以继续使用旧字段名称，尽管这将在未来版本中删除。

- [LND #2759][] 降低了所有通道的默认 [CLTV delta][bolt2 delta] 从 144 个区块（大约 24.0 小时）到 40 个区块（大约 6.7 小时）。当 Alice 想通过一系列路由节点支付给 Zed 时，她首先将资金给 Bob，条件是要么 Alice 可以在（例如）400 个区块后收回资金，要么 Bob 可以在此之前提供一个特定哈希的前映像（打开哈希锁的密钥）来领取资金。400 个区块的延迟在链上使用 `OP_CHECKLOCKTIMEVERIFY`（CLTV）进行强制执行。然后，Bob 以类似的条件将资金（减去他的路由费）发送给 Charlie，只是 CLTV 值从 Alice 的原始 400 个区块减少了他与 Charlie 的通道的 CLTV delta，减少到 360 个区块。这确保了如果 Charlie 等待最长时间（360 个区块）来完成他的 HTLC 并领取他的付款，Bob 仍有 40 个区块来完成原始 HTLC 并从 Alice 那里领取他的付款。如果 Bob 与 Charlie 的 HTLC 到期时间没有减少，使用 400 个区块的延迟，Bob 将面临损失资金的风险。Charlie 可以延迟完成他的 HTLC 到 400 个区块，然后 Alice 可以在 Bob 有时间完成 HTLC 之前取消她与 Bob 的 HTLC。

  随后的路由器分别从他们给下一个节点的条款值中减去他们的 delta。因此，使用高 CLTV delta 会减少可以在路由中使用的跳数，并使通道在路由支付时不太具有吸引力。

- [Eclair #894][] 用 HTTP POST 接口替换 JSON-RPC 接口。使用 HTTP 端点而不是 RPC 命令（例如 `channelstats` RPC 现在是 `POST http://localhost:8080/channelstats`）。参数使用与 RPC 参数相同的 JSON 语法作为命名的表单参数提供。返回的结果与更改前相同。旧接口仍可使用配置参数 `eclair.api.use-old-api=true` 使用，但预计将在后续版本中删除。有关详细信息，请参见[更新的 API 文档][eclair api docs]。

{% include linkers/issues.md issues="15555,15560,15620,15643,15519,15637,2759,894,13044" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[poly1305]: https://en.wikipedia.org/wiki/Poly1305
[0.16.0 segwit]: https://bitcoincore.org/en/releases/0.16.0/#segwit-wallet
[eclair api docs]: https://acinq.github.io/eclair/#introduction
[johoe's mempool statistics]: https://jochen-hoenicke.de/queue/#0,1w
[p2sh.info's fee estimate tracker]: https://p2sh.info/dashboard/db/fee-estimation?orgId=1
[trampoline thread]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-March/001939.html
[core meeting segwit]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2019/bitcoin-core-dev.2019-03-28-19.01.log.html#l-83
[bech32 adoption]: https://en.bitcoin.it/wiki/Bech32_adoption
[bolt2 delta]: https://github.com/lightningnetwork/lightning-rfc/blob/master/02-peer-protocol.md#cltv_expiry_delta-selection
[p2p protocol encryption]: https://gist.github.com/jonasschnelli/c530ea8421b8d0e80c51486325587c52
[bech32 series]: /zh/bech32-sending-support/
[newsletter #22]: /zh/newsletters/2018/11/20/#monitor-feerates
