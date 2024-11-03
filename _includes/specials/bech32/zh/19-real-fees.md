截至本文撰写时，比特币的价格在过去几个月中已迅速上涨。比特币价格的显著变化在 Bech32 的上下文中是值得注意的，因为交易费用是以比特币计价，而非美元计价。这意味着，即使费率保持不变，发送交易的实际成本也会随着比特币价格的上涨而增加。

我们之前讨论过[用户和服务通过切换到原生 Segwit (Bech32) 地址可以节省多少][bech32 savings segment]，但我们仅从虚拟字节（vbyte）和百分比节省的角度进行描述。在本节 Bech32 发送支持中，我们将以实际价值来探讨节省的情况。

最低的实用费用为 0.00000001 BTC/vbyte。到目前为止，最高的典型费用是在 2017 年 12 月和 2018 年 1 月达到的 0.00001000 BTC/vbyte。对于该范围，以下图表显示了两个常见交易模板（单签名和 2-of-3 多重签名）的用户可能节省的金额：

![单签名传统 P2PKH 与 Segwit P2WPKH 的对比](/img/posts/2019-07-real-cost-p2pkh-p2wpkh.png)

![2-of-3 多重签名传统 P2SH 与 Segwit P2WSH 的对比](/img/posts/2019-07-real-cost-p2sh-p2wsh.png)

对于使用其他交易模板的传统交易用户，您可以通过将您发送的典型交易的 txid 粘贴到诸如 Esplora 区块浏览器（如 [Blockstream.info][]）之类的信息网站中，粗略了解您将节省的百分比。您可以将该百分比乘以交易的虚拟字节大小，查看您将节省多少虚拟字节。请注意，使用第三方服务会暴露您对该交易的兴趣，可能会显著降低您的隐私。您可以通过检查您的一笔典型交易来私下获取大致的虚拟字节节省量。[^measure-scriptsigs] 当您知道将节省多少虚拟字节时，您可以通过将节省的虚拟字节数乘以您的预期费率（以 BTC/vbyte 计）和您预期的比特币价格，计算出以另一种货币计的节省金额，例如 `saved_vbytes * feerate * price`。

如果原生 Segwit 的用户每笔交易开始节省几十到几百美元，我们预计将对高频支出者（如交易所）产生更大的竞争压力，促使他们迁移到只接受使用 Bech32 地址的存款。鉴于每日比特币交易中有很大比例是存款到交易所，我们预计不提供 Bech32 发送支持的钱包和服务将很快失去用户的青睐。

[bech32 savings segment]: /zh/bech32-sending-support/#使用原生-segwit-节省费用
[transactionfee.info]: https://transactionfee.info/
[blockstream.info]: https://blockstream.info/

[^measure-scriptsigs]:
  1. 使用工具解析交易。Bitcoin Core 附带了一个名为 `bitcoin-tx` 的工具可以为您完成此操作。运行 `bitcoin-tx -json <hex_serialized_tx>`。

  2. 汇总所有 scriptSig 的总大小。`bitcoin-tx` 输出每个 scriptSig 的十六进制表示，将此十六进制字符串长度减半即可得出 scriptSig 的大小。

  3. 将 scriptSig 的大小乘以 0.75 即可得到节省的虚拟字节数。
