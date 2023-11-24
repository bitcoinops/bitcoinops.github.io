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
  in DNS). {% assign timestamp="1:20" %}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **BitMask Wallet 0.6.3 released:**
  [BitMask][bitmask website] is a web and browser extension-based wallet for Bitcoin,
  Lightning, RGB, and [payjoin][topic payjoin]. {% assign timestamp="17:42" %}

- **Opcode documentation website announced:**
  The [https://opcodeexplained.com/] website was recently [announced][OE tweet]
  and provides explanations of many of Bitcoin's opcodes. The effort is ongoing
  and [contributions are welcome][OE github]. {% assign timestamp="20:08" %}

- **Athena Bitcoin adds Lightning support:**
  The Bitcoin ATM [operator][athena website] recently [announced][athena tweet]
  support for receiving Lightning payments for cash withdrawals. {% assign timestamp="21:42" %}

- **Blixt v0.6.9 released:**
  The [v0.6.9][blixt v0.6.9] release includes support for simple taproot
  channels, defaults to [bech32m][topic bech32] receive addresses, and adds
  additional [zero conf channel][topic zero-conf channels] support. {% assign timestamp="22:22" %}

- **Durabit whitepaper announced:**
  The [Durabit whitepaper][] outlines a protocol using [timelocked][topic
  timelocks] Bitcoin transactions in conjunction with a chaumian-style mint
  to incentivize the seeding of large files. {% assign timestamp="23:07" %}

- **BitStream whitepaper announced:**
  The [BitStream whitepaper][] and [early prototype][bitstream github] layout a
  protocol for the hosting and atomic exchange of digital content for
  coins using timelocks and merkle trees with verification and fraud
  proofs.  For previous discussion of paid data transfer protocols, see
  [Newsletter #53][news53 data]. {% assign timestamp="25:01" %}

- **BitVM proof of concepts:**
  Two proof of concepts building on [BitVM][news273 bitvm] were posted including
  one [implementing][bitvm tweet blake3] the [BLAKE3][] hash function and
  [another][bitvm techmix poc] that [implements][bitvm sha256] SHA256. {% assign timestamp="42:33" %}

- **Bitkit adds taproot send support:**
  [Bitkit][bitkit website], a mobile Bitcoin and Lightning wallet, added
  [taproot][topic taproot] sending support in the [v1.0.0-beta.86][bitkit
  v1.0.0-beta.86] release. {% assign timestamp="55:17" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND v0.17.2-beta][] is a maintenance release that only includes one
  small change to fix the bug reported in [LND #8186][]. {% assign timestamp="55:53" %}

- [Bitcoin Core 26.0rc2][] is a release candidate for the next major
  version of the predominant full-node implementation. There's a [testing
  guide][26.0 testing] available. {% assign timestamp="56:34" %}

- [Core Lightning 23.11rc3][] is a release candidate for the next
  major version of this LN node implementation. {% assign timestamp="57:37" %}

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
  with the [c-lightning-rest][] plugin. {% assign timestamp="58:45" %}

- [Eclair #2752][] allows data in an [offer][topic offers] to reference
  a node using either its public key or the identity of one of its
  channels.  A public key is the typical way to identify a node, but it
  uses 33 bytes.  A channel can be identified using a [BOLT7][] _short
  channel identifier_ (SCID), which only uses 8 bytes. Because channels
  are shared by two nodes, an additional bit is prepended to the SCID to
  specifically identify one of the two nodes.  Because offers may often
  be used in size-constrained media, the space savings are significant. {% assign timestamp="59:42" %}

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
[bitmask website]: https://bitmask.app/
[https://opcodeexplained.com/]: https://opcodeexplained.com/opcodes/
[OE tweet]: https://twitter.com/thunderB__/status/1722301073585475712
[OE github]: https://github.com/thunderbiscuit/opcode-explained
[athena website]: https://athenabitcoin.com/
[athena tweet]: https://twitter.com/btc_penguin/status/1722008223777964375
[blixt v0.6.9]: https://github.com/hsjoberg/blixt-wallet/releases/tag/v0.6.9
[Durabit whitepaper]: https://github.com/4de67a207019fd4d855ef0a188b4519c/Durabit/blob/main/Durabit%20-%20A%20Bitcoin-native%20Incentive%20Mechanism%20for%20Data%20Distribution.pdf
[BitStream whitepaper]: https://robinlinus.com/bitstream.pdf
[bitstream github]: https://github.com/robinlinus/bitstream
[news273 bitvm]: /en/newsletters/2023/10/18/#payments-contingent-on-arbitrary-computation
[bitvm tweet blake3]: https://twitter.com/robin_linus/status/1721969594686926935
[BLAKE3]: https://en.wikipedia.org/wiki/BLAKE_(hash_function)#BLAKE3
[bitvm techmix poc]: https://techmix.github.io/tapleaf-circuits/
[bitvm sha256]: https://raw.githubusercontent.com/TechMiX/tapleaf-circuits/abc38e880872150ceec08a8b67ac2fddaddd06dc/scripts/circuits/bristol_sha256.js
[bitkit website]: https://bitkit.to/
[bitkit v1.0.0-beta.86]: https://github.com/synonymdev/bitkit/releases/tag/v1.0.0-beta.86
[news53 data]: /en/newsletters/2019/07/03/#standardized-atomic-data-delivery-following-ln-payments
