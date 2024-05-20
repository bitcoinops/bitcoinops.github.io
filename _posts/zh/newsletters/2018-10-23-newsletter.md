---
title: "Bitcoin Optech Newsletter #18"
permalink: /zh/newsletters/2018/10/23/
name: 2018-10-23-newsletter-zh
slug: 2018-10-23-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 包含一个关于通过未加密连接与 Bitcoin 节点进行 RPC 通信的警告、链接到两篇关于创建快速多方 ECDSA 密钥和签名的新论文（这些密钥和签名可能会为多签用户减少交易费用）并列出了一些来自流行的 Bitcoin 基础设施项目中值得注意的合并。

## 行动项

- **<!--close-open-rpc-ports-on-nodes-->****关闭节点上的开放 RPC 端口：** 大约 13% 的 Bitcoin 节点似乎在未加密的公共连接上开放了它们的 RPC 端口，这使得这些节点的用户面临风险。请参阅下面的完整新闻项，了解有关风险和推荐解决方案的更多详情。

## 新闻

- **<!--over-1-100-listening-nodes-have-open-rpc-ports-->****超过 1,100 个监听节点开放了 RPC 端口：** 最近在 #bitcoin-core-dev IRC 聊天室中提到，网络上许多 Bitcoin 节点开放了它们的 RPC 端口。Optech [进行了调查][port scan summary]，发现 8,400 个拥有 IPv4 地址的监听节点中，大约 1,100 个确实开放了 8332 端口（13.2%）。

    这可能表明许多节点操作者并不知道 RPC 通过 Internet 的通信默认完全不安全，并且会使您的节点面临多种攻击，即使您已经禁用了节点上的钱包，这些攻击也可能使您损失金钱。RPC 通信未加密，因此任何观察到您的服务器的单个请求的窃听者都可以窃取您的认证凭据，并使用它们来运行命令，这些命令会清空您的钱包（如果您有钱包的话），欺骗您的节点使用几乎没有工作量证明安全性的区块链分支，覆盖您文件系统上的任意文件，或造成其他损害。即使您从未通过 Internet 连接到您的节点，开放的 RPC 端口也存在风险，攻击者可能会猜到您的登录凭据。

    默认情况下，节点不接受来自任何其他计算机的 RPC 连接——您必须启用配置选项以允许 RPC 连接。要确定您是否启用了此功能，请检查您的 Bitcoin 配置文件和启动参数中的 `rpcallowip` 参数。如果存在此选项，您应该将其移除并重启您的节点，除非您有充分的理由相信所有到您节点的 RPC 连接都是加密的，或者仅限于受信任的私有网络。如果您想远程测试您的节点是否存在开放的 RPC 端口，可以在替换 *ADDRESS* 为您节点的 IP 地址后，运行以下 [nmap][] 命令：

    ```
    nmap -Pn -p 8332 ADDRESS
    ```

    如果 *state* 字段的结果是 "open"，则您应该按照上述说明移除 `rpcallowip` 参数。如果结果是 "closed" 或 "filtered"，则您的节点是安全的，除非您设置了自定义 RPC 端口或以其他方式启用了自定义配置。

    已经向 Bitcoin Core 提交了一个 [PR][Bitcoin Core #14532]，以使用户更难以这种方式配置他们的节点，并打印有关启用此类行为的额外警告。

- **<!--two-papers-published-on-fast-multiparty-ecdsa-->****两篇关于快速多方 ECDSA 的论文发表：** 在多方 ECDSA 中，两个或更多方可以合作（但无需信任）创建单一公钥，这些方还需要合作才能为该公钥创建单一有效签名。如果各方在创建公钥之前达成一致，他们还可以使得少于所有人可以签名，例如，需要其中 2-of-3 人合作签名。这比 Bitcoin 当前的多签更高效，后者需要将 *k* 个签名和 *n* 个公钥放入交易中以获得 k-of-n 的安全性，而多方 ECDSA 总是只需要一个签名和一个公钥，无论 *k* 或 *n* 是多少。多方 ECDSA 的技术也可用于[Newsletter #16][news16 mpecdsa]中描述的无脚本脚本（scriptless scripts）。

    最好的是，任何实现它们的人都可以立即获得这些优势，因为 Bitcoin 协议对 ECDSA 的当前支持也意味着它支持纯 ECDSA 多方方案。不需要对共识规则、P2P 协议、地址格式或任何其他共享资源进行更改。您需要的只是两个或更多实现了多方 ECDSA 密钥生成和签名的钱包。这可以使该方案吸引那些从 Bitcoin 多签的额外安全性中获益但因为必须支付额外的交易费用以支付额外的公钥和签名而损失的现有服务。

    专家可能需要时间来审查这些论文，评估它们的安全属性，并考虑实现它们——而且一些专家已经忙于实施一个共识变更提案，以启用 Schnorr 签名方案，该方案可以简化多方公钥和签名的生成，并提供多个其他好处。

    - [Fast Multiparty Threshold ECDSA with Fast Trustless Setup][mpecdsa goldfeder] 作者 Rosario Gennaro 和 Steven Goldfeder

    - [Fast Secure Multiparty ECDSA with Practical Distributed Key Generation and Applications to Cryptocurrency Custody][mpecdsa lindell] 作者 Yehuda Lindell, Ariel Nof, 和 Samuel Ranellucci

[mpecdsa goldfeder]: http://stevengoldfeder.com/papers/GG18.pdf
[mpecdsa lindell]: https://eprint.iacr.org/2018/987.pdf

## 值得注意的合并

本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-lightning][core lightning repo] 和 [libsecp256k1][libsecp256k1 repo] 中的重要代码变更如下：

- [Bitcoin Core #14291][]：在 Bitcoin Core 的多钱包模式下使用时，新的 `listwalletdir` RPC 可以列出钱包目录中的所有可用钱包。

- [Bitcoin Core #14424][]：修复了 0.17.0 版本的一个可能的回归，该问题影响仅监视的钱包，这些钱包要求用户导入多签脚本的公钥（而不仅仅是导入脚本），以便 Bitcoin Core 能够尝试使用 `includeWatching` 标志的 [fundrawtransaction][rpc fundrawtransaction] 等 RPC 来花费脚本。这个 PR 已经被标记为 0.17.1 的后续版本。对于 0.17.0 用户的一个解决方法在 [Bitcoin Core #14415][] 中有描述。

- [LND #1978][]、[#2062][LND #2062]、[#2063][LND #2063]：添加了用于创建清理交易的新函数，替换了来自 UTXO Nursery “专门用于孵化时限锁定的输出”的函数。这些新函数接受一系列输出，为它们生成具有适当费用的交易（费用支付回相同的钱包，不重用地址），并对交易进行签名。清理交易将 nLockTime 设置为当前区块链高度，实施了与其他钱包（如 Bitcoin Core 和 GreenAddress）相同的反费用抢夺技术，有助于阻止链重组，并允许 LND 的清理交易与那些钱包的交易相融合。

- [LND #2051][]：确保攻击者选择将其资金锁定很长一段时间（长达约 1 万年）的行为不会导致您的节点也将相同数量的资金锁定同样长的时间。有了这个补丁，您的节点将拒绝攻击者锁定其资金和您的资金超过 5,000 个区块（大约 5 周）的请求。

- [C-Lightning #2033][]：提供了一个新的 `listforwards` RPC，用于列出转发的支付（通过您的节点进行的支付渠道支付），包括提供有关您从转发路径中赚取的手续费的信息。此外，`getstats` RPC 现在返回一个新字段 `msatoshis_fees_collected`，包含您赚取的手续费总额。

- [Libsecp256k1 #354][]：允许调用方使用自定义哈希函数来使用 ECDH 函数。比特币共识协议不使用 ECDH，但它在其他地方使用与比特币相同的曲线参数，在 BIPs [47][BIP47]、[75][BIP75] 和 [151][BIP151]（旧草案）；Lightning BOLTs [4][BOLT4] 和 [8][BOLT8]；以及 Bitmessage、[ElementsProject][] 侧链使用机密交易和资产等其他地方。其中一些方案不能使用 libsecp256k1 使用的默认哈希函数，因此合并的 PR 允许传递指向自定义哈希函数的指针，该函数将替代默认值，并允许将任意数据传递给该函数。

{% include references.md %}
{% include linkers/issues.md issues="14291,14424,1978,2062,2063,2051,2033,354,14415,14532" %}

[bitmessage]: https://bitmessage.org/wiki/Encryption
[elementsproject]: https://elementsproject.org/
[port scan summary]: https://gist.github.com/harding/bf6115a567e80ba5e737242b91c97db2
[nmap]: https://nmap.org/download.html
[news16 mpecdsa]: /zh/newsletters/2018/10/09/#多方-ecdsa-用于无脚本的闪电网络支付通道