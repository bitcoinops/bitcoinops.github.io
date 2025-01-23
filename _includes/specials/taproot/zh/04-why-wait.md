{% capture /dev/null %}
<!-- 已在 regtest 上测试以下内容：
  - 根据 getblockchaininfo，Taproot 在 min_lockin_height 激活
  - nlocktime 为 x 的交易无法在高度 x-1 时发送，但可在高度 x 时发送

未测试：
  - 在 min_lockin_height 实际花费 P2TR 交易
-->

<!-- Taproot 规则生效前的最后一个区块 -->
{% assign ante_trb = "709,631" %}

<!-- 激活后保守的安全重组区块（+144 个区块） -->
{% assign safe_trb = "709,776" %}
{% endcapture %}
{% auto_anchor %}

本系列之前的文章鼓励钱包和服务开发者立即开始实施 [Taproot][topic taproot] 升级，以便在 Taproot 激活时准备就绪。但我们也警告不要在区块 {{site.trb}} 前生成任何 P2TR 地址，否则可能导致服务或用户资金损失。

不建议提前生成地址的原因是，在区块 {{site.trb}} 之前，任何发送至 P2TR 式输出的资金均可被*任何人*花费。这些资金将完全无安全保障。但从该区块开始，数千个全节点将开始强制执行 [BIP341][] 和 [BIP342][]（以及关联的 [BIP340][]）的规则。

如果区块链重组能被完全排除，那么在看到最后一个 Taproot 前区块（区块 {{ante_trb}}）后立即生成 P2TR 地址是安全的。但存在对区块链重组的担忧——不仅是意外重组，还包括蓄意制造以窃取早期 P2TR 支付的资金。

设想大量用户希望成为首批接收 P2TR 支付的人。他们在看到区块 {{ante_trb}} 后立即天真地向自己发送资金。[^timelocked-trb] 这些资金在区块 {{site.trb}} 中是安全的，但可能被创建替代 {{ante_trb}} 区块的矿工窃取。如果发送至 P2TR 输出的资金价值足够大，尝试挖两个区块而非一个可能变得更为有利可图（详见[手续费狙击][topic fee sniping]主题）。

因此，在重组风险有效消除前，我们不建议软件或服务生成 P2TR 地址。我们认为等待激活后 144 个区块（约一天）是较为保守的安全边际，可在最小化风险的同时避免显著延迟用户享受 Taproot 优势。

简言之：

- {{ante_trb}}: 最后一个允许任何人花费 P2TR 式输出资金的区块
- {{site.trb}}: 首个要求 P2TR 输出必须满足 [BIP341][] 和 [BIP342][] 规则才能被花费的区块
- {{safe_trb}}: 钱包可开始为用户提供 P2TR 输出的 [Bech32m][topic bech32] 接收地址的合理区块

以上均不影响本系列[首篇文章][taproot series 1]的建议——应尽快支持向 Bech32m 地址付款。若有人在您认为安全前请求向 P2TR 地址付款，风险由其自行承担。

[^timelocked-trb]:
    若用户希望在首个 Taproot 区块接收 P2TR 支付，应生成一个不与他人共享的地址，并创建 nLockTime 设为 {{ante_trb}} 的交易。该交易可在收到区块 {{ante_trb}} 后立即广播。nLockTime 将确保交易无法在 Taproot 规则生效的 {{site.trb}} 前被包含。若未充分理解新脚本类型和自定义锁定时间，此类操作可能存在风险，请谨慎处理。

[news139 st]: /zh/newsletters/2021/03/10/#taproot-activation-discussion
[taproot series 1]: /zh/preparing-for-taproot/#bech32m-发送支持
{% endauto_anchor %}
