{:.post-meta}
*by [Gustavo Flores Echaiz][], Product Manager at [Veriphi][]*

Fee optimization is possible through diverse techniques varying from Segregated
Witness, Transaction Batching, RBF (Replace By Fee) and Fee Estimation.
Calculating exact transaction fee savings from the last two techniques, RBF and
Fee Estimation is quite difficult, but segwit and Batching gains can be modelled
to hypothetical scenarios since their improvements are measurable.

In our report, we wanted to model what full adoption of Native segwit (P2WPKH or
P2WSH) and Transaction Batching would look like for the network compared to the
partial adoption that we currently see. We wanted to determine the transaction
fees that could be saved, how that has changed over time and how it impacts
block space and block weight.

Our modelling for transaction batching is based on David A. Harding’s [formula][harding batching formula]
for detecting whether a transaction spends coins it received in the same block.
If so, those transactions can hypothetically be batched and the transaction
weight reduced. After batching all potentially batchable transactions, we
combine the size of the hypothetical block and compare it to the real block
size. From there, we can calculate the bytes that were saved and the percentage
this saving represents. Finally, if we take the size of each block and remove
the size of the block header and the coinbase transaction (since it’s data that
pays no fees), we can divide the saved size by this new amount. The percentage
we get is an approximation of the fees paid if full adoption would’ve happened.
Our code for analysing the data and calculating the potential savings is
[here][veriphi batching repo].

For segwit, we analysed from block 481,825, which happened on the 24th of August
2017, the day of segwit activation, until the 637,090th block on the 30th of
June 2020. Our method goes through every input of every transaction and if the
input isn’t native segwit, it calculates the weight it would save if it were
native segwit, which can then indicate to us the amount of fees it could save.
Finally, we collect the block weight and block fee of each block in reality and
also collect the potential block weight and potential block fee of our model by
summing up the results of each transaction. You can find the repository of our
code used [here][veriphi segwit repo].

__Major takeaways__

Assuming a bitcoin price of $9250.00 (correct at the time of publication):

- From January 2012 to June 2020 (until the 637,090th block) 211,266.95 bitcoins
  were paid in fees to miners. This amounts to a total of around $1,954,219,287
  USD.
- Total savings during that period amounted to 57,817.69 bitcoins representing
  an amount of $534,813,632.5 USD. This represents a percentage of around 27.36%
  over the grand total of transaction fees paid.
- Over 21,131.97 bitcoins could have been saved by Bitcoin users if they would
  have all been using Transaction Batching. 190,134.98 bitcoins could have been
  paid in fees instead of the 211,941.32 bitcoins, which represents savings of
  9.97%. The 21,131.97 bitcoins saved represents a staggering amount of
  $195,470,722 USD.
- From August 24th 2017 to the 30th of June 2020, 36,685.72 bitcoins could have
  been saved by Bitcoin users if they would have all been using segwit Native
  (Bech32). Fees would have amounted to 59,848.61 bitcoins, down from 96,534.33
  bitcoins actually paid in fees, which is 38.00% in savings. The 36,685.72
  bitcoins saved represent $339,342,910 USD.
- The advantages brought through optimized fee management techniques such as
  segwit and Batching are most impressive and apparent during high transactional
  activity periods. A large percentage of the possible savings would have been
  achieved in only a few key months over the span of 8 years and 6 months
  analysed.

Read [our full report here][veriphi segwit batching full report] to understand
fee savings progression over time and blockspace savings.

{% include references.md %}
[Gustavo Flores Echaiz]: https://twitter.com/GustavoJ_Flores
[Veriphi]: https://veriphi.io/
[veriphi segwit batching full report]: https://veriphi.io/segwitbatchingcasestudy.pdf
[harding batching formula]: https://github.com/harding/ref-payment-batching
[veriphi batching repo]: https://github.com/Gfloresechaiz/ref-payment-batching
[veriphi segwit repo]: https://github.com/Gfloresechaiz/all_transactions_segwit
