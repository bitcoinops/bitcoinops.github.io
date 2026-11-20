---
title: 'Bitcoin Optech Newsletter #40'
permalink: /zh/newsletters/2019/04/02/
name: 2019-04-02-newsletter-zh
slug: 2019-04-02-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 提到了预估交易手续费的骤升，介绍了 LN 蹦床支付，并公开了 Bitcoin Core 的意图：在 0.20 版或更早版本中，把内置钱包的默认接收地址改为 bech32。此外，本刊照例还有 bech32 发送支持与热门比特币基础设施项目中值得注意的代码变更两个栏目。

{% include references.md %}

## 行动项

- **<!--help-test-bitcoin-core-0-18-0-rc2-->****帮助测试 Bitcoin Core 0.18.0 RC2：** 下一个 Bitcoin Core 主要版本的第二个候选版本（RC）已经[发布][0.18.0]。计划在生产环境中运行新版 Bitcoin Core 的组织和有经验的用户仍需参与测试。请通过[这个问题][Bitcoin Core #15555]报告反馈。

## 网络状态

- **<!--fee-increases-for-fast-confirmation-->****快速确认的手续费上涨：** 过去一年多来，只要支付的费率高于默认最低中继费率（[某段短暂的特殊时期][Newsletter #22]除外），大多数比特币交易都能较快确认；但上周出现了小幅积压，使得需要在接下来几个区块内确认交易的人面临更高的费率。愿意多等一会儿的付款方仍然能省钱。例如，截至本文写作时，Bitcoin Core 的手续费估算器给出的建议是：要在 2 个区块内确认，每 1,000 vbytes 需支付 0.00059060 BTC；而在 50 个区块内确认只需 0.00002120 BTC——多等最多 8 小时，就能省下超过 95%。更多信息可参考 [Johoe 的内存池统计数据][Johoe's mempool statistics]和 [P2SH.info 的费率估算追踪][P2SH.info's fee estimate tracker]。

## 新闻

- **<!--trampoline-payments-for-ln-->****LN 的蹦床支付：** Pierre-Marie Padiou 在 Lightning-Dev 邮件列表上发起了[讨论帖][trampoline thread]，提出 Alice 即使不知道通往 Zed 节点的路径，也可以给他付款：先把付款发给一个中间节点（Dan），再请 Dan 找出通往 Zed 的剩余路线。如果 Alice 运行的是一个轻量级 LN 节点、并不试图跟踪整个网络，这会特别有用。为了增强隐私，Alice 可以使用多个中间节点而不止一个（每个节点收到的指令都由 Alice 分别加密）。邮件中提到的一个缺点是：Alice 只能粗略估算所需的手续费，因为她并不知道实际路径，所以最终支付的手续费可能比自己选路时更多。

- **<!--bitcoin-core-schedules-switch-to-default-bech32-receiving-addresses-->****Bitcoin Core 计划把默认接收地址切换为 bech32：** 自 [0.16.0 版本][0.16.0 segwit]以来，用户希望接收付款时，Bitcoin Core 的内置钱包默认生成的是 P2SH 包装的 segwit 地址。这类地址与所有被广泛使用的软件保持向后兼容。正如一个[ issue][Bitcoin Core #15560]和[项目每周会议][core meeting segwit]中所讨论的，从 Bitcoin Core 0.20 开始（预计约一年后），Bitcoin Core 将默认使用原生 segwit 地址（bech32），从而额外节省手续费，并带来其他好处。目前，许多钱包和服务[已经支持向 bech32 地址付款][bech32 adoption]；如果 Bitcoin Core 项目在接下来六个月内看到足够多的新增采用、足以支持提前切换，就会改为在 Bitcoin Core 0.19 中默认使用 bech32 接收地址。如果用户在 GUI 或通过 RPC 明确要求，P2SH 包装的 segwit 地址仍会继续提供；不想采用这次变更的人也可以自行配置默认地址类型。（同样，尝鲜的用户如果想现在就改默认值，可以在 0.16.0 及以上的任何 Bitcoin Core 版本中设置 `addresstype=bech32` 配置选项。）

## Bech32 发送支持

*第 3 周，共 24 周。在 2019 年 8 月 24 日 segwit 软分叉锁定满两周年之前，Optech Newsletter 每周都会包含这一栏目，提供信息帮助开发者和组织实现 bech32 发送支持——也就是能够向原生 segwit 地址付款。你[不需要自己实现 segwit][bech32 series]，但你付款的对象却能享受到 segwit 带来的种种好处。*

{% include specials/bech32/zh/03-python-ref.md %}

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案（BIPs）][bips repo] 中值得注意的变更。注意：文中描述的 Bitcoin Core 合并都发生在它的 master 开发分支上；其中一些也可能被向后移植到 0.18 分支，供待发布的 0.18.0 使用。*

- [Bitcoin Core #15620][] 使 `maxtxfee` 配置参数不再影响 `sendrawtransaction` 和 `testmempoolaccept` RPC。此前这些 RPC 默认会拒绝手续费高于配置上限的交易，现在则以硬编码的默认值 0.1 BTC 作为可接受的上限。`maxtxfee` 配置参数仍会用于 Bitcoin Core 的内置钱包；它只是不再作用于节点层面的 RPC。这一改动是[钱包配置选项清理][Bitcoin Core #13044]的一部分，也是节点与钱包分离工作的一部分（在此次改动之前，两者都使用这一设置）。

- [Bitcoin Core #15643][] 修改了 Bitcoin Core 开发者用于合并提交的 Python 脚本，使 git 的合并消息中包含一份列表，说明哪些开发者批准（ACK）了被合并的那个 PR 版本。（这个项目内部改动本身也许并不值得注意，但该工具的另一项功能——把完整的 PR 描述复制进合并消息——让本节作者撰写这些合并摘要容易了许多，因此他鼓励其他比特币项目研究使用这个工具的好处：它既能自动生成更好的基于 git 的文档，也能提升项目的安全性和可审计性。）

- [Bitcoin Core #15519][] 为 Bitcoin Core 添加了 [Poly1305][] 实现，但尚未使用。预计日后会用于实现 [P2P 协议加密][P2P protocol encryption]。

- [Bitcoin Core #15637][] 修改了与内存池相关的 RPC（例如 `getrawmempool`），把 `size` 字段重命名为 `vsize`。原来的值其实也是 vsize，因此计算方式并未改变。这次合并只是明确该字段是 vsize，而不是剥离见证后的大小。为了向后兼容，你可以用 `deprecatedrpc=size` 参数启动 Bitcoin Core，继续使用旧字段名，不过该字段名会在未来的版本中移除。

- [LND #2759][] 把所有通道的默认 [CLTV delta][bolt2 delta] 从 144 个区块（约 24.0 小时）降低到 40 个区块（约 6.7 小时）。当 Alice 想通过一系列路由节点支付给 Zed 时，她首先把钱交给 Bob，条件是：要么 Alice 在（例如）400 个区块后可以取回这笔钱，要么 Bob 能在此之前提供某个特定哈希的原像（即打开哈希锁的密钥）来领取这笔钱。必要时，这 400 个区块的延迟会在链上通过 `OP_CHECKLOCKTIMEVERIFY`（CLTV）强制执行。随后，Bob 以类似条件把钱（减去他的路由手续费）转给 Charlie，只是 CLTV 值会按他与 Charlie 之间通道的 CLTV delta 从 Alice 原始的 400 个区块中扣减，降为 360 个区块。这样一来，即使 Charlie 拖到最长时限（360 个区块）才履行对 Bob 的 HTLC 并领取款项，Bob 仍剩 40 个区块来完成最初的 HTLC，从 Alice 那里领走*他的*款项。如果 Bob 给 Charlie 的 HTLC 到期时间完全没有缩短、仍是 400 个区块的延迟，Bob 就有损失资金的风险：Charlie 可以拖到 400 个区块才履行 HTLC，而 Alice 就能在 Bob 来得及履行 HTLC 之前取消她与 Bob 的 HTLC。

  之后每一跳路由器都会依次从自己提供给下一跳节点的条件数值中减去自己的 delta。因此，CLTV delta 设得越高，一条路由能用的跳数就越少，通道用于路由支付时也就越不具吸引力。

- [Eclair #894][] 用 HTTP POST 接口替换了 JSON-RPC 接口。不再使用 RPC 命令，而是改用 HTTP 端点（例如 `channelstats` RPC 现在变成 `POST http://localhost:8080/channelstats`）。参数以命名表单参数的形式传给端点，其 JSON 语法与 RPC 参数相同。返回结果与改动前完全一致。旧接口仍可通过配置参数 `eclair.api.use-old-api=true` 启用，但预计会在后续版本中移除。详情参见[更新后的 API 文档][eclair api docs]。

{% include linkers/issues.md issues="15555,15560,15620,15643,15519,15637,2759,894,13044" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[poly1305]: https://en.wikipedia.org/wiki/Poly1305
[0.16.0 segwit]: https://bitcoincore.org/en/releases/0.16.0/#segwit-wallet
[eclair api docs]: https://acinq.github.io/eclair/#introduction
[johoe's mempool statistics]: https://jochen-hoenicke.de/queue/#0,1w
[p2sh.info's fee estimate tracker]: https://p2sh.info/dashboard/db/fee-estimation?orgId=1
[trampoline thread]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-March/001939.html
[core meeting segwit]: http://www.erisian.com.au/meetbot/bitcoin-core-dev/2019/bitcoin-core-dev.2019-03-28-19.01.log.html#l-83
[bech32 adoption]: https://en.bitcoin.it/wiki/Bech32_adoption
[bolt2 delta]: https://github.com/lightningnetwork/lightning-rfc/blob/master/02-peer-protocol.md#cltv_expiry_delta-selection
[p2p protocol encryption]: https://gist.github.com/jonasschnelli/c530ea8421b8d0e80c51486325587c52
[bech32 series]: /zh/bech32-sending-support/
[newsletter #22]: /zh/newsletters/2018/11/20/#monitor-feerates
