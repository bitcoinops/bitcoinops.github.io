---
title: 'Bitcoin Optech Newsletter #6'
permalink: /en/newsletters/2018/07/31/
name: 2018-07-31-newsletter
slug: 2018-07-31-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter includes the usual dashboard and action items, a
feature article by developer Anthony Towns about the consolidation of
four million UTXOs at Xapo, news about possible upgrades to Bitcoin's
script system, links to a few highly-voted questions and answers on
the Bitcoin StackExchange, and some notable commits in the development
branches of the Bitcoin Core, Lightning Network Daemon (LND), and
C-lightning projects.

## Action items

- **Bitcoin Core 0.16.2 released:** a minor release that brings bug
  fixes and minor improvements.  If you use the [abandontransaction][rpc
  abandontransaction] or [verifytxoutproof][rpc verifytxoutproof] RPCs,
  you should particularly consider upgrading.  Otherwise, we recommend
  you review the [release notes][bitcoin core 0.16.2] for other changes
  that may affect your operation and upgrade when convenient.

## Dashboard items

- **Fees still low:** hash rate increased difficulty by more than 14%
  in the 2,016-block retarget period ending Sunday, giving an average
  time between blocks of 8 minutes and 41 seconds. This helped to absorb the
  increased transaction load from the past week's price
  speculation. Immediately following a difficulty retarget, the average
  time between blocks is restored to 10 minutes.

  As we transition away from the normal weekend transaction lull into the
  new week, there's the possibility for a rapid increase in estimated
  transaction fees.  We recommend being careful sending large low-fee
  transactions such as consolidations until closer to the weekend when
  transaction volume begins to taper off again.

## Field Report: Consolidation of 4 Million UTXOs at Xapo

*by [Anthony Towns](https://twitter.com/ajtowns), Developer on Bitcoin Core at [Xapo][]*

{% include articles/towns-xapo-consolidation.md hlevel='###' %}

## News

- **"Improvements in the Bitcoin Scripting Language" by Pieter
  Wuille:** a talk last week giving a high-level overview of several
  possible near-term improvements to Bitcoin.  We highly recommend
  watching the [video][sfdev video], viewing the [slides][sipa slides],
  or reading the [transcript][kanzure transcript] (with references) by
  Bryan Bishop---but if you're too busy, here's Wuille's conclusion: "my
  initial focus here is Schnorr signatures and taproot. The reason for
  this focus is that the ability to make any input and output in the
  cooperative case look identical is an enormous win for how script
  execution works.

    "Schnorr is necessary for this because without it we cannot encode
    multiple parties into a single key. Having multiple branches in
    there is a relatively simple change.

    "If you look at the consensus changes necessary for these things,
    it's really remarkably small, dozens of lines of code. It looks like
    a lot of the complexity is in explaining why these things are useful
    and how to use them and not so much in the impact on the consensus
    rules.

    "Things like aggregation, I think, are something that can be
    done after we have explored various options for structural
    improvements to the scripting language, once it's clear around what
    the structuring should be, because we will probably learn from the
    deployments how these things get used in practice. That's what I'm
    working on with a number of collaborators and we'll hopefully be
    proposing something soon, and that's the end of my talk."

[sfdev video]: https://www.youtube.com/watch?v=YSUVRj8iznU
[sipa slides]: https://prezi.com/view/YkJwE7LYJzAzJw9g1bWV/
[kanzure transcript]: http://diyhpl.us/wiki/transcripts/sf-bitcoin-meetup/2018-07-09-taproot-schnorr-signatures-and-sighash-noinput-oh-my/

## Selected Q&A from Bitcoin StackExchange

{% comment %}<!--
https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer
-->{% endcomment %}

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments of time to help answer other people's questions.  In
this new monthly feature, we highlight some of the top voted questions
and answers made there in the past month.*

- [Schnorr versus ECDSA][bse 77235]: in this answer, Bitcoin protocol
  developer Pieter Wuille explains some of the chief advantages of the
  Schnorr signature scheme over Bitcoin's current ECDSA signature
  scheme.

- [Why does HD key derivation stop working after a certain index in
  BIP44 wallets?][bse 76998]: a developer testing his wallet finds that
  a payment sent to low-numbered key indexes works as expected, but
  payments sent to high-numbered indexes never appear in his wallets.
  An answer from Viktor T. reveals why.

- [The maximum size of a Bitcoin DER-encoded signature is...][bse
  77191]: in this answer, Pieter Wuille provides the math for calculating
  the size of a Bitcoin signature.  As mentioned in [Newsletter #3][],
  the maximum size using a regular wallet is 72 bytes---but Wuille
  explains how you can create a non-standard transaction with a 73 byte
  signature and why you might think you saw a signature that was 74 or
  even 75 bytes.

- [If you can use almost any opcode in P2SH, why can't you use them in
  scriptPubKeys?][bse 76541]: in this answer, Bitcoin technical writer
  David A. Harding explains why early versions of Bitcoin restricted the
  types of transactions that could be sent to "standard transactions"
  and why most of those restrictions are still in place even though
  almost all opcodes are available for standard use now via P2SH and
  segwit P2WSH.

## Notable commits

*A quick look at recent merges and commits made in various open source
Bitcoin projects.*

{% comment %}
bitcoin: git log --merges 07ce278455757fb46dab95fb9b97a3f6b1b84faf..ef4fac0ea5b4891f4529e4b59dfd1f7aeb3009b5
lnd: git log --topo-order -p 271db7d06da3edf696e22109ce0277eaff11cc5e..92b0b10dc75de87be3a9f895c8dfc5a84a2aec7a
c-lightning: git log --topo-order -p d84d358562a3bcdf48856fdea24511907ff53fd9..0b597f671aa31c1c56d32a554fcdf089646fc7c1
{% endcomment %}

- [Bitcoin Core #12257][]: if you start Bitcoin Core with the
  optional flag `-avoidpartialspends`, the wallet will by default spend
  all outputs received to the same address whenever any one of them
  would be spent.  This prevents two outputs to the same address from being spent
  in separate transactions, which is a common way address reuse reduces
  privacy.  The downside is that it may make transactions larger than
  the smallest they need to be.  Bitcoin businesses using Bitcoin Core's
  built-in wallet who don't need the extra privacy may still want to
  toggle this flag on when fees are low for automatic consolidation of
  related inputs.

- [LND #1617][]: updates estimates for the size of on-chain
  transactions to prevent transactions from accidentally paying too low
  of a fee and getting stuck.  [This commit][lnd
  ee2f2573c1b1b33288d05ba59a1e8ef9e8fb621c] may be interesting for
  anyone wondering about the size of the transactions (and parts of
  transactions) produced in the current protocol.

- [LND #1531][]: the daemon no longer looks for spends in the memory
  pool---it waits for them to be a confirmed part of a block first.
  This allows the same code to work on full nodes like Bitcoin Core and
  btcd as well as on [BIP157][]-based lightweight clients that don't have
  access to unconfirmed transactions.  This is part of the ongoing effort
  to help people without full nodes use LN.

- In several commits, [C-lightning][] developers have mostly completed
  the transition from handling peer-related functions in `gossipd` to
  handling them in `channeld` or `connectd` as appropriate.

- C-lightning has improved its secret handling so that secrets and
  signatures are always generated and stored by a separate daemon than the
  parts of the system directly connected to the network.

{% include references.md %}
{% include linkers/issues.md issues="1617,1531,12257" %}

{% assign bse = "https://bitcoin.stackexchange.com/a/" %}
[bse 77235]: {{bse}}77235
[bse 76998]: {{bse}}76998
[bse 77191]: {{bse}}77191
[bse 76541]: {{bse}}76541

[lnd ee2f2573c1b1b33288d05ba59a1e8ef9e8fb621c]: https://github.com/lightningnetwork/lnd/commit/ee2f2573c1b1b33288d05ba59a1e8ef9e8fb621c
