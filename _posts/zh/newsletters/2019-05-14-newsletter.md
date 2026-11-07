---
title: 'Bitcoin Optech Newsletter #46'
permalink: /zh/newsletters/2019/05/14/
name: 2019-05-14-newsletter-zh
slug: 2019-05-14-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 包含一个关于近期 Taproot 提案的特别章节、一则关于 BIP174 PSBT 格式可能有一处小改动的新闻，以及我们关于 bech32 发送支持和热门基础设施项目中值得注意的变更的常规章节。

{% include references.md %}

## 行动项

*本周无。*

## 仪表盘项

- **<!--higher-feerates-->****费率走高：**截至本文写作时，预计在接下来 2 个区块内确认的费率，比预计在 30 个区块（6 小时）内确认的费率高十倍，比等待 144 个区块（1 天）或更久的费率高一百倍。这可能意味着，仍然有机会以较低成本合并适量数量的输入，以防费率进一步上升；但前提是你能容忍合并交易迟迟得不到确认。

## 新闻

- **<!--soft-fork-discussion-->****软分叉讨论：**Bitcoin-Dev 邮件列表上出现了多条回复，分别回应 [bip-taproot][] 和 [bip-tapscript][]。此外，Anthony Towns [发帖][anyprevout post]提出了另一项软分叉变更，借助 bip-taproot 的特性实现与 [BIP118][] SIGHASH_NOINPUT 目的相近的功能。由于本周的 Newsletter 已经包含一个关于 Taproot 的特别章节，我们把对这些反馈与扩展提案的总结推迟到下周的 Newsletter，好让读者先有时间消化 Taproot 的基本内容。

- **<!--addition-of-derivation-paths-to-bip174-psbts-->****向 BIP174 PSBT 添加派生路径：**Stepan Snigirev [发帖][psbt path]到 Bitcoin-Dev 邮件列表，建议允许 PSBT 包含 BIP32 扩展公钥（xpub），以及生成找零输出地址所用的那些公钥的派生路径。这有助于多重签名钱包判断交易的找零输出是否付回正确的签名者组合。[BIP174][] 的作者 Andrew Chow 对这个想法表示接受，一家硬件钱包的开发者也是如此。

## Taproot 和 Tapscript 提案 BIP 概述

上周，Pieter Wuille [发邮件][taproot post]到 Bitcoin-Dev 邮件列表，给出了两份提案 BIP 的链接。第一份 [bip-taproot][] 允许使用 Schnorr 风格签名或默克尔化脚本进行花费。第二份 [bip-tapscript][] 则规定了比特币现有 Script 语言的一个细微变体，供 bip-taproot 的默克尔花费使用。

对于已经熟悉比特币脚本以及 [MAST][] 这类概念的读者，应该可以直接读懂这两份 BIP。对于背景知识较少的读者，我们准备了下面这份总结，从“一个想升级到 Taproot 和 Tapscript 的现有钱包”的视角，来看提案中的一些关键特性。这只是这些提案所开放能力的一点皮毛：开发者之所以一直在等待 Schnorr 签名和基于 MAST 的支出约束，原因之一就是它们为过去难以或根本无法在比特币上实现的新功能提供了构建模块。这些进展我们留待以后再介绍，这里只讨论这两份提案如何让比特币的现有用法比今天更好。

请注意，所有 Taproot 功能都需要钱包主动选择启用（opt-in），因此现有钱包不必改变工作方式。只有希望利用 Taproot 和 Tapscript 优势的钱包才需要升级。

### 提案中没有的内容

在我们讨论这些提案可能为比特币添加的功能之前，先看一些不属于提案的内容：

- **<!--no-cross-input-signature-aggregation-->****不做跨输入签名聚合：**与当前的比特币交易一样，每个输入仍需包含自己需要的全部签名。这意味着合并、coinjoin 之类的交易拿不到任何特别折扣。如果 Taproot 和 Tapscript 提案被纳入比特币，我们认为开发者会继续寻找通过未来的软分叉把跨输入签名聚合引入比特币的办法，但他们必须先解决在研究 bip-taproot 描述的高级技术时暴露出来的[种种复杂问题][sigagg complications]。（相关讨论见 [Newsletter #3][] 中关于 [bip-schnorr][] 的部分。）

- **<!--no-new-sighash-types-->****没有新的 sighash 类型：**尽管部分现有 sighash 类型做了小幅调整，提案并未提供类似 [BIP118][] SIGHASH_NOINPUT 的东西。不过，bip-tapscript 确实提供了一种向前兼容机制（带标签的公钥），让未来的软分叉能轻松为签名检查操作码扩展新的 sighash 类型或其他变更。

- **<!--no-activation-mechanism-specified-->****未指定激活机制：**如果用户决定开始执行软分叉的新规则，为了安全，必须有足够多的用户从同一个区块开始执行新规则，才能阻止矿工生产违反新规则的区块。过去用过多种机制来实现这一点，也有其他方案被提出以备将来使用。然而 bip-taproot 对这些技术只字未提。Optech 同意该 BIP 第一作者的观点：[现在讨论激活为时过早][discuss activation]。我们首先需要确认大家对“这些提案是安全且值得做的”有广泛共识，然后才能开始争论最佳的激活方式。

### 使用 Taproot 的单签名支出

为了看清提案里有什么，我们主要考察现有用例如何迁移到 Taproot。最好的起点是目前比特币协议上转移大部分财富的方式：单签 P2PKH 和 P2WPKH 支出。

如今，单签 P2WPKH 钱包会生成一个私钥，从中派生公钥（pubkey），再对该公钥做哈希，生成 bech32 地址的见证程序。（P2PKH 在功能上相同，只是脚本和地址编码不同。）

| 对象      | 操作                                                       | 示例结果    |
|-|-|-|
| 私钥 | 从 [CSPRNG][] 读取 32 字节，或使用 [BIP32][] HD 派生 | `0x807d[...]0101` |
| 公钥  | point(0x807d[...]0101)，或使用 [BIP32][] HD 公共派生 | `0x02e5[...]3c23` |
| 哈希        | ripemd(sha256(0x0202e5[...]3c23))                               | `0x006e[...]05d6` |
| 地址     | bech32.encode('bc', 0, 0x006e[...]05d6)                         | `bc1qd6[...]24zh` |

在 Taproot 下，哈希这一步会被跳过，因此 bech32 地址将直接包含公钥，只做一处小改动。目前，33 字节的比特币式公钥编码后以 0x02 或 0x03 开头，好让验证者重建公钥在 secp256k1 椭圆曲线上的 Y 坐标；在 bip-taproot 中，这个字节的值会减去 2，于是 0x02 变成 0x00，0x03 变成 0x01。含义不变，但把数值放进低位后，其余位就腾出来留给未来的软分叉。同时，见证版本从 P2WPKH/P2WSH 使用的 `0` 改为 `1`。

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

从 P2PKH 或 P2WPKH 支出时，付款方必须把自己的公钥放进输入里。而使用 Taproot 时，公钥已经出现在被花费的 UTXO 中，因此不必再次包含，节省了几个 vbytes。支出还必须包含一个签名；这是 [bip-schnorr][] 所定义、可附加一个可选 sighash 字节的 Schnorr 风格签名。使用默认 sighash 时，签名是 64 字节（16 vbytes）；使用非默认 sighash 时则是 65 字节（16.25 vbytes[^vbytes-decimal]）。总体而言，这让创建并花费一个 Taproot 单签输出的成本比 P2WPKH 高约 5%。这大概无关紧要：创建 Taproot 输出的成本几乎与创建 P2WSH 输出相同——而人们一直在付这个钱，也没觉得有什么问题——而花费单密钥 Taproot 输出的成本比 P2WPKH 低 40%。

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

除了签名算法从 ECDSA 换成 Schnorr，交易摘要（签名承诺的那个哈希，用来证明这笔交易是对某个 UTXO 的授权花费）也有几处重要但容易实现的改动。

{:#tagged-hashes}
最值得注意的是，所用哈希从旧协议的双 SHA256（SHA256d）改为单次 SHA256 运算。此前多出来的那一轮哈希，据信没有提供任何有意义的安全性。此外，被哈希的数据会加上一个前缀，该值专用于哈希函数的这一用途；这有助于防止 [CVE-2012-2459][] 这类问题——某个上下文中的哈希被挪到另一个上下文中使用。前缀标签是 `SHA256(tag) || SHA256(tag)`，此处的 tag 是 UTF-8 字符串“TapSighash”，`||` 表示拼接。需要创建或验证大量签名的软件（例如活跃的 LN 节点或比特币全节点），可以使用预先用该前缀标签初始化过的 SHA256 函数，这样每次验证签名都不必重复这些运算。不追求极致性能的实现（例如普通钱包）直接调用默认的 SHA256 库函数、按上述算法实现即可。

{:#digest-changes}
哈希中包含哪些数据、这些数据如何序列化，也有一些改动。其中一些改进能让无法访问已验证 UTXO 条目的钱包（例如硬件钱包和 [HSMs][]）更高效，因为它们不必再取回那么多数据，就能确保自己签的是正确的 UTXO 和金额。

虽然听起来改动不少，但我们估计，对任何已经兼容 segwit、并且能接入 [libsecp256k1][] 这类库来生成 bip-schnorr 兼容签名的钱包来说，这不过是花一个下午做点小的序列化改动而已。

## 使用 Taproot 的简单多重签名支出

在单签 UTXO 之后，最常见的是简单多重签名 UTXO。这类输出只要求来自若干指定公钥的一定数量签名，没有其他条件。个人用户（例如要求多台设备协作才能花费）和一笔交易的多个参与方（例如托管）都会用到它。

用 Taproot 实现简单多重签名花费有两种方式，其中效率最高的是本小节要讲的密钥与签名聚合。另一种机制我们留到下一小节。

做聚合时，先创建两个或更多私钥并派生出各自的公钥，再把这些公钥合并成一个与其他任何比特币公钥都无法区分的公钥。这个公钥就用作上一小节所述的 segwit 见证程序。之后，部分或全部私钥的持有者为交易创建签名，再把签名合并成一个与其他任何 bip-schnorr 签名都无法区分的签名。这些签名必须承诺与上一小节相同的交易摘要，最终得到一个与单签花费完全无法区分的多重签名花费。

你可能已经注意到，上一段对聚合密钥与签名的具体机制语焉不详。原因是有多种已知方法，参与者用其中任何一种都行。研究人员甚至可能发现新方法并在比特币钱包中实现，而无需任何共识变更。这是因为签名算法只关心一个公钥和一个签名，只要它们在前面单签小节所述的规则下有效即可。话虽如此，在已知方法中，[MuSig 协议][musig]大概是比特币语境下研究得最充分的聚合协议。

无论有多少签名者参与，聚合后的密钥和签名所占字节数完全相同。可以对比 P2WSH 多重签名：每多一个公钥就多 8.50 vbytes，每多一个签名就多约 18.25 vbytes。

![Taproot 多重签名与 P2WSH 的大小比较](/img/posts/2019-05-taproot-multisig-size.png)

## 使用 Taproot 的复杂支出

比特币的 Script 语言允许用户规定自己的比特币在什么条件下才能被花费，而这些条件有时不只需要签名。Taproot 不仅支持这一功能，还从几个方面做了增强。

我们用一个基本的哈希时间锁定合约（HTLC）来说明，这类合约也用于 LN 和跨链原子交换。该合约可以通过三种方式终止：

1. Alice 公布一个能解开合约哈希锁的原像，从而拿到合约中的钱（一笔付款）。
2. 时间锁到期后，Bob 拿到合约中的钱（一笔退款）。
3. Alice 和 Bob 就资金如何分配达成一致，通常是因为其中一方本可以用前两个条件之一强行要求付款或退款。

以 LN 中的 HTLC 为例，我们可以写出两个相互独立的脚本，分别处理上面第 1、2 种情况：

```
(1) OP_HASH256 <hash> OP_EQUALVERIFY <Alice pubkey> OP_CHECKSIG
(2) <time> OP_CHECKLOCKTIMEVERIFY OP_DROP <Bob pubkey> OP_CHECKSIG
```


这两个独立的脚本随后各自做哈希，以便用作默克尔树的叶子。如前所述，待哈希的数据会加上一个标明用途的标签（标签本身也要哈希），本例中的标签是“TapLeaf”。叶子还必须包含脚本的大小和一个版本号（本提案只定义了版本 0xc0；其他版本留给未来的软分叉升级）。

两个脚本哈希完成后，把它们的摘要按字典序排列。这种排序让日后的默克尔包含证明无需知道每个叶子或分支在树中是位于其兄弟节点的左边还是右边即可完成验证，从而减少需要传输的数据量，也可能改善隐私。排好序后，把这两个哈希加上前缀标签“TapBranch”再一起哈希。由于这棵默克尔树只有两个叶子，得到的哈希就是默克尔根。

![示例 taproot 默克尔树](/img/posts/2019-05-taproot-tree.png)

这棵默克尔树只覆盖了 HTLC 两种可能的最终状态。对于第三种情况——Alice 和 Bob 一致同意如何花费——他们可以使用类似 MuSig 的签名聚合。与上面的多重签名小节一样，他们共同生成一个公钥，称为 *Taproot 内部密钥（internal key）*。

随后把默克尔根与内部密钥一起哈希（前缀标签“TapTweak”），所得摘要被当作一个私钥，再由它派生出一个公钥，这个值称为 *tweak*。把调整后的公钥与内部密钥相加，就派生出 *taproot 输出密钥*——凡是支付上述三个条件的 bech32 地址和 scriptPubKey 里用的都是这个密钥。

![taproot tweak 和输出密钥的构造](/img/posts/2019-05-taproot-tweak.png)
{:.center}

到要花这笔钱的时候，Alice 和 Bob 中的任何一方都可以提供自己想用的脚本、该脚本所需的数据（一个签名，Alice 的情况还需要一个哈希原像）、Taproot 内部密钥，以及自己没用到的那个脚本的哈希。另一种做法是 Alice 和 Bob 合作，用签名聚合（需先处理 tweak）生成一个签名，配合前几小节所述的“单公钥、单签名”花费模式来花费。只要他们提供的数据在任一种情况下都是正确的，这笔花费就会被接受。

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

因为我们选了小树和简单的示例脚本，用 Taproot 脚本路径花费的成本，与那条没用到的分支上可以省掉的数据成本相当，结果在 Alice 花费的情况下 Taproot 反而略贵一点。但在 Bob 花费的情况下略便宜，而双方共同花费要比其他任何方案都便宜得多（而且用它还会完全掩盖这是一笔 HTLC 的事实）。

树的最大深度为 32 层，因此一棵树最多可容纳约四十亿个脚本。但在任何一笔花费交易中只会出现其中一个脚本，而且只需生成 32 个与默克尔树直接相关的哈希，就能证明该脚本属于这棵树——这意味着，比我们这个简单 HTLC 更复杂的脚本可以获得比上面大得多的效率提升（更多信息请参阅专讲 [MAST][] 的文章）。

### 使用 Tapscript 后的脚本细微变化

在 Taproot 中使用比特币 Script 时，一些规则有了变化，最值得注意的是：

- **<!--unused-and-invalid-opcodes-redefined-->****未使用和无效的操作码被重新定义：** 从未分配过的操作码、被中本聪设为无效的操作码，以及为升级而创建但尚未使用的操作码，其字节都被改成具有 `OP_SUCCESS` 操作码的语义——无条件地让包含该代码的任何脚本判定为有效。因为未来的软分叉只能靠把原本有效的东西变为无效来添加新规则，所以今天就留足有效性，将来软分叉的空间才最大。当然，接收方可以自己决定用哪些脚本收款，因此在某个软分叉赋予 `OP_SUCCESS` 操作码新的、受共识强制的含义之前，任何人都不应把 `OP_SUCCESS` 操作码写进自己的脚本。

- **<!--schnorr-signatures-required-->****必须使用 Schnorr 签名：** Tapscript 不接受 ECDSA 签名。

- **<!--new-script-based-multisig-semantics-->****新的基于脚本的多重签名语义：** 现有的 `OP_CHECKMULTISIG` 和 `OP_CHECKMULTISIGVERIFY` 操作码在 Tapscript 中不可用。有两种替代方案。第一，可以把现有的单签 `OP_CHECKSIG` 和 `OP_CHECKSIGVERIFY` 串联使用。例如（2-of-2 多重签名）：

  ```
  <A pubkey> OP_CHECKSIGVERIFY <B pubkey> OP_CHECKSIG
  ```

  第二，可以用新的 `OP_CHECKSIGADD`（`OP_CSADD`）操作码：当某个签名与指定公钥匹配时，就把计数器加一。例如（2-of-3）：

  ```
  <A pubkey> OP_CHECKSIG <B pubkey> OP_CSADD <C pubkey> OP_CSADD OP_2 OP_EQUAL
  ```

  这一改动是为了支持批量验证多个签名，与逐个独立验证签名相比，可以[显著加快验证速度][bip-schnorr]。

- **<!--redefined-sigops-limit-->****重新定义 sigops 限制：** 由于验证签名是比特币 Script 中最耗 CPU 的操作，比特币的早期版本曾给一个区块能包含的签名检查操作数（sigops）设了上限，该限制的若干版本后来又应用到 P2SH 和 segwit v0 脚本上。然而这个限制带来一个问题：矿工在挑选要把哪些有效交易放进区块时，必须同时考虑两个因素——手续费密度（手续费/vbyte）和 sigop 密度（sigops/vbyte）。这比只按手续费密度优化区块构成要难得多。

  Taproot 把这件事简化成一个参数：使用 Taproot 花费的有效交易，必须为每个成功执行的 sigop 附带一定数量的数据。规则是第一个 sigop 免费，此后每多一个 sigop，见证中就必须包含 50 字节数据。由于 Schnorr 签名至少 64 字节，这足以覆盖所有预期用法还绰绰有余，也就是说，矿工只需把收益最高的有效 Taproot 交易放进区块，无须再操心 sigops。

### Taproot 和 Tapscript 总结及下一步

这两个提案合起来给比特币带来开发者期盼多年的两项功能。第一项是 Schnorr 签名，它将为越来越多依靠多重签名安全性的比特币用户（包括 LN 用户）带来更好的隐私和更低的手续费；而对 Schnorr 高级用法（例如[无脚本脚本][scriptless scripts]和[谨慎日志合约（DLC）][discreet log contracts]）的研究，还可能在无需进一步更改共识的前提下，在效率、隐私和金融合约方面带来许多重大改进。

第二项是基于 Taproot 的 MAST，它让开发者能写出远比今天复杂的脚本，同时仍把链上影响压到最低——付款方只需把最少的数据放到链上——既降低了高级用户的费率，又改善了他们的隐私。

最后，由于许多单签、多重签名和基于 MAST 的花费很可能都只用一个公钥和一个签名就能完成，要追踪那些使用不同比特币功能的用户会变得困难得多——这一优势使比特币的归属更难被追踪，比特币因此更具可替代性，也更难被零敲碎打地有效审查，从而惠及所有比特币用户。

然而这些提案的前景并不确定。目前，它们需要密码学和比特币协议方面的专家，以及打算使用这些功能的应用开发者仔细审查。之后，它们还需要在完整节点中实现，这又会带来更多审查和大量测试（有一个[示例实现][example implementation]已经可用，但目前只是为了帮助提案审查者）。最后，是否执行这套提案，将由那些用自己完整节点验证收款的人来决定。

Optech 不知道这些目标何时——或者能否——实现，但我们会尽力在今后的 Newsletter 中向你通报任何进展。

## Bech32 发送支持

*第 9 周，共 24 周。在 2019 年 8 月 24 日 segwit 软分叉锁定满两周年之前，Optech Newsletter 将每周刊载本栏目，为开发者和组织提供实现 bech32 发送支持所需的信息——即支付原生 segwit 地址的能力。这[不需要你自己实现 segwit][bech32 series]，但确实能让你付款的对象享受到 segwit 的诸多好处。*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/zh/09-qrcode.md %}

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案（BIPs）][bips repo] 中的值得注意的变更。*

- [Bitcoin Core #15730][] 为 `getwalletinfo` RPC 增加 `scanning` 字段，用于告知用户该程序重新扫描区块链、查找影响其钱包的交易的进度（前提是用户请求了重新扫描，或重新扫描被自动触发）。若不在扫描，则只返回 `false`。

- [Bitcoin Core #15930][] 弃用了 `getunconfirmedbalance` RPC 以及 `getwalletinfo` RPC 中三个不同的 *balance* 字段。取而代之的是新增 `getbalances` RPC，它提供两组字段。对于钱包可以花费的余额（“IsMine”）：`trusted` 字段对应由钱包自身创建、或已有至少一次确认的输出；`untrusted_pending` 字段对应仍在内存池中、支付给钱包的输出；`immature` 字段对应矿工生成交易产生的输出，这些输出尚未获得 100 次确认（这是它们最早可被花费的时点）。对于钱包仅观察的余额（“watchonly”），同样的三个字段放在另一个对象下提供。

- [C-Lightning #2524][] 记录转发支付失败的相关细节，以便日后在 `listforwards` RPC 中展示这些细节。

- [Bitcoin Core #15939][] 移除了 32 位 Windows 的构建目标，这意味着未来版本的 Bitcoin Core 将不再提供 Win32 二进制文件。有证据表明，极少（如果有的话）Bitcoin Core 用户还在使用 32 位 Windows。

## 致谢

我们感谢 Anthony Towns 和 Pieter Wuille 对本期 Newsletter Taproot 概述草稿提出的精辟审阅意见。任何遗留的错误都由 Newsletter 作者负责。

## 脚注

[^vbytes-decimal]:
    技术上，vbytes 是一个整数单位，使其与传统的比特币区块权重中的字节单位向后兼容。
    我们在本文档中将其用作浮点单位以获得更高的精度。


{% include linkers/issues.md issues="15730,15930,2524,15939" %}
[anyprevout post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016929.html
[psbt path]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-April/016894.html
[taproot post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016914.html
[mast]: https://bitcointechtalk.com/what-is-a-bitcoin-merklized-abstract-syntax-tree-mast-33fdf2da5e2f
[sigagg complications]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-March/015838.html
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
