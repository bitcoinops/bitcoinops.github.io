---
title: "使用 Bitcoin Core 28.0 策略的钱包集成指南"
permalink: /zh/bitcoin-core-28-wallet-integration-guide/
name: 2024-10-10-bitcoin-core-28-wallet-integration-guide-zh
type: posts
layout: post
lang: zh
slug: 2024-10-10-bitcoin-core-28-wallet-integration-guide-zh

excerpt: >
  Bitcoin Core 28.0 包含了一些 P2P 和交易池策略的新特性。这些特性可能对许多钱包和交易类型有用。Gregory Sanders 在本文中提供了一个概要性的功能集指南，介绍了如何单独或组合使用这些特性。

---

{:.post-meta}
*作者：[Gregory Sanders][]*

[Bitcoin Core 28.0][bc 28.0] 包含了一些 P2P 和交易池策略的新特性。这些特性可能对许多钱包和交易类型有用。Gregory Sanders 在本文中提供了一个概要性的功能集指南，介绍了如何单独或组合使用这些特性。

## 一父一子交易（1P1C）中继

在 Bitcoin Core 28.0 之前，每笔交易都必须达到或超过本地节点的动态交易池最低费率，才能进入其交易池。这个值随着交易拥堵而上下波动，为支付的传播创建了一个不断变化的底价。这给处理无法签署[替代交易][topic rbf]的预签名交易的钱包带来了极大的困难，因为它们必须预测未来结算交易时的底价。预测几分钟后就已经是够困难的了，几个月显然更不可能。

[包中继][topic package relay]一直是全网所期待的功能，可缓解交易无法追加费用而导致卡住的风险。只要开发正确并广泛部署到网络上，包中继将允许钱包开发人员通过相关交易为交易带来费用，从而允许低费用的祖先交易进入交易池。

在 Bitcoin Core 28.0 中，实现了包中继的一种有限变体，用于包含1个父交易和1个子交易（“1P1C”）。1P1C 允许单个父交易进入交易池，无视动态交易池最低费率，使用单个子交易和简单的[子为父偿（CPFP）][topic cpfp]费用增加。如果子交易有额外的未确认父交易，这些交易将无法成功传播。这种限制极大地简化了实现，同时还允许其他交易池可继续工作，如[族群交易池][topic cluster mempool]可针对大量用例继续运行而不受影响。

除非交易是 [TRUC 交易][topic v3 transaction relay]（稍后描述），否则每笔交易仍必须满足*静态*每虚拟字节 1 聪的最低费用。

该功能的最后一个注意事项是，该版本的传播保证也是有限的。如果 Bitcoin Core 节点连接到了一个有足够决心的对手方，他们仍可以阻止父子交易对的传播。包中继的额外加固工作将继续作为一个[项目][package relay tracking issue]进行。

通用包中继仍然是未来的一项工作，将基于有限包中继及其在网络上的推出数据来进行。

以下是在 regtest 环境中设置演示 1P1C 中继的钱包的命令：

```hack
bitcoin-cli -regtest createwallet test
{
  "name": "test"
}
```

```hack
# 获取自发送地址
bitcoin-cli -regtest -rpcwallet=test getnewaddress
bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3
```

```hack
# 创建低费用交易超过 "minrelay"
bitcoin-cli -regtest -rpcwallet=test -generate 101
{
[
...
]
}

bitcoin-cli -regtest -rpcwallet=test listunspent
[
  {
    "txid": "49ea7a01bcba744bd82ecea3e36c4ee9a994f010508a28a09df38f652e74643b",
    "vout": 0,
    ...
    "amount": 50.00000000,
    ...
  }
]

# 交易池最低费用和 minrelay 相同，为了更容易测试此功能，我们将使用 TRUC 交易允许 0 费用交易。
# 还启用了 fullrbf，这是 28.0 的默认设置。
bitcoin-cli -regtest getmempoolinfo
{
  "loaded": true,
  ...
  "mempoolminfee": 0.00001000,
  "minrelaytxfee": 0.00001000,
  ...
  "fullrbf": true,
}

# 从 v2 交易开始
bitcoin-cli -regtest createrawtransaction '[{"txid": "49ea7a01bcba744bd82ecea3e36c4ee9a994f010508a28a09df38f652e74643b", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "50.00000000"}]'

02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# 并将前导 02 替换为 03。03 是 TRUC 版本
03000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# 签名并发送
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 03000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000
{
  "hex": "030000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402200a82f2fd8aa5f32cdfd9540209ccfc36a95eea21518ede1c3787561c8fb7269702207a258e6f027ce156271879c38628ad9b3425b83c33d8cd95fb20dd3c567fdff70121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000",
  "complete": true
}

bitcoin-cli -regtest sendrawtransaction 030000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402200a82f2fd8aa5f32cdfd9540209ccfc36a95eea21518ede1c3787561c8fb7269702207a258e6f027ce156271879c38628ad9b3425b83c33d8cd95fb20dd3c567fdff70121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000

error code: -26
error message:
min relay fee not met, 0 < 110

# 我们需要包中继和 CPFP 使用单个输出
bitcoin-cli -regtest decoderawtransaction 030000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402200a82f2fd8aa5f32cdfd9540209ccfc36a95eea21518ede1c3787561c8fb7269702207a258e6f027ce156271879c38628ad9b3425b83c33d8cd95fb20dd3c567fdff70121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000

{
  "txid": "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de",
  "hash": "7d855ffbd8bc17892e28f3f326d0e4919d35c27a7370f5d9f9ce538e93a347cf",
  "version": 3,
  "size": 191,
  "vsize": 110,
  ...
  "vout": [
    ...
    "scriptPubKey": {
      "hex": "001400991cdadccdf30cb5a04663b0371cb433a095b4",
    ...
}

# 为 CPFP 费用留出聪
bitcoin-cli -regtest createrawtransaction '[{"txid": "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "49.99994375"}]'
0200000001de7615100656cdc2f8fd0217fbbae0d7c6cea020c7d9f64ada16d269db6491bf0000000000fdffffff0100ed94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# 签名 TRUC 变体并发送，作为 1P1C 包
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 0300000001de7615100656cdc2f8fd0217fbbae0d7c6cea020c7d9f64ada16d269db6491bf0000000000fdffffff0100ed94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000 '[{"txid": "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de", "vout": 0, "scriptPubKey": "001400991cdadccdf30cb5a04663b0371cb433a095b4", "amount": "50.00000000"}]'
{
  "hex": "03000000000101de7615100656cdc2f8fd0217fbbae0d7c6cea020c7d9f64ada16d269db6491bf0000000000fdffffff0100ed94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220685a6d76db97b2c27950f267b70d606f1864002ff6b4617cd2e29afd5ddfac83022037be8bb2ebe8194b4263f16a634e5c00a5f6c4eef0968d12994ed66dcf15b9ac0121020797cc343a24dfe49c7ee9b94bf3daaf15308d8c12e3f0f7e102b95ee55f939f00000000",
  "complete": true
}

bitcoin-cli -regtest -rpcwallet=test submitpackage '["030000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff01f90295000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402200a82f2fd8aa5f32cdfd9540209ccfc36a95eea21518ede1c3787561c8fb7269702207a258e6f027ce156271879c38628ad9b3425b83c33d8cd95fb20dd3c567fdff70121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000", "03000000000101de7615100656cdc2f8fd0217fbbae0d7c6cea020c7d9f64ada16d269db6491bf0000000000fdffffff0100ed94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220685a6d76db97b2c27950f267b70d606f1864002ff6b4617cd2e29afd5ddfac83022037be8bb2ebe8194b4263f16a634e5c00a5f6c4eef0968d12994ed66dcf15b9ac0121020797cc343a24dfe49c7ee9b94bf3daaf15308d8c12e3f0f7e102b95ee55f939f00000000"]'
{
  "package_msg": "success",
  "tx-results": {
    "7d855ffbd8bc17892e28f3f326d0e4919d35c27a7370f5d9f9ce538e93a347cf": {
      "txid": "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de",
      "vsize": 110,
      "fees": {
        "base": 0.00000000,
        "effective-feerate": 0.00025568,
        "effective-includes": [
          "7d855ffbd8bc17892e28f3f326d0e4919d35c27a7370f5d9f9ce538e93a347cf",
          "4333b3d2eea820373262c7ffb768028bc82f99f47839349722eb60c58cd65b55"
        ]
      }
    },
    "4333b3d2eea820373262c7ffb768028bc82f99f47839349722eb60c58cd65b55": {
      "txid": "6c2f4dec614c138703f33e6a5c215112bad4cf79593e9757105e09b09bf3e2de",
      "vsize": 110,
      "fees": {
        "base": 0.00005625,
        "effective-feerate": 0.00025568,
        "effective-includes": [
          "7d855ffbd8bc17892e28f3f326d0e4919d35c27a7370f5d9f9ce538e93a347cf",
          "4333b3d2eea820373262c7ffb768028bc82f99f47839349722eb60c58cd65b55"
        ]
      }
    }
  },
  "replaced-transactions": [
  ]
}
```

1P1C 包已以 25.568 sats/vB 的有效费率进入本地交易池，尽管父交易低于 minrelay 费率。成功！

## TRUC 交易

确认前拓扑受限（TRUC）交易，也称为 v3 交易，是一种新的、可选的[交易池策略][policy series]，旨在允许健壮的手续费替换（RBF）交易，同时减轻费用相关的交易[钉死][topic transaction pinning]以及交易包限制钉死。其核心理念是：**虽然许多功能无法适用于所有交易，但我们可以为有限拓扑内的包来实现这些功能**。TRUC 开创了一种方法，将这一更强大的策略集嵌入到拓扑限制之上。

简而言之，TRUC 交易是 nVersion 为 3 的交易，其单体交易的体积不得超过 10 kvB；如果作为某一笔 TRUC 交易的子交易，则不得超过 1 kvB。TRUC 交易不能花费非 TRUC 交易，反之亦然。所有 TRUC 交易都被视为选择加入 RBF，无论是否有 [BIP125][] 信号。如果另一个非冲突的 TRUC 子交易添加到父 TRUC 交易中，它将被视为与原始子交易的[冲突][topic kindred rbf]，并应用普通 RBF 解析规则，包括费率和总费用检查。

TRUC 交易也允许为 0 费用，前提是子交易足够增加整个包的费率。

这种受限的拓扑也非常适合 1P1C 中继范式，假设所有签名交易版本都是 TRUC，就不必担心交易对手怎么做。

TRUC 支付是可替换的，因此任何交易只要其输入的一部分不被交易者所拥有，就可以被双花。换句话说，接收零确认 TRUC 支付并不比接收非 TRUC 支付更安全。

## 1P1C 拓扑包 RBF

有时 1P1C 包的父交易与交易池中的父交易冲突。这可能发生在有多个预签名父交易版本的情况下。以前，新的父交易将仅考虑 RBF 的情况，而如果费用太低则会被丢弃。

使用 1P1C 拓扑包 RBF，新的子交易也将被包含在 RBF 检查中，允许钱包开发人员通过 P2P 网络强大地传输 1P1C 包，而不管它们的本地交易池中命中了哪些版本的冲突交易。

请注意，在当前版本中，所有冲突的交易都必须是单例本身或 1P1C 交易包，没有其他依赖项。否则，替换将被拒绝。任意数量的这种族群都可以冲突。由于族群交易池，此规则将在未来的版本中放宽。

继续我们运行的 1P1C 示例，我们将对现有的 1P1C 包执行包 RBF，这次使用非 TRUC 交易包：

```hack
# 父子 TRUC 对
bitcoin-cli -regtest getrawmempool
[
  "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de",
  "6c2f4dec614c138703f33e6a5c215112bad4cf79593e9757105e09b09bf3e2de"
]

# 使用新的 v2 1P1C 包来双花父交易
# 其中父交易费用高于 minrelay 但不足以对此包进行 RBF
bitcoin-cli -regtest createrawtransaction '[{"txid": "49ea7a01bcba744bd82ecea3e36c4ee9a994f010508a28a09df38f652e74643b", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "49.99999"}]'

02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# 签名并发送（失败）
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000
{
  "hex": "020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220488d98ad79495276bb4cdda4d7c62292043e185fa705d505c7dceef76c4b61d30220567243245416a9dd3b76f3d94bfd749e0915929226ba079ec918f6675cbfa3950121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000",
  "complete": true
}

bitcoin-cli -regtest sendrawtransaction 020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220488d98ad79495276bb4cdda4d7c62292043e185fa705d505c7dceef76c4b61d30220567243245416a9dd3b76f3d94bfd749e0915929226ba079ec918f6675cbfa3950121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000

error code: -26
error message:
insufficient fee, rejecting replacement f17146d87a029cb04777256fc0382c637a31b2375f3981df0fb498b9e44ceb59, less fees than conflicting txs; 0.00001 < 0.00005625

# 通过子交易为新包带来额外费用，以胜过旧包
bitcoin-cli -regtest createrawtransaction '[{"txid": "f17146d87a029cb04777256fc0382c637a31b2375f3981df0fb498b9e44ceb59", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "49.99234375"}]'

020000000159eb4ce4b998b40fdf81395f37b2317a632c38c06f257747b09c027ad84671f10000000000fdffffff01405489000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000

# 作为一个包来签名并发送
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 020000000159eb4ce4b998b40fdf81395f37b2317a632c38c06f257747b09c027ad84671f10000000000fdffffff01405489000000000016001400991cdadccdf30cb5a04663b0371cb433a095b400000000 '[{"txid": "f17146d87a029cb04777256fc0382c637a31b2375f3981df0fb498b9e44ceb59", "vout": 0, "scriptPubKey": "001400991cdadccdf30cb5a04663b0371cb433a095b4", "amount": "49.99999"}]'
{
  "hex": "0200000000010159eb4ce4b998b40fdf81395f37b2317a632c38c06f257747b09c027ad84671f10000000000fdffffff01405489000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402205d086fa617bdbf5a3df3a15cc9a927ad884c714d46d9ef6762ad2fa6a259740c022032c60b4fe5d533d990489c27dc3283d8b3999b97f6c12986ac8159b92cb6de820121020797cc343a24dfe49c7ee9b94bf3daaf15308d8c12e3f0f7e102b95ee55f939f00000000",
  "complete": true
}

bitcoin-cli -regtest -rpcwallet=test submitpackage '["020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff0111ff94000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4024730440220488d98ad79495276bb4cdda4d7c62292043e185fa705d505c7dceef76c4b61d30220567243245416a9dd3b76f3d94bfd749e0915929226ba079ec918f6675cbfa3950121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000", "0200000000010159eb4ce4b998b40fdf81395f37b2317a632c38c06f257747b09c027ad84671f10000000000fdffffff01405489000000000016001400991cdadccdf30cb5a04663b0371cb433a095b40247304402205d086fa617bdbf5a3df3a15cc9a927ad884c714d46d9ef6762ad2fa6a259740c022032c60b4fe5d533d990489c27dc3283d8b3999b97f6c12986ac8159b92cb6de820121020797cc343a24dfe49c7ee9b94bf3daaf15308d8c12e3f0f7e102b95ee55f939f00000000"]'
{
  "package_msg": "success",
  "tx-results": {
    "fe15d23f59537d12cddf510616397b639a7b91ba2f846c64533e847e53d7c313": {
      "txid": "f17146d87a029cb04777256fc0382c637a31b2375f3981df0fb498b9e44ceb59",
      "vsize": 110,
      "fees": {
        "base": 0.00001000,
        "effective-feerate": 0.03480113,
        "effective-includes": [
          "fe15d23f59537d12cddf510616397b639a7b91ba2f846c64533e847e53d7c313",
          "256cebd037963d77b2692cdc33ee36ee0b0944e6b9486a6aaad0792daa0f677c"
        ]
      }
    },
    "256cebd037963d77b2692cdc33ee36ee0b0944e6b9486a6aaad0792daa0f677c": {
      "txid": "858fe07b01bc7c1c1dda50ba16a33b164c0bc03d0eff8f9546558c088e087f60",
      "vsize": 110,
      "fees": {
        "base": 0.00764625,
        "effective-feerate": 0.03480113,
        "effective-includes": [
          "fe15d23f59537d12cddf510616397b639a7b91ba2f846c64533e847e53d7c313",
          "256cebd037963d77b2692cdc33ee36ee0b0944e6b9486a6aaad0792daa0f677c"
        ]
      }
    }
  },
  "replaced-transactions": [
    "bf9164db69d216da4af6d9c720a0cec6d7e0bafb1702fdf8c2cd5606101576de",
    "6c2f4dec614c138703f33e6a5c215112bad4cf79593e9757105e09b09bf3e2de"
  ]
}

```

## 支付给锚点（P2A）

[锚点][topic anchor outputs]的定义是被单独添加的输出，以允许子交易 CPFP 该交易。由于这些输出不是支付，它们的值接近“粉尘”聪，并会立即被花费。

添加了一种新的输出脚本类型，[支付给锚点（P2A）][topic ephemeral anchors]，可以实现锚点的“无密钥”优化版本。输出脚本是“OP_1 <4e73>”，不需要见证数据即可花费，这意味着与现有锚点输出相比有费用减少。它还允许任何人创建 CPFP 交易。

P2A 可以独立于 TRUC 交易或 1P1C 包使用。一笔有 P2A 输出但没有子交易的交易仍然可以广播，尽管该输出的花费金额太小。同样，包和 TRUC 交易不需要有 P2A 输出就可以使用新的费用追加功能。

此新输出类型的粉尘限制为 240 聪。低于此粉尘阈值的 P2A 输出即使它们在包中被花费也不会被传播，因为策略仍将完全强制执行[粉尘][topic uneconomical outputs]限制。虽然此提案最初与一次性粉尘相关联，但现在不再是这样。

示例 P2A 创建和花费：

```hack
# P2A 地址在 regtest 是 "bcrt1pfeesnyr2tx"，在主网是 "bc1pfeessrawgf"
bitcoin-cli -regtest getaddressinfo bcrt1pfeesnyr2tx
{
  "address": "bcrt1pfeesnyr2tx",
  "scriptPubKey": "51024e73",
  "ismine": false,
  "solvable": false,
  "iswatchonly": false,
  "isscript": true,
  "iswitness": true,
  "ischange": false,
  "labels": [
  ]
}

# 脚本类型为“anchor”的 Segwit 输出
bitcoin-cli -regtest decodescript 51024e73
{
  "asm": "1 29518",
  "desc": "addr(bcrt1pfeesnyr2tx)#swxgse0y",
  "address": "bcrt1pfeesnyr2tx",
  "type": "anchor"
}

# P2WPKH 和 P2A 输出的最小聪值
bitcoin-cli -regtest createrawtransaction '[{"txid": "49ea7a01bcba744bd82ecea3e36c4ee9a994f010508a28a09df38f652e74643b", "vout": 0}]' '[{"bcrt1qqzv3ekkueheseddqge3mqdcukse6p9d5yuqxv3": "0.00000294"}, {"bcrt1pfeesnyr2tx": "0.00000240"}]'
02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff02260100000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4f0000000000000000451024e7300000000

# 签名并发送带有 P2A 输出的交易
bitcoin-cli -regtest -rpcwallet=test signrawtransactionwithwallet 02000000013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff02260100000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4f0000000000000000451024e7300000000
{
  "hex": "020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff02260100000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4f0000000000000000451024e7302473044022002c7e756b15135a3c0a061df893a857b42572fd816e41d3768511437baaeee4102200c51fcce1e5afd69a28c2d48a74fd5e58b280b7aa2f967460673f6959ab565e80121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000",
  "complete": true

# 关闭严格费用检查
bitcoin-cli -regtest -rpcwallet=test sendrawtransaction 020000000001013b64742e658ff39da0288a5010f094a9e94e6ce3a3ce2ed84b74babc017aea490000000000fdffffff02260100000000000016001400991cdadccdf30cb5a04663b0371cb433a095b4f0000000000000000451024e7302473044022002c7e756b15135a3c0a061df893a857b42572fd816e41d3768511437baaeee4102200c51fcce1e5afd69a28c2d48a74fd5e58b280b7aa2f967460673f6959ab565e80121030af1fadce80bcb8ba614634bc82c71eea2ed87a5692d3127766cc896cef1bdb100000000 "0"
fdee3b6a5354f31ce32242db10eb9ee66017e939ea87db0c39332262a41a424b

# 替换了先前的包
bitcoin-cli -regtest getrawmempool
[
  "fdee3b6a5354f31ce32242db10eb9ee66017e939ea87db0c39332262a41a424b"
]

# 对于子交易，将金额烧到手续费里，对 65vbyte 的交易使用 OP_RETURN 以避免 tx-size-small 错误
bitcoin-cli -regtest createrawtransaction '[{"txid": "fdee3b6a5354f31ce32242db10eb9ee66017e939ea87db0c39332262a41a424b", "vout": 1}]' '[{"data": "feeeee"}]'
02000000014b421aa4622233390cdb87ea39e91760e69eeb10db4222e31cf354536a3beefd0100000000fdffffff010000000000000000056a03feeeee00000000

# 无需签名；它是无见证的 segwit
bitcoin-cli -regtest -rpcwallet=test sendrawtransaction 02000000014b421aa4622233390cdb87ea39e91760e69eeb10db4222e31cf354536a3beefd0100000000fdffffff010000000000000000056a03feeeee00000000
8d092b61ef3c1a58c24915671b91fbc6a89962912264afabc071a4dbfd1a484e

```

## 用户故事

继通用的、发布说明级的功能描述之后，我们将描述一些常见的钱包模式，以及它们如何可以从这些更新中受益，无论钱包是否主动进行更改。

### 简单支付

用户的一个问题是，他们无法确信比特币接收者不会创建任意的交易链来钉死用户。如果用户希望有更可预测的 RBF 行为，一种方法是选用 TRUC 交易。收到的支付可以通过最大金额为 1kvB 的花费来健壮地进行费用提升。

如果适配，钱包应该：

- 将版本设置为 3
- 仅使用已确认的输出
- 保持在 10kvB 以内（而不是非 TRUC 限制的 100kvB）
  - 这个限定的极限仍然支持更大的批量支付。
  - 如果钱包没有选择，只能花费未确认的输入，该输入必须来自 TRUC 交易，并且此新交易必须低于 1kvB。

### Coinjoins

隐私是 [coinjoin][topic coinjoin] 场景的重点，但 coinjoin 并不试图隐藏起来。TRUC 交易对于 coinjoin 本身可能是有价值的。coinjoin 可能没有足够的费率进入区块链，因此需要费用增加。

除了 TRUC 交易之外，还可以添加 P2A 输出，允许隔离的钱包（如瞭望塔）仅为交易费用付费。

如果其他参与者花费他们的未确认输出，可能会发生 TRUC 的同辈驱逐。同辈驱逐保留 TRUC 拓扑限制，但允许更高的费率 CPFP - 新的子交易可以“替换”先前的子交易，而无需花费冲突的输入。因此，coinjoin 的所有参与者始终都能够对该交易进行 CPFP。

置顶注意事项：参与 coinjoin 的人仍然可以在经济上来骚扰该交易，方法是双花他们自己在 coinjoin 交易中的输入，要求 coinjoin 对骚扰者的第一笔交易进行 RBF。

### 闪电网络

闪电网络协议包含几种主要类型的交易：

1. 注资交易：单方或双方出资的合约启动交易。时间敏感度较低。
2. 承诺交易：提交最新支付通道状态的交易。这些交易是不对称的，当前需要 “update_fee” 消息双向更新多少资金输出值给费用。这些费用必须足够传播最新版本的承诺交易进入矿工的交易池。
3. HTLC 预签名交易

升级 Bitcoin Core 节点来使用 1P1C 中继和包 RBF，显著增加了闪电网络的安全性。即使相关的承诺交易低于交易池的最低费率，或与另一个低手续费（因此无法迅速确认）的承诺交易包相冲突，也能用来单方面关闭通道。

为了充分利用此更新，钱包和后端应该与 **submitpackage** Bitcoin Core RPC 命令集成：

```hack
bitcoin-cli submitpackage ‘[“<commitment_tx_hex>”, “<anchor_spend_hex>”]’
```

钱包实现应该使用承诺交易以及锚点子交易与后端集成，以确保以适当的费率传播到矿工的交易池和包含在区块中。

注意：如果提交了多个子交易、单个父交易的包，RPC 端点将返回成功，但这些包不会在 1P1C 中继更新中传播。

一旦网络上有足够多的节点升级，LN 协议可能会删除 “update_fee” 消息，这一直是过去几年来强制关闭的一个来源。删除此协议消息后，承诺交易可以设置为静态 1 聪/vbyte 费率。使用 TRUC 交易，我们可以确保竞争的承诺交易与锚点花费可以在网络上 RBF 对方，并且如果有来自同一承诺交易的竞争输出花费，RBF 可以发生，而不管谁在花费哪个输出。TRUC 交易也可以是 0 费用的，从而减少了规范复杂性。使用 TRUC 的同辈驱逐，我们也可以弃用 1 区块 CSV 锁定时间。因为我们不再过分关心正在花费哪些未确认的输出，只要每一方都能自己花费单个输出即可。

使用 TRUC + P2A 锚点，我们可以将当前的两个锚点减少为单个无密钥锚点。此锚点不需要承诺公钥或签名，从而节省了额外的区块空间。费用增加也可以外包给没有特权密钥材料的其他代理。锚点也可以由两个参与者之间共享密钥材料的单个输出（而不是 P2A）组成，但这会在无害的单方关闭情况下增加额外的 vbytes。

类似的策略也可以用于实现高级功能，如拼接，以减少 RBF 钉死的风险。例如，小于 1kvB 的 TRUC 通道拼接可以对另一个通道的单方关闭进行 CPFP，而不会增加手续费追加者的 RBF 钉死风险。后续的追加可以以串行方式进行，只需替换通道拼接交易即可。代价是在通道拼接期间揭示 TRUC 交易类型。

可以看到，这些更新的功能可以避免复杂性并节省成本，前提是每笔交易都适合 1P1C 范式。

### Ark

并非所有交易模式都适合 1P1C 范式。一个很好的例子是 [Ark][topic ark] 输出，它承诺一棵树的预签名（或基于限制条款的承诺）交易来解开共享 UTXO。

如果 Ark 服务提供商（ASP）离线或处理交易，用户可以选择进行单方退出，这涉及用户提交一系列交易来解开他们在交易树中的分支位置。这需要 O(logn) 笔交易。如果其他客户端也在尝试离开树，子交易的数量可能超出交易池对未确认交易链条规模的限制，或产生手续费过低、无法及时确认的冲突交易。如果在特别长的时间窗口内都没有打包，ASP 可以单方面收回所有资金，导致用户资金损失。

理想情况下，Ark 树的最初单方关闭应该是：

1. 发布整个默克尔分支到底层虚拟 UTXO（vUTXO）
2. 每个分支交易都是 0 费用的，以避免费用预测或需要预先决定谁来付费
3. 最终的叶子交易有 0 值锚点花费，其中 CPFP 为整个默克尔树的发布付费给矿工的交易池和包含在区块中

为了正确执行这个理想的过程，我们缺少一些东西：

1. 通用包中继。我们目前没有一种方法可以在 P2P 网络中稳健地传播这些无费用的交易链。
2. 如果太多分支以低费率发布，因为针对后代交易计数限制的钉死攻击，用户可能无法及时发布自己的分支。理想化的 Ark 场景参与者数量会很多。但参与者数量较多时会尤其糟糕。
3. 我们需要通用的同辈驱逐。我们还没有可用于无价值锚点的 0 值输出支持。

相反，让我们尝试以一些额外费用为代价，将所需的交易结构尽可能适配到 1P1C 范式。所有 Ark 树交易，从树根开始，都是 TRUC 交易，并添加一个最小聪值 P2A 输出。

当传输者选择从 Ark 单方退出时，用户发布根交易，并花费 P2A 以支付手续费，然后等待确认。一旦确认，用户提交默克尔分支中的下一个交易，并花费该交易的 P2A 以进行 CPFP。以此类推，直到整个默克尔分支被发布并从 Ark 树中安全提取资金。其他使用相同 Ark 的用户可能恶意或意外地以太低的费率发布同一内部节点交易，但同辈驱逐将确保每一步诚实的子交易都可以用 RBF 来参与竞争（只要低于 1kvB），而无需锁定所有其他输出，也无需为交易安排多个锚点。

假设是二叉树，这个的代价是第 1 个用户相对于理想化 Ark 的增加近 100% vbyte 开销，而对整个树增加大约 50%。对于 4 叉树，这将降低到整个树的大约 25%。

### LN 拼接

闪电网络的更高级构造也会出现其他类型的交易拓扑，可能需要一些工作才能与 1P1C 中继匹配。

闪电网络[拼接][topic splicing]作为一种新兴的标准，已在普遍使用。每个拼接都花费原始注资输出、将资金重新存入到一个新的注资输出（以及同一批预签名承诺交易链）。在未确认时，原始通道状态和新通道状态同时由双方签名和跟踪。

一个可能超出 1P1C 范式的例子是：

1. Alice 和 Bob 注资到一个通道。
2. Alice 进行一次拼接到由 Carol 控制的链上地址。Carol 使用的是一套冷密钥集合，所以她无法 CPFP。这次拼接的目标是在几个小时内确认。
3. Bob 的节点因某种原因离线或强制关闭。
4. 费率飙升（也许某个代币刚刚推出），使得拼接到 Carol 的交易推迟很久。

Alice 希望对 Carol 进行链上支付，所以她不会把没有拼接的承诺交易发到链上。这意味着需要 splice_tx->commitment_tx->anchor_spend 的包以使其传播。

现在，让我们考虑如何将其适配到 1P1C 范式，而不浪费 vbytes。一个 LN 钱包可以对每个链上支付签名两个拼接交易（而不是一个），这两笔交易将相互冲突。一种版本携带费用估计器所选择的相对保守的费率。另一种版本可以包含 240 聪的 P2A 输出，或未来 0 聪的[临时粉尘][topic ephemeral anchors]。

首先，广播无锚点的拼接交易。

如果没有手续费市场没有异动，这笔交易就会被确认。从而，如果有需要，Alice 可以继续正常进行强制关闭。

如果有费用事件导致第一次拼接需要太长时间，则以 1P1C 形式广播 *带有* 锚点的拼接交易以及锚点花费、使用包 RBF 替换无锚点版本。这个费用增加使支付到 Carol 成为可能，然后如有需要，继续强制关闭。

还可以放出携带不同手续费率的更多拼接版本，但请注意，每个副本都需要为承诺交易以及所有未完成的出账 HTLC （offered HTLC）添加额外的签名。

{% include references.md %}

[Gregory Sanders]: https://github.com/instagibbs
[bc 28.0]: https://github.com/bitcoin/bitcoin/releases/tag/v28.0
[bc 28.0 release notes]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-28.0.md
[package relay tracking issue]: https://github.com/bitcoin/bitcoin/issues/27463
[policy series]: /zh/blog/waiting-for-confirmation/
