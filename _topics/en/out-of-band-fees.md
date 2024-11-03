---
title: Out-of-band fees

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
  - Fee Management
  - Security Problems

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
#primary_sources:
#    - title: Test
#    - title: Example
#      link: https://example.com

## Optional.  Each entry requires "title" and "url".  May also use "feature:
## true" to bold entry and "date"
optech_mentions:
  - title: "Discussion of HTLC mining incentives and out-of-band fees"
    url: /en/newsletters/2020/07/01/#discussion-of-htlc-mining-incentives

  - title: Discussion about submitting transactions directly to miners
    url: /en/newsletters/2021/11/03/#submitting-transactions-directly-to-miners

  - title: "Improvements to features for miners that accept out-of-band fees"
    url: /en/newsletters/2023/05/10/#bitcoin-core-pr-review-club

  - title: Discussion about the effect of out-of-band fees on proposed fee-dependent timelocks
    url: /en/newsletters/2024/01/03/#fee-dependent-timelocks

  - title: "Frequent use of exogenous fees may risk mining decentralization due to out-of-band fees"
    url: /en/newsletters/2024/01/10/#frequent-use-of-exogenous-fees-may-risk-mining-decentralization

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Fee sniping
    link: topic fee sniping

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters

excerpt: >
  **Out-of-band fees** are payments made directly to a specific miner
  (or group of miners) in exchange for confirming one or more
  transactions.  They can be contrasted with standard in-band fees that
  are paid using the fee implied by the difference in a transaction's
  input and output value.

---
For example, Alice broadcasts a transaction at a feerate that is low
relative to other transactions in typical miner mempools.  Alice wants
to increase its feerate but is unable to use either [RBF][topic rbf] or
[CPFP][topic cpfp] fee bumping.  Instead, she contacts a miner directly
and pays them to include the transaction in their candidate blocks,
which will eventually lead to confirmation (unless the miner gives up).
Alice's payment can be completely independent of her transaction; she
may even pay using a non-bitcoin form of currency.

Consistent use of out-of-band fees weakens Bitcoin's censorship
resistance.  Miners controlling a large amount of hash rate produce
blocks more consistently than smaller miners, meaning someone such as
Alice who wants a transaction confirmed quickly will put more effort
into paying large miners than paying small miners.  For example, if
Alice pays miners controlling 55% of hashrate to include her transaction
in their block candidates, there's a 99% chance that her transaction
will be confirmed within 6 blocks: `1 - (1 - 0.55)**6`

The advantage to Alice of paying small miners out of band is minuscule,
likely meaning they will not receive the same opportunity to earn fees
as large miners.  If large miners earn a significantly higher percentage of profit than
small miners for a long period of time, we would expect large miners to
control a majority of total network hash rate.  The fewer entities that
control a majority of hash rate, the fewer entities there are that need
to be compromised to censor which transactions get included in blocks.

{% include references.md %}
{% include linkers/issues.md issues="" %}
