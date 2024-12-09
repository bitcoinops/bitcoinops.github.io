---
title: 'Bitcoin Optech Newsletter #127'
permalink: /zh/newsletters/2020/12/09/
name: 2020-12-09-newsletter-zh
slug: 2020-12-09-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一个针对 taproot 的 Bech32 地址格式的提案，提到处理某些 QR 编码地址时的一个错误，感谢加密货币开放专利联盟（COPA）的新成员，并提到了 Minsc 策略语言和编译器的新功能。此外，还包括我们常规的 Bitcoin Core PR 审查俱乐部会议总结、新软件发布与候选发布，以及流行比特币基础设施软件的显著变更。

## 行动项

*本周无。*

## 新闻

- **<!--bech32-addresses-for-taproot-and-beyond-->****用于 taproot 及后续版本的 Bech32 地址：** Pieter Wuille [发布了][wuille post]他与 Gregory Maxwell 合作研究的结果，寻找更新的 [Bech32 地址][topic bech32]的最佳常数，以消除[可变性问题][mutability problem]并尽可能缓解其他数据输入问题。他还回应了由多位研究人员进行的研究（[1][russell test]、[2][casatta test]、[3][schmidt test1]、[4][schmidt test2]），研究内容涉及哪些钱包支持[地址的前向兼容性][forward address compatibility]。研究结果表明，大多数钱包需要更新才能向 [taproot][topic taproot] 地址支付，即使我们继续使用未更改的 [BIP173][] 地址方案。基于他的研究和现有的信息，如果没有令人信服的反对意见，他计划撰写一个提案，提出修改后的 Bech32 校验和公式用于 segwit v1 地址（taproot）及后续 segwit 版本地址。如果采用了该提案的 Bech32 地址，对钱包和服务的影响如下：

  - **<!--support-for-current-addresses-remains-unchanged-->***对当前地址的支持保持不变：* 能够向当前原生 segwit 地址（版本 0）发送或接收的现有钱包无需修改即可继续工作。目前的原生 segwit 地址均以 `bc1q` 开头。P2SH 包裹的 segwit 地址也不受影响。

  - **<!--wallets-that-support-segwit-v1-addresses-now-won-t-be-forward-compatible-->*** 当前支持 segwit v1+ 地址的钱包将不具有前向兼容性：*已经实现 BIP173 前向兼容的钱包会发现它无法支持 taproot 和使用 Wuille 新提案生成的后续地址。这些地址将因校验和不匹配而失败。根据邮件列表中发布的调查结果，目前已知受影响的钱包是 Bitcoin Core 和 BRD 钱包。

  - **<!--all-other-wallets-will-need-to-update-eventually-anyway-->***其他所有钱包最终都需要更新：* 调查的其他钱包和服务当前不支持计划的 taproot 地址，因此当用户开始请求向这些 v1 地址付款时，它们需要升级。对于已经支持发送到当前 segwit 地址的钱包，更新应该很容易，因为计划的算法变更最小。

- **<!--thwarted-upgrade-to-uppercase-bech32-qr-codes-->****升级为大写 Bech32 QR 码的尝试受阻：** BTCPay Server 最近实施了 [BIP173][] 中描述的一项优化（详见 [Newsletter #46][bech32 upper]），创建以大写字母开头的 Bech32 地址的 QR 码，以生成更小、更简单的 QR 码。不幸的是，一位使用 BTCPay 的商户[报告][btcpay #2099]，他们的一位客户无法支付这些新的 QR 码。BTCPay 的贡献者快速确认，客户使用的钱包软件未正确实现 [RFC3986][] 大小写不敏感的模式解析。虽然钱包的开发者迅速解决了问题，但 BTCPay 的贡献者回滚了 QR 码更改，并开始测试大量流行用户钱包，以确定有多少支持大写 `bitcoin:` 模式字符串。不幸的是，根据初步结果，发现其他几个流行钱包也未实现大小写不敏感的 RFC3986 模式解析。任何对解决该问题感兴趣的人都被鼓励[协助测试][btcpay #2110]，以便通知受影响钱包的开发者。

- **<!--cryptocurrency-open-patent-alliance-copa-gains-new-members-->****加密货币开放专利联盟（COPA）新增成员：** Square Crypto 在 Twitter 上[宣布][square tweet]，一些新组织加入了该联盟，致力于防止专利被滥用以阻碍加密货币技术的创新和采用。我们与许多人一道感谢 COPA 的所有现有成员：ARK.io、Bithyve、Blockchain Commons、Blockstack、Blockstream、Carnes Validadas、Cloudeya Ltd.、Coinbase、Foundation Devices、Horizontal Systems、Kraken、Mercury Cash、Protocol Labs、Request Network、SatoshiLabs、Square、Transparent Systems 和 VerifyChain。

{% comment %}<!-- 这是我对自己政策的调整，即 (1) 发布信息现在应列入发布部分；(2) 我仅涵盖值得注意的代码更改部分列出的项目的发布；(3) Minsc 不属于这些项目。以下技术上并不是一个发布公告，而是新功能的声明，*恰好*与发布对应。是的，也许我应该制定更好的政策，或者更随性一些。-->{% endcomment %}

- **<!--minsc-adds-new-features-->****Minsc 增添新功能：** 这一策略语言和编译器的最新[版本][minsc 0.2]支持多种新数据类型：公钥、哈希、策略、[miniscript][topic miniscript]、[描述符][topic descriptors]、地址和网络。它还添加了新的转换函数：`miniscript()`、`wsh()`、`wpkh()`、`sh()` 和 `address()`。以下是一个[示例][minsc example]，取自项目官网，使用指定的公钥（作为带派生路径的 [BIP32][] 扩展公钥）以及多个转换函数，返回最终行中指定的数据集：

  ```hack
  $alice = xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw/9/0;

  $policy = pk($alice/1/3) && older(1 month);
  $miniscript = miniscript($policy); // 将策略编译为 miniscript
  $descriptor = wsh($miniscript); // 使用 p2wsh 描述符封装
  $address = address($descriptor); // 生成地址

  [ $policy, $miniscript, $descriptor, $address ]
  ```
## Bitcoin Core PR 审查俱乐部

*在这一每月栏目中，我们总结了最近一次 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议，重点介绍了一些重要的问题和答案。点击下面的问题可以查看会议中答案的摘要。*

[定期建立区块中继连接并同步区块头][review club #19858] 是 Suhas Daftuar 提交的一个拉取请求（[#19858][Bitcoin Core #19858]），该提议通过增加一种寻找高质量节点的新方法来使[日蚀攻击][topic eclipse attacks]变得更加困难。该提案平均每五分钟向一个新节点建立一个出站连接并与其同步区块头。如果该节点告知本地节点有新区块，则本地节点断开现有的一个仅中继区块的对等节点连接，将该连接槽位分配给新节点。这一改动会增加攻击者持续对节点进行分区攻击的成本，因为只要节点的对等地址管理器（[addrman][]）中至少有一个诚实节点地址，它最终应该总能找到工作量最多的有效链。

大部分讨论集中在对提议变更的理解上。

{% include functions/details-list.md
  q0="**<!--q0-->**什么是仅中继区块的连接？"
  a0="仅中继区块的连接是一种连接类型，引入于 [Bitcoin Core #15759][Bitcoin Core #15759]，这种连接仅中继区块，而不中继交易或潜在对等节点的 IP 地址。"

  q1="**<!--q1-->**仅中继区块的连接比完全中继连接更不容易被观察到吗？"
  a1="是的，完全中继连接会传播交易和地址，这可能泄露网络拓扑信息，并被间谍用来绘制连接图。"
  a1link="https://bitcoincore.reviews/19858#l-59"

  q2="**<!--q2-->**描述一个定期建立仅中继区块连接可以帮助防止攻击的场景？"
  a2="当一个节点被日蚀攻击，但其 addrman 中仍有诚实地址时。"
  a2link="https://bitcoincore.reviews/19858#l-89"

  q3="**<!--q3-->**如果在建立这些新的仅中继区块连接时发现新区块，会发生什么？"
  a3="如果我们发现新区块，我们将替换现有的一个较新的仅中继区块对等节点，用新的对等节点取而代之。"
  a3link="https://bitcoincore.reviews/19858#l-194"

  q4="**<!--q4-->**此更改可能的权衡是什么？"
  a4="这可能[减少网络中的开放监听插槽数量][few sockets]，并[增加网络的持续负载][network load]。最后，任何更改都会涉及[成本、复杂性和维护][complexity]。"

  q5="**<!--q5-->**除了提高单个节点对日蚀攻击的抵抗力之外，这种行为对整个网络可能有什么好处？"
  a5="定期连接到新节点以同步区块链顶端应该有助于通过更频繁的连接将整个网络桥接起来，从而为网络图提供更多边，增强对分区攻击的安全性。"
  a5link="https://github.com/bitcoin/bitcoin/pull/19858#discussion_r483713328"
%}

## 发布与候选发布

*流行比特币基础设施项目的新版本和候选发布。请考虑升级到新版本或协助测试候选版本。*

- [Bitcoin Core 0.21.0rc2][Bitcoin Core 0.21.0] 是该全节点实现及其相关钱包和其他软件下一个主要版本的候选发布。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [LND #4782][] 为使用[锚定输出][topic anchor outputs]的 LN 通道新增了对[瞭望塔][topic watchtowers]客户端的支持，使这些锚定通道可以备份其状态，类似于当前遗留通道的备份方式。


{% include references.md %}
{% include linkers/issues.md issues="20564,4782,19858,15759" %}
[bitcoin core 0.21.0]: https://bitcoincore.org/bin/bitcoin-core-0.21.0/
[mutability problem]: /zh/newsletters/2019/12/28/#bech32-mutability
[forward address compatibility]: /zh/bech32-sending-support/#自动-bech32-支持未来的软分叉
[russell test]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-October/018256.html
[casatta test]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-October/018257.html
[schmidt test1]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-October/018258.html
[schmidt test2]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-November/018268.html
[btcd #1661]: https://github.com/btcsuite/btcd/issues/1661
[bech32 upper]: /zh/bech32-sending-support/#使用-bech32-地址创建更高效的二维码
[btcpay #2099]: https://github.com/btcpayserver/btcpayserver/issues/2099
[rfc3986]: https://tools.ietf.org/html/rfc3986#section-3.1
[square tweet]: https://twitter.com/sqcrypto/status/1334626548515663872
[minsc 0.2]: https://github.com/shesek/minsc/releases/tag/v0.2.0
[minsc example]: https://min.sc/#c=%24alice%20%3D%20xpub68Gmy5EdvgibQVfPdqkBBCHxA5htiqg55crXYuXoQRKfDBFA1WEjWgP6LHhwBZeNK1VTsfTFUHCdrfp1bgwQ9xv5ski8PX9rL2dZXvgGDnw%2F9%2F0%3B%0A%0A%24policy%20%3D%20pk%28%24alice%2F1%2F3%29%20%26%26%20older%281%20month%29%3B%0A%24miniscript%20%3D%20miniscript%28%24policy%29%3B%20%2F%2F%20compile%20policy%20to%20miniscript%0A%24descriptor%20%3D%20wsh%28%24miniscript%29%3B%20%2F%2F%20wrap%20with%20a%20p2wsh%20descriptor%0A%24address%20%3D%20address%28%24descriptor%29%3B%20%2F%2F%20generate%20the%20address%0A%0A%5B%20%24policy%2C%20%24miniscript%2C%20%24descriptor%2C%20%24address%20%5D
[wuille post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-December/018292.html
[bip21 lowercase]: /zh/bech32-sending-support/#bip21-complications
[btcpay #2110]: https://github.com/btcpayserver/btcpayserver/issues/2110
[few sockets]: https://bitcoincore.reviews/19858#l-180
[network load]: https://github.com/bitcoin/bitcoin/pull/19858#issuecomment-734874989
[complexity]: https://bitcoincore.reviews/19858#l-188
[addrman]: https://github.com/bitcoin/bitcoin/blob/884bde510e2db59ee44604e2cccabb0bf1ef6ada/src/addrman.h#L99
