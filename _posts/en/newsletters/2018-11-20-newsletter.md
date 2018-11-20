---
title: "Bitcoin Optech Newsletter #22"
permalink: /en/newsletters/2018/11/20/
name: 2018-11-20-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's "wumbo-sized" newsletter provides a note about Bitcoin hash
rate related to forks on other coins, summarizes several accepted goals
for the Lightning Network protocol version 1.1 specification, and lists
several notable commits in popular Bitcoin infrastructure projects.

## Action items

- **Monitor feerates:** due to activity associated with Bitcoin Cash,
  which can use the same mining equipment used for Bitcoin, blocks on
  Bitcoin may appear less frequently than expected, raising feerates and
  causing other effects.  However, these conditions may suddenly
  reverse, providing a period of fast blocks and low fee rates.  See the
  News section below for more information and recommended actions
  for Bitcoin businesses.

## Feature News: Lightning Network protocol 1.1 goals

LN protocol developers [met in Adelaide][rusty wrapup] last weekend to
determine which changes to adopt for the forthcoming Lightning Protocol
Specification 1.1.  Thirty proposals were accepted at a
high-level---meaning full specifications for each proposal are not
necessarily defined or agreed upon yet---but the [basic outline][ln1.1 outline] of the
new features is available.  Some highlights from the meeting include:

- **Multi-path payments:** the current normal way to make a payment over
  LN is using a single path.  Alice pays Charlie through her channel to
  Bob and Bob's channel to Charlie.  This works well for small payments
  where each participant has enough capacity
  to support the payment.  But if we use this mechanism when Alice has
  10 open channels each containing a maximum of 10% of her total hot
  wallet balance, Alice can only spend at most 10% of her funds at a
  time.

    Multipath payments provide a solution to this problem: if Alice
    wants to send 15% of her funds, she can send 7.5% to Charlie through
    her channel with Bob and 7.5% through her channel with Dan (who also
    has a channel with Charlie).  Although the partial payments are
    routed through separate paths, they can each commit to the same
    hash Alice would've used to send a single-path payment.  If Charlie
    receives multiple payments within a reasonable time period that
    equal or exceed the expected amount, he can guarantee that he'll
    receive all of them by simply revealing the single preimage used by
    all of the hashes.  This reuses the same proven security mechanism
    currently used for single-path payments and so doesn't introduce any
    new security assumptions.  The same mechanism also works if some
    other party along the path with sufficient channel capacity
    merges together the partial payments and forwards a single
    payment along the remainder of the path to Charlie.

    For more information, see the following Lightning-Dev threads which
    often call this feature Atomic Multi-path Payments (AMP): [an early
    proposal with separate hashes/preimages][roasbeef amp], [something
    like the currently favored proposal][zmn base amp], [a possibly too
    optimistic proposal][pickhardt local amp].

- **Dual-funded channels:** a nice feature of the current implementation
  is that only one party to the channel needs to initially commit any
  funds to it.  For example, Alice opens a channel to Bob with 0.1 BTC
  of her money and none of Bob's money.  This makes it very easy for
  users to accept new incoming channels, but it also means that channels can only be
  used in one direction initially---Alice can pay Bob or route payments
  through Bob, but Alice can't receive payments from Bob or from any
  routing path including Bob until Alice has sent Bob some money.  This
  creates a bootstrapping problem: if Alice wants to receive payments
  via LN, she has to get people to open new channels to her node---which
  requires they pay onchain transaction fees and wait for onchain
  confirmations that can take hours.

    A proposed solution to this problem is to allow dual-funded
    channels.  Alice agrees to put 0.1 BTC into a channel with Bob if
    Bob agrees to open the channel with 0.1 BTC of his own funds.  This
    can cost Bob money---namely onchain transaction fees and the
    opportunity cost of having his funds committed for some time---but
    Bob also receives the opportunity to earn LN routing fees for any
    payments sent to Alice.

    The basic implementation of dual-funding is probably simple (LN
    nodes already handle bidirectional payments) but creating an
    incentive mechanism that can reward capital providers like Bob is
    still being discussed.  For more information, see the following
    threads: [1][neigut liquidity], [2][zmn liquidity], [3][zmn dual
    rbf].  Also see the section on *advertising node liquidity* in [Newsletter #21][].

- **Splicing:** you can't currently
  increase a channel's maximum balance or send some of the channel's funds onchain to
  another person without closing the whole channel and opening another between
  the same parties.  Closing one channel and opening another requires
  completely stopping all payments between the two parties until an
  appropriate number of onchain confirmations have been received for the
  close-and-reopen transaction.

    Splicing provides a solution where parties cooperatively create an
    onchain transaction that adds to or subtracts from the channel.
    When adding funds (splicing in), the funds previously in the channel
    can continue to be used offchain without interruption while the new
    funds are being confirmed.  When spending funds onchain (splicing
    out), the remaining funds can also continue to be used offchain
    without interruption while the onchain recipient sees no difference
    from a normal transaction.  This allows the wallet UI to make
    in-channel funds part of the total available balance for spending in
    onchain transactions so that users don't need to manually manage
    offchain and onchain balances separately.  Combined with multipath
    payments that allow funds from multiple channels to be intermixed in
    payments, this greatly simplifies spending: users will just click a
    link, review the invoice, and click *Pay*---letting the wallet
    automatically use any of its available balance for either an onchain
    payment or an offchain payment using any number of paths.

    For more information, see the following threads: [1][zmn splicing
    cut-through], [2][pickhardt bolt splicing], [3][russell splicing].
    Also see the news item about *channel splicing* in [Newsletter #17][].

- **Wumbo:** by agreement among early LN implementations, currently each
  channel's capacity is limited by default to about 0.168 BTC (about $40
  USD when defined; currently about $750).  This was [chosen][russell
  why limit] to help prevent users from putting too much money into
  unproven software.

    Several years later, LN has matured significantly and some
    participants want to signal that they're willing to open higher
    value channels.  The 1.1 spec proposal will allow such participants
    to set a bit named "wumbo" (jumbo) to indicate their willingness to
    accept larger channels and larger in-channel payments.

    For more information, see the following threads: [1][zmn describing
    wumbo], [2][zmn global wumbo].  For etymological reference, the name
    wumbo appears to come from a [segment][youtube wumbo] in the
    SpongeBob SquarePants cartoon where an "M" is interpreted as
    standing for Mini, is inverted into a "W", and redefined as standing
    for wumbo.

- **Hidden destinations:** LN payments currently route payments using an
  onion method similar to sending data to a Tor exit node.  Alice wants
  to ultimately pay Zed, so she finds a path to him through Bob,
  Charlene, and Dan.  To prevent the intermediaries from learning about
  anything but the two channels they route though (e.g. Charlene knows
  about Bob and Dan), Alice encrypts each step of the path so that only
  the next step in disclosed to each recipient.  When Zed ultimately
  receives the payment, he can simply return the success preimage to
  Dan, who returns it to Charlene, and so forth back to Alice.

    However, Tor also has a hidden service mode where both the
    sender and the recipient each choose part of the path so that
    neither of them can determine exactly where the packets came from or
    went---providing significantly improved privacy.  This proposal for
    LN mirrors that mode.  Alice will still choose Bob, Charlene, and
    Dan, but Zed can prevent Alice from learning about his routes by
    choosing Edmond, Fran, and George.  Zed provides information about
    how to find Edmond to Alice---but the information about Fran,
    George, and Zed's own node is encrypted so that Alice can't see it.
    This can allow hidden channels---a current feature of several LN
    implementations---to stay hidden even when routing payments from
    arbitrary spenders.

    This feature is also called rendez-vous routing.  For more
    information, see the [description][lnrfc rz] on the LN protocol
    documentation wiki.  See also the following mailing list threads:
    [1][cjp rz], [2][zmn rz], [3][zmn rz packetswitch].

Although discussed at the summit, the proposed 1.1 goals don't directly
address *watchtowers* that help protect channels for users that are
currently offline, *autopilots* that help users open their initial
payment channels, or *deterministic preimage generation* that allow
private keys to stay offline while an online component simply completes
acceptance of payments.  These are services that can be built on top of
the protocol and so don't currently require any coordination between
implementations.

## News

{% comment %}<!-- math for first sub-bullet:
exp(-45/9) # 45 minute block, 9 minute avg interval
exp(-45/12) # 45 minute block, 12 minute avg interval

The reason long interblock periods become more common at a faster rate
than average interblock times increase is because the variance for
independent events is the square of the average.

-->{% endcomment %}

- **Slowed block production, increased fees:** as widely reported,
  several miners and mining pools are producing blocks for competing
  forks of Bitcoin Cash when they could likely earn greater revenues by
  creating blocks for Bitcoin.  This is the likely cause of the
  approximately 7% reduction in Bitcoin difficulty over the retarget
  period ending Friday (UTC) and may mean additional decreases in
  Bitcoin hash rate and difficulty for an unknown length of time.
  Relevant consequences for Bitcoin businesses include:

    - *Slower confirmation times:* the average time between blocks may
      increase moderately to 11 or 12 minutes and the chance of there
      being a long wait between blocks will increase significantly in
      relative percentages (e.g. with historically typical 9 minute
      average block intervals, about 0.7% of blocks take more than 45
      minutes; with a 12 minute interval, 2.3% take more than 45
      minutes).  Recommendation: Bitcoin users are already familiar with
      occasional long delays, so likely no action is needed.

    - *Possibly increased fees:* a longer time between finding blocks
      means less space for transactions, which can cause fee increases.
      Occasional long waits between blocks also tend to create sudden
      fee spikes that can persist for hours afterwards.  Recommendation:
      ensure your fee estimation is working correctly and consider
      preparing any fee-reduction measures you're willing to use such as
      payment batching.

    - *Increased revenues for profit-maximizing miners:* miners not only
      profit from increased fees, but each time
      Bitcoin's difficulty adjusts downwards, mining becomes more
      profitable for Bitcoin miners (all other things being equal).
      Recommendation: do the math on reactivating slightly-old miners
      and overclocking current miners.  With the recent price drop, this
      might instead mean you don't need to turn off a miner that
      would've otherwise been unprofitable to operate.

    - *Possible sudden end:* it's possible a large set of ideological miners
      producing blocks for Bitcoin Cash will all return to mining for
      the most profitable chain at roughly the same time.  Combined
      with any past difficulty decreases, this could produce a series of
      Bitcoin blocks with shorter average time between blocks than
      normal.  This will likely wipe out any moderate backlog and allow
      fees to drop to their default minimums.  Recommendation: consider
      preparing to perform fee-reducing [input consolidations][] if fees
      drop to their minimums.

- **Lightning protocol discussion:** over 75 emails have been posted to
  the Lightning-Dev mailing list in the past week, representing almost
  10% of the list's traffic in the past 365 days.  Many of the threads
  continue conversations started at the protocol developers summit.  If
  you're interested in Lightning protocol development, we suggest
  reading each of this month's [threads][ln threads].

- **LND enters release cycle for version 0.5.1:** experienced users of
  the LND implementation may wish to test this pre-release to help find
  any last-minute problems before the final release of this maintenance
  update.

## Optech News

- **Second Optech workshop held in Paris:** as announced in [Newsletter #12][],
  we held our second workshop in Paris last week. There were 24 engineers from
  Bitcoin companies and open source projects in attendance, and we had great
  discussions about wallet descriptors, Partially Signed Bitcoin Transactions (PSBTs),
  Lightning integration, taproot, coin selection, and fee bumping.  Huge thanks
  to Ledger for hosting and helping with organization.

  If you work at a member company and have any requests or suggestions for
  future Optech events (such as location, venue, dates, format, topics,
  or anything else), please [contact us][optech email]. We're here to help our member
  companies!

## Notable code changes

*Notable code changes this week in [Bitcoin Core][core commits],
[LND][lnd commits], [C-lightning][cl commits], and [libsecp256k1][secp
commits].*

{% include linkers/github-log.md
  refname="core commits"
  repo="bitcoin/bitcoin"
  start="e70a19e7132dac91b7948fcbfac086f86fec3d88"
  end="35739976c1d9ad250ece573980c57e7e7976ae23"
%}
{% include linkers/github-log.md
  refname="lnd commits"
  repo="lightningnetwork/lnd"
  start="d4b042dc1946ece8b60d538ade8e912f035612fe"
  end="4da1c867c3209dab4e4a824b73d89fc38b616b37"
%}
{% include linkers/github-log.md
  refname="cl commits"
  repo="ElementsProject/lightning"
  start="62e6a9ff542e40364b67a7aa419e33ed72b96a42"
  end="d5aaa11373cc6759f9f894a1daf7fb88d0834bc9"
%}
{% include linkers/github-log.md
  refname="secp commits"
  repo="bitcoin-core/secp256k1"
  start="1086fda4c1975d0cad8d3cad96794a64ec12dca4"
  end="314a61d72474aa29ff4afba8472553ad91d88e9d"
%}

- [C-Lightning #2075][] adds support for plugins.  As their
  [documentation][cl plugin] describes, "plugins are a simple yet
  powerful way to extend the functionality provided by c-lightning.
  They are subprocesses that are started by the main `lightningd` daemon
  and can interact with `lightningd` in a variety of ways."  At present,
  plugins can add command-line options to the main process, but there
  are plans to allow them to add new JSON-RPC commands, receive events,
  and insert code to be called by hooks in the main process.  A
  `helloworld` plugin written in Python is provided with C-Lightning as
  an example.

- [Bitcoin Core #14411][] The [listtransactions][rpc listtransactions] RPC
  has its filter parameter partly restored, making it possible to
  retrieve a list of the transactions sent to addresses or scripts with
  a particular label.  This has been backported to the 0.17 branch as
  [PR #14441][Bitcoin Core #14441] and is expected to be distributed in
  the next maintenance release.

- [LND #2124][] adds another essential portion of watchtower support,
  specifically the ability to detect that an attacker has made an
  onchain attempt steal from one of the watchtower's users.  The
  watchtower can use the information from the onchain transaction to
  decrypt a breach remedy transaction previously provided by the victim
  in order to both negate the attack and penalize the attacker by
  claiming any funds the attacker legitimately owned in the channel.  In
  the current implementation, the watchtower receives a percentage of
  the recovered funds to compensate it for its diligent monitoring.
  This merge is an extension of PRs [#1535][LND #1535] and [#1512][LND
  #1512] described in [Newsletter #19][] and is a major step towards
  making LN safer for everyday users.

## Special thanks

We thank Christian Decker, practicalswift, and René Pickhardt for providing
suggestions or answering questions related to the content of this
newsletter.  Any remaining errors are entirely the fault of the
newsletter's author.

{% include references.md %}
{% include linkers/issues.md issues="2075,14411,2124,1535,1512,14441" %}

[ln threads]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/thread.html
[roasbeef amp]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-February/000993.html
[zmn base amp]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001577.html
[pickhardt local amp]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001626.html
[neigut liquidity]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001532.html
[zmn liquidity]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001555.html
[zmn dual rbf]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001631.html
[zmn splicing cut-through]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-April/001153.html
[pickhardt bolt splicing]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-June/001322.html
[russell splicing]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-October/001434.html
[russell why limit]: https://medium.com/@rusty_lightning/bitcoin-lightning-faq-why-the-0-042-bitcoin-limit-2eb48b703f3
[youtube wumbo]: https://www.youtube.com/watch?v=--hsVknT1c0
[zmn describing wumbo]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001596.html
[zmn global wumbo]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001576.html
[cjp rz]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001498.html
[zmn rz]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001547.html
[zmn rz packetswitch]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001553.html
[cl plugin]: https://github.com/ElementsProject/lightning/blob/master/doc/plugins.md
[rusty wrapup]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2018-November/001569.html
[ln1.1 outline]: https://github.com/lightningnetwork/lightning-rfc/wiki/Lightning-Specification-1.1-Proposal-States
[input consolidations]: https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation
[lnrfc rz]: https://github.com/lightningnetwork/lightning-rfc/wiki/Rendez-vous-mechanism-on-top-of-Sphinx
