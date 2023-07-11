---
title: Quantum resistance

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - Post-quantum cryptography

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Security Enhancements

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Discussion of quantum computer attacks on taproot
    url: /en/newsletters/2021/03/24/#discussion-of-quantum-computer-attacks-on-taproot
    feature: true

  - title: "Question about paying public keys directly versus hash indirection"
    url: /en/newsletters/2020/04/29/#what-are-the-potential-attacks-against-ecdsa-that-would-be-possible-if-we-used-raw-public-keys-as-addresses

  - title: "Question about whether taproot create security risk from quantum threats?"
    url: /en/newsletters/2020/02/26/#could-taproot-create-larger-security-risks-or-hinder-future-protocol-adjustments-re-quantum-threats

  - title: "Question about whether hashing pubkeys really provides quantum resistance?"
    url: /en/newsletters/2019/10/30/#why-does-hashing-public-keys-not-actually-provide-any-quantum-resistance

  - title: "Bitcoin Core contributor meeting transcripts: taproot quantum discussion"
    url: /en/newsletters/2019/06/12/#taproot-accumulator-quantum

  - title: BIP151 discussion, including about NewHope quantum-resistant key exchange
    url: /en/newsletters/2018/09/11/#bip151-discussion

  - title: PR opened for initial BIP151 support, NewHope quantum resistance to follow
    url: /en/newsletters/2018/08/28/#pr-opened-for-initial-bip151-support

  - title: "Discussion about quantum-safe key exchange"
    url: /en/newsletters/2022/04/20/#quantum-safe-key-exchange

  - title: "2022 year-in-review: quantum-safe key exchange"
    url: /en/newsletters/2022/12/21/#quantum-safe-keys

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Taproot
    link: topic taproot

  - title: Version 2 P2P transport
    link: topic v2 p2p transport

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Quantum resistance** is the ability for cryptographic protocols to
  remain secure in the presence of fast quantum computers.

---

Bitcoin uses a variety of cryptographic protocols with varying degrees
of vulnerability to fast quantum computers:

- **SHA256, SHA256d, and RIPEMD160** used variously in Bitcoin's proof
  of work and to uniquely identify blocks, scripts, individual
  transactions, and collections of transactions, plus used for hash
  locks in [HTLCs][topic htlc], would have their security strength
  reduced to its square root by [Grover's algorithm][] running on an
  idealized quantum computer.  That means an algorithm like SHA256 that
  currently has an estimated second preimage resistance of 256 bits
  (2<sup>256</sup>) would be reduced to 128 bits (2<sup>128</sup> is the
  square root of 2<sup>256</sup>).  That loss can be overcome by using a
  roughly equivalent algorithm with twice as many security bits, e.g.
  going from SHA256 to SHA512.

- **ECDSA** public keys used in Bitcoin are vulnerable to a
  factorization attack using [Shor's algorithm][].  This would
  completely eliminate the security of ECDSA, assuming an idealized
  quantum computer.  Since public keys used for proposed [schnorr
  signatures][topic schnorr signatures] are essentially identical to
  those used for ECDSA, the same attack applies.  Quantum-resistant
  alternatives to ECDSA are known, but they involve much larger key and
  signature sizes, so most developers seem to prefer to delay upgrading
  until it's necessary.

- **Noise** is the [protocol framework][noise framework] used for
  encrypted communication in LN.
  Optech has not seen discussion of its quantum resistance, but we
  believe the way LN currently uses it depends on the security of ECDSA,
  so if fast quantum computers are developed, they may be able to
  decrypt old communication between LN nodes.  Alternative key exchange
  mechanisms such as [NewHope][] are known and are proposed for
  implementation in other parts of Bitcoin, such as the [version 2
  Bitcoin transport protocol][topic v2 p2p transport].

The worst case for attacks assumes an idealized quantum computer with
sufficient capacity and reliability to perform the attack.  It's likely
that the capacity and reliability of quantum computers will increase
gradually over time, meaning the security of the cryptography used in
Bitcoin will similarly decrease gradually over time, with attacks
progressing from computationally infeasible, to theoretically possible
but implausible, to extraordinarily expensive, to very expensive, to
practical.  As long as this progression is followed and is possible to
publicly track, it's likely Bitcoin can continue using its currently
highly space efficient cryptography while it remains safe, and then
upgrade to post-quantum cryptography when it looks like it'll soon
become necessary.

{% include references.md %}
{% include linkers/issues.md issues="" %}
[grover's algorithm]: https://en.wikipedia.org/wiki/Grover%27s_algorithm
[shor's algorithm]: https://en.wikipedia.org/wiki/Shor%27s_algorithm
[newhope]: https://newhopecrypto.org/
[noise framework]: https://duo.com/labs/tech-notes/noise-protocol-framework-intro
