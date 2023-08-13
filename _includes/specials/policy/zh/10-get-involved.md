我们希望这个系列可以让读者更好地了解在等待确认时发生了什么。我们从讨论比特币的一些意识形态价值开始，将其[转化][policy01]为比特币的结构和设计目标。对等网络的分布式结构提供了比典型的集中式模型更高的抗审查性和隐私保护。一个开放的交易中继网络有助于每个人知晓即将进入区块的交易。这提高了[区块中继的效率][policy01]，使得作为一个新矿工加入比特币网络更可行，同时也创造了一个[对区块空间的公开拍卖][policy02]。作为一个由许多独立的、匿名的实体运行节点组成的理想网络，节点软件必须被设计成[可防 DoS 攻击][policy05]并尽量减少运营成本。

手续费在比特币网络中扮演着重要的角色，作为解决区块空间竞争的“公平”方式。在交易池中，允许交易替换、可以感知交易包的选择和驱逐算法，使用[激励兼容性][policy02]来衡量存储一个交易的效用，并为用户启用 [RBF][topic rbf] 和 [CPFP][topic cpfp] 作为追加手续费的机制。这些交易池策略的组合、能[经济地构造交易][policy03]的钱包和良好的[费率估计][policy04]，为区块空间创造了一个高效的市场，从而使每个人受益。

个别节点还会执行 _交易中继策略_，以[保护自己避免资源耗尽][policy05]和[表达个人偏好][policy06]。在[网络范围内][policy07]，标准规则和其他策略保护着对扩展性、节点运行的可访问性以及更新共识规则的能力等至关重要的资源。由于网络中的绝大多数都遵守这些策略，它们是比特币应用程序和 L2 协议所依赖的[接口][policy08]的重要组成部分。然而，它们并不完美。我们描述了几个[与交易池策略相关的提案][policy09]，这些提案致力于解决广泛的局限性以及特定用例，比如[对 L2 结算交易的钉死攻击][policy08]。

我们还强调，网络政策的持续演进需要协议、应用和钱包开发者之间的合作。随着比特币生态系统在软件、使用案例和用户方面的增长，去中心化的决策过程变得更加必要，但也更具挑战性。即使比特币的采用率增长，系统也是由利益相关者的关注和努力而形成的——没有一家公司负责收集客户反馈并雇佣工程师来构建新的协议功能或删除未使用的功能。对希望成为网络的粗略共识的一部分的利益相关者而言，目前有不同的参与途径：自主了解情况、提出疑问和问题、参与网络设计，甚至贡献改进的实现。下次当你的交易确认时间过长时，就知道该怎么做了！

[policy01]: /zh/newsletters/2023/05/17/#等待确认-1-我们为什么需要一个交易池
[policy02]: /zh/newsletters/2023/05/24/#等待确认-2激励
[policy03]: /zh/newsletters/2023/05/31/#等待确认3竞价区块空间
[policy04]: /zh/newsletters/2023/06/07/#等待确认-4费率估算
[policy05]: /zh/newsletters/2023/06/14/#等待确认-5用于保护节点资源的规则
[policy06]: /zh/newsletters/2023/06/21/#等待确认-6规则一致性
[policy07]: /zh/newsletters/2023/06/28/#等待确认-7网络资源
[policy08]: /zh/newsletters/2023/07/05/#等待确认-8交易池规则是个接口
[policy09]: /zh/newsletters/2023/07/12/#等待确认-9规则提案