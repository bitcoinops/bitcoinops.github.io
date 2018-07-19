---
title: 'Field Report: Consolidation of 4 Million UTXOs at Xapo'
permalink: /en/xapo-utxo-consolidation/
name: 2018-07-30-xapo-utxo-consolidation
type: posts
layout: post
lang: en
version: 1
---

{:.post-meta}
*by [Anthony Towns](https://twitter.com/ajtowns)<br>Developer on Bitcoin Core
at [Xapo][]*

As mentioned in [newsletter #3][newsletter 3], the past few months of low
transaction fees makes it a great time to do UTXO consolidation!
Consolidation has been one of a variety of activities [Xapo][Xapo] has been
undertaking to be prepared for the next time fees spike like they did in the
last few months of 2017.

{% assign img1_label = "Plot of total Bitcoin UXTOs, January - July 2018" %}

{:.center}
![{{img1_label}}](/img/posts/utxo-consolidation-2018.png)<br>
*{{img1_label}},
source: [Statoshi](https://statoshi.info/dashboard/db/unspent-transaction-output-set?panelId=6&fullscreen&from=1514759562608&to=1532039707168)*

[newsletter 3]: https://bitcoinops.org/en/newsletters/2018/07/10/#dashboard-items
[Xapo]: https://www.xapo.com/

The idea behind UTXO consolidation is essentially this: when your average
outgoing payment is larger than your average incoming payment (or when they’re
the same, but you’re batching outgoing payments), you’ll often have to combine
many UTXOs in order to fund an outgoing transaction, which increases the size
of your transactions and hence the fees you pay. By consolidating UTXOs in
advance, you can combine inputs ahead of time, giving you more
control over when most of those costs are incurred. If you can do it when
fees are low, that lets you reduce those costs pretty substantially.

For example, if you would have spent a dozen 2-of-3 multisig inputs at 100 s/B
(satoshis per byte), that would cost around 360,000 satoshis; while if you
consolidated those inputs beforehand at 2 s/B, and then spent the single
consolidated input later at 100 s/B, your total cost for the two transactions
is only about 41,000 satoshis: i.e. 87% less paid in fees. And if fees don’t
rise the risk isn’t huge: if fees just sat at 2 s/B, you’d be spending 7,900
satoshis across two transactions if you consolidated, rather than spending
7,200 satoshis in a single transaction if you did nothing.

Consolidation also gives an opportunity to update the addresses you use for
your UTXOs, for example to roll keys over, switch to multisig, or switch to
segwit or bech32 addresses. And reducing the number of UTXOs makes it easier to
run a full node too, marginally improving Bitcoin’s decentralisation and
overall security, which is always nice.

Of course, one thing you really don’t want to have happen is for your
consolidation transactions to somehow fill up the blockchain and cause fees to
immediately start rising! There are two metrics to watch to avoid this risk:
one is whether the [mempool][mempool] is full (which causes the minimum
acceptable fee to rise), and the other is how much empty space there has been
in recent blocks (which gives an indication of whether miners will accept more
transactions at the minimum fee). Both these metrics have been very promising
most of the time over the past few months: the mempool has regularly been close
to empty, meaning the transactions paying as little as 1 s/B have been
propagated to miners; and many blocks have not been full, meaning cheap
consolidation transactions will get mined reasonably quickly rather than
creating a backlog that will cause fees to rise.

[mempool]: https://statoshi.info/dashboard/db/memory-pool?panelId=1&fullscreen&from=1509458400000&to=1531813659334&theme=dark

The approach we took to actually doing the consolidation was to have a script
that would select groups of small UTXOs and create a consolidation transaction
spending them to a single pool address at a fee rate of 1.01 satoshis per byte.
The script gradually feeds consolidation transactions into the network, so it
doesn’t cause too large a spike in the mempool, and perhaps more importantly so
we don’t risk having our transactions get dropped because they have low fees
and the mempool has filled up. We triggered this manually when we were
comfortable it wouldn't interfere with our operations, and when there didn’t seem
to be much load on the Bitcoin network in general.

All in all, this has worked out pretty well; we’ve reduced our UTXO count by
something like [4 million UTXOs][4 million UTXOs] this year, and aside from
some [concerned][redditors1] [redditors][redditors2], the cost to the network
as a whole has been minimal, as has the cost to us.

[4 million UTXOs]: https://www.oxt.me/entity/Xapo
[redditors1]: https://www.reddit.com/r/BitcoinDiscussion/comments/8ocyc9/massive_consolidation_currently_underway/
[redditors2]: https://www.reddit.com/r/Bitcoin/comments/8p3y5b/does_xapo_spamming_the_blockchain/

## Additional resources

- [Techniques to reduce transaction fees: consolidation](https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#Consolidation) - Bitcoin Wiki
- [How to cheaply consolidate coins to reduce miner fees](https://en.bitcoin.it/wiki/How_to_cheaply_consolidate_coins_to_reduce_miner_fees) - Bitcoin Wiki
- [What are some best practices regarding the usage of consolidations and fanouts?](https://bitgo.freshdesk.com/support/solutions/articles/27000044185-what-are-some-best-practices-regarding-the-usage-of-consolidations-and-fanouts-) - BitGo
