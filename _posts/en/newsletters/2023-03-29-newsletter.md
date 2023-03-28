---
title: 'Bitcoin Optech Newsletter #244'
permalink: /en/newsletters/2023/03/29/
name: 2023-03-29-newsletter
slug: 2023-03-29-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal to improve capital
efficiency on LN using tunable penalties.  Also included are our regular
sections with summaries of top questions and answers from the Bitcoin
Stack Exchange, announcements of new releases and release candidates,
and descriptions of notable changes to popular Bitcoin infrastructure
software.

{% assign S0 = "_S<sub>0</sub>_" %}
{% assign S1 = "_S<sub>1</sub>_" %}

## News

- **Preventing stranded capital with multiparty channels and channel factories:**
  John Law [posted][law stranded post] to the Lightning-Dev mailing list
  the summary of a [paper][law stranded paper] he's written.  He
  describes how always-available nodes can continue using their funds to
  forward payments even when they share a channel with a node that's
  currently unavailable (such as the user of a mobile LN wallet).  This
  requires the use of multiparty channels, which compose well with a
  channel factory design he's previously described.  He also restates a
  known benefit of [channel factories][topic channel factories] of
  allowing channels to be rebalanced offchain, which may also allow
  better use of capital.  He describes how to use both benefits in the
  context of his previous innovation of the _tunable penalty_ layer for
  LN.  We'll summarize tunable penalties, show how they can be used for
  multiparty channels and channel factories, and then explain Law's new
  results in context.

    Alice and Bob create (but do not immediately sign) a transaction
    which spends 50M sats from each of them (100M total) to a _funding
    output_ which will require cooperation from both of them to spend.
    In the diagrams below, we show confirmed transactions as shaded.

    {:.center}
    ![Alice and Bob create the funding transaction](/img/posts/2023-03-tunable-funding.dot.png)

    They each also use a different output they individually control to
    create (but not broadcast) two _state transactions_, one for each of
    them.  The first output of each state transaction pays a trivial amount
    (say 1,000 sat) as an input to a timelocked offchain _commitment transaction_.  The relative timelock
    prevents each commitment transaction from being eligible for
    confirmation onchain until a certain amount of time after its parent
    state transaction is confirmed onchain.  Each of the two commitment
    transactions is also funded by conflicting spends of the funding output
    (meaning that only one of the commitment transactions can eventually be
    confirmed).  With all the child transactions created, the transaction
    which creates the funding output can be signed and broadcast.

    {:.center}
    ![Alice and Bob create their commitment transactions](/img/posts/2023-03-tunable-commitment.dot.png)

    Each of the commitment transactions pays to the current state of the
    channel.  For the initial state ({{S0}}), 50M sats is refunded
    to each Alice and Bob (for simplicity we ignore transaction fees).
    Alice or Bob can start the process of unilaterally closing the
    channel by publishing their version of the state transaction; after
    the enforced delay, they can then publish the corresponding
    commitment transaction.  For example, Alice publishes her state
    transaction and her commitment transaction (which pays both her and
    Bob); at that point, Bob can simply never spend his state
    transaction and instead spend the money used to create it at any
    later time however he would like.

    {:.center}
    ![Alice spends honestly from the channel](/img/posts/2023-03-tunable-honest-spend.dot.png)

    There are two other alternatives to unilaterally closing the channel in
    its initial state.  First, Alice and Bob can cooperatively close the
    channel at any time by spending the funding transaction output (the same
    as is done in the current LN protocol).  Second, they could update the
    state---for example, increasing Alice's balance by 10M sat and decreasing
    Bob's balance by the same amount.  State {{S1}} looks similar
    to the initial state ({{S0}}), but to enact it, the previous
    state is revoked by each party giving the other a witness[^keychain] for
    spending the first output from their respective state transactions for
    the previous state ({{S0}}).  Neither party can use the other's witness
    because the {{S0}} state transactions don't themselves contain witnesses yet
    so they can't be broadcast.

    With multiple states available, it's possible to accidentally or
    deliberately close the channel in an outdated state.  For example, Bob may
    try to close the channel in state {{S0}} where he had an additional 10M
    satoshis.  To do this, Bob signs and broadcasts his state transaction
    for {{S0}}.  Bob can't take any further action immediately because of
    the timelock on the commitment transaction.  During the wait, Alice
    detects this attempt to broadcast an outdated state and uses the witness
    he previously gave her to spend the first output of his state
    transaction, paying some or all of the penalty amount to transaction
    fees.  Since that output is the same output Bob needs to later
    broadcast the commitment transaction that pays him the extra 10M
    sat, he will be blocked from claiming those funds if the transaction
    Alice creates is confirmed.  With Bob blocked, Alice is the only one
    who can unilaterally publish the latest state onchain;
    alternatively, Alice and Bob can still perform a cooperative channel
    close at any time.

    {:.center}
    ![Bob attempts to spend dishonestly from the channel but is blocked by Alice](/img/posts/2023-03-tunable-dishonest-spend.dot.png)

    If Bob notices Alice attempting to spend from his outdated state
    transaction, he could attempt to enter in a Replace By Fee (RBF) bidding
    war with Alice, but that's a case where the penalty amount being
    _tunable_ is especially powerful: the penalty amount could be trivial
    (e.g. 1K sats, as in our example) or it could equal the amount at stake
    (10M sats) or it could even be larger than the entire value of the
    channel.  The decision is entirely up to Alice and Bob to negotiate
    with each other when updating the channel's state.

    One of the other advantages of the Tunable-Penalty Protocol (TPP) is
    that the penalty amount is paid entirely by the user who puts their outdated
    state transaction onchain.  It doesn't use any of the bitcoins from the
    shared funding transaction.  This allows more than two users to safely
    share a TPP channel; for example, we can imagine Alice, Bob, Carol, and
    Dan all sharing a channel.  Each of them has their own commitment
    transaction funded from their own state transaction:

    {:.center}
    ![A channel between Alice, Bob, Carol, and Dan](/img/posts/2023-03-tunable-multiparty.dot.png)

    They can operate this as a multiparty channel, requiring each state be
    revoked by every party.  Alternatively, they can use the joint funding
    transaction as a channel factory, creating multiple channels between
    pairs or multiples of users.  Prior to Law's description of this
    implication of the TPP last year (see [Newsletter #230][news230 tp]), it
    was believed practical implementation of channel factories on Bitcoin
    would require a mechanism like [eltoo][topic eltoo], which requires a
    consensus change like [SIGHASH_ANYPREVOUT][topic
    sighash_anyprevout].  TPP doesn't require consensus changes.  To
    keep the diagram below simple, we've only illustrated a single
    channel created in a factory of four participants; the number of
    states the channel participants need to manage equals the number of
    participants in the factory, although Law also [previously
    described][law factories] an alternative construction with a single
    state but a higher cost to close unilaterally.

    {:.center}
    ![A channel between Alice and Bob created from a factory by Alice, Bob, Carol, and Dan](/img/posts/2023-03-tunable-factory.dot.png)

    An advantage of channel factories described in its [original
    paper][channel factories paper] is that the parties within the factory
    can cooperatively rebalance their channels without creating any onchain
    transactions.  For example, if the factory consists of Alice, Bob,
    Carol, and Dan, the total value of the channel between Alice and Bob can
    be decreased and the value of the channel between Carol and Dan can be
    increased by the same amount by updating the offchain factory state.
    Law's TPP-based factories provide the same benefit.

    This week Law noted that factories with the ability to provide
    multiparty channels (which is possible with TPP) have an additional
    advantage: allowing capital to be used even when one channel participant
    is offline.  For example, imagine if Alice and Bob have dedicated LN
    nodes that are almost always available to forward payments but Carol
    and Dan are casual users whose nodes are often unavailable.  In an
    original-style channel factory, Alice has a channel with Carol ({A,C}) and a
    channel with Dan ({A,D}).  She can't use any of her funds in those
    channels when Carol and Dan are unavailable.  Bob has the same problem
    ({B,C} and {B,D}).

    In a TPP-based factory, Alice, Bob, and Carol can open a multiparty
    channel together, requiring all three of them to cooperate to update its
    state.  One of the outputs of a commitment transaction in that channel
    pays Carol but the other output can only be spent if Alice and Bob
    cooperate.  When Carol is unavailable, Alice and Bob can cooperatively
    change the balance distribution of their joint output offchain, allowing
    them to make or forward LN payments if they have other LN channels.  If
    Alice remains unavailable too long, either one of them can unilaterally
    put the channel onchain.  The same benefits apply if Alice and Bob share
    a channel with Dan.

    This allows Alice and Bob to continue earning forwarding fees even when
    Carol and Dan are unavailable, preventing those channels from seeming
    unproductive.  The ability to rebalance channels offchain (with no
    onchain fees) may also decrease the downsides for Alice and Bob of
    keeping their funds in a channel factory for a longer time.  Together
    these benefits may reduce the number of onchain transactions,
    increase the total payment capacity of the Bitcoin network, and
    lower the cost to forward payments over LN.

    As of this writing, tunable penalties and Law's various proposals for
    using them have not received much public discussion.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Why isn't the taproot deployment buried in Bitcoin Core?]({{bse}}117569)
  Andrew Chow explains the rationale for the taproot soft fork
  [deployment][topic soft fork activation] not being [buried][BIP90] as [others
  have][bitcoin buried deployments].

- [What restrictions does the version field in the block header have?]({{bse}}117530)
  Murch notes an increase in [blocks][explorer block 779960] mined using [overt
  ASICBoost][topic ASICBoost], lists restrictions on the version field, and
  walks through examples of [block header version fields][FCAT block header blog].

- [What is the relation between transaction data and ids?]({{bse}}117453)
  Pieter Wuille explains the legacy transaction serialization format covered by
  `txid` identifier, the witness extended serialization format covered by the `hash` and
  `wtxid` identifiers, and points out in a [separate answer][se117577] that
  hypothetical additional transaction data would be covered by the `hash` identifier.

- [Can I request tx messages from other peers?]({{bse}}117546)
  User RedGrittyBrick points to resources explaining the [performance][wiki getdata] and
  [privacy][Bitcoin Core #18861] reasons that arbitrary requests for
  transactions from peers is not supported by Bitcoin Core's P2P layer.

- [Eltoo: Does the relative locktime on the first UTXO set the lifetime of the channel?]({{bse}}117468)
  Murch confirms that the question's example [eltoo][topic eltoo]-constructed LN channel
  has a limited lifetime but points to mitigations from the [eltoo
  whitepaper][] that keep the timeouts from expiring.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Rust Bitcoin 0.30.0][] is the latest release of this library for
  using data structures related to Bitcoin.  The [release notes][rb rn]
  mention a [new website][rust-bitcoin.org] and a large number of API
  changes.

- [LND v0.16.0-beta.rc5][] is a release candidate for a new major
  version of this popular LN implementation.

- [BDK 1.0.0-alpha.0][] is a test release of the major changes to BDK
  described in [last week's newsletter][news243 bdk].  Developers of
  downstream projects are encouraged to begin integration testing.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27278][] begins logging by default when a header for a
  new block is received, unless the node is in Initial Block Download
  (IBD).  This was [inspired][obeirne selfish] by multiple node
  operators noticing that three blocks arrived very close to each other,
  the later two which reorged the first block out of the best block
  chain.  For clarity, let's call the first block _A_, the block that
  replaced it _A'_, and the final block _B_.

  That could indicate that blocks A' and B were created by the same
  miner who deliberately delayed broadcasting them until they would
  cause another miner's block to become stale, denying that miner the
  block reward it would have ordinarily received from A---an attack
  known as _selfish mining_.  The occurrence could also be a coincidence
  or accidental selfish mining.  However, one possibility
  [raised][sanders requests] by developers during the investigation was
  that the timings may not have actually been as close as they
  seemed---it's possible that Bitcoin Core didn't request A' until B was
  received since A' by itself wasn't enough to trigger a reorg.

  Logging the time when headers are received means that, if the
  situation were to repeat in the future, node operators would be able
  to determine when their node first learned about the existence of A'
  even if it didn't choose to download it immediately.  This logging may
  add up to two new lines per block (although future PRs may reduce it
  to just one line), which was considered to be a small enough
  additional overhead to help detect selfish mining attacks and other
  problems associated with critical block relay.

- [Bitcoin Core #26531][] adds tracepoints for monitoring events
  affecting the mempool using the Extended Berkeley Packet Filter (eBPF)
  as implemented in previous PRs (see [Newsletter #133][news133 usdt]).
  A script is also added for using the tracepoints for monitoring
  mempool statistics and activity in real time.

- [Core Lightning #5898][] updates its dependency on [libwally][] to a
  more recent version (see [Newsletter #238][news238 libwally]), which allows adding support for [taproot][topic
  taproot], version 2 [PSBT][topic psbt] (see [Newsletter #128][news128
  psbt2]), and affects support for LN on Elements-style sidechains.

- [Core Lightning #5986][] updates RPCs which return values in msats to
  no longer include the string "msat" as part of the result.  Instead,
  all returned values are integers.  This completes a deprecation begun
  several releases ago, see [Newsletter #206][news206 msat].

- [Eclair #2616][] adds support for opportunistic [zero-conf
  channels][topic zero-conf channels]---if the remote peer sends the
  `channel_ready` message before the expected number of confirmations,
  Eclair will verify that the funding transaction was entirely created
  by the local node (so the remote peer can't get a conflicting
  transaction confirmed) and then will allow the channel to be used.

- [LDK #2024][] begins including route hints for channels which have
  been opened but which are too immature to have been publicly announced
  yet, such as [zero-conf channels][topic zero-conf channels].

- [Rust Bitcoin #1737][] adds a [security reporting policy][rb sec] for the
  project.

- [BTCPay Server #4608][] allows plugins to expose their features as an
  app in the BTCPay user interface.

- [BIPs #1425][] assigns [BIP93][] to the codex32 scheme for encoding
  [BIP32][] recovery seeds using Shamir's Secret Sharing Scheme (SSSS)
  algorithm, a checksum, and a 32-character alphabet as described in
  [Newsletter #239][news239 codex32].

- [Bitcoin Inquisition #22][] adds an `-annexcarrier` runtime option which
  allows pushing from 0 to 126 bytes of data a taproot input's annex
  field.  The author of the PR is planning to use the feature to allow
  people to begin experimenting on signet with [eltoo][topic eltoo]
  using a fork of Core Lightning.

## Footnotes

[^keychain]:
    It isn't important to this high-level overview to describe what the
    witness is, but some of the proposed benefits do depend on the
    details.  The original [Tunable Penalties][] protocol description
    suggests releasing the private key used to generate the signature
    for spending from the commitment transaction.  It's possible to
    generate private keys in a sequence where anyone who knows one key
    can also derive any later key (but not any earlier key).  This means
    each time Alice revokes a later state, she can give Bob an earlier
    key which Bob can use to derive any later key (for an earlier
    state).  E.g.,

      | Channel state | Key state |
      | 0     | MAX |
      | 1     | MAX - 1 |
      | 2     | MAX - 2 |
      | x     | MAX - x |
      | MAX   | 0 |

    This allows Bob to store all the information he needs to spend from
    an outdated state transaction in a very small constant amount of
    space (less than 100 bytes by our calculations<!-- commitment tx's
    vin outpoint @<=34 bytes, priv key @32 bytes, reference index @<=4
    bytes -->).  The information can also easily be shared with a
    [watchtower][topic watchtowers] (which does not need to be trusted,
    as any successful spending from an outdated state transaction will
    prevent an outdated commitment transaction from being published
    onchain.  Since the funds involved in that outdated state
    transaction belong entirely to the party who is in breach of the
    protocol, there's no security risk to outsourcing the information
    about spending from it).

{% include references.md %}
{% include linkers/issues.md v=2 issues="27278,26531,5898,5986,2616,2024,1737,4608,1425,22,18861" %}
[lnd v0.16.0-beta.rc5]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc5
[bdk 1.0.0-alpha.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-alpha.0
[rust bitcoin 0.30.0]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/bitcoin-0.30.0
[news230 tp]: /en/newsletters/2022/12/14/#factory-optimized-ln-protocol-proposal
[channel factories paper]: https://tik-old.ee.ethz.ch/file//a20a865ce40d40c8f942cf206a7cba96/Scalable_Funding_Of_Blockchain_Micropayment_Networks%20(1).pdf
[law factories]: https://raw.githubusercontent.com/JohnLaw2/ln-efficient-factories/main/efficientfactories10.pdf
[news206 msat]: /en/newsletters/2022/06/29/#core-lightning-5306
[rb sec]: https://github.com/rust-bitcoin/rust-bitcoin/blob/master/SECURITY.md
[news239 codex32]: /en/newsletters/2023/02/22/#proposed-bip-for-codex32-seed-encoding-scheme
[law stranded post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-March/003886.html
[law stranded paper]: https://github.com/JohnLaw2/ln-hierarchical-channels
[obeirne selfish]: https://twitter.com/jamesob/status/1637198454899220485
[sanders requests]: https://twitter.com/theinstagibbs/status/1637235436849442817
[news133 usdt]: /en/newsletters/2021/01/27/#bitcoin-core-19866
[libwally]: https://github.com/ElementsProject/libwally-core
[news128 psbt2]: /en/newsletters/2020/12/16/#new-psbt-version-proposed
[tunable penalties]: https://github.com/JohnLaw2/ln-tunable-penalties
[news238 libwally]: /en/newsletters/2023/02/15/#libwally-0-8-8-released
[rust-bitcoin.org]: https://rust-bitcoin.org/
[rb rn]: https://github.com/harding/rust-bitcoin/blob/bbda9599fa32936f31472620d014893fda17d8c3/bitcoin/CHANGELOG.md#030---2023-03-21-the-first-crate-smashing-release
[news243 bdk]: /en/newsletters/2023/03/22/#bdk-793
[bitcoin buried deployments]: https://github.com/bitcoin/bitcoin/blob/master/src/consensus/params.h#L19
[explorer block 779960]: https://blockstream.info/block/00000000000000000003a337a676b0101f3f7ef7dcbc01debb69f85c6da04dcf?expand
[FCAT block header blog]: https://medium.com/fcats-blockchain-incubator/understanding-the-bitcoin-blockchain-header-a2b0db06b515#b9ba
[se117577]: https://bitcoin.stackexchange.com/a/117577/87121
[wiki getdata]: https://en.bitcoin.it/wiki/Protocol_documentation#getdata
[eltoo whitepaper]: https://blockstream.com/eltoo.pdf#page=15
