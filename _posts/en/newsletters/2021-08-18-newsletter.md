---
title: 'Bitcoin Optech Newsletter #162'
permalink: /en/newsletters/2021/08/18/
name: 2021-08-18-newsletter
slug: 2021-08-18-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about the dust limit and
includes our regular sections with descriptions of changes to services
and client software, how you can prepare for taproot, new releases and
release candidates, and notable changes to popular Bitcoin
infrastructure software.

## News

- **Dust limit discussion:** Bitcoin Core and other node software
  refuses by default to relay or mine any transaction with an output
  value below a certain amount, the [dust limit][topic uneconomical
  outputs] (the exact amount varies by output type).  This makes it more
  difficult for users to create *uneconomical outputs*---UTXOs that
  would cost more in fees to spend that they hold in value.

    This week, Jeremy Rubin [posted][rubin dust] to the Bitcoin-Dev
    mailing list a five-point argument for removing the dust limit and
    stated a belief that the reason for the limit is to prevent "spam"
    and "[dust fingerprint attacks][topic output linking]".  Others
    [replied][corallo dust] with [counterarguments][harding dust] and
    noted that the limit exists not to prevent spam but to prevent
    users from permanently wasting the resources of full node operators
    by creating UTXOs that the users will have no financial incentive to
    ever spend.  Parts of the discussion also [described][riard dust]
    the [impact][towns dust] of both the dust limit and uneconomical
    outputs on parts of LN.

    As of this writing, it did not appear any agreement was likely to be
    reached.  At least for the short term, we expect the dust limit to
    remain.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Preparing for taproot #9: signature adaptors

*A weekly [series][series preparing for taproot] about how developers
and service providers can prepare for the upcoming activation of taproot
at block height {{site.trb}}.*

{% include specials/taproot/en/08-signature-adaptors.md %}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Bitcoin Core 22.0rc2][bitcoin core 22.0] is a release candidate
  for the next major version of this full node implementation and its
  associated wallet and other software. Major changes in this new
  version include support for [I2P][topic anonymity networks] connections,
  removal of support for [version 2 Tor][topic anonymity networks] connections,
  and enhanced support for hardware wallets.

- [Bitcoin Core 0.21.2rc1][bitcoin core 0.21.2] is a release candidate
  for a maintenace version of Bitcoin Core.  It contains several bug
  fixes and small improvements.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #22642][] updates Bitcoin Core's release process for
  upcoming version 22.0 to concatenate the GPG signatures of everyone
  who [reproducibly built][topic reproducible builds] the binaries into a single file which
  can be batch verified ([example][gpg batch]).  Signatures from
  deterministic builders have been available for years, but this should
  make them more accessible and also reduce the existing dependency
  on the project's lead maintainer signing the release binaries.

- [Bitcoin Core #21800][] implements ancestor and descendant limits for
  mempool package acceptance. Bitcoin Core limits the number of
  related transactions in its mempool as a protection against DoS
  attacks and so that block construction is tractable for miners. By default,
  those [limits][bitcoin core mempool limits] ensure that no transaction
  in the mempool, combined with its mempool ancestors, can exceed 25
  transactions or 101KvB in weight. The same rules apply to the transaction
  combined with its mempool descendants.

    Those ancestor and descendant limits are enforced when a transaction is
    considered for addition to the mempool. If adding the transaction would
    cause one of the limits to be exceeded, then the transaction is rejected.
    Although package semantics have not been finalized, [#21800][bitcoin core #21800]
    implements ancestor and descendant limit checks for validating
    arbitrary packages (i.e. when multiple transactions are considered
    for addition to the mempool at the same time). Mempool package acceptance
    was implemented for testing only in [#20833][mempool package test accept],
    and will eventually be exposed over the p2p network as part of [package
    relay][topic package relay].

- [Bitcoin Core #21500][] updates the `listdescriptors` RPC with a
  `private` parameter that, when set, will return the private form of
  each descriptor.  The private form contains any known private keys or
  extended private keys (xprvs), allowing this updated command to be
  used to backup the wallet.

- [Rust-Lightning #1009][] adds a `max_dust_htlc_exposure_msat` channel
  configuration option which limits the total balance of pending "dusty HTLCs"
  whose amounts are below the [dust limit][topic uneconomical outputs].

  This change is in preparation for a [proposed][BOLTs #873]
  `option_dusty_htlcs_uncounted` feature bit, which advertises that the node
  does not wish to count "dusty HTLCs" against `max_accepted_htlcs`. Node
  operators would likely want to adopt this feature bit since
  `max_accepted_htlcs` is mainly used to limit the potential size of the onchain
  transaction if a force-close were to happen and "dusty HTLCs" are unclaimable
  onchain and would never affect the final transaction size.

  The newly added `max_dust_htlc_exposure_msat` channel configuration option
  ensures that even when `option_dusty_htlcs_uncounted` is turned on, users can
  still limit the total balance of "dusty HTLCs" as this balance would be lost
  as fees to miners in a force-close.

{% include references.md %}
{% include linkers/issues.md issues="22642,21800,21500,1009,873" %}
[bitcoin core 22.0]: https://bitcoincore.org/bin/bitcoin-core-22.0/
[bitcoin core 0.21.2]: https://bitcoincore.org/bin/bitcoin-core-0.21.2/
[gpg batch]: https://gist.github.com/harding/78631dbcd65ff4a499e164c4e9dc85d4
[rubin dust]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019307.html
[corallo dust]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019308.html
[harding dust]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019310.html
[riard dust]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019327.html
[towns dust]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-August/019333.html
[bitcoin core mempool limits]: /en/newsletters/2018/12/04/#fn:fn-cpfp-limits
[mempool package test accept]: /en/newsletters/2021/06/02/#bitcoin-core-20833
