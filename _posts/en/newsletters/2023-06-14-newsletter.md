---
title: 'Bitcoin Optech Newsletter #255'
permalink: /en/newsletters/2023/06/14/
name: 2023-06-14-newsletter
slug: 2023-06-14-newsletter
type: newsletter
layout: newsletter
lang: en
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

## Waiting for confirmation #5: Feerates for DoS protection

_A limited weekly [series][policy series] about transaction relay,
mempool inclusion, and mining transaction selection---including why
Bitcoin Core has a more restrictive policy than allowed by consensus and
how wallets can use that policy most effectively._

{% include specials/policy/en/05-feerate-dos-protection.md %}

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

FIXME:LarryRuane

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/27501#l-FIXME"
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

- [Bitcoin Core #27501][] mempool / rpc: add getprioritisedtransactions, delete a mapDeltas entry when delta==0 FIXME:AdamJonas

- [Core Lightning #6243][] updates the `listconfigs` RPC to put all
  configuration information in a single dictionary and also passes the
  state of all configuration options to restarted plugins.

- [Eclair #2677][] Increase default max-cltv value ; Maybe use as a template / link to https://bitcoinops.org/en/newsletters/2019/10/23/#lnd-3595 FIXME:Xekyo

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
