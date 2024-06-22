---
title: 'Bitcoin Optech Newsletter #36'
permalink: /zh/newsletters/2019/03/05/
name: 2019-03-05-newsletter-zh
slug: 2019-03-05-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 链接了 C-Lightning 0.7 升级公告，提到 Bitcoin-Dev 邮件列表的服务中断，并描述了一个提议的软分叉，以消除 Bitcoin 共识协议中的几个旧问题。同时还包括对流行 Bitcoin 基础设施项目中值得注意的提交的摘要。

## 行动项

- **<!--upgrade-to-c-lightning-0-7-->****升级到 C-Lightning 0.7：**此新主要版本的最显著功能是一个插件系统，允许你的代码提供自定义 RPC 或在内部 lightningd 事件上运行。该版本还实现了协议增强和若干错误修复。请参阅[发布公告][cl 0.7]了解详细信息并考虑[升级][cl upgrade]。

## 新闻

- **<!--bitcoin-dev-mailing-list-outage-->****Bitcoin-Dev 邮件列表中断：**发送到 Bitcoin-Dev 邮件列表的邮件未能传递给读者。列表管理员正试图解决该问题，并且还在调查替代列表提供者。由 Linux Foundation 托管的其他比特币相关列表（例如 Lightning-Dev 列表）似乎没有遇到同样的问题。未来的 Optech Newsletter 将提到订阅者为继续接收协议讨论而需要采取的任何行动。

- **<!--cleanup-soft-fork-proposal-->****清理软分叉提案：**Matt Corallo 提交了一个 [Bitcoin Core 拉取请求][Bitcoin Core #15482]并尝试向 Bitcoin-Dev 邮件列表发送一个[提议的 BIP][BIP-cleanup]，以进行可能的软分叉，消除可能让某人攻击 Bitcoin 网络或其用户的几个边缘情况漏洞。这些漏洞已被公开多年，人们认为任何实际攻击都将代价过高而无法获利，或可以足够快地处理以防止威胁到比特币的生存能力。然而，最好是主动修复这些漏洞而不是被动应对。

  Optech 用以下要点总结了该提案，但我们认识到许多读者可能不熟悉 `OP_CODESEPARATOR`、`FindAndDelete()`、时间扭曲攻击和默克尔树漏洞等概念的细节，所以我们还在本期 Newsletter 中附上了一个附录，提供关于这些主题的额外背景信息。

  - **<!--prevent-use-of-op-codeseparator-and-findanddelete-in-legacy-transactions-->****防止在传统交易中使用 `OP_CODESEPARATOR` 和 `FindAndDelete()`：**目前没有人被知晓在传统（非 segwit）Bitcoin 交易中使用这两个功能，但攻击者可以滥用它们显著增加验证非标准交易所需的计算工作量，从而创建可能需要半小时或更长时间来验证的区块。大多数读者可能从未听说过这些功能，因为没有已知的有用行为是它们不能以其他方式完成的，但仍需要 `OP_CODESEPARATOR` 的人可以使用 [BIP143][] segwit 版本，它以避免计算爆炸的方式实现了该功能。自 2018 年 6 月发布的 Bitcoin Core 0.16.1 以来，这些功能的使用未被默认挖掘或传播。

{% comment %}<!--
      ## How long until all bitcoins are released by a timewarp
      ## There are 26 retarget periods per year, about 100 years of subsidy left: 2600
      ## Calculate in days
      In [7]: x = 0
         ...: for i in range(2600):
         ...:     x += 14*(0.25**i)
         ...: print(x)
         ...:
         18.666666666666668 -->{% endcomment %}

  - **<!--fix-the-time-warp-attack-->****修复时间扭曲攻击：**此攻击允许控制大多数算力的矿工即使总网络算力稳定或增加，也能维持或降低挖矿难度，使其能够比协议目标更快地生产区块。区块生产的增加将加速比特币区块补贴的释放，可能在攻击开始后的三周内释放所有剩余比特币。然而，攻击的设置至少在产生任何影响前会有一周的时间公开可见，因此在没有矿工卡特尔尝试的情况下，修复它并不是一个高优先级。提议的软分叉通过要求新难度周期中的第一个区块时间戳不早于前一周期最后一个区块的时间戳前 600 秒来解决这个问题。参见 [Newsletter #10][] 提到的邮件列表讨论。

  - **<!--forbid-use-of-non-push-opcodes-in-scriptsig-->****禁止在 scriptSig 中使用非推送操作码：**自 2010 年 7 月修复关键安全漏洞的[修复][1opreturn fix]以来，每个 scriptSig 在与一个币的 scriptPubKey 结合进行脚本验证之前都会被评估为仅包含数据元素。这几乎消除了在 scriptSig 中使用非数据推送操作码的任何理由（例外情况是它可能在堆栈上放置重复或排列的数据元素时略微更有效）。然而，因为比特币仍然技术上允许在 scriptSig 中使用非推送操作码，这可能被攻击者滥用以增加验证包含在区块中的交易所需的工作量。自 2011 年以来，禁止在 scriptSig 中使用非推送操作码已成为默认的中继和挖矿策略，并且在设计时已为发送到 [BIP16][] P2SH 和 [BIP141][] segwit 的支付禁止。

  - **<!--limit-legacy-and-bip143-sighashes-to-the-currently-defined-set-->****将传统和 BIP143 签名哈希限制为当前定义的集合：**你通过生成一个数字签名来证明一笔交易是你比特币的授权支出，该签名承诺对支出交易的哈希。然而，为了提供额外的灵活性，比特币允许你使用一个一字节*签名哈希类型*来指示究竟哪些交易部分（及相关数据）包含在哈希中。到目前为止，这个字节的 256 个可能值中只有 6 个具有定义的含义——如果你使用任何其他值，你的签名将承诺几乎与 `SIGHASH_ALL` 使用的数据完全相同。唯一的区别是签名哈希必须承诺其自己的签名哈希标志，这对于否则等效的数据将不同，并且会使缓存复杂化。自采用 [BIP141][] segwit 以来，预期任何新的签名哈希类型都将通过新的见证版本引入，因此删除指定未定义签名哈希类型的能力允许改进的缓存以减少节点开销。

  - **<!--forbid-transactions-64-bytes-or-smaller-->****禁止 64 字节或更小的交易：**比特币的默克尔树中派生的元素（节点）是通过将两个 32 字节的哈希摘要组合成一个 64 字节的二进制 blob 然后对其进行哈希形成的。然而，64 字节交易的交易标识符（txid）也是通过对一个 64 字节二进制 blob 进行哈希生成的。这可能允许交易伪装成一对哈希，或者一对哈希伪装成交易，从而创建比特币默克尔证明和 SPV 证明的漏洞。因为没有已知的方法可以通过 64 字节或更小的交易安全地支出比特币，提议的软分叉将禁止此类交易包含在区块中。

  该提案计划使用 [BIP9][] 激活机制，信号从 2019 年 8 月 1 日开始，如果未激活则在一年后结束。由于这仍然是一个提案，需要协议专家进行评估，在完整节点中实现（参见 Corallo 的 [PR][Bitcoin Core #15482]），并被用户自愿采用以便强制执行。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和 [Bitcoin Improvement Proposals (BIPs)][bips repo] 中值得注意的更改。*

- [Bitcoin Core #15471][] 删除了 GUI 和 RPC 中显示的关于“正在挖掘未知区块版本”的警告。该警告旨在告知用户矿工和用户可能正在使用 [BIP9][] 版本位协调软分叉激活，看到警告的用户可以升级他们的节点以在激活时理解和执行新的一致性规则。然而，矿工们越来越多地使用包含一些版本位作为随机数的公开 ASICBoost，如 [BIP320][] 所提议，导致该消息虚假触发。此合并只是删除了不再对用户有帮助的警告。是否项目将采用 BIP320、实施更复杂的警告系统，或尝试使用完全不同的解决方案来信号未来的软分叉（如通过生成（coinbase）交易信号）尚未决定。

- [C-Lightning #2382][] 将 `listpayments` RPC 重命名为 `listsendpays`。该命令列出你发送的所有支付的状态，但以前的名称让人误以为它也会列出收到的支付。还提供了一个新的 RPC `listpays`。目前，它提供的信息基本上与 `listsendpays` 相同，但当多路径支付实施时，它会将所有支付部分收集到一个 JSON 对象中。

  同一个 PR 还允许 `sendpay` RPC 接受一个 `bolt11` 字段，该字段将在用户以后运行 `listpay`、`listsendpays` 或 `waitsendpay` RPC 时保存并返回给用户。

## 附录：共识清理背景

以下子部分试图提供与清理软分叉相关的当前 Bitcoin 协议操作的背景信息。

### 时间扭曲攻击

{% comment %}<!--
#!/bin/bash

_median() {
  if [ $# -ne 11 ]
  then
    echo ERROR: wrong number of timestamps specified
    exit
  fi
  echo "$@" | sed 's/ /\n/g' | sort -n | numaverage -M
}
## Basic idea
_median 1 2 3 4 5 6 7 8 9 10 11

## Initial state
_median 1 1 1 1 1 1 2 2 2 2 2

## Immediately after a stamp of 12
_median 1 1 1 1 1 2 2 2 2 2 12

## Point before next num needs to be 4
_median 1 2 2 2 2 2 12 3 3 3 3

## Point before the next num needs to 5
_median 2 12 3 3 3 3 3 4 4 4 4

## End of this 11-block set beginning with "12"
_median 12 3 3 3 3 3 4 4 4 4 5

-->{% endcomment %}

Bitcoin 0.1 及其后所有版本实现的共识规则要求一个区块的时间戳必须大于前 11 个区块的中值。所以如果前面的区块时间戳是 {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}，下一个区块的时间戳必须为 7 或更大（但 12 会是一个自然选择）。

但是，如果矿工创建了时间戳为 {1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2} 的区块怎么办？那么下一个区块可以包含的时间戳为 2 或更大。但如果你无论如何放入一个时间戳为 12 的区块呢？然后，具有最小递增时间戳的下一个区块序列将看起来像：{12, 3, 3, 3, 3, 3, 4, 4, 4, 4, 5}。从查看此序列的人的角度来看，你似乎穿越时间回到了过去。你可以反复使用这种技巧，以便在最小化时间戳增量的区块序列中偶尔插入一个具有高时间戳的区块。

这值得注意，因为我们继续使用的 Bitcoin 0.1 共识规则还通过仅查看 2,016 区块重目标周期中的第一个和最后一个区块的时间戳来调整难度——而不是任何中间的区块。所以，如果矿工使用上述技术准备一个低时间戳区块序列，他们可以给该周期中的第一个区块一个低时间戳（比如 8 周前），并给该周期中的最后一个区块一个当前时间戳，使得共识算法认为这两个区块是 8 周前挖出的——导致算法将难度降低到当前值的 1/4（单次难度调整允许的最大减少量）。

通过反复使用这种技巧，矿工最终可以将难度降低到绝对最小值——尽管很容易相信 Bitcoin 在他们完成之前就会变得毫无用处，因为每秒会产生数千个区块，并且其 2100 万 BTC 补贴将被耗尽。部分阻止这种攻击的原因是矿工需要发布具有最小增量时间戳的大部分常规长度两周重目标周期的区块，然后他们才能开始创建较短持续时间的重目标周期。这希望能给 Bitcoin 开发人员时间创建一个简单的补丁（如提议的那个），并给用户时间通过紧急升级他们的节点来实现它。

提议的软分叉通过要求新重目标周期中的第一个区块的时间戳不早于其前一个区块（前一个周期最后一个区块）的 600 秒来工作。这意味着矿工只能为重目标周期中的第一个区块设置一个人为的低时间戳，如果他们还为前一个周期的最后一个区块设置了一个人为的低时间戳——但在前一个周期中设置低时间戳将会提高当时的难度，增加的难度会降低他们在当前周期末的难度，使任何此类尝试变得更糟。

然而，如果确实由于自然哈希率损失而需要很长时间来挖掘重目标周期中的所有区块，重目标公式仍将按预期工作以降低难度。

大多数使用当前软件的矿工可能会自动遵循此规则，但建议进行升级以确保他们这样做。轻量级客户端也可能希望强制执行该规则，以防矿工未能自己执行（如 [2015 年发生的情况][4 july fork]，导致暂时的 6 个区块分叉，随后是几个较短的分叉）。

更多信息：

- **<!--article-about-bitcoin-timestamp-reliability-->**Jameson Lopp 的 [关于 Bitcoin 时间戳可靠性的文章][lopp timestamp]

- **<!--proposal-to-use-timewarp-to-eliminate-the-need-for-hard-forks-->**Mark Friedenbach 的[使用时间扭曲消除硬分叉需求的提议][Friedenbach proposal]；另请参见我们在 [Newsletter #16][] 中的摘要 - 提议的清理软分叉消除了使用这个有争议想法的能力

### Merkle 树攻击

Bitcoin 使用一个 *merkle 树* 将所有交易连接到包含在区块头中的 32 字节哈希，称为 *merkle 根*。merkle 树允许拥有完整区块的人通过生成一系列将交易连接到 merkle 根的 32 字节哈希，向仅拥有交易的人证明该交易包含在一个区块中。

然而，32 字节哈希成对使用（64 字节数据），而一个精心构造的 Bitcoin 交易也可以是 64 字节，使得可能说服用户某个哈希对是交易或反之亦然。在任何情况下，用户都可能被欺骗接受看起来像是最有工作量证明（PoW）链的一部分但实际上不是并且从未被完整节点验证的交易。

{% comment %}<!--
一个最小的交易：

4 version
1 number of inputs
36 outpoint
1 size of scriptSig
_ scriptSig
4 sequence
1 number of outputs
8 amount
1 size of scriptPubKey
_ scriptPubKey
4 nLockTime
====
60 字节

-->{% endcomment %}

提议的软分叉通过简单地使任何 64 字节或更小的交易无效来解决问题。这是合理的，因为交易所需的字段最少消耗 60 字节。在 64 字节交易中，这只剩下 4 字节可用于 scriptPubKey 字段来为收款人保护资金。在这么少的字节中没有已知的方法可以安全地做到这一点，因此 64 字节或更小的交易没有任何安全性，没有任何人会使用它们除了进行攻击。这类交易自 2010 年以来未被 Bitcoin Core 默认中继或挖掘，因此矿工不需要更改他们的交易选择软件，只要他们没有更改硬编码的默认值。

该规则仅适用于交易的*剥离大小*，即不包括任何 segwit 部分的交易。由于 segwit 交易的最小剥离大小与传统交易相同，并且 scriptPubKey 不是 segwit 折扣字段，上述逻辑也表明没有安全的方法使用小于 64 字节的 segwit 交易。返回有关交易解码数据的 Bitcoin Core RPC，例如 `getrawtransaction`，在 `strippedsize` 字段中打印剥离大小。

矿工生成（coinbase）交易必须包含超出正常交易所需的数据，因此自 2012 年 [BIP34][] 激活以来，它们的最小大小为 64 字节。提议的清理软分叉要求它们仅比此最小大小大一个字节。包含 segwit 输入的区块的任何生成交易——这是过去一年多以来的几乎所有区块——其最小大小超过 100 字节，因此任何创建 segwit 区块的矿工都能通过此规则。

更多信息：

- **<!--cve-2017-12842-description-->**Sergio Demian Lerner 的 [CVE-2017-12842 描述][cve-2017-12842 description]

- **<!--mailing-list-discussion-->**各种作者在[邮件列表讨论][bitcoin-dev merkle tree]

### 传统交易验证

2015 年挖掘了一个包含几乎 1 MB 大小交易的区块，在当时的桌面计算机上需要大约 25 秒进行验证。除了其大尺寸，该交易在各方面都是普通的，但仍需要比包含更小交易的等效大小区块长约 10 倍的时间进行验证。原因是验证传统交易中包含签名的每个输入需要生成一个散列，该交易包含 5,570 个输入，需要对相同数据的略微变体进行 5,570 次散列。

不幸的是，Bitcoin 协议还提供了一些很少使用的功能，可以被利用以便在每个不同的签名检查操作（sigop）中对每个输入执行相同的调整和重新散列。由于每个输入可能需要几十个甚至数百个 sigop，这显著放大了这种攻击的效果。

具体而言，`OP_CODESEPARATOR` 操作码需要更改签名如何承诺其执行的脚本，但通过承诺单独复制整个交易的大部分（例如最坏情况下几乎 1.00 MB）来低效地实现。 [BIP143][] segwit 重新实现了此功能，通过直接承诺执行的脚本解决了 segwit 用户的问题，该脚本不能超过 10,000 字节（0.01 MB）。

如果直接在 scriptPubKey 中包含签名（或假装是签名的东西），则需要更多的工作，因为这将导致一个内部的 `FindAndDelete()` 操作修改执行的脚本，并再次导致 sigop 承诺单独复制几乎整个交易。因为 Bitcoin 中的安全签名承诺其支出的 scriptPubKey，并且 scriptPubKey 中的签名不能承诺自身，所以没有正当理由检查包含在 scriptPubKey 中的签名。[BIP143][] segwit 通过简单地规定不使用 `FindAndDelete()` 解决了其支出的这一问题。

最后，原始 Bitcoin 协议还允许攻击者向 scriptSig 添加非推送操作码，以在区块中使用多达额外 20,000 个 sigop，以及执行其他操作（如使用 `OP_DUP`（重复））以增加需要完成的验证工作。

将所有这些问题结合起来，使得准备充分的攻击者能够创建即使在快速硬件上也需要很长时间验证的区块。Optech 不知道最坏情况需要多长时间，因为研究人员保留其示例脚本私密以避免武装攻击者。我们自信地听说，在现代快速硬件上可以创建需要超过半小时验证的区块。（在上述机制的其他已知问题纠正之前，测试表明可能创建需要[几个小时验证的区块][sdl findanddelete]。）攻击矿工可以使用这些问题对验证节点和其他矿工进行拒绝服务攻击，可能找到从这种情况中获利的方法。然而，由于攻击涉及很少使用的 Bitcoin 功能，任何实际攻击可能会通过软分叉立即禁用这些功能——确保 Bitcoin 在软分叉激活后立即恢复正常。

我们无法通过禁止使用传统交易签名完全解决每个传统输入需要对一组略有不同的交易数据进行散列的问题，但共识清理软分叉提议通过禁止在传统输入中使用 `OP_CODESEPARATOR`、触发 `FindAndDelete()` 的行为和在 scriptSig 中使用非数据推送操作码来防止问题放大。许多开发人员认为这是可以接受的，因为没有已知的此行为生产性用途，没有人在链上活动中可见有人使用它们，并且因为想要玩 `OP_CODESEPARATOR` 的人仍可以使用 segwit 中提供的非问题版本。结合缓存改进，这可以将最坏情况的区块验证时间控制在秒级而不是分钟级。

更多信息：

- **<!--the-megatransaction-->**Rusty Russell 的 [The Megatransaction][megatransaction] - 一个需要 25 秒验证的区块

- **<!--cve-2013-2292-description-->**Sergio Demian Lerner 的 [CVE-2013-2292 描述][CVE-2013-2292 description] - 一个理论上假设需要三分钟验证的区块

- **<!--speculations-on-op-codeseparator-->**Peter Todd 的 [关于 `OP_CODESEPARATOR` 的猜测][todd codesep] - 关于在修复 `1 OP_RETURN` 错误之前如何使用 `OP_CODESEPARATOR` 以及 Nakamoto 是否考虑使用它来启用签名委托的信息（授权支出输出的签名者能够在不创建链上交易的情况下授予他人支出权限）

- **<!--op-1-op-return-bug-description-->**[<!--op-->`1 OP_RETURN` 错误描述][1return] - 一个允许任何人支出他人比特币的已修复错误。被称为“迄今为止 Bitcoin 最大的安全问题”。Satoshi Nakamoto 的[对此错误的修复][1opreturn fix]涉及将 scriptSig 的评估与每个支出对应的 scriptPubKey 分离，实际上消除了任何使用 `OP_CODESEPARATOR` 和 `FindAndDelete()` 的用途

## 更正

本 Newsletter 的早期版本错误地报告了未定义的 sighash 标志允许签名承诺任何哈希。实际上，它必须承诺与默认的 `SIGHASH_ALL` 标志算法相同的数据。我们感谢 Russell O'Connor 和 Pieter Wuille 独立报告此错误。

{% include references.md %}
{% include linkers/issues.md issues="15482,2382,15471" %}
[bip-cleanup]: https://github.com/TheBlueMatt/bips/blob/cleanup-softfork/bip-XXXX.mediawiki
[1return]: https://bitcoin.stackexchange.com/questions/38037/what-is-the-1-return-bug
[todd codesep]: https://bitcointalk.org/index.php?topic=255145.msg2773654#msg2773654
[megatransaction]: https://rusty.ozlabs.org/?p=522
[sdl findanddelete]: https://bitslog.wordpress.com/2017/01/08/a-bitcoin-transaction-that-takes-5-hours-to-verify/
[cl 0.7]: https://blockstream.com/2019/03/01/clightning-07-now-with-more-plugins/
[cl upgrade]: https://github.com/ElementsProject/lightning/releases/tag/v0.7.0
[lopp timestamp]: https://medium.com/@lopp/bitcoin-timestamp-security-8dcfc3914da6
[friedenbach proposal]: http://freico.in/forward-blocks-scalingbitcoin-paper.pdf
[bitcoin-dev merkle tree]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016091.html
[CVE-2013-2292 description]: https://bitcointalk.org/?topic=140078
[4 july fork]: https://en.bitcoin.it/wiki/July_2015_chain_forks
[CVE-2017-12842 description]: https://bitslog.wordpress.com/2018/06/09/leaf-node-weakness-in-bitcoin-merkle-tree-design/
[1opreturn fix]: https://github.com/bitcoin/bitcoin/commit/73aa262647ff9948eaf95e83236ec323347e95d0#diff-8458adcedc17d046942185cb709ff5c3R1114
[newsletter #10]: /zh/newsletters/2018/08/28/#requests-for-soft-fork-solutions-to-the-time-warp-attack
[newsletter #16]: /zh/newsletters/2018/10/09/#前向区块不通过硬分叉实现链上容量增加