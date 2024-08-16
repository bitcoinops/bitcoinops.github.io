---
title: 'RBF in the Wild'
permalink: /zh/rbf-in-the-wild/
name: 2019-02-11-rbf-in-the-wild-zh
slug: 2019-02-11-rbf-in-the-wild-zh
type: posts
layout: post
lang: zh
version: 1

excerpt: >
  一项关于支持可选择 RBF (BIP125) 的钱包和区块浏览器在可用性问题上的研究。

---
可选择通过费用替代（RBF）于 2015 年 12 月标准化。但谁在支持它，用户体验如何？这篇文章展示了用户在流行的比特币钱包和区块浏览器中看到的 [BIP125][] 可选择 RBF 的研究结果。研究成果最初在最近一次 [Bitcoin Optech 研讨会](/en/workshops/)中展示。

理解其他钱包、交易所和区块浏览器如何处理可选择 RBF 交易对比特币服务来说是一个重要的考虑因素。为了让交易所或钱包支持 RBF，他们希望知道 RBF 得到了广泛的支持，并且接收钱包或区块浏览器中的用户体验不会混淆。

这项研究的目标是评估钱包和区块浏览器生态系统中对可选择 RBF 的支持情况。尽管该研究的目的是描述性而非规定性，但我们确实有一些一般性的建议。在评估可用性时，每项服务应考虑其用户群体的经验和知识。希望将这些信息汇总到一个位置将有助于比特币公司就如何支持 RBF 做出明智的决策，甚至开始讨论哪些技术有效，哪些无效。

交易替换很重要，因为它可以启用：

- 钱包和用户对交易费用有更精细的控制，因为可以在初始费用较低时稍后提高费用
- 解决由于费用不足以被矿工打包的卡住交易

除了这些基本用例之外，RBF 还可以用于更高级的场景，例如：

- 将两个或多个付款合并为一个交易（迭代支付批处理）
- 预先计算费用提升
- 关闭无法提前预测费用的长时间支付通道[^closing_lightning_channels]

## 背景

[完整的交易替换](https://en.bitcoin.it/wiki/Replace_by_fee#Full_RBF)从比特币的 0.1.0 初始版本到 0.3.12 都是可用的，但存在一些潜在的缺点。即，无限制地替换交易意味着没有速率限制机制来防止 DoS/垃圾邮件替换。此外，如果原始交易具有相同或更高的费用率，矿工没有动机替换交易。

中本聪在 0.3.12 中[禁用交易替换](https://github.com/bitcoin/bitcoin/commit/05454818dc7ed92f577a1a1ef6798049f17a52e7#diff-118fcbaaba162ba17933c7893247df3aR522)，并留下评论 _“// 暂时禁用替换功能”_。从 0.3.12 到 0.11.x，比特币核心没有默认的交易替换功能。

这种情况在彼得·托德的 [BIP125 “可选择的完全通过费用替换信号”][BIP125]被合并到比特币核心 0.12.0 时发生了变化。BIP125 通过要求替换交易的更高费用解决了上述垃圾邮件防范和激励问题。

![2018 年 RBF 交易](/img/posts/rbf-in-the-wild/rbf-transactions-in-2018.png)
*2018 年大约 6% 的交易信号可选择 RBF。来源：[Bitcoin Optech 仪表盘](https://dashboard.bitcoinops.org/d/ZsCio4Dmz/rbf-signalling?orgId=1&from=1514835702976&to=1546285302976)*

## 评估内容

比特币钱包根据以下标准进行评估：

- 我能发送一个信号 RBF 的交易吗？
- 我能替换原始交易吗？
- 我能看到一个传入交易信号 RBF 吗？
- 我能看到一个传入的替换交易吗？

比特币区块浏览器根据以下标准进行评估：

- 我能看到一个交易信号 RBF 吗？
- 我能在替换后看到原始交易吗？

此外，每个标准的可用性都以带标题的截图记录。

有许多涉及 RBF 交易替换的高级场景。为本研究的目的，测试仅涉及单个交易替换。

在分析时间范围内，2018 年 8 月 - 11 月，汇总的结果显示：

- 测试的 23 个钱包中有 6 个支持以某种方式发送 RBF 交易
- 测试的 23 个钱包中有 2 个有一些指示交易接收信号 RBF
- 测试的 12 个区块浏览器中有 2 个显示某些指标表明交易信号 RBF

## 一些可用性示例

以下是一些不同服务如何从可用性角度处理 RBF 的精选示例。没有一个例子是为了批评任何特定的软件，而是展示 RBF 可用性和支持的成熟度。

在适当的情况下，已经提交了错误报告。

### Electrum：在交易列表中显示 RBF 标志

![Electrum 细微标记 RBF 交易的截图](/img/posts/rbf-in-the-wild/rbf-electrum-label.png)

在此示例中，Electrum 用一个细微的“rbf”标签标记了一个信号 RBF 的交易。Electrum 是少数支持发送和接收 RBF 的钱包之一。

在钱包中标记未确认交易的 RBF 可视化地识别出哪些传出交易可以在确认延迟时由用户提高费用。RBF 标签还显示哪些传入交易可以由其发送者使用 BIP125 提高费用。

### Bitcoin Core：差点增加交易费用

![Bitcoin Core 增加交易费用失败的截图](/img/posts/rbf-in-the-wild/rbf-bitcoin-core-increase-fee-fails.png)

在此示例中，Bitcoin Core 允许发送信号 RBF 的交易。初始交易广播后，Bitcoin Core 然后显示“增加交易费用”选项。然而，由于缺少找零输出，实际费用提升时失败。如果找零地址不够大以增加交易费用，用户体验也会类似。

BIP125 允许向替换交易添加额外的输入，这将解决这些找零输出不足的失败。然而，这在目前的 Bitcoin Core 用户界面中是不可能的。

### insight.bitpay.com：不显示 RBF 交易

![Bitpay 的 Insight 浏览器显示未确认 RBF 交易错误消息的截图](/img/posts/rbf-in-the-wild/rbf-insight-bitpay-no-rbf.png)

尽管 Bitpay 的 Insight 浏览器确实显示未确认交易，但它不显示任何信号 RBF 的未确认交易。这对于从支持 RBF 的交易所提款的用户来说是令人困惑的，因为用户在交易确认之前不会在浏览器中看到他们的交易。

### GreenAddress：提供多种费用提升选项

![GreenAddress 钱包显示具有费用选项的提升费用下拉菜单的截图](/img/posts/rbf-in-the-wild/rbf-green-multiple-bump-options.png)

GreenAddress 允许试图提升现有交易费用的用户根据一些预选选项选择其费用提升级别。还显示了法定货币（美元）金额，这意味着用户无需手动进行转换。GreenAddress 的费用提升对话框还有关于当前费用确认级别的估计。

### Bitcoin Core：显示原始交易后确认

![Bitcoin Core 显示'冲突'交易的鼠标悬停截图](/img/posts/rbf-in-the-wild/rbf-bitcoin-core-show-original.png)

Bitcoin Core 在一个被替换的交易确认后显示原始交易为失败（带 X 图标）。一个工具提示显示替换交易支出的地址（通常与原始地址相同）。

### GreenAddress：在交易列表中显示 RBF 标志

![GreenAddress 标记 RBF 交易的截图](/img/posts/rbf-in-the-wild/rbf-green-rbf-label.png)

GreenAddress 在交易列表中显示一个视觉 RBF 标志（“可替换”）。还注意到由于替换交易已在此示例中广播，存在双重支付。

### Bitpay：明显的 RBF 警告

![Bitpay 支付收据显示 RBF 警告的截图](/img/posts/rbf-in-the-wild/rbf-bitpay-overt-warnings.png)

Bitpay 显示了一个明确的 RBF 交易警告，表示处理可能会有延迟。Bitpay 还建议“为了避免将来的这种延迟，请在您的钱包中禁用 RBF 设置”。这些消息具有误导性，还暗示未确认的“非 RBF”信号交易不可替换。

任何未确认的交易都可能因多种原因被替换，包括发送者广播多个交易花费相同的 UTXO（[示例][todd reddit gold]）、发送者直接挖掘花费相同 UTXO 的不同交易（[芬尼攻击][Finney attack]）或发送者与矿工合作让花费相同 UTXO 的不同交易包含在区块中（[示例][betcoin dice]）。

### Explorer blocktrail.com：RBF 视觉标签

![blocktrail.com 浏览器交易详情显示可选择 RBF 标签的截图](/img/posts/rbf-in-the-wild/rbf-blocktrain-rbf-label.png)

Blocktrail 显示一个橙色的可选择 RBF 标签，并为用户提供更多信息的鼠标悬停详细信息。

### Samourai：静默失败的交易提升

![Samourai 钱包增加交易费用对话框的截图](/img/posts/rbf-in-the-wild/rbf-samourai-fail-bump.png)

与上述 Bitcoin Core 示例类似，费用提升交易时存在问题。然而，在这种情况下，出现了静默失败，并且用户没有关于发生了什么的消息。钱包中有足够的资金进行替换交易。

进一步测试表明，在 Samourai 中费用提升是可能的，也许这是代码中的一个边缘情况，涉及找零地址或额外输入。

### Coinbase：原始交易挂起

![Coinbase 交易列表显示挂起交易的截图](/img/posts/rbf-in-the-wild/rbf-coinbase-original-transaction-pending.png)

Coinbase 在交易列表中显示原始和替换交易。即使替换交易已收到 6 次以上确认，原始交易仍保持“挂起”状态。

注意：Coinbase 账户余额未受影响。Optech 正在与 Coinbase 联系，正在解决此问题。

### GreenAddress：关联 RBF 交易

![GreenAddress 交易详情和交易列表的截图](/img/posts/rbf-in-the-wild/rbf-green-associate-rbf-transactions.png)

GreenAddress 在用户界面的两个地方关联原始和替换交易。左侧是替换交易的交易详细信息屏幕，标有“由 txhash 双重支付”字段，这是原始交易的交易 ID。右侧的交易列表截图显示了一个可展开部分，列出了任何被此替换交易替换的原始交易。

### Samourai：信用余额的原始交易

![Samourai 钱包交易列表在余额更新前后的截图](/img/posts/rbf-in-the-wild/rbf-samourai-credit-balance-with-rbf.png)

Samourai 钱包显示原始和替换交易没有 RBF 标签。此外，余额实际上为两个交易都计入了信用。在一个小时内，并且在替换交易确认之前，原始交易被丢弃并显示了正确的余额（右图）。

看到两个正常的交易和增加的余额的用户可能会在交易稍后消失并且他们的余额减少时感到困惑。

### Xapo：未确认交易的电子邮件通知

![Xapo 电子邮件显示传入交易的截图](/img/posts/rbf-in-the-wild/rbf-xapo-email-notifications.png)

Xapo 发送原始和替换交易的电子邮件确认，这可能会向接收者表明他们将通过两个交易总共获得 2,000 位，而实际上在此示例中总共获得 1,000 位。

### Ledger Live：错误

![Ledger Live 的投资组合显示红色错误消息的截图](/img/posts/rbf-in-the-wild/rbf-ledger-dashboard-sync-error-message.png)

Ledger Live 的内部数据库被替换交易破坏。

注意：修复方法是重新安装 Ledger Live。Optech 正在与 Ledger 联系，解决此问题。

### Electrum：高级 RBF 费用提升控制

![Electrum 的高级费用提升选项对话框的截图，包括滑块和文本框](/img/posts/rbf-in-the-wild/rbf-electrum-advanced-rbf-options.png)

Electrum 允许在用户界面中更高级地控制费用。此外，该对话框提供将交易标记为最终的功能。

### BRD：通用错误消息

![BRD 钱包交易列表屏幕显示失败交易的截图](/img/posts/rbf-in-the-wild/rbf-brd-transaction-list-incoming-bumped.png)

BRD 在替换交易上显示“失败”标签。在测试中，“失败”交易实际上最终成为确认的交易。

## 可用性考虑

对于钱包、区块浏览器和其他比特币服务的一个普遍建议是支持可选择 RBF。本研究中测试的大多数服务都不支持 RBF。随着未来网络上的拥堵增加，RBF 将成为扩展工具箱中的一个重要工具。

根据上述一些示例，关于 RBF 支持还有一些其他建议。

### 浏览器重定向到替换交易

在几乎所有的浏览器中，尝试在替换交易确认后查看原始交易会导致 404 错误。这对之前访问过原始交易页面的用户来说可能会感到困惑。

浏览器应考虑从原始交易到最终确认的替换交易的 301 重定向。特别是当原始交易已通过该浏览器被访问者查看时。重定向应附有警报消息，表明原始交易已被当前交易替换。

### 保留原始交易

此建议类似于前一个建议，仅适用于钱包而非浏览器。

原始交易应在用户界面中保留，即使是细微的或在高级对话框下。当发送替换交易时，用户可能仍希望在其钱包中引用之前尝试过但从未确认的交易。

保留原始交易可能并不总是可行的。例如，如果钱包是轻客户端或在传入原始交易广播时不在线，则可能只会看到替换交易。

### 使用支持 RBF 的区块浏览器

支持 RBF 的钱包且不在应用程序中提供区块浏览器详细信息的，应链接到支持 RBF 的区块浏览器。这将为用户提供一致的体验，因为在从支持 RBF 的应用程序过渡到不支持 RBF 的浏览器时，交易不会“消失”。

### 链接到区块浏览器的地址页面

钱包/交易所应考虑链接到区块浏览器的“地址”页面而不是“交易”页面。这可以简化交易可能被替换/从浏览器消失的事实，同时也提供一个单一可靠的链接，供某人查看交易。

最好是浏览器实施类似上述的重定向方案，然而，如果该选项不可用，这是一个更用户友好的替代方案。

### 标记信号可选择 RBF 的交易

信号 RBF 的交易可以在交易列表和交易详细信息屏幕中进行可视化标记。或者，信号 RBF 的交易可以作为默认值，非 RBF 交易则获得一个“不可提升”类型的标签。这样的标签对于让用户知道他们的哪些交易是 BIP125 可替换的最有用。最终，任何未确认的交易都可以被替换。

### 不基于未确认交易触发

基于未确认交易触发的操作（电子邮件、内部流程等）对用户来说可能是混淆的。像“您已收到 0.5 BTC”这样的通知消息应避免，因为交易替换可能会多次触发，使收件人对发生的事情产生错误印象。如果您希望基于未确认交易发送电子邮件，请确保通知措辞适当。同样，基于未确认交易触发后台处理也是危险的。

## 钱包兼容性

鉴于本研究迄今收到的热烈反响，正在进行关于钱包和区块浏览器对 Bech32 支持的后续研究。

随着收集到更多指标，用于收集和显示结果的更好格式将是一个专门的 Optech 钱包兼容性网站。

如果您有建议认为其他有价值的指标或未来希望评估的比特币服务，请联系 [mike@bitcoinops.org](mailto:mike@bitcoinops.org)。

## 资源

- **<!--bip125-opt-in-full-replace-by-fee-signaling-->**[BIP125 可选择的完全通过费用替换信号](https://github.com/bitcoin/bips/blob/master/bip-0125.mediawiki)
- **<!--bitcoin-wiki-s-techniques-to-reduce-transaction-fees-->**[Bitcoin Wiki 的减少交易费用的技术](https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#opt-in_transaction_replacement)
- **<!--bitcoincore-org-s-opt-in-rbf-faq-->**[Bitcoincore.org 的可选择 RBF 常见问题](https://bitcoincore.org/en/faq/optin_rbf/)
- **<!--bitcoin-wiki-s-transaction-replacement-->**[Bitcoin Wiki 的交易替换](https://en.bitcoin.it/wiki/Transaction_replacement)
- **<!--bitcoin-optech-s-scaling-book-->**[Bitcoin Optech 的扩展书](https://github.com/bitcoinops/scaling-book)

## 脚注

[^closing_lightning_channels]:
    闪电网络（及其他类似系统）依赖于交换预签名交易，这些交易可能在未来某个不确定的时间点广播。无法预测签署时应设置的费用率。目前在比特币和闪电网络开发邮件列表上有讨论关于对标准内存池政策规则进行例外处理，使第二层协议用户能够更可预测地进行费用提升。


{% include references.md %}
[optech team]: /en/about/
[announcement]: /zh/announcing-bitcoin-optech/
[workshops]: /en/workshops/
[newsletters]: /zh/newsletters/
[dashboard]: https://dashboard.bitcoinops.org/
[dashboard blog post]: /zh/dashboard-announcement/
[scaling book]: https://github.com/bitcoinops/scaling-book
[scaling book feebumping]: https://github.com/bitcoinops/scaling-book/blob/master/1.fee_bumping/fee_bumping.md
[softfork]: /zh/newsletters/2018/12/18/#新闻
[lightning cpfp carve-out]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016518.html
[finney attack]: https://bitcoin.stackexchange.com/questions/4942/what-is-a-finney-attack
[todd reddit gold]: https://www.coingecko.com/buzz/peter-todd-explains-how-he-double-spent-coinbase
[betcoin dice]: https://bitcointalk.org/index.php?topic=327767.0
