---
title: 'Bitcoin Optech Newsletter #142'
permalink: /en/newsletters/2021/03/31/
name: 2021-03-31-newsletter
slug: 2021-03-31-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a paper and a short discussion about
probabilistic path selection for LN and includes our regular sections with
summaries of popular questions and answers from the Bitcoin
StackExchange, release and release candidates, and notable changes to
Bitcoin infrastructure software.

## Action items

- **Upgrade BTCPay Server to 1.0.7.1:** this [release][btcpay server
  1.0.7.1] fixes "one critical and several low-impact vulnerabilities
  that affected BTCPay Server versions 1.0.7.0 and older", according to
  the project's release notes.

## News

- **Paper on probabilistic path selection:** René Pickhardt
  [posted][pickhardt post] to the Lightning-Dev mailing list a
  [paper][pickhardt et al] he co-authored with Sergei Tikhomirov, Alex
  Biryukov, and Mariusz Nowostawski.  The paper models a network of
  channels having a uniform distribution of balances within their
  respective channel capacity.  E.g., for a channel with the capacity of
  100 million satoshis between Alice and Bob, the paper assumes all of
  the following states are equally as likely for that channel, and that
  the same holds true for every other channel on the network:

    | Alice | Bob |
    | 0 sat | 100,000,000 sat |
    | 1 sat | 99,999,999 sat |
    | ... | ...|
    | 100,000,000 sat | 0 sat |

   Making this assumption allows the authors to draw conclusions about
   the probability that a payment will succeed based on its amount and how
   many hops (channels) it needs to traverse.  This allows the authors to
   prove the benefit of several known heuristics---such as keeping paths
   short and using [multipath payments][topic multipath payments] to break
   larger payments into smaller payments (under certain other
   assumptions).  They also use the model to evaluate new proposals,
   such as allowing [Just-In-Time (JIT) rebalancing][topic jit routing]
   via [bolts #780][].

   The paper uses its conclusions to provide a routing algorithm that it
   claims can reduce payment retry attempts by 20% compared to their
   simplification of existing routing algorithms.  The new algorithm
   prefers routes with a higher computed probability of success, whereas
   existing algorithms use a heuristic approach.  Combined with JIT
   rebalancing, they estimate a 48% improvement.  Given that each retry
   usually requires several seconds, and could take much longer in some
   cases, this could provide an improved user experience.
   The algorithm was tested against several example networks, including
   one drawn from a snapshot of almost 1,000 live channels.

   The paper deliberately does not take routing fees into consideration,
   and most responses on the mailing list focused on how to
   use the results while still ensuring users don't pay an excessive
   amount of fees.

- **Updated article about payment batching:** Optech has published an
  [article about payment batching][batching post], updated from our
  original announcement of it in [Newsletter #37][news37 batching].
  Payment batching is a technique that can help spenders save up to 80%
  on transaction fees.

## Selected Q&A from Bitcoin StackExchange

*[Bitcoin StackExchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

FIXME:bitschmidty

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BTCPay Server 1.0.7.1][] fixes several security vulnerabilities.  It
  also includes a number of improvements and non-security bug fixes.

- [HWI 2.0.1][] is a bugfix release that addresses minor issues with Trezor
  T passphrase entry and keyboard shortcuts in the `hwi-qt` user
  interface.

- [C-Lightning 0.10.0-rc2][C-Lightning 0.10.0] is a release candidate
  for the next major version of this LN node software.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[Bitcoin Improvement Proposals (BIPs)][bips repo], and [Lightning
BOLTs][bolts repo].*

- [Bitcoin Core #17227][] Qt: Add Android packaging support FIXME:jnewbery

- [Rust-Lightning #849][] makes a channel's `cltv_expiry_delta`
  configurable and reduces the default value from 72 blocks to 36
  blocks.  This parameter sets the deadline by which a node must settle
  a payment attempt with its upstream peer after learning from its
  downstream peer whether that payment succeeded; it must be long enough
  to confirm a transaction onchain if necessary but should
  be short enough that it's competitive with other nodes that are trying
  to minimize possible delays.  See also [Newsletter #40][news40
  cltv_expiry_delta] where LND reduced its value to 40 blocks.

- [C-Lightning #4427][] makes it possible to experiment with
  [dual funded][topic dual funding] payment channels by using the configuration option
  `--experimental-dual-fund`.  Dual funding allows funds for the initial
  channel balance to be contributed by both the node initiating the
  channel and the node accepting the channel, which can be useful for
  merchants and other users who want to begin receiving payments as
  soon as the channel finishes opening.

- [Eclair #1738][] Handle aggregated anchor outputs htlc txs FIXME:dongcarl

- [BIPs #1080][] updates [BIP8][] with a `minimum_activation_height`
  parameter that delays the time nodes begin enforcing a locked-in soft
  fork until after the specified height.  This makes BIP8 compatible
  with the *Speedy Trial* proposal (see [Newsletter #139][news139 speedy
  trial]) that would allow miners to activate [taproot][topic taproot]
  but would not begin enforcing taproot's rules until roughly six months
  after the release of software implementing Speedy Trial.

{% include references.md %}
{% include linkers/issues.md issues="17227,849,4427,1738,1080,1080,780" %}
[c-lightning 0.10.0]: https://github.com/ElementsProject/lightning/releases/tag/v0.10.0rc2
[hwi 2.0.1]: https://github.com/bitcoin-core/HWI/releases/tag/2.0.1
[news40 cltv_expiry_delta]: /en/newsletters/2019/04/02/#lnd-2759
[pickhardt post]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-March/002984.html
[pickhardt et al]: https://arxiv.org/abs/2103.08576
[news139 speedy trial]: /en/newsletters/2021/03/10/#a-short-duration-attempt-at-miner-activation
[btcpay server 1.0.7.1]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.0.7.1
[batching post]: /en/payment-batching/
[news37 batching]: /en/newsletters/2019/03/12/#optech-publishes-book-chapter-about-payment-batching
