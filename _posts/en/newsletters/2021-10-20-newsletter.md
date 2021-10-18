---
title: 'Bitcoin Optech Newsletter #171'
permalink: /en/newsletters/2021/10/20/
name: 2021-10-20-newsletter
slug: 2021-10-20-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a thread about paying
frequently-offline LN nodes, describes a set of proposals for lowering
the cost of LN payment path probing in order to make certain attacks
more expensive, and links to instructions useful for creating taproot
transactions on signet and testnet.  Also included are our regular
sections describing recent changes to clients and services, new releases
and release candidates, and notable changes to popular Bitcoin
infrastructure software.

## News

- **Paying offline LN nodes:** Matt Corallo started a [thread][corallo
  mobile] on the Lightning-Dev mailing list for brainstorming how
  frequently-offline LN nodes (such as those on mobile devices) can
  receive payments without requiring a custodial solution or locking up
  channel liquidity for prolonged periods of time.  Corallo believes
  there's a reasonably good solution involving an untrusted third
  party once LN is [upgraded][zmn taproot] to support [PTLCs][topic
  ptlc], but he's also seeking suggestions for any alternative solutions
  that could be deployed even before PTLC support is added.

- **Lowering the cost of probing to make attacks more expensive:** a few weeks apart, developers
  ZmnSCPxj and Joost Jager each made [substantially][zmn prop] similar
  [proposals][jager prop] for eliminating the requirement to lock up
  capital in order to probe a payment path.  Both proposals suggest this
  as a first step towards adding upfront routing fees to the
  network---fees that would cost the spender money even if a payment
  attempt failed.  Upfront fees are one of the suggested mitigations for
  [channel jamming attacks][topic channel jamming attacks].

    Currently, LN nodes can send guaranteed-to-fail payments in order to
    probe a payment path.  For example, Alice generates an [HTLC][topic
    htlc] that pays a preimage nobody knows.  She routes the payment
    through Bob and Charlie to Zed.  Since Zed doesn't know the payment
    preimage, he's forced to reject the payment even though it indicates
    he's supposed to be the ultimate receiver.  If Alice receives the
    reject message from Zed's node, she knows that Bob and Charlie had
    enough funds in their channels to allow paying Zed, and so she can
    immediately react to Zed's rejection by sending an actual payment
    that has a high probability of succeeding (the only liquidity-related reason for failing would be if Bob's
    or Charlie's balances had changed in the meantime).  The advantage
    to Alice of starting with a guaranteed-to-fail probe is that she can
    probe multiple paths in parallel and use whichever one succeeds
    first, reducing the overall payment time.  The primary disadvantage
    is that each payment probe temporarily locks up funds belonging to
    Alice and to intermediate nodes like Bob and Charlie; if Alice is
    probing several long paths in parallel, she could easily be locking
    up 100x or more of her payment amount.  A secondary disadvantage is
    that this type of payment path probing can sometimes result in
    unnecessary unilateral channel closures and their resulting onchain
    fees.

    ZmnSCPxj and Jager propose to allow sending a special probe message
    that doesn't require using an HTLC, temporarily locking up bitcoins,
    or risking channel failure.  The message would be essentially free
    to send, although ZmnSCPxj's proposal does suggest some mitigations
    to avoid denial of service flood attacks.

    If free probing does actually allow spending nodes to find paths
    that are reliable a high percentage of the time, ZmnSCPxj and Jager
    argue that developers and users should be less resistant to paying
    upfront fees that will cost users on the rare occasions when
    payments fail.  That small occasional cost to honest users
    would become a large guaranteed cost to dishonest nodes executing
    extensive jamming attacks, reducing the risk that such attacks
    will occur (and compensating routing node operators for deploying
    extra capital to improve the network if a sustained attack did occur).

    The idea received a modest level of discussion as of this writing.

- **Testing taproot:** in response to a [request][schildbach taproot
  wallet] on the Bitcoin-Dev mailing list, Anthony Towns
  [provided][towns taproot wallet] step-by-step instructions for
  creating a [bech32m][topic bech32] address for testing in Bitcoin Core on
  [signet][topic signet] or testnet.  These instructions may be easier
  to use for developers testing taproot than those [previously
  provided][p4tr signet] by Optech.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Zeus wallet adds LN features:**
  Zeus, a mobile Bitcoin and Lightning wallet application, in its
  [v0.6.0-alpha3][zeus v0.6.0-alpha3] release, provides additional support for [atomic
  multipath payments (AMPs)][topic amp], [Lightning Addresses][news167 lightning
  addresses], and [coin control][topic coin selection] features.

- **Sparrow adds coinjoin support:**
  [Sparrow 1.5.0][] adds [coinjoin][topic coinjoin] features by integrating with
  Samourai's [Whirlpool][whirlpool].

- **JoinMarket 0.9.2 adds RBF support:**
  In addition to defaulting to using [fidelity bonds][news161 fidelity bonds] in
  the UI, [JoinMarket 0.9.2][joinmarket 0.9.2] also supports [replace by fee
  (RBF)][topic rbf] for non-coinjoin transactions.

- **Coldcard supports descriptor-based wallets:**
  [Coldcard 4.1.3][coldcard 4.1.3] now supports `importdescriptors` in Bitcoin
  Core, enabling [descriptor][topic descriptors] wallets and [PSBT][topic psbt]
  workflows with Bitcoin Core.

- **Simple Bitcoin Wallet adds CPFP, RBF, hold invoices:**
  Simple Bitcoin Wallet, previously known as Bitcoin Lightning Wallet, added
  [child pays for parent (CPFP)][topic cpfp] and RBF (fee bump and
  cancellation) features in version 2.2.14 and [hold invoices][topic hold invoices] in
  [2.2.15][slw 2.2.15].

- **Electrs 0.9.0 released:**
  [Electrs 0.9.0][] now uses Bitcoin's P2P protocol instead of reading blocks
  from disk or JSON RPC. Users should consult the [upgrading guide][Electrs
  0.9.0 upgrading guide] for details on upgrading.

## Preparing for taproot #18: trivia

*A weekly [series][series preparing for taproot] about how developers
and service providers can prepare for the upcoming activation of taproot
at block height {{site.trb}}.*

{% include specials/taproot/en/18-trivia.md %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BDK 0.12.0][] is a release that adds the ability to store data using
  Sqlite, among other improvements.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], and
[Lightning BOLTs][bolts repo].*

<!-- we wouldn't normally cover a small code comment like this, but it
seems worth publicizing the decision to use this value -->
- [Bitcoin Core #22863][] documents a decision to use the same minimum
  output amount ("dust amount") of 294 sat for P2TR outputs as for
  P2WPKH outputs.  This is done even though it costs less to spend a
  P2TR output than a P2WPKH output because some developers were
  [opposed][bitcoin core #22779] to lowering the dust limit at this
  time.

- [Bitcoin Core #23093][] adds a `newkeypool` RPC method that will mark all
  pre-generated addresses in the wallet as used so that a new set of addresses
  is generated.  Most users should never need this, but the behavior is
  used in the background if a user upgrades from an older non-[BIP32][]
  wallet to using [HD key generation][topic bip32].

- [Bitcoin Core #22539][] considers replacement transactions seen by the
  local node when generating fee estimates.  Replacement transactions
  were [previously][bitcoin core #9519] not considered when they rarely
  occurred, but currently about [20% of all transactions][optech rbf] send the
  [BIP125][] signal for opting in to replacement and [several
  thousand][0xb10c stats] replacements occur in a typical day.

- [Eclair #1985][] adds a new `max-exposure-satoshis` configuration setting <!-- full name is
  long:
  eclair.on-chain-fees.feerate-tolerance.dust-tolerance.max-exposure-satoshis
  --> that allows the user to set the maximum amount of money they'll
  donate to miners if the channel is forced closed with unresolved
  [uneconomical payments][topic uneconomical outputs].  See the
  description of CVE-2021-41591 in [last week's newsletter][news170 ln
  cve] for more information.

- [Rust-Lightning #1124][] extends the `get_route` API with the ability
  to pass an additional parameter that can be used to avoid reusing
  previously failed routes.  Additional planned changes will make it
  easier to use previous routing successes and failures to improve the
  quality of later results.

- [BOLTs #894][] adds suggested checks to the specification.   Implementations
  can implement these to prevent donating excess bitcoins to miner fees
  when routing payments that are uneconomical onchain.  See [last week's
  newsletter][news170 ln cve] for details about problems possible when
  these checks are not present.

{% include references.md %}
{% include linkers/issues.md issues="22863,23093,22539,4567,1985,1124,894,22779,9519" %}
[corallo mobile]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-October/003307.html
[zmn taproot]: /en/preparing-for-taproot/#ln-with-taproot
[zmn prop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-September/003256.html
[jager prop]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-October/003314.html
[schildbach taproot wallet]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019532.html
[towns taproot wallet]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-October/019543.html
[p4tr signet]: /en/preparing-for-taproot/#testing-on-signet
[news170 ln cve]: /en/newsletters/2021/10/13/#ln-spend-to-fees-cve
[BDK 0.12.0]: https://github.com/bitcoindevkit/bdk/releases/tag/v0.12.0
[0xb10c stats]: https://github.com/bitcoin/bitcoin/pull/22539#issuecomment-885763670
[optech rbf]: https://dashboard.bitcoinops.org/d/ZsCio4Dmz/rbf-signalling?orgId=1
[zeus v0.6.0-alpha3]: https://github.com/ZeusLN/zeus/releases/tag/v0.6.0-alpha3
[news167 lightning addresses]: /en/newsletters/2021/09/22/#lightning-address-identifiers-announced
[sparrow 1.5.0]: https://github.com/sparrowwallet/sparrow/releases/tag/1.5.0
[whirlpool]: https://bitcoiner.guide/whirlpool/
[news161 fidelity bonds]: /en/newsletters/2021/08/11/#implementation-of-fidelity-bonds
[joinmarket 0.9.2]: https://github.com/JoinMarket-Org/joinmarket-clientserver/releases/tag/v0.9.2
[coldcard 4.1.3]: https://blog.coinkite.com/version-4.1.3-released/
[slw 2.2.15]: https://github.com/btcontract/wallet/releases/tag/2.2.15
[Electrs 0.9.0]: https://github.com/romanz/electrs/releases/tag/v0.9.0
[Electrs 0.9.0 upgrading guide]: https://github.com/romanz/electrs/blob/master/doc/usage.md#important-changes-from-versions-older-than-090
