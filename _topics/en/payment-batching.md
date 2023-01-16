---
title: Payment batching

## Optional.  Shorter name to use for reference style links e.g., "foo"
## will allow using the link [topic foo][].  Not case sensitive
# shortname: foo

## Optional.  An entry will be added to the topics index for each alias
aliases:
 - Batching

## Required.  At least one category to which this topic belongs.  See
## schema for options
categories:
  - Fee Management

## Required.  Use Markdown formatting.  Only one paragraph.  No links allowed.
## Should be less than 500 characters
excerpt: >
  **Payment batching** is the technique of including multiple payments in
  the same onchain transaction.  This splits the cost of creating a
  transaction, spending inputs, and creating a change output across all
  the payments in the transaction, reducing the average cost per payment.

## Optional.  Produces a Markdown link with either "[title][]" or
## "[title](link)"
primary_sources:
    - title: Scaling Bitcoin using Payment Batching
      link: scaling payment batching

## Optional.  Each entry requires "title", "url", and "date".  May also use "feature:
## true" to bold entry
optech_mentions:
  - title: "2018 year-in-review: about 11% of payments used batching"
    url: /en/newsletters/2018/12/28/#batched-payments

  - title: "Presentation: A Return to Fees, covering techniques including batching"
    url: /en/newsletters/2019/05/29/#presentation-a-return-to-fees

  - title: "Proposed new opcode to make batching more efficient during fee spikes"
    url: /en/newsletters/2019/05/29/#proposed-transaction-output-commitments

  - title: "Non-equal value coinjoins could look like batching for improved privacy"
    url: /en/newsletters/2020/01/08/#coinjoins-without-equal-value-inputs-or-outputs

  - title: "OP_CHECKTEMPLATEVERIFY discussion about compressed payment batching"
    url: /en/newsletters/2020/02/12/#op-checktemplateverify-ctv-workshop

  - title: Withdrawal transactions from Coinbase now use payment batching
    url: /en/newsletters/2020/03/18/#coinbase-withdrawal-transactions-now-using-batching

  - title: Specter Desktop adds payment batching support
    url: /en/newsletters/2020/08/19/#specter-desktop-adds-batching

  - title: "C-Lightning #3812 adds batching support to its onchain wallet"
    url: /en/newsletters/2020/09/16/#c-lightning-3812

  - title: "C-Lightning #3763 adds new RPC to batch open channels"
    url: /en/newsletters/2020/09/16/#c-lightning-3763

  - title: "Bitcoin Core #16378 adds a new RPC to the wallet with batching support"
    url: /en/newsletters/2020/09/23/#bitcoin-core-16378

  - title: Sparrow wallet adds support for payment batching
    url: /en/newsletters/2020/11/18/#sparrow-wallet-adds-payment-batching-and-payjoin

  - title: "BOLTs #803 adds recommendations for securely using batches to settle HTLCs"
    url: /en/newsletters/2020/12/16/#bolts-803

  - title: "Field Report: How batching could have saved millions of dollars in fees"
    url: /en/veriphi-segwit-batching/
    date: 2020-08-12

  - title: Candidate set based block templates may help fee bumping batched payments
    url: /en/newsletters/2021/06/02/#candidate-set-based-csb-block-template-construction

  - title: "Proposal for `OP_VAULT` opcode supports batching vault withdrawals"
    url: /en/newsletters/2023/01/18/#proposal-for-new-vault-specific-opcodes

## Optional.  Same format as "primary_sources" above
see_also:
  - title: OP_CHECKTEMPLATEVERIFY
    link: topic op_checktemplateverify
---
It's realistically possible to save 75% on transaction fees by
batching just a small number of payments and with no degradation in
confirmation speed or other changes required.  Even using exactly the
same inputs you'd use without batching, it's possible to save more
than 20%.

![Plot of savings from payment batching](/img/posts/payment-batching/p2wpkh-batching-cases-combined.png)

{% include references.md %}
