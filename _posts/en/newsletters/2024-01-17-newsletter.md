---
title: 'Bitcoin Optech Newsletter #285'
permalink: /en/newsletters/2024/01/17/
name: 2024-01-17-newsletter
slug: 2024-01-17-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter discloses a past vulnerability affecting Core
Lightning, announces two new soft fork proposals, provides an overview
of the cluster mempool proposal, relays information about an updated
specification and implementation of transaction compression, and
summarizes a discussion about Miner Extractable Value (MEV) in non-zero
ephemeral anchors.  Also included are our regular sections with the
announcements of new releases and descriptions of notable changes to
popular Bitcoin infrastructure software.

## News

- **Disclosure of past vulnerability in Core Lightning:** Matt Morehouse
  used Delving Bitcoin to [announce][morehouse delving] a vulnerability
  he had previously [responsibly disclosed][topic responsible
  disclosures] that affected Core Lightning versions 23.02 through
  23.05.2.  More recent versions of 23.08 or higher are not affected.

  The new vulnerability was discovered by Morehouse's following up on
  his prior work on fake funding, which he also responsibly disclosed
  (see [Newsletter #266][news266 lnbugs]).  When re-testing nodes that
  had implemented fixes for fake funding, he triggered a [race
  condition][] that crashed CLN with about 30 seconds of effort.  If
  an LN node is offline, it can't defend a user against malicious or
  broken counterparties, which puts the user's funds at risk.
  Analysis indicated that CLN had fixed the original fake funding
  vulnerability but was unable to safely include a test for it before
  the vulnerability was disclosed, resulting in the subsequent merge of a
  plugin introducing the exploitable race condition.  After
  Morehouse's disclosure, a quick patch was merged in CLN to prevent
  the race condition from crashing the node.

  For more information, we recommend reading Morehouse's excellent
  [full disclosure][morehouse full] blog post. {% assign timestamp="2:15" %}

- **New LNHANCE combination soft fork proposed:** Brandon Black
  [posted][black lnhance] to Delving Bitcoin details about a soft fork
  that combines previous proposals for [OP_CHECKTEMPLATEVERIFY][topic
  op_checktemplateverify] (CTV) and [OP_CHECKSIGFROMSTACK][topic
  op_checksigfromstack] (CSFS) with a new proposal for an
  `OP_INTERNALKEY` that places the [taproot internal key][] on the stack.
  Authors of scripts must know the internal key before they can pay to
  an output, so they could directly include an internal key in a script.
  However, `OP_INTERNALKEY` is a simplified version of an [old suggestion][rubin templating]
  from CTV's original author, Jeremy Rubin, to save several vbytes and
  potentially make scripts more reusable by allowing the value of the
  key to be retrieved from the script interpreter.

  In the thread, Black and others describe some of the protocols that
  would be enabled by this combination of consensus changes:
  [LN-Symmetry][topic eltoo] (eltoo), [Ark][topic ark]-style
  [joinpools][topic joinpools], reduced-signature [DLCs][topic dlc],
  and [vaults][topic vaults] without presigned transactions, among
  other described benefits of the underlying proposals, such as
  CTV-style congestion control and CSFS-style signature delegation.

  As of this writing, technical discussion was limited to the request
  about what protocols the combination proposal would enable. {% assign timestamp="4:59" %}

- **Proposal for 64-bit arithmetic soft fork:** Chris Stewart
  [posted][stewart 64] a [draft BIP][bip 64] to Delving Bitcoin for
  enabling 64-bit arithmetic operations on Bitcoin in a future soft
  fork.  Bitcoin [currently][script wiki] only allows 32-bit operations
  (using signed integers, so numbers over 31 bits can't be used).
  Support for 64-bit values would be especially useful in any
  construction that needs to operate on the number of satoshis paid in
  an output, as that is specified using a 64-bit integer.  For example,
  [joinpool][topic joinpools] exit protocols would benefit from amount
  introspection (see Newsletters [#166][news166 tluv] and [#283][news283
  exits]).

  As of this writing, discussion was focused on details of the
  proposal, such as how to encode the integer value, what
  [taproot][topic taproot] upgrade feature to use, and whether
  creating a new set of arithmetic opcodes is preferred to upgrading
  existing ones. {% assign timestamp="21:08" %}

- **Overview of cluster mempool proposal:** Suhas Daftuar
  [posted][daftuar cluster] a summary of the [cluster mempool][topic
  cluster mempool] proposal to Delving Bitcoin.  Optech attempted to
  summarize the current state of cluster mempool discussion in
  [Newsletter #280][news280 cluster] but we would strongly recommend
  reading the overview by Daftuar, who is one of the architects of the
  proposal.  One detail we have not previously covered caught our
  attention:

  - *CPFP carve out needs to be removed:* the [CPFP carve out][topic
    cpfp carve out] mempool policy added to Bitcoin Core in [2019][news56 carveout]
    attempts to address the CPFP version of [transaction
    pinning][topic transaction pinning] where a counterparty attacker
    uses Bitcoin Core's limits on the number and size of related
    transactions to delay consideration of a child transaction
    belonging to an honest peer.  The carve out allows one transaction
    to slightly exceed the limits.  In cluster mempool, related
    transactions are placed in a cluster and the limits are applied
    per cluster, not per transaction.  Under that policy, there's no
    known way to ensure a cluster only contains a maximum of one carve
    out unless we restrict the relationships allowed between
    transactions relayed on the network far beyond the current
    restrictions.  A cluster with multiple carve outs could
    significantly exceed its limits, at which point the protocol would
    need to be engineered for those much higher limits. That would
    accommodate users of carve outs but restrict what regular
    transaction broadcasters can do---an undesirable proposition.

    A proposed solution to the incompatibility between carve out and
    cluster mempool is [v3 transaction relay][topic v3 transaction
    relay], which would allow regular users of v1 and v2 transactions
    to continue using them in all the historically typical ways, but
    also allow the users of contract protocols like LN to opt in to v3
    transactions that enforce a restricted set of relationships
    between transactions (_topology_).  The restricted topology would
    mitigate transaction pinning attacks
    and could be combined with nearly drop-in replacements for carve
    out transactions such as [ephemeral anchors][topic ephemeral
    anchors].

  It's important that a major change to Bitcoin Core's mempool
  management algorithms take into account all the ways people use
  Bitcoin today, or may use it in the near future, so we would encourage
  developers working on software for mining, wallets, or contract
  protocols to read Daftuar's description and ask questions about
  anything that's not clear or which might adversely affect how Bitcoin
  software will interact with cluster mempool. {% assign timestamp="38:25" %}

- **Updated specification and implementation of Bitcoin transaction compression:**
  Tom Briar [posted][briar compress] to the Bitcoin-Dev mailing list an
  updated [draft specification][compress spec] and [proposed
  implementation][bitcoin core #28134] of compressed Bitcoin
  transactions.  Smaller transactions would be more practical to relay
  through bandwidth-constrained mediums, such as by satellite or through
  steganography (e.g., encoding a transaction in a bitmap image).  See
  [Newsletter #267][news267 compress] for our description of the
  original proposal.  Briar describes the notable changes: "removing the
  grinding of the nLocktime in favor of a relative block height, which
  all of the compressed inputs use, and the use of a second kind of
  variable integer." {% assign timestamp="45:22" %}

- **Discussion of Miner Extractable Value (MEV) in non-zero ephemeral anchors:**
  Gregory Sanders [posted][sanders mev] to Delving Bitcoin to discuss
  concerns about [ephemeral anchor][topic ephemeral anchors] outputs
  that contain more than 0 satoshis.  An ephemeral anchor pays to a
  standardized output script that anyone can spend.

  One way to use ephemeral anchors would be for them to have a zero
  output amount, which is reasonable given that the policy rules for
  them require that they be accompanied by a child transaction spending
  the anchor output.  However, in the current LN protocol, when a party
  wants to create an [uneconomic][topic uneconomical outputs] HTLC, the
  payment amount is instead used to overpay the commitment transaction's
  onchain fees; this is called a _trimmed HTLC_.  If HTLC trimming is
  done in a commitment transaction using ephemeral anchors, it could be
  profitable for a miner to confirm the commitment transaction without a
  child transaction that spends the ephemeral anchor output.  Once a
  commitment transaction is confirmed, there's no incentive for anyone
  to spend a zero-amount ephemeral anchor output, meaning it will
  consume space in full node UTXO sets forever, an undesirable outcome.

  A proposed alternative is to put the trimmed HTLC amounts into the
  value of the ephemeral anchor outputs.  That way they incentivize
  confirming both the commitment transaction and a spend of the
  ephemeral anchor output.  In his post, Sanders analyzes this
  possibility and finds that this can create several security problems.
  These can be solved by miners analyzing transactions, determining when
  it would be more profitable for them to spend an ephemeral anchor
  output themselves, and creating the necessary transaction.  This is a
  type of [miner extractable value][news201 mev] (MEV).  Several
  alternative solutions were also proposed:

  - *Only relaying transactions that are fully miner incentive compatible:*
    if anyone attempts to spend an ephemeral anchor in a way that
    doesn't maximize revenue for a miner, that transaction would not be
    relayed by Bitcoin Core.

  - *Burn trimmed value:* instead of turning the amount of trimmed HTLCs
    into fees, the amount would instead be spent to an `OP_RETURN`
    output, destroying those satoshis by making them permanently
    unspendable.  This would only happen if a commitment transaction
    containing a trimmed HTLC was put onchain; normally trimmed HTLCs
    are resolved offchain and their value is successfully transferred from
    one party to the other.

  - *Ensure MEV transactions propagate easily:* instead of having miners
    run special code that maximizes their value, ensure that
    transactions maximizing their value propagate easily through the
    network.  That way anyone can run the MEV code and relay the results
    to miners in a way that ensures all miners and relay nodes can
    obtain the same set of transactions.

  No clear conclusion has been reached at the time of writing. {% assign timestamp="46:51" %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LDK 0.0.119][] is a new release of this library for building
  LN-enabled applications.  Multiple new features are added, including
  receiving payments to multi-hop [blinded paths][topic rv routing],
  along with multiple bug fixes and other improvements. {% assign timestamp="56:24" %}

## Notable code and documentation changes

*Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #29058][] is a preparation step to activate
  [version 2 P2P transport (BIP324)][topic v2 p2p transport] by default.
  This patch adds v2transport support for `-connect`, `-addnode`, and
  `-seednode` configuration arguments if `-v2transport` is enabled and
  reconnects with v1 if the peer does not support v2. Additionally,
  this update adds a column displaying the transport protocol version
  to the `netinfo` peer connection `bitcoin-cli` dashboard. {% assign timestamp="57:17" %}

- [Bitcoin Core #29200][] allows the [I2P network support][topic
  anonymity networks] to use connections encrypted using "ECIES-X25519
  and ElGamal (types 4 and, 0, respectively). This allows to connect to
  I2P peers of either type, and the newer, faster ECIES-X25519 will be
  preferred." {% assign timestamp="58:59" %}

- [Bitcoin Core #28890][] removes the `-rpcserialversion` configuration
  parameter that was previously deprecated (see [Newsletter
  #269][news269 rpc]).  This option was introduced during the transition
  to v0 segwit to allow older programs to continue to access blocks and
  transactions in stripped format (without any segwit fields). At this
  point, all programs should be updated to handle segwit transactions
  and this option should no longer be needed. {% assign timestamp="1:00:08" %}

- [Eclair #2808][] updates the `open` command with  a
  `--fundingFeeBudgetSatoshis` parameter that defines the maximum amount
  the node is willing to pay in onchain fees to open a channel, with the
  default set to 0.1% of the amount paid into the channel.  Eclair will
  try to pay a lower fee if possible, but it will pay up to the budgeted
  amount if necessary.  The `rbfopen` command is also updated to accept
  the same parameter which defines the maximum amount to spend on [RBF
  fee bumping][topic rbf]. {% assign timestamp="1:01:25" %}

- [LND #8188][] adds several new RPCs for quickly obtaining debugging
  information, encrypting it to a public key, and decrypting it given a
  private key.  As the PR explains, "The idea is that we would publish a
  public key in the GitHub issue template and would ask users to run the
  `lncli encryptdebugpackage` command and upload the encrypted output
  files to the GitHub issue to provide us with the information we
  normally require to debug user problems." {% assign timestamp="1:02:09" %}

- [LND #8096][] adds a "fee spike buffer".  In the current LN protocol,
  the party who single-funded a channel is responsible for paying
  any onchain fees directly <!-- endogenously --> included in the
  commitment transaction and the presigned HTLC-Success and HTLC-Timeout
  transactions (HTLC-X transactions).  If the funding party is low on
  funds in the channel and if feerates rise, the funding party may
  not be able to accept a new incoming payment because they don't have
  enough funds to pay for its fees---this is despite the fact that an
  incoming payment would increase the funding party's balance, if the
  payment settles.  To avoid this type of stuck-channel problem, a
  recommendation in [BOLT2][] (added several years ago in [BOLTs
  #740][]) suggests the funder voluntarily keep an extra reserve of
  funds to ensure an additional payment can be received even if feerates
  rise.  LND now implements this solution, which is also implemented by
  Core Lightning and Eclair (see Newsletters [#85][news85 stuck] and
  [#89][news89 stuck]). {% assign timestamp="1:07:44" %}

- [LND #8095][] and [#8142][lnd #8142] add additional logic to parts of
  LND's codebase for handling [blinded paths][topic rv routing].  This is
  part of ongoing work to add full support for blinded paths to LND. {% assign timestamp="1:09:08" %}

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28134,29058,29200,28890,2808,8188,8096,8095,8142,740" %}
[morehouse delving]: https://delvingbitcoin.org/t/dos-disclosure-channel-open-race-in-cln/385
[morehouse blog]: https://morehouse.github.io/lightning/cln-channel-open-race/
[news266 dos]: /en/newsletters/2023/08/30/#disclosure-of-past-ln-vulnerability-related-to-fake-funding
[script wiki]: https://en.bitcoin.it/wiki/Script#Arithmetic
[news166 tluv]: /en/newsletters/2021/09/15/#amount-introspection
[news283 exits]: /en/newsletters/2024/01/03/#pool-exit-payment-batching-with-delegation-using-fraud-proofs
[daftuar cluster]: https://delvingbitcoin.org/t/an-overview-of-the-cluster-mempool-proposal/393/
[news280 cluster]: /en/newsletters/2023/12/06/#cluster-mempool-discussion
[news267 compress]: /en/newsletters/2023/09/06/#bitcoin-transaction-compression
[briar compress]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-January/022274.html
[compress spec]: https://github.com/bitcoin/bitcoin/blob/7e8511c1a8229736d58bd904595815636f410aa8/doc/compressed_transactions.md
[news201 mev]: /en/newsletters/2022/05/25/#miner-extractable-value-discussion
[news266 lnbugs]: /en/newsletters/2023/08/30/#disclosure-of-past-ln-vulnerability-related-to-fake-funding
[race condition]: https://en.wikipedia.org/wiki/Race_condition
[morehouse full]: https://morehouse.github.io/lightning/cln-channel-open-race/
[black lnhance]: https://delvingbitcoin.org/t/lnhance-bips-and-implementation/376/
[stewart 64]: https://delvingbitcoin.org/t/64-bit-arithmetic-soft-fork/397/
[daftuar cluster]: https://delvingbitcoin.org/t/an-overview-of-the-cluster-mempool-proposal/393/
[sanders mev]: https://delvingbitcoin.org/t/ephemeral-anchors-and-mev/383/
[bip 64]: https://github.com/bitcoin/bips/pull/1538
[taproot internal key]: /en/newsletters/2019/05/14/#complex-spending-with-taproot
[news56 carveout]: /en/newsletters/2019/07/24/#bitcoin-core-15681
[news269 rpc]: /en/newsletters/2023/09/20/#bitcoin-core-28448
[news85 stuck]: /en/newsletters/2020/02/19/#c-lightning-3500
[news89 stuck]: /en/newsletters/2020/03/18/#eclair-1319
[ldk 0.0.119]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.119
[rubin templating]: https://freenode.irclog.whitequark.org/bitcoin-wizards/2019-05-24#24661606;
