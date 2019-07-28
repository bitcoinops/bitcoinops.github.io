In percentage terms, the number of native segwit outputs---payments to
bech32 addresses---has slightly declined over the past year (~50,000
blocks).  The obvious explanation would be that people tried bech32
addresses, didn't like them, and went back to using legacy addresses or
P2SH-wrapped segwit addresses.  If that's the case, should we give up on
bech32 addresses?

![Percent of all transactions paying native segwit (bech32) outputs](/img/posts/2019-07-tx-types-bech32-percentage.png)

{:.center}
*Note: all charts in this section use a simple moving average over
10,000 blocks.*

Perhaps first we should investigate whether there's an alternative
explanation.  Percentages are synthetic results---information derived
from combining multiple other sources---so the first thing to look at is
the raw data.  The graph below shows the total number of outputs paid to
various types of scripts over the past two years:

![Total number of transactions paying P2PKH, P2SH, bech32, and nulldata](/img/posts/2019-07-tx-types-bech32-all-totals.png)

Contrary to the percentage data, we see the number of P2WPKH outputs
slowly (but steadily) increasing.  What we also see is that the number
of other outputs is also increasing.  This may become more clear if we
stack the totals:

![Total number of transactions paying P2PKH, P2SH, bech32, and nulldata
stacked on top of each other](/img/posts/2019-07-tx-types-bech32-all-totals-stacked.png)

Now we can see that the average number of outputs is slightly higher today
than it was at the previous peak of Bitcoin activity during late 2017 and early 2018.
That makes sense---the more transactions that use segwit, the more block
space there is available for other transactions.  However, despite the
overall increase, there are slightly fewer payment outputs (P2PKH, P2SH,
and native segwit).  The remaining outputs constitute a significant
increase in the number of `OP_RETURN` (nulldata) scripts.

This growth in the overall number of outputs and the number of nulldata
outputs explains why the percentage of bech32 outputs has been
declining despite the absolute number increasing.  It means that we
shouldn't give up on bech32.  Indeed, the recent spike in overall
outputs (and other recent data [available elsewhere][return to fees])
may be a sign of upcoming feerate increases that will encourage more
users and organizations to cut costs by switching to bech32.

[return to fees]: https://www.youtube.com/watch?v=ihUQ4C42KUk

