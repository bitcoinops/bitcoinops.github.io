---
title: 'Bitcoin Optech Newsletter #284'
permalink: /en/newsletters/2024/01/10/
name: 2024-01-10-newsletter
slug: 2024-01-10-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes discussion about LN anchors and
elements of the v3 transaction relay proposal and announces a
research implementation of LN-Symmetry.  Also included are our regular
sections with the summary of Bitcoin Core PR Review Club meeting and the
description of notable changes to popular Bitcoin infrastructure
software.

## News

- **Discussion about LN anchors and v3 transaction relay proposal:**
  Antoine Poinsot [posted][poinsot v3] to Delving Bitcoin to
  foster discussion about the proposals for [v3 transaction relay
  policy][topic v3 transaction relay] and [ephemeral anchors][topic
  ephemeral anchors].  The thread appears to have been motivated by
  Peter Todd [posting][todd v3] a critique of v3 relay policy on his
  blog.  We've arbitrarily divided the discussion into several parts:

  {% assign timestamp="1:03" %}

  - **Frequent use of exogenous fees may risk mining decentralization:**
    an ideal version of the Bitcoin protocol would reward each miner
    proportionately to their hashrate.  The implicit fees paid in
    transactions preserve that property: a miner with 10% of total
    hashrate has a 10% chance of capturing a next-block fee, whereas a
    miner with 1% of hashrate has a 1% chance.  Fees paid outside of
    transactions and directly to miners, called [out-of-band fees][topic out-of-band fees],
    violate that property: a system that pays miners who together control
    over 55% of hashrate has a 99% chance of getting a transaction
    confirmed within 6 blocks<!-- 1 - (1 - 0.55)**6 -->, likely resulting
    in little effort being made to pay small miners of 1% or less
    hashrate.  If small miners are paid proportionately less than large miners, mining
    will naturally centralize, which will reduce the number of entities
    that need to be compromised in order to censor which transactions
    get confirmed.

    Actively used protocols such as [LN-Penalty with anchors][topic
    anchor outputs] (LN-Anchors), [DLCs][dlc cpfp], and [client-side
    validation][topic client-side validation] allow at least some of
    their onchain transactions to pay fees _exogenously_, meaning the
    fees paid by the core of the transaction can be augmented with
    fees paid using one or more independent UTXOs.  For example, in
    LN-Anchors the commitment transaction includes one output for each
    party to fee bump using [CPFP][topic cpfp] (the child transaction
    spending an extra UTXO) and the HTLC-Success and HTLC-Failure
    transactions (HTLC-X transactions) are partly signed using
    `SIGHASH_SINGLE|SIGHASH_ANYONECANPAY` so they can be aggregated
    into a single transaction with at least one extra input to pay
    fees (the extra input being a separate UTXO).

    Focusing on a thought-experiment version of LN that uses [P2TR][topic
    taproot] and proposed ephemeral anchors, Peter Todd argues that
    its dependency on exogenous fees significantly incentivizes paying
    out-of-band fees.  In particular, the unilateral close of a
    channel with no pending payments ([HTLCs][topic htlc]) would
    allow a large miner accepting out-of-band fees to include twice as many
    close transactions in a block than could be included by a smaller
    miner who only accepted in-band fees paid for through CPFP fee
    bumping.  The large miner could profitably encourage this by
    offering a moderate discount to users paying out of band.  Peter
    Todd calls that a threat to decentralization.

    The post does suggest that some uses of exogenous fees in protocols is
    acceptable, so the concern may be about the frequency of their
    expected use and the relative size difference between using them
    and paying out of band.  In other words, frequently occurring
    zero-pending unilateral closes with a 100% overhead would likely
    be considered more of a risk than potentially rarer unilateral
    closes with 20 pending HTLCs where the overhead is less than 10%.

  - **Implications of exogenous fees on safety, scalability, and costs:**
    Peter Todd's post also noted that existing designs such as
    [LN-Anchors][topic anchor outputs] and future designs that use
    [ephemeral anchors][topic ephemeral anchors] require each user to keep
    an extra UTXO in their wallet to use for essential fee bumping.
    Because creating UTXOs costs block space, this reduces the maximum
    number of independent users of the protocol by half or more in
    theory.  It also means a user can't safely allocate their full
    wallet balance to their LN channels, which worsens the LN user
    experience.  Finally, using [CPFP fee bumping][topic cpfp] or
    attaching additional inputs to a transaction to pay fees exogenously
    requires using more block space and paying more transaction fees
    than paying fees directly from a transaction's input value
    (endogenous fees), making it more expensive in theory even if the
    other problems were not a concern.

  - **Ephemeral anchors introduce a new pinning attack:** as described in
    [last week's newsletter][news283 pinning], Peter Todd described a
    minor pinning attack against uses of ephemeral anchors.  For a
    commitment transaction with no pending payments (HTLCs), an
    unprivileged attacker could create a situation when an honest user
    might have to pay 1.5x to 3.7x more in fees to obtain the feerate
    they intended.  However, if the honest user chose to be [patient][harding
    pinning] instead of spending extra fees, the attacker would end up
    paying some or all of the honest user's fees.  Given that
    zero-pending commitment transactions don't have any
    timelock-dependent urgency, many honest users might choose to be
    patient and get their transaction confirmed at the attacker's
    expense.  The attack also works when HTLCs are used, but it
    costs the honest user less to break free and can still result in the
    attacker losing money.

  - **An alternative: use endogenous fees with presigned incremental RBF bumps:**
    Peter Todd suggests and analyzes an alternative approach, signing
    multiple versions of each commitment transaction at different
    feerates.  For example, he suggests signing 50 different versions of
    the LN-Penalty commitment transaction at feerates starting at 10
    sats/vbyte and increasing in each version by 10% until a transaction
    paying 1,000 sats/vbyte is signed.  For a commitment transaction
    with no pending payments (HTLCs), his analysis indicates the signing
    time would be about 5 milliseconds.  However, for each HTLC attached
    to the commitment transaction, the number of signatures would
    increase by 50 and the signing time would increase by 5
    milliseconds.  Bastien Teinturier linked to a [previous
    discussion][bolts #1036] he had started about a similar approach.

    Although the idea may work in some situations, Peter Todd's post
    noted that endogenous fees with presigned incremental fee bumps
    were not a satisfactory replacement for exogenous fees in all cases.
    When the delays required for presigning commitment transactions
    containing multiple HTLCs are multiplied by the several hops on a
    typical payment path, the [delay][harding delays] can easily
    become more than a second and, at least in theory, extend to
    delays of more than a minute.  Peter Todd notes that the delay
    could be reduced to roughly constant time if the proposed
    [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] opcode (APO) were
    available.

    Even if the delay was a constant 5 milliseconds, it's
    [possible][harding stuckless] that could lead to forwarding nodes
    using endogenous fees earning less forwarding fees than nodes
    using exogenous fees due to anticipated effects of LN payers
    eventually making [redundant overpayments][topic redundant
    overpayments] that will economically reward faster forwarding
    over slower forwarding, even when the difference is on the order
    of milliseconds.

    An additional challenge would be using the same endogenous fees for
    the presigned HTLC-Success and HTLC-Timeout transactions (HTLC-X
    transactions).  Even with APO, that would naively imply creating
    <i>n<sup>2</sup></i> signatures, although Peter Todd notes that
    the number of signatures could be reduced by assuming the HTLC-X
    transactions would pay a similar feerate to the commitment
    transaction.

    <p><!-- Using our tx-calc, 1-in, 22-out for 20 HTLC is 1014 vbytes;
         BOLT3 "expected weights" gives worst-case HTLC-X weight of 705
         = 176.25 vbytes, times 20 is 3525, plus 1014 is 4539. Multiply
         everything by 1,000 s/vb to get total sats --></p>

    There was an unresolved [debate][teinturier fees] about whether
    endogenous fees would result in an excessive amount of capital
    being reserved for fees.  For example, if Alice signs fee
    variants from 10 s/vb to 1,000 s/vb, she must make decisions based
    on the possibility that her counterparty Bob will put the 1,000
    s/vb variant onchain, even if she wouldn't pay that feerate
    herself.  That means she can't accept payments from Bob where he
    spends the money he would need for the 1,000 s/vb variant.  For
    example, a commitment transaction with 20 HTLCs would make 1
    million sats temporarily unspendable ($450 USD at the time of
    writing).  If endogenous fees were also used for the HTLC-X
    transactions, the temporarily unspendable amount for 20 HTLCs
    would be closer to 4.5 million sats ($2,050 USD).  By comparison,
    if Bob was expected to pay his fees exogenously, then Alice
    wouldn't need to reduce the capacity of the channel for her
    safety.

  - **Overall conclusions:** discussion was ongoing at the time of
    writing.  Peter Todd concluded that "existing usage of anchor
    outputs should be phased out due to the above-mentioned miner
    decentralization risks; new anchor output support should not be
    added to new protocols or Bitcoin Core."  LN developer Rusty Russell
    [posted][russell inline] about using a more efficient form of
    exogenous fees in new protocols to minimize the concern about
    out-of-band fees.  In the Delving Bitcoin thread, other developers
    working on LN, v3 transactions, and ephemeral anchors defended the
    usefulness of anchors and it seemed likely that they would continue
    working on v3-related protocols.  We will provide updates in future
    newsletters if anything significant changes.

- **LN-Symmetry research implementation** Gregory Sanders
  [posted][sanders lns] to Delving Bitcoin about a [proof-of-concept
  implementation][poc lns] he made of the [LN-Symmetry][topic eltoo]
  protocol (originally called _eltoo_) using a software fork of Core
  Lightning.  LN-Symmetry provides bi-directional payment channels that
  guarantee the ability to publish the latest channel state onchain
  without a need for penalty transactions.  However, they require
  allowing a child transaction to spend from any possible version of a
  parent transaction, which is only possible with a soft fork protocol
  change such as [SIGHASH_ANYPREVOUT][topic sighash_anyprevout].
  Sanders offers several highlights from his work:

  {% assign timestamp="35:03" %}

  - *Simplicity:* LN-Symmetry is a much simpler protocol than the
    currently used LN-Penalty/[LN-Anchors][topic anchor outputs]
    protocol.

  - *Pinning:* "[Pinning][topic transaction pinning] is super hard to
    avoid." Sander's work on this concern gave him insight and
    inspiration that has led to his contributions to [package
    relay][topic package relay] and his widely praised proposal for
    [ephemeral anchors][topic ephemeral anchors].

  - *CTV:* "[CTV][topic op_checktemplateverify] (through emulation)
    [...] allowed for 'fast forwards' that are extremely simple and
    would likely reduce payment times if widely adopted."

  - *Penalties:* Penalties truly did not seem necessary.  This was the
    hope for LN-Symmetry, but some people thought that a penalty
    protocol would still be necessary to deter malicious
    counterparties from attempting theft.  Support for penalties
    significantly increases protocol complexity and requires reserving
    some channel funds to pay the penalties, so it is preferable to
    avoid supporting them if they are not necessary for safety.

  - *Expiry deltas:* LN-Symmetry requires longer CLTV expiry deltas
    than expected.  When Alice forwards an HTLC to Bob, she gives him
    a certain number of blocks to claim its funds with a preimage;
    after that time expires, she can take back the funds.  When Bob
    further forwards the HTLC to Carol, he gives her a lower number of
    blocks during which she must reveal the preimage.  The delta
    between those two expires is the _CLTV expiry delta_.  Sanders
    found that the delta needed to be long enough to prevent the
    counterparty from benefiting if they aborted the protocol midway
    through a commitment round.

  Sanders is currently working on making improvements to Bitcoin Core's
  mempool and relay policy that will make it easier to deploy
  LN-Symmetry and other protocols in the future.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

[Nuke adjusted time (attempt 2)][review club 28956]
is a PR by Niklas Gögge that modifies a block validity
check related to the block's timestamp.
Roughly, if a block's timestamp (contained in its header)
is too far in the past or the future, the node rejects the
block as invalid. Note that if the block is invalid because
its timestamp is too far in the future, it can become valid
later (although the chain may have moved on).

  {% assign timestamp="50:01" %}

{% include functions/details-list.md
  q0="Is it necessary for block headers to have a timestamp? If so, why?"
  a0="Yes, the timestamp is used in difficulty adjustment and
      to validate transaction timelocks."
  a0link="https://bitcoincore.reviews/28956#l-39"

  q1="What is the difference between Median Time Past (MTP) and
      network-adjusted time? Which of these are relevant to the PR?"
  a1="MTP is the median time of the last 11 blocks, and is the lower
      bound of block timestamp validity. Network-adjusted
      time is calculated as our own node's time plus the median
      of the offsets between our time and that of a random selection
      of 199 of our outbound peers. (This median can be negative.)
      The network-adjusted time plus 2 hours is the maximum
      valid block timestamp.
      Only network-adjusted time is relevant to this PR."
  a1link="https://bitcoincore.reviews/28956#l-67"

  q2="Why are these times conceptually very different?"
  a2="MTP is uniquely defined for all nodes synced to
      the same chain; there is consensus on time.
      Network-adjusted time can vary across nodes."
  a2link="https://bitcoincore.reviews/28956#l-74"

  q3="Why don't we just use MTP for everything and scrap
      network-adjusted time?"
  a3="MTP is used as the lower bound of block timestamp
      validity, but it can't be used as an upper bound
      because future block timestamps are unknown."
  a3link="https://bitcoincore.reviews/28956#l-77"

  q4="Why are limits enforced on how far \"off\" a block
      header's timestamp is allowed to be from the node's internal clock?
      And since we don't require exact agreement on time, can these
      limits be made more strict?"
  a4="The block timestamp range is restricted so that malicious
      nodes' ability to manipulate difficulty adjustments and
      locktimes is limited. These kinds of attacks are called
      timewarp attacks.
      The valid range can be made more strict to an extent,
      but making it too strict could lead to temporary chain splits
      since some nodes may reject blocks that other nodes accept.
      Block timestamps don't need to be exactly correct, but
      they need to track actual time over the long run."
  a4link="https://bitcoincore.reviews/28956#l-82"

  q5="Before this PR, why would an attacker try to manipulate
      a node's network-adjusted time?"
  a5="If the node is a miner, to get its mined blocks rejected
      by the network or to get it to not accept a valid block so
      it keeps wasting hashrate on an old tip
      (both of those would give an advantage to a competing miner);
      to get the attacked node to follow the wrong chain;
      to cause a time-locked transaction to not be mined when
      it should be;
      to perform a [time dilation attack][] on the Lightning Network."
  a5link="https://bitcoincore.reviews/28956#l-89"

  q6="Prior to this PR, how could an attacker try to manipulate a
      node's network-adjusted time? Which network message(s) would
      they use?"
  a6="An attacker would need to send us version messages with
      manipulated timestamps from multiple peers that they control.
      They would need us to make more than 50% of our outbound
      connections to their nodes, which is hard but much easier
      than completely eclipsing the node."
  a6link="https://bitcoincore.reviews/28956#l-100"

  q7="This PR uses the node's local clock as the upper-bound
      block validation time, rather than network-adjusted time.
      Can we be sure that this reduces esoteric attack surfaces,
      rather than increasing them?"
  a7="Discussion ensued with no clear resolution as to whether it's
      easier for an attacker to affect a node's peer set or its
      internal clock (using malware or NTP fakery, for example),
      but most participants agreed that the PR is an improvement."
  a7link="https://bitcoincore.reviews/28956#l-102"

  q8="Does this PR change consensus behavior? If so, is this a
      soft fork, a hard fork, or neither? Why?"
  a8="Because consensus rules can't consider data from outside of the
      block chain (such as each node's own clock), this PR can't be
      considered a consensus change; it's just a network _acceptance_
      policy change. But that doesn't mean it's optional; having
      some policy rule limiting how far a block's timestamp can be
      in the future is [essential][se timestamp accecptance]
      to the security of the network."
  a8link="https://bitcoincore.reviews/28956#l-141"

  q9="Which operations were relying on network-adjusted time
      prior to this PR?"
  a9="[`TestBlockValidity`][TestBlockValidity function],
      [`CreateNewBlock`][CreateNewBlock function] (used by miners
      to build block templates), and
      [`CanDirectFetch`][CanDirectFetch function] (used in the P2P
      layer). The variety of these uses shows that the PR doesn't
      just affect block validity, but there are other implications,
      which we need to validate."
  a9link="https://bitcoincore.reviews/28956#l-197"
%}

## Notable code and documentation changes

*Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [LND #8308][] raises the `min_final_cltv_expiry_delta` from 9 to 18 as
  recommended by BOLT 02 for terminal payments. This value affects external
  invoices that don't supply the `min_final_cltv_expiry` parameter. The change
  remedies the interoperability issue discovered after CLN stopped
  including the parameter when the default of 18 was used, as
  [mentioned][cln hotfix] in last week's newsletter. {% assign timestamp="1:05:06" %}

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="1036,8308" %}
[poinsot v3]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340
[todd v3]: https://petertodd.org/2023/v3-transactions-review
[dlc cpfp]: https://github.com/discreetlogcontracts/dlcspecs/blob/master/Non-Interactive-Protocol.md
[news283 pinning]: /en/newsletters/2024/01/03/#v3-transaction-pinning-costs
[harding pinning]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340/22
[harding delays]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340/6
[harding stuckless]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340/5
[teinturier fees]: https://github.com/bitcoin/bitcoin/pull/28948#issuecomment-1873793179
[russell inline]: https://rusty.ozlabs.org/2024/01/08/txhash-tx-stacking.html
[sanders lns]: https://delvingbitcoin.org/t/ln-symmetry-project-recap/359
[poc lns]: https://github.com/instagibbs/lightning/tree/eltoo_support
[cln hotfix]: /en/newsletters/2024/01/03/#core-lightning-6957
[review club 28956]: https://bitcoincore.reviews/28956
[time dilation attack]: /en/newsletters/2020/06/10/#time-dilation-attacks-against-ln
[se timestamp accecptance]: https://bitcoin.stackexchange.com/a/121251/97099
[TestBlockValidity function]: https://github.com/bitcoin/bitcoin/blob/063a8b83875997068b3eb506b5f30f2691d18052/src/validation.cpp#L4228
[CreateNewBlock function]: https://github.com/bitcoin/bitcoin/blob/063a8b83875997068b3eb506b5f30f2691d18052/src/node/miner.cpp#L106
[CanDirectFetch function]: https://github.com/bitcoin/bitcoin/blob/063a8b83875997068b3eb506b5f30f2691d18052/src/net_processing.cpp#L1314
