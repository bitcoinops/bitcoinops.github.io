---
title: 'Bitcoin Optech Newsletter #170'
permalink: /en/newsletters/2021/10/13/
name: 2021-10-13-newsletter
slug: 2021-10-13-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a vulnerability recently fixed in
several LN implementations and summarizes a proposal providing multiple
benefits for upgrading the LN protocol to take advantage of features in
taproot.  Also included are our regular sections with the summary of a
recent Bitcoin Core PR Review Club meeting, information about preparing for
taproot, listings of new software releases and release candidates, and
descriptions of notable changes to popular Bitcoin infrastructure
software.

## News

- **LN spend to fees CVE:** last week, Antoine Riard [posted][riard cve]
  the announcement of CVEs for multiple programs to the Lightning-Dev
  mailing list.  Bitcoin users have always been discouraged from
  creating [uneconomical outputs][topic uneconomical outputs] that would
  cost a significant portion of their value to spend.  However, LN
  allows users to send small amounts that would be uneconomical onchain.
  In those cases, the paying or routing node overpays the miner fee for
  the commitment transaction by the small amount, effectively donating
  the money to miners if the commitment transaction gets published
  (which, in most cases, shouldn't happen).

    As reported by Riard, LN implementations allowed setting their
    uneconomical limit to 20% or more of a channel's value, so five
    or fewer payments could spend all of a channel's value to miner
    donations.  Losing value to miners is a fundamental risk of the
    small-payments mechanism used in LN, but risking losing all of a
    channel's value in just five payments was apparently considered
    excessive.

    Several mitigations are described in Riard's email, including having
    LN nodes simply refuse to route payments that would risk donating
    more than a certain amount of their funds to miner fees.
    Implementing this may decrease the ability of nodes to
    simultaneously route more than a few small payments that are
    uneconomical onchain, although it's unclear whether it will cause any
    problems in practice.  All affected LN implementations tracked by
    Optech have released, or soon will release, a version implementing
    at least one of the proposed mitigations.

- **Multiple proposed LN improvements:** Anthony Towns [posted][towns
  proposal] to the Lightning-Dev mailing list a detailed proposal, with
  some example code, describing how to reduce payment latency, improve
  backup resiliency, and allow receiving LN payments while signing keys
  are offline.  The proposal provides some of the same benefits of
  [eltoo][topic eltoo] but without requiring the
  [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] soft fork or any other
  consensus changes beyond the taproot soft fork that will activate at
  block height {{site.trb}}.  As such, it could be deployed as soon as
  it was implemented and tested by LN developers.  Looking at the major
  features:

    - **Reduced payment latency:** some details necessary to process a
      payment but not specific to the details of the payment can be
      exchanged by channel partners in advance, allowing a node to
      initiate or route a payment by simply sending the payment and
      a signature for the payment to the channel partner.  No round-trip
      communication is required on the critical path, allowing payments
      to propagate across the network at close to the speed of the
      underlying links between LN nodes.  Refunding a payment in case of
      failure would be slower, but not slower than before this change.
      This feature is an extension of ideas previously proposed by
      developer ZmnSCPxj (see [Newsletter #152][news152 ff]), who also
      [wrote][zmnscpxj name drop] a related post this week based on some
      of his out of band discussions with Towns.

    - **Improved backup resiliency:** currently LN requires both channel
      parties and any [watchtowers][topic watchtowers] they use to store
      information about every prior state of the channel in case of attempted
      theft.  Towns's proposal uses deterministic derivation for most
      information about channel state and encodes a state number in
      each transaction to allow recovering the necessary information
      (with some small amount of brute force grinding required in some
      cases).  This allows a node to backup all of the key-related
      information it needs at the time a channel is created.  Any other
      required information should be obtainable from either the block
      chain (in case of a theft attempt) or from the channel
      partner (in the case a node loses its own data).

    - **Receiving payments with an offline key:** an online (hot) key is
      fundamentally required to send or route a payment in LN, but the
      current protocol also requires an online key in order to receive a
      payment.  Based on an adaptation of ZmnSCPxj's previously
      mentioned idea by Lloyd Fournier (also covered in [Newsletter
      #152][news152 ff]), it would be possible for a receiving node to
      only need to bring its keys online in order to open a channel,
      close a channel, or rebalance its channels.  This could
      improve the security of merchant nodes.

    The proposal would also provide the [better known][zmnscpxj taproot ln]
    privacy and efficiency advantages of upgrading LN to use taproot and
    [PTLCs][topic ptlc].  The idea was well discussed on the mailing
    list, with discussion ongoing at the time of writing.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

FIXME is a PR by FIXME to FIXME.  The review club FIXME:glozow

{% include functions/details-list.md

  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/FIXME#l-FIXME"

%}

## Preparing for taproot #17: is cooperation always an option?

*A weekly [series][series preparing for taproot] about how developers
and service providers can prepare for the upcoming activation of taproot
at block height {{site.trb}}.*

{% include specials/taproot/en/17-keypath-universality.md %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Eclair 0.6.2][] in a new release that includes a fix for
  the vulnerability described in the *news* section above as well new
  features and other bug fixes described in its [release notes][eclair
  rn].

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], and
[Lightning BOLTs][bolts repo].*

- [Bitcoin Core #20487][] adds a `-sandbox` configuration option that
  can be used to enable an experimental system call (syscall) sandbox.
  When the sandbox is active, the kernel will terminate Bitcoin Core if
  it makes any syscalls other than those on a per-process whitelist.  The
  mode is currently only available on x86_64 and is mainly meant for
  testing what syscalls are being used by particular threads.

- [Bitcoin Core #17211][] Allow fundrawtransaction and walletcreatefundedpsbt to take external inputs FIXME:jnewbery

- [Bitcoin Core #22340][] p2p: Use legacy relaying to download blocks in blocks-only mode FIXME:adamjonas

- [Bitcoin Core #23123][] removes the `-rescan` startup option.  Users
  can instead use the `rescan` RPC.

- [Eclair #1980][] will accept commitment transactions created with any
  feerate above the local full node's dynamic minimum relay fee when
  [anchor outputs][topic anchor outputs] are being used.

- [LND #5363][] allows skipping the PSBT finalization step within LND,
  allowing PSBTs to be finalized and broadcast using other software.
  This can lead to funds loss if the transaction's txid is accidentally
  changed, but it does allow alternative workflows.

- [LND #5642][] in-memory graph cache for faster pathfinding FIXME:dongcarl

- [LND #5770][] provides more information to LND's subsystems about
  uneconomical outputs in order to allow implementing mitigations for
  the LN CVE described in the *news* section above.

{% include references.md %}
{% include linkers/issues.md issues="20487,17211,22340,23123,1980,5363,5642,5770" %}
[riard cve]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-October/003257.html
[zmnscpxj name drop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-October/003265.html
[news152 ff]: /en/newsletters/2021/06/09/#receiving-ln-payments-with-a-mostly-offline-private-key
[towns proposal]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-October/003278.html
[zmnscpxj taproot ln]: /en/preparing-for-taproot/#ln-with-taproot
[eclair 0.6.2]: https://github.com/ACINQ/eclair/releases/tag/v0.6.2
[eclair rn]: https://github.com/ACINQ/eclair/blob/master/docs/release-notes/eclair-v0.6.2.md
