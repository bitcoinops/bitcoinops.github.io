---
title: 'Bitcoin Optech 周报 #422'
permalink: /zh/newsletters/2026/09/11/
name: 2026-09-11-newsletter-zh
slug: 2026-09-11-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报介绍了一项提议中的协议：把概率式的 coinjoin 伪装成隐蔽的下注；并总结了一组面向轻客户端的基准测试：把静默支付索引服务器与致密区块过滤器作了对比。此外还包括我们的常规栏目：新版本和候选版本的公告，以及流行比特币基础设施软件的重大变更。

## 新闻

- **<!--a-protocol-for-probabilistic-coinjoin-and-covert-betting-->****一套用于概率式 coinjoin 与隐蔽下注的协议：** Adam Gibson 在 Delving Bitcoin 上[发帖][bab del]，介绍了 Babilonia——一项关于新的概率式 [coinjoin][topic coinjoin] 与隐蔽下注协议的提案。这个提案背后的想法是：让追求隐私的行为具备合理的可否认性。可识别的行为会被追踪、被标记，乃至被认定为犯罪；Gibson 于是提出了一套隐蔽的下注协议，用户参与其中，为的是打破共同输入所有权启发式。这场下注看起来像是一次链上抛硬币，钱在双方之间易手，但在外人看来就是一笔普通的支付。

  这套协议在一篇[论文][bab paper]里有描述，运作方式如下：
  - Alice 和 Bob 各自提供输入，构建出一个共享的 UTXO。他们还会签署一笔退款交易——万一长时间超时，资金就退回各自的所有者——以及一笔支付交易，用来结算这场下注。

  - Alice 生成两个秘密数字 `a_1` 和 `a_2`，从中挑一个作为自己的选择，并公布对应的公钥 `A_1` 和 `A_2`。

  - Bob 挑其中一个作为自己的猜测，并构造出一个公钥 `K`；只有在他和 Alice 的选择相同时，`K` 才是可以花费的。

  - 支付交易把资金发送到一个可由 `K` 花费的输出。Alice 用一个局部[适配器签名][topic adaptor signatures]为这笔交易签名。等 Bob 也用自己的局部签名签过、而且注资交易确认之后，Alice 通过带外渠道给出适配器里隐藏的秘密值，让 Bob 能解出她所选的数字。如果 Bob 赢了，他就补全并广播这笔支付交易，把资金取走。

  按作者的说法，多轮运行这套协议，在统计意义上可以让用户保住自己最初的资金（扣除手续费），同时改善隐私。这是就平均而言，对具体某个用户来说则可能出现偏差。不过 Gibson 在论文里表示，目前还没有一个清晰的指标能衡量这套协议的实际效果。在一篇后续帖子里，Gibson 指出，单独一场下注会泄露它的规模，因为赢家拿到的支付额是他投入彩池金额的整数倍；他还放出了论文的第二版，其中把每场下注拆分成若干不等额的子下注。

- **<!--update-on-silent-payments-light-clients-->****静默支付轻客户端的进展：** Rob Segers 在 Bitcoin-Dev 邮件列表上[发帖][sp light ml]，介绍了此前 Delving Bitcoin 上一场讨论的最新进展（见[周报 #305][news305 sp light]）。那场讨论在 2024 年 6 月停滞下来，主题是为[静默支付][topic silent payments]轻客户端制定规范，并衡量从区块中取数据的几种不同做法的性能。

  Segers 跑了一个 [BlindBit Oracle v2][blindbit gh] 实例，这是 [BIP352][] 索引服务器的一种实现，它完全弃用了过滤器，改为按输出逐条推送数据（txid、tweak，以及 8 字节的输出前缀）；他把它的性能与 [BIP158 致密区块过滤器][topic compact block filters]以及仅含 [taproot][topic taproot] 的过滤器作了比较。比较用的是未经抽样的区块数据，范围从 taproot 激活起一直到区块 965,089（共 255,434 个区块）。[结果][results gh]显示，BlindBit Oracle 这条路线下载的字节数，大约是“仅含 taproot 的过滤器，加上过滤器客户端仍然需要的原始 tweak 数据”的 2.1 倍——而且这还没算上过滤器客户端每次命中时必须去取的那整个区块；换来的是没有误报，也不必每次命中都去取区块。

  Segers 还指出，轻客户端目前无法判断服务器是否漏掉了某个区块的 tweak，而这会让接收方在毫不知情的情况下损失资金。他的服务器会针对每个区块，对排序后的 tweak 集合发布承诺，并每六小时把这些承诺作为检查点发布到 nostr 上，这样事后就能追究漏发的责任；不过客户端在命中时仍然应该去取整个区块。

  最后，Segers 指出，新版 BlindBit Oracle 已经与最初的规范严重偏离。为此，作者给出了一份[收敛草案][sp light draft]，目前正在讨论中。

## 版本和候选版本

_流行比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。_

- [LDK v0.3-rc1][] 是这一用于构建支持闪电网络的钱包和应用的库下一个主版本的候选版本。它为待处理的[拼接][topic splicing]增加了 [RBF][topic rbf] 手续费追加，并支持在同一次拼接中同时增加和移除资金。它现在还会默认协商[锚点通道][topic anchor outputs]，并要求应用显式接受入站通道。升级会让此前签发的、带有支付元数据的 [BOLT11][] 发票失效。开发者在测试之前应当查阅 [API 与向后兼容性方面的变更][ldk 0.3 notes]。

- [LDK v0.2.6][] 是这一用于构建支持闪电网络的钱包和应用的库的安全版本。它修复了一个拒绝服务漏洞：一笔无效支付在另一笔具有相同支付哈希的 HTLC 已被成功转发之后才遭到拒绝，这可能会让通道管理器陷入一种无法反序列化的状态。它还修复了一个手续费膨胀漏洞：恶意的交易对手可以在自己发起的拼接中，诱使节点在向这次拼接出资时多分配手续费，而多出来的部分会进到交易对手的输出里。

- [BTCPay Server 2.4.4][] 是这一自托管支付处理器的安全版本。它删除了旧式的 BitPay Basic-auth API 密钥，并移除了这种认证方式，受影响的集成方必须迁移到受支持的认证方式上。已有的 Greenfield API 密钥仍然可以继续使用。这个版本还要求改变发票状态时必须经过授权，禁止受限的 API 密钥去创建不受限的密钥，并包含下文介绍的 API 密钥存储方面的改动。配套的 Docker 更新限制了主机管理权限，把 LND 共用的默认钱包口令换成了各自独立的口令，并在反向代理层面封掉了 LND 那些无需认证的钱包管理路由。这些针对 LND 的改动，应对的是已经观察到的探测行为：在 2.4.2 事件（见[周报 #418][news418 btcpay]）之后又重新把 LND API 暴露出来的服务器上，有人在探测 LND 那个无需认证的口令修改端点。这样做过的运维者应当把该访问权限撤掉。建议所有服务器管理员升级，并查阅[破坏性变更说明][btcpay 2.4.4 announcement]。至于网站托管计费插件，迁移需要先升级到 4.0.0 版，再把旧的 API 密钥换成新的 Greenfield API 密钥；详见其[迁移指南][btcpay billing migration]。

## 重大的代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #35949][] 更新了区块模板的构建方式，使其遵循 [BIP54][] 针对 Murch–Zawy [时间扭曲][topic time warp]攻击提出的缓解措施（见[周报 #316][news316 timewarp]）。对于每个 2,016 个区块的难度周期，其最后一个区块的最小时间戳必须不早于该周期第一个区块的时间戳。此前，如果节点的时钟落后于该周期的第一个区块，提议的时间戳也可能更早，只要它大于前 11 个区块的中位时间戳就行。现在，`getblocktemplate` RPC 会在必要时同时调整 `mintime` 和提议的 `curtime`，节点时钟落后于这个最小值的情况也包括在内。这项改动适用于所有网络，是为[共识清理][topic consensus cleanup]软分叉可能的激活做准备，但并不改变共识验证规则。

- [Bitcoin Core #34931][] 修复了一个 bug：无法反序列化的 UTXO 数据库条目会被当成缺失的币来处理。这样一来，一个花费了该不可读的币的有效区块，就可能被永久标记为无效，从而让受影响的节点无法跟上网络的最佳链。Bitcoin Core 现在会区分这两种情形，并在反序列化失败时以数据库错误中止。要触发这个 bug，还得另外存在币的序列化 bug，或者在写入存储之前发生了内存损坏，因为寻常的磁盘损坏已经能被 LevelDB 的校验和检测出来。

- [Bitcoin Core #36048][] 修复了非 Windows 系统上通过 `-walletnotify` 配置选项（见[周报 #86][news86 walletnotify]）实施命令注入的问题。已通过认证的 RPC 调用方可以用 `createwallet` 命令创建一个名字经过精心构造的钱包。如果运维者在配置 `-walletnotify` 时用了钱包名占位符 `%w`，那么该钱包后续的交易通知就可能在节点的操作系统上执行嵌在钱包名里的命令。虽然钱包名是做过 shell 转义的，但替换函数会对其中的正则表达式替换字符做特殊解释，从而破坏了 shell 引用。现在，占位符替换会把钱包名当作字面量处理，shell 转义也就保住了。这个行为是从 Bitcoin Core 24.0 引入的。

- [Bitcoin Core #36123][] 和 [#36169][bitcoin core #36169] 修复了新 HTTP 服务器中内存无界增长和 Windows 上端口共享的问题（见[周报 #411][news411 http]和[周报 #420][news420 http]）。第一个 PR 防止客户端通过以快于服务器处理速度的节奏发送请求，把服务器为每条连接维护的接收缓冲区撑到无限大。现在，当已缓冲的请求还等着处理时，套接字读取会暂停，让 TCP 背压去把发送方拖慢。第二个 PR 则为 Windows 上的监听套接字独占地保留地址和端口。此前，本机上另一个进程可能绑定到同一个端点，进而有可能收到包含 RPC 凭据的连接。在一位审阅者的测试中，16 条 REST 连接在 90 秒内造成的内存增长，在这个缓冲修复之前是 3.2 GB，之后只有 3 MB。

- [Bitcoin Core #36176][] 修复了这样一个错误：当动态设置文件已被 `-nosettings` 选项禁用时，钱包操作若试图保存它的“启动时加载”偏好就会出错。用户在创建、加载或卸载钱包时，可以一并指定它是否应当在下次启动时自动加载（见[周报 #111][news111 load]）。此前，在设置已被禁用的情况下试图保存这项偏好，会返回一个 RPC 错误，或者让 Bitcoin-Qt 因未捕获的异常而崩溃——而此时钱包状态其实已经改变了。现在，这个操作会正常完成，只是附带一条警告，说明该偏好没能保存下来。

- [Core Lightning #9434][] 和 [#9473][core lightning #9473] 修复了 `askrene` 中与持久化路由偏好有关的崩溃（见[周报 #316][news316 askrene]）。`askrene` 把路由信息按层（layer）存放，其中可以包含偏向或回避特定节点或通道的偏置（bias，见[周报 #381][news381 biases]）。第一个 PR 修复的是一处启动崩溃：从持久化的层中恢复一个带描述的节点偏置时会崩溃。恢复入站和出站偏置值的过程中，复用了那块已经被释放的描述缓冲区，导致 `askrene` 崩溃；而 `lightningd` 把 `askrene` 当作重要插件，于是也跟着停机。第二个 PR 修复的则是把通道或节点偏置重置为零、借此移除它们时的崩溃。此前，那条值为零的偏置记录会在被保存之前就先从内存中移除，造成空指针解引用。现在，零值会先保存下来，然后才把记录从内存中移除，这样重启之后就不会再把之前的偏置恢复回来。

- [LND #11061][] 继续推进 [BOLT12 要约][topic offers]的实现，增加了用 [BIP340][] [schnorr 签名][topic schnorr signatures]对发票请求和发票进行签名与验证的支持。签名承诺的是一个默克尔根，它由消息中参与签名的 TLV 记录构建而成。读取端的验证器现在会拒绝无效签名，而不再只是检查签名存在与否。这项工作建立在[周报 #413][news413 bolt12]所介绍的发票请求编解码器之上。

- [LND #11125][] 允许调用方把钱包 UTXO 一直预留到花费它们的那笔交易达到指定的确认数为止。此前，预留要么在指定时间之后过期，要么在花费交易第一次确认时就被移除。于是，确认得慢就可能熬过预留期；而一旦发生重组，这些输入又会变回未预留状态。现在，`LeaseOutput`（见[周报 #182][news182 leaseoutput]）和 `FundPsbt` 这两个 RPC 都接受一个确认数，使预留可以跨越重组继续有效，并且不受基于时间的过期影响。调用方仍然可以显式释放预留；交易被放弃时就必须这么做。按时间计的预留仍然是默认行为。

- [LND #11064][] 让开通道消息显式指明通道类型，这是 [BOLT2][] 的要求。LND 现在会在 `open_channel` 中包含 `channel_type`，在 `accept_channel` 中把它回显出来，并拒绝那些没有带上它的入站 `open_channel` 消息。RPC 调用方仍然可以不指定类型，这种情况下 LND 会根据双方各自支持的通道类型来挑一个。

- [BTCPay Server #7561][] 和 [#7542][btcpay server #7542] 改动了 API 密钥的存储和处理方式。第一个 PR 改为存放哈希和派生出的密钥 ID，而不再把明文凭据长期留在数据库里。一个清理任务会在新创建的明文秘密值存在超过五分钟后将其清除。迁移完成之后，已有的 Greenfield 密钥仍然可以用于认证，但它们的秘密值再也无法从服务器上取回。这次升级还删除了旧式的、类 BitPay 的 Basic-auth API 密钥，并移除了那种认证方式。现在撤销某个 API 密钥需要用它的 ID，而不是它的秘密值；密钥相关的响应里也增加了 `id` 字段。第二个 PR 则把新生成的 API 密钥从跳转到密钥管理页面的 URL 中拿掉，避免这个 URL 通过浏览器历史或请求日志泄露凭据。

- [BTCPay Server #7559][] 把闪电网络支付的监控时间，从 BTCPay 发票的支付截止时间延长到它所配置的监控周期结束。此前，客户可以在 BTCPay 发票过期之后才去付那张闪电网络发票，但 BTCPay 不会记录这笔支付。现在，监听器会沿用已有的监控周期，让这段时间内收到的迟到支付能够被记录下来。这并不会改变两种发票各自的支付截止时间，也不意味着会无限期地检测支付。

{% include snippets/recap-ad.md when="2026-09-15 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="35949,34931,36048,36123,36169,36176,9434,9473,11061,11125,11064,7561,7542,7559" %}

[bab del]: https://delvingbitcoin.org/t/babilonia-probabilistic-coinjoin-and-covert-betting/2704
[bab paper]: https://github.com/AdamISZ/babilonia-paper
[sp light ml]: https://groups.google.com/g/bitcoindev/c/qqDYHnnoM7k
[news305 sp light]: /zh/newsletters/2024/05/31/#light-client-protocol-for-silent-payments
[blindbit gh]: https://github.com/setavenger/blindbit-oracle
[results gh]: https://github.com/bitsagarob/silentpayments-measurements
[sp light draft]: https://github.com/bitsagarob/silentpayments-measurements/blob/master/LIGHT-CLIENT-PROTOCOL-DRAFT.md

[LDK v0.3-rc1]: https://github.com/lightningdevkit/rust-lightning/tree/v0.3-rc1
[ldk 0.3 notes]: https://github.com/lightningdevkit/rust-lightning/blob/v0.3-rc1/CHANGELOG.md
[LDK v0.2.6]: https://github.com/lightningdevkit/rust-lightning/blob/v0.2.6/CHANGELOG.md
[BTCPay Server 2.4.4]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.4
[btcpay 2.4.4 announcement]: https://blog.btcpayserver.org/btcpay-server-2-4-4/
[btcpay billing migration]: https://github.com/btcpayserver/whmcs-plugin/blob/master/GUIDE.md#upgrade-from-v3x-to-v4x
[news418 btcpay]: /zh/newsletters/2026/08/14/#btcpay-server-2-4-2
[news316 timewarp]: /zh/newsletters/2024/08/16/#new-time-warp-vulnerability-in-testnet4
[news86 walletnotify]: /zh/newsletters/2020/02/26/#bitcoin-core-13339
[news411 http]: /zh/newsletters/2026/06/26/#bitcoin-core-35182
[news420 http]: /zh/newsletters/2026/08/28/#bitcoin-core-35730
[news111 load]: /zh/newsletters/2020/08/19/#bitcoin-core-15937
[news316 askrene]: /zh/newsletters/2024/08/16/#core-lightning-7517
[news381 biases]: /zh/newsletters/2025/11/21/#core-lightning-8608
[news413 bolt12]: /zh/newsletters/2026/07/10/#lnd-10832
[news182 leaseoutput]: /zh/newsletters/2022/01/12/#lnd-5964
