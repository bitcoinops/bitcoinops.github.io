---
title: 'Bitcoin Optech Newsletter #106'
permalink: /zh/newsletters/2020/07/15/
name: 2020-07-15-newsletter-zh
slug: 2020-07-15-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了对 BIP118 草案中 `SIGHASH_NOINPUT` 的一项拟议更新，并总结了热门比特币基础设施项目的值得注意的变更。

## 行动项

*本周无。*

## 新闻

- **<!--bip118-update-->****BIP118 更新：** Anthony Towns [在 Bitcoin-Dev 邮件列表上发帖][towns post]，给出一个 PR 的链接：该 PR 提议用 `SIGHASH_ANYPREVOUT` 和 `SIGHASH_ANYPREVOUTANYSCRIPT` 的[草案规范][anyprevout spec]替换 [BIP118][] 草案中 [SIGHASH_NOINPUT][topic sighash_anyprevout] 的现有文本。两份提案都描述了一些可选的签名哈希（sighash）标志，它们不承诺交易中具体花费哪些 UTXO（输入/前序输出），从而让人可以在尚不知道会花费哪个 UTXO 的情况下为交易创建签名。拟议的 [eltoo][topic eltoo] 结算层就能用上这一特性：它可以创建一串交易，让后面的任一交易都能花费之前任一交易的金额，于是链下合约即使早期状态已在链上确认，也能按最新状态结算。

  noinput 与 anyprevout 两份提案的主要区别在于：noinput 需要自己的一个全新 segwit 版本，而 anyprevout 复用了拟议的 [BIP342][]（[tapscript][topic tapscript] 规范）中的一项升级特性。两份提案的其他差异在[修订后的文本][anyprevout revisions]中说明。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi]、[比特币改进提案（BIPs）][bips repo]和[闪电网络 BOLT 规范][bolts repo]中的值得注意的变更。*

- [Bitcoin Core #19219][] 澄清了手动封禁对等节点与自动抑制对等节点之间的[区别][ban vs discourage]，并把行为不当的对等节点 IP 地址放入一个不持久化的滚动布隆过滤器，阻止它们滥用 Bitcoin Core 有限的连接槽位，从而降低最坏情况下的资源占用。这类对等节点现在被记为 *discouraged*（抑制），而不再是 *banned*（封禁），以反映 [#14929][Bitcoin Core #14929] 中的改动（见 [Newsletter #32][news32 bcc14929]）。相比之下，节点绝不会接受来自手动封禁对等节点的入站连接，这些对等节点的地址和子网会在关闭时写入 banlist.dat，并在启动时重新加载。封禁可用于避免与间谍节点或其他恶意骚扰者建立连接——不过封禁和抑制都挡不住 DoS 攻击，因为攻击者换个 IP 地址重连是轻而易举的事。

  该 PR 是一系列针对对等节点管理的现有与未来改动中的第一项。在本周的相关合并中，[#19464][Bitcoin Core #19464] 移除了 `-banscore` 配置选项，[#19469][Bitcoin Core #19469] 更新 `getpeerinfo` RPC，弃用了 `banscore` 字段。针对[资源占用][cuckoo filter]、[入站连接优化][eviction-logic] 以及对等节点管理相关界面的进一步改进，目前正在开发中。

- [Bitcoin Core #19328][] 更新了 `gettxoutsetinfo` RPC，新增 `hash_type` 参数，用于指定如何生成当前 UTXO 集的校验和。目前只有两个选项：`hash_serialized_2` 生成一个自 Bitcoin Core 0.15（2017 年 9 月）起一直作为默认值的校验和，`none` 则不返回校验和。[计划][Bitcoin Core #18000] 将来支持基于 [muhash][] 的校验和，并配合一个索引，使校验和返回速度比现在快得多（据 Optech 贡献者的早期测试，可不到两秒）。眼下，请求 `none` 结果能让 `gettxoutsetinfo` RPC 跑得快很多，这对每个区块后都要运行它的人（例如审计可花费的比特币数量）很有用。关于快速 UTXO 集校验和的历史背景，可参见 Pieter Wuille 的[这篇 2017 年文章][wuille rolling]。

- [Bitcoin Core #19191][] 为 `-whitebind` 和 `-whitelist` 配置项新增了 `download` 权限。当某个对等节点被赋予该权限后，即使本地节点已达到 `-maxuploadtarget` 上传上限，它仍可从本地节点继续下载。这样，节点就能方便地限制向公共网络提供的数据量，而不限制向同一私有网络内本地对等节点提供的数据量。现有的 `noban` 权限同样会给持有该权限的对等节点无限下载能力，但这一点可能会在未来版本中改动。

- [LND #971][] 新增了一项能力：通过 `openchannel` 的新标志 `remote_max_value_in_flight_msat`，控制尚未结算的 HTLC 中待处理金额的上限（这些金额有被锁住的风险）。该新标志将通过 RPC 接口和命令行两种方式提供给 LND 用户。

- [LND #4281][] 新增 `--external-hosts` 命令行标志，接受一个或多个域名构成的列表。LND 会定期向 DNS 查询每个域名的 IP 地址，并对外宣告自己正在该地址上监听连接。这让使用[动态 DNS][dynamic dns] 服务的用户可以自动更新节点对外公布的 IP 地址。

{% include references.md %}
{% include linkers/issues.md issues="19219,14929,19464,19469,19328,19191,971,4281,18000" %}
[dynamic dns]: https://en.wikipedia.org/wiki/Dynamic_DNS
[towns post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-July/018038.html
[anyprevout spec]: https://github.com/ajtowns/bips/blob/bip-anyprevout/bip-0118.mediawiki
[anyprevout revisions]: https://github.com/ajtowns/bips/blob/bip-anyprevout/bip-0118.mediawiki#revisions
[wuille rolling]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-May/014337.html
[muhash]: https://cseweb.ucsd.edu/~mihir/papers/inchash.pdf
[bitcoin core 0.15]: https://bitcoincore.org/en/releases/0.15.0/#low-level-rpc-changes
[cuckoo filter]: https://github.com/bitcoin/bitcoin/pull/19219#issuecomment-652685715
[eviction-logic]: https://github.com/bitcoin/bitcoin/issues/19500#issuecomment-657257874
[news32 bcc14929]: /zh/newsletters/2019/02/05/#bitcoin-core-14929
[ban vs discourage]: https://github.com/bitcoin/bitcoin/blob/f4de89edfa8be4501534fec0c662c650a4ce7ef2/src/banman.h#L29-L55
[hwi]: https://github.com/bitcoin-core/HWI
