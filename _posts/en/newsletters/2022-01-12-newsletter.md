---
title: 'Bitcoin Optech Newsletter #182'
permalink: /en/newsletters/2022/01/12/
name: 2022-01-12-newsletter
slug: 2022-01-12-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter describes an idea to add accounts to Bitcoin for
paying transaction fees and includes our regular sections with the
summary of a Bitcoin Core PR Review Club meeting and descriptions of notable changes to
popular Bitcoin infrastructure projects.

## News

- **Fee accounts:** Jeremy Rubin [posted][rubin feea] to the Bitcoin-Dev
  mailing list the rough idea for a soft fork that could make it easier
  to add fees to presigned transactions, such as those used in LN and
  other contract protocols.  The idea is an outgrowth of his transaction
  sponsorship idea described in [Newsletter #116][news116 sponsorship].

    The basic idea for fee accounts is that users could create
    transactions that deposited bitcoins into an account tracked by
    upgraded full nodes that understood the new consensus rules.  When
    the user subsequently wanted to add fees to a transaction, they
    would sign a short message containing the amount they wanted to pay
    plus the txid of that transaction.  Upgraded full nodes would allow
    any block containing both the transaction and the signed message to
    pay the miner of that block the signed fee amount.

    Rubin suggests that this would eliminate many problems with
    [CPFP][topic cpfp] and [RBF][topic rbf] fee bumping related to
    contract protocols where two or more users shared ownership of a
    UTXO, or other cases where the use of presigned transactions meant
    the current network feerates couldn't have been known when the
    transaction was signed in the past.

## Bitcoin Core PR Review Club

*In this monthly section, we summarize a recent [Bitcoin Core PR Review Club][]
meeting, highlighting some of the important questions and answers.  Click on a
question below to see a summary of the answer from the meeting.*

[Erlay support signaling][reviews 23443] is a PR by Gleb Naumenko to add
transaction reconciliation negotiation to p2p code. It is part of a series of
PRs to add support for [Erlay][topic erlay] to Bitcoin Core. The review club
meeting discussed the reconciliation handshake protocol and weighed the
advantages and disadvantages of splitting large projects into smaller chunks.

{% include functions/details-list.md
  q0="What are the benefits of splitting PRs into smaller parts? Are there any
drawbacks to this approach?"
  a0="Splitting a large PR into smaller chunks helps encourage more focused and
thorough review on a PR before merge without forcing reviewers to consider huge
change sets at a time, and it reduces the chance of running into review
obstacles due to Github scalability issues. Non-controversial and mechanical
code changes can be merged more quickly, and contentious bits can be discussed
over more time. However, unless reviewers conceptually agree with the full
change set, they are trusting that the author is taking them in the right
direction. Also, since the merge is not atomic, the author needs to ensure that
the intermediate states aren't unsafe or doing something nonsensical, such as
announcing support for Erlay before nodes are actually able to do reconciliation."
  a0link="https://bitcoincore.reviews/23443#l-29"

  q1="When are nodes supposed to announce reconciliation support?"
  a1="Nodes should only send `sendrecon` to a peer if transaction relay on this
connection is on: the node is not in blocksonly mode, this isn't a
block-relay-only connection, and the peer didn't send `fRelay=false`. The peer
must also support witness transaction identifier (wtxid) relay, because sketches
for transaction reconciliation are based on the transaction wtxids."
  a1link="https://bitcoincore.reviews/23443#l-51"

  q2="What is the overall handshake and 'registration for reconciliation'
protocol flow?"
  a2="After `version` messages are sent, but before `verack` messages are sent,
peers each send a `sendrecon` message containing information such as their
locally-generated salt. There is no enforced order; either peer may send it
first. If a node sends and receives a valid `sendrecon` message, it should
initialize the reconciliation state for that peer."
  a2link="https://bitcoincore.reviews/23443#l-63"

  q3="Why doesn't Erlay include a p2p protocol version bump?"
  a3="A new protocol version is not necessary for things to work; nodes using
Erlay would not be incompatible with the existing protocol. Older nodes that
don't understand Erlay messages such as `sendrecon` would simply ignore them
and still be able to function normally."
  a3link="https://bitcoincore.reviews/23443#l-78"

  q4="What is the reason for generating local per-connection salts? How is it
generated?"
  a4="A connection's reconciliation salt is the combination of both peers'
locally-generated salts and is used to create shortids for each transaction. The
salted hash function used for shortids is designed to efficiently create compact
ids, but is not guaranteed to be secure against collisions if an attacker can
control what the salt is. When both sides contribute to the salt, no third-party
can control what the salt is. Locally, a new salt is generated for each
connection so that the node cannot be fingerprinted this way."
  a4link="https://bitcoincore.reviews/23443#l-93"
%}

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[Rust-Lightning][rust-lightning repo], [libsecp256k1][libsecp256k1
repo], [Hardware Wallet Interface (HWI)][hwi repo],
[Rust Bitcoin][rust bitcoin repo], [BTCPay Server][btcpay server repo],
[BDK][bdk repo], [Bitcoin Improvement Proposals (BIPs)][bips repo], and
[Lightning BOLTs][bolts repo].*

- [Bitcoin Core #23882][] contains an update of the documentation
  in `validation.cpp` regarding the operation of testnet3.

  In the original version of Bitcoin, it was possible for transactions to have identical content
  and thus colliding txids. The duplication issue could especially occur
  with coinbase transactions for which the composition of input and
  outputs was partially the same for every coinbase transaction <!--
  e.g. the outpoint being all 00s --> and otherwise determined entirely
  by the creator of a block template. The
  mainnet blockchain contains two duplicate coinbase transactions, at height
  91,842 and 91,880. They are identical to previous coinbase
  transactions and overwrote existing coinbase outputs before they were
  spent, reducing total available supply by 100 BTC.  These incidents
  prompted the introduction of [BIP30][] which forbade duplicate
  transactions. Enforcement of BIP30 was [implemented][bip30-impl]
  by checking for each transaction whether any UTXOs existed for the
  respective txid already. The duplication issue
  was effectively prevented by the subsequent introduction of [BIP34][] which
  required the block's height as the first item in a
  coinbase transaction's scriptSig. Since the height is unique, the
  content of coinbases could no longer be identical at different heights,
  which also prevents the issue in descendant transactions inductively.
  Thus it removed the need to perform extra checks for duplicates.

  It was later shown that [BIP34][] was flawed in that there already
  existed some coinbase transactions before [BIP34][]'s introduction
  that matched the height pattern for future block heights. The
  first block height at which a miner would be able to produce
  a BIP30-violating collision is at 1,983,702, which we expect after the
  year 2040 on mainnet. However, testnet3 has meanwhile exceeded the height
  of 1,983,702. Bitcoin Core thus reverted to performing
  the checks for duplicate unspent transactions on every testnet transaction.

- [Eclair #2117][] adds support for processing [onion message][topic onion
  messages] replies in preparation for supporting the [offers protocol][topic
  offers].

- [LND #5964][] adds a `leaseoutput` RPC that tells the wallet not to
  spend the indicated UTXO for a specified period of time.  This is
  similar to RPCs offered by other wallet software, such as Bitcoin
  Core's `lockunspent`.

- [BOLTs #912][] adds a new optional field to [BOLT11][] invoices for
  metadata provided by the receiver.  If the field is used in an
  invoice, the spending node may need to include the metadata in the
  payment message it routes through the network to the receiver.  The
  receiver can then use the metadata as part of processing the payment,
  such as the [originally proposed][news168 stateless] use of this
  information for enabling [stateless invoices][topic stateless
  invoices].

- [BOLTs #950][] introduces backward compatible warning messages to
  [BOLT1][] and reduces requirements to send fatal errors, avoiding
  unnecessary channel closure. This is the first step toward more
  standardized and enriched errors. More discussion can be found at
  [BOLTs #834][] and in
  [[Carla Kirk-Cohen]]'s [post][Error Codes for LN] to the Lightning-dev
  mailing list (see [Newsletter #136][news136 warning post]).

{% include references.md %}
{% include linkers/issues.md issues="23882,2117,5964,912,950,834,23443" %}
[rubin feea]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019724.html
[news116 sponsorship]: /en/newsletters/2020/09/23/#transaction-fee-sponsorship
[news168 stateless]: /en/newsletters/2021/09/29/#stateless-ln-invoice-generation
[reviews 23443]: https://bitcoincore.reviews/23443
[Error Codes for LN]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2021-February/002964.html
[news136 warning post]: /en/newsletters/2021/02/17/#c-lightning-4364
[bip30-impl]: https://github.com/bitcoin/bitcoin/pull/915/files
