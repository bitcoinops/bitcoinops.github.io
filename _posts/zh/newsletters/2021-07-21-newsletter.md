---
title: 'Bitcoin Optech Newsletter #158'
permalink: /zh/newsletters/2021/07/21/
name: 2021-07-21-newsletter-zh
slug: 2021-07-21-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了近期服务和客户端软件的更改，讨论了为何钱包应暂缓生成 Taproot 地址，列出了新软件发布与候选版本，并总结了热门比特币基础设施软件的值得注意的变更。

## 新闻

*本周无重要新闻。*

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--lightning-powered-news-site-stacker-news-launches-->****闪电网络驱动的新闻网站 Stacker News 上线：** [开源][stacker news github]新闻网站 [Stacker News][stacker.news] 发布，支持 LNURL 身份验证，也支持通过闪电网络微支付进行投票和评论。

- **<!--suredbits-announces-dlc-wallet-alpha-release-->****Suredbits 宣布 DLC 钱包 alpha 版本发布：** [Suredbits 的 bitcoin-s][suredbits blog] 软件包含 GUI，支持借助预言机在比特币区块链上执行谨慎日志合约（DLC）。公告最后提到，他们还计划使用 [schnorr 签名][topic schnorr signatures]和[点时间锁定合约（PTLC）][topic ptlc]来实现[兼容闪电网络的 DLC][suredbits blog dlcs ln]。

- **<!--sparrow-1-4-3-supports-p2tr-->****Sparrow 1.4.3 支持 P2TR：** Sparrow 的 [1.4.3 版本][sparrow 1.4.3] 在 [signet][topic signet] 和 regtest 上支持[单签 P2TR 钱包][taproot series 4]。该版本还支持[向 P2TR 的 bech32m 地址发送][taproot series 1]。

- **<!--coldcard-firmware-adds-seed-xor-feature-->****Coldcard 固件新增 Seed XOR 功能：** Coldcard 的 [4.1.0 固件][coldcard 4.1.0] 支持 [Seed XOR][seed xor]，这是一种分割/组合 [BIP39][] 种子的方法，其中每个部分都可作为独立钱包使用。组合后经 XOR 运算的结果同样可作为钱包使用，由此可实现蜜罐资金、合理推诿等特性。

- **<!--bluewallet-integrates-lightning-dev-kit-->****BlueWallet 集成 Lightning Dev Kit：** BlueWallet [宣布][bluewallet ldk tweet]转向新的闪电网络实现，现使用 [Lightning Dev Kit (LDK)][ldk github]。

## 准备 Taproot #5：我们为什么要等待？

*关于开发者与服务提供商如何为即将在区块高度 {{site.trb}} 激活的 Taproot 做准备的[系列][series preparing for taproot]周更文章。*

{% include specials/taproot/zh/04-why-wait.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LND 0.13.1-beta][] 是维护版本，包含对 0.13.0-beta 引入功能的微小改进和错误修复。

- [Rust-Lightning 0.0.99][] 是包含若干 API 和配置变更的版本。详见其[发布说明][rl 0.0.99 rn]。

- [Eclair 0.6.1][] 是包含性能改进、若干新功能和多项错误修复的新版本。除[发布说明][eclair 0.6.1]外，还可参阅下文*值得注意的变更*栏目中关于 Eclair #1871 和 #1846 的描述。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]的值得注意的变更。*

- [Bitcoin Core #22112][] 将 [I2P][] 地址的默认端口从 8333（IPv4 和 IPv6 的默认端口）改为 0，并禁止连接端口非 0 的 I2P 地址。[SAM v3.1 规范][sam specification]（Bitcoin Core 支持的版本）未包含端口概念。若未来 Bitcoin Core 支持包含端口概念的 SAM v3.2，此限制可能解除。

- [C-Lightning #4611][] 更新插件提供的 `keysend` RPC，新增 `routehints` 参数，可用来提供把支付路由至[未公开通道][topic unannounced channels]所需的信息。

- [C-Lightning #4646][] 为移除旧有行为做了两项准备。第一项变更假定节点支持 2019 年加入的 TLV 编码（参见 [Newsletter #55][news55 tlv]），只有明确声明不支持 TLV 编码的节点才会被区别对待。第二项变更将支付密钥（payment secret）改为必填项（此前的讨论见 [Newsletter #75][news75 payment secrets]，LND 开始要求该字段的经过见 [Newsletter #126][news126 lnd4752]）。

- [C-Lightning #4614][] 更新 `listchannels` RPC，新增可选 `destination` 参数用于仅返回通向指定节点的通道。

- [Eclair #1871][] 修改其 SQLite 设置，将每秒可处理的 [HTLC][topic htlc] 数量提升 5 倍，并增强抗数据丢失能力。PR 中引用了 Joost Jager 对比不同节点软件 HTLC 吞吐量的[博客文章][jager ln perf]。

- [Eclair #1846][] 新增了对*预先关闭脚本*（upfront shutdown script）的可选支持：节点在协商新通道时会指定一个地址，对等节点同意该地址将是日后双方关闭通道时唯一允许使用的地址。另见 [Newsletter #76][news76 upfront shutdown] 对 LND 中该功能实现的描述。

- [Rust-Lightning #975][] 将基础支付转发费设为可配置，默认值为 1 聪（截至 2021 年 7 月的市场费率）。闪电网络路由节点可收取两种费用：固定的基础费，或按路由金额收取一定百分比；多数节点两者兼用。此前 Rust-Lightning 将基础费设为预估的链上结算 HTLC 所需费用，远高于 1 聪。

- [BTCPay Server #2462][] 优化了通过 BTCPay 追踪外部钱包支付的功能，例如当实例运营者希望使用个人钱包进行退款时。

## 脚注

{% include references.md %}
{% include linkers/issues.md issues="22112,4611,4646,4614,1871,1846,975,2462" %}
[LND 0.13.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.1-beta
[eclair 0.6.1]: https://github.com/ACINQ/eclair/releases/tag/v0.6.1
[news76 upfront shutdown]: /zh/newsletters/2019/12/11/#lnd-3655
[rl 0.0.99 rn]: https://github.com/rust-bitcoin/rust-lightning/blob/main/CHANGELOG.md#0099---2021-07-09
[news55 tlv]: /zh/newsletters/2019/07/17/#bolts-607
[news75 payment secrets]: /zh/newsletters/2019/12/04/#c-lightning-3259
[news126 lnd4752]: /zh/newsletters/2020/12/02/#lnd-4752
[jager ln perf]: https://bottlepay.com/blog/bitcoin-lightning-node-performance/
[rust-lightning 0.0.99]: https://github.com/rust-bitcoin/rust-lightning/releases/tag/v0.0.99
[I2P]: https://geti2p.net/en/
[sam specification]: https://geti2p.net/en/docs/api/samv3
[stacker news github]: https://github.com/stackernews/stacker.news
[stacker.news]: https://stacker.news/
[suredbits blog]: https://suredbits.com/dlc-wallet-alpha-release/
[suredbits blog dlcs ln]: https://suredbits.com/discreet-log-contracts-on-lightning-network/
[sparrow 1.4.3]: https://github.com/sparrowwallet/sparrow/releases/tag/1.4.3
[taproot series 4]: /zh/preparing-for-taproot/#从-p2wpkh-到单签-p2tr
[taproot series 1]: /zh/preparing-for-taproot/#bech32m-发送支持
[coldcard 4.1.0]: https://blog.coinkite.com/version-4.1.0-released/
[seed xor]: https://seedxor.com/
[bluewallet ldk tweet]: https://twitter.com/bluewalletio/status/1414908931902779394
[ldk github]: https://github.com/lightningdevkit
[series preparing for taproot]: /zh/preparing-for-taproot/
