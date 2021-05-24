---
title: 'Bitcoin Optech Newsletter #12'
permalink: /en/newsletters/2018/09/11/
name: 2018-09-11-newsletter
slug: 2018-09-11-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter references a discussion about BIP151 encryption
for the peer-to-peer network protocol, provides an update on
compatibility between Bitcoin and the W3C Web Payments draft
specification, and briefly describes some notable merges in popular
Bitcoin infrastructure projects.

## Action items

- **Allocate time to test Bitcoin Core 0.17RC3:** Bitcoin Core has
  uploaded [binaries][bcc 0.17] for 0.17 Release Candidate (RC) 3.
  Testing is greatly appreciated and can help ensure the quality of the
  final release.

- Plans for the second Optech [workshop][workshop] are progressing,
  with date and location confirmed for Paris on November 12th/13th. The
  tentative list of topics is:
    - Replace-by-fee vs. child-pays-for-parent as fee replacement techniques
    - Partially Signed Bitcoin Transactions (BIP 174)
    - Output script descriptors for wallet interoperability (gist)
    - Lightning wallet integration and applications for exchanges
    - Approaches to coin selection & consolidation

  **Member companies who would like to send engineers to the workshop should
  [email Optech][optech email]**.

## News

- **BIP151 discussion:** as mentioned in [Newsletter #10][news10 news],
  Jonas Schnelli has [proposed][schnelli bip151] an updated draft of
  [BIP151][] encryption for the peer-to-peer network protocol.
  Cryptographer Tim Ruffing provided [constructive criticism][ruffing
  bip151] of the draft on the Bitcoin-Dev mailing list this week that
  received also-constructive rebuttals from Schnelli and Gregory
  Maxwell.  These posts may be interesting reads for anyone wondering
  why certain cryptographic choices were made in the protocol, such as
  the use of the NewHope quantum-computing resistant key exchange.

- **W3C Web Payments Working Group update:** Lightning Network developer
  Christian Decker is a member of this group attempting to create
  standards for web-based payments.  In a [reply][decker w3c] sent to
  the Lightning-Dev mailing list, Decker explains why he thinks the
  current draft specification will be fundamentally compatible with both
  payments to Bitcoin addresses and Lightning Network payments.  The
  draft even explicitly allocates the XBT currency code to Bitcoin.

## Notable commits

*Notable commits this week in [Bitcoin Core][core commits], [LND][lnd
commits], and [C-lightning][cl commits].  Reminder: new merges to
Bitcoin Core are made to its master development branch and are unlikely
to become part of the upcoming 0.17 release---you'll probably have to
wait until version 0.18 in about six months from now.*

{% include linkers/github-log.md
  refname="core commits"
  repo="bitcoin/bitcoin"
  start="68f3c7eb080e461cfeac37f8db7034fe507241d0"
  end="cb25cd6aa18c69918176d68e36e26f7e373aa48c"
%}
{% include linkers/github-log.md
  refname="lnd commits"
  repo="lightningnetwork/lnd"
  start="2b448be048daf85cef4cbb37ceed4413fdb051e6"
  end="1941353fb28755a170793e43595601d75c8f3dda"
%}
{% include linkers/github-log.md
  refname="cl commits"
  repo="ElementsProject/lightning"
  start="77d3ca3ea3ba607e0b08c7921c41bfc0a9658ed2"
  end="634f19a7b230edc686be56ab950b80784e56252c"
%}

- [Bitcoin Core #12775][] adds support for RapidCheck (a [QuickCheck][]
  reimplementation) to Bitcoin Core, providing a property-based testing suite
  that generates its own tests based on what programmers tell it are the
  properties of a function (e.g. what it accepts as input and returns
  as output).

- [Bitcoin Core #12490][] removes the `signrawtransaction` RPC from the
  master development branch.  This RPC is labeled as deprecated in the
  upcoming 0.17 release and users are encouraged to use the
  `signrawtransactionwithkey` RPC when they are providing their own
  private key for signing or the `signrawtransactionwithwallet` RPC when
  they want the built-in wallet to automatically provide the private key.

- [Bitcoin Core #14096][] provides [documentation for output script
  descriptors][] which are used in the new `scantxoutset` RPC in Bitcoin
  Core 0.17 and are expected to be used for other interactions with the
  wallet in the future.

- **LND** made almost 30 merges in the past week, many of which made
  small enhancements or bugfixes to its autopilot facility---its ability
  to allow users to choose to automatically open new channels with
  automatically-selected peers.  Several merges also updated which
  versions of libraries LND depends upon.

- [C-Lightning #1899][] added several hundred lines of documentation to its
  repository this week, most of it inline code documentation or updates
  to files in its [/doc directory][c-lightning docs].

{% include references.md %}
{% include linkers/issues.md issues="12775,12490,14096,1899" %}

[bcc 0.17]: https://bitcoincore.org/bin/bitcoin-core-0.17.0/
[workshop]: /workshops
[documentation for output script descriptors]: https://github.com/bitcoin/bitcoin/blob/master/doc/descriptors.md
[news10 news]: {{news10}}#news
[decker w3c]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-August/001404.html
[schnelli bip151]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-September/016355.html
[ruffing bip151]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-September/016372.html
[quickcheck]: https://en.wikipedia.org/wiki/QuickCheck
[c-lightning docs]: https://github.com/ElementsProject/lightning/tree/master/doc

