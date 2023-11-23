{:.post-meta}
*by [Antoine Poinsot][] from [Wizardsardine][]*

我们对 Miniscript 的（实际）兴趣始于2020年初，当时我们正在设计 [Revault][]，这是一种仅使用当时可用的脚本原语的多方（保险柜）[vault] [topic vaults] 架构。

在最初的演示用途中，Revault 总是使用一组固定的参与者。当我们试图将其推广到生产环境中的更多参与者时，我们很快遇到了问题。

- 实际上，我们 _确定_ 演示中使用的脚本是安全的吗？我们广告上的所有花费办法都一定能成功吗？除了广告上的办法，还有没有其他花费它的方法？
- 即使是这样，我们如何将其推广到允许数量不等的参与者，并保持安全性？我们如何应用一些优化措施，并确保生成的脚本具有相同的语义？
- 此外，Revault 使用预签名交易（以强制执行花费规则）。给定脚本的配置，我们如何提前知道为费用提升分配多少预算？我们如何确保使用这些脚本进行的 _任何_ 交易都能通过最常见的标准性检查？
- 最后，即使我们假设我们的脚本与预期的语义相对应，并且始终可以花费，我们如何 _具体地_ 花费它们呢？就是说，我们如何为每一种可能的配置生成令人满意的见证（“签名”）？我们如何使硬件签名设备与我们的脚本兼容呢？

如果没有 Miniscript，这些问题本来可能成为绊脚石。两个在车库里的人不太可能编写出一款能够[即时创建某些脚本的软件、指望它可以取得最好的结果][rekt lost funds]并基于此称之为增强安全性的比特币钱包。我们想要围绕 Revault 的开发启动一家公司，但如果不能向投资者提供合理的保证，证明我们能够将安全的产品带到市场上，我们就无法获得资金支持。如果没有资金，我们也无法解决所有这些工程问题。

[进入 miniscript][sipa miniscript]，“这是一种用结构化方式编写比特币脚本（子集）的语言，使分析、组合、通用签名等功能成为可能[...]它具有允许组合的结构，非常容易静态分析，以验证各种属性(花费条件、正确性、安全属性、熔融性等)”。这正是我们所需要的。凭借这个强大的工具，我们可以为我们的投资者提供更好的保证[0]，筹集资金，并开始 Revault 的开发。

当时，miniscript 距离成为任何比特币应用程序开发人员可以使用的成套解决方案还很遥远。(如果你是 2023 年之后阅读这篇文章的新比特币开发人员，是的，曾经我们手动编写比特币脚本)。我们不得不将 miniscript 集成到 Bitcoin Core 中(见 PRs [#24147][Bitcoin Core #24147]、[#24148][Bitcoin Core #24148]和[#24149][Bitcoin Core #24149])，并将其用作 Revault 钱包的后端，且说服签名设备制造商在他们的固件中实现它。后半部分将是最困难的。

这是一个先有鸡还是先有蛋的问题：在没有用户需求的情况下，制造商实现 miniscript 的动机很低，并且我们无法在没有签名设备支持的情况下发布 Revault。幸运的是，这一循环最终在 2021 年 3 月被 [Stepan Snigirev][] 打破，他为 [Specter DIY][]带来[github embit descriptors]对 miniscript 描述符的[支持][github specter descriptors]。然而，Specter DIY 长时间被声明为仅仅是一个“功能原型”，是 [Salvatore Ingala][] 在 2022 年首次将 [miniscript 带到了生产就绪的签名设备上][ledger miniscript blog]，推出了适用于 Ledger Nano S（+）的[新比特币应用程序][ledger bitcoin app]。该应用程序于 2023 年 1 月发布，才使我们能够发布支持最流行签名设备的[Liana 钱包][]。

还剩下最后一个开发工作来结束我们的 Miniscript 旅程。[Liana][github liana] 是一个专注于钱包恢复选项的比特币钱包。它允许指定一些带时间锁的恢复条件 (例如第三方恢复密钥，它们[通常不能花费资金][blog liana 0.2 recovery]，或[衰减/扩张的多重签名][blog liana 0.2 decaying])。最初，Miniscript 仅适用于 P2WSH 脚本。但在 [taproot][topic taproot]激活两年后，每次花钱都必须在链上发布你的恢复花费路径是令人遗憾的。为此，我们一直在努力将 miniscript 移植到 tapscript 中(见[此处][github minitapscript]和[此处][Bitcoin Core #27255])。

未来是光明的。大多数签名设备已经实施或正在实施 miniscript 支持(例如最近的 [Bitbox][github bitbox v9.15.0] 和 [Coldcard][github coldcard 227])，加上 [taproot 和 miniscript 原生框架][github bdk]的完善，使用安全原语在比特币上签约比以往任何时候都更容易。

有趣的是，开源工具和框架的资金支持降低了创新公司竞争的门槛，更广泛地说，降低了要实施的项目的门槛。这种趋势在过去几年中加速发展，让我们对这个领域的未来充满希望。

[0] 当然，仍然存在风险。但至少我们有信心能够克服链上的部分。链下部分（正如预期的那样）将证明更具挑战性。

{% include references.md %}
{% include linkers/issues.md v=2 issues="24147,24148,24149,27255" %}
[Antoine Poinsot]: https://twitter.com/darosior
[Wizardsardine]: https://wizardsardine.com/
[Revault]: https://wizardsardine.com/revault
[rekt lost funds]: https://rekt.news/leaderboard/
[sipa miniscript]: https://bitcoin.sipa.be/miniscript
[Stepan Snigirev]: https://github.com/stepansnigirev
[github embit descriptors]: https://github.com/diybitcoinhardware/embit/pull/4
[github specter descriptors]: https://github.com/cryptoadvance/specter-diy/pull/133
[Specter DIY]: https://github.com/cryptoadvance/specter-diy
[Salvatore Ingala]: https://github.com/bigspider
[ledger miniscript blog]: https://www.ledger.com/blog/miniscript-is-coming
[ledger bitcoin app]: https://github.com/LedgerHQ/app-bitcoin-new
[Liana wallet]: https://wizardsardine.com/liana/
[github liana]: https://github.com/wizardsardine/liana
[blog liana 0.2 recovery]: https://wizardsardine.com/blog/liana-0.2-release/#trust-distributed-safety-net
[blog liana 0.2 decaying]: https://wizardsardine.com/blog/liana-0.2-release/#decaying-multisig
[github minitapscript]: https://github.com/sipa/miniscript/pull/134
[github bitbox v9.15.0]: https://github.com/digitalbitbox/bitbox02-firmware/releases/tag/firmware%2Fv9.15.0
[github coldcard 227]: https://github.com/Coldcard/firmware/pull/227
[github bdk]: https://github.com/bitcoindevkit/
