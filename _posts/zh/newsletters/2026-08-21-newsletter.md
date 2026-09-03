---
title: 'Bitcoin Optech 周报 #419'
permalink: /zh/newsletters/2026/08/21/
name: 2026-08-21-newsletter-zh
slug: 2026-08-21-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报总结了 LND 通道关闭中一个已修复的重组漏洞的披露情况，并介绍了 `rawtr()` 输出脚本描述符的一份 BIP 草案。此外还包括我们的常规栏目：介绍服务和客户端软件的近期变化，以及流行比特币基础设施软件的重大变更。

## 新闻

- **<!--reorg-vulnerability-in-lnd-channel-closes-->****LND 通道关闭中的重组漏洞：** Bastien Teinturier 在 Delving Bitcoin 上[发帖][lnd vuln del]，[负责任披露][topic responsible disclosures]了一个影响 [0.20.0][lnd v20.0] 之前各版本 LND 的漏洞；0.20.0 已于 2026 年 2 月修复了它。仍在运行旧版本的运营者应当升级。据 Teinturier 所知，没有人因这个漏洞受到影响。

  在该版本之前，LND 节点会在合作关闭的通道获得第一个链上确认之后就立即把它忘掉，从而失去了针对链重组的保护。一旦发生重组，攻击者就可以为该通道发布一笔旧的、已撤销的承诺交易；而由于节点早已忘掉这条通道，它不会发布惩罚交易，攻击者也就能把通道里的资金全部取走。

  这个漏洞发现于 2025 年 2 月，并在 [LND #10331][] 中得到修复（见[周报 #389][news389 lnd10331]）。该补丁让节点在认定通道关闭已成定局之前等待更多确认（至少六个，遵循 [BOLT5][] 对重组安全的处理方式）。Teinturier 的帖子里还附有一份 regtest 复现步骤和这次披露的时间线。

- **<!--draft-bip-for-rawtr-output-script-descriptor-->****`rawtr()` 输出脚本描述符的 BIP 草案：** Jean Pablo 在 Bitcoin-Dev 邮件列表上[发帖][rawtr ml]，介绍了一项针对 `rawtr()` [输出脚本描述符][topic descriptors]的 BIP 提案。

  `rawtr()` 描述符可以直接用输出密钥来表示一个 P2TR 输出，既不需要内部密钥，也不需要脚本树。这个密钥会被直接当作 [taproot][topic taproot] 输出密钥使用，而不对其施加 [BIP341][] 的 tweak。举例来说，当内部结构未知，或者所有者尚未公开脚本树时，这就很有用。

  这个描述符自 Bitcoin Core 24.0 版起就已提供，但一直没有在任何 BIP 中作出规范。有几个实现绕开了这个问题：要么不支持它，要么引用其他 BIP。这项提案的目标就是补上这块空白。BIP 草案和测试向量都已经放出，正在 [BIPs #2251][] 中讨论。

## 服务和客户端软件的变更

*在这个每月栏目中，我们会重点介绍比特币钱包和服务的有趣更新。*

- **<!--payjoin-dev-kit-rust-payjoin-1-0-0-released-->****Payjoin Dev Kit（rust-payjoin）1.0.0 发布：** Payjoin Dev Kit 项目[发布][payjoin 1.0.0]了 rust-payjoin 的首个稳定版本，既支持同步的 BIP78 [payjoin][topic payjoin]，也支持异步的 BIP77 payjoin，后者带有可恢复的、持久化的会话。

- **<!--silent-payments-sender-plugin-for-electrum-->****Electrum 的静默支付发送插件：** Ali Sherief [发布][sp electrum delving]了一个插件，为 Electrum 桌面钱包增加了[静默支付][topic silent payments]（BIP352）的发送能力（不含接收），适用于单签名软件钱包。

- **<!--superscalar-implementation-announced-->****Superscalar 实现发布：** 8144225309 [宣布][superscalar delving]推出 Superscalar 的一个实现；Superscalar 是 ZmnSCPxj 提出的[通道工厂][topic channel factories]设计，能在不需要软分叉的前提下，把许多自托管的闪电网络客户端放在单个链上 UTXO 背后（见我们的 [Superscalar 深入探讨播客][superscalar deepdive]）。

- **<!--cofund-multisig-wallet-announced-->****Cofund 多重签名钱包发布：** Cofund [宣布][cofund x]推出一款自托管[多重签名][topic multisignature]钱包，它构建在基于策略的 [taproot][topic taproot]（P2TR）架构之上，支持多厂商密钥注册和分层多重签名。

- **<!--lexe-adds-human-readable-addresses-and-lnurl-withdraw-->****Lexe 增加人类可读地址和 LNURL-withdraw：** Lexe 是一款自托管的闪电网络钱包，它把每位用户的节点运行在可信执行环境（TEE）中，这样节点可以保持在线，而运营方又不必托管用户资金。该项目[宣布][lexe x]支持 [BIP353][] 人类可读的比特币地址（这类地址同时也可以当作 Lightning Address 使用），以及 [LNURL-withdraw][topic lnurl]。

- **<!--ledger-bitcoin-app-2-5-0-adds-human-readable-policy-descriptions-->****Ledger 比特币应用 2.5.0 增加人类可读的策略说明：** Salvatore Ingala [宣布][salvatoshi x]推出 Ledger 比特币应用 2.5.0 版；在注册钱包策略时，它会为许多 [taproot][topic taproot] [miniscript][topic miniscript] 和[多重签名][topic multisignature]钱包策略显示一段人类可读的说明，而不再只给出晦涩的[描述符][topic descriptors]模板。这样用户就更容易核对一项策略，并在注册之前发现恶意替换（例如把 3-of-5 换成了 1-of-5）。

- **<!--bark-0-5-0-released-->****Bark 0.5.0 发布：** Second [发布][second x]了其 [Ark][topic ark] 实现 Bark 的 0.5.0 版本，新增了从助记词恢复钱包全部链下余额（VTXO）的能力，也支持把闪电网络支付接收到外部的 Ark 地址——后者让非托管的 Lightning Address 服务器成为可能。

- **<!--bitcoin-pir-for-private-utxo-queries-->****用于私密 UTXO 查询的 Bitcoin-PIR：** Weikeng Chen [宣布][bitcoinpir]推出 Bitcoin-PIR，这是一套私有信息检索（private information retrieval，PIR）系统，让轻客户端可以在 UTXO 集中查询属于自己的地址或脚本公钥，而不必向服务器透露自己关心的到底是哪些。它提供四种 PIR 后端可供选择：DPF-PIR、HarmonyPIR、OnionPIRv2，以及一种由可信执行环境（TEE）支撑的 ORAM 方案。

- **<!--op-templatehash-ark-demonstration-->****基于 OP_TEMPLATEHASH 的 Ark 演示：** Steven Roose [上线][templatehash]了一个 signet 演示：让 Second 的 [Ark][topic ark] 实现 Bark 运行在 `OP_TEMPLATEHASH` 之上——这是一个 taproot 原生的、类 [CTV][topic op_checktemplateverify] [限制条款][topic covenants]操作码。该演示由 Bark [代码仓库][bark gitlab]的 `templatehash` 分支构建而成。

- **<!--libshrincs-formally-verified-hash-based-signatures-->****libshrincs 提供经形式化验证的哈希签名：** Jonas Nick [宣布][libshrincs delving]推出 libshrincs，这是[后量子][topic quantum resistance]哈希签名的一个 C 语言实现，带有机器验证的安全性证明，由 remix7531 编写。

## 重大的代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #32784][] 新增了一个 `derivehdkey` 钱包 RPC 命令：它可以从钱包已知的某个 [HD 密钥][topic bip32] 出发，按调用方指定的派生路径推导出一个 xpub，并可以按需一并推导出 xprv；该路径必须至少包含一个强化派生步骤。这在协调多重签名钱包时很有用——每位参与者所提供的 xpub，都派生自与钱包默认单签名[描述符][topic descriptors]不同的路径。由于强化派生需要私钥材料，这个 RPC 对仅观察钱包不可用，加密钱包也必须先解锁。

- [Bitcoin Core #35797][] 允许在使用 [`descriptorprocesspsbt`][topic descriptors] RPC（见[周报 #253][news253 descriptorpsbt]）时，即便还没有添加任何输入，也能先填充 [PSBT][topic psbt]v2 的输出元数据。此前，`UpdatePSBTOutput` 在遍历输出脚本时会使用 PSBT 未签名交易的第一个输入，而当 PSBTv2 只有输出、没有输入时，这就可能失败。现在，它改用一笔含有占位输入（dummy input）的临时交易来做元数据遍历，不会修改 PSBT 本身。

- [Bitcoin Core #35531][] 通过改变交易标识符和位置的存储方式，减少了 `-txindex` 选项（见[周报 #161][news161 txindex]）所占用的磁盘空间。新格式不再存储每个 32 字节的 txid 和交易在磁盘上的位置，而是对 txid 计算加盐 [SipHash][]、取其五字节前缀放进数据库键，并把区块序号和交易偏移量编码成一个紧凑的六字节后缀，键对应的值则留空。查找时会扫描所有共享该前缀的条目，借助区块索引确定每个候选项所在的区块位置，并在从磁盘读出交易之后校验完整的 txid，从而安全地处理碰撞。在 PR 作者的主网测试中，完全重建后的索引从大约 66 GB 缩小到 26 GB，索引耗时也从约 1 小时 50 分钟降到 1 小时 19 分钟。已有的索引仍然可读，但必须重建才能把磁盘空间收回来。重建之后，较老的 Bitcoin Core 版本无法读取新条目，降级时同样需要重建索引。

- [Bitcoin Core #35889][] 改善了 `gettxspendingprevout` RPC 在检查大批量输出点时的性能。此前，当在交易池中找到花费某个输出点的交易时，程序会在持有交易池锁的情况下，把该输出点从一个向量的中间位置删除，迫使其余条目整体前移。现在，这个 RPC 会把每个请求扫描一遍，把已解析的结果存放在它们原本的下标位置上，只把尚未解析的输出点收集到一份单独的工作清单里，再通过可选的 `txospenderindex`（见[周报 #394][news394 txospender]）去查找。这就让交易池那一趟处理从平方复杂度变成了线性复杂度。根据 PR 作者的基准测试，仅涉及交易池的大批量请求，在 Ryzen 7 3700X 上的完成速度约为原来的 9 倍，在树莓派 5 上则达到 31 倍。

- [Bitcoin Core #35605][] 弃用了 `removeprunedfunds` 钱包 RPC，并默认将其禁用。仍然需要它的用户必须使用 `-deprecatedrpc=removeprunedfunds` 启动选项。该 RPC 计划在下一个大版本中移除。移除的理由是：它暴露了危险的行为，却没有任何已知的有用场景——它可以删除属于该钱包的任意一笔交易，包括那些并非通过配套的 `importprunedfunds` RPC 添加进来的交易。它同时也是一项维护负担；关于此前一个涉及该 RPC 的 bug，见[周报 #391][news391 removeprunedfunds]。

- [Eclair #3352][] 修复了当 Eclair 作为单方注资通道的接受方时，[BOLT2][] 通道储备检查缺失的问题，确保任何一方的粉尘限额都不会超过对方的通道储备。如果没有这些检查，对等节点就可能把余额一直花到只剩储备金，而这个储备金低于适用的粉尘限额，导致它的输出在承诺交易中被略去；这样一来，它即便发布已撤销状态，也没有任何链上资金会被罚没。这个 PR 还新增了一个可配置的通道大小上限 `eclair.channel.max-funding-satoshis`，默认值为 50 亿聪（50 BTC）。此前对 [wumbo 通道][topic large channels]的支持让通道规模突破了原有的协议上限，这项改动则重新加上了一个上界。

- [Eclair #3351][] 修复了[即时注资][topic jit channels]（见[周报 #323][news323 fly]）中的若干 bug；这项功能目前用在 ACINQ 为 Phoenix 钱包运行的闪电网络服务提供商（LSP）节点上。具体来说，重启之后，Eclair 可能无法识别出某个 [HTLC][topic htlc] 其实已经完成了双方交叉签名，因为它只检查了处于待定状态的通道变更。这可能导致同一笔支付被转发两次。现在 Eclair 在转发之前还会检查当前的承诺状态。此外，这个 PR 还理清了若干超时和链上失败的处理路径，防止 Eclair 在让对应的上游 HTLC 失败之后，仍然向下游对等节点付款。

- [Eclair #3345][] 限制了每个对等节点通过 [BOLT7][] gossip 查询来请求和同步[通道公告][topic channel announcements]时可以占用的资源。一项可配置的速率限制（默认为每秒 5 个请求）对每条连接分别生效，`query_channel_range` 和 `query_short_channel_ids` 合并计算。Eclair 会等到某个查询的回复发送完毕之后，才接受新的工作，以保持传输层的背压。Eclair 会忽略重复的短通道 ID（SCID），以防止响应被放大，并拒绝畸形或相互重叠的查询。它还限制了同步期间的内存占用，为每个对等节点最多保留 2,000 个排队的 `query_short_channel_ids` 请求。类似的资源管理保护此前已经加入 LND（见[周报 #366][news366 lnd gossip]和[周报 #417][news417 lnd gossip]）。

- [LND #8754][] 为远程签名器（见[周报 #172][news172 remote]）实现了一种实验性的出站连接模式；远程签名器方案会把涉及私钥的操作交给一台独立的签名器服务器处理。签名器仍然不会自行验证它收到的请求，因此仅观察节点发来什么请求，它就会签什么。这种新模式改变的只是两者的连接方式：签名器不再监听入站连接，而是主动向仅观察节点上一个专用的 RPC 监听器发起出站连接，使它无需接受任何入站连接即可工作。[周报 #326][news326 signer]此前讨论过这套做法，当时是结合确定性 macaroon 生成一并介绍的。

- [LND #11065][] 新增了一个实验性的 `XCreateAccount` RPC 以及对应的 `lncli wallet accounts create` 命令，用来创建一个具名的、完全可花费的账户，其密钥派生自 LND 钱包的主密钥。这与已有的 `ImportAccount` RPC（见[周报 #144][news144 lnd xpub]）不同，后者导入的是一个仅观察的 xpub。[选币][topic coin selection]、余额、地址派生和找零都可以限定在该账户范围内，从而在同一个钱包里划分出彼此隔离的资金口袋。账户的地址类型一经选定便不可更改，默认为 [taproot][topic taproot]。

- [HWI #842][] 新增了一个 `registerdescriptor` 命令，用于在从某个钱包签名交易之前，先把一个具名的[输出脚本描述符][topic descriptors]注册到受支持的硬件签名设备上。目前已为 BitBox02、Coldcard、Jade 以及非 legacy 型号的 Ledger 设备实现了该功能。对于使用 [BIP388][] 钱包策略（见[周报 #302][news302 bip388]）的设备，HWI 会把描述符转换成钱包描述符模板和密钥信息向量，同时还会返回后续签名所需的、各设备特有的注册数据。

{% include snippets/recap-ad.md when="2026-08-25 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="10331,2251,32784,35797,35531,35889,35605,3352,3351,3345,8754,11065,842" %}

[payjoin 1.0.0]: https://github.com/payjoin/rust-payjoin/releases/tag/payjoin-1.0.0
[sp electrum delving]: https://delvingbitcoin.org/t/silent-payments-sender-bip352-plugin-for-electrum/2743
[superscalar delving]: https://delvingbitcoin.org/t/superscalar-an-implementation-report/2705
[superscalar deepdive]: /en/podcast/2024/10/31/
[cofund x]: https://x.com/getcofund/status/2085389177193972164
[lexe x]: https://x.com/lexeapp/status/2079245197817548964
[salvatoshi x]: https://x.com/salvatoshi/status/2086727660353261863
[second x]: https://x.com/secondhq/status/2084716752789991614
[bitcoinpir]: https://bitcoinpir.org
[templatehash]: https://templatehash.com
[bark gitlab]: https://gitlab.com/ark-bitcoin/bark
[libshrincs delving]: https://delvingbitcoin.org/t/libshrincs-a-c-implementation-with-a-machine-checked-security-proof/2795
[lnd vuln del]: https://delvingbitcoin.org/t/disclosure-lnd-doesnt-wait-for-enough-confirmations-when-closing-channels/2800
[lnd v20.0]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta
[rawtr ml]: https://groups.google.com/g/bitcoindev/c/CCZN_qQ5C1s
[SipHash]: https://en.wikipedia.org/wiki/SipHash
[news389 lnd10331]: /zh/newsletters/2026/01/23/#lnd-10331
[news253 descriptorpsbt]: /zh/newsletters/2023/05/31/#bitcoin-core-25796
[news161 txindex]: /zh/newsletters/2021/08/11/#bitcoin-core-pr-审查俱乐部
[news394 txospender]: /zh/newsletters/2026/02/27/#bitcoin-core-24539
[news391 removeprunedfunds]: /zh/newsletters/2026/02/06/#bitcoin-core-34358
[news323 fly]: /zh/newsletters/2024/10/04/#eclair-2861
[news172 remote]: /zh/newsletters/2021/10/27/#lnd-5689
[news326 signer]: /zh/newsletters/2024/10/25/#lnd-9172
[news366 lnd gossip]: /zh/newsletters/2025/08/08/#lnd-10097
[news417 lnd gossip]: /zh/newsletters/2026/08/07/#lnd-10992
[news302 bip388]: /zh/newsletters/2024/05/15/#bips-1389
[news144 lnd xpub]: /zh/newsletters/2021/04/14/#lnd-5047
