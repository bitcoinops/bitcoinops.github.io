---
title: 'Bitcoin Optech Newsletter #137'
permalink: /zh/newsletters/2021/02/24/
name: 2021-02-24-newsletter-zh
slug: 2021-02-24-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了关于 taproot 软分叉激活参数选择的讨论结果，并包含我们的固定栏目：Bitcoin Stack Exchange 精选问答、发布与候选发布，以及热门比特币基础设施软件的值得注意的变更。

## 新闻

- **<!--taproot-activation-discussion-->****Taproot 激活讨论：** Michael Folkson [总结][folkson lot]了关于 [taproot][topic taproot] 激活参数的第二次会议，结论是“对 LOT=true 和 LOT=false 都没有形成压倒性共识”。LOT 即 [BIP8][] 中的 LockinOnTimeout 参数，决定节点是否强制要求表态支持激活该分叉。不过，对其他激活参数几乎达成了一致，其中最显著的一点是把激活分叉所需表态的算力（哈希率）比例从 95% 降低到 90%。

  邮件列表上围绕 LOT 参数的讨论仍在继续，主要涉及鼓励用户自行选择该选项会带来什么影响——无论是通过命令行选项，还是通过选择使用哪个软件版本。截至本文撰写时，尚未达成明确共识，似乎也没有一条获得广泛支持的推进路径来激活 taproot——尽管 taproot 本身几乎已是众望所归。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们有点空闲时帮助好奇或困惑用户的地方。在本月栏目中，我们精选自上次更新以来得票最高的一些问题和回答。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--is-sharding-a-good-alternative-to-multisig-->**[分片（sharding）是多重签名的一个好替代方案吗？]({{bse}}102007)
  用户 S.O.S 询问像沙米尔秘密共享（Shamir's Secret Sharing，SSS）这样的分片方案能否实现类似多重签名的功能。Pieter Wuille 指出了 `OP_CHECKMULTISIG` 相较于 SSS 的优势（可追责、无需在一台机器上重建私钥），SSS 相较于 `OP_CHECKMULTISIG` 的优势（手续费更低、隐私更好），以及 [schnorr 签名][topic schnorr signatures]需要考虑的因素（无法追责、无需在一台机器上重建私钥、手续费更低、隐私更好，但复杂性更高）。

- **<!--can-a-channel-be-closed-while-the-funding-tx-is-still-stuck-in-the-mempool-->**[在注资交易仍卡在内存池中时，通道能否关闭？]({{bse}}102180)
  在尝试打开 LN 通道、却把注资交易的费率（feerate）设得过低之后，PyrolitePancake 询问在注资交易仍留在内存池中时关闭通道的问题。一种选择是等待确认并可能重新广播交易，从而继续打开通道；Rene Pickhardt 则指出，双重花费注资交易的输入会让它从内存池中被剔除。cdecker 为 C-lightning 提供了一些示例命令，用于重新广播注资交易或构造双重花费。

- **<!--with-peerblockfilters-1-hundreds-of-btcwire-0-5-0-neutrino-connections-are-downloading-tb-from-my-bitcoin-node-->**[启用 peerblockfilters=1 后，数百个“btcwire 0.5.0/neutrino”连接正在从我的 Bitcoin 节点下载数 TB 数据]({{bse}}102263)
  在启用[紧凑区块过滤器][topic compact block filters]的情况下运行 Bitcoin Core 0.21.0 时，qertoip 注意到有大量连接（75%）和带宽占用（90%）来自 `btcwire 0.5.0/neutrino` 用户代理。Murch 指出，这些对等节点是 LND 节点；由于紧凑区块过滤器既是 Bitcoin Core 的[一项新功能][news132 0.21.0]，又[默认处于禁用状态][news98 18877]，目前网络上提供紧凑区块过滤器服务的对等节点可能偏少，导致支持这些过滤器的节点流量偏高。

- **<!--is-there-dumpwallet-output-documentation-explanation-->**[是否有 `dumpwallet` 输出的文档和解释？]({{bse}}101767)
  Andrew Chow 借这个回答的机会，补充了 `dumpwallet` RPC 输出的文档和解释。

- **<!--is-there-something-about-bitcoin-that-prevents-implementing-the-same-privacy-protocols-of-monero-and-zcash-->**[比特币是否有某些限制，使得无法实现与 Monero 和 Zcash 相同的隐私协议？]({{bse}}101868)
  Pieter Wuille 列举了一些原因，说明开发者为何可能不愿投入、生态系统为何可能不愿支持 Monero 或 Zcash 所采用的隐私方案。考虑因素包括“自愿启用”方式的缺点、引入新的密码学安全假设、可扩展性问题，以及供应量的可审计性问题。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LND 0.12.1-beta][LND 0.12.1-beta] 是 LND 最新的维护版本。它修复了一个可能导致通道意外关闭的边缘情况，以及一个可能让某些支付无谓失败的 bug，此外还有一些小改进和错误修复。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的变更。*

- [Bitcoin Core #19136][] 为 `getaddressinfo` RPC 新增了 `parent_desc` 字段，其中包含一个[输出脚本描述符][topic descriptors]，对应包含该地址公钥的钱包。该钱包的 [BIP32][] 路径会被去掉所有硬化前缀，只保留公开派生步骤，这样描述符就能导入其他钱包软件，让它们监控发往该地址及其兄弟地址的比特币。

- [Bitcoin Core #15946][] 使得可以同时使用 `prune` 和 `blockfilterindex` 两个配置选项，在修剪节点上维护[紧凑区块过滤器][topic compact block filters]（若启用了 `peerblockfilters` 配置选项，还会对外提供这些过滤器）。一位 LND 开发者[指出][osuntokun request]这对他们的软件会有帮助；此外，未来的更新还可能让钱包逻辑利用区块过滤器，判断修剪节点需要重新下载哪些历史区块才能导入钱包。

- [Eclair #1693][] 和 [Rust-Lightning #797][] 更改了节点地址公告的处理方式。当前的 [BOLT7][] 规范要求对公告内的地址排序，但一些实现并未使用或强制执行这条规则。Eclair 更新了自己的实现，开始进行排序；Rust-Lightning 则更新了自己的实现，不再要求排序。有一个 [PR][bolts #842] 已提交以更新规范，但究竟应做何种更改仍在讨论中。

- [HWI #454][] 更新了 `displayaddress` 命令，增加了在 BitBox02 设备上注册多重签名地址的支持。

- [BIPs #1052][] 把 [BIP338][] 这个编号分配给了在比特币 P2P 协议中添加 `disabletx` 消息的提案。节点在建立连接期间发送该消息，即向对等节点表明：它永远不会在这条连接上请求或公告交易。正如 [Newsletter #131][news131 disabletx] 中所述，这允许对等节点对禁用了交易中继的连接采用不同的限制，例如接受超过当前 125 个连接上限的额外连接。另见 1 月 12 日 P2P 开发者会议的[讨论总结][2021-01-12 p2p summary]。

{% include references.md %}
{% include linkers/issues.md issues="1052,454,19136,15946,1693,797,842,798" %}
[LND 0.12.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.12.1-beta
[folkson lot]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-February/018425.html
[2021-01-12 p2p summary]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/P2P-IRC-meetings#topic-disabletx-p2p-message-sdaftuar
[osuntokun request]: https://github.com/bitcoin/bitcoin/pull/15946#issuecomment-571854091
[news131 disabletx]: /zh/newsletters/2021/01/13/#proposed-disabletx-message
[news132 0.21.0]: /zh/newsletters/2021/01/20/#bitcoin-core-0-21-0
[news98 18877]: /zh/newsletters/2020/05/20/#bitcoin-core-18877
