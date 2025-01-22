{% auto_anchor %}
对于已经支持接收和使用 v0 segwit P2WPKH 输出的钱包来说，将其升级到用于单签的 v1 segwit P2TR 应该相对容易。以下是主要步骤：

- **<!--use-a-new-bip32-key-derivation-path-->****使用新的 BIP32 密钥推导路径：** 你不需要修改你的 [BIP32][] 分层确定性 (HD) 代码，并且你的用户也不需要更换种子。[^electrum-segwit] 然而，我们强烈建议你为你的 P2TR 公钥使用新的推导路径（例如由 [BIP86][] 定义）；如果你不这样做，当你在 ECDSA 和 [schnorr 签名][topic schnorr signatures]两者中都使用相同密钥时，可能会导致[潜在攻击][bip340 alt signing]。

- **<!--tweak-your-public-key-by-its-hash-->****通过其哈希值调整你的公钥：** 尽管在单签场景中技术上并非必须，尤其当你的所有密钥都来自随机选定的 BIP32 种子时，BIP341 [建议][bip341 cite22]让你的密钥承诺到一个不可花费的脚本哈希树中。其操作很简单，只需要使用椭圆曲线加法操作，将你的公钥与该公钥哈希得到的曲线点相加即可。遵循这一建议的好处在于，如果你日后添加无脚本的[多签][topic multisignature]支持，或者为 [`tr()` 描述符][`tr()` descriptors]添加支持，你也可以使用相同的代码。

- **<!--create-your-addresses-and-monitor-for-them-->****创建你的地址并进行监控：** 使用 [bech32m][topic bech32] 来创建你的地址。付款将发送到脚本 `OP_1 <tweaked_pubkey>`。你可以使用与扫描 v0 segwit 地址（如 P2WPKH）相同的方法来扫描支付到该脚本的交易。

- **<!--creating-a-spending-transaction-->****创建支出交易：** 对于 taproot 来说，所有的非见证字段都与 P2WPKH 相同，因此你无需担心交易序列化的改变。

- **<!--create-a-signature-message-->****创建签名消息：** 这是对支出交易数据的承诺。大部分数据与为 P2WPKH 交易所签名的内容相同，但字段的顺序[已改变][BIP341 sigmsg]，并且有一些额外内容需要签名。实现这一点只需要对各种数据进行序列化和哈希处理，所以编写这部分代码应该相对容易。

- **<!--sign-a-hash-of-the-signature-message-->****对签名消息的哈希进行签名：** 生成 schnorr 签名有多种方法。最好的方式是不“自己动手写加密”而是使用你信任的、经过充分审阅的库提供的函数。但如果因某些原因你无法这样做，[BIP340][] 提供了一种算法，如果你已经有可用于制作 ECDSA 签名的原语，那么实现它应该相当简单。当你获得签名后，将其放入输入的见证数据中，然后发送你的支出交易。

即使在 taproot 于区块 {{site.trb}} 激活之前，你也可以使用 testnet、公用默认 [signet][topic signet] 或者 Bitcoin Core 的私有 regtest 模式来测试你的代码。如果你为开源钱包添加了 taproot 支持，我们鼓励你将实现它的拉取请求链接添加到 Bitcoin Wiki 上的 [taproot 用法][wiki taproot uses]和 [bech32m 采用][wiki bech32 adoption]页面，以便其他开发者可以从你的代码中学习。

[^electrum-segwit]:
    当 Electrum 升级到 segwit v0 时，要求任何希望使用 bech32 地址接收资金的用户都生成新的种子。虽然这在技术上并非必要，但它使 Electrum 的作者能够在其自定义种子推导方法中引入一些新的[功能][electrum seeds]。其中一个功能是允许通过种子版本号来指定一个种子应当使用的脚本。这使得旧脚本可以被安全地逐步弃用（例如，未来某个版本的 Electrum 可能会发布，它将不再支持接收到传统的 P2PKH 地址）。

    大约在 Electrum 开发者部署其版本化种子同期，Bitcoin Core 的开发者开始使用 [输出脚本描述符][topic descriptors] 来解决相同的问题——允许逐步弃用脚本（同时也解决了其他问题）。下表对比了 Electrum 的版本化种子和 Bitcoin Core 的描述符与此前两者都使用的 *隐式脚本* 方法（目前在大多数其他钱包中仍普遍使用）。

    <table>
    <tr>
    <th>脚本管理</th>
    <th>初始备份</th>
    <th>引入新脚本</th>
    <th>扫描（带宽/CPU 成本）</th>
    <th>弃用脚本</th>
    </tr>

    <tr>
    <th markdown="1">

    隐式脚本（例如 [BIP44][]）

    </th>
    <td>种子词</td>
    <td>自动（无需用户操作）</td>
    <td>必须扫描所有受支持的脚本，O(n)</td>
    <td>无法警告用户他们使用了不受支持的脚本</td>
    </tr>

    <tr>
    <th>显式脚本（版本化种子）</th>
    <td>种子词（包含版本位）</td>
    <td>用户必须备份新的种子；资金要么被拆分到两个独立钱包中，要么需要用户将旧钱包的资金转移到新钱包</td>
    <td>只扫描单一脚本模板，O(1)</td>
    <td>警告用户有关不受支持的脚本</td>
    </tr>

    <tr>
    <th markdown="1">

    显式脚本（[描述符][topic descriptors]）

    </th>
    <td>种子词和描述符</td>
    <td>用户必须备份新的描述符</td>
    <td>仅扫描实际使用过的脚本模板，O(n)；对于新钱包而言 n=1</td>
    <td>警告用户有关不受支持的脚本</td>
    </tr>
    </table>

{% include linkers/issues.md issues="" %}
[electrum seeds]: https://electrum.readthedocs.io/en/latest/seedphrase.html#motivation
[bip340 alt signing]: https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki#alternative-signing
[bip341 cite22]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#cite_note-22
[`tr()` descriptors]: /zh/preparing-for-taproot/#taproot-描述符
[bip341 sigmsg]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#common-signature-message
[wiki bech32 adoption]: https://en.bitcoin.it/wiki/Bech32_adoption
[wiki taproot uses]: https://en.bitcoin.it/wiki/Taproot_Uses
{% endauto_anchor %}
