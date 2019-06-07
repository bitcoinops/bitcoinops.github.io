---
title: 'Bitcoin Optech Newsletter #44'
permalink: /en/newsletters/2019/04/30/
name: 2019-04-30-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter sees another slow news week but does contain our
regular sections on bech32 sending support, selected questions and
answers from the Bitcoin StackExchange, and notable changes in popular
Bitcoin infrastructure projects.

{% include references.md %}

## Action items

*None at the time of writing.*  Note: if the Bitcoin Core release team
are satisfied that no blocking issues were found in the fourth [release
candidate][0.18.0] distributed last week, they intend to tag the final
release for version 0.18.0 around the time this newsletter is being
published.  If that happens, we'll provide detailed release coverage in
next week's newsletter.  But please don't wait on us if you plan to
upgrade---everything you need to know about the new version is explained
in its release notes, which will be published with or linked to as part
of the various release announcements on different platforms such as
[BitcoinCore.org][].

## News

*None this week.  We hope everyone is enjoying a lovely spring, fall, or
dry season.*

## Bech32 sending support

*Week 7 of 24.  Until the second anniversary of the segwit soft
fork lock-in on 24 August 2019, the Optech Newsletter will contain this
weekly section that provides information to help developers and
organizations implement bech32 sending support---the ability to pay
native segwit addresses.  This [doesn't require implementing
segwit][bech32 series] yourself, but it does allow the people you pay to
access all of segwit's multiple benefits.*

{% comment %}<!-- weekly reminder for harding: check Bech32 Adoption
wiki page for changes -->{% endcomment %}

{% include specials/bech32/07-altbech32.md %}

## Selected Q&A from Bitcoin StackExchange

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments of time to help curious or confused users.  In
this monthly feature, we highlight some of the top voted questions and
answers made since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- ["Do HTLCs work for micropayments?"]({{bse}}85650) David Harding
  and Gregory Maxwell both point out that there is risk in having an output
  with too small of an amount to be spent on-chain, while that payment
  is being routed. A micropayment of less than 546 satoshis would not
  be relayed by the Bitcoin network. The current mitigation is for LN to
  temporarily move such small payments to be a miner fee instead of an
  output, depending on the game theory that if an attacker cannot steal
  money, they won’t spend money to attack.

- [How was the dust limit of 546 satoshis was chosen? Why not 550
  satoshis?]({{bse}}86068) The Bitcoin Core transaction relay policy
  sets a dust limit of 546 satoshis as the minimum amount for an output,
  which seems a peculiar amount. Raghav Sood describes how 546 is three
  times the minimum cost to create and spend a P2PKH output. A reference
  is made to a [2013 discussion][dust convo].

- [History of transactions in Lighting Network.]({{bse}}85901) A LN
  beginner asks how the history of transactions conducted on LN for a
  user can be saved and how a payer receives a proof of payment. Mark H
  responds saying the LN wallet would need to save transaction history
  for a user and provides a nice explanation of how a payment hash
  provided to a payer results in a payment preimage reveal that serves
  as proof of payment.

- [How can my private key be revealed if I use the same nonce while
  generating the signature?]({{bse}}85638) Pieter Wuille provides a
  thorough answer that, if you’re familiar with the math used in
  public key cryptography, demonstrates how a private
  key is revealed in such circumstances.

- [Why do lightning invoices expire?]({{bse}}85981) Rene Pickhardt
  guesses that the primary reason would be a high
  volume recipient with relatively low storage capability could run out
  of storage or memory. An additional reason given is to provide some closure to
  proceed if a payment is not initiated or completed rather than leave
  it dangling. David Harding points out that traditional businesses put
  expiration dates on invoices to avoid an obligation to deliver goods in the
  future at a previously offered price.

- [Are there still miners or mining pools which refuse to implement
  SegWit?]({{bse}}86208) Mark Erhardt provides extensive analysis demonstrating
  that essentially the answer is "no." Only 0.03% non-empty blocks from
  the past year had no SegWit transactions, and the two primary miners of
  those few blocks have demonstrated in 2019 that they’re mining blocks
  with SegWit transactions.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[LND][lnd repo], [C-Lightning][c-lightning repo], [Eclair][eclair repo],
[libsecp256k1][libsecp256k1 repo], and [Bitcoin Improvement Proposals
(BIPs)][bips repo].  Note: unless otherwise noted, all merges described
for Bitcoin Core are to its master development branch; some may also be
backported to its pending release.*

- [Bitcoin Core #14039][] causes Bitcoin Core to reject transactions
  submitted via RPC or received via the P2P network
  if they use the segwit-style extended transaction encoding when they
  don't include any segwit inputs.  The extended transaction encoding
  includes a segwit marker, a segwit flag, and witness data fields.
  Signatures included in legacy inputs don't commit to these fields, so
  adding the fields to a transaction produces a (small) waste of
  bandwidth in a transaction consisting entirely of legacy inputs.  For
  this reason, [BIP144][] specified that transactions which don't need
  the extended format should use the legacy format.  Previously Bitcoin Core accepted
  incorrectly formatted transactions and normalized them by stripping out
  unnecessary segwit-only parts before calculating their size (weight) or
  relaying them to other peers; now it will refuse to accept
  transactions that don't use the appropriate format.

- [Bitcoin Core #15846][] updates the node to accept transactions into
  its mempool for relay and mining if any outputs in the transaction pay
  segwit address versions 1 through 16---the versions reserved for
  future protocol upgrades.  Previously, such transaction would be
  rejected.  Any money sent to a future version address is not secure
  (any miner can spend it) until users enforce a soft fork giving that
  address special meaning, similar to the special meaning of segwit
  version 0 addresses for P2WPKH and P2WSH.  That means no one should be
  using version 1+ addresses today.  However, if anyone does create such
  an address and asks a segwit-supporting wallet or service to pay it,
  this change ensures that the transaction will be relayed and mined
  like any other transaction.  (A future edition of
  this newsletter's *bech32 sending support* section will go into more
  depth about the addresses for future segwit versions.)

- [Eclair #950][] stops sending channel disabled updates each time a
  node disconnects, but instead only sends them if someone requests the
  node route a payment through a channel whose node is disconnected.
  This prevents notifying the network about channels nobody is actually
  trying to use.  The PR makes several other minor changes to how the
  node handles network gossip with the aim to reduce unnecessary
  traffic.

{% include linkers/issues.md issues="14039,15846,950" %}
[0.18.0]: https://bitcoincore.org/bin/bitcoin-core-0.18.0/
[dust convo]: https://github.com/bitcoin/bitcoin/pull/2577#issuecomment-17738577
[bitcoincore.org]: https://bitcoincore.org/
[bech32 series]: /en/bech32-sending-support/
