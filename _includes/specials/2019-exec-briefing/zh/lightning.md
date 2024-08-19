{% include references.md %}
{% capture operating-on-lightning-zh %}Kotliar 开始解释说，前几年较高的交易费用对 Bitrefill 的业务产生了重大影响，因此他们特别努力在降低费用相关的支出方面表现出色。接收 LN 支付的能力支持了这一目标，他相信他们是第一个在主网上出售真实商品以接收 LN 支付的服务。如今，LN 支付约占他们销售额的 5%，这与他们使用以太坊的业务量相似。

  他认为企业现在开始研究 LN 是很重要的。“在比特币中，我们已经习惯于等待 [...] 但让客户等待不确定的时间，会产生客户离开的风险。”例如，当存款在交易所结算时，客户可能不再有兴趣进行本可以为交易所赚取佣金的交易。此外，Bitrefill 使用 LN 的经验表明，LN 改进的发票消除了链上比特币支付中出现的多种支付错误，包括超额支付、少付、卡住的交易、复制粘贴错误以及其他问题。通过 LN 接收支付还消除了合并 UTXO 的需要，并减少了在热钱包和冷钱包之间轮换资金的需求。消除所有这些问题有可能显著减少客户支持和后端支出。

  在他演讲的一个特别有趣的部分，Kotliar 显示了当前链上支付中或许有高达 70% 是用户将资金从一个交易所转移到另一个交易所（甚至在同一交易所的不同用户之间）。如果所有这些活动都可以通过 LN 支付从链上转移，交易所及其用户可以节省大量资金，并且比特币中的每个人都将受益于可用区块空间的增加。

  Kotliar 用几个简短的片段结束了他的演讲。他描述了 Bitrefill 看到 LN 用户今天使用的软件和服务，以及他预计他们在不久的将来会使用的。他接着解释了 Bitrefill 为 LN 用户（包括企业）提供的两个服务，[Thor][] 和 [Thor Turbo][]。最后，他简要描述了对 LN 的几项计划改进：可重复使用地址（参见 [Newsletter #30][newsletter #30 spon]）、拼接进出（参见 [#22][Newsletter #22 splice]）和更大的通道（也参见 [#22][Newsletter #22 wumbo]）。

  总的来说，Kotliar 提出了一个令人信服的观点，即 LN 的更快速度、更低费用和改进的发票意味着希望在不久的将来保持竞争力以服务比特币客户的企业，应该立即开始研究实现 LN 支持。{% endcapture %}

[thor]: https://www.bitrefill.com/thor-lightning-network-channels/?hl=en
[thor turbo]: https://www.bitrefill.com/thor-turbo-channels/?hl=en
[newsletter #30 spon]: /zh/newsletters/2019/01/22/#pr-opened-for-spontaneous-ln-payments
[newsletter #22 splice]: /zh/newsletters/2018/11/20/#splicing
[newsletter #22 wumbo]: /zh/newsletters/2018/11/20/#wumbo
