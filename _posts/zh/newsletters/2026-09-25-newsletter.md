---
title: 'Bitcoin Optech 周报 #424'
permalink: /zh/newsletters/2026/09/25/
name: 2026-09-25-newsletter-zh
slug: 2026-09-25-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报介绍了一项提案，用于让闪电网络的链下协议具备后量子安全性。此外还包括我们的常规栏目：Bitcoin Stack Exchange 精选问答、新版本和候选版本的公告，以及流行比特币基础设施软件的重大变更。

## 新闻

- **<!--proposal-for-a-post-quantum-lightning-network-->****后量子闪电网络提案：** Ahmet Kurt 在 Delving Bitcoin 上[发帖][pqln del]，介绍了名为 PQLN 的新提案，让闪电网络的链下部分具备[抗量子能力][topic quantum resistance]。这项工作建立在[周报 #408][news408 pq ln]介绍的逐层分析之上。作者与合作者还发表了一篇相关[论文][pqln paper]，并提供了一个基于 rust-lightning、可供测试的[实现][pqln repo]。

  Kurt 解释了闪电网络各层为获得后量子（PQ）安全性所作的修改。不过，他强调，涉及链上操作的那些层没有改动，因为这部分需要共识变更。主要改动如下：

  - Gossip（[BOLT7][]）：PQ 密钥直接通过 gossip 分发。`node_announcement` 消息携带节点的 ML-DSA 和 ML-KEM 公钥，以及 ML-DSA 签名；`channel_update` 消息则只携带签名。这些密钥会被固定（pinning），让节点可以拒绝任何试图替换它们的通告。作者指出，`channel_announcement` 消息没有修改，因为它的四个签名中有两个使用链上注资密钥生成，仍有一半签名可能被伪造。
  - 传输（[BOLT8][]）：Noise 握手改用混合方案，执行两次 ML-KEM 密钥封装。第一次针对已固定的静态密钥，另一次针对新的临时密钥，以提供前向保密。协议不进行带内协商，因为量子攻击者可以轻易伪造协商所涉及的消息。
  - 发票（[BOLT11][]）：发票中的一个带标签字段最多容纳 639 字节，因此大小为 2420 字节的 ML-DSA-44 签名必须拆到 4 个不同字段里。
  - 要约（[BOLT12][]）：由于[要约][topic offers]自带信任锚（anchor），节点会为每个要约承诺一个新的 ML-DSA 密钥。付款方会在发出任何 [HTLC][topic htlc] 之前，用该密钥检查发票。
  - 洋葱路由（[BOLT4][]）：ML-KEM 密文太大，放不进洋葱包，因此洋葱包的格式保持不变，而 Sphinx 秘密值改用混合方案。密文与洋葱包一起放在 `update_add_htlc` 消息中发送，使用一个包含 20 个槽位的列表。为防止节点推断路由长度，每个未使用的槽位都填入伪密文。

  按 Kurt 的说法，这次迁移的主要开销在于带宽：节点需要下载的数据量是普通闪电网络节点的 10 倍，存储的数据量则是 9 倍。计算开销反而不是问题，最耗时的操作 —— ML-DSA 签名 —— 也只需 0.33 ms。作者在 regtest 上测试了与传统节点的互操作性，结果良好：当支付路由中存在传统节点时，PQLN 节点会回退到传统协议；如果设置了 require-PQ 标志，则会在发送任何 HTLC 之前失败。

  最后，作者列出了一些尚未解决的问题：密钥固定只能保护那些在足以威胁所用密码算法的量子计算机出现之前就已相互接触的节点；rust-lightning 中 1,024 字节的 `MAX_EXCESS_BYTES_FOR_RELAY` 限制，使非 PQ 节点无法中继 PQ gossip；功能位和 TLV 类型的分配也尚未完成。

## Bitcoin Stack Exchange 精选问答

*[Bitcoin Stack Exchange][bitcoin.se] 是 Optech 贡献者们寻找问题答案时首先会去的地方之一；有闲暇时，他们也会在这里帮助好奇或困惑的用户。在这个每月栏目中，我们会重点介绍自上次更新以来发布的一些高票问题和答案。*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- **<!--what-would-be-a-drawback-if-sum-instead-of-sha256-of-amounts-was-used-in-the-taproot-signature-message-->** [在 taproot 签名消息中，用金额总和代替金额的 SHA256 哈希会有什么缺点？]({{bse}}130977)
  用户 1uba 解释说，在 [taproot][topic taproot] 签名哈希（sighash）中只承诺输入金额的总和，仍然能防止 [BIP341][] 提到的手续费多付攻击。不过，为签名设备准备交易的软件就可以在输入之间调换金额，只要总和不变就行。这会影响离线签名设备，也会影响协作交易，因为签名者需要核实自己输入的金额。

- **<!--post-bip110-fork-is-it-necessary-to-resync-from-block-0-->** [BIP110 分叉之后，是否需要从区块 0 开始重新同步？]({{bse}}131037)
  Murch 预计，一个执行了 BIP110 规则（见[周报 #418][news418 bip110]）并启用了修剪的 Bitcoin Knots 节点，仍然保存着两条链最后一个共同区块，因为在该节点最后一次运行之前，BIP110 链上新增的区块很少。将它换成 Bitcoin Core 应当就能正常工作；但如果节点没有自行重组，他建议对 BIP110 节点拒绝的第一个区块尝试执行 `reconsiderblock`。

- **<!--can-a-bitcoin-node-build-a-partial-utxo-set-from-only-the-most-recent-blocks-and-use-it-to-validate-new-transactions-->** [比特币节点能否只用最近的区块构建部分 UTXO 集，并用它验证新交易？]({{bse}}131051)
  Pieter Wuille 解释说，这样的节点无法判断一个缺失的输入究竟已经被花费，还是在它跳过的区块中创建的。由于它无法将任何交易判定为无效并拒绝，这套方案没有进行任何有用的验证，安全性等同于完全依赖工作量证明的 SPV。

## 版本和候选版本

_流行比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。_

- [Bitcoin Core 32.0rc2][] 是这一主流全节点实现下一个主版本的候选版本。已有一份[测试指南][bcc32 testing]可供参考。

- [Core Lightning 26.06.8][] 是这一流行闪电网络节点实现的安全版本，修复了按负责任披露流程报告的漏洞。源代码现在就可以获取，但少量测试暂未公开，以便在攻击者能轻易找出漏洞之前，给用户更多时间升级。运行过开发版本的节点无法降级到这个版本，因为它们使用的数据库结构版本更高。项目方强烈建议升级。

- [LDK v0.3-rc2][] 是这一用于构建支持闪电网络的钱包和应用的库下一个主版本的第二个候选版本。它为待处理的[拼接][topic splicing]增加了 [RBF][topic rbf] 手续费追加，并支持在同一次拼接中同时增加和移除资金。它现在还会默认协商[锚点通道][topic anchor outputs]，并要求应用显式接受入站通道。升级会让此前签发的、带有支付元数据的 [BOLT11][] 发票失效。开发者在测试之前应当查阅 [API 与向后兼容性方面的变更][ldk 0.3 notes]。

## 重大的代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #34566][] 增加了多 signet 数据目录支持（见[周报 #412][news412 netmagic]），让自定义 [signet][topic signet] 可以共用一个基础数据目录，而各自的链数据不会冲突。每个自定义 signet 都使用一个 `signet_XXXXXXXX` 子目录，后缀是从 signet 挑战派生出的四字节网络标识符。为避免升级后重新同步，已有自定义 signet 的用户应手动将其目录改名为新格式。

- [BIPs #1951][] 加入了 [BIP138][]，规定了一套用于钱包非种子数据的紧凑加密方案，例如备份[描述符][topic descriptors]和 [BIP388][] 钱包策略（见[周报 #351][news351 backup]）。加密密钥从描述符中符合条件的扩展公钥（xpub）的根公钥派生而来；备份中存有恢复数据，持有其中任一密钥的人都可以借此解密。一个共同签名者只用自己的种子，就能恢复多签描述符，而不需要其他共同签名者的密钥。由于解密只用到公钥材料，载荷中不能包含私钥。保密性的前提是 xpub 从未被披露。Ledger 和 Trezor 桌面应用这类单签钱包会将账户 xpub 发送给服务器；如果多签复用了这个 xpub，服务器就能解密该多签的每一份备份。因此，这份 BIP 建议使用 xpub 从未被分享过的账户来构建多签，例如 BIP48 或 BIP87 账户。

- [BIPs #2224][] 加入了 [BIP461][]，规定了一套统一的确定性 ECDSA 签名算法，确保给定的私钥和消息始终生成相同的签名。签名者用 RFC 6979 派生 nonce，再通过计数器反复尝试，直到 `r` 的编码不需要前导零字节，以生成 [low-r 签名][topic low-r grinding]，并将 `s` 规范化为低值形式。由于输出是确定的，密钥持有者可以将同一个密钥加载到两个独立的签名设备上，对同一条消息签名，再比较结果。任何差异都表明至少一个签名设备没有遵守规范，也可能说明它试图通过 nonce 的选择来[泄露密钥材料][topic exfiltration-resistant signing]，就像 Dark Skippy 攻击那样（见[周报 #315][news315 dark skippy]）。

- [Core Lightning #9507][] 补上了缺失的费率上下限，并修复了可能把极高的手续费估计值变成接近零的费率、或者让节点反复崩溃的溢出问题。此前，对等节点提出的[拼接][topic splicing]和针对[双向注资][topic dual funding]开通道的 [RBF][topic rbf] 尝试没有费率上限，而双向注资开通道本身则既没有下限检查，也没有上限检查。已存储的费率如果高到让下一次 RBF 费率计算溢出，或者存储的值为零，就会触发 `listpeerchannels` 中的断言。由于插件会在启动时调用它，节点每次重启都会崩溃。这个 PR 为对等节点的提议和后端的[手续费估算][topic fee estimation]加上了 4,000 sat/vB 的上限，即使启用了 `--ignore-fee-limits` 也不例外。它还将 CLN 自己提出的开通道、拼接、承诺更新和 RBF 的费率限制在 400 sat/vB，并在升级时修正已存储的超出范围的费率。

- [Core Lightning #9508][] 修复了[拼接][topic splicing]和开通道方面的若干问题。此前，在 CLN 收到对等节点的 `splice_locked` 之前，可能会漏掉对等节点为待处理拼接广播的承诺交易。现在，CLN 会监控每次待处理拼接的注资输出，并识别对它的花费。如果对等节点在 CLN 已经发出签名之后，对该拼接发送 `tx_abort`，CLN 现在也会正确地强制关闭通道。此前，检查逻辑没能识别已经签过名的拼接，表示签名已经发送的标志也未能跨重启保存。这让 CLN 接受了 `tx_abort`，却没有强制关闭。这个 PR 还会拒绝已有三场开通道协商正在进行的对等节点发起新的[双向注资][topic dual funding]开通道请求，计数时也包括单方注资的协商。超过这个上限，或者让通道静止超过十分钟的对等节点，会被断开连接。

- [Core Lightning #9509][] 修复了通道链上结算方面的若干问题。此前，如果一次强制关闭的所有输出都支付到已知的关闭脚本，CLN 就可能将其当作合作关闭。一个在开通道时没有预先承诺关闭脚本的对等节点，可以发送 `shutdown` 消息，把一笔旧的、已撤销承诺交易的输出脚本指定为自己的关闭脚本，随后中止合作关闭，再广播那笔承诺交易而不受惩罚。现在，CLN 会先根据锁定时间和序列号的编码识别承诺交易，再检查输出。如果一笔承诺交易仍处于已确认状态，但它受监控的后代交易遭到重组，这个 PR 会重启 `onchaind`，而不会让通道一直处于无人监控的状态，直到节点重启。当 CLN 在链上得知原像时，现在也会兑现对应的、尚未解决的入站 [HTLC][topic htlc]，即使对应出站 HTLC 的失败处理仍在等待中。其他修复还防止了与遭到重组的关闭输出，以及向未指定金额发票的备用地址进行链上支付有关的崩溃。

- [Core Lightning #9510][] 和 [#9511][core lightning #9511] 加强了输入解析和日志处理。第一个 PR 修复了一处缓冲区溢出：通过代理连接一个通告了很长 DNS 主机名的节点时，它可能让 `connectd` 崩溃。CLN 现在会在启动时拒绝自身配置中主机名无效的 `dns:` 地址，并忽略收到的节点通告中无效的 DNS 地址。它还将 JSON 的嵌套深度限制为 256 层，将 REST 请求体限制为 2 MiB，并修复了一个会让畸形消息导致 CLN 崩溃的 [BOLT12][topic offers] TLV 解析 bug。第二个 PR 修复了一处栈溢出：未经认证的 REST 请求如果包含一个极大的参数，就可能让节点崩溃。它还从 `getlog` 中移除了 I/O 日志，因为原始 RPC 和插件流量可能包含 rune（授予受限 RPC 访问权限的认证令牌）和其他秘密值。

- [Core Lightning #9513][] 修复了 `xpay` 获取 [BOLT12 要约][topic offers]发票时的金额验证。此前，它会直接使用取得的发票金额，却不检查是否与获授权的金额一致，从而让收款方能够要求更大金额的支付。现在，发票金额必须与请求的金额相同；如果没有提供金额，则不能超过要约金额。这个 PR 还防止节点因回复路径不含任何跳的[洋葱消息][topic onion messages]而停机；任何节点都可以发送这种消息。CLN 现在会将这样的路径当作不存在，并把其他无法解析的回复路径记入日志，而不再终止 `offers` 插件。

- [LND #11198][] 修复了一处 bug：[AMP][topic amp] 支付的原像重建失败，会导致整张发票被取消。一张可复用的 AMP 发票可以接受多组相互独立的支付，每组由若干 [HTLC][topic htlc] 组成。此前，一个无效的支付组可能取消整张发票，并干扰其他已接受的支付组，尽管原像重建失败只影响这一组。现在，LND 会让新到达的 HTLC 失败，并取消此前已接受、属于失败组的 HTLC。发票仍然可以继续支付，其他已接受的支付组也仍能完成并结算。

- [LND #11146][] 继续推进 [BOLT12 要约][topic offers]的实现，为要约、发票请求和发票增加了带验证的字符串编码器和解码器。这些编解码器在解析的同时，进行相应的网络、功能、到期时间和签名检查，建立在[周报 #422][news422 bolt12]介绍的签名支持之上。新的 `ValidateInvoiceForPayment` 函数还会根据最初的请求，以及付款方预期的签名节点来检查发票。只有有效签名并不足够：否则，[盲化路径][topic rv routing]上的一个节点就可能返回一张用自己密钥签名的发票。

- [LND #11132][] 恢复了对 [BOLT1][] 的遵守，会回复每一条通过其限流策略的有效 `ping`。此前，一个独立的 `pong` 限速器可能悄悄压掉本应发送的回复（见[周报 #421][news421 ping]）。LND 现在为每个对等节点使用一个令牌桶，容量为 200 个令牌，每秒补充 10 个。请求的回复越大，消耗的令牌越多；最大尺寸的回复消耗十个令牌，从而维持此前的带宽限制。耗尽预算会导致对等节点被断开连接。

{% include snippets/recap-ad.md when="2026-09-29 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="34566,1951,2224,9507,9508,9509,9510,9511,9513,11198,11146,11132" %}

[news418 bip110]: /zh/newsletters/2026/08/14/#bips-2225
[pqln del]: https://delvingbitcoin.org/t/pqln-post-quantum-security-for-the-bitcoin-lightning-networks-off-chain-surfaces/2893
[pqln paper]: https://arxiv.org/abs/2609.13781
[pqln repo]: https://github.com/ahmet-kurt/pq-rust-lightning
[news408 pq ln]: /zh/newsletters/2026/06/05/#postquantum-lightning-discussion
[Bitcoin Core 32.0rc2]: https://bitcoincore.org/bin/bitcoin-core-32.0/test.rc2/
[bcc32 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/32.0-Release-Candidate-Testing-Guide
[Core Lightning 26.06.8]: https://github.com/ElementsProject/lightning/releases/tag/v26.06.8
[LDK v0.3-rc2]: https://github.com/lightningdevkit/rust-lightning/tree/v0.3-rc2
[ldk 0.3 notes]: https://github.com/lightningdevkit/rust-lightning/blob/v0.3-rc2/CHANGELOG.md
[news412 netmagic]: /zh/newsletters/2026/07/03/#bitcoin-core-35610
[news351 backup]: /zh/newsletters/2025/04/25/#standardized-backup-for-wallet-descriptors
[news315 dark skippy]: /zh/newsletters/2024/08/09/#faster-seed-exfiltration-attack
[news422 bolt12]: /zh/newsletters/2026/09/11/#lnd-11061
[news421 ping]: /zh/newsletters/2026/09/04/#lnd-11090
