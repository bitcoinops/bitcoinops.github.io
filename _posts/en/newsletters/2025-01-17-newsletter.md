---
title: 'Bitcoin Optech Newsletter #337'
permalink: /en/newsletters/2025/01/17/
name: 2025-01-17-newsletter
slug: 2025-01-17-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes continued discussion about rewarding
pool miners with tradeable ecash shares and describes a new proposal for
enabling offchain resolution of DLCs.  Also included are our regular
sections announcing new releases and release candidates and describing
notable changes to popular Bitcoin infrastructure software.

## News

- **Continued discussion about rewarding pool miners with tradeable ecash shares:**
  [discussion][ecash tides] continued since our [previous
  summary][news304 ecashtides] of a Delving Bitcoin thread about paying
  [pool miners][topic pooled mining] with ecash for each share they
  submitted.  Previously, Matt Corallo [asked][corallo whyecash] why a
  pool would implement the extra code and accounting to handle tradable ecash
  shares when they could simply pay miners using a normal ecash mint (or
  via LN).  David Caseria [replied][caseria pplns] that in some _pay per
  last N shares_ ([PPLNS][topic pplns]) schemes, such as
  [TIDES][recap291 tides], a miner might need to wait for the pool to
  find several blocks, which might take days or weeks for a small pool.
  Instead of waiting, a miner with ecash shares could immediately sell
  them on an open market (without disclosing to the pool or any third
  party anything about their identity, not even any ephemeral identity
  they used when mining).

  Caseria also noted that existing mining pools find it financially
  challenging to support the _full paid per share_ ([FPPS][topic fpps])
  scheme where a miner is paid proportional to the entire block reward
  (subsidy plus transaction fees) when they create a share.  He didn't
  elaborate, but we understand the problem to be variance in fees
  forcing pools to keep large reserves.  For example, if a pool miner
  controls 1% of hashrate and creates shares on a template with about
  1,000 BTC in fees and 3 BTC in subsidy, they would be owed by their
  pool about 10 BTC.  However, if the pool doesn't mine that block and,
  when they do mine a block, fees are back down to a fraction of the
  block reward, the pool might only have 3 BTC total to split between
  all of its miners, forcing it to pay from its reserves.  If that
  happens too many times, the pool's reserves will be exhausted and it
  will go out of business.  Pools address this in various ways,
  including using [proxies for actual fees][news304 fpps proxy].

  Developer vnprc [described][vnprc ehash] the solution he's been
  [building][hashpool] that focuses on ecash shares received in the
  PPLNS payout scheme.  He thinks this could be especially useful for
  launching new pools: right now, the first miner to join a pool suffers
  the same high variance as solo mining, so typically the only people
  who can start a pool are existing large miners or those willing to
  rent significant hashrate.  However, with PPLNS ecash shares, vnprc
  thinks a pool could launch as a client of a larger pool, so even the
  first miner to join the new pool would receive lower variance than
  solo mining.  The intermediate pool could then sell the ecash shares
  it earns to finance whatever payout scheme it chooses to pay
  its miners.  Once the intermediate pool acquired a
  significant amount of hashrate, it would also have leverage for
  negotiating with larger pools about creating alternative block
  templates that suit its miners.

- **Offchain DLCs:** developer conduition [posted][conduition offchain]
  to the DLC-dev mailing list about a contract protocol that allows an
  offchain spend of the funding transaction signed by both parties to
  create multiple [DLCs][topic dlc].  After the offchain DLC has settled
  (e.g., all required oracle signatures have been obtained), a new
  offchain spend can be signed by both parties to reallocate funds
  according to the contract resolution.  A third alternative spend can
  then allocate the funds to new DLCs.

  Replies by Kulpreet Singh and Philipp Hoenisch linked to previous
  research and development of this basic idea, including approaches that
  allow the same pool of funds to be used for both offchain DLCs and
  LN (see Newsletters [#174][news174 dlc-ln] and [#260][news260 dlc]).
  A [reply][conduition offchain2] from conduition described his
  proposal's major difference from previous proposals.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [LDK v0.1][] is a milestone release of this library for building
  LN-enabled wallets and applications.  New features include "support
  for both sides of the LSPS channel open negotiation protocols, [...]
  includes support for [BIP353][] Human Readable Names resolution, [and
  a reduction in] on-chain fee costs when resolving multiple HTLCs for a
  single channel force-closure."

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Eclair #2936][] introduces a 12-block delay before marking a channel as
  closed after its funding output has been spent to allow for the propagation of
  a [splice][topic splicing] update (see Newsletter [#214][news214
  splicing] and an Eclair developer's description of the [motivation][tbast splice]).
  Spent channels are temporarily tracked in a new `spentChannels` map, where
  they are either removed after 12 blocks or updated as spliced channels. When a
  splice occurs, the parent channel's short channel identifier (SCID), capacity,
  and balance bounds are updated instead of creating a new channel.

- [Rust Bitcoin #3792][] adds ability to encode and decode [BIP324][]’s [v2 P2P
  transport][topic v2 P2P transport] messages (see Newsletter [#306][news306 v2]).
  This is achieved by adding a `V2NetworkMessage` struct, which wraps the original
  `NetworkMessage` enum and provides v2 encoding and decoding.

- [BDK #1789][] updates the default transaction version from 1 to 2 to improve
  wallet privacy.  Prior to this, BDK wallets were more identifiable due to
  only 15% of the network using version 1. In addition, version 2 is required
  for a future implementation of [BIP326][]’s nSequence-based [anti fee
  sniping][topic fee sniping] mechanism for [taproot][topic taproot]
  transactions.

- [BIPs #1687][] merges [BIP375][] to specify sending [silent payments][topic
  silent payments] using [PSBTs][topic psbt]. If there are multiple independent
  signers, a [DLEQ][topic dleq] proof is required to allow all signers to prove to co-signers
  that their signature doesn’t misspend funds, without revealing
  their private key (see [Newsletter #335][news335 dleq] and [Recap
  #327][recap327 dleq]).

- [BIPs #1396][] updates [BIP78][]’s [payjoin][topic payjoin] specification to
  align with [BIP174][]’s [PSBT][topic psbt] specification, resolving a previous
  conflict. In BIP78, a receiver previously deleted UTXO data after completing
  its inputs, even if the sender needed the data. With this update, UTXO data is
  now retained.

{% include snippets/recap-ad.md when="2025-01-21 15:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3792,1789,1687,1396,2936" %}
[ldk v0.1]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.1
[news174 dlc-ln]: /en/newsletters/2021/11/10/#dlcs-over-ln
[news260 dlc]: /en/newsletters/2023/07/19/#wallet-10101-beta-testing-pooling-funds-between-ln-and-dlcs
[ecash tides]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870
[news304 ecashtides]: /en/newsletters/2024/05/24/#challenges-in-rewarding-pool-miners
[corallo whyecash]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870/27
[caseria pplns]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870/29
[recap291 tides]: /en/podcast/2024/02/29/#how-does-ocean-s-tides-payout-scheme-work-transcript
[vnprc ehash]: https://delvingbitcoin.org/t/ecash-tides-using-cashu-and-stratum-v2/870/32
[hashpool]: https://github.com/vnprc/hashpool
[conduition offchain]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000186.html
[news304 fpps proxy]: /en/newsletters/2024/05/24/#pay-per-share-pps
[tbast splice]: https://github.com/ACINQ/eclair/pull/2936#issuecomment-2595930679
[conduition offchain2]: https://mailmanlists.org/pipermail/dlc-dev/2025-January/000189.html
[news214 splicing]: /en/newsletters/2022/08/24/#bolts-1004
[news306 v2]: /en/newsletters/2024/06/07/#rust-bitcoin-2644
[news335 dleq]: /en/newsletters/2025/01/03/#bips-1689
[recap327 dleq]: /en/podcast/2024/11/05/#draft-bip-for-dleq-proofs
