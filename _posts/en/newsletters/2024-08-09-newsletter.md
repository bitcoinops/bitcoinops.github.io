---
title: 'Bitcoin Optech Newsletter #315'
permalink: /en/newsletters/2024/08/09/
name: 2024-08-09-newsletter
slug: 2024-08-09-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter announces the Dark Skippy fast seed exfiltration
attack, summarizes discussion about block withholding attacks and
proposed solutions, shares statistics about compact block
reconstruction, describes a replacement cycling attack against
transactions with pay-to-anchor outputs, mentions a new BIP specifying
threshold signing with FROST, and relays an announcement of an
improvement to Eftrace that allows it to opportunistically verify
zero-knowledge proofs using two proposed soft forks.

## News

- **Faster seed exfiltration attack:** Lloyd Fournier, Nick Farrow, and
  Robin Linus announced [Dark Skippy][], an improved method for key
  exfiltration from a Bitcoin signing device which they previously
  [responsibly disclosed][topic responsible disclosures] to
  approximately 15 different hardware signing device vendors.  _Key exfiltration_ occurs
  when transaction signing code deliberately creates its signatures in
  such a way that they leak information about the underlying key
  material, such as a private key or a [BIP32 HD wallet seed][topic
  bip32].  Once an attacker obtains a user's seed, they can steal any of
  the user's funds at any time (including funds spent in the transaction
  that results in exfiltration, if the attacker acts quickly).

  The authors mention that the best previous key exfiltration attack of
  which they are aware required dozens of signatures to exfiltrate a
  BIP32 seed.  With Dark Skippy, they are now able to exfiltrate a seed
  in two signatures, which may both belong to a single transaction with
  two inputs, meaning all of a user's funds may be vulnerable from the
  moment they first try to spend any of their money.

  Key exfiltration can be used by any logic that creates signatures,
  including software wallets---however, it's generally expected that a
  software wallet with malicious code will simply transmit its seed to
  the attacker over the internet.  Exfiltration is mainly considered to
  be a risk for hardware signing devices that don't have direct access
  to the internet.  A device that has had its logic corrupted, through either
  its firmware or hardware logic, can now quickly exfiltrate a
  seed even if the device is never connected to a computer (e.g. all
  data is transferred using NFC, SD cards, or QR codes).

  Methods of performing [exfiltration-resistant signing][topic
  exfiltration-resistant signing] for Bitcoin have been discussed
  (including in Optech newsletters as far back as [Newsletter
  #87][news87 anti-exfil]) and are currently implemented in two hardware
  signing devices that we are aware of (see [Newsletter #136][news136
  anti-exfil]).  That deployed method does require an extra round trip
  of communication with the hardware signing device compared to standard
  single-sig signing, although that may be less of a downside if users
  become accustomed to other types of signing, such as [scriptless
  multisignatures][topic multisignature], that also require additional
  round trips of communication.  Alternative methods of exfiltration-resistant
  signing that offer different tradeoffs are also known,
  although none has been implemented in Bitcoin hardware signing devices
  to our knowledge.

  Optech recommends that anyone using hardware signing devices to protect
  substantial amounts of money guard against corrupted
  hardware or firmware, either through the use of exfiltration-resistant
  signing or through the use of multiple independent devices (e.g. with
  scripted or scriptless multisignature or threshold signing). {% assign timestamp="1:24" %}

- **Block withholding attacks and potential solutions:**
  Anthony Towns [posted][towns withholding] to the Bitcoin-Dev mailing
  list to discuss the [block withholding attack][topic block
  withholding], a related _invalid shares_ attack, and potential
  solutions to both attacks---including disabling client work selection
  in [Stratum v2][topic pooled mining] and oblivious shares.

  Pool miners are paid for submitting units of work, called _shares_,
  each of which is a _candidate block_ that contains a certain amount of
  proof of work (PoW).  The expectation is that a known portion of those
  shares will also contain enough PoW to make their candidate block
  eligible for inclusion on the most-PoW blockchain.  For example, if
  the share PoW target is 1/1,000<sup>th</sup> of the valid-block PoW
  target, the pool expects to pay for 1,000 shares for every valid block
  it produces on average.  A classic block withholding attack occurs
  when a pool miner does not submit the 1-in-1,000 share that produces a
  valid block but does submit the other 999 shares that are not valid
  blocks.  This allows the miner to be paid for 99.9% of their work but
  prevents the pool from earning any income from that miner.

  Stratum v2 includes an optional mode that pools can enable to allow
  miners to include a different set of transactions in their candidate
  blocks than what the pool suggests mining.  The pool miner can even
  attempt mining transactions that the pool doesn't have.  This can make
  it expensive for the pool to validate miner shares: each share can
  contain up to several megabytes of transactions that the pool has
  never seen before, all of which may be
  designed to be slow to validate.  That can easily overwhelm a pool's
  infrastructure, affecting its ability to accept shares from honest
  users.

  Pools can avoid this problem by only validating share PoW, skipping
  transaction validation, but that allows a pool miner to collect
  payment for submitting invalid shares 100% of the time, which is
  slightly worse than the approximately 99.9% of the time they can
  collect payment from a classic block withholding attack.

  This incentivizes pools to either forbid client transaction selection
  or require that pool miners use a persistent public identity (e.g. a
  name validated through government-issued documentation) so that bad
  actors can
  be banned.

  One solution Towns proposes is for pools to provide multiple block
  templates, allowing each miner to choose their preferred template.
  This is similar to the existing system used by [Ocean Pool][].  Shares
  submitted based on pool-created templates can be validated quickly
  and with a minimum amount of bandwidth.  This prevents the invalid
  shares attack that pays 100% but does not help with the approximately
  99.9% profitable block withholding attack.

  To address the block withholding attack, Towns updates an idea
  [originally proposed][rosenfeld pool] by Meni Rosenfeld in 2011 that
  describes how a conceptually simple hard fork could prevent a pool
  miner from knowing whether any particular share had enough PoW to be a
  valid block, making them _oblivious shares_.  An attacker who can't
  discriminate between valid-block PoW and share PoW can only deprive a
  pool of valid-block income at the same rate the attacker deprives
  themselves of share income.  The approach has downsides:

  - *SPV-visible hard fork:* all hard fork proposals require all full
    nodes to upgrade.  However, many proposals (such as simple block
    size increase proposals like [BIP103][]) do not require upgrades of
    lightweight clients that use _simplified payment validation_ (SPV).
    This proposal changes how the block header field is interpreted and
    so would require all lightweight clients to also upgrade.  Towns
    does offer an alternative that wouldn't necessarily require light
    clients to upgrade, but it would reduce their security
    significantly.

  - *Requires pool miners to use a private template from the pool:* not
    only would a template be required to prevent the 100% invalid shares
    attack but the pool would need to keep that template secret from
    pool miners until after all shares generated using that template
    were received.  The pool could use that to trick miners into
    producing PoW for transactions the miners would object to.  However,
    expired templates could be published to allow auditing.  Most modern
    pools generate a new template every few seconds, so any auditing
    could be performed in near real-time, preventing a malicious pool
    from tricking its miners for more than a few seconds.

  - *Requires share submission:* one of the advantages of Stratum v2 (in
    certain operating modes) is that an honest pool miner who finds a
    block for the pool can immediately broadcast it to the Bitcoin P2P
    network, allowing it to begin propagating even before the
    corresponding share has reached the pool server.  With oblivious
    shares, the share would need to be received by the pool and
    converted into a full block before it could be broadcast.

  Towns concludes by describing two of the motivations for fixing the block
  withholding attack: it affects small pools more than large pools, and
  it costs almost nothing to attack pools that allow anonymous miners,
  whereas pools that require miners to identify themselves can ban known
  attackers.  Fixing block withholding could help Bitcoin mining to
  become more anonymous and decentralized. {% assign timestamp="17:21" %}

- **Statistics on compact block reconstruction:** developer 0xB10C
  [posted][0xb10c compact] to Delving Bitcoin about the recent
  reliability of [compact block][topic compact block relay]
  reconstruction.  Many relaying full nodes have been using [BIP152][]
  compact block relay since the feature was added to Bitcoin Core 0.13.0
  in 2016.  This allows two peers that have already shared some
  unconfirmed transactions to use a short reference to those
  transactions when they are confirmed in a new block rather than
  re-transmitting the entire transaction.  This significantly reduces
  bandwidth and, by doing so, also reduces latency---allowing new blocks
  to propagate more quickly.

  Faster propagation of new blocks decreases the number of accidental
  blockchain forks.  Fewer forks reduces the amount of proof-of-work (PoW) that
  is wasted and reduces the number of _block races_ that benefit larger
  mining pools over smaller pools, helping to make Bitcoin more secure
  and more decentralized.

  However, sometimes new blocks include transactions that a node has not
  seen before.  In that case, the node receiving a compact block usually
  needs to request those transactions from the sending peer and then
  wait for the peer to respond.  This slows down block propagation.
  Until a node has all of the transactions in a block, that block can't
  be validated or relayed to peers.  <!--
  https://bitcoin.stackexchange.com/questions/123858/can-a-bip152-compact-block-be-sent-before-validation-by-a-node-that-doesnt-know
  --> This increases the frequency of accidental blockchain forks,
  reduces PoW security, and increases centralization pressure.

  For that reason, it's useful to monitor how often compact blocks
  provide all of the information necessary to immediately validate a new
  block with no additional transactions needing to be requested, called
  a _successful reconstruction_.  Gregory Maxwell [recently
  reported][maxwell reconstruct] a decrease in successful
  reconstructions for nodes running Bitcoin Core with its default
  settings, especially when compared to a node running with the
  `mempoolfullrbf` configuration setting enabled.

  Developer 0xB10C's post this week summarized the number of successful
  reconstructions he's observed using his own nodes with various
  settings, with some data going back about six months.  Recent data on
  the effect of enabling `mempoolfullrbf` only goes back about a week,
  but it matches Maxwell's report.  This has helped motivate
  consideration of a [pull request][bitcoin core #30493] to enable
  `mempoolfullrbf` by default in an upcoming version of Bitcoin Core. {% assign timestamp="21:47" %}

- **Replacement cycle attack against pay-to-anchor:** Peter Todd
  [posted][todd cycle] to the Bitcoin-Dev mailing list about the
  pay-to-anchor (P2A) output type that is part of the [ephemeral
  anchors][topic ephemeral anchors] proposal.  P2A is a transaction
  output that anyone can spend.  This can be useful for [CPFP][topic
  cpfp] fee bumping---especially in multiparty protocols such as LN.
  However, CPFP fee bumping in LN is currently vulnerable to a
  counterparty performing a [replacement cycling attack][topic
  replacement cycling] where the malicious counterparty performs a
  two-step process.  They first [replace][topic rbf] an honest user's version of a
  transaction with the counterparty's version of the same transaction.
  They then replace the replacement with a transaction unrelated to
  either user's version of the transaction.  When an LN channel has
  unresolved [HTLCs][topic htlc], a successful replacement cycle can
  allow the counterparty to steal from the honest party.

  Using LN's current [anchor outputs][topic anchor outputs] channel
  type, only a counterparty can perform a replacement cycling attack.
  However, Todd points out that, because P2A allows anyone to spend the
  output, anyone can perform a replacement cycling attack against
  transactions using it.  Still, only a counterparty can economically
  benefit from the attack, so there's no direct incentive for third
  parties to attack P2A outputs.  The attack can be free in the case
  where the attacker is planning to broadcast their own transaction at a
  feerate higher than the honest user's P2A spend and the attacker
  successfully completes the replacement cycle without their
  intermediate state getting confirmed by miners.  All existing deployed
  LN mitigations against replacement cycling attacks (see [Newsletter
  #274][news274 cycle mitigate]) will be equally effective at defeating
  P2A replacement cycling. {% assign timestamp="36:23" %}

- **Proposed BIP for scriptless threshold signatures:** Sivaram
  Dhakshinamoorthy [posted][dhakshinamoorthy frost] to the Bitcoin-Dev
  mailing list to announce the availability of a [proposed BIP][frost
  sign bip] for creating [scriptless threshold signatures][topic
  threshold signature] for Bitcoin's implementation of [schnorr
  signatures][topic schnorr signatures].  This allows a set of signers
  that have already performed a setup procedure (e.g. using
  [ChillDKG][news312 chilldkg]) to securely create
  signatures that only require interaction from a dynamic subset of
  those signers.  The signatures are indistinguishable onchain from
  schnorr signatures created by single-sig users and scriptless
  multisignature users, improving privacy and fungibility. {% assign timestamp="42:24" %}

- **Optimistic verification of zero-knowledge proofs using CAT, MATT, and Elftrace:**
  Johan T. Halseth [posted][halseth zkelf] to Delving Bitcoin to
  announce that his tool, [Elftrace][], now has the ability to verify
  zero-knowledge (ZK) proofs.  For this to be useful onchain, both
  [OP_CAT][topic op_cat] and the [MATT][topic acc] proposed soft forks
  would need to be activated. {% assign timestamp="50:40" %}

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

[Add PayToAnchor(P2A), OP_1 <0x4e73>, as standard output script for spending][review club 30352] is a PR by [instagibbs][gh instagibbs]
that introduces a new `TxoutType::ANCHOR` output script type. Anchor
outputs have a `OP_1 <0x4e73>` output script (resulting in a [`bc1pfeessrawgf`][mempool bc1pfeessrawgf] address). Making these
outputs standard facilitates creating and relaying transactions that
spend from an anchor output.

{% include functions/details-list.md
  q0="Before `TxoutType::ANCHOR` is defined in this PR,
  what `TxoutType` would a `scriptPubKey` `OP_1 <0x4e73>` be classified
  as?"
  a0="Because it consists of a 1-byte push opcode (`OP_1`) and a 2-byte
  data push (`0x4e73`), it is a valid v1 witness output. Because it is
  not 32 bytes, it doesn't qualify as a `WITNESS_V1_TAPROOT`, thus
  defaulting to a `TxoutType::WITNESS_UNKNOWN`."
  a0link="https://bitcoincore.reviews/30352#l-18"

  q1="Based on the answer to the previous question, would it be standard
  to create this output type? What about to spend it? (Hint: how
  do [`IsStandard`][gh isstandard] and [`AreInputsStandard`][gh
  areinputsstandard] treat this type?)"
  a1="Because `IsStandard` (which is used to check outputs) only
  considers `TxoutType::NONSTANDARD` to be non-standard, creating it
  would be standard. Because `AreInputsStandard` considers a transaction
  that spends from a `TxoutType::WITNESS_UNKNOWN` to be non-standard, it
  would not be standard to spend it."
  a1link="https://bitcoincore.reviews/30352#l-24"

  q2="Before this PR, with default settings, which output types can
  be _created_ in a standard transaction? Is that the same as the script
  types that can be _spent_ in a standard transaction?"
  a2="All defined `TxoutType`'s except `TxoutType::NONSTANDARD` can be
  created. All defined `TxoutType`'s except `TxoutType::NONSTANDARD` and
  `TxoutType::WITNESS_UNKNOWN` are allowed to be spent (although it's
  impossible to spend `TxoutType::NULL_DATA`)."
  a2link="https://bitcoincore.reviews/30352#l-42"

  q3="Define _anchor output_, without mentioning Lightning Network
  transactions (try to be more general)."
  a3="An anchor output is an extra output created on presigned
  transactions to allow fees to be added via CPFP at the time of
  broadcasting. See also [topic anchor outputs] for more information."
  a3link="https://bitcoincore.reviews/30352#l-48"

  q4="Why does the size of the output script of an anchor output
  matter?"
  a4="A large output script makes it costlier to relay and prioritize
  the transaction."
  a4link="https://bitcoincore.reviews/30352#l-66"

  q5="How many virtual bytes are needed to create and spend a P2A
  output?"
  a5="Creating a P2A output requires 13 vbytes. Spending it requires 41
  vbytes."
  a5link="https://bitcoincore.reviews/30352#l-120"

  q6="The 3rd commit [adds][gh 30352 3rd commit] `if
  (prevScript.IsPayToAnchor()) return false` to `IsWitnessStandard`.
  What does this do, and why is it needed?"
  a6="It ensures that an anchor output can only be spent without witness
  data. This prevents an attacker from taking an honest spending
  transaction, adding witness data to it and then propagating it at a
  higher absolute fee but lower feerate. This would force the honest
  user to pay increasingly higher fees to replace it."
  a6link="https://bitcoincore.reviews/30352#l-154"
%}

{% assign timestamp="33:15" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Libsecp256k1 0.5.1][] is a minor release for this library of
  Bitcoin-related cryptographic functions.  It changes the default size
  of the precomputed table for signing to match Bitcoin Core's default
  and adds example code for ElligatorSwift-based key exchange (which is
  the protocol used in [version 2 encrypted P2P transport][topic v2 p2p
  transport]). {% assign timestamp="53:11" %}

- [BDK 1.0.0-beta.1][] is a release candidate for this library for
  building wallets and other Bitcoin-enabled applications.  The original
  `bdk` Rust crate has been renamed to `bdk_wallet` and lower layer
  modules have been extracted into their own crates, including
  `bdk_chain`, `bdk_electrum`, `bdk_esplora`, and `bdk_bitcoind_rpc`.
  The `bdk_wallet` crate "is the first version to offer a stable 1.0.0 API." {% assign timestamp="53:43" %}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #30493][] enables [full RBF][topic rbf] as the default setting,
  while leaving the option for node operators to revert to opt-in RBF. Full RBF
  allows for the replacement of any unconfirmed transaction, regardless of
  [BIP125][bip125 github] signaling. It has been an option in Bitcoin Core since
  July 2022 (see Newsletter [#208][news208 fullrbf]), but was previously
  disabled by default. For the discussions about making full RBF the default,
  see Newsletter [#263][news263 fullrbf]. {% assign timestamp="54:39" %}

- [Bitcoin Core #30285][] adds two key [cluster linearization][wuille cluster]
  algorithms to the [cluster mempool][topic cluster mempool] project:
  `MergeLinearizations` for combining two existing linearizations, and
  `PostLinearize` for improving linearizations by additional processing. This PR
  builds on work discussed in last week’s Newsletter [#314][news314 cluster]. {% assign timestamp="57:33" %}

- [Bitcoin Core #30352][] introduces a new output type, Pay-To-Anchor (P2A), and
  makes its spending standard. This output type is keyless (allowing anyone to spend it) and enables compact
  anchors for [CPFP][topic cpfp] fee bumping that are resistant to
  txid malleability (see [Newsletter #277][news277 p2a]). Combined with
  [TRUC][topic v3 transaction relay] transactions, this advances the
  implementation of [ephemeral anchors][topic ephemeral anchors] to replace
  LN [anchor outputs][topic anchor outputs] that are based on the [CPFP carve-out][topic
  cpfp carve out] relay rule. {% assign timestamp="1:02:26" %}

- [Bitcoin Core #29775][] adds a `testnet4` configuration option that will set
  the network to [testnet4][topic testnet] as specified in [BIP94][].  Testnet4
  includes fixes several problems with the previous testnet3 (see [Newsletter
  #306][news306 testnet]).  The existing Bitcoin Core `testnet` configuration
  option that uses testnet3 remains available but is expected to be deprecated
  and removed in subsequent releases. {% assign timestamp="1:02:39" %}

- [Core Lightning #7476][] catches up to the latest proposed [BOLT12
  specification][bolt12 spec] updates by adding the rejection of zero-length
  [blinded paths][topic rv routing] in [offers][topic offers] and invoice
  requests. Additionally, it allows `offer_issuer_id` to be missing in offers
  with a provided blinded path. In such cases, the key used to sign the invoice
  is used as the final blinded path key, since it's safe to assume that the
  offer issuer has access to this key. {% assign timestamp="1:08:21" %}

- [Eclair #2884][] implements [BLIP4][] for [HTLC
  endorsement][topic htlc endorsement], becoming the first LN implementation to
  do so, to partially mitigate [channel jamming attacks][topic channel jamming
  attacks] on the network. This PR enables the optional relaying of incoming endorsement
  values, with relaying nodes using their local determination of the
  inbound peer's reputation to decide whether they should include an
  endorsement when forwarding an [HTLC][topic htlc] to the next hop.
  If widely adopted by the network, endorsed HTLCs could receive preferential
  access to scarce network resources such as liquidity and HTLC slots. This
  implementation builds on previous Eclair work discussed in Newsletter
  [#257][news257 eclair]. {% assign timestamp="1:08:55" %}

- [LND #8952][] refactors the `channel` component in `lnwallet` to use the typed
  `List`, as part of a series of PRs implementing dynamic commitments, a
  type of [channel commitment upgrade][topic channel commitment upgrades]. {% assign timestamp="1:12:10" %}

- [LND #8735][] adds the ability to generate invoices with [blinded paths][topic
  rv routing] using the `-blind` flag in the `addinvoice` command. It also
  allows payment of such invoices. Note that this is only implemented for [BOLT11][]
  invoices, as [BOLT12][topic offers] is not yet implemented in LND. [LND
  #8764][] extends the previous PR by allowing the use of multiple blinded paths
  when paying an invoice, specifically to perform multipath payments
  ([MPP][topic multipath payments]). {% assign timestamp="1:13:40" %}

- [BIPs #1601][] merges [BIP94][] to introduce testnet4, a new version of
  [testnet][topic testnet] that includes consensus rule improvements aimed at
  preventing easy-to-perform network attacks. All previous mainnet soft forks are
  enabled from the genesis block in testnet4, and the port used is `48333` by
  default. See Newsletters [#306][news306 testnet4] and [#311][news311 testnet4]
  for more details on how testnet4 fixes the issues that led to problematic behavior with
  testnet3. {% assign timestamp="1:14:44" %}

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30493,30285,30352,30562,7476,2884,8952,8735,8764,1601,29775" %}
[BDK 1.0.0-beta.1]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.1
[libsecp256k1 0.5.1]: https://github.com/bitcoin-core/secp256k1/releases/tag/v0.5.1
[news274 cycle mitigate]: /en/newsletters/2023/10/25/#deployed-mitigations-in-ln-nodes-for-replacement-cycling
[dark skippy]: https://darkskippy.com/
[news87 anti-exfil]: /en/newsletters/2020/03/04/#proposal-to-standardize-an-exfiltration-resistant-nonce-protocol
[news136 anti-exfil]: /en/newsletters/2021/02/17/#anti-exfiltration
[towns withholding]: https://mailing-list.bitcoindevs.xyz/bitcoindev/Zp%2FGADXa8J146Qqn@erisian.com.au/
[0xb10c compact]: https://delvingbitcoin.org/t/stats-on-compact-block-reconstructions/1052
[maxwell reconstruct]: https://github.com/bitcoin/bitcoin/pull/30493#issuecomment-2260918779
[todd cycle]: https://mailing-list.bitcoindevs.xyz/bitcoindev/ZqyQtNEOZVgTRw2N@petertodd.org/
[dhakshinamoorthy frost]: https://mailing-list.bitcoindevs.xyz/bitcoindev/740e2584-5b6c-47f6-832e-76928bf613efn@googlegroups.com/
[frost sign bip]: https://github.com/siv2r/bip-frost-signing
[halseth zkelf]: https://delvingbitcoin.org/t/optimistic-zk-verification-using-matt/1050
[ocean pool]: https://ocean.xyz/blocktemplate
[rosenfeld pool]: https://bitcoil.co.il/pool_analysis.pdf
[elftrace]: https://github.com/halseth/elftrace
[news306 testnet]: /en/newsletters/2024/06/07/#bip-and-experimental-implementation-of-testnet4
[news312 chilldkg]: /en/newsletters/2024/07/19/#distributed-key-generation-protocol-for-frost
[bip125 github]: https://github.com/bitcoin/bips/blob/master/bip-0125.mediawiki
[news208 fullrbf]: /en/newsletters/2022/07/13/#bitcoin-core-25353
[news263 fullrbf]: /en/newsletters/2023/08/09/#full-rbf-by-default
[wuille cluster]: https://delvingbitcoin.org/t/introduction-to-cluster-linearization/1032
[news314 cluster]: /en/newsletters/2024/08/02/#bitcoin-core-30126
[bolt12 spec]: https://github.com/lightning/bolts/pull/798
[news257 eclair]: /en/newsletters/2023/06/28/#eclair-2701
[news306 testnet4]: /en/newsletters/2024/06/07/#bip-and-experimental-implementation-of-testnet4
[news311 testnet4]: /en/newsletters/2024/07/12/#bitcoin-core-pr-review-club
[news277 p2a]: /en/newsletters/2023/11/15/#eliminating-malleability-from-ephemeral-anchor-spends
[review club 30352]: https://bitcoincore.reviews/30352
[gh instagibbs]: https://github.com/instagibbs
[mempool bc1pfeessrawgf]: https://mempool.space/address/bc1pfeessrawgf
[gh isstandard]: https://github.com/bitcoin/bitcoin/blob/fa0b5d68823b69f4861b002bbfac2fd36ed46356/src/policy/policy.cpp#L7
[gh areinputsstandard]: https://github.com/bitcoin/bitcoin/blob/fa0b5d68823b69f4861b002bbfac2fd36ed46356/src/policy/policy.cpp#L177
[gh 30352 3rd commit]: https://github.com/bitcoin-core-review-club/bitcoin/commit/ccad5a5728c8916f8cec09e838839775a6026293#diff-ea6d307faa4ec9dfa5abcf6858bc19603079f2b8e110e1d62da4df98f4bdb9c0R228-R232
