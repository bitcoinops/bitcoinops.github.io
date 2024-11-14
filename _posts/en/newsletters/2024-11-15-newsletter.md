---
title: 'Bitcoin Optech Newsletter #329'
permalink: /en/newsletters/2024/11/15/
name: 2024-11-15-newsletter
slug: 2024-11-15-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes a new offchain payment resolution
protocol and links to papers about potential IP-layer tracking and
censorship of LN payments.  Also included are announcements of new
releases and release candidates (including security critical updates for
BTCPay Server) and descriptions of notable changes to popular Bitcoin
infrastructure software.

## News

- **MAD-based offchain payment resolution (OPR) protocol:** John Law
  [posted][law opr] to Delving Bitcoin the description of a micropayment
  protocol that requires both participants to contribute funds to a bond
  that can be effectively destroyed at any time by either participant.
  This creates an incentive for both parties to appease the other or
  risk mutually assured destruction (MAD) of the bonded funds.

  This differs from the ideal of a _trustless protocol_ where only the
  party at fault loses funds in the case of a protocol breach.  However,
  in practice, deployed trustless protocols like LN often require the
  conforming party to pay onchain transaction fees to recover their
  funds from a breach.  Law uses this fact to argue for some of the
  benefits of a MAD-based protocol:

  - In the case of destruction of funds, it uses much less blockchain
    space than trustless contract enforcement, improving scalability.

  - Being based on counterparty appeasement rather than global
    consensus, the MAD-based protocol can enforce expiries as short as a
    fraction of a second rather than a minimum of at least several
    blocks.  Law gives the example of guaranteed payment resolution
    (success or failure) in less than ten seconds compared to LN
    currently needing up to two weeks in the worst case to settle a
    payment.

  - In the case of a prolonged communication failure between two
    counterparties, the MAD-based protocol doesn't require either party
    to put any data onchain (and both parties are incentivized not to do
    so, as they will lose their portion of the bond deposit).  In a
    protocol like [LN-Penalty][topic ln-penalty], pending [HTLCs][topic
    htlc] in a channel must be settled onchain by a deadline if
    communication breaks down.

    Law emphasizes that this can make OPR much more efficient inside a
    [channel factory][topic channel factories], [timeout tree][topic
    timeout trees], or other nested structure that would ideally keep
    the nested portions offchain.

  Matt Morehouse [replied][morehouse opr] that appeasement can logically
  lead to slow theft.  For example, Mallory claims Bob failed at an
  operation that's worth 5% of the bond; Bob isn't sure he failed, but
  paying Mallory 5% is better than losing his 50% of the bond, so he
  acquiesces; Mallory repeats.  This problem is made worse by the
  inability to prove fault in typical communication networks: if Mallory
  and Bob lose contact for long enough for a failure to occur, they may
  each blame the other, resulting in MAD.  Morehouse additionally notes
  that OPR requires reserving more user funds for the bond deposits,
  which may degrade UX---users today are already confused about the
  [BOLT2][] _channel reserve_ that prevents them from spending more than
  99% of channel balance.

  Discussion was ongoing at the time of writing.

- **Papers about IP-layer censorship of LN payments:** Charmaine Ndolo
  [posted][ndolo censor] to Delving Bitcoin summaries of [two][atv
  revelio] recent [papers][nt censor] about reducing the privacy of LN
  payments and potentially censoring them.  The papers note that
  metadata about TCP/IP packets containing LN protocol messages, such as
  the number of packets and the total amount of data, makes it
  relatively easy to guess what type of payload those messages contain
  (e.g. a new [HTLC][topic htlc]).  An attacker who controls a network
  used by several nodes may be able to observe the message hopping
  between nodes.  If the attacker also controls one of those LN nodes,
  it will learn some information about the message being transmitted
  (e.g.  payment amount or that it's an [onion message][topic onion
  messages]).  This can be used to selectively prevent some payments from
  succeeding, or even from failing quickly---preventing immediate
  retrying and potentially forcing channels to be closed onchain.

  No replies have been posted as of this writing.

## Releases and release candidates

_New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates._

- [BTCPay Server 2.0.3][] and [1.13.7][btcpay server 1.13.7] are
  maintenance releases that include security critical fixes for users of
  certain plugins and features.  Please see the linked release notes for
  details.

## Notable code and documentation changes

_Notable recent changes in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], [Lightning BOLTs][bolts repo],
[Lightning BLIPs][blips repo], [Bitcoin Inquisition][bitcoin inquisition
repo], and [BINANAs][binana repo]._

- [Bitcoin Core #30592][] removes the `mempoolfullrbf` setting option that
  allows users to disable [full RBF][topic rbf] and revert to opt-in RBF. Now
  that full RBF is widely adopted, there's no benefit to disabling it, so the
  option has been removed. Full RBF was recently enabled by default (see
  Newsletter [#315][news315 fullrbf]).

- [Bitcoin Core #30930][] adds a peer services column to the `netinfo` command
  and an `outonly` filter option to display only outgoing connections. The new
  peer services column lists the services supported by each peer, including full
  blockchain data (n), [bloom filters][topic transaction bloom filtering] (b),
  [segwit][topic segwit] (w), [compact filters][topic compact block filters]
  (c), limited blockchain data up to the last 288 blocks (l), [version 2 p2p
  transport protocol][topic v2 p2p transport] (2). Some help text updates are
  also made.

- [LDK #3283][] implements [BIP353][] by adding support for payments to DNS-based
  human-readable Bitcoin payment instructions that resolve to [BOLT12][]
  [offers][topic offers] as specified in [BLIP32][]. A new
  `pay_for_offer_from_human_readable_name` method is added to `ChannelManager` to
  allow users to initiate payments directly to HRNs. The PR also introduces an
  `AwaitingOffer` payment state to handle pending resolutions, and a new
  `lightning-dns-resolver` crate to handle [BLIP32][] queries. See Newsletter
  [#324][news324 blip32] for previous work on this.

- [LND #7762][] updates several `lncli` RPC commands to respond with status
  messages instead of returning empty responses, to more clearly indicate that
  the command was successfully executed. The affected commands include `wallet
  releaseoutput`, `wallet accounts import-pubkey`, `wallet labeltx`,
  `sendcustom`, `connect`, `disconnect`, `stop`, `deletepayments`,
  `abandonchannel`, `restorechanbackup`, and `verifychanbackup`.

{% assign four_days_after_posting = page.date | date: "%s" | plus: 345600 | date: "%Y-%m-%d 15:30" %}
{% include snippets/recap-ad.md when=four_days_after_posting %}
{% include references.md %}
{% include linkers/issues.md v=2 issues="30592,30930,3283,7762" %}
[law opr]: https://delvingbitcoin.org/t/a-fast-scalable-protocol-for-resolving-lightning-payments/1233
[morehouse opr]: https://delvingbitcoin.org/t/a-fast-scalable-protocol-for-resolving-lightning-payments/1233/2
[ndolo censor]: https://delvingbitcoin.org/t/research-paper-on-ln-payment-censorship/1248
[atv revelio]: https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=10190502
[nt censor]: https://drops.dagstuhl.de/storage/00lipics/lipics-vol316-aft2024/LIPIcs.AFT.2024.12/LIPIcs.AFT.2024.12.pdf
[btcpay server 2.0.3]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.0.3
[btcpay server 1.13.7]: https://github.com/btcpayserver/btcpayserver/releases/tag/v1.13.7
[news315 fullrbf]: /en/newsletters/2024/08/09/#bitcoin-core-30493
[news324 blip32]: /en/newsletters/2024/10/11/#ldk-3179
