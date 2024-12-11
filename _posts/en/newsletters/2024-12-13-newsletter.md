---
title: 'Bitcoin Optech Newsletter #333'
permalink: /en/newsletters/2024/12/13/
name: 2024-12-13-newsletter
slug: 2024-12-13-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a vulnerability that allowed stealing
from old versions of various LN implementations, announces a
deanonymization vulnerability affecting Wasabi and related software,
summarizes a post and discussion about LN channel depletion, links to a
poll for opinions about selected covenant proposals, describes two types
of incentive-based pseudo-covenants, and references summaries of the
periodic in-person Bitcoin Core developer meeting.  Also included are our
regular sections summarizing a Bitcoin Core PR Review Club meeting,
listing changes to services and client software, linking to popular
Bitcoin Stack Exchange questions and answers, announcing new releases
and release candidates, and describing notable changes to popular
Bitcoin infrastructure software.

## News

- **Vulnerability allowing theft from LN channels with miner assistance:**
  David Harding [announced][harding irrev] to Delving Bitcoin a
  vulnerability he had [responsibly disclosed][topic responsible
  disclosures] earlier in the year.  Old versions of Eclair, LDK, and
  LND with default settings allowed the party who opened a channel to
  steal up to 98% of channel value.  Core Lightning remains affected if
  the non-default `--ignore-fee-limits` configuration option is used;
  this option's documentation already indicates it is dangerous.

  The announcement also described two less severe variants of the vulnerability.
  All LN implementations listed above attempt to mitigate those
  additional risks, but a complete solution awaits additional work on
  [package relay][topic package relay], [channel upgrades][topic channel
  commitment upgrades], and related projects.

  The vulnerability takes advantage of the LN protocol allowing an old
  channel state to commit to more onchain fees than the
  fee-paying party controls in the latest state.  For example, in a
  state where Mallory controls 99% of the channel balance, she dedicates 98%
  of the overall balance to [endogenous][topic fee sourcing] fees.  She then
  creates a new state that pays only minimal fees and forwards 99% of
  the channel balance to Bob's side.  By personally mining the old state
  that pays 98% to fees, she can capture those fees for
  herself---reducing the maximum value Bob can receive onchain from his
  expected 99% to an actual 2%.  Mallory can use this method to
  simultaneously steal from about 3,000 channels per block (with each
  channel potentially controlled by a different victim), allowing theft
  of about $3 million USD per block if the average channel value is
  about $1,000 USD.

  Users who became aware of the attack before losing their funds would
  not have been able to protect themselves by shutting down their LN
  nodes, as Mallory may have already created the necessary states.  Even
  if the victims attempted to force close their channels in their latest
  state (e.g., where Bob controls 99% of channel value), Mallory could
  cause them to lose 98% of channel value by sacrificing 1% of channel
  value herself.

  The worst-case vulnerability was fixed, and the less severe variants
  partly mitigated, by limiting the maximum amount of channel value that
  can be dedicated to fees.  As fees in an earlier state are still
  allowed to be higher than the amount the fee-paying party controls in
  a later state, some theft is still possible---but the amount is
  bounded.  A complete solution awaits improvements in fully
  [exogenous][topic fee sourcing] fee sourcing (such as all states paying
  the same commitment transaction fee), which depends on robust package
  relay for [CPFP][topic cpfp] fee bumping in the Bitcoin P2P protocol
  and channel commitment transaction upgrades for LN.

- **Deanonymization vulnerability affecting Wasabi and related software:**
  a developer of GingerWallet [disclosed][drkgry deanon] a method a
  [coinjoin][topic coinjoin] coordinator could use to prevent users from
  gaining any privacy during a coinjoin.  Bitcoin Magazine journalist
  Shinobi [reports][shinobi deanon] that the vulnerability was
  originally discovered in 2021 by Yuval Kogman and [reported][wasabi
  #5439] to the Wasabi development team along with several other
  problems.  Optech has been aware since mid-2022 that Kogman had
  serious outstanding concerns with deployed versions of Wasabi but we
  neglected to investigate further; we apologize to him and Wasabi
  users for our failure.

- **Insights into channel depletion:** René Pickhardt [posted][pickhardt
  deplete] to Delving Bitcoin and [participated][dd deplete], along with
  Christian Decker, in an Optech Deep Dive about his research into the
  mathematical foundations of payment channel networks (namely LN).  A
  particular focus of his Delving Bitcoin post was a discovery that some
  channels in circular paths on the network will eventually become
  depleted if the path is used enough.  When a channel is effectively
  fully depleted, meaning it cannot forward additional payments in the
  depleted direction, the circular path (cycle) is broken.  As each
  cycle in the network graph is successively broken, the network
  converges on a residual graph that has no cycles (a spanning tree).
  This replicates a [prior result][guidi spanning] from researcher
  Gregorio Guidi, although Pickhardt arrived at it from a different
  approach, and also appears to be confirmed in unpublished research by
  Anastasios Sidiropoulos.

  ![Example of cycles, depletion, and residual spanning tree](/img/posts/2024-12-depletion.png)

  Perhaps the most notable insight provided by this result is that
  widespread channel depletion occurs even in a circular economy where
  there are no source nodes (i.e., net spenders) and sink nodes (i.e.,
  net receivers).  If LN was used for every
  payment---customer-to-business, business-to-business, and
  business-to-worker---it would still converge on a spanning tree.

  It's not clear whether nodes would want their channels to be part of
  the residual spanning tree or not.  On one hand, that tree represents
  the last part of the network that would still be capable of forwarding
  payments---it's equivalent to a hub-and-spoke topology---so it may be
  possible to charge high forwarding fees across the residual channels.
  On the other hand, the residual channels are what's left after all
  other channels have already collected fees to depletion.

  Although a channel with higher forwarding fees is less likely to
  become depleted (all other things being equal), the properties of
  other channels in the same cycles strongly influence the likelihood of
  depletion, making it challenging for a node operator to attempt to use
  control over their forwarding fees alone to prevent depletion.

  Higher capacity channels are also less likely to become depleted than
  lower capacity channels.  That seems obvious, but carefully
  considering the reason for it yields a surprising insight about k>2
  multiparty offchain protocols.  A higher capacity channel supports a
  greater number of wealth distributions between its participants, so
  payments through it remain feasible when equivalent payments through
  lower capacity channels would exhaust a party's balance.  For two
  participants, as in current-generation LN channels, each additional
  satoshi given to capacity will increase the range of the wealth
  distribution by one.  However, in [channel factories][topic channel
  factories] and other multiparty constructions that allow funds to move
  offchain between _k_ parties, each additional sat given to capacity
  increases the range of wealth distributions by one _for each of the
  k parties_---exponentially increasing the number of feasible payments and
  reducing the risk of depletion.

  Consider an example of the current LN where Alice has
  channels with Bob and Carol, who also have a channel with each
  other: {AB, AC, BC}.  Each channel has a capacity of 1 BTC.  In this
  configuration, the maximum value Alice can control (and thus send or
  receive) is 2 BTC.  The same limit applies to Bob and Carol.  These
  limits would also apply if the total of 3 BTC were used to recreate all
  three channels in a channel factory; however, if the factory
  remained operational, an offchain state update between all three
  parties could zero out the channel between Bob and Carol, allowing
  Alice to control up to the full 3 BTC (and thus she could send or
  receive up to 3 BTC).  A subsequent state update could do the same for
  Bob and Carol, also allowing them to send or receive up to 3 BTC.
  This use of multiparty offchain protocols allows the same amount of
  capital to give each participant access to higher-capacity channels
  that are less likely to become depleted.  Fewer depletions and an
  expanded range of feasible payments correspond to a greater maximum
  throughput of LN, as Pickhardt has written about before (see
  Newsletters [#309][news309 feasible] and [#325][news325 feasible]).

  In both his post and the Optech Deep Dive discussion, Pickhardt
  sought data (e.g., from large LSPs) that could be used to help
  validate the simulated results.

- **Poll of opinions about covenant proposals:** /dev/fd0 [posted][fd0
  poll] to the Bitcoin-Dev mailing list a link to a [public poll][wiki
  poll] of developer opinions about selected [covenant][topic covenants] proposals.  Yuval
  Kogman [noted][kogman poll] that developers were asked to evaluate
  both the "technical merit of [each] proposal" and their "vibes-based
  opinion about [its] community support," but without developers being
  able to express all possible combinations of the two through the
  poll's limited options.  Jonas Nick [requested][nick poll] "separating
  technical evaluations from community support," and Anthony Towns
  [suggested][towns poll] simply asking developers whether they had any
  outstanding concerns about each proposal.  Nick and Towns separately
  recommended developers link to evidence and arguments supporting their
  opinions.

  Although the discussion highlighted faults in the poll, a showing of more
  support for some proposals over others may help covenant
  researchers converge on a short list of ideas for the broader
  community to review.

- **Incentive-based pseudo-covenants:** Jeremy Rubin [posted][rubin
  unfed] to the Bitcoin-Dev mailing list a link to a [paper][rubin unfed
  paper] he authored about oracle-assisted [covenants][topic covenants].
  The model involves two oracles: a _covenant oracle_ and an _integrity
  oracle_.  The covenant oracle places funds in a fidelity bond and
  agrees to only sign transactions based on a program returning success.
  The integrity oracle can seize funds from a bond by using [accountable
  computing][topic acc] to prove a signature was created for a program
  that did not return success.  If fraud occurs, there is no guarantee
  that a user who lost money due to the covenant oracle's deceit will
  recover lost funds.

  Ethan Heilman independently [posted][heilman slash] to the Bitcoin-Dev
  mailing list a different construction that allows anyone to use a
  fraud proof to punish incorrect signing.  However, in this case, the
  funds are not seized but destroyed.  This ensures a fraudulent signer
  is punished but prevents victims from recovering their lost value.

- **Bitcoin Core developer meeting summaries:** many Bitcoin Core
  developers met in person in October, and several notes from the
  meeting have now been [published][coredev notes].  Discussions topics
  included [adding payjoin support][], creating [multiple binaries][]
  that communicate with each other, a [mining interface][] and [Stratum
  v2 support][], improved [benchmarking][] and [flamegraphs][], an [API
  for libbitcoinkernel][], preventing [block stalling][], improvements
  to [RPC code][] inspired by Core Lightning, resumed [development of
  erlay][], and [contemplating covenants][].

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

FIXME:stickies-v

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/30239#l-27FIXME"
%}

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME:bitschmidty

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Core Lightning 24.11][] is a release of the next major version of
  this popular LN implementation.  It contains an experimental new
  plugin for making payments that using advanced route selection; paying
  and receiving payments to [offers][topic offers] is enabled by
  default; and multiple improvements to [splicing][topic splicing] have been
  added, in addition to several other features and bug fixes.

- [BTCPay Server 2.0.4][] is a release of this payment processing
  software that includes multiple new features, refinements, and bug
  fixes.

- [LND 0.18.4-beta.rc2][] is a release candidate for a minor version of
  this popular LN implementation.

- [Bitcoin Core 28.1RC1][] is a release candidate for a maintenance
  version of the predominant full-node implementation.

- [BDK 1.0.0-beta.6][] is the last planned beta test release of this
  library for building Bitcoin wallets and other Bitcoin-enabled
  applications before the 1.0.0 release of `bdk_wallet`.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #31096][] Package validation: accept packages of size 1

- [Bitcoin Core #31175][] rpc: Remove submitblock pre-checks

- [Bitcoin Core #31112][] Improve parallel script validation error debug logging

- [LDK #3446][] Support Trampoline flag in BOLT12 invoices

- [Rust Bitcoin #3682][] Add API scripts and output files

- [BTCPay Server #5743][] Multisig/watchonly wallet transaction creation flow proof of concept

- [BDK #1756][] fix(electrum): prevent `fetch_prev_txout` from querying coinbase transactions

- [BIPs #1535][] BIP 348: OP_CHECKSIGFROMSTACK

- [BOLTs #1180][] and [BLIPs #48][] Include BIP 353 name info in `invoice_request`s

## Happy holidays!

This is Bitcoin Optech's final regular newsletter of the year.  On
Friday, December 20th, we'll publish our seventh annual year-in-review
newsletter.  Regular publication will resume on Friday, January 3rd.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="31096,31175,31112,3446,3682,5743,1756,1535,1180,48" %}
[core lightning 24.11]: https://github.com/ElementsProject/lightning/releases/tag/v24.11
[lnd 0.18.4-beta.rc2]: https://github.com/lightningnetwork/lnd/releases/tag/v0.18.4-beta.rc2
[eclair v0.11.0]: https://github.com/ACINQ/eclair/releases/tag/v0.11.0
[ldk v0.0.125]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.125
[bitcoin core 28.1RC1]: https://bitcoincore.org/bin/bitcoin-core-28.1/
[harding irrev]: https://delvingbitcoin.org/t/disclosure-irrevocable-fees-stealing-from-ln-using-revoked-commitment-transactions/1314
[pickhardt deplete]: https://delvingbitcoin.org/t/channel-depletion-ln-topology-cycles-and-rational-behavior-of-nodes/1259/6
[guidi spanning]: https://diyhpl.us/~bryan/irc/bitcoin/bitcoin-dev/linuxfoundation-pipermail/lightning-dev/2019-August/002115.txt
[news309 feasible]: /en/newsletters/2024/06/28/#estimating-the-likelihood-that-an-ln-payment-is-feasible
[news325 feasible]: /en/newsletters/2024/10/18/#research-on-fundamental-delivery-limits
[fd0 poll]: https://gnusha.org/pi/bitcoindev/028c0197-5c45-4929-83a9-cfe7c87d17f4n@googlegroups.com/
[wiki poll]: https://en.bitcoin.it/wiki/Covenants_support
[kogman poll]: https://gnusha.org/pi/bitcoindev/CAAQdECALHHysr4PNRGXcFMCk5AjRDYgquUUUvuvwHGoeJDgZJA@mail.gmail.com/
[nick poll]: https://gnusha.org/pi/bitcoindev/941b8c22-0b2c-4734-af87-00f034d79e2e@gmail.com/
[towns poll]: https://gnusha.org/pi/bitcoindev/Z1dPfjDwioa%2FDXzp@erisian.com.au/
[rubin unfed]: https://gnusha.org/pi/bitcoindev/30440182-3d70-48c5-a01d-fad3c1e8048en@googlegroups.com/
[rubin unfed paper]: https://rubin.io/public/pdfs/unfedcovenants.pdf
[heilman slash]: https://gnusha.org/pi/bitcoindev/CAEM=y+V_jUoupVRBPqwzOQaUVNdJj5uJy3LK9JjD7ixuCYEt-A@mail.gmail.com/
[drkgry deanon]: https://github.com/GingerPrivacy/GingerWallet/discussions/116
[shinobi deanon]: https://bitcoinmagazine.com/technical/wabisabi-deanonymization-vulnerability-disclosed
[wasabi #5439]: https://github.com/WalletWasabi/WalletWasabi/issues/5439
[adding payjoin support]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/payjoin
[multiple binaries]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/multiprocess-binaries
[mining interface]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/mining-interface
[stratum v2 support]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/stratumv2
[benchmarking]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/leveldb
[flamegraphs]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/flamegraphs
[api for libbitcoinkernel]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/kernel
[block stalling]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/block-stalling
[rpc code]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/rpc-discussion
[development of erlay]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/erlay
[contemplating covenants]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10/covenants
[coredev notes]: https://btctranscripts.com/bitcoin-core-dev-tech/2024-10
[dd deplete]: /en/podcast/2024/12/12/
[bdk 1.0.0-beta.6]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.6
[btcpay server 2.0.4]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.0.4
