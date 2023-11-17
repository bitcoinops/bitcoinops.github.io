---
title: 'Bitcoin Optech Newsletter #278'
permalink: /en/newsletters/2023/11/22/
name: 2023-11-22-newsletter
slug: 2023-11-22-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal to allow retrieval of LN
offers using specific DNS addresses similar to lightning addresses.
Also included are our regular sections summarizing changes to services
and client software, announcing new releases and release candidates, and
describing notable changes to popular Bitcoin infrastructure software.

## News

- **Offers-compatible LN addresses:** Bastien Teinturier
  [posted][teinturier addy] to the Lightning-Dev mailing list about
  creating email-style addresses for LN users in a way that takes
  advantage of the features of the [offers protocol][topic offers].  For
  context, a popular [lightning address][] standard exists based on
  [LNURL][], which requires operating an always-available HTTP server to
  associate email-style addresses with LN invoices.  Teinturier notes
  that this creates several problems:

    - _Lack of privacy:_ the server operator likely learns the IP
      address of the spender and the receiver.

    - _Risk of theft:_ the server operator can man-in-the-middle
      invoices to steal funds.

    - _Infrastructure and dependencies:_ the server operator must setup
      DNS and HTTPS hosting, and the spender software must be able to
      use DNS and HTTPS.

  Teinturier offers three proposed designs based on offers:

    - _Linking domains to nodes:_ a DNS record maps a domain (e.g.
      example.com) to an LN node identifier.  The spender sends an
      [onion message][topic onion messages] to that node requesting an
      offer for the ultimate receiver (e.g. alice@example.com).  The
      domain node replies with an offer signed by its node key, allowing
      the spender to later prove fraud if it provided an offer that
      wasn't from Alice.  The spender can now use the offer protocol to
      request an invoice from Alice.  The spender can also associate
      alice@example.com with the offer, so it doesn't need to contact
      the domain node for future payments to Alice.  Teinturier notes
      that this design is extremely simple.

    - _Certificates in node announcements:_ the existing mechanism an LN
      node uses to advertise itself to the network is modified to allow
      an advertisement to contain an SSL certificate chain proving that
      (according to a certificate authority) the owner of example.com
      claimed this particular node is controlled by alice@example.com.
      Teinturier notes that this would require LN implementations to
      implement SSL-compatible cryptography.

    - _Store offers directly in DNS:_ a domain may have multiple DNS
      records that directly store offers for particular addresses.  For
      example, a DNS `TXT` record, `alice._lnaddress.domain.com`,
      includes an offer for Alice.  Another record,
      `bob._lnaddress.domain.com` includes an offer for Bob.  Teinturier
      notes that this requires the domain owner create one DNS record
      per user (and update that record if the user needs to change their
      default offer).

  The email spurred an active discussion.  One notable suggestion was
  possibly allowing both the first and third suggestions to be used (the
  suggestions for linking domains to nodes and storing offers directly
  in DNS).

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND v0.17.2-beta][] is a maintenance release that only includes one
  small change to fix the bug reported in [LND #8186][].

- [Bitcoin Core 26.0rc2][] is a release candidate for the next major
  version of the predominant full-node implementation. There's a [testing
  guide][26.0 testing] available.

- [Core Lightning 23.11rc3][] is a release candidate for the next
  major version of this LN node implementation.

## Notable code and documentation changes

*Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Core Lightning #6857][] updates the names of several configuration
  options used for the REST interface to prevent them from conflicting
  with the [c-lightning-rest][] plugin.

- [Eclair #2752][] allows data in an [offer][topic offers] to reference
  a node using either its public key or the identity of one of its
  channels.  A public key is the typical way to identify a node, but it
  uses 33 bytes.  A channel can be identified using a [BOLT7][] _short
  channel identifier_ (SCID), which only uses 8 bytes. Because channels
  are shared by two nodes, an additional bit is prepended to the SCID to
  specifically identify one of the two nodes.  Because offers may often
  be used in size-constrained media, the space savings are significant.

{% include snippets/recap-ad.md when="2023-11-22 15:00" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="6857,2752,8186" %}
[bitcoin core 26.0rc2]: https://bitcoincore.org/bin/bitcoin-core-26.0/
[26.0 testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/26.0-Release-Candidate-Testing-Guide
[core lightning 23.11rc3]: https://github.com/ElementsProject/lightning/releases/tag/v23.11rc3
[c-lightning-rest]: https://github.com/Ride-The-Lightning/c-lightning-REST
[teinturier addy]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2023-November/004204.html
[lnurl]: https://github.com/fiatjaf/lnurl-rfc
[lightning address]: https://lightningaddress.com/
[lnd v0.17.2-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.2-beta
