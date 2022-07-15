---
title: Congestion control
uid: congestion_control
topic_page_or_best_reference: https://github.com/bitcoin/bips/blob/master/bip-0119.mediawiki#Congestion_Controlled_Transactions
excerpt: >
  Congestion control is a category of techniques that minimize the
  amount of data that needs to be placed onchain during periods of high
  block space demand (or low supply) with the expectation that omitted
  data will be published onchain later when demand or supply have
  returned to acceptable levels.

---
For example, an exchange wants to pay 50 of its users in a [payment
batch][topic payment batching].  Although the batch is efficient on a
per-receiver basis, it's still a fairly large transaction and will
require a large fee when feerates are high.  Instead, the exchange
constructs its batch as a transaction template and uses [CTV][topic
op_checktemplateverify] to pay the hash of that template.  Instead of 50
payment outputs, this congestion control transaction only has one
payment output, making it much cheaper to get confirmed.

The exchange gives a copy of the CTV template transaction to the 50
people withdrawing their funds as trustless proof that only they can
claim the funds.  Later, when feerates have decreased, one or more of
them broadcasts that transaction, it gets confirmed, and they receive
the funds to their wallets.

Overall, this uses more block space than simply paying the 50
withdrawers in a single-stage payment batch.  Depending on the structure
of the template transaction, it can reasonably end up using twice the
total block space.  <!-- e.g. with a radix of 2 -->

If congestion control were to become widely used, it could help smooth
out variations in feerates.  This could help prevent [fee sniping][topic
fee sniping] in periods when transaction fees are substantial compared
to the block subsidy.

However, it's not clear that congestion control would be widely used.
Other options for cheaply receiving payments during high feerates
might be available (e.g. using LN).  Or, for receivers who have
short-term trust in the spender (e.g. as expected when using a
centralized exchange), it's simpler, cheaper overall, and more block
space efficient to just send a single-stage payment batch at the desired
low feerate with no congestion control, letting it naturally confirm
when global feerates drop to the level of that transaction.

{% include references.md %}
