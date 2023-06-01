---
title: 'Bitcoin Optech Newsletter #54'
permalink: /en/newsletters/2019/07/10/
name: 2019-07-10-newsletter
slug: 2019-07-10-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the release of the newest version of
Eclair and describes a potential routing improvement for LN.  Also
included are our regular sections about bech32 sending support and
notable code changes in popular Bitcoin infrastructure projects.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

*None this week.*

## News

- **Eclair 0.3.1 released:** the newest version of this LN software
  includes new and improved API calls as well as other changes that allow
  it to perform faster and use less memory.  [Upgrading][Eclair 0.3.1]
  is recommended.

- **Brainstorming just-in-time routing and free channel rebalancing:**
  sometimes LN nodes receive a routed payment that they reject because
  their outbound channel for that payment doesn't currently have a high
  enough balance to support it.  Rene Pickhardt previously
  [proposed][pickhardt jit] Just-In-Time (JIT) routing where the node
  would attempt to move funds into that channel from one or more of its
  other channel balances.  If successful, the payment could then be
  routed; otherwise, it would be rejected like normal.  Because the
  routed payment might fail for other reasons and prevent the routing
  node from earning any fees, any JIT rebalance operations need to be
  free or they could end up costing the node money in a way that
  attackers could exploit.

    In a new [post][zmn jit] to the Lightning-Dev mailing list,
    pseudonymous LN developer [[ZmnSCPxj]] describes two situations in which
    other profit-maximizing nodes might allow free rebalances.  The
    first case is the observation that the next hop in the route
    will receive its own routing fee paid
    by the spender if the payment succeeds.  ZmnSCPxj describes a method
    by which the next hop's node can make their part of the rebalance contingent on
    receipt of the routing income, ensuring that they either get
    paid or the rebalance doesn't happen.  This would require additional
    communication between nodes and so it's a change that probably needs
    further discussion in order to be considered for addition to the LN
    specification.

    The second case ZmnSCPxj describes is other nodes along the
    rebalance path who themselves want to rebalance one or more of their
    channels in the same direction as the routing node.  These nodes can
    allow free routing in that direction to encourage someone to perform
    that rebalancing.  This second case doesn't require any changes to
    the LN specification: nodes can already set their routing fees to
    zero, allowing any other nodes to attempt JIT routing with free
    rebalances.  The worst case would be that a payment that would've
    failed anyway will take a bit longer to return a failure message to
    the spender, a delay equal to the amount of time any routing nodes
    spent attempting to rebalance their channels in order to support the
    payment.

## Bech32 sending support

*Week 17 of 24 in a [series][bech32 series] about allowing the people
you pay to access all of segwit's benefits.*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/17-signmessage.md %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], and [Bitcoin Improvement Proposals
(BIPs)][bips repo].*

- [Bitcoin Core #15427][] extends the `utxoupdatepsbt` RPC with a `descriptors` parameter
  that takes an [output script descriptor] and uses it to update a
  [BIP174][] Partially Signed Bitcoin Transaction (PSBT) with
  information about the scripts (addresses) involved in the transaction.
  This is in addition to the RPC's previous behavior of adding
  information to the PSBT from the node's mempool and UTXO set.  This
  new feature is especially useful for hardware wallets and other paired
  wallets as it makes it possible to add HD key-path information to the
  PSBTs so that wallets asked to sign a PSBT can easily derive the keys
  needed for signing or verify that a change output does indeed pay back
  into the wallet.

- [Bitcoin Core #16257][] aborts adding funds to an unsigned transaction
  if its feerate is above the maximum amount set by the `maxtxfee`
  configuration option (default: 0.1 BTC).  Previously, the funding code
  would silently reduce the fee to the maximum, which could lead to
  users with typos in their transactions overpaying as much as $1,200
  USD in fees (at current prices).  The new behavior gives users a
  chance to fix typos and eliminate any loss of funds.

- [Eclair #1045][] adds support for Tag-Length-Value (TLV) message
  encoding.  LN implementations [plan][tlv pr] to move most of their
  messages to this format in the future.  LND and C-Lightning have
  previously implemented TLV support.

{% include linkers/issues.md issues="15427,16326,16257,1045" %}
[bech32 series]: /en/bech32-sending-support/
[lnd rc]: https://github.com/LightningNetwork/lnd/releases
[eclair 0.3.1]: https://github.com/ACINQ/eclair/releases/tag/v0.3.1
[tlv pr]: https://github.com/lightningnetwork/lightning-rfc/pull/607
[pickhardt jit]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-March/001891.html
[zmn jit]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-July/002055.html
