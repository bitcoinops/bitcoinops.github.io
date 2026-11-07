---
title: 'Bitcoin Optech Newsletter #67'
permalink: /zh/newsletters/2019/10/09/
name: 2019-10-09-newsletter-zh
slug: 2019-10-09-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 请求大家协助测试 Bitcoin Core 和 LND 的候选发布版本，跟踪围绕拟议的 noinput 与 anyprevout sighash 标志的持续讨论，并介绍热门比特币基础设施项目的若干值得注意的变更。

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## 行动项

- **<!--help-test-bitcoin-core-0-19-0rc1-->****帮助测试 Bitcoin Core 0.19.0rc1：** Bitcoin Core 的生产用户尤其应当测试这个[最新的候选发布版本][core 0.19.0]，以确保它满足你所在机构的全部需求。打算参与测试的有经验用户，也请抽一点时间试用 GUI，留意那些对平时不参加 RC 测试、经验较少的用户影响可能格外大的问题。

- **<!--help-test-lnd-0-8-0-beta-rc2-->****帮助测试 LND 0.8.0-beta-rc2：** 鼓励有经验的 LND 用户[协助测试][lnd 0.8.0-beta]下一个版本。这是有史以来第一次，测试内容可以包括为 LND 创建[可重现构建][lnd repo build]，并验证其哈希值与 LND 开发者分发的二进制文件一致。

## 新闻

- **<!--continued-discussion-about-noinput-anyprevout-->****关于 noinput/anyprevout 的持续讨论：** 拟议中的这个 sighash 标志能让 LN 实现用上 [eltoo][]；它最近又在 Bitcoin-dev 和 Lightning-dev 邮件列表上[引发讨论][noinput thread]。在回顾了此前的讨论之后，Christian Decker 提出了几个问题：提案背后的想法有用吗？（回复者似乎都认为有用。）人们希望强制使用 chaperon 签名吗？（回复者似乎温和反对。）人们希望强制输出标记吗？（回复者似乎反对，部分人强烈反对。）

  针对输出标记的问题，C-Lightning 贡献者 ZmnSCPxj [提出][zmn internal tagging]了另一种标记机制：把标记放进 taproot 承诺，这样除非走脚本路径花费，否则标记不可见。这样，担心 noinput 的付款方就能确保自己不会付款给兼容 noinput 的脚本——这正是输出标记的[初衷][orig output tagging]——同时又不会像输出标记那样损害隐私性和可替代性。有几个人似乎对这个想法感兴趣，但还看不出他们是想把它作为提案的一部分，还是只是更中意它、而不喜欢外部输出标记（如上所述，回复者普遍反对外部输出标记）。

  目前整个讨论帖已有 20 多条消息，还衍生出一场关于 `OP_CAT` 的[讨论][cat spinoff]。希望这场讨论能解决 noinput 相关的重大未决问题，让该提案重回正轨，争取被纳入后续的软分叉。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的变更。*

- [Bitcoin Core #13716][] 为 `bitcoin-cli` 新增了 `-stdinrpcpass` 和 `-stdinwalletpassphrase` 两个参数，让它可以从标准输入缓冲区读取 RPC 密码或钱包密码短语，而不必作为命令行参数、被记进 shell 历史记录。读取时标准输入的回显也被关闭，这样旁人看你的屏幕也看不到密码短语。

- [Bitcoin Core #16884][] 把 RPC 接口用户（包括通过 `bitcoin-cli` 使用的用户）的默认地址类型从 P2SH 包装的 P2WPKH 改为原生 segwit（bech32）P2WPKH。这项改动位于主开发分支上，预计要到 2020 年年中的 Bitcoin Core 0.20.0 才会发布。不过，预计在接下来一个月左右随 0.19.0 发布的[一项早先改动][gui bech32]，也会把 GUI 用户的默认地址类型切换为 bech32 P2WPKH。

- [Bitcoin Core #16507][] 修复了一个[舍入问题][bitcoin core #16499]：费率高于节点动态最低费率的交易会被节点接纳入内存池，但如果交易费率低于“把最低费率向上取整到 0.00001000 BTC 的整数倍”后的值，节点就不会把这些交易中继给对等节点。

- [LND #3545][] 新增了相应代码和[文档][lnd repo doc]，允许用户创建 LND 的可重现构建。这样一来，任何具备中等技术水平的人都能构建出与 Lightning Labs 发布的完全相同的二进制文件，从而确保用户运行的是 LND 仓库及其依赖项中经过同行评审的代码。

- [LND #3365][] 新增了对使用 `option_static_remotekey` 承诺输出的支持，详见[本节后文][opt static remotekey]。这种新的承诺协议在出了问题、数据丢失时尤其有用。一旦发生这种情况，你只需等待通道对手方关闭通道，把资金支付到一个直接由你的 HD 钱包派生的密钥上。由于该密钥生成时没有附加任何数据（即没有“微调”），你的钱包无需额外数据就能找到并花掉这笔资金。与 LND 过去使用、如今仍兼容的[数据丢失保护][data loss protection]协议相比，这是一种简化方案。

- [C-Lightning #3078][] 新增了对创建和使用通道的支持，这类通道花费 Liquid 侧链上的 Liquid-BTC。

- [C-Lightning #2803][] 新增了一个名为 `pyln` 的 Python 包，其中部分实现了 LN 规范。如其[文档][pyln-proto readme]所述：“该包用纯 Python 实现了闪电网络协议的一部分，仅供协议测试和少量辅助工具使用。我们认为它还不够安全，不足以处理任何真实资金（已经警告过你了！）。”

- [C-Lightning #3062][] 使 `plugin` 命令在请求的插件 20 秒内未报告启动成功时返回错误。

- [BOLTs #676][] 修订了 [BOLT2][]，规定节点在验证注资交易之前不应发送 `funding_locked` 消息。这样可以让后来的实现者警惕那个导致[上周 Newsletter 所述漏洞][ln vuln disclosure]的问题。

- [BOLTs #642][] 允许开通通道的两个对等节点协商 `option_static_remotekey` 标志。如果双方都设置该标志，那么他们创建的、自己可以单方面花费的承诺交易（例如强制关闭通道时用到的），必须把对方的资金支付到开通道之初协商好的静态地址。例如 Alice 的地址是 `bc1ally`、Bob 的地址是 `bc1bob`，两人都请求了 `option_static_remotekey`，那么 Alice 能发布到链上的任何承诺交易都必须支付给 `bc1bob`，Bob 能发布到链上的任何承诺交易都必须支付给 `bc1ally`。如果至少有一方没有设置该标志，双方就退回旧协议：每笔承诺交易使用不同的收款地址，这些地址由远程对等方的公钥与承诺标识符结合派生而来。

  始终支付同一个地址，意味着该地址可以是客户端 HD 钱包中正常可派生的地址，即使用户除了 HD 种子之外丢失了全部状态，也能找回资金。一般认为这优于[数据丢失保护][data loss protection]协议，因为后者得存下足够多的状态，至少能联系上远程对等方并识别出通道。有了 `option_static_remotekey`，可以设想远程对等方最终会厌倦等待一个不再上线的对等方，干脆单方面关闭通道，把资金放到链上某个你的 HD 钱包能找到的地址里。

{% include linkers/issues.md issues="13716,16884,16507,16499,3545,3365,3078,2803,3062,676,642" %}
[lnd repo doc]: https://github.com/lightningnetwork/lnd/blob/master/build/release/README.md
[core 0.19.0]: https://bitcoincore.org/bin/bitcoin-core-0.19.0/
[lnd 0.8.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.8.0-beta-rc2
[lnd repo build]: #lnd-3545
[noinput thread]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002176.html
[cat spinoff]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002201.html
[ln vuln disclosure]: /zh/newsletters/2019/10/02/#full-disclosure-of-fixed-vulnerabilities-affecting-multiple-ln-implementations
[data loss protection]: /zh/newsletters/2019/01/29/#fn:fn-data-loss-protect
[pyln-proto readme]: https://github.com/ElementsProject/lightning/blob/master/contrib/pyln-proto/README.md
[opt static remotekey]: #bolts-642
[zmn internal tagging]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-October/002180.html
[gui bech32]: /zh/newsletters/2019/04/16/#bitcoin-core-15711
[orig output tagging]: /zh/newsletters/2019/02/19/#discussion-about-tagging-outputs-to-enable-restricted-features-on-spending
[eltoo]: https://blockstream.com/eltoo.pdf
