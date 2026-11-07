---
title: 'Bitcoin Optech Newsletter #147'
permalink: /zh/newsletters/2021/05/05/
name: 2021-05-05-newsletter-zh
slug: 2021-05-05-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 鼓励矿工开始为 taproot 发出信号，并介绍围绕“仅凭钱包种子关闭已丢失的 LN 通道”这一想法的持续讨论。此外还包括我们的固定栏目：发布与候选发布公告，以及热门比特币基础设施软件值得注意的代码与文档变更。

## 行动项

- **<!--miners-encouraged-to-start-signaling-for-taproot-->****鼓励矿工开始为 taproot 发出信号：** 对于愿意强制执行 [taproot][topic taproot] 新共识规则的矿工，我们鼓励他们开始发出信号，并确保自己最迟在 [BIP341 中规定的最小激活区块](https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#deployment)之前，就能运行 Bitcoin Core 0.21.1（见下文）或其他兼容的、会强制执行 taproot 的软件。

  任何想要无需信任地监控信号进展的人，都可以升级到 Bitcoin Core 0.21.1 并使用 `getblockchaininfo` RPC。例如，下面的命令会打印当前难度调整周期内的区块数、其中已发出信号的区块数，以及 taproot 在本周期内有无可能激活（假设没有发生重组）：

  ```text
  $ bitcoin-cli getblockchaininfo \
    | jq '.softforks.taproot.bip9.statistics | .elapsed,.count,.possible'
  353
  57
  false
  ```

  如果你更喜欢带有补充矿工进展信息的图形化展示，并且不需要使用你自己的节点，我们推荐 Hampus Sjöberg 的 [taproot.watch][]。

## 新闻

- **<!--closing-lost-channels-with-only-a-bip32-seed-->****仅凭 BIP32 种子关闭已丢失的通道：** 正如 [Newsletter #128][news128 ln ecdh] 中所介绍的，Lloyd Fournier 提出了一种创建新通道的方法，能让除 BIP32 钱包种子之外丢失了所有信息的用户，仅凭 LN 网络的公开信息重新找到自己的对等节点。找到对等节点之后，用户就可以请求对方使用 [BOLT2][] 的数据丢失保护协议关闭双方的共同通道（参见 [Newsletter #31][news31 data_loss]）。所提议的方法并不完美——用户仍应创建备份[^missing-peer]并在相互独立的系统上复制多份——但 Fournier 的提议提供了额外的冗余，这对普通用户尤其有用。

  两周前，Rusty Russell 在尝试为该想法[编写规范][russell ecdh spec]并加以实现之后，重新启动了[讨论帖][russell ecdh channels]。在与 Fournier 进行了更多邮件列表讨论，并在每周的 LN 协议开发会议上做了一次小组[讨论][lndev deterministic]之后，Russell 表示他倾向于反对这个想法，[他说][russell backups]：“不过我认为加密备份是一个更有可能被实现的方案。因为把备份发到对等节点以外的地方很有用，而且如果你愿意，它们还可以包含 HTLC 信息。”能够包含 [HTLC][topic htlc] 信息，就可以结算当时仍处于挂起状态的支付，而这是仅依赖 BIP32 种子的任何恢复机制都无法提供的能力。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [Bitcoin Core 0.21.1][Bitcoin Core 0.21.1] 是 Bitcoin Core 的新版本，包含所提议的 [taproot][topic taproot] 软分叉的激活逻辑。Taproot 使用 [schnorr 签名][topic schnorr signatures]，并允许使用 [tapscript][topic tapscript]。这三者分别由 BIPs [341][BIP341]、[340][BIP340] 和 [342][BIP342] 规定。此外，该版本还包含向 [BIP350][] 规定的 [bech32m][topic bech32] 地址付款的能力，尽管在主网上付给这类地址的比特币，在使用这类地址的软分叉（如 taproot）激活之前并不安全。该版本还包括错误修复和小幅改进。

  注意：由于为 Bitcoin Core 的 Windows 版本提供代码签名证书的证书颁发机构出现了[问题][wincodesign]，Windows 用户安装时需要多点一次确认提示。预计问题解决后会发布带更新证书的 0.21.1.1 版本。如果你本来就打算升级，那么没有理由因为这个问题而推迟使用 0.21.1。

- [BTCPay 1.1.0][] 是该自托管支付处理软件的最新主要版本。它支持 [Lightning Loop][news53 lightning loop]，把 [WebAuthN/FIDO2][fido2 website] 增加为一种双因素认证选项，做了多项 UI 改进，并标志着今后的版本号将改用[语义化版本控制][semantic versioning website]。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[比特币改进提案（BIPs）][bips repo]以及[闪电网络规范（BOLTs）][bolts repo]中值得注意的变更。*

- [Bitcoin Core #19160][] 是 [multiprocess 项目][bitcoin core multiprocess]中的下一个 PR，添加了 `bitcoin-node` 进程生成其他进程并使用 [Cap'n Proto][capn proto] 与它们通信的能力。这些功能目前仅用于测试，但项目中的 [下一个 PR][Bitcoin Core #10102] 将允许 Bitcoin Core 以多进程模式启动，`bitcoin-core` 进程将生成单独的 `bitcoin-wallet` 和 `bitcoin-gui` 进程。

- [Bitcoin Core #19521][] 大体完成了 [币统计索引项目][bitcoin core coinstats]，让 `gettxoutsetinfo` RPC 大幅提速。此前该 RPC 每次被调用都要扫描完整的 UTXO 集，用户很难持续、快速地核验比特币供应量，或比较不同节点之间的 UTXO 集哈希。现在用户可以用 `-coinstatsindex` 配置选项启动节点，在后台开始构建币统计索引。一旦索引同步完成，`gettxoutsetinfo` 几乎瞬间返回，用户还可以为统计指定高度或区块哈希。能够获取特定区块的统计数据，对于让社区验证 [assumeUTXO][topic assumeutxo] 链状态存档尤其有用。

- [Bitcoin Core #21009][] 移除了在把 segwit 之前的节点（v0.13.0 或更早版本）升级到强制实施 segwit 的版本时触发的 RewindBlockIndex 逻辑。segwit 之前的节点只处理剥离过的区块，这些区块缺少（隔离的）见证数据。RewindBlockIndex 逻辑会丢弃这类区块的副本，按完整格式重新下载，再用 segwit 的规则验证。由于 segwit 之前的节点自 2018 年起就已停止维护，这种情况已不多见。今后的版本将改为提示用户重新索引（reindex），以获得等效结果。

- [LND #5159][] 在[此前工作][news144 lnd ampsendpayment]的基础上，增加了通过在 `sendpayment` RPC 中手动指定支付参数来发起自发原子多路径支付（AMP）的支持。用 AMP 发票调用 `sendpayment` 的功能预计会在后续 PR 中实现。

- [Rust-Lightning #893][] 现在只有在支付包含支付秘密（payment secret）时才接受该支付。支付秘密由接收方创建并写入发票。付款方在支付中带上该秘密，以防第三方降低[多路径支付][topic multipath payments]的隐私性。与这一改动同时进行的还有若干 API 变更，目的是降低支付被错误接受的概率。

- [BIPs #1104][] 依据 Speedy Trial 提案（参见 [Newsletter #139][news139 speedy trial]），更新了 [BIP341][] 中 [taproot][topic taproot] 规范的激活参数。

## 脚注

[^missing-peer]:
    数据丢失保护协议，以及其他提议的方法，如[请求双方共同关闭通道的隐蔽请求][news128 covert]，都要求你的通道对等节点仍然在线并能响应。如果对方已永久离线，而你又没有备份，你的资金就会永久丢失。如果你改从备份恢复，那么在广播旧状态时仍可能损失全部资金；但如果你备份的是最新状态，或者你的对等节点不对旧状态提出异议，你就有机会挽回资金。

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
