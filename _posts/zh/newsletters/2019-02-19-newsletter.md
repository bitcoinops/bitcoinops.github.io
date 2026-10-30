---
title: 'Bitcoin Optech Newsletter #34'
permalink: /zh/newsletters/2019/02/19/
name: 2019-02-19-newsletter-zh
slug: 2019-02-19-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了一场关于为 BIP118 SIGHASH_NOINPUT_UNSAFE 标记输出的讨论，宣布若干合并已到位，使 Bitcoin Core 内置钱包能以只读（watch-only）模式配合硬件钱包使用，并介绍了下一个 Bitcoin Core 版本功能冻结的完成情况。同时还总结了热门 Bitcoin 基础设施项目中大量的代码与文档变更。

## 行动项

本周无。

## 新闻

- **<!--discussion-about-tagging-outputs-to-enable-restricted-features-on-spending-->****关于标记输出以启用受限花费功能的讨论：**[BIP118][] SIGHASH_NOINPUT_UNSAFE（noinput）提案允许签名者在生成授权花费某个 UTXO 的签名时，选择允许该签名被重复使用（“重放”），去花费发送到同一公钥的其他 UTXO。当它与支付通道这类协议配合使用时可启用新功能——这些协议中的各方共用同一组公钥（参见为 LN 提议的 [Eltoo][] 层）。但它也可能带来*重放攻击*：用户重复使用地址时就可能损失资金。例如：Alice 动用了她此前收到、发往自己某个地址的一枚比特币，并用 SIGHASH_NOINPUT_UNSAFE 签名向 Bob 支付。后来有人又向 Alice 的同一地址打了款，本意是再给她一些钱。现在 Bob（或任何其他人）只要重放 Alice 之前那个签名，就能把这笔输出发给 Bob。

  避免这种事故的办法之一，就是在功能名称后面加上“UNSAFE”，促使开发者在自己的工具里实现它之前先了解协议的细微之处。不过，一些开发者一直在寻找额外的防错手段。去年 12 月，Johnson Lau [提议][lau output tagging]：只有当被花费的输出在创建时就被特别标记为允许使用 noinput，才允许使用 noinput。这样，只有付款方和收款方都同意时（例如支付通道）才能用上该功能，从而避免因沟通失误或理解偏差而损失资金。

  [上周重启的讨论][nick output tagging]以及本周的讨论，分析了这会对 Eltoo 和 [Channel Factories][] 等提议的二层协议产生什么影响。尽管标记增加了复杂性，但普遍看法是它不会从根本上增加成本，也不会降低所描述提案的有效性，不过可能让这些提案的隐私性略差一些。

- **<!--bitcoin-core-preliminary-hardware-wallet-support-->****Bitcoin Core 初步硬件钱包支持：**经过数月的渐进改进，本周合并了最后一批 PR，使 Bitcoin Core 的主开发分支能够借助[硬件钱包交互][HWI]（HWI）工具，与硬件钱包配合接收和发送交易。HWI 是 Bitcoin Core 项目的一部分，但尚未随 Bitcoin Core 软件一起分发，目前只能通过命令行访问。它提供了一个坚实的基础，可以在其上构建工具，让外部密钥存储轻松配合 Bitcoin Core 的原生钱包和全验证节点使用。另外需要注意的是，通过 [Electrum Personal Server][]，已经可以把硬件钱包连接到那个接入你全节点的 Electrum 钱包上。

  使用硬件安全模块（HSM）、冷钱包和多重签名等先进安全技术的组织，可能需要研究 HWI 的设计，以及它如何通过[输出脚本描述符][descriptor]和 [BIP174][] PSBT 与 Bitcoin Core 交互。这些下一代密钥和交易数据（及元数据）编码，以及其他进展如 [miniscript][] 策略语言，使得构建和操作与完整节点交互的安全比特币存储解决方案比以往更容易。

- **<!--bitcoin-core-freeze-week-->****Bitcoin Core 冻结周：**按照[计划][Bitcoin Core #14438]，项目已停止接受即将发布的 0.18 主要版本的新功能。正如经常发生的那样，在此之前大约有一周时间，大家都在做最后一刻的审查和合并新功能，这一点从下面*值得注意的变更*部分那份长长的清单中也能看出来。接下来的两周将专注于开发者测试和错误修复，然后再发布供用户测试的候选版本（RC）。主要版本的 RC 周期通常持续两到四周，之后才会最终发布。

  相关的一点是，项目倾向于在新开发周期早期合并主要新功能，以便它们能得到尽可能多的额外开发者测试。0.18 分支大约在 3 月 1 日创建；此后，任何希望某个功能出现在 0.19 版本（预计 2019 年 10 月发布）中的人，最好在接下来的两个月内为该功能提交 PR，或者协助审查该功能已有的 PR。一些仍需更多审查或开发的现有 PR 包括：BIP156 蒲公英[隐私增强交易中继][Bitcoin Core #13947]、BIP151 [加密 P2P 连接][Bitcoin Core #14032]、BIP157/158 [紧凑区块过滤器][Bitcoin Core #14121]、使用 GNU Guix 简化[可复现构建][Bitcoin Core #15277]、改进对[外部签名者][Bitcoin Core #14912]（如硬件钱包）的支持、[把钱包与节点分开][Bitcoin Core #10973]，以及允许对已在内存池中停留数小时以上的任何交易进行 [RBF][Bitcoin Core #10823]。

## 值得注意的代码与文档变更

*本周 [Bitcoin Core][bitcoin core repo]、[LND][lnd repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[libsecp256k1][libsecp256k1 repo] 和[比特币改进提案（BIPs）][bips repo]中值得注意的变更。*

- [Bitcoin Core #15368][] 为输出脚本描述符增加了校验和支持。[描述符][descriptor]用于监控收到的付款并生成新地址，因此校验和能防止复制错误，提高安全性，避免资金去向不明或被发送到无法花费的地址。描述符语法中新增了 `#` 字符，用于把描述符与其 8 个字符的校验和分隔开，例如 `wpkh(031234...cdef)#012345678`（扩展示例见脚注[^fn-example]）。现在所有返回描述符的 Bitcoin Core RPC 都会附带校验和。对于不太会有资金损失风险的 RPC，不要求输入中包含校验和；但对于安全至关重要的 RPC，例如 `deriveaddress` 和 `importmulti`，已改为要求用户提供校验和。最后，新增了 `getdescriptorinfo` RPC，它接受一个描述符，返回包含校验和的规范化形式，以及一些其他信息。

- [Bitcoin Core #13932][] 添加了三个用于管理 PSBT 的新 RPC：`utxoupdatepsbt` 搜索未花费交易输出（UTXO）集合，以查找部分交易所花费的输出。如果这些输出中的任何一个支付了原生 segwit 地址，它会将该输出的详细信息添加到 PSBT 的一个字段中。这些信息是 PSBT 签名者所必需的，因为 segwit 的 [BIP143][] 签名格式要求对某些信息签名，而这些信息既不直接包含在支出交易中，也无法从签名者的私钥推导出来，例如被花费输出的金额。`joinpsbts` 将多个 PSBT 的输入合并为一个 PSBT。`analyzepsbt` 检查 PSBT，并打印出用户为最终完成它需要采取的下一步。

- [Bitcoin Core #14075][] 为 `importmulti` RPC 添加了一个 `keypool` 参数，允许把导入的公钥加入密钥池——即用于创建新接收地址和找零地址的密钥列表。该选项只对已禁用私钥的钱包可用（参见 [PR#9662][Bitcoin Core #9662]，在 [Newsletter #5][] 中描述）。这使冷钱包或硬件钱包用户可以把公钥导入只读模式的 Bitcoin Core 钱包，然后正常接收支付。在尝试付款时，钱包可以用 [BIP174][] PSBT 生成一笔未签名的交易（其中包含找零地址），再把它发给 [HWI][] 之类的工具，由该工具连接外部钱包进行审核和签名。

- [Bitcoin Core #14021][] 更改了 `importmulti` RPC，以存储作为[输出脚本描述符][descriptor]一部分包含的任何密钥来源元数据。[密钥来源信息][key origin information]指定了用于生成公钥的 HD 种子和派生路径。当钱包中有密钥来源元数据时，钱包生成的任何 PSBT 都将包含该数据，以允许硬件钱包或其他程序定位签署 PSBT 所需的私钥。参见脚注[^fn-example]了解描述符中密钥来源信息的示例。

- [Bitcoin Core #14481][] 更新了 `listunspent`、`signrawtransactionwithkey` 和 `signrawtransactionwithwallet` RPC，分别为它们增加了新的 `witnessScript` 字段。第一个 RPC 返回 witnessScript，另外两个可以将其作为输入。此前 Bitcoin Core 把现有的 P2SH `redeemScript` 字段挪用来存放 segwit 的 witnessScript，但在 P2SH 包装 segwit 的情况下，这可能格外令人困惑。这项更改明确了哪份数据该放在哪里。

- [Bitcoin Core #15063][] 允许钱包在 [BIP70][] 支持被禁用时，回退为按 [BIP21][] 解析 `bitcoin:` URI。按照 [BIP72][] 的规定，`bitcoin:` URI 曾以向后兼容的方式扩展，增加了一个 `r=` 参数，用来存放 BIP70 的 URL。这样做的目的是让已经在使用 BIP21 URI 的服务能够升级支持 BIP70，同时不流失现有用户。但如今许多钱包和服务都在弃用 BIP70 支持，同一套机制也可以反过来用：过去支持 BIP70 的服务，可以让不依赖 BIP70 的用户仅仅点击 `bitcoin:` 链接就继续拿到付款详情。

- [Bitcoin Core #15153][] 添加了一个 GUI 菜单以打开钱包，[#15195][Bitcoin Core #15195] 添加了一个菜单以关闭钱包。这使得从 GUI 使用 Bitcoin Core 的多钱包模式容易得多，尽管目前还不能在不使用调试控制台的情况下从 GUI 创建钱包（该任务是[动态钱包清单][Bitcoin Core #13059]中的最后一项）。

- [Eclair #862][] 现在支持全大写和全小写的支付请求（发票）。按 [BOLT11][] 规范，不允许大小写混用（该规范基于 [BIP173][] bech32）。

- [BIPs #760][] 更新了 [BIP158][] 紧凑区块过滤器，以添加正确处理数据载体输出（`OP_RETURN` 输出）的额外测试向量。

## 脚注

[^fn-example]:
    下面是一个描述符格式的当前示例，其中包含密钥来源信息和可检错的校验和：

    ```
    $ bitcoin-cli getaddressinfo bc1qsksdpqqmsyk9654puz259y0r84afzkyqdfspvc | jq .desc
    "wpkh([f6bb4c63/0'/0'/21']034ed70f273611a3f21b205c9151836d6fa9051f74f6e6bbff67238c9ebc7d04f6)#mtdep7g7"
    ```

    解析这个描述符，可以看到以下内容：

    - 这个地址属于见证公钥哈希（Witness Public Key Hash）类型 `wpkh()`，也称为 P2WPKH。描述符可以简洁地描述 P2PKH、P2SH、P2WPKH、P2WSH 和嵌套 segwit 的所有常见用法。

    - **<!--key-origin-information-->[密钥来源信息][key origin information]**用方括号 `[...]` 表示。

        - **<!--bip32-keyid-->`f6bb4c63`** 是用于标识所给路径根部那把密钥的指纹。指纹是其 `ripemd(sha256())` 哈希的前 32 位，如 [BIP32][bip32 keyid] 所定义。这样一来，工具（例如与 PSBT 配合使用的工具）就能轻松处理多重签名脚本，以及其他需要多个签名设备、各用不同密钥的情况。

        - **<!--bip32-->`/0'/0'/21'`** 是 HD 密钥路径，对应于标准 [BIP32][] 表示法中的 `m/0'/0'/21'`。这让没有预先算出全部公钥的钱包也能知道，要生成签名该用哪把私钥。（Bitcoin Core 会预先计算自己的公钥，因此作为冷钱包使用时通常不需要这类信息——但存储空间和算力都很有限的硬件钱包需要 HD 路径信息才能高效工作。）

    - 用于生成 P2WPKH 密钥哈希的实际公钥是 `034ed7...04f6`

    - `#` 之后的校验和 `mtdep7g7` 可以保护描述符字符串，使其在导入时不受输入错误的影响


{% include references.md %}
{% include linkers/issues.md issues="14438,13947,14032,14121,15277,14912,10973,10823,15368,13932,14075,9662,14021,14481,15063,15153,15195,13059,862,760" %}
[bip32 keyid]: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#key-identifiers
[eltoo]: https://blockstream.com/eltoo.pdf
[lau output tagging]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-December/016549.html
[nick output tagging]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-February/016667.html
[channel factories]: https://www.tik.ee.ethz.ch/file/a20a865ce40d40c8f942cf206a7cba96/Scalable_Funding_Of_Blockchain_Micropayment_Networks.pdf
[electrum personal server]: https://github.com/chris-belcher/electrum-personal-server
[key origin information]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md#key-origin-identification
[newsletter #5]: /zh/newsletters/2018/07/24/#bitcoin-core-9662
[hwi]: https://github.com/bitcoin-core/HWI
[descriptor]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
[miniscript]: /en/topics/miniscript/
