---
title: 'Bitcoin Optech Newsletter #196'
permalink: /en/newsletters/2022/04/20/
name: 2022-04-20-newsletter
slug: 2022-04-20-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about allowing
quantum-safe key exchange on Bitcoin and includes our regular sections
with descriptions of notable changes to services and client software,
releases and release candidates, and popular Bitcoin infrastructure
software.

## News

- **Quantum-safe key exchange:** Erik Aronesty started a
  [thread][aronesty qc] on the Bitcoin-Dev mailing list about [quantum
  resistance][topic quantum resistance]---keeping Bitcoin secure in case
  a fast Quantum Computer (QC) is developed.  Fast QCs are predicted to
  be able to generate signatures corresponding to Bitcoin public keys
  without knowledge of the original private key, allowing someone
  possessing a fast QC to spend money belonging to other people.  Few security
  researchers believe fast QCs are a near-term threat, but any method
  that can eliminate them as a concern without significantly disturbing
  existing uses of Bitcoin may warrant consideration.

    Aronesty suggested allowing users to receive payments to a public
    key secured by a quantum-safe algorithm---also perhaps securing the
    bitcoins with an existing-style Bitcoin public key so that an
    exploitable problem would need to be found with both key algorithms
    before any bitcoins could be stolen as the result of a cryptographic
    key failure.  This would require a soft fork consensus change and
    would likely reduce the maximum number of useful transactions per
    block in the worst case given that quantum-safe witness data is
    larger than Bitcoin's currently-used ECDSA and [schnorr][topic
    schnorr signatures] witness data.

    Lloyd Fournier [suggested][fournier qc] instead that a standardized
    scheme be developed that allows taproot outputs to commit to
    quantum-safe public keys in addition to their usual schnorr public
    keys.  The quantum safe public keys might not be currently
    spendable, but if Bitcoin users became more concerned about an
    impending fast QC, they could choose to soft fork in a consensus
    change that required the quantum-safe spending paths be used.
    Fournier also suggested that details about the problem and possible
    solutions could be [described][qc issue] for current and future
    researchers and developers on [BitcoinProblems.org][].

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LND 0.14.3-beta][] is a release with several bug fixes
  for this popular LN node software.

- [Bitcoin Core 23.0 RC5][] is a release candidate for the next major
  version of this predominant full node software.  The [draft release
  notes][bcc23 rn] list multiple improvements that advanced users and
  system administrators are encouraged to [test][test guide] before the final release.

- [Core Lightning 0.11.0rc3][] is a release candidate for the next major
  version of this popular LN node software.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [LND #5810][] routing: send payment metadata FIXME:Xekyo maybe related to https://bitcoinops.org/en/topics/stateless-invoices/

- [LND #6212][] prevents HTLCs from being sent through the HTLC
  interceptor to an external process if accepting the HTLC might require
  the channel be closed onchain immediately or within a short time.
  This can happen if the HTLC's expiry is near the most recently seen
  block.

- [LND #6024][] adds a `time_pref` pathfinding parameter that can be
  used to change the tradeoff between routing through channels
  considered to be more likely to relay the payment (faster) and those
  which charge less fees.

- [LND #6385][] removes the option to use the original LN protocol onion
  payment format when constructing new payments, requiring the user now
  create a TLV-style onion format.  TLV onions were added to the
  protocol in 2019 (see [Newsletter #55][news55 tlv]) and have been the
  default in all LN software for over two years.  Other LN software have
  been making similar changes to drop older onion format support, such
  as the update to Core Lightning reported in [Newsletter
  #158][news158 cl4646].

{% include references.md %}
{% include linkers/issues.md v=2 issues="5810,6212,6024,6385" %}
[bitcoin core 23.0 rc5]: https://bitcoincore.org/bin/bitcoin-core-23.0/
[bcc23 rn]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Notes-draft
[test guide]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/23.0-Release-Candidate-Testing-Guide
[lnd 0.14.3-beta]: https://github.com/lightningnetwork/lnd/releases/tag/v0.14.3-beta
[core lightning 0.11.0rc3]: https://github.com/ElementsProject/lightning/releases/tag/v0.11.0rc3
[aronesty qc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020209.html
[fournier qc]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-April/020214.html
[qc issue]: https://github.com/bitcoin-problems/bitcoin-problems.github.io/issues/4
[bitcoinproblems.org]: https://bitcoinproblems.org/
[news55 tlv]: /en/newsletters/2019/07/17/#bolts-607
[news158 cl4646]: /en/newsletters/2021/07/21/#c-lightning-4646
