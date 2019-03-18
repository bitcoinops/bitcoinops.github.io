{% comment %}<!-- internal site links, alphabetical order -->{% endcomment %}
[optech email]: mailto:info@bitcoinops.org
[rss feed]: /feed.xml

{% comment %}<!-- reused (or likely to be reused) external links, alphabetical order -->{% endcomment %}
[bip-schnorr]: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki
[bips repo]: https://github.com/bitcoin/bips/
[Bitcoin Core 0.16.2]: https://bitcoincore.org/en/releases/0.16.2/
[BitcoinCore.org]: https://bitcoincore.org/
[bitcoin core repo]: https://github.com/bitcoin/bitcoin
[bitcoin.pdf]: https://bitcoincore.org/bitcoin.pdf
[bitcoin.se]: https://bitcoin.stackexchange.com/
[c-lightning]: https://github.com/ElementsProject/lightning
[c-lightning repo]: https://github.com/ElementsProject/lightning
[cve-2012-2459]: https://bitcointalk.org/?topic=102395
[cve-2017-12842]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-12842
[cve-2018-17144]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-17144
[descriptor]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
[eclair repo]: https://github.com/ACINQ/eclair
[hwi]: https://github.com/bitcoin-core/HWI
[libminisketch]: https://github.com/sipa/minisketch
[libsecp256k1]: https://github.com/bitcoin-core/secp256k1
[libsecp256k1 repo]: https://github.com/bitcoin-core/secp256k1
[lnd repo]: https://github.com/lightningnetwork/lnd/
{% comment %}<!-- TODO: switch miniscript link to some sort of overview page when available -->{% endcomment %}
[miniscript]: http://bitcoin.sipa.be/miniscript/miniscript.html
[musig]: https://eprint.iacr.org/2018/068
[output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md

{% comment %}<!-- BIPs in order lowest to highest
Note: as of 2019-02-24/Jekyll 3.8.3, this is currently inefficient as
the loop is run each time this file is included (but it still only adds
about 1 second of compile time to the whole site).  However, Jekyll 4.0
is expected to cache rendered includes so that, if none of the variables
in the included file is redefined, the cached file will be used, so the
loop will only be run once no matter how many times this file is
included in documents.  See https://github.com/jekyll/jekyll/pull/7108
for details --> {% endcomment %}
{% for i in (1..400) %}
{% assign i_padded = "0000" | append: i | slice: -4, 4 %}
[BIP{{i}}]: https://github.com/bitcoin/bips/blob/master/bip-{{i_padded}}.mediawiki
{% endfor %}

{% comment %}<!-- Later link definitions supersede earlier definitions.
When more recent information about a BIP is available not in the regular
place, put links here. -->{% endcomment %}
[BIP151]: https://gist.github.com/jonasschnelli/c530ea8421b8d0e80c51486325587c52

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
{% assign news13 = "/en/newsletters/2018/09/18/" %}
[newsletter #13]: {{news13}}
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
{% assign news22 = "/en/newsletters/2018/11/20/" %}
[newsletter #22]: {{news22}}
{% assign news23 = "/en/newsletters/2018/11/27/" %}
[newsletter #23]: {{news23}}
{% assign news25 = "/en/newsletters/2018/12/11/" %}
[newsletter #25]: {{news25}}
{% assign news26 = "/en/newsletters/2018/12/18/" %}
[newsletter #26]: {{news26}}
{% assign news27 = "/en/newsletters/2018/12/28/" %}
[newsletter #27]: {{news27}}
{% assign news30 = "/en/newsletters/2019/01/22/" %}
[newsletter #30]: {{news30}}
{% assign news31 = "/en/newsletters/2019/01/29/" %}
[newsletter #31]: {{news31}}
{% assign news34 = "/en/newsletters/2019/02/19/" %}
[newsletter #34]: {{news34}}
{% assign news36 = "/en/newsletters/2019/03/05/" %}
[newsletter #36]: {{news36}}
{% assign news37 = "/en/newsletters/2019/03/12/" %}
[newsletter #37]: {{news37}}

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
