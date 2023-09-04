---
title: 'Bitcoin Optech Newsletter #267'
permalink: /en/newsletters/2023/09/06/
name: 2023-09-06-newsletter
slug: 2023-09-06-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a new technique for compressing Bitcoin
transactions and summarizes an idea for privacy-enhanced transaction
cosigning.  Also included are our regular sections announcing new
releases and release candidates and describing notable changes to
popular Bitcoin infrastructure software.

## News

- **Bitcoin transaction compression:** Tom Briar [posted][briar
  compress] to the Bitcoin-Dev mailing list a [draft specification][compress
  spec] and [proposed implementation][compress impl] of compressed
  Bitcoin transactions.  Smaller transactions would be more practical to
  relay through bandwidth constrained mediums, such as by satellite or
  through steganography (e.g., encoding a transaction in a bitmap image).
  Traditional compression algorithms take advantage of most structured
  data having some elements that occur more frequently than other
  elements.  However, typical Bitcoin transactions consist largely of
  uniform elements---data that looks random---like public keys and hash
  digests.

    Briar's proposal addresses this using several approaches:

    - For the parts of a transaction where an integer is currently
      represented by 4 bytes (e.g., transaction version and outpoint
      index), these are replaced by a variable-length integer that can
      be as small as 2 bits.

    - The uniformly distributed 32-byte outpoint txid in each input
      is replaced by a reference to the location of that
      transaction in the block chain using its block height and location
      within the block, e.g.  `123456` and `789` would indicate the
      789th transaction in block 123,456.  Because the block at a
      particular height can change due to a block chain reorganization
      (breaking the reference and making it impossible to uncompress the transaction),
      this method is only used when the referenced transaction has at
      least 100 confirmations.

    - For P2WPKH transactions where the witness structure needs to
      include a signature plus a 33-byte public key,
      the public key is omitted and a technique of reconstructing it
      from the signature is used.

    Some other techniques are used to save a few extra bytes in typical
    transactions.  The general downside of the proposal is that
    converting a compressed transaction back into something that full
    nodes and other software can use requires more CPU, memory, and I/O
    than processing a regular serialized transaction.  That means
    high-bandwidth connections will likely continue to use the regular
    transaction format and only low-bandwidth transmission will use
    compressed transactions.

    The idea received a moderate amount of discussion, mostly around
    ideas for saving a small amount of additional space per input.

- **Privacy enhanced co-signing:** Nick Farrow [posts][farrow cosign] to
  the Bitcoin-Dev mailing list about how a [scriptless threshold
  signature scheme][topic threshold signature] like [FROST][] could
  improve the privacy of people who use co-signing services.  A typical
  user of a co-signing service has multiple signing keys that are stored
  separately for security; but, to simplify normal spending, they also
  allow their outputs to be spent by a combination of some of their keys
  plus one or more keys held by one or more service providers who only
  sign after authenticating the user in some way.  The user can bypass
  the service provider if needed, but the service provider makes
  operations easier in most cases.

    With scripted threshold signature schemes like 2-of-3
    `OP_CHECKMULTISIG`, the service's public key must be associated with
    the output being spent, so any service will be able to find the
    transactions it signed by looking at onchain data, allowing it
    accumulate data about its users.  Worse, all currently used protocols
    we're aware of directly reveal user transactions to the service
    provider before signing, allowing the service to refuse to sign
    certain transactions.

    As Farrow describes, FROST allows hiding the signed transaction from
    the service at every step of the process, from generation of an
    output script, to signing, to publication of the fully signed
    transaction.  All the service will know is when it signed and any
    data the user provided to authenticate themselves with the service.

    The idea received some discussion on the mailing list.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test release candidates.*

- [Libsecp256k1 0.4.0][] is the latest release of this library for
  Bitcoin-related cryptographic operations.  The new version includes a
  module with an implementation of ElligatorSwift encoding; see the
  project [changelog][libsecp cl] for more information.

- [LND v0.17.0-beta.rc2][] is a release candidate for the next major
  version of this popular LN node implementation.  A major new
  experimental feature planned for this release, which could likely
  benefit from testing, is support for "simple taproot channels".

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #28354][] default acceptnonstdtxn=0 on all chains FIXME:glozow

- [LDK #2468][] Offer outbound payments FIXME:bitschmidty

{% include references.md %}
{% include linkers/issues.md v=2 issues="28354,2468" %}
[LND v0.17.0-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc2
[briar compress]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021924.html
[compress spec]: https://github.com/TomBriar/bitcoin/blob/2023-05--tx-compression/doc/compressed_transactions.md
[compress impl]: https://github.com/TomBriar/bitcoin/pull/3
[farrow cosign]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-August/021917.html
[frost]: https://eprint.iacr.org/2020/852
[libsecp cl]: https://github.com/bitcoin-core/secp256k1/blob/master/CHANGELOG.md
[libsecp256k1 0.4.0]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.4.0
