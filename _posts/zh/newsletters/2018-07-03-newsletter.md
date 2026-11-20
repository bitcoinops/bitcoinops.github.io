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

我们已经改用新平台分发本周的 Newsletter。如果你不想每周收到比特币开源社区动态的更新，请点击本邮件底部的退订链接。

如果你对我们正在做的事情有任何疑问或评论，请随时通过 [info@bitcoinops.org](mailto:info@bitcoinops.org) 与我们联系！


## 欢迎

欢迎阅读第二期 Bitcoin Optech 小组 Newsletter！作为我们新组织的一员，你可以期待我们定期发布的 Newsletter，内容涵盖比特币开源开发和协议新闻、Optech 公告以及会员公司的案例研究。这些 Newsletter 也可在[我们的网站][newsletter page]上找到。

一如既往，如果你对本期 Newsletter 有任何反馈或评论，请随时联系我们。

提醒尚未成为正式会员的公司：我们请你缴纳 5000 美元的象征性会费，以资助我们的开支。

[newsletter page]: /zh/newsletters/


## 第一次 Optech 工作坊！

如先前公告，Bitcoin Optech 小组正在筹办第一场工作坊，**7 月 17 日在旧金山**举行。参与者是来自旧金山湾区比特币公司的 1-2 名工程师。我们将就以下 3 个话题进行圆桌讨论：

- 选币（Coin Selection）最佳实践；
- 费率估算、手续费替换（RBF）、子为父付（CPFP）最佳实践；
- Optech 社区与沟通 —— 让 Optech 更好地满足企业需求。

如果你想参与此次工作坊，或参与其他地区今后的工作坊，请与我们联系。

## 开源新闻

本期汇总来自更广泛的比特币开源社区的相关行动项、仪表盘项和新闻。

### 行动项

没有新的行动项，但仍建议跟进以下先前发布的项目。

- **<!--newsletter-1-->**Bitcoin Core 0.12.0 及更早版本有 DoS 漏洞待披露。山寨币可能受影响。参见 [Newsletter #1][newsletter #1]

- **<!--bitcoin-core-0-16-1-->**升级到 2018 年 6 月 15 日发布的 [Bitcoin Core 0.16.1][Bitcoin Core 0.16.1]。矿工尤其应升级。参见 [Newsletter #1][newsletter #1]

[Bitcoin Core 0.16.1]: https://bitcoincore.org/en/download/
[newsletter #1]: /zh/newsletters/2018/06/26/

### 仪表盘项

- **<!--transaction-fees-remain-very-low-->****交易手续费仍然很低：** 截至本文撰写时，预计 2 个或更多区块后确认的费率估算仍大致处于 Bitcoin Core 默认的最低中继手续费水平。这是[合并输入][consolidate inputs]的好时机。

  **更新（7 月 2 日）**：过去 3-4 天，估算的[网络哈希率][hash rate graph]有所下降，最初降幅最高达 10%，此后略有反弹。有人推测中国西南部的洪水摧毁了大量挖矿设备。但要注意，由于出块速度本身存在自然波动，短时间内只能对当前网络哈希率作粗略估计。网络哈希率降低意味着出块变慢，可能造成内存池拥堵，并可能推高手续费。到目前为止，内存池拥堵似未明显加剧，手续费仍然很低。不过，建议在发送大额交易前持续关注出块速度和内存池拥堵情况。

[consolidate inputs]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation

[hash rate graph]: https://bitcoinwisdom.com/bitcoin/difficulty

- **<!--testnet-high-block-production-rate-->****测试网出块率过高：** 上周晚些时候，一名矿工在测试网上接连出块，有时每秒就出好几个，导致部分测试网服务商的服务质量下降。这是测试网反复出现的问题，根源在于测试网刻意没有设置挖矿的经济激励。如果你需要测试自己的软件，使用 Bitcoin Core 的 [regtest 模式][regtest mode]搭建私有测试网会更可靠。

[regtest mode]: https://bitcoin.org/en/developer-examples#regtest-mode

### 新闻

- **<!--continued-discussion-over-graftroot-safety-->****关于 Graftroot 安全性的持续讨论：** [Graftroot][] 是针对 [taproot][] 提出的一种可选（opt-in）替代方案；taproot 是对 [MAST][] 提出的增强，而 MAST 本身又是对现有比特币脚本的增强。MAST 允许把比特币脚本中未使用的条件分支排除在区块链之外，从而改善可扩展性、隐私性和可替代性。taproot 进一步允许在常见情况下把脚本中实际用到的条件分支也排除在区块链之外，从而改善 MAST 的可扩展性、隐私性和可替代性。Graftroot 则允许脚本的参与者把自己的花费权限委托给其他方，包括允许现有参与者对受托方附加基于脚本的额外条件，从而改善 taproot 的灵活性和可扩展性；这些操作全部在链下完成，不会削弱可扩展性、隐私性和可替代性方面的收益。

  在一场进展缓慢的[讨论][graftroot discussion]中，比特币开发邮件列表的成员一直在尝试给出一个措辞不那么正式的安全性证明：默认启用 graftroot 委托，不会降低那些不需要该功能的用户的安全性（例如只想使用 taproot 而不做委托，甚至只用普通 MAST 的用户）。尽管还需要更多同行评审，但这项工作似乎进展顺利，专家目前一致认为默认启用 graftroot 是安全的。

[graftroot]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-February/015700.html
[taproot]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-January/015614.html
[MAST]: https://bitcointechtalk.com/what-is-a-bitcoin-merklized-abstract-syntax-tree-mast-33fdf2da5e2f
[graftroot discussion]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016049.html


- **<!--bip174-discussion-->****[BIP174][] 讨论：** 如[上周的 Newsletter][newsletter #1]所述，邮件列表上关于这项拟议 BIP 的[讨论][BIP174 discussion]仍在继续。该提案旨在形成一项行业标准，让在线/离线（热/冷）钱包、软件/硬件钱包、多重签名钱包以及多用户交易（例如 coinjoin）之间的通信更简单。不过，BIP 提议者现已提交 [PR][BIP174 update]，请求把该 BIP 的状态从“草案”改为“提议”。这意味着除非在实现中发现重大问题，否则它不太可能再被改动。如果你的组织生产上述互操作钱包之一，或对其有重要依赖，最好在它定稿之前尽快评估当前提案。

[BIP174]: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
[BIP174 update]: https://github.com/bitcoin/bips/pull/694
[BIP174 discussion]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016150.html

- **<!--dandelion-transaction-relay-->****[蒲公英][Dandelion]交易中继：** 本周，比特币开发邮件列表简要讨论了这项旨在增强隐私的改进提案，它针对的是新交易最初的中继方式。主要关注点在于它如何选择经由哪些对等节点中继交易；在仅少数节点支持蒲公英的初期部署阶段，这一点可能被滥用，从而暂时削弱隐私。讨论中提出了两种缓解办法。

[Dandelion]: https://github.com/mablem8/bips/blob/master/bip-dandelion.mediawiki
[dandelion discussion]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016162.html