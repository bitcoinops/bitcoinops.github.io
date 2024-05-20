---
title: "Bitcoin Optech Newsletter #23"
permalink: /zh/newsletters/2018/11/27/
name: 2018-11-27-newsletter-zh
slug: 2018-11-27-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 提供了关于可能的手续费率增加的提醒，总结了为伴随 BIP118 `SIGHASH_NOINPUT_UNSAFE` 的 sighash 标志改进的建议，并简要描述了简化 LN 承诺交易手续费增加的提案。同时还包括来自 Bitcoin Stack Exchange 的近期精选问答和热门比特币基础设施项目中值得注意的代码更改说明。

## 行动项

- **<!--monitor-feerates-->****监控手续费率：** 最近汇率的下降可能导致哈希率的适度下降以及往返于交易所的币量增加，这可能导致下周手续费率上升。除非下周哈希率出现显著的新变化，否则预计周日左右会进行难度调整，缓解最近的哈希率下降。

## 新闻

- **<!--sighash-updates-->****Sighash 更新：** Pieter Wuille 在 Bitcoin-Dev 邮件列表上启动了一个[线程][wuille sighash]，建议对未来的 segwit Sighash 进行两项补充，特别是 [BIP118][] `SIGHASH_NOINPUT_UNSAFE`。签名哈希是交易中签名所承诺的数据。通常，哈希会承诺一份正在花费的币的列表、接收币的脚本以及一些元数据——但也可以仅签署一些交易字段，以允许其他用户以你可能接受的方式更改你的交易（例如用于二层协议）。

  Wuille 建议对哈希的元数据进行两项补充。两者都是可选的，但都可以成为普通链上钱包的默认设置。首先，交易费包含在哈希中，以允许硬件钱包或离线钱包确保它们不会被欺骗向矿工发送过多的费用。其次，所花费币的 scriptPubKey 也包含在哈希中——这也有助于确保硬件钱包和离线钱包通过消除当前的一个歧义来提高安全性，即被花费的脚本是 scriptPubKey、P2SH redeemScript 还是 segwit witnessScript。

- **<!--simplified-fee-bumping-for-ln-->****简化的 LN 手续费提升：** 支付通道中的资金部分受一个多签合同保护，该合同要求双方签署通道可以关闭的任何状态。尽管这提供了无信任的安全性，但它也有一个不受欢迎的副作用与交易费有关——各方可能会在通道实际关闭前数周或数月签署通道状态，这意味着他们必须提前很长时间猜测交易费。

  Rusty Russell 已向 BOLT 存储库提交了一个[PR][simple commit PR]并启动了一个邮件列表[线程][simple commit thread]，以征求对修改某些 LN 交易的构建和签名的提案的反馈，以允许 [BIP125][] 费用替换（RBF）和子支付父（CPFP）费用提升。在一封[后续邮件][corallo simple commit]中，Matt Corallo 表示该提案可能依赖于对节点用于中继未确认交易的方法和策略进行一些更改。

## Bitcoin Stack Exchange 精选问答

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选之一——或者在我们有空时帮助回答其他人的问题。在这个月度特色中，我们重点介绍了自上次更新以来投票最高的一些问题和答案。*

- **<!--how-could-you-create-a-fake-signature-to-pretend-to-be-satoshi-->**[如何创建假签名假装是中本聪？][bse 81115] Gregory Maxwell 提出并回答了一个问题，关于你如何创建一个看起来像与任意公钥（如已知属于中本聪的公钥）对应的 ECDSA 签名的值——但没有访问私钥。Maxwell 解释说这很容易——如果你能让人们跳过部分验证程序。

- **<!--how-to-encrypted-a-message-using-a-bitcoin-keypair-->**[如何使用比特币密钥对加密消息？][bse 80640] Pieter Wuille 和 Gregory Maxwell 分别回答了一个问题，关于使用比特币私钥和公钥进行加密，而不是它们通常用于签名和验证。Wuille 的答案提供了完成此操作的机制的细节，但两个答案都警告用户尝试使用比特币的密钥和工具进行非加密用途的危险。

- **<!--what-is-transaction-pinning-->**[什么是交易固定？][bse 80804] John Newbery 提出并回答了一个关于术语*交易固定*的问题。他的定义描述了一种方法，使得即使是一个小交易的手续费提升也变得过于昂贵，尽管它信号了选择性手续费替换（RBF）。（交易固定可能会为 LN 等协议带来问题，因为这些协议的安全性取决于某些交易在特定时间内确认。）

- **<!--what-makes-batch-verification-of-schnorr-signatures-effective-->**[是什么使得 Schnorr 签名的批量验证有效？][bse 80702] Pieter Wuille 提供了一个简单的解释，说明如何在椭圆曲线上同时进行几次乘法运算。这可能比按顺序进行单次乘法快得多，允许多个签名一起验证比单独验证更快。

## 值得注意的代码更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-lightning][core lightning repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码更改。*

- [Bitcoin Core #14708][] 在 `bitcoin.conf` 配置文件中使用未识别的部分名称时打印警告。例如，如果你使用 `testnet` 而不是正确名称 `test` 创建以下配置文件，Bitcoin Core 以前会默默忽略 testnet 选项。这个合并的 PR 会使其打印通知：“警告：部分 [testnet] 未被识别。”

  ```toml
  [testnet]
  txindex = 1
  ```
- [C-Lightning #2087][] 为 `getinfo` RPC 的结果添加了新字段，用于节点的对等数、待处理通道数、活动通道数和非活动通道数。这现在与 LND 的 `getinfo` RPC 显示的信息相匹配。

- [C-Lightning #2096][] 在尝试处理 [BOLT11][] 发票之前去除前缀 `lightning:` 文本。这段文本有时会添加，以便 LN 钱包可以注册为 URI 处理程序。前缀文本将根据 [BIP173][] bech32 规范被剥离，如果它全部是小写或大写（但不是混合大小写）。

- [C-Lightning #2081][] 和 [#2092][c-lightning #2092] 修复了并行运行多个 RPC 命令的问题。作为用户可见的更改，`lightningd` 现在在 RPC 的最终输出中添加双换行符（`\n\n`）而不是单换行符。由于单换行符可能在 RPC 输出的其他地方使用，终止时使用双换行符使非 JSON 解析器容易找到一个 RPC 调用结果的结束和下一个调用结果的开始（当相同的套接字用于两者时）。

- [Bitcoin Core #14756][] 添加了 `rpcauth.py` 脚本接受标准输入而不是可能存储在 shell 历史记录中的命令行参数密码的能力。该脚本是生成 RPC 访问登录凭据的首选方式，当不使用 `bitcoin-cli` 作为启动 `bitcoind` 守护进程的同一用户时。

- [Bitcoin Core #14532][] 更改了用于绑定 Bitcoin Core RPC 端口到默认（localhost）以外的任何设置。以前，使用 `-rpcallowip` 配置选项会导致 Bitcoin Core 监听所有接口（尽管仍然只接受来自允许 IP 地址的连接）；现在，还需要传递 `-rpcbind` 配置选项来指定监听地址。对于不太可能的配置和关于在不受信任网络上监听的危险的新警告，将打印新警告。希望此更改将有助于减少在公共接口上监听 RPC 连接的节点数量，其危险性在 [Newsletter #18][] 的*新闻*部分进行了描述。

- [C-Lightning #2095][] 在发现 C-Lightning 未遵守 [BOLT2][] 限制后，强制执行通道和支付价值的最大金额。未来的更改可能会支持一个可选的 wumbo 位（巨型位），允许节点协商超大通道和支付金额。


{% include references.md %}
{% include linkers/issues.md issues="14708,2087,2096,2081,2092,14756,14532,2095" %}

{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[bse 81115]: {{bse}}81115
[bse 80640]: {{bse}}80640
[bse 80804]: {{bse}}80804
[bse 80702]: {{bse}}80702

[wuille sighash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016488.html
[simple commit PR]: https://github.com/lightningnetwork/lightning-rfc/pull/513
[simple commit thread]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001643.html
[corallo simple commit]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001666.html
[newsletter #18]: /zh/newsletters/2018/10/23/#over-1-100-listening-nodes-have-open-rpc-ports