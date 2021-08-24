---
title: 'Bitcoin Optech Newsletter #165'
permalink: /en/newsletters/2021/09/08/
name: 2021-09-08-newsletter
slug: 2021-09-08-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal for Bitcoin-related MIME
types and summarizes a paper about a design for a new decentralized
mining pool.  Also included are our regular sections with the summary of
a Bitcoin Core PR Review Club meeting, how to prepare for taproot, new
releases and release candidates, and notable changes to popular Bitcoin
infrastructure projects.

## News

- **Bitcoin-related MIME types:** Peter Gray [posted][gray mime] to the
  Bitcoin-Dev mailing list about registering MIME types with the
  [IANA][] for [PSBTs][topic psbt], raw transactions in binary format,
  and [BIP21][] URIs.  Andrew Chow [explained][chow mime] that he
  previously attempted to register a MIME type for PSBTs but his
  application was rejected.  He believed registering a MIME type would
  require writing an [IETF][] specification (an RFC), which might
  require a significant amount of work to shepard into becoming an
  established document.  Gray [suggested][gray bip] instead that a BIP
  be created for defining unofficial MIME types to be used by Bitcoin
  applications.

- **Braidpool, a P2Pool alternative:** [P2Pool][] is a system used for
  decentralized pool-based Bitcoin mining since 2011.  A new [paper][braidpool
  paper] that was [posted][pool2win post] to the Bitcoin-Dev mailing
  list describes several perceived flaws and an alternative
  decentralized pool design with two notable improvements: a more
  efficient use of block space for payouts by using payment channels
  with minimal trust in a third party, and more tolerance for higher
  latency connections between pool members.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Use legacy relaying to download blocks in blocks-only mode][review club #22340]
is a PR by Niklas Gögge to make nodes setting the `-blocksonly` configuration option always use legacy block relay
for downloading blocks. The review club compared legacy block download with
[BIP152][]-style [compact block][topic compact block relay] download and discussed why blocksonly nodes don't benefit from
the latter.

{% include functions/details-list.md

  q0="What sequence of messages is used in legacy block relaying?"
  a0="Nodes running v0.10 and newer use [headers-first synchronization][headers
first pr]: a node first receives a `headers` message from its peer containing
the block header. After validating the header, it then requests the full
block by sending a `getdata(MSG_BLOCK, blockhash)` message to the peer that
announced it, and the peer responds with a `block` message containing the full
block."
  a0link="https://bitcoincore.reviews/22340#l-49"

  q1="What sequence of messages is used in BIP152 low bandwidth compact block relaying?"
  a1="Peers indicate that they want to use compact block relay by sending
`sendcmpct` at the start of the connection. Low bandwidth compact block relay is
very similar to legacy block relay: after processing a block header, the node
requests a compact block from its peer using `getdata(MSG_CMPCT_BLOCK,
blockhash)`, and receives a `cmpctblock` in response. The node can use the
compact block shortids to look for the block transactions in its mempool and
cache of extra transactions. If any transactions are still unknown, it can
request them from a peer using `getblocktxn` and receive `blocktxn` messages in
response."
  a1link="https://bitcoincore.reviews/22340#l-56"

  q2="What sequence of messages is used in BIP152 high bandwidth compact block relaying?"
  a2="A node can request high bandwidth compact blocks from a peer when first
establishing the connection by sending `sendcmpct` with `hb_mode` set to 1 at
the start of the connection. This means the peer can send a `cmpctblock`
immediately, without sending headers first or waiting for a `getdata` request
for the block. If needed, the node can request and download any unknown block
transactions using `getblocktxn` and `blocktxn`, identically to low bandwidth
compact block relay."
  a2link="https://bitcoincore.reviews/22340#l-59"

  q3="Why does compact block relay waste bandwidth for blocksonly nodes during
block download? How much bandwidth is wasted?"
  a3="Compact block relay reduces bandwidth usage for nodes that have a mempool
because they don't need to re-download the majority of block transactions.
However, nodes in blocksonly mode don't participate in transaction relay and
typically have empty mempools, which means they need to download all of the
transactions anyway. The shortids, `getblocktxn` and `blocktxn` overhead [add up
to approximately 38kB per block][aj calculations] of wasted bandwidth, and the
extra round trip for `getblocktxn` and `blocktxn` messages also increases the
time it takes to download the block."
  a3link="https://bitcoincore.reviews/22340#l-82"

  q4="Does a node in blocksonly mode keep a mempool?"
  a4="While blocksonly nodes don't participate in transaction relay, they still
have a mempool and it may contain transactions for a few different reasons. For
example, if the node was in normal mode, then restarted in blocksonly mode, the
mempool is persisted across the restart. Also, any transactions submitted
through the wallet and client interfaces are validated and relayed using the
mempool."
  a4link="https://bitcoincore.reviews/22340#l-97"

  q5="What is the difference between blocksonly and block-relay-only? Should
these changes be applied for block-relay-only connections as well?"
  a5="Blocksonly mode is a node setting, while block-relay-only is an attribute
of a peer connection. When a node is started in blocksonly mode, the node sends
`fRelay=false` in the version handshake with all peers and disconnects peers that
send any transaction-related messages. Whether or not in blocksonly mode, a node
may have block-relay-only connections on which they ignore incoming transaction
and addr messages. As such, the existence of block-relay-only connections has no
relation to a node's mempool contents and ability to reconstruct blocks from
compact block messages, so these changes shouldn't be applied to
block-relay-only connections."
  a5link="https://bitcoincore.reviews/22340#l-111"
%}

## Preparing for taproot #12: Vaults with taproot

*A weekly [series][series preparing for taproot] about how developers
and service providers can prepare for the upcoming activation of taproot
at block height {{site.trb}}.*

{% include specials/taproot/en/11-vaults-with-taproot.md %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 22.0rc3][bitcoin core 22.0] is a release candidate
  for the next major version of this full node implementation and its
  associated wallet and other software. Major changes in this new
  version include support for [I2P][topic anonymity networks] connections,
  removal of support for [version 2 Tor][topic anonymity networks] connections,
  and enhanced support for hardware wallets.

- [Bitcoin Core 0.21.2rc2][bitcoin core 0.21.2] is a release candidate
  for a maintenance version of Bitcoin Core.  It contains several bug
  fixes and small improvements.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #22009][] updates the wallet to always run both the Branch
  and Bound (BnB) and knapsack algorithms for [coin selection][topic coin
  selection], and then choose the best result using a new *waste score* heuristic
  to compare the cost effectiveness of the results. Previously, the changeless
  BnB result was always preferred if one was found.

    The waste score heuristic assumes that every input must eventually be spent
    at a feerate of 10 sat/vB, and that change outputs are avoidable. Inputs are
    scored as the difference between their cost at the current feerate and the
    baseline feerate, resulting in a waste score deduction for spending inputs at
    lower feerates and a waste score increase at higher feerates. Change outputs
    always increase the waste score by the cost of the change output creation as
    well as the future cost of spending the change output.

    In a wallet spending at various feerates, this approach will shift some
    input consumption to lower feerates, reducing the overall wallet operation
    cost. The baseline feerate separating consolidatory and thrifty coin selection
    behavior can be configured with the new option `-consolidatefeerate`. The
    subsequent PR [Bitcoin Core #17526][] proposes to add a third coin selection
    algorithm based on a Single Random Draw.

- [Eclair #1907][] updates how it uses block chain watchdogs to prevent
  [eclipse attacks][topic eclipse attacks] (see [Newsletter
  #123][news123 eclair watchdogs]).  When Tor is available, Eclair now
  uses it to contact the watchdogs (using native onion endpoints when
  possible).  This should make it more difficult for an upstream
  attacker to selectively censor just the watchdog providers.

- [Eclair #1910][] updates how it uses Bitcoin Core's ZMQ messaging
  interface to improve the reliability of learning about new blocks.
  Anyone else using ZMQ for block discovery may wish to investigate the
  changes.

- [BIPs #1143][] introduces BIPs 380-386 specifying
  [output script descriptors][topic descriptors]. Output script descriptors are a simple
  language that contains all the information necessary to allow a wallet or
  other program to track payments made to or spent from a particular script
  or set of related scripts. [BIP380][] describes the philosophy, general
  structure, shared expressions, and checksum. The rest of the BIPs specify
  each descriptor function itself, categorized by: non-segwit ([BIP381][]),
  segwit ([BIP382][]), multisig ([BIP383][]), combination output ([BIP384][]),
  raw script and address ([BIP385][]), and tree ([BIP386][]) descriptors.

- [BOLTs #847][] allows two channel peers to negotiate what fee should
  be paid in a mutual close transaction. Previously, only a single fee
  was sent, and the other party had to either accept or reject that
  precise fee.  *[Edit: see next week's newsletter for a [more
  accurate][news166 fee negotiation] description.]*

- [BOLTs #880][] adds a `channel_type` field to the `openchannel` and
  `acceptchannel` messages, allowing the sending node to explicitly request
  channel features different from ones implied by the nodes' advertised feature
  bits. This backwards compatible change has been implemented in [Eclair
  #1867][], [LND #5669][], and is pending merge as part of [C-Lightning
  #4616][].

- [BOLTs #824][] adds a slight variation on the [anchor outputs][topic
  anchor outputs] channel state commitment protocol.  In the earlier
  protocol, presigned spends of [HTLCs][topic htlc] could include fees,
  but this opened the fee-stealing attack vector described in
  [Newsletter #115][news115 anchor fees].  In this alternative protocol,
  all presigned HTLC spends use zero fee, so no fees can be stolen.

## Footnotes

{% include references.md %}
{% include linkers/issues.md issues="22009,1907,1910,1143,847,880,824,1867,5669,4616,22340,17526" %}
[bitcoin core 22.0]: https://bitcoincore.org/bin/bitcoin-core-22.0/
[bitcoin core 0.21.2]: https://bitcoincore.org/bin/bitcoin-core-0.21.2/
[news115 anchor fees]: /en/newsletters/2020/09/16/#stealing-onchain-fees-from-ln-htlcs
[news123 eclair watchdogs]: /en/newsletters/2020/11/11/#eclair-1545
[p2pool]: https://bitcointalk.org/index.php?topic=18313.0
[gray mime]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019385.html
[iana]: https://en.wikipedia.org/wiki/Internet_Assigned_Numbers_Authority
[chow mime]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019386.html
[ietf]: https://en.wikipedia.org/wiki/Internet_Engineering_Task_Force
[gray bip]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-September/019390.html
[braidpool paper]: https://github.com/pool2win/braidpool/raw/main/proposal/proposal.pdf
[pool2win post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019371.html
[aj calculations]: https://github.com/bitcoin/bitcoin/pull/22340#issuecomment-872723147
[headers first pr]: https://github.com/bitcoin/bitcoin/pull/4468
[news166 fee negotiation]: /en/newsletters/2021/09/15/#c-lightning-4599
