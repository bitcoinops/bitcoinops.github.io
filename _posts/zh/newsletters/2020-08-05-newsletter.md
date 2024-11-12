---
title: 'Bitcoin Optech Newsletter #109'
permalink: /zh/newsletters/2020/08/05/
name: 2020-08-05-newsletter-zh
slug: 2020-08-05-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了新的 Minsc 策略语言，并包含最近转录的演讲和对话、发布与候选发布，以及一些流行的比特币基础设施项目的值得注意的更改。

## 行动项

*本周无行动项。*

## 新闻

- **<!--new-spending-policy-language-->****新的支出策略语言：** Nadav Ivgi [宣布][ivgi minsc]他开发了一种新的语言 Minsc，该语言可以让开发人员更轻松地指定花费 UTXO 所需满足的条件。新语言基于 [miniscript][topic miniscript] 策略语言，但增加了使用变量和函数的功能以及其他几个特性。Minsc 策略可以编译为 miniscript 策略，这些策略又可以编译为 miniscript，从而生成常规的比特币脚本。与 miniscript 的兼容性意味着使用 Minsc 开发的策略在未来可以被任何支持 miniscript 的钱包解析，从而让钱包贡献签名、原像或花费比特币所需的其他数据，而不需要开发人员手动指定如何处理每个特定的脚本模板。这应当能加快对新语言特性的升级，并大大简化用于 Coinjoin、合约协议、共享币所有权及其他类型的协作的钱包的互操作性开发。

  Ivgi 还为该语言创建了一个出色的[网站][min.sc]，其中包含丰富的示例和一个实时编译器，该编译器允许链接输入，以便开发人员可以轻松地玩转该语言并与其他开发人员分享他们的 Minsc 策略。我们建议任何对开发支出策略感兴趣的人访问该网站，但为了说明 Minsc 的功能，我们提供了一个来自 Ivgi 自身示例的改编示例。几年前，在 miniscript 和 Minsc 出现之前，LN 开发者手工编写了以下 [HTLC 脚本][HTLC script]，它在 BOLT3 中有详细描述：

  ```python
  # 使用撤销密钥发送给远程节点
  OP_DUP OP_HASH160 <RIPEMD160(SHA256(revocationpubkey))> OP_EQUAL
  OP_IF
      OP_CHECKSIG
  OP_ELSE
      <remote_htlcpubkey> OP_SWAP OP_SIZE 32 OP_EQUAL
      OP_IF
          # 通过 HTLC-success 交易发送给本地节点
          OP_HASH160 <RIPEMD160(payment_hash)> OP_EQUALVERIFY
          2 OP_SWAP <local_htlcpubkey> 2 OP_CHECKMULTISIG
      OP_ELSE
          # 超时后发送给远程节点
          OP_DROP <cltv_expiry> OP_CHECKLOCKTIMEVERIFY OP_DROP
          OP_CHECKSIG
      OP_ENDIF
  OP_ENDIF
  ```

  可以使用以下 Minsc 策略（将 `cltv_expiry` 设定为 3 小时）[指定][htlc minsc]相同的限制条件：

  ```hack
  fn htlc_received($revocationpubkey, $local_htlcpubkey,
                   $remote_htlcpubkey, $payment_hash,
                   $cltv_expiry)
  {
    // 通过 HTLC-success 交易发送给本地节点
    $success = pk($local_htlcpubkey) && hash160($payment_hash);

    // 超时后发送给远程节点
    $timeout = older($cltv_expiry);

    // 使用撤销密钥发送给远程节点，或使用 success/timeout
    pk($revocationpubkey) || (pk($remote_htlcpubkey) && ($success || $timeout))
  }

  htlc_received(A, B, C, H, 3 hours)
  ```

  Minsc 策略对于大多数开发人员来说要容易分析得多，并且它能够利用 miniscript 将策略转换为比原始手工编写的脚本更小的脚本。

## 最近转录的演讲和对话

*[Bitcoin Transcripts][] 是技术性比特币演讲和讨论的转录库。在本月的特辑中，我们重点介绍了上个月的一些精选转录内容。*

- **<!--raspiblitz-full-node-->****RaspiBlitz 全节点：** Rootzoll 和 Openoms 出现在 [Potzblitz][] 节目中，介绍了 RaspiBlitz，这是一款基于树莓派构建的比特币和闪电网络全节点（也兼容其他硬件）。Openoms 探讨了你可以在 RaspiBlitz 上安装的一些应用和服务，如 [ThunderHub][] 和 [Balance of Satoshis][]。Rootzoll 解释了 IP2TOR 订阅服务如何解决在家庭网络上运行的 RaspiBlitz 全节点与移动钱包连接的问题。([转录][rb transcript]、[视频][rb video]、[幻灯片][rb slides])

- **<!--chicago-meetup-discussion-->****芝加哥聚会讨论：** 参与者匿名讨论了多种闪电网络攻击，包括 [flood and loot][]、费用勒索、[交易固定][topic transaction pinning]、原像拒绝（参见 [Newsletter #95][news95 LN payment atomicity]）和时间膨胀（参见 [Newsletter #101][news101 LN time dilation]）。针对这些不同程度的攻击，讨论了当前用户在闪电网络上应如何保护自己，以及从长远来看哪些措施是足够的。诸如 [package relay][topic package relay]、[anchor outputs][topic anchor outputs] 和重新设计 Bitcoin Core 的内存池等解决方案正在进行中，但在链上层和闪电层还需要更多的工作。([转录][chicago transcript])

- **<!--sapio-->****Sapio：** Jeremy Rubin 在 Reckless VR 上展示了 Sapio，这是一种新的高级编程语言，专为构建带有 [OP_CHECKTEMPLATEVERIFY][topic OP_CHECKTEMPLATEVERIFY] 的状态智能合约而设计。Rubin 使用 Blockstream 的 Liquid 侧链最近的时间锁 [问题][timelock issue] 案例研究，解释了 Sapio 和 OP_CHECKTEMPLATEVERIFY 理论上如何防止资金意外转移到 2-of-3 多重签名紧急备份中。([转录][sapio transcript]、[视频][sapio video]、[幻灯片][sapio slides])

- **<!--sydney-meetup-discussion-->****悉尼聚会讨论：** 参与者匿名讨论了过去几个月中 Bitcoin Core 构建系统中的已解决错误，以及在 MacOS 上构建和分发 Bitcoin Core 二进制文件面临的未来挑战，特别是关于认证要求以及苹果从 Intel 处理器过渡到 ARM 处理器的问题。其他话题包括 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 提案的更新、通用比特币兼容通道，以及关于 taproot 激活的最新思考。([转录][sydney transcript])

- **<!--bip-taproot-->****BIP-Taproot：** Pieter Wuille 和 Russell O’Connor 参加了由 London BitDevs 和 Bitcoin Munich 共同组织的活动，探讨了 [MAST][topic MAST] 原始想法如何演变为最终的 [taproot][topic Taproot] 提案。Wuille 讲述了他个人动机从寻求实现跨输入签名聚合转变为增强更复杂交易的隐私和效率的过程。O’Connor 还更新了 Simplicity 语言的开发进展（参见 [Newsletter #96][news96 simplicity]）。他推测 Simplicity 可能如何作为 Tapleaf 版本实现，并用于委托、[契约][topic covenants]以及当前比特币脚本无法实现的其他功能。[libsecp256k1 #558] 中的 [schnorr 签名][topic schnorr signatures] PR 和 Bitcoin Core 中的 taproot [PR][Bitcoin Core #17977] 正在寻求进一步的审查，O’Connor 鼓励社区提前考虑 taproot 可能会在他们的软件中带来的破坏。([转录][london/munich transcript]、[视频][london/munich video])

## 发布与候选发布

*流行比特币基础设施项目的新发布和候选发布。请考虑升级到新版本或帮助测试候选发布。*

- [C-Lightning 0.9.0][C-Lightning 0.9.0] 是 C-Lightning 的最新主要版本。它增加了对更新的 `pay` 命令和新的 `keysend` RPC 的支持，这两者均在 [Newsletter #107][news107 notable] 中进行了描述。它还包括其他几个值得注意的更改和多个错误修复。

- [Bitcoin Core 0.20.1][Bitcoin Core 0.20.1] 是一个新的维护版本。除了错误修复和由于这些修复引起的一些 RPC 行为更改外，计划的发布还提供了与 [HWI][topic HWI] 的最新版本兼容性，并支持硬件钱包固件中的[手续费超额支付攻击][fee overpayment attack]。

- [LND 0.11.0-beta.rc1][LND 0.11.0-beta] 是新主要版本的第一个候选发布。

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口 (HWI)][hwi]、[比特币改进提案（BIPs)][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #19569][] 允许 Bitcoin Core 从使用 wtxid 中继交易的对等方获取 _孤儿_ 交易的父交易。孤儿交易是指从一个对等方接收到的未确认交易，但我们尚未获得其父交易，既不在我们的最佳区块链中，也不在内存池中。更准确地说，孤儿交易至少有一个交易输入，其关联的输出不在 UTXO 集合或我们内存池的 outpoint 映射中。

  当我们收到一个孤儿交易时，我们将其放在一个称为孤儿集的临时数据结构中。然后我们要求发送孤儿交易的对等方也发送我们尚未拥有的父交易。我们可以这样做是因为孤儿交易包含其父交易的 txid。我们只需向对等方发送一个包含这些 txid 的 `getdata` 消息来请求父交易。

  对于 [wtxid 中继对等方][news108 wtxid relay]，交易使用 _wtxid_ 而非 _txid_ 来通告和请求。然而，孤儿交易包含的是其父交易的 txid 而非 wtxid，因此无法使用 wtxid 请求父交易。上周合并的 [PR #18044][Bitcoin Core #18044] 引入了 wtxid 中继对等方，但并未允许从 wtxid 对等方获取父交易。该后续 PR 允许我们使用 txid 来获取这些父交易。

  使用 txid 获取父交易可能最终会被[包中继][topic package relay]机制取代，通过该机制我们可以直接向对等方请求所有未确认的祖先交易。

- [Eclair #1491][] 增加了部分支持创建、使用和关闭使用[锚定输出][topic anchor outputs]的通道，以在正常情况下减少链上交易费用，并在必要时提高费用以确保安全。此实现处理了所有基本内容，但尚不支持双边通道关闭或实际的费用提升；这些将稍后添加。此外，与 LND 实现的互操作性测试揭示了一个需要在[规范][anchor spec discuss]中澄清的情况。

- [LND #4488][] 更新了用户可以设置的最小 CLTV 过期差值至 18 个区块，以符合更新的[推荐值][BOLTs #785]。默认值仍为 40 个区块。当 LN 支付的结算截止时间仅剩这些区块时，LND 将单方面关闭通道以确保最新状态记录在链上。然而，过期差值越高，支付在通道中暂时卡住的时间就越长（无论是意外还是故意）。这导致一些 LN 实现使用优化低 CLTV 过期差值的路由算法，进而导致一些用户设置了特别不安全的差值。这个新的最小值应当有助于防止没有经验的用户轻率地设置不安全的值。

- [BIPs #948][] 更新了 [BIP174][] 规范中的 [PSBT][topic psbt] 输入记录，明确允许为单个输入同时提供非见证 UTXO（完整交易）和见证 UTXO。这与 Bitcoin Core 中的[当前行为][news105 fee overpayment]一致，其动机是防止在未包含非见证 UTXO 的多输入 segwit PSBT 上发生的多付费用攻击（详见[之前的 Newsletter][fee overpayment attack]）。

- [BIPs #947][] 更新了 [BIP325][] 规范中的 [signet][topic signet]，更改了区块签名验证方法。Signet 是一个测试网络，其中有效区块由受信任的签名者签署，这一变化消除了某些问题并简化了某些类型的测试。

  之前，signet 假定使用与传统比特币脚本兼容的签名（例如 DER 编码的 ECDSA 签名）。此更改后，signet 改为使用一对虚拟交易——这些交易在区块链上无效，也不会被包含在区块中，但比特币软件可以轻松构建（直接或使用 [PSBT][topic PSBT]）。第一个交易承诺支付给网络的受信任签名者脚本。第二个虚拟交易随后花费第一个虚拟交易的输出。第二个虚拟交易的签名被包含在区块的 coinbase 交易中，以证明区块已被有效签署。

  这种新方法的主要优势在于它允许使用 segwit 交易。当前 segwit v0 中可用的操作码几乎与传统脚本完全相同 <!-- 我认为唯一的变化是 OP_CODESEPARATOR -->，因此这看起来可能无关紧要——但如果 segwit v1（[taproot][topic taproot]）在 signet 上可用，这将允许使用 [schnorr 签名][topic schnorr signatures]来签署区块。未来的协议更改可能也会使用 segwit，这将允许这些功能得到使用。次要的优势是，任何能够为任意输入签署 PSBT 的软件或硬件现在都可以作为 signet 的受信任签名者运行。

{% include references.md %}
{% include linkers/issues.md issues="19569,1491,4488,948,947,785,18044,558,17977" %}
[C-Lightning 0.9.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.9.0
[Bitcoin Core 0.20.1]: https://bitcoincore.org/bin/bitcoin-core-0.20.1/
[LND 0.11.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.11.0-beta.rc1
[fee overpayment attack]: /zh/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[news105 fee overpayment]: /zh/newsletters/2020/07/08/#bitcoin-core-19215
[news107 notable]: /zh/newsletters/2020/07/22/#值得注意的代码和文档更改
[anchor spec discuss]: https://github.com/lightningnetwork/lightning-rfc/pull/688#issuecomment-661669232
[ivgi minsc]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-July/018062.html
[min.sc]: https://min.sc
[htlc script]: https://github.com/lightningnetwork/lightning-rfc/blob/master/03-transactions.md#received-htlc-outputs
[htlc minsc]: https://min.sc/#c=fn%20htlc_received%28%24revocationpubkey%2C%20%24local_htlcpubkey%2C%20%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%24remote_htlcpubkey%2C%20%24payment_hash%2C%0A%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%20%24cltv_expiry%29%0A%7B%0A%20%20%2F%2F%20To%20local%20node%20via%20HTLC-success%20transaction%0A%20%20%24success%20%3D%20pk%28%24local_htlcpubkey%29%20%26%26%20hash160%28%24payment_hash%29%3B%0A%0A%20%20%2F%2F%20To%20remote%20node%20after%20timeout%0A%20%20%24timeout%20%3D%20older%28%24cltv_expiry%29%3B%0A%0A%20%20%2F%2F%20To%20remote%20node%20with%20revocation%20key%2C%20or%20use%20success%2Ftimeout%20with%20remote%20consent%0A%20%20pk%28%24revocationpubkey%29%20%7C%7C%20%28pk%28%24remote_htlcpubkey%29%20%26%26%20%28%24success%20%7C%7C%20%24timeout%29%29%0A%7D%0A%0Ahtlc_received%28A%2C%20B%2C%20C%2C%20H%2C%203%20hours%29
[news108 wtxid relay]: /zh/newsletters/2020/07/29/#bitcoin-core-18044
[rb transcript]: https://diyhpl.us/wiki/transcripts/lightning-hack-day/2020-06-21-rootzoll-openoms-raspiblitz/
[rb video]: https://www.youtube.com/watch?v=1EqUi4xRbr0
[rb slides]: https://keybase.pub/oms/Potzblitz9-RaspiBlitz-slides.pdf
[chicago transcript]: https://diyhpl.us/wiki/transcripts/chicago-bitdevs/2020-07-08-socratic-seminar/
[news95 ln payment atomicity]: /zh/newsletters/2020/04/29/#new-attack-against-ln-payment-atomicity
[news101 ln time dilation]: /zh/newsletters/2020/06/10/#time-dilation-attacks-against-ln
[sapio transcript]: https://diyhpl.us/wiki/transcripts/vr-bitcoin/2020-07-11-jeremy-rubin-sapio-101/
[sapio video]: https://www.youtube.com/watch?v=4vDuttlImPc
[sapio slides]: https://docs.google.com/presentation/d/1X4AGNXJ5yCeHRrf5sa9DarWfDyEkm6fFUlrcIRQtUw4/
[timelock issue]: https://medium.com/blockstream/patching-the-liquid-timelock-issue-b4b2f5f9a973
[sydney transcript]: https://diyhpl.us/wiki/transcripts/sydney-bitcoin-meetup/2020-07-21-socratic-seminar/
[london/munich transcript]: https://diyhpl.us/wiki/transcripts/london-bitcoin-devs/2020-07-21-socratic-seminar-bip-taproot/
[london/munich video]: https://www.youtube.com/watch?v=bPcguc108QM
[news96 simplicity]: /zh/newsletters/2020/05/06/#simplicity-next-generation-smart-contracting
[potzblitz]: https://www.youtube.com/channel/UCqUfpNS9-dzAvobqhviX39w
[flood and loot]: https://arxiv.org/abs/2006.08513
[thunderhub]: https://www.thunderhub.io/
[balance of satoshis]: https://github.com/alexbosworth/balanceofsatoshis
[hwi]: https://github.com/bitcoin-core/HWI
