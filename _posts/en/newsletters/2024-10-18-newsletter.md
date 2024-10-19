---
title: 'Bitcoin Optech Newsletter #325'
permalink: /en/newsletters/2024/10/18/
name: 2024-10-18-newsletter
slug: 2024-10-18-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter looks at summaries of some of the topics
discussed at a recent LN developer meeting.  Also include are our
regular sections with descriptions of changes to popular clients and
services, announcements of new releases and release candidates, and
summaries of notable changes to popular Bitcoin infrastructure software.

## News

- **LN Summit 2024 notes:** Olaoluwa Osuntokun [posted][osuntokun
  summary] to Delving Bitcoin a summary of his [notes][osuntokun
  notes] (with additional commentary) from a recent LN developer
  conference.  Some of the topics discussed included:

  - **Version 3 commitment transactions:** developers discussed how to use
    [new P2P features][bcc28 guide], including [TRUC][topic v3 transaction relay]
    transactions and [P2A][topic ephemeral anchors] outputs, to improve
    the security of LN commitment transactions that can be used to
    unilaterally close a channel.  Discussion focused on various design
    tradeoffs.

  - **PTLCs:** although long proposed as a privacy upgrade to LN, as well
    as possibly useful for other purposes such as [stuckless
    transactions][topic redundant overpayments], recent research
    into the tradeoffs of various possible [PTLC][topic ptlc]
    implementations was discussed (see [Newsletter #268][news268 ptlc]).
    A particular focus was the construction of the [signature
    adaptor][topic adaptor signatures] (e.g. using scripted multisig
    versus scriptless [MuSig2][topic musig]) and its effect on the
    commitment protocol (see next item).

  - **State update protocol:** a proposal was discussed to convert LN's
    current state update protocol from allowing either side to propose an
    update at any time to only allowing one party at a time to propose
    updates (see Newsletters [#120][news120 simcom] and
    [#261][news261 simcom]).  Allowing either side to propose updates can
    result in both sides proposing updates simultaneously, which is
    difficult to reason about and can lead to accidental channel force
    closures.  The alternative is for only one party to be in
    charge at a time, e.g.  Alice is initially the only one allowed to
    propose state updates; if she has none to propose, she can tell Bob
    that he's in charge.  When Bob's finished proposing updates, he can
    transfer control back to Alice.  This simplifies reasoning about the
    protocol, eliminates problems with simultaneous proposals, and
    further makes it easy for the non-controlling party to reject any
    unwanted proposals.  The new round-based protocol would also work
    well with MuSig2-based signature adaptors.

  - **SuperScalar:** the developer of a proposed [channel factory][topic
    channel factories] construction for end-users gave a presentation on
    the proposal and solicited feedback.  Optech will publish a more
    detailed description of [SuperScalar][zmnscpxj superscalar] in a
    future newsletter.

  - **Gossip upgrade:** developers discussed upgrades to the [LN gossip
    protocol][topic channel announcements].  These are most urgently
    needed for supporting new types of
    funding transactions, such as for [simple taproot channels][topic
    simple taproot channels], but may also add support for other
    features.  One new feature discussed was having channel announcement
    messages include an SPV proof (or a commitment to an SPV proof) to
    allow lightweight clients to verify that a funding transaction (or
    sponsoring transaction) was included in a block at some point.

  - **Research on fundamental delivery limits:** research was presented on
    payment flows that cannot result in success given limitations of the
    network (e.g., channels with insufficient capacity); see [Newsletter
    #309][news309 feasible].  If an LN payment is infeasible, the
    spender and receiver can always use an onchain payment.  However,
    the rate of onchain payments is limited by the maximum block weight,
    so it's possible to calculate the maximum throughput (payments per
    second) of the combined Bitcoin and LN system by dividing the
    maximum onchain rate by the rate of infeasible LN payments.  Using
    this rough metric, to achieve a maximum of about 47,000 payments per
    second, the infeasible rate must be below 0.29%.  Two techniques
    were discussed for reducing the infeasible rate: (1) virtual or real
    channels that involve more than two parties, as more parties implies
    more funds for forwarding and more forwarding funds increases the
    rate of feasibility; and (2) credit channels where parties who
    trust each other can forward payments between themselves without the
    ability to enforce those payments onchain---with all other users
    still receiving trustless payments.

  Osuntokun encouraged other participants to post corrections or
  expansions to the thread.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Coinbase adds taproot send support:**
  Coinbase exchange [now supports][coinbase post] user withdrawals (send) to taproot
  [bech32m][topic bech32] addresses.

- **Dana wallet released:**
  [Dana wallet][dana wallet github] is a [silent payment][topic silent payments] wallet focused on the
  donation use case. The developers recommend using [signet][topic signet] and
  also run a signet [faucet][dana wallet faucet].

- **Kyoto BIP157/158 light client released:**
  [Kyoto][kyoto github] is a Rust light client using [compact block
  filters][topic compact block filters] for use by wallet developers.

- **DLC Markets launches on mainnet:**
  The [DLC][topic dlc]-based platform [announced][dlc markets blog] mainnet
  availability for its non-custodial trading service.

- **Ashigaru wallet announced:**
  Ashigaru is a fork of the Samourai Wallet project and the
  [announcement][ashigaru blog] listed improvements to [batching][scaling
  payment batching], [RBF][topic rbf] support, and [fee estimation][topic fee estimation].

- **DATUM protocol announced:**
  The [DATUM mining protocol][datum docs] allows miners to build candidate blocks as part
  of a [pooled mining][topic pooled mining] setup, similar to the Stratum v2 protocol.

- **Bark Ark implementation announced:**
  The Second team [announced][bark blog] the [Bark][bark codeberg]
  implementation of the [Ark][topic ark] protocol and [demonstrated][bark demo]
  live Ark transactions on mainnet.

- **Phoenix v2.4.0 and phoenixd v0.4.0 released:**
  The [Phoenix v2.4.0][phoenix v2.4.0] and [phoenixd v0.4.0][] releases add
  support for the [BLIP36][blip36] on-the-fly funding proposal and other
  liquidity features (see [Podcast #323][pod323 eclair]).

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BDK 1.0.0-beta.5][] is a release candidate (RC) of this library for
  building wallets and other Bitcoin-enabled applications.  This latest
  RC "enables RBF by default and updates the bdk_esplora client to retry
  server requests that fail due to rate limiting. The `bdk_electrum`
  crate now also offers a use-openssl feature."

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #30955][] introduces two new methods to the `Mining` interface
  (see Newsletter [#310][news310 mining]), in line with the requirements for
  [Stratum V2][topic pooled mining]. The `submitSolution()` method allows miners
  to submit a block solution more efficiently by only requiring the nonce,
  timestamp, version fields, and coinbase transaction, instead of the entire
  block. Additionally, `getCoinbaseMerklePath()` is introduced to construct the
  merkle path field required in the `NewTemplate` message. This PR also
  reinstates `BlockMerkleBranch`, which was previously removed in [Bitcoin Core
  #13191][].

- [Eclair #2927][] adds enforcement of recommended feerates (see Newsletter
  [#323][news323 fees]) for on-the-fly funding (see Newsletter [#323][news323
  fly]), by rejecting `open_channel2` and `splice_init` messages that use a
  feerate lower than the recommended value.

- [Eclair #2922][] removes support for [splicing][topic splicing] without
  channel quiescence (see Newsletter [#309][news309 quiescence]), to conform to
  the latest splicing protocol as proposed in [BOLTs #1160][], which requires
  nodes to use the quiescence protocol during splicing. Previously, splicing was
  allowed under a less formal mechanism, where splice messages were permitted if
  the commitments were already quiescent, acting as a "poor man's" version of
  channel quiescence.

- [LDK #3235][] adds a `last_local_balance_msats` field to the
  `ChannelForceClosed` event, which gives the local balance of a node in
  millisatoshis (msats) just before the channel was force-closed, allowing users
  to know how many msats they lost due to rounding.

- [LND #8183][] adds the optional `CloseTxInputs` field to the
  `chanbackup.Single` structure in the [static channel backup][topic static
  channel backups] (SCB) file, to store the inputs required to generate force-close
  transactions. This allows users to manually retrieve funds when a peer
  is offline using the `chantools scbforceclose` command as a last-resort
  recovery option. However, users should exercise extreme caution as this
  feature could result in the loss of funds if the channel has been updated
  since the backup was created. In addition, the PR introduces the
  `ManualUpdate` method, which will update channel backups whenever LND shuts
  down.

- [Rust Bitcoin #3450][] adds v3 as a new variant of the transaction version,
  following Bitcoin Core’s acceptance of [Topologically Restricted Until
  Confirmation (TRUC)][topic v3 transaction relay] transactions as standard (see
  Newsletter [#307][news307 truc]).

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 14:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30955,2927,2922,3235,8183,3450,13191,1160" %}
[BDK 1.0.0-beta.5]: https://github.com/bitcoindevkit/bdk/releases/tag/v1.0.0-beta.5
[osuntokun summary]: https://delvingbitcoin.org/t/ln-summit-2024-notes-summary-commentary/1198
[osuntokun notes]: https://docs.google.com/document/d/1erQfnZjjfRBSSwo_QWiKiCZP5UQ-MR53ZWs4zIAVcqs/edit?tab=t.0#heading=h.chk08ds793ll
[news268 ptlc]: /en/newsletters/2023/09/13/#ln-messaging-changes-for-ptlcs
[news120 simcom]: /en/newsletters/2020/10/21/#simplified-htlc-negotiation
[news261 simcom]: /en/newsletters/2023/07/26/#simplified-commitments
[zmnscpxj superscalar]: https://delvingbitcoin.org/t/superscalar-laddered-timeout-tree-structured-decker-wattenhofer-factories/1143
[news309 feasible]: /en/newsletters/2024/06/28/#estimating-the-likelihood-that-an-ln-payment-is-feasible
[bcc28 guide]: /en/bitcoin-core-28-wallet-integration-guide/
[coinbase post]: https://x.com/CoinbaseAssets/status/1843712761391399318
[dana wallet github]: https://github.com/cygnet3/danawallet
[dana wallet faucet]: https://silentpayments.dev/
[saving satoshi editor]: https://script.savingsatoshi.com/
[kyoto github]: https://github.com/rustaceanrob/kyoto
[dlc markets blog]: https://blog.dlcmarkets.com/dlc-markets-reshaping-bitcoin-trading/
[ashigaru blog]: https://ashigaru.rs/news/release-wallet-v1-0-0/
[datum docs]: https://ocean.xyz/docs/datum
[bark blog]: https://blog.second.tech/ark-on-bitcoin-is-here/
[bark codeberg]: https://codeberg.org/ark-bitcoin/bark
[bark demo]: https://blog.second.tech/demoing-the-first-ark-transactions-on-bitcoin-mainnet/
[phoenix v2.4.0]: https://github.com/ACINQ/phoenix/releases/tag/android-v2.4.0
[phoenixd v0.4.0]: https://github.com/ACINQ/phoenixd/releases/tag/v0.4.0
[blip36]: https://github.com/lightning/blips/pull/36
[pod323 eclair]: /en/podcast/2024/10/08/#eclair-2848-transcript
[news310 mining]:/en/newsletters/2024/07/05/#bitcoin-core-30200
[news323 fees]: /en/newsletters/2024/10/04/#eclair-2860
[news323 fly]: /en/newsletters/2024/10/04/#eclair-2861
[news309 quiescence]:/en/newsletters/2024/06/28/#bolts-869
[news307 truc]: /en/newsletters/2024/06/14/#bitcoin-core-29496
