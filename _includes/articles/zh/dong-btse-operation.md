{:.post-meta}
*by [Carl Dong](https://twitter.com/carl_dong)<br>Optech 工程师*

[BTSE](https://www.btse.com/en/home) 使用 Segwit、BIP32 分层确定性（HD）钱包和多重签名密钥管理来减少运营负担并提高资金安全性。在本次 Optech 实地报告中，我们采访了 BTSE 的员工，了解这些比特币技术如何为其交易所运营带来收益。

BIP32 是一个被广泛实施的[标准][BIP32]，它描述了如何[从一个扩展公钥](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#Unsecure_money_receiver_NmisubHsub0)确定性地派生任意多个新的公钥，即使相应的私钥保持离线状态。如果没有 BIP32，安全存储私钥的负担将促使重复使用公钥和地址，从而导致[问题](https://en.bitcoin.it/wiki/Address_reuse)，包括交易所的抢先交易以及用户隐私的丧失。谈到用户冷钱包存款的运营优势时，BTSE 的首席执行官 Jonathan Leong 提到，“如果热钱包的密钥被泄露，所有用户的地址都必须重新生成，并且不可避免地会有一些用户继续向他们的旧地址发送资金。”

尽管使用 BIP32 的交易所可以将其私钥保持离线，但该私钥仍是一个单点故障的风险。幸运的是，通过使用 k-of-n 多重签名地址（每个 n 公钥均来自不同的扩展公钥派生），交易所可以减轻单一密钥被泄露的影响。BTSE 通过这种组合实现了无需接触私钥即可动态生成任意数量的地址，这些地址直接存入多重签名的冷钱包。

除了 BIP32 和多重签名，BTSE 还使用 [P2SH-P2WSH](https://bitcoincore.org/en/segwit_wallet_dev/#complex-script-support)（P2SH 包裹的 Segwit）作为他们的存款地址。Segwit 允许 BTSE 通过减少交易的权重来降低交易费用，例如将资金转移到热钱包或 UTXO 合并时。作为一个例子，从 P2SH-P2WSH 的 2-of-3 多重签名地址花费资金比从传统的 P2SH 地址花费[节省 44% 的费用](https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#P2SH-wrapped_segwit)。随着向原生 Segwit P2WSH 地址的发送支持逐步增加（可在 Optech 的[兼容性矩阵][compatibility matrix]中追踪），企业也应考虑使用这些地址来进行存款，以解锁额外 14% 的节省并为他们的多重签名脚本提高安全性（256 位而非 160 位）。您可以在我们的 [Bech32 发送支持系列][bech32 series]中了解采用速度、地址安全性及更多内容。

Segwit、BIP32 和多重签名相互协作，帮助 BTSE 在运营一个安全、易用且低费用的交易所时减少负担。Optech 鼓励新的交易所在设计基础设施时考虑这些技术。对于现有的交易所，正如之前的实地报告所提到的，考虑采用这些技术并减少技术债务的好时机是在您进行 UTXO 合并时。

{% include references.md %}
[bech32 series]: /zh/bech32-sending-support/