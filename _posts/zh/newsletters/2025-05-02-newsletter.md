---
title: 'Bitcoin Optech Newsletter #352'
permalink: /zh/newsletters/2025/05/02/
name: 2025-05-02-newsletter-zh
slug: 2025-05-02-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报链接到了不同族群线性化技术的比较，并简要总结了关于增加或移除 Bitcoin Core `OP_RETURN` 大小限制的讨论。此外，还包含了我们的常规栏目，宣布新版本和候选版本，并总结了热门比特币基础设施软件的显著变更。

## 新闻

- **<!--comparison-of-cluster-linearization-techniques-->族群线性化技术比较：**
  Pieter Wuille 在 Delving Bitcoin 上[发帖][wuille clustrade]讨论了三种不同族群线性化技术之间的一些基本权衡，随后发布了每种技术实现的[基准测试][wuille clusbench]。其他几位开发者讨论了该结果，并提出了用于澄清的问题，Wuille 对此做出了回应。

- **<!--increasing-or-removing-bitcoin-core-s-op-return-size-limit-->****增加或移除 Bitcoin Core 的 `OP_RETURN` 大小限制：**
  在 Bitcoin-Dev 的一个帖子中，几位开发者讨论了更改或移除 Bitcoin Core 对 `OP_RETURN` 数据载体输出的默认限制。随后的一个 Bitcoin Core [拉取请求][bitcoin core #32359]引发了更多讨论。我们不会试图总结所有这些冗长的讨论，而是总结我们认为支持和反对该变更的最有说服力的论点。

  - *<!--for-increasing-or-eliminating-the-limit-->支持增加（或取消）限制的观点：* Pieter Wuille [认为][wuille opr]，交易标准化政策不太可能显著阻止资金充足的组织所创建的携带数据的交易得到确认。这些组织会努力将交易直接发送给矿工。此外，他认为无论区块是否包含携带数据的交易，区块通常都是满的，因此节点需要存储的总数据量大致相同。

  - *<!--against-increasing-the-limit-->反对增加限制的观点：* Jason Hughes [认为][hughes opr]，增加限制会更容易在运行全节点的计算机上存储任意数据，其中一些数据可能非常令人反感（包括在大多数司法管辖区是非法的）。即使用户在磁盘上加密数据（参见[周报 #316][news316 blockxor]），存储这些数据以及使用 Bitcoin Core RPC 检索这些数据的能力对许多用户来说都可能存在问题。

## 新版本和候选版本

_热门比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。_

- [LND 0.19.0-beta.rc3][] 是这款热门闪电网络节点的候选版本。其中一项可能需要测试的主要改进是合作关闭通道的场景中新的基于 RBF 手续费提升机制。

## 代码和文档的显著变更

_近期在 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案 (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 中的显著变更。_

- [Bitcoin Core #31250][] 禁止了旧版钱包的创建和加载，完成了向[描述符][topic descriptors]钱包的迁移，描述符钱包自 2021 年 10 月以来一直是默认选项（参见[周报 #172][news172 descriptors]）。旧版钱包使用的 Berkeley DB 文件无法再加载，所有针对旧版钱包的单元测试和功能测试均已删除。部分旧版钱包代码仍然存在，但将在后续的 PR 中移除。Bitcoin Core 仍然能够将旧版钱包迁移到新的描述符钱包格式（参见[周报 #305][news305 bdbro]）。

- [Eclair #3064][] 通过引入 `ChannelKeys` 类重构了通道密钥管理。现在每个通道都有自己的 `ChannelKeys` 对象，该对象与承诺点一起派生出用于签名远程/本地承诺和 [HTLC][topic htlc] 交易的 `CommitmentKeys` 集合。强制关闭逻辑和脚本/见证创建也更新为依赖 `CommitmentKeys`。以前，密钥生成分散在代码库的多个部分以支持外部签名器，这很容易出错，因为它依赖于命名而不是类型来确保提供正确的公钥。

- [BTCPay Server #6684][] 添加了对 [BIP388][] 钱包策略[描述符][topic descriptors]子集的支持，允许用户导入和导出单签名和 k-of-n 策略。它包括 Sparrow 支持的格式，如 P2PKH、P2WPKH、P2SH-P2WPKH 和 P2TR，以及相应的多重签名变体（P2TR 除外）。此 PR 的预期目标是改进多重签名钱包的使用。

- [BIPs #1555][] 合并了 [BIP321][]，该提案提出了一种用于描述比特币支付指令的 URI 方案，该方案对 [BIP21][] 进行了现代化和扩展。它保留了基于路径的旧版地址，但通过使新的支付方式可通过其自身的参数进行识别来标准化查询参数的使用，并允许在至少一个指令出现在查询参数中时将地址字段留空。它增加了一个可选扩展，用于向花费者提供支付证明，并提供了有关如何整合新支付指令的指南。

{% include snippets/recap-ad.md when="2025-05-06 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31250,3064,6684,1555,32359" %}
[lnd 0.19.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc3
[wuille clustrade]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/68
[wuille clusbench]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/73
[hughes opr]: https://mailing-list.bitcoindevs.xyz/bitcoindev/f4f6831a-d6b8-4f32-8a4e-c0669cc0a7b8n@googlegroups.com/
[wuille opr]: https://mailing-list.bitcoindevs.xyz/bitcoindev/QMywWcEgJgWmiQzASR17Dt42oLGgG-t3bkf0vzGemDVNVnvVaD64eM34nOQHlBLv8nDmeBEyTXvBUkM2hZEfjwMTrzzoLl1_62MYPz8ZThs=@wuille.net/
[news316 blockxor]: /zh/newsletters/2024/08/16/#bitcoin-core-28052
[news172 descriptors]: /zh/newsletters/2021/10/27/#bitcoin-core-23002
[news305 bdbro]: /zh/newsletters/2024/05/31/#bitcoin-core-26606
