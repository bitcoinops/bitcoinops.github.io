---
layout: page
title: About
permalink: /zh/about/
redirect_from: /about
---

Bitcoin Operations Technology Group（简称 Optech）致力于将最好的开源技术和技术手段引入使用比特币的企业，以降低成本并改善客户体验。

该组织的初期重点是与其成员组织合作，减少交易大小并尽量减少随后的交易费用增加的影响。我们提供[研讨会][workshops]、[每周通讯][weekly newsletters]、[原创研究][dashboard]、[案例研究和公告][blog]、[播客][podcast]，并帮助促进企业与开源社区之间的关系。

[workshops]: /zh/workshops
[weekly newsletters]: /zh/newsletters/
[dashboard]: https://dashboard.bitcoinops.org/
[blog]: /zh/blog/
[podcast]: /en/podcast/

如果你是比特币公司的工程师或经理，或者是开源贡献者，并希望成为其中的一员，请通过 [info@bitcoinops.org](mailto:info@bitcoinops.org) 联系我们。

## 资金

Optech 不以盈利为目的，所有材料和文档均以 MIT 许可证发布。

初始资金由 Wences Casares 和 John Pfeffer 提供，用于支付外部承包商和偶发费用。Chaincode Labs 提供了支持 Optech 的资源。

我们慷慨的成员公司支付年度会费以覆盖费用。

## Optech 贡献者

Optech 生产的所有材料都是开源的，并以 MIT 许可证发布。任何人都可以通过提交 issue 和拉取请求、审阅通讯和其他材料，以及贡献翻译来参与。我们最常规的贡献者包括：

{% assign contributors = site.data.contributors.contributors | sort: "name" %}
{% include contributors.html id="contributors" %}

{% include sponsors.html %}

## 前 Optech 贡献者

我们感谢所有之前的贡献者为我们所做的努力。

{% assign contributors = site.data.contributors.contributors_alum | sort: "name" %}
{% include contributors.html id="contributors_alum" %}
