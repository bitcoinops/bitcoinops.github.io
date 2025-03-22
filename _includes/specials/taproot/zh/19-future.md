{% auto_anchor %}

随着 Taproot 在区块高度 {{site.trb}} 临近激活，我们可以开始展望开发者们此前希望在 Taproot 基础上构建的部分共识变更。

- ​**<!--cross-input-signature-aggregation-->**​**跨输入签名聚合：​** [schnorr 签名][topic schnorr signatures]使得多个独立公私钥对的持有者能够轻松创建单个签名来证明所有密钥持有者的协作授权。
   通过未来的共识变更，这将允许交易包含单个签名来证明该交易中所有被花费的 UTXO 所有者均已授权支出。这将为每个密钥路径花费（首个输入之后）节省约 16 vbytes，为资金整合和 [coinjoins][topic coinjoin] 带来显著空间节省。它甚至可能使得基于 coinjoin 的支出比个人单独支出更经济，为使用更隐私的支出方式提供温和激励。

- ​**<!--sighash-anyprevout-->**​**SIGHASH_ANYPREVOUT：​** 每笔比特币交易都包含一个或多个输入，每个输入通过 txid 引用前序交易的输出。这个引用告知 Bitcoin Core 等全验证节点该交易可支出的金额及验证授权所需的条件。所有比特币交易签名生成方式（无论是否使用 Taproot）要么承诺 prevouts 中的 txid，要么完全不承诺 prevouts。

  这对不希望使用预先安排交易序列的多用户协议构成挑战。如果任何用户可以跳过特定交易，或更改除见证数据外的任何交易细节，将导致后续交易的 txid 改变。txid 的变更会使之前为后续交易创建的签名失效。这迫使链下协议实施惩罚机制（如 LN 惩罚机制）来惩戒提交旧交易的用户。

  [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] 通过允许签名跳过对 prevout txid 的承诺来解决此问题。根据使用的其他标志，它仍会承诺关于 prevout 和交易的其他细节（如金额和脚本），但不再关心前序交易使用的 txid。这将使实现 [eltoo][topic eltoo] 闪电网络层以及[保险库][topic vaults]和其他合约协议的[改进][p4tr vaults]成为可能。

- ​**<!--delegation-and-generalization-->**​**委托与通用化：​** 创建脚本（Taproot 或其他类型）后，[几乎][rubin delegation] 无法在不泄露私钥的情况下委托他人使用该脚本（使用 [BIP32][] 钱包时[逆向推导][bip32 reverse derivation]可能[极其危险][bip32 reverse derivation]）。此外，对于希望使用密钥路径支出加少量脚本条件的用户，Taproot 可变得更具成本效益。目前已提出多种通过通用化和提供[签名者委托][topic signer delegation]来增强 Taproot 的方法：

  - ​**<!--graftroot-->**​**Graftroot：​** 在 Taproot 概念提出后不久[提出][maxwell graftroot]，Graftroot 将为任何能够进行 Taproot 密钥路径支出的用户提供额外功能。密钥路径签名者可以不直接支出资金，而是签署描述新支出条件的脚本，将支出权限委托给能够满足该脚本的任何人。支出交易中需提供签名、脚本及满足脚本所需的任何数据。密钥路径签名者可以通过这种方式委托无限数量的脚本，且在实际支出发生前不会产生任何链上数据。

  - ​**<!--generalized-taproot-g-root-->**​**通用化 Taproot（g'root）：​** 数月后，Anthony Towns [提出][towns groot]使用公钥点承诺多种支出条件的方法，无需使用类似 [MAST][topic mast] 的结构。这种 *通用化 Taproot*（g'root）构造在 "[Taproot 假设不成立][p4tr taproot assumption]" 时可能更高效，同时 "[提供][sipa groot agg]构建软分叉安全的跨输入聚合系统的简便方法"。

  - ​**<!--entroot-->**​**Entroot：​** [近期][wuille entroot]综合 Graftroot 和 g'root 的方案，简化多数场景并提升带宽效率。它支持来自任何能够满足 Entroot 分支的签名者委托，而不仅限于能够创建顶层密钥路径支出的用户。

- ​**<!--new-and-old-opcodes-->**​**新旧操作码：​** Taproot 软分叉包含对 [Tapscript][topic tapscript] 的支持，通过 `OP_SUCCESSx` 操作码提供了改进的比特币新操作码添加方式。与比特币早期添加的 `OP_NOPx`（无操作）操作码类似，`OP_SUCCESSx` 操作码设计为可替换为不总是返回成功的操作码。部分提议的新操作码包括：

  - ​**<!--restore-old-opcodes-->**​**恢复旧操作码：​** 2010 年因安全漏洞担忧而禁用的多个数学和字符串操作码。许多开发者希望在进行安全审查后重新启用这些操作码，并在某些情况下扩展其处理更大数值的能力。

  - ​**<!--op-cat-->**​**OP_CAT：​** 这个曾被禁用的操作码值得特别关注，研究人员发现其单独使用即可通过[密钥树][keytrees]、[后量子密码][rubin pqc]或与 [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] 等新操作码[结合][poelstra cat]实现[各类][rubin pqc]有趣功能。

  - ​**<!--op-tapleaf-update-verify-->**​**OP_TAPLEAF_UPDATE_VERIFY：​** 如[第 166 期周报][news166 tluv]所述，`OP_TLUV` 操作码在配合 Taproot 密钥路径和脚本路径功能时，能高效实现强大的[契约][topic covenants]，可用于构建[联合质押池][topic joinpools]、[保险库][topic vaults]等安全与隐私改进方案，也可能与 [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] 良好结合。

以上所有设想仍仅为提案，无法保证最终实现。需要研究人员和开发者推动每个提案走向成熟，最终由用户决定是否值得通过改变比特币共识规则来添加这些功能。

{% endauto_anchor %}

[news166 tluv]: /zh/newsletters/2021/09/15/#covenant-opcode-proposal
[wuille entroot]: https://gist.github.com/sipa/ca1502f8465d0d5032d9dd2465f32603
[towns groot]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-July/016249.html
[maxwell graftroot]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-February/015700.html
[p4tr multisignatures]: /zh/preparing-for-taproot/#多签
[p4tr vaults]: /zh/preparing-for-taproot/#使用-taproot-的保险库
[rubin delegation]: /zh/newsletters/2021/03/24/#signing-delegation-under-existing-consensus-rules
[p4tr taproot assumption]: /zh/preparing-for-taproot/#合作永远是可行选项吗
[keytrees]: https://blockstream.com/2015/08/24/en-treesignatures/#h.2lysjsnoo7jd
[rubin pqc]: https://rubin.io/blog/2021/07/06/quantum-bitcoin/
[poelstra cat]: https://www.wpsoftware.net/andrew/blog/cat-and-schnorr-tricks-i.html
[bip32 reverse derivation]: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#implications
[sipa groot agg]: https://gnusha.org/url/https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-October/016461.html
