{% auto_anchor %}

在 taproot 激活后，用户将开始接收支付至 P2TR 输出的交易。随后，他们将花费这些输出。某些情况下，用户可能向非 P2TR 输出支付，但仍会使用 P2TR 找零输出将剩余资金返还给自己。

{:.center}
![示例交易 P2TR -> {P2WPKH、P2TR}](/img/posts/2021-10-p2tr-to-p2tr_p2wpkh.png)

对于观察此类交易的专家或算法而言，可以合理推断 P2TR 输出是用户自身的找零输出，而其他输出则为支付输出。虽然这并非绝对成立，但属于最可能的解释。

有观点认为，由于钱包向 P2TR 过渡期间可能出现的隐私暂时下降，应当忽略 taproot 的诸多[隐私优势][p4tr benefits]。多位专家[指出][coindesk experts]这种担忧属于过度反应。我们认同此观点，并补充以下考量：

- ​**<!--other-metadata-->**​**其他元数据：​**​ 交易可能包含其他揭示找零与支付输出的元数据。最令人担忧的是当前大量存在的[地址复用][topic output linking]现象，严重损害交易双方的隐私。只要这些问题存在，拒绝为遵循最佳实践的钱包和服务用户实施重大隐私升级便显失明智。

- ​**<!--output-script-matching-->**​**输出脚本匹配：​**​ Bitcoin Core 内置钱包默认在支付输出包含隔离见证类型时[使用隔离见证找零输出][bitcoin core #12119]，否则使用默认找零地址类型。例如支付至 P2PKH 输出时可能使用 P2PKH 找零，支付至 P2WPKH 输出时使用 P2WPKH 找零。如[周报 #155][news155 bcc22154]所述，taproot 激活后 Bitcoin Core 将在交易包含其他 P2TR 输出时优先使用 P2TR 找零输出，最大程度减少过渡期找零可识别性的增加。

- ​**<!--request-upgrades-->**​**请求升级：​**​ P2TR 为比特币历史首次提供了机会，让所有用户无论安全需求如何均使用相同类型的输出脚本，并频繁使用不可区分的输入，显著提升隐私。若期望提升比特币隐私，可要求收款方和服务提供商支持 taproot（并停止地址复用）。若双方均完成升级，找零输出将更难以识别，同时还能获得 taproot 的其他卓越隐私优势。
{% include linkers/issues.md issues="12119" %}

{% endauto_anchor %}

[p4tr benefits]: /zh/preparing-for-taproot/#多签
[p4tr safety]: /zh/preparing-for-taproot/#我们为什么要等待
[coindesk experts]: https://www.coindesk.com/tech/2020/12/01/privacy-concerns-over-bitcoin-upgrade-taproot-are-a-non-issue-experts-say/
[compat bcc]: /en/compatibility/bitcoin-core/
[news155 bcc22154]: /zh/newsletters/2021/06/30/#bitcoin-core-22154
