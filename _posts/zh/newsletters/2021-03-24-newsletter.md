---
title: 'Bitcoin Optech Newsletter #141'
permalink: /zh/newsletters/2021/03/24/
name: 2021-03-24-newsletter-zh
slug: 2021-03-24-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一种在现有比特币共识规则下进行签名委派的技术，总结了关于 taproot 对比特币抗量子密码学能力影响的讨论，并宣布了为帮助激活 taproot 而举行的一系列每周会议。此外还包括我们的常设栏目，介绍对服务和客户端软件的更改、新版本和候选发布，以及对流行的比特币基础设施软件值得注意的更改。

## 新闻

- **<!--signing-delegation-under-existing-consensus-rules-->****在现有共识规则下的签名委派：**
  设想 Alice 想让 Bob 能够花费她的某个 UTXO，却不想立即创建一笔链上交易，也不想将她的私钥交给他。这就是所谓的*委派（delegation）*，多年来已被广泛讨论，最近较为著名的例子是在 [graftroot 提案][graftroot proposal]中提及的场景。上周，Jeremy Rubin 在 Bitcoin-Dev 邮件列表中[发布][rubin delegation]了一份说明，描述了在当下的比特币中实现委派的一种方法。

  假设 Alice 有一个 `UTXO_A`，Bob 有一个 `UTXO_B`。Alice 创建了一笔同时花费 `UTXO_A` 和 `UTXO_B` 的部分签名交易。Alice 对她的 UTXO 使用 [SIGHASH_NONE][SIGHASH_NONE] 标志进行签名，这使得签名不对交易的任何输出进行承诺。这样，交易中另一个输入的所有者——Bob——就可单方面控制输出的选择，他可以用常规的 `SIGHASH_ALL` 标志对输出进行签名，从而防止他人修改这笔交易。通过这种双输入的 `SIGHASH_NONE` 技巧，Alice 就将花费其 UTXO 的能力委派给了 Bob。

  此技巧主要具有理论意义。其他已提出的委派技术——包括 graftroot、[OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 和 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack]——在多个方面可能更为优越，但目前只有这种技巧可以在主网上供有兴趣的人进行实验。

- **<!--discussion-of-quantum-computer-attacks-on-taproot-->****关于量子计算机对 taproot 攻击的讨论：**
  最初的比特币软件提供了两种接收比特币的方式：

  - **<!--pay-to-public-key-p2pk-->***支付到公钥（Pay-to-Public-Key，P2PK）*：实现了[原始比特币论文][original Bitcoin paper]中描述的简单明了的方法，即将比特币支付给一个公钥，并允许通过该公钥对应的签名花费这些比特币。当公钥信息能由软件完全处理时，比特币软件默认使用这种方式。

  - **<!--pay-to-public-key-hash-p2pkh-->***支付到公钥哈希（Pay-to-Public-Key-Hash，P2PKH）*：增加了一层间接性，以一个哈希摘要接收比特币，这个哈希摘要承诺了要使用的公钥。要花费这些比特币，必须在签名的同时公布公钥，使得用于哈希摘要的 20 字节数据成为额外的开销。当支付信息可能需要人工处理（例如可复制粘贴的地址）时，默认使用这种方式。

  中本聪从未解释为何同时实现这两种方法，但人们普遍认为他增加哈希间接性的原因是为了缩小地址的大小，使其更易于传播。当时原始比特币实现中的公钥为 65 字节，而地址哈希只有 20 字节。

  过去十年中出现了许多发展。为使某些多签协议[在默认情况下既简单又安全][bech32 address security]，已确定多方协议使用 32 字节承诺可能是更好的选择。比特币开发者还了解到了先前已知的技术，可将公钥压缩至 33 字节，之后又[优化][news48 oddness]到 32 字节。最终，[taproot 的主要创新][news27 taproot]展示出 32 字节公钥可用与 32 字节哈希具有相近安全性的方式承诺脚本（参见 [news87 fournier proof][news87 fournier proof]）。这意味着在需要通用地址格式的情况下，无论使用哈希还是公钥，通信的数据量都是 32 字节。此外，直接使用公钥还能消除哈希间接性带来的额外带宽和存储成本。如果每笔支付都直接使用公钥而不是 32 字节哈希，每年可节省约 13 GB 的区块链空间。<!-- 32 字节 * 每区块 8000 个输入 * 每年约 52416 个区块 --> [BIP341][BIP341] 对 taproot 的规范将接受支付到公钥（P2PK）风格作为原因描述为节省空间。

  {:#p2pkh-hides-keys}
  不过，P2PKH 的哈希间接性确实有一个优势：在实际需要授权花费前，可将公钥对公众隐藏。这意味着如果有对公钥实施攻击的对手，在交易广播前可能无法利用该能力，并且在交易确认达到一定深度后，可能会失去窃取由该公钥控制资金的机会。这限制了攻击可用的时间，从而使缓慢的攻击可能无法奏效。尽管在 taproot 直接使用公钥（P2PK 风格）这一决定的背景下，此问题此前已被深入讨论（参见 [1][tap qc1]、[2][tap qc2] 以及 [Newsletter #70][news70 qc] 和 [Newsletter #86][news86 qc]），但在有人[发表][dashjr quantum]一封[电子邮件][friedenbach post]质疑 taproot，担心“可能在本十年末就出现可攻击比特币式公钥的量子计算机”后，本周 Bitcoin-Dev 邮件列表上对此问题的讨论再度活跃。

  在邮件列表讨论中，没有参与者表示反对 taproot，但他们确实检视了该观点的前提条件、讨论了替代方案，并评估了这些替代方案所涉及的权衡。以下是对部分讨论的总结：

  - **<!--hashes-not-currently-doing-a-good-job-at-qc-resistance-->***哈希目前并未在量子计算机（QC）防护方面发挥良好效果：* 根据 [2019 年的一项调查][wuille stealable]，如果攻击者拥有一台强大的量子计算机，且除比特币区块链副本外别无他物，就可窃取超过 1/3 的比特币。这大部分源于用户[重复使用地址][topic output linking]（一种并不鼓励但似乎难以消除的做法）。

    此外，讨论参与者指出，任何与第三方共享个人公钥或 [BIP32][BIP32] 扩展公钥（xpub）的人，也在公钥泄露时会受到强大量子计算机的威胁。这可能包括大部分存储于硬件钱包或处于闪电网络（LN）支付通道中的比特币。总之，即便如今几乎普遍使用 P2PKH 风格的公钥哈希，只要量子计算机强大到一定程度，并能访问公共或第三方数据，几乎所有比特币都可能被窃取。这意味着，在 taproot 中使用 P2PK 风格的非哈希公钥并未显著改变当前的比特币安全模型。

  - **<!--taproot-improvement-in-post-qc-recovery-at-no-onchain-cost-->***taproot 在后量子计算机恢复方面的改进且不增加链上成本：* 如果比特币用户得知有强大的量子计算机即将出现或已出现，他们可拒绝接受任何 taproot 密钥路径（key-path）花费（仅使用单个签名的花费方式）。然而，如果用户在创建 taproot 地址时事先准备，当初接收该地址的比特币也可以通过脚本路径（script-path）花费。在这种情况下，taproot 地址会对 [tapscripts][topic tapscript] 的哈希进行承诺，用户可利用该哈希承诺作为某种[方案][ruffing scheme]的一部分来迁移至安全对抗量子计算机的新加密算法，或者——如果在量子计算机成为威胁前就已为比特币标准化了新的安全算法——用户可立即将其比特币转移至新方案中。这只有在以下情况下可行：用户为后备的脚本花费路径做好准备、他们未与他人共享这些后备路径中涉及的公钥（包括 BIP32 xpub）、并且我们能在强大的量子计算机对比特币造成严重破坏前获知其出现。

  - **<!--is-the-attack-realistic-->***这种攻击现实吗？* 有一位回复者认为在本十年末出现快速量子计算机的可能性[被视为][fournier progress]“远比目前预测进展率乐观”。另一位[指出][towns parallelization]，若有一台缓慢的量子计算机，只需通过并行化（量子计算机集群）实现即可在极短时间内得到结果，从而使 P2PKH 风格哈希间接性所提供的时间延迟保护毫无意义。还有一位回复者[提议][harding bounty]构建特殊比特币地址，只能由正在实现快速量子计算突破的人花费；用户可自愿向这些地址捐赠比特币，以创造一个激励性的早期预警系统。

  - **<!--we-could-add-a-hash-style-address-after-taproot-is-activated-->***taproot 激活后我们仍可新增哈希风格地址：* 如果许多用户真的认为强大的量子计算机的突然出现是个威胁，我们可以通过后续软分叉[添加][dashjr quantum]一种类似 P2PKH 风格的 taproot 地址类型，使用哈希。但这会带来一些被多位回复者反对的后果：

    - **<!--use-->**它会制造混淆

    - **<!--create-->**它会占用更多区块空间

    - **<!--reduces-->**它会[降低][poelstra anon] taproot 匿名集的规模，无论是直接影响还是在使用[环签名成员证明][nick ring]或 [Provisions][Provisions] 等协议时都有影响

  - **<!--bandwidth-storage-costs-versus-cpu-costs-->***带宽/存储成本与 CPU 成本之间的权衡：* 通过所谓的*密钥恢复（key recovery）*技术，从签名及其所签名的交易数据中派生公钥有可能消除哈希间接性产生的 32 字节存储开销（参见 [rubin recovery][rubin recovery]）。然而，同样遭到反对。密钥恢复需要[大量的 CPU 资源][corallo recovery overhead]，这会使节点变慢，并且会阻止使用 schnorr 批量验证（batch validation）将历史区块验证加速最多三倍的优势。此外，这还会[使得][poelstra slowdowns]匿名成员证明等相关技术的开发更困难且计算量更大。[可能][poelstra patent story]还存在[专利][US7215773B1]问题。

  截至撰写本文时，邮件列表中的讨论似乎已结束，并未明显导致社区对 taproot 的支持减弱。随着研究者和企业继续改进量子计算机的最新技术，我们预计未来仍会有关于如何最佳保障比特币安全的讨论。

- **<!--weekly-taproot-activation-meetings-->****每周的 taproot 激活会议：**
  已计划在接下来十周内，每周二 19:00 UTC 在 [##taproot-activation][] IRC 频道举行一次讨论会议，主题与激活 [taproot][topic taproot] 的细节相关。首次[会议][activation meeting log]已于 3 月 23 日（本周二）举行。

## 服务和客户端软件的更改

*在本月的特刊中，我们重点介绍比特币钱包和服务的有趣更新。*

- **<!--okcoin-launches-lightning-deposits-and-withdrawals-->****OKCoin 推出闪电网络充值与提现：**
  一篇[博客文章][okcoin lightning blog] 概述了 OKCoin 的闪电网络充值与提现支持。他们还将最低充值/提现门槛从 0.001 BTC 降低至 0.000001 BTC。目前，在通过闪电网络进行交易时，OKCoin 的限额为 0.05 BTC。

- **<!--bitmex-announces-bech32-support-->****BitMEX 宣布支持 bech32：**
  一篇[博客文章][bitmex bech32 blog] 详细说明了 BitMEX 为支持 [bech32][topic bech32] 存款所制定的上线计划。在此之前，BitMEX 已[推出][news77 bitmex bech32 send]了 bech32 提款（发送）支持。

- **<!--specter-v1-2-0-released-->****Specter v1.2.0 发布：**
  [Specter v1.2.0][specter v1.2.0] 支持 Bitcoin Core [描述符（descriptor）钱包][topic descriptors]和币控制特性。

- **<!--breez-streams-audio-for-lightning-payments-->****Breez 通过闪电网络支付实现音频串流：**
  Breez 钱包[集成了一款音频播放器][breez podcast blog]，结合 [keysend（即自发支付）][topic spontaneous payments]，允许用户在收听播客时向出版者进行持续小额支付，同时也可发送一次性的小费支付。

- **<!--key-manager-dux-reserve-announced-->****密钥管理器 Dux Reserve 发布：**
  Thibaud Maréchal [宣布][dux reserve tweet]了 Dux Reserve，一款测试版开源桌面密钥管理器，可在 MacOS、Windows 和 Linux 上运行，并支持 Ledger、Coldcard 和 Trezor 硬件钱包。

- **<!--coldcard-now-using-libsecp256k1-->****Coldcard 现已使用 libsecp256k1：**
  Coldcard 的[4.0.0 版本][coldcard blog 4.0.0]在其他功能之外，也将其加密操作切换为使用 Bitcoin Core 的 [libsecp256k1][] 库。

## 发布与候选发布

*流行的比特币基础设施项目的新版本和候选发布。请考虑升级到新版本或协助测试候选发布。*

- [C-Lightning 0.10.0-rc1][C-Lightning 0.10.0] 是该闪电网络节点软件下一个主版本的候选发布。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的更改。*

- [Bitcoin Core #20861][] 实现了对 [BIP350][]（v1+ 见证地址的 Bech32m 格式）的支持。Bech32m 取代了 bech32（[BIP173][]）作为 1-16 号原生 segwit 输出的地址格式。0 号原生 segwit 输出（P2WPKH 和 P2WSH）仍将使用 bech32。该拉取请求使 Bitcoin Core 用户在 taproot 输出（[BIP341][]）定义于网络中时，能够向支付到 Taproot (P2TR) 地址付款。此更改不应影响任何主网系统，但在已经使用 bech32 编码地址激活 taproot 的测试环境（如 signet）中可能会引发地址不兼容问题。Bech32m 支持也将向下回溯至 Bitcoin Core 0.19、0.20 和 0.21 版本。

- [Bitcoin Core #21141][] 更新了 `-walletnotify` 配置设置，每当加载的钱包中出现相关交易时会调用用户指定的命令。现在可以通过 `%b` 和 `%h` 这两个新占位符向该命令传递区块哈希和区块高度，未确认交易则为定义值。

- [C-Lightning #4428][] 弃用 `fundchannel_complete` RPC 接受 txid 的方式，要求改为传入 [PSBT][topic psbt]。通过检查 PSBT 是否包含资助输出，可避免用户传入错误数据而导致资金无法恢复的[问题][c-lightning #4416]。

- [C-Lightning #4421][] 实现了上周 [Newsletter #140][news140 recovery] 中介绍的资金交易恢复程序。误将资金打入被一方篡改的交易（例如通过 RBF）且尚未使用该通道的用户，现在可向 `lightning-close` 命令提供交易输出，与支持 `shutdown_wrong_funding` 特性的对等方协商恢复。

- [LND #5068][] 提供了一系列新的配置选项，用于限制 LND 处理网络 [gossip](gossip) 信息的数量，这可帮助资源有限的系统。

- [Libsecp256k1 #831][] 实现了一种算法，可将签名验证加速 15%，并能在仍保持恒定时间（最大化侧信道抗性的）算法下将签名生成的时间减少 25%。同时还消除了部分对其他库的依赖。详情请参阅 [Newsletter #136][news136 safegcd] 了解该优化的更多信息。

- [BIPs #1059][] 添加了 [BIP370][]，该 BIP 对版本 2 PSBT 进行了规范，如邮件列表中此前讨论的那样（参见 [Newsletter #128][news128 psbtv2]）。


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
