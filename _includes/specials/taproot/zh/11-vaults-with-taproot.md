*由 [Antoine Poinsot][darosior]，[Revault][] 开发者*

比特币[保险库][topic vaults]是一种需要两笔连续交易才能使用户从钱包中支出资金的合约。已经提出了许多此类协议（单方或多方，有或没有[契约][topic covenants]），因此我们将重点讨论它们的共同点。

与通过单一链上交易执行多次支付的[批量支付][topic payment batching]相反，保险库使用多笔交易来执行一次支付。第一笔交易，即 *unvault*，支付给：

1. 在相对时间锁后的一组公钥，或
2. 没有任何时间锁的单个公钥。

第一种支出路径是主路径，预计将与“热”密钥一起使用。第二种支出路径允许进行*取消*交易（有时称为*回收*、*恢复*或*重新保险库化*交易）。

因此，比特币保险库与 [Taproot][topic taproot] 的洞察相反，后者认为大多数合约都有一个合作签名的“顺利路径”（争议路径通常包含时间锁）。比特币保险库恰恰相反。*支出* 交易必须使用 Taproot 脚本发送路径，因为它受到相对时间锁的限制[^0]，而 *取消* 交易理论上可以使用密钥支出路径。

由于多方保险库在实践中已经需要大量交互，它们理论上可以受益于通过 [BIP340][] 实现的交互式[多签名][topic multisignature]和 [门限签名][topic threshold signature]方案，例如 [Musig2][topic musig]。然而，这些方案也带来了新的安全挑战。由于保险库协议旨在用于冷存储，设计选择更为保守，因此保险库可能会是最后一个使用这些新技术的协议。

通过切换到 Taproot，保险库还可以受益于隐私和效率的轻微改进，得益于使用梅尔克分支和更短的 BIP340 签名（尤其是对于多方签名）。例如，在一个包含 6 个“冷”密钥和 3 个“活跃”密钥（门限为 2）的多方设置中，*unvault* 输出脚本可以表示为深度为 2 的 Taproot，叶子如下：

- `<X> CSV DROP <active key 1> CHECKSIG <active key 2> CHECKSIGADD 2 EQUAL`
- `<X> CSV DROP <active key 2> CHECKSIG <active key 3> CHECKSIGADD 2 EQUAL`
- `<X> CSV DROP <active key 3> CHECKSIG <active key 1> CHECKSIGADD 2 EQUAL`
- `<cold key 1> CHECKSIG <cold key 2> CHECKSIGADD <cold key 3> CHECKSIGADD <cold key 4> CHECKSIGADD <cold key 5> CHECKSIGADD <cold key 6> CHECKSIGADD 6 EQUAL`

在 Taproot 中，只需要揭示用于支出输出的叶子，因此交易的重量显著小于等效的 P2WSH 脚本：

```text
IF
  6 <cold key 1> <cold key 2> <cold key 3> <cold key 4> <cold key 5> <cold key 6> 6 CHECKMULTISIG
ELSE
  <X> CSV DROP
  2 <active key 1> <active key 2> <active key 3> 3 CHECKMULTISIG
ENDIF
```

尽管在成功支出时撤销分支可以被隐藏（如果使用多签门限，它的存在和参与者的数量也会被模糊化），但隐私提升是有限的，因为保险库的使用模式在链上将是显而易见的。

最后，像大多数预签名交易协议一样，保险库协议将极大受益于基于 Taproot 的进一步比特币升级，例如 [BIP118][] 的 [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]。尽管这需要进一步的谨慎和协议调整，`ANYPREVOUT`和`ANYPREVOUTANYSCRIPT`将使*取消*签名可重新绑定，这将大大减少交互性并允许 0(1) 的签名存储。这对 [Revault 协议][evault protocol] 中的*紧急*签名尤为有趣，因为它将大大减少 DoS 攻击面。通过在输出中使用`ANYPREVOUTANYSCRIPT`签名，您实际上是在创建一个契约，通过限制该交易支出此币时如何创建其输出。未来更具可定制性的签名哈希将允许更灵活的限制。

[^0]:
    如果已知，您可以预签 支出 交易并指定 nSequence，但这样您就不再需要“活跃”密钥的备用支出路径。而且，通常您在收到比特币时并不知道如何花费它们。

[darosior]: https://github.com/darosior
[revault]: https://github.com/revault
[revault protocol]: https://github.com/revault/practical-revault
