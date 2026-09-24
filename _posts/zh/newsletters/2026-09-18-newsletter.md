---
title: 'Bitcoin Optech 周报 #423'
permalink: /zh/newsletters/2026/09/18/
name: 2026-09-18-newsletter-zh
slug: 2026-09-18-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报总结了一份分析：矿池的难度控制器会让慢下来的矿工陷入搁浅；此外还介绍了一项针对 Utreexo 初始区块下载的改进提案，并给出了一份 BIP 草案的链接，用来规定不可花费的 taproot 内部密钥。此外还包括我们的常规栏目：介绍服务和客户端软件的近期变化、新版本和候选版本的公告，以及流行比特币基础设施软件的重大变更。

## 新闻

- **<!--vardiff-controllers-that-strand-slowing-miners-->****会让减速矿工陷入搁浅的 vardiff 控制器：** Eric Price 在 Delving Bitcoin 上[发帖][price vardiff]，分析了[矿池][topic pooled mining]在矿工慢下来时如何调整其难度。矿池会给每位矿工指定一个份额难度（share difficulty），这是一个比全网难度更容易达到的目标值；区块头候选必须达到这个目标，才能作为份额提交上去。有一类叫做可变难度（vardiff）控制器的软件，它运行在矿池里，或者运行在矿工与矿池之间的代理上，根据矿工提交份额的快慢来调高或调低这个难度，目标是维持一个稳定的份额速率。而矿工一旦慢下来，难度却仍然停在按它此前速度设定的水平上，于是产出的份额就很少。至于那种只在份额到达时才更新的控制器，则可能根本注意不到这次减速。

  Price 认为，调整控制器的参数解决不了这个问题，因为控制器没办法从那些压根没有到达的份额里估算出速率来。一个只在份额落地时才重新计算的控制器，可能会无限期地把难度保持在过高的水平上。他给出的修复办法是加一个计时器：只要固定的时间间隔过去、期间没有收到该矿工的份额，就把难度调低。Stratum v2 的参考实现已经这么做了，只不过对于长时间保持连接的矿工，它恢复得比较慢。Ckpool 则只在收到份额时才重新计算。他还放出了一个[整形代理（shaping proxy）][shape proxy]，它会丢弃矿工的一部分份额，好让运维者测试自家矿池到底会不会把难度调下来。

  Anthony Towns [建议][towns vardiff]在 Stratum v2 和 [DATUM][news325 datum] 部署所使用的本地代理或网关上处理这件事，例如在 30 秒没有收到份额之后，就把该连接的难度减半。Price 表示认同，并在[另一个主题帖][price frontier]里论证说：针对每位矿工的控制，必须落在仍然能看到每位矿工份额的最后一跳上。

- **<!--improvements-in-utreexo-initial-block-download-->****Utreexo 初始区块下载的改进：** Davidson Souza 在 Delving Bitcoin 上[发帖][utreexo ibd del]，介绍了一种在初始区块下载（IBD）期间提升 [Utreexo][topic utreexo] 性能的办法。Utreexo 是一种动态累加器，它把 UTXO 集表示成一片由完美默克尔树构成的森林，这样节点只需保存这些树根。它的目标是降低验证节点的存储需求，代价则是带宽增加——因为每笔交易的验证都需要附上一份包含证明。每份包含证明的大小都和它相关的那个区块差不多，加起来总的数据需求大约是 1.3TB。即便对近期花掉的 UTXO 做大量缓存，用于显式删除的证明数据仍有大约 200GB。这项提案会让 IBD 期间不再需要删除证明，从而把证明方面的开销降到接近于零。

  按照目前正在 [BIPs #1923] 中讨论的 BIP181，Utreexo 有一个 `modify` 操作，它既负责把输出添加到树中，也负责把输出从树中删除。前者遵循一个多步骤的流程，借助的是“销毁并移动”的循环；而后者的做法是删掉树上的一个节点，并把它的兄弟节点提升到它们父节点原来的位置上。Souza 和其他开发者提议修改这个添加操作，让它把删除隐含在内。如果你事先就知道某个 UTXO 已经被花掉了，那就可以干脆不把它加进树里，而是直接把树根按删除操作所预期的那样往上提。

  其中一个关键点在于：怎么知道哪些 UTXO 已经被花掉了。Souza 的提案利用了 [SwiftSync][topic swiftsync] 的 hints 文件——这个文件的用途恰恰就是记录被花掉的输出，同时它还保有一份哈希聚合值，可以用来检查所提供的文件是否正确。这也意味着，这个隐式删除操作只能在 IBD 期间使用；IBD 结束之后，Utreexo 客户端就会回到常规的添加和删除操作上。一个基于 `assumevalid` 的 SwiftSync 实现正在 [Floresta #1115][flor PR115] 中开发，而不依赖 `assumevalid` 的版本也在积极开发之中。

- **<!--new-bip-draft-for-unspendable-internal-keys-->****不可花费内部密钥的新 BIP 草案：** NTL 在 Bitcoin-Dev 邮件列表上[发帖][unspendable ml]，介绍了他的提案：写一份新的 BIP 草案，规定如何让 [taproot][topic taproot] 密钥路径变得不可花费。这份新规范建立在此前 Salvatore Ingala、Pieter Wuille、Josie Baker 等开发者在 Delving Bitcoin 上的一场讨论之上（见[周报 #283][news283 unspendable]），也建立在 Andrew Toth 此前在 [BIPs #1746][] 中定义一份专门 BIP 的尝试之上（见[周报 #338][news338 unspendable]）。

  这项提案已经以[草案][unspendable gh]的形式放出，它用 `_` 作为占位符，表示这个内部密钥没有已知的签名密钥。它还规定，内部密钥必须从一个合成的 [BIP32][] 扩展公钥派生而来，这个扩展公钥用的是 [BIP341][] 的 Nothing Up My Sleeve（NUMS）点——一个离散对数未知的点——以及一个链码，而这个链码是对规范化之后的策略所作的带标签哈希；这样一来，不同的实现就能各自独立地复现出同一个地址。

  按作者的说法，这项新提案遵循三条指导原则：它不去管别的 BIP 有没有被遵守，除非那直接影响到当前这个具体问题；它不提出新的密码学方案或新结构，只使用已经有的东西；它也不宣称自己对脚本做了语义上的规范化。

## 服务和客户端软件的变更

*在这个每月栏目中，我们会重点介绍比特币钱包和服务的有趣更新。*

- **<!--bitboxapp-adds-spark-based-lightning-payments-->****BitBoxApp 增加基于 Spark 的闪电网络支付：** BitBox [宣布][bitbox ln blog]在移动版 BitBoxApp [4.52.0][bitboxapp 4.52.0] 中推出一个公开测试版热钱包，它构建在 Breez SDK 和 Spark [状态链][topic statechains]之上。

- **<!--covenants-diy-script-editor-->****Covenants.diy 脚本编辑器：** [covenants.diy][covenants diy] 是一个编辑器，用来构建[限制条款][topic covenants]脚本，并在浏览器里单步执行它们。它支持的能力包括 [`OP_CTV`][topic op_checktemplateverify]、[`OP_CSFS`][topic op_checksigfromstack]、[`OP_CAT`][topic op_cat]、[ANYPREVOUT][topic sighash_anyprevout]、`OP_TEMPLATEHASH`、`OP_INTERNALKEY`、`OP_PAIRCOMMIT` 和 `OP_TXHASH`，设计用途是在测试网络上使用。

- **<!--entropylab-offline-key-calculator-->****EntropyLab 离线密钥计算器：** [EntropyLab][entropylab gh] 是一个自包含的 HTML 文件，供气隙环境使用；它可以把用户提供的熵或已有的密钥材料，转换成 [BIP39][] 种子、扩展密钥、[描述符][topic descriptors]、地址、[BIP85][] 子熵，以及 [BIP352][] [静默支付][topic silent payments]地址等等。

## 版本和候选版本

_流行比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。_

- [Eclair 0.14.3][] 是这一闪电网络节点实现的安全版本，它修复了可被恶意对等节点利用的漏洞，强烈建议升级。它修复了通道关闭、[拼接][topic splicing]和[即时注资][topic jit channels]方面的问题。它还增加了对注资费率的可配置上限，并允许[蹦床节点][topic trampoline payments]留存更低的手续费以提升支付成功率，详见下文的重大变更栏目。

## 重大的代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #35445][] 修复了一个兼容性 bug：已有的[描述符][topic descriptors]钱包，如果其 [miniscript][topic miniscript] 表达式使用了 `h` 这种风格的硬化派生标记，在升级到 31.0 版之后就加载不了。此前的一次改动 [#31734][bitcoin core #31734] 改变了 Bitcoin Core 在计算内部描述符标识符时表示硬化派生路径的方式，导致新版软件误报这个已有的钱包已经损坏。现在，已存储的标识符会被当作相关钱包记录之间的链接来对待，而不再是需要重新计算并验证的值。`importdescriptors` 和 `createwalletdescriptor` 这两个 RPC 在检查某个描述符是否已经存在时，现在改为比较规范化之后的描述符字符串。

- [Bitcoin Core #36076][] 修复了一个 bug：`combinepsbt` 在合并 [PSBT][topic psbt] 时，可能把某个输入所要求的签名哈希（sighash）类型丢掉。如果第一个 PSBT 里没有 `PSBT_IN_SIGHASH_TYPE`，那么从另一个 PSBT 复制过来的签名就不会带上这个字段，于是最终化时可能会拒绝那些使用了非默认 sighash 类型（例如 `ALL|ANYONECANPAY`）的有效签名。现在，当这个字段在第一个 PSBT 中缺失时也会被复制过来，这样无论参数顺序如何，都能完成最终化。

- [Bitcoin Core #36150][] 修复了一个 bug：把修剪与新建的[致密区块过滤器索引][topic compact block filters]（`-blockfilterindex`）或 UTXO 集统计索引（`-coinstatsindex`，见[周报 #198][news198 coinstats]）一起启用时，可能导致该索引无法完成同步。当一个未修剪的节点带着这两项设置重启时，区块文件可能在新索引还没确定自己需要哪些区块之前就被修剪掉了。现在，索引会在高度零处安上一个修剪锁，而且早在它处理第一个区块之前就安好。

- [Bitcoin Core #36174][] 为新 HTTP 服务器（见[周报 #411][news411 http]）增加了发送侧的背压，与[周报 #422][news422 http]介绍的接收侧防护相配套。此前，客户端可以只管发很多请求却不去读回复，导致排队的回复数据无限增长。现在，当某条连接的发送缓冲区超过 32 MiB 时，服务器会暂停处理该连接后续的请求，等客户端把回复读走之后再恢复。此前那次修复防的是另一个方向：进来的请求堆积得比处理速度还快。

- [Bitcoin Core #34743][] 改变了 IBD 期间手动选定的对等节点拖住区块下载时的处理方式（见[周报 #237][news237 stall]）。此前，如果某个对等节点没能把区块交付过来、而下载又缺了它就没法推进，节点就会把该对等节点断开。现在，对于通过 `-addnode`、`-connect` 或 `addnode` RPC 选定的对等节点，节点会把该对等节点尚未交付的区块重新放回可请求状态、改从其他对等节点那里获取，并且在两分钟内不再向这个拖后腿的对等节点发出新的区块请求。手动指定的对等节点仍然受另外的区块下载超时和区块头同步超时约束。

- [Bitcoin Core #36081][] 为 `getmininginfo` RPC 的响应增加了 `bestblockhash` 字段。它和已有的 `next` 对象（见[周报 #339][news339 mininginfo]）配合起来，可以让挖矿软件用一次 RPC 调用就同时取得当前链尖的哈希和下一个区块的难度目标。此前，通过分开的多次 RPC 调用去取哈希和挖矿信息，可能与链尖变化撞上，得到的值会分属不同的链尖。

- [Bitcoin Core #35975][] 修复了一处钱包崩溃：对同一笔交易的两个熔融版本分别调用 `bumpfee` 时，钱包会崩溃。此前，对其中一个版本追加手续费，并不会立刻把另一个标记为已被替换；这时再去对另一个版本追加手续费，就可能触发断言失败并让节点崩溃。现在，对任一版本追加手续费，都会把它的所有熔融变体标记为已被替换；而对一个已经被替换掉的变体再去追加手续费，则会返回错误。这个 PR 还确保备注和[替换][topic rbf]元数据会被复制到熔融交易上（包括熔融过的手续费追加替换交易），并且在重新加载钱包之后依然保留。

- [BIPs #2241][] 加入了 [BIP332][]，它规定了对近期陈旧链尖的选择性加入式中继，此前在[周报 #417][news417 staletip]中讨论过。`staletip` 消息包含一个已知的分叉点区块哈希、这条陈旧分支的各个区块头，以及一个标志位，表明发送方是否愿意提供该陈旧链尖的区块数据。对等节点之间通过 [BIP434][] 协商是否支持这一功能，Bitcoin Core 中的实现见[周报 #410][news410 bip434]。建议的资源上限包括每次通告 20 个区块头，以及 1,000 个区块的时效窗口。

- [BIPs #2258][] 更新了 [BIP93][] [codex32][topic codex32]，在检查校验和的长度限制时把前缀所占的部分也算进去。此前，这些检查只统计数据部分，于是有些字符串的长度会超出该校验和所声明的检错保证能覆盖的范围。现在，规范和参考实现都改用完整展开后的长度来选取和验证校验和。此外，这个 PR 还把主种子的编码限制为 16、20、24、28、32 或 64 字节的种子，以减少在纠正意外插入或删除的字符时的歧义。这些尺寸上已有的编码保持不变，但此前允许的其他尺寸的编码就不再符合规范了。

- [Eclair #3380][] 会拒绝带有 `Origin` 头部的 API 请求，WebSocket 连接也包括在内，以防止有人利用缓存的 HTTP Basic 认证凭据发动跨站请求伪造。基于浏览器的前端现在必须走自己的后端，而不能直接去调用 Eclair。`curl` 和 `eclair-cli` 这类命令行客户端只要不设置这个头部，就不受影响。

- [Eclair #3376][] 修复了通道关闭、[拼接][topic splicing]和[即时注资][topic jit channels]方面的若干问题。在由 Eclair 付手续费的情况下，关闭手续费的协商现在会拒绝那些既超出所配置的最高关闭费率、又落在本地费率区间之外的对方提议。此前，协商的回退路径可能接受过高的手续费，从而把本地的通道余额消耗掉。在拼接尚未完成时强制关闭通道，如果缺少发布这次拼接所需的对方签名，Eclair 现在会使用注资交易已经完整签好的那个最新承诺。如果对方广播了这次拼接、而且它先确认了，Eclair 则改用花费新注资输出的那个承诺来关闭。此外，这个 PR 还会在为经由[盲化][topic rv routing]路径的支付执行即时注资之前，先检查中继手续费和 [CLTV 到期增量][topic cltv expiry delta]，避免那种可能导致资金损失的不安全转发。这个 PR 新增了 `on-chain-fees.max-funding-feerate` 设置项，默认值为 50 sat/vB，用来给通道开启和拼接时[自动估算出的费率][topic fee estimation]设上限。

- [Eclair #3372][] 让充当[蹦床节点][topic trampoline payments]的 Eclair 节点可以留存更低的手续费，从而把发送方手续费预算中更多的部分留给下游路由使用。对于带有路由提示或[盲化][topic rv routing]路径的支付，新增的 `relay.fees.min-local-trampoline` 设置项规定了 Eclair 所留存的最低手续费。运维者可以把这个下限设得比自己标准的出站通道手续费还低，这样当下游手续费总额（包括收款方的闪电网络服务提供商（LSP）所收取的部分）本来会超出预算时，支付仍有机会成功。不带这些提示的支付，则照旧计入通常的本地通道开销。此外，这个 PR 还把 `relay.fees.min-trampoline` 所要求的默认最低手续费总预算，从 1 sat 加上转发金额的 0.01%，提高到 2 sats 加上 0.04%。

- [LND #11163][] 修复了使用转发拦截器（见[周报 #104][news104 intercept]）时对重放 [HTLC][topic htlc] 的处理方式；这个拦截器可以让外部软件来批准或拒绝转发。在对等节点重连或节点重启之后，LND 可能会重新处理一笔它其实已经转发过的入站 HTLC。此前，LND 可能把这当成一次新的拦截，并因为诸如过期时间太近之类的原因把它拒掉——哪怕对应的出站 HTLC 仍然是活跃的。现在，LND 会查看已有的转发记录，让这次重放沿着原本那笔支付的处理结果继续走下去。至于那些还在等拦截器作决定的支付，LND 则会让这笔 HTLC 继续挂起，并沿用它原本的自动失败期限（见[周报 #224][news224 intercept]），从而避免在重放时再做一次过期检查。

- [BDK #2246][] 和 [#2263][bdk #2263] 改进了钱包余额的归类方式（见[周报 #213][news213 balance]），办法是检查某个输出的交易祖先里是否还有尚未结清的交易。此前，花费一笔未确认的入账支付所产生的找零，可能被视为受信任的，尽管它其实取决于那笔入账交易能否确认。现在，BDK 会把这种不受信任的状态沿着后代交易一路传下去。新的 `classify_outpoints` API 会把逐个输出的归类结果暴露出来；而更新后的 `balance` API 则让应用可以分别定义哪些交易算作不受信任，以及什么时候才算结清。第二个 PR 增加了 `ChainPosition::confirmations_lower_bound`，帮助应用定义诸如“需要六个确认”这类结清规则。它返回的是一个保守的确认数（把确认所在的那个区块也算进去），对于未确认的交易，或者确认高度高于所提供链尖的情况，则返回零。

{% include snippets/recap-ad.md when="2026-09-22 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1923,1746,35445,31734,36076,36150,36174,34743,36081,2241,3380,2258,3376,3372,11163,2246,2263,35975" %}

[price vardiff]: https://delvingbitcoin.org/t/research-a-clockless-vardiff-strands-a-slowing-miner/2718
[shape proxy]: https://github.com/marafoundation/sv2-apps/tree/shape-proxy-v0.1.0/test-tools/shape-proxy
[towns vardiff]: https://delvingbitcoin.org/t/research-a-clockless-vardiff-strands-a-slowing-miner/2718/4
[news325 datum]: /zh/newsletters/2024/10/18/#datum-protocol-announced
[price frontier]: https://delvingbitcoin.org/t/vardiff-belongs-at-the-frontier/2734
[utreexo ibd del]: https://delvingbitcoin.org/t/implicit-deletions-and-improvements-in-utreexo-ibd/2881
[flor PR115]: https://github.com/getfloresta/Floresta/pull/1115
[bitbox ln blog]: https://blog.bitbox.swiss/en/introducing-lightning-in-the-bitboxapp/
[bitboxapp 4.52.0]: https://github.com/BitBoxSwiss/bitbox-wallet-app/releases/tag/v4.52.0
[covenants diy]: https://covenants.diy/
[entropylab gh]: https://github.com/OogaBoogaX/entropylab
[unspendable ml]: https://groups.google.com/g/bitcoindev/c/se3TkNnbno4
[news283 unspendable]: /zh/newsletters/2024/01/03/#how-to-specify-unspendable-keys-in-descriptors
[news338 unspendable]: /zh/newsletters/2025/01/24/#draft-bip-for-unspendable-keys-in-descriptors
[unspendable gh]: https://github.com/bitryonix/bips/blob/bip-xxxx-unspendable-internal-keys/bip-xxxx-unspendable-internal-keys.mediawiki
[news198 coinstats]: /zh/newsletters/2022/05/04/#bitcoin-core-21726
[news237 stall]: /zh/newsletters/2023/02/08/#bitcoin-core-25880
[news339 mininginfo]: /zh/newsletters/2025/01/31/#bitcoin-core-31583
[news417 staletip]: /zh/newsletters/2026/08/07/#draft-bip-for-stale-tip-relay
[news410 bip434]: /zh/newsletters/2026/06/19/#bitcoin-core-35221
[news411 http]: /zh/newsletters/2026/06/26/#bitcoin-core-35182
[news422 http]: /zh/newsletters/2026/09/11/#bitcoin-core-36123
[Eclair 0.14.3]: https://github.com/ACINQ/eclair/releases/tag/v0.14.3
[news104 intercept]: /zh/newsletters/2020/07/01/#lnd-4018
[news224 intercept]: /zh/newsletters/2022/11/02/#lnd-6831
[news213 balance]: /zh/newsletters/2022/08/17/#bdk-640
