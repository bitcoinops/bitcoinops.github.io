---
title: 'Bitcoin Optech Newsletter #34'
permalink: /zh/newsletters/2019/02/19/
name: 2019-02-19-newsletter-zh
slug: 2019-02-19-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了一次关于 BIP118 SIGHASH_NOINPUT_UNSAFE 的输出标记讨论，宣布了一些合并，使得可以将 Bitcoin Core 的内置钱包与硬件钱包配对使用观看模式，并描述了下一个 Bitcoin Core 版本功能冻结的完成情况。同时还总结了流行 Bitcoin 基础设施项目中大量的代码和文档更改。

## 行动项

本周无。

## 新闻

- **<!--discussion-about-tagging-outputs-to-enable-restricted-features-on-spending-->****关于标记输出以启用受限支出功能的讨论：**[BIP118][] SIGHASH_NOINPUT_UNSAFE（noinput）提案允许生成授权支出一个 UTXO 的签名的人可选择允许该签名重复用于支出发送到相同公钥的其他 UTXO。这在与包含相同公钥的协议（例如支付通道）一起使用时可以启用新功能（参见提议的闪电网络 [Eltoo][]层），但它也可能使得在用户重用地址时发生*重放攻击*，导致资金损失。例如：Alice 使用她之前收到的一个硬币到她的一个地址，并使用 SIGHASH_NOINPUT_UNSAFE 签署了对 Bob 的支出。后来有人向 Alice 的同一地址支付了一些钱，意图向她发送更多的钱。Bob（或其他任何人）现在可以通过重放 Alice 之前的签名将该输出发送给 Bob。

  避免这种事故的一种方法是简单地在功能名称后附加“UNSAFE”，鼓励开发人员在其工具中实施之前了解协议的细微差别。然而，一些开发者一直在寻找额外的方法来防止问题发生。去年十二月，Johnson Lau [提议][lau output tagging]只有在创建时已被特别标记为允许使用 noinput 的输出，才能使用 noinput。这仅允许在支付者和接收者都同意的情况下（如支付通道）使用该功能，防止任何误传或误解导致资金损失。

  [上周重新讨论][nick output tagging]和本周的讨论分析了这对提议的二层协议（如 Eltoo 和 [Channel Factories][]）的影响。尽管标记增加了复杂性，但普遍认为它不会从根本上增加成本或降低所描述提案的有效性，尽管它可能使它们的隐私性略有降低。

- **<!--bitcoin-core-preliminary-hardware-wallet-support-->****Bitcoin Core 初步硬件钱包支持：**经过数月的渐进改进，本周合并了支持 Bitcoin Core 主开发分支与硬件钱包通过[硬件钱包交互][HWI]（HWI）工具接收和发送交易所需的最终一组 PR。HWI 是 Bitcoin Core 项目的一部分，但尚未与 Bitcoin Core 软件一起分发，目前仅可通过命令行访问。它提供了一个坚实的基础，可以构建工具，使得使用 Bitcoin Core 原生钱包和完整验证节点的外部密钥存储变得容易。还请注意，已经可以将硬件钱包连接到使用 [Electrum Personal Server][] 连接到你的完整节点的 Electrum 钱包。

  使用硬件安全模块（HSM）、冷钱包和多重签名等先进安全技术的组织可能需要调查 HWI 的设计及其如何与使用[输出脚本描述符][descriptor]和 [BIP174][] PSBT 的 Bitcoin Core 交互。这些下一代密钥和交易数据（及元数据）编码，以及其他进展如 [miniscript][] 策略语言，使得构建和操作与完整节点交互的安全比特币存储解决方案比以往更容易。

- **<!--bitcoin-core-freeze-week-->****Bitcoin Core 冻结周：**按照[计划][Bitcoin Core #14438]，项目已停止接受即将发布的 0.18 主要版本的新功能。正如经常发生的情况，这之前是一周左右的最后时刻审查和合并新功能，这反映在本周的*值得注意的更改*部分中。接下来的两周将专注于开发人员测试和错误修复，随后发布供用户测试的候选版本（RC）。主要版本的 RC 周期通常持续两到四周，然后才最终发布。

  相关的是，项目倾向于在新开发周期的早期合并主要新功能，以便它们尽可能多地进行额外的开发人员测试。在 0.18 分支大约在 3 月 1 日创建之后，任何希望在 0.19 版本（预计 2019 年 10 月发布）中看到某个功能的人建议要么在接下来的两个月内尝试为其打开 PR，要么协助审查现有该功能的 PR。一些需要更多审查或开发的现有 PR 包括支持 BIP156 蒲公英[隐私增强交易中继][Bitcoin Core #13947]、BIP151 [加密 P2P 连接][Bitcoin Core #14032]、BIP157/158 [紧凑区块过滤器][Bitcoin Core #14121]、使用 GNU Guix 简化的[可重复构建][Bitcoin Core #15277]、改进对[外部签名者][Bitcoin Core #14912]（如硬件钱包）的支持、[将钱包与节点分离][Bitcoin Core #10973]以及允许[RBF 对任何交易][Bitcoin Core #10823]在其在内存池中存在超过几小时后。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和 [Bitcoin Improvement Proposals (BIPs)][bips repo] 中值得注意的更改。*

- [Bitcoin Core #15368][] 添加了对输出脚本描述符校验和的支持。[描述符][descriptor]用于监控接收支付和生成新地址，因此校验和通过防止复制错误提高了安全性，这些错误可能导致资金丢失或发送到不可支配的地址。一个 `#` 字符被添加到描述符语法中，用于将描述符与其 8 个字符的校验和分隔，例如 `wpkh(031234...cdef)#012345678`（参见脚注[^fn-example]了解扩展示例）。现在所有 Bitcoin Core RPC 返回的描述符都包含校验和。对于不太容易导致资金损失的 RPC，不要求输入包括校验和，但对于安全至关重要的 RPC，例如 `deriveaddress` 和 `importmulti`，要求用户提供校验和。最后，添加了一个新的 `getdescriptorinfo` RPC，接受一个描述符并返回包含校验和的规范形式以及一些其他信息。

- [Bitcoin Core #13932][] 添加了三个用于管理 PSBT 的新 RPC：`utxoupdatepsbt` 搜索未花费交易输出（UTXO）集合，以查找部分交易所花费的输出。如果这些输出中的任何一个支付了原生 segwit 地址，它会将该输出的详细信息添加到 PSBT 的一个字段中。这些信息是 PSBT 签名者所必需的，因为 [BIP143][] segwit 的签名格式要求签署不直接包含在支出交易中的信息，也不能从签名者的私钥推导出，例如所花费输出的价值。`joinpsbts` 将多个 PSBT 的输入合并为一个 PSBT。`analyzepsbt` 检查 PSBT 并打印用户完成最终化所需的下一步操作。

- [Bitcoin Core #14075][] 为 `importmulti` RPC 添加了一个 `keypool` 参数，允许导入的公钥添加到密钥池中——用于创建新接收地址和找零地址的密钥列表。该选项仅适用于禁用私钥的钱包（参见 [PR#9662][Bitcoin Core #9662]，在 [Newsletter #5][] 中描述）。这允许冷钱包或硬件钱包的用户将其公钥导入观看模式的 Bitcoin Core 钱包，然后正常接收支付。在尝试支付时，钱包可以生成一个未签名的交易——包括一个找零地址——使用 [BIP174][] PSBT 并将其发送到连接到外部钱包进行审查和签名的工具（如 [HWI][]）。

- [Bitcoin Core #14021][] 更改了 `importmulti` RPC，以存储作为[输出脚本描述符][descriptor]一部分包含的任何密钥来源元数据。[密钥来源信息][key origin information]指定了用于生成公钥的 HD 种子和派生路径。当钱包中有密钥来源元数据时，钱包生成的任何 PSBT 都将包含该数据，以允许硬件钱包或其他程序定位签署 PSBT 所需的私钥。参见脚注[^fn-example]了解描述符中密钥来源信息的示例。

- [Bitcoin Core #14481][] 更新了 `listunspent`、`signrawtransactionwithkey` 和 `signrawtransactionwithwallet` RPC，每个包含一个新的 `witnessScript` 字段。第一个 RPC 返回 witnessScript，另外两个可以将其作为输入。之前 Bitcoin Core 过载了现有 P2SH `redeemScript` 字段用于 segwit witnessScripts，但这在 P2SH 包装 segwit 的情况下可能特别令人困惑。此更改明确了哪些数据用于何处。

- [Bitcoin Core #15063][] 允许钱包在 [BIP70][] 支持已禁用的情况下回退到 [BIP21][] 解析 `bitcoin:` URI。正如 [BIP72][] 所规定的那样，`bitcoin:` URI 以向后兼容的方式扩展，包含一个额外的 `r=` 参数，包含 BIP70 URL。这是为了允许已经使用 BIP21 URI 的服务升级以支持 BIP70 而不失去现有用户。然而，现在许多钱包服务正在弃用其 BIP70 支持，相同的机制可以反过来使用，使先前支持 BIP70 的服务允许其非 BIP70 用户通过点击 `bitcoin:` 链接继续获取支付详细信息。

- [Bitcoin Core #15153][] 添加了一个 GUI 菜单以打开钱包，[#15195][Bitcoin Core #15195] 添加了一个菜单以关闭钱包。这使得从 GUI 使用 Bitcoin Core 的多钱包模式变得更容易，尽管目前还不能在不使用调试控制台的情况下从 GUI 创建钱包（该任务是[动态钱包清单][Bitcoin Core #13059]中的最后一项）。

- [Eclair #862][] 现在支持全大写和全小写的支付请求（发票）。不允许混合大小写，根据 [BOLT11][] 规范（该规范基于 [BIP173][] bech32）。

- [BIPs #760][] 更新了 [BIP158][] 紧凑区块过滤器，以添加正确处理数据载体输出（`OP_RETURN` 输出）的额外测试向量。

## 脚注

[^fn-example]:
    带有密钥来源信息和错误检测校验和的描述符格式当前示例：

    ```
    $ bitcoin-cli getaddressinfo bc1qsksdpqqmsyk9654puz259y0r84afzkyqdfspvc | jq .desc
    "wpkh([f6bb4c63/0'/0'/21']034ed70f273611a3f21b205c9151836d6fa9051f74f6e6bbff67238c9ebc7d04f6)#mtdep7g7"
    ```

    解析这个，我们看到如下内容：

    - 地址是一个见证公钥哈希 `wpkh()`，也称为 P2WPKH。描述符可以简洁地描述 P2PKH、P2SH、P2WPKH、P2WSH 和嵌套 segwit 的所有常见用法。

    - **<!--key-origin-information-->[密钥来源信息][key origin information]**在方括号 `[...]` 之间描述。

        - **<!--bip32-keyid-->`f6bb4c63`** 是标识路径提供者密钥的指纹。指纹是其 `ripemd(sha256())` 哈希的前 32 位，如 [BIP32][bip32 keyid] 定义。这使得工具（如与 PSBT 一起使用的工具）可以轻松处理多重签名脚本和其他使用不同密钥的情况。

        - **<!--bip32-->`/0'/0'/21'`** 是 HD 密钥路径，对应于标准 [BIP32][] 表示法中的 `m/0'/0'/21'`。这允许没有预先计算所有公钥的钱包知道生成签名所需的私钥。（Bitcoin Core 预先计算其公钥，因此通常不需要此信息作为冷钱包使用——但具有最小存储和计算速度的硬件钱包需要 HD 路径信息才能有效工作。）

    - 用于生成 P2WPKH 密钥哈希的实际公钥是 `034ed7...04f6`

    - 紧跟 `#` 的校验和保护描述符字符串在导入时免受输入错误影响，`mtdep7g7`


{% include references.md %}
{% include linkers/issues.md issues="14438,13947,14032,14121,15277,14912,10973,10823,15368,13932,14075,9662,14021,14481,15063,15153,15195,13059,862,760" %}
[bip32 keyid]: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#key-identifiers
[eltoo]: https://blockstream.com/eltoo.pdf
[lau output tagging]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016549.html
[nick output tagging]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-February/016667.html
[channel factories]: https://www.tik.ee.ethz.ch/file/a20a865ce40d40c8f942cf206a7cba96/Scalable_Funding_Of_Blockchain_Micropayment_Networks.pdf
[electrum personal server]: https://github.com/chris-belcher/electrum-personal-server
[key origin information]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md#key-origin-identification
[newsletter #5]: /zh/newsletters/2018/07/24/#bitcoin-core-9662
[hwi]: https://github.com/bitcoin-core/HWI
[descriptor]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
[hwi]: https://github.com/bitcoin-core/HWI
[miniscript]: /en/topics/miniscript/
