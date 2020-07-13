---
title: 'RBF in the Wild'
permalink: /en/rbf-in-the-wild/
name: 2019-02-11-rbf-in-the-wild
slug: 2019-02-11-rbf-in-the-wild
type: posts
layout: post
lang: en
version: 1

excerpt: >
  A study of usability concerns among wallets and block explorers that
  support opt-in RBF (BIP125).

---
Opt-in Replace by Fee (RBF) was standardized in December 2015. But who is
supporting it and what is the user experience like? This post presents a study of
[BIP125][] opt-in RBF as seen by users of popular Bitcoin wallets and block explorers. The
findings were initially presented during the most recent [Bitcoin Optech
Workshop in Paris](/workshops/).

Understanding how other wallets, exchanges, and block explorers handle opt-in
RBF transactions is an important consideration for Bitcoin services. In order
for exchanges or wallets to support RBF, they want to know that there is broad
support for RBF and that user experience in receiving wallets or block
explorers is not confusing.

The goal of this study is to evaluate how opt-in RBF is supported in the wallet
and explorer ecosystem. While the study is meant to be more descriptive than
prescriptive, we do have some general recommendations. When evaluating
usability, each service should consider the experience and knowledge of its
user base. Hopefully, the compilation of this information in one location will
help Bitcoin companies make informed decisions about how to support RBF and
even start some discussions about which techniques work and which do not.

Transaction replacement is important as it can enable:

- Wallets and users to have finer control over transaction fees since an
  initially low fee can later be bumped
- 'Unsticking' a stuck transaction that doesn't have enough fee to be mined

As well as those basic use cases, RBF can be used in more advanced scenarios
such as:

- Combining two or more payments into a single transaction (Iterative Payment
  Batching)
- Pre-computed fee bumping
- Closing long-lasting payment channels where the fees cannot be predicted
  ahead of time.[^closing_lightning_channels]

## Background

[Full transaction
replacement](https://en.bitcoin.it/wiki/Replace_by_fee#Full_RBF) was available
from Bitcoin’s original 0.1.0 release until 0.3.12, but there were a few
potential downsides. Namely, the unrestricted ability to replace transactions
meant there was no rate limiting mechanism to prevent DoS/spam replacements.
There was also no incentive for a miner to replace the transaction, especially
if the original transaction had the same or higher feerate.

Satoshi [disabled transaction
replacement](https://github.com/bitcoin/bitcoin/commit/05454818dc7ed92f577a1a1ef6798049f17a52e7#diff-118fcbaaba162ba17933c7893247df3aR522)
in 0.3.12, leaving the comment _“// Disable replacement feature for now”_. From
0.3.12 to 0.11.x Bitcoin Core had no default transaction replacement
capabilities.

That changed when an implementation of Peter Todd’s [BIP125 “Opt-in Full
Replace-by-Fee
Signaling”][BIP125] was
merged into Bitcoin Core 0.12.0. BIP125 solves both the spam prevention and
incentive issues mentioned above by requiring higher transaction fees for
replacement transactions.

![rbf-transactions-in-2018](/img/posts/rbf-in-the-wild/rbf-transactions-in-2018.png)
*~6% of transactions signaled opt-in RBF in 2018. Source: [Bitcoin Optech
Dashboard](https://dashboard.bitcoinops.org/d/ZsCio4Dmz/rbf-signalling?orgId=1&from=1514835702976&to=1546285302976)*

## What was evaluated?

Bitcoin wallets were evaluated on the following criteria:

- Can I send an RBF signaled transaction?
- Can I replace the original transaction?
- Can I see that an incoming transaction has RBF signaled?
- Can I see an incoming replacement transaction?

Bitcoin block explorers were evaluated on the following criteria:

- Can I see that a transaction has RBF signaled?
- Can I see the original transaction after it has been replaced?

Additionally, usability, in the form of captioned screenshots, were documented
for each criteria.

There are many advanced scenarios which can involve RBF transaction
replacements. For purposes of this study, the test only involved single
transaction replacements.

During the timeframe of analysis, August - November 2018, the aggregate
findings show:

- 6/23 wallets tested support sending RBF transaction in some way
- 2/23 wallets tested have some indication the transaction being received has
  RBF signaled
- 2/12 explorers tested show some indicator that a transaction has RBF signaled

## Some Usability Examples

Below are a few select examples of how different services handle RBF from a
usability perspective. None of the examples is included to be critical of any
particular piece of software, but demonstrating the maturity of RBF’s usability
and support.

Where appropriate, bug reports have been filed.

### Electrum: Show RBF Flag in Tx List

![Electrum subtle labeling of RBF transaction
screenshot](/img/posts/rbf-in-the-wild/rbf-electrum-label.png)

In this example Electrum tags an RBF signaled transaction with a subtle “rbf”
label. Electrum is one of the few wallets that supports RBF for both sending
and receiving.

Labeling an unconfirmed transaction in the wallet with RBF visually identifies
which outgoing transactions can be fee bumped by the user if there is a delay
in confirming. The RBF label also shows which incoming transactions can be fee
bumped by their sender using BIP125.

### Bitcoin Core: Increase Transaction Fee, Almost

![Bitcoin Core increase transaction fee failure
screenshots](/img/posts/rbf-in-the-wild/rbf-bitcoin-core-increase-fee-fails.png)

In this example Bitcoin Core allows the sending of a transaction with RBF
signaled. After the initial transaction broadcast, Bitcoin Core then shows the
“Increase transaction fee” option. However, the fee bump fails during the
actual bumping of the transaction due to a missing change output. There is a
similar user experience if the change address is not large enough to increase
the transaction fee.

BIP125 allows additional inputs to be added to the replacement transaction,
which would resolve these insufficient change output failures. However, this is
not currently possible through the Bitcoin Core UI.

### insight.bitpay.com: No RBF Transactions Shown

![Bitpay's Insight explorer showing error message for unconfirmed RBF
transaction
screenshot](/img/posts/rbf-in-the-wild/rbf-insight-bitpay-no-rbf.png)

While Bitpay’s Insight explorer does show unconfirmed transactions, it does not
show any RBF signaled unconfirmed transactions. This is confusing for users
withdrawing from an exchange that supports RBF as the user will not see their
transaction in the explorer until after it confirms.

### GreenAddress: Offer Multiple Bump Options

![GreenAddress wallet shows a bump fee dropdown with fee options
screenshot](/img/posts/rbf-in-the-wild/rbf-green-multiple-bump-options.png)

GreenAddress allows the user, who is trying to bump an existing transaction, to
choose their fee bump level based on some preselected options. Fiat (USD)
amounts are also shown which means users do not need to do the conversion
manually. The GreenAddress bump fee dialog also has an estimation about the
current fee confirmation level.

### Bitcoin Core: Showing Original Tx Post Confirm

![Bitcoin Core showing 'conflicted' transaction mouse over
screenshot](/img/posts/rbf-in-the-wild/rbf-bitcoin-core-show-original.png)

Bitcoin Core shows the original transaction as failed (with X icon) after a
bumped transaction replaces it and confirms (with checkmark icon). A tooltip
shows the address that the replacement transaction spent to (which is usually
the same as the original).

### GreenAddress: Visual RBF Flag in Tx List

![GreenAddress labeling of RBF transaction
screenshot](/img/posts/rbf-in-the-wild/rbf-green-rbf-label.png)

GreenAddress shows a visual RBF flag (“replaceable”) in the Tx list. Also noted
is the fact that there is a double spend since a replacement transaction has
already been broadcast in this example.

### Bitpay: Overt RBF Warning

![Bitpay payment receipt showing RBF warnings
screenshot](/img/posts/rbf-in-the-wild/rbf-bitpay-overt-warnings.png)

Bitpay shows an explicit warning for RBF transactions saying that there may be
a delay in processing. Bitpay also recommends "To avoid this delay in the
future disable the RBF setting in your wallet". These messages are misleading
and also infer that unconfirmed "non RBF" signaled transactions are not
replaceable.

Any unconfirmed transaction risks being replaced for a variety of reasons
including the spender broadcasting more than one transaction spending the same UTXO ([example][todd reddit gold]),
the spender directly mining a different transaction spending the same UTXO ([Finney attack][]), or the spender working with
a miner to get a different transaction spending the same UTXO included in a
block ([example][betcoin dice]).

### Explorer blocktrail.com: RBF Visual Label

![blocktrail.com explorer transaction details showing opt-in rbf label
screenshot](/img/posts/rbf-in-the-wild/rbf-blocktrain-rbf-label.png)

Blocktrail shows an orange opt-in RBF label and also a mouseover detail for the
user providing more information.

### Samourai: Silently Fail Transaction Bump

![Samourai wallet increase transaction fee dialog
screenshot](/img/posts/rbf-in-the-wild/rbf-samourai-fail-bump.png)

Similar to the Bitcoin Core example above, there was a problem with fee bumping
the transaction. However, in this case, there was a silent failure and no
message for the user on what happened. There were sufficient funds in the
wallet for a replacement transaction.

Additional testing showed that fee bumping is possible in Samourai and perhaps
this is an edge case in the code involving the change address or additional
inputs.

### Coinbase: Original Transaction Pending

![Coinbase transaction list showing pending transaction
screenshot](/img/posts/rbf-in-the-wild/rbf-coinbase-original-transaction-pending.png)

Coinbase shows both the original and replacement transaction in the transaction
list. The original transaction remained as 'pending' even after the replacement
received 6+ confirmations.

Note: Coinbase account balance was not affected. Optech is in communication
with Coinbase regarding this and they are working on a fix.

### GreenAddress: Associate RBF Transactions

![GreenAddress transaction details and transaction list
screenshots](/img/posts/rbf-in-the-wild/rbf-green-associate-rbf-transactions.png)

GreenAddress has two places in the UI where the original and replacement
transaction are associated. On the left, the transaction details screen  of the
replacement transaction notes a “Double spend by txhash” field which is the
transaction ID of the original transaction. The screenshot on the right of the
transaction list shows an expandable section which lists any original
transactions that have been replaced by this replacement transaction.

### Samourai: Credit Balance of Original Transaction

![Samourai wallet transaction list before and after balance update
screenshots](/img/posts/rbf-in-the-wild/rbf-samourai-credit-balance-with-rbf.png)

Samourai wallet shows both the original and replacement transaction with no RBF
label. Additionally, the balance was actually credited for both transactions.
Within an hour, and before the replacement transaction confirmed, the original
transaction was discarded and the correct balance appeared (right image).

A user seeing two normal looking transactions and an increased balance might be
confused when the transaction later disappears and their balance is smaller.

### Xapo: Email Notifications for Unconfirmed Txs

![Xapo emails showing incoming transactions
screenshot](/img/posts/rbf-in-the-wild/rbf-xapo-email-notifications.png)

Xapo sends email confirmations for both the original and replacement
transaction which might indicate to a receiver that they will get 2,000 bits
total via two transactions, instead of the actual 1,000 bits total in one
transaction in this example.

### Ledger Live: Error

![Ledger Live's Portfolio showing red error message
screenshot](/img/posts/rbf-in-the-wild/rbf-ledger-dashboard-sync-error-message.png)

Ledger Live’s internal database was corrupted by the replacement transaction.

Note: The fix was to reinstall Ledger Live. Optech is in communication with
Ledger regarding this issue.

### Electrum: Advanced Control of RBF Fee Bump

![Electrum's dialog of advanced fee bumping options including slider and textbox
screenshot](/img/posts/rbf-in-the-wild/rbf-electrum-advanced-rbf-options.png)

Electrum allows more advanced control of the fees in the UI. Additionally the
dialog provides the capability to mark the transaction as final.

### BRD: Generic Error Messages

![BRD wallet transactions list screen showing a failed transaction
screenshot](/img/posts/rbf-in-the-wild/rbf-brd-transaction-list-incoming-bumped.png)

BRD shows a “Failed” label on the replacement transaction. In testing, the
“Failed” transaction actually ends up being the transaction that confirms.

## Usability Considerations

A blanket recommendation for wallets, explorers, and other Bitcoin services
would be to support opt-in RBF. Most of the services tested in this study do
not have any support for RBF. As congestion builds on the network in the
future, RBF will be an important tool in the scaling toolbox.

Based on some of the examples above, there are some additional recommendations
regarding RBF support.

### Explorers Redirect to Replacement Transaction

In almost all explorers, attempting to view the original transaction after the
replacement confirms results in a 404 error. This can be confusing for users
that have previously visited the original transaction's page on the explorer
site and come back to find it has disappeared.

Explorers should consider 301 redirects from the original to the replaced
transaction that eventually confirms. Especially when the original transaction
has been viewed by a visitor via that explorer. The redirection should be
accompanied with an alert message indicating the original transaction has been
replaced by the current transaction.

### Persist Original Transactions

This recommendation is similar to previous one, only applied to wallets instead
of explorers.

Original transactions should be persisted in the UI, even subtly or under an
advanced dialog. When sending a replacement transaction, a user may still want
to have a reference to previously attempted, never-to-confirm transaction in
their wallet.

Persisting original transactions might not always be possible. For example, if
the wallet is a light client or is not online when an incoming original
transaction was broadcast, it might only see the replacement transaction.

### Use RBF-Compatible Block Explorers

Wallets that support RBF and do not provide block explorer details within the
app itself, should link to an RBF-compatible block explorer. This will provide
a consistent experience for the user as transactions will not “disappear” when
transitioning from the RBF-supporting app to the non-RBF-supporting explorer.

### Link to Block Explorer's Address Page

Wallets/Exchanges should consider linking to the block explorer’s “address”
page instead of “transaction” page. This can simplify the fact that
transactions might be replaced/disappear from the explorer while also providing
a single reliable link where someone can view the transaction.

It is preferable that the explorer implement a redirect scheme similar to the
one outlined above, however, this is a more user friendly alternative if that
option is not available.

### Label Transactions Signaling opt-in RBF

Transactions signaling RBF could be visually labeled both in transaction list
and transaction detail screens. Alternatively, RBF-signaling transactions could
be the default and NON RBF transactions get an “unbumpable” type label. Such a
label is most useful for letting a user know which of their transactions are
BIP125 replaceable. Ultimately, any unconfirmed transaction can be replaced.

### Don't Trigger Based on Unconfirmed Transactions

Triggering actions (emails, internal processes, etc) based on an unconfirmed tx
is potentially confusing for users. Notification messaging like “You have
received .5 BTC” should be avoided as transaction replacements can trigger
multiple times giving the recipient the wrong impression of what has taken
place. If you want to email based on unconfirmed transactions, make sure to
word the notification appropriately. Similarly, triggering back office
processes based on unconfirmed transactions is also dangerous.

## Wallet Compatibility

Given the warm reception this study has received so far, a follow up study
regarding Bech32 support across wallets and explorers is in the works.

As more metrics are collected, a better format for collecting and displaying
the results will be a dedicated Optech Wallet Compatibility website.

If you have a suggestion of additional metrics that you think are valuable or
Bitcoin services that you would like to see evaluated in the future, please
reach out to [mike@bitcoinops.org](mailto:mike@bitcoinops.org).

## Resources

- [BIP125 opt-in Full Replace-by-Fee Signaling](https://github.com/bitcoin/bips/blob/master/bip-0125.mediawiki)
- [Bitcoin Wiki’s Techniques to reduce transaction fees](https://en.bitcoin.it/wiki/Techniques_to_reduce_transaction_fees#opt-in_transaction_replacement)
- [Bitcoincore.org’s opt-in RBF FAQ](https://bitcoincore.org/en/faq/optin_rbf/)
- [Bitcoin Wiki’s Transaction Replacement](https://en.bitcoin.it/wiki/Transaction_replacement)
- [Bitcoin Optech’s Scaling Book](https://github.com/bitcoinops/scaling-book)

## Footnotes

[^closing_lightning_channels]:
    Lightning (and other similar systems) rely on exchanging pre-signed
    transactions which may or may not be broadcast at an undetermined point in
    future. It is impossible to predict what the feerate should be set to at the
    time of signing. There is [currently discussion][lightning cpfp carve-out] on
    the Bitcoin and Lightning dev mailing lists about making exceptions to the
    standard mempool policy rules so fee-bumping can be done more predictably
    by users of second layer protocols.

{% include references.md %}
[optech team]: /about/
[announcement]: /en/announcing-bitcoin-optech/
[workshops]: /workshops/
[newsletters]: /en/newsletters/
[dashboard]: https://dashboard.bitcoinops.org/
[dashboard blog post]: /en/dashboard-announcement/
[scaling book]: https://github.com/bitcoinops/scaling-book
[scaling book feebumping]: https://github.com/bitcoinops/scaling-book/blob/master/1.fee_bumping/fee_bumping.md
[softfork]: /en/newsletters/2018/12/18/#news
[lightning cpfp carve-out]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2018-November/016518.html
[finney attack]: https://bitcoin.stackexchange.com/questions/4942/what-is-a-finney-attack
[todd reddit gold]: https://www.coingecko.com/buzz/peter-todd-explains-how-he-double-spent-coinbase
[betcoin dice]: https://bitcointalk.org/index.php?topic=327767.0
