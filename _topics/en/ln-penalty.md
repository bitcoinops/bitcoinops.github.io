---
title: LN-Penalty

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Lightning Network
  - Contract Protocols

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Lightning Network
      link: https://lightning.network/lightning-network-paper.pdf

    - title: Deployable Lightning
      link: https://github.com/ElementsProject/lightning/blob/4c68f2eb1a8a574352066edf85e5c86bedcad62e/doc/deployable-lightning.pdf

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Discussion of LN-Penalty versus proposed LN-Symmetry (eltoo)"
    url: /en/newsletters/2019/09/11/#eltoo-sample-implementation-and-discussion

  - title: "Proposed new transaction relay policies designed for LN-penalty"
    url: /en/newsletters/2022/10/05/#proposed-new-transaction-relay-policies-designed-for-ln-penalty

  - title: Factory-optimized LN protocol compared to LN-Penalty
    url: /en/newsletters/2022/12/14/#factory-optimized-ln-protocol-proposal

  - title: "Proposal for fraud proofs for providing outdated backup states to make LN-Penalty safer"
    url: /en/newsletters/2023/08/23/#fraud-proofs-for-outdated-backup-state

  - title: "Using covenants to improve LN scalability (compatible with LN-Penalty)"
    url: /en/newsletters/2023/09/27/#using-covenants-to-improve-ln-scalability

  - title: "Superscalar: a timeout tree channel factory proposal with leaves using LN-Penalty"
    url: /en/newsletters/2024/11/01/#timeout-tree-channel-factories

## Optional.  Same format as "primary_sources" above
see_also:
  - title: "LN-Symmetry (eltoo)"
    link: topic eltoo

  - title: Duplex micropayment channels
    link: topic duplex micropayment channels

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **LN-Penalty** is a state protocol that penalizes a party who
  publishes a past state by allowing their funds to be seized by their
  counterparty.  The protocol is most widely used as the payment channel
  protocol (PCP) at the heart of the original (and still only fully
  developed) version of LN.  It is also used to manage state for
  repeated off-chain DLCs between two parties.

---
The concept for LN-Penalty was developed by Joseph Poon and Tadge Dryja
in the original [Lightning Network paper][pd ln], with refinements
focused on practical implementation [proposed][deployable lightning] by
Rusty Russell and others.  At the time of its development, it offered
several advantages over previously proposed PCPs:

- **Bidirectional:** the [BIP65][bip65 pcp] PCP provided the first
  trustless payment channel protocol construction for Bitcoin, but it
  only allowed payments to safely flow in the direction of the receiver.
  By comparison, LN-Penalty allows payments to flow in both directions.

- **Non-expiring:** the [Spillman][spillman pcp] PCP allows
  bidirectional payments but the channel must be closed by a deadline
  (and each change of direction reduces the time to the deadline).  By
  comparison, LN-Penalty allows payment channels to stay open
  indefinitely.

- **Unlimited state updates:** because each BIP65 state update must
  change channel balance by at least one satoshi and each change of
  direction in a Spillman channel reduces the time to until expiry,
  both only support a limited number of state updates.  By comparison,
  LN-Penalty theoretically supports an unlimited number of state
  updates.  In practice, the deployed version of LN-Penalty is currently
  limited to about 1.5 billion state updates <!--BOLT3: "sequence:
  upper 8 bits are 0x80, lower 24 bits are upper 24 bits of the obscured
  commitment number" --> as part of simplifying support for
  [watchtowers][topic watchtowers].

At the time LN-Penalty was proposed, it required relative locktimes
(added through [soft fork activation][topic soft fork activation] of
BIPs [68][bip68] and [112][bip112]) and a fix for txid malleability
(added through soft fork activation of BIPs [141][bip141] and
[143][bip143]).

Several limitations of LN-Penalty have been identified:

- **Toxic waste:** if any of a user's old states is broadcast, that
  user will lose all of their funds.  That can happen if the user's
  backups are compromised or if their software resets to an earlier
  state (e.g. due to a loss of newer state stored in volatile memory).
  This runs contrary to the general design in software to make backing
  up and restoring as easy as possible.  PCPs that don't create toxic
  waste include Spillman channels, CLTV channels, proposed [duplex
  payment channels][topic duplex micropayment channels], and proposed
  [LN-Symmetry][topic eltoo].

- **Two party only:** old states may allocate more funds to a party than
  they are entitled to in the latest state.  Penalizing the party who
  publishes an old state by allowing all of their funds from that old
  state to be seized effectively disincentivizes that behavior.  That
  mechanism only works well for two users where funds either belong to
  Alice or Bob.  For more users, say three users, Alice can publish an
  old state that assigns to her funds that the latest state assigns in
  part Bob and in part to Carol.  If Alice publishes that state, both
  Bob and Carol must be able to act unilaterally to recover their funds
  (otherwise it isn't a trustless protocol) but they each must not be
  able to seize the other's funds (again for trustlessness).  The
  inability to scale the protocol to multiple users in a single channel
  can be limiting in the context of [channel factories][topic channel
  factories], [DLCs][topic dlc], and other protocols.  PCPs that allow
  multiple parties include Spillman channels, duplex payment
  channels, LN-Symmetry, and multiple variants of the tunable
  penalty protocol.

- **Fully penalized:** the publication of an old state results in that
  party losing 100% of their balance in the channel.  There's no way to
  increase or decrease that penalty.  PCPs that allow adjustable
  penalties include variants of the tunable penalty protocol and a
  variant of LN-Symmetry called [Daric][]; it's likely the
  case that an adjustable penalty mechanism could be added to some
  of the other PCPs mentioned in this article.

As of this writing, LN-Penalty is the only fully developed PCP
compatible with LN.

{% include references.md %}
{% include linkers/issues.md issues="" %}
[pd ln]: https://lightning.network/lightning-network-paper.pdf
[deployable lightning]: https://github.com/ElementsProject/lightning/blob/4c68f2eb1a8a574352066edf85e5c86bedcad62e/doc/deployable-lightning.pdf
[bip65 pcp]: https://github.com/bitcoin/bips/blob/master/bip-0065.mediawiki#user-content-Payment_Channels
[spillman pcp]: https://en.bitcoin.it/wiki/Payment_channels#Spillman-style_payment_channels
[news244 tunable]: /en/newsletters/2023/03/29/#preventing-stranded-capital-with-multiparty-channels-and-channel-factories
[daric]: https://eprint.iacr.org/2022/1295
