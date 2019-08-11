We've frequently mentioned the fee savings available to people spending
segwit inputs, but we've never before mentioned that you don't need to
take advantage of the savings.  If you want, you can pay the same fee
you would've paid without segwit in order to possibly have your
transaction confirm more quickly (all other things being equal).  For some
users, such as traders attempting arbitrage across exchanges, saving
money may not be as important as faster confirmation
for the same amount of money.

To examine this idea, let's first generate a chart using Bitcoin Core's
fee estimates that illustrates the potential fee savings available to
creators of typical single-sig, one-input, two-output transactions:

![Estimated fee in USD, Y=fee, X=confirmation target](/img/posts/2019-08-rate-over-time.png)

We see that, in general, it takes longer for a transaction to confirm
the less you pay---but users of segwit can often pay less per
transaction for the same amount of waiting.  Now let's simply re-arrange
the axes for the same data:

![Estimated fee in USD, Y=confirmation target, X=fee](/img/posts/2019-08-time-over-rate.png)

For a given fee, it's expected that users of segwit will sometimes wait
less time for confirmation than legacy users, with native segwit users
gaining the greatest advantage.  In these estimates, the variation in
confirmation speed for different transaction types all paying the same
total fee can be more than 6 blocks (about an hour on average).

For users and organizations who have a fixed maximum price they're
willing to pay in fees per transaction, using segwit could significantly
reduce confirmation time for their transactions during periods of
high activity.  Although this advantage only benefits people spending
from bech32 and other segwit addresses, it's another reason to expect
people and organizations will increasingly request your software and
services pay bech32 addresses in the near future.
