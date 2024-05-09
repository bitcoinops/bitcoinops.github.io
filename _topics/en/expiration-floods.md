---
title: Expiration floods

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
title-aliases:
  - Forced expiration spam
  - Flood and loot

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Contract Protocols
  - Lightning Network
  - Security Problems
  - Security Enhancements

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "The Bitcoin Lightning Network: Scalable Off-Chain Instant Payments"
      link: https://lightning.network/lightning-network-paper.pdf

    - title: "Flood & Loot: A Systemic Attack On The Lightning Network"
      link: https://arxiv.org/abs/2006.08513

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: LN developer discussion about flood and loot attacks
    url: /en/newsletters/2020/08/05/#chicago-meetup-discussion

  - title: Concern about forced expiration spam in very large channel factories
    url: /en/newsletters/2023/09/27/#using-covenants-to-improve-ln-scalability

  - title: Mitigating expiration floods with fee-depedent timelocks
    url: /en/newsletters/2024/01/03/#fee-dependent-timelocks

## Optional.  Same format as "primary_sources" above
see_also:
  - title: HTLCs
    link: topic htlc

  - title: PTLCs
    link: topic ptlc

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Expiration floods** occur when many timelock-contingent payments
  need to be settled onchain within a limited period of time.  If not
  all of the settlement transactions can fit into blocks before
  timelocks begin expiring, then not all of the contingent payments will
  resolve as expected, likely resulting in some users losing money.

---
For example, Mallory runs a very popular LN node with many users.  Each
channel has the maximum-allowed number of incoming and outgoing pending
[HTLCs][topic htlc], making the cost to resolve each of those channels
onchain around 100,000 vbytes.  A full block can only fit about 10 of
those channels.  If the most critical [timelocks][topic timelocks] on
some of the HTLCs might expire in 10 blocks or less, Mallory can force
close more than 100 of those channels to eliminate the guarantee that
her honest counterparties will receive their money.

Although an expiration flood can be triggered deliberately by a
malicious counterparty, it can also happen accidentally either by
coincidence or by a situation that causes many users to attempt to close
their channels simultaneously, e.g. a bug in a software implementation.
In the accidental case, some honest users will get their money and other
honest users may not, even though they all followed the protocol
correctly.

Expiration floods were described in the original [Lightning Network
paper][] under the name **forced expiration spam**.  A later
[paper][flood and loot] called the attack **flood and loot**.  Concern
about expiration floods has heavily influenced the development of LN and
other offchain protocols.

Mitigations that don't require consensus changes include:

- **Minimizing onchain enforcement data:** designing protocols and
  setting limits so that timelock-contingent payments are small.  For
  example, many LN implementations default to accepting and creating
  much less than the protocol-allowed maximum number of pending HTLCs.
  (That also helps mitigate other attacks.)

- **Using long timelocks when possible:** in our example above, Mallory
  needs to close at least 100 channels with 10-block timelocks.  If the
  timelocks were 100 blocks, she'd need to close 1,000 channels
  simultaneously.  It would take more effort on her part to find that
  many victims and get their channels into an exploitable state.

- **Improving counterparty decentralization:** someone who is a
  counterparty to 100 users has more power to execute an expiration
  flood attack than someone who is only counterparty to 10 users.
  This suggests that a less centralized distribution of counterparties
  might be safer against deliberately triggered expiration floods.
  Of course, in privacy-protecting protocols, it may be impossible to
  prove that two counterparties are distinct entities and not colluding.

Proposed mitigations that require consensus changes include:

- **Dynamic bounded block sizes:** this would allow miners to create larger
  blocks during high periods of demand so that they can confirm more
  transactions during an expiration flood.  [Proposals][friedenbach
  dynamic] of this [nature][maxwell dynamic]
  usually require miners to pay a cost for creating higher blocks, such
  as destroying bitcoins or generating more proof of work.  The lost
  bitcoins and work are expected to be compensated for by the extra fee
  income they will receive from confirming urgent transactions.

- **Fee-dependent timelocks:** [this][fdt] would prevent a timelock from
  expiring when feerates were above a specified amount.  If too many
  timelock-contingent payments entered the mempool at once; the users
  would bid up their feerates in competition with each other to get
  their transactions confirmed before the regular timelocks expired.
  When feerates exceeded the fee-dependent timelock, expiration of those
  timelocks would be delayed, keeping those users safe until feerates
  reduced. As long as the user paid a feerate above their fee-dependent
  timelock amount, their transaction should confirm before the timelock
  expires, ensuring the user's desired transaction gets confirmed before
  the timelock expires.

{% include references.md %}
{% include linkers/issues.md issues="" %}
[lightning network paper]: https://lightning.network/lightning-network-paper.pdf
[flood and loot]: https://arxiv.org/abs/2006.08513
[friedenbach dynamic]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-May/008017.html
[maxwell dynamic]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2015-May/008038.html
[fdt]: /en/newsletters/2024/01/03/#fee-dependent-timelocks
