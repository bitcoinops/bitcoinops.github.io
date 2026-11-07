---
title: "Bitcoin Optech Newsletter #18"
permalink: /zh/newsletters/2018/10/23/
name: 2018-10-23-newsletter-zh
slug: 2018-10-23-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本期 Newsletter 包含：一则关于通过未加密连接对 Bitcoin 节点进行 RPC 通信的警告；两篇新论文的链接，主题是快速多方 ECDSA 密钥与签名的生成，这类方案有望为多重签名用户降低交易手续费；以及热门 Bitcoin 基础设施项目中一些值得注意的合并。

## 行动项

- **<!--close-open-rpc-ports-on-nodes-->****关闭节点上开放的 RPC 端口：** 大约 13% 的 Bitcoin 节点似乎通过未加密的公共连接对外开放了 RPC 端口，这让这些节点的用户面临风险。有关风险和建议对策的更多细节，请参阅下面的完整新闻条目。

## 新闻

- **<!--over-1-100-listening-nodes-have-open-rpc-ports-->****超过 1,100 个监听节点开放了 RPC 端口：** 最近在 #bitcoin-core-dev IRC 聊天室中提到，网络上许多 Bitcoin 节点开放了它们的 RPC 端口。Optech [进行了调查][port scan summary]，发现 8,400 个拥有 IPv4 地址的监听节点中，大约 1,100 个确实开放了 8332 端口（13.2%）。

    这可能说明，许多节点运营者并不知道：经由 Internet 的 RPC 通信默认完全不安全，会让你的节点暴露在多种攻击之下；即使你已经禁用了节点上的钱包，这些攻击也可能让你损失资金。RPC 通信不加密，因此任何窃听者只要观察到发往你服务器的一次请求，就能窃取你的认证凭据，并用它执行命令：清空你的钱包（如果你启用了钱包）、诱骗你的节点改用一条几乎没有工作量证明安全的区块链分叉、覆盖你文件系统上的任意文件，或者造成其他破坏。即使你从不通过 Internet 连接自己的节点，开放的 RPC 端口也存在被攻击者猜出登录凭据的风险。

    默认情况下，节点不接受来自任何其他计算机的 RPC 连接——你必须启用某个配置选项才能允许 RPC 连接。要判断你是否启用了这项功能，请检查 Bitcoin 配置文件与启动参数中是否出现 `rpcallowip` 参数。如果该选项存在，除非你有充分理由认为发往你节点的所有 RPC 连接都经过加密、或只来自可信的私有网络，否则应当删除它并重启节点。如果你想从远端测试自己的节点是否开放了 RPC 端口，可以把 *ADDRESS* 换成你节点的 IP 地址，再运行下面的 [nmap][] 命令：

    ```
    nmap -Pn -p 8332 ADDRESS
    ```

    如果 *state* 字段的结果是“open”，你应当按上面的说明删除 `rpcallowip` 参数。如果结果是“closed”或“filtered”，那么你的节点就是安全的——除非你自行设置了 RPC 端口，或者以其他方式改过配置。

    有人向 Bitcoin Core 提交了一个 [PR][Bitcoin Core #14532]，目的是让用户更难这样配置节点，并在启用这类行为时打印更多警告。

- **<!--two-papers-published-on-fast-multiparty-ecdsa-->****两篇关于快速多方 ECDSA 的论文发表：** 在多方 ECDSA 中，两方或更多方可以协作（但无需相互信任）生成一个公钥，而要为这个公钥生成一个有效签名，同样需要这些参与方共同协作。如果参与方在生成公钥之前商定好，还可以实现由其中一部分人签名，例如 3 人中的 2 人协作即可签名。这比 Bitcoin 现有的多重签名高效得多：为了实现 k-of-n 的安全性，后者需要往交易里放入 *k* 个签名和 *n* 个公钥；而多方 ECDSA 无论 *k*、*n* 是多少，始终只需要一个签名和一个公钥。多方 ECDSA 背后的技术也可用于[Newsletter #16][news16 mpecdsa]中所述的无脚本脚本（scriptless scripts）。

    最妙的是，任何人只要实现了这套方案，就能立刻获得这些优势：Bitcoin 协议目前对 ECDSA 的支持，本身就意味着它也支持纯 ECDSA 的多方方案。不需要对共识规则、P2P 协议、地址格式或任何其他共享资源作任何更改。你需要的只是两个或更多实现了多方 ECDSA 密钥生成与签名的钱包。因此，对那些受益于 Bitcoin 多重签名带来的额外安全性、却又因额外公钥和签名要多付交易手续费而吃亏的现有服务来说，这套方案很有吸引力。

    专家们审查这些论文、评估其安全性质、并考虑落地实现，大概都需要时间——而且有些专家已经在忙于实现一项共识变更提案，以启用 Schnorr 签名方案；该方案既能简化多方公钥与签名的生成，还带来另外几项好处。

    - [Fast Multiparty Threshold ECDSA with Fast Trustless Setup][mpecdsa goldfeder] 作者 Rosario Gennaro 和 Steven Goldfeder

    - [Fast Secure Multiparty ECDSA with Practical Distributed Key Generation and Applications to Cryptocurrency Custody][mpecdsa lindell] 作者 Yehuda Lindell、Ariel Nof 和 Samuel Ranellucci

[mpecdsa goldfeder]: http://stevengoldfeder.com/papers/GG18.pdf
[mpecdsa lindell]: https://eprint.iacr.org/2018/987.pdf

## 值得注意的合并

本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-lightning][core lightning repo] 和 [libsecp256k1][libsecp256k1 repo] 中值得注意的代码变更如下：

- [Bitcoin Core #14291][]：在 Bitcoin Core 的多钱包模式下使用时，新的 `listwalletdir` RPC 可以列出钱包目录中的所有可用钱包。

- [Bitcoin Core #14424][]：修复了 0.17.0 中一个很可能是回归的问题，它影响只读（watch-only）钱包：这类钱包需要用户导入多重签名脚本对应的公钥（而不只是导入脚本），Bitcoin Core 才能通过 `includeWatching` 标志调用 [fundrawtransaction][rpc fundrawtransaction] 等 RPC 来尝试花费该脚本。该 PR 已被标记为待向后移植到 0.17.1（等该版本的工作启动时）。0.17.0 用户的变通办法见 [Bitcoin Core #14415][]。

- [LND #1978][]、[#2062][LND #2062]、[#2063][LND #2063]：新增了用于构造清扫交易（sweep transaction）的函数，取代了 UTXO Nursery 中原有的函数——该模块“专门用于孵化时间锁定的输出”。这些新函数接受一组输出，为它们生成一笔手续费合适的交易，把资金付回同一个钱包（且不使用重复地址），并对交易签名。清扫交易会把 nLockTime 设为当前区块链高度，采用与 Bitcoin Core、GreenAddress 等其他钱包相同的反手续费狙击（anti-fee sniping）技术，有助于抑制链重组，也让 LND 的清扫交易能与其他钱包的交易混在一起而不易区分。

- [LND #2051][]：确保即使攻击者故意把自己的资金锁定极长时间（最长约 1 万年），也无法让你的节点把同样多的资金锁定同样长的时间。打上这个补丁后，你的节点会拒绝攻击者提出的、要求把其资金和你的资金同时锁定超过 5,000 个区块（约 5 周）的请求。

- [C-Lightning #2033][]：新增了一个 `listforwards` RPC，用于列出转发的支付（即经由你节点转发的支付通道付款），并给出你作为转发路径一环所赚手续费金额的信息。此外，`getstats` RPC 现在返回一个新字段 `msatoshis_fees_collected`，其中是你累计赚取的手续费总额。

- [Libsecp256k1 #354][]：允许 ECDH 函数的调用方使用自定义哈希函数。比特币共识协议并不使用 ECDH，但它在别处也有使用，且采用与比特币相同的曲线参数：例如 BIP [47][BIP47]、[75][BIP75] 和 [151][BIP151]（旧草案）描述的方案；闪电网络的 BOLT [4][BOLT4] 和 [8][BOLT8]；以及其他多种场合，如 Bitmessage、使用机密交易与资产的 [ElementsProject][] 侧链，还有一些以太坊智能合约。其中一些方案无法使用 libsecp256k1 的默认哈希函数，因此这个已合并的 PR 允许传入一个指向自定义哈希函数的指针，用它替代默认函数，并允许向该函数传入任意数据。

{% include references.md %}
{% include linkers/issues.md issues="14291,14424,1978,2062,2063,2051,2033,354,14415,14532" %}

[bitmessage]: https://bitmessage.org/wiki/Encryption
[elementsproject]: https://elementsproject.org/
[port scan summary]: https://gist.github.com/harding/bf6115a567e80ba5e737242b91c97db2
[nmap]: https://nmap.org/download.html
[news16 mpecdsa]: /zh/newsletters/2018/10/09/#多方-ecdsa-用于无脚本的闪电网络支付通道