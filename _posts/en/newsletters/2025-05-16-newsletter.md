---
title: 'Bitcoin Optech Newsletter #354'
permalink: /en/newsletters/2025/05/16/
name: 2025-05-16-newsletter
slug: 2025-05-16-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a fixed vulnerability affecting old
versions of Bitcoin Core.  Also included are our regular sections
summarizing recent discussions about changing Bitcoin's consensus rules,
announcing new releases and release candidates, and describing notable
changes to popular Bitcoin infrastructure software.

## News

- **Vulnerability disclosure affecting old versions of Bitcoin Core:**
  Antoine Poinsot [posted][poinsot addrvuln] to the Bitcoin-Dev mailing
  list to announce a vulnerability affecting Bitcoin Core versions
  before 29.0.  The vulnerability was originally [responsibly
  disclosed][topic responsible disclosures] by Eugene Siegel along with
  another closely related vulnerability described in [Newsletter
  #314][news314 excess addr].  An attacker could send an excessive
  number of node address advertisements to force a 32-bit identifier to
  overflow, resulting in a node crash.  This was partly
  mitigated by limiting the number of updates to one per peer per every
  ten seconds, which for the default limit of about 125 peers would
  prevent overflow unless the node was continuously attacked for over 10
  years. <!-- 2**32 * 10 / 125 / (60 * 60 * 24 * 365) --> The
  vulnerability was completely fixed by using 64-bit identifiers,
  starting with last month's release of Bitcoin Core 29.0.

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

- **Proposed BIP for 64-bit arithmetic in Script:** Chris Stewart
  [posted][stewart bippost] a [draft BIP][64bit bip] to the Bitcoin-Dev
  mailing list that proposes upgrading Bitcoin's existing opcodes to
  operate on 64-bit numeric values.  This follows his previous research
  (see Newsletters [#285][news285 64bit], [#290][news290
  64bit], and [#306][news306 64bit]).  In a change from some of the
  earlier discussion, the new proposal uses numbers in the same
  compactSize data format currently used in Bitcoin.  Additional related
  [discussion][stewart inout] occurred on two [threads][stewart
  overflow] on Delving Bitcoin.

- **Proposed opcodes for enabling recursive covenants through quines:**
  Bram Cohen [posted][cohen quine] to Delving Bitcoin to suggest a set
  of simple opcodes that would enable the creation of recursive
  [covenants][topic covenants] through self-reproducing scripts
  ([quines][]).  Cohen describes how the opcodes could be used to create a
  simple [vault][topic vaults] and mentions a more advanced system that
  he's been working on.

- **Description of benefits to BitVM from `OP_CTV` and `OP_CSFS`:**
  Robin Linus [posted][linus bitvm-sf] to Delving Bitcoin about several
  of the improvements to [BitVM][topic acc] that would become possible if the
  proposed [OP_CTV][topic op_checktemplateverify] and [OP_CSFS][topic
  op_checksigfromstack] opcodes were added to Bitcoin in a soft fork.
  The benefits he describes includes increasing the number of operators
  without downsides, "reducing transaction sizes by approximately 10x"
  (which reduces worst-case costs), and allowing non-interactive peg-ins
  for certain contracts.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LND 0.19.0-beta.rc4][] is a release candidate for this popular LN
  node.  One of the major improvements that could probably use testing
  is the new RBF-based fee bumping for cooperative closes.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #32155][] miner: timelock the coinbase to the mined block's height

- [Bitcoin Core #28710][] Remove the legacy wallet and BDB dependency

- [Core Lightning #8272][] connectd: remove DNS seed lookups.

- [LND #8330][] bitromortac/2401-bimodal-improvements

- [Rust Bitcoin #4458][] locktimes: replace `MtpAndHeight` type with pair of `BlockMtp` and `BlockHeight`

- [BIPs #1848][] 'jamesob-25-05-withdraw-vault' - See also https://delvingbitcoin.org/t/withdrawing-op-vault-bip-345/1670

- [BIPs #1841][] Adds BIP172: Define Bitcoin Subunits as Satoshis

- [BIPs #1821][] BIP177: Redefine Bitcoin’s Base Unit

{% include snippets/recap-ad.md when="2025-05-20 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="32155,28710,8272,8330,4458,1848,1841,1821" %}
[lnd 0.19.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.19.0-beta.rc4
[news314 excess addr]: /en/newsletters/2024/08/02/#remote-crash-by-sending-excessive-addr-messages
[stewart bippost]: https://groups.google.com/g/bitcoindev/c/j1zEky-3QEE
[64bit bip]: https://github.com/Christewart/bips/blob/2025-03-17-64bit-pt2/bip-XXXX.mediawiki
[news285 64bit]: /en/newsletters/2024/01/17/#proposal-for-64-bit-arithmetic-soft-fork
[news290 64bit]: /en/newsletters/2024/02/21/#continued-discussion-about-64-bit-arithmetic-and-op-inout-amount-opcode
[news306 64bit]: /en/newsletters/2024/06/07/#updates-to-proposed-soft-fork-for-64-bit-arithmetic
[stewart inout]: https://delvingbitcoin.org/t/op-inout-amount/549/4
[stewart overflow]: https://delvingbitcoin.org/t/overflow-handling-in-script/1549
[poinsot addrvuln]: https://mailing-list.bitcoindevs.xyz/bitcoindev/EYvwAFPNEfsQ8cVwiK-8v6ovJU43Vy-ylARiDQ_1XBXAgg_ZqWIpB6m51fAIRtI-rfTmMGvGLrOe5Utl5y9uaHySELpya2ojC7yGsXnP90s=@protonmail.com/
[cohen quine]: https://delvingbitcoin.org/t/a-simple-approach-to-allowing-recursive-covenants-by-enabling-quines/1655/
[linus bitvm-sf]: https://delvingbitcoin.org/t/how-ctv-csfs-improves-bitvm-bridges/1591/
[quines]: https://en.wikipedia.org/wiki/Quine_(computing)
