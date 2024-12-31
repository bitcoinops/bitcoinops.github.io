{:.post-meta}
*作者：[CardCoins][]*

_“批量添加”是一种在内存池中将额外输出添加到未确认交易的方案。本文汇报了 [CardCoins][] 在其客户提现流程中引入该方案的再组织（reorg）与 DoS 安全实现所做出的努力。_

[Replace By Fee][topic rbf]（RBF，BIP125）与[批量支付][payment batching]是与比特币内存池直接交互的企业不可或缺的两种工具。无论手续费上涨还是下跌，企业始终需要在手续费效率方面不断努力。

每种工具都十分强大，但也各有复杂性与细微之处。例如，为客户提现进行批量支付可能能为企业节省手续费，但也会让需要加速交易的客户通过 [CPFP][topic cpfp] 的方式变得不划算。同样，RBF 对于采用“低费率初始广播、逐步提高费率”策略的企业很有用，但它会让客户在看到自己的提现交易在钱包里更新时[可能产生混淆][rbf blog]。此外，如果客户想在此交易依然未确认的情况下花费它，那么企业在尝试替换其父交易时就必须承担这笔子交易的费用。更糟糕的是，客户在另一个服务那里收到的这笔提现交易可能被对方[固定][pinning]。

将这两种工具结合使用时，服务提供商会获得新功能，但也会面临新的复杂性。在最基本的场景下，将 RBF 与单一、固定的批量支付结合，其复杂性仅是二者分别存在的复杂性的简单叠加。然而，当你把 RBF 与“additive batching” 组合时，就会出现某些边缘案例与危险的故障情形。

在 “additive RBF batching” 场景下，服务提供商会在交易仍处于内存池且尚未确认时，引入新的输出（以及已确认的输入），从而把新的客户提现纳入这笔交易。这使得服务提供商能为用户带来近乎即时提现的体验，同时保留通过批量处理大量客户提现所带来的大部分手续费节省。当每位客户请求提现时，就会向内存池中的交易添加一个输出。直到该交易被确认或到达其他本地最优状态前，它都会继续被更新。

针对这种 “additive RBF batching”，可能存在多种策略。在 [CardCoins][]，我们采用了安全优先的方式实现（并得到了 [Matthew Zipkin][] 的协助），并在博客文章 [RBF Batching at CardCoins: Diving into the Mempool's Dark Reorg Forest][cardcoins rbf blog] 中对此实现细节进行了介绍。

{% include references.md %}
[CardCoins]: https://www.cardcoins.co/
[payment batching]: /payment-batching/
[rbf blog]: /zh/rbf-in-the-wild/#一些可用性示例
[pinning]: /en/topics/transaction-pinning/
[Matthew Zipkin]: https://twitter.com/MatthewZipkin
[cardcoins rbf blog]: https://blog.cardcoins.co/rbf-batching-at-cardcoins-diving-into-the-mempool-s-dark-reorg-forest
