---
title: 'Bitcoin Optech Newsletter #109'
permalink: /zh/newsletters/2020/08/05/
name: 2020-08-05-newsletter-zh
slug: 2020-08-05-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 介绍了新的 Minsc 策略语言，我们还照例收录了最近转录的演讲与对话、发布与候选发布，以及热门比特币基础设施项目的值得注意的变更。

## 行动项

*本周无行动项。*

## 新闻

- **<!--new-spending-policy-language-->****新的支出策略语言：** Nadav Ivgi [宣布][ivgi minsc]他开发了一种新的语言 Minsc，该语言可以让开发人员更轻松地指定花费 UTXO 所需满足的条件。新语言基于 [miniscript][topic miniscript] 策略语言，但增加了使用变量和函数的功能以及其他几个特性。Minsc 策略可以编译为 miniscript 策略，这些策略又可以编译为 miniscript，从而生成常规的比特币脚本。与 miniscript 的兼容性意味着，用 Minsc 开发的策略将来可以被任何懂 miniscript 的钱包求解，让这些钱包贡献签名、原像或花费比特币所需的其他数据，而无需钱包开发者手动指明如何处理钱包支持的每一种脚本模板。这应当能加快升级到新的语言特性，并大大简化面向 coinjoin、合约协议、共享币所有权以及其他各类理想协作场景的互操作钱包开发。

  Ivgi 还为这门语言做了一个出色的[网站][min.sc]，其中既有大量示例，也有一个实时编译器——它支持直接链接当前输入，方便开发者随手摆弄这门语言，并把自己的 Minsc 策略分享给其他开发者。我们建议对开发支出策略感兴趣的读者去逛逛这个网站；不过为了说明 Minsc 能做什么，下面给出一个改编自 Ivgi 本人示例的例子。几年前，在 miniscript 和 Minsc 出现之前，LN 开发者手工编写了 BOLT3 中规定的如下 [HTLC 脚本][HTLC script]：

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

  Minsc 策略对于大多数开发人员来说要容易分析得多，并且它能够利用 miniscript 将策略转换为比原始手工编写的脚本略小一些的脚本。

## 最近转录的演讲与对话

*[Bitcoin Transcripts][] 汇集了比特币技术演讲与讨论的转录稿。在这个月度栏目中，我们挑选上个月的部分转录稿加以介绍。*

- **<!--raspiblitz-full-node-->****RaspiBlitz 全节点：** Rootzoll 和 Openoms 做客 [Potzblitz][]，介绍 RaspiBlitz——一款运行在树莓派上的比特币与闪电网络全节点（也兼容其他硬件）。Openoms 演示了可以在 RaspiBlitz 上安装的一些应用和服务，例如 [ThunderHub][] 和 [Balance of Satoshis][]。Rootzoll 解释了 IP2TOR 订阅服务如何解决一个难题：如何让移动钱包连上运行在家庭网络里的 RaspiBlitz 全节点。（[转录][rb transcript]、[视频][rb video]、[幻灯片][rb slides]）

- **<!--chicago-meetup-discussion-->****芝加哥聚会讨论：** 匿名化的参与者讨论了多种闪电网络攻击，包括 [flood and loot][]、手续费勒索、[交易钉住][topic transaction pinning]、原像拒绝（参见 [Newsletter #95][news95 LN payment atomicity]）和时间膨胀（参见 [Newsletter #101][news101 LN time dilation]）。面对这些严重程度各异的攻击，大家争论了当前用户该怎么做才能在闪电网络上保护自己，以及从更长远的眼光看什么样的缓解措施才算够用。诸如[交易包中继][topic package relay]、[锚定输出][topic anchor outputs] 和重构 Bitcoin Core 内存池等方案正在推进——但未来数月乃至数年，链上层与闪电网络层都还需要付出更多努力。（[转录][chicago transcript]）

- **<!--sapio-->****Sapio：** Jeremy Rubin 在虚拟现实环境 Reckless VR 中介绍了 Sapio。Sapio 是一门新的高级编程语言，专为借助 [OP_CHECKTEMPLATEVERIFY][topic OP_CHECKTEMPLATEVERIFY] 构建有状态的智能合约而设计。Rubin 以 Blockstream 的 Liquid 侧链最近一次时间锁[问题][timelock issue] 为案例，说明 Sapio 与 OP_CHECKTEMPLATEVERIFY 理论上如何能防止资金意外转入那个 2-of-3 多重签名紧急备份。（[转录][sapio transcript]、[视频][sapio video]、[幻灯片][sapio slides]）

- **<!--sydney-meetup-discussion-->****悉尼聚会讨论：** 匿名化的参与者讨论了过去几个月 Bitcoin Core 构建系统中已修复的 bug，以及鉴于公证（notarization）要求和苹果从 Intel 处理器转向 ARM 处理器，未来在 macOS 上构建和分发 Bitcoin Core 二进制程序将面临的挑战。其他话题包括 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 提案的更新、泛化的比特币兼容通道，以及关于 taproot 激活的最新思考。（[转录][sydney transcript]）

- **<!--bip-taproot-->****BIP-Taproot：** Pieter Wuille 和 Russell O’Connor 参加了由 London BitDevs 与 Bitcoin Munich 联合举办的活动，回顾了 [MAST][topic MAST] 最初的构想如何演变为最终的 [taproot][topic Taproot] 提案。Wuille 讲到他个人的动机如何从推动跨输入签名聚合，转向增强复杂交易的隐私与效率。O’Connor 还介绍了 Simplicity 语言的开发进展（参见 [Newsletter #96][news96 simplicity]）。他推测未来几年 Simplicity 可能如何作为一种 Tapleaf 版本落地，并用于委托、[契约][topic covenants] 以及当前用 Bitcoin Script 无法实现的其他功能。libsecp256k1 中 [schnorr 签名][topic schnorr signatures] 的 [PR][libsecp256k1 #558] 以及 Bitcoin Core 中的 taproot [PR][Bitcoin Core #17977] 正在征求更多审查，O’Connor 鼓励社区在任何可能的部署之前尽早考虑 taproot 会破坏自家软件的哪些地方。（[转录][london/munich transcript]、[视频][london/munich video]）

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [C-Lightning 0.9.0][C-Lightning 0.9.0] 是 C-Lightning 最新的主要版本。它新增了对更新版 `pay` 命令和新 `keysend` RPC 的支持，两者都在 [Newsletter #107][news107 notable] 中介绍过。它还包含若干其他值得注意的变更和多项错误修复。

- [Bitcoin Core 0.20.1][Bitcoin Core 0.20.1] 是一个新的维护版本。除了错误修复以及这些修复带来的一些 RPC 行为变化之外，计划发布的版本还兼容较新版本的 [HWI][topic HWI]，并能用上 HWI 对为应对[手续费超额支付攻击][fee overpayment attack] 而发布的硬件钱包固件的支持。

- [LND 0.11.0-beta.rc1][LND 0.11.0-beta] 是一个新大版本的首个候选发布。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi]、[比特币改进提案（BIPs）][bips repo]和[闪电网络 BOLT 规范][bolts repo]中的值得注意的变更。*

- [Bitcoin Core #19569][] 允许 Bitcoin Core 从使用 wtxid 中继交易的对等方获取 _孤儿_ 交易的父交易。孤儿交易是指从一个对等方接收到的未确认交易，但我们尚未获得其父交易，既不在我们的最佳区块链中，也不在内存池中。更准确地说，孤儿交易至少有一个交易输入，其关联的输出不在 UTXO 集合或我们内存池的 outpoint 映射中。

  当我们收到一个孤儿交易时，我们将其放在一个称为孤儿集的临时数据结构中。然后我们要求发送孤儿交易的对等方也发送我们尚未拥有的父交易。我们可以这样做是因为孤儿交易包含其父交易的 txid。我们只需向对等方发送一个包含这些 txid 的 `getdata` 消息来请求父交易。

  对于 [wtxid 中继对等节点][news108 wtxid relay]，交易是用 _wtxid_ 而非 _txid_ 来公告和请求的。然而，孤儿交易里带的是父交易的 txid 而非 wtxid，因此无法用 wtxid 请求父交易。上周合并的 [PR #18044][Bitcoin Core #18044] 引入了 wtxid 中继对等节点，却不允许从 wtxid 对等节点获取父交易。这个后续 PR 让我们可以用 txid 去获取这些父交易。

  用 txid 获取父交易的做法，最终可能会被[交易包中继][topic package relay]机制取代——那时可以直接向对等节点请求一笔交易的全部未确认祖先。

- [Eclair #1491][] 部分支持创建、使用和关闭采用[锚定输出][topic anchor outputs] 的通道，既能减少正常情况下的链上手续费，又能在需要时为安全考虑提高手续费。此实现覆盖了所有基础功能，但尚不支持双方共同关闭通道或真正的手续费追加；这些会后续加入。此外，与 LND 实现的互操作性测试暴露出一种情况，需要在[规范][anchor spec discuss]中加以澄清。

- [LND #4488][] 把用户可设置的最小 CLTV 过期差值下调到 18 个区块，以符合[更新后的建议值][BOLTs #785]。默认值仍为 40 个区块。当距离一笔 LN 支付必须结算只剩这么多区块时，LND 会单方面关闭通道，确保最新状态被记录到链上。然而，过期差值越高，支付可能在通道里暂时卡住的时间就越长（无论出于意外还是有意为之）。这促使一些 LN 实现改用偏好低 CLTV 过期差值的路径查找算法，进而又让一些用户把差值设成特别不安全的数值。新的下限应当有助于防止没有经验的用户轻率地设出危险的值。

- [BIPs #948][] 更新了 [BIP174][] 中关于 [PSBT][topic psbt] 输入记录的规范，明确允许为同一个输入同时提供非见证 UTXO（完整交易）和见证 UTXO。这与 Bitcoin Core 的[当前行为][news105 fee overpayment]一致，起因于一种可能性：对未包含非见证 UTXO 的多输入 segwit PSBT 可能发起手续费超额支付攻击，详见[之前的 Newsletter][fee overpayment attack]。

- [BIPs #947][] 更新了 [BIP325][] 中 [signet][topic signet] 的规范，更换了区块签名的验证方法。signet 是一类测试网络，其有效区块由受信任的签名者签名；这一改动消除了一些问题，也让某些类型的测试更容易。

  此前，signet 假定使用与传统 Bitcoin Script 兼容的签名（例如 DER 编码的 ECDSA 签名）。改动之后，signet 改用一对虚拟交易——这类交易在区块链上无效，也不会被打包进区块，但比特币软件可以轻松构造（直接构造，或借助 [PSBT][topic PSBT]）。第一笔交易承诺向该网络的受信任签名者脚本付款；第二笔虚拟交易随后花费第一笔虚拟交易的输出。区块的 币基交易中会包含第二笔虚拟交易的签名，以证明该区块确实被有效签署。

  这种新方法的主要好处是可以用上 segwit 交易。当前 segwit v0 可用的操作码几乎与传统脚本完全一致 <!-- 我认为唯一的变化是 OP_CODESEPARATOR -->，所以这看起来也许无关紧要——但如果 segwit v1（[taproot][topic taproot]）能在某个 signet 上启用，就可以用 [schnorr 签名][topic schnorr signatures] 来签署区块。由于未来的协议变更多半也会使用 segwit，这些特性同样能用得上。次要的好处是，任何能为任意输入签署 PSBT 的软件或硬件，现在都能充当 signet 的受信任签名者。

{% include references.md %}
{% include linkers/issues.md issues="19569,1491,4488,948,947,785,18044,558,17977" %}
[C-Lightning 0.9.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.9.0
[Bitcoin Core 0.20.1]: https://bitcoincore.org/bin/bitcoin-core-0.20.1/
[LND 0.11.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.11.0-beta.rc1
[fee overpayment attack]: /zh/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[news105 fee overpayment]: /zh/newsletters/2020/07/08/#bitcoin-core-19215
[news107 notable]: /zh/newsletters/2020/07/22/#值得注意的代码与文档变更
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
