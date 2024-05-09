---
title: 'Bitcoin Optech Newsletter #240'
permalink: /en/newsletters/2023/03/01/
name: 2023-03-01-newsletter
slug: 2023-03-01-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about the fastest way to
verify that a BIP32 master seed backup probably hasn't been corrupted
without using any digital devices.  Also included are our regular
sections with announcements of new releases and release candidates, plus
summaries of notable changes to popular Bitcoin infrastructure software.

## News

- **Faster seed backup checksums:** Peter Todd [replied][todd codex32]
  to the discussion about a draft BIP for Codex32 (see [last week's
  newsletter][news239 codex32]), a scheme that allows creating,
  verifying, and using recovery codes for a [BIP32][topic bip32] seed.
  A particular advantage of Codex32 over existing schemes is the ability
  to verify the integrity of backups using just pen, paper,
  documentation, and a modest amount of time.

  As designed, Codex32 provides very strong assurances about its
  ability to detect errors in the backups.  Peter Todd suggested a far
  easier method would be to generate recovery codes that could have
  their parts added together to produce a checksum.  If dividing the
  checksum by a known constant produced no remainder, it would verify
  the integrity of the backup within the parameters of the checksum
  algorithm.  Peter Todd suggested using an algorithm that provided
  roughly 99.9% protection against any typos, which he thought would
  be sufficiently strong, easy for people to use, and easy for people
  to memorize so that they didn't need the extra Codex32 materials.

  Russell O'Connor [replied][o'connor codex32] that a full Codex32
  recovery code can be checked much faster than full verification if
  the user is willing to accept less protection.  Checking just two
  characters at a time would guarantee detection of any
  single-character mistake in a recovery code and provide 99.9%
  protection against other substitution errors.  The process would be
  somewhat similar to generating the type of checksum that Peter Todd
  described, although it would require using a special lookup table
  which ordinary users would be unlikely to memorize.  If verifiers
  were willing to use a different lookup table each time they checked
  their code, each additional verification would increase their chance
  of detecting an error up until the seventh verification, where they
  would have the same assurance as they would receive from performing
  full Codex32 verification.  No changes are required to Codex32 to
  obtain the reinforcing quick check property, although Codex32's
  documentation will need to be updated to provide the necessary
  tables and worksheets in order to make it usable. {% assign timestamp="2:31" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [HWI 2.2.1][] is a maintenance release of this application for
  allowing software wallets to interface with hardware signing devices. {% assign timestamp="10:17" %}

- [Core Lightning 23.02rc3][] is a release candidate for a new
  maintenance version of this popular LN implementation. {% assign timestamp="11:38" %}

- [lnd v0.16.0-beta.rc1][] is a release candidate for a new major
  version of this popular LN implementation. {% assign timestamp="12:03" %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25943][] adds a parameter to the `sendrawtransaction`
  RPC to limit the amount of funds burned per output. If the
transaction contains an output whose script is heuristically deemed to
be unspendable (one with an `OP_RETURN`, an invalid opcode, or
exceeding the maximum script size) and whose value is greater than
`maxburnamount`, it will not be submitted to the mempool.  By default,
the amount is set to zero, protecting users from unintentionally burning
funds. {% assign timestamp="12:59" %}

- [Bitcoin Core #26595][] adds `wallet_name` and `passphrase` parameters to the
  [`migratewallet`][news217 migratewallet] RPC in order to support migrating
  encrypted legacy wallets and wallets not currently loaded into
  [descriptor][topic descriptors] wallets. {% assign timestamp="15:11" %}

- [Bitcoin Core #27068][] updates how Bitcoin Core handles passphrase
  entry.  Previously, a passphrase containing an ASCII null character
  (0x00) would be accepted---but only the part of the string up to the
  first null character would be used in the process of encrypting the
  wallet.  This could lead to a wallet having a much less secure
  passphrase than the user expected.  This PR will use the entire passphrase,
  including null characters, for encryption and decryption.  If the user
  enters a passphrase containing null characters which fails to decrypt
  an existing wallet, indicating they may have set a passphrase under
  the old behavior, they'll be provided with instructions for a
  workaround. {% assign timestamp="16:51" %}

- [LDK #1988][] adds limits for peer connections and unfunded channels
  to prevent denial of service resource exhaustion attacks.  The new
  limits are:

  - A maximum of 250 data-sharing peers which don't have a funded
    channel with the local node.

  - A maximum of 50 peers which may currently be trying to open a
    channel with the local node.

  - A maximum of 4 channels that have not yet been funded from a
    single peer. {% assign timestamp="18:37" %}

- [LDK #1977][] makes public its structures for serializing and parsing
  [offers][topic offers] as defined in [draft BOLT12][bolts #798].  LDK
  doesn't yet have support for [blinded paths][topic rv routing], so it
  can't currently send or receive offers directly, but this PR allows
  developers to begin experimenting with them. {% assign timestamp="20:15" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="25943,26595,27068,1988,1977,798" %}
[core lightning 23.02rc3]: https://github.com/ElementsProject/lightning/releases/tag/v23.02rc3
[lnd v0.16.0-beta.rc1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.16.0-beta.rc1
[hwi 2.2.1]: https://github.com/bitcoin-core/HWI/releases/tag/2.2.1
[news239 codex32]: /en/newsletters/2023/02/22/#proposed-bip-for-codex32-seed-encoding-scheme
[todd codex32]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021498.html
[o'connor codex32]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-February/021504.html
[news217 migratewallet]: /en/newsletters/2022/09/14/#bitcoin-core-19602
