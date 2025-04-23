---
title: 'Bitcoin Optech Newsletter #343'
permalink: /en/newsletters/2025/02/28/
name: 2025-02-28-newsletter
slug: 2025-02-28-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a post about having full nodes ignore
transactions that are relayed without being requested first.  Also
included are our regular sections with popular questions and answers
from the Bitcoin Stack Exchange, announcements of new releases and
release candidates, and summaries of notable changes to popular Bitcoin
infrastructure software.

## News

- **Ignoring unsolicited transactions:** Antoine Riard [posted][riard
  unsol] to Bitcoin-Dev two draft BIPs that would allow a node to signal
  that it will no longer accept `tx` messages that it had not requested
  using an `inv` message, called _unsolicited transactions_.  Riard
  previously proposed the general idea in 2021 (see [Newsletter
  #136][news136 unsol]).   The first proposed BIP adds a mechanism that
  allows nodes to signal their transaction relay capabilities and
  preferences; the second proposed BIP uses that signaling mechanism to
  indicate that the node will ignore unsolicited transactions.

  There are several small advantages to the proposal, as discussed in a
  [Bitcoin Core pull request][bitcoin core #30572], but it conflicts
  with the design of some older lightweight clients and could prevent
  users of that software from being able to broadcast their
  transactions, so a careful deployment might be required.  Although
  Riard had opened the aforementioned pull request, he later closed it
  after indicating that he planned to work on his own full node
  implementation based on libbitcoinkernel.  He also indicated the
  proposal may help address some attacks he recently disclosed (see
  [Newsletter #332][news332 txcen]). {% assign timestamp="0:30" %}

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [What’s the rationale for how the loadtxsoutset RPC is set up?]({{bse}}125627)
  Pieter Wuille explains why [assumeUTXO's][topic assumeUTXO] value for
  representing the UTXO set is hardcoded at a particular block height, ways of
  distributing assumeUTXO snapshots in the future, and the benefits of assumeUTXO
  compared with just copying Bitcoin Core's internal data stores. {% assign timestamp="19:52" %}

- [Are there classes of pinning attacks that RBF rule #3 makes impossible?]({{bse}}125461)
  Murch points out that [RBF][topic rbf] rule #3 is not intended to prevent
  [pinning][topic transaction pinning] attacks and touches on Bitcoin Core's
  [replacement policy][bitcoin core replacements]. {% assign timestamp="23:41" %}

- [Unexpected locktime values]({{bse}}125562)
  User polespinasa lists the different reasons why Bitcoin Core sets specific
  [nLockTime][topic timelocks] values: to `block_height` to avoid [fee
  sniping][topic fee sniping], a random value less than the block height 10% of
  the time for privacy, or 0 if the blockchain is not current. {% assign timestamp="25:38" %}

- [Why is it necessary to reveal a bit in a script path spend and check that it matches the parity of the Y coordinate of Q?]({{bse}}125502)
  Pieter Wuille elaborates on [BIP341's rationale][bip341 rationale] to keep the
  Y coordinate parity check during [taproot][topic taproot] script path spending
  to allow for the potential future addition of batch validation functionality. {% assign timestamp="28:42" %}

- [Why does Bitcoin Core use checkpoints and not the assumevalid block?]({{bse}}125626)
  Pieter Wuille details a history of checkpoints in Bitcoin Core and what
  purpose they served, and points to an open PR and discussion of [removing
  checkpoints][Bitcoin Core #31649]. {% assign timestamp="32:19" %}

- [How does Bitcoin Core handle long reorgs?]({{bse}}105525)
  Pieter Wuille outlines how Bitcoin Core handles blockchain reorgs, commenting
  that one difference in larger reorgs is that "re-adding transactions back to
  the mempool is not performed". {% assign timestamp="36:58" %}

- [What is the definition of discard feerate?]({{bse}}125623)
  Murch defines discard feerate as the maximum feerate for discarding change and
  summarizes the code to calculate the discard feerate as "the 1000-block target
  feerate cropped to 3–10 ṩ/vB if it falls outside of that range". {% assign timestamp="37:59" %}

- [Policy to miniscript compiler]({{bse}}125406)
  Brunoerg notes that the Liana wallet uses the policy language and points to
  both the [sipa/miniscript][miniscript github] and
  [rust-miniscript][rust-miniscript github] libraries as examples of policy compilers. {% assign timestamp="40:37" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Core Lightning 25.02rc3][] is a release candidate for the next major
  version of this popular LN node. {% assign timestamp="43:01" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Core Lightning #8116][] changes the handling of interrupted channel closing
  negotiations to retry the process even if it’s not needed. This fixes an issue
  where a node missing the `CLOSING_SIGNED` message from its peer gets an error
  when reconnecting and broadcasts a unilateral close transaction. Meanwhile,
  the peer, already in the `CLOSINGD_COMPLETE` state, has broadcast the mutual
  close transaction, potentially leading to a race between the two transactions.
  This fix allows renegotiation to continue until the mutual close transaction
  is confirmed. {% assign timestamp="43:34" %}

- [Core Lightning #8095][] adds a `transient` flag to the `setconfig` command
  (see Newsletter [#257][news257 setconfig]), introducing dynamic configuration
  variables that are applied temporarily without modifying the configuration
  file. These changes are reverted upon restart. {% assign timestamp="46:06" %}

- [Core Lightning #7772][] adds a `commitment_revocation` hook to the
  `chanbackup` plugin that updates the `emergency.recover` file (see Newsletter
  [#324][news324 emergency]) whenever a new revocation secret is received. This
  enables users to broadcast a penalty transaction when sweeping funds using
  `emergency.recover` if the peer has published an outdated revoked state. This
  PR extends the [static channel backup][topic static channel backups] SCB
  format and updates the `chanbackup` plugin to serialize both the new and
  legacy formats. {% assign timestamp="47:53" %}

- [Core Lightning #8094][] introduces a runtime-configurable `xpay-slow-mode`
  variable to the `xpay` plugin (see Newsletter [#330][news330 xpay]), which
  delays the return of success or failure until all parts of a [multipath
  payments][topic multipath payments] (MPP) are resolved. Without this setting,
  a failure status could be returned even if some [HTLCs][topic htlc] are still
  pending. If a user retries and successfully pays the invoice from another
  node, an overpayment could occur if the pending HTLC is also settled. {% assign timestamp="48:31" %}

- [Eclair #2993][] enables the recipient to pay for fees associated with the
  [blinded][topic rv routing] portion of a payment path, while the sender covers
  fees for the non-blinded portion.  Previously, the sender paid all fees, which
  could allow them to infer and potentially unblind the path. {% assign timestamp="51:38" %}

- [LND #9491][] adds support for cooperative channel closures when there are
  active [HTLCs][topic htlc] using the `lncli closechannel` command. When
  initiated, LND will halt the channel to prevent the creation of new HTLCs and
  wait for all existing HTLCs to be resolved before starting the negotiation
  process. Users must set the `no_wait` parameter to enable this behavior;
  otherwise, an error message will prompt them to specify it. This PR also
  ensures that the `max_fee_rate` setting is enforced for both parties when a
  cooperative channel closure is initiated; previously, it was only applied to
  the remote party. {% assign timestamp="53:14" %}

{% include snippets/recap-ad.md when="2025-03-04 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30572,8116,8095,7772,8094,2993,9491,31649" %}
[riard unsol]: https://mailing-list.bitcoindevs.xyz/bitcoindev/e98ec3a3-b88b-4616-8f46-58353703d206n@googlegroups.com/
[news136 unsol]: /en/newsletters/2021/02/17/#proposal-to-stop-processing-unsolicited-transactions
[news332 txcen]: /en/newsletters/2024/12/06/#transaction-censorship-vulnerability
[Core Lightning 25.02rc3]: https://github.com/ElementsProject/lightning/releases/tag/v25.02rc3
[news257 setconfig]: /en/newsletters/2023/06/28/#core-lightning-6303
[news324 emergency]: /en/newsletters/2024/10/11/#core-lightning-7539
[news330 xpay]: /en/newsletters/2024/11/22/#core-lightning-7799
[bitcoin core replacements]: https://github.com/bitcoin/bitcoin/blob/master/doc/policy/mempool-replacements.md#current-replace-by-fee-policy
[bip341 rationale]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#cite_note-10
[miniscript github]: https://github.com/sipa/miniscript
[rust-miniscript github]: https://github.com/rust-bitcoin/rust-miniscript
