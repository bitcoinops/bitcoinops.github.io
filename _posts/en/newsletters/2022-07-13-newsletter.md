---
title: 'Bitcoin Optech Newsletter #208'
permalink: /en/newsletters/2022/07/13/
name: 2022-07-13-newsletter
slug: 2022-07-13-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes discussions about half aggregation of
schnorr signatures, a workaround for protocols that can't reliably use
x-only pubkeys, and allowing deliberately slow LN payment forwarding.
Also included are our regular sections with the summary of a Bitcoin
Core PR Review Club, announcements of releases and relase candidates,
and descriptions of notable changes to popular Bitcoin infrastructure
projects.

## News

- **Half aggregation of BIP340 signatures:** Jonas Nick [posted][nick
  agg] to the Bitcoin-Dev mailing list a [draft BIP][bip-agg] and [blog
  post][blog agg] about half aggregation of Bitcoin's [schnorr
  signatures][topic schnorr signatures].  As mentioned in the blog post,
  the proposal "allows aggregating multiple schnorr signatures into a
  single signature that is about half as long as the sum of the
  individual signatures.  Importantly, this scheme is non-interactive,
  which means that a set of signatures can be half-aggregated by a third
  party without any involvement from the signers."

    A [separate document][cia doc] provides examples of how half
    aggregation could benefit the operators of Bitcoin and LN nodes, plus
    several concerns that would need to be considered in the design of a
    soft fork adding half aggregation to the consensus protocol.

- **X-only workaround:** Bitcoin public keys are points on a
  two-dimensional graph which are referenced by the intersection of an
  *x* coordinate and a *y* coordinate.  For any given *x* coordinate,
  there are only two valid *y* coordinates and these can be calculated
  from the *x* value.  This allowed an optimization in the design of
  [taproot][topic taproot] to require all public keys used with
  [BIP340][]-style schnorr signatures to only use a certain one of these
  *y* coordinates, allowing any public keys included in transactions to
  omit including the *y* point entirely, saving one vbyte per signature
  over the original taproot design.

    At the time, this technique (called *x-only public keys*) was thought
    to be an optimization with no significant tradeoffs, but later
    design work on OP_TAPLEAF_UPDATE_VERIFY ([TLUV][news166 tluv])
    revealed that x-only pubkeys required either computationally
    limiting the proposal or storing extra data in the block chain or
    UTXO set.  The problem may affect other advanced uses of pubkeys as
    well.

    This week, Tim Ruffing [posted][ruffing xonly] to the Bitcoin-Dev
    mailing list a potential workaround that only requires a slight bit
    of additional computation by signers---an amount that even a
    resource-constrained hardware signing device can probably perform
    without making its user wait too long.

- **Allowing deliberately slow LN payment forwarding:** in a reply to a
  thread about recursive/nested [MuSig2][topic musig] (see [Newsletter #204][news204
  rmusig]) and the latency that nodes using it would add when routing
  payments, developer Peter Todd [asked][todd delay] on the
  Lightning-Dev mailing list whether it would "be worthwhile to allow
  people to opt-in to their payments happening more slowly for privacy?"
  For example, if Alice and Bob each sent forward-slowly payments around
  the same time through Carol's forwarding node to Dan's forwarding
  node, Carol would be able to forward both payments together, reducing
  the amount of privacy-leaking information about the participants that
  third parties could discover through [balance probing][topic payment
  probes], network activity surveillance, or other techniques.  Developer
  Matt Corallo [agreed][corallo delay] it was an interesting idea.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

FIXME:glozow

{% include functions/details-list.md

  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/24148#l-41FIXME"

%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BTCPay Server 1.6.1][] is a release of the 1.6 branch of this popular
  self-hosted payment processor solution which includes multiple new
  features and bug fixes.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25353][] Add a `-mempoolfullrbf` node setting FIXME:Xekyo

- [Bitcoin Core #25454][] p2p: Avoid multiple getheaders messages in flight to the same peer FIXME:adamjonas

- [Core Lightning #5239][] improves the gossip handling code by updating
  CLN's internal map of the payment relay network using all received
  announcements but continuing to only relay the announcements that
  satisfy CLN's gossip rate limits.  Previously, CLN dropped incoming
  messages according to its rate limits.  The change can give CLN nodes
  a better view of the network when their peers have looser (or no) rate
  limits without affecting how much data CLN sends to its peers.

- [Core Lightning #5275][] adds support for [zero-conf channel
  opens][topic zero-conf channels] and the related Short Channel
  IDentifier (SCID) aliases (see
  [Newsletter #203][news203 scid]).  This includes updates to the
  `listpeers`, `fundchannel`, and `multifundchannel` RPCs.

- [LND #5955][], like the merge listed above, also adds support for
  zero-conf channel opens and the related SCID aliases.

- [LDK #1567][] adds support for a basic [payment probing][topic payment probes]
  API that can be used by an application to test which payment
  routes will be more likely to succeed if a payment is sent through
  them in the near future.  It includes support for constructing the
  [HTLCs][topic htlc] in a way that allows the sending node to separate
  them from actual payment HTLCs when they come back without storing any
  extra state.

- [LDK #1589][] adds a [security policy][ldk security policy] that can
  be used for safely reporting security vulnerabilities to the LDK
  maintainers.

- [BTCPay Server #3922][] adds the basic UI for *custodian
  accounts*---accounts tied into a BTCPay instance where the funds are
  managed by a custodian, such as a Bitcoin exchange (rather than by the
  local user controlling their own private keys).  BTCPay instances may
  have both local wallets and custodian accounts, which can make it
  easy to manage funds between them, e.g. allowing a merchant to receive
  funds privately and securely to their wallet but also quickly transfer
  amounts to an exchange to be sold.

- [BDK #634][] adds a `get_block_hash` method that returns a header
  hash for a block on the best block chain at a particular height.

- [BDK #614][] avoids creating transactions that spend from immature
  coinbase outputs---outputs to a miner's coinbase transaction which
  have less than 100 confirmations (blocks built on top of that block).

{% include references.md %}
{% include linkers/issues.md v=2 issues="25353,25454,5239,5275,5955,1567,1589,3922,634,614" %}
[btcpay server 1.6.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.6.1
[ldk security policy]: https://github.com/TheBlueMatt/rust-lightning/blob/92919c8f375311e4f9a596d64a026a172839dd0f/SECURITY.md
[nick agg]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020662.html
[bip-agg]: https://github.com/ElementsProject/cross-input-aggregation/blob/master/half-aggregation.mediawiki
[blog agg]: https://blog.blockstream.com/half-aggregation-of-bip-340-signatures/
[news166 tluv]: /en/newsletters/2021/09/15/#covenant-opcode-proposal
[ruffing xonly]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020663.html
[news204 rmusig]: /en/newsletters/2022/06/15/#recursive-musig2
[todd delay]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003621.html
[corallo delay]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-June/003641.html
[news203 scid]: /en/newsletters/2022/06/08/#bolts-910
[cia doc]: https://github.com/ElementsProject/cross-input-aggregation
