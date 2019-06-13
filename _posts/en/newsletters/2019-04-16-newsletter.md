---
title: 'Bitcoin Optech Newsletter #42'
permalink: /en/newsletters/2019/04/16/
name: 2019-04-16-newsletter
slug: 2019-04-16-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter requests testing of the latest release candidates
for Bitcoin Core and LND, describes how helping people accept payments
to bech32 addresses can lower fees, and lists notable code changes in
popular Bitcoin projects.

{% include references.md %}

## Action items

- **Help test Bitcoin Core 0.18.0 release candidates:** Bitcoin Core's
  third RC for its next major version is [available][0.18.0] and a
  fourth is being prepared.  Testing is greatly appreciated.  Please use
  [this issue][Bitcoin Core #15555] for reporting feedback.

- **Help test LND 0.6-beta RC4:** [release candidates][lnd releases]
  for the next major version of LND are being published.  Testing by
  organizations and experienced LN users is encouraged to catch any
  regressions or serious problems that could affect users of the final
  release.  [Open a new issue][lnd issue] if you discover any problems.

## News

*No notable technical news this week.  (Note: When we at Optech started
this newsletter, we decided to avoid stuffing short newsletters with
fluff pieces and other unnecessary information, so newsletter length
varies depending on the actual amount of significant technical news each
week.  You've probably seen us publish an occasional very long
newsletter; this week, you see the opposite.)*

## Bech32 sending support

*Week 5 of 24.  Until the second anniversary of the segwit soft
fork lock-in on 24 August 2019, the Optech Newsletter will contain this
weekly section that provides information to help developers and
organizations implement bech32 sending support---the ability to pay
native segwit addresses.  This [doesn't require implementing
segwit][bech32 series] yourself, but it does allow the people you pay to
access all of segwit's multiple benefits.*

{% include specials/bech32/05-fee-savings.md %}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], and [Bitcoin Improvement Proposals
(BIPs)][bips repo].  Note: all merges described for Bitcoin Core and LND
are to their master development branches; some may also be backported to
their pending releases.*

- [Bitcoin Core #15711][] generates bech32 addresses by default in the
  GUI.  The user can still generate a P2SH-wrapped segwit address by
  unchecking a box on the Request Payment screen in case they need to
  receive money from a service that doesn't yet provide bech32 sending
  support.  The bitcoind default of generating P2SH-wrapped segwit
  addresses is not changed.

- [C-Lightning #2506][] adds a `min-capacity-sat` configuration
  parameter to reject channel open requests below a certain value.  This
  replaces a hardcoded minimum of 0.00001 BTC previously in the code.

- [LND #2933][] adds a document describing LND's current [backup and recovery
  options][lnd recover].

- [C-Lightning #2540][] adds an invoice hook that's called whenever a
  "valid payment for an unpaid invoice has arrived."  Among other tasks
  that can be performed when a payment is received, this can be used by
  a plugin to implement "hold invoices" as previously implemented in LND
  (see our description of [LND #2022][] in [Newsletter #38][]).

- [C-Lightning #2554][] changes the default invoice expiration from one
  hour to one week.  This is the time after which the node will
  automatically reject attempts to pay the invoice.  Services that want
  to minimize exchange rate risk will need to pass a lower `expiry`
  value when using the `invoice` RPC.

{% include linkers/issues.md issues="15555,15711,2933,2908,2540,2554,2506,2022" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[lnd releases]: https://github.com/lightningnetwork/lnd/releases
[bech32 easy]: {{news38}}#bech32-sending-support
[lnd issue]: https://github.com/lightningnetwork/lnd/issues/new
[lnd recover]: https://github.com/lightningnetwork/lnd/blob/master/docs/recovery.md
[bech32 series]: /en/bech32-sending-support/
