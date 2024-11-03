---
title: 'Bitcoin Optech Newsletter #161'
permalink: /en/newsletters/2021/08/11/
name: 2021-08-11-newsletter
slug: 2021-08-11-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter follows up on a previous description about
fidelity bonds in JoinMarket and includes our regular sections with the
summary of a Bitcoin Core PR Review Club meeting, suggestions for
preparing for taproot, announcements of releases and release candidates,
and descriptions of notable changes to popular infrastructure projects.

## News

- **Implementation of fidelity bonds:** the [JoinMarket 0.9.0][]
  implementation of [coinjoin][topic coinjoin] includes [support][jm notes]
  for [fidelity bonds][fidelity bonds doc].  As previously described in
  [Newsletter #57][news57 fidelity bonds], the bonds improve the sybil resistance of the
  JoinMarket system, increasing the ability for coinjoin initiators
  ("takers") to choose unique liquidity providers ("makers").  Within
  days of release, [over 50 BTC][waxwing toot] (currently valued at over
  $2 million USD) had been placed in timelocked fidelity bonds.

  Although the specific implementation is unique to JoinMarket, the
  overall design may be useful in other decentralized protocols built
  on top of Bitcoin.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Prefer to use txindex if available for GetTransaction][review club #22383] is a PR by Jameson Lopp
which improves the performance of `GetTransaction` (and, by extension, the `getrawtransaction` RPC
for users) by utilizing the transaction index (txindex) when possible. This change fixes an unexpected
performance loss in which a call to `getrawtransaction` on a txindex-enabled node is significantly
slower when called with the hash of the block that includes the transaction. The review club
evaluated the cause of this performance issue by comparing the steps to retrieve a transaction with
and without txindex.

{% include functions/details-list.md

  q0="What are the different ways `GetTransaction` can retrieve a transaction from disk?"
  a0="The transaction can be retrieved from the mempool (if unconfirmed), by retrieving the entire
  block from disk and searching for the transaction, or by using txindex to fetch the transaction
  from disk by itself."
  a0link="https://bitcoincore.reviews/22383#l-33"

  q1="Why do you think that performance is worse when the block hash is provided (when txindex is
  enabled)?"
  a1="Participants guessed that the bottleneck was in the deserialization of the block. Another
  process unique to fetching the entire block - albeit less time-consuming - is a linear search
  through the entire list of transactions."
  a1link="https://bitcoincore.reviews/22383#l-42"

  q2="If we are looking up the transaction by block hash, what are the steps? How much data
  is deserialized?"
  a2="We first use the block index to find the file and byte offset necessary for accessing the block.
  We then fetch and deserialize the entire block and scan through the list of transactions until we
  find a match. This involves deserializing about 1-2MB of data."
  a2link="https://bitcoincore.reviews/22383#l-56"

  q3="If we are looking up the transaction using the txindex, what are the steps? How much data is
  deserialized?"
  a3="The txindex maps from transaction id to the file, block position (similar to the block index),
  and the offset within the blk\*.dat file where the transaction starts. We fetch and deserialize the
  block header and transaction. The header is 80B and allows us to return the block hash to the user
  (which is information not stored in the txindex). The transaction
  can be any size but is typically thousands of times smaller than the block."
  a3link="https://bitcoincore.reviews/22383#l-88"

  q4="The first version of this PR included a behavior change: when an incorrect `block_index` is
  provided to `GetTransaction`, find and return the tx anyway using the txindex. Do you think this change is an improvement,
  and should it be included in this PR?"
  a4="Participants agreed that it could be helpful but misleading, and that notifying the
  user of the incorrect block hash input would be better. They also noted that a performance
  improvement and behavior change would be best split into separate PRs."
  a4link="https://bitcoincore.reviews/22383#l-128"
%}

## Preparing for taproot #8: multisignature nonces

*A weekly [series][series preparing for taproot] about how developers
and service providers can prepare for the upcoming activation of taproot
at block height {{site.trb}}.*

{% include specials/taproot/en/07-nonces.md %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [C-Lightning 0.10.1][] is a release
  that contains a number of new features, several bug fixes,
  and a few updates to developing protocols (including [dual
  funding][topic dual funding] and [offers][topic offers]).

- [Bitcoin Core 22.0rc2][bitcoin core 22.0] is a release candidate
  for the next major version of this full node implementation and its
  associated wallet and other software. Major changes in this new
  version include support for [I2P][topic anonymity networks] connections,
  removal of support for [version 2 Tor][topic anonymity networks] connections,
  and enhanced support for hardware wallets.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #21528][] aims to improve the p2p propagation of full
  node listening addresses.  Exposure to a diverse set of addresses is important
  for nodes to be protected against network partitions such as [eclipse attacks][topic eclipse attacks].
  When Bitcoin Core nodes receive an address message containing 10 or fewer
  addresses, they forward it to 1 or 2 peers. This is the primary technique
  used to self-advertise addresses, so sending to peers that would not relay
  these addresses would effectively stop or "black hole" the propagation through
  the network. Although propagation failures cannot be prevented in the malicious case, this
  patch improves address propagation for the honest cases, such as for block-relay-only
  connections or light clients.

  This update identifies whether or not an inbound connection is a
  candidate for forwarding addresses based on whether it has sent an address
  related message over the connection, such as `addr`, `addrv2`, or `getaddr`. This behavior
  change could be problematic if there is software on the network that
  relies on receiving address messages but never initiates an address-related
  message. Therefore, the author took care to circulate this proposed change
  before it was merged, including posting it to the
  [mailing list][addrRelay improvements] and researching
  [other open source clients][addr client research] to confirm compatibility.

- [LND #5484][] allows storing all data in a single external Etcd
  database. This improves high-availability deployments by making cluster
  leadership changes instantaneous. The corresponding LND clustering
  documentation was previously covered in [Newsletter #157][news157 lnd ha].

- [Rust-Lightning #1004][] adds a new event for `PaymentForwarded` that
  allows tracking when a payment has been successfully forwarded.  Since
  successful forwarding may earn fees for the node, this allows tracking
  that income for the user's accounting records.

- [BTCPay Server #2730][] makes the amount optional when generating
  invoices. This simplifies the payment flow in cases where the operator
  delegates the choice of the amount to the user, e.g. when topping up
  an account.

{% include references.md %}
{% include linkers/issues.md issues="21528,5484,1004,2730,22383" %}
[C-Lightning 0.10.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.1
[joinmarket 0.9.0]: https://github.com/JoinMarket-Org/joinmarket-clientserver/releases/tag/v0.9.0
[jm notes]: https://github.com/JoinMarket-Org/joinmarket-clientserver/blob/master/docs/release-notes/release-notes-0.9.0.md#fidelity-bond-for-improving-sybil-attack-resistance
[fidelity bonds doc]: https://gist.github.com/chris-belcher/18ea0e6acdb885a2bfbdee43dcd6b5af/
[waxwing toot]: https://x0f.org/@waxwing/106696673020308743
[news57 fidelity bonds]: /en/newsletters/2019/07/31/#fidelity-bonds-for-improved-sybil-resistance
[addrRelay improvements]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-April/018784.html
[addr client research]: https://github.com/bitcoin/bitcoin/pull/21528#issuecomment-809906430
[news157 lnd ha]: /en/newsletters/2021/07/14/#lnd-5447
[bitcoin core 22.0]: https://bitcoincore.org/bin/bitcoin-core-22.0/
