---
title: 'Bitcoin Optech Newsletter #1'
permalink: /zh/newsletters/2018/06/26/
name: 2018-06-26-newsletter-zh
slug: 2018-06-26-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
version: 1

excerpt: >
  本期技术讨论通讯公告对 Bitcoin Core 旧版本的潜在漏洞公开，指向关于改进币选择（Coin Selection）的 PR，并讨论 Bitcoin Core 多钱包模式下的动态钱包加载和卸载。
---

## 欢迎

欢迎阅读第一期 Bitcoin Optech 小组 Newsletter！作为我们新组织的一员，您可以期待我们定期发布的 Newsletter，内容涵盖比特币开源开发和协议新闻、Optech 公告以及会员公司的案例研究。我们计划在我们的网站上发布这些 Newsletter。

我们希望您觉得这份新闻通讯有价值。我们是为您创造这个的，所以如果您有任何反馈，请随时联系我们，无论是您想看到我们报道额外内容，还是对我们已经包含的内容的改进建议。

提醒还没有成为正式会员的公司。我们请求您支付 5000 美元的象征性贡献，以帮助我们资助我们的开支。

## 第一次 Optech 工作坊！

Bitcoin Optech 小组正在组织一系列工作坊的第一次活动，将于 **7 月 17 日在旧金山**举行。Square 已慷慨承诺主办下午的工作坊，之后我们将有一个小组晚餐。参与者将是来自旧金山湾区比特币公司的 1-2 名工程师。我们将就以下 3 个话题进行圆桌讨论：

- 币选择（Coin Selection）最佳实践；
- 费用估算，RBF（Replace-By-Fee），CPFP（Child-Pays-For-Parent）最佳实践；
- Optech 社区和沟通 -- 优化 Optech 以满足企业需求。

我们计划根据 Optech 会员公司的需求，在其他地区组织类似的工作坊。如果这听起来对您有吸引力，请随时与我们联系，让我们知道您希望看到什么。

## 开源新闻

我们在最初接触比特币公司时听到的一个一致主题是希望改善与开源社区的沟通。为此，我们计划在每期 Newsletter 中提供与更广泛的比特币开源社区相关的行动项、仪表盘项和新闻的摘要。

### 行动项

- **<!--pending-dos-vulnerability-disclosure-for-bitcoin-core-0-12-0-and-earlier-altcoins-may-be-affected-->****公开 Bitcoin Core 0.12.0 及更早版本的潜在 DoS 漏洞。山寨币可能会受到影响。** 如 2016 年 11 月的[公告][alert announcement]所述，Bitcoin Core 开发者计划公开中本聪于 2010 年创建用于签名网络警报的私钥。此密钥可能被滥用，导致 Bitcoin 0.3.9 至 Bitcoin Core 0.12.0 版本出现内存溢出(Out-of-Memory, OOM)情况，进而导致这些节点崩溃（但没有披露会导致资金损失的攻击）。许多山寨币都是基于 0.12.0 之前的代码分叉的，可能也容易受到同样的攻击，但它们使用不同的密钥，因此除非这些密钥也被误用，否则无法实施攻击。

  建议的行动包括：(1) 检查您的基础设施中是否有 0.12.0 或更早版本的比特币节点，并尽可能升级它们（这包括 Bitcoin XT、Bitcoin Classic 和 Bitcoin Unlimited 的旧版本）；(2) 检查您的基础设施中是否有基于 Bitcoin Core 0.12.0 或更早版本的山寨币节点，并升级它们或将它们置于过滤掉点对点协议警报消息的代理后面。如果您绝对依赖于 0.12.0 之前的节点，请立即通知 Bitcoin Core 开发者或您的Optech 联系人。

[alert announcement]: https://bitcoin.org/en/alert/2016-11-01-alert-retirement

- **<!--bitcoin-core-0-16-1-released-->****Bitcoin Core [0.16.1 发布][]：** 包含修复针对可能导致矿工在极罕见情况下遭受财产损失的情况。同时修复主要影响新节点的 DoS 攻击，并且包括关于中继策略的更改，以备一年多后可能的未来软分叉。建议所有用户升级，强烈推荐矿工升级。

[0.16.1 发布]: https://bitcoincore.org/en/2018/06/15/release-0.16.1/

- **<!--bitcoin-dev-mailing-list-changing-hosts-->****比特币开发邮件列表更换主机：** 如果您订阅了[公共比特币开发邮件列表][mailing list]，请注意即将发布关于域名更改的公告。除了将电子邮件地址改为不同的域名，目前还不清楚是否需要用户采取任何行动，尽管三年前的主机更换要求所有成员重新订阅。

[mailing list]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/

### 仪表盘项

- **<!--transaction-fee-increase-->****交易费用增加：** 上周早些时候观察到的交易费用激增，据信与 Bithumb 黑客攻击有关，既包括攻击者移动被盗资金，也包括其他人因应迅速变化的汇率而移动自己的资金。截至本邮件发送时，低费用交易仍能在几个区块内确认，因此现在是合并交易的好时机。

### 新闻

- **<!--new-backup-and-recovery-format-for-private-key-material-->****私钥信息的新备份和恢复格式：** 几位开发者正在为比特币私钥、HD 钱包扩展公钥和私钥以及 HD 钱包种子开发一种新的编码。该格式基于用于原生隔离见证地址的 bech32 格式。该编码正在[比特币开发邮件列表][bech32x]上积极开发中，鼓励任何处理私钥信息备份（例如纸质钱包备份）或为客户提供此类服务（例如资金清理）的公司参与进来。

[bech32x]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016065.html

- **<!--coin-selection-simulations-->****币选择模拟：** 即将发布的 Bitcoin Core 0.17.0 版本实现基于 Mark Erhardt 的[分支定界算法（Branch and Bound algorithm）][branch and bound paper]的更有效的币选择算法。目前，贡献者正在进行旨在识别当理想策略不起作用时的合适的备选策略的模拟。如果您的组织使用 Bitcoin Core 来优化币选择以最小化费用，那么跟踪或贡献比特币核心 PR [#13307][pr 13307]可能是值得的。

[branch and bound paper]: http://murch.one/wp-content/uploads/2016/11/erhardt2016coinselection.pdf
[pr 13307]: https://github.com/bitcoin/bitcoin/pull/13307


- **<!--bip174-discussion-->****[BIP174][] 讨论：** 关于这个提议的 BIP 的邮件列表[讨论][BIP174 discussion]仍在继续，该提议旨在制定行业标准，使钱包之间的通信变得更加容易，以应对在线/离线（热/冷）钱包、软件/硬件钱包和多签钱包的情况。然而，现在对该提案的重大更改正在遭到抵制，因此可能已临近最终确定。如果您的组织生产或必要使用上述互操作钱包之一，您可能希望在最终确定之前尽快评估当前提案。

[BIP174]: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
[BIP174 discussion]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016121.html


- **<!--dynamic-wallet-loading-in-bitcoin-core-->****Bitcoin Core 中的动态钱包加载：** 最后一个 PR 已经合并到比特币核心中，设计了一套新的 RPC，允许其在多钱包模式下动态创建新钱包、加载和卸载它们。如果您的组织在 Bitcoin Core 内部管理交易（或希望这样做），这可以显著简化您的钱包隔离（例如，将客户存款与公司资金分开，或将热钱包资金与仅观察的冷钱包资金分开）。在 Bitcoin Core git 的 master 分支上使用 RPC `createwallet`、`loadwallet` 和 `unloadwallet` 的预生产代码已可用。