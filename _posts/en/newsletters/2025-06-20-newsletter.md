---
title: 'Bitcoin Optech Newsletter #359'
permalink: /en/newsletters/2025/06/20/
name: 2025-06-20-newsletter
slug: 2025-06-20-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes a proposal to limit public
participation in Bitcoin Core repositories, announces a significant
improvements to BitVM-style contracts, and summarizes research into
LN channel rebalancing.  Also included are our regular sections
summarizing recent changes to clients and services, announcing new
releases and release candidates, and describing recent changes to popular
Bitcoin infrastructure software.

## News

- **Proposal to restrict access to Bitcoin Core Project discussion:**
  Bryan Bishop [posted][bishop priv] to the Bitcoin-Dev mailing list to
  suggest that the Bitcoin Core Project limit the public's ability to
  participate in project discussions in order to reduce the amount of
  disruption caused by non-contributors.  He called this
  "privatizing Bitcoin Core",
  points to examples of this privatization already happening on an ad
  hoc basis in private offices with multiple Bitcoin Core contributors,
  and warns that in-person privatization leaves out remote contributors.

  Bishop's post suggests a method for online privatization, but
  Antoine Poinsot [questioned][poinsot priv] whether that method would
  achieve the goal.  Poinsot also suggested that many private
  office discussions might occur not out of fear of public reproach but
  because of "the natural advantages of in-person discussions".

  Several replies suggested that making major changes is
  probably not warranted at this time but that stronger moderation of
  comments on the repository might alleviate the most
  significant type of disruption.  However, other replies noted several
  challenges with stronger moderation.

  Poinsot, Sebastian "The Charlatan" Kung, and Russell Yanofsky---the only highly
  active Bitcoin Core contributors to reply to the thread as of the time
  of writing---[indicated][kung priv] either [that][yanofsky priv]  they don't think a major
  change is necessary or that any changes should be made incrementally
  over time.

- **Improvements to BitVM-style contracts:** Robin Linus [posted][linus
  bitvm3] to Delving Bitcoin to announce a significant reduction in the
  amount of onchain space required by [BitVM][topic acc]-style
  contracts.  Based on an [idea][rubin garbled] by Jeremy Rubin that
  builds on new cryptographic primitives, the new approach "reduces the
  onchain cost of a dispute by over 1,000 times compared to the previous
  design", with disprove transactions being "just 200 bytes".

  However, Linus's paper notes the tradeoff for this approach: it
  "requires a multi-terabyte offchain data setup".  The paper gives an
  example of a SNARK verifier circuit with about 5 billion gates and
  reasonable security parameters requiring a 5 TB offchain setup, 56 kB
  onchain transaction to assert the result, and minimal onchain
  transaction (~200 B) in the case that a party needs to prove the
  assertion was invalid.

- **Channel rebalancing research:** Rene Pickhardt [posted][pickhardt
  rebalance] to Delving Bitcoin thoughts about rebalancing channels
  to maximize the rate of successful payments across
  the whole network.  His ideas can be compared to approaches that look
  at smaller groups of channels, such as [friend-of-a-friend
  rebalancing][topic jit routing] (see [Newsletter #54][news54 foaf
  rebalance]).

  Pickhardt notes that there are several challenges to a global approach and
  asks interested parties to answer a few questions, such as whether
  this approach is worth pursuing and how to address certain
  implementation details.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

FIXME:bitschmidty

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [Core Lightning 25.05][] is a release of the next major
  version of this popular LN node implementation.  It reduces the
  latency of relaying and resolving payments, improves fee
  management, provides [splicing][topic splicing] support compatible
  with Eclair, and enables [peer storage][topic peer storage] by
  default.  Note: its [release documentation][core lightning 25.05]
  contains a warning for users of the `--experimental-splicing`
  configuration option.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Eclair #3110][] Increase channel spent delay to 72 blocks

- [Eclair #3101][] Parse offers and pay offers with currency

- [LDK #3817][] Revert attribution of failures

- [LDK #3623][] adi2011/peer-storage/encrypt-decrypt

- [BTCPay Server #6755][] feat(wallet): enhance Coin Selection with advanced filters and improved UX

- [Rust libsecp256k1 #798][] completes the [MuSig2][topic musig]
  implementation in the library, giving downstream projects access to a
  robust [scriptless multisignature][topic multisignature] protocol.

{% include snippets/recap-ad.md when="2025-06-24 16:30" %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="3110,3101,3817,3623,6755" %}
[Core Lightning 25.05]: https://github.com/ElementsProject/lightning/releases/tag/v25.05
[bishop priv]: https://mailing-list.bitcoindevs.xyz/bitcoindev/CABaSBax-meEsC2013zKYJnC3phFFB_W3cHQLroUJcPDZKsjB8w@mail.gmail.com/
[poinsot priv]: https://mailing-list.bitcoindevs.xyz/bitcoindev/4iW61M7NCP-gPHoQZKi8ZrSa2U6oSjziG5JbZt3HKC_Ook_Nwm1PchKguOXZ235xaDlhg35nY8Zn7g1siy3IADHvSHyCcgTHrJorMKcDzZg=@protonmail.com/
[kung priv]: https://mailing-list.bitcoindevs.xyz/bitcoindev/58813483-7351-487e-8f7f-82fb18a4c808n@googlegroups.com/
[linus bitvm3]: https://delvingbitcoin.org/t/garbled-circuits-and-bitvm3/1773
[rubin garbled]: https://rubin.io/bitcoin/2025/04/04/delbrag/
[pickhardt rebalance]: https://delvingbitcoin.org/t/research-update-a-geometric-approach-for-optimal-channel-rebalancing/1768
[rust libsecp256k1 #798]: https://github.com/rust-bitcoin/rust-secp256k1/pull/798
[news54 foaf rebalance]: /en/newsletters/2019/07/10/#brainstorming-just-in-time-routing-and-free-channel-rebalancing
[yanofsky priv]: https://github.com/bitcoin-core/meta/issues/19#issuecomment-2961177626
