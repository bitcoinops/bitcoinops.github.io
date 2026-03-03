---
title: 'Bitcoin Optech Newsletter #353'
permalink: /zh/newsletters/2025/05/09/
name: 2025-05-09-newsletter-zh
slug: 2025-05-09-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报介绍一种最近发现的理论上的共识失败漏洞，并链接了一种避免复用 BIP35 钱包路径的提议。此外是我们的常规栏目：最近一期 Bitcoin Core PR 审核俱乐部会议的总结，软件新版本和候选版本的发行说明，以及热门的比特币基础设施软件的重大代码变更说明。

## 新闻

- **<!--bip30-consensus-failure-vulnerability-->** **BIP30 共识失败漏洞**：Ruben Somsen 在 Bitcoin-Dev 邮件组中[发帖][somsen bip30]提出了一个现在（检查点已经从 Bitcoin Core 中移除，详见[周报 #346][news346 checkpoints]）可能发生的理论上的共识故障。简而言之，区块高度 9172 和 91812 的 coinbase 交易跟 91880 和 91842 的分别[重合][topic duplicate transactions]。[BIP30][] 指定这两个区块的处理方式应该跟历史版本的 Bitcoin Core 在 2010 年的处理方式一致，就是在 UTXO 集中用后来出现的重合交易覆盖掉更早的 coinbase 条目。然而，Somsen 指出，影响其中一个（或两个）区块的重组可能导致重合条目从 UTXO 集中移除，而因为先前的覆盖操作，较早的那个条目也不会留下来；但是，一个新启动的节点从未看到过覆盖交易，就依然会保留更早的交易，从而产生不一样的 UTXO 集。如果某一笔交易被花费，这可能会导致共识故障。

  在 Bitcoin Core 还有检查点的时候，这不是个问题，因为检查点要求上述四个区块都出现在最佳区块链上。这不会立即变成问题 —— 只是在理论上，如果比特币的工作量证明安全机制崩溃的话，才会变成现实。人们讨论了多种可能的解决方案，比如为这两个例外硬编码额外的特例逻辑。

- **<!--avoiding-bip32-path-reuse-->** **避免 BIP32 路径复用**：Kevin Loaec 在 Delving Bitcoin 论坛中[发帖][loaec bip32reuse]讨论防止相同的 [BIP32][topic bip32] 钱包派生路径被不同钱包使用的办法；复用相同的路径可能导致隐私风险（因为[输出关联][topic output linking]）以及理论上的资金安全风险（例如，因为[量子计算][topic quantum resistance]的可能性）。他提出了三种可能的方法：使用随机化的路径、使用基于钱包生日的路径，以及使用基于递增计数器的路径。他建议使用基于生日的方法。

  他还建议抛弃大部分 [BIP48][] 派生路径元素，因为随着[描述符][topic descriptors]钱包的日渐流行（尤其在多签名钱包和复杂脚本钱包中），使用这些元素已经没有必要。不过，Salvatore Ingala 依然[建议][ingala bip48]保留 BIP48 路径的 *coin type*（资金类型）部分，因为这可以帮助保证用在不同密码货币中的密钥是有分隔的，一些硬件签名设备也是这样做的。

## Bitcoin Core PR 审核俱乐部

*在这个月度栏目中，我们会总结最近一次 [Bitcoin Core PR 审核俱乐部][Bitcoin Core PR Review Club] 会议，提炼出一些重要的问题和回答。点击问题描述可以看到会议上的回答的总结。*

“[添加可执行的 bitcoin 封装器][review club 31375]” 是由 [ryanofsky][gh ryanofsky] 发起的一项 PR，引入了一种新的 `bitcoin` 二进制文件，可以用来发现和启动多种 Bitcoin Core 二进制文件。

Bitcoin Core v29 发行了 7 种二进制文件（比如，`bitcoind`、`bitcoin-qt` 和 `bitcoin-cli`），但在未来[多进程][multiprocess design]二进制文件推出的时候，这个数量还会[增加][Bitcoin Core #30983]。新的 `bitcoin` 封装器会把命令（例如 `gui`）映射成正确的整体程序（`bitcoin-qt`）或者多线程（`bitocin-gui`）二进制文件。除了探测能力，这个封装器还提供了向前兼容性（forward compatibility），所以二级制文件可以重新组织，而用户界面无需改变。

有了这项 PR，用户可以用 `bitcoin daemon` 或者 `bitcoin gui` 来启动 Bitcoin Core。直接启动 `bitcoind` 或者 `bitcoin-qt` 二进制文件都依然是可行的，不受本 PR 的影响。

{% include functions/details-list.md
  q0="<!--from-issue-30983-four-packaging-strategies-were-listed-which-specific-drawbacks-of-the-side-binaries-approach-does-this-pr-address-->从 Issue #30983 的描述来看，有四种封装策略。这个 PR 所采用的 “side-binaries” 有什么缺点？"
  a0="本 PR 所假设的 side-binaries 方法要求随附现有的整体程序二进制文件发行新的多进程二进制文件。当二进制文件变得这么多，用户可能就会犯难，不知道哪个二进制文件才是自己要的。本 PR 通过提供一个单一的入口来消除大部分混淆，入口可以提供选项的概述和帮助文本。其中一个审核员建议加入模糊搜索，以进一步增加它的作用。"
  a0link="https://bitcoincore.reviews/31375#l-40"
  q1="<!--getexepath-does-not-use-readlink-proc-self-exe-on-linux-even-though-it-would-be-more-direct-what-advantages-does-the-current-implementation-have-what-corner-cases-might-it-miss-->在 Linx 系统中，`GetExePath()` 不会使用 `readlink(\"/proc/self/exe\")` ，即使这样更加直接。那么当前的实现有什么好处？它会不会忽略了什么东西？"
  a1="可能有其它非 Windows 操作系统也没有 proc 文件系统。除此之外，作者和客座都无法找出使用 procfs 的任何缺点。"
  a1link="https://bitcoincore.reviews/31375#l-71"
  q2="<!--in-execcommand-explain-the-purpose-of-the-fallback-os-search-boolean-under-what-circumstances-is-it-better-to-avoid-letting-the-os-search-for-the-binary-on-the-path-->在 `ExecCommand` 中，`fallback_os_search` 布尔值有什么用？在什么情况下，最好避免让操作系统在 `PATH` 中搜索二进制文件？"
  a2="如果可执行的封装器看起来是通过路径（例如 “/build/bin/bitcoin”）而不是搜索（例如 “bitcoin”）调用的，那么它就会假设用户在使用一个本地的编译，然后 `fallback_os_search` 就会设为 `false`。引入这个布尔值是为了避免以外混淆来自不同来源的二进制文件。举个例子，如果用户并没有在本地编译 `gui`，那么 `/build/bin/bitcoin/gui` 就不应该回调系统安装好的 `bitcoin-gui`。作者正在考虑完全移除 `PATH` 搜索，如果能得到用户的反馈意见就好了。"
  a2link="https://bitcoincore.reviews/31375#l-75"
  q3="<!--the-wrapper-searches-prefix-libexec-only-when-it-detects-that-it-is-running-from-an-installed-bin-directory-why-not-always-search-libexec-->封装器仅会在它检测到它从安装好的 `bin` 目录运行时才会搜索。为什么不是总是搜索 `libexec` 呢？"
  a3="封装器对自己尝试运行的目录应该是保守的，而且鼓励使用标准的  `PREFIX/{bin,libexec}` 格式，而不鼓励程序包创建不标准的格式、或在二进制文件以预期之外的方式组织时工作。"
  a3link="https://bitcoincore.reviews/31375#l-75"
  q4="<!--the-pr-adds-an-exemption-in-security-check-py-because-the-wrapper-contains-no-fortified-glibc-calls-why-does-it-not-contain-them-and-would-adding-a-trivial-printf-to-bitcoin-cpp-break-reproducible-builds-under-the-current-rules-->这个 PR 在 `security-check.py` 中添加了一个豁免，因为封装器并不包含强化的（fortified） `glibc` 调用。为什么不包含呢？向 `bitcoin.cpp` 加入一个简单的  `printf` 会在当前的规则下打破可复现的编译吗？"
  a4="封装器二进制文件是非常简单的，它不包含任何可以强化的调用。如果未来加入了这样的调用，security-check.py 中的豁免可以移除。"
  a4link="https://bitcoincore.reviews/31375#l-117"
%}

## 新版本和候选版本

*热门的比特币基础设施项目的新版本和候选版本。请考虑升级到新版本或帮助测试候选版本。*

- [LND 0.19.0-beta.rc4][] 是这个热门的闪电网络节点实现的一个候选版本。一个可能需要测试的重大提升是其新的适用于合作关闭场景的基于 RBF 的手续费追加。

## 重大的代码和文档变更

*本周出现重大变更的有：[Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[Hardware Wallet Interface (HWI)][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[Bitcoin Improvement Proposals (BIPs)][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo]。*

- [Core Lightning #8227][] 加入了基于 Rust 编程语言的 `lsps-client` 和 `lsps-service` 插件，实现了一种闪电服务商（LSP）节点和客户端之间的通信协议，该协议在 [BOLT8][] 点对点消息之上使用了一种 JSON-RPC 格式，如 [BLIP50][]（详见周报 [#335][news335 blip50]）。这为实现 [BLIP51][] 所述的入账流动性请求以及 [BLIP52][] 所述的 “[按需即时通道][topic jit channels]” 奠定了基础。

- [Core Lightning #8162][] 更新了待处理通道开启请求的处理方式：无限期保留对等节点发起的待处理通道请求，但仅保留最新的 100 个。以前，未确认的通道开启请求会在 2016 个区块后抛弃。此外，已关闭的通道也会保留在内存中，以允许节点响应对等节点的 `channel_reestablish` 消息。

- [Core Lightning #8166][] 加强了 `wait` RPC 命令：用子系统专属的对象（`invoices`、`forwards`、`sendpays` 以及 [`htlcs`][topic htlc]）替代了单一的 `details` 对象。此外，`listhtlcs` PRC 现在支持使用新的 `created_index` 和 `updated_index` 字段、`index` 和 `start`、`end` 参数来使用页码。

- [Core Lightning #8237][] 给 `listpeerchannels` PRC 命令添加了一个 `chort_channel_id` 参数，以返回一条具体的通道（如果有的话）。

- [LDK #3700][] 为 `HTLCHandlingFailed` 事件添加了一个新的 `failure_reason` 字段，以提供关于 [HTLC][topic htlc] 失败的额外信息，以及原因来自本地还是下游。`failed_next_destination` 字段被重命名为 `fuilure_type`； `UnknownNextHop` 变体被弃用，换成了更加通用的 `InvalidForward`。

- [Rust Bitcoin #4387][] 重构了 [BIP32][topic bip32] 的错误处理：将单一的 `bip32::Error` 替换成了单独的枚举，用于派生、子编号/路径解析和拓展公钥解析。这个 PR 也引入了一种新的 `DerivationError::MaximunDepthExceeded` 变体，用于超过 256 层的路径。这些 API 变更会打破后向兼容性。

- [BIPs #1835][] 更新了 [BIP48][]（详见周报 [#135][news135 bip48]），以在使用 m/48' 前缀的确定性多签名钱包中为 [taproot][topic taproot]（P2TR）派生保留脚本类型数值 3；现有的其它保留数值有：P2SH-P2WSH（1'）和 P2WSH（2'）。

- [BIPs #1800][] 合并了 [BIP54][]，该 BIP 详述了修复比特币协议中一系列长期存在的漏洞的[共识清理软分叉][topic consensus cleanup]。关于这个 BIP 的详细描述，请看周报 [#348][news348 cleanup]。

- [BOLTs #1245][] 通过禁止在发票中使用非最短长度编码（non-minimal length encodings），收紧了 [BOLT11][]：expiry 字段（x）、最后一跳的 [CLTV 过期差值][topic cltv expiry delta]字段（c），以及特性比特字段（9），都必须以不使用 0 开头的最短长度序列化，而读取者也应该拒绝任何包含 0 开头的发票。这一变更的动机是模糊测试发现，当 LDK 重新序列化非最短的发票为最短发票（删去额外的 0）时，发票的 ECDSA 签名无法通过验证。

{% include snippets/recap-ad.md when="2025-05-13 16:30" %}

{% include references.md %}

{% include linkers/issues.md v=2 issues="8227,8162,8166,8237,3700,4387,1835,1800,1245,50,51,52,30983" %}
[lnd 0.19.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc4
[wuille clustrade]: https://delvingbitcoin.org/t/how-to-linearize-your-cluster/303/68
[somsen bip30]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAPv7TjZTWhgzzdps3vb0YoU3EYJwThDFhNLkf4XmmdfhbORTaw@mail.gmail.com/
[loaec bip32reuse]: https://delvingbitcoin.org/t/avoiding-xpub-derivation-reuse-across-wallets-in-a-ux-friendly-manner/1644
[ingala bip48]: https://delvingbitcoin.org/t/avoiding-xpub-derivation-reuse-across-wallets-in-a-ux-friendly-manner/1644/3
[news346 checkpoints]: /zh/newsletters/2025/03/21/#bitcoin-core-31649
[news335 blip50]: /zh/newsletters/2025/01/03/#blips-52
[news135 bip48]: /zh/newsletters/2021/07/28/#bips-1072
[news348 cleanup]: /zh/newsletters/2025/04/04/#draft-bip-published-for-consensus-cleanup
[review club 31375]: https://bitcoincore.reviews/31375
[gh ryanofsky]: https://github.com/ryanofsky
[multiprocess design]: https://github.com/bitcoin/bitcoin/blob/master/doc/design/multiprocess.md
