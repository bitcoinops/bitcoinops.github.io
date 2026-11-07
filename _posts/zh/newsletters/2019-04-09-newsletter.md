---
title: 'Bitcoin Optech Newsletter #41'
permalink: /zh/newsletters/2019/04/09/
name: 2019-04-09-newsletter-zh
slug: 2019-04-09-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 呼吁大家测试 Bitcoin Core 与 LND 的候选版本，介绍了关于用 UTXO 快照加快节点初次同步的讨论，并照例介绍 bech32 发送支持，以及热门比特币基础设施项目中值得注意的合并。

{% include references.md %}

## 行动项

- **<!--help-test-bitcoin-core-0-18-0-rc3-->****帮助测试 Bitcoin Core 0.18.0 RC3：** 下一个 Bitcoin Core 主要版本的第三个候选版本（RC）已经[发布][0.18.0]。这可能是最后一个测试版本，因此我们鼓励组织和专家用户尽快测试，以便在正式发布前发现任何可能的回归问题。请通过[这个问题][Bitcoin Core #15555]报告反馈。

- **<!--help-test-lnd-0-6-beta-rc3-->****帮助测试 LND 0.6-beta RC3：** 本周[发布][lnd releases]了下一个 LND 主要版本的第一、第二和第三个 RC。我们鼓励组织和经验丰富的 LN 用户参与测试，以便发现可能影响正式版用户的回归问题或严重问题。如果发现问题，请[新开一个 issue][lnd issue]。

## 新闻

- **<!--discussion-about-an-assumed-valid-mechanism-for-utxo-snapshots-->****关于 UTXO 快照的“假设有效”机制的讨论：** Bitcoin Core 开发者准备新的主要版本时，会由一位开发者挑出最佳区块链上某个近期区块的哈希值。其他知名贡献者各自检查自己的节点，确认该哈希确实属于最佳区块链，然后把该哈希作为“假设有效”（assumed valid）区块写进软件。新用户首次启动 Bitcoin Core 时，程序默认会跳过该假设有效区块之前所有区块中所含交易的脚本评估[^full-chain-verification]。程序仍会记录每笔交易造成的比特币所有权变更，存入一个称为未花费交易输出（UTXO）集的索引中。逐条审查历史上的每次所有权变更固然仍要花时间，但仅跳过脚本检查就能把初始同步时间缩短约 80%——根据[测试][0.14 tests]的结果。[实现“假设有效”特性][Bitcoin Core #9484]的 Gregory Maxwell 曾论证：“由于链历史的有效性是一个简单的客观事实，审查这一设置很容易。”

  本周，James O'Beirne 在 Bitcoin-Dev 邮件列表上发起了[讨论帖][assumeutxo thread]：对某个特定区块处的 UTXO 集计算哈希，让多位知名贡献者各自验证得到相同的哈希，再让新安装的 Bitcoin Core 节点默认用这个哈希下载完全相同的 UTXO 集。这样，新启动的节点不仅能跳过脚本，还能跳过该假设有效区块之前的全部区块链数据，可能把今天启动一个节点所需的时间减少 95% 以上（而且随着区块链继续增长，这个比例肯定还会更大）。随后可以在用户已经开始使用节点之后，于后台验证较早的区块和交易，最终让他们的安全性等同于禁用此功能的用户。这是个老想法，也是推动研究[可快速更新的 UTXO 承诺][fast updatable UTXO commitments]和[自动 levelDB 备份][automatic levelDB backups] 等其他技术的部分动机。

  讨论主要围绕这个想法是否可取。支持的观点包括：它让启动新节点容易得多；对已经信任自己开发团队同侪评审的人来说，信任模型似乎也没有改变。反对的观点则担心：依靠假设有效的 UTXO 集做快速初始同步，会掩盖一个事实——区块大小增大会让从头开始的完整初始同步昂贵得多；如果区块大小增长过多，财力普通的人可能再也无法以无须信任的方式验证比特币的 UTXO 状态，从而迫使新用户去信任老用户。

## Bech32 发送支持

*第 4 周，共 24 周。在 2019 年 8 月 24 日 segwit 软分叉锁定满两周年之前，Optech Newsletter 每周都会包含这一栏目，提供信息帮助开发者和组织实现 bech32 发送支持——也就是能够向原生 segwit 地址付款。你[不需要自己实现 segwit][bech32 series]，但你付款的对象却能享受到 segwit 带来的种种好处。*

{% include specials/bech32/zh/04-ecc.md %}

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案 (BIPs)][bips repo] 中值得注意的变更。注意：文中描述的 Bitcoin Core 与 LND 合并都发生在各自的 master 开发分支上；其中一些也可能被向后移植到各自待发布的版本中。*

- [Bitcoin Core #15596][] 更新了 `sendmany` RPC，移除了 `minconf` 参数，因为该参数[的表现与人们预期的不符][sendmany wackiness]。现在一律使用钱包的默认行为：在来自他人的输出得到确认之前不动用它们，并根据 `spendzeroconfchange` 配置设置，选择性地允许花费自己尚未确认的找零输出。这与更常用的 `sendtoaddress` RPC 一直以来的工作方式相同。

- [LND #2885][] 更改了 LND 在重新上线时尝试重新连接所有对等节点的方式。以前它会一次性向所有持久对等节点发起连接；现在它把这些连接分散到 30 秒的时间窗口内，使峰值内存占用降低约 20%。这也意味着定期发送的消息（如 ping）不会在同一时刻发给所有对等节点。

- [LND #2740][] 实现了新的 gossip 子系统，把对等节点分成两类：活跃 gossiper 与被动 gossiper。活跃 gossiper 是那些按目前常规方式、把自身全部状态共享给你的节点的对等节点；被动 gossiper 则是你只会向其请求特定更新的对等节点。由于大多数活跃 gossiper 发给你的更新与所有其他 gossiper 相同，多留几个纯粹是浪费带宽，因此这段代码会确保你默认只保留 3 个活跃 gossiper，其余 gossiper 一律划入被动类别。此外，新代码会以[轮询（round-robin）][round-robin]方式，同一时间只向一个活跃 gossiper 请求更新，避免从不同节点重复同步相同的更新。在 PR 描述的一次测试中，这项改动使请求的 gossip 数据量减少了 97.5%。

- [LND #2313][] 实现了相关代码与 RPC，允许 LND 节点使用静态通道备份。它基于 [LND #2370][] 中实现的数据丢失保护（DLP）协议，可以随时把当前全部通道状态备份到一个文件，之后也能从这个文件恢复，让你的远端对等节点协助你按最新状态关闭其中任一通道（不含尚未最终确定的路由支付（HTLC））。注意：尽管这个功能名字里带“静态”，它并不像 HD 钱包那样只备份一次。它是一份至少每次开新通道时都要重做一次的备份——但这已经比现状好得多：在现状下，一旦数据丢失，你可能一个通道里的资金都救不回来。PR 描述中还提到会进一步改善备份的鲁棒性。关于基于 DLP 的备份与恢复如何工作，详见 [Newsletter #31][] 中对 LND #2370 的描述。把这项备份方面的重大改进合并进来，是即将发布的 LND 0.6-beta 版的主要目标之一。

- [BIPs #772][] 应作者要求撤回了 [BIP151][]，该作者已针对 [P2P 协议加密][P2P protocol encryption] 提出了一种替代方案。

- [BIPs #756][] 把 [BIP127][] 分配给 [Newsletter #33][] 中所述的储备证明工具规范。该 BIP 的草案文本已合并。

## 脚注

[^full-chain-verification]:
    假设有效机制默认启用，但可以通过带配置参数 `assumevalid=0`（或 `noassumevalid`）启动 Bitcoin Core 来禁用。禁用后，你的节点会完整验证区块链中的每笔交易，确保其遵循所有共识规则。请注意，这对你的节点已经处理过的区块没有影响；因此如果你想验证旧区块中的脚本，就需要从第一次使用节点起就启用该选项，或者用 `reindex-chainstate` 配置选项重启一次 Bitcoin Core。对于修剪（pruned）节点，重建索引需要重新下载所有被修剪掉的区块。

{% include linkers/issues.md issues="15555,9484,772,756,2313,15596,2885,2740,2370" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[0.14 tests]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#ibd
[p2p protocol encryption]: https://gist.github.com/jonasschnelli/c530ea8421b8d0e80c51486325587c52
[lnd releases]: https://github.com/lightningnetwork/lnd/releases
[lnd issue]: https://github.com/lightningnetwork/lnd/issues/new
[assumeutxo thread]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-April/016825.html
[fast updatable UTXO commitments]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-May/014337.html
[automatic leveldb backups]: https://github.com/bitcoin/bitcoin/issues/8037
[round-robin]: https://en.wikipedia.org/wiki/Round-robin_scheduling
[bitcoin core 0.5.0]: https://bitcoin.org/en/release/v0.5.0
[sendmany wackiness]: https://github.com/bitcoin/bitcoin/pull/15595#issue-260932169
[bech32 series]: /zh/bech32-sending-support/
[newsletter #31]: /zh/newsletters/2019/01/29/#lnd-2370
[newsletter #33]: /zh/newsletters/2019/02/12/#tool-released-for-generating-and-verifying-bitcoin-ownership-proofs