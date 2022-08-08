---
title: 'Bitcoin Optech Newsletter #212'
permalink: /en/newsletters/2022/08/10/
name: 2022-08-10-newsletter
slug: 2022-08-10-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about lowering the
default minimum transaction relay feerate in Bitcoin Core and other
nodes.  Also included are our regular sections with the summary of a
Bitcoin Core PR Review Club, announcements of new releases and release
candidates, and descriptions of notable changes to popular Bitcoin
infrastructure projects.

## News

- **Lowering the default minimum transaction relay feerate:** Bitcoin
  Core only relays individual unconfirmed transactions that pay a
  [feerate of at least one satoshi per vbyte][topic default minimum
  transaction relay feerates] (1 sat/vbyte).  If a node's mempool fills
  with transactions paying at least 1 sat/vbyte, then a higher feerate
  will need to be paid.  Transactions paying a lower feerate can still
  be included in blocks by miners and those blocks will be relayed.
  Other node software implements similar policies.

    Lowering the default minimum feerate has been discussed in the past
    (see [Newsletter #3][news3 min]) but [hasn't been merged][bitcoin
    core #13922] into Bitcoin Core.  The topic saw renewed
    [discussion][chauhan min] in the past couple weeks:

    - *Individual change effectiveness:* it was [debated][todd min] by
      [several][vjudeu min] people how effective it was for individual
      node operators to change their policies.

    - *Past failures:* it was [mentioned][harding min] that the previous
      attempt to lower the default feerate was hampered by the lower
      rate also reducing the cost of several minor denial-of-service
      (DoS) attacks.

    - *Alternative relay criteria:* it was [suggested][todd min2] that
      transactions violating certain default criteria (such as the
      default minimum feerate) could instead fulfill some separate
      criteria that make DoS attacks costly---for example, if a modest amount
      of hashcash-style proof of work committed to the transaction to
      relay.

    The discussion did not reach a clear conclusion as of this writing.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

FIXME:LarryRuane

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/12345#l-123"
%}

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [Core Lightning 0.12.0rc1][] is a release candidate for the next major
  version of this popular LN node implementation.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #25610][] wallet, rpc: Opt in to RBF by default FIXME:adamjonas

- [Bitcoin Core #24584][] amends [coin selection][topic coin selection] to prefer input sets
  composed of a single output type. This addresses scenarios in which
  mixed-type input sets reveal the change output of preceding
  transactions. This follows a related privacy improvement to [always
  match the change type][#23789] to a recipient output (see
  [Newsletter #181][news181 change matching]).

- [Core Lightning #5071][] adds a bookkeeper plugin that provides an
  accounting record of movements of bitcoins by the node running the
  plugin, including the ability to track the amount spent on fees.  The
  merged PR includes several new RPC commands.

- [BDK #645][] adds a way to specify which [taproot][topic taproot] spend paths to sign
  for.  Previously, BDK would sign for the keypath spend if it was able,
  plus sign for any scriptpath leaves it had the keys for.

- [BOLTs #911][] adds the ability for an LN node to announce a DNS
  hostname that resolves to its IP address.  Previous discussion about
  this idea was mentioned in [Newsletter #167][news167 ln dns].

{% include references.md %}
{% include linkers/issues.md v=2 issues="25610,24584,5071,645,911,13922" %}
[core lightning 0.12.0rc1]: https://github.com/ElementsProject/lightning/releases/tag/v0.12.0rc1
[news167 ln dns]: /en/newsletters/2021/09/22/#dns-records-for-ln-nodes
[news181 change matching]: /en/newsletters/2022/01/05/#bitcoin-core-23789
[chauhan min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020784.html
[todd min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020800.html
[vjudeu min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020821.html
[harding min]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-July/020808.html
[todd min2]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-August/020815.html
[news3 min]: /en/newsletters/2018/07/10/#discussion-min-fee-discussion-about-minimum-relay-fee
[#23789]: https://github.com/bitcoin/bitcoin/issues/23789
