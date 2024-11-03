---
title: 'Bitcoin Optech Newsletter #102'
permalink: /zh/newsletters/2020/06/17/
name: 2020-06-17-newsletter-zh
slug: 2020-06-17-newsletter-zh
type: newsletter
layout: newsletter
lang: zh
---
本周的 Newsletter 总结了 CoinPool 支付池提案和 WabiSabi 协调的 Coinjoin 协议。还包括我们定期的服务、客户端软件和基础设施软件的值得注意的更改部分。

## 行动项

*本周无行动项。*

## 新闻

- **<!--coinpool-generalized-privacy-for-identifiable-onchain-protocols-->****CoinPool 通用隐私方案，用于可识别的链上协议：** Antoine Riard 和 Gleb Naumenko [发布][coinpool post]了一个关于支付池的提案，旨在通过允许多个用户无需信任地共享对单个 UTXO 的控制，从而改善针对第三方区块链监控的隐私。与之前的支付池设计（如 [joinpool][]）相比，CoinPool 设计的重点是允许参与者对池内成员之间的交易做出链下承诺。借助 [taproot][topic taproot]，这允许合作的参与者使用 UTXO 来操作如闪电网络或 [vaults][topic vaults] 等协议，这些 UTXO 在链上表现得与单密钥 UTXO 无异，从而改善了参与者的隐私并提升了链上可扩展性。从这个意义上来说，该协议作为一种通用的 [channel factory][topic channel factories]，不仅适用于闪电网络，还适用于许多会创建具有独特指纹的链上交易的协议。

  作者概述了 CoinPool 如何利用现有的比特币功能再加上 taproot、[SIGHASH_NOINPUT][topic sighash_anyprevout]，以及通过 Bitcoin Script 使用仅删除累加器的能力（如默克尔树，或类似于提议的 [BIP116][] `OP_MERKLEBRANCHVERIFY`）。他们似乎并未推动一个特定的设计，而是希望展开讨论，研究 CoinPool 或类似机制如何成为钱包默认使用的通用工具，以消除当前和提议的多用户协议的链上痕迹。

- **<!--check-hardware-wallet-compatibility-->****WabiSabi 协调的具有任意输出值的 Coinjoin：** 在 [coinjoin][topic coinjoin] 协议中，一组用户协作创建一个交易模板，以便使用他们现有的 UTXO（输入）生成一组新的 UTXO（输出）。创建此交易模板的方式对 Coinjoin 提供的隐私有重要影响，不同的实现方式使用了不同的方法：

  <p><!-- Taker creates tx template, see discussion between harding and waxwing: http://gnusha.org/joinmarket/2020-06-14.log --></p>

  - [Joinmarket][] 有两类用户：支付进行 Coinjoin 的用户（*市场需求方*）和为 Coinjoin 提供 UTXO 而获得报酬的用户（*市场供给方*）。为了创建 Coinjoin，需求方联系多个供给方，收集他们的输入和输出信息并创建交易模板。这使得需求方能够了解 Coinjoin 中所有参与者的输入和输出之间的对应关系，但也保证了每个供给方只知道自己输入和输出之间的对应关系。需求方直接获得 Coinjoin 的隐私收益，而供给方则直接获得提供流动性的收入。如果需求方保护了他们自己的隐私，供给方也间接获得了针对第三方区块链监控的增强隐私。希望获得隐私保证的供给方可以在几轮混合中作为需求方操作。

    <p><!-- Quotes from joinmarket README.md:
      - "Ability to spend directly, or with coinjoin"
      - "Can specify exact amount of coinjoin (figures from 0.01 to 30.0 btc"
    --></p>

    这种模式为需求方提供了很大的灵活性，可以自由决定交易模板中的输入和输出。例如，需求方可以选择他们希望创建的 Coinjoin 数量，或在 Coinjoin 中将其资金转移给第三方。

  - [Wasabi][] 使用一个集中协调者来组织使用该软件创建的每个 Coinjoin。为了防止该协调者了解输入与输出之间的关系，用户匿名提交他们希望创建的输出，并获得对承诺进行[盲签名][chaumian blinded signature]。随后，每个用户通过另一个匿名身份连接，并提交每个输出及其解盲后的签名。签名由协调者提供，但解盲后的签名无法追溯到接收盲签名的特定用户。这使得在不让协调者知道输入资金来源的情况下，可以构建交易模板。

    由于协调者在创建盲签名时无法查看输出，因此它不能允许用户指定任意金额，否则用户可能会试图在 Coinjoin 中获取比他们贡献的更多的资金。虽然这不是一个安全风险——其他参与者会拒绝签署任何格式错误的交易——但这种失败会导致协议重启。如果允许任意金额，盲化过程将阻止识别出撒谎的用户，从而无法将其禁止在未来的混合轮次中，这将允许对协议进行无限制的拒绝服务攻击。因此，Wasabi 要求所有输出要么属于一组允许的金额（例如 0.1 BTC、0.2 BTC、0.4 BTC 等），要么是一个未盲化的找零输出。这限制了使用 Wasabi 进行用户指定金额的支付或任意金额的支付。

  本周，几位 Wasabi 的贡献者[发布][wabisabi post]了一个新的协议，称为 WabiSabi，该协议在概念上扩展了现有协议，并采用了[秘密交易][confidential transactions]中的技术。这样可以让客户端对任意输出金额创建承诺，并且在不暴露金额的情况下证明每个金额都在一个指定范围内（例如 0.0001 BTC 到 2100 万 BTC），并且它们的总和为一个指定值。协调者使用此指定值验证客户端要创建的输出总和等于客户端提供的输入总和（减去费用）。然后，协调者可以为每个输出提供一个匿名凭证，使客户端能够稍后匿名向协调者提交该输出以纳入交易模板。

  实现该协议的软件将能够创建协调的 Coinjoin，使客户端可以选择他们的输出金额，从而为不等值 Coinjoin（参见 [Newsletter #79][news79 unequal coinjoin]）和在 Coinjoin 中进行支付（无论是向 Coinjoin 之外的第三方支付，还是向 Coinjoin 内的参与方支付）提供实验机会。

  提议的协议与当前的 Wasabi 协议存在显著差异（例如用键验证匿名凭证替代了盲签名），因此其作者正在寻求对该协议的审查、批评以及关于如何最有效使用该协议的建议。

## 服务和客户端软件的更改

*在这个每月特辑中，我们重点介绍比特币钱包和服务的有趣更新。*

- **<!--caravan-adds-hd-wallet-support-coin-control-and-hardware-wallet-test-suite-->****Caravan 添加了 HD 钱包支持、币控制和硬件钱包测试套件：** 除了单地址多签协调外，Caravan 现在还支持 HD 钱包的多签协调和币控制功能。Caravan 的创建者 Unchained Capital 还[宣布][unchained caravan blog]了一个用于测试硬件钱包在浏览器中交互和 Trezor 多签地址确认的测试套件。

- **<!--bitpay-s-copay-and-bitcore-projects-support-native-segwit-->****Bitpay 的 Copay 和 Bitcore 项目支持原生 segwit：** Bitpay 的 [Copay 钱包][copay segwit]和后端 [Bitcore 服务][bitcore segwit]现在均支持接收和花费原生 segwit 输出。

- **<!--desktop-version-of-blockstream-green-wallet-->****Blockstream Green 钱包桌面版本：** Blockstream 已发布其 [Green 钱包桌面版][blockstream green desktop blog]，支持 macOS、Windows 和 Linux。桌面版支持 2-of-3 和 2-of-2 多签钱包，以及 Tor 和测试网。

- **<!--react-native-library-photon-lib-announced-->****React native 库 photon-lib 宣布：** [Tankred Hase 共享][photon-lib tweet]了一个新的库 [photon-lib][]，用于使用 React Native 构建比特币钱包功能。该库支持 HD 钱包和轻客户端功能，但仍在开发中，尚未准备好投入生产。

## 值得注意的代码和文档更改

*本周在 [Bitcoin Core][bitcoin core repo]、[C-Lightning][c-lightning repo]、[Eclair][eclair repo]、[LND][lnd repo]、[Rust-Lightning][rust-lightning repo]、[libsecp256k1][libsecp256k1 repo]、[Bitcoin 改进提案（BIPs）][bips repo]和[闪电网络规范][bolts repo]中的值得注意的更改。*

- [BIPs #910][] 将 [BIP85][] 分配给 Ethan Kosakovsky 的从 BIP32 密钥链生成确定性熵的提案。BIP85 描述了一个超级密钥链，其子密钥可以用于创建传统的 HD 密钥链种子。有关该提案的更多详情，请参见 [Newsletter #93][news93 bip32 keychains]。

{% include references.md %}
{% include linkers/issues.md issues="910" %}
[coinpool post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/017964.html
[joinpool]: https://gist.github.com/harding/a30864d0315a0cebd7de3732f5bd88f0
[joinmarket]: https://github.com/JoinMarket-Org/joinmarket-clientserver
[wasabi]: https://wasabiwallet.io/
[wabisabi post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/017969.html
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
