---
title: 'Bitcoin Optech Newsletter #42'
permalink: /en/newsletters/2019/04/16/
name: 2019-04-16-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter requests testing of the latest release candidates
for Bitcoin Core and LND, describes how helping people accept payments
to bech32 addresses can lower fees, and lists notable code changes in
popular Bitcoin projects.

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
segwit][bech32 easy] yourself, but it does allow the people you pay to
access all of segwit's multiple benefits.*

One reason your users and customers may want you to implement bech32
sending support is because it'll allow the receivers of those payments
to save on fees when they re-spend that money.  This week, we'll look at
how much money they'll save and discuss how their savings could also
help you save money.

For the legacy P2PKH address format implemented in the first version of
Bitcoin, the scriptSig that authorizes a spend is typically 107 vbytes.
For P2SH-wrapped segwit P2WPKH, this same information is moved to a
witness data field that only consumes 1/4 as many vbytes (27 vbytes) but
whose P2SH overhead adds 23 vbytes for a total of 50 vbytes.  For native
segwit P2WPKH, there's no P2SH overhead, so 27 vbytes is all that's used.

This means you could argue that P2SH-P2WPKH saves over 50% compared to
P2PKH, and that P2WPKH saves another almost 50% compared to P2SH-P2WPKH
or 75% compared to P2PKH alone.  However, spending transactions contain
more than just scriptSigs and witness data, so the way we usually
compare savings is by looking at prototype transactions.  For example,
we imagine a typical transaction containing a single input and two
outputs (one to the receiver; one as change back to the spender).  In
that case:

- Spending P2PKH has a total transaction size of
  220 vbytes
- Spending P2SH-P2WPKH has a size of 167 vbytes (24% savings)
- Spending P2WPKH output has a size of 141 vbytes (16% savings vs
  P2SH-P2WPKH or 35% vs P2PKH)

To compare simple multisig transactions (those that just use a single
`OP_CHECKMULTSIG` opcode), things get more complex because k-of-n
multisig inputs vary in size depending on the number of signatures (k)
and the number of public keys (n).  So, for simplicity's sake, we'll
just plot the sizes of legacy P2SH-multisig compared to wrapped P2SH-P2WSH
multisig (up to the maximum 15-of-15 supported by legacy P2SH).  We can
see that switching to P2SH-P2WSH can save from about 40% (1-of-2
multisig) to about 70% (15-of-15).

![Plot of multisig transaction sizes with P2SH and P2SH-P2WSH](/img/posts/2019-04-segwit-multisig-size-p2sh-to-p2sh-p2wsh.png)

We can then compare P2SH-P2WSH to native P2WSH to see the additional
constant-sized savings of about 35 bytes per transaction or about 5% to
15%.

![Plot of multisig transaction sizes with P2SH-P2WSH and P2WSH](/img/posts/2019-04-segwit-multisig-size-p2sh-p2wsh-to-p2wsh.png)

The scripts described above account for almost all scripts being used
with addresses that aren't native segwit.  (Users of more complex
scripts, such as those used in LN, are mostly using native segwit today.)
Those less efficient script types currently consume a majority fraction
of block capacity (total block weight).  Switching to native segwit in
order to reduce a transaction's weight allows you to reduce its fee by
the same percentage without changing how long it'll take to confirm---all other
things being equal.

But all other things aren't equal.  Because the transactions use less
block weight, there's more weight available for other transactions.  If
the supply of available block weight increases and demand remains constant, we
expect prices to go down (unless they're already at the default minimum
relay fee).  This means more people spending native segwit inputs lowers
the fee not just for those spenders but for everyone who creates
transactions---including wallets and services that support sending to
bech32 addresses.

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

{% include references.md %}
{% include linkers/issues.md issues="15555,15711,2933,2908,2540,2554,2506,2022" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[lnd releases]: https://github.com/lightningnetwork/lnd/releases
[bech32 easy]: {{news38}}#bech32-sending-support
[lnd issue]: https://github.com/lightningnetwork/lnd/issues/new
[lnd recover]: https://github.com/lightningnetwork/lnd/blob/master/docs/recovery.md
