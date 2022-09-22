---
title: 'Bitcoin Optech Newsletter #217'
permalink: /zh/newsletters/2022/09/14/
name: 2022-09-14-newsletter-zh
slug: 2022-09-14-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---

本周的周报包括我们的常规部分：Bitcoin Core PR 审核俱乐部会议的总结、软件的新版本和候选版本，以及热门比特币基础设施软件的重大变更。

## 新闻

*本周无重大新闻*。

## Bitcoin Core PR 审核俱乐部

*在这个每月一次的栏目中，我们会总结最新一期 [Bitcoin Core PR 审核俱乐部][] 会议的内容，标注出重要的问题和答案。点击下文的问题描述，可看到会议对该问题的答案总结。*

“[减少初次区块同步期间发现区块后的带宽开销][review club 25720]” 是由 Suhas Daftuar 发起的一个 PR，可以减少节点在跟对等节点同步区块链（包括初次区块同步）时的带宽要求。比特币文化的一个重要部分就是最小化运行全验证节点的资源要求（也包括网络要求），以鼓励更多用户运行全节点。加速同步时间也是目标之一。

区块链的同步可以分成两个阶段：第一阶段，节点接收来自对等节点的区块头，这些区块头（大概率）足以确定 “最好的链（拥有最多工作量证明的链）”；第二阶段，节点使用最优链的区块头来请求和下载对应的完整区块。这个 PR 只影响第一个阶段（下载区块头的阶段）。

{% include functions/details-list.md
  q0="为什么大部分节点在初次区块同步时接收的都是 ` inv ` 区块消息，即使他们明明表示偏爱区块头消息（[BIP 130][]）？"
  a0="仅当一个节点跟自己的对等节点分享过区块头，对等节点才会使用区块头消息，向其宣布与分享过的区块头有关的新区块。而同步中的节点不会发送区块头。"
  a0link="https://bitcoincore.reviews/25720#l-30"

  q1="为什么（在初次区块同步中）添加使用 ` inv ` 区块消息向我们宣布新区块的对等节点作为区块头同步对等节点，会浪费带宽呢？"
  a1="这样的对等节点接下来会给我们发送重复的区块头数据流： ` inv ` 消息会触发一个发给相同对等节点的 ` getheaders ` 请求，而返回的 ` headers ` （区块头）又会立即触发另一次 ` getheaders ` 请求，请求接下来一连串的区块头。接收重复的区块头没有害处，但会消耗额外的带宽。"
  a1link="https://bitcoincore.reviews/25720#l-62"

  q2="你估计被浪费掉的带宽是多少（上限和下限）？"
  a2="上限是（以字节计）： `(对等节点的数量 - 1) * 区块数量 * 81`；下限是 0（如果在区块头同步期间完全没有收到任何新区块，就是 0；即使同步节点和网络都很好，下载全部 70 多万个区块头也需要花好几分钟时间。"
  a2link="https://bitcoincore.reviews/25720#l-79"

  q3="CNodeState 的部分 `fSyncStarted` 和
  `m_headers_sync_timeout` 以及 `PeerManagerImpl::nSyncStarted`有什么作用 `nSyncStarted` 并设置 `fSyncStarted = true` 然后更新 `m_headers_sync_timeout`？"
  a3="`nSyncStarted` 统计将 `fSyncStarted` 设为真值的对等节点的数量，而且，在节点的区块头逼近当前（一天内）的链顶端之前，这个数值不能大于 1。这个（任意的）对等节点将成为我们的初次区块头同步的对等节点。如果这个对等节点很慢，节点会根据 ` m_headers_sync_timeout ` 将它超时，然后寻找另一个 “初次” 区块头同步对等节点。但是，如果在区块头同步期间，某个对等节点发送 ` inv ` 消息来宣布新区块，如果不使用这个 PR，则节点将同时跟这个节点请求区块头，而 *不会* 设置 ` fSyncStarted ` 标签。这就是冗余区块头消息的根源，而且可能并不是有意设计的，只不过有个好处就是在初次区块头同步节点带有恶意、崩溃或者非常慢时，依然能继续同步区块头。有了这个 PR，节点将只跟额外的 *一个* 对等节点请求区块头（而不是跟所有宣布了新区块的对等节点请求区块头）。"
  a3link="https://bitcoincore.reviews/25720#l-102"

  q4="相对于本 PR 所采取的办法，另一种办法是在超时（无论固定时间还是随机）后添加一个额外的区块头同步对等节点。那么，与这种替代方法相比，本 PR 有何优势呢？"
  a4="其中一个好处是，使用 ` inv ` 向你宣布新区块的节点有更高的概率会响应你的请求。另一种好处是，最先成功使用  ` inv ` 向你宣布新区块的节点通常也是一个非常快的对等节点。所以，在发现第一个对等节点网速较慢之后，我们不会再选另一个比较慢的对等节点。"
  q4link="https://bitcoincore.reviews/25720#l-135"
%}

## 新版本和候选版本

*热门比特币基础设施项目的新版本和候选版本。请考虑更新到新版本或帮助测试候选版本。*

- [LDK 0.0.111][] 加入了对创建、接收和转发[洋葱消息][onion messages]的支持，以及多个新特性和漏洞修复。

## 重大代码和文献变更

*本周出现重大变更的有：[Bitcoin Core][Bitcoin Core]、[Core Lightning][Core Lightning]、[Eclair][Eclair]、[LDK][LDK]、[LND][LND]、[libsecp256k1][libsecp256k1]、[硬件钱包接口（HWI）][Hardware Wallet Interface (HWI)]、[Rust Bitcoin][Rust Bitcoin]、[BTCPay Server][BTCPay Server]、[BDK][BDK] 和 [Lightning BOLTs][Lightning BOLTs]*。

- [Bitcoin Core #25614][] 在 [Bitcoin Core #24464][] 基础上开发，允许按照特定的严重级别在 addrdb、addrman、banman、i2p、mempool、netbase、net、net_processing、timedata 和 torcontrol 中添加和跟踪日志。
- [Bitcoin Core #25768][] 修复了一个漏洞，该漏洞使得钱包模块并不总会重新广播未确认交易的子交易。Bitcoin Core 内置的钱包模块会定期尝试广播任何未确认的交易。这些未确认交易中，有些交易可能会花费另一些未确认的交易。Bitcoin Core 在将它们发送给另一个 Bitcoin Core 子系统之前会先打乱交易的顺序，但子系统预期会先收到未确认的父交易、再收到子交易（或者，更一般化地来说，希望先收到所有未确认的祖先交易，然后再收到后代交易）。当一个子交易先于父交易送达，它会在内部就被拒绝掉，而不是被广播出去。
- [Bitcoin Core #19602][] 加入了一个  ` migratewallet ` RPC 方法，可以将一个钱包转化为原生使用[描述符][descriptors]的形式。该方法对前 HD 钱包（在 [BIP32][] 存在和普及之前由 Bitcoin Core 创建的钱包）、HD 钱包和没有私钥的观察钱包都适用。在调用这个函数以前，请先阅读[相关文档][managing wallets]，并注意，非描述符钱包和原生支持描述符的钱包之间有一些 API 差异。
- [Eclair #2406][] 添加了一个用于配置实验性的[交互式注资协议][interactive funding protocol]实现的选项，以要求通道开启交易仅包含 *已确认的输入* —— 也就是花费已确认交易的输出的输入。如果启用了这个选项，它可以防止通道启动者通过使用低手续费的大面额未确认交易来推迟通道开启。、
- [Eclair #2190][] 移除了对最初的定长洋葱数据格式的支持；该格式也被 [BOLTs #962][] 提议从闪电网络规范中移除。升级后的变长格式在三年前就已经[添加到了规范中][added to the specification]，而 BOLTs #962 PR 中提到的扫描结果显示，在超过 17000 个公开节点中，只有 5 个不支持变长格式。Core Lightning 也在今年早些时候移除了这种格式（见[周报 #193][news193 cln5058]）。
- [Rust Bitcoin #1196][] 修改了此前加入的 ` LockTime ` 类型（见[周报 #211][news211 rb994]），成为 ` absolute::LockTime ` 类型，并加入了一种新的 ` relative::LockTime ` ，来表示对应于 [BIP68][] 和 [BIP112][] 的时间锁。

{% include references.md %}
{% include linkers/issues.md v=2 issues="25614,24464,25768,19602,2406,2190,962,619,1196" %}

[managing wallets]: https://github.com/bitcoin/bitcoin/blob/master/doc/managing-wallets.md
[news193 cln5058]: /en/newsletters/2022/03/30/#c-lightning-5058
[news211 rb994]: /zh/newsletters/2022/08/03/#rust-bitcoin-994
[ldk 0.0.111]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.111
[review club 25720]: https://bitcoincore.reviews/25720
[BIP 130]: https://github.com/bitcoin/bips/blob/master/bip-0130.mediawiki


[onion messages]: https://bitcoinops.org/en/topics/onion-messages/
[Bitcoin Core]: https://github.com/bitcoin/bitcoin
[Core Lightning]: https://github.com/ElementsProject/lightning
[Eclair]: https://github.com/ACINQ/eclair
[LDK]: https://github.com/lightningdevkit/rust-lightning
[LND]: https://github.com/lightningnetwork/lnd/
[libsecp256k1]: https://github.com/bitcoin-core/secp256k1
[Hardware Wallet Interface (HWI)]: https://github.com/bitcoin-core/HWI
[Rust Bitcoin]: https://github.com/rust-bitcoin/rust-bitcoin
[BTCPay Server]: https://github.com/btcpayserver/btcpayserver/
[BDK]: https://github.com/bitcoindevkit/bdk
[Bitcoin Improvement Proposals (BIPs)]: https://github.com/bitcoin/bips/
[Lightning BOLTs]: https://github.com/lightning/bolts
[descriptors]: https://bitcoinops.org/en/topics/output-script-descriptors/
[interactive funding protocol]: https://bitcoinops.org/en/topics/dual-funding/
[added to the specification]: https://github.com/lightning/bolts/issues/619
