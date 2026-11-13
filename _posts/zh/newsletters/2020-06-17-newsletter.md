---
title: 'Bitcoin Optech Newsletter #102'
permalink: /zh/newsletters/2020/06/17/
name: 2020-06-17-newsletter-zh
slug: 2020-06-17-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了 CoinPool 支付池提案，以及 WabiSabi 协调式 coinjoin 协议。我们还照例收录了值得注意的服务、客户端软件与基础设施软件变更。

## 行动项

*本周无行动项。*

## 新闻

- **<!--coinpool-generalized-privacy-for-identifiable-onchain-protocols-->****CoinPool：为可识别的链上协议提供一种通用隐私方案：** Antoine Riard 和 Gleb Naumenko 在 Bitcoin-Dev 邮件列表上[发帖][coinpool post]，讨论支付池——这是一种通过允许多个用户无需信任地共享对单个 UTXO 的控制，来改善对第三方区块链监控之隐私性的技术。与之前的支付池设计（如 [joinpool][]）相比，CoinPool 设计的重点是允许参与者对池内成员之间的交易做出链下承诺。借助 [taproot][topic taproot]，合作的参与者就能用与单密钥 UTXO 无法区分的 UTXO 来运行 LN 或 [vaults][topic vaults] 等协议，既改善参与者隐私，也提升链上可扩展性。从这个意义上说，该协议相当于一种通用的 [channel factory][topic channel factories]，不仅适用于 LN，也适用于许多会创建带独特指纹的链上交易的协议。

  作者概述了 CoinPool 如何利用现有的比特币功能再加上 taproot、[SIGHASH_NOINPUT][topic sighash_anyprevout]，以及通过 Bitcoin Script 使用仅删除累加器的能力（如默克尔树，或类似于提议的 [BIP116][] `OP_MERKLEBRANCHVERIFY`）。他们似乎并未推动一个特定的设计，而是希望展开讨论，研究 CoinPool 或类似机制如何成为一种钱包默认使用的通用机制，以消除现有和拟议中各种多用户协议的链上痕迹。

- **<!--wabisabi-coordinated-coinjoins-with-arbitrary-output-values-->****WabiSabi 协调的具有任意输出值的 coinjoin：** 在 [coinjoin][topic coinjoin] 协议中，一组用户协作创建一个交易模板，花费各自现有的一些 UTXO（输入），生成一组新的 UTXO（输出）。创建这笔交易模板的方式会影响 coinjoin 提供的隐私，不同的实现采用了不同做法：

  <p><!-- Taker creates tx template, see discussion between harding and waxwing: http://gnusha.org/joinmarket/2020-06-14.log --></p>

  - [Joinmarket][] 有两类用户：付费参与 coinjoin 的用户（*市场需求方*）和为 coinjoin 提供 UTXO 而获得报酬的用户（*市场供给方*）。为了创建 coinjoin，需求方联系多个供给方，收集他们的输入和输出信息并创建交易模板。这让需求方得以了解 coinjoin 中所有参与者的输入与输出的对应关系，但也保证每个供给方只知道自己哪些输入为自己的哪些输出提供资金。需求方直接获得 coinjoin 带来的隐私收益，而供给方则直接获得提供流动性的收入。如果需求方维护好自己的个人隐私，供给方也能间接获得针对第三方区块链监控的更强隐私。希望获得隐私保障的供给方，随时可以作为需求方参与几轮混合。

    <p><!-- Quotes from joinmarket README.md:
      - "Ability to spend directly, or with coinjoin"
      - "Can specify exact amount of coinjoin (figures from 0.01 to 30.0 btc"
    --></p>

    这种模式让需求方在决定交易模板中自己的输入和输出时拥有很大灵活性。例如，需求方可以选择自己想创建的 coinjoin 金额，也可以在 coinjoin 过程中把资金支付给第三方。

  - [Wasabi][] 使用一个中心化协调者来组织用该软件创建的每一次 coinjoin。为了防止该协调者知道哪些输入为哪些输出提供资金，用户匿名对自己想要创建的输出作出承诺，并获得对承诺的 [Chaumian 盲签名][chaumian blinded signature]。之后，每个用户以另一个匿名身份连接，提交每个输出及其解盲后的签名。该签名可证明来自协调者，但解盲后的签名无法与收到盲签名的特定用户关联起来。这样一来，无需协调者知道哪些输入为哪些输出提供资金，也能构建交易模板。

    由于协调者在创建盲签名时看不到输出，它就不能允许用户指定任意金额，否则用户可能试图在 coinjoin 中拿到比自己投入更多的钱。这不算安全风险——其他参与者会拒绝签署任何格式错误的交易——但这类失败需要重启协议。如果允许任意金额，盲化就会妨碍识别撒谎的用户，也无法在后续轮次中禁止其参与，从而使该协议可被无限制地发起拒绝服务攻击。因此，Wasabi 要求所有输出要么属于少数几种允许的金额（例如 0.1 BTC、0.2 BTC、0.4 BTC 等），要么是未盲化的找零输出。这限制了 Wasabi 支持用户指定金额、以及支持用任意金额付款的能力。

  本周，几位 Wasabi 贡献者在 Bitcoin-Dev 邮件列表上[发帖][wabisabi post]，介绍了一个他们称为 WabiSabi 的新协议；该协议在概念上扩展了现有协议，采用了[机密交易][confidential transactions]中的一种技术。这让客户端能对任意输出金额作出承诺，并在不暴露金额的前提下证明每个金额都各自处于指定范围内（例如 0.0001 BTC 到 2100 万 BTC），且它们的总和为某个指定值。协调者用这个指定值来验证：客户端想要创建的输出总和，等于客户端提供的输入总和（扣除手续费）。随后，协调者可以为每个输出签发一份匿名凭证，让客户端之后能匿名地把该输出提交给协调者，纳入交易模板。

  实现该协议的软件将能创建协调式 coinjoin，让客户端自行选择输出金额，从而便于试验不等值 coinjoin（参见 [Newsletter #79][news79 unequal coinjoin]），以及在 coinjoin 内部完成支付（既可付给未参与该 coinjoin 的第三方，也可付给该 coinjoin 内的参与方）。

  拟议协议与 Wasabi 当前协议有大量差异（例如以带密钥验证的匿名凭证取代盲签名），因此其作者正在征求意见、批评，以及有关如何最有效使用该协议的建议。

## 服务和客户端软件的变更

*在本月栏目中，我们重点介绍 Bitcoin 钱包与服务的一些有趣更新。*

- **<!--caravan-adds-hd-wallet-support-coin-control-and-hardware-wallet-test-suite-->****Caravan 新增 HD 钱包支持、选币控制与硬件钱包测试套件：** 除了单地址多重签名协调之外，Caravan 现在还支持 HD 钱包多重签名协调和选币控制功能。Caravan 的创建者 Unchained Capital 还[宣布][unchained caravan blog]了一套测试套件，用于测试硬件钱包在浏览器中的交互，以及 Trezor 多重签名地址确认。

- **<!--bitpay-s-copay-and-bitcore-projects-support-native-segwit-->****Bitpay 的 Copay 和 Bitcore 项目支持原生 segwit：** Bitpay 的 [Copay 钱包][copay segwit]和后端 [Bitcore 服务][bitcore segwit]现在均支持接收和花费原生 segwit 输出。

- **<!--desktop-version-of-blockstream-green-wallet-->****Blockstream Green 钱包桌面版：** Blockstream 已发布其 [Green 钱包桌面版][blockstream green desktop blog]，支持 macOS、Windows 和 Linux。桌面版支持 2-of-3 和 2-of-2 多重签名钱包，以及 Tor 和测试网。

- **<!--react-native-library-photon-lib-announced-->****React Native 库 photon-lib 发布：** [Tankred Hase 分享][photon-lib tweet]了一个新的库 [photon-lib][]，用于通过 React Native 构建比特币钱包功能。该库支持 HD 钱包和轻客户端功能，但仍在开发中，尚未达到生产可用的程度。

## 值得注意的代码与文档变更

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Bitcoin 改进提案（BIPs）][bips repo]和[闪电网络 BOLT 规范][bolts repo]中的值得注意的变更。*

- [BIPs #910][] 将 [BIP85][] 分配给 Ethan Kosakovsky 的从 BIP32 密钥链生成确定性熵的提案。BIP85 描述了一条超级密钥链，其子密钥可用于创建传统 HD 密钥链的种子。有关该提案的更多细节，请参见 [Newsletter #93][news93 bip32 keychains]。

{% include references.md %}
{% include linkers/issues.md issues="910" %}
[coinpool post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/017964.html
[joinpool]: https://gist.github.com/harding/a30864d0315a0cebd7de3732f5bd88f0
[joinmarket]: https://github.com/JoinMarket-Org/joinmarket-clientserver
[wasabi]: https://wasabiwallet.io/
[wabisabi post]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/017969.html
[news79 unequal coinjoin]: /zh/newsletters/2020/01/08/#coinjoins-without-equal-value-inputs-or-outputs
[chaumian blinded signature]: https://en.wikipedia.org/wiki/Blind_signature
[confidential transactions]: https://en.bitcoin.it/wiki/Confidential_transactions
[news93 bip32 keychains]: /zh/newsletters/2020/04/15/#proposal-for-using-one-bip32-keychain-to-seed-multiple-child-keychains
[unchained caravan blog]: https://unchained-capital.com/blog/gearing-up-the-caravan/
[blockstream green desktop blog]: https://blockstream.com/2020/05/21/en-blockstream-green-now-on-desktop/
[photon-lib tweet]: https://twitter.com/tankredhase/status/1265640624973246465
[photon-lib]: https://github.com/photon-sdk/photon-lib
[copay segwit]: https://github.com/bitpay/copay/pull/10766
[bitcore segwit]: https://github.com/bitpay/bitcore/pull/2418
