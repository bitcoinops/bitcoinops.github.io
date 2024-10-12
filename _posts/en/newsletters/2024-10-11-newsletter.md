---
title: 'Bitcoin Optech Newsletter #324'
permalink: /en/newsletters/2024/10/11/
name: 2024-10-11-newsletter
slug: 2024-10-11-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces three vulnerabilities affecting old
versions of the Bitcoin Core full node, announces a separate vulnerability affecting
old versions of the btcd full node, and links to a contributed Optech
guide describing how to use multiple new P2P network features added in
Bitcoin Core 28.0.  Also included are our regular sections summarizing a
Bitcoin Core PR Review Club meeting, announcements of new releases and
release candidates, and descriptions of notable changes to popular
Bitcoin infrastructure software.

## News

- **Disclosure of vulnerabilities affecting Bitcoin Core versions before 25.0:**
  Niklas Gögge [posted][gogge corevuln] to the Bitcoin-Dev mailing list
  links to the announcements of three vulnerabilities affecting versions
  of Bitcoin Core that have been past their end of life since at least
  April 2024.

  - [CVE-2024-35202 remote crash vulnerability][]: an attacker can send
    a [compact block][topic compact block relay] message deliberately
    designed to fail block reconstruction.  Failed reconstructions
    sometimes happen even in honest use of the protocol, in which case
    the receiving node requests the full block.

    However, instead of replying with a full block, the attacker could
    send a second compact block message for the same block header.
    Before Bitcoin Core 25.0, this would cause the node to crash, as the
    code was designed to prevent the compact block reconstruction code
    from running more than once on the same compact block session.

    This easily exploitable vulnerability could have been used to crash
    any Bitcoin Core node, which could be used as part of other
    attacks to steal money from users.  For example, a crashed Bitcoin
    Core node would be unable to alert a connected LN node that a
    channel counterparty was attempting to steal funds.

    The vulnerability was discovered, [responsibly disclosed][topic
    responsible disclosures], and fixed by Niklas Gögge, with the
    [fix][bitcoin core #26898] released in Bitcoin Core 25.0.

  - [DoS from large inventory sets][]: for each of its peers, a Bitcoin
    Core node keeps a list of transactions to send to that peer.  The
    transactions in the list are sorted based on their feerates and
    their relationships to each other in an attempt to ensure that the
    best transactions relay fast and to make it harder to probe the
    relay network topology.

    However, during a surge of network activity in May 2023, several
    users began noticing their nodes using an excessive amount of CPU.
    Developer 0xB10C determined that the CPU was being
    consumed by the sorting function.  Developer Anthony Towns
    investigated further and [fixed][bitcoin core #27610] the problem by
    ensuring transactions left the queue at a variable rate that increases
    during periods of high demand.  The fix was released in Bitcoin Core
    25.0.

  - [Slow block propagation attack][]: before Bitcoin Core 25.0, an
    invalid block from an attacker could prevent Bitcoin Core from
    continuing to process a valid block with the same header from honest
    peers.  This especially affected compact block reconstruction when
    additional transactions needed to be requested: a node would stop
    waiting for the transactions if it received an invalid block from a
    different peer.  Even if the transactions were later received, the
    node would ignore them.

    After Bitcoin Core had rejected the invalid block (and possibly
    disconnected the peer that sent it), it would restart attempting to
    request the block from other peers.  Multiple attacking peers could
    keep it in this cycle for an extended period of time.  Faulty peers
    that may not have been designed as attackers could trigger the same
    behavior accidentally.

    <!-- I've previously confirmed that "ghost43" (all lowercase) is how
    they'd like to be attributed -->

    The problem was discovered after several developers, including
    William Casarin and ghost43, reported problems with their nodes.
    Several other developers investigated, with Suhas Daftuar isolating
    this vulnerability.  Daftuar also [fixed][bitcoin core #27608] it by
    preventing any peer from affecting the download state of other
    peers, except in the case where a block has passed validation and
    been stored to disk.  The fix was included in Bitcoin Core 25.0.

- **CVE-2024-38365 btcd consensus failure:** as announced in [last
  week's newsletter][news323 btcd], Antoine Poinsot and Niklas Gögge
  [disclosed][pg btcd] a consensus failure vulnerability affecting the
  btcd full node.  In legacy Bitcoin transactions, signatures are stored
  in the signature script field.  However, the signatures also commit to
  the signature script field.  It's not possible for a signature to
  commit to itself, so signers commit to all of the data in the signature
  script field except for the signature.  Verifiers must correspondingly
  remove the signature before checking the accuracy of the signature
  commitment.

  Bitcoin Core's function for removing signatures, `FindAndDelete`, only
  removes exact matches of the signature from the signature script.
  The function implemented by btcd, `removeOpcodeByData` removed _any_
  data in the signature script which contained the signature.  This
  could be used to cause btcd to remove more data from the signature
  script than Bitcoin Core would remove before it respectively
  verified the commitment, leading one program to consider the commitment
  valid and the other invalid.  Any transaction containing an invalid
  commitment is invalid and any block containing an invalid transaction
  is invalid, allowing consensus between Bitcoin Core and btcd to be
  broken.  Nodes that fall out of consensus can be tricked into
  accepting invalid transactions and may not see the latest transactions
  the rest of the network considers to be confirmed, either of which can
  result in a significant loss of money.

  Poinsot's and Gögge's responsible disclosure allowed btcd maintainers
  to quietly fix the vulnerability and release version 0.24.2 with the
  fix about three months ago.

- **Guide for wallets employing Bitcoin Core 28.0:** As mentioned in
  [last week's newsletter][news323 bcc28], the newly released version
  28.0 of Bitcoin Core contains several new features for the P2P
  network, including one parent one child (1P1C) [package
  relay][topic package relay], topologically restricted until
  confirmation ([TRUC][topic v3 transaction relay]) transaction relay,
  [package RBF][topic rbf] and [sibling eviction][topic kindred rbf],
  and a standard pay-to-anchor ([P2A][topic ephemeral anchors]) output
  script type.  These new features can significantly improve security
  and reliability for several common use cases.

  Gregory Sanders has written a [guide][sanders guide] for Optech aimed
  at developers of wallets and other software that uses Bitcoin Core to
  create or broadcast transactions.  The guide walks through the use of
  several of the features and describes how the features can be useful
  for multiple protocols, including simple payments and RBF fee bumping,
  LN commitments and [HTLCs][topic htlc], [Ark][topic ark], and [LN
  splicing][topic splicing].

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

[Add getorphantxs][review club 30793] is a PR by [tdb3][gh tdb3] that
adds a new experimental RPC method named `getorphantxs`. Since it is
intended primarily for developers, it is hidden. This new method
provides the caller with a list of all current orphan transactions,
which can be helpful when checking orphan behavior/scenarios (e.g. in
functional tests like `p2p_orphan_handling.py`) or for providing
additional data for statistics/visualization.

{% include functions/details-list.md
  q0="What is an orphan transaction? At what point do transactions enter
  the orphanage?"
  a0="An orphan transaction is one whose inputs refer to unknown or
  missing parent transactions. Transactions enter the orphanage when
  they are received from a peer but they fail validation with
  `TX_MISSING_INPUTS` in `ProcessMessage`."
  a0link="https://bitcoincore.reviews/30793#l-16"
  q1="What command can you run to get a list of available RPCs?"
  a1="`bitcoin-cli help` provides a list of available RPCs. Note: since
  `getorphantxs` is [marked as hidden][gh getorphantxs hidden] as a
  developer-only RPC, it will not show up in this list."
  a1link="https://bitcoincore.reviews/30793#l-26"
  q2="If an RPC has a non-string argument, does anything special need to
  be done to handle it?"
  a2="Non-string RPC arguments must be added to the `vRPCConvertParams`
  list in `src/rpc/client.cpp` to ensure proper type conversion."
  a2link="https://bitcoincore.reviews/30793#l-72"
  q3="What is the maximum size of the result from this RPC? Is there a
  limit to how many orphans are retained? Is there a limit to how long
  orphans can stay in the orphanage?"
  a3="The maximum number of orphans is 100
  (`DEFAULT_MAX_ORPHAN_TRANSACTIONS`). At `verbosity=0`, each txid is a
  32-byte binary value, but when hex-encoded for the JSON-RPC result, it
  becomes a 64-character string (since each byte is represented by two
  hex characters). This means the maximum result size is approximately
  6.4 kB (100 txids * 64 bytes).<br><br>
  At `verbosity=2`, the hex-encoded transaction is by far the largest
  field in the result, so for simplicity we'll ignore the other fields
  in this calculation. The maximum serialized size of a transaction can
  be up to 400 kB (in the extreme, impossible case that it consists only
  of witness data), or 800 kB when hex-encoded. Therefore, the maximum
  result size is roughly 80 MB (100 transactions * 800 kB).<br><br>
  Orphans are time-limited and are removed after 20 minutes, as defined
  by `ORPHAN_TX_EXPIRE_TIME`."
  a3link="https://bitcoincore.reviews/30793#l-94"
  q4="Since when has there been a maximum orphanage size?"
  a4="The `MAX_ORPHAN_TRANSACTIONS` variable was introduced back in 2012
  already, in commit [142e604][gh commit 142e604]."
  a4link="https://bitcoincore.reviews/30793#l-105"
  q5="Using the `getorphantxs` RPC, would we be able to tell how long a
  transaction has been in the orphanage? If yes, how would you do it?"
  a5="Yes, by using `verbosity=1`, you can get the expiration timestamp
  of each orphan transaction. Subtracting the `ORPHAN_TX_EXPIRE_TIME`
  (i.e. 20 minutes) gives the insertion time."
  a5link="https://bitcoincore.reviews/30793#l-128"
  q6="Using the `getorphantxs` RPC, would we be able to tell what the
  inputs of an orphan transaction are? If yes, how would you do it?"
  a6="Yes, with `verbosity=2`, the RPC returns the raw transaction hex,
  which can be decoded using `decoderawtransaction` to reveal its
  inputs."
  a6link="https://bitcoincore.reviews/30793#l-140"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Inquisition 28.0][] is the latest release of this
  [signet][topic signet] full node designed for experimenting with
  proposed soft forks and other major protocol changes.  The updated
  version is based on the recently released Bitcoin Core 28.0.

- [BDK 1.0.0-beta.5][] is a release candidate (RC) of this library for
  building wallets and other Bitcoin-enabled applications.  This latest
  RC "enables RBF by default, updates the bdk_esplora client to retry
  server requests that fail due to rate limiting. The `bdk_electrum`
  crate now also offers a use-openssl feature."

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Core Lightning #7494][] introduces a 2-hour lifespan for `channel_hints`,
  allowing pathfinding information learned from a payment to be reused in future
  attempts in order to skip unnecessary attempts. Channels that were considered
  unavailable will be gradually restored and become fully available after 2
  hours, to ensure that outdated information doesn't cause routes to be skipped
  that may have since recovered.

- [Core Lightning #7539][] adds a `getemergencyrecoverdata` RPC command to fetch
  and return data from the `emergency.recover` file. This will allow developers
  using the API to add wallet backup functionality to their applications.

- [LDK #3179][] introduces new `DNSSECQuery` and `DNSSECProof` [onion
  messages][topic onion messages], and a `DNSResolverMessageHandler` to handle
  these messages as the core functionality to implement [BLIP32][]. This PR also
  adds an `OMNameResolver` that verifies the DNSSEC proofs and turns them into
  [offers][topic offers]. See Newsletter [#306][news306 blip32].

- [LND #8960][] implements custom channel functionality by adding taproot
  overlay as a new experimental channel type, which is identical to a [simple
  taproot channel][topic simple taproot channels] but commits additional metadata
  in the [tapscript][topic tapscript] leaves for channel scripts. The main
  channel state machine and database are updated to process and store custom
  tapscript leaves. A config option `TaprootOverlayChans` must be set to enable
  support for taproot overlay channels. The custom channels initiative enhances
  LND’s support for [taproot assets][topic client-side validation]. See
  Newsletter [#322][news322 customchans].

- [Libsecp256k1 #1479][] adds a [MuSig2][topic musig] module for a
  [BIP340][]-compatible multisig scheme as specified in [BIP327][]. This module
  is almost identical to the one implemented in [secp256k1-zkp][zkpmusig2], but
  has some minor changes, such as removing support for [adaptor
  signatures][topic adaptor signatures] to make it non-experimental.

- [Rust Bitcoin #2945][] introduces support for [testnet4][topic testnet] by
  adding the `TestNetVersion` enum, refactoring the code, and including the
  necessary parameters and blockchain constants for testnet4.

- [BIPs #1674][] reverts the changes to the [BIP85][] specification
  described in [Newsletter #323][news323 bip85].  The changes broke
  compatibility with deployed versions of the protocol.  Discussion on
  the PR supported creating a new BIP for the major changes.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="7494,7539,3179,8960,1479,2945,1674,26898,27610,27608" %}
[BDK 1.0.0-beta.5]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.5
[news323 bip85]: /en/newsletters/2024/10/04/#bips-1600
[sanders guide]: /en/bitcoin-core-28-wallet-integration-guide/
[gogge corevuln]: https://mailing-list.bitcoindevs.xyz/bitcoindev/2df30c0a-3911-46ed-b8fc-d87528c68465n@googlegroups.com/
[cve-2024-35202 remote crash vulnerability]: https://bitcoincore.org/en/2024/10/08/disclose-blocktxn-crash/
[dos from large inventory sets]: https://bitcoincore.org/en/2024/10/08/disclose-large-inv-to-send/
[slow block propagation attack]: https://bitcoincore.org/en/2024/10/08/disclose-mutated-blocks-hindering-propagation/
[news323 btcd]: /en/newsletters/2024/10/04/#impending-btcd-security-disclosure
[pg btcd]: https://delvingbitcoin.org/t/cve-2024-38365-public-disclosure-btcd-findanddelete-bug/1184
[news323 bcc28]: /en/newsletters/2024/10/04/#bitcoin-core-28-0
[bitcoin inquisition 28.0]: https://github.com/bitcoin-inquisition/bitcoin/releases/tag/v28.0-inq
[review club 30793]: https://bitcoincore.reviews/30793
[gh tdb3]: https://github.com/tdb3
[gh getorphantxs hidden]: https://github.com/bitcoin/bitcoin/blob/a9f6a57b6918b2f92c7d6662e8f5892bf57cc127/src/rpc/mempool.cpp#L1131
[gh commit 142e604]: https://github.com/bitcoin/bitcoin/commit/142e604184e3ab6dcbe02cebcbe08e5623182b81
[news306 blip32]: /en/newsletters/2024/06/07/#blips-32
[news322 customchans]: /en/newsletters/2024/09/27/#lnd-9095
[zkpmusig2]: https://github.com/BlockstreamResearch/secp256k1-zkp