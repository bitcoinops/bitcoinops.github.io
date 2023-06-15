---
title: 'Bulletin Hebdomadaire Bitcoin Optech #255'
permalink: /fr/newsletters/2023/06/14/
name: 2023-06-14-newsletter-fr
slug: 2023-06-14-newsletter-fr
type: newsletter
layout: newsletter
lang: fr
---
This week's newsletter summarizes a discussion about allowing relay of
transactions containing data in the taproot annex field and links to a
draft BIP for silent payments.  Also included is another entry in our
limited weekly series about mempool policy, plus our regular sections
summarizing a Bitcoin Core PR Review Club meeting, announcing new
software releases and release candidates, and describing notable changes
to popular Bitcoin infrastructure software.

## News

- **Discussion about the taproot annex:** Joost Jager [posted][jager
  annex] to the Bitcoin-Dev mailing list a request for a change in the Bitcoin Core
  transaction relay and mining policy to allow storing arbitrary data in
  the [taproot][topic taproot] annex field.  This field is an optional
  part of the witness data for taproot transactions.  If present,
  signatures in taproot and [tapscript][topic tapscript] must commit to
  its data (making it impossible for a third party to add, remove, or
  change) but it has no other defined purpose at present---it's reserved
  for future protocol upgrades, especially soft forks.

    Although there have been [previous proposals][riard annex] to define
    a format for the annex, these have not seen widespread acceptance
    and implementation.  Jager proposed two formats ([1][jager annex],
    [2][jager annex2]) that could be used to allow anyone to add
    arbitrary data to the annex in a way that would not significantly
    complicate later standardization efforts that might be bundled with
    a soft fork.

    Greg Sanders [replied][sanders annex] to ask what data Jager
    specifically wanted to store in the annex and described his own use
    for the annex in testing the [LN-Symmetry][topic eltoo] protocol
    with the [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] soft fork
    proposal using Bitcoin Inquisition (see [Newsletter #244][news244
    annex]).  Sanders also described a problem with the annex: in a
    multi-party protocol (such as a [coinjoin][topic coinjoin]), each
    signature only commits to the annex for the input containing that
    signature---not the annexes for other inputs in the same
    transaction.  That means if Alice, Bob, and Mallory sign a coinjoin
    together, there's no way Alice and Bob can prevent Mallory from
    broadcasting a version of the transaction with a large annex that
    delays its confirmation.  Because Bitcoin Core and other full nodes
    don't currently relay transactions that contain annexes, this is not
    a problem at present.  Jager [replied][jager annex4] that he wants
    to store signatures from ephemeral keys for a type of [vault][topic
    vaults] that doesn't require a soft fork, and he  [suggested][jager
    annex3] that some
    [previous work][bitcoin core #24007] in Bitcoin Core could possibly
    address the problem with annex relay in some multiparty protocols.

- **Draft BIP for silent payments:** Josie Baker and Ruben Somsen
  [posted][bs sp] to the Bitcoin-Dev mailing list a draft BIP for
  [silent payments][topic silent payments], a type of reusable payment
  code that will produce a unique onchain address each time it is used,
  preventing [output linking][topic output linking].  Output linking can
  significantly reduce the privacy of users (including users not
  directly involved in a transaction).  The draft goes into detail about
  the benefits of the proposal, its tradeoffs, and how software can
  effectively use it.  Several insightful comments have already been
  posted on the [PR][bips #1458] for the BIP.

## Waiting for confirmation #5: Policy for Protection of Node Resources

_A limited weekly [series][policy series] about transaction relay,
mempool inclusion, and mining transaction selection---including why
Bitcoin Core has a more restrictive policy than allowed by consensus and
how wallets can use that policy most effectively._

{% include specials/policy/en/05-dos.md %}

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Allow inbound whitebind connections to more aggressively evict peers when slots are full][review club 27600]
is a PR by Matthew Zipkin (pinheadmz) that improves a node operator's
ability in certain cases to configure desired peers for the node.
Specifically, if the node operator has whitelisted a potential inbound
peer (for example, a light client controlled by the node operator), then
without this PR, and depending on the node's peer state, it's possible
that the node will deny this light client's connection attempt.

This PR makes it much more likely that the desired peer will be able to
connect to our node. It does this by evicting an existing inbound peer
that, without this PR, would have been ineligible for eviction.

{% include functions/details-list.md
  q0="Why does this PR only apply to inbound peer requests?"
  a0="Our node _initiates_ outbound connections; this PR modifies how
      the node _reacts_ to an incoming connection request.
      Outbound nodes can be evicted, but that's done with an entirely
      separate algorithm."
  a0link="https://bitcoincore.reviews/27600#l-33"

  q1="What is the impact of the `force` parameter of `SelectNodeToEvict()`
      on the return value?"
  a1="Specifying `force` as `true` ensures that a non-`noban` inbound peer
      is returned, if one exists, even if it would otherwise be protected
      from eviction.
      Without the PR, it would not return a peer if they all are excluded
      (protected) from eviction."
  a1link="https://bitcoincore.reviews/27600#l-70"

  q2="How is the function signature of `EraseLastKElements()` changed in this PR?"
  a2="It changed from being a `void` return function to returning the last
      entry that was _removed_ from the eviction candidates list. (This
      \"protected\" node might be evicted if necessary.)
      However, as a result of discussion during the review club meeting,
      the PR was later simplified such that this function is no longer modified."
  a2link="https://bitcoincore.reviews/27600#l-126"

  q3="`EraseLastKElements` used to be a templated function, but this PR removes
      the two template arguments. Why? Are there any downsides to this change?"
  a3="This function was and (with this PR) is being called with unique template
      arguments, so there is no need for the function to be templated.
      The PR's changes to this function were reverted, so it's still templated,
      because changing this would be beyond the scope of the PR."
  a3link="https://bitcoincore.reviews/27600#l-126"

  q4="Suppose we pass a vector of 40 eviction candidates to `SelectNodeToEvict()`.
      Before and after this PR, what’s the theoretical maximum of Tor nodes
      that can be protected from eviction?"
  a4="Both with and without the PR, the number would be 34 out of 40, assuming
      they're not `noban` and inbound."
  a4link="https://bitcoincore.reviews/27600#l-156"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning 23.05.1][] is a maintenance release for this LN
  implementation.  Its release notes say, "this is a bugfix-only release
  which repairs several crashes reported in the wild. It is a
  recommended upgrade for anyone on v23.05."

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27501][] adds a `getprioritisedtransactions` RPC that
  returns a map of all fee deltas created by the user with
  `prioritisetransaction`, indexed by txid. The map also indicates whether
  each transaction is present in the mempool.  See also [Newsletter
  #250][news250 getprioritisedtransactions].

- [Core Lightning #6243][] updates the `listconfigs` RPC to put all
  configuration information in a single dictionary and also passes the
  state of all configuration options to restarted plugins.

- [Eclair #2677][] increases the default `max_cltv` from 1,008 blocks
  (about one week) to 2,016 blocks (about two weeks). This extends the
  maximum permitted number of blocks until a payment attempt
  times out. The change is motivated by nodes on the network raising
  their reserved time window to address an expiring HTLC
  (`cltv_expiry_delta`) in response to high on-chain feerates. Similar
  changes have been [merged to LND][lnd max_cltv] and CLN.

- [Rust bitcoin #1890][] adds a method for counting the number of
  signature operations (sigops) in non-tapscript scripts.  The number of
  sigops is limited per block and Bitcoin Core's transaction selection
  code for mining treats transactions with a high ratio of sigops per
  size (weight) as if they were larger transactions, effectively
  lowering their feerate.  That means it can be important for
  transaction creators to use something like this new method to check
  the number of sigops they are using.

{% include references.md %}
{% include linkers/issues.md v=2 issues="27501,6243,2677,1890,1458,24007" %}
[policy series]: /en/blog/waiting-for-confirmation/
[jager annex]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021731.html
[riard annex]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020991.html
[jager annex2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021756.html
[sanders annex]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021736.html
[news244 annex]: /en/newsletters/2023/03/29/#bitcoin-inquisition-22
[jager annex3]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021743.html
[bs sp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021750.html
[jager annex4]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021737.html
[Core Lightning 23.05.1]: https://github.com/ElementsProject/lightning/releases/tag/v23.05.1
[review club 27600]: https://bitcoincore.reviews/27600
[news250 getprioritisedtransactions]: /en/newsletters/2023/05/10/#bitcoin-core-pr-review-club
[lnd max_cltv]: /en/newsletters/2019/10/23/#lnd-3595
