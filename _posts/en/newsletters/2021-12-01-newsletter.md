---
title: 'Bitcoin Optech Newsletter #177'
permalink: /en/newsletters/2021/12/01/
name: 2021-12-01-newsletter
slug: 2021-12-01-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a recently fixed interoperability issue
between different LN software and includes our regular sections with a
list of new releases and release candidates plus notable changes to
popular Bitcoin infrastructure software.

## News

- **LN interoperability:** a recent change to the LN specification
  described in [Newsletter #165][news165 bolts880] was implemented in different ways by
  different LN nodes, resulting in nodes running the latest version of
  LND being unable to open new channels with nodes running the latest
  versions of C-Lightning and Eclair.  LND users are encouraged to
  upgrade to a bug fix release, 0.14.1 (described in the *Releases and
  release candidates* section below).

    A related [discussion][xraid interop] was started on the
    Lightning-Dev mailing list about improving interoperability testing.
    Christian Decker, who previously created and maintained the LN
    [integration testing framework][ln integration], said that [he
    believes][decker interop] basic interoperability testing is
    "unlikely to catch any but the most egregious issues".  LN
    developers participating in the discussion [noted][zmn interop] that
    catching these sort of bugs is why every major implementation
    provides release candidates (RCs) and why expert users and
    administrators of production systems are encouraged to contribute to
    the testing of those RCs.

    For anyone interested in participating in such testing, the Optech
    newsletter lists RCs from four major LN implementations, plus
    various other Bitcoin software.  The LND version under discussion was
    listed as an RC in Newsletters [#174][news174 lnd] and [#175][news175
    lnd].

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.14.1-beta][] is a maintenance release that fixes the issue
  described in more detail both in the *News* section above and in the
  description of [LND #6026][] in the *Notable changes* section below.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], and
[Lightning BOLTs][bolts repo].*

- [Bitcoin Core #16807][] updates address validation to return the indices of
  likely typos in [bech32 and bech32m][topic bech32] addresses
  using the mechanism described in [Newsletter #41][news41 bech32 error detection].
  The typos will be correctly identified if no more than two substitution
  errors were made. The pull request also improves test coverage, adds more
  documentation to the address validation code, and improves error messages
  when decoding fails, especially to distinguish use of bech32 and bech32m.

- [Bitcoin Core #22364][] adds support for creating [descriptors][topic
  descriptors] for [taproot][bip386]. This
  allows wallet users to generate and use P2TR addresses by creating a default
  bech32m descriptor with their wallet instead of importing one.

- [LND #6026][] fixes an issue with the [implementation][lnd #5669] of
  [BOLTs #880][] explicit channel type negotiation (see [Newsletter
  #165][news165 bolts880]). A [proposed change][bolts #906] to the LN
  specification would allow LND to eventually implement strict explicit
  negotiation.

- [Rust-Lightning #1176][] adds initial support for [anchor outputs][topic
  anchor outputs]-style fee bumping. As of this merge, support for anchor
  outputs is implemented in all four LN implementations we cover.

- [HWI #475][] adds [support][hwi support matrix] for the [Blockstream Jade][news132 jade]
  hardware signer and tests using the [QEMU emulator][qemu website].

{% include references.md %}
{% include linkers/issues.md issues="16807,22364,6026,5669,880,906,1176,475,6026" %}
[lnd 0.14.1-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.1-beta
[news165 bolts880]: /en/newsletters/2021/09/08/#bolts-880
[xraid interop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-November/003354.html
[decker interop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-November/003358.html
[zmn interop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-November/003365.html
[ln integration]: https://cdecker.github.io/lightning-integration/
[news174 lnd]: /en/newsletters/2021/11/10/#lnd-0-14-0-beta-rc3
[news175 lnd]: /en/newsletters/2021/11/17/#lnd-0-14-0-beta-rc4
[hwi support matrix]: https://hwi.readthedocs.io/en/latest/devices/index.html#support-matrix
[news132 jade]: /en/newsletters/2021/01/20/#blockstream-announces-jade-hardware-wallet
[qemu website]: https://www.qemu.org/
[news41 bech32 error detection]: /en/bech32-sending-support/#locating-typos-in-bech32-addresses
