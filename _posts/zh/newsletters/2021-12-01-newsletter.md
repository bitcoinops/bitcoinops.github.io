---
title: 'Bitcoin Optech Newsletter #177'
permalink: /zh/newsletters/2021/12/01/
name: 2021-12-01-newsletter-zh
slug: 2021-12-01-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周 Newsletter 描述了近期闪电网络不同实现间的互操作性修复方案，并包含常规的新版本发布与候选版本信息，以及热门比特币基础设施软件的重要更新。

## 新闻

- ​**<!--ln-reliability-versus-fee-parameterization-->****闪电网络互操作性问题：** 此前 [Newsletter #165][news165 bolts880] 描述的 LN 规范变更在不同实现中存在差异，导致最新版 LND 节点无法与 C-Lightning 和 Eclair 最新版建立通道。建议 LND 用户升级至 0.14.1 修复版本（详见下文*发布与候选发布*章节）。

  围绕提升互操作性测试，Lightning-Dev 邮件列表展开[相关讨论][xraid interop]。曾开发 LN [集成测试框架][ln integration]的 Christian Decker [表示][decker interop]基础测试"仅能捕获最严重的问题"。参与讨论的开发者[指出][zmn interop]，此类问题的发现需要依赖各主要实现提供候选版本（RCs），并鼓励专家用户参与测试。

  有意参与测试的用户可关注 Optech Newsletter 列出的四个主要 LN 实现候选版本。本次涉及 LND 版本的 RC 信息曾发布于 [Newsletter #174][news174 lnd] 和 [Newsletter #175][news175 lnd]。

## 发布与候选发布

*新版本发布与候选版本：*

- [LND 0.14.1-beta][] 维护版本修复上文描述的互操作性问题，详细技术细节可参考下文 [LND #6026][] 变更说明。

## 重要代码与文档变更

*本周重要代码变更涉及 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]。*

- [Bitcoin Core #16807][] 升级地址验证功能，通过 [Newsletter #41][news41 bech32 error detection] 描述的机制返回 [bech32 和 bech32m][topic bech32] 地址可能的拼写错误位置。当错误不超过两处时可准确定位。本次更新还增强测试覆盖、完善文档，并优化解码失败的报错信息（特别是区分 bech32 与 bech32m）。

- [Bitcoin Core #22364][] 新增对 [Taproot][bip386] [描述符][topic descriptors]的创建支持，用户现在可通过生成默认 bech32m 描述符直接使用 P2TR 地址，无需手动导入。

- [LND #6026][] 修复 [BOLTs #880][] 明确通道类型协商（参见 [Newsletter #165][news165 bolts880]）的[实现问题][lnd #5669]。LN 规范[提议变更][bolts #906]将允许 LND 最终实现严格协商机制。

- [Rust-Lightning #1176][] 新增对[锚定输出][topic anchor outputs]式手续费追加的初步支持。至此，四大主流 LN 实现均已支持锚定输出功能。

- [HWI #475][] 新增对 [Blockstream Jade][news132 jade] 硬件签名设备的支持，测试中使用了 [QEMU 模拟器][qemu website]。

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
