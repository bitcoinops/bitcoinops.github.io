---
title: 'Bitcoin Optech 周报 #413'
permalink: /zh/newsletters/2026/07/10/
name: 2026-07-10-newsletter-zh
slug: 2026-07-10-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周周报介绍了一项研究：使用 fountain code 让已剪枝节点也能参与初始区块下载（IBD）。此外还包括我们的常规栏目：宣布新版本与候选版本，并总结流行比特币基础设施软件的重要代码变更。

## 新闻

- **<!--using-fountain-codes-for-ibd-->****使用 fountain code 实现 IBD：** Lucas Lima 在 Delving Bitcoin 上[发帖][fount del]，介绍他最新的研究：使用 [fountain code][fount wiki]，让已剪枝节点也能为初始区块下载（IBD）提供帮助，同时不会显著增加它们的存储需求。

  Lima 还专门写了一篇[博文][fount blog]，解释这一方案如何实现：将整条区块链划分为多个 epoch，每个 epoch 都是由 `k` 个区块组成的定长分块；再用 fountain code 对这些 epoch 编码，并把得到的编码结果（称为 droplets）连同区块头一起发送给那些需要重建区块链的节点。
  接收节点（文中称为 bucket node）需要收集并解码某个 epoch 的足够多 droplets，才能重建出这 `k` 个区块。随后再用区块头验证收到的数据是否有效，从而防止恶意节点污染重建出的区块链。

  讨论中也提出了一些关键问题。尤其是，开发者强调：要成功重建区块链，节点需要连接大量对等节点；IBD 速度会更慢；存在节点指纹识别风险；而且还可能扩大 DoS 攻击面。

## 版本和候选版本

_流行比特币基础设施项目的新版本和候选版本。请考虑升级到新版本，或帮助测试候选版本。_

- [Bitcoin Core 31.1][] 是这一主流全节点实现的维护版本。它修复了 `-privatebroadcast` 中的一个 IP 地址泄漏问题；该问题可能削弱[交易来源隐私][topic transaction origin privacy]（见[周报 #409][news409 privatebroadcast]）。它还修复了 chainstate 数据库压缩、钱包迁移、输入大小估算、[MuSig2][topic musig] 密钥聚合，以及在 [v2 P2P 传输][topic v2 p2p transport]重新连接期间的代理处理等问题。详见其[发布说明][bcc31.1 rn]。

- [LND v0.20.2-beta][] 是这一流行 LN 节点实现的维护版本。它修复了 DNS 回退时的 panic，以及一个链上 forward-interceptor 结算漏洞，并加入了上周介绍过的、针对最终一跳 [HTLC][topic htlc] 的 CLTV 到期高度验证（见[周报 #412][news412 cltv]）。

## 重大的代码和文档变更

_以下是来自 [Bitcoin Core][bitcoin core repo]、[Core Lightning][core lightning repo]、[Eclair][eclair repo]、[LDK][ldk repo]、[LND][lnd repo]、[libsecp256k1][libsecp256k1 repo]、[硬件钱包接口（HWI）][hwi repo]、[Rust Bitcoin][rust bitcoin repo]、[BTCPay Server][btcpay server repo]、[BDK][bdk repo]、[比特币改进提案（BIPs）][bips repo]、[Lightning BOLTs][bolts repo]、[Lightning BLIPs][blips repo]、[Bitcoin Inquisition][bitcoin inquisition repo] 和 [BINANAs][binana repo] 的近期重大变更。_

- [Bitcoin Core #32489][] 增加了一个 `exportwatchonlywallet` RPC，用来把当前已加载钱包导出为一个仅供观察的钱包文件；该文件可在另一台节点上通过 `restorewallet` RPC 加载（见[周报 #366][news366 watchonly]）。导出的钱包包含原钱包的公开[描述符][topic descriptors]、交易记录、标签和其他元数据，但不包含私钥。此前，用户必须通过导入公开描述符的方式手动构造这样的钱包。

- [Bitcoin Core #32606][] 更新了[致密区块中继][topic compact block relay]逻辑：如果某个对等节点没有通过 `sendcmpct` 协商支持、没有被本节点选为使用 `sendcmpct(1)` 接收高带宽区块公告的对等节点，或者本地节点运行在 `-blocksonly` 模式下，那么来自该对等节点的致密区块消息都会被忽略。由于致密区块需要使用接收方交易池中的交易来重建，处理这些消息会泄露接收方缺少哪些交易、或者已经拥有哪些交易。对仅区块模式的节点来说，这一点尤其不理想，因为它们交易池中的交易更可能源自本地。

- [Bitcoin Core #34020][] 为 Mining IPC 接口增加了 `getTransactionsByTxID()` 和 `getTransactionsByWitnessID()` 两个方法（见[周报 #310][news310 mining]和[周报 #323][news323 mining]）。每个方法都接收一组 txid 或 wtxid，并返回节点交易池中对应的序列化交易；对于节点并不了解的交易，则返回空元素。这对 [Stratum v2][topic pooled mining] 的自定义作业声明很有用：矿池可能只想从矿工提出的区块模板中，请求那些自己尚未持有的交易。

- [Core Lightning #9104][] 和 [#9292][core lightning #9292] 为 `option_simple_close` 合作关闭协议加入了实验性支持（见[周报 #342][news342 simpleclose]）。传统的合作关闭要求双方就唯一一笔关闭交易及其手续费达成一致；如果双方意见不合，关闭流程就可能卡住。simple close 通过允许每一方各自提出一笔有效的关闭交易来避免这个问题，并由各自从自己的输出中扣除自己选择的手续费。双方版本的交易都可以被签名并广播，而最先确认的那笔冲突交易会关闭该通道。CLN 在新的 `simpleclosed` 子守护进程中实现了这一流程；如果对方版本支付的手续费更高，它会延迟广播自己的版本。[#9292][core lightning #9292] 修复了一个边缘情形：此前，如果一笔已签名的 simple-close 交易把关闭方不合算的输出替换成一个被允许的零值 `OP_RETURN`，CLN 会拒绝该交易，从而导致强制关闭。

- [Eclair #3323][] 会使那些 CLTV 到期高度距离当前超过 2016 个区块（约两周）的入站 [HTLC][topic htlc] 失败。这将 Eclair 现有的、针对出站 HTLC 的最大到期高度策略扩展到了入站 HTLC，可降低资金长期锁定的风险，并让[通道阻塞攻击][topic channel jamming attacks]更难奏效。Eclair 会先临时接收这类违规 HTLC 进入通道承诺交易，然后再让它失败，因为如果直接拒绝，就会导致强制关闭通道。

- [LND #10832][] 延续了 LND 对 [BOLT12 要约][topic offers]的实现，为 `InvoiceRequest` 消息增加支持（见[周报 #410][news410 bolt12]）。新代码增加了 TLV 编码、解码和结构校验，同时将签名验证以及与对应要约的交叉检查，留待后续 PR 完成。

{% include snippets/recap-ad.md when="2026-07-14 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32489,32606,34020,9104,9292,3323,10832" %}
[fount del]: https://delvingbitcoin.org/t/fountain-codes-a-way-to-reduce-blockchain-storage-costs/2624
[fount wiki]: https://en.wikipedia.org/wiki/Fountain_code
[fount blog]: https://lucasdbr05.com/posts/fountain-codes/
[Bitcoin Core 31.1]: https://bitcoincore.org/bin/bitcoin-core-31.1/
[bcc31.1 rn]: https://bitcoincore.org/en/releases/31.1/
[LND v0.20.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.2-beta
[news366 watchonly]: /zh/newsletters/2025/08/08/#bitcoin-core-pr-审核俱乐部
[news310 mining]: /zh/newsletters/2024/07/05/#bitcoin-core-30200
[news323 mining]: /zh/newsletters/2024/10/04/#bitcoin-core-30510
[news342 simpleclose]: /zh/newsletters/2025/02/21/#bolts-1205
[news410 bolt12]: /zh/newsletters/2026/06/19/#lnd-10789
[news409 privatebroadcast]: /zh/newsletters/2026/06/12/#bitcoin-core-35410
[news412 cltv]: /zh/newsletters/2026/07/03/#lnd-10927
