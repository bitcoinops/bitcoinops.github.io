---
title: 'Bitcoin Optech Newsletter #257'
permalink: /en/newsletters/2023/06/28/
name: 2023-06-28-newsletter
slug: 2023-06-28-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes an idea for preventing the pinning of
coinjoin transactions and describes a proposal for speculatively using
hoped-for consensus changes.   Also included is another entry in our
limited weekly series about mempool policy, plus our regular sections
describing popular questions and answers on the Bitcoin Stack Exchange,
new releases and release candidates, and changes to popular Bitcoin
infrastructure software.

## News

- **Preventing coinjoin pinning with v3 transaction relay:** Greg
  Sanders [posted][sanders v3cj] to the Bitcoin-Dev mailing list a
  description for how the proposed [v3 transaction relay rules][topic v3
  transaction relay] could allow creating a [coinjoin][topic
  coinjoin]-style multiparty transaction that wouldn't be vulnerable to
  [transaction pinning][topic transaction pinning].  The specific
  concern with pinning is that one of the participants in a coinjoin can
  use their input to the transaction to create a conflicting transaction
  that prevents the coinjoin transaction from confirming.

    Sanders proposes that coinjoin-style transactions can avoid this
    problem by having each participant initially spend their bitcoins to
    a script that can only be spent by either a signature from all
    participants in the coinjoin or by just the participant after a
    timelock expires.  Alternatively, for a coordinated coinjoin, the
    coordinator and the participant must sign together (or the
    participant alone after the timelock expiration).

    Up until the timelock expires, the participant must now get either
    the other parties or the coordinator to co-sign any conflicting
    transactions, which they are unlikely to do unless signing would be
    in the best interests of all the participants (e.g. a [fee
    bump][topic rbf]).

- **Speculatively using hoped-for consensus changes:** Robin Linus
  [posted][linus spec] to the Bitcoin-Dev mailing list an idea for
  spending money to a script fragment that can't be executed for a long
  time (such as 20 years).  If that script fragment is interpreted under
  current consensus rules, it will allow miners in 20 years to claim all
  the funds paid to it.  However, the fragment is designed so that an
  upgrade to the consensus rules will give the fragment a different
  meaning.  Linus gives the example of an `OP_ZKP_VERIFY` opcode that,
  if added to Bitcoin, will allow anyone providing a Zero-Knowledge
  Proof (ZKP) for a program with a particular hash to claim the funds.

    This could allow people to spend BTC today to one of these scripts
    and use the proof of that spend to receive an equivalent amount of
    BTC on a [sidechain][topic sidechains] or alternative chain, called a
    _one-way peg_.  The BTC on the other chain could be spent repeatedly
    for 20 years, until the script timelock expired.  Then the current
    owner of the BTC on the other chain could generate a ZKP proof that
    they owned it and use that proof to withdraw the locked deposit on
    the Bitcoin mainnet, creating a _two-way peg_.  With a good design
    for the verification program, the withdrawal would be simple and
    flexible, which would allow for fungible withdrawals.

    The authors note that anyone who would benefit from this
    construction (e.g. who receives BTC on another chain) is basically
    making a bet that Bitcoin's consensus rules will be changed (e.g.
    `OP_ZKP_VERIFY` will be added).  This gives them an incentive to
    advocate for the change, but heavily incentivizing some users to
    change the system may result in other users feeling like they're
    being coerced.  The idea had not received any discussion on the
    mailing list as of this writing.

## Waiting for confirmation #7: Network Interest

_A limited weekly [series][policy series] about transaction relay,
mempool inclusion, and mining transaction selection---including why
Bitcoin Core has a more restrictive policy than allowed by consensus and
how wallets can use that policy most effectively._

{% include specials/policy/en/07-network-interest.md %}

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Why do Bitcoin nodes accept blocks that have so many excluded transactions?]({{bse}}118707)
  User commstark wonders why a node accepts a block from miners that exclude
  transactions that were anticipated for that block according to that node's
  [block template][reference getblocktemplate]. There are various [tools][miningpool observer] that
  [show][mempool space] expected compared to actual blocks. Pieter Wuille points
  out that due to inherent variance in different nodes' [mempools][waiting for
  confirmation 1] related to transaction propagation, a consensus rule enforcing
  block contents is not possible.

- [Why does everyone say that soft forks restrict the existing ruleset?]({{bse}}118642)
  Pieter Wuille uses the rules added during the [taproot][topic taproot] and
  [segwit][topic segwit] soft fork [activations][topic soft fork activation] as
  examples of tightening the consensus rules:

  - taproot added the requirement that `OP_1 <32 bytes>` (taproot) output spends
    adhere to the taproot consensus rules
  - segwit added the requirement that `OP_{0..16} <2..40 bytes>` (segwit) output
    spends adhere to the segwit consensus rules and also requires empty witness
    data for pre-segwit outputs

- [Why is the default LN channel limit set to 16777215 sats?]({{bse}}118709)
  Vojtěch Strnad explains the 2^24 satoshi limit history and motivation for
  large (wumbo) channels and also links to Optech's [large channel topic][topic
  large channels] for more information.

- [Why does Bitcoin Core use ancestor score instead of just ancestor fee rate to select transactions?]({{bse}}118611)
  Sdaftuar explains that performance optimization is the reason that the mining
  block template transaction selection algorithm uses both the ancestor feerate and ancestor
  score. (See [Waiting for confirmation #2: Incentives][waiting for confirmation
  2]).

- [How does Lightning multipart payments (MPP) protocol define the amounts per part?]({{bse}}117405)
  Rene Pickhardt points out that [multipath payments][topic multipath payments]
  do not have a protocol-specified part size or algorithm for choosing part size and
  points out some relevant payment-splitting research.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [BTCPay Server 1.10.3][] is the latest release for this self-hosted
  payment processing software.  See their [blog post][btcpay 1.10] for a
  tour of the headline features in the 1.10 branch.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo], and
[Bitcoin Inquisition][bitcoin inquisition repo].*

- [Core Lightning #6303][] adds a new `setconfig` RPC that allows
  changing some configuration options without restarting the daemon.

- [Eclair #2701][] begins recording both when an offered [HTLC][topic
  htlc] is received and when it is settled.  This allows tracking how
  long the HTLC was pending from the node's perspective.  If many HTLCs,
  or a few high-value HTLCs, are pending for long periods of time, this
  may indicate a [channel jamming attack][topic channel jamming attacks]
  is in progress.  Tracking HTLC duration helps detect such attacks and
  may contribute to mitigating them.

- [Eclair #2696][] changes how Eclair allows users to configure what
  feerates to use.  Previously, users could specify what feerate to use
  with a _block target_, e.g. a setting of "6" meant Eclair would try to
  get a transaction confirmed within six blocks.  Now Eclair accepts
  "slow", "medium", and "fast", which it translates into specific
  feerates using constants or block targets.

- [LND #7710][] adds the ability for plugins (or the daemon itself) to
  retrieve data received earlier in an HTLC.  This is necessary for
  [route blinding][topic rv routing] and may be used by various [channel
  jamming][topic channel jamming attacks] countermeasures, among other
  ideas for future features.

- [LDK #2368][] allows accepting new channels created by a peer that use
  [anchor outputs][topic anchor outputs] but requires the controlling
  program deliberately choose to accept each new channel.  This is done
  because properly settling an anchor channel may require the user to have
  access to one or more UTXOs with sufficient value.  LDK, as a library
  that is unaware of what non-LN UTXOs the user's wallet controls, uses
  this prompt to give the controlling program a chance to verify that it
  has the necessary UTXOs.

- [LDK #2367][] makes [anchor channels][topic anchor outputs] accessible
  to regular consumers of the API.

- [LDK #2319][] allows a peer to create an HTLC that commits to paying
  less than the amount the original spender said should be paid,
  allowing the peer to keep the difference for itself as an extra fee.  This
  is useful for the creation of [JIT channels][topic jit channels] where
  a peer receives an HTLC for a receiver that doesn't have a channel
  yet.  The peer creates an onchain transaction that funds the channel
  and commits to the HTLC within that channel---but it incurs additional
  transaction fees in creating that onchain transaction.  By taking an
  extra fee, it is compensated for its costs if the receiver accepts the
  new channel and settles the HTLC on time.

- [LDK #2120][] adds support for finding a route to a receiver who is
  using [blinded paths][topic rv routing].

- [LDK #2089][] adds an event handler that makes it easy for wallets to
  fee bump any [HTLCs][topic htlc] that need to be settled onchain.

- [LDK #2077][] refactors a large amount of code to make it easier later
  to add support for [dual funded channels][topic dual funding].

- [Libsecp256k1 #1129][] ElligatorSwift + integrated x-only DH FIXME:Xekyo

{% include references.md %}
{% include linkers/issues.md v=2 issues="6303,2701,2696,7710,2368,2367,2319,2120,2089,2077,1129" %}
[policy series]: /en/blog/waiting-for-confirmation/
[sanders v3cj]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021780.html
[linus spec]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2023-June/021781.html
[BTCPay Server 1.10.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.10.3
[btcpay 1.10]: https://blog.btcpayserver.org/btcpay-server-1-10-0/
[miningpool observer]: https://miningpool.observer/template-and-block
[mempool space]: https://mempool.space/graphs/mining/block-health
[waiting for confirmation 1]: /en/blog/waiting-for-confirmation/#why-do-we-have-a-mempool
[reference getblocktemplate]: https://developer.bitcoin.org/reference/rpc/getblocktemplate.html
[waiting for confirmation 2]: /en/blog/waiting-for-confirmation/#incentives
