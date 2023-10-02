---
title: 'Bitcoin Optech Newsletter #210'
permalink: /en/newsletters/2022/07/27/
name: 2022-07-27-newsletter
slug: 2022-07-27-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposed BIP for creating signed
messages for non-legacy addresses and summarizes a discussion about
provably burning small amounts of bitcoin for denial of service
protection.  Also included are our regular sections with popular
questions and answers from the Bitcoin Stack Exchange, announcements of
new releases and releases candidates, and summaries of notable changes
to popular Bitcoin infrastructure software.

## News

- **Multiformat single-sig message signing:** Bitcoin Core and many
  other wallets have long included support for signing and verifying
  arbitrary messages when the key used to sign them corresponds to a
  P2PKH address.  Bitcoin Core doesn't support signing or verifying
  arbitrary messages for any other address type, including addresses
  covering single-sig P2SH-P2WPKH, native P2WPKH, and P2TR outputs.  A
  previous proposal, [BIP322][], to provide [fully generic message
  signing][topic generic signmessage] that could work with any script
  has not yet [been merged][bitcoin core #24058] into Bitcoin Core or
  added to any other popular wallet of which we're aware.

    This week, Ali Sherief [proposed][sherief gsm] that the same message
    signing algorithm used for P2WPKH also be used for other output
    types.  For verification, programs should infer how to derive the
    key (if necessary) and verify the signature using the address type.
    E.g., when provided a [bech32][topic bech32] address with a 20 byte
    data element, assume it's for a P2WPKH output.

    Developer Peter Gray [noted][gray cc] that ColdCard
    wallets already create signatures in this way and developer Craig
    Raw [said][raw sparrow] Sparrow Wallet that wallet is able to
    validate them in addition to also following the [BIP137][]
    validation rules and a slightly different set of rules implemented
    in Electrum.

    Sherief is planning to write a BIP specifying the behavior. {% assign timestamp="2:05" %}

- **Proof of micro-burn:** several developers [discussed][pomb]
  use cases and designs of onchain transactions that destroy bitcoins
  ("burn" bitcoins) in small increments as a proof of resource
  consumption. To extend an example use case by Ruben
  Somsen [from the thread][somsen hashcash], the idea would be to
  allow 100 users to each attach to their emails a proof that $1 of
  bitcoins had been burned, providing the type of anti-spam protection
  originally envisioned as a benefit of [hashcash][].

    Several solutions were discussed using merkle trees, although one
    respondent suggested that the small amounts involved suggest that
    having participants trust (or partially trust) a centralized third
    party may be a reasonable way to avoid unnecessary complexity. {% assign timestamp="9:43" %}

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Why do invalid signatures in `OP_CHECKSIGADD` not push to the stack?]({{bse}}114446)
  Chris Stewart asks why "if an invalid signature is found, the interpreter fails
  execution rather than continuing". Pieter Wuille explains that this behavior,
  defined in BIP340-342, is designed to support batch validation of
  [schnorr signatures][topic schnorr signatures] in the future.
  Andrew Chow gives an additional reason for the behavior, noting that
  certain malleability concerns are also mitigated by this approach. {% assign timestamp="30:41" %}

- [What are packages in Bitcoin Core and what is their use case?]({{bse}}114305)
  Antoine Poinsot explains [packages][bitcoin docs packages] (a grouping of
  related transactions), their relation to [package relay][topic package relay],
  and a recent [package relay BIP proposal][news201 package relay]. {% assign timestamp="34:17" %}

- [How much blockspace would it take to spend the complete UTXO set?]({{bse}}114043)
  Murch explores a hypothetical scenario of consolidating all existing UTXOs. He
  provides blockspace calculations for each output type and concludes the process would
  take about 11,500 blocks. {% assign timestamp="37:43" %}

- [Does an uneconomical output need to be kept in the UTXO set?]({{bse}}114493)
  Stickies-v notes that while provably unspendable UTXOs including `OP_RETURN`
  or scripts larger than the max script size are removed from the UTXO
  set, removing [uneconomical outputs][topic uneconomical outputs] could cause
  issues, including a hard fork as Pieter Wuille points out, if those outputs are spent. {% assign timestamp="39:37" %}

- [Is there code in libsecp256k1 that should be moved to the Bitcoin Core codebase?]({{bse}}114467)
  Similar to other efforts to modularize areas of the Bitcoin Core codebase like
  [libbitcoinkernel][libbitcoinkernel project] or [process separation][devwiki
  process separation], Pieter Wuille notes a clear area of responsibility of the
  [libsecp256k1][] project: everything that involves operations on private or public keys. {% assign timestamp="47:07" %}

- [Mining stale low-difficulty blocks as a DoS attack]({{bse}}114241)
  Andrew Chow explains that [assumevalid][assumevalid notes] and more recently
  [`nMinimumChainWork`][Bitcoin Core #9053] help filter out low-difficulty chain attacks. {% assign timestamp="48:32" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BTCPay Server 1.6.3][] adds new features, improvements, and bug fixes
  to this popular self-hosted payment processor.

- [LDK 0.0.110][] adds a variety of new features (many covered in
  previous newsletters) to this library for building LN-enabled
  applications.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25351][] ensures that after an import of addresses,
  keys, or descriptors to a wallet, the subsequent rescan will not only
  scan the blockchain but also evaluate whether transactions in the
  mempool are relevant to the wallet. {% assign timestamp="51:42" %}

- [Core Lightning #5370][] reimplements the `commando` plugin and makes
  it a built-in part of CLN.  Commando allows a node to receive commands
  from authorized peers using LN messages.  Peers are authorized using
  *runes*, which is a custom CLN protocol based on a simplified version
  of [macaroons][].  Although Commando is now built into CLN, it's only
  operable if a user creates rune authentication tokens.  For additional
  information, see CLN's manual pages for [commando][] and [commando-rune][]. {% assign timestamp="53:51" %}

- [BOLTs #1001][] recommends that nodes who advertise a change to their
  payment forwarding policies continue accepting payments received
  using the old policies for about 10 minutes.  This prevents payments
  from failing just because the sender hasn't heard about a recent
  policy update.  See [Newsletter #169][news169 cln4806] for the example
  of an implementation adopting a rule like this. {% assign timestamp="56:25" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="25351,5370,1001,24058,9053" %}
[BTCPay Server 1.6.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.6.3
[LDK 0.0.110]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.110
[commando]: https://github.com/rustyrussell/lightning/blob/2e13b72f55080be07ea68de77976eb990a043f5d/doc/lightning-commando.7.md
[commando-rune]: https://github.com/rustyrussell/lightning/blob/2e13b72f55080be07ea68de77976eb990a043f5d/doc/lightning-commando-rune.7.md
[news169 cln4806]: /en/newsletters/2021/10/06/#c-lightning-4806
[sherief gsm]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020759.html
[gray cc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020762.html
[raw sparrow]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020766.html
[pomb]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020745.html
[hashcash]: https://en.wikipedia.org/wiki/Hashcash
[somsen hashcash]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020746.html
[macaroons]: https://en.wikipedia.org/wiki/Macaroons_(computer_science)
[bitcoin docs packages]: https://github.com/bitcoin/bitcoin/blob/53b1a2426c58f709b5cc0281ef67c0d29fc78a93/doc/policy/packages.md#definitions
[news201 package relay]: /en/newsletters/2022/05/25/#package-relay-proposal
[libbitcoinkernel project]: https://github.com/bitcoin/bitcoin/issues/24303
[devwiki process separation]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/Process-Separation
[assumevalid notes]: https://bitcoincore.org/en/2017/03/08/release-0.14.0/#assumed-valid-blocks
