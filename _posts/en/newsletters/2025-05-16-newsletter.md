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
  starting with last month's release of Bitcoin Core 29.0. {% assign timestamp="1:17" %}

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
  overflow] on Delving Bitcoin. {% assign timestamp="5:28" %}

- **Proposed opcodes for enabling recursive covenants through quines:**
  Bram Cohen [posted][cohen quine] to Delving Bitcoin to suggest a set
  of simple opcodes that would enable the creation of recursive
  [covenants][topic covenants] through self-reproducing scripts
  ([quines][]).  Cohen describes how the opcodes could be used to create a
  simple [vault][topic vaults] and mentions a more advanced system that
  he's been working on. {% assign timestamp="23:11" %}

- **Description of benefits to BitVM from `OP_CTV` and `OP_CSFS`:**
  Robin Linus [posted][linus bitvm-sf] to Delving Bitcoin about several
  of the improvements to [BitVM][topic acc] that would become possible if the
  proposed [OP_CTV][topic op_checktemplateverify] and [OP_CSFS][topic
  op_checksigfromstack] opcodes were added to Bitcoin in a soft fork.
  The benefits he describes includes increasing the number of operators
  without downsides, "reducing transaction sizes by approximately 10x"
  (which reduces worst-case costs), and allowing non-interactive peg-ins
  for certain contracts. {% assign timestamp="36:39" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LND 0.19.0-beta.rc4][] is a release candidate for this popular LN
  node.  One of the major improvements that could probably use testing
  is the new RBF-based fee bumping for cooperative closes. {% assign timestamp="1:07:28" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #32155][] updates the internal miner to [timelock][topic
  timelocks] coinbase transactions by setting the `nLockTime` field to the
  current block’s height minus one and requiring the `nSequence` field not to be
  final (to enforce the timelock). Although the built-in miner isn’t typically
  used on mainnet, updating it encourages mining pools to adopt these changes
  early in their own software in preparation for the
  [consensus cleanup][topic consensus cleanup] soft fork proposed in [BIP54][]. Timelocking coinbase
  transactions solves the [duplicate transaction][topic duplicate transactions]
  vulnerability, and would allow the costly [BIP30][] checks to be lifted. {% assign timestamp="1:08:27" %}

- [Bitcoin Core #28710][] removes the remaining legacy wallet code,
  documentation, and related tests. This includes the legacy-only RPCs, such as
  `importmulti`, `sethdseed`, `addmultisigaddress`, `importaddress`,
  `importpubkey`, `dumpwallet`, `importwallet`, and `newkeypool`. As the final
  step for legacy wallet removal, the BerkeleyDB dependency and related
  functions are also removed. However, the bare minimum of legacy code and an
  independent BDB parser (see Newsletter [#305][news305 bdb]) are retained in
  order to perform wallet migration to [descriptor][topic descriptors] wallets. {% assign timestamp="1:09:38" %}

- [Core Lightning #8272][] disables the DNS seed lookup peer discovery fallback
  from the connection daemon `connectd` to resolve call block issues caused by
  offline DNS seeds. {% assign timestamp="1:13:28" %}

- [LND #8330][] adds a small constant (1/c) to the pathfinding bimodal
  probability model to address numerical instability. In edge cases where the
  calculation would otherwise fail due to rounding errors and produce a zero
  probability, this regularization provides a fallback by causing the model to
  revert to a uniform distribution. This resolves normalization bugs that occur
  in scenarios involving very large channels or channels that don't fit a
  bimodal distribution. Additionally, the model now skips unnecessary
  probability calculations and automatically corrects outdated channel liquidity
  observations and contradictory historical information. {% assign timestamp="1:14:09" %}

- [Rust Bitcoin #4458][] replaces the `MtpAndHeight` struct with an explicit
  pair of the newly added `BlockMtp` and the already existing `BlockHeight`,
  enabling better modeling of both block height and Median Time Past (MTP)
  values in relative [timelocks][topic timelocks]. Unlike
  `locktime::absolute::MedianTimePast`, which is constrained to values above 500 million
  (roughly after 1985), `BlockMtp` can represent any 32-bit timestamp. This
  makes it suitable for theoretical edge cases, such as chains with unusual
  timestamps. This update also introduces `BlockMtpInterval`, and renames
  `BlockInterval` to `BlockHeightInterval`. {% assign timestamp="1:14:52" %}

- [BIPs #1848][] updates the status of [BIP345][] to `Withdrawn`, as the author
  [believes][obeirne vaultwithdraw] its proposed `OP_VAULT` opcode has been superseded by
  [`OP_CHECKCONTRACTVERIFY`][topic matt] (OP_CCV), a more general [vault][topic vaults] design
  and a new type of [covenant][topic covenants]. {% assign timestamp="1:04:33" %}

- [BIPs #1841][] merges [BIP172][], which proposes formally defining Bitcoin’s
  indivisible base unit as a “satoshi,” reflecting current widespread usage and
  helping standardize terminology across applications and documentation. {% assign timestamp="1:16:25" %}

- [BIPs #1821][] merges [BIP177][], which proposes redefining “bitcoin” to
  represent the smallest indivisible unit (commonly referred to as 1 satoshi),
  rather than 100,000,000 units. The proposal argues that aligning terminology
  with the actual base unit would reduce confusion caused by arbitrary decimal
  conventions. {% assign timestamp="1:16:42" %}

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
[news305 bdb]: /en/newsletters/2024/05/31/#bitcoin-core-26606
[obeirne vaultwithdraw]: https://delvingbitcoin.org/t/withdrawing-op-vault-bip-345/1670/
