---
title: 'Bitcoin Optech Newsletter #93'
permalink: /zh/newsletters/2020/04/15/
name: 2020-04-15-newsletter-zh
slug: 2020-04-15-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了一个创建统一多钱包备份的提议，该提议旨在规避许多支持确定性密钥派生的钱包无法导入 BIP32 扩展私钥的问题。还包括我们的常规部分，描述了发布候选版本和流行的比特币基础设施软件的更改。

## 行动项

*本周无。*

## 新闻

- **<!--proposal-for-using-one-bip32-keychain-to-seed-multiple-child-keychains-->****使用一个 BIP32 密钥链为多个子密钥链生成种子的提议：**几周前，Ethan Kosakovsky 在 Bitcoin-Dev 邮件列表中[发布][kosakovsky post]了一个[提议][kosakovsky proposal]，该提议使用一个 [BIP32][] 分层确定性 (HD) 密钥链生成子 HD 密钥链的种子，这些子密钥链可以用于不同的场景。鉴于 BIP32 已经提供可以在签名钱包之间共享的扩展私钥 (xprv)，这可能看起来是不必要的。问题在于，许多钱包并未实现导入 xprv 的功能——它们只允许导入 HD 种子或一些前置数据，这些数据会被转换为种子（例如 [BIP39][] 或 [SLIP39][] 种子词）。

  Kosakovsky 的提议是创建一个超级密钥链，其子密钥将被转换为种子、种子词或其他数据，这些数据可以输入到各种钱包的 HD 密钥链恢复字段中。这样，拥有多个钱包的用户可以仅使用超级密钥链的种子（加上派生路径和将确定性熵转换为输入数据的库）备份所有钱包。

  {% assign img="/img/posts/2020-04-subkeychains.dot.png" %}
  [![使用一个 BIP32 密钥链为子 BIP32 密钥链生成种子]({{img}})]({{img}})

  对该提议的反应不一（支持：[1][react gray], [2][react back]；反对：[1][react allen], [2][react rusnak]），但本周一家硬件钱包制造商[声明][novak post]他们打算实现对该协议的支持，并请求对该提议进行进一步审查。

## 发布与候选发布

*流行的比特币基础设施项目的新发布版本和候选发布版本。请考虑升级到新版本或帮助测试候选发布版本。*

- [Bitcoin Core 0.20.0rc1][bitcoin core 0.20.0]：下一个 Bitcoin Core 主要版本的首个候选发布版本现已供有经验的用户测试。如果您发现任何问题，请[报告][bitcoin core issue]，以便在最终发布前修复。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo] 中的值得注意的更改。*

- [LND #3967][] 增加了发送[多路径支付][topic multipath payments]的支持，补充了已有的接收逻辑。此前，当 LND 无法通过单一路由承载全部金额时，它会支付失败。通过多路径支付，LND 现在可以将发票拆分为多个较小的 HTLC，每个 HTLC 可以走不同的路由，从而更好地利用 LN 中的流动性。用户可以通过 RPC 参数或命令行选项控制部分支付的最大数量。

- [LND #4075][] 允许为超过先前约 0.043 BTC 限制的支付创建发票。网络范围内的 HTLC 限制为 0.043 BTC，这会阻止超过此金额的支付通过单个通道进行。随着[本周 LND](lnd-3967) 中发送多路径支付的实现合并，发票可以为超过 0.043 BTC 的总支付金额开具，发送方可以将支付拆分为部分支付。

{% include references.md %}
{% include linkers/issues.md issues="3967,4075" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[kosakovsky post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017683.html
[kosakovsky proposal]: https://gist.github.com/ethankosakovsky/268c52f018b94bea29a6e809381c05d6
[slip39]: https://github.com/satoshilabs/slips/blob/master/slip-0039.md
[novak post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-April/017751.html
[bitcoin core issue]: https://github.com/bitcoin/bitcoin/issues/new/choose
[react gray]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017687.html
[react back]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017713.html
[react allen]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017688.html
[react rusnak]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-March/017684.html
