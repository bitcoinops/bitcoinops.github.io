---
title: 'Bitcoin Optech Newsletter #157'
permalink: /zh/newsletters/2021/07/14/
name: 2021-07-14-newsletter-zh
slug: 2021-07-14-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 概述了关于一项新提议操作码的讨论，并链接到一个更新后的、用于追踪 bech32m 支持的 Wiki 页面。文中还包括我们的常规栏目：Bitcoin Core PR 审查俱乐部会议要点、为 taproot 做准备的建议，以及热门比特币基础设施项目值得注意的变更。

## 新闻

- **<!--request-for-op-checksigfromstack-design-suggestions-->****征求 `OP_CHECKSIGFROMSTACK` 设计建议：** Jeremy Rubin 在 Bitcoin-Dev 邮件列表上[发帖][rubin csfs]，给出了一份 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] 操作码的草案规范，并邀请更倾向于其他设计的开发者提供反馈。讨论中提到了若干替代方案，但也延伸到是否应同时引入 [OP_CAT][] 操作码。

  `OP_CAT` 和 `OP_CSFS` 可以实现任意交易内省——即把比特币支付到一个脚本，而该脚本能检查日后花费这些比特币的交易几乎任何部分。这可以支持许多高级特性（包括 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 和 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 等其他拟议升级的某些实现版本[^expensive]），但 `OP_CAT` 也让创建递归[契约][topic covenants]成为可能，而这类契约可能永久限制锁定其中的比特币的可花费性。有人[反对][rubin cost/benefit]在比特币中允许契约，但也有人[提出论据][harding altcoins]，[认为][towns multisig]递归契约的最坏情况在今天的比特币中已经存在，因此不必担心启用 `OP_CAT` 或类似操作码。

  尽管有这些讨论，Rubin 仍决定让 `OP_CSFS` 提案独立于任何添加 `OP_CAT` 的提案，[认为][rubin just csfs]仅 `OP_CSFS` 本身就足够有用。

- **<!--tracking-bech32m-support-->****跟踪 bech32m 支持：** Bitcoin Wiki 上的 [bech32 采用情况][wiki bech32 adoption]页面已[更新][erhardt bech32m tweet]，以跟踪支持向 [bech32m][topic bech32] 地址（用于 taproot）发送和接收的各软件与服务。

## Bitcoin Core PR 审查俱乐部

*在本月度栏目中，我们总结了一次最近的 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议的情况，并重点介绍了一些重要的问答。点击下面的问题即可查看会议中的答案摘要。*

[Use script_util helpers for creating P2{PKH,SH,WPKH,WSH} scripts][review club #22363] 是 Sebastian Falbesoner 提交的一个 PR，用 `script_util` 辅助函数替换功能测试中的手工脚本创建，并修复了 `get_multisig()` 函数中的一个错误。会议逐项解释了该 PR 涉及的术语和各脚本输出类型。

{% include functions/details-list.md

  q0="**<!--q0-->**`script_util.py` 中的 `key_to_p2pkh_script`、`script_to_p2sh_script`、`key_to_p2wpkh_script` 和 `script_to_p2wsh_script` 分别做什么？"
  a0="这些是用于构建 Pay to Public Key Hash、Pay to Script Hash、Pay to Witness Public Key Hash 以及 Pay to Witness Script Hash 脚本（CScript 对象）的辅助函数，输入为公钥或脚本。"
  a0link="https://bitcoincore.reviews/22363#l-17"

  q1="**<!--q1-->**请定义 scriptPubKey、scriptSig 和 witness。"
  a1="scriptPubKey 和 scriptSig 分别是交易输出和输入中的字段，用于指定并满足花费条件。witness 是一个为同样目的而设置的附加字段，由隔离见证引入。花费要求在输出的 scriptPubKey 中被承诺，花费该输出的输入必须在 scriptSig 和/或 witness 中提供满足这些要求的数据。"
  a1link="https://bitcoincore.reviews/22363#l-31"

  q2="**<!--q2-->**请定义 redeem script 和 witness script。它们之间是什么关系？"
  a2="P2SH 和 P2WSH 输出类型会在 scriptPubKey 中承诺一个脚本哈希。花费该输出时，付款方必须提供脚本本身，以及让它通过所需的签名或其他数据。该脚本出现在 scriptSig 中时称为 redeemScript，出现在 witness 中时称为 witness script。从这个角度说，二者是类似的：redeemScript 之于 P2SH 输出，相当于 witness script 之于 P2WSH 输出。但它们并不互斥，因为花费 P2SH-P2WSH 输出的交易会同时包含两者。"
  a2link="https://bitcoincore.reviews/22363#l-55"

  q3="**<!--q3-->**要把币发送给某个人，而花费条件编码在脚本中，输出的 scriptPubKey 里包含什么？花费这笔币时，输入需要提供什么？"
  a3="scriptPubKey 中包含脚本哈希和用于验证匹配的操作码：`OP_HASH160 OP_PUSHBYTES_20 <20B script hash> OP_EQUAL`。而 scriptSig 则包含脚本本身及初始堆栈数据。"
  a3link="https://bitcoincore.reviews/22363#l-102"

  q4="**<!--q4-->**我们为什么使用 Pay-To-Script-Hash 而不是 Pay-To-Script？"
  a4="正如 [BIP16][] 中所述，这么做的核心动机是提供一种通用方式，为任意复杂度的交易提供资金，同时把提供花费条件的负担留给赎回资金的一方。与会者也提到，把脚本排除在 scriptPubKey 之外，意味着相关手续费要到赎回时才支付，而且能使 UTXO 集更小。"
  a4link="https://bitcoincore.reviews/22363#l-112"

  q5="**<!--q5-->**当一个不支持隔离见证的节点验证一个 P2SH-P2WSH 输入时，它会做什么？而一个支持隔离见证的节点又会多做什么？"
  a5="不支持隔离见证的节点看不到 witness；它只执行 P2SH 的规则，验证 redeemScript 与 scriptPubKey 中提交的哈希是否匹配。支持隔离见证的节点则能识别出这是一个见证程序，并利用 witness 中的数据和相应的 scriptCode 来执行隔离见证规则。"
  a5link="https://bitcoincore.reviews/22363#l-137"

  q6="**<!--q6-->**在原始的 [`get_multisig()`](https://github.com/bitcoin/bitcoin/blob/091d35c70e88a89959cb2872a81dfad23126eec4/test/functional/test_framework/wallet_util.py#L109) 函数中，那个 P2SH-P2WSH 脚本有何问题？"
  a6="它在 P2SH-P2WSH 的 redeemScript 中直接使用了 witness script，而非其哈希值。"
  a6link="https://bitcoincore.reviews/22363#l-153"
%}

## 准备 Taproot #4：从 P2WPKH 到单签 P2TR

*这是一个[系列][series preparing for taproot]的每周内容，介绍在区块高度 {{site.trb}} 激活 taproot 前，开发者和服务提供商如何做好准备。*

{% include specials/taproot/zh/03-p2wpkh-to-p2tr.md %}

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LND 0.13.1-beta.rc2][LND 0.13.1-beta] 是一个维护版本，针对 0.13.0-beta 中引入的功能进行了少量改进与错误修复。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中值得注意的变更。*

- [C-Lightning #4625][] 更新了其 [LN offers][topic offers] 实现，以匹配最新的[规范变更][offers spec changes]。值得注意的是，offers 不再需要包含签名。这显著缩短了 offers 的编码字符串，从而改善二维码的可识别度。

- [Eclair #1746][] 增加了将数据并行复制到 PostgreSQL 数据库的功能，与主 SQLite 数据库同时使用。该功能旨在便于那些最终打算迁移后端的服务器进行测试。去年，Suredbits 工程师 Roman Taranchenko 在 Optech 的[实地报告][suredbits enterprise ln]中介绍了如何为 Eclair 定制 PostgreSQL 后端以满足企业需求。

- [LND #5447][] 新增了一份[文档][lnd leader]，介绍如何在集群中部署多个 LND 节点，并使用一种在集群节点间复制的替代数据库，以支持自动故障切换。感兴趣的读者可以对比 [Newsletter #128][news128 eclair akka] 中介绍的 Eclair 做法。

- [Libsecp256k1 #844][] 对 [schnorr 签名][topic schnorr signatures] 的 API 做了多项更新，其中最值得注意的是一个[提交][nick varsig]，它允许对任意长度的消息进行签名与验证。目前比特币中的所有签名都针对 32 字节哈希，但允许对可变长度数据签名，可能对 Bitcoin 之外的应用有用，也可能让 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] 这类新操作码能够[验证][oconnor var csfs]为非比特币系统创建的签名。预计 [BIP340][]（比特币的 schnorr 签名规范）会更新，以说明如何安全地对可变长度数据签名。

- [BIPs #943][] 更新了 [BIP118][]，改为基于即将激活的 taproot 和 tapscript，而不再基于 segwit v0。此外，本次修订把标题从 SIGHASH_NOINPUT 改为 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]，以反映该签名哈希标志现在被称为“ANYPREVOUT”——虽然签名可能适用于任何前置输出，但输入的部分内容仍会被承诺。

- [BTCPay Server #2655][] 告知网页浏览器：当用户点击指向[区块浏览器][topic block explorers]中某笔交易的链接时，不要发送 HTTP `referer` <!-- sic --> 字段。这样就避免告诉区块浏览器用户来自哪个 BTCPay 服务器——而这一信息正是“该服务器发起或接收了这笔交易”的有力证据。即便如此，对隐私有较高需求的用户仍应避免在第三方区块浏览器中查询自己的交易。

## 脚注

[^expensive]:
    使用 `OP_CHECKSIGFROMSTACK`（`OP_CSFS`）实现 [BIP118][] 的 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 或 [BIP119][] 的 [OP_CHECKTEMPLATEVERIFY][topic op_checksigfromstack] 等提案的主要特性时，如果采用 scriptpath 花费，占用的区块空间会比这些经过优化的提案更多。[支持][news48 generic csfs] `OP_CSFS` 的理由是：可以先引入通用构造，证明人们确实会使用该功能，再通过共识变更加入更高效的实现。此外，随着 [taproot][topic taproot] 引入 keypath 花费，任何脚本在某些情况下都能以最少的区块空间完成，从而可能减少对那些只在非最优情形下节省空间的特定构造的需求。

{% include references.md %}
{% include linkers/issues.md issues="4625,5447,844,1746,943,2655,22363" %}
[LND 0.13.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.13.1-beta.rc2
[bip341 cite22]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#cite_ref-22-0
[News128 eclair akka]: /zh/newsletters/2020/12/16/#eclair-1566
[oconnor var csfs]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019193.html
[erhardt bech32m tweet]: https://twitter.com/murchandamus/status/1413687483246776322
[wiki bech32 adoption]: https://en.bitcoin.it/wiki/Bech32_adoption
[rubin csfs]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019192.html
[harding altcoins]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019203.html
[towns multisig]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019209.html
[rubin just csfs]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019229.html
[lnd leader]: https://github.com/bhandras/lnd/blob/f41771ce54bb7721101658477ad538991fc99fe6/docs/leader_election.md
[nick varsig]: https://github.com/bitcoin-core/secp256k1/pull/844/commits/a0c3fc177f7f435e593962504182c3861c47d1be
[news48 generic csfs]: /zh/newsletters/2019/05/29/#not-generic-enough
[rubin cost/benefit]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-July/019200.html
[offers spec changes]: https://github.com/lightningnetwork/lightning-rfc/pull/798#issuecomment-871124755
[suredbits enterprise ln]: /zh/suredbits-enterprise-ln/
[series preparing for taproot]: /zh/preparing-for-taproot/
