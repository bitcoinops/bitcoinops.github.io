{% include references.md %}
{% capture operating-on-lightning %}Kotliar begins by explaining that high
transaction fees during previous years had a significant effect on Bitrefill's
business, so they made a special effort to get really good at minimizing
fee-related expenses.  The ability to receive LN payments supported that goal,
and he believes they were the first service on mainnet to sell real items for
LN payments.  Today, LN payments represent about 5% of their sales, similar to
the amount of business they do using Ethereum.

  He believes it's important for businesses to start working on LN now.  "In
  Bitcoin we've gotten used to waiting for things [...] but making customers wait
  an unknown amount of time creates a risk that the customer will go away."  For
  example, by the time a deposit clears at an exchange, the customer may no
  longer be interested in making the trade that would've earned the exchange a
  commission.  Additionally, Bitrefill's experience with LN is that LN's improved
  invoicing eliminates a number of different payment errors seen with onchain
  bitcoin payments, including overpayments, underpayments, stuck transactions,
  copy/paste errors, and other problems.  Receiving payments over LN also
  eliminates the need to consolidate UTXOs and reduces the need to rotate money
  between hot and cold wallets.  Eliminating all of these problems has the potential to significantly reduce customer support and backend expenses.

  In a particularly interesting section of his talk, Kotliar shows how perhaps as
  much as 70% of current onchain payments are users moving money
  from one exchange to another exchange (or even between different users of the
  same exchange).  If all that activity could be moved offchain using LN
  payments, exchanges and their users could save a considerable amount of money and everyone in Bitcoin would benefit from the increase in available block space.

  Kotliar concluded his talk with a few short segments.  He described what
  software and services Bitrefill sees LN users using today and what he
  expects them to be using in the near future.  He then explained two of
  Bitrefill's services for LN users (including businesses), [Thor][] and [Thor
  Turbo][].  Finally, he briefly described several planned improvements to LN:
  reusable addresses (see [Newsletter #30][newsletter #30 spon]), splicing in and out (see
  [#22][Newsletter #22 splice]), and larger channels (also [#22][Newsletter
  #22 wumbo]).

  Overall, Kotliar made a compelling case that LN's faster speed, lower fees,
  and improved invoicing means businesses that expect to remain competitive
  serving Bitcoin customers in the near future should start working on
  implementing LN support today.{% endcapture %}

[thor]: https://www.bitrefill.com/thor-lightning-network-channels/?hl=en
[thor turbo]: https://www.bitrefill.com/thor-turbo-channels/?hl=en
[newsletter #30 spon]: /en/newsletters/2019/01/22/#pr-opened-for-spontaneous-ln-payments
[newsletter #22 splice]: /en/newsletters/2018/11/20/#splicing
[newsletter #22 wumbo]: /en/newsletters/2018/11/20/#wumbo
