---
title: 'Bitcoin Optech Newsletter #315'
permalink: /en/newsletters/2024/08/09/
name: 2024-08-09-newsletter
slug: 2024-08-09-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter FIXME:harding

## News

- **Faster key exfiltration attack:** Lloyd Fournier, Nick Farrow, and
  Robin Linus announced [Dark Skippy][], an improved method for key
  exfiltration from a Bitcoin signing device.  _Key exfiltration_ occurs
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
  to the internet.  A device that has had its logic corrupted, either
  through its firmware or through hardware logic, can now exfiltrate a
  seed even if the device is never connected to a computer (e.g. all
  data is transferred using NFC, SD cards, or QR codes).

  Methods of performing [exfiltration resistant signing][topic
  exfiltration resistant signing] for Bitcoin have been discussed
  (including in Optech newsletters as far back as [Newsletter
  #87][news87 anti-exfil]) and are currently implemented in two hardware
  signing devices that we are aware of (see [Newsletter #136][news136
  anti-exfil]).  That deployed method does require an extra round trip
  of communication with the hardware signing device compared to standard
  single-sig signing, although that may be less of a downside if users
  become accustomed to other types of signing, such as [scriptless
  multisignatures][topic multisignature], that also require additional
  round trips of communication.  Alternative methods of exfiltration
  resistant signing that offer different tradeoffs are also known,
  although none has been implemented in Bitcoin hardware signing devices
  to our knowledge.

  Optech recommends that anyone using hardware signing devices to protect
  substantial amounts of money take steps to prepare against corrupted
  hardware or firmware, either through the use of exfiltration resistant
  signing or though the use of multiple independent devices (e.g. with
  scripted or scriptless multisignature or threshold signing).

<!-- FIXME:harding add Meni's reference for block withholding attack to topic page -->

- **Block withholding attacks and potential solutions:**
  Anthony Towns [posted][towns withholding] to the Bitcoin-Dev mailing
  list to discuss the [block withholding attack][topic block
  withholding], a related _invalid shares_ attack, and potential
  solutions to both attacks---including disabling client work selection
  in [Stratum v2][topic pooled mining] and oblivious shares.

  Pool miners are paid for submitting units of work, called _shares_,
  each of which is a _candidate block_ that contains a certain amount of
  proof of work (PoW).  The expectation is that a portion of those
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
  miners to include a different set of transaction in their candidate
  blocks than what the pool suggests mining.  The pool miner can even
  attempt mining transactions that the pool doesn't have.  This can make
  it expensive for the pool to validate miner shares: each share can
  contain up to several megabytes of transactions that the pool has
  never seen before, with potentially all of them being transactions
  designed to be slow to validate.  That can easily overwhelm a pool's
  infrastructure, affecting its ability to accept shares from honest
  users.

  Pools can avoid this problem by only validating share PoW, skipping
  transaction validation, but that allows a pool miner to collect
  payment for submitting invalid shares 100% of the time, which is
  slightly worse than the approximately 99.9% of the time they can
  collect payment from a classic block withholding attack.

  This incentivizes pools to either forbid client transaction selection
  or to require pool miners use a public identity so that bad actors can
  be banned.

  One solution Towns proposes is for pools to provide multiple block
  templates, allowing each miner to choose their preferred template.
  This is similar to the existing system used by [Ocean Pool][].  Shares
  submitted based on a pool-created templates can be validated quickly
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

  - *Requires pool miners use a private template from the pool:* not
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
  become more decentralized.

- **Statistics on compact block reconstruction:** developer 0xB10C
  [posted][0xb10c compact] to Delving Bitcoin about the recent
  reliability of [compact block][topic compact block relay]
  reconstruction.  Many relaying full nodes have been using [BIP152][]
  compact block relay since the feature was added to Bitcoin Core 0.13.0
  in 2016.  This allows two peers which have already shared some
  unconfirmed transactions to use a short reference to those
  transactions when they are confirmed in a new block rather than
  re-transmitting the entire transaction.  This significantly reduces
  bandwidth and, by doing so, also reduces latency---allowing new blocks
  to propagate more quickly.

  Faster propagation of new blocks decreases the number of accidental
  blockchain forks.  Fewer forks reduces the amount of proof-of-work that
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
  `mempoolfullrbf` by default in an upcoming version of Bitcoin Core.

<!-- FIXME:harding update ephemeral anchors topic to include P2A -->

- **Replacement cycle attack against pay-to-anchor:** Peter Todd
  [posted][todd cycle] to the Bitcoin-Dev mailing list about the
  pay-to-anchor (P2A) output type that is part of the [ephemeral
  anchors][topic ephemeral anchors] proposal.  P2A is an transaction
  output that anyone can spend.  This can be useful for [CPFP][topic
  cpfp] fee bumping---especially in multiparty protocols such as LN.
  However, CPFP fee bumping in LN is currently vulnerable to a
  counterparty performing a [replacement cycling attack][topic
  replacement cycling] where the malicious counterparty perfroms a
  two-step process.  They first replace an honest user's version of a
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
  feerate higher than the honest user's P2A spend and the attacker is
  able to successfully complete the replacement cycle without their
  intermediate state getting confirmed by miners.  All existing deployed
  LN mitigations against replacement cycling attacks (see [Newsletter
  #274][news274 cycle mitigate]) will be equally effective at defeating
  P2A replacement cycling.

- **Proposed BIP for scriptless threshold signatures:** Sivaram
  Dhakshinamoorthy [posted][dhakshinamoorthy frost] to the Bitcoin-Dev
  mailing list to announce the availability of a [proposed BIP][frost
  sign bip] for creating [scriptless threshold signatures][topic
  threshold signature] for Bitcoin's implementation of [schnorr
  signatures][topic schnorr signatures].  This allows a set of wallets
  that have already performed a set up procedure to securely create
  signatures that only require interaction from a dynamic subset of
  those wallets.  The signatures are indistinguishable onchain from
  schnorr signatures created by single-sig users and scriptless
  multisignature users, improving privacy and fungibility.

- **Optimistic verification of zero-knowledge proofs using CAT, MATT, and Elftrace:**
  Johan T. Halseth [posted][halseth zkelf] to Delving Bitcoin to
  announce that his tool, [Elftrace][], now has the ability to verify
  zero-knowledge (ZK) proofs.  For this to be useful onchain, both
  [OP_CAT][topic op_cat] and the [MATT][topic acc] proposed soft forks
  would need to be activated.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

FIXME:stickies-v

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/29775#l-29FIXME"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Libsecp256k1 0.5.1][] FIXME:harding

- [BDK 1.0.0-beta.1][] is a release candidate for "the first beta version of
  `bdk_wallet` with a stable 1.0.0 API".  FIXME:harding update

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

- [Bitcoin Core #30493][] policy: enable full-rbf by default

- [Bitcoin Core #30285][] Merge bitcoin/bitcoin#30285: cluster mempool: merging & postprocessing of linearizations <!-- just a quick mention to let readers know that cluster mempool progress is being made quickly -->

- [Bitcoin Core #30352][] and [#30562][bitcoin core #30562] policy: Add PayToAnchor(P2A), `OP_1 <0x4e73>` as a standard output script for spending Also #30562

- [Bitcoin Core #29775][] adds a `testnet4` configuration option that
  will set the network to [testnet4][topic testnet] as specified in
  [BIP94][].  Testnet4 includes fixes several problems with the previous
  testnet3 (see [Newsletter #306][news306 testnet]).  The existing
  Bitcoin Core `testnet` configuration option that uses testnet3 remains
  available but is expected to be deprecated and removed in subsequent
  releases.

- [Core Lightning #7476][]
  - common/bolt12: allow missing offer_issuer_id.
  - BOLT12: reject zero-length blinded paths.

- [Eclair #2884][] Add HTLC endorsement/confidence
  Implements https://github.com/lightning/blips/pull/27


- [LND #8952][] ProofOfKeags/refactor/lnwallet-channel-typed-list <!-- quick mention to let people know that https://bitcoinops.org/en/topics/channel-commitment-upgrades/ is being worked on -->

- [LND #8735][] and [#8764][lnd #8764] Route Blinding

- [BIPs #1601][] Add BIP94: Testnet 4

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
