---
title: "Bitcoin Optech Newsletter #23"
permalink: /zh/newsletters/2018/11/27/
name: 2018-11-27-newsletter-zh
slug: 2018-11-27-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 提醒读者费率可能上涨，概述了为配合 BIP118 `SIGHASH_NOINPUT_UNSAFE` 而提出的 sighash 标志改进建议，并简要介绍了一个简化 LN 承诺交易手续费追加（fee bumping）的提案。此外还包括 Bitcoin Stack Exchange 近期的精选问答，以及热门比特币基础设施项目中值得注意的代码变更说明。

## 行动项

- **<!--monitor-feerates-->****监控费率（feerate）：** 最近汇率下跌，很可能导致了哈希率小幅下降，并可能使往返交易所的币量增加，从而在下周推高费率。除非下周哈希率再出现剧烈变化，否则预计周日前后会有一次难度调整，可抵消最近哈希率下降的大部分影响。

## 新闻

- **<!--sighash-updates-->****Sighash 更新：** Pieter Wuille 在 Bitcoin-Dev 邮件列表上发起了一个[讨论帖][wuille sighash]，建议在未来改动 segwit 的 sighash 时增加两项内容，特别是针对 [BIP118][] `SIGHASH_NOINPUT_UNSAFE`。签名哈希（signature hash）是交易中签名所承诺的数据。通常，这个哈希承诺了要花费哪些币、由哪些脚本接收这些币，以及一些元数据——但也可以只签署部分交易字段，从而允许其他人以你能接受的方式修改你的交易（例如用于二层协议）。

  Wuille 建议把两类元数据也纳入哈希。两项都是可选的，但都可能成为普通链上钱包的默认行为。第一，把交易手续费纳入哈希，好让硬件钱包或离线钱包确保自己不会被骗、向矿工多付手续费。第二，把所花费币的 scriptPubKey 也纳入哈希——这同样能增强硬件钱包和离线钱包的安全性，因为它消除了目前的一处歧义：被花费的脚本究竟是 scriptPubKey、P2SH redeemScript，还是 segwit witnessScript。

- **<!--simplified-fee-bumping-for-ln-->****简化 LN 的手续费追加：** 支付通道中的资金，部分依靠一份多重签名（multisig）合约来保护：通道可能关闭的任何状态，都需要双方签名。这提供了无需信任第三方的安全性，但也带来一个与交易手续费有关的副作用——双方可能在通道实际关闭前数周或数月就签好了通道状态，这意味着他们必须提前很久猜测届时的手续费水平。

  Rusty Russell 已向 BOLT 仓库提交了一个 [PR][simple commit PR]，并在邮件列表上发起了[讨论帖][simple commit thread]，就一项提案征求意见：修改部分 LN 交易的构造与签名方式，使其既能用 [BIP125][] 手续费替换（RBF）来追加手续费，也能用子为父付（CPFP）来追加手续费。在一封[后续邮件][corallo simple commit]中，Matt Corallo 表示，该提案可能取决于节点中继未确认交易的方法与策略先做出一些改动。

## Bitcoin Stack Exchange 精选问答

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者寻找问题答案的首选去处之一，也是我们在有点空闲时帮忙回答他人问题的地方。在这个每月专栏中，我们挑出自上次更新以来得票较高的一些问题和答案。*

- **<!--how-could-you-create-a-fake-signature-to-pretend-to-be-satoshi-->**[如何伪造一个签名，冒充中本聪？][bse 81115] Gregory Maxwell 提出并回答了一个问题：如何在不掌握私钥的情况下，构造出一个看起来像是某个任意公钥（比如已知属于中本聪的公钥）对应 ECDSA 签名的值。Maxwell 解释说，这很容易——前提是你能诱使别人跳过部分验证流程。

- **<!--how-to-encrypted-a-message-using-a-bitcoin-keypair-->**[如何用比特币密钥对加密消息？][bse 80640] Pieter Wuille 和 Gregory Maxwell 分别回答了同一个问题：用比特币私钥和公钥来做加密，而不是它们通常的签名与验证用途。Wuille 的回答详细说明了实现这一点的机制，但两人的回答都提醒用户：这些密钥和工具在比特币中本是用于非加密的用途，拿它们做加密是有风险的。

- **<!--what-is-transaction-pinning-->**[什么是交易钉住（transaction pinning）？][bse 80804] John Newbery 提出并回答了关于“*交易钉住*”这个术语的问题。他的定义描述的是一种做法：即使是那些已经表示接受手续费替换（RBF）的小额交易，也会被弄得让追加手续费的成本高得不可承受。（交易钉住会给 LN 这类协议带来问题，因为这些协议的安全性取决于某些交易能否在特定时间内确认。）

- **<!--what-makes-batch-verification-of-schnorr-signatures-effective-->**[是什么让 Schnorr 签名的批量验证更高效？][bse 80702] Pieter Wuille 用简单的方式解释了为什么可以在椭圆曲线上同时进行多次乘法运算。这比串行地做单次乘法要快得多，因此把多个签名放在一起验证，比逐个验证更快。

## 值得注意的代码变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-lightning][core lightning repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码变更。*

- [Bitcoin Core #14708][] 当 `bitcoin.conf` 配置文件中出现无法识别的节（section）名时，会打印警告。例如，如果你写了下面这个配置文件，用了 `testnet` 而不是正确的 `test`，Bitcoin Core 以前会静默忽略其中的 testnet 选项；这次合并的 PR 会让它打印一条提示：“Warning: Section [testnet] is not recognized.”

  ```toml
  [testnet]
  txindex = 1
  ```
- [C-Lightning #2087][] 为 `getinfo` RPC 的返回结果增加了新字段，分别表示节点的对等节点数、待处理通道数、活跃通道数和不活跃通道数。现在这与 LND 的 `getinfo` RPC 显示的信息一致。

- [C-Lightning #2096][] 在处理 [BOLT11][] 发票之前，会先去掉前缀文本 `lightning:`。这段文本有时会被加上，以便 LN 钱包注册为处理这类 URI 的程序。按 [BIP173][] bech32 规范，只有此前缀全为小写或全为大写（不含大小写混用）时才会被剥离。

- [C-Lightning #2081][] 和 [#2092][c-lightning #2092] 修复了并行运行多条 RPC 命令时的一个问题。用户可见的变化是：`lightningd` 现在会在 RPC 的最终输出末尾添加两个换行符（`\n\n`），而不再只加一个换行符。由于 RPC 输出的其他位置也可能出现单个换行，以双换行结尾可以让非 JSON 解析器在同一个套接字先后用于两次调用时，轻松分辨前一次调用结果的结束与后一次调用结果的开始。

- [Bitcoin Core #14756][] 让 `rpcauth.py` 脚本可以从标准输入读取密码，而不必把密码作为命令行参数传入——后者可能被记进 shell 历史。当你不是以启动 `bitcoind` 守护进程的同一用户身份使用 `bitcoin-cli` 时，这个脚本是生成 RPC 登录凭据的首选方式。

- [Bitcoin Core #14532][] 修改了把 Bitcoin Core 的 RPC 端口绑定到默认地址（localhost）以外地址时所用的设置。以前，只要用了 `-rpcallowip` 配置选项，Bitcoin Core 就会监听所有网络接口（虽然仍只接受来自允许 IP 地址的连接）；现在还必须传入 `-rpcbind` 配置选项来指定监听地址。对于少见配置会打印新的警告，也会提醒用户在不受信任的网络上监听有何风险。希望这项改动有助于减少在公共接口上监听 RPC 连接的节点数量——这种做法的危险性曾在 [Newsletter #18][] 的*新闻*部分介绍过。

- [C-Lightning #2095][] 在发现 C-Lightning 并未遵守 [BOLT2][] 的限制后，开始强制执行该规范对通道金额和支付金额规定的上限。未来的改动可能会支持一个可选的 wumbo 位（巨型位），允许节点协商超大通道和支付金额。


{% include references.md %}
{% include linkers/issues.md issues="14708,2087,2096,2081,2092,14756,14532,2095" %}

{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[bse 81115]: {{bse}}81115
[bse 80640]: {{bse}}80640
[bse 80804]: {{bse}}80804
[bse 80702]: {{bse}}80702

[wuille sighash]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016488.html
[simple commit PR]: https://github.com/lightningnetwork/lightning-rfc/pull/513
[simple commit thread]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001643.html
[corallo simple commit]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001666.html
[newsletter #18]: /zh/newsletters/2018/10/23/#over-1-100-listening-nodes-have-open-rpc-ports