---
title: 'Bitcoin Optech Newsletter #97'
permalink: /en/newsletters/2020/05/13/
name: 2020-05-13-newsletter
slug: 2020-05-13-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal that taproot signatures make
an additional commitment to spent scriptPubKeys and includes our regular
sections with the summary of a Bitcoin Core PR Review Club meeting, a
list of releases and release candidates, and descriptions of notable
changes to popular Bitcoin infrastructure software.

## Action items

*None this week.*

## News

- **Request for an additional taproot signature commitment:** an idea
  previously discussed[^increase-quote] among Bitcoin experts would be allowing
  hardware wallets to automatically sign any transaction as long as it
  provably increases the user's balance.  This could make it easy for
  the hardware wallet to automatically participate in [coinjoin][topic
  coinjoin] transactions or LN payment routing.

    However, several years ago, Greg Sanders [described][sanders safe
    automation] an attack that could be used to trick a hardware wallet
    into thinking that its balance was increasing when it was actually
    decreasing.  An attacker would create an unsigned transaction
    spending two of the hardware wallet's inputs to two outputs---one
    output paying the wallet slightly more than the larger of the
    two inputs and the other output paying the attacker.  The attacker
    would ask for a signature on the first input (without disclosing that the
    second input belonged to the wallet); the wallet would sign that
    input after verifying that the output paying back into the wallet
    was larger than the input.  Then the attacker would ask for a
    signature for the second input---pretending that this was for a
    completely different transaction---causing the wallet to also sign
    the second input after again verifying that there was an output
    larger than the input.  Finally, the attacker would put both signatures
    into a final transaction and broadcast it, stealing money from the
    wallet.  Sanders's description of the problem also described a
    potential solution, but it requires that wallets know the
    scriptPubKeys for each previous output being spent in the
    transaction.

    ![Illustration of using a fake coinjoin to trick a hardware wallet into losing funds](/img/posts/2020-05-fake-coinjoin-trick-hardware-wallet.dot.png)

    Last week, Andrew Kozlik [posted][kozlik spk commit] to the
    Bitcoin-Dev mailing list to request that [taproot][topic taproot]
    signatures directly commit to the scriptPubKey of every input's
    previous output.  This commitment is already made indirectly by
    committing to the outpoints of all the transaction's
    inputs,[^outpoint-txid-spk] but making it directly in the
    transaction digest would allow a [Partially Signed Bitcoin
    Transaction][topic psbt] (PSBT) to trustlessly provide signers with
    a copy of all scriptPubKeys being spent in a transaction.  The scriptPubKeys in the PSBT
    wouldn't require any trust because, if any of the scriptPubKeys were missing
    or modified, the signer's commitment to the scriptPubKeys would be
    invalid, making the transaction invalid.  This would allow hardware
    wallets to use the solution described by Sanders in 2017 without
    needing to trust an external program to provide correct copies of
    the scriptPubKeys being spent.

## Bitcoin Core PR Review Club

_In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting._

[Flush undo files after last block write][review club #17994] is a PR
([#17994][Bitcoin Core #17994]) by Karl-Johan Alm that changes the way
that _undo files_ are flushed to disk. Undo files are created when the
UTXO set is updated to reflect the transactions in a new block; if the
block is later removed during a reorg, the undo file contains the
changes that will restore the UTXO set to its previous state, undoing
the effects of originally processing the block.

Most of the discussion was around the basic concepts and the details of
the bug fix:

{% include functions/details-list.md
  q0="Can the existing bug result in data loss (and potentially consensus
      failure)?"
  a0="No. The [bug][Bitcoin Core #17890] can result in using disk space unnecessarily, but cannot
      result in data loss."
  a0link="https://bitcoincore.reviews/17994.html#l-33"

  q1="Is it possible to create the undo data for a block without having all the
      preceding blocks?"
  a1="No. Creating the undo data for a block requires having the UTXO set at
      the point that the block was connected. For that, we need to have
      validated and connected all preceding blocks."
  a1link="https://bitcoincore.reviews/17994.html#l-43"

  q2="Do we ever modify block or undo data after it has been written to disk?"
  a2="In general, no. Block and undo data are write-only. Once they've been
      written to disk, they are not modified. A pruning node may delete block
      and undo data after it's been buried by enough new blocks."
  a2link="https://bitcoincore.reviews/17994.html#l-79"

  q3="Is undo data written to disk in the same order as the block data?"
  a3="No. Block data is written in the order that the blocks were received
      (which may not be in height order, since we fetch blocks in parallel
      during initial sync), and undo data is written in the order that the blocks
      were connected. However, undo data always appears in the corresponding
      `rev*` file to the `blk*` file that the block appears in."
  a3link="https://bitcoincore.reviews/17994.html#l-103"

  q4="How is space allocated in the block and undo files? Why?"
  a4="Space is pre-allocated in the files in chunks of 16MB for block files
      and 1MB for undo files. This is to reduce filesystem fragmentation."
  a4link="https://bitcoincore.reviews/17994.html#l-122"

  q5="What does this PR change?"
  a5="In this PR, the undo file is finalized and flushed to disk when
      the highest block in the file has been connected, instead of when
      the corresponding block file is flushed."
  a5link="https://bitcoincore.reviews/17994.html#l-204"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Eclair 0.4][] is a new major version release that upgrades Eclair's
  major dependencies, adds support for the latest version of Bitcoin
  Core, and deprecates Eclair Node GUI (instead users are encouraged to
  run [Phoenix][] or [Eclair Mobile][]).

- [C-Lightning 0.8.2.1][] is a new maintenance release that fixes an
  incompatibility in large channels ("wumbo channels") between
  C-Lightning and Eclair.  See the linked release notes for details.

- [Bitcoin Core 0.20.0rc1][bitcoin core 0.20.0] is a release candidate
  for the next major version of Bitcoin Core.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1 repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

*Note: the commits to Bitcoin Core mentioned below apply to its master
development branch and so those changes will likely not be released
until version 0.21, about six months after the release of the upcoming
version 0.20.*

- [Bitcoin Core #16224][] displays all of the GUI's translated error
  messages in both the locale's language and in English.  This can help
  users find help and quickly describe the problem to developers.
  Additionally, the English version of the error message is now what
  is written to the debug log, again to make it easier for developers
  to comprehend the problem and provide assistance.

- [C-Lightning #3659][] has `channeld` create the penalty transaction, as
  it has enough information about previous commitment transactions. With
  this change, C-Lightning now supports watchtowers, such as
  [Talaia’s The Eye of Satoshi watchtower][talaia]. Possible [future
  extensions][CL future] are to include the HTLC transactions for watchtower
  settlement and to generate penalty transactions for commitments created before the watchtower plugin was activated.

- [Rust-Lightning #539][] adds support for `option_static_remotekey` channels
  and requires connecting peers to support this feature. In the case of data
  loss on your end, this feature allows your channel counterparty to pay an
  untweaked key agreed upon during the initial channel open, which will close
  the channel and allow your wallet to spend your funds. See Newsletter
  [#67][news67 static_remotekey] for more details on this feature.

- [LND #4139][] extends the `gettransactions` and `listsweeps` RPCs to
  allow passing start and end block heights to only retrieve
  transactions confirmed within that block range.  A value of `-1` for
  the end height may be used to also list unconfirmed transactions.

## Footnotes

[^increase-quote]:
    "You keep the wallet connected to the computer, and the connected
    computer runs a watch-only lightning wallet, and then communicates
    with the hardware wallet for signatures on transactions that
    strictly increase the balance of your channel." ---Excerpt from the
    rough [transcript][snigirev ref] of a talk about hardware wallets by
    Stephan Snigirev; transcript by Bryan Bishop

[^outpoint-txid-spk]:
    In the existing [BIP341][] specification of [taproot][topic
    taproot], each input commits to the outpoints of every input
    included in the transaction.  Outpoints are the txid
    and output index (vout) of the output being spent.  Txids are a hash
    of most parts of the transaction containing that output.  So a
    commitment to an outpoint is a commitment to a txid which is a
    commitment to the previous output (including the output's
    scriptPubKey).

{% include references.md %}
{% include linkers/issues.md issues="16224,3659,539,4139,17994,17890" %}
[bitcoin core 0.20.0]: https://bitcoincore.org/bin/bitcoin-core-0.20.0
[c-lightning 0.8.2.1]: https://github.com/ElementsProject/lightning/releases/tag/v0.8.2.1
[eclair 0.4]: https://github.com/ACINQ/eclair/releases/tag/v0.4
[phoenix]: https://phoenix.acinq.co/
[eclair mobile]: https://github.com/ACINQ/eclair-mobile
[sanders safe automation]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2017-August/014843.html
[kozlik spk commit]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2020-April/017801.html
[snigirev ref]: https://diyhpl.us/wiki/transcripts/austin-bitcoin-developers/2019-06-29-hardware-wallets/
[talaia]: https://twitter.com/sr_gi/status/1258830271148961795
[CL future]: https://github.com/ElementsProject/lightning/issues/3724
[news67 static_remotekey]: /en/newsletters/2019/10/09/#bolts-642
