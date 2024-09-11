---
title: 'Bitcoin Optech Newsletter #319'
permalink: /en/newsletters/2024/09/06/
name: 2024-09-06-newsletter
slug: 2024-09-06-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a proposal for allowing Stratum v2
pool miners to receive compensation for the transaction fees contained
in the block templates they turn into shares, announces a research fund
investigating the proposed `OP_CAT` opcode, and describes a discussion
about mitigating merkle tree vulnerabilities with or without a soft
fork.  Also included are our regular sections announcing new releases
and release candidates as well as describing notable changes to popular
Bitcoin infrastructure software.

## News

- **Stratum v2 extension for fee revenue sharing:** Filippo Merli
  [posted][merli stratumfees] to Delving Bitcoin about an extension to
  [Stratum v2][topic pooled mining] that will allow tracking the amount
  of fees included in _shares_ when the shares contain transactions
  selected by an individual miner.  This can be used to adjust the
  amount paid to the miner by the pool, with miners selecting higher
  feerate transactions being paid more.

  Merli links to a [paper][merli paper] he co-authored that examines
  some of the challenges of paying different miners different amounts
  based on the transactions they select. The paper suggests a scheme
  that is compatible with a _pay per last N shares_ (PPLNS) pooled
  mining payout scheme.  His post links to two in-progress
  implementations of the scheme. {% assign timestamp="1:49" %}

- **OP_CAT research fund:** Victor Kolobov [posted][kolobov cat] to the
  Bitcoin-Dev mailing list to announce a $1 million fund for research
  into a proposed soft fork to add an [`OP_CAT`][topic op_cat] opcode.
  "Topics of interest include but are not limited to: the security
  implications of `OP_CAT` activation on Bitcoin, `OP_CAT`-based computing
  and locking script logic on Bitcoin, applications and protocols
  utilizing `OP_CAT` on Bitcoin, and general research related to
  `OP_CAT` and its impact." Submissions must be received by 1 January 2025. {% assign timestamp="17:53" %}

- **Mitigating merkle tree vulnerabilities:** Eric Voskuil [posted][voskuil
  spv] to the Delving Bitcoin discussion thread about the [consensus
  cleanup soft fork proposal][topic consensus cleanup] (see [Newsletter
  #296][news296 cleanup]) a request for an update given recent
  [discussion][voskuil spv dev] on the Bitcoin-Dev mailing list.  In
  particular, he saw "no justification for the proposed invalidation of
  64 byte transactions" based on his argument that there's no
  performance improvement to full nodes in protecting against [merkle
  tree vulnerabilities][topic merkle tree vulnerabilities] like
  CVE-2012-2459 by forbidding 64-byte transactions in comparison to
  other checks that can be performed without a consensus change (and,
  indeed, those checks are being performed now).  The consensus cleanup
  proposal champion, Antoine Poinsot, appeared to [agree][poinsot cache]
  about this full node aspect: "The advantage I initially mentioned
  about how making 64-bytes transactions invalid could help caching
  block failures at an earlier stage is incorrect."

  However, Poinsot and others also previously proposed forbidding
  64-byte transactions to protect software verifying merkle proofs
  against CVE-2017-12842.  This vulnerability affects lightweight
  wallets that use _simplified payment verification_ (SPV) as described
  in the original [Bitcoin paper][].  It can also affect
  [sidechains][topic sidechains] that perform SPV and may affect some
  proposed [covenants][topic covenants] that require soft fork
  activation.

  Since the publication of CVE-2017-12842, it's been known that SPV can
  be made safe by a verifier additionally checking the depth of the
  coinbase transaction in a block.  Voskuil estimates this would require
  an additional 576 bytes on average for typical modern blocks---a small
  increase in bandwidth.  Poinsot [summarized][poinsot spv] the
  arguments and Anthony Towns [expanded][towns depth] on an argument
  about the complexity of performing the additional depth verification.

  Voskuil also linked to a previous [suggestion][lerner commitment] by
  Sergio Demian Lerner for an alternative soft fork consensus change
  that would have a block header commit to the depth of its merkle tree.
  This would also protect against CVE-2017-12842 without forbidding
  64-byte transactions and would allow SPV proofs to be maximally
  efficient.

  Discussion was ongoing at the time of writing. {% assign timestamp="22:43" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning 24.08][] is a major release of this popular LN node
  implementation containing new features and bug fixes. {% assign timestamp="55:21" %}

- [LDK 0.0.124][] is the latest releases of this library for building
  LN-enabled applications. {% assign timestamp="57:59" %}

- [LND v0.18.3-beta.rc2][] is a release candidate for a minor bug fix
  release of this popular LN node implementation. {% assign timestamp="1:06:19" %}

- [BDK 1.0.0-beta.2][] is a release candidate for this library for
  building wallets and other Bitcoin-enabled applications.  The original
  `bdk` Rust crate has been renamed to `bdk_wallet` and lower layer
  modules have been extracted into their own crates, including
  `bdk_chain`, `bdk_electrum`, `bdk_esplora`, and `bdk_bitcoind_rpc`.
  The `bdk_wallet` crate "is the first version to offer a stable 1.0.0 API." {% assign timestamp="1:06:43" %}

- [Bitcoin Core 28.0rc1][] is a release candidate for the next major
  version of the predominant full node implementation.  A [testing
  guide][bcc testing] is available. {% assign timestamp="1:07:27" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

_Note: the commits to Bitcoin Core mentioned below apply to its master
development branch, so those changes will likely not be released until about six
months after the release of the upcoming version 28._

- [Bitcoin Core #30454][] and [#30664][bitcoin core #30664]
  respectively add a CMake-based build system (see [Newsletter
  #316][news316 cmake]) and remove the previous autotools-based build
  system.  See also follow-ups in PRs [#30779][bitcoin core #30779],
  [#30785][bitcoin core #30785], [#30763][bitcoin core #30763],
  [#30777][bitcoin core #30777], [#30752][bitcoin core #30752],
  [#30753][bitcoin core #30753], [#30754][bitcoin core #30754],
  [#30749][bitcoin core #30749], [#30653][bitcoin core #30653],
  [#30739][bitcoin core #30739], [#30740][bitcoin core #30740],
  [#30744][bitcoin core #30744], [#30734][bitcoin core #30734],
  [#30738][bitcoin core #30738], [#30731][bitcoin core #30731],
  [#30508][bitcoin core #30508], [#30729][bitcoin core #30729], and
  [#30712][bitcoin core #30712]. {% assign timestamp="1:15:05" %}

- [Bitcoin Core #22838][] implements multiple derivation path
  [descriptors][topic descriptors] ([BIP389][]), which allows a single
  descriptor string to specify two related derivation paths, the first for
  receiving payments, and the second for internal use (such as for change). See
  Newsletters [#211][news211 bip389] and [#258][news258 bip389]. {% assign timestamp="1:17:41" %}

- [Eclair #2865][] adds the ability to wake up a disconnected mobile peer by
  attempting to connect to its last known IP address and push a mobile
  notification. This is especially useful in the context of [async
  payments][topic async payments] where the local node holds a payment or an [onion
  message][topic onion messages] and when the peer comes back online, it is
  delivered. See Newsletter [#232][news232 async]. {% assign timestamp="1:19:56" %}

- [LND #9009][] introduces a mechanism to ban peers for sending invalid channel
  announcements, such as channels that are already spent, have no funding
  transaction, or have an invalid funding output. Banned peers are handled
  differently depending on the relationship:

  - For banned peers without a shared channel, the node disconnects from them.

  - For banned peers with a shared channel, the node ignores all of their
    channel announcements for 48 hours.

  {% assign timestamp="1:21:49" %}

- [LDK #3268][] adds `ConfirmationTarget::MaximumFeeEstimate` for a more
  conservative [fee estimation][topic fee estimation] method for [dust][topic
  uneconomical outputs] calculations when checking counterparty feerates, to
  avoid unnecessary force closures caused by sudden fee spikes. This PR also
  splits `ConfirmationTarget::OnChainSweep` into `UrgentOnChainSweep` and
  `NonUrgentOnChainSweep` to distinguish between time-sensitive (e.g., with
  expiring [HTLCs][topic htlc]) and non-urgent force closures. {% assign timestamp="1:23:33" %}

- [HWI #742][] adds support for the Trezor Safe 5 hardware signing device.

- [BIPs #1657][] adds a new standard field to [PSBT][topic psbt] outputs for [DNSSEC][dnssec]
  proofs when using [BIP353][]. External devices such as hardware signers may examine
  the PSBT outputs to retrieve [RFC 9102][rfc9102]-formatted proofs, which
  enforce time constraints to ensure that only valid proofs are accepted. See
  Newsletter [#307][news307 bip353]. {% assign timestamp="1:26:55" %}

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30454,30664,30779,30785,30763,30777,30752,30753,30754,30749,30653,30739,30740,30744,30734,30738,30731,30508,30729,30712,22838,2865,9009,3268,742,1657" %}
[Core Lightning 24.08]: https://github.com/ElementsProject/lightning/releases/tag/v24.08
[LND v0.18.3-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.3-beta.rc2
[BDK 1.0.0-beta.2]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.2
[bitcoin core 28.0rc1]: https://bitcoincore.org/bin/bitcoin-core-28.0/
[voskuil spv]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/28
[voskuil spv dev]: https://mailing-list.bitcoindevs.xyz/bitcoindev/72e83c31-408f-4c13-bff5-bf0789302e23n@googlegroups.com/
[poinsot cache]: https://mailing-list.bitcoindevs.xyz/bitcoindev/wg_er0zMhAF9ERoYXmxI6aB7rc97Cum6PQj4UOELapsHVBBVWktFeOZT7sHDlyrXwJ5o5s9iMb2LW2Od-qacywsh-86p5Q7dP3XjWASXcMw=@protonmail.com/
[bitcoin paper]: https://bitcoincore.org/bitcoin.pdf
[poinsot spv]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/41
[lerner commitment]: https://bitslog.com/2018/06/09/leaf-node-weakness-in-bitcoin-merkle-tree-design/
[towns depth]: https://delvingbitcoin.org/t/great-consensus-cleanup-revival/710/43
[merli stratumfees]: https://delvingbitcoin.org/t/pplns-with-job-declaration/1099
[merli paper]: https://github.com/demand-open-source/pplns-with-job-declaration/blob/bd7258db08e843a5d3732bec225644eda6923e48/pplns-with-job-declaration.pdf
[kolobov cat]: https://mailing-list.bitcoindevs.xyz/bitcoindev/04b61777-7f9a-4714-b3f2-422f99e54f87n@googlegroups.com/
[news296 cleanup]: /en/newsletters/2024/04/03/#revisiting-consensus-cleanup
[news316 cmake]: /en/newsletters/2024/08/16/#bitcoin-core-switch-to-cmake-build-system
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/28.0-Release-Candidate-Testing-Guide
[ldk 0.0.124]: https://github.com/lightningdevkit/rust-lightning/releases
[news211 bip389]: /en/newsletters/2022/08/03/#multiple-derivation-path-descriptors
[news258 bip389]: /en/newsletters/2023/07/05/#bips-1354
[news232 async]: /en/newsletters/2023/01/04/#eclair-2464
[dnssec]: https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions
[rfc9102]: https://datatracker.ietf.org/doc/html/rfc9102
[news307 bip353]: /en/newsletters/2024/06/14/#bips-1551
