---
title: Anchor outputs

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - Simplified commitments

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Lightning Network

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Anchor outputs** are special outputs in LN commitment transactions
  that are designed to allow the transaction to be fee bumped.  An
  earlier name for the proposal was **simplified commitments.**

## Optional.  Use Markdown formatting.  Multiple paragraphs.  Links allowed.
extended_summary: |
  Each time the balance changes in an LN channel, a *commitment
  transaction* is created and signed by the participating parties.  The
  transaction is only broadcast if one party decides to
  unilaterally close the channel (e.g. because the other party has
  become unresponsive).  Because the broadcast of the commitment
  transaction may occur a long time after it was created, the commitment
  transaction may pay too much or too little in transaction fees.
  Paying a too-low feerate may prevent the commitment transaction from
  confirming before any timelocks contained within it expire, allowing
  funds to be stolen.

  The solution to this is for the commitment transaction to pay a
  minimal amount of fees and then to allow either channel participant to fee
  bump the transaction.  Early designs to accomplish this using [Replace-by-Fee
  (RBF)][topic rbf] fee bumping ran into problems with [transaction
  pinning][topic transaction pinning].  Later designs used
  [Child Pays For Parent (CPFP)][topic cpfp] fee bumping and came to
  depend on [CPFP carve-out][topic cpfp carve out] to circumvent the
  pinning problem.

  As of this writing, the most recent versions of the design add two
  outputs to the commitment transaction---one for each LN party---and
  require all other outputs in the commitment transaction to have their
  scripts encumbered by a `1 OP_CHECKSEQUENCEVERIFY` (CSV) condition
  that prevents them from being spent for at least one block.

  To be fully effective, the protocol also depends of Bitcoin full nodes
  implementing [package relay][topic package relay] so that there's a
  way to CPFP fee bump commitment transactions even if their feerates
  are below a node's minimum relay fee.  But until package relay is
  available, it's possible for LN nodes to just pay a somewhat higher
  feerate on their commitment transactions to ensure that they'll be
  accepted by nodes.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Anchor outputs
      link: https://github.com/lightningnetwork/lightning-rfc/pull/688

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Simplified fee bumping for LN
    url: /en/newsletters/2018/11/27/#simplified-fee-bumping-for-ln

  - title: LN simplified commitments discussion
    url: /en/newsletters/2019/10/30/#ln-simplified-commitments

  - title: Continued discussion of LN anchor outputs
    url: /en/newsletters/2019/11/06/#continued-discussion-of-ln-anchor-outputs

  - title: "2019 year-in-review: anchor outputs"
    url: /en/newsletters/2019/12/28/#anchor-outputs

  - title: "LND #3829 updates code & documentation to simplify adding anchor outputs"
    url: /en/newsletters/2020/01/15/#lnd-3829

  - title: "LND #3821 adds draft anchor commitments support"
    url: /en/newsletters/2020/03/18/#lnd-3821

  - title: "Using anchor outputs to ensure HTLC sends can be fee bumped"
    url: /en/newsletters/2020/04/29/#settlement-transaction-anchor-outputs

  - title: "LND 0.10 presentation: anchor outputs"
    url: /en/newsletters/2020/05/06/#lnd-v0-10

  - title: "Anchor outputs may help mitigate LN fee ransom attack"
    url: /en/newsletters/2020/06/24/#ln-fee-ransom-attack

  - title: "Eclair #1484 adds basic support for anchor outputs"
    url: /en/newsletters/2020/07/29/#eclair-1484

## Optional.  Same format as "primary_sources" above
see_also:
  - title: CPFP carve-out
    link: topic cpfp carve out

  - title: Package relay
    link: topic package relay
---
