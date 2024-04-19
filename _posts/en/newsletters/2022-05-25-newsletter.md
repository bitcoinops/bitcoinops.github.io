---
title: 'Bitcoin Optech Newsletter #201'
permalink: /en/newsletters/2022/05/25/
name: 2022-05-25-newsletter
slug: 2022-05-25-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a draft BIP for package relay and
provides an overview of a concern with Miner Extractable Value (MEV) for
Bitcoin covenant design.  Also included are our regular sections with
the summary of top questions and answers from the Bitcoin Stack
Exchange, announcements of new releases and release candidates, and
descriptions of notable changes to popular Bitcoin infrastructure
software.

## News

- **Package relay proposal:** Gloria Zhao [posted][zhao package] to the
  Bitcoin-Dev mailing list a draft BIP for [package relay][topic package
  relay].  This is a feature that can make [CPFP fee bumping][topic
  cpfp] much more reliable at ensuring a child transaction can
  contribute fees towards getting its parent confirmed.  Several
  contract protocols, including LN, already require reliable CPFP fee
  bumping, so package relay would improve their security and usability.
  The draft BIP proposes to add four new messages to
  the Bitcoin P2P protocol:

  - `sendpackages` allows two peers to negotiate the package acceptance
    features they support.

  - `getpckgtxns` requests transactions that were previously announced as
    part of a package.

  - `pckgtxns` provides transactions that are part of a package.

  - `pckginfo1` provides information about a package of transactions
    including the number of transactions, each transaction's identifier
    (wtxid), the total size (weight) of the transactions, and
    the total fees of the transaction.  The feerate of the package can be
    calculated by dividing fees by weight.

  Additionally the existing `inv` and `getdata` messages are updated
  with a new inventory (inv) type, `MSG_PCKG1`, which allows a node to
  tell its peers that it is willing to send a `pckginfo1` message about
  a transaction and which those peers can then use to request that
  `pckginfo1` message for a particular transaction.

  Using these messages, a node can use an `inv(MSG_PCKG1)` message to tell
  its peers that they might be interested in receiving a `pckginfo1` about
  a transaction, e.g. because it is a high-feerate child of a low-feerate
  unconfirmed parent transaction the peers might otherwise ignore.  If any
  peer requests the `pckginfo1` message, they can use the info in the
  message to determine whether they really are interested in the package
  and to learn the wtxids of any transactions they need to download in
  order to validate the high feerate child.  The actual transactions can
  be requested with a `getpckgtxns` message and received in a `pckgtxins`
  message.

  Although the [draft BIP][bip-package-relay] focuses on just the
  protocol, Zhao's email provides additional context, briefly describes
  alternative designs that were found deficient, and links
  to a [presentation][zhao preso] with additional details.

- **Miner extractable value discussion:** developer /dev/fd0
  [posted][fd0 ctv9] to the Bitcoin-Dev mailing list a summary of the
  [ninth IRC meeting][ctv9] about [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] (CTV).  Among other topics discussed during
  that meeting, Jeremy Rubin listed several concerns he's heard people
  express about recursive [covenants][topic covenants] (which CTV does
  not enable).  One of those concerns was creating Miner Extractable
  Value (MEV) significantly beyond the amount available from running a
  simple transaction selection algorithm such as that provided by
  Bitcoin Core.

  MEV has become a particular concern in Ethereum and related
  protocols where the use of public onchain trading protocols allows
  miners to frontrun trades.  For example, imagine the following two
  unconfirmed transactions both being available to mine in the next
  block:

  * Alice sells asset *x* to Bob for 1 ETH
  * Bob sells *x* to Carol for 2 ETH (Bob earns 1 ETH in profit)

  <br>If those two exchanges are conducted using a public onchain trading
  protocol, a miner can cut Bob out of the transaction.  For example:

  * Alice sells asset *x* to Miner Mallory for 1 ETH
  * Miner Mallory sells *x* to Carol for 2 ETH (Mallory earns 1 ETH in
    profit; Bob earns nothing)

  <br>Obviously this is a problem for Bob, but it also creates several
  problems for the network.  The first problem is that miners need to
  find opportunities for MEV.  That's trivial in the simple example
  above, but more complex opportunities can only be found through
  computationally intensive algorithms.
  The amount of value that can be found by a certain amount of computation is
  independent of each miner's hashrate, so two miners can join
  together to halve the amount of money they need to spend on computation
  for capturing MEV---producing an economy of scale that
  encourages centralization of mining and which can leave the network
  more vulnerable to transaction censorship.  A [report][bitmex
  flashbots] by BitMex Research claims that a centralized service that
  brokers these types of MEV transactions was being used by 90% of
  Ethereum hashrate at the time the report was written.  To obtain the
  maximum returns, that service could be changed to discourage mining
  competing transactions, effectively giving it the power to
  censor transactions if it was used by 100% of miners (or if it was
  used by more than 50% of miners and allowed to engage in block chain
  reorganization).

  A second problem is that, even if Mallory does produce a block
  capturing the 1 ETH of MEV, any other miner can produce an
  alternative block capturing the MEV for themselves.  This pressure to re-mine blocks
  exacerbates [fee sniping][topic fee sniping] pressure, which at its
  worst can make confirmation scores useless for determining
  transaction finality, eliminating the ability to use proof of work
  to secure the network.

  Bitcoin's use of UTXOs rather than Ethereum-style accounts makes it
  harder to implement the types of protocols that are particularly
  vulnerable to MEV.  However, in the CTV meeting, Jeremy Rubin noted
  that recursive covenants make it easier to implement account-based
  systems on top of Bitcoin UTXOs and so increase the chance that MEV
  will become a significant future concern for Bitcoin protocol
  design.

  Replying to /dev/fd0's summary for the mailing list, developer
  ZmnSCPxj suggested that we only adopt mechanisms that encourage
  protocols designed for maximum onchain privacy.  That privacy would
  deny miners the information necessary to perform MEV.  As of the
  writing of this newsletter, no further comments had been received on
  the mailing list but, from mentions on Twitter and elsewhere, we see
  evidence that developers are increasingly considering the
  impact of MEV on Bitcoin protocol design.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [How much entropy is lost alphabetising your mnemonics?]({{bse}}113432)
  HansBKK wonders how much entropy is lost if 12 or 24 word seed phrases were sorted
  alphabetically. Pieter Wuille breaks down a series of metrics including number
  of possibilities, entropy, and mean number of guesses to brute force across 12 and 24
  words and also notes considerations for word repetition.

- [Taproot signing with PSBT: How to determine signing method?]({{bse}}113489)
  Guggero lists three ways of providing a valid [Schnorr signature][topic
  schnorr signatures] in taproot: a keypath spend with [BIP86][] commitment, a
  keypath spend with a commitment to the root of the script tree, and a
  scriptpath spend. Andrew Chow confirms Guggero's outline of how each signing
  method is indicated within a [PSBT][topic psbt].

- [How would faster blocks cause mining centralization?]({{bse}}113505)
  Murch focuses on why shorter block times would cause more frequent
  reorganizations and how those would benefit larger miners in the context
  of block propagation latency.

- [What does "waste metric" mean in the context of coin selection?]({{bse}}113622)
  Murch explains that, when spending, Bitcoin Core uses
  a [waste metric][news165 waste] heuristic as a "measure of the fees for the
  input set at the current feerate compared to spending the same inputs at the
  hypothetical long-term feerate". This heuristic is used to evaluate [coin
  selection][topic coin selection] candidates that result from the Branch and
  Bound (BnB), Single Random Draw (SRD), and knapsack algorithms.

- [Why isn't `OP_CHECKMULTISIG` compatible with batch verification of schnorr signatures?]({{bse}}113816)
  Pieter Wuille points out that since [`OP_CHECKMULTISIG`][wiki
  op_checkmultisig] doesn't indicate which signatures go with what pubkeys, it is
  incompatible with batch verification and [motivated][bip342 fn4] BIP342's new
  `OP_CHECKSIGADD` opcode.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning 0.11.1][] is a bug fix release that eliminates an issue
  causing unilateral channel close transactions to be broadcast
  unnecessarily and a separate issue that lead to the C-Lightning node
  crashing.

- [LND 0.15.0-beta.rc3][] is a release candidate for the next major
  version of this popular LN node.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #20799][] removes support for version one [compact block
  relay][topic compact block relay], which allowed faster and more
  bandwidth efficient relay of blocks and transactions to peers that
  didn't support segwit.  Version two remains enabled and allows
  fast and efficient relay to segwit-supporting peers.

- [LND #6529][] adds a `constrainmacaroon` command that allows
  restricting the privileges of an already-created macaroon
  (authentication token).  Previously, changing privileges required
  creating a new macaroon.

- [LND #6524][] increases the version number of LND's aezeed backup
  scheme from 0 to 1.  This will indicate to future software recovering
  funds from an aezeed backup that they should scan for [taproot][topic
  taproot] outputs received to the wallet.

## Special thanks

In addition to our regular newsletter contributors, we thank Jeremy
Rubin in particular this week for providing additional detail about MEV.
We remain solely responsible for any errors or omissions.

{% include references.md %}
{% include linkers/issues.md v=2 issues="20799,6529,6524" %}
[lnd 0.15.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.15.0-beta.rc3
[Core Lightning 0.11.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.11.1
[zhao package]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020493.html
[bip-package-relay]: https://github.com/bitcoin/bips/pull/1324
[zhao preso]: https://docs.google.com/presentation/d/1B__KlZO1VzxJGx-0DYChlWawaEmGJ9EGApEzrHqZpQc/edit#slide=id.p
[fd0 ctv9]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020501.html
[ctv9]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-May/020501.html
[bitmex flashbots]: https://blog.bitmex.com/flashbots/
[news165 waste]: /en/newsletters/2021/09/08/#bitcoin-core-22009
[wiki op_checkmultisig]: https://en.bitcoin.it/wiki/OP_CHECKMULTISIG
[bip342 fn4]: https://github.com/bitcoin/bips/blob/master/bip-0342.mediawiki#cite_note-4
