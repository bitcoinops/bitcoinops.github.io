---
title: 'Bitcoin Optech Newsletter #246'
permalink: /en/newsletters/2023/04/12/
name: 2023-04-12-newsletter
slug: 2023-04-12-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a discussion about LN splicing and
links to a proposed BIP for recommended transaction terminology.  Also
included are our regular sections with the summary of a Bitcoin Core PR
Review Club meeting, announcements of new releases and release
candidates---including a security update for libsecp256k1---and and
descriptions of notable changes made to popular Bitcoin infrastructure
software.

## News

- **Splicing specification discussions:** several LN developers posted
  to the Lightning-Dev mailing list this week about ongoing work on the
  [draft specification][bolts #863] for [splicing][topic splicing],
  which allows some funds in an offchain LN channel to be spent onchain
  (splice-out) or for onchain funds to be added to an offchain channel
  (splice-in).  The channel can continue to operate while an onchain
  splicing transaction is waiting for sufficient confirmations.

  {:.center}
  ![Splicing transaction flow](/img/posts/2023-04-splicing1.dot.png)

  Discussions this week included:

  - *Which commitment signatures to send:* when a splice is created, a
    node will hold parallel commitment transactions, one that spends
    from the original funding output and one that spends from each new
    funding output for all pending splices.  Each time the channel state
    is updated, all of the parallel commitment transactions need to be
    updated.  The simple way to handle this is by sending the same
    messages that would be sent for an individual commitment transaction
    but repeating them, one for each parallel commitment transaction.

    That's what was done in the original draft specifications for
    splicing (see Newsletters [#17][news17 splice] and [#146][news146
    splice]).  However, as Lisa Neigut [explained][neigut splice] this
    week, the creation of a new splice requires signing the new derived
    commitment transaction.  In the current draft specification, sending
    any signature requires sending signatures for all other current
    commitment transactions.  That's redundant: the signatures for those
    other commitment transactions were already sent.  Additionally, the
    way each party in the current LN protocol acknowledges they received
    a signature from their counterparty is by sending the revocation
    point for the previous commitment transaction.  Again, that
    information would already have been sent.  It's not harmful to
    re-send signatures and old revocation points, but it requires extra
    bandwidth and processing.  The advantage is that performing the same
    operation in all cases helps keep the specification simple, which
    may reduce implementation and testing complexity.

    The alternative is to special case only sending the minimum number
    of signatures for the new commitment transaction when a new splice
    is negotiated, plus an acknowledgment that they were received.  This
    is much more efficient, even if it adds some complexity.  It's worth
    noting that LN nodes only need to manage parallel commitment
    transactions until a splice transaction has confirmed to a
    sufficient depth for both counterparties to consider it secure.
    After that, they can return to operating on a single commitment
    transaction.

  - *Relative amounts and zero-conf splices:* Bastien Teinturier
    [posted][teinturier splice] about several proposed specification
    updates.  In addition to the aforementioned commitment signatures
    change, he also recommends that splice proposals use relative
    amounts, e.g. "200,000 sats" indicates Alice will splice in that
    amount and "-50,000 sats" indicates she wants to splice out that
    amount.  He also mentions a concern involving zero-conf splicing but
    does not go into detail about it.

- **Proposed BIP for transaction terminology:** Mark "Murch" Erhardt
  [posted][erhardt terms] the draft of an [informational BIP][terms bip]
  to the Bitcoin-Dev mailing list that suggests a vocabulary to use for
  referring to parts of transactions and concepts relating to them.  As
  of this writing, all replies to the proposal were supportive of the
  effort.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Don't download witnesses for assumed-valid blocks when running in prune mode][review club 27050]
is a PR by Niklas Gögge (dergoegge) that improves the performance of Initial Block Download
(IBD) by not downloading witness data on nodes that are configured to both
[prune block data][docs pruning] and use [assumevalid][docs assume valid]. This
optimization was discussed in a recent [stack exchange question][se117057].

{% include functions/details-list.md
  q0="If assume-valid is enabled but not pruning, why does the node need
     to download (non-recent) witness data, given that the
     node won't be checking this data? Should this PR also disable
     witness download in this non-pruning case?"
  a0="The witness data is needed because peers may request non-recent
      blocks from us (we advertise ourselves as non-pruned)."
  a0link="https://bitcoincore.reviews/27050#l-31"

  q1="How much bandwidth might be saved by this enhancement during an IBD?
      In other words, what is the cumulative size of all witness data up to
      a recent block (say, height 781213)?"
  a1="110.6 GB, which is about 25% of the total block data. One participant
      pointed out that 110 GB is about 10% of his monthly ISP download
      limit, so this is a significant reduction. Participants also expected
      the percentage savings to increase with the recently expanded use of
      witness data."
  a1link="https://bitcoincore.reviews/27050#l-52"

  q2="Would this improvement reduce the amount of download data from all
      blocks back to the genesis block?"
  a2="No, only since segwit activation (block height 481824); blocks before
      segwit do not have witness data."
  a2link="https://bitcoincore.reviews/27050#l-73"

  q3="This PR implements two main changes, one to the block request logic
      and one to block validation. What are these changes in more detail?"
  a3="In validation, when script checks will be skipped, also skip witness merkle tree checks.
      In the block request logic, remove `MSG_WITNESS_FLAG` from the fetch
      flags so our peers don't send us the witness data."
  a3link="https://bitcoincore.reviews/27050#l-83"

  q4="Without this PR, script validation is skipped under assume-valid,
      but other checks that involve witness data are not skipped.
      What are these checks that this PR will cause to be skipped?"
  a4="The coinbase merkle root, the witness sizes, the maximum
      witness stack items, and the block weight."
  a4link="https://bitcoincore.reviews/27050#l-91"

  q5="The PR does not include an explicit code change for skipping
      all the extra checks mentioned in the previous question.
      Why does that work out?"
  a5="It turns out that all the extra checks just pass when you don't
      have any witnesses.
      This makes sense considering that segwit was a soft fork.
      With the PR, we are essentially just pretending like we are a
      pre-segwit node (up to the assume-valid point)."
  a5link="https://bitcoincore.reviews/27050#l-117"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Libsecp256k1 0.3.1][] is a **security release** that fixes an issue
  related to code that should run in constant time but was not when
  compiled with Clang version 14 or higher.  The vulnerability may leave
  affected applications vulnerable to timing [side-channel
  attacks][topic side channels].  The authors strongly recommend
  updating affected applications.

- [BDK 1.0.0-alpha.0][] is a test release of the major changes to BDK
  described in [Newsletter #243][news243 bdk].  Developers of
  downstream projects are encouraged to begin integration testing.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Core Lightning #6012][] implements several significant improvements
  in the Python library for writing CLN plugins (see [Newsletter
  #26][news26 pyln-client]) that allow it to better work
  with CLN's gossip store.  The changes allow building better analysis tools
  for gossip and will make it easier to develop plugins that use gossip
  data.

- [Core Lightning #6124][] commando-listrunes & commando-blacklist FIXME:adamjonas

- [Eclair #2607][] adds a new `listreceivedpayments` RPC that lists all
  payments received by the node.

- [LND #7437][] adds support for backing up just a single channel to a
  file.

- [LND #7069][] allows a client to send a message to its
  [watchtower][topic watchtowers] asking for a session to be deleted.
  This allows the watchtower to stop monitoring for onchain transactions
  which close the channel in a revoked state.  This reduces the storage
  and CPU requirements for both the watchtower and the client.

- [BIPs #1372][] assigns [BIP327][] to the [MuSig2][topic musig]
  protocol for creating [multisignatures][topic multisignature] which
  can be used with [taproot][topic taproot] and other
  [BIP340][]-compatible [schnorr signature][topic schnorr signatures]
  systems.  As described in the BIP, the benefits include
  non-interactive key aggregation and a requirement for only two rounds
  of communication to complete the signing.  Non-interactive signing is also
  possible with additional setup between the participants.  The protocol
  is compatible with all of the advantages of any multisignature scheme,
  such as significantly reducing onchain data and enhancing privacy---both
  for participants and for users of the network in general.

{% include references.md %}
{% include linkers/issues.md v=2 issues="6012,6124,2607,7437,7069,1372,863" %}
[bdk 1.0.0-alpha.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-alpha.0
[news243 bdk]: /en/newsletters/2023/03/22/#bdk-793
[neigut splice]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-March/003894.html
[teinturier splice]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-March/003895.html
[erhardt terms]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021550.html
[terms bip]: https://github.com/Xekyo/bips/pull/1
[news26 pyln-client]: /en/newsletters/2018/12/18/#c-lightning-2161
[news17 splice]: /en/newsletters/2018/10/16/#proposal-for-lightning-network-payment-channel-splicing
[news146 splice]: /en/newsletters/2021/04/28/#draft-specification-for-ln-splicing
[libsecp256k1 0.3.1]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.3.1
[review club 27050]: https://bitcoincore.reviews/27050
[docs pruning]: https://github.com/bitcoin/bitcoin/blob/master/doc/release-notes/release-notes-0.11.0.md#block-file-pruning
[docs assume valid]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#assumed-valid-blocks
[se117057]: https://bitcoin.stackexchange.com/questions/117057/why-is-witness-data-downloaded-during-ibd-in-prune-mode
