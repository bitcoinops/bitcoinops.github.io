---
title: 'Bitcoin Optech Newsletter #249'
permalink: /en/newsletters/2023/05/03/
name: 2023-05-03-newsletter
slug: 2023-05-03-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes an analysis of using a flexible
covenant design to reimplement the `OP_VAULT` proposal, summarizes a
post about signature adaptor security, and relays a job announcement
that may be particularly interesting to some readers.  Also included are
our regular sections describing new releases, release candidates, and
notable changes to popular Bitcoin infrastructure software.

## News

- **MATT-based vaults:** Salvatore Ingala [posted][ingala vaults] to the
  Bitcoin-Dev mailing list a rough implementation of a [vault][topic
  vaults] with similar behavior to the recent OP_VAULT proposals (see
  [Newsletter #234][news234 op_vault]) but which is instead based on
  Ingala's Merklize All The Things (MATT) proposal (see [Newsletter
  #226][news226 matt]).  MATT would allow the creation of very flexible
  contracts on Bitcoin through the soft fork addition of a few very
  simple [covenant][topic covenants] opcodes.

    In this week's post, Ingala sought to demonstrate that MATT would not
    only be very flexible, but that it would also be efficient and easy
    to use in transaction templates that might one day see frequent use.
    As is done in recent versions of the `OP_VAULT` proposal, Ingala builds
    upon the [BIP119][] proposal for [OP_CHECKTEMPLATEVERIFY][topic
    op_checktemplateverify] (CTV).  Using two additional proposed
    opcodes (and acknowledging that they don't entirely cover everything
    necessary), he provides a set of features that is almost equivalent
    to `OP_VAULT`.  It's only notable omission is "an option to add an
    additional output that is sent back to the same exact vault."

    As of this writing, Ingala's post had not received any direct
    replies, but there was [continued discussion][halseth matt] about
    his original proposal for MATT and it's ability to allow
    verification that an (essentially) arbitrarily complex program was
    run. {% assign timestamp="12:29" %}

- **Analysis of signature adaptor security:** Adam Gibson
  [posted][gibson adaptors] to the Bitcoin-Dev mailing list an analysis
  of the security of [signature adaptors][topic adaptor signatures],
  especially about how they interact with [multisignature][topic
  multisignature] protocols such as [MuSig][topic musig] where multiple
  parties need to trustlessly work together to create adaptors.
  Signature adaptors are planned for use in upgrading LN in the
  near-term to use [PTLCs][topic ptlc] for improved efficiency and
  privacy.  They're also envisioned for use in a number of other
  protocols, again mainly to improve efficiency, privacy, or both.  They
  represent one of the most powerful building blocks for new and
  upgraded Bitcoin protocols, so careful analysis of their security
  properties is essential to ensure they are used correctly.  Gibson
  builds on the previous analysis of Lloyd Fournier and others (see
  [Newsletter #129][news129 adaptors]), but he also notes areas that
  need further analysis and seeks review of his own contributions. {% assign timestamp="33:40" %}

- **Job opportunity for project champions:** Steve Lee of the Spiral
  grant-giving organization [posted][lee hiring] to the Bitcoin-Dev
  mailing list with a request for highly experienced Bitcoin
  contributors to apply for a paid full-time position championing
  cross-team projects that will provide significant improvements to
  Bitcoin's long-term scalabality, security, privacy, and flexibility.
  See his post for details. {% assign timestamp="1:17" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND v0.16.2-beta][] is a minor release of this LN implementation that
  includes several bug fixes for "performance regressions introduced in
  the prior minor release". {% assign timestamp="56:25" %}

- [Core Lightning 23.05rc2][] is a release candidate for the next
  version of this LN implementation. {% assign timestamp="57:20" %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #25158][] adds an `abandoned` field to the transaction detail
  responses from the `gettransaction`, `listtransactions`, and `listsinceblock` RPCs
  indicating which transactions have been marked [abandoned][abandontransaction rpc]. {% assign timestamp="58:17" %}

- [Bitcoin Core #26933][] reintroduces the requirement that each
  transaction meet the node's minimum relay feerate (`-minrelaytxfee`)
  in order to be accepted to the mempool, even when being evaluated as a
  package. Package validation still allows bumping a transaction below
  the dynamic mempool minimum feerate. This policy was reintroduced to
  avoid the risk of zero-fee transactions losing their fee-bumping
  descendant in the event of a replacement. It may reversed in the
  future if a DoS-resistant method of preventing such transactions is
  found, e.g. through a package topology restriction like v3 or a
  modification to the mempool's eviction process. {% assign timestamp="1:00:23" %}

- [Bitcoin Core #25325][] introduces a pool based memory resource for
  the UTXO cache. The new data structure pre-allocates and manages a
  larger pool of memory to track UTXOs instead of allocating and freeing
  memory for each UTXO individually. UTXO lookups represent a major proportion of
  memory accesses, especially during IBD. Benchmarks indicate that
  reindexing is sped up by over 20% by the more efficient memory
  management. {% assign timestamp="1:04:24" %}

- [Bitcoin Core #25939][] allows nodes with the optional transaction
  index enabled to search that index when using the `utxoupdatepsbt` RPC
  to update a [PSBT][topic psbt] with information about the transaction outputs it
  spends.  When the RPC was first implemented in 2019 (see [Newsletter
  #34][news34 psbt]), two types of outputs were common on the network:
  legacy outputs and segwit v0 outputs.  Each spend of a legacy output
  in a PSBT needs to include a full copy of the transaction which
  contained that output so that a signer can verify the amount of that
  output.  Creating a spend without verifying the amount of the output
  being spent can lead to the spender massively overpaying transaction
  fees, so verification is important.

  Each spend of a segwit v0 output commits to its amount in an attempt
  to allow PSBTs to include only the output's scriptPubKey and amount
  rather than the entire previous transaction.  It was believed that
  this would eliminate the need to include the entire transaction.
  Since every unspent transaction output for every confirmed transaction
  is stored in Bitcoin Core's UTXO set, the `utxoupdatepsbt` RPC can add
  the necessary scriptPubKey and amount data to any PSBT spending a
  UTXO.  The `utxoupdatepsbt` also previously searched the local node's
  mempool for UTXOs to allow users to spend outputs from unconfirmed
  transactions.

  However, after `utxoupdatepsbt` was added to Bitcoin Core, several
  hardware signing devices began requiring even spends of segwit v0
  outputs to include full transactions in order to prevent a variation
  of fee overpayment that could result from a user seemingly signing the
  same transaction twice (see [Newsletter #101][news101 overpayment]).
  That increased the need to be able to include full transactions in a
  PSBT.

  This merged PR will search the transaction index (if enabled) and the
  local node's mempool for full transactions, and will include them in
  the PSBT if required.  If a full transaction is not found, the UTXO
  set will be used for spends of segwit outputs.  Note that Taproot
  (segwit v1) eliminates the overpayment concern for most transactions
  that spend at least one taproot output, so we expect to see future
  updates of hardware signing devices cease requiring full transactions
  in that case. {% assign timestamp="1:07:18" %}

- [LDK #2222][] allows updating information about a channel using a
  message gossiped by the nodes involved in that channel without
  verifying the channel corresponds to a UTXO.  LN Gossip messages should
  only be accepted if they belong to a channel with a proven UTXO as that's
  one of the ways that LN is designed to prevent denial-of-service
  (DoS) attacks, but some LN nodes won't have the capability to look up
  UTXOs and may have other methods for preventing DoS attacks.  This
  merged PR makes it easier for them to use information without a source
  for UTXO data. {% assign timestamp="1:12:31" %}

- [LDK #2208][] adds transaction rebroadcasting and fee bumping of
  unresolved [HTLCs][topic htlc] in channels that have been forced
  closed.  This helps address some [pinning attacks][topic transaction
  pinning] and ensures reliability.  See also [Newsletter #243][news243
  rebroadcast] where LND added its own rebroadcasting interface and
  [last week's newsletter][news247 rebroadcast] where CLN improved its
  own logic. {% assign timestamp="1:15:39" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="25158,26933,25325,2222,2208,25939" %}
[Core Lightning 23.05rc2]: https://github.com/ElementsProject/lightning/releases/tag/v23.05rc2
[lnd v0.16.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.2-beta
[news101 overpayment]: /en/newsletters/2020/06/10/#fee-overpayment-attack-on-multi-input-segwit-transactions
[news129 adaptors]: /en/newsletters/2020/12/23/#ptlcs
[news243 rebroadcast]: /en/newsletters/2023/03/22/#lnd-7448
[news247 rebroadcast]: /en/newsletters/2023/04/19/#core-lightning-6120
[ingala vaults]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021588.html
[news226 matt]: /en/newsletters/2022/11/16/#general-smart-contracts-in-bitcoin-via-covenants
[news234 op_vault]: /en/newsletters/2023/01/18/#proposal-for-new-vault-specific-opcodes
[halseth matt]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021593.html
[gibson adaptors]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021594.html
[lee hiring]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-April/021589.html
[news34 psbt]: /en/newsletters/2019/02/19/#bitcoin-core-13932
[abandontransaction rpc]: https://developer.bitcoin.org/reference/rpc/abandontransaction.html
