---
title: Fee sniping

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
aliases:
  - Anti fee sniping

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Mining
  - Security Problems
  - Security Enhancements

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: "Bitcoin Core #2340: discourage fee sniping with nLockTime"
      link: https://github.com/bitcoin/bitcoin/pull/2340

    - title: Anti-fee-sniping protection with nSequence in taproot transactions
      link: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-June/019048.html

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "LND #2063 updates sweeper to use nLockTime anti fee sniping"
    url: /en/newsletters/2018/10/23/#lnd-1978

  - title: "Suggestion to use anti fee sniping for interactive LN funding transactions"
    url: /en/newsletters/2020/02/05/#interactive-construction-of-ln-funding-transactions

  - title: "C-Lightning #3465 implements anti fee sniping for withdrawal transactions"
    url: /en/newsletters/2020/02/12/#c-lightning-3465

  - title: BIP proposed for wallets to set nSequence by default on taproot transactions
    url: /en/newsletters/2021/06/16/#bip-proposed-for-wallets-to-set-nsequence-by-default-on-taproot-transactions

  - title: "BIPs #1269 assigns BIP326 to a recommendation for default taproot anti fee sniping"
    url: /en/newsletters/2022/03/16/#bips-1269

  - title: "LDK #1531 begins using anti fee sniping for LN funding transactions"
    url: /en/newsletters/2022/06/29/#ldk-1531

  - title: "BDK #611 begins using anti fee sniping by default"
    url: /en/newsletters/2022/07/06/#bdk-611

  - title: Discussion about fee sniping in relationship to block subsidy
    url: /en/newsletters/2022/07/20/#fee-sniping

  - title: "CoreDev.tech transcript of discussion about fees and fee sniping"
    url: /en/newsletters/2022/10/26/#fees

## Optional.  Same format as "primary_sources" above
# see_also:
#   - title:
#     link:

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Fee sniping** occurs when a miner deliberately re-mines one or more
  previous blocks in order to take the fees from the miners who
  originally created those blocks.  Although re-mining a previous block
  is less likely to succeed than simply extending the chain with a new
  block, it can be more profitable if the previous block is worth much
  more in transaction fees than the transactions currently in the
  miner's mempool.

---
Fee sniping is a problem that may occur as Bitcoin's subsidy
continues to diminish and transaction fees begin to dominate
Bitcoin's block rewards.  If transaction fees are all that matter,
then a miner with `x` percent of the hash rate has a `x` percent
chance of mining the next block, so the expected value to them of
honestly mining is `x` percent of the [best feerate set of
transactions][csb] in their mempool.

Alternatively, a miner could dishonestly attempt to re-mine the
previous block plus a wholly new block to extend the
chain.  This behavior is referred to as fee sniping, and the dishonest
miner's chance of succeeding at it if every
other miner is honest is `(x/(1-x))^2`.  Even though fee sniping has an
overall lower probability of success than honest mining, attempting
dishonest mining could be the more profitable choice if transactions in
the previous block paid significantly higher feerates than the
transactions currently in the mempool---a small chance at a large amount
can be worth more than a large chance at a small amount.

The problem is actually worse than described above because every miner
who chooses to mine dishonestly reduces the number of honest
miners trying to extend the chain.  The smaller the share of hash
rate controlled by honest miners, the greater the probability that a
dishonest miner will be successful, so a single large miner
rationally choosing to mine dishonestly can set off a cascade of
ever smaller miners also rationally defecting to dishonest mining.
If that persists for an extended period of time, confirmation scores
cease to be a proxy for transaction finality and Bitcoin becomes
unusable until the problem is resolved.  We expect the most likely
resolution would be centralization of mining---a cartel representing
a majority of hash rate agreeing to never reorg each others' blocks
can restore stability to the system, but that comes with the
increased risk that they'll later
censor certain transactions.

### Mitigations

- **Block transaction limit:** without a limit on the number of
  transactions that can be contained within a block, such as a block
  size or block weight limit, dishonest miners could take all the
  transactions they know about now and try to put them into the oldest block
  they're working to re-mine.  All other blocks would be empty, with
  miners only creating them to bury their re-mined block under as much
  proof of work as possible.

    {:.center}
    ![Illustration of fee sniping without block limits](/img/posts/2021-06-sniping-size-limit.png)

    Limiting the number of transactions that can be contained within a
    Bitcoin block produces two desirable effects:

    1. It tends to prevent any new block at the tip of the chain from
       containing all pending transactions, leaving some transactions
       for the next block.  If the amount of transaction fee expected
       from honestly mining the next block is close to the amount of
       transaction fee available from dishonestly re-mining the previous
       block, all rational miners will behave honestly.

    2. It ensures that, even if dishonest miners do re-mine blocks, they
       won't be able to achieve maximum revenue by leaving the blocks
       near the tip empty---those blocks will need to contain fee-paying
       transactions.  Other dishonest miners may attempt themselves to
       fee snipe those transactions, reducing the revenue of the initial
       fee sniping miner and possibly discouraging them from fee sniping
       in the first place.

- **Rearrangement protection (anti fee sniping):** even with a block size
  limit, a dishonest miner doesn't need to use the exact same set of
  transactions included in the block that they're attempting to re-mine.
  They can replace any low feerate transactions in that block with
  higher feerate transactions from their mempool.  This has the benefit
  of burying higher feerate transactions further back in the chain where
  other dishonest miners will have to work harder to re-mine them a
  second time.

    {:.center}
    ![Illustration of honest mining compared to fee sniping](/img/posts/2021-06-afs.png)

     It's possible to limit this abuse by preventing miners from being
     able to include pending high-feerate transactions in the re-mined
     version of any previous block.  Miners would only be allowed to
     include pending transactions in blocks after the current chain tip.
     In other words, in an ideal situation, there wouldn't be any
     difference between the regular transactions in blocks created by
     economically rational dishonest miners and blocks created by honest
     miners.  This can reduce the revenue available to the dishonest
     miner and make them more vulnerable to fee sniping by other
     dishonest miners---again reducing the initial dishonest miner's
     expected rewards possibly enough to keep them mining honestly in
     the first place.

     This rearrangement protection is commonly called **anti fee
     sniping.** Originally [implemented][bitcoin core #2340] in Bitcoin
     Core, anti fee sniping is now also used by several other wallets.

    All wallets that implement anti fee sniping today use nLockTime
    height locks to prevent a transaction from being included in the
    re-mined version of a previous block.  It's also [possible][belcher
    post] to implement the same protection using [BIP68][] nSequence
    height locks, which could help make regular wallet transactions look
    like contract protocol transactions and vice versa.

We're unaware of any developers who think the above mechanisms are a
complete solution to the fee sniping problem, but every other mitigation
that has been proposed so far seems to have significant downsides.  None
of those alternatives appears to be an active area of research and
development.

<!-- other mitigations I'm aware of:

  - Permanent subsidy (yikes!)

  - Miner pays excess fees forward to next miner (AKA the reorg
    shakedown fee)

  - Transactions commit to current chaintip, making them (and their
    fees) invalid in case of reorg

-->

{% include references.md %}
{% include linkers/issues.md issues="2340" %}
[csb]: /en/newsletters/2021/06/02/#candidate-set-based-csb-block-template-construction
[belcher post]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-June/019048.html
[news18 lnd afs]: /en/newsletters/2018/10/23/#lnd-1978
[news84 cl afs]: /en/newsletters/2020/02/12/#c-lightning-3465
