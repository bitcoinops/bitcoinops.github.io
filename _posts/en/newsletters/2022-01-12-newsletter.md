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

- [Bitcoin Core #23882][] doc: testnet3 was not reset and is doing BIP30 checks again FIXME:Xekyo (we wouldn't usually cover a small documentation change like this, but I'm personally curious *why* BIP30 checks are needed again at this height, what implications that has for testnet (e.g., don't BIP30 checks require a full tx index, i.e. no pruning?), and what further implications that may have for mainnet when it reaches the same height.  Of course, if the answers to all of these questions are boring, we should just drop this summary of a tiny change to a code comment)

- [Eclair #2117][] Process replies to onion messages FIXME:dongcarl

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

- [BOLTs #950][] Really: BOLT 1: introduce warning messages, reduce requirements to send (hard) errors FIXME:adamjonas

{% include references.md %}
{% include linkers/issues.md issues="23882,2117,5964,912,950,23443" %}
[rubin feea]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019724.html
[news116 sponsorship]: /en/newsletters/2020/09/23/#transaction-fee-sponsorship
[news168 stateless]: /en/newsletters/2021/09/29/#stateless-ln-invoice-generation
[reviews 23443]: https://bitcoincore.reviews/23443
