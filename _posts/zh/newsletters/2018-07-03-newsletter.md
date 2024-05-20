---
title: 'Bitcoin Optech Newsletter #2'
permalink: /zh/newsletters/2018/07/03/
name: 2018-07-03-newsletter-zh
slug: 2018-07-03-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
version: 1
excerpt: >
  关于 graftroot 安全性的讨论仍在继续，BIP174 部分签名比特币交易(PSBT)正式标记为提议，并讨论了蒲公英(Dandelion)交易中继。

---

### 取消订阅

我们已经转移到一个新平台来分发本周的 Newsletter。如果您对接收有关比特币开源社区动态的每周更新不感兴趣，请点击此邮件底部的取消订阅链接。

如果您对我们正在做的事情有任何疑问或评论，请随时通过 [info@bitcoinops.org](mailto:info@bitcoinops.org) 与我们联系！


## 欢迎

欢迎阅读第二期 Bitcoin Optech 小组 Newsletter！作为我们新组织的一员，您可以期待我们定期发布的 Newsletter，内容涵盖比特币开源开发和协议新闻、Optech 公告以及会员公司的案例研究。这些 Newsletter 也可在[我们的网站][newsletter page]上找到。

一如既往，如果您对本新闻通讯有任何反馈或评论，请随时联系我们。

提醒还没有成为正式会员的公司。我们请求您支付 5000 美元的象征性贡献，以帮助我们资助我们的开支。

[newsletter page]: /zh/newsletters/


## 第一次 Optech 工作坊！

如先前宣布，Bitcoin Optech 小组正在组织我们的第一次工作坊 **7 月 17 日在旧金山**。参与者将是来自旧金山湾区比特币公司的1-2名工程师。我们将就以下3个话题进行圆桌讨论：

- 币选择（Coin Selection）最佳实践；
- 费用估算，RBF（Replace-By-Fee），CPFP（Child-Pays-For-Parent）最佳实践；
- Optech 社区和沟通 - 优化 Optech 以满足企业需求。

如果您希望参与此次或其他地区的未来工作坊，请与我们联系。

## 开源新闻

来自更广泛的比特币开源社区的相关行动项、仪表盘项和新闻的摘要。

### 行动项

没有新的行动项，但仍建议跟进以下先前发布的项目。

- **<!--newsletter-1-->**待公开的 Bitcoin Core 0.12.0 及更早版本的 DoS 漏洞。山寨币可能受影响。参见 [Newsletter #1][newsletter #1]

- **<!--bitcoin-core-0-16-1-->**升级到于 2018 年 6 月 15 日发布的 [Bitcoin Core 0.16.1][Bitcoin Core 0.16.1]。特别推荐矿工进行升级。参见 [Newsletter #1][newsletter #1]

[Bitcoin Core 0.16.1]: https://bitcoincore.org/en/download/
[newsletter #1]: /zh/newsletters/2018/06/26/

### 仪表盘项

- **<!--transaction-fees-remain-very-low-->****交易费用仍然非常低：**截至撰写本文时，对于 2 个或更多区块后确认的费用估算大约保持在 Bitcoin Core 默认的最低中继费用水平。这是[合并输入][consolidate inputs]的好时机。

  **更新（7 月 2 日）**：在过去的 3-4 天里，估算的[网络哈希率][hash rate graph]下降了，最初下降了大约 10%，但之后有所反弹。一些人推测，中国西南部的洪水摧毁了大量的采矿设备。然而，需要注意的是，由于区块发现率的自然波动，在短时间内只能大致估算当前的网络哈希率。较低的网络哈希率意味着区块发现速度减慢，可能导致内存池拥堵潜在更高的费用。到目前为止，内存池拥堵似乎没有显著增加，费用仍然很低。然而，建议在发送大量交易前继续监控区块发现率和内存池拥堵情况。

[consolidate inputs]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation

[hash rate graph]: https://bitcoinwisdom.com/bitcoin/difficulty

- **<!--testnet-high-block-production-rate-->****测试网高区块生产率：**上周晚些时候，一位矿工在测试网上快速连续生产大量区块，有时每秒钟产生几个区块，导致一些测试网提供者的服务降级。这是测试网上反复出现的问题，是由于那里缺乏挖矿的经济激励所致。如果您需要测试软件，使用 Bitcoin Core 的 [regtest 模式][regtest mode]构建自己的私人测试网会更可靠。

[regtest mode]: https://bitcoin.org/en/developer-examples#regtest-mode

### 新闻

- **<!--continued-discussion-over-graftroot-safety-->****关于 Graftroot 安全性的持续讨论：** [Graftroot][] 是对 [taproot][] 提议的可选替代方案，而 taproot 是对 [MAST][] 提议的增强，MAST 本身是对当前比特币脚本的提议的增强。MAST 通过在区块链中允许不包含比特币脚本中未使用的条件分支来改善可扩展性、隐私性和可替代性。Taproot 通过在区块链中允许在常见情况下即使是脚本中使用的条件分支也不包含，进一步改进 MAST 的可扩展性、隐私性和可替代性。Graftroot 通过允许脚本中的参与者将他们的支出权限委托给其他方来改进 taproot 的灵活性和可扩展性，包括允许现有参与者对代表施加额外的基于脚本的条件——所有这些都在链下完成，而不降低可扩展性、隐私性和可替代性的好处。

  在一场进展缓慢的[讨论][graftroot discussion]中，比特币开发邮件列表的成员一直在尝试构建一个非正式措辞的安全性证明，以证明默认启用 graftroot 委托不会降低不需要它的用户的安全性（例如，只想使用 taproot 而不委托或甚至只是普通的 MAST）。尽管还需要更多的同行评审，但这一努力似乎正在积极进行中，目前的专家们一致认为，默认启用 graftroot 是安全的。

[graftroot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-February/015700.html
[taproot]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-January/015614.html
[MAST]: https://bitcointechtalk.com/what-is-a-bitcoin-merklized-abstract-syntax-tree-mast-33fdf2da5e2f
[graftroot discussion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016049.html


- **<!--bip174-discussion-->****[BIP174][] 讨论：** 如[上周的 Newsletter][newsletter #1] 中提到，邮件列表[讨论][BIP174 discussion]继续围绕这个提议的 BIP 进行，该 BIP 旨在制定行业标准，使钱包之间的通信变得更加容易，以应对在线/离线（热/冷）钱包、软件/硬件钱包、多签名钱包和多用户交易（例如 CoinJoin）。然而，BIP 提议者现在已经开启 [PR][BIP174 update]，请求将 BIP 状态从“草案”改为“提议”。这意味着除非发现了实现方面的重大问题，否则它不太可能被更改。如果您的组织生产或必要使用上述互操作钱包之一，您可能希望在最终确定之前尽快评估当前提案。

[BIP174]: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
[BIP174 update]: https://github.com/bitcoin/bips/pull/694
[BIP174 discussion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016150.html

- **<!--dandelion-transaction-relay-->****[蒲公英][Dandelion]交易中继：** 本周在比特币开发邮件列表上简要讨论了这个提议的隐私增强改进，它涉及到新交易最初被传播的方式。主要关注点是它如何选择通过哪些节点路由交易，这可能在最初部署期间被滥用来暂时降低隐私，那时只有少数节点支持蒲公英。两种缓解这个问题的方法被讨论。

[Dandelion]: https://github.com/mablem8/bips/blob/master/bip-dandelion.mediawiki
[dandelion discussion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016162.html