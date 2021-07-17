{% capture /dev/null %}
<!-- Tested the following on regtest:
  - according to getblockchaininfo, taproot becomes active at min_lockin_height
  - a tx with nlocktime x can't be sent at height x-1 and can be sent at height x

Not tested:
  - Actually spending a P2TR tx at min_lockin_height
-->

<!-- last block before taproot rules enforced -->
{% assign ante_trb = "709,631" %}
<!-- Conservatively reorg safe block after activation (+144 blocks) -->
{% assign safe_trb = "709,776" %}
{% endcapture %}

Earlier entries in this series saw us encouraging developers working on
wallets and services to begin implementing [taproot][topic taproot]
upgrades now so that they're ready when taproot activates.  But we've
also warned against generating any addresses for P2TR before block
{{site.trb}} as this could cause your service or your users to lose
money.

The reason not to generate addresses in advance is that any payment to a
P2TR-style output can be spent by *anyone*
prior to block {{site.trb}}.  The money would be completely unsecured.
But starting with that block, thousands of full nodes will begin
enforcing the rules of [BIP341][] and [BIP342][] (and, by association,
[BIP340][]).

If it was guaranteed that there wouldn't be a reorganization of the
block chain, it would be safe to start generating addresses for P2TR as
soon as the final pre-taproot block was seen (block {{ante_trb}}).  But
there's reason to be concerned about block chain reorgs---not just
accidental reorgs but also those deliberately created to take money from
early P2TR payments.

Imagine a large number of people all wanting to be one of the first to
receive a P2TR payment.  They naively send themselves some money as soon
as they see block {{ante_trb}}.[^timelocked-trb]  Those payments will be
secure in block {{site.trb}}, but they can be stolen by any miner who
creates an alternative to block {{ante_trb}}.  If the value of the money
sent to P2TR outputs is large enough, it could easily become more
profitable to attempt to mine two blocks instead of just one (see our
[fee sniping][topic fee sniping] topic for more details).

For this reason, we don't recommend your software or service generate
addresses for P2TR until you think the reorg risk has been effectively
eliminated.  We think waiting 144 blocks (approximately one day) after
activation is a reasonably conservative margin that minimizes risk
without significantly delaying you or your users from taking advantage
of the benefits of taproot.

In short:

- {{ante_trb}}: last block where anyone can spend money sent to a P2TR-style output
- {{site.trb}}: first block where P2TR outputs can only be spent if they satisfy
  the [BIP341][] and [BIP342][] rules.
- {{safe_trb}}: a reasonable block at which wallets can start giving their
  users [bech32m][topic bech32] receiving addresses for P2TR outputs

None of the above changes the advice given in the [first part][taproot
  series 1] of this series to enable paying to bech32m addresses as soon
  as possible.  If someone requests payment to an address for P2TR
  before you think it's safe, that's their risk to take.

[^timelocked-trb]:
    Users who want to receive a P2TR payment in the first taproot block
    should generate an address they don't share with anyone and then
    create a transaction to that address with nLockTime set to
    {{ante_trb}}.  That transaction can be broadcast at as soon as block
    {{ante_trb}} has been received.  The nLockTime will ensure the
    transaction can't be included into any block before {{site.trb}},
    where taproot rules are enforced.  Messing about with new script
    types and custom locktimes can be dangerous if you don't know what
    you're doing, so please take care.

[news139 st]: /en/newsletters/2021/03/10/#taproot-activation-discussion
[taproot series 1]: /en/preparing-for-taproot/#bech32m-sending-support
