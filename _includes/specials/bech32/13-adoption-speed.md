Bech32 addresses aren't the first time some Bitcoin users have changed
address formats.  In April 2012, P2SH addresses starting with a `3` were
introduced and eventually came to be used in about 25% of all
transaction outputs.  This week, we'll look at the relative speed of
adoption of the two different address formats.  For reasons we describe
later, this can't be an entirely fair comparison, but it may provide us
with a rough guide to how well we're doing so far with bech32 adoption.

We'll first look at the percentage of outputs per block sent to P2SH or
native segwit (bech32) addresses as measured from the day each proposal
became active on mainnet.  All plots in this section are averaged over
30 days using a simple moving average.  We also limit the data points on
P2SH plot to about two months before segwit activation so that almost no
P2SH-wrapped segwit outputs are miscounted as legacy P2SH.

![P2SH adoption speed versus native segwit.  Segwit line is aggregation of both P2WPKH and P2WSH](/img/posts/2019-06-p2sh-vs-segwit-aggregate.png)

One particularly unfair aspect of the above plot is that P2SH is really
only useful for advanced scripts (such as multisig).  There was no need
and no benefit for anyone using single-sig addresses (those starting
with a `1`) to upgrade to P2SH.  By comparison, there are native segwit
addresses for both single-sig users (P2WPKH) and advanced script users
(P2WSH).  To try to make that comparison more fair, the following plot
over a smaller date range separates the two uses of native segwit so you can compare bech32 P2WSH
use to its rough equivalent P2SH.

![P2SH adoption speed versus native segwit.  Separate lines for P2WPKH and P2WSH](/img/posts/2019-06-p2sh-vs-segwit-separate.png)

Notably, we see that almost all use of native segwit addresses to date
is for single-sig P2WPKH.  The P2SH activity prior to segwit activation,
which peaked at 25% of all outputs, has not migrated to native P2WSH
outputs.  Indeed, when we consider that all LN deposit transactions (and
at least some other onchain LN transaction) are using native P2WSH
outputs, it appears as if almost none of the late-2017 P2SH activity has
converted to P2WSH so far.

This points to another aspect that makes the different address data hard
to compare: all the things that were possible using legacy P2SH are also
possible using either P2SH-wrapped segwit addresses or native P2WSH
addresses.  P2SH-wrapped segwit addresses are backwards compatible and
can [significantly reduce transaction fees][bech32 fees] whereas bech32
addresses aren't backwards compatible with older wallets and only save a
small fixed amount of extra fees compared to P2SH-wrapped segwit.  This may give users
of advanced scripts less incentive than other users to switch from
P2SH-wrapped segwit address to native
segwit addresses in the short term.

Overall, the plot seems to show that it took about three years for P2SH
addresses to really start taking off, but that bech32 address were
already successful within just a few months of the segwit soft fork
activation.  With some wallets already defaulting to bech32 and several
more planning to do so in the coming months, we expect to see increased
adoption before the end of 2019.

[bech32 fees]: /en/newsletters/2019/04/16/#bech32-sending-support
