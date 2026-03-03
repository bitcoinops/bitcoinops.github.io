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
  code] is available on GitHub. {% assign timestamp="1:47" %}

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

{% assign timestamp="14:05" %}

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
  `scriptPubKeys` but with different (and possibly worse) trade-offs. {% assign timestamp="1:00:05" %}

- **Native STARK proof verification in Bitcoin Script**: Abdelhamid Bakhta
  [posted][abdel delving] to Delving Bitcoin a detailed proposal for a new
  [tapscript][topic tapscript] opcode `OP_STARK_VERIFY` which would enable the
  verification of a specific variant of STARK proof in Bitcoin Script. This
  would enable embedding proof of arbitrary computations in Bitcoin. The
  proposed opcode does not bind the proofs to any Bitcoin-specific data, so the
  proofs are merely verified proofs of whatever computation they themselves
  embed. These proofs can be linked to specific Bitcoin transactions using other
  signing methods. The post discusses various use cases such as [validity
  rollups][news222 validity rollups]. {% assign timestamp="1:18:47" %}

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
  #2015][] to add the generated test vectors to BIP54. {% assign timestamp="35:47" %}

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Core Lightning 25.09.2][] is a maintenance release for the current major
  version of this popular LN node that includes several bug fixes related to
  `bookkeeper` and to `xpay`, some of which are summarized in the code and
  documentation changes section below. {% assign timestamp="1:30:54" %}

- [LND 0.20.0-beta.rc3][] is a release candidate for this popular LN node. One
  improvement that would benefit from testing is the fix for premature wallet
  rescanning. {% assign timestamp="1:31:44" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #31645][] increases the default `dbbatchsize` config from 16 MB
  to 32 MB. This option determines the batch size used to flush the UTXO set
  cached in memory (as set by `dbcache`) to disk after IBD or an
  [assumeUTXO][topic assumeutxo] snapshot. This update primarily benefits HDDs
  and lower-end systems. For example, the author reports a 30% improvement in
  flushing time on a Raspberry Pi with a `dbcache` of 500. Users can override
  the default setting if desired. {% assign timestamp="1:32:34" %}

- [Core Lightning #8636][] adds an `askrene-timeout` config (default 10s) that
  causes `getroutes` to fail once the deadline is reached. When `maxparts` is
  set to a low value, `askrene` (see [Newsletter #316][news316 askrene]) may
  enter a retry loop on a route with insufficient capacity. This PR disables the
  bottleneck route in that scenario to ensure forward progress. {% assign timestamp="1:40:08" %}

- [Core Lightning #8639][] updates `bcli` to use `-stdin` when interfacing with
  `bitcoin-cli` to avoid operating system-dependent `argv` (command line
  arguments) size limits. This update resolves an issue that blocked users from
  building large transactions (e.g., [PSBTs][topic psbt] with 700 inputs). Other
  improvements to the performance of large transactions were also made. {% assign timestamp="1:43:18" %}

- [Core Lightning #8635][] updates payment status management to only mark a
  payment part as pending after the outgoing [HTLC][topic htlc] has been created
  when using `xpay` (see [Newsletter #330][news330 xpay]) or
  `injectpaymentonion`. Previously, the payment part was marked as pending
  first, and if the HTLC creation then failed, the item could stay pending
  forever in `listpays` or `listsendpays`. {% assign timestamp="1:44:31" %}

- [Eclair #3209][] adds a check to ensure routing feerate values can’t be
  negative. Previously, setting this value would trigger a channel force
  closure. {% assign timestamp="1:46:25" %}

- [Eclair #3206][] immediately fails a held incoming [HTLC][topic htlc] when a
  [liquidity advertisement][topic liquidity advertisements] purchase is aborted
  after signing begins but before signatures are exchanged. Previously, Eclair
  wouldn't handle this edge case and would only fail the HTLC shortly before its
  expiration, tying up the sender's funds unnecessarily. This change was
  motivated by cases where non-malicious mobile wallets would disconnect and
  abort. {% assign timestamp="1:46:59" %}

- [Eclair #3210][] updates its weight estimation to assume 73-byte DER-encoded
  signatures (see [Newsletter #6][news6 der]), aligning with the [BOLT3][]
  specification and with other implementations, such as LDK. This ensures that
  peers that also assume this size will never reject an `interactive-tx` attempt
  from Eclair due to fee underpayment. Eclair never generates these non-standard
  signatures. {% assign timestamp="1:49:31" %}

- [LDK #4140][] fixes premature force-closes for outgoing [async payments][topic
  async payments] when a node restarts. Previously, when an often-offline node
  came back online and an outgoing [HTLC][topic htlc] was
  `LATENCY_GRACE_PERIOD_BLOCKS` (3 blocks) past its [CLTV expiry][topic cltv
  expiry delta], LDK would force-close immediately, before the node could
  reconnect and allow the peer to fail the HTLC. In this scenario, since the
  node isn’t racing to claim an incoming HTLC, LDK adds a 4,032-block grace
  period after the HTLC’s CLTV expiry before force-closing. {% assign timestamp="1:54:13" %}

- [LDK #4168][] removes the flag on `read_event` that signals the pause of peer
  message reading. This makes `send_data` the only source of truth for
  pause/resume signals. This fixes a race condition where a node could receive a
  late pause signal from `read_event` after `send_data` had already resumed
  reading. The late pause would leave reads disabled indefinitely until the node
  sent a message to that peer again. {% assign timestamp="1:59:12" %}

- [Rust Bitcoin #5116][] updates the responses of `compute_merkle_root` and
  `compute_witness_root` to return `None` when the transaction list contains
  adjacent duplicates. This prevents the mutated [merkle root
  vulnerability][topic merkle tree vulnerabilities], CVE 2012-2459, where an
  invalid block with a duplicated transaction can share the same merkle root
  (and block hash) as a valid block, leading Rust Bitcoin to confuse and reject
  both. This solution is inspired by a similar one in Bitcoin Core. {% assign timestamp="2:01:06" %}

- [BTCPay Server #6922][] introduces `Subscriptions`, through which merchants
  can define recurring payment offerings and plans as well as onboard users via
  a checkout process. The system tracks each subscriber's credit balance, which
  is deducted during each billing period. A subscriber portal is included where
  users can upgrade or downgrade plans, view their credits, history, and
  receipts. Merchants can set up email alerts to notify users when a payment is
  almost due. While this doesn't introduce automatic charges, a planned [Nostr
  Wallet Connect (NWC)][news290 nwc] integration could make that possible for
  certain wallets. {% assign timestamp="2:05:05" %}

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
[LND 0.20.0-beta.rc3]: https://github.com/lightningnetwork/lnd/releases/tag/v0.20.0-beta.rc3
[Core Lightning 25.09.2]: https://github.com/ElementsProject/lightning/releases/tag/v25.09.2
[news316 askrene]: /en/newsletters/2024/08/16/#core-lightning-7517
[news330 xpay]: /en/newsletters/2024/11/22/#core-lightning-7799
[news6 der]: /en/newsletters/2018/07/31/#the-maximum-size-of-a-bitcoin-der-encoded-signature-is
[news290 nwc]: /en/newsletters/2024/02/21/#multiparty-coordination-protocol-nwc-announced
