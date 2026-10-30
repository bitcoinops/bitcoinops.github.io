---
title: 'Bitcoin Optech Newsletter #36'
permalink: /zh/newsletters/2019/03/05/
name: 2019-03-05-newsletter-zh
slug: 2019-03-05-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 给出 C-Lightning 0.7 升级公告的链接，提到 Bitcoin-Dev 邮件列表出现服务中断，并介绍一项提议的软分叉，用来消除 Bitcoin 共识协议中的几个老问题。此外还包括热门 Bitcoin 基础设施项目中值得注意的提交摘要。

## 行动项

- **<!--upgrade-to-c-lightning-0-7-->****升级到 C-Lightning 0.7：**这个新大版本最引人注目的特性是一套插件系统，让你自己的代码可以提供自定义 RPC，或响应 lightningd 的内部事件运行。该版本还实现了协议增强和若干错误修复。详情请参阅[发布公告][cl 0.7]，并考虑[升级][cl upgrade]。

## 新闻

- **<!--bitcoin-dev-mailing-list-outage-->****Bitcoin-Dev 邮件列表中断：**发往 Bitcoin-Dev 邮件列表的邮件目前无法转发给读者。列表管理员正在设法解决该问题，同时也在考察其他列表托管方。由 Linux Foundation 托管的其他比特币相关列表（例如 Lightning-Dev 列表）似乎没有出现同样的问题。今后的 Optech Newsletter 会提示订阅者为继续接收协议讨论需要采取哪些行动。

- **<!--cleanup-soft-fork-proposal-->****清理软分叉提案：**Matt Corallo 提交了一个 [Bitcoin Core 拉取请求][Bitcoin Core #15482]，并尝试向 Bitcoin-Dev 邮件列表发送一份[提议的 BIP][BIP-cleanup]，内容是一项可能的软分叉，用来消除若干边缘情况——这些情况可能让人攻击 Bitcoin 网络或其用户。这些漏洞多年来一直公开，人们认为真正付诸实施的攻击要么成本过高、无利可图，要么能被足够快地处理，不至于威胁 Bitcoin 的存续。不过，主动修复总比事后补救好。

  Optech 在下面几个要点中总结该提案。不过我们明白，许多读者对 `OP_CODESEPARATOR`、`FindAndDelete()`、时间扭曲攻击和默克尔树漏洞等概念的细节并不熟悉，所以本期 Newsletter 还附了一个附录，为这些主题补充背景知识。

  - **<!--prevent-use-of-op-codeseparator-and-findanddelete-in-legacy-transactions-->****禁止在传统交易中使用 `OP_CODESEPARATOR` 和 `FindAndDelete()`：**据了解，没有人在传统（非 segwit）Bitcoin 交易中使用这两个功能，但攻击者可以滥用它们，大幅增加验证一笔非标准交易所需的计算量，从而构造出需要半小时甚至更久才能验证完的区块。大多数读者可能从未听说过这两个功能，因为二者能实现的已知有用行为，都可以用其他方式完成；但仍需要 `OP_CODESEPARATOR` 的人可以使用其 [BIP143][] segwit 版本，该版本的实现方式避免了计算量爆炸。自 2018 年 6 月 Bitcoin Core 0.16.1 发布以来，默认情况下不会再挖出或中继使用这些功能的交易。

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

  - **<!--fix-the-time-warp-attack-->****修复时间扭曲攻击：**此攻击让控制多数算力的矿工即使全网算力持平或增长，也能维持或降低挖矿难度，从而以快于协议目标的速度出块。出块速度加快会加速释放比特币区块补贴，可能在攻击开始后三周内就把剩余比特币全部释放出来。不过，攻击的准备工作在真正产生效果之前，至少会有一周时间公开可见，因此在没有矿工卡特尔试图发动攻击的情况下，修复它的优先级并不高。提议的软分叉这样解决该问题：要求新难度周期的第一个区块，其时间戳不得比上一周期最后一个区块的时间戳早 600 秒以上。另请参见 [Newsletter #10][]，我们在那里提到过一次关于该话题的邮件列表讨论。

  - **<!--forbid-use-of-non-push-opcodes-in-scriptsig-->****禁止在 scriptSig 中使用非推送操作码：**自 2010 年 7 月针对一个严重安全漏洞做出[修复][1opreturn fix]以来，每个 scriptSig 在与某个币的 scriptPubKey 结合进行脚本验证之前，都会被先求值为只含数据元素。这几乎消除了在 scriptSig 中使用非数据推送操作码的任何理由（例外是在堆栈上放置重复或重排的数据元素时可能略微更高效）。然而，由于比特币在技术上仍然允许在 scriptSig 中使用非推送操作码，攻击者可能借此增加验证区块中某笔交易所需的工作量。自 2011 年起，禁止在 scriptSig 中使用非推送操作码就已是默认的中继与挖矿策略；而在设计上，发送给 [BIP16][] P2SH 和 [BIP141][] segwit 的支付也禁止这样做。

  - **<!--limit-legacy-and-bip143-sighashes-to-the-currently-defined-set-->****把传统签名哈希和 BIP143 签名哈希限制在当前已定义的集合内：**你要证明一笔交易是对你自己比特币的授权花费，方式是生成一个数字签名，让该签名承诺支出交易的哈希。不过，为了提供额外的灵活性，比特币允许你用一个一字节的*签名哈希类型*指出究竟交易的哪些部分（及相关数据）被纳入哈希。这个字节共有 256 种可能取值，目前只有 6 种有定义的含义——如果你使用其他任何值，你的签名所承诺的数据与 `SIGHASH_ALL` 所用数据几乎完全相同。唯一的差别是，签名哈希还必须承诺它自己的 sighash 标志；对于其他方面完全相同的数据，这个标志会不一样，从而使缓存变得复杂。自 [BIP141][] segwit 被采用以来，新的签名哈希类型预计都会通过新的见证版本引入，因此禁止指定未定义的签名哈希类型，就能改进缓存、降低节点开销。

  - **<!--forbid-transactions-64-bytes-or-smaller-->****禁止 64 字节及更小的交易：**比特币默克尔树中的派生元素（节点），是把两个 32 字节的哈希摘要拼成一个 64 字节的二进制数据块、再对它做哈希得到的。但一笔 64 字节交易的交易标识符（txid），同样是以完全相同的方式对一个 64 字节数据块做哈希算出来的。这就可能让一笔交易伪装成一对哈希，或者让一对哈希伪装成一笔交易，从而为比特币的默克尔证明和 SPV 证明带来漏洞。由于目前不知道有任何方法能用 64 字节及更小的交易安全地花费比特币，提议的软分叉将禁止把此类交易打包进区块。

  该提案计划使用 [BIP9][] 激活机制，信号从 2019 年 8 月 1 日开始，如果未激活则在一年后结束。由于这仍然是一个提案，需要协议专家进行评估，在完整节点中实现（参见 Corallo 的 [PR][Bitcoin Core #15482]），并被用户自愿采用以便强制执行。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案（BIPs）][bips repo]中值得注意的变更。*

- [Bitcoin Core #15471][] 移除了 GUI 和 RPC 中显示的“正在挖出未知区块版本”警告。该警告原本用于告知用户：矿工和用户可能正在通过 [BIP9][] 版本位协调激活某个软分叉，看到警告的用户可以升级自己的节点，以便在软分叉激活时理解并执行新的共识规则。然而，矿工越来越多地采用公开的 ASICBoost，按 [BIP320][] 的提议把部分版本位当作 nonce 使用，导致这条消息被误触发。这次合并只是删掉了这条已不再对用户有帮助的警告。项目究竟是采用 BIP320、实现更精细的警告系统，还是尝试用完全不同的方式来为未来的软分叉发出信号（例如通过生成交易（coinbase）发出信号），目前尚未决定。

- [C-Lightning #2382][] 将 `listpayments` RPC 重命名为 `listsendpays`。该命令列出你发送的所有支付的状态，但以前的名称让人误以为它也会列出收到的支付。还提供了一个新的 RPC `listpays`。目前，它提供的信息基本上与 `listsendpays` 相同，但当多路径支付实施时，它会将所有支付部分收集到一个 JSON 对象中。

  同一个 PR 还允许 `sendpay` RPC 接受一个 `bolt11` 字段，这个字段会被保存下来；用户日后运行 `listpay`、`listsendpays` 或 `waitsendpay` RPC 时，它会被返回给用户。

## 附录：共识清理背景

以下小节介绍与这项清理软分叉相关的 Bitcoin 协议当前运作方式，作为背景资料。

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

Bitcoin 0.1 及其后所有版本实现的共识规则要求，一个区块的时间戳必须大于前 11 个区块时间戳的中位数。因此，如果前面区块的时间戳是 {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}，下一个区块的时间戳就必须为 7 或更大（不过填 12 比较自然）。

但是，如果矿工造出时间戳为 {1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2} 的区块呢？那么下一个区块的时间戳只要为 2 或更大即可。可如果你偏偏给它填了个 12 呢？接下来若继续按时间戳最小递增的方式出块，序列就会是：{12, 3, 3, 3, 3, 3, 4, 4, 4, 4, 5}。在旁观者看来，你像是穿越回了过去。这招可以一直用下去：在一串时间戳只做最小递增的区块里，时不时插入一个时间戳很高的区块。

这值得注意，因为我们一直沿用的 Bitcoin 0.1 共识规则在调整难度时，只看一个 2,016 区块的难度调整周期里第一个和最后一个区块的时间戳——完全不看中间的区块。所以，如果矿工用上面的手法准备了一串低时间戳的区块，就能给该周期的第一个区块一个很低的时间戳（比如 8 周之前），再给该周期的最后一个区块一个当前时间戳，让共识算法以为这两个区块的挖掘时间相隔 8 周——从而把难度降到当前值的 1/4（这是单次难度调整允许的最大降幅）。

通过反复使用这种技巧，矿工最终可以将难度降到绝对最小值——尽管不难想见，在他们做到这一步之前比特币就已经毫无用处了：每秒会产出数千个区块，剩下的 2100 万 BTC 补贴也会被抽干。目前能在一定程度上阻止这种攻击的原因之一是：矿工必须先在一个正常长度为两周的难度调整周期的大部分时间里，持续发布时间戳只做最小递增的区块，之后才能开始制造时长更短的难度调整周期。这有望给 Bitcoin 开发者留出时间编写一个简单的补丁（例如所提议的这个），也给用户留出时间通过紧急升级节点来部署它。

提议的软分叉这样实现：要求新难度调整周期的第一个区块，其时间戳不得比它前一个区块（上一周期的最后一个区块）的时间戳早 600 秒以上。这意味着矿工要想给难度调整周期的第一个区块设置人为偏低的时间戳，就必须同时给上一周期的最后一个区块也设置人为偏低的时间戳——但在上一周期里放低时间戳会*提高*当时的难度，提高的幅度与他们随后在本周期末能降低的幅度相当，因此这类尝试只会得不偿失。

然而，如果确实由于自然哈希率损失而需要很长时间来挖掘难度调整周期中的所有区块，难度调整公式仍将按预期工作以降低难度。

大多数使用当前软件的矿工可能会自动遵守这条规则，但仍建议升级，以确保他们确实遵守。轻客户端也可能希望主动执行这条规则，以防矿工自己不去执行（正如 [2015 年发生过的那样][4 july fork]：先是一次持续 6 个区块的临时分叉，随后又出现了几次较短的分叉）。

更多信息：

- **<!--article-about-bitcoin-timestamp-reliability-->**Jameson Lopp 的 [关于 Bitcoin 时间戳可靠性的文章][lopp timestamp]

- **<!--proposal-to-use-timewarp-to-eliminate-the-need-for-hard-forks-->**Mark Friedenbach 的[使用时间扭曲消除硬分叉需求的提议][Friedenbach proposal]；另请参见我们在 [Newsletter #16][] 中的摘要——而所提议的清理软分叉恰好消除了使用这个有争议想法的可能

### 默克尔树攻击

Bitcoin 用一棵*默克尔树*把区块内的所有交易汇集成一个 32 字节的哈希，也就是包含在区块头里的*默克尔根*。借助默克尔树，掌握完整区块的人可以向只掌握某笔交易的人证明该交易确实被打包进了区块：他只需提供一串把该交易连到默克尔根的 32 字节哈希。

然而，32 字节哈希是成对使用的（共 64 字节数据），而一笔精心构造的 Bitcoin 交易也恰好可以是 64 字节，因此就有可能让用户相信某个哈希对就是一笔交易，或者反过来。无论哪种情况，用户都可能被诱导接受一笔看起来属于工作量最大的那条（PoW）链、实际上却不在链上、也从未被全节点验证过的交易。

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

提议的软分叉通过直接让任何 64 字节及更小的交易失效来解决问题。这样做是合理的，因为一笔交易必需的字段最少就要占用 60 字节。在 64 字节的交易里，只剩下 4 字节留给 scriptPubKey 字段，用来为收款人保障资金。已知没有任何办法能在这么少的字节里做到安全，所以 64 字节及更小的交易不可能有任何安全性，人们除了用来攻击也没有理由使用它们。这类交易自 2010 年起就不在 Bitcoin Core 的默认中继和挖矿范围内，因此只要矿工没改动硬编码的默认值，就不需要修改自己的交易选择软件。

该规则只适用于交易的*剥离大小*（stripped size），即去掉所有 segwit 部分之后的交易。由于 segwit 交易的最小剥离大小与传统交易相同，而 scriptPubKey 又不是享受 segwit 折扣的字段，上面的推理同样说明：小于 64 字节的 segwit 交易没有安全的用法。返回交易解码数据的 Bitcoin Core RPC（例如 `getrawtransaction`）会在 `strippedsize` 字段中打印剥离大小。

矿工的生成交易（coinbase）必须包含超出普通交易所需的数据，因此自 2012 年 [BIP34][] 激活以来，其最小大小就是 64 字节。提议的清理软分叉要求它们只能比这个最小值大 1 个字节。对于包含 segwit 输入的区块（过去一年多以来几乎所有区块都是如此），其生成交易的最小大小超过 100 字节，因此任何打包 segwit 区块的矿工都必然符合这条规则。

更多信息：

- **<!--cve-2017-12842-description-->**Sergio Demian Lerner 的 [CVE-2017-12842 描述][cve-2017-12842 description]

- **<!--mailing-list-discussion-->**多位作者的[邮件列表讨论][bitcoin-dev merkle tree]

### 传统交易验证

2015 年挖出过一个区块，其中包含一笔近 1 MB 的交易，用当时的桌面计算机验证要花大约 25 秒。这笔交易除了体积大，其他方面都很普通，但验证它所需的时间仍大约是验证一个装满小交易的同等大小区块的 10 倍。原因在于，验证传统交易中每个带签名的输入时，都需要对交易数据的一部分生成哈希。这笔近 1 MB 的交易包含 5,570 个输入，也就需要对同一数据的细微变体做 5,570 次哈希。

不幸的是，Bitcoin 协议还提供了一些很少使用的特性，可被利用来让每个输入内部执行的每一次签名检查操作（sigop）都重复同样的一套数据微调与重新哈希。由于单个输入可能需要执行几十甚至上百次 sigop，这会把这种攻击的效果显著放大。

具体来说，`OP_CODESEPARATOR` 操作码需要改变签名对其所执行脚本的承诺方式，但它的实现很低效：每次执行一次 sigop，都要承诺整个交易大段内容的单独副本（最坏情况下接近 1.00 MB）。[BIP143][] 在 segwit 中重新实现了这一特性，改为直接承诺所执行的脚本，从而解决了 segwit 用户的问题——该脚本最大不超过 10,000 字节（0.01 MB）。

如果直接在 scriptPubKey 中放入签名（或伪装成签名的东西），还需要付出更多的工作：这会触发内部的 `FindAndDelete()` 操作去修改所执行的脚本，再次让 sigop 承诺几乎整个交易的独立副本。由于 Bitcoin 中的安全签名会承诺它所花费的 scriptPubKey，而 scriptPubKey 中的签名无法承诺自身，所以检查 scriptPubKey 里的签名毫无正当理由。[BIP143][] segwit 则直接规定不使用 `FindAndDelete()`，从而为其花费解决了这一问题。

最后，原始 Bitcoin 协议还允许攻击者向 scriptSig 添加非推送操作码，从而在一个区块中额外用掉最多 20,000 个 sigop，并执行其他操作（如使用 `OP_DUP`（重复））以增加需要完成的验证工作。

把所有这些问题叠加起来，准备充分的攻击者就能构造出即使在快速硬件上也要花很长时间才能验证完的区块。Optech 并不清楚最坏情况究竟要多久，因为研究者没有公开他们的示例脚本，以免给攻击者送上现成武器。不过我们得到可靠消息：在当今的快速硬件上，可以构造出验证耗时超过半小时的区块。（在上述机制的其他已知问题被修正之前，测试表明还能构造出验证需要[好几个小时][sdl findanddelete]的区块。）发动攻击的矿工可以利用这些问题，对验证节点和其他矿工发起拒绝服务攻击，甚至可能找到从中获利的方法。不过，由于这些攻击都涉及很少使用的 Bitcoin 特性，任何实际攻击都很可能会遇到一个立即禁用这些特性的软分叉——从而保证一旦软分叉激活，Bitcoin 就能恢复正常。

除非彻底禁止使用传统交易签名，否则我们无法解决每个传统输入都要对一组略有不同的交易数据做哈希这个问题；不过，共识清理软分叉提出通过禁止在传统输入中使用 `OP_CODESEPARATOR`、禁止触发 `FindAndDelete()` 的行为、禁止在 scriptSig 中使用非数据推送操作码，来防止问题被放大。许多开发者认为这是可以接受的：这类行为没有已知的生产性用途，链上也没有任何使用它们的活动迹象，而且想摆弄 `OP_CODESEPARATOR` 的人仍然可以使用 segwit 中没有问题的那一版。再配合缓存方面的改进，最坏情况下的区块验证时间有望从分钟级降到秒级。

更多信息：

- **<!--the-megatransaction-->**Rusty Russell 的 [The Megatransaction][megatransaction] - 一个需要 25 秒验证的区块

- **<!--cve-2013-2292-description-->**Sergio Demian Lerner 的 [CVE-2013-2292 描述][CVE-2013-2292 description] - 一个被推测理论上需要三分钟才能验证的区块

- **<!--speculations-on-op-codeseparator-->**Peter Todd 的 [关于 `OP_CODESEPARATOR` 的推测][todd codesep] - 介绍在修复 `1 OP_RETURN` 错误之前 `OP_CODESEPARATOR` 是如何被使用的，以及中本聪是否曾考虑用它来实现签名委托（让某个输出的授权签名者可以授权他人花费它，而无需创建链上交易）

- **<!--op-1-op-return-bug-description-->**[<!--op-->`1 OP_RETURN` 错误描述][1return] - 一个已经修复的错误，它曾允许任何人花掉任何人的比特币，被称为“Bitcoin 有史以来最严重的安全问题”。中本聪针对该错误的[修复][1opreturn fix]把 scriptSig 的求值与每笔花费对应的 scriptPubKey 分开，实际上让 `OP_CODESEPARATOR` 和 `FindAndDelete()` 失去了用武之地

## 更正

本 Newsletter 的早期版本曾错误地称，未定义的 sighash 标志允许签名承诺任意哈希。实际上，它必须承诺与默认 `SIGHASH_ALL` 标志算法相同的数据。我们感谢 Russell O'Connor 和 Pieter Wuille 各自独立报告了这一错误。

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
[bitcoin-dev merkle tree]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016091.html
[CVE-2013-2292 description]: https://bitcointalk.org/?topic=140078
[4 july fork]: https://en.bitcoin.it/wiki/July_2015_chain_forks
[CVE-2017-12842 description]: https://bitslog.wordpress.com/2018/06/09/leaf-node-weakness-in-bitcoin-merkle-tree-design/
[1opreturn fix]: https://github.com/bitcoin/bitcoin/commit/73aa262647ff9948eaf95e83236ec323347e95d0#diff-8458adcedc17d046942185cb709ff5c3R1114
[newsletter #10]: /zh/newsletters/2018/08/28/#requests-for-soft-fork-solutions-to-the-time-warp-attack
[newsletter #16]: /zh/newsletters/2018/10/09/#前向区块不通过硬分叉实现链上容量增加