---
title: 'Bitcoin Optech Newsletter #89'
permalink: /en/newsletters/2020/03/18/
name: 2020-03-18-newsletter
slug: 2020-03-18-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter summarizes an update to a proposed standard for
LN and includes our regular sections about notable changes to services,
client software, and popular Bitcoin infrastructure projects.

## Action items

*None this week.*

## News

- **Proposed watchtower BOLT has been updated:** Sergi Delgado Segura
  [emailed][segura email] the Lightning-Dev mailing list an [updated
  version][watchtower bolt] of a suggested protocol for
  [watchtower][topic watchtowers] communication.  See [Newsletter
  #75][news75 watchtower] for our original description of this proposal.  According to
  Segura, the update includes details about "user accounts, payment
  methods, and message signing."  His email also provides a list of
  features he would like to add, with discussion about each near the end
  of the email.

## Changes to services and client software

*In this monthly feature, we highlight interesting updates to Bitcoin
wallets and services.*

- **Coinbase withdrawal transactions now using batching:** Coinbase has rolled
out [batch withdrawals][coinbase batching blog] that they estimate will reduce
their load on the Bitcoin network by 50%. Instead of each withdrawal payment
generating a single onchain transaction, multiple payments will be
[combined into a single transaction][scaling payment batching] once every 10 minutes.

- **Bitstamp supports bech32:** Bitstamp users can now benefit from using native
[bech32][topic bech32] addresses after the exchange announced support for both
[bech32 deposits and withdrawals][bitstamp bech32 blog].

- **Deribit supports bech32 withdrawals:** [Deribit announced][deribit bech32
withdrawal tweet] that its exchange users can now withdraw bitcoins to bech32
native addresses.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #16902][] changes consensus code to fix an inefficiency
  in the parsing of `OP_IF` and related opcodes.  In legacy and segwit
  v0 script, the inefficiency isn't believed to cause any significant
  problems. However, the proposal for [tapscript][topic tapscript] would
  make it possible for an attacker to use the inefficiency to create blocks with transactions
  that could take a large amount of CPU to verify.  Fixing the
  inefficiency now reduces the number of changes that need to be made in the
  proposed schnorr, taproot, and tapscript soft fork.  For more
  information, see the Bitcoin Core PR Review Club [meeting notes][club
  #16902] about this PR.

- [LND #3821][] adds [anchor commitments][topic anchor outputs] for
  LN channels and enables them by default if both participating nodes of a
  channel signal support. Anchor commitment transactions can be fee
  bumped unilaterally by either party, which is useful because
  commitment transactions might be broadcast a long time after they
  commit to their on-chain feerate.

- [LND #3963][] adds detailed [documentation][lnd op safety] about how
  to use LND safely.

- [Eclair #1319][] implements the same solution as described in
  [Newsletter #85][news85 ln stuck] for a rare stuck-channels problem
  where payments are rejected for insufficient funds when the channel
  funder is receiving the money but doesn't have enough balance to
  afford the payment's commitment (HTLC) cost.

{% include references.md %}
{% include linkers/issues.md issues="16902,3821,3963,1319" %}
[lnd op safety]: https://github.com/lightningnetwork/lnd/blob/master/docs/safety.md
[segura email]: https://lists.linuxfoundation.org/pipermail/lightning-dev/2020-March/002586.html
[watchtower bolt]: https://github.com/sr-gi/bolt13/blob/master/13-watchtowers.md
[club #16902]: https://bitcoincore.reviews/16902/
[news75 watchtower]: /en/newsletters/2019/12/04/#proposed-watchtower-bolt
[news85 ln stuck]: /en/newsletters/2020/02/19/#c-lightning-3500
[coinbase batching blog]: https://blog.coinbase.com/coinbase-rolls-out-bitcoin-transaction-batching-5f6d09b8b045
[bitstamp bech32 blog]: https://www.bitstamp.net/article/weve-added-support-bech32-bitcoin-addresses-bitsta/
[deribit bech32 withdrawal tweet]: https://twitter.com/DeribitExchange/status/1234904442169851909