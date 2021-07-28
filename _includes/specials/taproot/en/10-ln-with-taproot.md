*By [ZmnSCPxj][], LN protocol developer*

In this post, we'll look at two privacy features that [taproot][topic taproot] enables
for LN:

* [PTLCs][topic ptlc] over LN.
* P2TR Channels.

### PTLCs Over LN

PTLCs enable [many features][suredbits payment points], with a major
feature for LN being [payment decorrelation][p4tr ptlcs] without
any need to randomize routes.[^route-randomization] Every node along a
single-path or [multipath][topic multipath payments] route can be given a scalar that is used to
tweak each forwarded PTLC, enabling *payment decorrelation* where
individual forwards no longer [leak][news163 htlc problems] the unique identifier for each
LN payment.

PTLCs are ***not a privacy panacea***.  If a surveillant node sees a
forward with a particular timelock and value, and a second surveillant
node shortly after sees a forward with a *lower* timelock and *slightly
lower* value, then *very likely* those forwards belong to the same
payment path, even if the surveillant nodes can no longer correlate them
via a unique identifying hash.  However, we *do* get:

* Increased uncertainty in the analysis.  The probabilities a surveillant
  can work with are now lower and thus their information is that much
  less valuable.
* A *lot* more decorrelation in multipath payments.  Separate paths will
  not have strong timelock and value correlation with each other, and if
  LN succeeds, there should be enough payments that timing
  correlation is not reliable either.
* No increase in cost compared to an [HTLC][topic htlc] (and possibly even a slight
  cost reduction due to [multisignature efficiency][p4tr
  multisignatures]).

In principle, a pre-taproot channel can be upgraded to support PTLCs without
closing and reopening the channel.  Existing channels can host PTLCs by
creating an offchain transaction that spends the existing non-taproot
funding output to a taproot output containing a PTLC.  That means adding
support for PTLCs over LN does not require any cost to users
beyond each node and its channel peers upgrading their software.

However, to actually use PTLCs, *every* forwarding node from the spender
to the receiver must support PTLCs.  This means PTLC support may remain
largely unused until a sufficient number of nodes have upgraded.  They
don't all necessary need to use the same protocol (there could be
multiple PTLC protocols), but they all must support some PTLC protocol.
Having to support multiple PTLC protocols would be an added maintenance
burden and I *hope* we do not have too many such protocols (ideally just
one).

### P2TR Channels

One solution for improving the decorrelation between the base layer and
the LN layer has been [unpublished channels][topic unannounced channels]---channels whose
existence isn't gossiped on LN.

Unfortunately, every LN channel requires cooperation between two signers, and in the current
pre-taproot Bitcoin, every 2-of-2 script is *openly* coded.  LN is the
most popular user of 2-of-2 multisignature, so any block chain explorer
can show that this is a LN channel being closed.  The funds can then be traced
from there, and if they go to another P2WSH output, then that is likely
to be *another* unpublished channel.  Thus, even unpublished channels
are identifiable onchain once they are closed, with some level of false
positives.

Taproot, by using [schnorr signatures][topic schnorr signatures], allows for n-of-n to look exactly
the same as 1-of-1.  With some work, even [k-of-n][topic threshold signature] will also look the same
as 1-of-1 (and n-of-n).  We can then propose a feature where an LN
channel is backed by a P2TR UTXO, i.e. a
P2TR channel, which increases the *onchain* privacy of
unpublished channels.[^two-to-tango]

<!-- P2WSH 2-of-2: itemCount OP_0 <sig> <sig> <2 <key> <key> 2 OP_CMS>
             220 =   1 + 1 + 1+72 +1+72 +1+1+1+33+1+33+1+1

                  outpoint + nSequence + scriptSig + witness
             96 = 36 + 4 + 1 + 220/4
     P2TR: itemCount <sig>
             66 = 1 + 1 + 64

                    outpoint + nSequence + scriptSig + witness
             57.5 = 36 + 4 + 1 + 66/4

    Comparison:
      38.5 = 96 - 57.5
      ~40% = 1 - 57.5 / 96
-->

This (rather small) privacy boost also helps published channels as well.
Published channels are only gossiped for as long as they are open, so somebody
trying to look for published channels will not be able to learn about
*historical* channels.  If a surveillant wants to see every published
channel, it has to store all that data itself and cannot rely on any
kind of "archival" node.

In addition, taproot keypath spends are 38.5 vbytes (40%) smaller than
LN's existing P2WSH spends.  Unfortunately, you **cannot upgrade
an existing pre-taproot channel to a P2TR channel**.  The
existing channel uses the existing P2WSH 2-of-2 scheme and has to be
closed in order to switch to a P2TR channel.

In theory, the actual funding transaction outpoint is only a concern
of the two nodes that use the channel.  Other nodes on the network will
not care about what secures the channel between any two nodes.  However,
published channels are shared over the LN gossip network.  When a
node receives a gossiped published channel, it consults its own trusted
Bitcoin full node, checking if the funding outpoint exists, and more
importantly **has the correct address**.  Checking the address helps
ensure that it is difficult to spam the channel gossip mechanism; you
need actual funds on the blockchain in order to send channel gossip.
Thus, in practice, even P2TR channels require some amount
of remote compatibility; otherwise, senders will ignore these channels
for routing, as they cannot validate that those channels *exist*.

### Time Frames

I think the best way to create time frames for features on a distributed
FOSS project is to look at *previous* features and how long they took,
and use those as the basis for how long features will take to actually
deploy.[^planning-details]

The most recent new major feature that I believe is similar in scope to
PTLCs over LN is [dual-funding][topic dual funding].  Lisa Neigut created an initial
proposal for a dual-funding protocol in [BOLTs #524][], with the [first
dual-funded channel on mainnet][neigut first dual funded] being
[opened][first dual funded tx] almost 2 years and 6 months later.
Dual-funding only requires compatibility with your direct peers.  PTLCs
over LN require compatibilty with all routing nodes on your
selected paths, including the receiver, so I feel justified in giving
this feature a +50% time modifier due to the added complication, for an
estimate of 3 years and 9 months starting from when a specific PTLC
protocol is proposed.

For P2TR channels, we should note that while this is "only"
between two direct peers, it also has lower benefits.  Thus, I expect it
will be lower priority.  Assuming most developers prioritize
PTLC-over-LN, then I expect P2TR channels will start
getting worked on by the time the underlying [SIGHASH_ANYPREVOUT][topic sighash_anyprevout] or other
ways to implement Decker-Russell-Osuntokun ("[Eltoo][topic eltoo]") are available.

[^route-randomization]:
    A payer can choose a very twisty path (i.e. route randomization) to
    make HTLC correlation analysis wrong, but that has its own drawbacks:

    * Twisty paths are costlier *and* less reliable (more nodes
      have to be paid, and more nodes need to *successfully* forward
      in order for the payment to reach the destination).
    * Twisty paths are longer, meaning the payer is telling *more*
      nodes about the payment, making it *more* likely they will hit
      *some* surveillant node.
      Thus, twisty paths are not necessarily a perfect improvement
      in privacy.

[^planning-details]:
    Yes, details matter, but they also do not: from a high enough
    vantage point, the unexpected hardships of some aspect of
    development and the unexpected non-hardships of other aspects
    of development cancel out, and we are left with every major
    feature being roughly around some average time frame.
    If we want to make **accurate** estimates as opposed to
    **feel-good** estimates, we should use methods that avoid
    the [planning fallacy][WIKIPEDIAPLANNINGFALLACY].
    Thus, we should just look for a similar previous completed
    feature, and *deliberately ignore* its details, only looking
    at how long the feature took to implement.

[^two-to-tango]:
    When considering unpublished channels, remember that
    it takes two to tango, and if an unpublished channel is
    closed, then one participant (say, an LN service provider)
    uses the remaining funds for a *published* channel, a blockchain
    explorer can guess that the source of the funds has some
    probability of having been an unpublished channel that was
    closed.

{% include references.md %}
{% include linkers/issues.md issues="524" %}
[zmnscpxj]: https://zmnscpxj.github.io/about.html
[suredbits payment points]: https://suredbits.com/payment-points-monotone-access-structures/
[WIKIPEDIAPLANNINGFALLACY]: https://en.wikipedia.org/wiki/Planning_fallacy
[neigut first dual funded]: https://medium.com/blockstream/c-lightning-opens-first-dual-funded-mainnet-lightning-channel-ada6b32a527c
[first dual funded tx]: https://blockstream.info/tx/91538cbc4aca767cb77aa0690c2a6e710e095c8eb6d8f73d53a3a29682cb7581
[russell deployable ln]: https://github.com/ElementsProject/lightning/blob/master/doc/deployable-lightning.pdf
[p4tr ptlcs]: /en/newsletters/2021/08/25/#preparing-for-taproot-10-ptlcs
[p4tr multisignatures]: /en/newsletters/2021/08/04/#preparing-for-taproot-7-multisignatures
[news163 htlc problems]: /en/newsletters/2021/08/25/#privacy-problems-with-htlcs
