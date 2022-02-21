---
title: 'Bitcoin Optech Newsletter #188'
permalink: /en/newsletters/2022/02/23/
name: 2022-02-23-newsletter
slug: 2022-02-23-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a discussion about fee bumping and
transaction fee sponsorship, describes a proposal for an updated LN
gossip wire protocol, and advertises a signet for testing
`OP_CHECKTEMPLATEVERIFY`.  Also included are our regular sections with
selected questions and answers from the Bitcoin Stack Exchange and
descriptions of notable changes to popular Bitcoin infrastructure
projects.

## News

- **Fee bumping and transaction fee sponsorship:** separate from the
  replace-by-fee discussion started a couple weeks ago (see [Newsletter
  #186][news186 rbf]), this week James O'Beirne [started][obeirne bump]
  a discussion about fee bumping.  In particular, O'Beirne is concerned
  that some of the transaction relay policy changes being proposed will
  complicate the use of fee bumping for users and wallet developers.  As
  an alternative, he seeks renewed consideration of [transaction fee
  sponsorship][topic fee sponsorship] (previously described in
  [Newsletter #116][news116 sponsorship]).

    The ideas received significant discussion on the mailing list, with
    many responses mentioning challenges to implementation of fee
    sponsorship.

- **Updated LN gossip proposal:** Rusty Russell [posted][russell gossip]
  to the Lightning-Dev mailing list a detailed proposal for a new set of
  LN gossip messages similar to his 2019 proposal described in
  [Newsletter #55][news55 gossip].  The new proposal uses
  [BIP340][]-style [schnorr signatures][topic schnorr signatures] and
  [x-only public keys][news72 xonly].  Also included are a number of
  simplifications over the existing LN gossip protocol, which is used to
  advertise the existence of public channels for routing.  The updated
  protocol is designed to maximize efficiency, especially when combined
  with an [erlay][topic erlay]-like [minisketch][topic minisketch]-based
  efficient gossip protocol.

- **CTV signet:** Jeremy Rubin [published][rubin ctv signet] parameters
  and code for a [signet][topic signet] with
  [OP_CHECKTEMPLATEVERIFY][topic op_checktemplateverify] activated.
  This simplifies public experimentation with the proposed opcode and
  makes it much easier to test compatibility between different software
  using the code.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME:bitschmidty

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #24307][] RPC: Return external_signer in getwalletinfo FIXME:Xekyo

- [C-Lightning #5010][] preliminary rust lang support FIXME:dongcarl

- [LDK #1199][] adds support for "phantom node payments", payments that
  can be accepted by any one of several nodes, which can be used for
  load balancing.  This requires creating LN invoices with [BOLT11][] route
  hints that suggest multiple paths all to the same non-existent
  ("phantom") node.  For each of the paths, the last hop before reaching
  the phantom node is a real node that knows the phantom node's key for
  decrypting and reconstructing [stateless invoices][topic stateless
  invoices] (see [Newsletter #181][news181 rl1177]), allowing it to
  accept the payment's [HTLC][topic htlc].

  {:.center}
  ![Phantom node route hints illustration](/img/posts/2022-02-phantom-node-payments.dot.png)

{% include references.md %}
{% include linkers/issues.md v=1 issues="24307,5010,1199," %}
[news186 rbf]: /en/newsletters/2022/02/09/#discussion-about-rbf-policy
[obeirne bump]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019879.html
[news116 sponsorship]: /en/newsletters/2020/09/23/#transaction-fee-sponsorship
[russell gossip]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2022-February/003470.html
[news72 xonly]: /en/newsletters/2019/11/13/#x-only-pubkeys
[news55 gossip]: /en/newsletters/2019/07/17/#gossip-update-proposal
[rubin ctv signet]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-February/019925.html
[news181 rl1177]: /en/newsletters/2022/01/05/#rust-lightning-1177
