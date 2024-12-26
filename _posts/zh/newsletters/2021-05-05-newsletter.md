---
title: 'Bitcoin Optech Newsletter #147'
permalink: /zh/newsletters/2021/05/05/
name: 2021-05-05-newsletter-zh
slug: 2021-05-05-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 鼓励矿工开始为 taproot 发出信号，并描述了关于仅使用钱包种子关闭丢失的 LN 通道的持续讨论。此外，还包括我们的定期栏目，其中有发布与候选发布的公告，以及流行比特币基础设施软件的值得注意的更改描述。

## 行动项

- **<!--draft-ln-splicing-->****鼓励矿工开始为 taproot 发出信号：** 预计愿意强制执行 [taproot][topic taproot] 新共识规则的矿工被鼓励开始发出信号，并确保他们能够在 [BIP341 中指定的最小激活区块](https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#deployment) 之前运行 Bitcoin Core 0.21.1（下文描述）或其他兼容的 taproot 强制执行软件。

  任何想要无需信任地监控信号进展的人可以升级到 Bitcoin Core 0.21.1 并使用 `getblockchaininfo` RPC。例如，以下命令行将打印当前重定向期内的区块数、已发出信号的区块数，以及 taproot 在此期间激活的可能性（假设没有重组）：

  ```text
  $ bitcoin-cli getblockchaininfo \
    | jq '.softforks.taproot.bip9.statistics | .elapsed,.count,.possible'
  353
  57
  false
  ```

  如果您更喜欢带有补充矿工进展信息的图形表示，并且不需要使用您自己的节点，我们推荐 Hampus Sjöberg 的 [taproot.watch][]。

## 新闻

- **<!--draft-ln-splicing-->****仅使用 BIP32 种子关闭丢失的通道：** 正如 [Newsletter #128][news128 ln ecdh] 中所述，Lloyd Fournier 提出了创建新通道的方法，该方法允许仅通过其 BIP32 钱包种子丢失所有信息的用户，仅使用关于 LN 网络的公共信息重新发现其对等方。一旦用户找到其对等方，他们可以请求对等方使用 [BOLT2][] 数据丢失保护协议关闭他们的共同通道（参见 [Newsletter #31][news31 data_loss]）。所提议的方法并不完美——用户仍应创建备份[^missing-peer] 并在独立系统之间复制它们——但 Fournier 的提议提供了额外的冗余，这对于日常用户尤其有用。

  两周前，Rusty Russell 在尝试[规范][russell ecdh spec]和实现该想法后，重新启动了[讨论线程][russell ecdh channels]。在与 Fournier 以及每周 LN 协议开发会议中的小组[对话][lndev deterministic]进行了一些额外的邮件列表讨论后，Russell 表示他倾向于反对该想法，[称][russell backups]：“我认为加密备份是一个更可能被实施的解决方案。因为它们有用，可以发送到除了对等方之外的地方，并且如果需要，它们还可以包含 HTLC 信息。” 能够包含 [HTLC][topic htlc] 信息将允许结算当时挂起的支付，这是基于仅使用 BIP32 种子的任何恢复机制无法提供的能力。

## 发布与候选发布

*流行的比特币基础设施项目的新版本发布与候选发布。请考虑升级到新版本或协助测试候选发布。*

- [Bitcoin Core 0.21.1][Bitcoin Core 0.21.1] 是 Bitcoin Core 的新版本，包含了提议的 [taproot][topic taproot] 软分叉的激活逻辑。Taproot 使用 [schnorr 签名][topic schnorr signatures]并允许使用 [tapscript][topic tapscript]。这些分别由 BIPs [341][BIP341]、[340][BIP340] 和 [342][BIP342] 规定。此外，还包括使用 [BIP350][] 规定的 [bech32m][topic bech32] 地址支付的能力，尽管在主网上向这些地址支付的比特币在使用这些地址的软分叉（如 taproot）激活之前不会是安全的。该版本还包括错误修复和小幅改进。

  注意：由于为 Bitcoin Core 的 Windows 版本提供代码签名证书的证书颁发机构存在[问题][wincodesign]，Windows 用户需要点击额外的提示来安装。预计在问题解决后，将发布带有更新证书的 0.21.1.1 版本。如果您计划升级，因这一问题而延迟使用 0.21.1 没有必要。

- [BTCPay 1.1.0][] 是该自托管支付处理软件的最新主要版本。它包括对 [Lightning Loop][news53 lightning loop] 的支持，添加了使用 [WebAuthN/FIDO2][fido2 website] 作为两因素认证选项，进行了各种 UI 改进，并标记了未来版本号将采用[语义化版本控制][semantic versioning website]。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中发生的值得注意的更改。*

- [Bitcoin Core #19160][] 是 [multiprocess 项目][bitcoin core multiprocess]中的下一个 PR，添加了 `bitcoin-node` 进程生成其他进程并使用 [Cap'n Proto][capn proto] 与它们通信的能力。这些功能目前仅用于测试，但项目中的 [下一个 PR][Bitcoin Core #10102] 将允许 Bitcoin Core 以多进程模式启动，`bitcoin-core` 进程将生成单独的 `bitcoin-wallet` 和 `bitcoin-gui` 进程。

- [Bitcoin Core #19521][] 几乎完成了 [coin statistics index 项目][bitcoin core coinstats]，大幅加快了 `gettxoutsetinfo` RPC 的速度。直到现在，RPC 每次调用都会扫描完整的 UTXO 集，使用户难以持续快速地验证币供应或比较不同节点之间的 UTXO 集哈希。用户现在可以使用 `-coinstatsindex` 配置选项启动他们的节点，以在后台开始构建币统计索引。一旦同步完成，`gettxoutsetinfo` 几乎瞬间运行，用户可以为统计数据指定高度或区块哈希。能够获取特定区块的统计数据将特别有助于允许社区验证 [assumeUTXO][topic assumeutxo] chainstate 存档。

- [Bitcoin Core #21009][] 移除了在将预 SegWit 节点（v0.13.0 或更早版本）更新为强制 SegWit 版本时触发的 RewindBlockIndex 逻辑。预 SegWit 节点仅处理缺少（隔离）见证数据的精简区块。RewindBlockIndex 逻辑丢弃了这些区块的副本，以完整形式重新下载它们，并使用 SegWit 规则进行验证。由于预 SegWit 节点自 2018 年以来已停止支持，这种情况已变得不常见。未来的发布将提示用户重新索引以获得等效结果。

- [LND #5159][] 基于[之前的工作][news144 lnd ampsendpayment]，通过手动指定支付参数为 `sendpayment` RPC 添加了支持进行自发的原子多路径支付（AMP）。预计使用 AMP 发票调用 `sendpayment` 的功能将在后续 PR 中实现。

- [Rust-Lightning #893][] 仅允许在包含支付秘密的情况下接受支付。支付秘密由接收方创建并包含在发票中。支出者在支付中包含支付秘密以防止第三方尝试降低[多路径支付][topic multipath payments]的隐私。与此变化一起，还有几个 API 更改旨在减少支付被错误接受的可能性。

- [BIPs #1104][] 根据 Speedy Trial 提案（参见 [Newsletter #139][news139 speedy trial]）更新了 [BIP341][] [taproot][topic taproot] 规范的激活参数。

## 脚注

[^missing-peer]:
    数据丢失保护协议，以及其他提议的方法，如[共同关闭通道的隐蔽请求][news128 covert]，要求您的通道对等方仍然在线并且有响应。如果他们已永久无法访问且您没有备份，您的资金将永久丢失。如果您从备份恢复，您可能仍会在广播旧状态时失去所有资金，但如果您备份了最新状态或您的对等方不反对旧状态，您有机会恢复您的资金。

{% include references.md %}
{% include linkers/issues.md issues="19160,19521,21009,5159,893,1104,10102" %}
[bitcoin core 0.21.1]: https://bitcoincore.org/bin/bitcoin-core-0.21.1/
[btcpay 1.1.0]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.1.0
[wincodesign]: https://github.com/bitcoin-core/gui/issues/252#issuecomment-802591628
[russell ecdh channels]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-April/002996.html
[russell ecdh spec]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-April/002998.html
[russell backups]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-April/003026.html
[news128 covert]: /zh/newsletters/2020/12/16/#covert-request-for-mutual-close
[taproot.watch]: https://taproot.watch/
[news128 ln ecdh]: /zh/newsletters/2020/12/16/#fast-recovery-without-backups
[news31 data_loss]: /zh/newsletters/2019/01/29/#fn:fn-data-loss-protect
[news139 speedy trial]: /zh/newsletters/2021/03/10/#a-short-duration-attempt-at-miner-activation
[lndev deterministic]: https://lightningd.github.io/meetings/ln_spec_meeting/2021/ln_spec_meeting.2021-04-26-20.17.log.html#l-115
[bitcoin core multiprocess]: https://github.com/bitcoin/bitcoin/projects/10
[capn proto]: https://capnproto.org/
[bitcoin core coinstats]: https://github.com/bitcoin/bitcoin/pull/18000
[news53 lightning loop]: /zh/newsletters/2019/07/03/#lightning-loop-supports-user-loop-ins
[semantic versioning website]: https://semver.org/
[fido2 website]: https://fidoalliance.org/fido2/fido2-web-authentication-webauthn/
[news144 lnd ampsendpayment]: /zh/newsletters/2021/04/14/#lnd-5108
