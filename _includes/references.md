{% comment %}<!-- internal site links, alphabetical order -->{% endcomment %}
[bech32 series]: /en/bech32-sending-support/
[compatibility matrix]: /en/compatibility/
[topics]: /en/topics/
[podcast]: /en/podcast/
[op_cat]: /en/topics/op_cat/
[optech email]: mailto:info@bitcoinops.org
[rss feed]: /feed.xml
[scaling payment batching]: /en/payment-batching/
[series preparing for taproot]: /en/preparing-for-taproot/

{% comment %}<!-- links for topics -->{% endcomment %}
{% for topic in site.topics %}
  [topic {{topic.shortname | default: topic.title}}]: {{topic.url}}
{%- endfor %}

{% comment %}<!-- reused (or likely to be reused) external links, alphabetical order -->{% endcomment %}
[bdk repo]: https://github.com/bitcoindevkit/bdk
[binana repo]: https://github.com/bitcoin-inquisition/binana
[bip-anyprevout]: https://github.com/ajtowns/bips/blob/bip-anyprevout/bip-0118.mediawiki
[bip-cleanup]: https://github.com/TheBlueMatt/bips/blob/cleanup-softfork/bip-XXXX.mediawiki
[bip-coshv]: https://github.com/JeremyRubin/bips/blob/op-checkoutputshashverify/bip-coshv.mediawiki
[bip-schnorr]: https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki
[bip-taproot]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki
[bip-tapscript]: https://github.com/bitcoin/bips/blob/master/bip-0342.mediawiki
[bips repo]: https://github.com/bitcoin/bips/
[Bitcoin Core 0.16.2]: https://bitcoincore.org/en/releases/0.16.2/
[Bitcoin Core PR Review Club]: https://bitcoincore.reviews/
[BitcoinCore.org]: https://bitcoincore.org/
[bitcoin core repo]: https://github.com/bitcoin/bitcoin
[bitcoin inquisition repo]: https://github.com/bitcoin-inquisition/bitcoin
[bitcoin transcripts]: https://twitter.com/btctranscripts
[bitcoin.pdf]: https://bitcoincore.org/bitcoin.pdf
[bitcoin.se]: https://bitcoin.stackexchange.com/
[blips repo]: https://github.com/lightning/blips
[bolts repo]: https://github.com/lightning/bolts
[btcpay server repo]: https://github.com/btcpayserver/btcpayserver/
[c-lightning]: https://github.com/ElementsProject/lightning
[c-lightning repo]: https://github.com/ElementsProject/lightning
[core lightning repo]: https://github.com/ElementsProject/lightning
[eclair repo]: https://github.com/ACINQ/eclair
[elementsproject.org]: https://elementsproject.org/
[FIXME]: https://example.com/FIXME{% comment %}<!-- for use during drafting; skip-test -->{% endcomment %}
[hwi repo]: https://github.com/bitcoin-core/HWI
[ldk repo]: https://github.com/lightningdevkit/rust-lightning
[libminisketch]: https://github.com/sipa/minisketch
[libsecp256k1]: https://github.com/bitcoin-core/secp256k1
[libsecp256k1 repo]: https://github.com/bitcoin-core/secp256k1
[lnd repo]: https://github.com/lightningnetwork/lnd/
[nostr]: https://github.com/nostr-protocol/nips
[@bitcoinoptech]: https://twitter.com/bitcoinoptech
[rust bitcoin repo]: https://github.com/rust-bitcoin/rust-bitcoin
[rust-lightning repo]: https://github.com/rust-bitcoin/rust-lightning

{% comment %}<!-- BIPs, BLIPs, and BINANAs in order lowest to highest
Note: as of 2019-02-24/Jekyll 3.8.3, this is currently inefficient as
the loop is run each time this file is included (but it still only adds
about 1 second of compile time to the whole site).  However, Jekyll 4.0
is expected to cache rendered includes so that, if none of the variables
in the included file is redefined, the cached file will be used, so the
loop will only be run once no matter how many times this file is
included in documents.  See https://github.com/jekyll/jekyll/pull/7108
for details --> {% endcomment %}
[BIP1]: https://github.com/bitcoin/bips/blob/master/bip-0001.mediawiki
[BIP2]: https://github.com/bitcoin/bips/blob/master/bip-0002.mediawiki
[BIP8]: https://github.com/bitcoin/bips/blob/master/bip-0008.mediawiki
[BIP9]: https://github.com/bitcoin/bips/blob/master/bip-0009.mediawiki
[BIP12]: https://github.com/bitcoin/bips/blob/master/bip-0012.mediawiki
[BIP13]: https://github.com/bitcoin/bips/blob/master/bip-0013.mediawiki
[BIP16]: https://github.com/bitcoin/bips/blob/master/bip-0016.mediawiki
[BIP17]: https://github.com/bitcoin/bips/blob/master/bip-0017.mediawiki
[BIP18]: https://github.com/bitcoin/bips/blob/master/bip-0018.mediawiki
[BIP19]: https://github.com/bitcoin/bips/blob/master/bip-0019.mediawiki
[BIP21]: https://github.com/bitcoin/bips/blob/master/bip-0021.mediawiki
[BIP22]: https://github.com/bitcoin/bips/blob/master/bip-0022.mediawiki
[BIP23]: https://github.com/bitcoin/bips/blob/master/bip-0023.mediawiki
[BIP32]: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
[BIP30]: https://github.com/bitcoin/bips/blob/master/bip-0030.mediawiki
[BIP34]: https://github.com/bitcoin/bips/blob/master/bip-0034.mediawiki
[BIP35]: https://github.com/bitcoin/bips/blob/master/bip-0035.mediawiki
[BIP37]: https://github.com/bitcoin/bips/blob/master/bip-0037.mediawiki
[BIP39]: https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki
[BIP40]: https://github.com/bitcoin/bips/blob/master/bip-0040.mediawiki
[BIP41]: https://github.com/bitcoin/bips/blob/master/bip-0041.mediawiki
[BIP44]: https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
[BIP45]: https://github.com/bitcoin/bips/blob/master/bip-0045.mediawiki
[BIP46]: https://github.com/bitcoin/bips/blob/master/bip-0046.mediawiki
[BIP47]: https://github.com/bitcoin/bips/blob/master/bip-0047.mediawiki
[BIP48]: https://github.com/bitcoin/bips/blob/master/bip-0048.mediawiki
[BIP49]: https://github.com/bitcoin/bips/blob/master/bip-0049.mediawiki
[BIP52]: https://github.com/bitcoin/bips/blob/master/bip-0052.mediawiki
[BIP61]: https://github.com/bitcoin/bips/blob/master/bip-0061.mediawiki
[BIP62]: https://github.com/bitcoin/bips/blob/master/bip-0062.mediawiki
[BIP65]: https://github.com/bitcoin/bips/blob/master/bip-0065.mediawiki
[BIP66]: https://github.com/bitcoin/bips/blob/master/bip-0066.mediawiki
[BIP67]: https://github.com/bitcoin/bips/blob/master/bip-0067.mediawiki
[BIP68]: https://github.com/bitcoin/bips/blob/master/bip-0068.mediawiki
[BIP69]: https://github.com/bitcoin/bips/blob/master/bip-0069.mediawiki
[BIP70]: https://github.com/bitcoin/bips/blob/master/bip-0070.mediawiki
[BIP71]: https://github.com/bitcoin/bips/blob/master/bip-0071.mediawiki
[BIP72]: https://github.com/bitcoin/bips/blob/master/bip-0072.mediawiki
[BIP75]: https://github.com/bitcoin/bips/blob/master/bip-0075.mediawiki
[BIP78]: https://github.com/bitcoin/bips/blob/master/bip-0078.mediawiki
[BIP79]: https://github.com/bitcoin/bips/blob/master/bip-0079.mediawiki
[BIP84]: https://github.com/bitcoin/bips/blob/master/bip-0084.mediawiki
[BIP85]: https://github.com/bitcoin/bips/blob/master/bip-0085.mediawiki
[BIP86]: https://github.com/bitcoin/bips/blob/master/bip-0086.mediawiki
[BIP87]: https://github.com/bitcoin/bips/blob/master/bip-0087.mediawiki
[BIP88]: https://github.com/bitcoin/bips/blob/master/bip-0088.mediawiki
[BIP90]: https://github.com/bitcoin/bips/blob/master/bip-0090.mediawiki
[BIP91]: https://github.com/bitcoin/bips/blob/master/bip-0091.mediawiki
[BIP93]: https://github.com/bitcoin/bips/blob/master/bip-0093.mediawiki
[BIP94]: https://github.com/bitcoin/bips/blob/master/bip-0094.mediawiki
[BIP103]: https://github.com/bitcoin/bips/blob/master/bip-0103.mediawiki
[BIP111]: https://github.com/bitcoin/bips/blob/master/bip-0111.mediawiki
[BIP112]: https://github.com/bitcoin/bips/blob/master/bip-0112.mediawiki
[BIP113]: https://github.com/bitcoin/bips/blob/master/bip-0113.mediawiki
[BIP114]: https://github.com/bitcoin/bips/blob/master/bip-0114.mediawiki
[BIP116]: https://github.com/bitcoin/bips/blob/master/bip-0116.mediawiki
[BIP117]: https://github.com/bitcoin/bips/blob/master/bip-0117.mediawiki
[BIP118]: https://github.com/bitcoin/bips/blob/master/bip-0118.mediawiki
[BIP119]: https://github.com/bitcoin/bips/blob/master/bip-0119.mediawiki
[BIP125]: https://github.com/bitcoin/bips/blob/master/bip-0125.mediawiki
[BIP127]: https://github.com/bitcoin/bips/blob/master/bip-0127.mediawiki
[BIP129]: https://github.com/bitcoin/bips/blob/master/bip-0129.mediawiki
[BIP130]: https://github.com/bitcoin/bips/blob/master/bip-0130.mediawiki
[BIP133]: https://github.com/bitcoin/bips/blob/master/bip-0133.mediawiki
[BIP136]: https://github.com/bitcoin/bips/blob/master/bip-0136.mediawiki
[BIP137]: https://github.com/bitcoin/bips/blob/master/bip-0137.mediawiki
[BIP140]: https://github.com/bitcoin/bips/blob/master/bip-0140.mediawiki
[BIP141]: https://github.com/bitcoin/bips/blob/master/bip-0141.mediawiki
[BIP143]: https://github.com/bitcoin/bips/blob/master/bip-0143.mediawiki
[BIP144]: https://github.com/bitcoin/bips/blob/master/bip-0144.mediawiki
[BIP145]: https://github.com/bitcoin/bips/blob/master/bip-0145.mediawiki
[BIP146]: https://github.com/bitcoin/bips/blob/master/bip-0146.mediawiki
[BIP147]: https://github.com/bitcoin/bips/blob/master/bip-0147.mediawiki
[BIP148]: https://github.com/bitcoin/bips/blob/master/bip-0148.mediawiki
[BIP149]: https://github.com/bitcoin/bips/blob/master/bip-0149.mediawiki
[BIP150]: https://github.com/bitcoin/bips/blob/master/bip-0150.mediawiki
[BIP151]: https://github.com/bitcoin/bips/blob/master/bip-0151.mediawiki
[BIP152]: https://github.com/bitcoin/bips/blob/master/bip-0152.mediawiki
[BIP155]: https://github.com/bitcoin/bips/blob/master/bip-0155.mediawiki
[BIP156]: https://github.com/bitcoin/bips/blob/master/bip-0156.mediawiki
[BIP157]: https://github.com/bitcoin/bips/blob/master/bip-0157.mediawiki
[BIP158]: https://github.com/bitcoin/bips/blob/master/bip-0158.mediawiki
[BIP159]: https://github.com/bitcoin/bips/blob/master/bip-0159.mediawiki
[BIP173]: https://github.com/bitcoin/bips/blob/master/bip-0173.mediawiki
[BIP174]: https://github.com/bitcoin/bips/blob/master/bip-0174.mediawiki
[BIP179]: https://github.com/bitcoin/bips/blob/master/bip-0179.mediawiki
[BIP199]: https://github.com/bitcoin/bips/blob/master/bip-0199.mediawiki
[BIP300]: https://github.com/bitcoin/bips/blob/master/bip-0300.mediawiki
[BIP301]: https://github.com/bitcoin/bips/blob/master/bip-0301.mediawiki
[BIP320]: https://github.com/bitcoin/bips/blob/master/bip-0320.mediawiki
[BIP322]: https://github.com/bitcoin/bips/blob/master/bip-0322.mediawiki
[BIP324]: https://github.com/bitcoin/bips/blob/master/bip-0324.mediawiki
[BIP325]: https://github.com/bitcoin/bips/blob/master/bip-0325.mediawiki
[BIP326]: https://github.com/bitcoin/bips/blob/master/bip-0326.mediawiki
[BIP327]: https://github.com/bitcoin/bips/blob/master/bip-0327.mediawiki
[BIP328]: https://github.com/bitcoin/bips/blob/master/bip-0328.mediawiki
[BIP329]: https://github.com/bitcoin/bips/blob/master/bip-0329.mediawiki
[BIP330]: https://github.com/bitcoin/bips/blob/master/bip-0330.mediawiki
[BIP331]: https://github.com/bitcoin/bips/blob/master/bip-0331.mediawiki
[BIP337]: https://github.com/bitcoin/bips/blob/master/bip-0337.mediawiki
[BIP338]: https://github.com/bitcoin/bips/blob/master/bip-0338.mediawiki
[BIP339]: https://github.com/bitcoin/bips/blob/master/bip-0339.mediawiki
[BIP340]: https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki
[BIP341]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki
[BIP342]: https://github.com/bitcoin/bips/blob/master/bip-0342.mediawiki
[BIP345]: https://github.com/bitcoin/bips/blob/master/bip-0345.mediawiki
[BIP347]: https://github.com/bitcoin/bips/blob/master/bip-0347.mediawiki
[BIP350]: https://github.com/bitcoin/bips/blob/master/bip-0350.mediawiki
[BIP351]: https://github.com/bitcoin/bips/blob/master/bip-0351.mediawiki
[BIP352]: https://github.com/bitcoin/bips/blob/master/bip-0352.mediawiki
[BIP353]: https://github.com/bitcoin/bips/blob/master/bip-0353.mediawiki
[BIP370]: https://github.com/bitcoin/bips/blob/master/bip-0370.mediawiki
[BIP371]: https://github.com/bitcoin/bips/blob/master/bip-0371.mediawiki
[BIP372]: https://github.com/bitcoin/bips/blob/master/bip-0372.mediawiki
[BIP373]: https://github.com/bitcoin/bips/blob/master/bip-0373.mediawiki
[BIP379]: https://github.com/bitcoin/bips/blob/master/bip-0379.md
[BIP380]: https://github.com/bitcoin/bips/blob/master/bip-0380.mediawiki
[BIP381]: https://github.com/bitcoin/bips/blob/master/bip-0381.mediawiki
[BIP382]: https://github.com/bitcoin/bips/blob/master/bip-0382.mediawiki
[BIP383]: https://github.com/bitcoin/bips/blob/master/bip-0383.mediawiki
[BIP384]: https://github.com/bitcoin/bips/blob/master/bip-0384.mediawiki
[BIP385]: https://github.com/bitcoin/bips/blob/master/bip-0385.mediawiki
[BIP386]: https://github.com/bitcoin/bips/blob/master/bip-0386.mediawiki
[BIP387]: https://github.com/bitcoin/bips/blob/master/bip-0387.mediawiki
[BIP388]: https://github.com/bitcoin/bips/blob/master/bip-0388.mediawiki
[BIP389]: https://github.com/bitcoin/bips/blob/master/bip-0389.mediawiki
[BIP390]: https://github.com/bitcoin/bips/blob/master/bip-0390.mediawiki
[BIP431]: https://github.com/bitcoin/bips/blob/master/bip-0431.mediawiki

{% for i in (1..10) %}
{% assign i_padded = "0000" | append: i | slice: -4, 4 %}
[BIN24-{{i}}]: https://github.com/bitcoin-inquisition/binana/blob/master/2024/BIN-2024-{{i_padded}}.md
{% endfor %}

{% for i in (1..50) %}
{% assign i_padded = "0000" | append: i | slice: -4, 4 %}
[BLIP{{i}}]: https://github.com/lightning/blips/blob/master/blip-{{i_padded}}.md
{% endfor %}

{% comment %}<!-- Later link definitions supersede earlier definitions.
When more recent information about a BIP is available not in the regular
place, put links here. -->{% endcomment %}

{% comment %}<!-- BOLTs in order lowest to highest -->{% endcomment %}
[BOLT1]: https://github.com/lightningnetwork/lightning-rfc/blob/master/01-messaging.md
[BOLT2]: https://github.com/lightningnetwork/lightning-rfc/blob/master/02-peer-protocol.md
[BOLT3]: https://github.com/lightningnetwork/lightning-rfc/blob/master/03-transactions.md
[BOLT4]: https://github.com/lightningnetwork/lightning-rfc/blob/master/04-onion-routing.md
[BOLT5]: https://github.com/lightningnetwork/lightning-rfc/blob/master/05-onchain.md
[BOLT7]: https://github.com/lightningnetwork/lightning-rfc/blob/master/07-routing-gossip.md
[BOLT8]: https://github.com/lightningnetwork/lightning-rfc/blob/master/08-transport.md
[BOLT11]: https://github.com/lightningnetwork/lightning-rfc/blob/master/11-payment-encoding.md

{% comment %}<!--REQUIRES PERIODIC UPDATE: update rpc_version below to latest
version of BitcoinCore.org's RPC docs-->{% endcomment %}
{% assign rpc_prefix = "https://bitcoincore.org/en/doc/0.20.0/rpc" %}
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
