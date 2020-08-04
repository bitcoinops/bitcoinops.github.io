{:.post-meta}
*by [Gustavo Flores Echaiz][], Product Manager at [Veriphi][]*

Fee optimization is possible through diverse techniques varying from segregated
witness, transaction batching, RBF (Replace By Fee) and fee estimation.
Calculating exact transaction fee savings from the last two techniques, RBF and
fee estimation, is quite difficult---but segwit and batching gains can be modelled
to hypothetical scenarios since their improvements are measurable.

In our report, we wanted to model what full adoption of native segwit (P2WPKH or
P2WSH) and transaction batching would look like for the network compared to the
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
the size of the block header and the miner's coinbase transaction, we
can divide the saved size by this new amount. The percentage
we get is an approximation of the fees that would've been paid in the case of full adoption.
Our code for analysing the data and calculating the potential savings is
[here][veriphi batching repo].

For segwit, we analysed from block 481,825, which happened on the 24th of August
2017, the day of segwit activation, until block 637,090 on the 30th of
June 2020. Our method goes through every input of every transaction and if the
input isn’t native segwit, it calculates the weight it would save if it were
native segwit, which can then indicate to us the amount of fees it could save.
Finally, we collect the block weight and block fee of each block in reality and
also collect the potential block weight and potential block fee of our model by
summing up the results of each transaction. You can find the repository of our
code used [here][veriphi segwit repo].

__Major takeaways__

Assuming a bitcoin price of $9,250 (correct at the time the report was published):

- From January 2012 to June 2020 (until block 637,090) 211 thousand BTC
  were paid in fees to miners. This amounts to a total of around $2 billion
  USD.
- Total savings during that period amounted to almost 58 thousand BTC representing
  an amount of about $530 million USD. This represents a percentage of around 27.36%
  over the grand total of transaction fees paid.
- Over 21 thousand BTC could have been saved by Bitcoin users if they
  would have all been using transaction batching, a savings of 10% or
  almost $200 million USD.
- From 24 August 2017 to 30 June 2020, about 37 thousand BTC could have
  been saved by Bitcoin users if they would have all been using segwit native
  (bech32), down from over 97 thousand BTC
  actually paid in fees, which is 38% in savings or about $340 million USD.
- The advantages brought through optimized fee management techniques such as
  segwit and batching are most impressive and apparent during high transactional
  activity periods. A large percentage of the possible savings would have been
  achieved in only a few key months over the span of 8 years and 6 months
  analysed.

Read [our full report here][veriphi segwit batching full report] to understand
the progression of fee savings over time.

{% include references.md %}
[Gustavo Flores Echaiz]: https://twitter.com/GustavoJ_Flores
[Veriphi]: https://veriphi.io/
[veriphi segwit batching full report]: https://veriphi.io/segwitbatchingcasestudy.pdf
[harding batching formula]: https://github.com/harding/ref-payment-batching
[veriphi batching repo]: https://github.com/Gfloresechaiz/ref-payment-batching
[veriphi segwit repo]: https://github.com/Gfloresechaiz/all_transactions_segwit
