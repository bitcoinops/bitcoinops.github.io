{% auto_anchor %}
[输出脚本描述符][topic descriptors] 为钱包提供了一种通用方式，用来存储生成地址所需的信息、有效扫描付款给这些地址的输出，以及之后从这些地址花费。此外，描述符相对紧凑且包含一个基础校验和，这使其在备份地址信息、在不同钱包之间复制或在合作提供多签的多个钱包之间共享时都非常方便。

尽管当前只有少数项目在使用描述符，但它们和相关的 [miniscript][topic miniscript] 项目有潜力显著提升不同钱包和工具之间的互操作性。随着越来越多的用户利用 taproot 带来的好处，通过[多签][topic multisignature]来加强安全性，以及通过备份花费条件来提高恢复能力，这一点将变得愈加重要。

在此之前，需要先对描述符进行更新以适配 taproot。最近合并的 [Bitcoin Core #22051][] 拉取请求正是针对这一需求。该语法设计允许使用单一描述符模板，同时提供使用 P2TR 密钥路径花费和脚本路径花费所需的全部信息。对于简单的单签名，以下描述符就足够了：

```
tr(<key>)
```

相同的语法也适用于多签和[阈值签名][topic threshold signature]。例如，Alice、Bob 和 Carol 使用 [MuSig][topic musig] 聚合它们的密钥，然后支付给 `tr(<combined_key>)`。

出人意料的是，“`tr(<key>)` 中的 key” 并不会直接是地址中所编码的那个密钥。`tr()` 描述符遵循了 BIP341 中的[安全性建议][bip341 safety]，使用一个承诺于不可花费脚本树的内部密钥，这就消除了对简单密钥聚合方案（像 [MuSig][topic musig] 和 MuSig2 这类更先进的方案不受影响）的一个攻击。

对于脚本路径花费，新增了一种可指定二叉树内容的语法。例如，`{ {B,C} , {D,E} }` 描述了这样一棵树：

```
Internal key
    / \
   /   \
  / \ / \
  B C D E
```

可以将这棵树作为可选的第二个参数传入之前使用的描述符模板。例如，如果 Alice 希望能够通过密钥路径花费，但也允许 Bob、Carol、Dan 和 Edmond 以能够为她生成审计轨迹的脚本路径花费（但不对第三方链上监控暴露），她可以使用如下描述符：

```
tr( <a_key> , { {pk(<b_key>),pk(<c_key>)} , {pk(<d_key>),pk(<e_key>)} )
```

上述功能足以让描述符用于 taproot，但拉取请求 #22051 中提到仍有一些可能被添加的功能，用于让描述符更好地完整描述预期的策略：

- **<!--voided-keypaths-->*****无效化密钥路径：** 某些用户可能希望禁止通过密钥路径花费，从而强制使用脚本路径花费。现在可以在 `tr()` 第一个参数中使用不可花费的密钥来实现，但能够在描述符本身中记录这一偏好并让它计算出一个保护隐私的不可花费密钥路径将更好。

- **<!--tapscript-multisig-->*****Tapscript 多签：** 对于传统和 v0 segwit，`multi()` 和 `sortedmulti()` 描述符支持 `OP_CHECKMULTISIG` 操作码。为了在 taproot 中实现批量验证，基于脚本的多签在 tapscript 中的处理方式有所不同，因此 `tr()` 描述符目前需要通过 `raw()` 脚本来指定任何必需的多签操作码。对 tapscript 版本的 `multi()` 和 `sortedmulti()` 进行更新将非常有用。

- **<!--musig-based-multisignatures-->*****基于 MuSig 的多签：** 在本文前面，我们描述了 Alice、Bob 和 Carol 手动聚合它们的密钥，以使用一个 `tr()` 描述符。理想情况下，应当能有一个函数允许像 `tr(musig(<a_key>, <b_key>, <c_key>))` 这样指定，这样他们就能保留全部初始密钥信息并用它来填充它们协同签名所用 [PSBT][topic psbt] 中的各字段。

- **<!--timelocks-hashlocks-and-pointlocks-->*****时间锁、哈希锁和点锁：** 这些在闪电网络、[DLCs][topic dlc]、[coinswaps][topic coinswap] 以及许多其他协议中使用的强大结构，目前只能通过 `raw()` 函数来描述。可将它们直接加入描述符是可行的，但也可能会在描述符的姊妹项目 [miniscript][topic miniscript] 中添加对它们的支持。miniscript 整合到 Bitcoin Core 仍在进行中，但我们预期它的创新将和 PSBT、描述符等工具一样，推广到其他钱包中。

钱包并不需要实现描述符就能开始使用 taproot，但那些实现了描述符的，将为自己使用更高级的 taproot 功能奠定更好的基础。

{% include linkers/issues.md issues="22051" %}
[bip341 safety]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#cite_note-22
{% endauto_anchor %}
