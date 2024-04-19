---
title: 'Bitcoin Optech Newsletter #84'
permalink: /en/newsletters/2020/02/12/
name: 2020-02-12-newsletter
slug: 2020-02-12-newsletter
type: newsletter
layout: newsletter
lang: en
---
This week's newsletter seeks help testing a Bitcoin Core release
candidate and summarizes some discussion about the BIP119
`OP_CHECKTEMPLATEVERIFY` proposal.  Also included is our regular section
about notable code and documentation changes.

## Action items

- **Help test Bitcoin Core 0.19.1rc1:** this upcoming maintenance
  [release][bitcoin core 0.19.1] includes several bug fixes.
  Experienced users are encouraged to help test for any regressions or
  other unexpected behavior.

## News

- **`OP_CHECKTEMPLATEVERIFY` (CTV) Workshop:** video ([morning][ctv
  morning vid], [afternoon][ctv afternoon vid]) and a [transcript][ctv
  transcript] are available from a recent workshop about [BIP119][] CTV.
  If this proposed soft fork is adopted, users would be able to use a
  new CTV opcode to create [covenants][topic covenants] with less
  interaction than would be required using current consensus rules.
  Several possible applications of the opcode were discussed, with most
  attention being focused on vaults and compressed payment batching
  (sometimes called *congestion control transactions*, see [Newsletter #48][news48 cc]).  A significant
  part of the workshop also consisted of critical feedback from the
  audience and replies to the criticism.  A final discussion covered how
  and when to attempt to get BIP119 activated, including when a PR for
  it should be opened to the Bitcoin Core repository, what activation
  mechanism it should use (e.g.  [BIP9][] versionbits), and what range
  of activation dates would be appropriate if it uses a miner-activated
  soft fork mechanism such as BIP9.

  Subsequent to
  the workshop, CTV proposer Jeremy Rubin announced a [mailing
  list][ctv mailing list] to help coordinate future review and
  discussion of the BIP119 proposal.

## Notable code and documentation changes

*Notable changes this week in [Bitcoin Core][bitcoin core repo],
[C-Lightning][c-lightning repo], [Eclair][eclair repo], [LND][lnd repo],
[libsecp256k1][libsecp256k1 repo], [Bitcoin Improvement Proposals
(BIPs)][bips repo], and [Lightning BOLTs][bolts repo].*

- [Bitcoin Core #17585][] deprecates the `label` field returned by the
  `getaddressinfo` RPC as the `labels` (plural) field already exists and provides
  the same functionality. The `label` field is expected to be removed in 0.21; for
  compatibility, the old behavior can be re-enabled in the interim by launching
  `bitcoind` with `-deprecatedrpc=label`. This change is the final one in a series
  of changes to clean up the `getaddressinfo` RPC interface (including a
  PR covered in [Newsletter #80][news80 label]).

- [Bitcoin Core #18032][] extends the results of the `createmultisig`
  and `addmultisigaddress` RPCs to include a `descriptor` field that
  contains an [output script descriptor][topic descriptors]
  for the created multisig address.  Providing a descriptor here makes it
  easier for the user (or a program that is calling this RPC) to get all
  the information they need to not only monitor for payments received to
  the created address but to also later create unsigned transactions
  which start the process of spending that money.

- [C-Lightning #3475][] allows a plugin hook to return `{ "result" :
  "continue" }` to tell `lightningd` to process the action the same way
  it would without the hook being executed.  This makes it easy for
  hooks to only execute in special cases.

- [C-Lightning #3372][] allows the user to specify an alternative
  program to use instead of one of the default sub-daemons (the
  C-Lightning system consists of multiple interacting daemons, referred
  to as *sub-daemons* of `lightningd`).  For example (from the PR
  description):

  ```
  # Use remote_hsmd instead of lightning_hsmd for signing:
  lightningd --alt-subdaemon=lightning_hsmd:remote_hsmd ...
  ```

  This option can be dangerous if the alternative sub-daemon isn't fully
  compatible with the other daemons being used, but it also allows
  improved flexibility and may simplify some testing.

- [C-Lightning #3465][] implements anti fee sniping for withdrawal
  transactions, similar to LND's implementation of the same thing (see
  [Newsletter #18][news18 afs]).  Anti fee sniping uses the nLockTime
  field to prevent a transaction from being included in any block whose
  height is lower than that of the tip of the block chain when the
  transaction was produced.  This limits the ability of a miner who is
  reorganizing (forking) the chain from being able to arbitrarily
  rearrange transactions to maximize their fee revenue.

- [LND #3957][] adds some code that can be used in later PRs that add
  Atomic Multipath Payments (AMP).  AMP is another type of [multipath
  payment][topic multipath payments] similar to the "base" or "basic"
  type already supported by C-Lightning, Eclair, and LND.  AMP is harder
  for routing nodes to distinguish from normal single-part payments and
  can guarantee that the receiver either claims all parts of the payment
  or none of it.

- [BOLTs #684][] updates [BOLT7][] to suggest that nodes send their own
  generated announcements even when the remote peer requests a filter
  that would suppress that announcement.  This can help ensure that a
  node gets announced to the network via its direct peers without
  otherwise changing how filtering works.

{% include references.md %}
{% include linkers/issues.md issues="18032,3475,3372,3465,3957,684,17585" %}
[bitcoin core 0.19.1]: https://bitcoincore.org/bin/bitcoin-core-0.19.1/
[ctv morning vid]: https://twitter.com/JeremyRubin/status/1223672458516938752
[ctv afternoon vid]: https://twitter.com/JeremyRubin/status/1223729378946715648
[news18 afs]: /en/newsletters/2018/10/23/#lnd-1978
[ctv transcript]: https://diyhpl.us/wiki/transcripts/ctv-bip-review-workshop/
[ctv mailing list]: https://mailman.mit.edu/mailman/listinfo/bip-0119-review
[news48 cc]: /en/newsletters/2019/05/29/#proposed-transaction-output-commitments
[news80 label]: /en/newsletters/2020/01/15/#bitcoin-core-17578
