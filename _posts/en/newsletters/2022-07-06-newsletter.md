---
title: 'Bitcoin Optech Newsletter #207'
permalink: /en/newsletters/2022/07/06/
name: 2022-07-06-newsletter
slug: 2022-07-06-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes discussions about long-term
block reward funding, alternatives to BIP47 reusable payment
codes, options for announcing LN channel splices, LN routing fee
collection strategies, and onion message rate limiting.  Also included
are our regular sections with announcements of new software releases and
release candidates, plus summaries of notable changes to popular Bitcoin
infrastructure software.

## News

- **Long-term block reward funding:** in a thread on the Bitcoin-Dev
  mailing list ostensibly about [covenants][topic covenants], it was
  noted that Bitcoin's long term security currently depends on
  demand for block space.   That demand must generate transaction
  fees to pay for Proof of Work (PoW) in excess of what an attacker
  would be willing to purchase to disrupt Bitcoin users.  Developer
  Peter Todd [pointed out][todd subsidy] that this dependency could be
  removed if the Bitcoin protocol were modified to include a perpetual
  subsidy.  Several respondents indicated that they thought the system
  is better off without a perpetual subsidy, while others looked for
  alternatives or apparent equivalencies such as [demurrage][].

  As of this writing, the thread appears to consist of casual
  conversation rather than advocacy for any particular proposal to
  change Bitcoin in the near future.

- **Updated alternative to BIP47 reusable payment codes:** developer
  Alfred Hodler [posted][hodler new codes] to the Bitcoin-Dev mailing
  list a proposal for an alternative to [BIP47][] that attempts to
  address some of the issues found during its use in production.  BIP47
  allows Alice to publish a payment code that anyone can use in
  combination with their own keys to create an unlimited number of
  private addresses for Alice that only they and Alice will know belong
  to her, avoiding the worst problems of [address reuse][topic output
  linking].

  However, one of the problems with BIP47 is that the first
  transaction from spender Bob to receiver Alice is a *notification
  transaction* that uses a special address associated with the payment
  code.  This definitely leaks to third parties who know Alice's
  payment code that someone is planning to start paying her.  If Bob's
  wallet isn't carefully designed to segregate funds used for
  notification transactions, the transaction may also leak that Bob is
  planning to pay Alice---reducing or possibly even eliminating the
  benefits of BIP47.

  Hodler's scheme would be less likely to leak this information but it
  would increase the amount of data a client implementing the protocol
  would need to learn from the block chain, making it less suitable
  for light clients.  Ruben Somsen indicated several alternatives
  that could also be investigated, including Somsen's silent
  payments idea (see [Newsletter #194][news194 silent payments]),
  Robin Linus's [2022 stealth addresses][] idea, and [previous
  discussion][prauge bip47] posted to the mailing list about improving
  upon BIP47.

- **Announcing splices:** in a [PR][bolts #1004] and a
  [discussion][osuntokun splice] on the Lightning-Dev mailing list,
  developers discussed the best way to communicate that a channel that
  was seemingly being closed onchain was in fact a [splice][topic
  splicing] where funds were being added to the channel or removed from
  it.

  One proposal was for nodes to simply not consider a channel closed
  until some amount of time after its onchain closing transaction was
  seen.  This would give time for the announcement of the new
  (post-splice) channel to propagate.  In the interim, nodes would
  still attempt to route payments through the seemingly-closed
  channel, as a spliced channel would still be able to forward
  payments with full LN security even before its new channel open
  transaction received a suitable number of confirmations.

  Another proposal was to include a signal onchain as part of the
  closing transaction that a splice was in progress, telling nodes
  that they could continue trying to forward payments through it.

  The discussion had not come to a clear conclusion at the time this
  summary was being written.

- **Fundamental fee-collection strategies for LN forwarding nodes:**
  developer ZmnSCPxj [summarized][zmnscpxj forwarding] three strategies
  LN forwarding nodes can use in collecting fees for routing payments
  (including the strategy of not collecting fees).  ZmnSCPxj then
  analyzes possible outcomes of the different strategies.  This seems
  related to his proposal for nodes to use routing fees to improve
  payment success rates, see [Newsletter #204][news204 fee signal],
  which also received significant [additional commentary][towns fee
  signal] in the past week from Anthony Towns.

- **Onion message rate limiting:** Bastien Teinturier
  [posted][teinturier rate limit] a summary of an idea he attributes to
  Rusty Russell for rate limiting [onion messages][topic onion
  messages].  The proposal has each node store just an extra 32 bytes of
  information for each of their peers that allows them to
  Probabilistically punish peers who send too much traffic.  The
  suggested penalty is to just halve the rate limit for a peer relaying
  too much traffic for about 30 seconds.  It's acceptable if this
  lightweight penalty is occasionally enforced against the wrong peer,
  as may happen with this idea.  The proposal also allows the originator
  of a message to learn which downstream nodes are rate limiting their
  messages (again probabilistically), giving them a chance to resend the
  message by a different route.

  Olaoluwa Osuntokun [suggested][osuntokun onion pay] reconsideration
  of his previous proposal for preventing abuse of onion messages by
  charging for data relay, see [Newsletter #190][news190 onion pay].
  Replies from other developers as of this writing seemed to indicate
  they first try the lightweight rate limiting to see if it works
  before adding the complexity of payments for onion messages.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LDK 0.0.109][] is a new release of this LN node library, which
  includes both of the new features described for LDK in the *notable
  changes* section below.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #24836][] adds a regtest-only RPC, `submitpackage`, to
  help L2 protocol and application developers who intend to use
  [package relay][topic package relay] in the future test their transactions against the
  Bitcoin Core default package policy.  The current policy is outlined
  [here][packages doc]. This RPC can also be used to test future
  additions and changes, such as the proposed package RBF rules.

- [Bitcoin Core #22558][] adds support for [BIP371][]’s additional [PSBT][topic
  psbt] fields (see [Newsletter #155][news155 psbt extensions]) for [taproot][topic taproot].

- [Core Lightning #5281][] adds support for specifying the `log-file`
  configuration option multiple times to write to multiple log files.

- [LDK #1555][] updates its pathfinding code to slightly prefer routing
  through channels which advertise that they won't accept payments
  larger than half the amount of money committed to the channel.  This
  is believed to provide a slight privacy improvement by limiting the
  amount of balance information a third party can discover by probing a
  channel (sending a payment ([HTLC][topic htlc]) they don't intend to
  settle).  If a set of payments up to the total amount of a channel can
  be sent, then a prober can learn nearly the exact balance of the
  channel by just trying different sets of payments until all parts are
  accepted.  However, if the set of payments which can be sent is limited to
  half the channel balance, it's harder for the prober to determine
  whether payments are being rejected because of a lack of funds on one
  side of the channel or because of the self-imposed limit (the
  `max_htlc_in_flight_msat` limit).  The [BOLT2][]
  `max_htlc_in_flight_msat` limit isn't gossiped, so LDK instead uses
  each channel's gossiped [BOLT7][] `htlc_maximum_msat` value as a proxy
  value.

- [LDK #1550][] provides the ability for users to add a list of nodes to
  a local banlist which will prevent pathfinding from routing payments
  through those nodes.

- [LND #6592][] adds a new `requiredreserve` RPC to the wallet subserver
  that prints the number of satoshis the wallet is reserving in UTXOs it
  unilaterally controls to fee bump [anchor outputs][topic anchor
  outputs] if necessary.  An additional `--additionalChannels` RPC
  parameter, which takes an integer argument, reports the number of
  satoshis the wallet will reserve if that number of additional channels
  are opened.

- [Rust Bitcoin #1024][] adds additional code for helping developers
  work around the [`SIGHASH_SINGLE` "bug"][shs1] where the Bitcoin protocol
  expects a value of `1` to be signed when the input containing the
  `SIGHASH_SINGLE` signature has an index number higher than the index
  number of any output in the transaction.

- [BTCPay Server #3709][] adds support for pull payments to be received
  via a [LNURL withdraw][].

- [BDK #611][] begins setting the nLockTime of new transactions to the
  height of the most recent block by default, enabling [anti fee
  sniping][topic fee sniping].

{% include references.md %}
{% include linkers/issues.md v=2 issues="24836,22558,5281,1555,1550,1024,3709,611,1004,6592" %}
[ldk 0.0.109]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.109
[lnurl withdraw]: https://github.com/fiatjaf/lnurl-rfc/blob/luds/03.md
[todd subsidy]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020551.html
[hodler new codes]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020605.html
[news194 silent payments]: /en/newsletters/2022/04/06/#delinked-reusable-addresses
[prauge bip47]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-June/020549.html
[osuntokun splice]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003616.html
[zmnscpxj forwarding]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003617.html
[news204 fee signal]: /en/newsletters/2022/06/15/#using-routing-fees-to-signal-liquidity
[towns fee signal]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003624.html
[teinturier rate limit]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003623.html
[osuntokun onion pay]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003631.html
[news190 onion pay]: /en/newsletters/2022/03/09/#paying-for-onion-messages
[2022 stealth addresses]: https://gist.github.com/RobinLinus/4e7467abaf0a0f8a521d5b512dca4833
[demurrage]: https://en.wikipedia.org/wiki/Demurrage_%28currency%29
[shs1]: https://www.coinspect.com/capture-coins-challenge-1-sighashsingle/
[packages doc]: https://github.com/bitcoin/bitcoin/blob/09f32cffa6c3e8b2d77281a5983ffe8f482a5945/doc/policy/packages.md
[news155 psbt extensions]: /en/newsletters/2021/06/30/#psbt-extensions-for-taproot
