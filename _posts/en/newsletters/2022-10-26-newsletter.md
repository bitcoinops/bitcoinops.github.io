---
title: 'Bitcoin Optech Newsletter #223'
permalink: /en/newsletters/2022/10/26/
name: 2022-10-26-newsletter
slug: 2022-10-26-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes continued discussion about enabling
full RBF, provides overviews for several transcripts of discussions at a
CoreDev.tech meeting, and describes a proposal for ephemeral anchor
outputs designed for contract protocols like LN.  Also included are our
regular sections with summaries of popular questions and answers from
the Bitcoin Stack Exchange, a list of new software releases and release
candidates, and descriptions of notable changes to popular Bitcoin
infrastructure software.

## News

- **Continued discussion about full RBF:** in [last week's
  newsletter][news222 rbf], we summarized a discussion on the
  Bitcoin-Dev mailing list about the inclusion of a new `mempoolfullrbf`
  option that could create problems for several businesses which
  accept transactions with zero confirmations ("zero conf") as final
  payments.  Discussion continued this week on both the mailing list and
  the #bitcoin-core-dev IRC room.  Some highlights of the discussion
  include:

    - *Free option problem:* Sergej Kotliar [warned][kotliar free
      option] that he believes the greatest problem with any type of transaction
      replacement is that it creates a free American call option.  For
      example, customer Alice requests to buy widgets from merchant Bob.
      Bob gives Alice an invoice for 1 BTC at the current price of
      $20,000 USD/BTC.  Alice sends Bob the 1 BTC in a transaction with
      a low feerate.  The transaction remains unconfirmed when the
      exchange rate changes to $25,000 USD/BTC, meaning Alice is now
      paying $5,000 more.  At this point, she quite rationally chooses
      to replace her transaction with one paying the BTC back to
      herself, effectively canceling the transaction.  However, if instead the
      exchange rate had changed in Alice's favor (e.g. $15,000 USD/BTC), Bob
      can't cancel Alice's payment and so he has no way in the normal
      onchain Bitcoin transaction flow to exercise the same option,
      creating an asymmetric exchange rate risk.  By comparison, when
      transaction replacement isn't possible, Alice and Bob share the
      same exchange rate risk.

        Kotliar notes that the problem exists today with [BIP125][]
        opt-in [RBF][topic rbf] being available, but believes that
        full-RBF would make the problem worse.

        Greg Sanders and Jeremy Rubin [replied][sanders cpfp] in
        [separate][rubin cpfp] emails to note that merchant Bob could
        incentivize miners to confirm customer Alice's original
        transaction using [CPFP][topic cpfp], particularly if [package
        relay][topic package relay] was enabled.

        Antoine Riard [noted][riard free option] that the same risk
        exists with LN, as Alice could wait to pay merchant Bob's
        invoice up until shortly before it expired, giving her time to
        wait for the exchange rate to change.  Although in that case, if
        Bob noticed that the exchange rate had changed significantly, he
        could instruct his node not to accept the payment, returning the
        money to Alice.

    - *Bitcoin Core not in charge of network:* Gloria Zhao [wrote][zhao
      no control] in the IRC discussion, "I think whatever option we
      take, it should be made abundantly clear to users that Core does
      not control whether full RBF happens or not. We could revert
      [25353][bitcoin core #25353] and it could still happen. [...]"

        After the meeting, Zhao also posted a detailed [overview][zhao
        overview] of the situation.

    - *No removal means the problem could happen:* in the IRC discussion,
      Anthony Towns [echoed][towns uncoordinated] his points from last
      week, "if we're not going to remove the `mempoolfullrbf` option from
      24.0, we're going for an uncoordinated deployment."

        Greg Sanders was [doubtful][sanders doubt], "the question is:
        will 5%+ set a variable? I suspect not."  Towns [replied][towns
        uasf], "[UASF][topic soft fork activation] `uacomment`
        demonstrated it's easy to get ~11% to set a variable in just a
        couple of weeks".

    - *Should be an option:* Martin Zumsande [said][zumsande option] in
      the IRC discussion, "I think that if a meaningful number of node
      operators and miners want a specific policy, it shouldn't be on
      the devs to tell them 'you can't have that now'. Devs can and
      should give a recommendation (by picking the default), but
      providing options to informed users should never be a problem."

    As of this writing, no clear resolution had been reached.  The
    `mempoolfullrbf` option is still included in the release candidates
    for the upcoming version of Bitcoin Core 24.0 and it is Optech's
    recommendation that any service depending on zero conf transactions
    carefully evaluate the risks, perhaps starting by reading the emails
    linked in [last week's newsletter][news222 rbf].

- **CoreDev.tech transcripts:** prior to The Atlanta Bitcoin Conference
  (TabConf), about 40 developers participated in a CoreDev.tech event.
  [Transcripts][coredev xs] for about half of the meetings from the event
  have been provided by Bryan Bishop.  Notable discussions included:

    - [Transport encryption][p2p encryption]: a conversation about the
      recent update to the [version 2 encrypted transport
      protocol][topic v2 p2p transport] proposal (see
      [Newsletter #222][news222 bip324]).  This protocol would make it
      harder for network eavesdroppers to learn which IP address
      originated a transaction and improve the ability to detect and
      resist man-in-the-middle attacks between honest nodes.

        The discussion covers several of the protocol design
        considerations and is a recommended read for anyone wondering
        why the protocol authors made certain decisions.  It also
        examines the relationship to the earlier [countersign][topic
        countersign] authentication protocol.

    - [Fees][fee chat]: a wide-ranging discussion about transaction fees
      historically, presently, and in the future.  Some topics included
      queries about why blocks are seemingly almost always nearly full
      but the mempool isn't, debate about how long we have for a significant
      fee market to develop before we have to [worry][topic fee sniping]
      about Bitcoin's long-term stability, and what solutions we could
      deploy if we did believe a problem existed.

    - [FROST][]: a presentation about the FROST threshold signature
      scheme.  The transcript documents several excellent technical
      questions about the cryptographic choices in the design and may
      be useful reading for anyone interested in learning more
      about FROST specifically or cryptographic protocol design in
      general.  See also the TabConf transcript about [ROAST][], another
      threshold signature scheme for Bitcoin.

    - [GitHub][github chat]: a discussion about moving the Bitcoin Core
      project's git hosting from GitHub to another issue and PR
      management solution, as well as considering the benefits of
      continuing to use GitHub.

    - [Provable specifications in BIPs][hacspec chat]: part of a discussion
      about using the [hacspec][] specification language in BIPs to
      provide specifications that are provably correct.  See also the
      [transcript][hacspec preso] for a related talk during the TabConf.

    - [Package and v3 transaction relay][package relay chat]: the
      transcript of a presentation about proposals to enable [package
      transaction relay][topic package relay] and use new transaction
      relay rules to eliminate [pinning attacks][topic transaction
      pinning] in certain cases.

    - [Stratum v2][stratum v2 chat]: a discussion that started with the
      announcement of a new open-source project implementing the Stratum
      version 2 pooled mining protocol.  Improvements made available by
      Stratum v2 include authenticated connections and the ability for
      individual miners (those with local mining equipment) to choose
      which transactions to mine (rather than the pool choosing
      transactions).  In addition to many other benefits, it was
      mentioned in the discussion that allowing individual miners to
      choose their own block template might become highly desirable to
      pools that are worried about governments mandating which
      transactions can be mined, as in the [Tornado Cash][] controversy.
      Most of the discussion focused on the changes that would need to
      be made to Bitcoin Core to enable native support for Stratum v2.
      See also the TabConf transcript about [Braidpool][braidpool chat],
      a decentralized pooled mining protocol.

    - [Merging][merging chat] is a discussion about strategies to help
      get code reviewed in the Bitcoin Core project, although many
      suggestions also apply to other projects.  Ideas included:

        - Break big changes into several small PRs

        - Make it easy for reviewers to understand the ultimate
          objective.  For all PRs, this means writing a motivational PR
          description.  For changes that are being made incrementally,
          use tracking issues, project boards, and motivate
          refactorings by also opening the PRs that will use that
          refactored code to accomplish a desirable goal

        - Produce high-level explainers for long-running projects
          describing the state before the project, the current progress,
          what it will take to accomplish the outcome, and the benefits
          that will provide to users

        - Form working groups with those who are interested in the same
          projects or code subsystems

- **Ephemeral anchors:** Greg Sanders followed up previous discussion
  about v3 transaction relay (see [Newsletter #220][news220 ephemeral])
  with a [post][sanders ephemeral] to the Bitcoin-Dev mailing containing
  a proposal for a new type of [anchor output][topic anchor outputs].  A
  v3 transaction could pay zero fees but contain an output paying the
  script `OP_TRUE`, allowing anyone to spend it under the consensus
  rules in a child transaction.  The unconfirmed zero-fee parent transaction would
  only be relayed and mined by Bitcoin Core if it was part of a transaction package which also
  contained the child transaction spending the OP_TRUE output.  This
  would only affect Bitcoin Core's policy; no consensus rules would be
  changed.

    Described advantages of this proposal include that it eliminates the need
    to use one-block relative timelocks (called `1 OP_CSV` after the
    code used to enable them) to prevent [transaction pinning][topic
    transaction pinning] and allows anyone to fee bump the parent
    transaction (similar to an earlier [fee sponsorship][topic fee
    sponsorship] soft fork proposal).

    Jeremy Rubin [replied][rubin ephemeral] in support of the proposal
    but noted that it doesn't work for any contract that can't use v3
    transactions.  Several other developers also discussed the concept,
    all of them seeming to find it appealing as of this writing.

## Selected Q&A from Bitcoin Stack Exchange

*[Bitcoin Stack Exchange][bitcoin.se] is one of the first places Optech
contributors look for answers to their questions---or when we have a
few spare moments to help curious or confused users.  In
this monthly feature, we highlight some of the top-voted questions and
answers posted since our last update.*

{% comment %}<!-- https://bitcoin.stackexchange.com/search?tab=votes&q=created%3a1m..%20is%3aanswer -->{% endcomment %}
{% assign bse = "https://bitcoin.stackexchange.com/a/" %}

- [Why would someone use a 1-of-1 multisig?]({{bse}}115443)
  Vojtěch Strnad asks why someone would choose to use 1-of-1 multisig over
  P2WPKH given P2WPKH is cheaper and has a larger anonymity set. Murch lists a
  variety of resources showing at least one entity spending millions of 1-of-1
  UTXOs over the years, although the motivations remain unclear.

- [Why would a transaction have a locktime in the year 1987?]({{bse}}115549)
  1440000bytes points to a comment from Christian Decker referencing [a section][bolt 3 commitment]
  from the BOLT 3 Lightning spec that allocates the locktime field as "upper 8
  bits are 0x20, lower 24 bits are the lower 24 bits of the obscured commitment
  transaction number".

- [What is the size limit on the UTXO set, if any?]({{bse}}115439)
  Pieter Wuille answers that there is no consensus limit on the UTXO set size and that the
  rate of growth of the UTXO set is bounded by the block size which limits the
  number of UTXOs that can be created in a given block. In a [related answer][se
  murch utxo calcs], Murch estimates that it would take about 11 years to create
  a UTXO for every person on Earth.

- [Why is `-blockmaxweight` set to 3996000 by default?]({{bse}}115499)
  Vojtěch Strnad points out that the default setting for `-blockmaxweight` in
  Bitcoin Core is 3,996,000 which is less than the segwit limit of 4,000,000
  weight units (WU). Pieter Wuille explains that the difference allows
  buffer space for a miner to add a larger coinbase transaction with additional
  outputs beyond the default coinbase transaction created by the block template.

- [Can a miner open a Lightning channel with a coinbase output?]({{bse}}115588)
  Murch points out challenges with a miner creating a Lightning channel using an
  output from their coinbase transaction including delays in closing the channel
  given the coinbase maturation period as well as needing to continuously renegotiate the
  channel open while hashing due to the coinbase transaction's hash constantly
  changing during mining.

- [What is the history on how previous soft forks were tested prior to being considered for activation?]({{bse}}115434)
  Michael Folkson quotes a [recent mailing list post][aj soft fork testing] from Anthony Towns which
  describes the testing around the P2SH, CLTV, CSV, segwit, [taproot][topic
  taproot], CTV, and [Drivechain][topic sidechains] proposals.

## Releases and release candidates

*New releases and release candidates for popular Bitcoin infrastructure
projects.  Please consider upgrading to new releases or helping to test
release candidates.*

- [LDK 0.0.112][] is a release of this library for building LN-enabled
  applications.

- [Bitcoin Core 24.0 RC2][] is a release candidate for the
  next version of the network's most widely used full node
  implementation.  A [guide to testing][bcc testing] is available.

  **Warning:** this release candidate includes the `mempoolfullrbf`
  configuration option which several protocol and application developers
  believe could lead to problems for merchant services as described
  in the newsletters for this week and last week.  Optech encourages any
  services that might be affected to evaluate the RC and participate in
  the public discussion.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo], [Core
Lightning][core lightning repo], [Eclair][eclair repo], [LDK][ldk repo],
[LND][lnd repo], [libsecp256k1][libsecp256k1 repo], [Hardware Wallet
Interface (HWI)][hwi repo], [Rust Bitcoin][rust bitcoin repo], [BTCPay
Server][btcpay server repo], [BDK][bdk repo], [Bitcoin Improvement
Proposals (BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #23443][] adds a new P2P protocol message,
  `sendtxrcncl` (send transaction reconciliation), that allows a node to
  signal to a peer that it supports [erlay][topic erlay].  This PR adds
  just the first part of the erlay protocol---other parts are needed
  before it can be used.

- [Eclair #2463][] and [#2461][eclair #2461] update Eclair's
  implementation of the [interactive and dual funding protocols][topic
  dual funding] to require every funding input opt-in to [RBF][topic
  rbf] and also be confirmed (i.e. spend an output that's already in the
  block chain).  These changes ensure RBF can be used and that none of
  the fees contributed by an Eclair user will be used to help confirm any
  of their peer's previous transactions.

{% include references.md %}
{% include linkers/issues.md v=2 issues="23443,2463,2461,25353" %}
[bitcoin core 24.0 rc2]: https://bitcoincore.org/bin/bitcoin-core-24.0/
[ldk 0.0.112]: https://github.com/lightningdevkit/rust-lightning/releases/tag/v0.0.112
[bcc testing]: https://github.com/bitcoin-core/bitcoin-devwiki/wiki/24.0-Release-Candidate-Testing-Guide
[news222 rbf]: /en/newsletters/2022/10/19/#transaction-replacement-option
[kotliar free option]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021056.html
[sanders cpfp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021060.html
[rubin cpfp]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021059.html
[riard free option]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021067.html
[zhao no control]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-440
[towns uncoordinated]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-488
[sanders doubt]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-490
[towns uasf]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-492
[zumsande option]: https://www.erisian.com.au/bitcoin-core-dev/log-2022-10-20.html#l-493
[coredev xs]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/
[p2p encryption]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-10-p2p-encryption/
[news222 bip324]: /en/newsletters/2022/10/19/#bip324-update
[fee chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-fee-market/
[frost]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-frost/
[roast]: https://diyhpl.us/wiki/transcripts/tabconf/2022/roast/
[github chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-github/
[hacspec chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-hac-spec/
[hacspec]: https://hacspec.github.io/
[hacspec preso]: https://diyhpl.us/wiki/transcripts/tabconf/2022/hac-spec/
[package relay chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-package-relay/
[stratum v2 chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-11-stratum-v2/
[tornado cash]: https://www.coincenter.org/analysis-what-is-and-what-is-not-a-sanctionable-entity-in-the-tornado-cash-case/
[braidpool chat]: https://diyhpl.us/wiki/transcripts/tabconf/2022/braidpool/
[merging chat]: https://diyhpl.us/wiki/transcripts/bitcoin-core-dev-tech/2022-10-12-merging/
[news220 ephemeral]: /en/newsletters/2022/10/05/#ephemeral-dust
[sanders ephemeral]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021036.html
[rubin ephemeral]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/021041.html
[zhao overview]: https://github.com/glozow/bitcoin-notes/blob/full-rbf/full-rbf.md
[bolt 3 commitment]: https://github.com/lightning/bolts/blob/316882fcc5c8b4cf9d798dfc73049075aa89d3e9/03-transactions.md#commitment-transaction
[se murch utxo calcs]: https://bitcoin.stackexchange.com/questions/111234/how-many-useable-utxos-are-possible-with-btc-inside-them/115451#115451
[aj soft fork testing]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-October/020964.html
