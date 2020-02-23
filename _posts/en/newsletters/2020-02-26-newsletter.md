---
title: 'Bitcoin Optech Newsletter #86'
permalink: /en/newsletters/2020/02/26/
name: 2020-02-26-newsletter
slug: 2020-02-26-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes two proposed routing improvements for
LN, summarizes three interesting talks from the Stanford Blockchain
Conference, links to popular questions and answers from the Bitcoin
StackExchange, and lists several notable changes to popular Bitcoin
infrastructure software.

## Action items

*None this week.  Note: the list of releases and release candidates has
been moved to its own [section][release rc section].*

## News

- **Reverse up-front payments:** as described in [Newsletter #72][news72
  upfront], LN developers have been looking for a way to charge a small
  fee for routing an LN payment (HTLC) even if the payment is rejected.
  This can discourage payments that are designed to consume bandwidth
  and liquidity before ultimately failing at no cost.
  This week, Joost Jager [proposed][jager up-front] a new scheme where
  up-front fees are paid from the receiver of an HTLC back towards the
  sender of the payment.  For example, if a payment is being sent from
  Alice to Bob to Carol, then Alice receives a small fee from Bob and
  Bob receives a small fee from Carol.  The fee would be proportional to
  the amount of time the HTLC remained pending, which would incentivize
  quickly routing or rejecting HTLCs and would ensure users of [hold
  invoices][topic hold invoices] (for example,  Carol) paid the routing
  nodes (such as Bob) for tying up their routing capital.

    Several responders seemed to like the idea and began discussing how
    it might be implemented as well as what technical challenges it
    would need to overcome.

- **LN direct messages:** Rusty Russell [proposed][russell dm] allowing
  LN nodes to route encrypted messages between peers without using the
  LN payments mechanism.  This could replace current uses of
  messages-over-payments, such as [Whatsat][], with a simpler protocol
  that might be easier to build upon (such as for the *offers* idea
  described in [Newsletter #72][news72 offers]).  Russell's proposal
  originally specified using the same there-and-back onion routing used
  for LN payments (HTLCs), but developer ZmnSCPxj [proposed][zmn circular] having the
  message sender specify the full path from their node to the message
  recipient and back to the sender.  For example, if Alice wants to
  communicate with Carol, she might choose the following path:

        Alice → Bob → Carol → Dan → Alice

    This type of circle routing would make surveillance more difficult
    and would eliminate the overhead for routing nodes of having to
    store the return path, making the protocol stateless for routing
    nodes.  Discussion remains ongoing as of this writing, with a focus
    on enhancing privacy and preventing the mechanism from being abused
    for spam.

FIXME:jnwebery-sbc-report

## Selected Q&A from Bitcoin StackExchange

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{%
endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure.
Please consider upgrading to new releases or helping to test release
candidates.*

- [Bitcoin Core 0.19.1][] (release candidate)

- [LND 0.9.1][] (release candidate)

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #13339][] wallet: Replace %w by wallet name in -walletnotify script FIXME:bitschmidty

- [Eclair #1325][] allows the `SendToRoute` endpoint to accept routing
  hints that can help the spending node find a path to the receiving
  node.

- [BOLTs #682][] allows the `init` message to include a `networks` field
  with the identifier (chain hash) for the networks the node is
  interested in, which may help prevent nodes on one network (e.g.
  testnet) from connecting to nodes on another network (e.g. mainnet).

- [BOLTs #596][] updates [BOLT2][] to allow LN nodes to advertise that
  they'll accept channel opens over the previous maximum value limit of
  about 0.17 BTC.  This is one of the features of the "wumbo" proposal,
  the other feature being the ability to send larger payments in a
  channel.  See [Newsletter #22][news22 wumbo] for details.

{% include references.md %}
{% include linkers/issues.md issues="1325,886,682,596,13339" %}
[bitcoin core 0.19.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.1/
[sipa nonce updates]: https://github.com/sipa/bips/pull/198
[lnd 0.9.1]: https://github.com/lightningnetwork/lnd/releases/tag/v0.9.1-beta.rc1
[release rc section]: #releases-and-release-candidates
[news72 upfront]: /en/newsletters/2019/11/13/#ln-up-front-payments
[jager up-front]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002547.html
[russell dm]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002552.html
[whatsat]: https://github.com/joostjager/whatsat
[news72 offers]: /en/newsletters/2019/11/13/#proposed-bolt-for-ln-offers
[news83 nonce safety]: /en/newsletters/2020/02/05/#safety-concerns-related-to-precomputed-public-keys-used-with-schnorr-signatures
[news22 wumbo]: /en/newsletters/2018/11/20/#wumbo
[multi-wallet support]: https://github.com/bitcoin/bitcoin/projects/2#card-31911994
[stack exchange harding target answer]: https://bitcoin.stackexchange.com/questions/23912/how-is-the-target-section-of-a-block-header-calculated/36228#36228
[mechanism design]: https://en.wikipedia.org/wiki/Mechanism_design
[selfish mining]: https://www.cs.cornell.edu/~ie53/publications/btcProcFC.pdf
[pvss]: https://en.wikipedia.org/wiki/Publicly_Verifiable_Secret_Sharing
[adaptor signatures]: https://download.wpsoftware.net/bitcoin/wizardry/mw-slides/2018-05-18-l2/slides.pdf
[ring signatures]: https://en.wikipedia.org/wiki/Ring_signature
[bulletproofs]: https://eprint.iacr.org/2017/1066.pdf
[zk-SNARKs]: https://en.wikipedia.org/wiki/Non-interactive_zero-knowledge_proof
[timing attack]: https://en.wikipedia.org/wiki/Timing_attack
[zmn circular]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-February/002555.html
