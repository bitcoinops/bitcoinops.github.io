---
title: 'Bitcoin Optech Newsletter #379'
permalink: /en/newsletters/2025/11/07/
name: 2025-11-07-newsletter
slug: 2025-11-07-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter shares an analysis comparing the historical performance
of the OpenSSL and libsecp256k1 libraries.  Also included are our regular sections with
descriptions of discussions about changing consensus, announcements of
new releases and release candidates, and summaries of notable changes to
popular Bitcoin infrastructure software.

## News

- **Comparing performance of ECDSA signature validation in OpenSSL vs. libsecp256k1:** Sebastian Falbesoner [posted to Delving][sebastion delving]
  about comparing the performance of ECDSA signature validation between OpenSSL
  and libsecp256k1 over the last decade. He mentions that it will be the 10th
  anniversary of Bitcoin Core switching from OpenSSL to libsecp256k1, and wanted
  to imagine a hypothetical situation in which Bitcoin Core never switched.

  From the start, when the switch happened, libsecp256k1 was 2.5 - 5.5 times
  faster than OpenSSL. Nonetheless, OpenSSL could have improved over the years,
  so it was worth testing to see how it compared over the decade.

  The methodology consisted of three steps (parse compressed public key, parse
  DER-encoded signature, verify ECDSA signature) that could be tested using
  functions in both libraries. A benchmark was made with a list of pseudo-random
  key pairs. He ran the benchmark on three separate machines and provided a bar
  plot. The chart showed that over the years, libsecp256k1 had improved
  significantly. Meaning a ~28% improvement from bc-0.19 to bc-0.20 and another
  ~30% improvement from bc-0.20 to bc-22.0 while OpenSSL had remained the same.

  Sebastian concludes that outside the Bitcoin ecosystem, the secp256k1 curve is
  not that relevant and doesn't count as a first-class citizen, that would
  justify the hours of work to improve it. He also encourages readers to attempt
  to reproduce his results and to report any issues with his methodology or
  differences found in their own results. The [source code][libsecp benchmark
  code] is available on GitHub.

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

- **BIP54 implementation and test vectors**: Antoine Poinsot [posted][ap bip54
  post] to the Bitcoin-Dev mailing list an update on his [consensus
  cleanup][topic consensus cleanup] work on [BIP54][] (see [Newsletter
  #348][news348 bip54] for more details). He opened [Bitcoin Inquisition
  #99][binq bip54 pr], implementing BIP54 consensus rules. This PR comes with
  unit tests for each of the four mitigations, which can be used to generate
  test vectors for the proposal. Moreover, it contains a fuzz harness for the
  sigop accounting logic and functional tests that mimic the mitigations'
  behaviour in realistic situations, including historical violations.
  Additionally, a [custom miner][bip54 miner] was developed to generate a full
  header chain needed by the test vectors for mitigations requiring mainnet
  blocks, such as timestamp and coinbase restrictions. Finally, he opened [BIPs
  #2015][] to add the generated test vectors to BIP54.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

FIXME:Gustavojfe

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

FIXME:Gustavojfe

{% include snippets/recap-ad.md when="2025-11-11 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="2015,2017,31645,8636,8639,8635,3209,3206,3210,4140,4168,5116,6922" %}
[sebastion delving]: https://delvingbitcoin.org/t/comparing-the-performance-of-ecdsa-signature-validation-in-openssl-vs-libsecp256k1-over-the-last-decade/2087
[libsecp benchmark code]: https://github.com/theStack/secp256k1-plugbench
[ap bip54 post]: https://groups.google.com/g/bitcoindev/c/1XEtmIS_XRc
[news348 bip54]: /en/newsletters/2025/04/04/#draft-bip-published-for-consensus-cleanup
[binq bip54 pr]: https://github.com/bitcoin-inquisition/bitcoin/pull/99
[bip54 miner]: https://github.com/darosior/bitcoin/commits/bip54_miner/
