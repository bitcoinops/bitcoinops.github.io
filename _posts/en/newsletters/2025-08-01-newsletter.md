---
title: 'Bitcoin Optech Newsletter #365'
permalink: /en/newsletters/2025/08/01/
name: 2025-08-01-newsletter
slug: 2025-08-01-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes the results of a test of compact block
relay prefilling and links to a mempool-based fee estimation library.
Also included are our regular sections summarizing discussion about
changing Bitcoin's consensus rules, announcing new releases and release
candidates, and describing notable changes to popular Bitcoin
infrastructure software.

## News

- **Testing compact block prefilling:** David Gumberg [replied][gumberg
  prefilling] to a Delving Bitcoin thread about compact block
  reconstruction efficiency (previously covered in Newsletters
  [#315][news315 cb] and [#339][news339 cb]) with a summary of the
  results he obtained testing [compact block relay][topic compact block
  relay] _prefilling_---a node pre-emptively relaying some or all
  transactions in a new block to its peers when it thinks the peers may
  not already have those transactions.  Gumberg's post is detailed and
  links to a Jupyter notebook to allow others to experiment for themselves.
  Key takeaways include:

  - Considered independently of network transport, a simple rule for
    determining which transactions to prefill increased the rate of
    successful block reconstructions from about 62% to about 98%.

  - When considering network transport, some prefills may have resulted
    in an extra round trip---negating any benefit in that case and
    possibly degrading performance slightly.  However, many prefills
    could have been constructed to avoid the problem, increasing the
    likely reconstruction rate to about 93% and still supporting further
    improvements.

- **Mempool-based fee estimation library:** Lauren Shareshian
  [posted][shareshian estimation] to Delving Bitcoin to announce a
  library for [fee estimation][topic fee estimation] developed by Block.
  Unlike some other fee estimation tools, it solely uses the flow of
  transactions into a node's mempool as the basis of its estimates.
  The post compares the library, Augur, to several fee estimation
  services and finds that Augur has a low miss rate (i.e., over 85% of
  transactions confirm within their intended window) and a low average
  overestimation rate (i.e., transactions overpay fees by only about 16%
  more than necessary).

  Abubakar Sadiq Ismail [replied][ismail estimation] to the Delving
  thread and also started an informative [issue][augur #3] on the Augur
  repository for examining some of the assumptions used by the library.

## Changing consensus

_A monthly section summarizing proposals and discussion about changing
Bitcoin's consensus rules._

- **Migration from quantum-vulnerable outputs:** Jameson Lopp
  [posted][lopp qmig] to the Bitcoin-Dev mailing list a three-step
  proposal for phasing out spending from [quantum-vulnerable
  outputs][topic quantum resistance].

  - Three years after consensus activation of the [BIP360][]
    quantum-resistant signature scheme (or an alternative scheme), a
    soft fork would reject transactions with outputs paying
    quantum-vulnerable addresses.  Only spends to quantum-resistant
    outputs would be allowed.

  - Two years later, a second soft fork would reject spends from
    quantum-vulnerable outputs.  Any funds remaining in
    quantum-vulnerable outputs would become unspendable.

  - Optionally, at some undefined later time, a consensus change could
    allow spending from quantum-vulnerable outputs using a
    quantum-resistant proof scheme (see [Newsletter #361][news361 pqcr]
    for an example).

  Most of the discussion in the thread largely repeated prior
  discussions about whether it was necessary to prevent people from
  spending quantum-vulnerable bitcoins before it was certain
  a quantum computer fast enough to steal them existed (see [Newsletter
  #348][news348 destroy]).  Reasonable arguments were made on both sides
  and we expect that debate to continue.

- **Taproot-native `OP_TEMPLATEHASH` proposal:** Greg Sanders
  [posted][sanders th] to Bitcoin-Dev mailing list a proposal to add three opcodes to
  [tapscript][topic tapscript].  Two of the opcodes are the previously
  proposed [OP_CHECKSIGFROMSTACK][topic op_checksigfromstack] and
  `OP_INTERNALKEY` (see [Newsletter #285][news285 ik]).  The final
  opcode is `OP_TEMPLATEHASH`, a taproot-native variation on
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] (`OP_CTV`) with
  the following differences highlighted by the authors:

  - No changes to legacy (pre-segwit) scripts.  See
    [Newsletter #361][news361 ctvlegacy] for prior discussion about this
    alternative.

  - The data that is hashed (and the order it is hashed in) is very
    similar to the data hashed for signatures to commit to in
    [taproot][topic taproot], simplifying implementation for any
    software that already supports taproot.

  - It commits to the taproot [annex][topic annex], which `OP_CTV` does
    not.  One way this can be used is to ensure some data is published
    as part of a transaction, such as data used in a contract protocol
    to allow a counterparty to recover from publication of an old state.

  - It redefines an `OP_SUCCESSx` opcode rather than an `OP_NOPx`
    opcode.  Soft forks redefining `OP_NOPx` opcodes must be `VERIFY`
    opcodes that mark the transaction invalid if they fail.  Redefinitions
    of `OP_SUCCESSx` opcodes can simply place either `1` (success) or
    `0` (failure) on the stack after execution; this allows them to be
    used directly in cases where redefined `OP_NOPx` redefinitions would
    need to be wrapped by conditionals such as `OP_IF`
    statements.

  - "It prevents surprising inputs with ...  `scriptSig`" (see
    [Newsletter #361][news361 bitvm]).

  Brandon Black [replied][black th] with a comparison of the proposal to
  his earlier LNHANCE bundle proposal (see [Newsletter #285][news285
  ik]) and found it comparable in most ways, although he noted that it
  is less efficient in onchain space for _congestion control_ (a form of
  delayed [payment batching][topic payment batching]).

- **Proposal to allow longer relative timelocks:** developer Pyth
  [posted][pyth timelock] to Delving Bitcoin to suggest allowing
  [BIP68][] relative timelocks to be extended from their current maximum
  of about one year to a new maximum of about ten years.  This would
  require a soft fork and the use of an additional bit from the
  transaction input _sequence_ field.

  Fabian Jahr [replied][jahr timelock] with a concern that
  [timelocks][topic timelocks] too far in the future could lead to a
  loss of funds, such as due to the development of quantum computers
  (or, we add, the deployment of quantum defense protocols such as
  Jameson Lopp's proposal described earlier in this newsletter).  Steven
  Roose [noted][roose timelock] that far-future timelocks are already
  possible using other time lock mechanisms (such as presigned
  transactions and [BIP65 CLTV][bip65]), and Pyth added that their
  desired use case is for a wallet recovery path where the long timelock
  would only be used if the primary path became unavailable and the
  alternative would be permanent loss of the funds anyway.

- **Security against quantum computers with taproot as a commitment scheme:**
  Tim Ruffing [posted][ruffing qtr] a link to a [paper][ruffing paper]
  he wrote analyzing the security of [taproot][topic taproot]
  commitments against manipulation by quantum computers.  He examines
  whether taproot commitments to tapleaves would continue to possess the
  _binding_ and _hiding_ properties it has against classical
  computers.  He concludes that:

  > A quantum attacker needs to perform at least 2^81 evaluations of
  > SHA256 to create a Taproot output and be able to open it to an
  > unexpected Merkle root with probability 1/2. If the attacker has
  > only quantum machines whose longest sequence of SHA256 computations
  > is limited to 2^20, then the attacker needs at least 2^92 of these
  > machines to get a success probability of 1/2.

  If taproot commitments are secure against manipulation by quantum
  computers, then quantum resistance can be added to Bitcoin by
  disabling keypath spends and adding quantum-resistant
  signature-checking opcodes to [tapscript][topic tapscript].  A recent
  update to [BIP360][] pay-to-quantum-resistant-hash that Ethan Heilman
  [posted][heilman bip360] to the Bitcoin-Dev mailing
  list makes exactly this change.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Bitcoin Core 29.1rc1][] is a release candidate for a maintenance
  version of the predominant full node software.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #29954][] extends the `getmempoolinfo` RPC by adding two relay
  policy fields to its response object: `permitbaremultisig` (whether the node
  relays bare multisig outputs) and `maxdatacarriersize` (the maximum aggregate
  bytes allowed in OP_RETURN outputs for a transaction in the mempool). Other
  policy flags, such as [`fullrbf`][topic rbf] and `minrelaytxfee`, were already
  exposed, so these additions allow for a complete relay policy snapshot.

- [Bitcoin Core #33004][] enables the `-natpmp` option by default, allowing
  automatic port forwarding via the [Port Control Protocol (PCP)][pcp] with a
  fallback to the [NAT Port Mapping Protocol (NAT-PMP)][natpmp] (see Newsletter
  [#323][news323 natpmp]). A listening node behind a router that supports either
  PCP or NAT-PMP becomes reachable without manual configuration.

- [LDK #3246][] enables the creation of [BOLT12 offers][topic offers] and
  refunds without a [blinded path][topic rv routing] by using the offer’s
  `signing_pubkey` as the destination. The `create_offer_builder` and
  `create_refund_builder` functions now delegate blinded path creation to
  `MessageRouter::create_blinded_paths`, where a caller can generate a compact
  path by passing `DefaultMessageRouter`, a full-length pubkey path with
  `NodeIdMessageRouter`, or no path at all with `NullMessageRouter`.

- [LDK #3892][] exposes the merkle tree signature of [BOLT12][topic offers]
  invoices publicly, enabling developers to build CLI tools or other software to
  verify the signature or recreate invoices. This PR also adds an `OfferId`
  field to BOLT12 invoices to track the originating offer.

- [LDK #3662][] implements [BLIPs #55][], also known as LSPS05, which defines
  how clients can register for webhooks via an endpoint to receive push
  notifications from an LSP. The API exposes additional endpoints that enable
  clients to list all webhook registrations or remove a specific one. This can
  be useful for clients to get notified when receiving an [async payment][topic
  async payments].

{% include snippets/recap-ad.md when="2025-08-05 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="29954,33004,3246,3892,3662,55" %}
[bitcoin core 29.1rc1]: https://bitcoincore.org/bin/bitcoin-core-29.1/
[augur #3]: https://github.com/block/bitcoin-augur/issues/3
[news315 cb]: /en/newsletters/2024/08/09/#statistics-on-compact-block-reconstruction
[news339 cb]: /en/newsletters/2025/01/31/#updated-stats-on-compact-block-reconstruction
[gumberg prefilling]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052/34
[shareshian estimation]: https://delvingbitcoin.org/t/augur-block-s-open-source-bitcoin-fee-estimation-library/1848/
[ismail estimation]: https://delvingbitcoin.org/t/augur-block-s-open-source-bitcoin-fee-estimation-library/1848/2
[news361 pqcr]: /en/newsletters/2025/07/04/#commit-reveal-function-for-post-quantum-recovery
[sanders th]: https://mailing-list.bitcoindevs.xyz/bitcoindev/26b96fb1-d916-474a-bd23-920becc3412cn@googlegroups.com/
[news285 ik]: /en/newsletters/2024/01/17/#new-lnhance-combination-soft-fork-proposed
[news361 ctvlegacy]: /en/newsletters/2025/07/04/#concerns-and-alternatives-to-legacy-support
[pyth timelock]: https://delvingbitcoin.org/t/exploring-extended-relative-timelocks/1818/
[jahr timelock]: https://delvingbitcoin.org/t/exploring-extended-relative-timelocks/1818/2
[roose timelock]: https://delvingbitcoin.org/t/exploring-extended-relative-timelocks/1818/3
[ruffing qtr]: https://mailing-list.bitcoindevs.xyz/bitcoindev/bee6b897379b9ae0c3d48f53d40a6d70fe7915f0.camel@real-or-random.org/
[ruffing paper]: https://eprint.iacr.org/2025/1307
[heilman bip360]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CAEM=y+W=rtU2PLmHve6pUVkMQQmqT67KOg=9hp5oMspuHrgMow@mail.gmail.com/
[lopp qmig]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CADL_X_fpv-aXBxX+eJ_EVTirkAJGyPRUNqOCYdz5um8zu6ma5Q@mail.gmail.com/
[news348 destroy]: /en/newsletters/2025/04/04/#should-vulnerable-bitcoins-be-destroyed
[black th]: https://mailing-list.bitcoindevs.xyz/bitcoindev/aG9FEHF1lZlK6d0E@console/
[news361 bitvm]: /en/newsletters/2025/07/04/#continued-discussion-about-ctv-csfs-advantages-for-bitvm
[news323 natpmp]: /en/newsletters/2024/10/04/#bitcoin-core-30043
[pcp]: https://datatracker.ietf.org/doc/html/rfc6887
[natpmp]: https://datatracker.ietf.org/doc/html/rfc6886
