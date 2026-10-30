---
title: 'Bitcoin Optech Newsletter #141'
permalink: /zh/newsletters/2021/03/24/
name: 2021-03-24-newsletter-zh
slug: 2021-03-24-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了一种在现有比特币共识规则下实现签名委派的技术，总结了关于 taproot 对比特币抵御量子计算能力影响的讨论，并宣布了一系列旨在帮助激活 taproot 的每周会议。此外还包括我们的固定栏目：服务和客户端软件的变更、新版本与候选发布，以及热门比特币基础设施软件的值得注意的变更。

## 新闻

- **<!--signing-delegation-under-existing-consensus-rules-->****在现有共识规则下的签名委派：**
  设想 Alice 想让 Bob 能够花费她的某个 UTXO，却不想立即创建一笔链上交易，也不想将她的私钥交给他。这就是所谓的*委派（delegation）*，多年来已被广泛讨论，最近较为著名的例子是在 [graftroot 提案][graftroot proposal]中提及的场景。上周，Jeremy Rubin 在 Bitcoin-Dev 邮件列表中[发布][rubin delegation]了一份说明，描述了在当下的比特币中实现委派的一种方法。

  假设 Alice 有一个 `UTXO_A`，Bob 有一个 `UTXO_B`。Alice 创建了一笔同时花费 `UTXO_A` 和 `UTXO_B` 的部分签名交易。Alice 对她的 UTXO 使用 [SIGHASH_NONE][SIGHASH_NONE] 标志进行签名，这使得签名不对交易的任何输出进行承诺。这样，交易中另一个输入的所有者——Bob——就可单方面控制输出的选择，他可以用常规的 `SIGHASH_ALL` 标志对输出进行签名，从而防止他人修改这笔交易。通过这种双输入的 `SIGHASH_NONE` 技巧，Alice 就将花费其 UTXO 的能力委派给了 Bob。

  这种技巧似乎主要具有理论意义。其他已提出的委派技术——包括 graftroot、[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 和 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]——在多个方面可能更为优越，但目前只有这种技巧可以在主网上供有兴趣的人进行实验。

- **<!--discussion-of-quantum-computer-attacks-on-taproot-->****关于量子计算机攻击 taproot 的讨论：**
  最初的比特币软件提供了两种接收比特币的方式：

  - **<!--pay-to-public-key-p2pk-->***支付到公钥（Pay-to-Public-Key，P2PK）*：实现了[原始比特币论文][original Bitcoin paper]中描述的简单明了的方法，即将比特币支付给一个公钥，并允许通过该公钥对应的签名花费这些比特币。当公钥信息能由软件完全处理时，比特币软件默认使用这种方式。

  - **<!--pay-to-public-key-hash-p2pkh-->***支付到公钥哈希（Pay-to-Public-Key-Hash，P2PKH）*：增加了一层间接性，以一个哈希摘要接收比特币，这个哈希摘要承诺了要使用的公钥。要花费这些比特币，必须在签名的同时公布公钥，使得用于哈希摘要的 20 字节数据成为额外的开销。当支付信息可能需要人工处理（例如可复制粘贴的地址）时，默认使用这种方式。

  中本聪从未解释为何同时实现这两种方法，但人们普遍认为他增加哈希间接性的原因是为了缩小地址的大小，使其更易于传播。当时原始比特币实现中的公钥为 65 字节，而地址哈希只有 20 字节。

  过去十年中出现了许多发展。为使某些多重签名协议[在默认情况下既简单又安全][bech32 address security]，人们认定多方协议所用的脚本大概应使用 32 字节的承诺。比特币开发者还了解到此前已知的一些技术，能把公钥压缩到 33 字节，后来又[优化][news48 oddness]到 32 字节。最后，[taproot 的主要创新][news27 taproot]表明，32 字节的公钥可以承诺一个脚本，而安全强度与 32 字节哈希[相近][news87 fournier proof]。这一切意味着，如果人们想要一种通用地址格式，那么无论用哈希还是用公钥，需要传输的地址数据量都不再变化——两者都是 32 字节。不过，直接使用公钥仍能消除哈希间接性带来的额外带宽和存储开销。如果每笔支付都发往公钥而不是 32 字节哈希，每年可节省约 13 GB 的区块链空间。<!-- 32 bytes * 8000 inputs per block * 52416 blocks per year --> [BIP341][BIP341] 中关于 taproot 的规范把节省空间列为其接受 P2PK 风格公钥支付、而不接受 P2PKH 风格哈希支付的原因。

  {:#p2pkh-hides-keys}
  不过，P2PKH 的哈希间接性确实有一个优势：在需要用它授权花费之前，可以把公钥对公众隐藏起来。这意味着，即使对手有能力破解某个公钥的安全性，也可能要等到交易广播之后才能动用这种能力；而一旦交易确认达到一定深度，他们也可能失去窃取该公钥所控制资金的能力。这缩短了攻击可用的时间窗口，使缓慢的攻击可能无法奏效。尽管在 taproot 选择直接使用 P2PK 风格公钥的背景下，这一点此前已被详细讨论（参见 [1][tap qc1]、[2][tap qc2] 以及 [Newsletter #70][news70 qc] 和 [Newsletter #86][news86 qc]），但本周 Bitcoin-Dev 邮件列表又[重新讨论][dashjr quantum]了这个话题，起因是有人[发表][friedenbach post]了一封反对 taproot 的电子邮件，担心“最快到本十年末”就会出现足以攻击比特币式公钥的量子计算机。

  邮件列表讨论的参与者没有人表示自己也反对 taproot，但他们确实检视了该论点的前提、讨论了替代方案，并评估了这些替代方案会带来哪些取舍。下面概述其中部分讨论：

  - **<!--hashes-not-currently-doing-a-good-job-at-qc-resistance-->***哈希目前并未在量子计算机（QC）防护方面发挥良好作用：* 根据 [2019 年的一项调查][wuille stealable]，如果攻击者拥有一台强大的量子计算机，且除比特币区块链副本外别无他物，就可窃取超过 1/3 的比特币。其中大部分源于用户[重复使用地址][topic output linking]（一种不被鼓励、但短期内似乎难以消除的做法）。

    此外，讨论参与者指出，任何与第三方共享个人公钥或 [BIP32][BIP32] 扩展公钥（xpub）的人，一旦公钥泄露，也会受到强大量子计算机的威胁。这可能包括大部分存放在硬件钱包或 LN 支付通道中的比特币。简言之，即便如今我们几乎普遍使用 P2PKH 风格的哈希公钥，只要量子计算机足够强大并能获取公开数据或第三方数据，几乎所有比特币都可能被窃取。这意味着，taproot 选择使用 P2PK 风格的非哈希公钥，并未显著改变比特币当前的安全模型。

  - **<!--taproot-improvement-in-post-qc-recovery-at-no-onchain-cost-->***taproot 在不增加链上成本的前提下改善了后量子时代的恢复能力：* 如果比特币用户得知已有或即将出现强大的量子计算机，他们可以拒绝所有 taproot 密钥路径（key-path）花费，即只用单个签名的那种花费。不过，如果用户在创建 taproot 地址时就提前做好准备，那么发往该地址的比特币也可以用脚本路径（script-path）花费来动用。此时，taproot 地址承诺的是用户想使用的 [tapscript][topic tapscript] 的哈希。这个哈希承诺可以作为某种[方案][ruffing scheme]的一部分，用来迁移到能够抵御量子计算机的新密码学算法；或者，如果这类算法在量子计算机构成威胁之前就为比特币标准化了，它可以让比特币的所有者立即迁移到新方案。但这只有在以下条件下才有效：各个用户建立了备用的 tapscript 花费路径，没有共享这些备用路径涉及的任何公钥（包括 BIP32 xpub），并且我们能在强大的量子计算机对比特币造成过多破坏之前就得知它的出现。

  - **<!--is-the-attack-realistic-->***这种攻击现实吗？* 有一位回复者认为，本十年末就出现快速量子计算机，[属于][fournier progress]“在预测的进展速度中极其乐观的一端”。另一位[指出][towns parallelization]，把单台慢速量子计算机的设计变成能并行工作的量子计算机集群，是“相当直接的工程挑战”，结果可在很短的时间内得出——这会让 P2PKH 风格哈希间接性提供的任何保护都变得无意义。还有一位回复者[提议][harding bounty]构造特殊的比特币地址，只有那些在快速量子计算机方面取得进展的人才能花费；用户可以自愿向这些地址捐赠比特币，从而形成一个有激励的早期预警系统。

  - **<!--we-could-add-a-hash-style-address-after-taproot-is-activated-->***taproot 激活后我们仍可新增哈希风格地址：* 如果确实有大量用户认为强大量子计算机的突然出现是一种威胁，我们可以通过后续软分叉[增加][dashjr quantum]一种使用哈希的 P2PKH 风格 taproot 地址类型。但这会带来一些后果，多位回复者因此表示反对：

    - **<!--use-->**它会制造混淆

    - **<!--create-->**它会占用更多区块空间

    - **<!--reduces-->**它会[缩小][poelstra anon] taproot 匿名集的规模，无论是直接影响，还是在采用[环签名成员证明][nick ring]或 [Provisions][Provisions] 之类的协议时

  - **<!--bandwidth-storage-costs-versus-cpu-costs-->***带宽/存储成本与 CPU 成本之间的取舍：* 有一种[可能][rubin recovery]可以消除哈希间接性带来的额外 32 字节存储开销：从签名及其所签名的交易数据中派生出公钥，这种技术称为*密钥恢复（key recovery）*。但这一方案同样遭到反对。密钥恢复需要[大量 CPU 资源][corallo recovery overhead]，会使节点变慢，还会妨碍使用 schnorr 批量验证——而这项技术最多能让历史区块验证快三倍。它还会[使][poelstra slowdowns]匿名成员证明等相关技术既更难开发，也更耗费 CPU。[可能][poelstra patent story]还存在[专利][US7215773B1]问题。

  截至本文撰写时，邮件列表的讨论似乎已经结束，社区对 taproot 的支持并未明显减少。随着研究者和企业继续推进量子计算的前沿，我们预计未来还会有关于如何最好地保障比特币安全的讨论。

- **<!--weekly-taproot-activation-meetings-->****每周的 taproot 激活会议：**
  为讨论 [taproot][topic taproot] 激活的相关细节，已安排在连续十周里每周二 19:00 UTC 于 [##taproot-activation][] IRC 频道举行会议，首次[会议][activation meeting log]已于昨天（3 月 23 日）举行。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--okcoin-launches-lightning-deposits-and-withdrawals-->****OKCoin 推出闪电网络充值与提现：**
  一篇[博客文章][okcoin lightning blog] 概述了 OKCoin 的闪电网络充值与提现支持。他们还将最低充值/提现门槛从 0.001 BTC 降低至 0.000001 BTC。目前，在通过闪电网络进行交易时，OKCoin 的限额为 0.05 BTC。

- **<!--bitmex-announces-bech32-support-->****BitMEX 宣布支持 bech32：**
  一篇[博客文章][bitmex bech32 blog] 详细说明了 BitMEX 为支持 [bech32][topic bech32] 存款所制定的上线计划。在此之前，BitMEX 已[推出][news77 bitmex bech32 send]了 bech32 提款（发送）支持。

- **<!--specter-v1-2-0-released-->****Specter v1.2.0 发布：**
  [Specter v1.2.0][specter v1.2.0] 支持 Bitcoin Core 的[输出脚本描述符（descriptor）钱包][topic descriptors]和选币控制功能。

- **<!--breez-streams-audio-for-lightning-payments-->****Breez 通过闪电网络支付实现音频串流：**
  Breez 钱包[集成了一款音频播放器][breez podcast blog]，结合 [keysend（即自发支付）][topic spontaneous payments]，让用户可以在收听播客的同时向发布者流式付款，也可以发送一次性打赏。

- **<!--key-manager-dux-reserve-announced-->****密钥管理器 Dux Reserve 发布：**
  Thibaud Maréchal [宣布][dux reserve tweet]了 Dux Reserve，一款测试版开源桌面密钥管理器，可在 MacOS、Windows 和 Linux 上运行，并支持 Ledger、Coldcard 和 Trezor 硬件钱包。

- **<!--coldcard-now-using-libsecp256k1-->****Coldcard 现已使用 libsecp256k1：**
  Coldcard 的[4.0.0 版本][coldcard blog 4.0.0]在其他功能之外，也将其加密操作切换为使用 Bitcoin Core 的 [libsecp256k1][] 库。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [C-Lightning 0.10.0-rc1][C-Lightning 0.10.0] 是该 LN 节点软件下一个主要版本的候选发布。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo] 中的值得注意的变更。*

- [Bitcoin Core #20861][] 实现了对 [BIP350][]（v1 及以上见证地址所用的 Bech32m 格式）的支持。Bech32m 取代 bech32（[BIP173][]），成为 1–16 号原生 segwit 输出的地址格式。0 号原生 segwit 输出（P2WPKH 和 P2WSH）仍继续使用 bech32。一旦 taproot 输出（[BIP341][BIP341]）在网络中定义，这个 PR 就能让 Bitcoin Core 用户向 Taproot 支付（P2TR）地址付款。此更改不应影响任何主网系统，但在 signet 等测试环境中可能引发地址不兼容问题——这些环境已按此前的提议，用 bech32 编码地址激活了 taproot。Bech32m 支持也将向后移植到 Bitcoin Core 0.19、0.20 和 0.21。

- [Bitcoin Core #21141][] 更新了 `-walletnotify` 配置设置，每当出现影响已加载钱包的交易时，就会调用用户指定的命令。现在可以向传给该命令的参数中加入两个新占位符：`%b` 表示包含该交易的区块的哈希，`%h` 表示该区块的高度。对于未确认交易，两者都会被设为已定义的值。

- [C-Lightning #4428][] 弃用 `fundchannel_complete` RPC 接受 txid 的方式，改为要求传入[部分签名比特币交易（PSBT）][topic psbt]。这样可以检查 PSBT 是否包含资金输出，从而避免用户传入错误数据后无法恢复资金的[问题][c-lightning #4416]。

- [C-Lightning #4421][] 实现了上周 [Newsletter #140][news140 recovery] 中介绍的注资交易恢复流程。误用被自己篡改的交易（例如通过 RBF）为通道注资、但尚未使用该通道的用户，现在可以把交易输出提供给 `lightning-close` 命令，与支持 `shutdown_wrong_funding` 特性的对等节点协商恢复。

- [LND #5068][] 提供了一系列新的配置选项，用于限制 LND 处理网络 gossip 信息的数量。这对资源有限的系统会有帮助。

- [Libsecp256k1 #831][] 实现了一种算法，可将签名验证速度提升 15%。在仍采用可最大限度抵抗侧信道攻击的常数时间算法的前提下，它还能把生成签名所需的时间缩短 25%。此外，它还消除了 Libsecp256k1 对某些其他库的依赖。关于这一优化的更多信息，参见 [Newsletter #136][news136 safegcd]。

- [BIPs #1059][] 加入了 [BIP370][]，该 BIP 规定了版本 2 的 PSBT，正如此前在邮件列表中讨论的那样（参见 [Newsletter #128][news128 psbtv2]）。


{% include references.md %}
{% include linkers/issues.md issues="20861,21141,4428,4416,4421,1059,5064,5068,831" %}
[c-lightning 0.10.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.0rc1
[news136 safegcd]: /zh/newsletters/2021/02/17/#faster-signature-operations
[graftroot proposal]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-February/015700.html
[original bitcoin paper]: https://bitcoin.org/bitcoin.pdf
[bech32 address security]: /zh/bech32-sending-support/#地址安全性
[news48 oddness]: /zh/newsletters/2019/05/29/#move-the-oddness-byte
[news27 taproot]: /zh/newsletters/2018/12/28/#taproot
[news87 fournier proof]: /zh/newsletters/2020/03/04/#taproot-in-the-generic-group-model
[dashjr quantum]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018641.html
[friedenbach post]: https://freicoin.substack.com/p/why-im-against-taproot
[wuille stealable]: https://twitter.com/pwuille/status/1108097835365339136
[ruffing scheme]: https://gist.github.com/harding/bfd094ab488fd3932df59452e5ec753f
[fournier progress]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018658.html
[harding bounty]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018648.html
[provisions]: https://eprint.iacr.org/2015/1008
[nick ring]: https://twitter.com/n1ckler/status/1334240709814136833
[poelstra anon]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018667.html
[rubin recovery]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018643.html
[corallo recovery overhead]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018644.html
[towns parallelization]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018649.html
[poelstra slowdowns]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018667.html
[poelstra patent story]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018646.html
[##taproot-activation]: https://webchat.freenode.net/##taproot-activation
[activation meeting log]: http://gnusha.org/taproot-activation/2021-03-23.log
[news128 psbtv2]: /zh/newsletters/2020/12/16/#new-psbt-version-proposed
[news70 qc]: /zh/newsletters/2019/10/30/#why-does-hashing-public-keys-not-actually-provide-any-quantum-resistance
[news86 qc]: /zh/newsletters/2020/02/26/#could-taproot-create-larger-security-risks-or-hinder-future-protocol-adjustments-re-quantum-threats
[tap qc1]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-January/015620.html
[tap qc2]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016556.html
[rubin delegation]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-March/018615.html
[sighash_none]: https://btcinformation.org/en/developer-guide#term-sighash-none
[US7215773B1]: https://patents.google.com/patent/US7215773B1/en
[news140 recovery]: /zh/newsletters/2021/03/17/#rescuing-lost-ln-funding-transactions
[okcoin lightning blog]: https://blog.okcoin.com/2021/03/04/how-to-use-bitcoin-lightning-network/
[dux reserve tweet]: https://twitter.com/thibm_/status/1369331407441510405
[bitmex bech32 blog]: https://blog.bitmex.com/introducing-bech32-deposits-on-bitmex-to-deepen-bitcoin-integration-lower-fees/
[news77 bitmex bech32 send]: /zh/newsletters/2019/12/18/#bitmex-bech32-send-support
[specter v1.2.0]: https://github.com/cryptoadvance/specter-desktop/releases/tag/v1.2.0
[breez podcast blog]: https://medium.com/breez-technology/podcasts-on-breez-streaming-sats-for-streaming-ideas-d9361ae8a627
[coldcard blog 4.0.0]: https://blog.coinkite.com/version-4.0.0-released/
