{% auto_anchor %}
使用 Optech 的 [交易大小计算器][transaction size calculator]，我们可以比较不同类型单签名交易的大小。正如预期，使用 P2WPKH 输入和输出的交易远小于使用 P2PKH 输入和输出的交易——但或许令人惊讶的是，P2TR 交易比同等的 P2WPKH 交易略大。

|                    | P2PKH (legacy) | P2WPKH (segwit v0) | P2TR (taproot/segwit v1) |
|--------------------|----------------|--------------------|--------------------------|
| **Output**         | 34             | 31                 | 43                       |
| **Input**          | 148            | 68                 | 57.5                     |
| **2-in, 2-out tx** | 374            | 208.5              | 211.5                    |

这可能会让人觉得，为了迎接在区块 {{site.trb}} 激活的 taproot 而在单签名钱包中实现 taproot 花费是得不偿失的，但当我们进一步研究时会发现，对于钱包用户和整个网络而言，使用 P2TR 进行单签名仍然有许多好处。

- **<!--cheaper-to-spend-->****花费更便宜：** 与花费 P2WPKH UTXO 相比，花费单签名 P2TR UTXO 在输入层面上节约了大约 15% 的成本。上表这样过于简单的分析掩盖了一个细节，即花费者无法选择他们被要求支付的地址，所以如果你还停留在 P2WPKH，而其他人都升级到了 P2TR，那么你的 2 入、2 出交易的实际常见大小将会达到 232.5 vbytes——而全部使用 P2TR 的交易仍然只有 211.5 vbytes。

- **<!--privacy-->****隐私：** 虽然当早期采用者切换到新的脚本格式时会失去一些隐私，但用户切换到 taproot 也能立刻获得隐私增强。你的交易在链上可能与正在使用新 LN 通道、更高效的 [DLCs][topic dlc]、安全的[多签][topic multisignature]、各种巧妙的钱包备份恢复方案或其他上百种全新发展场景的人看起来毫无区别。

  现在就对单签名采用 P2TR 还能让你的钱包在之后升级到多签名、tapscript、LN 支持或其他功能时，不会影响你的现有用户的隐私。UTXO 是在你旧版或新版软件中接收的都无关紧要——这两种 UTXO 在链上看起来没有差别。

- **<!--more-convenient-for-hardware-signing-devices-->****更方便硬件签名设备：** 自从重新发现了[手续费超额支付攻击][news101 fee overpayment attack]以来，一些硬件签名设备在没有为该交易输入的每个 UTXO 提供元数据（包含创建该 UTXO 的完整交易中重要部分的副本）的情况下，拒绝为交易签名。这样会极大增加硬件签名器需要执行的最糟糕情况处理量，对主要通过尺寸有限的二维码进行交互的硬件签名器来说尤其棘手。taproot 消除了导致手续费超额支付攻击的漏洞，从而能够显著提高硬件签名器的性能。

- **<!--more-predictable-feerates-->****更可预测的费率：** 适用于 P2PKH 和 P2WPKH UTXO 的 ECDSA 签名大小具有灵活性（参见 [Newsletter #3][news3 sig size]）。由于钱包需要在创建签名前先决定交易的费率，大多数钱包只是默认假设最糟糕的签名大小，并接受在实际生成更小签名时稍微超额支付费率。对于 P2TR，则可以预先明确签名的确切大小，钱包就能可靠地选择精准的费率。

- **<!--help-full-nodes-->****帮助全节点：** 比特币系统的整体安全性依赖于有相当比例的比特币用户使用自己的节点验证所有已确认的交易，包括验证你的钱包所创建的交易。taproot 的 [schnorr 签名][topic schnorr signatures]可以被高效地批量验证，在节点赶上之前区块的过程中，[CPU 耗时大约可以减少一半][batch graph]。即使你对上面提到的其他优势都不感兴趣，也可以考虑为了那些运行全节点的人而做好使用 taproot 的准备。

[transaction size calculator]: /en/tools/calc-size/
[news3 sig size]: /zh/newsletters/2018/07/10/#unrelayable-transactions
[news101 fee overpayment attack]: /zh/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[batch graph]: https://github.com/jonasnick/secp256k1/blob/schnorrsig-batch-verify/doc/speedup-batch.md
{% endauto_anchor %}
