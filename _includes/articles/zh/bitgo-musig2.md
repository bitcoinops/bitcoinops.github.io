{:.post-meta}
*作者：[Brandon Black][]，来自 [BitGo][]*

第一篇[MuSig 论文][MuSig paper]出版于 2018 年，而且 [MuSig][topic musig] 在比特币上的潜能，正是用来让 taproot 软分叉获得支持的卖点之一。对 MuSig 的开发延续了下来，[MuSig-DN][] 和 [MuSig2][] 的论文在 2020 年出版。到 2021 年， taproot 在比特币主网上临近激活的时候，对 MuSig 签名即将到来的兴奋之情是真实可感的。在 BitGo，我们期待能趁着 taproot 的激活发布一款 MuSig taproot 钱包；但是当时的规范、测试节点和参考实现都是不完整的。于是，BitGo 只能先[发布][bitgo blog taproot]第一款基于 tapscript 的多签名钱包，并在主网上发起了[第一笔 tapscript 多签名交易][first tapscript multisig transaction]。接近两年以后，MuSig2 在 [BIP327][] 中得到规范，我们就[发布][bitgo blog musig2]了第一款 MuSig taproot 多签名钱包。

{{include.extrah}}## 为什么要使用 MuSig2？

{{include.extrah}}### 与脚本式多签名相比

相比于脚本式的多签名构造，MuSig 有两大长处。第一点，也是最明显的一点，其交易体积更小（因此矿工手续费更少）。链上的一个签名是 64 ~ 73 字节，换算过来是 16 ~ 18.25 虚拟字节（vB），而 MuSig 可以将两个（甚至更多）签名合并为一个签名。在 BitGo 的 2-of-3 多签名钱包中，使用 MuSig 密钥路径的一个输入只需 57.5 vB，而一个原生的隔离见证输入需要 104.5 vB、使用深度为 1 的脚本路径的 [tapscript][topic tapscript] 输入需要 107.5 vB。第二个好处是，MuSig 也提升了隐私性。在联合持有的输出上使用 MuSig 密钥路径时，这样的合作式花费无法被第三方区块链观察者辨别出跟单签名 taproot 花费有何区别。

当然，MuSig2 也有一些缺点。两种重要的缺点都围绕着签名使用需要用到的 [nonce 值](#nonce确定性的和随机的)。不像普通的 ECDSA（椭圆曲线数字签名算法）和 [schnorr 签名][topic schnorr signatures]，MuSig2 的签名者无法一贯地使用确定性的 nonce 值。这种缺点，使得保证高质量的 nonce 和避免 nonce 复用变得更加困难。MuSig2 在大部分情况下要求 2 轮通信。有些时候，第一轮可以预先计算出来，但必须谨慎进行。

{{include.extrah}}### 与其它 MPC 协议相比

因为上面提到的手续费和隐私性上的好处，“MPC（多方计算）” 签名协议越来越受欢迎。MuSig 是一种 *简单* 的多签名协议（只支持 n-of-n 模式），是因为 schnorr 签名的线性可加特性而成为可能的。MuSig2 可以用一场 30 分钟的演讲解释清楚，而完整的参考实现是 461 行的 Python 代码。[门限签名][topic threshold signature]（t-of-n）协议，例如 [FROST][]，会复杂很多；甚至基于 ECDSA 的[两方的多签名][2-party multi-signatures]，也要依赖于 Paillier 加密算法和其它技术。

{{include.extrah}}## 脚本类型的选择

即使在 [taproot][topic taproot] 激活以前，为一个多签名（t-of-n）钱包选择一种具体的脚本，也是难事。Taproot 因为有了多种花费路径，让这个问题变得更加复杂；而 MuSig 本身甚至提供了更多选项。在我们开始设计 BitGo 的 taproot MuSig2 钱包时，我们考虑了以下事项：

- 我们使用固定的公钥顺序，而不对公钥使用字典排序。每一个签名密钥都有跟公钥一起储存的特定角色，所以每次都以相同的顺序使用这些公钥会更简单，而且更容易预测。
- 我们的 MuSig 密钥路径仅包含最常用的签名人组合，“用户”/“bitgo”。将 “后备” 签名密钥包含在 MuSig 密钥路径中，将极大地减少后备密钥的使用频率。
- 我们不在 Taptree（脚本树）上包含 “用户”/“bitgo” 签名组合。这是我们的第二种 taproot 脚本类型；第一种类型包含了 3 个 tapscript 的设计，需要脚本式签名功能的用户可以使用第一种类型。
- 在 tapscript 中，我们不会使用 MuSig 密钥。我们的钱包包含了一个 “后备” 密钥，这个密钥被假设是难以访问的、而且会使用我们控制之外的软件来签名，所以预期这个后备密钥能够依照 MuSig 协议来签名是不现实的。
- 在 tapscript 中，我们选择了 `OP_CHECKSIG`/`OP_CHECKSIGVERIFY` 而不是 `OP_CHECKSIGADD`。在构造交易的时候，我们知道哪一把密钥会签名，而 2-of-2 的、深度为 1 的脚本，会比 2-of-3 的、深度为 0 的脚本稍微便宜一些。

所以，最终的结构是这样的：

{:.center}
![BitGo's MuSig taproot structure](/img/posts/bitgo-musig/musig-taproot-tree.png)

{{include.extrah}}## Nonce（确定性的和随机的）

椭圆曲线数字签名是在一个一次性秘密值（叫做 “nonce”，意思是只用一次的数字）的帮助下制作出来的。通过在签名中分享 nonce 公开值（nonce 公开值和 nonce 秘密值的关系，就像公钥与私钥的关系），验证者可以确认签名等式成立，而无需签名人揭晓自己长期使用的私钥。为了保护这个长期使用的私钥，同一个私钥（或者有关联的私钥）在签名不同的消息时绝不能使用相同的 nonce 值（nonce 不能复用）。对单签名来说，最常被推荐的避免 nonce 复用的方法就是 [RFC6979][]：确定性的 nonce 生成法。完全随机的数值也是安全的，只要它一经使用就立即被丢弃的话。但这些方法都不能直接为多签名协议所用。

为了在 MuSig 中安全地使用确定性 nonce 值，在 MuSig-DN 这样的技术中，必须证明所有的参与者都正确地生成了确定性 nonce 值。没有这样的证据，恶意的签名人就可以为同一条消息发起两个签名会话，然后提供不一样的 nonce 值。另一个生成确定性 nonce 值的签名会使用相同的 nonce 值为两条实质上不同的信息生成两个碎片签名，最终导致私钥泄露给恶意签名人。

在 MuSig2 规范的开发期间，[Dawid][] 和我意识到，*最后一个* 贡献 nonce 值的签名人可以确定性地生成自己的 nonce 值。我跟 [Jonas Nick][] 讨论了这一点，他于是将此形式化、成为规范。在 BitGo 的 MuSig2 实现中，这种确定性的签名模式用在了我们 HSM（硬件签名模块）中，以使这些硬件可以无状态地（statelessly）执行 MuSig2 签名。

在多轮签名协议中使用随机 nonce 值时，签名人必须考虑这些 nonce 秘密值在轮次之间如何存储。在单签名中，nonce 秘密值在创建它的同一个执行步骤中就可以删除。如果一个攻击者可以在 nonce 值创建之后、来自其它签名器的 nonce 值到来之前立即克隆一个签名器的状态，这个签名器就可以被诱骗为实质上不同的多条消息使用同一个 nonce 值生成多个签名。因此，我们建议签名人仔细考虑自己的初始状态是否可被访问、nonce 秘密值具体在什么时候会被删除。在 BitGo 用户使用 BitGo SDK 运行 MuSig2 流程时，nonce 秘密值是使用 [MuSig-JS][] 库来保存的，并且，一旦为了签名而访问它们，就会导致它们被删除。

{{include.extrah}}## 形成规范的流程

我们在 BitGo 实现 MuSig2 的经验表明，在比特币生态里工作的公司和个人应该花时间来审核自己意图实现（甚至只是期待会出现）的东西的规范，并为这样的规范的开发作出贡献。在我们第一次审核 MuSig2 规范的草稿、并开始学习如何最好地将它整合进我们的签名系统时，为了将带状态的签名引入我们的 HSM，我们考虑过许多困难的方法。

幸运的是，在我向 Dawid 介绍了其中的挑战之后，他很确信有一种办法可以使用确定性的 nonce 值，而且我们最终得出了其中一个签名人可以使用确定性 nonce 值的粗糙想法。后来，我又向 Jonas 提起了这个想法，并解释了我们尝试启用的具体应用场景，他意识到了其中的价值，将它融合进了规范。

现在，其它的 MuSig2 实现也可以利用这样的灵活性：其中一位签名人无需管理状态。在开发过程中，通过审核（以及实现）MuSig2 规范的草稿，我们成功为规范作出了贡献，并且在这份规范作为 BIP327 正式发布之后，很快我们的 MuSig2 签名就整装待发了。

{{include.extrah}}## MuSig 与 PSBT

[PSBT（部分签名的比特币交易）][topic psbt] 格式意在携带让各方（比如：签名人和协调人）可以签名一笔交易所需的所有信息。签名所需的信息越多，这种格式的价值就越大。我们试验了使用额外的字段扩展我们现有的 API 格式以协助 MuSig2 签名 vs. 转化成 PSBT 的成本和好处。最终我们将需要交换的交易数据转化成 PSBT 格式，而且获得了巨大的成功。尚不为许多人所知的是，BitGo 钱包现在可以跟支持 PSBT 的硬件签名设备集成（除了使用 MuSig2 的 BitGo 钱包，详见下一段）。

但现在还没有公开为 MuSig2 签名而设的 PSBT 字段。在我们的实现中，我们基于 [Sanket][] 分享给我们的一份草案，用上了专门的字段。这是一个很少被提起的 PSBT 格式的好处 —— 你可以在同一种二进制格式中额外加入定制化的交易构造或者签名协议所需的 *无论什么* 数据；因为全局的、每个输入、每个输出的部分已经得到定义。PSBT 规范将未签名的交易跟脚本、签名以及其它最终形成一笔完整的交易所需的数据分离开来。这种分离可以在签名流程中提升通信的效率。举个例子，我们的 HSM 拿仅包含自己的 nonce 值和签名的最小 PSBT 作为响应，而这个 PSBT 可以很容易地组合成预签名的 PSBT。

{{include.extrah}}## 致谢

感谢在 Blockstream 工作的 Jonas Nick 和 Sanket Kanjalkar、在 Fedi 工作的 Dawid Ciężarkiewicz，以及在 BitGo 团队的 [Saravanan Mani][]、David Kaplan，和其他人。

{% include references.md %}
[Brandon Black]: https://twitter.com/reardencode
[BitGo]: https://www.bitgo.com/
[MuSig paper]: https://eprint.iacr.org/2018/068
[MuSig-DN]: https://eprint.iacr.org/2020/1057
[MuSig2]: https://eprint.iacr.org/2020/1261
[bitgo blog taproot]: https://blog.bitgo.com/taproot-support-for-bitgo-wallets-9ed97f412460
[first tapscript multisig transaction]: https://mempool.space/tx/905ecdf95a84804b192f4dc221cfed4d77959b81ed66013a7e41a6e61e7ed530
[bitgo blog musig2]: https://blog.bitgo.com/save-fees-with-musig2-at-bitgo-3248d690f573
[FROST]: https://datatracker.ietf.org/doc/draft-irtf-cfrg-frost/
[2-party multi-signatures]: https://duo.com/labs/tech-notes/2p-ecdsa-explained
[RFC6979]: https://datatracker.ietf.org/doc/html/rfc6979
[Dawid]: https://twitter.com/dpc_pw
[Jonas Nick]: https://twitter.com/n1ckler
[MuSig-JS]: https://github.com/brandonblack/musig-js
[Sanket]: https://twitter.com/sanket1729
[Saravanan Mani]: https://twitter.com/saravananmani_
