---
title: 'Bitcoin Optech Newsletter #115'
permalink: /zh/newsletters/2020/09/16/
name: 2020-09-16-newsletter-zh
slug: 2020-09-16-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 建议检查是否有易受 InvDoS 攻击的节点，简要描述该攻击，总结了针对 LN 通道的另一种攻击，并链接到 Crypto Open Patent Alliance 的公告。此外，还包括我们的常规发布、候选发布以及流行比特币基础设施项目的显著更改。

## 行动项

- **<!--check-for-nodes-vulnerable-to-the-invdos-attack-->****检查是否有易受 InvDoS 攻击的节点：** 本周披露的攻击影响了多个旧版本的全节点软件（包括一些山寨币）。根据[论文][invdos paper]，受影响的比特币软件包括“Bitcoin Core v0.16.0、Bitcoin Core v0.16.1、Bitcoin Knots v0.16.0、所有 bcoin 的测试版本至 v1.0.0-pre，[以及]所有 btcd 的版本至 v0.20.1-beta。”比特币核心、Bitcoin Knots、bcoin 和 btcd 的最新版本均已修复漏洞。详细信息请见下文 *新闻* 部分。

## 新闻

- **<!--inventory-out-of-memory-denial-of-service-attack-invdos-->****库存内存耗尽拒绝服务攻击（InvDoS）：** Braydon Fuller 和 Javed Khan 向 Bitcoin-Dev 邮件列表[发布][invdos post]了一个攻击（[网站][invdos site]、[论文][invdos paper]、[CVE-2018-17145][]），此前他们已向各种比特币及其衍生的全节点维护者披露该攻击。该攻击涉及比特币节点使用的 `inv`（库存）消息，用于通知其对等方新交易（或其他数据）的哈希值。通常，当节点接收到库存时，它会检查是否已有该哈希值的交易，然后请求完整的未见过的交易。在此攻击中，攻击者会向受害节点发送大量 `inv` 消息，每条消息几乎包含最大数量的交易哈希。当过多的库存被排队时，受害节点的内存会耗尽并崩溃。

  多个受影响的程序中已有代码限制应排队的库存数量，但研究人员能够绕过这些保护。作为一种仅能使节点崩溃的漏洞，它无法直接用于窃取受影响节点的资金。然而，它可用于执行[日蚀攻击][topic eclipse attacks]，最终可能导致资金被盗，尽管尚无证据表明此攻击已在公开场合使用。

  建议所有用户升级到所选全节点软件的最新版本，或查看[网站][invdos site]上的受影响和已修补版本列表。

- **<!--stealing-onchain-fees-from-ln-htlcs-->****从 LN HTLC 中窃取链上费用：** Antoine Riard 向 Lightning-Dev 邮件列表[发布][riard post]了关于 LN 规范近期更新中的潜在漏洞（见 [Newsletter #112][news112 bolts688]）。根据更新规范，远程方在为其 2-of-2 多签脚本的一半签名时包含了一个[标志][sighash]。该标志，即 `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY`，允许支付（称为 HTLC）被放入包含其他输入和输出的交易中。此设计允许多个 HTLC 被捆绑在一起进入一个包含额外输入的交易中，该输入支付任何额外的交易费用，且包含可选的额外输出用于收取支付这些额外费用后的剩余资金。这使得在 HTLC 确认前选择支付的费率成为可能。

  {:.center}
  ![使用费用提升输入和找零输出支出 HTLC](/img/posts/2020-09-htlc-fee-bumping.dot.png)

  但是，Riard 注意到此前的机制仍然可以让 HTLCs 提交可变费率。攻击者可以将多个 HTLC 设置为高费用，然后构造一个仅包含一个额外输出的交易，以获取预期用于支付费用的部分资金。Riard 的邮件描述了如何利用此基本技术进行更复杂的攻击，以最大化窃取的金额。

  {:.center}
  ![使用找零输出从过度支付费用的 HTLC 中窃取费用](/img/posts/2020-09-htlc-fee-stealing.dot.png)

  已提出几种解决方案，其中最简单的可能是让 HTLC 仅支付最小中继费用——要求广播 HTLC 的方添加任何必要的额外费用。尚无 LN 实现默认使用此更新规范，因此只有那些使用与[锚定输出][topic anchor outputs]相关的实验选项的用户可能受到影响。

- **<!--crypto-open-patent-alliance-->****Crypto Open Patent Alliance：** Square [宣布][square tweet]成立一个[组织][copa]，以协调加密货币技术相关专利的共享。成员允许任何人自由使用其专利，作为交换，成员可以在面对专利侵权者时使用池中的专利进行防御。除了 Square，Blockstream 也[宣布][blockstream tweet]加入该联盟。

## 发布与候选发布

*流行比特币基础设施项目的新发布和候选发布。请考虑升级到新版本或帮助测试候选版本。*

- [C-Lightning 0.9.1][C-Lightning 0.9.1] 是一个新版本，包含许多新功能和漏洞修复，包括以下 *值得注意的更改* 部分中描述的所有新功能。详情请参阅项目的[发布说明][cl 0.9.1 rn]。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范（BOLTs）][bolts repo]中值得注意的更改。*

- [C-Lightning #4020][] 增加了一个新的 `channel_state_changed` 通知钩子，每次通道状态更改时（例如从“正常”操作状态变为“关闭中”）都会触发该通知。

- [C-Lightning #3812][] 添加了 `multiwithdraw` RPC，允许向多个地址发送链上资金，实现[支付批处理][topic payment batching]。

- [C-Lightning #3763][] 添加了 `multifundchannel` RPC，允许使用单个包含多个输出的存款交易来同时资助多个通道。由于支付批处理的效率优势，此举可节省 75% 或更多的交易费用。作为实验，此新功能已被用于在测试网上[向每个功能正常并公开的 LN 节点][russell tx]开设一个通道（[tweet][russell tweet]）。

- [C-Lightning #3973][] 增加了双向资助通道的接收方支持。双向资助通道中，两个参与方均出资，而不仅仅是单一发起方出资（参见 Newsletters [#22][news22 dual] 和 [#83][news83 dual]）。发起方的初始实现仍在开发中，相关规范变更的[草案][neigut interactive funding]已公布。

- [C-Lightning #3870][] 实现了惩罚交易的“焦土”费用提升机制。如果远程对等方广播了旧的通道状态，本地节点可以使用相应的撤销密钥创建惩罚交易，支出由不合规对等方声称的所有资金。为避免此情况，对等方可能尝试贿赂矿工以忽略诚实节点的惩罚交易。焦土策略通过费用提升惩罚交易，使其支付的费用达到其全部价值，确保不合规对等方无法从其试图窃取的资金中获利。理论上，如果窃贼知道他们无法从攻击中获利，则不会尝试此类攻击。此 PR 似乎受到 Lightning-Dev 邮件列表七月讨论的[启发][C-Lightning #3832]，详见 [Newsletter #104][news104 scorched earth]。

  C-Lightning 使用的焦土策略是定期提高惩罚交易的费用，最终将其替换为支付全部价值的交易。任何其他实现类似策略的人可能需要审查此代码，了解其如何处理潜在问题，例如最小交易大小（见 [Newsletter #99][news99 min]）和 Bitcoin Core 中一年多前的最大费用 API 更改（见 [Newsletter #39][news39 maxfeerate]）。

- [LND #4310][] 添加了使用 `lncli` 创建和使用配置文件的功能。配置文件会将保存的参数自动应用到所有连接中，非常适合那些始终使用相同的非默认参数或连接到多个服务器的用户。例如，用户可以创建一个配置文件，直接使用 `lncli -p test getinfo` 而非 `lncli --rpcserver=10019 --network=regtest getinfo`。此外，还允许将 LND 的认证凭证（“macaroons”）通过加密存储在配置文件中。

- [LND #4558][] 更新了 LND 的现有[锚定输出][topic anchor outputs]实现，以符合三周前合并的最新规范（见 [Newsletter #112][news112 bolts688]）。此外，计划在 LND 的下一个主要版本中将其默认启用，从实验功能集中移除。

- [Rust-Lightning #618][] 添加了对 rust-lightning 的 C/C++ 绑定支持。这为创建其他语言（如 Swift、Java、Kotlin 和 JavaScript）的 API 提供了框架。相比 JSON 或 RPC 等替代方法，该方法具有更高的性能和内存效率，这对移动和资源受限环境尤为重要。更多详情请参见[绑定文档][bindings readme]。

- [Libsecp256k1 #558][] 实现了 secp256k1 椭圆曲线上的 [Schnorr 签名][topic schnorr signatures]验证和单方签名，符合 [BIP340][] 的标准化。相比比特币现有的 ECDSA 签名，Schnorr 签名依赖较少的安全假设、不可篡改，并允许更简单的密钥聚合方案，如 [MuSig][topic musig]。Schnorr 签名也是 [taproot][topic taproot] 的关键组成部分，taproot 使用聚合的 Schnorr 签名实现“共识”密钥路径支出。使用密钥路径支出 taproot 输出提供更好的支出条件隐私性并减少签名大小。Bitcoin Core 也已[更新][Bitcoin Core #19944]其内部 libsecp256k1 树以包含此更改。

{% include references.md %}
{% include linkers/issues.md issues="4020,3812,3763,3973,3870,3832,4310,4558,618,558,19944" %}
[C-Lightning 0.9.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.9.1rc2
[cl 0.9.1 rn]: https://github.com/ElementsProject/lightning/blob/817a7533d16263a63f50df7557a60479622d15d6/CHANGELOG.md#091---2020-09-15-the-antiguan-btc-maximalist-society
[russell tweet]: https://twitter.com/rusty_twit/status/1304581535849275393
[russell tx]: https://blockstream.info/testnet/tx/cde8bedfec5e683298bb67116f0f33a4d6384b7947a889b226301bf28bab035c
[news112 bolts688]: /zh/newsletters/2020/08/26/#bolts-688
[news22 dual]: /zh/newsletters/2018/11/20/#dual-funded-channels
[news83 dual]: /zh/newsletters/2020/02/05/#interactive-construction-of-ln-funding-transactions
[news99 min]: /zh/newsletters/2020/05/27/#minimum-transaction-size-discussion
[news39 maxfeerate]: /zh/newsletters/2019/03/26/#bitcoin-core-13541
[invdos paper]: https://invdos.net/paper/CVE-2018-17145.pdf
[invdos post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-September/018164.html
[invdos site]: https://invdos.net/
[cve-2018-17145]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-17145
[riard post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-September/002796.html
[square tweet]: https://twitter.com/sqcrypto/status/1304087270736236544
[copa]: https://open-patent.org/
[blockstream tweet]: https://twitter.com/Blockstream/status/1304529416131940352
[neigut interactive funding]: https://github.com/niftynei/lightning-rfc/pull/1
[news104 scorched earth]: /zh/newsletters/2020/07/01/#discussion-of-htlc-mining-incentives
[sighash]: https://btcinformation.org/en/developer-guide#signature-hash-types
[bindings readme]: https://github.com/rust-bitcoin/rust-lightning/tree/main/lightning-c-bindings
[hwi]: https://github.com/bitcoin-core/HWI
