---
title: 'Bitcoin Optech Newsletter #310'
permalink: /zh/newsletters/2024/07/05/
name: 2024-07-05-newsletter-zh
slug: 2024-07-05-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的新闻部分总结了 10 个披露出来的影响旧版本 Bitcoin Core 的漏洞，还介绍了一个允许 BOLT11 发票包含盲化路径的提议。此外是我们的常规栏目：软件的新版本和候选版本发行公告，流行的比特币基础设施软件的重大变更总结。

## 新闻

- **<!--disclosure-of-vulnerabilities-affecting-bitcoin-core-versions-before-0210-->影响 0.21.0 以前版本 Bitcoin Core 的漏洞披露**：Antoine Poinsot 在 Bitcoin-Dev 邮件组中[贴出][poinsot disclose]了一个链接，[公布][bcco announce]了 10 个影响已经退役接近两年的 Bitcoin Core 软件版本的漏洞。我们将披露总结如下：

  - [<!--remote-code-execution-due-to-bug-in-miniupnpc-->因 miniupnpc 而出现的远程代码执行漏洞][Remote code execution due to bug in miniupnpc]：在 Bitcoin Core 0.11.1（发布于 2015 年 10 月）以前的版本中，节点会默认启用 [UPnP][] 以允许通过 [NAT][] 的入站连接。这是使用 [miniupnpc 库][miniupnpc library] 来实现的，而后者已被 Aleksandar Nikolic 发现具有多个可被远程攻击的漏洞（[CVE-2015-6031][]）。这些流动在上游库中修复了，修复也进入了 Bitcoin Core，并且开发者们采取了一项更新：默认禁用 UPnP。在研究这个 bug 的过程中，Bitcoin 开发者 Wladimir J. Van Der Laan 发现了同一库中的另一个远程代码执行漏洞。该漏洞已得到[尽责披露][topic responsible disclosures]，并已在上游库中修复，也进入到了 Bitcoin Core 0.12 中（发行于 2016 年 2 月）。

  - [<!--node-crash-dos-from-multiple-peers-with-large-messages-->来自多个对等节点的大体积消息可造成节点崩溃][Node crash DoS from multiple peers with large messages]：在 Bitcoin Core 0.10.1 之前，节点对 P2P 消息的体积要求是不能超过（约）32 MB。并且，一直以来（直到现在），节点默认允许高达 130 个连接。如果每个对等节点都在几乎同一时间发送最大体积的消息，这会让节点需要在其它内存要求之上额外划出 4 GB 的内存空间，已经超过了许多节点能够提供的大小。这个漏洞是由 BitcoinTalk.org 论坛的用户 Evil-Knievel 尽责披露的，获得了编号 [CVE-2015-3641][]，并且在 Bitcoin Core 0.10.1 中修复了，修复方法是将消息的体积限制在 2 MB 之下（后续又为了隔离见证升级而提高到约 4 MB）。

  - [<!--censorship-of-unconfirmed-transactions-->审查未确认的交易][Censorship of unconfirmed transactions]：对等节点一般会通过交易的 txid 或 wtxid 来宣布新交易。在节点第一次看到一个 txid 或者 wtxid 时，它会从第一个宣布这笔交易的对等节点处请求完整的交易。在等待这个对等节点回复的时间里，节点也会跟踪其它宣布了相同 txid 或 wtxid 的对等节点。如果第一个对等节点不回复、直至超时，节点会从第二个节点处请求完整交易（如果再次超时，则转向第三个节点，以此类推）。

    在 Bitcoin Core 0.21.0 之前，节点最多只会跟踪 50000 个请求。所以，第一个对等节点在宣布一个 txid 之后，可以推迟回复节点对完整交易的请求，等待该节点的其它对等节点都宣布该笔交易，然后发送 50000 条关于其它 txid 的宣布（可以都是假的 txid）。如此一来，当节点对第一个对等节点的完整交易请求超时后，它将不会再向其它任何对等节点请求完整交易。攻击者（第一个对等节点）可以无限重复这种攻击，从而永久阻止节点受到这比交易。请注意，这种对未确认交易的审查可以阻止交易迅速得到确认，这可能导致合约式协议（比如闪电通道）中的资金损失。John Newbery 引用了来自 Amiti Uttarwar 的共同发现，负责地披露了这个漏洞。修复措施在 Bitcoin Core 0.21.0 中放出。

  - [<!--unbound-ban-list-cpumemory-dos-->无限大小的禁止连接列表所带来的 CPU/内存 DoS][Unbound ban list CPU/memory DoS]：Bitcoin Core [PR #15617][bitcoin Core #15617]（首次包含在 0.19.0 中）添加了代码，使得在收到一条 P2P `getaddr` 消息时，检查被本地禁止连接的 IP 地址，最高可达 2500 次。节点的禁止连接列表的长度时不受限制的，如果一个攻击者控制了大量的 IP 地址（例如，易于获得的 IPv6 地址），这份列表会膨胀成巨大的规模。当这个列表变得很长的时候，每一次 `getaddr` 请求都可能消耗超量的 CPU 和内存，可能让节点不可用甚至崩溃。这个漏洞被编号为 [CVE-2020-14198][]，在 Bitcoin Core 0.20.1 中得到了修复。

  - [<!--netsplit-from-excessive-time-adjustment-->源自过量时间调整的网络分裂][Netsplit from excessive time adjustment]：旧版本的 Bitcoin Core 允许自身的时钟被它连接到的前 200 个对等节点所报告的时间扭曲。这些代码本意是允许不超过 70 分钟的扭曲。所有版本的 Bitcoin Core 软件都会暂时无视带有超过本地时间 2 个小时以上的时间戳的区块。两个 bug 的组合，让攻击者可以让受害者的时钟倒拨两个小时以上，使之忽略掉带有准确时间戳的区块。该漏洞由开发者 practicalswift 尽责披露，并在 Bitcoin Core  0.21.0 中得到了修复。

  - [<!--cpu-dos-and-node-stalling-from-orphan-handling-->因处理孤儿交易而产生的 CPU DoS 以及节点卡顿][CPU DoS and node stalling from orphan handling]：Bitcoin Core 节点会跟踪 “*孤儿交易*” 的一个不超过 100 笔交易的缓存，对于这些交易，节点在交易池和 UTXO 集中还没有必要的父交易信息。在验证完一笔新交易之后，节点会检查孤儿交易中是否有某一个变得可以处理。在 Bitcoin Core 0.18.0 之前，每次检查孤儿交易缓存的时候，节点都会尝试使用最新的交易池和 UTXO 状态、验证每一笔孤儿交易。如果这 100 笔缓存的孤儿交易都被构造成需要大量的 CPU 来验证，节点可能会浪费超量的 CPU，可能因此无法处理新区块和新交易长达数小时。这种攻击基本上时免费的：孤儿交易时可以免费创建的，因为它们可以引用根本不存在的父交易。一个停滞的节点将无法生成区块模板，因此这种攻击可能会被用来阻止一个矿工获得收益，而且可以用来阻止交易得到确认、可能会导致合约式协议（例如闪电通道）的用户失去资金。开发者 sec.eine 尽责披露了这个漏洞；该漏洞在 Bitcoin Core 0.18.0 中修复了。

  - [<!--memory-dos-from-large-inv-messages-->来自大体积 `inv` 消息的内存 DoS ][Memory DoS from large `inv` messages]：一条 P2P `inv` 消息可以包含一个高达 50000 个区块头哈希值的列表。在 0.20.0 版本以前，新式 Bitcoin Core 节点会为自己不理解的每一个哈希值回复一条单独的 P2P `getheaders` 消息，而这样的消息的体积将是约 1 kB。这导致节点会在内存中存储大约 50 MB 的消息，等待对等节点接收它们。每一个对等节点都可以这样做（而对等节点的数量默认可达大约 130 个），这就会在节点的常规内存要求之上额外使用超过 6.5 GB 的内存 —— 足以让许多节点崩溃。崩溃的节点可能无法处理为合约式协议的用户处理时间敏感的交易，可能导致用户损失资金。John Newbery 负责地披露了这个漏洞，并提供了一种修复措施：仅用一条 `getheaders` 消息来回复一条 `inv` 消息，无论后者包含了多少哈希值；此修复进入了 Bitcoin Core 0.20.0。

  - [<!--memory-dos-using-lowdifficulty-headers-->使用低难度区块头的内存 DoS][Memory DoS using low-difficulty headers]：自 Bitcoin Core 0.10 以来，节点会请求其每一个对等节点来发它们所知的 *最佳区块链*（累积最多工作量证明的有效区块链）的区块头。这种方法的一个已知问题是，一个恶意的对等节点可以用大量低难度（例如，难度 1）的假冒区块头来轰炸节点，这样的区块头用先进的 ASIC 挖矿设备是很容易创建的。Bitcoin Core 最初的解决方法是仅接受与代码内硬编码的 *检查点* 相匹配的区块链上的区块头。最后一个检查点，虽然来自 2014 年，但以现在的标准来说也具有一个相对高的难度，所以它会要求大量地做功来创建假冒的区块头。但是，Bitcoin Core 0.12 加入的一项代码变更开始允许节点接受低难度的区块头进入内存，潜在地让攻击者可以用假冒区块头填满内存。这可以会导致节点宕机，并进一步导致合约式协议（比如闪电通道）的用户损失资金。Cory Fields 负责地披露了这个漏洞；该漏洞在 0.15.0 中修复。

  - [<!--cpuwasting-dos-due-to-malformed-requests-->通过格式错乱的请求浪费 CPU 的 DoS][CPU-wasting DoS due to malformed requests]：在 Bitcoin Core 0.20.0 以前，攻击者或出故障的对等节点可以发送一种格式错乱的 P2P `getdata` 消息，导致处理消息的线程消耗 100% 的 CPU。（攻击发生后）在连接持续时间内，节点将不再能从攻击者处接收消息，虽然还能从诚实对等节点处收取消息。对于拥有少数 CPU 核心的节点来说，这可能只会造成一些小问题；在别处就会变成一种麻烦。John Newbery 负责地披露了这个漏洞并提供了一种修复措施；该措施进入了 Bitcoin Core 0.20.0。

  - [<!--memoryrelated-crash-in-attempts-to-parse-bip72-uris-->尝试解析 BIP72 URI 而导致的内存崩溃][Memory-related crash in attempts to parse BIP72 URIs]：0.20.0 以前的 Bitcoin Core 支持延伸了 [BIP21][] `bitcoin:` URI 的 [BIP70 支付协议][topic bip70 payment protocol]、使用由 [BIP72][] 定义的参与 `r` 来引用一个 HTTP(S) URL。Bitcoin Core 会尝试从这个 URL 上下载文件，并存储在内存中等待解析，但是，如果这个文件大于可用的内存，Bitcoin Core 最终就会终止。当尝试下载在后台发生时，用户可能会走开，因此没有注意到节点的崩溃、也没有重启关键的服务。这个漏洞由 Michael Ford 尽责披露，并由 Bitcoin Core 0.20.0 通过移除 BIP70 支持的方式修复（见周报 [周报 #70][news70 bip70]）。

  Poinsot 的公告说，在 Bitcoin Core 22.0 中修复的其它漏洞将会在本月晚些时候公布；而 23.0 所修复的漏洞会在下个月公布。后续版本所修复的漏洞将根据 Bitcoin Core 的[新的披露策略][new disclosure policy]来发布（见[周报#306][news306 disclosure]）。

- **<!--adding-a-bolt11-invoice-field-for-blinded-paths-->为盲化路径添加一种 BOLT11 发票字段**：Elle Mouton 在 Delving Bitcoin 论坛[提出][mouton b11b]了一种 BLIP 规范提议：为 [BOLT11][] 发票加入一个可选的字段，以沟通一条可以给接收者的节点支付的[盲化路径][topic rv routing]。举个例子，商家 Bob 希望从顾客 Alice 处接收一笔支付，但不想暴露自己节点的身份，也不想暴露与其共享通道的对等节点。他生成一条从本地节点几跳远的节点起步的盲化路径，并添加到一个 BOLT11 发票中（该发票因此变成非标准发票），并将发票交给 Alice。如果 Alice 使用的软件能够解析这个发票并使用盲化路径来路由一笔支付，Alice 就能给 Bob 支付。

  如果 Alice 所用的软件并不支持这个 BLIP，她就不能给这个发票支付，而是会收到一条报错消息。

  Mouton 在这个 BLIP 中指出，BOLT11 中的盲化路径仅意图在 [offers][topic offers] 协议得到普遍部署、用于沟通发票之后，因为 offer 协议原生使用盲化路径，而且相比 BOLT11 发票具有其它优势。

  Bastien Teinturier [表示][teinturier b11b]反对这个想法以及相关的想法（暴露 offer 发票格式）。他倾向于专注在 offer 的完全部署上，他认为这会让整个系统更快到达其终极状态，同时消除永久支持中间状态的负担。他认为，在尝试支付带有盲化路径的 BOLT11 发票但遇到报错之后，用户就会要求开发者添加对这种特性的支持，让开发者从 offer 相关的工作中分心。

  Olaoluwa Osuntokun [回复][osuntokun b11b]称他倾向于让盲化路径的开发工作独立于 offer 协议的其它依赖，以保证盲化路径尽可能好地工作。他设想带有盲化路径的 BOLT11 被用在例如 [L402][] 这样的协议中：客户端已经可以直接跟服务端沟通，所以已经获得了 offer 具备的许多优势，他们唯一需要的就是使用盲化路径的小型升级，以求得到与 offer 等同的隐私性。

  截至本文撰写之时，尚不清楚这场讨论是否有结论。BLIP 是可选的规范；从讨论中来看，这个 BLIP 可能会被 LND 实现，但不会被 Eclair 或 lightning-kmp（Phoenix 钱包的基础）实现；其它实现的计划没有展现。

## 新版本和候选版本

*流行的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试旧版本。*

- [Bitcoin Core 26.2rc1][] 是 Bitcoin Core 旧版本系列的一个维护版本的候选版本。

## 重大的代码和文档变更

*近期出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]*

- [Bitcoin Core #28167][] 引入了 `-prccookieperms` 作为 `bitcoind` 的一种新的启动选项，以允许用户为 RPC 许可 cookie 设定文件读取权限，可在 owner（默认值）、group 和 all users 之间选择。

- [Bitcoin Core #30007][] 将 Ava Chow（achow 101）的 DNS 种子库添加到了 `chainparams`，以提供一个额外的受信任对等节点发现源。它使用了 [Dnsseedrs][dnsseedrs]，一种新的开源的比特币 DNS 种子库，以 Rust 语言编写，可抓取属于 IPv4、IPv6、Tor v3、I2P 和 CJDNS 网络的节点地址。

- [Bitcoin Core #30200][] 引入了一种新的 `Mining`（挖矿）接口。现有的 RPC，比如 `getblocktemplate` 和 `generateblock`，将立即开始使用这个接口。未来的工作，比如使用 Bitcoin Core 作为模板提供者的 [Stratum V2][topic pooled mining] 接口，也将使用这种新的挖矿接口。

- [Core Lightning #7342][] 纠正了对一种罕见的启动情形的处理：因为检测到 `bitcoind` 回退了其区块高度而中断服务（在区块链重组期间，就可能发生这种事）。现在，它会等待区块高度到达其以前记录的高度，然后开始扫描新收到的（也即重组的）区块。

- [LND #8796][] 放松了对通道开启参数的限制，从现在开始，允许对等节点使用一个 `min_depth` 为 0 的参数、初始化非[零确认][topic zero-conf channels]的通道。不过，LND 还是会等待至少一个确认，才将相关通道认为是可用的。这一变更提升了 LND 与其它支持这种特性的闪电实现（比如 LDK）的互操作性，并与 [BOLT2][] 规范一致。

- [LDK #3125][] 加入了编码和解析 `HeldHtlcAvailable` 和 `ReleaseHeldHtlc` 消息的支持，这是未来实现[异步支付][topic async payments]协议的前提。它也为这些消息添加了[洋葱消息][topic onion messages]载荷，还为 `OnionMessenger` 加入了一个 `AsyncPaymentsMessageHandler` 特征。

- [BIPs #1610][] 添加了 [BIP379][BIP379 md] 作为 [Miniscript][topic miniscript] 的规范。Miniscript 是一种可以编译成 Bitcoin Script 但允许组合、模板化以及确定性分析的编程语言。[周报 #304][news304 miniscript] 之前介绍过这个 BIP。

- [BIPs #1540][] 添加了 [328][bip328]、[390][bip390] 和 [373][bip373] 作为 [MuSig2][topic musig] 聚合公钥派生方案（328）、输出脚本[描述符][topic descriptors]（390）以及允许 MuSig2 数据进入任意版本的 PSBT 的 [PSBT][topic psbt] 字段（373）的规范。MuSig2 是一种用于[schnorr 数字签名][topic schnorr signatures]算法的公钥及签名聚合协议，它只要求两轮交互（MuSig1 要求三轮交互），从而提供了与基于脚本的多签名差别不大的签名体验。这套派生方案允许从一个 [BIP327][] MuSig2 聚合公钥构造 [BIP32][topic bip32] 类型的拓展公钥。

{% include references.md %}
{% include linkers/issues.md v=2 issues="28167,30007,30200,7342,8796,3125,1610,1540,15617" %}

[bitcoin core 26.2rc1]: https://bitcoincore.org/bin/bitcoin-core-26.2/
[mouton b11b]: https://delvingbitcoin.org/t/blip-bolt-11-invoice-blinded-path-tagged-field/991
[teinturier b11b]: https://delvingbitcoin.org/t/blip-bolt-11-invoice-blinded-path-tagged-field/991/5
[osuntokun b11b]: https://delvingbitcoin.org/t/blip-bolt-11-invoice-blinded-path-tagged-field/991/6
[l402]: https://github.com/lightninglabs/L402
[remote code execution due to bug in miniupnpc]: https://bitcoincore.org/en/2024/07/03/disclose_upnp_rce/
[cve-2015-6031]: https://nvd.nist.gov/vuln/detail/CVE-2015-6031
[node crash dos from multiple peers with large messages]: https://bitcoincore.org/en/2024/07/03/disclose_receive_buffer_oom/
[censorship of unconfirmed transactions]: https://bitcoincore.org/en/2024/07/03/disclose_already_asked_for/
[unbound ban list cpu/memory dos]: https://bitcoincore.org/en/2024/07/03/disclose-unbounded-banlist/
[netsplit from excessive time adjustment]: https://bitcoincore.org/en/2024/07/03/disclose-timestamp-overflow/
[cpu dos and node stalling from orphan handling]: https://bitcoincore.org/en/2024/07/03/disclose-orphan-dos/
[memory dos from large `inv` messages]: https://bitcoincore.org/en/2024/07/03/disclose-inv-buffer-blowup/
[memory dos using low-difficulty headers]: https://bitcoincore.org/en/2024/07/03/disclose-header-spam/
[cpu-wasting dos due to malformed requests]: https://bitcoincore.org/en/2024/07/03/disclose-getdata-cpu/
[news70 bip70]: /en/newsletters/2019/10/30/#bitcoin-core-17165
[memory-related crash in attempts to parse BIP72 URIs]: https://bitcoincore.org/en/2024/07/03/disclose-bip70-crash/
[cve-2020-14198]: https://nvd.nist.gov/vuln/detail/CVE-2020-14198
[news306 disclosure]: /zh/newsletters/2024/06/07/#upcoming-disclosure-of-vulnerabilities-affecting-old-versions-of-bitcoin-core
[upnp]: https://zh.wikipedia.org/wiki/UPnP
[nat]: https://zh.wikipedia.org/wiki/%E7%BD%91%E7%BB%9C%E5%9C%B0%E5%9D%80%E8%BD%AC%E6%8D%A2
[miniupnpc library]: https://miniupnp.tuxfamily.org/
[poinsot disclose]: https://mailing-list.bitcoindevs.xyz/bitcoindev/xsylfaVvODFtrvkaPyXh0mIc64DWMCchxiVdTApFqJ_0Q5v0bOoDpS_36HwDKmzdDO9U2RKMzESEiVaq47FTamegi2kCNtVZeDAjSR4G7Ic=@protonmail.com/
[bcco announce]: https://bitcoincore.org/en/security-advisories/
[new disclosure policy]: https://mailing-list.bitcoindevs.xyz/bitcoindev/rALfxJ5b5hyubGwdVW3F4jtugxnXRvc-tjD_qwW7z73rd5j7lXGNdEHWikmSdmNG3vkSOIwEryZzOZr_DgmVDDmt9qsX0gpRAcpY9CfwSk4=@protonmail.com/T/#u
[CVE-2015-3641]: https://nvd.nist.gov/vuln/detail/CVE-2015-3641
[dnsseedrs]: https://github.com/achow101/dnsseedrs
[news304 miniscript]: /zh/newsletters/2024/05/24/#proposed-miniscript-bip-miniscript-bip
[BIP379 md]: https://github.com/bitcoin/bips/blob/master/bip-0379.md
