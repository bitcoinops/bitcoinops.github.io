---
title: 'Bitcoin Optech Newsletter #67'
permalink: /zh/newsletters/2019/10/09/
name: 2019-10-09-newsletter-zh
slug: 2019-10-09-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 请求帮助测试 Bitcoin Core 和 LND 的候选版本，跟踪关于提议的 noinput 和 anyprevout sighash 标志的持续讨论，并描述了几个值得注意的比特币基础设施项目的更改。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--help-test-bitcoin-core-0-19-0rc1-->****帮助测试 Bitcoin Core 0.19.0rc1：** 强烈鼓励 Bitcoin Core 的生产用户测试此[最新的候选版本][core 0.19.0]，以确保它满足您组织的所有需求。还请有经验的用户在测试时花些时间测试 GUI，寻找可能会对不经常参与 RC 测试的经验不足用户产生不利影响的问题。

- **<!--help-test-lnd-0-8-0-beta-rc2-->****帮助测试 LND 0.8.0-beta-rc2：** 鼓励有经验的 LND 用户[帮助测试][lnd 0.8.0-beta]下一个版本。这次测试首次可以包含创建 LND 的[可重现构建][lnd repo build]，并验证其哈希值与 LND 开发者分发的二进制文件的哈希值相同。

## 新闻

- **<!--continued-discussion-about-noinput-anyprevout-->****关于 noinput/anyprevout 的持续讨论：** 这个提议的 sighash 标志将允许闪电网络实现使用 [eltoo][]，并在 Bitcoin-dev 和 Lightning-dev 邮件列表中[再次讨论][noinput thread]。在总结之前的讨论后，Christian Decker 提出了几个问题：提案背后的想法有用吗？（回复者似乎都同意）。人们是否希望强制使用 chaperon 签名？（回复者似乎持中度反对意见）。人们是否希望强制输出标记？（回复者似乎反对，部分人强烈反对）。

  对于输出标记问题，C-Lightning 贡献者 ZmnSCPxj [提出][zmn internal tagging]了一种替代的标记机制，该机制将标记放在 taproot 承诺中，除非使用脚本路径支出，否则是不可见的。这可以允许担心 noinput 的支出方确保他们不支付给兼容 noinput 的脚本——这是输出标记背后的[最初目标][orig output tagging]——但不会因输出标记而导致隐私和可替代性的下降。几个人似乎对这个想法表现出兴趣，尽管尚不清楚他们是希望将其作为提案的一部分，还是仅仅偏好它而不是外部输出标记（正如上面所提到的，回复者普遍反对外部输出标记）。

  目前整个讨论超过 20 条消息，并引发了关于 `OP_CAT` 的[衍生讨论][cat spinoff]。希望讨论能够解决与 noinput 相关的主要未决问题，并帮助该提案走上包含在后续软分叉中的轨道。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]的一些值得注意的更改。*

- [Bitcoin Core #13716][] 增加了 `-stdinrpcpass` 和 `-stdinwalletpassphrase` 参数到 `bitcoin-cli`，允许它从标准输入缓冲区读取 RPC 或钱包密码短语，而不是作为命令行参数存储在 shell 历史记录中。读取期间标准输入的回显也被禁用，因此密码短语不会对正在观察屏幕的人可见。

- [Bitcoin Core #16884][] 切换了 RPC 接口用户（包括通过 `bitcoin-cli` 使用者）的默认地址类型，从 P2SH 包装的 P2WPKH 切换到原生 segwit (bech32) P2WPKH。此更改在主开发代码分支上，预计要到 2020 年年中发布的 Bitcoin Core 0.20.0 才会发布。然而，预计在下个月左右作为 0.19.0 一部分发布的[之前的更改][gui bech32]将切换 GUI 用户的默认地址类型，也使用 bech32 P2WPKH。

- [Bitcoin Core #16507][] 修复了一个[舍入问题][bitcoin core #16499]，其中节点会接受费率大于节点动态最低费率的交易进入其内存池，但不会将这些费率低于四舍五入到下一个 0.00001000 BTC 的交易转发给其他节点。

- [LND #3545][] 增加了代码和[文档][lnd repo doc]，允许用户创建 LND 的可重现构建。这应允许任何具有中等技术技能的人构建与 Lightning Labs 发布的二进制文件相同的二进制文件，从而确保用户运行的是经过同行评审的 LND 仓库及其依赖项的代码。

- [LND #3365][] 增加了使用 `option_static_remotekey` 承诺输出的支持，如[本节后文所述][opt static remotekey]。这种新的承诺协议在出现问题并丢失数据时特别有用。如果发生这种情况，您只需要等待您的通道对手通过支付一个直接从您的 HD 钱包派生的密钥来关闭通道。由于密钥是在没有任何附加数据（“调整”）的情况下生成的，您的钱包不需要额外的数据即可找到和使用您的资金。这是 LND 之前使用并继续理解的[数据丢失保护][data loss protection]协议的简化替代方案。

- [C-Lightning #3078][] 增加了创建和使用在 Liquid 侧链上花费 Liquid-BTC 的通道的支持。

- [C-Lightning #2803][] 增加了一个名为 `pyln` 的新 python 包，包含对闪电网络规范的部分实现。正如其[文档][pyln-proto readme]中所述，“该包用纯 python 实现了部分闪电网络协议。它仅用于协议测试和一些小工具。它不被认为足够安全，无法处理任何实际资金（请注意风险！）。”

- [C-Lightning #3062][] 使得 `plugin` 命令在请求的插件在 20 秒内未报告成功启动时返回错误。

- [BOLTs #676][] 修改了 [BOLT2][]，规定节点在验证资金交易之前不应发送 `funding_locked` 消息。这警告了未来的实现者关于导致[上周 Newsletter 中描述的漏洞][ln vuln disclosure]的问题。

- [BOLTs #642][] 允许开启通道的两个节点协商 `option_static_remotekey` 标志。如果双方都设置了此标志，他们创建的任何可以单方面花费的承诺交易（例如，强制关闭通道）必须将对方的资金支付到在初始通道开启时协商的静态地址。例如，如果 Alice 有地址 `bc1ally`，Bob 有地址 `bc1bob`，并且他们都请求了 `option_static_remotekey`，那么 Alice 可以发布到链上的任何承诺交易必须支付给 `bc1bob`，而 Bob 可以发布到链上的任何承诺交易必须支付给 `bc1ally`。如果他们中至少一方没有设置此标志，他们将回退到使用旧协议，为每笔承诺交易使用不同的支付地址，这些地址通过将远程对等方的公钥与承诺标识符组合来创建。

  始终支付相同的地址允许该地址成为客户端 HD 钱包中的正常派生地址，使用户即使丢失了除 HD 种子以外的所有状态，也能恢复资金。这被认为优于[数据丢失保护][data loss protection]协议，后者依赖于存储足够的状态以至少能够联系远程对等方并识别通道。使用 `option_static_remotekey`，可以假定远程对等方最终会厌倦等待失踪的对等方出现并单方面关闭通道，将资金放入链上的一个地址，您的 HD 钱包可以找到该地址。

{% include linkers/issues.md issues="13716,16884,16507,16499,3545,3365,3078,2803,3062,676,642" %}
[lnd repo doc]: https://github.com/lightningnetwork/lnd/blob/master/build/release/README.md
[core 0.19.0]: https://bitcoincore.org/bin/bitcoin-core-0.19.0/
[lnd 0.8.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.8.0-beta-rc2
[lnd repo build]: #lnd-3545
[noinput thread]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002176.html
[cat spinoff]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002201.html
[ln vuln disclosure]: /zh/newsletters/2019/10/02/#full-disclosure-of-fixed-vulnerabilities-affecting-multiple-ln-implementations
[data loss protection]: /zh/newsletters/2019/01/29/#fn:fn-data-loss-protect
[pyln-proto readme]: https://github.com/ElementsProject/lightning/blob/master/contrib/pyln-proto/README.md
[opt static remotekey]: #bolts-642
[zmn internal tagging]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002180.html
[gui bech32]: /zh/newsletters/2019/04/16/#bitcoin-core-15711
[orig output tagging]: /zh/newsletters/2019/02/19/#discussion-about-tagging-outputs-to-enable-restricted-features-on-spending
[eltoo]: https://blockstream.com/eltoo.pdf
