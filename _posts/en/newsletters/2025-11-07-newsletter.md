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

- **Multiple discussions about restricting data**: multiple conversations
  examined ideas to change the limits of various fields in consensus:

  - *Limiting scriptPubkeys to 520 bytes*: PortlandHODL [posted][ph 520spk post]
    a proposal to the Bitcoin-Dev mailing list seeking to limit the
    `scriptPubKey` size to 520 bytes in consensus. Similar to BIP54 [consensus
    cleanup][topic consensus cleanup], this would limit the maximum block
    verification cost in legacy script corner cases. It would also make it
    impossible to create larger contiguous data segments using `OP_RETURN`.
    Feedback to the idea included pushback that this change would have greater
    confiscation surface area for older pre-signed protocols compared to BIP54
    (which also limits maximum block verification cost), and that it would close
    certain potential [soft fork upgrade][topic soft fork activation] paths
    (especially around [quantum resistance][topic quantum resistance]).

  - *Temporary soft fork to reduce data*: Dathon Ohm opened a BIPs [pull
    request][BIPs #2017] and [posted][do post] to the Bitcoin-Dev mailing list a
    proposal which attempts to temporarily limit the ways that Bitcoin
    transactions can be used to encode data. While the soft fork is described as
    [temporary][topic transitory soft forks], discussion on the mailing list and
    pull request is critical of the large confiscation surface of the proposed
    changes. Additionally, while a temporary soft fork is possible, any
    controversy surrounding the expiration of the temporary soft fork turns the
    expiration into a contentious hard fork. Peter Todd [illustrated][pt post
    tx] the limitations of this approach by encoding the text of the proposed
    BIP into a Bitcoin transaction that would be valid under the proposed
    consensus rules.

- **Post-quantum signature aggregation**: Tadge Dryja [posted][td post civ] to
  the Bitcoin-Dev mailing list a proposal for an `OP_CHECKINPUTVERIFY`
  (`OP_CIV`) opcode that enables a locking script to commit to a specific UTXO
  being spent in the same transaction. This enables a group of related UTXOs to
  be spent with a single authorizing signature, similar in effect to
  [cross-input signature aggregation][topic cisa]. This approach is more costly
  than separate ECDSA or [BIP340][] signatures, but would save significant
  transaction vbytes with multi-kilobyte post-quantum signatures. `OP_CIV` could
  also be used for generic sibling input checks in protocols like [BitVM][topic
  acc]. Other proposals such as `OP_CHECKCONTRACTVERIFY` could be used to
  achieve a similar signature sharing scheme by committing to sibling
  `scriptPubKeys` but with different (and possibly worse) trade-offs.

- **Native STARK proof verification in Bitcoin Script**: Abdelhamid Bakhta
  [posted][abdel delving] to Delving Bitcoin a detailed proposal for a new
  [tapscript][topic tapscript] opcode `OP_STARK_VERIFY` which would enable the
  verification of a specific variant of STARK proof in Bitcoin Script. This
  would enable embedding proof of arbitrary computations in Bitcoin. The
  proposed opcode does not bind the proofs to any Bitcoin-specific data, so the
  proofs are merely verified proofs of whatever computation they themselves
  embed. These proofs can be linked to specific Bitcoin transactions using other
  signing methods. The post discusses various use cases such as [validity
  rollups][news222 validity rollups].

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
[ph 520spk post]: https://gnusha.org/pi/bitcoindev/6f6b570f-7f9d-40c0-a771-378eb2c0c701n@googlegroups.com/
[do post]: https://gnusha.org/pi/bitcoindev/AWiF9dIo9yjUF9RAs_NLwYdGK11BF8C8oEArR6Cys-rbcZ8_qs3RoJURqK3CqwCCWM_zwGFn5n3RECW_j5hGS01ntGzPLptqcOyOejunYsU=@proton.me/
[pt post tx]: https://gnusha.org/pi/bitcoindev/aP6gYSnte7J86g0p@petertodd.org/
[td post civ]: https://gnusha.org/pi/bitcoindev/05195086-ee52-472c-962d-0df2e0b9dca2n@googlegroups.com/
[abdel delving]: https://delvingbitcoin.org/t/proposal-op-stark-verify-native-stark-proof-verification-in-bitcoin-script/2056
[news222 validity rollups]: /en/newsletters/2022/10/19/#validity-rollups-research
[ap bip54 post]: https://groups.google.com/g/bitcoindev/c/1XEtmIS_XRc
[news348 bip54]: /en/newsletters/2025/04/04/#draft-bip-published-for-consensus-cleanup
[binq bip54 pr]: https://github.com/bitcoin-inquisition/bitcoin/pull/99
[bip54 miner]: https://github.com/darosior/bitcoin/commits/bip54_miner/
