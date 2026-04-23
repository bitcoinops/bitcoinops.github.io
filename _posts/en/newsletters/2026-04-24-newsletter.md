---
title: 'Bitcoin Optech Newsletter #402'
permalink: /en/newsletters/2026/04/24/
name: 2026-04-24-newsletter
slug: 2026-04-24-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes Hornet Node's work on a declarative executable
specification of consensus rules and summarizes a discussion about onion message
jamming in the Lightning Network. Also included are our regular sections with
selected questions and answers from the Bitcoin Stack Exchange, announcements of
new releases and release candidates, and descriptions of notable changes to
popular Bitcoin infrastructure software.

## News

- **Hornet Node's declarative executable specification of Bitcoin consensus rules**:
  Toby Sharp [posted][topic hornet update] to Delving Bitcoin and the Bitcoin-Dev [mailing
  list][hornet ml post] an update on the Hornet node project. Sharp had
  [previously][topic hornet] described a new node implementation Hornet that
  reduced initial block download times from 167 minutes down to 15 minutes. In
  this update, he reports completing a declarative specification of non-script
  block validation rules, consisting of 34 semantic invariants composed using a
  simple algebra.

  Sharp also outlines future work, including extending the specification to
  script validation, and discusses potential comparisons with other
  implementations such as libbitcoin in response to feedback from Eric Voskuil.

- **Onion message jamming in the Lightning Network**: Erick Cestari [posted][onion del] to
  Delving Bitcoin about the [onion message][topic onion messages] jamming problem affecting
  the Lightning Network. BOLT4 acknowledges onion messages to be unreliable, recommending
  to apply rate limiting techniques. According to Cestari, these techniques are what makes message jamming possible. Attackers
  may spin up malicious nodes and flood the network with spam messages triggering rate limits
  of peers, forcing them to drop legitimate messages. Moreover, BOLT4 does not enforce a
  maximum message length, allowing attackers to maximize the reach of a single message.

  Cestari reviewed several mitigations to onion message jamming and provided a
  comprehensive overview of the techniques he deemed more suitable:

  - *Upfront fees*: This technique was first proposed by Carla Kirk-Cohen in [BOLTs #1052][]
    as a solution for channel jamming, but can be easily extended. Nodes would advertise a per-message
    flat fee, to be included in the onion payload and deducted at each hop. In case the fee is not
    paid, the message would be just dropped by the node. This method presents some limitations, such
    as being able to only forward messages to channel peers and increased p2p overhead.

  - *Hop limit and proof-of-stake based on channel balances*: This technique was [proposed][mitig2 onion]
    by Bashiri and Khabbazian at the University of Alberta and has two different components:

    - Leashing hop count: Either setting a hard-cap on the maximum number of hops that a message could do
      (e.g. 3 hops), or having the sender solve a proof-of-work puzzle, whose difficulty increases
      exponentially with the number of hops.

    - Proof-of-stake forwarding rule: Each node sets per-peer rate limits according to the peer's aggregate
      channel balance, granting well-funded nodes more forwarding power.

    The trade-offs of this approach are related to centralization pressure, due to larger nodes being at
    an advantage, while the 3-hops hard-cap could reduce anonymity set.

  - *Bandwidth metered payment*: [Proposed][mitig3 onion] by Olaoluwa Osuntokun, this technique is
    similar in scope as upfront fees, but adds per-session state and settles through
    [AMP payments][topic amp]. A sender would first send the AMP payment, dropping fees
    at each intermediate step and delivering an ID for the session. The sender would then include the
    ID in the onion message. Known limitations of the approach are related to the ability to only forward
    messages to channel peers and the possibility to link all the messages belonging to the same session.

  - *Backpropagation-based rate limiting*: This approach, [proposed][mitig4 onion] by Bastien Teinturier,
    uses a backpressure mechanism that is statistically able to trace back spam to its source.
    When the per-peer rate limiting is hit, the node sends a drop message back to the sender, which in turn
    relays it to the last peer that forwarded the original message halving its rate limit. While the correct
    sender is statistically identified, the wrong peer could be penalized. Moreover, an attacker could fake
    the drop message, lowering rate limits of honest nodes.

  Finally, Cestari invited LN developers to join the discussion, stating that a window is still available to
  mitigate the issue before prolonged DDoS attacks hit the network, as [happened to Tor][tor issue] recently.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Why did BIP342 replace CHECKMULTISIG with a new opcode, instead of just removing FindAndDelete from it?]({{bse}}130665)
  Pieter Wuille explains that the replacement of `OP_CHECKMULTISIG` with
  `OP_CHECKSIGADD` in [tapscript][topic tapscript] was necessary to enable batch
  verification of [schnorr][topic schnorr signatures] signatures (see
  [Newsletter #46][news46 batch]) in a potential future protocol change.

- [Does SIGHASH_ANYPREVOUT commit to the tapleaf hash or the full taproot merkle path?]({{bse}}130637)
  Antoine Poinsot confirms that [SIGHASH_ANYPREVOUT][topic sighash_anyprevout]
  signatures currently commit only to the tapleaf hash, not the full merkle path
  in the [taproot][topic taproot] tree. However, this design is under discussion
  as one BIP co-author has suggested committing to the full merkle path instead.

- [What does the BIP86 tweak guarantee in a MuSig2 Lightning channel, beyond address format?]({{bse}}130652)
  Ava Chow points out that the tweak prevents the use of hidden script paths
  because [MuSig2's][topic musig] signing protocol requires all participants to
  apply the same [BIP86][] tweak for signature aggregation to succeed. If one
  party attempts to use a different tweak, such as one derived from a hidden
  script tree, their partial signature won't aggregate into a valid final
  signature.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

FIXME:Gustavojfe

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

FIXME:Gustavojfe

{% include snippets/recap-ad.md when="2026-04-28 16:30" %}
{% include references.md %}
[news46 batch]: /en/newsletters/2019/05/14/#new-script-based-multisig-semantics
[topic hornet update]: https://delvingbitcoin.org/t/hornet-update-a-declarative-executable-specification-of-consensus-rules/2420
[hornet ml post]: https://groups.google.com/g/bitcoindev/c/M7jyQzHr2g4
[topic hornet]: /en/newsletters/2026/02/06/#a-constant-time-parallelized-utxo-database
[onion del]: https://delvingbitcoin.org/t/onion-message-jamming-in-the-lightning-network/2414
[mitig2 onion]: https://ualberta.scholaris.ca/items/245a6a68-e1a6-481d-b219-ba8d0e640b5d
[mitig3 onion]: https://diyhpl.us/~bryan/irc/bitcoin/bitcoin-dev/linuxfoundation-pipermail/lightning-dev/2022-February/003498.txt
[mitig4 onion]: https://diyhpl.us/~bryan/irc/bitcoin/bitcoin-dev/linuxfoundation-pipermail/lightning-dev/2022-June/003623.txt
[tor issue]: https://blog.torproject.org/tor-network-ddos-attack/
