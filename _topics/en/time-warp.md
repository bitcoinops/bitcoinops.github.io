---
title: Time warp

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
#aliases:
#  - Foo

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Mining
  - Security Problems

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: bip-cleanup, describing a solution to the time warp attack
      link: https://github.com/TheBlueMatt/bips/blob/cleanup-softfork/bip-XXXX.mediawiki

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: Consensus cleanup soft fork propsed to eliminate time warp attack
    url: /en/newsletters/2019/03/05/#fix-the-time-warp-attack

  - title: Background on time warp attack for consensus cleanup soft fork
    url: /en/newsletters/2019/03/05/#the-time-warp-attack

  - title: "Forward blocks proposal to use time warp to technically avoid hard forks"
    url: /en/newsletters/2018/10/09/#forward-blocks-on-chain-capacity-increases-without-a-hard-fork

  - title: Discussion from Scaling Bitcoin V conference about fixing the time warp bug
    url: /en/newsletters/2018/10/09/#fixing-the-time-warp-bug

  - title: Request for soft fork solutions to the time warp attack
    url: /en/newsletters/2018/08/28/#requests-for-soft-fork-solutions-to-the-time-warp-attack

## Optional.  Same format as "primary_sources" above
see_also:
  - title: Consensus cleanup
    link: topic consensus cleanup

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Time warp** is an attack that allows a majority of miners to produce
  up to one block per second indefinitely.  The attack could be used to
  steal the remaining block subsidy or to perform a DoS attack on nodes
  and clients.

---

Bitcoin blocks contain an nTime field in their headers.  We want this to
be the time the block was created by its miner, but there's no way to
directly enforce that.  At best, we can try to enforce that the nTime
field is set to a value after any events it commits to and before the
present time.  Two rules in the Bitcoin Protocol try to accomplish that:

1. The nTime of a block must be greater than the median nTime of the
   previous 11 blocks, called Median Time Past (MTP).

2. The nTime of a block in UTC must be less than two hours in the future
   according to the UTC clock on the computer of the local full node
   verifying the block.

The first rule works well when a majority of hash rate is reporting
accurate times---it prevents a malicious or broken miner from reporting a
time more than a few hours in the past under normal circumstances.
However, a majority of hash rate can refuse to increment time by more
than one second per block, producing new blocks whose times are
increasingly further and further into the past.

That shouldn't be a long-term problem.  If the first and last blocks in
a 2,016-block *retarget period* are closer together than 20,160 minutes
(i.e. an average of roughly ten minutes per block), <!-- roughly because
of off-by-one error --> the Bitcoin Protocol raises the Proof of Work
(PoW) difficulty and existing miners become less profitable, strongly
disincentivizing such dishonest time reporting.  Unfortunately, because
the protocol only looks at the difference between the first and last
blocks, rather than taking a true average of the difference between each
block and its parent, it's possible to manipulate the Difficulty
Adjustment Algorithm (DAA).  For example, consider the following times
for 2,016 blocks:

|                | Block 0 | Block 1 |  ... | Block 2014 | Block 2015 |
| Real time      | 0       | 600     |  ... | 1,208,400  | 1,209,000  |
| Reported nTime | 0       | 1       |  ... | 2014       | 1,209,000  |

Although the involved miners reported the minimum allowed change for
every block except the last block, the algorithm makes the same
difficulty change it would've had they reported accurate times (in this
case, there's no difficulty change).  If the miner continues this
behavior for another retarget period, they can actually lower
difficulty:

|                | Block 2016 | Block 2017 | ... | Block 4030 | Block 4031 |
| Real time      | 1209600    | 1210200    | ... | 2418000    | 2418600    |
| Reported nTime | 2016       | 2017       | ... | 4030       | 2418600    |

In the above example, miners reporting real times would have the
expected number of seconds elapse in the period, so difficulty would
again remain the same.  But the lying miners start their time earlier so
it looks like almost twice as much time passed in their retarget period.
That causes the DAA to almost halve their future difficulty.

If the amount of PoW the lying miners need to produce halves, we would
expect them to produce blocks roughly twice as fast.  So even with
constant hash rate, they finish the next retarget period in roughly a
week:

|                | Block 4032 | Block 4033 | ... | Block 6046 | Block 6047 |
| Real time      | 2418900    |  2419200   | ... | 3023100    | 3023400    |
| Reported nTime | 4031       | 4032       | ... | 6046       | 3023400    |

This causes difficulty to go down by another 60% and miner block
production is again accelerated so that, in another few days, they can
drop difficulty again.  The Bitcoin Protocol doesn't allow difficulty to
drop more than 75% in a single retarget period, but each drop causes
miners to produce blocks more and more quickly.  After just a few weeks
of performing this time warp attack, equilibrium is reached when
difficulty drops to its minimum value of `1` and miners are producing
blocks at the rate of one a second (they can't sustain production any
faster than that or they'll eventually create blocks more than two hours
in the future, which isn't allowed).

Producing one block a second will cause the last satoshi of the 21
million bitcoins allotted to subsidy to be mined in a bit over two
months.  It will also place an extraordinary burden on full nodes even
if all those blocks are essentially empty.  If the blocks are full,
it'll require archival nodes to store almost 350 GB of additional data
per day.  In short, a time warp attack would seriously threaten the
current operation of the network.

### Mitigations and solutions

As seen above, under a roughly constant amount of hash rate, it takes
two retarget periods (about four weeks) worth of nTime manipulation
by a majority of hash rate before the attack has any significant effect.
Unless there is large amount of hidden hash rate secretly mining an
alternative chain at great cost, the evidence of the attack will be
publicly visible for the entirety of those estimated four weeks.
Defeating the attack on an ad hoc basis can be as easy as a large group
of Bitcoin users agreeing that they won't accept nTimes lower than *x*
after block height *y*.

A permanent solution proposed for the [consensus cleanup soft
fork][topic consensus cleanup] is requiring the first block in a new
retarget period have a timestamp no earlier than 600 seconds before its
previous block (the last block in the previous period). This means
miners can only set an artificially-low timestamp for the first block in
a retarget period if they also set an artificially-low timestamp for the
last block in the previous period---but putting a low timestamp in the
previous period would’ve raised difficulty then by as much as they’ll be
able to lower it at the end of the current period, making any such
attempt worse than useless.

It's believed that the ease of detecting and stopping this attack has
prevented anyone from trying it on Bitcoin.  However, the attack has been
used against Bitcoin's [testnet][gmaxwell testnet] and against
[altcoins][verge time warp]; in all known cases, the attack was made
easier by those networks using different DAAs than Bitcoin.

### Alternative uses

[Forward blocks][news16 forward blocks] is a proposal to use the time
warp attack as part of a major change to the consensus rules.  It would
allow nodes that don't upgrade for the change to continue validating as
much transaction data as possible.  Although praised as innovative
thinking, it seemed most developers preferred to see the time warp
attack eliminated as a vulnerability rather than held in reserve for
future use.

{% include references.md %}
{% include linkers/issues.md issues="" %}
[news16 forward blocks]: /en/newsletters/2018/10/09/#forward-blocks-on-chain-capacity-increases-without-a-hard-fork
[gmaxwell testnet]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-August/016316.html
[verge time warp]: https://blog.theabacus.io/the-verge-hack-explained-7942f63a3017
