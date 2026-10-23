---
title: 'Bitcoin Optech Newsletter #177'
permalink: /zh/newsletters/2021/12/01/
name: 2021-12-01-newsletter-zh
slug: 2021-12-01-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 描述了不同 LN 软件之间一个近期修复的互操作性问题，并包含常规栏目：新版本与候选版本列表，以及热门比特币基础设施软件的值得注意的变更。

## 新闻

- **<!--ln-reliability-versus-fee-parameterization-->****LN 互操作性：** 此前 [Newsletter #165][news165 bolts880] 描述的 LN 规范变更，被不同的 LN 节点以不同方式实现，导致运行最新版 LND 的节点无法与运行最新版 C-Lightning 和 Eclair 的节点开设新通道。建议 LND 用户升级到修复版本 0.14.1（详见下文*发布与候选发布*章节）。

  围绕改进互操作性测试，Lightning-Dev 邮件列表上展开了一场[相关讨论][xraid interop]。此前创建并维护 LN [集成测试框架][ln integration]的 Christian Decker [表示][decker interop]，基础的互操作性测试“除了最严重的问题之外，恐怕什么也发现不了”。参与讨论的 LN 开发者[指出][zmn interop]，正因为要发现这类 bug，每个主流实现才会提供候选版本（RC），也正因如此，我们才鼓励专家用户和生产系统的管理员参与这些 RC 的测试。

  有意参与这类测试的人，可以在 Optech Newsletter 中找到四个主要 LN 实现以及其他多种比特币软件的 RC。这里讨论的 LND 版本，曾分别在 [Newsletter #174][news174 lnd] 和 [Newsletter #175][news175 lnd] 中作为 RC 列出。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LND 0.14.1-beta][] 是维护版本，修复了上文*新闻*章节以及下文*值得注意的变更*章节中对 [LND #6026][] 的描述里更详细介绍的那个问题。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo] 的值得注意的变更。*

- [Bitcoin Core #16807][] 更新地址验证逻辑，通过 [Newsletter #41][news41 bech32 error detection] 描述的机制，返回 [bech32 和 bech32m][topic bech32] 地址中可能是拼写错误的位置。当替换错误不超过两处时，可以准确定位这些拼写错误。该 PR 还提高了测试覆盖率，为地址验证代码补充了更多文档，并改进了解码失败时的错误信息，尤其是用于区分 bech32 和 bech32m 的使用。

- [Bitcoin Core #22364][] 新增为 [taproot][bip386] 创建[输出脚本描述符][topic descriptors]的支持。这样钱包用户只要用自己的钱包生成默认的 bech32m 描述符，就能生成并使用 P2TR 地址，而无需导入描述符。

- [LND #6026][] 修复了 [BOLTs #880][] 显式通道类型协商的[实现][lnd #5669]问题（见 [Newsletter #165][news165 bolts880]）。LN 规范的一项[提议变更][bolts #906]将使 LND 最终能够实现严格的显式协商。

- [Rust-Lightning #1176][] 新增对[锚定输出][topic anchor outputs]式手续费追加的初步支持。至此，我们覆盖的全部四个 LN 实现都已实现锚定输出支持。

- [HWI #475][] 新增对 [Blockstream Jade][news132 jade] 硬件签名器的[支持][hwi support matrix]，并使用 [QEMU 模拟器][qemu website]进行了测试。

{% include references.md %}
{% include linkers/issues.md issues="16807,22364,6026,5669,880,906,1176,475,6026" %}
[lnd 0.14.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.1-beta
[news165 bolts880]: /zh/newsletters/2021/09/08/#bolts-880
[xraid interop]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-November/003354.html
[decker interop]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-November/003358.html
[zmn interop]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-November/003365.html
[ln integration]: https://cdecker.github.io/lightning-integration/
[news174 lnd]: /zh/newsletters/2021/11/10/#lnd-0-14-0-beta-rc3
[news175 lnd]: /zh/newsletters/2021/11/17/#lnd-0-14-0-beta-rc4
[hwi support matrix]: https://hwi.readthedocs.io/en/latest/devices/index.html#support-matrix
[news132 jade]: /zh/newsletters/2021/01/20/#blockstream-announces-jade-hardware-wallet
[qemu website]: https://www.qemu.org/
[news41 bech32 error detection]: /zh/bech32-sending-support/#查找-bech32-地址中的拼写错误
