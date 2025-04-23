---
title: 'Bitcoin Optech Newsletter #137'
permalink: /zh/newsletters/2021/02/24/
name: 2021-02-24-newsletter-zh
slug: 2021-02-24-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了关于选择 Taproot 软分叉激活参数讨论的结果，并包括我们定期的部分，内容涵盖来自 Bitcoin Stack Exchange 的精选问答、发布与候选发布，以及对流行比特币基础设施软件中值得注意的更改。

## 新闻

- **<!--taproot-activation-discussion-->****Taproot 激活讨论：** Michael Folkson [总结][folkson lot]了关于 [taproot][topic taproot] 激活参数的第二次会议，得出结论“对于 LOT=true 或 LOT=false 并未达成压倒性的共识”，LockinOnTimeout (LOT) 参数来自 [BIP8][]，决定节点是否需要强制信号以激活该分叉。然而，对于其他激活参数几乎达成了一致意见，最显著的是将需要信号以激活分叉的哈希率从 95% 减少到 90%。

  讨论继续在邮件列表上进行，主要围绕鼓励用户自行选择选项的影响，无论是通过命令行选项还是通过选择使用哪个软件版本。截至撰写本文时，尚未达成明确的协议，似乎也没有广泛支持的路径来激活 taproot——尽管 taproot 本身似乎几乎完全被期望。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选地点之一——或者当我们有一些闲暇时间帮助好奇或困惑的用户时。在这个月度特辑中，我们重点介绍了一些自上次更新以来获得最高票的问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--is-sharding-a-good-alternative-to-multisig-->**[Sharding 是否是 multisig 的一个好替代方案？]({{bse}}102007)
  用户 S.O.S 询问像 Shamir 的秘密共享 (SSS) 这样的分片方案实现 multisig 类似功能的可行性。Pieter Wuille 指出了 `OP_CHECKMULTISIG` 相较于 SSS 的优势（可追溯性，无需在一台机器上重建秘密密钥），SSS 相较于 `OP_CHECKMULTISIG` 的优势（更低的费用、更高的隐私），以及 [schnorr 签名][topic schnorr signatures]的考虑因素（缺乏可追溯性，无需在一台机器上重建秘密密钥，更低的费用、更高的隐私，额外的复杂性）。

- **<!--can-a-channel-be-closed-while-the-funding-tx-is-still-stuck-in-the-mempool-->**[在资金交易仍卡在 mempool 中时，通道是否可以关闭？]({{bse}}102180)
  在尝试打开 LN 通道但设置资金交易的 feerate 过低后，PyrolitePancake 询问在资金交易仍在 mempool 中时关闭通道的问题。虽然一种选择是通过等待确认并可能重新广播交易来继续打开通道，Rene Pickhardt 指出双重花费资金交易的输入将使其从 mempool 中移除。cdecker 为 C-lightning 提供了一些示例命令，用于重新广播资金交易或创建双重花费。

- **<!--with-peerblockfilters-1-hundreds-of-btcwire-0-5-0-neutrino-connections-are-downloading-tb-from-my-bitcoin-node-->**[启用 peerblockfilters=1 后，数百个“btcwire 0.5.0/neutrino”连接正在从我的比特币节点下载 TB]({{bse}}102263)
  在启用[致密区块过滤器][topic compact block filters]的 Bitcoin Core 0.21.0 运行时，qertoip 注意到大量连接（75%）和带宽使用（90%）来自 `btcwire 0.5.0/neutrino` 用户代理。Murch 指出这些对等方是 LND 节点，并且由于致密区块过滤器既是 Bitcoin Core 的[新功能][news132 0.21.0]，也是[默认情况下禁用的][news98 18877]，目前网络上可能缺乏支持致密区块过滤器的对等方，导致支持过滤器的节点流量较高。

- **<!--is-there-dumpwallet-output-documentation-explanation-->**[是否有 `dumpwallet` 输出的文档和解释？]({{bse}}101767)
  Andrew Chow 利用这个回答机会，提供了 `dumpwallet` RPC 输出的额外文档和解释。

- **<!--is-there-something-about-bitcoin-that-prevents-implementing-the-same-privacy-protocols-of-monero-and-zcash-->**[比特币是否有某些限制，防止实现与 Monero 和 Zcash 相同的隐私协议？]({{bse}}101868)
  Pieter Wuille 列出了开发者可能不选择开发，以及生态系统可能不选择支持 Monero 或 Zcash 所采取的隐私方法的一些挑战。考虑因素包括“选择加入”方法的缺点，引入新的密码学安全假设，可扩展性问题，以及供应审计性的问题。

## 发布与候选发布

*流行比特币基础设施项目的新发布和候选发布。请考虑升级到新版本或帮助测试候选发布。*

- [LND 0.12.1-beta][LND 0.12.1-beta] 是 LND 的最新维护版本。它修复了一个可能导致意外通道关闭的边缘情况和一个可能导致某些支付不必要失败的错误，以及一些其他的小改进和错误修复。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #19136][] 扩展了 `getaddressinfo` RPC，增加了一个新的 `parent_desc` 字段，包含钱包中地址的公钥的 [output script descriptor][topic descriptors]。钱包的 [BIP32][] 路径将移除所有硬化前缀，仅保留公共派生步骤，允许描述符被导入到其他钱包软件中，这些软件可以监控接收到该地址及其同级地址的比特币。

- [Bitcoin Core #15946][] 使得可以同时使用配置选项 `prune` 和 `blockfilterindex` 来在修剪节点上维护[致密区块过滤器][topic compact block filters]（如果使用了 `peerblockfilters` 配置选项，也会为其提供服务）。一位 LND 开发者[指出][osuntokun request]这将对他们的软件有益，并且它还可以允许未来的更新，允许钱包逻辑使用区块过滤器来确定修剪节点需要重新下载哪些历史区块以导入钱包。

- [Eclair #1693][] 和 [Rust-Lightning #797][] 更改了节点地址公告的处理方式。当前的 [BOLT7][] 规范要求对公告中的地址进行排序，然而一些实现并未使用或强制执行此规则。Eclair 更新了他们的实现以开始排序，Rust-Lightning 更新了他们的实现以停止要求排序。一个 [PR][bolts #842] 正在开放以更新规范，但关于应做何种更改仍在讨论中。

- [HWI #454][] 更新了 `displayaddress` 命令，增加了在 BitBox02 设备上注册 multisig 地址的支持。

- [BIPs #1052][] 将 [BIP338][] 分配给在比特币 P2P 协议中添加 `disabletx` 消息的提案。发送此消息的节点在连接建立期间向其对等方发出信号，表示它将永远不会在该连接上请求或公告交易。正如在 [Newsletter #131][news131 disabletx] 中描述的，这允许对等方为禁用中继连接使用不同的限制，例如接受超过当前 125 个连接最大值的额外连接。另见 1 月 12 日 P2P 开发者会议的[讨论总结][2021-01-12 p2p summary]。

{% include references.md %}
{% include linkers/issues.md issues="1052,454,19136,15946,1693,797,842,798" %}
[LND 0.12.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.12.1-beta
[folkson lot]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018425.html
[2021-01-12 p2p summary]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/P2P-IRC-meetings#topic-disabletx-p2p-message-sdaftuar
[osuntokun request]: https://github.com/bitcoin/bitcoin/pull/15946#issuecomment-571854091
[news131 disabletx]: /zh/newsletters/2021/01/13/#proposed-disabletx-message
[news132 0.21.0]: /zh/newsletters/2021/01/20/#bitcoin-core-0-21-0
[news98 18877]: /zh/newsletters/2020/05/20/#bitcoin-core-18877
