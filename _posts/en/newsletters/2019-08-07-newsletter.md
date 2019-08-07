---
title: 'Bitcoin Optech Newsletter #58'
permalink: /en/newsletters/2019/08/07/
name: 2019-08-07-newsletter
slug: 2019-08-07-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the maintenance release of Bitcoin Core
0.18.1, summarizes a discussion about BIP174 extensions, and notes a
proposal for LN trampoline payments.  Our *bech32 sending support*
section this week features a special case study contributed by BRD and
our *notable changes* section highlights several possibly significant
developments.

{% comment %}<!-- include references.md below the fold but above any Jekyll/Liquid variables-->{% endcomment %}
{% include references.md %}

## Action items

- **Upgrade to Bitcoin Core 0.18.1 when binaries are released:** this
  maintenance release has [been tagged][bitcoin core 0.18.1 tag], and binaries
  are expected to be uploaded to [bitcoincore.org][bitcoin core 0.18.1 binaries]
  in the next few days. The release makes available several bug fixes and other
  improvements.  Upgrading is recommended when the binaries are available.

## News

- **BIP174 extensibility:** the author of the Partially-Signed Bitcoin
  Transactions (PSBTs) specification, Andrew Chow, [proposed][psbt
  extensions] a few minor changes for general adoption:

    - *Reserved types for proprietary use:* some applications are
      already including data in PSBTs using types that aren't specified
      in [BIP174][].  It's proposed that one type byte or a range of
      type bytes be reserved for private PSBT extensions, similar to
      reserved IP address ranges for private networks.  The exact
      construction of this mechanism was a particular focus of
      discussion this week.

    - *Global version number:* although the goal is to design enhancements
      to PSBTs so that they're backwards compatible, Chow proposed to
      add a version byte to PSBTs indicating the most advanced feature
      they use so that older parsers can detect when they're being given
      a PSBT they might not understand.  PSBTs without an explicit
      version number would be considered to use version 0.

    - *Multi-byte types:* To allow more types, multi-byte types are
      proposed.  Mailing list discussion seems to favor using the same
      CompactSize unsigned integers used in the Bitcoin protocol.

- **Trampoline payments:** Bastien Teinturier opened a [PR][trampoline
  pr] in the BOLTs repository and started a [discussion][trampoline
  discussion] on the Lightning-Dev mailing list about adding support to
  the protocol for the trampoline payments described in [Newsletter
  #40][news40 trampoline payments] where the spender sends the payment
  to an intermediate node who calculates the path either to another
  intermediate node (for privacy) or to the receiving node.  This can be
  very beneficial to low-bandwidth LN clients (such as on mobile
  devices) that don't want to keep up with gossip traffic and so only
  know how to route to a small number of nodes.  Sending a trampoline
  payment will require coordination between multiple nodes, so it
  should be documented in the Lightning specification.

## Bech32 sending support

*Week 21 of 24 in a [series][bech32 series] about allowing the people
you pay to access all of segwit's benefits.*

{% include specials/bech32/21-brd.md %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #15911][] changes the `walletcreatefundedpsbt` to signal
  [BIP125][] Replace-by-Fee (RBF) if the wallet is configured to use RBF
  (the configuration option `walletrbf`).

- [Bitcoin Core #16394][] changes the `createwallet` RPC so that if an
  empty string is passed for the passphrase parameter, an unencrypted
  wallet will be created (and a warning printed).

- [LND #3184][] adds a watchtower client sub-server to LND that replaces
  the private watchtower implementation added for the most recent
  release.

- [LND #3164][] creates a new database into which information about the
  past 1,000 payments is stored.  (The default of 1,000 can be changed.)
  This is meant for use with LND's Mission Control feature that
  tries to better use information from past payment attempts (especially
  failures) to choose better routes for subsequent payment attempts.
  During the first upgrade to a version including this change, details about previous payments will be populated into
  this database from LND's lower-level HTLC-tracking database.

- [LND #3359][] adds an `ignore-historical-filters` configuration option
  that will cause LND to ignore a `gossip_timestamp_filter` sent from
  a peer.  That filter allowed peers to request all announcements that would've
  been gossiped during an earlier date range.  By ignoring requests for
  the filter, LND uses less memory and bandwidth.
  The ignore option currently defaults to False, so there's no
  change in default LND behavior, but a commit comment notes "down the
  road, the plan is to make this default to True."

- [C-Lightning #2771][] allows plugins to indicate whether or not they
  can be started and stopped during runtime rather than just being
  started on init and stopped on shutdown.  This information is used by
  a new `plugin` command that allows users to perform these runtime
  stops and starts.

- [C-Lightning #2892][] now always runs plugins from the Lightning
  configuration directory, reducing inconsistencies between different
  installs and making it easy for plugins to store and access data
  within that directory.

- [C-Lightning #2799][] provides a new `forward_event`
  notification for plugins that alerts when an HTLC has been offered,
  settled, failed by both parties, or failed locally (unilaterally).
  Additionally, the PR extends the `listforwards` RPC with a
  `payment_hash` field to allow the user to find additional information
  about the HTLC.

- [C-Lightning #2885][] spaces out reconnections to channel peers on
  startup in order to reduce the chance that a traffic flood causes
  C-Lightning to take more than 30 seconds to re-establish a channel
  after connecting to a peer.  This was the problem that was causing LND
  to send sync error messages as described in [last week's
  newsletter][news57 sync error].

- [BOLTs #619][] adds support for variable-sized payloads in
  LN onion routing.  Combined with Type-Length-Value (TLV) encoded
  fields, which was merged into the specification three weeks ago (see
  [Newsletter #55][tlv merge]), this makes it much easier to place
  extra data into the encrypted packets that relay payments, enabling
  the addition of several features (including the trampoline payments
  discussed earlier in this week's newsletter).

{% include linkers/issues.md issues="15911,16394,3184,3164,3359,2892,2799,2885,2771,619" %}
[bech32 series]: /en/bech32-sending-support/
[bitcoin core 0.18.1 tag]: https://github.com/bitcoin/bitcoin/releases/tag/v0.18.1
[bitcoin core 0.18.1 binaries]: https://bitcoincore.org/bin/bitcoin-core-0.18.1/
[news40 trampoline payments]: {{news40}}#trampoline-payments-for-ln
[news57 sync error]: {{news57}}#c-lightning-2842
[psbt extensions]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-July/017188.html
[trampoline pr]: https://github.com/lightningnetwork/lightning-rfc/pull/654
[trampoline discussion]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-August/002100.html
[tlv merge]: {{news55}}#bolts-607
