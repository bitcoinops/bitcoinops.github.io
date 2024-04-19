---
title: 'Bitcoin Optech Newsletter #213'
permalink: /en/newsletters/2022/08/17/
name: 2022-08-17-newsletter
slug: 2022-08-17-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes how BLS signatures could be used to
improve DLCs without consensus changes to Bitcoin and includes our
regular sections with announcements of new software releases and release
candidates, plus summaries of notable changes to popular Bitcoin
infrastructure software.

## News

- **Using Bitcoin-compatible BLS signatures for DLCs:** Discreet Log
  Contracts (DLCs) allow a trusted third party known as an oracle to
  attest to a piece of data.  Individuals who trust that oracle can use
  that attestation in contracts without revealing to the oracle that a
  contract exists or what its terms are, among [other benefits of
  DLCs][topic dlc].  DLCs were originally proposed to use a feature of
  [schnorr signatures][topic schnorr signatures] but were later
  developed to use more generalized [signature adaptors][topic adaptor
  signatures].

  This week, Lloyd Fournier [posted][fournier dlc-dev] to the DLC-Dev
  mailing list about the benefits of having an oracle make their
  attestation using Boneh--Lynn--Shacham ([BLS][]) signatures.  Bitcoin
  does not support BLS signatures and a soft fork would be required to
  add them, but Fournier links to a [paper][fournier et al] he
  co-authored that describes how information can be securely extracted
  from a BLS signature and used with Bitcoin-compatible signature
  adaptors without any changes to Bitcoin.

  Fournier then goes on to describe several benefits of BLS-based
  attestations.  The most significant of these is that it would allow
  "stateless" oracles where the parties to a contract (but not the
  oracle) could privately agree on what information they wanted the
  oracle to attest to, e.g. by specifying a program written in any
  programming language they knew the oracle would run.  They could
  then allocate their deposit funds according to the contract without
  even telling the oracle that they were planning to use it.  When it
  came time to settle the contract, each of the parties could run the
  program themselves and, if they all agreed on the outcome, settle
  the contract cooperatively without involving the oracle at all.  If
  they didn't agree, any one of them could send the program to the
  oracle (perhaps with a small payment for its service) and receive
  back a BLS attestation to the program source code and the value
  returned by running it.  The attestation could be transformed into
  signatures that would allow settling the DLC onchain.  As with
  current DLC contracts, the oracle would not know which onchain
  transactions were based on its BLS signatures.  Multiple oracles
  could be used, including in a threshold configuration (e.g.
  5-of-10).

  The post makes a compelling case for the advantages of stateless
  oracles over existing DLC oracles which need to be aware of the
  contract at the time the contract is being created.  As of this
  writing, the post had not received replies by other DLC
  contributors. {% assign timestamp="1:59" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Rust Bitcoin 0.29][] is a major new release series.  Its [release
  notes][rb29 rn] note that it includes breaking API changes but also
  numerous new features and bug fixes, including support for [compact
  block relay][topic compact block relay] data structures ([BIP152][])
  and improvements to [taproot][topic taproot] and [PSBT][topic psbt]
  support. {% assign timestamp="40:47" %}

- [Core Lightning 0.12.0rc2][] is a release candidate for the next major
  version of this popular LN node implementation. {% assign timestamp="43:02" %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #23480][] updates the [output script descriptor][topic
  descriptors] language with a `rawtr()` descriptor for referring to the
  exposed key in a taproot output in cases where either the key is used
  without a tweak (not recommended, see [BIP341][bip341 internal]) or
  when the internal key and scripts aren't known (which can be unsafe;
  see the PR comments or the documentation added by this PR for
  details).  Although it's already possible to refer to the key in those
  cases using the existing `raw()` descriptor, which is primarily meant
  to be used with tools like Bitcoin Core's `scantxoutset` RPC for
  scanning its database of UTXOs, the new `rawtr()` descriptor makes it
  easier to use other existing descriptor fields to associate additional
  information with the taproot output such as key origin information.
  The key origin information may indicate that an alternative key
  generation scheme is being used, such as incremental tweaking to
  create [vanity addresses][] or [cooperative tweaking for
  privacy][reusable taproot addresses]. {% assign timestamp="43:19" %}

- [Bitcoin Core #22751][] adds a `simulaterawtransaction` RPC which
  accepts an array of unconfirmed transactions and returns how much BTC
  those transactions will add or subtract from the wallet's balance. {% assign timestamp="44:50" %}

- [Eclair #2273][] implements the [proposed][bolts #851] interactive
  funding protocol where two LN nodes coordinate more closely to open a
  new payment channel.  Implementing interactive funding moves Eclair
  closer to support for [dual funding][topic dual funding] which allows
  funds to be contributed to a new channel by either of the nodes
  participating in that channel.  Additional preparation for dual
  funding was also merged this week in [Eclair #2247][]. {% assign timestamp="47:34" %}

- [Eclair #2361][] begins requiring channel updates to include the
  `htlc_maximum_msat` field as proposed by [BOLTs #996][] (see
  [Newsletter #211][news211 bolts996]). {% assign timestamp="50:27" %}

- [LND #6810][] begins using receiving payments to [taproot][topic
  taproot] outputs in almost all of the wallet's automatically-generated
  output scripts.  In addition, [LND #6633][] implements support for
  `option_any_segwit` (see [Newsletter #151][news151 any_segwit]), which
  allows receiving the funds from a mutual close of a channel to a
  taproot output. {% assign timestamp="52:03" %}

- [LND #6816][] adds [documentation][lnd 0conf] about how to use
  [zero-conf channels][topic zero-conf channels]. {% assign timestamp="53:10" %}

- [BDK #640][] updates the `get_balance` function to return the current
  balance separated into four categories: an `available` balance for
  confirmed outputs, a `trusted-pending` balance for unconfirmed outputs
  from the wallet to itself (e.g. change outputs), an
  `untrusted-pending` balance for unconfirmed outputs from external
  wallets, and an `immature` balance for outputs from coinbase (mining)
  outputs that haven't reached the minimum 100 confirmations necessary
  to become spendable according to Bitcoin's consensus rules. {% assign timestamp="53:58" %}

{% include references.md %}
{% include linkers/issues.md v=2 issues="23480,22751,2273,2361,2247,996,6810,6633,6816,640,851" %}
[rust bitcoin 0.29]: https://github.com/rust-bitcoin/rust-bitcoin/releases/tag/0.29.1
[core lightning 0.12.0rc2]: https://github.com/ElementsProject/lightning/releases/tag/v0.12.0rc2
[bls]: https://en.wikipedia.org/wiki/BLS_digital_signature
[fournier dlc-dev]: https://mailmanlists.org/pipermail/dlc-dev/2022-August/000149.html
[fournier et al]: https://eprint.iacr.org/2022/499.pdf
[bip341 internal]: https://github.com/bitcoin/bips/blob/master/bip-0341.mediawiki#constructing-and-spending-taproot-outputs
[news211 bolts996]: /en/newsletters/2022/08/03/#ldk-1519
[news151 any_segwit]: /en/newsletters/2021/06/02/#bolts-672
[lnd 0conf]: https://github.com/lightningnetwork/lnd/blob/6c915484ba056870f9ed8b57f043d51f26137507/docs/zero_conf_channels.md
[vanity addresses]: https://en.bitcoin.it/wiki/Vanitygen
[reusable taproot addresses]: https://gist.github.com/Kixunil/0ddb3a9cdec33342b97431e438252c0a
[rb29 rn]: https://github.com/rust-bitcoin/rust-bitcoin/blob/110b5d89630d705e5d5ed0541230923eb4fc600f/CHANGELOG.md#029---2022-07-20-edition-2018-release
