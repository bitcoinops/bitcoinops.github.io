---
title: Time warp

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#title-aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
topic-categories:
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
  - title: Requests for soft fork solutions to the time warp attack
    url: /en/newsletters/2018/08/28/#requests-for-soft-fork-solutions-to-the-time-warp-attack

  - title: "Forward blocks: on-chain capacity increases without a hard fork"
    url: /en/newsletters/2018/10/09/#forward-blocks-on-chain-capacity-increases-without-a-hard-fork

  - title: "Fixing the time warp bug: a discussion"
    url: /en/newsletters/2018/10/09/#fixing-the-time-warp-bug

  - title: "Consensus cleanup proposal: fix the time warp attack"
    url: /en/newsletters/2019/03/05/#the-time-warp-attack

  - title: "Question: where exactly is the 'off-by-one' difficulty bug and how does it relate to time warp?"
    url: /en/newsletters/2024/04/24/#where-exactly-is-the-off-by-one-difficulty-bug

  - title: "Draft BIP for testnet4 includes fix for time warp attack"
    url: /en/newsletters/2024/06/07/#bip-and-experimental-implementation-of-testnet4

  - title: "Question: how many blocks per second can sustainably be created using a time warp attack?"
    url: /en/newsletters/2024/07/26/#how-many-blocks-per-second-can-sustainably-be-created-using-a-time-warp-attack

  - title: "New time warp vulnernability affecting testnet4 despite previous time warp fixes"
    url: /en/newsletters/2024/08/16/#new-time-warp-vulnerability-in-testnet4

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Consensus cleanup soft fork proposal
    link: topic consensus cleanup

## Optional.  Force the display (true) or non-display (false) of stub
## topic notice.  Default is to display if the page.content is below a
## threshold word count
#stub: false

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Time warp** is an exploit of Bitcoin's difficulty adjustment
  algorithm that allows miners controlling a large amount of hashrate to
  prevent difficulty from increasing even as the rate of block
  production increases.

---
Ignoring some technical details, Bitcoin's difficulty adjustment
algorithm (DAA) attempts to keep an average of ten minutes between
new blocks by adjusting the difficulty of the proof of work (PoW) that
blocks must demonstrate in order to be valid.  This depends on miners
including the (approximate) current time in the block headers they
create, so that the Bitcoin consensus protocol can calculate how much the
recent inter-block average differs from the ideal of ten minutes.

Consensus rules prevent a single miner, or small number of miners, from
claiming they created a block far in the past by requiring that
any time in a block header must be greater than the median time of the
previous 11 blocks, called the _median time past_ (MTP) rule.

However, miners controlling a majority of hashrate (or a sub-majority of
miners using an attack that gives them influence over other miners, such
as _selfish mining_), can gain precise control over the header time of
each block.  For almost all blocks, they can set this to the minimum
increase of one second greater than the median.  But, for the last block
in a difficulty adjustment period, they can set it to the current time.
Using small numbers for illustrative purposes below, we can see a series
of header times suddenly advance far in the apparent future and then
return to the past, giving the attack its _time warp_ name:

    [0, 1, 2, 1795594, 3, 4, 5, ...]

Bitcoins DAA only adjusts difficulty once every 2016 blocks.  Miners who
begin a time warp attack cannot significantly affect difficulty for the
first 2016-block epoch because both the first and last blocks in that
epoch will need to have approximately accurate times.  For the second
epoch, miners can make it appear that the first block was mined two
weeks in the past and the last block was mined at present, giving an
average of about 20 minutes per block and causing the DAA to halve the
difficulty.  Miners will then by able to complete the next epoch twice
as fast and yet make it seem like it took about 25 minutes per block,
lowering difficulty further.  They can repeat the attack indefinitely
until they're producing one block per second, the lower bound allowed by
the MTP rule.

## Consequences

The original reason to fear the attack was that miners could use it to
quickly claim all remaining block subsidy.  The attack takes about a
month of publicly visible preparation before it really gets going, at
which point it would only take miners about another month to claim all
remaining subsidy, which was valued at approximately $91 billion USD at
the time of this writing (April 2024).

Since the discovery of the attack, a significant amount of user funds
(but believed to be far less than $91 billion) is now stored in contract
protocols that use [timelocks][topic timelocks].  Since the activation of
[BIP113][], those contracts all depend on MTP rather than block header
time.  During a time warp attack, MTP increases significantly slower
than normally, so funds could be made inaccessible to their users for
much longer than they expected or could potentially lead to users losing
money (depending on the contract).

The time warp attack would also result in much faster creation of new
blocks than expected, making it easy to overwhelm the CPU or bandwidth
of many nodes.  With a reduced
number of nodes on the network, many other attacks would be easier,
including [eclipse attacks][topic eclipse attacks] and unwanted
consensus changes.  A high rate of block production (due to a low
difficulty of creating each block) could also prevent miners from
converging on a single best chain, forcing nodes to frequently
reorganize and making transaction confirmation completely unreliable.

## Proposed use as an upgrade mechanism

A 2018 proposal called [forward blocks][news16 forward blocks] proposed
changing the consensus rules to deliberately encourage miners to perform
a timewarp to produce blocks more quickly.  Those blocks would commit to
essential transaction data, such as amounts and previous transaction,
allowing non-upgraded full nodes to continue verifying consensus rules
such as the 21 million bitcoin limit.  Upgraded nodes would look for
other transaction data, such as signatures, in _extension blocks_ that
would not be seen by older nodes.  This could increase the maximum
number of confirmed transactions on the network using only a
backwards-compatible soft fork.

We're unaware of any continued research or development of this idea for
Bitcoin.

## Solutions

Because the setup for the attack is public, takes about a month, and
requires cooperation from miners controlling a large portion of total
network hashrate, there has been an apparent lack of urgency to fixing
the attack.

A [request for solutions][news10 solutions] was made in 2018 and an
elegant solution was proposed as part of the [consensus cleanup][topic
consensus cleanup] soft fork proposal: require the first block in a new
difficulty period have a time no earlier than ten minutes before the
last block in the previous period.  This means miners can only set an
artificially-low timestamp for the first block in a retarget period if
they also set an artificially-low timestamp for the last block in the
previous period---but putting a low timestamp in the previous period
would’ve raised difficulty then by as much as they’ll be able to lower
it at the end of the current period, making any such attempt worse than
useless.

{% include references.md %}
{% include linkers/issues.md issues="" %}
[news16 forward blocks]: /en/newsletters/2018/10/09/#forward-blocks-on-chain-capacity-increases-without-a-hard-fork
[news10 solutions]: /en/newsletters/2018/08/28/#requests-for-soft-fork-solutions-to-the-time-warp-attack
