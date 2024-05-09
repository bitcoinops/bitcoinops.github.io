---
title: 'Bitcoin Optech Newsletter #247'
permalink: /zh/newsletters/2023/04/19/
name: 2023-04-19-newsletter-zh
slug: 2023-04-19-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的周报提供了 RGB 协议开发的最新更新，包括我们的常规部分，这些部分总结了最近对客户端和服务的更新，宣布新版本和候选版本，以及对热门比特币基础设施项目的重大变更介绍。

## 新闻

- **RGB 更新：** Maxim Orlovsky 在 Bitcoin-Dev 邮件列表中[发布了][orlovsky rgb] RGB 开发状态的更新。RGB 是一种使用比特币交易在链下合约中执行状态更新的协议。一个简单的例子涉及代币的创建和转移，尽管 RGB 的设计目的不仅仅是代币的转移。

  - 链下，Alice 创建了一个合约，其初始状态将 1000 个代币分配给她控制的某个 UTXO。

  - Bob 想要 400 个代币。Alice 给了他一份原始合约的副本，以及一笔可以花费她的 UTXO 的交易的新输出。该输出包含对新合约状态的非公开承诺。新的合约状态指定了金额的分配（400 给 Bob；600 返回给 Alice）以及控制这些金额的两个输出的标识符。Alice 广播这笔交易。这种代币转移防止双重花费的安全性现在与 Alice 的比特币交易相同，例如，当她的交易有六次确认时，代币转移将是安全的，不会受到最多六个区块的分叉的影响。

    控制金额的输出不需要是包含承诺的交易的输出（尽管这是允许的）。这消除了使用链上交易分析来跟踪基于 RGB 的传输的能力。代币可能已经转移到任何现有的 UTXO——或者转移到接收方知道将来会存在的任何 UTXO（例如，来自他们的冷钱包的预签名花费可能多年都不会出现在链上）。各种输出的比特币价值及它们的其他特征与 RGB 协议无关，尽管 Alice 和 Bob 希望确保它们易于花费。

  - 之后，Carol 想在一个使用了单个链上交易的原子互换中从 Bob 那里买 100 个代币。她生成一个未签名的 PSBT，从她的输入中为交易提供资金，使用一个输出向 Bob 支付比特币，并通过第二个输出将比特币零钱返还给她自己。其中一个输出也承诺了金额和 UTXO 标识符，使得她将在其中收到她购买的代币，而 Bob 将收到代币找零。

    Bob 向 Carol 提供原始合约和 Alice 之前创建的证明 Bob 现在控制 400 个代币的承诺。Bob 不需要知道 Alice 用她剩下的 600 个代币做了什么，Alice 也没有参与 Bob 和 Carol 之间的交换。这提供了隐私和可扩展性。Bob 使用控制代币的 UTXO 的签名输入来更新 PSBT。

    Carol 验证原始合约和之前状态更新的历史。她还确保 PSBT 中的所有其他内容都是正确的。她提供她的签名并广播交易。

  尽管上面的每个转移示例都是在链上进行的，但修改协议以在链下运行是很简单的。Carol 给了 Dan 一份合同副本以及使得她收到 100 个代币的状态更新历史。然后，她和 Dan 协调创建一个输出，该输出接收 100 个代币，并且需要他们两人的签名才能使用。在链下，他们通过生成花费多重签名输出的许多不同版本的交易来回转移代币，每个链下支出都致力于分配代币和用于接收这些代币的输出标识符。最后，其中一人广播其中一笔支出交易，将状态放在链上。

  分配代币的输出可能会受到比特币脚本的阻碍，该脚本决定了谁将最终控制代币。
  例如，他们可能会向一个 [哈希时间锁合约][topic htlc] 脚本支付，该脚本使 Carol 能够随时使用代币，如果 Carol 可以提供原像和她的签名，或者让 Dan 能够在时间锁定到期后仅使用他的签名来使用代币。这允许代币用于转发的链下支付，例如闪电网络中使用的代币。

  在对线程的 [回复][tenga rgb] 中，Federico Tenga 链接到基于 RGB 的 [闪电网络节点][rgb-lightning-sample]，该节点基于 [LDK][ldk
  repo] 的一个分支和该项目的 [LDK 示例][ldk-sample] 节点。通过该项目中的链接，我们找到了有关闪电网络兼容性的有用的 [附加信息][rgb.info ln]。有关 RGB 协议的更多信息可以在 LNP/BP 协会主办的 [网站][rgb.tech] 上找到。

  在本周的帖子中，Orlovsky 宣布 [发布][rgb blog] RGB v0.10。最重要的是，新版本与为以前版本创建的合约不兼容（但主网上没有已知的商业 RGB 合约允许）。新设计旨在允许所有新合约随着时间的推移进行升级，以应对协议未来的变化。还实施了许多其他改进，并呈现了添加其他功能的路线图。

  在撰写本文时，该公告已在邮件列表中收到了适量的讨论。{% assign timestamp="1:12" %}

## 服务和客户端软件变更

*在这个月度专题中，我们重点介绍了比特币钱包和服务的有趣更新。*

- **<!--descriptor-wallet-library-adds-block-explorer-->描述符钱包库添加区块浏览器：**
  [描述符钱包库][Descriptor wallet library]是一个基于 rust 描述符的钱包库，它建立在 rust-bitcoin 之上并支持 [miniscript][topic miniscript]，[描述符][topic descriptors]，[PSBTs][topic psbt]，在最近的[版本][Descriptor Wallet v0.9.2] 中，它是一个基于文本的 [区块浏览器][topic block explorers]，可以解析和显示来自交易输入见证的 taproot [控制块][se107154] 的更多的细节，以及与交易脚本匹配的描述符和 miniscripts。{% assign timestamp="36:02" %}

- **Stratum v2 参考实施更新公布：**
  该项目[发布了][stratum blog]有关更新的详细信息，包括池中矿工为候选区块选择交易的能力。鼓励矿工、矿池和挖矿固件开发人员进行测试并提供反馈。 {% assign timestamp="38:02" %}

- **Liana 0.4 发布:**
  Liana 的 [0.4 版本][liana 0.4]增加了对多恢复路径和额外描述符的支持，支持更多的分组人数。{% assign timestamp="42:35" %}

- **Coldcard 固件支持额外的 sighash 标志：**
  Coldcard 的 [版本 5.1.2 固件][coldcard firmware] 现在支持所有
  [签名哈希][wiki sighash]（sighash）类型，而不仅仅局限于`SIGHASH_ALL`，从而实现高级交易的可能性。{% assign timestamp="46:12" %}

- **Zeus 添加费用提升功能：**
  [Zeus v0.7.4][] 使用 [RBF][topic rbf] 和 [CPFP][topic cpfp] 添加费用提升功能，用于链上交易，包括 LN 通道打开和 LN 通道关闭交易。费用提升最初仅由 LND 后端支持。{% assign timestamp="45:09" %}

- **基于 Utreexo 的 Electrum Server 宣布**
   [Floresta][floresta blog] 是一种与 Electrum 协议兼容的服务器，它使用 [utreexo][topic utreexo] 来降低服务器的资源要求。软件目前支持 [signet][topic signet] 测试网。{% assign timestamp="48:12" %}

## 版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [BDK 0.28.0][] 是该库的维护版本，用于构建支持比特币的应用程序。{% assign timestamp="53:08" %}

- [Core Lightning 23.02.2][] 是这个热门的 LN 节点软件的维护版本，其中包含几个错误修复。{% assign timestamp="55:01" %}

- [Core Lightning 23.05rc1][] 是此 LN 节点下一个版本的候选版本。{% assign timestamp="55:40" %}

## 重大的代码和文档变更

*本周的重大变更有 [Bitcoin Core][bitcoin core repo]、[Core
Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]。*

- [Bitcoin Core #27358][] 更新 `verify.py` 脚本以自动执行验证 Bitcoin Core 版本文件的过程。用户导入他们信任的签名者的 PGP 密钥。该脚本下载一个版本的校验和文件列表以及提交这些校验和的人员的签名。然后该脚本验证至少 *k* 个提交这些校验和的可信签名者，用户可以决定 *k* 是多少。如果找到来自可信签名者的足够有效签名，脚本将下载文件，以便用户可以安装该版本的 Bitcoin Core。有关其他详细信息，见[文档][verify docs]。使用 Bitcoin Core 不需要该脚本，它只会自动执行鼓励用户在使用从互联网下载的安全敏感文件之前自行执行的过程。{% assign timestamp="56:57" %}

- [Core Lightning #6120][] 改进了其[交易替换][topic rbf] 逻辑，包括实施一组规则来确定何时自动执行 RBF 费用来加速一个交易并定期重新广播未确认的交易以确保它们被中继 (见 [周报 #243][news243 rebroadcast])。{% assign timestamp="1:01:14" %}

- [Eclair #2584][] 添加了对[通道拼接][topic splicing]的支持，包括将资金添加到现有通道的 splice-ins 和将资金从通道发送到链上目的地的 splice-outs。PR 指出，与当前[规范草案][bolts #863] 的实施存在一些差异。{% assign timestamp="1:04:54" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="27358,6120,2584,863" %}
[bdk 1.0.0-alpha.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-alpha.0
[orlovsky rgb]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021554.html
[tenga rgb]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021558.html
[rgb-lightning-sample]: https://github.com/RGB-Tools/rgb-lightning-sample
[ldk-sample]: https://github.com/lightningdevkit/ldk-sample
[rgb.tech]: https://rgb.tech/
[rgb.info ln]: https://docs.rgb.info/lightning-network-compatibility
[verify docs]: https://github.com/theuni/bitcoin/blob/754fb6bb8125317575edec7c20b5617ad27a9bdd/contrib/verifybinaries/README.md
[news243 rebroadcast]: /zh/newsletters/2023/03/22/#lnd-7448
[rgb blog]: https://rgb.tech/blog/release-v0-10/
[bdk 0.28.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.28.0
[Core Lightning 23.02.2]: https://github.com/ElementsProject/lightning/releases/tag/v23.02.2
[Core Lightning 23.05rc1]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc1
[Descriptor wallet library]: https://github.com/BP-WG/descriptor-wallet
[Descriptor Wallet v0.9.2]: https://github.com/BP-WG/descriptor-wallet/releases/tag/v0.9.2
[stratum blog]: https://stratumprotocol.org/blog/stratumv2-jn-announcement/
[liana 0.4]: https://wizardsardine.com/blog/liana-0.4-release/
[coldcard firmware]: https://coldcard.com/docs/upgrade
[wiki sighash]: https://en.bitcoin.it/wiki/Contract#SIGHASH_flags
[zeus v0.7.4]: https://github.com/ZeusLN/zeus/releases/tag/v0.7.4
[floresta blog]: https://medium.com/vinteum-org/introducing-floresta-an-utreexo-powered-electrum-server-implementation-60feba8e179d
[se107154]: https://bitcoin.stackexchange.com/questions/107154/what-is-the-control-block-in-taproot
