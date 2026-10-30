---
title: 'Bitcoin Optech Newsletter #118'
permalink: /zh/newsletters/2020/10/07/
name: 2020-10-07-newsletter-zh
slug: 2020-10-07-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一个通用消息签名协议的修订提案。此外，我们的常规部分还包括发布与候选发布，以及热门比特币基础设施软件的值得注意的变更。

## 行动项

*本周无。*

## 新闻

- **<!--alternative-to-bip322-generic-signmessage-->****BIP322 通用消息签名的替代方案：**现有的 [BIP322][] 提出了一个[通用消息签名协议][topic generic signmessage]，允许为任何比特币地址（脚本）签名消息，即便该地址使用了多重签名或高级功能。这包括为所有类型的 bech32 地址签名的能力；这类地址引入并随后被广泛采用已有数年，但该能力至今仍未标准化（参见 [Newsletter #54][news54 bech32 signing]）。

  本周，BIP322 的作者 Karl-Johan Alm 在 Bitcoin-Dev 邮件列表中[发布][alm signmessage]了另一个消息签名提案，使用一种称为“虚拟交易”的技术。第一笔虚拟交易会尝试花费一笔不存在的前置交易（其 txid 全为零），从而故意让自己无效。这笔交易支付给用户想要签名的地址（脚本），并包含一个针对所需消息的哈希承诺。第二笔交易花费第一笔交易的输出——如果这笔花费的签名和其他数据能构成有效交易，则认为消息已签名（不过第二笔虚拟交易仍然无法上链，因为它花费的是一笔无效的前置交易）。

  使用虚拟交易的优点在于，它可以与现有那些已配置为签署任意交易的软件配合使用，包括 [PSBT][topic psbt] 格式的交易。虚拟交易在 [BIP325][] 的 [signet][topic signet] 规范中也已被采用（参见 [Newsletter #109][news109 signet bip]）。修订后的规范还允许其中一笔虚拟交易包含引用特定 UTXO 的输入，从而让用户可以（可以说）证明自己对那些资金的控制权，类似于 [BIP127][] 的储备证明。

  Alm 正在寻求对此替代提案的反馈，包括该提案是否应取代 BIP322 或作为一个独立的 BIP 提出。

## 发布与候选发布

*热门比特币基础设施项目的新版本与候选发布。请考虑升级到新版本，或协助测试候选发布。*

- [LND 0.11.1-beta][lnd 0.11.1-beta] 是一个新的小版本发布。其发布说明将变更概括为“一系列可靠性改进、一些 macaroon（认证令牌）升级，以及一项让我们的[锚定承诺][topic anchor outputs]（anchor commitments）实现符合规范的改动”。

- [HWI 1.2.0-rc.1][HWI 1.2.0] 是一个候选发布，增加了对新硬件设备的支持并包含多个错误修复。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #19898][] 更改了调试日志中“意外版本”警告的打印条件，仅在设置了验证日志类别时才打印，而不再无条件打印。这类警告最初是为了提醒用户：矿工和用户可能正在使用 BIP9 版本位（versionbits）协调软分叉激活。但这些频繁的警告已成为误报，既让人无法据此采取行动，也给用户带来了不必要的困惑。更多信息请参见 [Newsletter #36][news36 pr15471]。

- [Bitcoin Core #15367][] 添加了一个 `-startupnotify` 配置参数，允许在 Bitcoin Core 完成初始化并准备好处理已启用的接口（如 ZMQ、REST、JSON-RPC 等）后执行一条 shell 命令。这可以直接用于启动依赖 Bitcoin Core 接口的程序/守护进程，或通知初始化系统（如 systemd）可以安全地启动相关程序/守护进程。

- [Bitcoin Core #19723][] 更改了处理未知 P2P 协议消息的方式。此前，节点会惩罚在 `version` 和 `verack` 消息之间发送未知消息的对等方；现在，从远程对等方发送 `version` 消息建立新连接，到该远程节点发送 `verack` 确认收到本地节点的版本，这段短暂的窗口内，节点会忽略未知消息。与之前一样，节点在收到某对等方的 `verack` 之后收到的未知消息仍会被忽略。

  通过在 `verack` 之前忽略消息，本地节点让对等方可以安全地发送特殊消息，以标识自己所支持的功能。如果节点能识别这些特殊消息，就可以启用对相应功能的支持；否则直接忽略该消息即可。关于这种协议功能协商方法的此前讨论，请参见 [Newsletter #111][news111 pre-verack]。

  *更正：*本条目最初错误地称 Bitcoin Core 会惩罚在 `verack` 之后发送未知消息的对等方。我们已更正为：未知消息从未被专门惩罚，只是接收顺序错误的消息会受到惩罚。在此更改之前，乱序即包括在 `verack` 之前收到 `version` 或 `wtxidrelay` 之外的任何消息。感谢 Marco Falke 指出我们描述中的错误。

- [Bitcoin Core #19725][] 更新了 `getpeerinfo` RPC。其结果现在会返回一个新的 `connection_type` 字段，说明节点为何要向某个出站对等方打开该连接，或为何接受该对等方的入站连接。RPC 输出中已有的 `addnode` 字段已弃用（默认不返回）；用户手动请求的连接现在显示为 `connection_type: manual`。

- [Bitcoin Core #18309][] 允许同一个 [ZeroMQ 配置参数][zmq.md]被指定多次。如果同一参数被指定多次，则其中列出的每个 IP 地址和端口都会收到通知。此前，只有第一个提供的地址/端口会收到通知。

- [Bitcoin Core #19501][] 为 `sendtoaddress` 和 `sendmany` RPC 添加了新的可选 `verbose` 参数，用于返回选择交易费率的机制——例如用户手动选择费率、自动选择了合适费率或使用了配置的备用费率。

- [Bitcoin Core #20003][] 使得在指定 `-proxy` 配置参数却没有提供值时，程序会立即退出。此前，程序会在没有代理的情况下启动，导致用户可能以为自己正在使用代理（例如为了隐私），而实际上并没有。

- [Bitcoin Core #19991][] 使得节点可以单独跟踪发往本地 Tor 洋葱服务的传入连接，并将其与同一台计算机上运行的服务或代理所建立的其他连接区分开。实现方式是让 Bitcoin Core 仅在 localhost 上额外监听一个端口（8334），并把发往该端口的连接都与 Tor 关联起来。Tor 监听端口可以用现有的 `-bind` 配置参数及其新增的 `=tor` 标志来更改。这个 PR 并没有利用“识别哪些连接来自 Tor”（或哪些现在更可能来自本地服务）的能力做任何特殊处理，相关工作留待后续 PR。升级到这一新代码的 Tor 洋葱服务运营者，可能需要按照[更新后的文档][bcc19991 tor.md]调整自己的设置。

- [Eclair #1528][] 允许插件（参见 [Newsletter #43][news43 eclair plugins]）注册新功能和消息类型。功能将被通告给对等方和潜在对等方，使用注册消息类型的消息将被路由到相应的插件。插件现在也可以发送带有任意消息类型的消息。

- [Eclair #1539][] 实现了一项简单措施，试图防止通道堵塞攻击。当一个节点与同一对等方之间有两个或更多开放通道，并收到一笔发往该对等方的支付时，它现在会选择剩余比特币价值最少的那个通道来路由这笔支付。这意味着攻击者会先堵塞低价值通道，再堵塞高价值通道。这并未消除该攻击，但意味着攻击者需要开设更多通道，才能堵塞一些高价值通道。这个 PR 与 [LND #4646][] 共享讨论，后者在 LND 中实现了同样的功能。

- [Eclair #1540][] 添加了用于设置 Bitcoin Core 钱包名称的配置参数。如果未设置，Eclair 将使用 Bitcoin Core 的默认钱包。[配置文档][eclair readme] 警告不要在有开放通道时更改钱包。

- [LND #4389][] 添加了一个新的 `psbt` 钱包子命令，允许用户创建和签署 [PSBT][topic psbt]。这扩展了 LND 此前的 PSBT 支持，原先的着力点是让其他钱包为打开通道提供资金（参见 [Newsletter #92][news92 lnd psbt]）。有关新的 `psbt` 子命令的详细信息及使用示例，请参见 LND 的[更新后的文档][lnd psbt.md]。

{% include references.md %}
{% include linkers/issues.md issues="19898,15367,19723,19725,18309,19501,20003,19991,1528,1539,1540,4389,19953,18947,4646" %}
[lnd 0.11.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.11.1-beta
[hwi 1.2.0]: https://github.com/bitcoin-core/HWI/releases/tag/1.2.0-rc.1
[news43 eclair plugins]: /zh/newsletters/2019/04/23/#eclair-927
[bcc19991 tor.md]: https://github.com/bitcoin/bitcoin/blob/96571b3d4cb4cda0fd3d5a457ae4a12f615de82b/doc/tor.md
[eclair readme]: https://github.com/ACINQ/eclair/blob/2073537c310a6e23134eda8b8a7670a367091381/README.md#configure-bitcoin-core-wallet
[lnd psbt.md]: https://github.com/guggero/lnd/blob/84dfed3fe2d28ceda343944874ab47fb57b73515/docs/psbt.md
[news54 bech32 signing]: /zh/bech32-sending-support/#消息签名支持
[news109 signet bip]: /zh/newsletters/2020/08/05/#bips-947
[news36 pr15471]: /zh/newsletters/2019/03/05/#bitcoin-core-15471
[news111 pre-verack]: /zh/newsletters/2020/08/19/#proposed-bip-for-p2p-protocol-feature-negotiation
[alm signmessage]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-October/018218.html
[news92 lnd psbt]: /zh/newsletters/2020/04/08/#lnd-4079
[zmq.md]: https://github.com/bitcoin/bitcoin/blob/master/doc/zmq.md
