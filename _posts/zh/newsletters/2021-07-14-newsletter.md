---
title: 'Bitcoin Optech Newsletter #157'
permalink: /zh/newsletters/2021/07/14/
name: 2021-07-14-newsletter-zh
slug: 2021-07-14-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 概述了关于一个新提案 opcode 的讨论，并链接到一个更新后的用于追踪 bech32m 支持的维基页面。文中还包括我们的常规部分，其中包含来自一次 Bitcoin Core PR 审查俱乐部会议的重点内容、关于如何为 taproot 做准备的建议，以及对一些流行比特币基础设施项目值得注意的更改的描述。

## 新闻

- **<!--request-for-op-checksigfromstack-design-suggestions-->****请求对 `OP_CHECKSIGFROMSTACK` 设计建议：** Jeremy
  Rubin [公告][rubin csfs]到 Bitcoin-Dev 邮件列表上，提交了一个关于 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] opcode 的草案规范，并邀请那些倾向于替代设计的开发者提出反馈。部分替代方案得到了讨论，但讨论也分支出是否应该同时引入 [OP_CAT][] opcode。

  `OP_CAT` 和 `OP_CSFS` 可以实现任意交易内省——即允许将比特币接收至一个脚本，该脚本可以检查随后花费这些比特币的交易几乎任何部分。此功能可启用许多高级特性（包括其他一些提案升级如 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 和 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 的某些版本[^expensive]），但 `OP_CAT` 也使得创建递归的[契约][topic covenants]成为可能，这些契约可能会永久地限制投入该契约之比特币的可花费性。一些人[反对][rubin cost/benefit]在比特币中允许契约，但也有[论点][harding altcoins]认为[最糟糕的情况][towns multisig]（递归契约）已经在现有比特币中成为可能，因此不必过于担心启用 `OP_CAT` 或类似 opcode。

  尽管有这些讨论，Rubin 仍决定将其 `OP_CSFS` 提案与添加 `OP_CAT` 的任何提案独立开来，[认为][rubin just csfs]仅 `OP_CSFS` 自身也已足够有用。

- **<!--tracking-bech32m-support-->****跟踪 bech32m 支持：** Bitcoin Wiki 上的 [bech32 采用情况][wiki bech32 adoption]页面已[更新][erhardt bech32m tweet]，以跟踪支持向 [bech32m][topic bech32] 地址（用于 taproot）发送和接收的各软件与服务。

## Bitcoin Core PR 审查俱乐部

*在本月度栏目中，我们总结了一次最近的 [Bitcoin Core PR 审查俱乐部][Bitcoin Core PR Review Club]会议的情况，并重点介绍了一些重要的问答。点击下面的问题即可查看会议中的答案摘要。*

[Use script_util helpers for creating P2{PKH,SH,WPKH,WSH} scripts][review club #22363] 是 Sebastian Falbesoner 提交的一个拉取请求，用以在功能测试中用 `script_util` 辅助函数替换手动脚本创建，并修复了 `get_multisig()` 函数中的一个错误。此次审查俱乐部会议中对提案中使用的各脚本输出类型及相关术语作了详细解析。

{% include functions/details-list.md

  q0="**<!--q0-->**`script_util.py` 中的 `key_to_p2pkh_script`、`script_to_p2sh_script`、`key_to_p2wpkh_script` 和 `script_to_p2wsh_script` 分别做什么？"
  a0="这些是用于构建 Pay to Public Key Hash、Pay to Script Hash、Pay to Witness Public Key Hash 以及 Pay to Witness Script Hash 脚本（CScript 对象）的辅助函数，输入为公钥或脚本。"
  a0link="https://bitcoincore.reviews/22363#l-17"

  q1="**<!--q1-->**请定义 scriptPubKey、scriptSig 和 witness。"
  a1="scriptPubKey 和 scriptSig 分别是交易输出和输入中的字段，用于指定并满足花费条件。witness 是一个为同样目的而设置的附加字段，由隔离见证引入。花费要求在输出的 scriptPubKey 中被承诺，花费该输出的输入必须在 scriptSig 和/或 witness 中提供满足这些要求的数据。"
  a1link="https://bitcoincore.reviews/22363#l-31"

  q2="**<!--q2-->**请定义 redeem script 和 witness script。它们之间是什么关系？"
  a2="P2SH 和 P2WSH 输出类型会在 scriptPubKey 中提交一个脚本哈希。当花费该输出时，花费者需提供完整脚本以及任何签名或其他验证所需的数据。该脚本在出现在 scriptSig 中时称为 redeemScript，而在 witness 中时称为 witness script。从这个角度来说，它们是对应的：对于 P2SH 输出，redeemScript 相当于 P2WSH 输出的 witness script。二者并不相互排斥，因为花费一个 P2SH-P2WSH 输出的交易会同时包含这二者。"
  a2link="https://bitcoincore.reviews/22363#l-55"

  q3="**<!--q3-->**如果要将币发送给一个在脚本中定义了花费条件的人，输出的 scriptPubKey 中包含什么？在花费这笔币时，输入需要提供什么？"
  a3="scriptPubKey 中包含脚本哈希和用于验证匹配的操作码：`OP_HASH160 OP_PUSHBYTES_20 <20B script hash> OP_EQUAL`。而 scriptSig 则包含脚本本身及初始堆栈数据。"
  a3link="https://bitcoincore.reviews/22363#l-102"

  q4="**<!--q4-->**我们为什么使用 Pay-To-Script-Hash 而不是 Pay-To-Script？"
  a4="正如 [BIP16][] 中所述，这么做的核心动机是提供一种通用方式为任意复杂度的交易提供资金，同时把提供花费条件的负担留给赎回资金的一方。与会者也提及，将脚本从 scriptPubKey 中移除意味着对脚本本身的费用要到赎回时才支付，而且能减小 UTXO 集的体积。"
  a4link="https://bitcoincore.reviews/22363#l-112"

  q5="**<!--q5-->**当一个不支持隔离见证的节点验证一个 P2SH-P2WSH 输入时，它会做什么？而一个支持隔离见证的节点又会多做什么？"
  a5="不支持隔离见证的节点看不到 witness；它只执行 P2SH 的规则，验证 redeemScript 与 scriptPubKey 中提交的哈希是否匹配。支持隔离见证的节点则能识别出这是一个见证程序，并利用 witness 中的数据和相应的 scriptCode 来执行隔离见证规则。"
  a5link="https://bitcoincore.reviews/22363#l-137"

  q6="**<!--q6-->**在原始的 [`get_multisig()`](https://github.com/bitcoin/bitcoin/blob/091d35c70e88a89959cb2872a81dfad23126eec4/test/functional/test_framework/wallet_util.py#L109) 函数中，那个 P2SH-P2WSH 脚本有何问题？"
  a6="它在 P2SH-P2WSH 的 redeemScript 中直接使用了 witness script，而非其哈希值。"
  a6link="https://bitcoincore.reviews/22363#l-153"
%}

## 准备 taproot #4：从 P2WPKH 到单签 P2TR

*这是一个[系列][series preparing for taproot]的每周内容，介绍在区块高度 {{site.trb}} 激活 taproot 前，开发者和服务提供商如何做好准备。*

{% include specials/taproot/zh/03-p2wpkh-to-p2tr.md %}

## 发布与候选发布

*面向流行比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选版本。*

- [LND 0.13.1-beta.rc2][LND 0.13.1-beta] 是一个维护版本，针对 0.13.0-beta 中引入的功能进行了少量改进与错误修复。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]上值得注意的变更：*

- [C-Lightning #4625][] 更新了其[闪电网络 (LN) offers][topic offers] 的实现，以匹配最新的[规范变更][offers spec changes]。值得注意的是，offers 已不再需要附带签名。这一改动显著缩短了 offers 的编码字符串，从而改善了二维码的识别度。

- [Eclair #1746][] 增加了将数据并行复制到 PostgreSQL 数据库的功能，与原先的 SQLite 数据库同时使用。此功能旨在为那些最终计划切换后端的服务器提供测试便利。去年，Suredbits 工程师 Roman Taranchenko 在 Optech 的[现场报告][suredbits enterprise ln] 中描述了如何将 Eclair 与 PostgreSQL 后端结合使用来满足企业需求。

- [LND #5447][] 添加了一份[文档][lnd leader]，介绍了如何使用可在集群节点间进行复制的替代数据库来部署多个 LND 节点，以实现自动故障切换。感兴趣的读者可对比 [Newsletter #128][news128 eclair akka] 中提到的 Eclair 所采用的方法。

- [Libsecp256k1 #844][] 对 [schnorr 签名][topic schnorr signatures] 的 API 进行了多项更新，其中最显著的是一个[提交][nick varsig]，允许对任意长度的数据进行签名与验证。目前比特币中的所有签名都针对 32 字节哈希，但对可变长度数据进行签名可能在比特币链外应用中具有价值，或者可用于实现如 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] 这类新 opcode 的[签名验证][oconnor var csfs]功能。预计 [BIP340][]（比特币的 schnorr 签名规范）将进行更新，以描述如何安全地对可变长度数据进行签名。

- [BIPs #943][] 更新了 [BIP118][]，改为基于即将激活的 taproot 和 tapscript，而不再基于 SegWit v0。同时，此次修订将原本标题 SIGHASH_NOINPUT 更名为 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]，以体现当前该签名标志已被称为“ANYPREVOUT”，因为虽然签名可适用于任何前置输出，但对输入的部分信息仍然会进行承诺。

- [BTCPay Server #2655][] 指示网页浏览器在用户点击指向[区块浏览器][topic block explorers]的交易链接时，不要发送 HTTP `referer` 字段，这可避免向区块浏览器暴露具体是从哪个 BTCPay server 跳转而来，从而表明该服务端是交易的来源或接收者。即便如此，如果用户对隐私有较高需求，仍应尽量避免在第三方区块浏览器中直接查询自己的交易。

## 脚注

[^expensive]:
    在使用 `OP_CHECKSIGFROMSTACK`（`OP_CSFS`）实现诸如 [BIP118][] 中的 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 或 [BIP119][] 中的 [OP_CHECKTEMPLATEVERIFY][topic op_checksigfromstack] 等提案的核心特性时，如果以 scriptpath 花费方式进行，其占用的区块空间会比那些经过优化的提案更多。[支持][news48 generic csfs] `OP_CSFS` 的理由是可以先引入通用构造，验证人们确实有需求后，再对共识进行修改，添加更高效的实现。此外，由于 [taproot][topic taproot] 引入了 keypath 花费，任何脚本在特定场合都可以使用最少的区块空间来完成执行，从而减少对在不最佳情形下依然能省空间的特定构造的需求。

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
