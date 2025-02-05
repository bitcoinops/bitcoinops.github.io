{% auto_anchor %}
将近两年前，James Chiang 和 Elichai Turkel 创建了一个[开源仓库][taproot-workshop]，其中包含一系列 Jupyter 笔记本，旨在为 Optech 组织的开发者培训提供 [Taproot][topic taproot] 技术相关内容。在旧金山、纽约和伦敦[举办][workshops]的研讨会收到了积极的反馈，但由于旅行限制，后续的线下研讨会未能如期进行。

自 Jupyter 笔记本发布以来，Taproot 发生了多项变更。然而，Taproot 支持已合并到 Bitcoin Core，这使得这些笔记本可以不再依赖于 Bitcoin Core 的自定义分支。开发者 Elle Mouton 友善地[更新了][mouton tweet]这些[笔记本][notebooks #168]，使其适应所有的更改，使其再次成为快速掌握 Taproot 算法和数据类型的绝佳实践工具。

这些笔记本分为四个部分：

- **<!--section-0-->****第 0 部分** 包含一个帮助您设置环境的笔记本，涵盖椭圆曲线密码学的基础知识，并介绍 BIPs [340][BIP340]、[341][BIP341] 和 [342][BIP342] 中广泛使用的标签哈希。

- **<!--section-1-->****第 1 部分** 指导您创建 [Schnorr 签名][topic schnorr signatures]。掌握这些知识后，您将学习如何使用 [MuSig][topic musig] 协议创建[多重签名][topic multisignature]。

- **<!--section-2-->****第 2 部分** 带您全面了解 Taproot。首先回顾 Segwit v0 交易的基本原理，然后帮助您创建和发送 Segwit v1（Taproot）交易。在掌握第 1 部分知识后，您将学习如何使用 MuSig 创建并花费 Taproot 输出。随后，您将接触密钥调整（key tweaking）概念，并学习如何利用 Taproot 公钥承载数据承诺。掌握承诺创建后，您将了解 [Tapscript][topic tapscript]——其与传统及 Segwit v0 脚本的区别，以及如何创建 Tapscript 树的承诺。最后，一个简短的笔记本将介绍如何使用 Huffman 编码来创建最优的脚本树。

- **<!--section-3-->****第 3 部分** 提供了一个可选练习，内容是创建一个 Taproot 输出，该输出会随着未花费时间的增加而改变所需的签名数量——在正常情况下提供高效的花费方式，同时在出现问题时提供强大的备份方案。

这些笔记本包含众多相对简单的编程练习，确保您真正掌握所学内容。本专栏作者并非优秀的程序员，但能够在六小时内完成所有笔记本练习，并遗憾没有更早学习这些内容。

{% include references.md %}
[taproot-workshop]: https://github.com/bitcoinops/taproot-workshop
[workshops]: /zh/schnorr-taproot-workshop/
[notebooks #168]: https://github.com/bitcoinops/taproot-workshop/pull/168
[mouton tweet]: https://twitter.com/ElleMouton/status/1418108253096095745
{% endauto_anchor %}
