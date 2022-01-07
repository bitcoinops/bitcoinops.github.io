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

FIXME:glozow

{% include functions/details-list.md
  q0="FIXME"
  a0="FIXME"
  a0link="https://bitcoincore.reviews/FIXME#l-21"
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
{% include linkers/issues.md issues="23882,2117,5964,912,950" %}
[rubin feea]: https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2022-January/019724.html
[news116 sponsorship]: /en/newsletters/2020/09/23/#transaction-fee-sponsorship
[news168 stateless]: /en/newsletters/2021/09/29/#stateless-ln-invoice-generation
