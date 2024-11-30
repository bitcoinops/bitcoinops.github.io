---
title: 'Bitcoin Optech Newsletter #118'
permalink: /zh/newsletters/2020/10/07/
name: 2020-10-07-newsletter-zh
slug: 2020-10-07-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 描述了一个通用消息签名协议的修订提案。此外，我们的常规部分还包含了发布、候选发布以及对流行的比特币基础设施软件的值得注意的更改。

## 行动项

*本周无。*

## 新闻

- **<!--alternative-to-bip322-generic-signmessage-->****BIP322 通用消息签名的替代方案：**现有的 [BIP322][] 提出了一个[通用消息签名协议][topic generic signmessage]，可以允许对任何比特币地址（脚本）签名，即便它使用了多重签名或高级功能。该协议涵盖对所有类型的 Bech32 地址签名的能力，这项功能即便在该类型地址引入多年、并广泛使用后仍未标准化（参见 [Newsletter #54][news54 bech32 signing]）。

  本周，BIP322 的作者 Karl-Johan Alm 在 Bitcoin-Dev 邮件列表中[发布][alm signmessage]了一个使用虚拟交易的新消息签名提案。该方法的第一笔虚拟交易将尝试花费一个不存在的前置交易（txid 为全零），从而故意使其无效。这笔交易支付给用户想要签名的地址（脚本），并包含一个对所需消息的哈希承诺。第二笔交易将花费第一笔交易的输出——如果该笔花费的签名和其他数据可以形成有效交易，则认为消息已签名（尽管该虚拟交易仍无法在链上包含，因为它花费的是一个无效的前置交易）。

  使用虚拟交易的优点在于其可以与现有软件配合使用，尤其是那些已经配置为签署任意交易的软件，包括 [PSBT][topic psbt] 格式的交易。修订后的规范还允许虚拟交易之一包含引用特定 UTXO 的输入，从而让用户（可以说）证明他们对这些资金的控制权，类似于 [BIP127][] 中的储备证明。

  Alm 正在寻求对此替代提案的反馈，包括该提案是否应取代 BIP322 或作为一个独立的 BIP 提出。

## 发布与候选发布

*流行的比特币基础设施项目的新版本和候选发布。请考虑升级至新版本或协助测试候选发布版本。*

- [LND 0.11.1-beta][lnd 0.11.1-beta] 是一个新的小版本发布。其发布说明总结了更改为“一些可靠性改进，一些 Macaroon（认证令牌）的升级，以及让我们的锚定承诺（anchor commitments）版本符合规范的更改”。

- [HWI 1.2.0-rc.1][HWI 1.2.0] 是一个候选发布，增加了对新硬件设备的支持并包含多个错误修复。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[比特币改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [Bitcoin Core #19898][] 更改了调试日志中“意外版本”的警告，只在设置验证日志类别时才打印此类警告，而非无条件打印。最初设计此警告是为了提醒用户矿工和用户可能正在使用 BIP9 版本位（versionbits）协调软分叉激活，但这些频繁的警告已变得无效且难以操作，对用户造成不必要的困扰。有关更多信息，请参见 [Newsletter #36][news36 pr15471]。

- [Bitcoin Core #15367][] 添加了一个 `-startupnotify` 配置参数，允许在 Bitcoin Core 完成初始化并准备好处理已启用的接口（如 ZMQ、REST、JSON-RPC 等）后执行一条 shell 命令。这可以直接用于启动依赖 Bitcoin Core 接口的程序/守护进程，或通知初始化系统（如 systemd）可以安全地启动相关程序/守护进程。

- [Bitcoin Core #19723][] 更改了处理未知 P2P 协议消息的方式。此前，节点会对在 `version` 和 `verack` 消息之间发送未知消息的对等方进行惩罚；现在，节点忽略在远程对等方通过发送 `version` 消息建立新连接到本地节点确认接收的 `verack` 消息之前收到的未知消息。收到的未知消息在 `verack` 之后仍然被忽略。

  通过忽略 `verack` 之前的消息，本地节点使得对等方可以安全地发送任何标识其支持的功能的特殊消息。如果节点识别出这些特殊消息，则可以启用对相应功能的支持；否则可以忽略该消息。有关此协议功能协商方法的更多讨论，请参见 [Newsletter #111][news111 pre-verack]。

  *更正：*此项目最初错误地说明 Bitcoin Core 会对在 `verack` 之后发送未知消息的对等方进行惩罚。我们已更正为表示未知消息从未被特别惩罚，尽管接收顺序错误的消息会受到惩罚。在此更改之前，这包括在 `verack` 之前收到 `version` 或 `wtxidrelay` 以外的任何消息。感谢 Marco Falke 提供的描述错误反馈。

- [Bitcoin Core #19725][] 更新了 `getpeerinfo` RPC。其结果现在返回一个新的 `connection_type` 字段，指示节点是因何原因与一个出站对等方建立连接或从对等方接受入站连接。RPC 输出中的现有 `addnode` 字段已弃用（默认不返回）；用户手动请求的连接现在显示为 `connection_type: manual`。

- [Bitcoin Core #18309][] 允许为每个 [ZeroMQ 配置参数][zmq.md]多次指定。如果同一参数指定多次，则每个列出的 IP 地址和端口将接收通知。此前，仅第一个提供的地址/端口会接收通知。

- [Bitcoin Core #19501][] 为 `sendtoaddress` 和 `sendmany` RPC 添加了新的可选 `verbose` 参数，用于返回选择交易费率的机制——例如用户手动选择费率、自动选择了合适费率或使用了配置的备用费率。

- [Bitcoin Core #20003][] 当 `-proxy` 配置参数未指定参数时，程序将立即退出。此前，程序会在没有代理的情况下启动，可能导致用户误以为正在使用代理（例如用于隐私）。

- [Bitcoin Core #19991][] 使其能够单独跟踪到本地 Tor 洋葱服务的传入连接，与同一台计算机上运行的服务或代理连接区分开来。通过让 Bitcoin Core 仅在本地监听额外的端口（8334）实现此功能，并将与该端口的任何连接与 Tor 关联。Tor 监听端口可使用现有的 `-bind` 配置参数及其新的 `=tor` 标志进行更改。此拉取请求未对识别哪些连接来自 Tor 进行任何特殊处理（或那些现在更可能来自本地服务的连接），将其留待未来的 PR。升级到此新代码的 Tor 洋葱服务运营商可能需要按照[更新的文档][bcc19991 tor.md]进行设置。

- [Eclair #1528][] 允许插件（参见 [Newsletter #43][news43 eclair plugins]）注册新功能和消息类型。功能将被通告给对等方和潜在对等方，使用注册消息类型的消息将被路由到相应的插件。插件现在也可以发送带有任意消息类型的消息。

- [Eclair #1539][] 实现了一个简单的措施以尝试防止通道阻塞攻击。当一个节点有两个或多个与同一对等方的开放通道并收到向该对等方的支付时，它现在通过剩余比特币价值最少的通道进行路由。这意味着攻击者最终会优先阻塞低价值通道，而非高价值通道。此措施并未完全消除攻击，但意味着攻击者需要更多开放通道来阻塞一些高价值通道。此拉取请求与 [LND #4646][] 共享讨论，LND 也实现了相同的功能。

- [Eclair #1540][] 添加了用于设置 Bitcoin Core 钱包名称的配置参数。如果未设置，Eclair 将使用 Bitcoin Core 的默认钱包。[配置文档][eclair readme] 警告不要在有开放通道时更改钱包。

- [LND #4389][] 添加了一个新的 `psbt` 钱包子命令，允许用户创建和签署 [PSBT][topic psbt]。这扩展了 LND 先前的 PSBT 支持，原先主要专注于允许其他钱包为打开通道提供资金（参见 [Newsletter #92][news92 lnd psbt]）。有关新的 `psbt` 子命令的详细信息及其使用示例，请参见 LND 的[更新文档][lnd psbt.md]。

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
