在[上周的专栏][p4tr sig adaptors]中，我们探讨了[签名适配器][topic adaptor signatures]，以及 [Taproot][topic taproot] 与 [Schnorr 签名][topic schnorr signatures]的激活将如何使适配器的使用更加私密和高效。签名适配器可以在比特币上以多种方式应用，其中最直接受益的用例之一是点时间锁定合约（Point Time Locked Contracts，简称 [PTLCs][topic ptlc]），它可以替代多年来使用的[哈希时间锁定合约（HTLCs）][topic htlc]。这将带来多个优势，但也伴随着一些挑战。为了理解两者，我们首先从一个简化的 HTLC 示例开始，该示例适用于链下 LN 支付、链上 CoinSwap，或像 Lightning Loop 这样结合链上和链下的混合系统——正是这种灵活性，使得 HTLC 被广泛使用。

Alice 想通过 Bob 向 Carol 支付，但 Alice 和 Carol 都不想信任 Bob。Carol 生成一个随机的前镜像（preimage），并使用 SHA256 算法对其进行哈希。然后，Carol 将哈希值提供给 Alice，并保留前镜像的秘密。Alice 发起支付给 Bob，Bob 可以使用自己的公钥签名加上前镜像来领取资金；或者，在 10 个区块后，Alice 可以使用自己的公钥签名将交易退还给自己。以下是用 Minsc 语言描述的[该 HTLC 逻辑][htlc1 minsc]：

```hack
(pk($bob) && sha256($preimage)) || (pk($alice) && older(10))
```

随后，Bob 可以使用几乎相同的脚本向 Carol 发起支付（可能扣除一些费用），但角色[相应调整][htlc2 minsc]，并且退款超时更短：

```hack
(pk($carol) && sha256($preimage)) || (pk($bob) && older(5))
```

现在，Carol 可以在 5 个区块内使用前镜像领取来自 Bob 的付款，这会将前镜像暴露给 Bob，使得 Bob 也能在 5 个区块内使用它向 Alice 领取付款。

### HTLC 的隐私问题

如果上述脚本在链上发布，由于相同的哈希和前镜像被重复使用，观察者可以立即看出 A 通过 B 向 C 付款。这对于同链和跨链的 CoinSwap 可能是个重大问题。不那么明显的是，这对 LN 等链下路由协议也是个问题。如果一个路径较长的支付中，有人控制多个跳数，他们可以通过检测相同的哈希和前镜像的重复使用来识别哪些节点是路由节点，从而推测出其余节点很可能是支付方或接收方。这是 可链接性问题（linkability problem）的一个组成部分，而这可能是 LN 目前最大的隐私弱点。

![HTLC 可链接性问题示意图](/img/posts/2021-07-ln-linkability1.dot.png)

虽然[多路径支付（MPP）][topic multipath payments]在一定程度上缓解了 LN 付款金额的可链接性问题，但它可能会加剧哈希可链接性问题，因为它给了监听节点更多机会来关联哈希值。

HTLC 的另一个问题是，任何需要链上执行的脚本都会与普通的支付脚本明显不同。这使得监测者更容易识别使用模式，并可能有效推测特定用户的信息。

### PTLC 解决方案

在前面的 Minsc 脚本中，我们使用了一个函数，只有在传入一个预先选择的特定值（前镜像）时，该函数才会返回 true。而[签名适配器（signature adaptors）][topic adaptor signatures] 也有类似的特性——它们只有在传入一个特定值（标量）时，才能转换成有效签名。如果暂时忽略[多重签名][topic multisignature]，我们可以将 HTLC 脚本转换为以下 PTLC 形式：

```hack
(pk($bob) && pk($alice_adaptor)) || (pk($alice) && older(10))
```

```hack
(pk($carol) && pk($bob_adaptor)) || (pk($bob) && older(5))
```

简单来说，Carol 给 Alice 一个椭圆曲线（EC）点，它对应一个隐藏的标量。Alice 使用该点和她选择的公钥创建一个签名适配器并交给 Bob；Bob 再使用相同的点和自己选择的公钥创建另一个适配器交给 Carol。Carol 通过转换 Bob 的适配器为有效签名来揭示标量，从而领取 Bob 的资金。随后，Bob 从 Carol 的有效签名中恢复该标量，并使用它转换 Alice 的适配器为有效签名，以领取 Alice 的资金。

这解决了链上监测的可链接性问题，因为区块链上展示的只是不同公钥对应的有效签名。第三方无法知道是否使用了适配器签名，更无法得知适配器的标量值。

然而，上述流程并不能防止参与路由的监听节点关联支付。如果所有支付都基于相同的标量，它们的可链接性就与使用哈希锁和前镜像一样高。为了解决这个问题，每个路由节点可以选择自己的标量，并在支付通过该节点时移除相应的点。我们修改示例如下：

和之前一样，Carol 给 Alice 一个点，但这次 Alice 还向 Bob 请求一个点。Alice 构造的适配器包含 Carol 的点和 Bob 的点的聚合。Bob 知道自己的点，因此可以从 Alice 传来的适配器中移除它。这样，Bob 得到的结果（他不知道的是，这实际上只是 Alice 从 Carol 那里获得的点），用于创建他给 Carol 的适配器。Carol 知道最终的标量，所以可以转换 Bob 的适配器为有效签名。Bob 从 Carol 的签名中恢复 Carol 的标量，并结合自己的标量转换 Alice 的适配器为有效签名。

在 Alice→Bob 和 Bob→Carol 这两个跳数中，使用了不同的 EC 点和标量，消除了可链接性。扩展到更长的路径后，我们可以看到隐私性的改进：

![PTLC 取消可链接性示意图](/img/posts/2021-07-ln-linkability2.dot.png)

正如上周提到的，Schnorr 签名使得将适配器签名与多重签名结合变得简单。对于一般的 PTLC，这使得链上的脚本可以进一步简化为：

```hack
pk($bob_with_alice_adaptor) || (pk($alice) && older(10))
```

```hack
pk($carol_with_bob_adaptor) || (pk($bob)   && older(5) )
```

在 Taproot 方案下，左分支可以成为密钥路径（keypath），右分支可以成为 Tapleaf。如果支付成功路由，Bob 和 Carol 可以在链上结算，而无需对手方进一步配合，从而使此类路由支付与单签支付、普通多重签名支付和合作解决的合约难以区分，同时还能最大化节省区块空间。如果需要执行退款条件，这种方式仍然相当高效，并具有良好的隐私性——pk(x) && older(n) 代码与[降级多签][degrading multisig]、[强制持币][enforced hodling]等多种可能的脚本难以区分。

在下周的专栏中，我们将邀请一位我们最喜爱的 LN 开发者撰写客座文章，讨论 LN 采用密钥路径支付、多重签名、PTLCs 以及 Taproot 启用的其他特性的必要变更。

[p4tr sig adaptors]: /zh/preparing-for-taproot/#签名适配器
[htlc history]: /en/topics/htlc/#history
[htlc1 minsc]: https://min.sc/#c=%2F%2F%20Traditional%20preimage-based%20HTLC%0A%24alice%20%3D%20A%3B%0A%24bob%20%3D%20B%3B%0A%24carol%20%3D%20C%3B%0A%24preimage%20%3D%20H%3B%0A%0A%28pk%28%24bob%29%20%26%26%20sha256%28%24preimage%29%29%20%7C%7C%20%28pk%28%24alice%29%20%26%26%20older%2810%29%29
[htlc2 minsc]: https://min.sc/#c=%2F%2F%20Traditional%20preimage-based%20HTLC%0A%24alice%20%3D%20A%3B%0A%24bob%20%3D%20B%3B%0A%24carol%20%3D%20C%3B%0A%24preimage%20%3D%20H%3B%0A%0A%28pk%28%24carol%29%20%26%26%20sha256%28%24preimage%29%29%20%7C%7C%20%28pk%28%24bob%29%20%26%26%20older%285%29%29
[degrading multisig]: https://github.com/bitcoinops/taproot-workshop/blob/master/3.1-degrading-multisig-case-study.ipynb
[enforced hodling]: https://bitcoin.stackexchange.com/questions/69809/op-checklocktimeverify-op-hodl-script
