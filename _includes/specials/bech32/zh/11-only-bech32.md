{% auto_anchor %}
上周在 [Newsletter #47][] 中，我们描述了不升级支持 bech32 发送功能的一个成本——用户可能会认为你的服务已经过时，从而寻找替代服务。本周，我们将探讨这一论点的更强形式：那些已经**只能接收 bech32 地址**的钱包。如果这些钱包的用户想要接收付款或从你的服务中提现，而你的服务尚未支持发送到 bech32 地址，他们要么不得不使用第二个钱包，要么不得不使用你的竞争对手。

<!--wasabi-source-their-documentation-see-provided-links-->
- **<!--wasabi-wallet-->**[Wasabi wallet][]，以其增强隐私的 coinjoin 模式和强制用户币控制而闻名，[只接受发送到 bech32 地址的付款][wasabi bech32 only]。这个相对较新的钱包是围绕类似于 [BIP158][] 中描述的致密区块过滤器设计的。然而，由于所有过滤器都是由 Wasabi 的基础设施提供的，[决定只生成与 bech32 地址相关的过滤器]["only generate filters regarding bech32 addresses"]以最小化过滤器大小，只包括 P2WPKH 输出和花费。这意味着钱包无法看到其他输出类型的付款，包括 P2SH 用于 P2SH 封装的 segwit 地址。

<!--trust-wallet-source-private-conversation-harding-had-with-a-tester-of-this-wallet-in-februray-2019-->
- **<!--trust-wallet-->**[Trust wallet][] 是一个相对较新的专有钱包，由币安加密货币交易所拥有，兼容 Android 和 iOS。作为一个新钱包，他们不需要实现旧地址接收支持，所以他们只实现了 segwit。这使得 bech32 成为发送比特币到该钱包的唯一支持方式。

<!--electrum-source-harding-tested-default-download-from-their-website-2019-05-27-->
- **<!--electrum-->**[Electrum][] 是一个流行的桌面和移动钱包。在创建新钱包种子时，你可以选择传统钱包和 segwit 钱包，segwit 是当前默认选项。选择 segwit 钱包种子的用户将只能生成 bech32 地址以接收付款。Electrum 警告用户，这可能会导致与尚未升级到 bech32 发送支持的软件和服务的兼容性问题：

  ![Electrum 中允许用户选择地址类型并警告他们某些服务可能不支持 bech32 地址的对话框](/img/posts/2019-05-electrum-choose-wallet-type.png)

  请注意，钱包作者既不需要也不推荐为了支持新的地址格式而创建新种子。其他钱包，如 Bitcoin Core 0.16.0 及以上版本，可以从同一个种子生成传统、p2sh-segwit 和 bech32 地址——用户只需要指定他们想要的地址类型（如果他们不想要默认的）。

随着时间的推移，我们预计会有更多的新钱包只实现接收当前最佳地址格式。今天，这意味着使用 bech32 的 P2WPKH 和 P2WSH 的 v0 segwit 地址，但如果 Taproot 被采用，它将使用同样使用 bech32 的 v1 segwit 地址。[news45 bech32]。你的服务延迟实现 bech32 发送支持的时间越长，你就越有可能因为客户无法使用他们喜欢的钱包请求付款而失去客户。

[Newsletter #47]: /zh/newsletters/2019/05/21/
[wasabi bech32 only]: https://github.com/zkSNACKs/WalletWasabi/blob/master/WalletWasabi.Documentation/FAQ.md#my-wallet-cant-send-to-bech32-addresses---what-wallets-can-i-use-instead
["only generate filters regarding bech32 addresses"]: https://github.com/zkSNACKs/Meta/blob/master/README.md#wasabi-wallet-under-the-hood
[wasabi wallet]: https://wasabiwallet.io/
[trust wallet]: https://trustwallet.com/
[electrum]: https://electrum.org/
[news45 bech32]: /zh/newsletters/2019/05/07/#bech32-发送支持
{% endauto_anchor %}
