---
title: 'Bitcoin Optech Newsletter #252'
permalink: /en/newsletters/2023/05/24/
name: 2023-05-24-newsletter-zh
slug: 2023-05-24-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报介绍了关于比特币和相关协议的零知识证明有效性证据的研究。此外，还有我们关于交易池规则的限定系列，以及我们的常规烂漫：客户端和服务的更新、软件的新版本和候选版本，以及热门的比特币基础设施项目的更新。

## 新闻

- **<!--state-compression-with-zeroknowledge-validity-proofs-->使用零知识证明有效性证据压缩状态**：Robin Linux 在 Bitcoin-Dev 邮件组中[发帖][linus post]，公开了他跟 Lukas George 联合撰写的、使用有效性证据来减少客户端（为免信任地验证系统未来的动作）所需下载的状态数量的[论文][lg paper]。这是他们第一次将自己的系统应用在比特币上。他们报告称已经有了一个原型，证明了在区块头链条中累积的工作量证明，而且允许一个客户端验证某一个区块头是这个链条的一部分。这使得客户端可以通过接收多个证据来确定哪条链是累积了最多工作量证明的。

    他们还有一个未达最优状态的原像，证明比特币区块链上的所有交易的状态转换都遵守了货币规则（例如：一个新区块产生了多少新比特币、每一个非 coinbase 的交易不能创建超过所花费价值的 UTXO、矿工得到的手续费在被花费的 UTXO 和被创建的 UTXO 的价值差额以内）。收到这样的证据以及最新 UTXO 集拷贝的客户端可以验证这个集合是准确和完整的。他们把这个证据称为 “*assumevalid* 证据”，这个名字来源于 [Bitcoin Core 中的一个特性][assumevalid]：你可以选择跳过一些较老的区块的交易脚本验证，因为你认为网络中的许多贡献者都已经成功验证了这些区块。
  
  为了尽可能降低他们的证据的复杂性，他们使用了一个版本的 [utreexo][topic utreexo]，并用上了一个为他们的系统而优化的哈希函数。他们独自声称，结合他们的证据与 utreexo，客户端只需下载非常少量的数据，几乎马上就可以变成一个全节点。
  
  至于他们的原型的效用，他们的说法是：“我们已经实现了区块头链证据以及 assumevalid 状态证据，作为原型。前者是是可行的，但后者依然需要性能优化，以证明区块的大小在合理范围内”。他们也在开发完整区块的证据，包括脚本验证，但他们也说，需要至少 40 倍的速度提升，才能让这样的证据有实用价值。
  
  除了比特币区块链的状态压缩，他们还提出了一套协议，可以用在基于 “客户端验证” 的代币协议中，类似于 Lightning Labs 所提出的 Taproot Assets 以及 RGB 协议的一些用途（见[周报 #195][news195 taro]和[周报 #247][news247 rgb]）。当 Alice 给 Bob 发送一些某代币的时候，Bob 需要验证这些代币在此前的每一次转账，直至这种代币的创生。在理想的情况下，这个历史的体量会随着代币转移的次数而线性上升。但如果 Bob 希望给 Carol 一些这种代币，而且数量比他从 Alice 那里得到的更多，他就需要合并从 Alice 那里收到的这种代币以及从别处收到的这种代币。Carol 将需要验证两部分历史：一部分表示一些数额经由 Alice 到达 Bob；另一部分表示另一些数额经由别处到达 Bob 。这叫做 “合并（merge）”。如果合并经常发生，需要被验证的历史的体积会接近于任意两位用户之间的每一次代币转移的历史体积。相比之下，在比特币中，每一个全节点都验证每一个用户提起的每一笔交易；而在使用客户端验证的代币协议中，这并不是严格要求的，但如果合并很常见，则也会像比特币一样。
  
  这意味着，一个可以压缩比特币状态的协议，也可以改造成压缩代币历史的协议，即使合并经常发生也没关系。论文的作者介绍了他们会如何实现这样的协议。他们的目标是产生一种证据，证明以前的每一次代币转移到遵循了这种代币的规则，包括使用他们为比特币生成的证据，以证明每一次代币转移都锚定到了比特币区块链。然后，Alice 就可以转移代币给 Bob，并给他一个简短的、体积恒定的有效性证据；Bob 可以验证这个证据，以知晓以前的转账发生在类某个区块高度、最终支付给了他的代币钱包，并给了他完全的控制权。
  
  虽然这篇论文经常提到可以进行的额外的研究和开发，我们发现，这是向着一个比特币的开发者们梦想了十多年的[特性][coinwitness]，作出的令人鼓舞的进步。{% assign timestamp="1:05" %}

## 等待确认 #2：激励

_这是一个关于交易转发、交易池纳入以及挖矿选择的限定周刊 —— 解释了为什么 Bitcoin Core 设置了比共识规则更严格的交易池规则，以及钱包可以如何更高效地使用这些交易池规则。_

{% include specials/policy/zh/02-cache-utility.md %} {% assign timestamp="19:00" %}

## 服务和客户端软件的变更

*在这个月度栏目中，我们会标出比特币钱包和服务的有趣更新。*

- **<!--passport-firmware-211-released-->Passport 固件 2.1.1 发布**：Passport 硬件签名设备的[最新的固件][passport 2.1.1]支持发送到 [taproot][topic taproot] 地址、[BIP85][] 特性，并提升了处理 “部分签名的比特币交易（[PSBTs][topic psbt]）” 和多签名配置的能力。{% assign timestamp="37:19" %}
- **<!--musig-wallet-munstr-released-->MuSig 钱包 Munstr 发布**：beta 版的 [Munstr 软件][munstr github] 软件使用了 [nostr 协议][nostr protocol]，以协助签名 [MuSig][topic musig] 多签名交易所需的通信。{% assign timestamp="37:40" %}
- **<!--cln-plugin-manager-coffee-released-->CLN 插件管理器 Coffee 发布**：[Coffee][coffee github] 是一个 CLN 闪电客户端的插件管理器，改进了 [CLN 插件][news22 plugins] 的安装、配置、依赖项管理和升级。{% assign timestamp="38:49" %}
- **<!--electrum-443-released-->Electrum 4.4.3 发布**：[最新的][electrum release notes] Electrum 软件包含 “钱币控制（coin control）” 上的提升，一个 UTXO 隐私性分析工具，并支持 “短通道标识符（SCID）”，还有别的修复和升级。{% assign timestamp="40:01" %}
- **<!--trezor-suite-adds-coinjoin-support-->Trezor Suite 添加 coinjoin 支持**：Trezor Suite 软件[宣布][trezor blog]支持使用 zkSNACK 协调员的 [coinjoins][topic coinjoin] 功能。{% assign timestamp="40:32" %}
- **<!--lightning-loop-defaults-to-musig2-->Lightning Loop 默认使用 MuSig2 协议**：[Lightning Loop][news53 loop] 现在开始默认使用 [MuSig2][topic musig] 作为互换协议，以获得更低的手续费和更好的隐私性。{% assign timestamp="41:18" %}
- **<!--mutinynet-announces-new-signet-for-testing-->Mutinynet 宣布推出新的用于测试的 signet**：[Mutinynet][mutinynet blog] 是一个定制化的 signet，出块时间为 30 秒，并提供了测试用的基础设施，包括[区块浏览器][topic block explorers]、水龙头、测试用的闪电节点和运行在网络中的 LSP。{% assign timestamp="42:40" %}
- **<!--nunchuk-adds-coin-control-bip329-support-->Nunchuk 添加了钱币控制和 BIP329 支持**：Nunchuk 的最新安卓和 iOS 版本添加了[钱币控制][nunchuk blog] 功能以及[BIP329][]钱包标签导出特性。{% assign timestamp="44:55" %}
- **<!--mycitadel-wallet-adds-enhanced-miniscript-support-->MyCitadel 钱包添加了强化后的 miniscript 支持**：[v1.3.0][mycitadel v1.3.0] 版本添加了包括[时间锁][topic timelocks]在内的更复杂的 [miniscript][topic miniscript] 功能。{% assign timestamp="45:22" %}
- **<!--edge-firmware-for-coldcard-announced-->Coldcard 的 Edge 固件发布**：Coinkite [宣布][coinkite blog] 为 Coldcard 硬件签名设备推出实验性的固件，专门让钱包开发者和有能力的用户实验更新的特性。最初的 6.0.0.X 版本包括了 taproot 密钥路径花费功能，[tapscript][topic tapscript] 多签名花费功能以及 [BIP129][] 支持。{% assign timestamp="47:08" %}

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试旧版本。*

- [Core Lightning 23.05][] 是这个闪电节点实现的最新版本。它包含了对 “[盲化支付][topic rv routing]” 、2 版 [PSBTs][topic psbt] 的支持，以及更灵活的手续费管理方法，还有其它多项升级。{% assign timestamp="49:54" %}
- [Bitcoin Core 23.2][] 是 Bitcoin Core 的上一个大版本的维护性更新。{% assign timestamp="52:20" %}
- [Bitcoin Core 24.1][] 是 Bitcoin Core 的当前版本的维护性更新。{% assign timestamp="52:20" %}
- [Bitcoin Core 25.0rc2][]  是 Bitcoin Core 的下一个大版本的候选更新。{% assign timestamp="54:06" %}

## 重大的代码和说明书变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo] 和 [Bitcoin Inquisition][bitcoin inquisition repo]*。

- [Bitcoin Core #27021][] 加入了一个接口，可以计算将一个输出的未确认祖先交易的手续费率提升到一个给定的数值需要多大的代价，这个数值称为 “费用赤字”。当[钱币选择][topic coin selection]考虑在某个费率下使用某一个输出时，其祖先交易在当前费率下的费用赤字会计算出来，然后从该输出的实际价值中扣除。这会反激励钱包在其它可花费的输出可用时选择花费这样这高代价输出。在一个[后续的 PR][bitcoin core #26152]，这个接口也会被用于帮助钱包支付额外的手续费（也即 “手续费追加额”） —— 在不得不使用这样的高代价输出的时候 —— 以保证新的交易支付了用户所要求的实质手续费率。

  这个算法可以通过计算一个未确认的 UTXO 的所有未确认的交易集群、再减去应该会在目标费率进入区块的交易，估算出需要为任意的祖先集合追加的手续费。另一种方法则提供了多个未确认输出的聚合手续费追加额，以修正祖先交易可能重叠所带来的影响。{% assign timestamp="56:48" %}

- [LND #7668][] 添加了能够在开启通道时附加最多达 500 字符的私密文字、并允许运营者日后检索这些信息，这也许能帮助运营者回忆开启这条通道的目的。{% assign timestamp="59:37" %}

- [LDK #2204][] 添加了设定定制化 “特性位（feature bites）” 的功能，可以向对等节点宣布，也可以在尝试解析对等节点的公告时使用。{% assign timestamp="1:00:50" %}

- [LDK #1841][] 实现了之前添加到闪电网络规范中的一个安全建议（见[周报 #128][news128 bolts803]）：当节点在使用 “[锚点输出][topic anchor outputs]” 时，不应该在交易需要迅速确认时尝试批量处理由多方控制的输入。这样能够防止其他人推迟你的交易得到确认。 {% assign timestamp="1:02:12" %}

- [BIPs #1412][] 更新了 [BIP329][] [钱包标签导出格式][topic wallet labels]，添加了一个字段用于存储密钥的初始信息。此外，这个规范现在建议标签的长度的限制为 255 字符。{% assign timestamp="1:03:35" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="27021,7668,2204,1841,1412,26152" %}
[Core Lightning 23.05]: https://github.com/ElementsProject/lightning/releases/tag/v23.05
[bitcoin core 23.2]: https://bitcoincore.org/bin/bitcoin-core-23.2/
[bitcoin core 24.1]: https://bitcoincore.org/bin/bitcoin-core-24.1/
[bitcoin core 25.0rc2]: https://bitcoincore.org/bin/bitcoin-core-25.0/
[linus post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-May/021679.html
[lg paper]: https://zerosync.org/zerosync.pdf
[news128 bolts803]: /en/newsletters/2020/12/16/#bolts-803
[news247 rgb]: /zh/newsletters/2023/04/19/#rgb
[news195 taro]: /en/newsletters/2022/04/13/#transferable-token-scheme
[coinwitness]: https://bitcointalk.org/index.php?topic=277389.0
[assumevalid]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#assumed-valid-blocks
[passport 2.1.1]: https://foundationdevices.com/2023/05/passport-version-2-1-0-is-now-live/
[munstr github]: https://github.com/0xBEEFCAF3/munstr
[nostr protocol]: https://github.com/nostr-protocol/nostr
[coffee github]: https://github.com/coffee-tools/coffee
[news22 plugins]: /en/newsletters/2018/11/20/#c-lightning-2075
[electrum release notes]: https://github.com/spesmilo/electrum/blob/master/RELEASE-NOTES
[trezor blog]: https://blog.trezor.io/coinjoin-privacy-for-bitcoin-11aaf291f23
[mutinynet blog]: https://blog.mutinywallet.com/mutinynet/
[news53 loop]: /en/newsletters/2019/07/03/#lightning-loop-supports-user-loop-ins
[nunchuk blog]: https://nunchuk.io/blog/coin-control
[mycitadel v1.3.0]: https://github.com/mycitadel/mycitadel-desktop/releases/tag/v1.3.0
[coinkite blog]: https://blog.coinkite.com/edge-firmware/
