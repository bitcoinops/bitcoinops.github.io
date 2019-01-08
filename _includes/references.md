{% comment %}<!-- internal site links, alphabetical order -->{% endcomment %}
[optech email]: mailto:info@bitcoinops.org
[rss feed]: /feed.xml

{% comment %}<!-- reused (or likely to be reused) external links, alphabetical order -->{% endcomment %}
[Bitcoin Core 0.16.2]: https://bitcoincore.org/en/releases/0.16.2/
[bitcoin.se]: https://bitcoin.stackexchange.com/
[bitcoin.pdf]: https://bitcoincore.org/bitcoin.pdf
[BitcoinCore.org]: https://bitcoincore.org/
[c-lightning]: https://github.com/ElementsProject/lightning
[cve-2017-12842]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-12842
[cve-2018-17144]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-17144
[libminisketch]: https://github.com/sipa/minisketch
[output script descriptors]: https://gist.github.com/sipa/e3d23d498c430bb601c5bca83523fa82

{% comment %}<!-- BIPs in order lowest to highest -->{% endcomment %}
[BIP21]: https://github.com/bitcoin/bips/blob/master/bip-0021.mediawiki
[BIP32]: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
[BIP37]: https://github.com/bitcoin/bips/blob/master/bip-0037.mediawiki
[BIP47]: https://github.com/bitcoin/bips/blob/master/bip-0047.mediawiki
[BIP61]: https://github.com/bitcoin/bips/blob/master/bip-0061.mediawiki
[BIP69]: https://github.com/bitcoin/bips/blob/master/bip-0069.mediawiki
[BIP70]: https://github.com/bitcoin/bips/blob/master/bip-0070.mediawiki
[BIP75]: https://github.com/bitcoin/bips/blob/master/bip-0075.mediawiki
[BIP114]: https://github.com/bitcoin/bips/blob/master/bip-0114.mediawiki
[BIP116]: https://github.com/bitcoin/bips/blob/master/bip-0116.mediawiki
[BIP117]: https://github.com/bitcoin/bips/blob/master/bip-0117.mediawiki
[BIP118]: https://github.com/bitcoin/bips/blob/master/bip-0118.mediawiki
[BIP125]: https://github.com/bitcoin/bips/blob/master/bip-0125.mediawiki
[BIP133]: https://github.com/bitcoin/bips/blob/master/bip-0133.mediawiki
[BIP143]: https://github.com/bitcoin/bips/blob/master/bip-0143.mediawiki
[BIP150]: https://github.com/bitcoin/bips/blob/master/bip-0150.mediawiki
{% comment %}<!-- FIXME: update if BIP151 ever updated -->{% endcomment %}
[BIP151]: https://gist.github.com/jonasschnelli/c530ea8421b8d0e80c51486325587c52
[BIP156]: https://github.com/bitcoin/bips/blob/master/bip-0156.mediawiki
[BIP157]: https://github.com/bitcoin/bips/blob/master/bip-0157.mediawiki
[BIP158]: https://github.com/bitcoin/bips/blob/master/bip-0158.mediawiki
[BIP159]: https://github.com/bitcoin/bips/blob/master/bip-0159.mediawiki
[BIP173]: https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki
[BIP174]: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
[BIP320]: https://github.com/bitcoin/bips/blob/master/bip-0320.mediawiki
[BIP322]: https://github.com/bitcoin/bips/blob/master/bip-0322.mediawiki

{% comment %}<!-- BOLTs in order lowest to highest -->{% endcomment %}
[BOLT2]: https://github.com/lightningnetwork/lightning-rfc/blob/master/02-peer-protocol.md
[BOLT4]: https://github.com/lightningnetwork/lightning-rfc/blob/master/04-onion-routing.md
[BOLT7]: https://github.com/lightningnetwork/lightning-rfc/blob/master/07-routing-gossip.md
[BOLT8]: https://github.com/lightningnetwork/lightning-rfc/blob/master/08-transport.md
[BOLT11]: https://github.com/lightningnetwork/lightning-rfc/blob/master/11-payment-encoding.md

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
{% assign news8 = "/en/newsletters/2018/08/14/" %}
[newsletter #8]: {{news8}}
{% assign news9 = "/en/newsletters/2018/08/21/" %}
[newsletter #9]: {{news9}}
{% assign news10 = "/en/newsletters/2018/08/28/" %}
[newsletter #10]: {{news10}}
{% assign news11 = "/en/newsletters/2018/09/04/" %}
[newsletter #11]: {{news11}}
{% assign news12 = "/en/newsletters/2018/09/11/" %}
[newsletter #12]: {{news12}}
{% assign news16 = "/en/newsletters/2018/10/09/" %}
[newsletter #16]: {{news16}}
{% assign news17 = "/en/newsletters/2018/10/16/" %}
[newsletter #17]: {{news17}}
{% assign news18 = "/en/newsletters/2018/10/23/" %}
[newsletter #18]: {{news18}}
{% assign news19 = "/en/newsletters/2018/10/30/" %}
[newsletter #19]: {{news19}}
{% assign news20 = "/en/newsletters/2018/11/06/" %}
[newsletter #20]: {{news20}}
{% assign news21 = "/en/newsletters/2018/11/13/" %}
[newsletter #21]: {{news21}}
{% assign news23 = "/en/newsletters/2018/11/27/" %}
[newsletter #23]: {{news23}}
{% assign news25 = "/en/newsletters/2018/12/11/" %}
[newsletter #25]: {{news25}}
{% assign news26 = "/en/newsletters/2018/12/18/" %}
[newsletter #26]: {{news26}}

{% comment %}
<!--REQUIRES PERIODIC UPDATE: update rpc_version below to latest
version of BitcoinCore.org's RPC docs-->
{% endcomment %}
{% assign rpc_prefix = "https://bitcoincore.org/en/doc/0.17.0/rpc" %}
[rpc abandontransaction]: {{rpc_prefix}}/wallet/abandontransaction/
[rpc fundrawtransaction]: {{rpc_prefix}}/rawtransactions/fundrawtransaction/
[rpc generatetoaddress]: {{rpc_prefix}}/generating/generatetoaddress/
[rpc getaddressinfo]: {{rpc_prefix}}/wallet/getaddressinfo/
[rpc getblocktemplate]: {{rpc_prefix}}/mining/getblocktemplate/
[rpc getnewaddress]: {{rpc_prefix}}/wallet/getnewaddress/
[rpc getpeerinfo]: {{rpc_prefix}}/network/getpeerinfo/
[rpc importaddress]:   {{rpc_prefix}}/wallet/importaddress/
[rpc importmulti]:   {{rpc_prefix}}/wallet/importmulti/
[rpc importprivkey]:   {{rpc_prefix}}/wallet/importprivkey/
[rpc importpubkey]:   {{rpc_prefix}}/wallet/importpubkey/
[rpc importwallet]:   {{rpc_prefix}}/wallet/importwallet/
[rpc listtransactions]: {{rpc_prefix}}/wallet/listtransactions/
[rpc scantxoutset]:   {{rpc_prefix}}/blockchain/scantxoutset/
[rpc verifytxoutproof]:   {{rpc_prefix}}/blockchain/verifytxoutproof/
