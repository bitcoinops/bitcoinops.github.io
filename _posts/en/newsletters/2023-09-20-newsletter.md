---
title: 'Bitcoin Optech Newsletter #269'
permalink: /en/newsletters/2023/09/20/
name: 2023-09-20-newsletter
slug: 2023-09-20-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter shares the announcement of an upcoming research
event and includes our regular sections summarizing significant updates
to various service and client software, announcing new software releases
and release candidates, and describing recent changes to popular
infrastructure software.

## News

- **Bitcoin research event:** Sergi Delgado Segura and Clara Shikhelman
  [posted][ds brd] to the Bitcoin-Dev and Lightning-Dev mailing lists to
  announce a _Bitcoin Research Day_ event to be held in New York City on
  October 27th.  It will be an in-person event with talks from a number
  of well-known Bitcoin researchers.  Reservations are required and
  some short (5 minute) presentation slots were still available as of
  the posting.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Bitcoin-like Script Symbolic Trace (B'SST) released:**
  [B'SST][] is a Bitcoin and Element script analysis tool that provides feedback
  on scripts including "conditions that the script enforces, possible
  failures, possible values for data".

- **STARK header chain verifier demo:**
  The [ZeroSync][news222 zerosync] project announced a [demo][zerosync demo] and
  [repository][zerosync code] using STARKs to prove and verify a chain of Bitcoin block headers.

- **JoinMarket v0.9.10 released:**
  The [v0.9.10][joinmarket v0.9.10] release adds [RBF][topic rbf] support for
  non-[coinjoin][topic coinjoin] transactions and fee estimation updates, among
  other improvements.

- **BitBox adds miniscript:**
  The [latest BitBox02 firmware][bitbox blog] adds [miniscript][topic
  miniscript] support in addition to a security fix and usability enhancements.

- **Machankura announces additive batching feature:**
  Bitcoin service provider [Machankura][] has [announced][machankura tweet] a
  beta feature that supports additive [batching][] using RBF in a [taproot][topic
  taproot] wallet that has a FROST [threshold][topic threshold signature] spending condition.

- **SimLN Lightning simulation tool:**
  [SimLN][] is a simulation tool for LN researchers and protocol/application
  developers that generates realistic LN payment activity. SimLN supports
  LND and CLN with work on Eclair and LDK-Node in progress.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning 23.08.1][] is a maintenance release that includes
  several bug fixes.

- [LND v0.17.0-beta.rc4][] is a release candidate for the next major
  version of this popular LN node implementation.  A major new
  experimental feature planned for this release, which could likely
  benefit from testing, is support for "simple taproot channels".

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Bitcoin Core #26152][] builds upon a previously added interface (see
  [Newsletter #252][news252 bumpfee]) to pay for any _fee deficit_ in
  the inputs selected to be included in a transaction.  A fee deficit
  occurs when the wallet must select UTXOs with unconfirmed ancestors
  that pay low feerates.  In order for the user's transaction to pay the
  user's selected feerate, the transaction must pay a fee high enough to
  pay for both its low-feerate unconfirmed ancestors and itself.  In
  short, this PR ensures that a user who chooses a feerate---setting a
  priority that will affect when the transaction confirms---will actually
  receive that priority even if the wallet must spend unconfirmed UTXOs.
  All other wallets we're aware of can only guarantee a certain
  feerate-based priority if they only spend confirmed UTXOs.  See also
  [Newsletter #229][news229 bumpfee] for the summary of a Bitcoin Core
  PR Review Club meeting about this PR.

- [Bitcoin Core #28414][] updates the `walletprocesspsbt` RPC to include
  a complete serialized transaction (in hex) if the wallet processing
  step resulted in a ready-to-broadcast transaction.  This saves the
  user the step of calling `finalizepsbt` on an already-final
  [PSBT][topic psbt].

- [Bitcoin Core #28448][] deprecates the `rpcserialversion` (RPC
  serialization version) configuration parameter.  This option was
  introduced during the transition to v0 segwit to allow older programs
  to continue to access blocks and transactions in stripped format
  (without any segwit fields).  At this point, all programs should be
  updated to handle segwit transactions and this option should no longer
  be needed, although it can be temporarily re-enabled as a deprecated
  API as described in the release notes added by the PR.

- [Bitcoin Core #28196][] adds a substantial portion of the code
  necessary to support the [v2 transport protocol][topic v2 p2p
  transport] as specified in [BIP324][] along with extensive fuzz
  testing of the code.  This does not enable any new features but
  reduces the amount of code that will need to be added to enable those
  features in future PRs.

- [Eclair #2743][] adds a `bumpforceclose` RPC that will manually tell
  the node to spend the [anchor output][topic anchor outputs] from a
  channel to [CPFP fee bump][topic cpfp] a commitment transaction.
  Eclair nodes provide automatic fee bumping when necessary, but this
  allows an operator to manually access the same ability.

- [LDK #2176][] increases the precision with which LDK attempts to
  probabilistically guess the amount of liquidity available in distant
  channels it has attempted to route payments through.  The precision
  went as low as 0.01500 BTC in a 1.00000 BTC channel; the new precision
  tracks down to about 0.00006 BTC in the same-sized channel.  This may
  slightly increase the time it takes to find a path for a payment, but
  tests indicate there is no major difference.

- [LDK #2413][] supports sending payments to [blinded paths][topic rv
  routing] and allows receiving payments to paths where a single final
  hop is hidden (blinded) from the spender.  [PR #2514][ldk #2514], also
  merged this week, provides other support for blinded payments in LDK.

- [LDK #2371][] adds support for managing payments using [offers][topic
  offers].  It allows a client application using LDK to use an offer to
  register its intent to pay an invoice, timing out the payment attempt
  if a sent offer never results in a received invoice, and then using
  existing code in LDK to pay the invoice (including retrying if the
  first attempts don't succeed).

{% include references.md %}
{% include linkers/issues.md v=2 issues="26152,28414,28448,28196,2743,2176,2413,2514,2371" %}
[LND v0.17.0-beta.rc4]: https://github.com/lightningnetwork/lnd/releases/tag/v0.17.0-beta.rc4
[ds brd]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-September/021959.html
[news252 bumpfee]: /en/newsletters/2023/05/24/#bitcoin-core-27021
[news229 bumpfee]: /en/newsletters/2022/12/07/#bitcoin-core-pr-review-club
[Core Lightning 23.08.1]: https://github.com/ElementsProject/lightning/releases/tag/v23.08.1
[B'SST]: https://github.com/dgpv/bsst
[news222 zerosync]: /en/newsletters/2022/10/19/#zerosync-project-launches
[zerosync demo]: https://zerosync.org/demo/
[zerosync code]: https://github.com/ZeroSync/header_chain
[joinmarket v0.9.10]: https://github.com/JoinMarket-Org/joinmarket-clientserver/releases/tag/v0.9.10
[bitbox blog]: https://bitbox.swiss/blog/bitbox-08-2023-marinelli-update/
[Machankura]: https://8333.mobi/
[machankura tweet]: https://twitter.com/machankura8333/status/1695827506794754104
[batching]: /en/payment-batching/
[SimLN]: https://github.com/bitcoin-dev-project/sim-ln
