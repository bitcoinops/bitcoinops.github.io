---
title: 'Bitcoin Optech Newsletter #289'
permalink: /en/newsletters/2024/02/14/
name: 2024-02-14-newsletter
slug: 2024-02-14-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes ideas for relay enhancements after
cluster mempool is deployed, describes results of research into the
topologies and sizes of LN-style anchor outputs in 2023, announces a new
host for the Bitcoin-Dev mailing list, and encourages readers to
celebrate I Love Free Software Day by thanking free software
contributors.  Also included are our regular sections summarizing a
Bitcoin Core PR Review Club meeting and describing notable changes to
popular Bitcoin infrastructure software.

## News

- **Ideas for relay enhancements after cluster mempool is deployed:**
  Gregory Sanders [posted][sanders future] to Delving Bitcoin several
  ideas for allowing individual transactions to opt-in to certain mempool
  policies after [cluster mempool][topic cluster mempool] support has
  been fully implemented, tested, and deployed.  The improvements build
  on the features of [v3 transaction relay][topic v3 transaction relay]
  by relaxing some of its rules that may no longer be needed and adding
  a requirement that a transaction (or a [package][topic package relay]
  of transactions) pay a feerate that makes them likely to be mined
  within the next block or two.

- **What would have happened if v3 semantics had been applied to anchor outputs a year ago?**
  Suhas Daftuar [posted][daftuar retrospective] to Delving Bitcoin about
  his research into the idea of automatically applying [v3 transaction
  relay policy][topic v3 transaction relay] to [anchors-style][topic
  anchor outputs] LN commitment and fee-bumping transactions (see
  [Newsletter #286][news286 imbued] for the underlying _imbued v3_
  proposal).  In short, he recorded 14,124 transactions in 2023 that
  looked like anchor spends.  Of those:

  - About 94% <!-- (14124 - 856) / 14124 --> would have been successful
    under the v3 rules.

  - About 2.1% <!-- 302/14124 --> had more than one parent (e.g.,
    attempts to batch [CPFP][topic cpfp] spends).  Some LN wallets do this for efficiency
    when closing more than one channel within a short amount of time.  They
    would need to disable this behavior if anchor-style outputs were to
    be imbued with v3 properties.

  - About 1.8% <!-- 251/14124 --> were not the first child of the
    parent.  Using the proposal for imbued v3, the second child would be
    able to replace the first child in a [package][topic package relay]
    (see [Newsletter #287][news287 kindred]).

  - About 1.2% <!-- 175/14124 --> were apparently grandchildren of the
    commitment transaction, i.e. spends of the spend of the anchor
    output.  LN wallets might do this for a variety of reasons, from
    closing multiple anchor channels in sequence to opening new channels
    with their change from the anchor close.  LN wallets would be unable
    to use this behavior if anchor-style outputs were imbued with v3
    properties.

  - About 1.2% <!-- 173 / 14124 --> were never mined and weren't
    analyzed further.

  - About 0.1% <!-- 19/14124 --> spent an unrelated unconfirmed output,
    resulting in the anchor spending having more than the allowed one
    parent.  Developer Bastien Teinturier thinks that this may have been
    a behavior of Eclair and notes that Eclair would resolve this
    situation automatically even with its current code.

  - Less than 0.1% <!-- 10/14124 --> were larger than 1,000 vbytes.
    This is also behavior that LN wallets would need to change.
    Daftuar's further research showed that nearly all anchor spends were
    less than 500 vbytes, potentially suggesting that the v3 size limit
    could be reduced.  This would make it less expensive for a defender
    to overcome an attempted [pinning attack][topic transaction pinning]
    against an anchor spend, but it would also prevent LN wallets from
    being able to contribute fees from more than a few UTXOs.
    Teinturier [noted][teinturier better] that "it's very tempting to
    reduce the 1,000 vbytes value, but past data only shows honest
    attempts (with very few pending HTLCs) as we haven’t seen any
    widespread attacks on the network yet, so it’s hard to figure out
    what value would be 'better'."

  Although additional discussion and research on this topic is expected,
  it was our impression from the results that LN wallets might need to
  make a few small changes to better conform with v3 semantics before
  Bitcoin Core could safely start treating anchor spends as v3
  transactions.

- **Bitcoin-Dev mailing list move:** the protocol development discussion
  mailing list is now hosted on a new server with a new email address.
  Everyone who wishes to continue receiving posts needs to resubscribe.
  For details, see the [migration email][] by Bryan Bishop.  For past
  discussion about the migration, see Newsletters [#276][news276 ml] and
  [#288][news288 ml].

- **I Love Free Software Day:** every year on February 14th,
  organizations such as [FSF][] and [FSFE][] encourage users of free
  and open source software (FOSS) to "reach out and say 'Thank you!' to
  all the people maintaining and contributing to Free Software".  Even
  if you're reading this newsletter after Feb 14th, we encourage you to
  take a moment to thank some of your favorite contributors to Bitcoin FOSS
  projects.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review
Club][] meeting, highlighting some of the important questions and
answers.  Click on a question below to see a summary of the answer from
the meeting.*

[Add `maxfeerate` and `maxburnamount` args to `submitpackage`][review club 28950]
is a PR by Greg Sanders (GitHub instagibbs) that adds functionality to the
`submitpackage` RPC that is already present in the single-transaction
RPCs `sendrawtransaction` and `testmempoolaccept`. This PR is part of
the larger [package relay][topic package relay] project. Specifically,
the PR allows a package submitter to specify arguments (mentioned in the
PR title) that enable sanity-checking of the transactions in the requested
package to prevent accidental loss of funds. The review club meeting
was hosted by Abubakar Sadiq Ismail (GitHub ismaelsadeeq).

{% include functions/details-list.md
  q0="Why is it important to perform these checks on submitted packages?"
  a0="It's helpful to users to ensure the transactions within packages
      have the same safeguards as individual transaction submission."
  a0link="https://bitcoincore.reviews/28950#l-27"

  q1="Are there other important checks apart from `maxburnamount` and
      `maxfeerate` that should be performed on packages before they are
      accepted to the mempool?"
  a1="Yes, two examples are the base fee check and maximum standard
      transaction size. These are low-cost checks, so can be checked
      early and fail the package quickly."
  a1link="https://bitcoincore.reviews/28950#l-33"

  q2="The options `maxburnamount` and `maxfeerate` can prevent a
      transaction from entering the mempool and being relayed. Can we
      consider these options as policy rules? Why or why not?"
  a2="This is policy; these checks don't apply to transactions in
      mined blocks (so this isn't consensus). These don't even
      affect relay of transactions from peers, only transactions
      submitted locally using RPC."
  a2link="https://bitcoincore.reviews/28950#l-47"

  q3="Why do we validate maxfeerate against the modified feerate
      instead of the base fee rate?"
  a3="(Earlier review clubs [24152][review club 24152],
      [24538][review club 24538], and [27501][review club 27501]
      covered the concept of modified versus base fees.)
      Most participants thought the base fee should be used instead
      of the modified fee, because `sendrawtransaction` and `testmempoolaccept`
      use the base fee in their checks, so that would seem more consistent.
      It may not make any practical difference since `prioritisetransaction`
      (which makes modified and base fees different) is generally used
      only by miners."
  a3link="https://bitcoincore.reviews/28950#l-69"

  q4="We validate maxfeerate against the modified feerate of individual
      package transactions, not package feerate. When can this be inaccurate?"
  a4="When a package child transaction is rejected because its modified
      fee rate exceeds `maxfeerate` individually, but does not if it's checked
      as a package."
  a4link="https://bitcoincore.reviews/28950#l-84"

  q5="Given that possible inaccuracy, why not check `maxfeerate` against
      package feerate instead?"
  a5="Because this can cause a different inaccuracy. Suppose
      transaction A has zero fee and B CPFPs (bumps) A. Both A and B
      are physically large so neither exceeds `maxfeerate`. But now
      high-fee rate C is added which spends from both A and B.
      (This is an allowed package topology because it's only two levels,
      although it was pointed out that the `submitpackage` RPC doesn't allow
      this topology.) In this case, C would be accepted because much of its
      fee is absorbed by A and B, but C should be rejected."
  a5link="https://bitcoincore.reviews/28950#l-108"

  q6="Why can’t `maxfeerate` be checked immediately after decoding like
      `maxburnamount` is?"
  a6="Because transaction inputs famously don't explicitly state the
      input amount; they can only be known after looking up the parent
      output. The fee rate requires the fee, which requires the input
      amounts."
  a6link="https://bitcoincore.reviews/28950#l-141"

  q7="How does the `maxfeerate` check in `testmempoolaccept` RPC differ
      from `submitpackage` RPC? Why can’t they be the same?"
  a7="`submitpackage` uses modified fees while
      `testmempoolaccept` uses base fees, as explained earlier.
      Also, the fee rate check is done after the `testaccept` package
      processing because the transactions are not added
      to mempool and broadcasted after the processing, so we can safely
      check `maxfeerate` and return appropriate error messages.
      The same can't be done in `submitpackage` because the package
      transactions might have already been accepted into the mempool and
      broadcasted to peers, rendering the check redundant."
  a7link="https://bitcoincore.reviews/28950#l-153"
%}

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Bitcoin Inquisition][bitcoin inquisition repo], and [BINANAs][binana
repo]._

- [Bitcoin Core #28948][] adds support for (but does not enable) [version 3 transaction
  relay][topic v3 transaction relay], allowing any v3 transaction that
  has no unconfirmed parent to enter the mempool according to the normal
  transaction acceptance rules.  The v3 transaction can be [CPFP
  fee-bumped][topic cpfp] but only if the child is 1,000 vbytes or less.
  Each v3 parent may only have one unconfirmed child transaction in the
  mempool and each child may only have one unconfirmed parent.  Either
  the parent or child transaction can always be [replaced by fee][topic
  rbf].  The rules only apply to Bitcoin Core's relay policy; at the
  consensus layer, v3 transactions are validated the same as version 2
  transactions defined in [BIP68][].  The new rules are intended to help
  contract protocols such as LN ensure their precommitted transactions
  can always be confirmed quickly with minimal extra fees needed to
  escape [transaction pinning attacks][topic transaction pinning].

- [Core Lightning #6785][] makes [anchor-style][topic anchor outputs]
  channels the default on Bitcoin.  Non-anchor channels are still used
  for channels on Elements-compatible [sidechains][topic sidechains].

- [Eclair #2818][] maximizes the number of inputs the Eclair wallet
  believes it can safely spend by detecting some cases when an existing
  unconfirmed transaction is very unlikely to become confirmed.  Eclair
  uses Bitcoin Core's wallet to manage its UTXOs for onchain spending,
  including for fee-bumping transactions.  When a UTXO controlled by the
  wallet is used as an input in a transaction, Bitcoin Core's wallet won't
  automatically create other unrelated transactions using that input.
  However, if that transaction becomes unconfirmable because a different
  input in that transaction was double spent, Bitcoin Core's wallet will
  automatically allow the UTXO to be spent in a different transaction
  again.  Unfortunately, if a parent of the transaction is made
  unconfirmable because a different version was confirmed, Bitcoin
  Core's wallet will not currently automatically allow the UTXO to be
  spent.  Eclair can independently detect a double spend of the parent
  transaction and it will now tell Bitcoin Core's wallet to
  [abandon][rpc abandontransaction] Eclair's earlier attempt to unlock
  the UTXO and allow it to be spent again.

- [Eclair #2816][] allows the node operator to choose the maximum amount
  they're willing to spend on an [anchor output][topic anchor outputs]
  to get a commitment transaction confirmed.  Previously Eclair
  would spend up to 5% of the channel value, but that may be too high
  for high-value channels.  Eclair's new default is the maximum feerate
  suggested by its feerate estimator, up to an absolute total of 10,000
  sat.  Eclair will also still pay up to the amount at risk from
  [HTLCs][topic htlc] expiring soon, which could be higher
  than 10,000 sats.

- [LND #8338][] adds initial functions for a new protocol for
  cooperatively closing channels (see [Newsletter #261][news261 close]
  and [BOLTs #1096][]).

- [LDK #2856][] updates LDK's implementation of [route
  blinding][topic rv routing] to ensure the receiver has enough blocks
  to claim a payment.  This is based on an update of the route blinding
  specification in [BOLTs #1131][].

- [LDK #2442][] includes details about each pending [HTLC][topic htlc] in the
  `ChannelDetails`.  This lets the consumer of the API learn what next
  needs to happen to move the HTLC closer to being accepted or rejected.

- [Rust Bitcoin #2451][] removes the requirement that an HD derivation path start
  with an `m`.  In [BIP32][], the string `m` is a variable representing
  the master private key.  When referring to just a path, the `m` is
  unnecessary and may be wrong in some contexts.

{% assign day_after_posting = page.date | date: "%s" | plus: 86400 | date: "%Y-%m-%d 15:00" %}
{% include snippets/recap-ad.md when=day_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="28948,6785,2818,2816,8338,2856,2442,2451,1131,1096" %}
[fsfe]: https://fsfe.org/activities/ilovefs/index.en.html
[fsf]: https://www.fsf.org/blogs/community/i-love-free-software-day-is-here-share-your-love-software-and-a-video
[sanders future]: https://delvingbitcoin.org/t/v3-and-some-possible-futures/523
[news261 close]: /en/newsletters/2023/07/26/#simplified-ln-closing-protocol
[teinturier better]: https://delvingbitcoin.org/t/v3-transaction-policy-for-anti-pinning/340/37
[daftuar retrospective]: https://delvingbitcoin.org/t/analysis-of-attempting-to-imbue-ln-commitment-transaction-spends-with-v3-semantics/527/
[news286 imbued]: /en/newsletters/2024/01/24/#imbued-v3-logic
[news287 kindred]: /en/newsletters/2024/01/31/#kindred-replace-by-fee
[migration email]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2024-February/022327.html
[news276 ml]: /en/newsletters/2023/11/08/#mailing-list-hosting
[news288 ml]: /en/newsletters/2024/02/07/#bitcoin-dev-mailing-list-migration-update
[review club 28950]: https://bitcoincore.reviews/28950
[review club 24152]: https://bitcoincore.reviews/24152
[review club 24538]: https://bitcoincore.reviews/24538
[review club 27501]: https://bitcoincore.reviews/27501
