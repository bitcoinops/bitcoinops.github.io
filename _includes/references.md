{% comment %}<!-- internal site links, alphabetical order -->{% endcomment %}
[bech32 series]: /en/bech32-sending-support/
[compatibility matrix]: /en/compatibility/
[optech email]: mailto:info@bitcoinops.org
[rss feed]: /feed.xml

{% comment %}<!-- reused (or likely to be reused) external links, alphabetical order -->{% endcomment %}
[bip-anyprevout]: https://github.com/ajtowns/bips/blob/bip-anyprevout/bip-anyprevout.mediawiki
[bip-coshv]: https://github.com/JeremyRubin/bips/blob/op-checkoutputshashverify/bip-coshv.mediawiki
[bip-schnorr]: https://github.com/sipa/bips/blob/bip-schnorr/bip-schnorr.mediawiki
[bip-taproot]: https://github.com/sipa/bips/blob/bip-schnorr/bip-taproot.mediawiki
[bip-tapscript]: https://github.com/sipa/bips/blob/bip-schnorr/bip-tapscript.mediawiki
[bips repo]: https://github.com/bitcoin/bips/
[Bitcoin Core 0.16.2]: https://bitcoincore.org/en/releases/0.16.2/
[BitcoinCore.org]: https://bitcoincore.org/
[bitcoin core repo]: https://github.com/bitcoin/bitcoin
[bitcoin.pdf]: https://bitcoincore.org/bitcoin.pdf
[bitcoin.se]: https://bitcoin.stackexchange.com/
[bolts repo]: https://github.com/lightningnetwork/lightning-rfc/
[c-lightning]: https://github.com/ElementsProject/lightning
[c-lightning repo]: https://github.com/ElementsProject/lightning
[cve-2012-2459]: https://bitcointalk.org/?topic=102395
[cve-2017-12842]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2017-12842
[cve-2018-17144]: https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2018-17144
[descriptor]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
[eclair repo]: https://github.com/ACINQ/eclair
[eltoo]: https://blockstream.com/eltoo.pdf
[erlay]: https://arxiv.org/pdf/1905.10518.pdf
[hwi]: https://github.com/bitcoin-core/HWI
[libminisketch]: https://github.com/sipa/minisketch
[libsecp256k1]: https://github.com/bitcoin-core/secp256k1
[libsecp256k1 repo]: https://github.com/bitcoin-core/secp256k1
[lnd repo]: https://github.com/lightningnetwork/lnd/
{% comment %}<!-- TODO: switch miniscript link to some sort of overview page when available -->{% endcomment %}
[miniscript]: http://bitcoin.sipa.be/miniscript/
[musig]: https://eprint.iacr.org/2018/068
{% assign _link_descriptors = 'https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md' %}
[output script descriptor]: {{_link_descriptors}}
[output script descriptors]: {{_link_descriptors}}

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

{% comment %}<!-- BOLTs in order lowest to highest -->{% endcomment %}
[BOLT2]: https://github.com/lightningnetwork/lightning-rfc/blob/master/02-peer-protocol.md
[BOLT3]: https://github.com/lightningnetwork/lightning-rfc/blob/master/03-transactions.md
[BOLT4]: https://github.com/lightningnetwork/lightning-rfc/blob/master/04-onion-routing.md
[BOLT7]: https://github.com/lightningnetwork/lightning-rfc/blob/master/07-routing-gossip.md
[BOLT8]: https://github.com/lightningnetwork/lightning-rfc/blob/master/08-transport.md
[BOLT11]: https://github.com/lightningnetwork/lightning-rfc/blob/master/11-payment-encoding.md

{% comment %}<!-- links old newsletters -->{% endcomment %}
{% include linkers/newsletters.md %}

{% comment %}
<!--REQUIRES PERIODIC UPDATE: update rpc_version below to latest
version of BitcoinCore.org's RPC docs-->
{% endcomment %}
{% assign rpc_prefix = "https://bitcoincore.org/en/doc/0.18.0/rpc" %}
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
