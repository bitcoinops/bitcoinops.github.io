---
title: 'Bitcoin Optech Newsletter #106'
permalink: /zh/newsletters/2020/07/15/
name: 2020-07-15-newsletter-zh
slug: 2020-07-15-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了对 BIP118 草案中 `SIGHASH_NOINPUT` 的提议更新，并总结了流行的比特币基础设施项目中的一些值得注意的更改。

## 行动项

*本周无。*

## 新闻

- **<!--bip118-update-->****BIP118 更新：** Anthony Towns [在 Bitcoin-Dev 邮件列表中发布了][towns post]一个 PR 链接，提议用 `SIGHASH_ANYPREVOUT` 和 `SIGHASH_ANYPREVOUTANYSCRIPT` 的[草案规范][anyprevout spec]替换现有的 [BIP118][] 草案中的 [SIGHASH_NOINPUT][topic sighash_anyprevout] 内容。两者的提案都描述了不需要对交易中使用的特定 UTXO（输入/前一输出）进行承诺的可选签名哈希（sighash）标志，使得可以在不知道具体花费哪个 UTXO 的情况下为交易创建签名。该功能可以被提议的 [eltoo][topic eltoo] 结算层使用，从而创建一系列交易，任何后续交易都可以花费任何之前交易的价值，从而允许在链下合约的最新状态被结算，即使较早的状态已经在链上确认。

  noinput 和 anyprevout 提案的主要区别在于，noinput 需要一种全新的 segwit 版本，而 anyprevout 则使用了提议的 [BIP342][] 规范中的 [tapscript][topic tapscript] 升级功能。提案之间的其他差异在[修订文本][anyprevout revisions]中进行了描述。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #19219][] 澄清了手动对等节点封禁和自动对等节点抑制之间的[区别][ban vs discourage]，并通过将违规对等节点的 IP 地址放入一个不可持久化的滚动布隆过滤器来减少最坏情况下的资源使用，以防止这些节点滥用 Bitcoin Core 的有限连接槽位。这些对等节点现在会被记录为 *discouraged*（抑制）而不是 *banned*（封禁），以反映在 [#14929][Bitcoin Core #14929] 中所做的更改（见 [Newsletter #32][news32 bcc14929]）。相比之下，手动封禁的对等节点将不会被接受其传入连接，它们的地址和子网会在关闭时写入 banlist.dat 并在启动时重新加载。封禁可以用来防止与间谍节点或其他破坏者的连接——尽管封禁和抑制都不能防止 DoS 攻击，因为攻击者可以轻松通过不同的 IP 地址重新连接。

  该 PR 标志着对等节点管理一系列当前和未来更改的开始。在本周的相关合并中，[#19464][Bitcoin Core #19464] 移除了 `-banscore` 配置选项，而 [#19469][Bitcoin Core #19469] 更新了 `getpeerinfo` RPC，废弃了 `banscore` 字段。目前正在开发进一步的[资源使用][cuckoo filter]改进、[传入连接优化][eviction-logic]以及对等节点管理相关的用户界面改进。

- [Bitcoin Core #19328][] 更新了 `gettxoutsetinfo` RPC，增加了一个新的 `hash_type` 参数，用于指定如何生成当前 UTXO 集的校验和。目前唯一的两个选项是 `hash_serialized_2`（自 Bitcoin Core 0.15（2017 年 9 月）以来的默认值）和 `none`（不返回校验和）。[计划][Bitcoin Core #18000]未来允许使用基于 [muhash][] 的校验和，以及一个索引，该索引将允许比目前更快地返回校验和（根据 Optech 贡献者的早期测试，不到两秒）。目前，请求 `none` 结果可以使 `gettxoutsetinfo` RPC 运行得更快，这对在每个区块后运行它的人（例如审计可花费的比特币数量）来说非常有用。有关快速 UTXO 集校验和的历史背景，请参见 Pieter Wuille 在 [2017 年的帖子][wuille rolling]。

- [Bitcoin Core #19191][] 更新了 `-whitebind` 和 `-whitelist` 配置设置，增加了一个新的 `download` 权限。当此权限应用于对等节点时，即使本地节点已达到其 `-maxuploadtarget` 最大上传限制，该对等节点仍被允许继续从本地节点下载。这使得节点能够限制提供给公共网络的数据量，而不会限制提供给同一私有网络的本地对等节点的数据量。现有的 `noban` 权限也授予具有该权限的对等节点无限的下载能力，但这可能会在未来的版本中进行更改。

- [LND #971][] 增加了对通过 `openchannel` 的新标志 `remote_max_value_in_flight_msat` 控制未结 HTLC 中最大待处理金额的支持（这些金额存在被锁定的风险）。此新标志将通过 RPC 接口和命令行提供给 LND 用户。

- [LND #4281][] 增加了一个 `--external-hosts` 命令行标志，它接受一个或多个域名列表。LND 将定期从 DNS 中轮询每个域的 IP 地址，并将 LND 正在该地址监听连接的消息进行广播。这使得使用[动态 DNS][dynamic DNS] 服务的用户可以自动更新其节点的广告 IP 地址。

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
