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
  本期技术讨论通讯公告对 Bitcoin Core 旧版本的潜在漏洞公开，指向关于改进选币（Coin Selection）的 PR，并讨论 Bitcoin Core 多钱包模式下的动态钱包加载和卸载。
---

## 欢迎

欢迎阅读第一期 Bitcoin Optech 小组 Newsletter！作为我们新组织的一员，你可以期待我们定期发布的 Newsletter，内容涵盖比特币开源开发和协议新闻、Optech 公告以及会员公司的案例研究。我们计划在我们的网站上发布这些 Newsletter。

我们希望这份 Newsletter 对你有价值。这份 Newsletter 是为你而办的，因此如果你有任何反馈，请随时联系我们，无论是希望我们增加报道的内容，还是对现有内容的改进建议。

提醒尚未成为正式会员的公司：我们请你缴纳 5000 美元的象征性会费，以资助我们的开支。

## 第一次 Optech 工作坊！

Bitcoin Optech 小组正在组织系列工作坊中的第一场，将于 **7 月 17 日在旧金山**举行。Square 慷慨提出主办下午的工作坊，之后我们还将共进晚餐。参与者是来自旧金山湾区比特币公司的 1-2 名工程师。我们将就以下 3 个话题进行圆桌讨论：

- 选币（Coin Selection）最佳实践；
- 费率估算、手续费替换（RBF）、子为父付（CPFP）最佳实践；
- Optech 社区与沟通 —— 让 Optech 更好地满足企业需求。

我们计划根据 Optech 会员公司的需求，在其他地区组织类似的工作坊。如果你觉得这有吸引力，请随时联系我们，告诉我们你希望看到哪些内容。

## 开源新闻

我们最初接触比特币公司时，反复听到的一个主题是：希望改善与开源社区的沟通。为此，我们计划在每期 Newsletter 中汇总相关的行动项、仪表盘项，以及更广泛的比特币开源社区的新闻。

### 行动项

- **<!--pending-dos-vulnerability-disclosure-for-bitcoin-core-0-12-0-and-earlier-altcoins-may-be-affected-->****Bitcoin Core 0.12.0 及更早版本有 DoS 漏洞待披露。山寨币可能受影响。** 如 2016 年 11 月的[公告][alert announcement]所述，Bitcoin Core 开发者计划公开中本聪于 2010 年创建、用于签署网络警报的私钥。该私钥一旦被滥用，可让 Bitcoin 0.3.9 至 Bitcoin Core 0.12.0 的节点出现内存耗尽（out-of-memory，OOM），最终导致这些节点崩溃（但目前没有披露会造成资金损失的攻击）。许多山寨币分叉自 0.12.0 之前的代码，可能同样易受攻击，不过它们使用不同的密钥，因此除非这些密钥也被滥用，攻击无法实施。

  建议采取的行动：(1) 检查你的基础设施中是否存在 0.12.0 或更低版本的比特币节点，尽可能将其升级（包括旧版本的 Bitcoin XT、Bitcoin Classic 和 Bitcoin Unlimited）；(2) 检查你的基础设施中是否存在基于 Bitcoin Core 0.12.0 或更低版本的山寨币节点，将其升级，或置于代理之后，由代理过滤点对点协议的警报消息。如果你完全依赖 0.12.0 之前的节点，请立即告知 Bitcoin Core 开发者或你的 Optech 联系人。

[alert announcement]: https://bitcoin.org/en/alert/2016-11-01-alert-retirement

- **<!--bitcoin-core-0-16-1-released-->****Bitcoin Core [0.16.1 发布][]：** 修复了一个可能导致矿工损失资金的缺陷，该情形预计极为罕见；同时修复了一个主要影响新节点的 DoS 攻击，并针对一年多以后可能实施的软分叉预先调整了中继策略。建议所有用户升级，矿工尤其强烈建议升级。

[0.16.1 发布]: https://bitcoincore.org/en/2018/06/15/release-0.16.1/

- **<!--bitcoin-dev-mailing-list-changing-hosts-->****比特币开发邮件列表更换主机：** 如果你订阅了[公共比特币开发邮件列表][mailing list]，请注意将很快发布关于域名变更的公告。目前尚不清楚除了今后需把邮件发往新域名之外，是否还需要用户做别的操作，不过三年前那次更换主机曾要求所有成员重新订阅。

[mailing list]: https://groups.google.com/g/bitcoindev/

### 仪表盘项

- **<!--transaction-fee-increase-->****交易手续费上涨：** 上周初观察到的交易手续费激增，据信与 Bithumb 交易所被黑有关，既涉及攻击者转移被盗资金，也涉及其他人在汇率剧烈波动之际转移自己的资金。截至本邮件发出时，低手续费交易仍能在几个区块内确认，因此眼下是做合并交易的好时机。

### 新闻

- **<!--new-backup-and-recovery-format-for-private-key-material-->****私钥材料的新备份与恢复格式：** 几位开发者正在为比特币私钥、HD 钱包扩展公钥和私钥以及 HD 钱包种子设计一种新的编码。该格式大致基于原生隔离见证地址所用的 bech32 格式。这一编码正在[比特币开发邮件列表][bech32x]上积极开发，任何在自己备份中保管私钥材料（例如纸钱包备份）或向客户提供此类服务（例如资金归集）的公司，都欢迎参与。

[bech32x]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016065.html

- **<!--coin-selection-simulations-->****选币模拟：** 即将发布的 Bitcoin Core 0.17.0 实现了一种高效得多的选币算法，它基于 Mark Erhardt 的[分支定界算法（Branch and Bound）][branch and bound paper]。贡献者目前正在运行模拟，以找出这一理想策略失效时适用的备选策略。如果你的组织借助 Bitcoin Core 优化选币以尽量降低手续费，不妨关注 Bitcoin Core PR [#13307][pr 13307]，或直接参与其中。

[branch and bound paper]: http://murch.one/wp-content/uploads/2016/11/erhardt2016coinselection.pdf
[pr 13307]: https://github.com/bitcoin/bitcoin/pull/13307


- **<!--bip174-discussion-->****[BIP174][] 讨论：** 邮件列表上关于这项拟议 BIP 的[讨论][BIP174 discussion]仍在继续。该提案旨在形成一项行业标准，让在线/离线（热/冷）钱包、软件/硬件钱包和多重签名钱包之间的通信更简单。不过，目前针对该提案的重大改动正遭到抵制，因此最终定稿可能为期不远。如果你的组织生产上述互操作钱包之一，或对其有重要依赖，最好在它定稿之前尽快评估当前提案。

[BIP174]: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
[BIP174 discussion]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-June/016121.html


- **<!--dynamic-wallet-loading-in-bitcoin-core-->****Bitcoin Core 中的动态钱包加载：** 为一组新增 RPC 而提交的最后一个 PR 已经合并。这组 RPC 让 Bitcoin Core 能在多钱包模式下动态创建、加载和卸载钱包。如果你的组织在 Bitcoin Core 内管理交易（或希望这样做），这可以大大方便你划分钱包（例如把客户存款与公司资金分开，或把热钱包资金与只读冷钱包资金分开）。预生产代码已可在 Bitcoin Core 的 git master 分支上使用，对应的 RPC 为 `createwallet`、`loadwallet` 和 `unloadwallet`。
