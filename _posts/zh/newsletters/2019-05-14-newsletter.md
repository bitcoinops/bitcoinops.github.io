---
title: 'Bitcoin Optech Newsletter #46'
permalink: /zh/newsletters/2019/05/14/
name: 2019-05-14-newsletter-zh
slug: 2019-05-14-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 包含关于最近 Taproot 提案的特别部分、关于 BIP174 PSBT 格式的小潜在更改的新闻，以及我们关于 bech32 发送支持和流行基础设施项目中的值得注意的变化的常规部分。

{% include references.md %}

## 行动项

*本周无。*

## 仪表盘项

- **<!--higher-feerates-->****更高的费用率：**在撰写本文时，预计在接下来的 2 个区块内确认的费用率比在 30 个区块（6 小时）内确认的费用率高十倍，比等待 144 个区块（1 天）或更长时间的费用率高一百倍。这可能意味着仍然有机会以较低成本合并适量的输入，以防费用率进一步上升，但前提是您能容忍合并交易确认的潜在长等待时间。

## 新闻

- **<!--soft-fork-discussion-->****软分叉讨论：**在 Bitcoin-Dev 邮件列表中，多个回复被发布，响应 [bip-taproot][] 和 [bip-tapscript][]。此外，Anthony Towns [发布][anyprevout post]了一个使用 bip-taproot 功能实现类似于 [BIP118][] SIGHASH_NOINPUT 的额外软分叉更改提案。由于本周的 Newsletter 已经包含关于 Taproot 的特别部分，我们将推迟对反馈和扩展的总结到下周的 Newsletter，这样读者可以先消化 Taproot 的基本内容。

- **<!--addition-of-derivation-paths-to-bip174-psbts-->****向 BIP174 PSBT 添加派生路径：**Stepan Snigirev [在][psbt path] Bitcoin-Dev 邮件列表中建议允许 PSBT 包含用于生成找零输出地址的公钥的 BIP32 扩展公钥（xpub）和派生路径。这可以帮助多重签名钱包确定交易的找零输出是否支付给正确的签名者集。[BIP174][] 的作者 Andrew Chow 对此想法持开放态度，硬件钱包的开发者也是如此。

## Taproot 和 Tapscript 提案 BIP 概述

上周，Pieter Wuille [发送邮件][taproot post]到 Bitcoin-Dev 邮件列表，提供了两个提案 BIP 的链接。第一个，[bip-taproot][]，允许使用 Schnorr 风格签名或 Merkle 化脚本进行支出。第二个，[bip-tapscript][]，定义了用于 bip-taproot Merkle 支出的比特币现有脚本语言的轻微变体。

对于已经熟悉比特币脚本和类似 [MAST][] 概念的读者，应该可以直接理解这些 BIP。对于背景较少的读者，我们准备了以下总结，从希望升级使用 Taproot 和 Tapscript 的现有钱包的角度来看这些提案的一些关键特性。这仅仅是这些提案所提供的功能的表面，开发人员一直在等待 Schnorr 签名和基于 MAST 的限制，因为它们提供了以前难以或无法在比特币上构建的新功能的构建模块。我们将这些进展的描述留到另一个时间，重点讨论这两个提案 BIP 如何使现有的比特币使用变得比现在更好。

请注意，所有 Taproot 功能都是钱包的选择性加入，因此现有钱包不需要改变其工作方式。只有希望利用 Taproot 和 Tapscript 优势的钱包才需要升级。

### 提案中没有的内容

在我们讨论这些提案可能为比特币添加的功能之前，先看一些不属于提案的内容：

- **<!--no-cross-input-signature-aggregation-->****没有跨输入签名聚合：**就像当前的比特币交易一样，每个输入都需要包含其所有必要的签名。这意味着诸如合并和混币的交易不会获得任何特殊折扣。如果 Taproot 和 Tapscript 提案成为比特币的一部分，我们认为开发人员将继续寻找将跨输入签名聚合带入比特币的方法，但他们需要找到方法来解决在研究 bip-taproot 描述的高级技术时发现的[复杂性][sigagg complications]。（参见 [Newsletter #3][] 中在 [bip-schnorr][] 上下文中的相关讨论。）

- **<!--no-new-sighash-types-->****没有新的 sighash 类型：**尽管某些现有的 sighash 类型被稍微修改了一下，但提案并未提供类似于 [BIP118][] SIGHASH_NOINPUT 的任何内容。然而，bip-tapscript 提供了一种前向兼容机制（标记公钥），使未来的软分叉可以轻松扩展签名检查操作码以包含新的 sighash 类型或其他更改。

- **<!--no-activation-mechanism-specified-->****没有指定激活机制：**如果用户决定他们想开始执行软分叉的新规则，安全性要求足够多的用户在同一个区块开始执行新规则，以阻止矿工创建违反新规则的区块。过去使用了各种机制来实现这一点，并描述了其他选项供未来使用。然而，bip-taproot 并未提及这些技术。Optech 同意 BIP 主要作者的观点，[激活讨论为时过早][discuss activation]。我们首先需要确保对提案的安全性和可取性达成广泛共识，然后再开始讨论最佳的激活方式。

### 使用 Taproot 的单签名支出

为了查看提案中的内容，我们将主要检查现有用例如何转移到 Taproot。最好的起点是查看目前通过比特币协议转移大部分财富的方式：单签名 P2PKH 和 P2WPKH 支出。

单签名 P2WPKH 钱包今天生成一个私钥，从中派生一个公钥（pubkey），并哈希该公钥以创建 bech32 地址的见证程序。（P2PKH 在功能上是相同的，但使用不同的脚本和不同的地址编码。）

| 对象      | 操作                                                       | 示例结果    |
|-|-|-|
| 私钥 | 从 [CSPRNG][] 读取 32 字节，或使用 [BIP32][] HD 派生 | `0x807d[...]0101` |
| 公钥  | point(0x807d[...]0101)，或使用 [BIP32][] HD 公共派生 | `0x02e5[...]3c23` |
| 哈希        | ripemd(sha256(0x0202e5[...]3c23))                               | `0x006e[...]05d6` |
| 地址     | bech32.encode('bc', 0, 0x006e[...]05d6)                         | `bc1qd6[...]24zh` |

在 Taproot 下，哈希步骤将被跳过，因此 bech32 地址将直接包含 pubkey，并有一个小改动。目前，33 字节的比特币风格 pubkeys 编码为以 0x02 或 0x03 开头，以允许验证者重建 secp256k1 椭圆曲线上的键的 Y 坐标；在 bip-taproot 中，此字节的值减少了 2，因此 0x02 变为 0x00，0x03 变为 0x01。含义保持不变，但使用低位来表示这些值，使其余位将来可以用于软分叉。同时，见证版本从 P2WPKH/P2WSH 使用的 `0` 变为 `1`。

| 对象           | 操作                               | 示例结果    |
|-|-|-|
| 私钥      | （同上）                         | `0x807d[...]0101` |
| 公钥       | （同上）                         | `0x02e5[...]3c23` |
| 更改密钥前缀 | (key[0] - 2),key[1:33])                 | `0x00e5[...]3c23` |
| 地址          | bech32.encode('bc', 1, 0x00e5[...]3c23) | `bc1pqr[...]xg73` |

以下是现有地址与示例 taproot 地址的对比。

| P2PKH   | `1B6FkNg199ZbPJWG5zjEiDekrCc2P7MVyC`                              |
| P2SH    | `3QsFXpFJf2ZY6GLWVoNFFd2xSDwdS713qX`                              |
| P2WPKH  | `bc1qd6h6vp99qwstk3z668md42q0zc44vpwkk824zh`                      |
| P2WSH   | `bc1q0jnggjwnn22a4ywxc2pcw86c0d6tghqkgk3hlryrxl7nmxkylmnq6smlx3`  |
| Taproot | `bc1pqrj4788jx79yn3x3wpgks3h6ex3rqgs5tk5qyjreu24vjdgu3q7zxkxxg73` |

从 P2PKH 或 P2WPKH 支出要求支出者在其输入中包含其公钥。对于 Taproot，公钥在被支出的 UTXO 中提供，因此通过不再重复包含它节省了几个 vbytes。支出还必须包含签名；这是一个由 [bip-schnorr][] 定义的 Schnorr 风格签名，附加一个可选的 sighash 字节。如果使用默认 sighash，签名为 64 字节（16 vbytes）；如果使用非默认 sighash，则为 65 字节（16.25 vbytes[^vbytes-decimal]）。总体而言，这使得创建和支出一个 Taproot 单签名输出的成本比 P2WPKH 贵约 5%。这可能不太显著：创建一个 Taproot 输出的成本几乎与创建一个 P2WSH 输出相同——人们经常支付这个费用而没有问题——而单键 Taproot 支出的成本比 P2WPKH 便宜 40%。

<table style="text-align: center;">
<tr>
  <th style="border-bottom-style: none;"></th>
  <th colspan="3">Vbytes</th>
</tr>
<tr>
  <th style="border-top-style: none;"></th>
  <th>P2PKH</th>
  <th>P2WPKH</th>
  <th>Taproot</th>
</tr>
<tr>
  <th>scriptPubKey</th>
  <td>25</td>
  <td>22</td>
  <td>35</td>
</tr>
<tr>
  <th>scriptSig</th>
  <td>107</td>
  <td>0</td>
  <td>0</td>
</tr>
<tr>
  <th>witness</th>
  <td>0</td>
  <td>26.75</td>
  <td>16.25</td>
</tr>
<tr>
  <th>Total</th>
  <td>132</td>
  <td>48.75</td>
  <td>51.25</td>
</tr>
</table>

除了从 ECDSA 更改为 Schnorr 作为签名算法外，还有一些对交易摘要（签名用于证明交易是对 UTXO 的授权支出的哈希）的重要但易于实现的更改。

{:#tagged-hashes}
最值得注意的是，使用的哈希从遗留协议的双 SHA256 (SHA256d) 改为单 SHA256 操作。以前使用的额外哈希不被认为提供了任何有意义的安全性。此外，哈希的数据前缀是特定于该哈希函数使用的值；这有助于防止像 [CVE-2012-2459][] 这样的问题，其中一个上下文的哈希可以在另一个上下文中使用。前缀标签是 `SHA256(tag) || SHA256(tag)`，其中标签在本例中是 UTF-8 字符串“TapSighash”，`||` 表示串联。需要创建或验证大量签名的软件（例如活动的 LN 节点或比特币完整节点）可以使用其 SHA256 函数的一个版本，该版本已预先初始化前缀标签，因此不需要为每次签名验证重复这些操作。不需要最大性能的实现（如普通钱包）可以按描述使用其默认 SHA256 库函数实现算法。

{:#digest-changes}
哈希中包含的数据及其序列化方式也有所更改。这包括一些改进，可以帮助没有访问已验证 UTXO 条目的钱包（例如硬件钱包和 [HSMs][]）更高效，因为它们不需要检索太多数据以确保它们签署的是正确的 UTXO 和金额。

尽管这可能听起来像是大量的更改，但我们认为，对于任何已经兼容 segwit 并且可以访问类似 [libsecp256k1][] 的库以生成 bip-schnorr 兼容签名的钱包来说，这仅仅是一个下午的工作，进行轻微的序列化更改。

## 使用 Taproot 的简单多重签名支出

在单签名 UTXO 之后，最常见的是简单多重签名 UTXO。这些输出依赖于特定公钥的一定数量的签名，但没有其他条件。个人用户（例如，要求多个设备协同工作以进行支出）和单笔交易的多个参与方（例如，托管）都会使用这些输出。

使用 Taproot 进行简单多重签名支出有两种方式，其中最有效的是本小节中描述的密钥和签名聚合。我们将在下一小节中检查另一种机制。

对于聚合，创建两个或更多私钥并派生其公钥。然后将公钥组合成一个与任何其他比特币公钥无法区分的公钥。这被用作前一小节中描述的 segwit 见证程序。之后，部分或全部私钥的拥有者创建签名，这些签名被组合成一个与任何其他 bip-schnorr 签名无法区分的签名。这必须如前一小节中所述提交到相同的交易摘要，但结果是一个完全无法区分于单签名支出的多重签名支出。

您可能已经注意到前一段在聚合密钥和签名的确切机制上是模糊的。原因是有多种已知方法，参与者可以使用其中的任何一种。研究人员甚至可以找到新方法并在比特币钱包中实现它们，而无需任何共识更改。这是因为签名算法只需要一个公钥和一个单签名，它们在上述单签名小节中描述的规则下有效。也就是说，在已知的方法中，[MuSig 协议][musig]可能是在比特币上下文中研究最深入的聚合协议。

无论有多少签名者，聚合密钥和签名所用的字节数都是完全相同的。这可以与 P2WSH 多重签名相比，后者每增加一个公钥增加 8.50 vbytes，每增加一个签名增加约 18.25 vbytes。

![Taproot 多重签名与 P2WSH 的大小比较](/img/posts/2019-05-taproot-multisig-size.png)

## 使用 Taproot 的复杂支出

比特币的脚本语言允许用户指定其比特币的支出条件，这些条件有时不仅需要签名。Taproot 不仅支持此功能，还以多种方式增强了它。

我们可以通过查看一个类似于 LN 和跨链原子交换中使用的基本哈希时间锁合约（HTLC）来考虑这一点。此合约可以通过三种方式终止：

1. Alice 发布释放合约的哈希锁的前映像，从而收到约定的资金（付款）。
2. 在时间锁到期后，Bob 收到约定的资金（退款）。
3. Alice 和 Bob 就如何分配资金达成共识，通常是因为他们中的一个可以使用上述条件之一强制付款或退款。

以 LN 中的 HTLC 为例，我们可以生成两个独立的脚本，每个脚本处理上述的其中一项：

```
(1) OP_HASH256 <hash> OP_EQUALVERIFY <Alice pubkey> OP_CHECKSIG
(2) <time> OP_CHECKLOCKTIMEVERIFY OP_DROP <Bob pubkey> OP_CHECKSIG
```


这些单独的脚本然后被哈希以便它们可以用作默克尔树的叶子。如前所述，要哈希的数据前缀带有一个标签（本身已哈希）以指示其用途。在本例中，标签是“TapLeaf”。叶子还必须包含脚本的大小和一个版本（本提案中只定义了版本 0xc0；其他版本可用于将来的软分叉升级）。

在两个脚本被哈希后，它们的摘要按字典顺序排列。这种排序允许稍后的默克尔包含证明在不知道每个叶子或分支是否出现在其配对兄弟的左侧或右侧的情况下进行，从而减少需要传输的数据量并可能改善隐私。排序后，这两个哈希将与前缀标签“TapBranch”一起哈希。由于这棵默克尔树只有两个叶子，结果哈希是默克尔根。

![示例 taproot 默克尔树](/img/posts/2019-05-taproot-tree.png)

此默克尔树仅覆盖 HTLC 的两种可能的终态。对于 Alice 和 Bob 达成共识的第三种情况，他们可以使用类似 MuSig 的签名聚合。与上面的多重签名部分一样，他们共同创建一个公钥，称为 *Taproot 内部密钥*。

然后将默克尔根和内部密钥一起哈希（前缀标签“TapTweak”），结果摘要用作私钥，从中派生一个公钥，这个值被称为 *tweak*。调整后的公钥添加到内部密钥中以派生 *taproot 输出密钥*——这是用于支付这三种条件的任何 bech32 地址和 scriptPubKeys 中使用的密钥。

![taproot tweak 和输出密钥的构造](/img/posts/2019-05-taproot-tweak.png)
{:.center}

当需要花费这笔资金时，Alice 或 Bob 可以提供他们想要使用的脚本、脚本所需的数据（签名和 Alice 的情况下的哈希前映像）、Taproot 内部密钥和他们未使用的脚本的哈希。或者，Alice 和 Bob 可以共同使用签名聚合（在考虑调整后）提供一个签名，结合前几个小节中描述的单密钥、单签名支出模式。只要他们提供的数据在任何一种情况下都是正确的，支出将被接受。

{% comment %}<!--
    P2WSH
      scriptPubKey: 34
      witnessScript: OP_IF OP_HASH256 <hash> OP_EQUALVERIFY <A pubkey>
                     OP_ELSE <time> OP_CLTV OP_DROP <B pubkey> OP_ENDIF OP_CHECKSIG
                     8 non-push, 4 push, 2x33 (pubkeys), 1x32 (hash), 1x4 (delta) = 114

      1. witnessScript, OP_1, preimage, Alice sig
          1+114           1      1+32       1+72    = 221/4 => 55.25

      2. witnessScript, OP_0, Bob sig
          1+114           1     1+72    = 189/4  => 47.25

      3. N/A (use one of the above)

    Taproot
      scriptPubKey: 35
      1. OP_HASH256 <hash> OP_EQUALVERIFY <Alice pubkey> OP_CHECKSIG
            1        1+32        1             1+33          1        = 69

         script, preimage, A sig; internal key; leaf hash
          1+69      1+32    1+64     1+33           32       = 234/4 => 58.5

      2. <time>     OP_CHECKLOCKTIMEVERIFY OP_DROP <Bob pubkey> OP_CHECKSIG
              1+4             1                 1        1+33         1 = 41

         script, B sig; internal key; leaf hash
           1+41   1+64      1+33         1+32       = 174/4 => 43.5

      3. AB sig
           1+64 = 65/4 => 16.25
-->{% endcomment %}

| | scriptPubKey vbytes | witness vbytes | 总 vbytes |
|-|-|-|-|
| P2WSH (1) Alice 支出   | 34  | 55.25 | 89.25 |
| P2WSH (2) Bob 支出     | 34  | 47.25 | 81.25 |
| P2WSH (3) 共同支出   | 不适用 | 不适用   | 不适用   |
| Taproot (1) Alice 支出 | 35  | 58.50 | 93.50 |
| Taproot (2) Bob 支出   | 35  | 43.50 | 78.50 |
| Taproot (3) 共同支出 | 35  | 16.25 | 51.25 |

因为我们选择了一个小树和一个简单的示例脚本，使用 Taproot 脚本路径支出的成本与可以从未花费的分支中省略的数据的成本类似，从而在 Alice 支出的情况下导致略高的成本。然而，Bob 支出的情况略便宜，联合支出的情况显著便宜于任何其他选项（使用它将完全隐藏这是一个 HTLC）。

树的最大深度为 32 行，允许树包含最多约四十亿个脚本。然而，任何支出交易中只会出现其中一个脚本，并且只需要生成与默克尔树直接相关的 32 个哈希以证明该脚本是树的一部分——这意味着比我们简单的 HTLC 更复杂的脚本可以获得比上述更大的效率改进（有关更多信息，请参阅专注于 [MAST][] 的文章）。

### 使用 Tapscript 的轻微脚本更改

在使用 Taproot 的比特币脚本时，一些规则发生了变化，最显著的是：

- **<!--unused-and-invalid-opcodes-redefined-->****未使用和无效的操作码被重新定义：** 从未分配的操作码、由中本聪设定为无效的操作码或为升级而创建但尚未使用的操作码都被更改为具有 `OP_SUCCESS` 操作码语义，该操作码无条件使包含该代码的任何脚本有效。因为未来的软分叉只能通过使先前有效的内容无效来添加新规则，所以今天的最大有效性将允许未来软分叉的最大灵活性。当然，接收方可以选择使用哪些脚本来接收付款，因此在软分叉赋予 `OP_SUCCESS` 操作码新的共识强制含义之前，任何人都不应在其脚本中包含 `OP_SUCCESS` 操作码。

- **<!--schnorr-signatures-required-->****要求 Schnorr 签名：** Tapscript 不接受 ECDSA 签名。

- **<!--new-script-based-multisig-semantics-->****新的基于脚本的多重签名语义：** 当前的 `OP_CHECKMULTISIG` 和 `OP_CHECKMULTISIGVERIFY` 操作码在 Tapscript 中不可用。有两种替代方案。首先，可以依次使用现有的单签名 `OP_CHECKSIG` 和 `OP_CHECKSIGVERIFY`。例如（2-of-2 多重签名）：

  ```
  <A pubkey> OP_CHECKSIGVERIFY <B pubkey> OP_CHECKSIG
  ```

  其次，新的 `OP_CHECKSIGADD` (`OP_CSADD`) 操作码可用于在签名与指定公钥匹配时增加计数器。例如（2-of-3）：

  ```
  <A pubkey> OP_CHECKSIG <B pubkey> OP_CSADD <C pubkey> OP_CSADD OP_2 OP_EQUAL
  ```

  此更改旨在允许批量验证多个签名，与独立检查每个签名相比，可以[显著加快验证速度][bip-schnorr]。

- **<!--redefined-sigops-limit-->****重新定义 sigops 限制：** 由于验证签名是比特币脚本中最耗 CPU 的操作，比特币的早期版本增加了一个块中最大签名检查操作（sigops）数量的限制，这一限制被应用于后来的 P2SH 和 segwit v0 脚本。然而，这一限制的一个问题是，矿工在选择要包含在块中的有效交易时必须考虑两个因素：费用密度（费用/vbyte）和 sigop 密度（sigops/vbyte）。这比仅基于费用密度优化块组成要困难得多。

Taproot 通过要求使用 Taproot 支出的有效交易为每个成功的 sigop 包含一定量的数据来将其简化为一个参数。规则是一免费 sigop，然后见证必须包含每个额外 sigop 的 50 字节数据。由于 Schnorr 签名至少为 64 字节，这应该提供足够的空间来覆盖所有预期用途，这意味着矿工可以简单地将最有利可图的有效 Taproot 交易包含在其块中，而无需担心 sigops。

### Taproot 和 Tapscript 总结及下一步

这些提案共同为比特币带来了开发人员多年来一直期望的两个功能。第一个功能，Schnorr 签名，将为越来越多利用多重签名安全性（包括 LN 用户）的比特币用户提供更高的隐私性和更低的费用，并且对 Schnorr 的高级用途（例如[无脚本脚本][scriptless scripts]和[离散对数合约][discreet log contracts]）的研究可能在无需进一步共识更改的情况下显著提高效率、隐私性和金融合同。

第二个功能，基于 Taproot 的 MAST，允许开发人员编写比今天可能更复杂得多的脚本，但仍通过允许支出者仅将最少的数据上链来最大限度地减少其上链影响——降低高级用户的费用率，同时提高其隐私性。

最后，由于很可能许多单签名、多重签名和基于 MAST 的支出都可以仅使用一个公钥和一个签名来解决，可能会变得更难跟踪使用不同比特币功能的不同用户——这一优势通过使比特币所有权更难跟踪，从而使比特币更具同质性，更难以有效地分批审查，造福所有比特币用户。

然而，这些提案的未来尚不确定。在此阶段，它们需要加密专家和比特币协议的专家以及计划使用这些功能的应用程序开发人员的仔细审查。随后，需要为完整节点实现这些提案，这将需要更多审查和广泛测试（一个[示例实现][example implementation]已可用，但目前旨在帮助提案审查者）。最后，决定是否执行此提案将取决于使用其自己的完整节点验证其传入付款的人。

Optech 不知道这些目标何时——或是否——会实现，但我们将尽力在本 Newsletter 的未来版本中让您了解任何进展。

## Bech32 发送支持

*第 9 周，共 24 周。在 2019 年 8 月 24 日 segwit 软分叉锁定的第二周年纪念日之前，Optech Newsletter 将包含这个每周部分，为开发人员和组织提供信息，帮助他们实现 bech32 发送支持——即支付本地 segwit 地址的能力。这[不需要自己实现 segwit][bech32 series]，但确实允许您支付的对象访问 segwit 的所有多重好处。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/09-qrcode.md %}

## 值得注意的代码和文档更改

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案(BIPs)][bips repo]中的值得注意的更改。*

- [Bitcoin Core #15730][] 扩展了 `getwalletinfo` RPC，增加了一个 `scanning` 字段，告知用户程序在重新扫描区块链以查找影响其钱包的交易（如果用户请求重新扫描或自动触发）的进度。否则，它仅返回 `false`。

- [Bitcoin Core #15930][] 弃用了 `getunconfirmedbalance` RPC 和 `getwalletinfo` RPC 中的三个不同的 *balance* 字段。取而代之的是，添加了一个 `getbalances` RPC，它提供了两组字段。对于钱包可以花费的余额（“IsMine”），提供一个 `trusted` 字段，用于钱包本身创建或至少有一个确认的输出；一个 `untrusted_pending` 字段，用于在内存池中支付给钱包的输出；以及一个 `immature` 字段，用于从矿工生成交易中获得但尚未收到 100 次确认的输出（最早可以花费）。对于钱包仅监视的余额（“watchonly”），提供相同的三个字段在不同的对象下。

- [C-Lightning #2524][] 记录转发付款失败的详细信息，以便稍后在 `listforwards` RPC 中显示这些详细信息。

- [Bitcoin Core #15939][] 移除了 32 位 Windows 的构建目标，这意味着将来版本的 Bitcoin Core 将没有 Win32 二进制文件。证据表明，很少（如果有的话）Bitcoin Core 用户使用 32 位 Windows。

## 致谢

我们感谢 Anthony Towns 和 Pieter Wuille 对本期 Newsletter Taproot 概述草稿的深刻评论。任何剩余的错误都是 Newsletter 作者的责任。

## 脚注

[^vbytes-decimal]:
  技术上，vbytes 是一个整数单位，使其与传统的比特币区块权重中的字节单位向后兼容。
  我们在本文档中将其用作浮点单位以获得更高的精度。


{% include linkers/issues.md issues="15730,15930,2524,15939" %}
[anyprevout post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016929.html
[psbt path]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-April/016894.html
[taproot post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016914.html
[mast]: https://bitcointechtalk.com/what-is-a-bitcoin-merklized-abstract-syntax-tree-mast-33fdf2da5e2f
[sigagg complications]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-March/015838.html
[discuss activation]: https://twitter.com/pwuille/status/1125478777084006400
[csprng]: https://en.wikipedia.org/wiki/Cryptographically_secure_pseudorandom_number_generator
[hsms]: https://en.wikipedia.org/wiki/Hardware_security_module
[musig]: https://blockstream.com/2018/01/23/en-musig-key-aggregation-schnorr-signatures/
[scriptless scripts]: http://diyhpl.us/wiki/transcripts/layer2-summit/2018/scriptless-scripts/
[discreet log contracts]: https://adiabat.github.io/dlc.pdf
[example implementation]: https://github.com/sipa/bitcoin/commits/taproot
[bech32 series]: /zh/bech32-sending-support/
[newsletter #3]: /zh/newsletters/2018/07/10/#特别新闻schnorr-签名提议-bip
[cve-2012-2459]: https://bitcointalk.org/?topic=102395
