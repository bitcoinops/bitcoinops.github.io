---
title: 'Bitcoin Optech Newsletter #93'
permalink: /zh/newsletters/2020/04/15/
name: 2020-04-15-newsletter-zh
slug: 2020-04-15-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了一项提议：创建一套统一的多钱包备份方案，以绕开这样一个限制——许多支持确定性密钥派生的钱包无法导入 BIP32 扩展私钥。此外还有我们的常规部分：候选发布，以及热门比特币基础设施软件的变更。

## 行动项

*本周无。*

## 新闻

- **<!--proposal-for-using-one-bip32-keychain-to-seed-multiple-child-keychains-->****用一个 BIP32 密钥链为多个子密钥链生成种子的提议：** 几周前，Ethan Kosakovsky 在 Bitcoin-Dev 邮件列表中[发布][kosakovsky post]了一项[提议][kosakovsky proposal]：用一个 [BIP32][] 分层确定性（HD）密钥链，为可在不同场景中使用的子 HD 密钥链生成种子。鉴于 BIP32 已经提供可在各签名钱包之间共享的扩展私钥（xprv），这似乎有些多余。问题在于，许多钱包并没有实现导入 xprv 的功能——它们只允许导入 HD 种子，或者导入某些会被转换为种子的前置数据（例如 [BIP39][] 或 [SLIP39][] 的种子词）。

  Kosakovsky 的提议是创建一个超级密钥链，把它的子密钥转换为种子、种子词或其他数据，从而可以填入各种钱包的 HD 密钥链恢复字段。这样一来，拥有多个钱包的用户只需用超级密钥链的种子（再加上派生路径，以及把确定性熵转换为输入数据的库），就能备份全部钱包。

  {% assign img="/img/posts/2020-04-subkeychains.dot.png" %}
  [![使用一个 BIP32 密钥链为子 BIP32 密钥链生成种子]({{img}})]({{img}})

  各方对该提议的反应不一（支持：[1][react gray]、[2][react back]；反对：[1][react allen]、[2][react rusnak]），但本周一家硬件钱包制造商[表示][novak post]打算实现对这套协议的支持，并请求对该提议做进一步审查。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Bitcoin Core 0.20.0rc1][bitcoin core 0.20.0]：下一个 Bitcoin Core 主要版本的首个候选发布现已可供有经验的用户测试。如果你发现任何问题，请[报告][bitcoin core issue]，以便在最终发布前修复。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络 BOLT 规范][bolts repo] 中的值得注意的变更。*

- [LND #3967][] 新增了发送[多路径支付][topic multipath payments]的支持，与已有的接收逻辑配套。以前，如果一张发票的全部金额无法由单条路径承载，LND 就会支付失败。有了多路径支付，LND 现在可以把发票拆成多个较小的 HTLC，每个 HTLC 走不同的路径，从而更好地利用 LN 中的流动性。用户可以通过 RPC 参数或命令行选项限制部分支付的最大数量。

- [LND #4075][] 允许为金额超过此前约 0.043 BTC 上限的支付创建发票。全网的 HTLC 上限为 0.043 BTC，这使得金额超过该值的支付无法经单条通道完成。由于[本周 LND 也合并了](#lnd-3967)发送多路径支付的实现，现在可以为超过 0.043 BTC 的合计支付金额开具发票，再由发送方把它拆成多笔部分支付。

{% include references.md %}
{% include linkers/issues.md issues="3967,4075" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[kosakovsky post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017683.html
[kosakovsky proposal]: https://gist.github.com/ethankosakovsky/268c52f018b94bea29a6e809381c05d6
[slip39]: https://github.com/satoshilabs/slips/blob/master/slip-0039.md
[novak post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-April/017751.html
[bitcoin core issue]: https://github.com/bitcoin/bitcoin/issues/new/choose
[react gray]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017687.html
[react back]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017713.html
[react allen]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017688.html
[react rusnak]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017684.html
