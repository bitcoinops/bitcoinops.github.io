{% auto_anchor %}
你的用户和客户希望你实现 Bech32 发送支持的一个原因是它将允许那些支付接收者在重新花费这些钱时节省费用。本周，我们将看看他们能节省多少钱，并讨论他们的节省如何也能帮助你省钱。

对于在第一个版本的 Bitcoin 中实现的传统 P2PKH 地址格式，授权支出的 scriptSig 通常为 107 vbytes。对于 P2SH 包装的 segwit P2WPKH，相同的信息被移动到一个见证数据字段，该字段仅消耗四分之一的 vbytes（27 vbytes），但其 P2SH 开销增加了 23 vbytes，总共 50 vbytes。对于原生 segwit P2WPKH，没有 P2SH 开销，因此仅使用 27 vbytes。

这意味着你可以说 P2SH-P2WPKH 比 P2PKH 节省了超过 50%，而 P2WPKH 比 P2SH-P2WPKH 再节省几乎 50%，或者比 P2PKH 单独节省 75%。然而，支出交易不仅包含 scriptSigs 和见证数据，所以我们通常比较节省的方法是看原型交易。例如，我们想象一个典型的交易，包含一个输入和两个输出（一个给接收者；一个作为找零返回给支出者）。在这种情况下：

- 支出 P2PKH 的总交易大小为 220 vbytes
- 支出 P2SH-P2WPKH 的大小为 167 vbytes（节省 24%）
- 支出 P2WPKH 输出的大小为 141 vbytes（比 P2SH-P2WPKH 节省 16% 或比 P2PKH 节省 35%）

要比较简单的 multisig 交易（那些只使用单个 `OP_CHECKMULTSIG` 操作码的交易），事情会变得更复杂，因为 k-of-n multisig 输入的大小取决于签名的数量（k）和公钥的数量（n）。所以，为了简单起见，我们只会绘制传统 P2SH-multisig 与包装 P2SH-P2WSH multisig（最多支持 15-of-15 的传统 P2SH）的大小。我们可以看到，切换到 P2SH-P2WSH 可以节省大约 40%（1-of-2 multisig）到大约 70%（15-of-15）。

![多重签名交易大小图（P2SH 和 P2SH-P2WSH）](/img/posts/2019-04-segwit-multisig-size-p2sh-to-p2sh-p2wsh.png)

然后我们可以将 P2SH-P2WSH 与原生 P2WSH 比较，看到每个交易额外节省大约 35 字节或大约 5% 到 15%。

![多重签名交易大小图（P2SH-P2WSH 和 P2WSH）](/img/posts/2019-04-segwit-multisig-size-p2sh-p2wsh-to-p2wsh.png)

上述脚本描述了几乎所有未使用原生 segwit 地址的脚本。（使用更复杂脚本的用户，例如在闪电网络中使用的脚本，今天大多使用原生 segwit。）这些效率较低的脚本类型目前消耗了区块容量（总区块权重）的主要部分。切换到原生 segwit 以减少交易的权重，可以在不改变确认时间的情况下，以相同比例降低费用——其他所有条件相同。

但是其他所有条件并不相同。由于交易使用较少的区块权重，其他交易有更多的权重可用。如果可用区块权重的供应增加，而需求保持不变，我们预计价格会下降（除非它们已经达到默认的最低中继费用）。这意味着更多使用原生 segwit 输入的人不仅降低了那些支出者的费用，也降低了所有创建交易的人的费用——包括支持发送到 Bech32 地址的钱包和服务。
{% endauto_anchor %}
