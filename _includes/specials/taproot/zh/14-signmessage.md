自四年前隔离见证（segwit）激活以来，尚未形成被广泛接受的为 [Bech32 或 Bech32m][topic bech32] 地址创建签名消息的方式。可以说，我们现在可以认为广泛的消息签名支持对用户或开发者而言并不十分重要，否则会有更多工作投入其中。但相较于过去使用传统地址时用户可便捷交换签名消息的情况，比特币钱包软件的功能似乎有所倒退。

我们在两年前关于 [Bech32 消费支持][bech32ss signmessage] 系列文章中提到的[通用 Signmessage][topic generic signmessage] 方案进展甚微，即便其协议文档 [BIP322][] 偶有更新（参见 Newsletter [#118][news118 virttx] 和 [#130][news130 inconclusive]），也未被 Bitcoin Core 采用。尽管如此，我们尚未发现更优替代方案，因此任何希望在 P2TR 钱包中添加 Signmessage 功能的开发者仍应将 BIP322 作为首选。

若得以实现，通用 Signmessage 协议将支持为以下类型的 P2TR 输出签名：纯单签、使用[多签][topic multisignature]或任何 [Tapscript][topic tapscript] 脚本。该协议还将向后兼容所有传统及 Bech32 地址，并向前兼容目前规划的近期变更类型（部分内容将在后续*为 Taproot 激活做准备*专栏中预告）。能够访问完整 UTXO 集的应用（例如通过全节点）还可利用 BIP322 生成和验证[储备证明][bip322 reserve proofs]，以证明签名者在特定时间点控制特定数量的比特币。

实现通用签名消息功能的创建相对简单。BIP322 采用称为*虚拟交易*的技术：首笔虚拟交易通过尝试花费不存在的先前交易（txid 全为零）构造为无效交易，该交易支付至用户需签名的地址（脚本）并包含对目标消息的哈希承诺；第二笔交易花费首笔交易的输出——若该花费的签名及其他数据构成有效交易，则视为消息已签名（尽管第二笔虚拟交易仍无法上链，因其源自无效的前序交易）。

对多数钱包而言，验证通用签名消息更为复杂。要完全验证*任意* BIP322 消息需实现比特币几乎所有的共识规则。多数钱包不具备此能力，因此 BIP322 允许其在无法完整验证脚本时返回"不确定"状态。实践中，尤其是 Taproot 鼓励密钥路径花费的背景下，这种情况可能较少。任何仅实现几种常用脚本类型的钱包将能验证超过 99% UTXO 的签名消息。

通用 Signmessage 支持将是比特币的一项有益补充。尽管过去数年其受关注度不足，我们仍鼓励阅读本文的钱包开发者考虑为您的程序添加实验性支持。这是为用户恢复已缺失数年的功能的便捷途径。若您是参与 BIP322 或相关储备证明实现的开发者，或认为此类功能有价值的服务提供商，欢迎联系 [info@bitcoinops.org][optech email] 以协调合作。

[reserve proofs]: https://github.com/bitcoin/bips/blob/master/bip-0322.mediawiki#full-proof-of-funds
[bech32ss signmessage]: /zh/bech32-sending-support/#消息签名支持
[bip322 reserve proofs]: https://github.com/bitcoin/bips/blob/master/bip-0322.mediawiki#full-proof-of-funds
[news118 virttx]: /zh/newsletters/2020/10/07/#alternative-to-bip322-generic-signmessage
[news130 inconclusive]: /zh/newsletters/2021/01/06/#proposed-updates-to-generic-signmessage
