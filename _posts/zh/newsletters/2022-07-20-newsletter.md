---
title: 'Bitcoin Optech Newsletter #209'
permalink: /zh/newsletters/2022/07/20/
name: 2022-07-20-newsletter-zh
slug: 2022-07-20-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报总结了多个关于提供长期可持续的区块奖励的讨论。此外还有我们的常规部分：客户端和服务的新功能、软件的新版本和候选版本，以及流行的比特币基础设施软件的重大变更总结。

## 新闻

- **<!--longterm-block-reward-ongoing-discussion-->关于长期区块奖励的持续讨论**：延续了关于比特币的区块补贴持续缩减的远景下如何可靠给 PoW 支付的问题，Bitcoin-Dev 邮件组中出现了两个新帖子：

  - “[<!--tail-emission-is-not-inflationary-->残币回收并非通胀][todd tail]” 从 Peter Todd 的一个论点出发。他认为，永续地使用新创建的比特币给矿工支付并不会导致流通中的比特币数量永远增加。相反，他认为每年都有一些比特币是永远丢失了的，所以，最终来说，比特币丢失的速度将与新增比特币的速度趋同，从而产生一个大体稳定的流通数量。他也指出，为比特币加入一种永续的区块补贴需要硬分叉。许多人都在 BitcoinTalk 论坛上给[关于这份邮件的帖子][talk tail]回复；我们将仅尝试总结几个我们认为最令人印象深刻的回复。

    - *<!--hard-fork-not-required-->不需要硬分叉*：Vjudeu [指出][vjudeu sf]，只需要软分叉，就可以通过产生面值为 0 但具有特殊含义的输出，来创造新的比特币。举个例子，当一个支持该软分叉的节点看到了一个 0 聪的输出时，它会通过检查交易的另一部分来知晓真正被转移的价值。这就创造了两种比特币，但可以假设这样的软分叉也可以提供一种机制来将 “传统的比特币” 转成 “修改后的比特币”。Vjudeu 还指出，相同的机制也可以用来实现隐私强化型比特币的数量盲化（例如：使用[机密交易][confidential transactions]）。

    - *<!--no-reason-to-believe-perpetual-issuance-is-sufficient-->没有理由这样的永续发行已然足够*：Anthony Towns 在邮件组中[发帖][towns pi]（Gregory Maxwell 也在 BitcoinTalk 论坛中 [发帖][maxwell pi]）指出，没有理由认为，给矿工支付匹配平均丢币速度的数量就能提供足够的 PoW 安全性；当然，这也有可能是过度支付。如果永续发行并不能保证安全性，而且它很有可能会带来额外的问题，那似乎不如保持有限的补贴 —— 虽然它也无法保证安全性 —— 至少它不会产生额外的问题，而且已经被所有比特币人接受了（无论是显性地还是隐性地）。

      Maxwell 进一步指出，平均而言，比特币矿工仅通过交易手续费一项所收取的价值，就已经比许多替代币的补贴、手续费和其它激励机制的总和要高得多。这些替代币都没有遭受基础性的 PoW 攻击，暗示着 *也许* 光交易手续费就已经足以让比特币保持安全性。简而言之，比特币也许已经越过了那个需要区块补贴来获得足够安全性的临界点。（虽然在当前，补贴也提供了其它好处，正如 Bram Cohen 的帖子总结的那样。下文将有述）。

      Towns 指出，Peter Todd 的结论基于比特币有一个恒定的平均每年丢币速率，但这跟 Towns 认为的系统层目标 —— 尽可能减少丢币 —— 是相矛盾的。与之相关的是，Maxwell 描述了如何可以完全消除丢币：允许所有人自动选择使用一种脚本，当这些币很长时间 —— 假设是 120 年，远远超过最初的所有者及其继承人的预期寿命 —— 没有人动用时，就自动捐出去。

    - *<!--censorship-resistance-->抗审查性*：开发者 ZmnSCPxj [延伸了][zmnscpxj cr] Eric Voskuil 提出的一种观点：交易手续费强化了比特币的抗审查性。举个例子，如果 90% 的矿工收入都来自于区块补贴，而 10% 来自于手续费，则一个搞审查的矿工会损失的收入直接就是 10%。但如果 90% 的收入都来自于手续费，而 10% 来自补贴，则矿工可以损失的收入高达 90% —— 这是一种强大的多的避免审查的激励。

      Peter Todde [反驳][todd cr] 这种观点道：永续发行将比 “微不足道的交易手续费” 给 PoW 安全性筹集更多的收入，而更高的收入将提高攻击者为促动矿工审查交易而需支付的费用。

  - “[<!--fee-sniping-->手续费狙击][cohen fs]”：Bram Cohen 发帖提到关于[手续费狙击][topic fee sniping]的问题，并提出保持交易手续费占总收入的 10% （剩下的都是区块补贴）是一种可能的解决方案。他简单列举了其它一些解决方案，不过其他人提供了包含细节的额外建议。

    - *<!--paying-fees-forward-->支付远期手续费*：Russell O'Connor [转发][oconnor forward fees]了一个老想法：矿工可以计算自己能够从交易池排在最前面的交易中收取的手续费最大值，而不会激励手续费狙击。他们可以向下一个矿工支付额外的手续费作为贿赂，激励其他矿工以合作而非竞争的方式构筑下一个区块。参与者们讨论了[这个][towns ff]想法的[许多][oconnor ff2]版本，但 Peter Todd [指出][todd centralizing]这种技术的一个根本问题在于，更小的矿工必须比大矿工支付更高的贿赂，这样的规模经济会导致比特币挖矿进一步中心化。

    - *<!--improving-market-design-->优化市场设计*：Anthony Towns [提出][towns market design]，优化比特币软件和用户处理流程可以显著地平滑化手续费（even out fees），让手续费狙击更不可能发生。但他进一步指出，除了 “对抗一些盲目恐慌情绪” 以外，这似乎不是一个重大的优先事项。

## 服务和客户端软件的变更

*在这个每月一次的栏目中，我们会突出比特币钱包和服务领域的有趣升级。*

- **<!--lnpbp-release-storm-beta-software-->LNP/BP 放出 Storm 软件的 Beta 版本**：LNP/BP 标准化协会[发布了][lnpbp tweet] [Storm][storm github] 的 Beta 版本；这是一个使用闪电网络的通讯和存储协议。

- **<!--robinhood-supports-bech32-->Robinhood 支持 bech32 地址**：交易所 Robinhood 支持[取款][robinhood withdrawals]到 [bech32][topic bech32] 地址。

- **<!--sphinx-announces-vls-signing-device-->Sphine 宣布支持使用 VLS 签名设备**：Sphinx 团队使用 “[可验证的闪电签名器（VLS）][vls gitlab]” [发布][sphinx vls blog] 一个硬件签名设备接口。

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。*

- [BDK 0.20.0][] 是这个开发比特币钱包的工具库的最新版本。它包含了 “ ` ElectrumBockchain ` 和描述符模板的 bug 修复，一种防范手续费狙击的新型交易构造方法，以及一种新的交易签名选择。”

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo] 和 [Lightning BOLTs][bolts repo]。*

- [Bitcoin Core #24148][] 给使用 [miniscript][topic miniscript] 语言编写的[输出脚本描述符][topic descriptors] 添加了 *观察钱包* 支持。举个例子，用户可以导入 ` wsh(and_v(v:pk(key_A),pk(key_B))) ` 开始观察对应于这个脚本的 P2WSH 输出的所有交易。预计未来会有一个 PR 支持为基于 miniscript 的描述符签名。

- [Bitcoin Core GUI #471][] 升级了图形界面，支持从一个钱包备份中恢复。此前，用户在恢复钱包时，要么需要使用命令行工具，要么只能将文件复制到特定目录。

- [LND #6722][] 支持使用兼容 [BIP340][] 的 [Schnorr 签名算法][topic schnorr signatures] 签名任意消息。带有 Schnorr 签名的消息也会被验证。

- [Rust Bitcoin #1084][] 加入了一种方法，可以根据 [BIP383][] 的定义给一组公钥排序。

{% include references.md %}
{% include linkers/issues.md v=2 issues="24148,471,6722,6724,1592,1084" %}

[bdk 0.20.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.20.0
[todd tail]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020665.html
[talk tail]: https://bitcointalk.org/index.php?topic=5405755.0
[vjudeu sf]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020684.html
[confidential transactions]: https://en.bitcoin.it/wiki/Confidential_transactions
[towns pi]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020693.html
[maxwell pi]: https://bitcointalk.org/index.php?topic=5405755.0
[zmnscpxj cr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020678.html
[voskuil cr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020676.html
[todd cr]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020688.html
[cohen fs]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020702.html
[oconnor forward fees]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020704.html
[oconnor ff2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020719.html
[towns ff]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020735.html
[todd centralizing]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020705.html
[towns market design]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020716.html
[lnpbp tweet]: https://twitter.com/lnp_bp/status/1545366480593846275
[storm github]: https://github.com/Storm-WG
[robinhood withdrawals]: https://robinhood.com/us/en/support/articles/cryptocurrency-wallets/#Supportedaddressformatsforcryptowithdrawals
[sphinx vls blog]: https://sphinx.chat/2022/06/27/a-lightning-nodes-problem-with-hats/
[vls gitlab]: https://gitlab.com/lightning-signer/docs
