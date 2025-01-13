---
title: 'Bitcoin Optech Newsletter #335'
permalink: /zh/newsletters/2025/01/03/
name: 2025-01-03-newsletter-zh
slug: 2025-01-03-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的新闻部分链接了关于使用中心化 coinjoin 协议的软件中长期存在的去匿名化漏洞的信息，还总结了（兼容无脚本式门限签名） ChillDKG 分布式密钥生成协议的 BIP 草案的一项更新。此外是我们的常规部分：总结关于变更比特币的共识规则的讨论、宣布软件的新版本和候选版本，以及热门的比特币基础设施软件的重大变更介绍。

## 新闻

- **<!--deanonymization-attacks-against-centralized-coinjoin-->对中心化 conjoin 协议的去匿名化攻击**：Yuval Kogman 在 Bitcoin-Dev 邮件组中[公开][kogman cc]了被当前版本的 Wasabi 和 Ginger 钱包软件（以及旧版本的 Samourai、Sparrow 和 Trezor Suite 钱包软件）所用的中心化 [coinjoin][topic coinjoin] 协议中的多项降低隐私性的漏洞。Kogman 曾经帮助设计用在 Wasabi 和 Ginger 中的 WabiSabi 协议（见[周报 #102][news102 wabisabi]），但 “在发布前离开以示抗议）。如果这些漏洞遭到利用，中心化的协调员可以确定哪个用户收到了哪个输出，从而取消使用一个复杂协议（相对于简单的网络服务器）的任何好处。Kogman 提供证明表明多位钱包开发者已经知晓这些漏洞长达数年。影响上述部分软件在一个类似漏洞已在[周报 #333][news333 vuln] 中提及。
- **<!--updated-chilldkg-draft-->ChillDKG 草案更新**：Tim Ruffing 和 Jonas Nick 在 Bitcoin-Dev 邮件组中[发帖][rn chilldkg]链接到了 [当前的 ChillDKG BIP 草案][bip-chilldkg]，该草案描述了一种与 FROST [无脚本式门限签名][topic threshold signature]兼容的分布式密钥生成协议。自他们最初公布该草案（[周报 #312][news312 chilldkg]）依赖，他们已经修复了一项安全漏洞、添加了一个可以识别故障参与者的调查阶段，并让备份和复原更加容易。他们已经跟 Sivaram Dhakshinamoorthy 合作，保证他们的提议跟后者兼容于比特币的 FROST 签名协议保持同步（详见[周报 #315][news315 frost]）。

## 共识变更

*一个新的月度栏目，总结关于变更比特币共识规则的提议和讨论。*

- **<!--ctv-enhancement-opcodes-->增强 CTV 的操作码**：开发者 mooonsettler 在 [Bitcoin-Dev][moonsettler ctvppml] 和 [Delving Bitcoin][moonsettler ctvppdelv] 论坛中发帖提议两种额外的操作码，用于跟已经提出的 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 相结合：

  - *OP_TEMPLATEHASH* 取一系列的交易元素为输入，转化为一个 CTV 兼容的哈希值。这让堆栈操作可以指明要被使用的输入、输入的数量、交易锁定时间、每个输出的价值、每个输出的脚本、输出的数量，以及要使用的交易版本号。
  - *OP_INPUTAMOUNTS* 将部分或者所有输入的价值（聪）放到堆栈里，可以用作 `OP_TEMPLATEHASH` 的参数（例如，用于要求一个价值相等的输出）。

  这些操作码可以一起创建跟 [BIP345][] 的 `OP_VAULT` 所能实现的 “[保险柜][topic vaults]” 具备类似属性的合约。这些操作码还可能为实现链上效率更高的[可追责计算][topic acc]以及其它合约式协议提供便利。截至本刊撰写之时，Delving Bitcoin 帖子中的讨论还在进行。

- **<!--adjusting-difficulty-beyond-256-bits-->** **调整超过 256 比特的难度**：Anders 在 Bitcoin-Dev 邮件组中[发帖][anders diff]表示担心区块头中能否调整超过 256 比特的 PoW 难度。当前的哈希率要经历突破无法想象的增长（2<sup>176</sup> 倍）才会面临这种情形，但 Michael Cassano [指出][cassano diff]，如果真的遇上这一天，那么一次分叉可以添加一个次级哈希目标，并且，只有主要哈希目标和次级哈希目标都达成，才能被当作一个有效区块。这就类似于一种缓解 “区块扣留攻击（block withholding attacks）”（详见[周报 #315][news315 withholding]）的提议。这种类型的分叉（也包括像 “forward blocks” 这样的提议，详见[周报 #16][news16 forward]），可能在技术上算是软分叉，因为它们只收紧了已有的规则，但一些开发者希望不要使用这样的标签，因为它们让不升级的节点以及可能所有轻（SPV）客户端都更容易被欺骗 —— 认为某一笔交易已经获得了几百次甚至上千次确认，但事实上这样的交易并没有被确认，或者与一笔已经确认的交易相冲突。

- **<!--transitory-soft-forks-for-cleanup-soft-forks-->用于共识清理软分叉的临时软分叉**：Jeremy Rubin 在 Delving Bitcoin 论坛中[提议][rubin transitory]仅仅临时应用为缓解或修复漏洞而设计的共识规则。这个想法曾经被提议用于添加新特性（详见[周报 #197][news197 transitory]），但并没有获得来自新特性支持者和对提议变更持犹豫态度的社区成员的任何支持。Rubin 表示，这个想法可能更适合于尝试修复漏洞但可能带来意外后果（阻止用户花费自己的比特币，称作 “没收风险”；或限制未来轻松修复漏洞的能力）的软分叉。David Harding [主张][harding transitory] ，临时软分叉提议在以前之所以缺乏支持，正是因为不论支持还是怀疑的社区成员，都不想要每隔几年就重新讨论一次支持或反对某一项共识变更；不论软分叉的内容是增加一项特性，还是解决一项流动，这种顾虑都是一样的。

- **<!--quantum-computer-upgrade-path-->抗量子计算机升级路径**：Matt Corallo 在 Bitcoin-Dev 邮件组中[提议][corallo qc]在 [tapscript][topic tapscript] 中添加一种抗量子计算的签名检查操作码，以允许资金被花费，即使 ECDSA 和 [Schnorr 签名][topic schnorr signatures] 相关的操作码都因为快速量子计算机的伪造风险而被禁用。Luke Dashjr [指出][dashjr qc]，当前为此使用一次软分叉是没有必要的，除非对抗量子的签名检查操作码在未来的工作原理已经有了广泛的共识、从而用户只需承诺它作为一个未来可用的选项。Tadge Dryja [建议][dryja qc] 使用一种临时软分叉，如果量子计算机看起来很快就能盗窃比特币了，那就临时限制使用无法抗量子的 ECDSA 和 Schnorr 签名；然后，如果有人能在链上解开一个只有量子计算机（或者发现了一种基础性的密码学漏洞）才能解开的谜题合约，那就自动将这种临时软分叉变成永久性的；否则，这个临时软分叉可以更新，或者失效（让被 ECDSA 和 Schnorr 签名保护的比特币重新变得可花费）。

- **<!--consensus-cleanup-timewarp-grace-period-->共识清理软分叉中的时间扭曲宽限期**：Sjors Provoost 在 Delving Bitcoin 论坛中[讨论][provoost timewarp] “[共识清理][topic consensus cleanup]” 软分叉缓解[时间扭曲攻击][topic time warp]的提议：禁止一个新难度周期的第一个区块的时间戳比上一周期的最后一个区块早于 600 秒。Provoost 担心，通过使用一个范围内的时间戳（称作 “时间戳滚动”）来扩大自己的挖矿 nonce 空间的诚实矿工会意外产生出具有较慢始终的节点不会立即接受的区块，从而降低该区块的传播速度（相比具有更小可变时间戳、但可能在同一时间生成出的竞争区块的）。如果一个竞争区块保持在最佳链上，那么滚动时间戳的矿工就会丧失收入。Provoost 转而建议一种不那么严苛的限制，例如禁止时间回退超过 7200 秒（两个小时）。Aotoine Poinsot 为 600 秒的选择[辩护][poinsot timewarp]，认为它避免了任何已知的问题，并提供了对未来的时间扭曲攻击的更强防御。

## 新版本和候选版本

*热门的比特币基础设施软件的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。*

- [BDK wallet-1.0.0][] 是这个用于开发比特币钱包软件或其它比特币赋能应用的库的第一个主要版本。最初的 Rust 库  `bdk` 已经被重命名为 `bdk_wallet`（带有一个有意保持稳定的 API）；而更低层级的模块已经被抽取成为独立的库，包括 `bdk_chain`、`bkd_electrum`、`bdk_esplora` 以及 `bdk_bitcoind_rpc`。
-  [LND 0.18.4-beta][] 是这个热门的闪电节点实现的一个小版本，它 “带有构建定制化通道所需的特性，以及常见 bug 的修复和稳定性提升”。
- [Core Lightning v24.11.1][] 是一个小版本，提升跟实验性插件 `xpay` 和更老的 `pay` RPC 之间的兼容性，并为 xpay 用户制作了多项其它升级。
- [Bitcoin Core 28.1rc2][] 是这个主流全节点实现的一个维护版本的候选发行。
- [LDK v0.1.0-beta1][] 是这个用于开发闪电节点赋能钱包和应用的库的一个候选发行。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Bitcoin Core #31223][] 改变了节点派生其 “[Tor][topic anonymity networks] 服务目标” P2P 端口的方法（详见周报 [#118][news118 tor]），使用用户指定的 `-port` 数值 + 1，而不是默认的 8334（只要用户给出了 `-port` 的数值）。这修复了一个问题：当本地多个节点都绑定到 8334 时，节点会因为端口冲突而宕机。不过，在两个本地节点都被分配了连续的 `-port` 数值的罕见情形中，它们的派生洋葱端口依然可能会冲突，但这完全可以避免。
- [Eclair #2888][] 实现了对 [BOLTs #1110][] 所述的[对等节点存储备份][topic peer storage]协议的支持，该协议让节点可以为发起请求的对等节点存储加密备份，默认最多 65 kB 。这一特性是为服务移动钱包的闪电网络服务商（LSP）而准备的，并且拥有可配置的设定，允许节点运营者指定自己原因保存数据多长时间。这让 Eclair 在 CLN 之后成为第二个支持对等节点存储的实现（详见周报 [#238][news238 storage]）。
- [LDK #3495][]  基于从随机探针中收集的真实世界数据，改善了[概率密度函数][probability density]和相关参数，从而提炼了闪电支付寻路中的历史成功率打分模型。这项 PR 将历史模型和先验模型与真实世界的行为相结合，加强了默认惩罚机制，并提高了寻路可靠性。
- [LDK #3436][] 将 `lightning-liquidity` 库移到了 `rust-lightning` 代码库内。这个库会提供在一个基于 LDK 的节点内集成一个（如[此处][lsp spec]所述的）LSP 所需的类型和原语。
- [LDK #3435][] 为[盲化路径][topic rv routing]支付语境消息添加了一个身份认证字段，让支付者可以包含一个基于哈希函数的消息认证码（HMAC）以及一个 nonce 之，让接收者可以验证支付者的身份。这修复了攻击者可以从一个由受害者节点发行的 [BOLT11][] 发票取得一个 `payment_secret` 的问题（即使该秘密值与该 [offer][topic offers] 所期待的数额并不匹配）。这可以帮助防止使用相同技术发起的去匿名化攻击。
- [LDK #3365][] 通过从 `get_channel_reestablish` 检索出 `holder_commitment_point`（下一个承诺交易点）（而非让它留在以前用过的 `PendingNext` 状态中），保证该值在升级中会立即被标记为可用。这一变更防止了一条通道在升级期间处于静止状态时，因为收到一条要求回复下一个承诺交易点的 `commitment_signed` 消息而强制关闭通道。
- [LDK #3340][] 加入了对带有[可钉死的][topic transaction pinning]输出的链上申领资金交易的[批处理][topic payment batching]，降低了强制关闭情形下得区块空间用量。以前，只有节点可以排他性领取（因此是不可钉死）的输出才可以批处理。现在，任何对手方可在 12 个区块内花费的输出都会被处理为可订死的，然后相应批量处理，只要它们的 [HTLC][topic htlc] 超时交易的[锁定时间][topic timelocks]是可以组合的。
- [BDK #1670][] 引入了一种新的 O(n) 规范化算法（canonicalization algorithm），可以定位合乎规范的交易，并从钱包的本地最佳链状态视角中移除与之冲突且不太可能被确认（不规范）的交易。这一显著更高效的办法替代了旧的 `get_chain_position`（该方法提供了 O(n<sup>2</sup>) 的解决方案，[可能已经成为][canalgo]特定使用场景中的 DoS 风险，现已被移除）。
- [BIPs #1689][] 合并了 [BIP374][]，以指定一种在比特币所使用的椭圆曲线（secp256k1）上生成和验证 “离散对数等式证据（[DLEQ][topic dleq]）” 的标准方法。这一 BIP 的动机是为多个独立签名人参与创建的 “[静默支付][topic silent payments]” 提供支持；一个 DLEQ 让所有签名人都能向联合签名人证明自己的签名是有效的，不会带来资金损失风险 —— 而且，无需揭晓自己的私钥。
- [BIPs #1697][] 更新了 [BIP388][]，通过仔细地变更语法，支持在[输出脚本描述符][topic descriptors]的模板集合中使用[MuSig][topic musig]。
- [BLIPs #52][] 添加了 [BLIP50][]，以指定一种用于 LSP 节点和客户沟通的协议，并使用一种基于 [BOLT8][] 点对点消息协议的 JSON-RPC 格式。这是一组从 [LSP 规范代码库][lsp spec] 上传的 BLIP 中的一个；这些规范被认为是稳定的，因为它们已经在多个 LSP 和客户端实现中进入生产场景。
- [BLIPs #54][] 添加了 [BLIP52][] 以指定一种 [JIT 通道][topic jit channels] 协议，让还没有任何闪电通道的客户端也可以立即接收支付。当 LSP 收到一个入账支付时，TA 会与客户端开启一条通道，而开启通道的代价会从收到的第一笔支付中扣除。这也是从 [LSP 规范代码库][lsp spec] 中上传的 BLIP 中的一个。 

{% include references.md %}
{% include linkers/issues.md v=2 issues="31223,2888,3495,3436,3435,3365,3340,1670,1689,1697,54,52,1110" %}

[news315 withholding]: /zh/newsletters/2024/08/09/#block-withholding-attacks-and-potential-solutions
[news16 forward]: /en/newsletters/2018/10/09/#forward-blocks-on-chain-capacity-increases-without-a-hard-fork
[moonsettler ctvppml]: https://groups.google.com/g/bitcoindev/c/1P1aqkfwE7E
[moonsettler ctvppdelv]: https://delvingbitcoin.org/t/ctv-op-templatehash-and-op-inputamounts/1344/
[anders diff]: https://groups.google.com/g/bitcoindev/c/JhEyfW7YKhY/m/qR4ucBeMCAAJ
[cassano diff]: https://groups.google.com/g/bitcoindev/c/JhEyfW7YKhY/m/gPNAMn3ICAAJ
[corallo qc]: https://groups.google.com/g/bitcoindev/c/8O857bRSVV8/m/4cM-7pf4AgAJ
[dashjr qc]: https://groups.google.com/g/bitcoindev/c/8O857bRSVV8/m/YT0fR2j_AgAJ
[dryja qc]: https://groups.google.com/g/bitcoindev/c/8O857bRSVV8/m/8nr6I5NIAwAJ
[rubin transitory]: https://delvingbitcoin.org/t/transitory-soft-forks-for-consensus-cleanup-forks/1333
[news197 transitory]: /en/newsletters/2022/04/27/#relayed
[harding transitory]: https://delvingbitcoin.org/t/transitory-soft-forks-for-consensus-cleanup-forks/1333/2
[provoost timewarp]: https://delvingbitcoin.org/t/timewarp-attack-600-second-grace-period/1326
[poinsot timewarp]: https://delvingbitcoin.org/t/timewarp-attack-600-second-grace-period/1326/11
[news333 vuln]: /zh/newsletters/2024/12/13/#deanonymization-vulnerability-affecting-wasabi-and-related-software
[news315 frost]: /zh/newsletters/2024/08/09/#proposed-bip-for-scriptless-threshold-signatures
[news312 chilldkg]: /zh/newsletters/2024/07/19/#distributed-key-generation-protocol-for-frost
[kogman cc]: https://groups.google.com/g/bitcoindev/c/CbfbEGozG7c/m/w2B-RRdUCQAJ
[news102 wabisabi]: /en/newsletters/2020/06/17/#wabisabi-coordinated-coinjoins-with-arbitrary-output-values
[rn chilldkg]: https://groups.google.com/g/bitcoindev/c/HE3HSnGTpoQ/m/Y2VhaMCrCAAJ
[bip-chilldkg]: https://github.com/BlockstreamResearch/bip-frost-dkg
[lnd 0.18.4-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.4-beta
[bitcoin core 28.1rc2]: https://bitcoincore.org/bin/bitcoin-core-28.1/
[bdk wallet-1.0.0]: https://github.com/bitcoindevkit/bdk/releases/tag/wallet-1.0.0
[core lightning v24.11.1]: https://github.com/ElementsProject/lightning/releases/tag/v24.11.1
[ldk v0.1.0-beta1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1.0-beta1
[news118 tor]: /en/newsletters/2020/10/07/#bitcoin-core-19991
[news238 storage]: /zh/newsletters/2023/02/15/#core-lightning-5361
[lsp spec]: https://github.com/BitcoinAndLightningLayerSpecs/lsp
[probability density]: https://en.wikipedia.org/wiki/Probability_density_function
[canalgo]: https://github.com/evanlinjin/bdk/blob/e9854455ca77875a6ff79047726064ba42f94f29/docs/adr/0003_canonicalization_algorithm.md
