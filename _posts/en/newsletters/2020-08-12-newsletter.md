---
title: 'Bitcoin Optech Newsletter #110'
permalink: /en/newsletters/2020/08/12/
name: 2020-08-12-newsletter
slug: 2020-08-12-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about
`SIGHASH_ANYPREVOUT` and eltoo, includes a field report showing how
57,000 BTC could have been saved in transaction fees using segwit and
batching, and provides our regular sections with the summary of a
Bitcoin Core PR Review Club meeting, releases and release candidates,
and notable changes to popular Bitcoin infrastructure projects.

## Action items

*None this week.*

## News

- **Discussion about eltoo and `SIGHASH_ANYPREVOUT`:** Richard Myers
  [resumed][myers anyprevout] a discussion about
  [SIGHASH_ANYPREVOUT][topic sighash_noinput] and provided a nice
  diagram of how its two [signature hash][] (sighash) types would be used
  within [eltoo][topic eltoo].  He also asked several questions about
  minimizing the number of network round trips needed to create eltoo
  state updates.  These questions received [answers from
  ZmnSCPxj][zmnscpxj reply] but also sparked a [second
  discussion][corallo relay] about attacks against LN payment atomicity
  within the context of eltoo.

    The advantage of eltoo over the currently used LN-penalty mechanism
    is that the publication of old eltoo channel states onchain doesn't
    prevent the publication of the ultimate channel state.  This is
    achieved in eltoo by creating signatures using `SIGHASH_ANYPREVOUT`
    so that the signature from the ultimate state can spend bitcoins
    from either the initial state, the penultimate state, or any state
    in between.  However, transactions still need to identify which
    state (previous output) they are attempting to spend.

    One problem with the eltoo mechanism is that both an attacker and an
    honest user could both try spending from the same previous state.
    Miners and relay nodes would only keep one of those transactions in
    their mempool, and there may be ways the attacker could ensure the
    version of the transaction everyone kept was an old state.  Another
    problem is that the attacker could
    possibly trick the honest user into spending from a state that relay
    nodes hadn't seen and so relay nodes would possibly reject the
    unconfirmed transaction because its parent transaction was not
    available.  Although neither of these problems would
    prevent the ultimate state from eventually being confirmed onchain,
    they could be used for [transaction pinning][topic transaction
    pinning] to prevent one of the honest user's time-sensitive
    transactions from confirming in time.  These problems are similar to
    the attack against LN payment atomicity described in [Newsletter
    #95][news95 ln atomicity].  One proposed mitigation would be to have
    special nodes (perhaps part of LN routing software) that looked for
    cases where eltoo was being used and could use their knowledge of
    that protocol to tell miners which transaction would truly be most
    profitable to mine.

## Field report: How segwit and batching could have saved half a billion dollars in fees

{% include articles/veriphi-segwit-batching.md %}

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

FIXME:jnewbery or jonatack

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/FIXME.html#FIXME"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.11.0-beta.rc2][lnd 0.11.0-beta] is a release candidate for the
  next major version of this project.  It allows accepting [large
  channels][topic large channels] (by default, this is off) and contains
  numerous improvements to its backend features that may be of interest
  to advanced users (see the [release notes][lnd 0.11.0-beta]).

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface (HWI)][hwi], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #18991][] Cache responses to GETADDR to prevent topology leaks FIXME:jnewbery

- [Bitcoin Core #19620][] prevents Bitcoin Core from re-downloading
  unconfirmed segwit transactions that attempt to spend non-standard
  UTXOs.  A non-standard UTXO is one that uses a currently discouraged
  feature, such as using v1 segwit outputs before those have been
  enabled on the network by a soft fork like [taproot][topic taproot].
  This helps address a concern described in [Newsletter #108][news108
  wtxid] about a potential taproot activation: nodes that don't upgrade
  for the soft fork won't accept unconfirmed taproot transactions, so
  they might end up downloading and rejecting the same unconfirmed
  taproot transactions over and over again.  That won't happen to any
  node running this patch, allowing backports of this patch to serve as
  an alternative to [backporting the wtxid relay feature][Bitcoin Core
  #19606], which would also prevent that wasted bandwidth.

- [C-Lightning #3909][] updates the `listpays` RPC to now return a new
  `created_at` field with a time stamp indicating when the first part of
  the payment was created.

- [Eclair #1499][] Add API commands to sign & verify arbitrary messages FIXME:dongcarl

{% include references.md %}
{% include linkers/issues.md issues="18991,19620,3909,1499,19606" %}
[lnd 0.11.0-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.11.0-beta.rc2
[news95 ln atomicity]: /en/newsletters/2020/04/29/#new-attack-against-ln-payment-atomicity
[myers anyprevout]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018069.html
[zmnscpxj reply]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018071.html
[corallo relay]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-August/018072.html
[news108 wtxid]: /en/newsletters/2020/07/29/#bitcoin-core-18044
[signature hash]: https://btcinformation.org/en/developer-guide#signature-hash-types
