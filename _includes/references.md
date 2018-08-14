{% comment %}<!-- internal site links, alphabetical order -->{% endcomment %}
[optech email]: mailto:info@bitcoinops.org

{% comment %}<!-- reused (or likely to be reused) external links, alphabetical order -->{% endcomment %}
[Bitcoin Core 0.16.2]: https://bitcoincore.org/en/releases/0.16.2/
[bitcoin.se]: https://bitcoin.stackexchange.com/
[c-lightning]: https://github.com/ElementsProject/lightning
[output script descriptors]: https://gist.github.com/sipa/e3d23d498c430bb601c5bca83523fa82

{% comment %}<!-- BIPs in order lowest to highest -->{% endcomment %}
[BIP37]: https://github.com/bitcoin/bips/blob/master/bip-0037.mediawiki
[BIP70]: https://github.com/bitcoin/bips/blob/master/bip-0070.mediawiki
[BIP157]: https://github.com/bitcoin/bips/blob/master/bip-0157.mediawiki
[BIP158]: https://github.com/bitcoin/bips/blob/master/bip-0158.mediawiki

{% comment %}<!-- old newsletters (variables & links) in date order earliest to latest -->{% endcomment %}
{% assign news0 = "/en/newsletters/2018/06/08/" %}
[newsletter #0]: {{news0}}
{% assign news1 = "/en/newsletters/2018/06/26/" %}
[newsletter #1]: {{news1}}
{% assign news2 = "/en/newsletters/2018/07/03/" %}
[newsletter #2]: {{news2}}
{% assign news3 = "/en/newsletters/2018/07/10/" %}
[newsletter #3]: {{news3}}
{% assign news4 = "/en/newsletters/2018/07/17/" %}
[newsletter #4]: {{news4}}
{% assign news5 = "/en/newsletters/2018/07/24/" %}
[newsletter #5]: {{news5}}
{% assign news6 = "/en/newsletters/2018/07/31/" %}
[newsletter #6]: {{news6}}
{% assign news7 = "/en/newsletters/2018/08/07/" %}
[newsletter #7]: {{news7}}

{% comment %}
<!--REQUIRES PERIODIC UPDATE: update rpc_version below to latest
version of BitcoinCore.org's RPC docs-->
{% endcomment %}
{% assign rpc_prefix = "https://bitcoincore.org/en/doc/0.16.2/rpc" %}
[rpc abandontransaction]: {{rpc_prefix}}/wallet/abandontransaction/
[rpc fundrawtransaction]: {{rpc_prefix}}/rawtransactions/fundrawtransaction/
[rpc importaddress]:   {{rpc_prefix}}/wallet/importaddress/
[rpc importmulti]:   {{rpc_prefix}}/wallet/importmulti/
[rpc importprivkey]:   {{rpc_prefix}}/wallet/importprivkey/
[rpc importpubkey]:   {{rpc_prefix}}/wallet/importpubkey/
[rpc importwallet]:   {{rpc_prefix}}/wallet/importwallet/
[rpc verifytxoutproof]:   {{rpc_prefix}}/blockchain/verifytxoutproof/
