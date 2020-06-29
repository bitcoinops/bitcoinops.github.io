---
title: 'Bitcoin Optech Newsletter #104'
permalink: /en/newsletters/2020/07/01/
name: 2020-07-01-newsletter
slug: 2020-07-01-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about mining incentives
related to HTLCs and links to an announcement about a proposed service to
store and relay presigned transactions.  Also included are our regular
sections with recently transcribed talks and conversations, new releases
and release candidates, and notable changes to popular Bitcoin
infrastructure projects.

## Action items

*None this week.*

## News

- **Discussion of HTLC mining incentives:** Itay Tsabary, Matan
  Yechieli, Ittay Eyal [posted][tye post] to the Bitcoin-Dev mailing
  list with a [paper][tye paper] they've written.  They claim that rational miners should
  want to run a modified Bitcoin node that allows a user to bribe it
  with a transaction that's timelocked and can't be confirmed until some
  point in the future.  As a result of this bribe, the miner won't
  confirm any transaction that could be mined immediately but which
  conflicts with the bribe (as long as the bribe pays a sufficiently
  higher feerate than any transactions it blocks).

    If this theory is accurate, it affects Hash TimeLock Contracts
    (HTLCs) which can be settled immediately by one party (Alice) using
    a preimage, or which can be settled later by a second party (Bob)
    after a timeout.  According to the authors, if Bob sees Alice use
    the preimage to spend the HTLC, Bob should send his conflicting
    timeout settlement transaction to miners with a sufficiently higher
    feerate than Alice's preimage settlement---even though miners can't
    immediately include Bob's transaction---bribing them to ignore
    Alice's transaction in favor of waiting to confirm his alternative
    transaction.  This allows Bob to steal the money Alice should
    receive.  HTLCs are currently used in LN, atomic swaps, and several
    other contract protocols.

    The authors of the paper propose a solution they call Mutually
    Assured Destruction HTLCs (MAD-HTLCs).  These require Bob to provide a
    hashlocked bond that makes him reveal his own preimage when sending
    his timeout settlement.  If both Alice and Bob reveal their
    respective preimages, miners will be able to claim both the
    payment/refund amount and the bond collateral---destroying the
    incentive for Bob to attempt to steal by bribing miners.

    The downsides to this approach are that it requires Bob to use more
    collateral---raising the cost of using HTLCs---and it uses more
    block chain space when MAD-HTLCs are settled onchain compared to
    traditional HTLCs---also raising costs.  It was also
    [claimed][harding mad miner] in the mailing list discussion that
    MAD-HTLCs might have their own problems with theft when the
    bonded user's counterparty is a miner (e.g. Alice is a miner).

    ZmnSCPxj [noted][zmnscpxj scorched earth] that a mechanism already
    exists to allow Alice to discourage Bob from attempting his
    theft: Alice can enact a [scorched earth][] policy where she spends
    all of her legitimate funds to fees in order to prevent Bob from
    receiving them.  In theory, this should prevent Bob from even trying
    the theft.  Another [paper][knw paper] by Majid Khabbazian, Tejaswi
    Nadahalli, and Roger Wattenhofer was [mentioned][nadahalli post] in
    the discussion, which showed (among other things) that nearly all
    miners would need to switch to the proposed bribe-accepting software
    before the attack would become particularly effective under normal
    conditions.

    In the short term, and probably the medium term, this attack does
    not appear to pose any significant danger to HTLCs whose receivers
    resolve their preimages well before their timelocks expire.  In the
    long term, this is an incentive compatibility concern that
    protocol developers may want to keep in mind.

- **Proposed service for storing, relaying, and broadcasting presigned transactions:**
  Jacob Swambo sent a [request for comments][swambo rfc] to the Bitcoin-Dev
  mailing list about creating software and a protocol for allowing
  applications to store presigned transactions with third-party services
  for later broadcast.  The software could also perhaps determine when to
  broadcast the transactions based on certain conditions being met.  This
  could be useful for software such as [vaults][topic vaults] and
  [watchtowers][topic watchtowers].  Swambo asks anyone interested in
  the idea, especially those interested in using it with their protocol, to
  contact him.

## Recently transcribed talks and conversations

*[Bitcoin Transcripts][] is the home for transcripts of technical
Bitcoin presentations and discussions. In this monthly feature, we
highlight a selection of the transcripts from the previous month.*

- **Magical Bitcoin:** Alekos Filini presented at LA BitDevs on [Magical
  Bitcoin][], a set of tools and libraries under development for onchain
  wallet developers. He explained that coin selection logic and
  transaction signing logic currently have to be rewritten multiple times
  across multiple projects---a problem Magical Bitcoin aims to address
  with modular, extensible, and peer-reviewed components.  A longer
  term ambition is to provide a platform for building native
  wallets and integrating them with existing projects.  Filini demoed
  the current functionality, which includes a playground with a Policy
  to [Miniscript][topic miniscript] compiler and some rudimentary
  visualizations. It is written in Rust and leverages the
  rust-miniscript library and the open source Esplora block explorer.
  ([transcript][mb ts], [video][mb vid])

- **Watchtowers and BOLT13:** Sergi Delgado appeared on [Potzblitz][] to
  discuss the latest state of [watchtower][topic watchtowers]
  development and a proposed watchtower protocol specification. He
  explored the various tradeoffs when designing a watchtower and the
  interplay between privacy requirements, accessibility, storage, and
  fees charged.  Delgado is working on the watchtower implementation
  [The Eye of Satoshi][teos] at Talaia Labs, which is aiming to be
  compliant with the proposed BOLT13 (see [Newsletter #75][news75
  watchtower bolt]).  Delgado also highlighted how watchtowers are
  becoming increasingly critical in multiple settings such as Bitcoin
  [vault][topic vaults] designs, statechains, and atomic swaps in addition to LN.
  ([transcript][watchtowers ts], [video][watchtowers vid],
  [slides][watchtowers slides])

- **Coinswap:** Aviv Milner presented on coinswap at the Wasabi Research
  Club. He explained the property of covertness and how Chris Belcher’s
  coinswap proposal (see [Newsletter #100][news100 coinswap]) provides
  covertness in a manner that other privacy schemes such as
  [coinjoin][topic coinjoin] fail to do. Milner also went through the
  motivation for routing coinswaps, namely to address the concern of
  unwittingly entering into a coinswap with an adversary such a chain
  surveillance company.  ([transcript][coinswap ts], [video][coinswap
  vid])

- **Schnorr signatures and multisignatures:** [BIP340][] co-authors Tim
  Ruffing, Pieter Wuille, and Jonas Nick held a discussion at London
  Bitcoin Devs on the specification of [schnorr signatures][topic
  schnorr signatures].  This covered earlier ideas for implementing
  schnorr signatures in Bitcoin and what the co-authors thought the
  community should be concerned about when considering a possible future
  soft fork deployment. Wuille noted that he is most concerned about how
  schnorr is adopted and what is built using it.  The following day, Tim
  Ruffing presented on the challenges of multisignature and threshold
  signature schemes using schnorr signatures (see also [Newsletter
  #68][news68 ruffing]).  He's been working with
  collaborators on a speculative [MuSig][topic musig] signature scheme
  that only requires two rounds of interaction rather than three,
  without relying on zero knowledge proofs, which would greatly simplify
  some threshold and multisignature signing workflows.  ([Meeting transcript][socratic ts],
  [meeting video][socratic vid], [presentation transcript][ruffing ts],
  [presentation video][ruffing vid], [presentation slides][ruffing
  slides])

- **Sydney meetup discussion:** A number of Bitcoin and LN developers
  joined this Sydney meetup to discuss various topics. Ruben Somsen gave
  a short presentation on Succinct Atomic Swaps (SAS) (see [Newsletter
  #98][news98 sas]) and how it compares to Chris Belcher’s coinswap
  proposal.  Another topic was Bitcoin Core's reliance on DNS seeds to
  find initial peers, whether it's a potential attack vector against newly
  started nodes, and how work by Matt Corallo and Antoine Riard on
  allowing [alternative transports][Bitcoin Core #18988] could help
  mitigate some risks.  Finally, Lloyd Fournier discussed how
  experimenting with his toy Rust implementation of secp256k1
  (secp256kfun) led to a small [fix][libsecp256k1 #732] in the ECDSA
  signature code in the actual secp256k1 library. The transcript was
  anonymized to encourage open discussion.  ([transcript][sydney ts])

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Hardware Wallet Interface (HWI) 1.1.2][hwi 1.1.2]: this release includes support
  for handling [PSBTs][topic psbt] with serialized previous segwit
  transactions, which is now required or suggested for several hardware
  wallets in response to the [fee overpayment attack][news101 fee
  overpayment].

- [LND 0.10.2-beta.rc4][lnd 0.10.2-beta]: this release candidate for an
  LND maintenance release is now available for testing.  It includes
  several bug fixes, including an important fix related to the creation
  of backups.

- [LND 0.10.3-beta.rc1][lnd 0.10.3-beta]: this release candidate,
  separate from the 0.10.2 RC, includes a package refactoring in
  addition to the bug fixes provided in 0.10.2.  For details, see a
  mailing list [post][osuntokun rcs] by LND developer Olaoluwa
  Osuntokun.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Hardware Wallet Interface][hwi], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #19305][] doc: add C++17 release note for 0.21.0 FIXME:dongcarl

- [Bitcoin Core #11413][] updates the `bumpfee`, `fundrawtransaction`,
  `sendmany`, `sendtoaddress`, and `walletcreatefundedpsbt` RPCs to
  allow manually specifying the feerate to use in the newly created or
  updated transaction.  By default, these commands still use either an
  automatic feerate computed by Bitcoin Core's built-in transaction fee
  estimate or the fallback feerate if there's not enough data for
  estimation.  For details on how to use the updated RPCs, see the
  [proposed release note][bcc11413rn].  Despite not affecting any major
  system, this PR was open for almost three years---the second longest
  of any PR that has been merged into Bitcoin Core so far.  We thank the
  author, Kalle Alm, and everyone else involved for their persistence.

- [Eclair #1466][] decreases the length of time that an Eclair node will wait
  before closing a channel when a peer becomes unresponsive while an HTLC is
  pending. To prevent payments from becoming stuck forever, each HTLC includes
  a timelock. If the timelock expires, then the sending party can reclaim
  the funds in the HTLC. To prevent the sending party from pulling back
  funds that an intermediate party has already paid to the next hop, the
  intermediate party must settle the pending HTLC onchain if the sending
  party becomes unresponsive. This PR increases Eclair's safety window---it
  will now broadcast the onchain transaction 24 blocks before the HTLC
  timeout, instead of 6 blocks before the timeout.

- [LND #4018][] adds the ability to delay forwarding a payment (HTLC),
  giving an external process the ability to review it and decide whether
  to cancel it or continue forwarding it.  This is similar to [hold
  invoices][topic hold invoices] but it applies to payments being routed
  to a node's peers rather than received by the node itself.  Several
  use cases are described in the PR---for example, one idea is to hold an
  HTLC, detect that its next hop is offline (e.g. a mobile node), send a
  notification to that node which will restart it, and then continue
  relaying the HTLC.

- [LND #4106][] adds a `getrecoveryinfo` RPC that returns information
  about the progress of restoring from a backup.

- [BIPs #933][] adds the [BIP339][] specification for transaction
  relay announcement using Witness Transaction Identifiers (wtxids).
  Currently, nodes announce new unconfirmed transactions to their peers
  using the transaction's txid, which is a hash over the legacy fields
  of the transaction.  The new fields used in segwit transactions are
  not included in the txid, which was necessary to eliminate third-party
  and counterparty transaction malleability.  However, during his June 2018 review
  of segwit, Peter Todd [noticed][todd relay malleability] that
  announcing transactions by their txid could allow nodes to modify the
  segwit fields before relaying a transaction.  This couldn't be used to
  steal money directly, but it did allow a relay node to mutate a valid
  transaction into an invalid or unacceptable transaction without
  changing its txid.

    Before Todd's discovery, this was a problem: Bitcoin Core would
    track the txids of invalid transactions it had recently seen and
    refuse to download them again.  That meant a malicious node could
    prevent any of its peers from downloading a valid segwit transaction
    from any of their other peers by sending them a mutated version of
    that transaction.  Arbitrary transaction censorship, even just at
    the relay level, is bad by itself---but it has especially severe
    consequences for time-sensitive protocols such as LN.

    At the time of Todd's analysis, segwit was nearing release, so a
    [quick fix][Bitcoin Core #8312] was implemented that prevents
    Bitcoin Core from caching the rejection status of segwit
    transactions that fail for the type of witness-related errors that
    malicious nodes can inject.  This eliminated the issue, but it means
    that Bitcoin Core uses more bandwidth than necessary when it
    encounters segwit transactions that are invalid because of
    accidental mistakes.  It may also complicate the development of new
    relay protocols such as [package relay][topic package relay].

    The long-term solution to the problem is that transactions should be
    announced using a hash that commits to the entire transaction---both
    the legacy fields and the new segwit fields.  That's exactly what
    wtxids do, and they're already needed in the protocol to construct
    the witness merkle root in each block's coinbase transaction.  This
    new BIP proposes updating the P2P protocol's `inv` message that
    announces new transactions, and the `getdata` message that requests
    a transaction, to allow them both to use wtxids.  That will allow
    nodes to skip re-downloading a transaction if it has the same wtxid
    as a transaction that was previously found to be invalid or
    unacceptable.

    The BIP339 proposal also adds the additional feature negotiation
    between newly started nodes described in [Newsletter #87][news87
    negotiation].  See also the [proposed implementation][Bitcoin Core
    #18044] for Bitcoin Core.

- [BIPs #923][] adds the [BIP78][] specification for the version of the
  [payjoin][topic payjoin] protocol originally implemented in BTCPay
  (see [Newsletter #94][news94 btcpayjoin]).  Payjoin allows a spender
  and a receiver to both add UTXOs to a transaction.  This decreases the
  reliability of the assumption made by third-party block chain
  surveillance companies that any set of UTXOs spent in the same
  transaction were all received by the same person.  BIP78 is based on
  the [BIP79][] specification of the Bustapay payjoin variant (see
  [Newsletter #13][news13 bustapay]) but contains several notable
  differences, including different extensions to [BIP21][] `bitcoin:`
  URIs, usage of PSBTs, and some additional requirements designed to
  enhance privacy.  Several programs already support this protocol and
  several more are currently working on adding support.  The PR for this
  BIP received significant discussion and may provide useful reference
  material for anyone interested in the subject.

- [BIPs #550][] revises the [BIP8][] alternative to [BIP9][]
  versionbits-based soft fork deployment.  BIP8 previously allowed a
  soft fork to be activated by miner signaling using the same parameters
  as would be used for BIP9, but it required that the soft fork activate
  at the end of the signaling period even if miners were still not
  signaling readiness to follow the new consensus rules.  This could be
  used to override miners who were obstructing activation of a fork, but
  it could also lead to diverging block chains between nodes that
  enforced the fork's new consensus rules and those that didn't.

    The main change to BIP8 from its previous version is that it
    may now be used initially without requiring mandatory
    lock-in.  Implementations may choose to commit to lock-in after their
    initial deployment of a BIP8-activated soft fork.  BIP8 mandates
    signaling for a period after the mandatory lock-in height, which will
    trigger even deployments without mandatory lock-in to begin
    enforcing the new rules at the same time as the mandatory lock-in
    nodes; in the best case, this allows the entire economy to
    synchronously begin enforcing the new rules.

{% include references.md %}
{% include linkers/issues.md issues="1466,19305,11413,4018,4106,933,923,550,8312,18044,18988,732" %}
[lnd 0.10.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.2-beta.rc4
[lnd 0.10.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.10.3-beta.rc1
[hwi 1.1.2]: https://github.com/bitcoin-core/HWI/releases/tag/1.1.2
[tye post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/017997.html
[tye paper]: https://arxiv.org/abs/2006.12031
[harding mad miner]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/018010.html
[zmnscpxj scorched earth]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/017998.html
[scorched earth]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2013-May/002632.html
[harding myopic]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/018009.html
[news101 fee overpayment]: /en/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[bcc11413rn]: https://github.com/kallewoof/bitcoin/blob/25dac9fa65243ca8db02df22f484039c08114401/doc/release-notes-11413.md
[todd relay malleability]: https://petertodd.org/2016/segwit-consensus-critical-code-review#peer-to-peer-networking
[news94 btcpayjoin]: /en/newsletters/2020/04/22/#btcpay-adds-support-for-sending-and-receiving-payjoined-payments
[news13 bustapay]: /en/newsletters/2018/09/18/#bustapay-discussion
[swambo rfc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/017996.html
[news87 negotiation]: /en/newsletters/2020/03/04/#improving-feature-negotiation-between-full-nodes-at-startup
[knw paper]: https://eprint.iacr.org/2020/774
[nadahalli post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-June/018015.html
[osuntokun rcs]: https://groups.google.com/a/lightning.engineering/forum/#!topic/lnd/jgd1ZC9T5n4
[mb ts]: https://diyhpl.us/wiki/transcripts/la-bitdevs/2020-05-21-alekos-filini-magical-bitcoin/
[mb vid]: https://www.youtube.com/watch?v=QVhC2DOIl7I)
[watchtowers ts]: https://diyhpl.us/wiki/transcripts/lightning-hack-day/2020-05-24-sergi-delgado-watchtowers/
[watchtowers vid]: https://www.youtube.com/watch?v=Vkq9CVxMclE
[watchtowers slides]: https://srgi.me/resources/slides/Potzblitz!2020-Watchtowers.pdf
[coinswap ts]: https://diyhpl.us/wiki/transcripts/wasabi-research-club/2020-06-15-coinswap/
[coinswap vid]: https://www.youtube.com/watch?v=Pqz7_Eqw9jM
[socratic ts]: https://diyhpl.us/wiki/transcripts/london-bitcoin-devs/2020-06-16-socratic-seminar-bip-schnorr/
[ruffing ts]: https://diyhpl.us/wiki/transcripts/london-bitcoin-devs/2020-06-17-tim-ruffing-schnorr-multisig/
[socratic vid]: https://www.youtube.com/watch?v=uE3lLsf38O4
[ruffing vid]: https://www.youtube.com/watch?v=8Op0Glp9Eoo
[ruffing slides]: https://slides.com/real-or-random/taproot-and-schnorr-multisig
[sydney ts]: https://diyhpl.us/wiki/transcripts/sydney-bitcoin-meetup/2020-06-23-socratic-seminar/
[magical bitcoin]: https://magicalbitcoin.org/
[news75 watchtower bolt]: /en/newsletters/2019/12/04/#proposed-watchtower-bolt
[news98 sas]: /en/newsletters/2020/05/20/#two-transaction-cross-chain-atomic-swap-or-same-chain-coinswap
[teos]: https://github.com/talaia-labs/python-teos
[news74 wagner]: /en/newsletters/2019/11/27/#schnorr-taproot-updates
[news100 coinswap]: /en/newsletters/2020/06/03/#design-for-a-coinswap-implementation
[potzblitz]: https://www.youtube.com/playlist?list=PLwgam6YBS0-jk1TlXD7QXDjTYJh-eJn_X
[news68 ruffing]: /en/newsletters/2019/10/16/#the-quest-for-practical-threshold-schnorr-signatures
