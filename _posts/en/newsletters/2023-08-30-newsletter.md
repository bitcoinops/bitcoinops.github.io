---
title: 'Bitcoin Optech Newsletter #266'
permalink: /en/newsletters/2023/08/30/
name: 2023-08-30-newsletter
slug: 2023-08-30-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the responsible disclosure of a
vulnerability affecting old LN implementations and summarizes a suggestion
for a mashup of proposed covenant opcodes.  Also included are our
regular sections with selected questions and answers from the Bitcoin
Stack Exchange, announcements of new software releases and release
candidates, and summaries of notable changes to popular Bitcoin
infrastructure software.

## News

- **Disclosure of past LN vulnerability related to fake funding:** Matt
  Morehouse [posted][morehouse dos] to the Lighting-Dev mailing list
  the summary of a vulnerability he had previously [responsibly
  disclosed][topic responsible disclosures] and which is now addressed
  in the latest versions of all popular LN implementations.  To
  understand the vulnerability, imagine that Bob runs an LN node.  He
  receives a request from Mallory's node to open a new channel and they go
  through the channel opening process up to the stage where Mallory is
  supposed to broadcast a transaction that funds the channel.  In order
  to later use that channel, Bob needs to store some state related to it
  and begin scanning new blocks for the transaction to become
  sufficiently confirmed.  If Mallory never broadcasts the transaction,
  Bob's storage and scanning resources are wasted.  If Mallory repeats
  the process thousands or millions of times, it might waste Bob's
  resources to the point where his LN node is unable to do anything
  else---including performing time-sensitive operations that are
  necessary to prevent loss of money.

    In Morehouse's testing against his own nodes, he was able to cause
    significant problems with Core Lightning, Eclair, LDK, and LND,
    including two cases that (in our opinion) could likely lead to loss
    of funds among many nodes.  Morehouse's [full description][morehouse
    post] links to the PRs where the issue was addressed (which includes
    PRs covered in Newsletters [#237][news237 dos] and [#240][news240
    dos]) and lists the LN releases that addressed the vulnerability:

    - Core Lightning 23.02
    - Eclair 0.9.0
    - LDK 0.0.114
    - LND 0.16.0

    There was some follow-up discussion on the mailing list and on
    [IRC][stateless funding].

- **Covenant mashup using `TXHASH` and `CSFS`:** Brandon Black
  [posted][black mashup] to the Bitcoin-Dev mailing list a proposal for
  a version of `OP_TXHASH` (see [Newsletter #185][news185 txhash])
  combined with [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] that
  would provide most of the features of [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] (CTV) and [SIGHASH_ANYPREVOUT][topic
  sighash_anyprevout] (APO) without much additional onchain cost over
  those individual proposals.  Although the proposal stands on its own,
  part of the motivation for creating it was to "clarify our thinking
  about [CTV and APO] individually and together, and potentially move
  toward consensus on a path toward enabling [...] amazing ways to use
  bitcoin in the future".

    The proposal received some discussion on the mailing list, with
    [additional revisions][delv mashup] posted and discussed on the
    Delving Bitcoin forum.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Is there an economic incentive to switch from P2WPKH to P2TR?]({{bse}}119301)
  Murch walks through common wallet usage patterns while comparing weights of
  transaction inputs and outputs for P2WPKH and [P2TR][topic taproot] output types. He concludes
  by saying: "Overall, you’d save up to 15.4% in transaction fees by using P2TR
  instead of P2WPKH. If you make vastly more small payments than you receive
  payments, you may save up to 1.5% by sticking to P2WPKH."

- [What is the BIP324 encrypted packet structure?]({{bse}}119369)
  Pieter Wuille outlines the network packet structure for [version 2 P2P
  transport][topic v2 p2p transport] as proposed in [BIP324][] with
  progress tracked in [Bitcoin Core #27634][].

- [What is the false positive rate for compact block filters?]({{bse}}119142)
  Murch answers from [BIP158][]'s section on [block filter][bip158 filters]
  parameter selection that notes a false positive rate for [compact block
  filters][topic compact block filters] of 1/784931, the equivalent of 1 block
  every 8 weeks for a wallet monitoring about 1000 output scripts.

- [What opcodes are part of the MATT proposal?]({{bse}}119239)
  Salvatoshi explains his Merkleize All The Things ([MATT][merkle.fun]) proposal (see
  Newsletters [#226][news226 matt], [#249][news249 matt], and [#254][news254
  matt]), including its currently proposed opcodes:
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify],
  OP_CHECKCONTRACTVERIFY, and [OP_CAT][].

- [Is there a well defined last Bitcoin block?]({{bse}}119223)
  RedGrittyBrick and Pieter Wuille point out that while there is not a block
  height limit, the current consensus rules will not permit a new block beyond
  Bitcoin's unsigned 32-bit timestamp limit in the year 2106. Transaction
  [nLockTime][topic timelocks] values have the same [timestamp limit]({{bse}}110666).

- [Why are miners setting the locktime in coinbase transactions?]({{bse}}110474)
  Bordalix answers a long-open question about miners seemingly using the coinbase
  transaction's locktime field to communicate something. A mining pool
  operator explained that they "repurpose those 4 bytes to hold the stratum
  session data for faster reconnect" and went on to [elaborate on the scheme][twitter satofishi].

- [Why doesn't Bitcoin Core use auxiliary randomness when performing Schnorr signatures?]({{bse}}119042)
  Matthew Leon asks why [BIP340][] recommends using auxiliary randomness when
  generating a [schnorr signature][topic schnorr signatures] nonce for
  protection against [side channel][topic side channels] attacks, yet Bitcoin
  Core doesn't provide auxiliary randomness in its implementation. Andrew Chow
  answers that the current implementation is still safe and that no PR has been
  opened to address the recommendation.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test release candidates.*

- [Core Lightning 23.08][] is the newest major release of this popular
  LN node implementation.  New features include the ability to
  change several node configuration settings without restarting the
  node, support for [Codex32][topic codex32]-formatted [seed][topic
  bip32] backup and restore, a new experimental plugin for improved
  payment pathfinding, experimental support for [splicing][topic
  splicing], and the ability to pay locally-generated invoices, among
  many other new features and bug fixes.

- [LND v0.17.0-beta.rc1][] is a release candidate for the next major
  version of this popular LN node implementation.  A major new
  experimental feature planned for this release, which could likely
  benefit from testing, is support for "simple taproot channels" as
  described in LND PR #7904 in the _notable changes_ section.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #27460][] adds a new `importmempool` RPC. The RPC will
  load a `mempool.dat` file and attempt to add the loaded transactions
  to its mempool.

- [LDK #2248][] provides a built-in system that LDK downstream projects
  can use for tracking the UTXOs referenced in gossip messages.  LN
  nodes that process gossip must only accept messages that are signed by
  a key associated with a UTXO, otherwise they can be forced into
  processing and relaying spam messages, or attempting to forward
  payments over nonexistent channels (which will always fail).  The new
  built-in `UtxoSource` works for LN nodes connected to a local Bitcoin
  Core.

- [LDK #2337][] makes it easier to use LDK for building
  [watchtowers][topic watchtowers] that run independently from a user's
  wallet but can receive encrypted LN penalty transactions from the
  user's node.  A watchtower can then extract information from each
  transaction in new blocks and use that information to attempt to
  decrypt the previously-received encrypted data.  If the decryption
  succeeds, the watchtower can broadcast the decrypted penalty
  transaction.  This protects the user against their counterparty
  publishing a revoked channel state when the user is unavailable.

- [LDK #2411][] and [#2412][ldk #2412] add an API for constructing
  payment paths for [blinded payments][topic rv routing].  The PRs help
  separate LDK's code for [onion messages][topic onion messages] (which
  use blinded paths) from blinded paths themselves.  A follow-up in
  [#2413][ldk #2413] will actually add support for route blinding.

- [LDK #2507][] adds a workaround for a longstanding issue in another
  implementation that leads to unnecessary channel force closures.

- [LDK #2478][] adds an event that provides information about a forwarded
  [HTLC][topic htlc] that has now been settled, including what channel
  it came from, the amount of the HTLC, and the amount of fee
  collected from it.

- [LND #7904][] adds experimental support for "simple taproot
  channels", allowing LN funding and commitment transactions to use
  [P2TR][topic taproot] with support for [MuSig2][topic musig]
  scriptless [multisignature][topic multisignature] signing when both
  parties are cooperating.  This reduces transaction weight space and improves
  privacy when channels are closed cooperatively.  LND continues to
  exclusively use [HTLCs][topic htlc], allowing payments starting in a
  taproot channel to continue to be forwarded through other LN nodes
  that don't support taproot channels.

    <!-- The following linked PRs have titles "1/x", "2/x", etc.  I've
    listed them in that order rather than by PR number -->
    This PR includes 134 commits that were previously merged into a
    staging branch from the following PRs: [#7332][lnd #7332],
    [#7333][lnd #7333], [#7331][lnd #7331], [#7340][lnd #7340],
    [#7344][lnd #7344], [#7345][lnd #7345], [#7346][lnd #7346],
    [#7347][lnd #7347], and [#7472][lnd #7472].

{% include references.md %}
{% include linkers/issues.md v=2 issues="27460,2466,2248,2337,2411,2412,2413,2507,2478,7904,7332,7333,7331,7340,7344,7345,7346,7347,7472,27634" %}
[LND v0.17.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc1
[core lightning 23.08]: https://github.com/ElementsProject/lightning/releases/tag/v23.08
[delv mashup]: https://delvingbitcoin.org/t/combined-ctv-apo-into-minimal-txhash-csfs/60/6
[morehouse dos]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-August/004064.html
[morehouse post]: https://morehouse.github.io/lightning/fake-channel-dos/
[news237 dos]: /en/newsletters/2023/02/08/#core-lightning-5849
[news240 dos]: /en/newsletters/2023/03/01/#ldk-1988
[black mashup]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021907.html
[news185 txhash]: /en/newsletters/2022/02/02/#composable-alternatives-to-ctv-and-apo
[stateless funding]: https://gnusha.org/lightning-dev/2023-08-27.log
[bip158 filters]: https://github.com/bitcoin/bips/blob/master/bip-0158.mediawiki#block-filters
[merkle.fun]: https://merkle.fun/
[news254 matt]: /en/newsletters/2023/06/07/#using-matt-to-replicate-ctv-and-manage-joinpools
[news249 matt]: /en/newsletters/2023/05/03/#matt-based-vaults
[news226 matt]: /en/newsletters/2022/11/16/#general-smart-contracts-in-bitcoin-via-covenants
[twitter satofishi]: https://twitter.com/satofishi/status/1693537663985361038
