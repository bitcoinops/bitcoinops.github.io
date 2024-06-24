---
title: 'Bitcoin Optech Newsletter #41'
permalink: /zh/newsletters/2019/04/09/
name: 2019-04-09-newsletter-zh
slug: 2019-04-09-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 请求测试 Bitcoin Core 和 LND 的候选版本，描述了关于 UTXO 快照用于节点快速初始同步的讨论，并提供了 bech32 发送支持的常规报道以及流行的比特币基础设施项目中的值得注意的合并。

{% include references.md %}

## 行动项

- **<!--help-test-bitcoin-core-0-18-0-rc3-->****帮助测试 Bitcoin Core 0.18.0 RC3：** 下一个 Bitcoin Core 主要版本的第三个候选版本（RC）已被[发布][0.18.0]。这可能是最终的测试版本，因此我们鼓励组织和专家用户及时测试，以确保在发布之前捕获到任何可能的回归。请使用[这个问题][Bitcoin Core #15555]报告反馈。

- **<!--help-test-lnd-0-6-beta-rc3-->****帮助测试 LND 0.6-beta RC3：** 本周发布了下一个 LND 主要版本的第一个、第二个和第三个 RC。鼓励组织和经验丰富的 LN 用户进行测试，以捕获可能影响最终用户的回归或严重问题。如果发现任何问题，请[打开一个新问题][lnd issue]。

## 新闻

- **<!--discussion-about-an-assumed-valid-mechanism-for-utxo-snapshots-->****关于 UTXO 快照的假设有效机制的讨论：** 当 Bitcoin Core 开发者准备新的主要版本时，一位开发者会选择在最佳区块链上最近的区块哈希。其他知名贡献者检查他们的个人节点，并确保该哈希确实是最佳区块链的一部分，然后将该哈希添加到软件中作为“假设有效”区块。当新用户首次启动 Bitcoin Core 时，程序默认跳过假设有效区块之前所有交易的脚本评估[^full-chain-verification]。程序仍然跟踪每个交易产生的比特币所有权变化，并保存在称为未花费交易输出（UTXO）集的索引中。虽然审查每个历史所有权变化仍需要时间，但简单跳过脚本检查可以将初始同步时间减少大约 80%，根据[测试][0.14 tests]。实施假设有效特性的 Gregory Maxwell 认为，“因为链历史的有效性是一个简单的客观事实，审查这个设置非常容易”。

  本周，James O'Beirne 在 Bitcoin-Dev 邮件列表上发起了[讨论][assumeutxo thread]，讨论在特定区块拍摄 UTXO 集的哈希值，让多个知名贡献者验证他们得到相同的哈希值，然后让新安装的 Bitcoin Core 节点默认使用该哈希值下载完全相同的 UTXO 集。这将允许新启动的节点不仅跳过脚本，还跳过假设有效区块之前的所有区块链数据，可能将启动节点的时间要求减少 95% 以上（随着区块链的增长，这一比例肯定会更高）。然后可以在用户已经使用节点后在后台验证旧的区块和交易，最终为他们提供与禁用此功能的用户相同的安全性。这是一个旧的想法，也是研究其他技术（如[快速可更新的 UTXO 承诺][fast
  updatable UTXO commitments]和[自动 levelDB 备份][automatic levelDB backups]）的部分动机。

  讨论主要围绕这是否是一个好主意。支持的论点包括它使启动新节点变得更容易，并且它似乎没有改变对已经信任其开发团队同行评审的任何人的信任模型。反对的论点包括担心具有假设有效 UTXO 集的快速初始同步会掩盖区块大小增加使从头开始的完全初始同步变得更加昂贵的事实；如果区块大小增加过多，任何普通人可能无法信任地验证比特币的 UTXO 状态，迫使新用户信任现有用户。

## Bech32 发送支持

*第 4 周，共 24 周。在 2019 年 8 月 24 日 Segwit 软分叉锁定的第二周年纪念日之前，Optech Newsletter 将包含这一每周部分，提供帮助开发人员和组织实施 bech32 发送支持的信息——即支付原生 segwit 地址的能力。这[不需要自己实现 segwit][bech32 series]，但它确实允许你支付的人访问 segwit 的所有多重好处。*

{% include specials/bech32/zh/04-ecc.md %}

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和 [比特币改进提案 (BIPs)][bips repo] 中的值得注意的更改。注意：描述的所有 Bitcoin Core 和 LND 的合并都是到它们的主开发分支；有些可能也会被移植到他们的待定版本。*

- [Bitcoin Core #15596][] 更新了 `sendmany` RPC，移除了 `minconf` 参数，这[没有按预期功能工作][sendmany wackiness]。现在总是使用钱包默认值。默认值是不花费从其他人那里收到的未确认输出，并根据 `spendzeroconfchange` 配置设置可选择允许花费自己未确认的找零输出。这与更常用的 `sendtoaddress` RPC 一直以来的工作方式相同。

- [LND #2885][] 更改了 LND 在重新上线时尝试重新连接到所有对等节点的方式。以前它试图一次性打开所有持久对等节点的连接。现在它将连接分布在 30 秒窗口内，以减少约 20% 的峰值内存使用量。这也意味着定期发送的消息（如 ping）不会同时发生在所有对等节点。

- [LND #2740][] 实施了一个新的 gossip 子系统，将其对等节点分为两个桶，活跃的 gossiper 和被动的 gossiper。活跃的 gossipers 是以目前正常的方式与你的节点共享所有状态的对等节点；被动的 gossipers 是你只会请求特定更新的对等节点。因为大多数活跃的 gossipers 会发送与你的节点相同的更新，拥有超过几个是浪费你的带宽，所以这个代码将确保你得到默认的 3 个活跃 gossipers，然后将任何其他 gossipers 放入被动类别。此外，新代码将尝试在[轮流][round-robin]的基础上仅从一个活跃的 gossiper 请求更新，以避免从不同节点同步相同的更新。在 PR 中描述的一次测试中，这一变化减少了请求的 gossip 数据量 97.5%。

- [LND #2313][] 实施了代码和 RPC，允许 LND 节点使用静态通道备份。这基于在 [LND #2370][] 实施的数据丢失保护（DLP）协议，允许在任何时候备份包含所有当前通道状态的单个文件，然后启用从该文件恢复以在任何后期点让你的远程对等节点帮助你关闭任何这些通道的最新状态（不包括未完成的路由支付（HTLCs））。注意：尽管此功能名称中的“静态”，这不像 HD 钱包一次性备份。这是一个需要至少在每次你打开一个新通道时进行的备份——但这比当前状态要好得多，在当前状态下，如果你丢失数据，你可能无法恢复任何通道中的任何资金。PR 描述中提到了进一步提高备份鲁棒性。有关基于 DLP 的备份和恢复如何工作的更多详细信息，请参见 [Newsletter #31][] 中对 LND #2370 的描述。将这一重大改进合并到备份中是即将发布的 LND 版本 0.6-beta 的主要目标之一。

- [BIPs #772][] 应作者要求撤回了 [BIP151][]，作者提出了一种[替代方案][P2P protocol encryption]。

- [BIPs #756][] 分配了 [BIP127][] 给在 [Newsletter #33][] 中描述的储备金证明工具的规范。BIP 的草案文本已合并。

## 脚注

[^full-chain-verification]:
    假设有效机制默认启用，但可以通过使用配置参数 `assumevalid=0`（或 `noassumevalid`）启动 Bitcoin Core 来禁用。这将允许你的节点完全验证区块链中的每笔交易，以确保其遵循所有共识规则。请注意，这对你的节点已经处理的区块没有影响，因此如果你想验证旧区块中的脚本，你需要在首次使用节点时启用此选项，或者你需要一次性重新启动 Bitcoin Core，并使用 `reindex-chainstate` 配置选项。对于修剪节点，重新索引需要重新下载所有修剪的区块。

{% include linkers/issues.md issues="15555,9484,772,756,2313,15596,2885,2740,2370" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[0.14 tests]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#ibd
[p2p protocol encryption]: https://gist.github.com/jonasschnelli/c530ea8421b8d0e80c51486325587c52
[lnd releases]: https://github.com/lightningnetwork/lnd/releases
[lnd issue]: https://github.com/lightningnetwork/lnd/issues/new
[assumeutxo thread]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-April/016825.html
[fast updatable UTXO commitments]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-May/014337.html
[automatic leveldb backups]: https://github.com/bitcoin/bitcoin/issues/8037
[round-robin]: https://en.wikipedia.org/wiki/Round-robin_scheduling
[bitcoin core 0.5.0]: https://bitcoin.org/en/release/v0.5.0
[sendmany wackiness]: https://github.com/bitcoin/bitcoin/pull/15595#issue-260932169
[bech32 series]: /zh/bech32-sending-support/
[newsletter #31]: /zh/newsletters/2019/01/29/#lnd-2370
[newsletter #33]: /zh/newsletters/2019/02/12/#tool-released-for-generating-and-verifying-bitcoin-ownership-proofs